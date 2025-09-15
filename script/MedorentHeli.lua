-- 🔧 FIX ISSUE #6: SISTEMA CONVOGLI COMPLETAMENTE RISCRITTO
-- Dichiarazione Trigger
local triggerConvogli1 = ZONE:FindByName("TriggerConv1")
local triggerConvogli2 = ZONE:FindByName("TriggerConv2")
local triggerConvogli3 = ZONE:FindByName("TriggerConv3")
local triggerConvogli4 = ZONE:FindByName("TriggerConv4")

-- ✅ NUOVO: Sistema di tracciamento stato convogli
local ConvoyStatus = {
    convoy1 = { active = false, group = nil, spawn = nil },
    convoy2 = { active = false, group = nil, spawn = nil },
    convoy3 = { active = false, group = nil, spawn = nil },
    convoy4 = { active = false, group = nil, spawn = nil }
}

-- Crea un nuovo Command Center
BlueCCPositionable = GROUP:FindByName("BLUE_HELICOMHQ")
BlueHQ = COMMANDCENTER:New(BlueCCPositionable, "HeliOPS Command Center", "HeliOPS Command Center")

-- Creo la definizione per i Detection Group
local HeliReconGroup = SET_GROUP:New()
HeliReconGroup:FilterPrefixes("HeliRecon")
HeliReconGroup:FilterCoalitions("blue")
HeliReconGroup:FilterStart()

EWGroup = SET_GROUP:New()
EWGroup:FilterPrefixes("EW")
EWGroup:FilterCoalitions("blue")
EWGroup:FilterStart()

-- Creo la zona di rilevamento
local DetectionHeli = DETECTION_AREAS:New(HeliReconGroup, 5000)

-- Creo le missioni
local HeliMissions = MISSION:New(BlueHQ, "HeliOPS Missions", "Primary", "Missioni Heli Medorent", coalition.side.BLUE)

-- Dichiaro il gruppo di Heli che potrà effettuare le missioni
local OPSHeli = SET_GROUP:New()
OPSHeli:FilterPrefixes("Damascus")
OPSHeli:FilterCoalitions("blue")
OPSHeli:FilterStart()

-- Creo i dispatcher e inizializzo
local HeliReconDispatcher = TASK_A2G_DISPATCHER:New( HeliMissions, OPSHeli, DetectionHeli )
BlueHQ:MessageToCoalition("Benvenuti nel Command Center HeliOPS", 30, "Benvenuti")

-- Creo il menu Radio per HeliOPS
local HeliOPSMenu = MENU_COALITION:New(coalition.side.BLUE, "HeliOPS")
local HeliOPSMenuMissioni = MENU_COALITION:New(coalition.side.BLUE, "Missione Convogli Heli", HeliOPSMenu)
local HeliOPSMenuMissioniUtility = MENU_COALITION:New(coalition.side.BLUE, "Utility", HeliOPSMenuMissioni)
local HeliOPSMenuMissioniPattugliaHeli = MENU_COALITION:New(coalition.side.BLUE, "Pattuglia Heli RED", HeliOPSMenuMissioni)
local HeliOPSMenuMissioniAFAC = MENU_COALITION:New(coalition.side.BLUE, "AFAC", HeliOPSMenuMissioniUtility)

-- ✅ SISTEMA AFAC (funziona correttamente)
SpawnAFAC = SPAWN:New("HeliRecon_AFAC1")
SpawnAFAC.InitKeepUnitNames = true
SpawnAFAC:InitLimit( 1, 200 )

local HeliOPSAttivaAFAC = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva AFAC", HeliOPSMenuMissioniAFAC, function ()
    SpawnAFAC:Spawn()
    BlueHQ:MessageToCoalition("AFAC Attivato", 20, coalition.side.BLUE, "AFAC")
end)

local HeliOPSDisattivaAFAC = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva AFAC", HeliOPSMenuMissioniAFAC, function ()
    local spawnedGroup = SpawnAFAC:GetFirstAliveGroup()
    if spawnedGroup then
        spawnedGroup:Destroy()
    end
    BlueHQ:MessageToCoalition("AFAC Disattivato", 20, coalition.side.BLUE, "AFAC")
end)

-- 🔧 NUOVO SISTEMA CONVOGLI COMPLETAMENTE RISCRITTO
local HeliOPSMenuMissioniConvoglio = MENU_COALITION:New(coalition.side.BLUE, "Convogli", HeliOPSMenuMissioni)

-- ✅ Inizializzazione corretta SPAWN (senza InitLimit problematico)
ConvoyStatus.convoy1.spawn = SPAWN:NewWithAlias("REDCON-V1", "Convoglio1")
ConvoyStatus.convoy2.spawn = SPAWN:NewWithAlias("REDCON-V1-1", "Convoglio2") 
ConvoyStatus.convoy3.spawn = SPAWN:NewWithAlias("REDCON-V1-2", "Convoglio3")
ConvoyStatus.convoy4.spawn = SPAWN:NewWithAlias("REDCON-V1-3", "Convoglio4")

-- ✅ FUNZIONE HELPER: Spawn singolo convoglio con controllo stato
local function SpawnSingleConvoy(convoyId, zone)
    local convoy = ConvoyStatus[convoyId]
    
    -- Controlla se già attivo
    if convoy.active and convoy.group and convoy.group:IsAlive() then
        BlueHQ:MessageToCoalition(string.format("❌ %s già attivo!", convoyId), 10, coalition.side.BLUE)
        return false
    end
    
    -- Spawn nuovo gruppo
    local newGroup = convoy.spawn:SpawnInZone(zone)
    if newGroup then
        convoy.group = newGroup
        convoy.active = true
        BlueHQ:MessageToCoalition(string.format("✅ %s attivato con successo", convoyId), 10, coalition.side.BLUE)
        
        -- ✅ NUOVO: Event handler per tracciare distruzione
        function newGroup:OnEventDead()
            env.info(string.format("CONVOY DEBUG: %s destroyed", convoyId))
            convoy.active = false
            convoy.group = nil
        end
        
        return true
    else
        BlueHQ:MessageToCoalition(string.format("❌ Errore spawn %s", convoyId), 10, coalition.side.BLUE)
        return false
    end
end

-- ✅ FUNZIONE HELPER: Destroy singolo convoglio con controllo stato  
local function DestroySingleConvoy(convoyId)
    local convoy = ConvoyStatus[convoyId]
    
    if convoy.active and convoy.group and convoy.group:IsAlive() then
        convoy.group:Destroy()
        convoy.active = false
        convoy.group = nil
        BlueHQ:MessageToCoalition(string.format("🔥 %s disattivato", convoyId), 10, coalition.side.BLUE)
        return true
    else
        BlueHQ:MessageToCoalition(string.format("⚠️ %s già inattivo", convoyId), 10, coalition.side.BLUE)
        return false
    end
end

-- ✅ MENU PRINCIPALE: Attiva tutti i convogli (o riattiva quelli distrutti)
local HeliOPSAttivaConvogli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "🚛 Attiva/Riattiva TUTTI i Convogli", HeliOPSMenuMissioniConvoglio, function ()
    local activated = 0
    
    if SpawnSingleConvoy("convoy1", triggerConvogli1) then activated = activated + 1 end
    if SpawnSingleConvoy("convoy2", triggerConvogli2) then activated = activated + 1 end  
    if SpawnSingleConvoy("convoy3", triggerConvogli3) then activated = activated + 1 end
    if SpawnSingleConvoy("convoy4", triggerConvogli4) then activated = activated + 1 end
    
    BlueHQ:MessageToCoalition(string.format("📊 Sistema Convogli: %d/4 attivati", activated), 20, coalition.side.BLUE)
end)

-- ✅ MENU PRINCIPALE: Disattiva tutti i convogli
local HeliOPSDisattivaConvogli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "🛑 Disattiva TUTTI i Convogli", HeliOPSMenuMissioniConvoglio, function ()
    local deactivated = 0
    
    if DestroySingleConvoy("convoy1") then deactivated = deactivated + 1 end
    if DestroySingleConvoy("convoy2") then deactivated = deactivated + 1 end
    if DestroySingleConvoy("convoy3") then deactivated = deactivated + 1 end
    if DestroySingleConvoy("convoy4") then deactivated = deactivated + 1 end
    
    BlueHQ:MessageToCoalition(string.format("📊 Sistema Convogli: %d/4 disattivati", deactivated), 20, coalition.side.BLUE)
end)

-- ✅ NUOVO: Menu per controllo individuale convogli
local HeliOPSMenuConvoyIndividual = MENU_COALITION:New(coalition.side.BLUE, "🎯 Controllo Individuale", HeliOPSMenuMissioniConvoglio)

-- Menu individuali per ogni convoglio
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Convoglio 1", HeliOPSMenuConvoyIndividual, function()
    SpawnSingleConvoy("convoy1", triggerConvogli1)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Convoglio 1", HeliOPSMenuConvoyIndividual, function()
    DestroySingleConvoy("convoy1")
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Convoglio 2", HeliOPSMenuConvoyIndividual, function()
    SpawnSingleConvoy("convoy2", triggerConvogli2)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Convoglio 2", HeliOPSMenuConvoyIndividual, function()
    DestroySingleConvoy("convoy2")
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Convoglio 3", HeliOPSMenuConvoyIndividual, function()
    SpawnSingleConvoy("convoy3", triggerConvogli3)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Convoglio 3", HeliOPSMenuConvoyIndividual, function()
    DestroySingleConvoy("convoy3")
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Convoglio 4", HeliOPSMenuConvoyIndividual, function()
    SpawnSingleConvoy("convoy4", triggerConvogli4)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Convoglio 4", HeliOPSMenuConvoyIndividual, function()
    DestroySingleConvoy("convoy4")
end)

-- ✅ NUOVO: Menu per status
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "📊 Status Convogli", HeliOPSMenuMissioniConvoglio, function()
    local status = "STATUS CONVOGLI:\n"
    for id, convoy in pairs(ConvoyStatus) do
        local state = convoy.active and "🟢 ATTIVO" or "🔴 INATTIVO"
        status = status .. string.format("%s: %s\n", id:upper(), state)
    end
    BlueHQ:MessageToCoalition(status, 15, coalition.side.BLUE)
end)

-- ✅ Sistema pattuglia (invariato, funziona)
SpawnPattugliaHeli = SPAWN:New("PattugliaHeliScout")
SpawnPattugliaHeli.InitKeepUnitNames = true
SpawnPattugliaHeli:InitLimit( 3, 200 )

local HeliOPSAttivaPattugliaHeli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Pattuglia Heli", HeliOPSMenuMissioniPattugliaHeli, function ()
    SpawnPattugliaHeli:Spawn()
    BlueHQ:MessageToCoalition("Pattuglia Heli Attivata", 20, coalition.side.BLUE, "PattugliaHeli")
end)

local HeliOPSDisattivaPattugliaHeli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Pattuglia Heli", HeliOPSMenuMissioniPattugliaHeli, function ()
    local spawnedGroup = SpawnPattugliaHeli:GetFirstAliveGroup()
    if spawnedGroup then
        spawnedGroup:Destroy()
    end
    BlueHQ:MessageToCoalition("Pattuglia Heli Disattivata", 20, coalition.side.BLUE, "PattugliaHeli")
end)

-- ✅ Sistema bastardi random (invariato, funziona)
BastardiRandom = SPAWN:New("StingerBastardi")
BastardiRandom:InitLimit( 8, 100 )

function SpawnaBastardi()
    ZonatriggerBastardi = ZONE:FindByName("ZonaBastardi")
    BastardiRandom:SpawnInZone(ZonatriggerBastardi, true)
end

local TIMERSpawnStinger = SCHEDULER:New(nil, SpawnaBastardi, {}, 0, 1800)
TIMERSpawnStinger:Start()