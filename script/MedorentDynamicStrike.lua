-- =========================================================================
-- MEDORENT DYNAMIC STRIKE
-- Missione addestramento AG modulare: HELI CAS + A-10 CAS + SEAD
-- Minaccia aerea opzionale: OFF di default per AG puro
-- =========================================================================
--
-- REQUISITI MISSION EDITOR (Late Activation templates):
--  - DS_CAS_SOFT_1..N
--  - DS_CAS_ARMOR_1..N
--  - DS_SHORAD_1..N
--  - DS_SEAD_SAM_1..N
--  - DS_AIR_THREAT_1..N (opzionale)
--
-- NOTA IMPORTANTE:
--  - I gruppi GROUND usano di default la posizione e la route del template nel ME.
--  - Quindi: se vuoi convogli su strada e dentro l'area, piazza i template su strada
--    e disegna una route che resti dentro la tua trigger zone.
--  - Solo la minaccia aerea usa lo spawn random in zona.
--
-- REQUISITI ZONE:
--  - ZONE_DS_TARGET_LANE
--  - ZONE_DS_AIR_SPAWN (solo se minaccia aerea ON)
--
-- Uso:
--  - Menu F10 coalizione BLUE -> Dynamic Strike
--  - Start / Stop / Reset
--  - Set Difficulty 1..5
--  - Toggle Air Threat (ON/OFF)
-- =========================================================================

local DYNAMIC_STRIKE_CONFIG = {
  mission_name = "DynamicStrike",
  coalition_side = coalition.side.BLUE,

  active = false,
  current_wave = 0,
  max_waves = 6,
  difficulty = 1,
  enable_air_threat = false,

  auto_next_wave = true,
  wave_interval_sec = 420,

  debug_mode = false,

  zones = {
    target_lane = "ZONE_DS_TARGET_LANE",
    air_spawn = "ZONE_DS_AIR_SPAWN",
  },

  templates = {
    soft_prefix = "DS_CAS_SOFT_",
    armor_prefix = "DS_CAS_ARMOR_",
    shorad_prefix = "DS_SHORAD_",
    sam_prefix = "DS_SEAD_SAM_",
    air_prefix = "DS_AIR_THREAT_",
  },

  spawn_mode = {
    soft = "template",    -- posizione/route esatte del template nel ME
    armor = "template",   -- posizione/route esatte del template nel ME
    shorad = "template",  -- statico o micro-route preparata nel ME
    sam = "template",     -- statico o micro-route preparata nel ME
    air = "zone",         -- spawn random nella air zone
  },

  -- Quanti template esistono per categoria.
  -- Minimo assoluto: 1 per categoria (5 template totali nel ME, script funziona uguale).
  -- Consigliato:     2 per categoria (10 template totali: uno leggero, uno pesante).
  -- La varieta' e' garantita da mix template + quantita' random.
  -- Se usi 1 solo template per categoria, imposta tutti a 1.
  template_count = {
    soft   = 2,   -- DS_CAS_SOFT_1 .. DS_CAS_SOFT_2
    armor  = 2,   -- DS_CAS_ARMOR_1 .. DS_CAS_ARMOR_2
    shorad = 2,   -- DS_SHORAD_1 .. DS_SHORAD_2
    sam    = 2,   -- DS_SEAD_SAM_1 .. DS_SEAD_SAM_2
    air    = 1,   -- DS_AIR_THREAT_1  (opzionale, solo se Air Threat ON)
  },

  qty = {
    soft = {
      [1] = {2, 3}, [2] = {3, 4}, [3] = {4, 5}, [4] = {5, 6}, [5] = {6, 7},
    },
    armor = {
      [1] = {1, 2}, [2] = {2, 3}, [3] = {2, 4}, [4] = {3, 5}, [5] = {4, 6},
    },
    shorad = {
      [1] = {0, 1}, [2] = {1, 2}, [3] = {2, 3}, [4] = {2, 4}, [5] = {3, 5},
    },
    sam = {
      [1] = {0, 1}, [2] = {1, 1}, [3] = {1, 2}, [4] = {2, 2}, [5] = {2, 3},
    },
    air = {
      [1] = {0, 1}, [2] = {1, 1}, [3] = {1, 2}, [4] = {2, 2}, [5] = {2, 3},
    },
  },
}

local DynamicStrike = {
  spawned_groups = {},
  schedulers = {},
  menus = {},
  initialized = false,
}

local function DS_Message(msg, duration)
  MESSAGE:New("[DynamicStrike] " .. msg, duration or 12):ToCoalition(DYNAMIC_STRIKE_CONFIG.coalition_side)
end

local function DS_LogInfo(msg)
  env.info("DynamicStrike: " .. msg)
  if DYNAMIC_STRIKE_CONFIG.debug_mode then
    DS_Message("DEBUG: " .. msg, 8)
  end
end

local function DS_ClampDifficulty(v)
  if v < 1 then return 1 end
  if v > 5 then return 5 end
  return v
end

local function DS_Rand(min_v, max_v)
  return math.random(min_v, max_v)
end

local function DS_GetQtyRange(table_cfg, difficulty)
  local r = table_cfg[difficulty]
  return r[1], r[2]
end

local function DS_ValidateTemplate(template_name)
  local g = GROUP:FindByName(template_name)
  return g ~= nil
end

local function DS_PickTemplate(prefix, max_count)
  local idx = DS_Rand(1, max_count)
  return prefix .. tostring(idx)
end

local function DS_PickUniqueTemplates(prefix, max_count, requested_count)
  local pool = {}
  local selected = {}

  for idx = 1, max_count do
    pool[idx] = prefix .. tostring(idx)
  end

  while #pool > 0 and #selected < requested_count do
    local pick_index = DS_Rand(1, #pool)
    table.insert(selected, pool[pick_index])
    table.remove(pool, pick_index)
  end

  return selected
end

local function DS_AddSpawned(group_obj)
  if group_obj then
    table.insert(DynamicStrike.spawned_groups, group_obj)
  end
end

local function DS_AliveCount()
  local alive = 0
  for _, g in ipairs(DynamicStrike.spawned_groups) do
    if g and g:IsAlive() then
      alive = alive + 1
    end
  end
  return alive
end

local function DS_ClearSpawned()
  for _, g in ipairs(DynamicStrike.spawned_groups) do
    if g and g:IsAlive() then
      g:Destroy(false)
    end
  end
  DynamicStrike.spawned_groups = {}
end

local function DS_SpawnTemplateInZone(template_name, zone_name)
  local z = ZONE:FindByName(zone_name)
  if not z then
    DS_LogInfo("Zone non trovata: " .. tostring(zone_name))
    return nil
  end

  if not DS_ValidateTemplate(template_name) then
    DS_LogInfo("Template non trovato: " .. template_name)
    return nil
  end

  local sp = SPAWN:New(template_name)
    :InitLimit(120, 0)
    :InitRandomizePosition(true, 220, 20)
    :InitRandomizeRoute(0, 0, 220)

  return sp:SpawnInZone(z, true)
end

local function DS_SpawnTemplateExact(template_name)
  if not DS_ValidateTemplate(template_name) then
    DS_LogInfo("Template non trovato: " .. template_name)
    return nil
  end

  local sp = SPAWN:New(template_name)
    :InitLimit(120, 0)

  return sp:Spawn()
end

local function DS_SpawnCategoryTemplate(category_name, template_name)
  local mode = DYNAMIC_STRIKE_CONFIG.spawn_mode[category_name] or "template"

  if mode == "zone" then
    local zone_name = DYNAMIC_STRIKE_CONFIG.zones.target_lane
    if category_name == "air" then
      zone_name = DYNAMIC_STRIKE_CONFIG.zones.air_spawn
    end
    return DS_SpawnTemplateInZone(template_name, zone_name)
  end

  return DS_SpawnTemplateExact(template_name)
end

local function DS_SpawnCategory(prefix, max_count, requested_count, category_name, allow_duplicates)
  local templates = {}

  if allow_duplicates then
    for _ = 1, requested_count do
      table.insert(templates, DS_PickTemplate(prefix, max_count))
    end
  else
    templates = DS_PickUniqueTemplates(prefix, max_count, requested_count)
  end

  for _, template_name in ipairs(templates) do
    DS_AddSpawned(DS_SpawnCategoryTemplate(category_name, template_name))
  end
end

local function DS_StopSchedulers()
  for _, scheduler in pairs(DynamicStrike.schedulers) do
    if scheduler then
      scheduler:Stop()
    end
  end
  DynamicStrike.schedulers = {}
end

local function DS_StatusText()
  return string.format(
    "Active=%s | Wave=%d/%d | Diff=%d | AirThreat=%s | Alive=%d",
    tostring(DYNAMIC_STRIKE_CONFIG.active),
    DYNAMIC_STRIKE_CONFIG.current_wave,
    DYNAMIC_STRIKE_CONFIG.max_waves,
    DYNAMIC_STRIKE_CONFIG.difficulty,
    tostring(DYNAMIC_STRIKE_CONFIG.enable_air_threat),
    DS_AliveCount()
  )
end

local function DS_BriefWave()
  local txt = string.format(
    "Wave %d/%d | Diff %d | AirThreat: %s\nHELI CAS: soft + SHORAD\nA-10 CAS: armor + hard targets\nSEAD: neutralizza SAM",
    DYNAMIC_STRIKE_CONFIG.current_wave,
    DYNAMIC_STRIKE_CONFIG.max_waves,
    DYNAMIC_STRIKE_CONFIG.difficulty,
    DYNAMIC_STRIKE_CONFIG.enable_air_threat and "ON" or "OFF"
  )
  DS_Message(txt, 20)
end

function DynamicStrike.SpawnWave()
  if not DYNAMIC_STRIKE_CONFIG.active then
    return
  end

  DYNAMIC_STRIKE_CONFIG.current_wave = DYNAMIC_STRIKE_CONFIG.current_wave + 1
  if DYNAMIC_STRIKE_CONFIG.current_wave > DYNAMIC_STRIKE_CONFIG.max_waves then
    DS_Message("Missione completata: numero massimo ondate raggiunto.", 12)
    DynamicStrike.StopMission()
    return
  end

  local d = DS_ClampDifficulty(DYNAMIC_STRIKE_CONFIG.difficulty)
  DS_Message("Generazione ondata " .. DYNAMIC_STRIKE_CONFIG.current_wave .. " (Diff " .. d .. ")", 10)

  local soft_min, soft_max = DS_GetQtyRange(DYNAMIC_STRIKE_CONFIG.qty.soft, d)
  local armor_min, armor_max = DS_GetQtyRange(DYNAMIC_STRIKE_CONFIG.qty.armor, d)
  local shorad_min, shorad_max = DS_GetQtyRange(DYNAMIC_STRIKE_CONFIG.qty.shorad, d)
  local sam_min, sam_max = DS_GetQtyRange(DYNAMIC_STRIKE_CONFIG.qty.sam, d)
  local air_min, air_max = DS_GetQtyRange(DYNAMIC_STRIKE_CONFIG.qty.air, d)

  local n_soft = DS_Rand(soft_min, soft_max)
  local n_armor = DS_Rand(armor_min, armor_max)
  local n_shorad = DS_Rand(shorad_min, shorad_max)
  local n_sam = DS_Rand(sam_min, sam_max)
  local n_air = DYNAMIC_STRIKE_CONFIG.enable_air_threat and DS_Rand(air_min, air_max) or 0

  DS_SpawnCategory(
    DYNAMIC_STRIKE_CONFIG.templates.soft_prefix,
    DYNAMIC_STRIKE_CONFIG.template_count.soft,
    math.min(n_soft, DYNAMIC_STRIKE_CONFIG.template_count.soft),
    "soft",
    false
  )

  DS_SpawnCategory(
    DYNAMIC_STRIKE_CONFIG.templates.armor_prefix,
    DYNAMIC_STRIKE_CONFIG.template_count.armor,
    math.min(n_armor, DYNAMIC_STRIKE_CONFIG.template_count.armor),
    "armor",
    false
  )

  DS_SpawnCategory(
    DYNAMIC_STRIKE_CONFIG.templates.shorad_prefix,
    DYNAMIC_STRIKE_CONFIG.template_count.shorad,
    math.min(n_shorad, DYNAMIC_STRIKE_CONFIG.template_count.shorad),
    "shorad",
    false
  )

  DS_SpawnCategory(
    DYNAMIC_STRIKE_CONFIG.templates.sam_prefix,
    DYNAMIC_STRIKE_CONFIG.template_count.sam,
    math.min(n_sam, DYNAMIC_STRIKE_CONFIG.template_count.sam),
    "sam",
    false
  )

  DS_SpawnCategory(
    DYNAMIC_STRIKE_CONFIG.templates.air_prefix,
    DYNAMIC_STRIKE_CONFIG.template_count.air,
    n_air,
    "air",
    true
  )

  DS_BriefWave()

  if DynamicStrike.schedulers.wave_monitor then
    DynamicStrike.schedulers.wave_monitor:Stop()
    DynamicStrike.schedulers.wave_monitor = nil
  end

  DynamicStrike.schedulers.wave_monitor = SCHEDULER:New(nil, function()
    if not DYNAMIC_STRIKE_CONFIG.active then
      return
    end

    local alive = DS_AliveCount()
    if alive <= 0 then
      DS_Message("Ondata " .. DYNAMIC_STRIKE_CONFIG.current_wave .. " completata.", 10)
      if DYNAMIC_STRIKE_CONFIG.auto_next_wave then
        if DynamicStrike.schedulers.next_wave then
          DynamicStrike.schedulers.next_wave:Stop()
          DynamicStrike.schedulers.next_wave = nil
        end
        DynamicStrike.schedulers.next_wave = SCHEDULER:New(nil, function()
          if DYNAMIC_STRIKE_CONFIG.active then
            DynamicStrike.SpawnWave()
          end
        end, {}, DYNAMIC_STRIKE_CONFIG.wave_interval_sec)
      end
    end
  end, {}, 30, 30)
end

function DynamicStrike.StartMission()
  if DYNAMIC_STRIKE_CONFIG.active then
    DS_Message("Missione già attiva.", 8)
    return
  end

  local zone_target = ZONE:FindByName(DYNAMIC_STRIKE_CONFIG.zones.target_lane)
  if not zone_target then
    DS_Message("Errore: manca la zona " .. DYNAMIC_STRIKE_CONFIG.zones.target_lane, 15)
    return
  end

  DYNAMIC_STRIKE_CONFIG.active = true
  DYNAMIC_STRIKE_CONFIG.current_wave = 0

  DS_Message("Missione avviata. Ruoli: HELI CAS / A-10 CAS / SEAD.", 12)
  DynamicStrike.SpawnWave()
end

function DynamicStrike.StopMission()
  if not DYNAMIC_STRIKE_CONFIG.active then
    DS_Message("Missione già fermata.", 8)
    return
  end

  DYNAMIC_STRIKE_CONFIG.active = false
  DS_StopSchedulers()
  DS_ClearSpawned()

  DS_Message("Missione fermata e ripulita.", 10)
end

function DynamicStrike.ResetMission()
  if DYNAMIC_STRIKE_CONFIG.active then
    DynamicStrike.StopMission()
  else
    DS_ClearSpawned()
    DS_StopSchedulers()
  end

  DYNAMIC_STRIKE_CONFIG.current_wave = 0
  DS_Message("Reset completato. Pronta per nuovo avvio.", 10)
end

function DynamicStrike.SetDifficulty(level)
  DYNAMIC_STRIKE_CONFIG.difficulty = DS_ClampDifficulty(level)
  DS_Message("Difficoltà impostata a " .. DYNAMIC_STRIKE_CONFIG.difficulty, 8)
end

function DynamicStrike.ToggleAirThreat()
  DYNAMIC_STRIKE_CONFIG.enable_air_threat = not DYNAMIC_STRIKE_CONFIG.enable_air_threat
  DS_Message("Minaccia aerea: " .. (DYNAMIC_STRIKE_CONFIG.enable_air_threat and "ON" or "OFF"), 10)
end

function DynamicStrike.ForceNextWave()
  if not DYNAMIC_STRIKE_CONFIG.active then
    DS_Message("Missione non attiva.", 8)
    return
  end

  DS_ClearSpawned()
  DynamicStrike.SpawnWave()
end

function DynamicStrike.ShowStatus()
  DS_Message(DS_StatusText(), 12)
end

function DynamicStrike.BuildMenu()
  if DynamicStrike.menus.root then
    return
  end

  DynamicStrike.menus.root = MENU_COALITION:New(DYNAMIC_STRIKE_CONFIG.coalition_side, "Dynamic Strike")

  DynamicStrike.menus.start = MENU_COALITION_COMMAND:New(
    DYNAMIC_STRIKE_CONFIG.coalition_side,
    "Start Mission",
    DynamicStrike.menus.root,
    DynamicStrike.StartMission
  )

  DynamicStrike.menus.stop = MENU_COALITION_COMMAND:New(
    DYNAMIC_STRIKE_CONFIG.coalition_side,
    "Stop Mission",
    DynamicStrike.menus.root,
    DynamicStrike.StopMission
  )

  DynamicStrike.menus.reset = MENU_COALITION_COMMAND:New(
    DYNAMIC_STRIKE_CONFIG.coalition_side,
    "Reset Mission",
    DynamicStrike.menus.root,
    DynamicStrike.ResetMission
  )

  DynamicStrike.menus.next_wave = MENU_COALITION_COMMAND:New(
    DYNAMIC_STRIKE_CONFIG.coalition_side,
    "Force Next Wave",
    DynamicStrike.menus.root,
    DynamicStrike.ForceNextWave
  )

  DynamicStrike.menus.status = MENU_COALITION_COMMAND:New(
    DYNAMIC_STRIKE_CONFIG.coalition_side,
    "Status",
    DynamicStrike.menus.root,
    DynamicStrike.ShowStatus
  )

  DynamicStrike.menus.air_toggle = MENU_COALITION_COMMAND:New(
    DYNAMIC_STRIKE_CONFIG.coalition_side,
    "Toggle Air Threat",
    DynamicStrike.menus.root,
    DynamicStrike.ToggleAirThreat
  )

  DynamicStrike.menus.diff_menu = MENU_COALITION:New(
    DYNAMIC_STRIKE_CONFIG.coalition_side,
    "Set Difficulty",
    DynamicStrike.menus.root
  )

  for i = 1, 5 do
    DynamicStrike.menus["difficulty_" .. i] = MENU_COALITION_COMMAND:New(
      DYNAMIC_STRIKE_CONFIG.coalition_side,
      "Difficulty " .. i,
      DynamicStrike.menus.diff_menu,
      function()
        DynamicStrike.SetDifficulty(i)
      end
    )
  end

  env.info("DynamicStrike: menu F10 creato correttamente")
end

local function DynamicStrike_Init()
  if DynamicStrike.initialized then
    return
  end

  DynamicStrike.initialized = true

  if math and math.randomseed then
    math.randomseed(timer.getAbsTime())
  else
    env.warning("DynamicStrike: math.randomseed non disponibile, continuo senza seed esplicito")
  end

  DynamicStrike.BuildMenu()
  DS_Message("Script caricato. Usa F10 -> Dynamic Strike.", 12)
  DS_LogInfo("Inizializzazione completata")
end

SCHEDULER:New(nil, function()
  DynamicStrike_Init()
end, {}, 5)
