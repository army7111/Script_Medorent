-- Crea un nuovo Command Center
local BlueCCPositionable = GROUP:FindByName("BLUE_HELICOMHQ")
local BlueHQ = COMMANDCENTER:New(BlueCCPositionable, "HeliOPS Command Center", "HeliOPS Command Center")

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
OPSHeli:FilterPrefixes("HeliOPS")
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

-- voce Radio e azione Spawn/Despawn AFAC
SpawnAFAC = SPAWN:New("HeliRecon-AFAC1")
SpawnAFAC.InitKeepUnitNames = true
SpawnAFAC:InitLimit( 1, 200 )

local HeliOPSAttivaAFAC = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva AFAC", HeliOPSMenuMissioniAFAC, function ()
    -- Codice Attivazione AFAC
    SpawnAFAC:Spawn()
    BlueHQ:MessageToCoalition("AFAC Attivato", 20, coalition.side.BLUE, "AFAC")
    -- Fine Codice Attivazione AFAC
end)

local HeliOPSDisattivaAFAC = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva AFAC", HeliOPSMenuMissioniAFAC, function ()
    -- Codice Disattivazione AFAC
    local spawnedGroup = SpawnAFAC:GetFirstAliveGroup()
    if spawnedGroup then
        spawnedGroup:Destroy()
    end
    BlueHQ:MessageToCoalition("AFAC Disattivato", 20, coalition.side.BLUE, "AFAC")
    -- Fine Codice Disattivazione AFAC
end)

-- voce Radio e azione Spawn/Despawn Gazelle
SpawnGazelle = SPAWN:New("HeliRecon-GazelleAI")
SpawnGazelle.InitKeepUnitNames = true
SpawnGazelle:InitLimit( 1, 200 )

local HeliOPSAttivaGazelle = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Gazelle", HeliOPSMenuMissioniUtility, function ()
    -- Codice Attivazione Gazelle
    SpawnGazelle:Spawn()
    BlueHQ:MessageToCoalition("Gazelle Attivato", 20, coalition.side.BLUE, "Gazelle")
    -- Fine Codice Attivazione Gazelle
end)

local HeliOPSDisattivaGazelle = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Gazelle", HeliOPSMenuMissioniUtility, function ()
    -- Codice Disattivazione Gazelle
    local spawnedGroup = SpawnGazelle:GetFirstAliveGroup()
    if spawnedGroup then
        spawnedGroup:Destroy()
    end
    BlueHQ:MessageToCoalition("Gazelle Disattivato", 20, coalition.side.BLUE, "Gazelle")
    -- Fine Codice Disattivazione Gazelle
end)

-- voce Radio e azione Spawn/Despawn Convoglio

local HeliOPSMenuMissioniConvoglio = MENU_COALITION:New(coalition.side.BLUE, "Convogli", HeliOPSMenuMissioni)

SpawnConvoglio1 = SPAWN:New("REDCON-V1"):InitLimit( 7, 1000 )
SpawnConvoglio2 = SPAWN:New("REDCON-V1-1"):InitLimit( 7, 1000 )
SpawnConvoglio3 = SPAWN:New("REDCON-V1-2"):InitLimit( 7, 1000 ) 
SpawnConvoglio4 = SPAWN:New("REDCON-V1-3"):InitLimit( 7, 1000 )

local HeliOPSAttivaConvogli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Sistema Convogli", HeliOPSMenuMissioniConvoglio, function ()
    -- Codice Attivazione Convoglio 1
    SpawnConvoglio1:SpawnScheduled(120, 0.5, true)
    SpawnConvoglio2:SpawnScheduled(180, 0.5, true)
    SpawnConvoglio3:SpawnScheduled(240, 0.5, true)
    SpawnConvoglio4:SpawnScheduled(60, 0.5, true)
    BlueHQ:MessageToCoalition("Convoglio 1 Attivato", 20, coalition.side.BLUE, "Convoglio")
    -- Fine Codice Attivazione Convoglio 1
end)

local HeliOPSDisattivaConvogli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Convoglio 1", HeliOPSMenuMissioniConvoglio, function ()
    -- Codice Disattivazione Convoglio 1
    local spawnedGroup = SpawnConvoglio1:GetFirstAliveGroup()
    if spawnedGroup then
        spawnedGroup:Destroy()
    end
    BlueHQ:MessageToCoalition("Convoglio 1 Disattivato", 20, coalition.side.BLUE, "Convoglio")
    -- Fine Codice Disattivazione Convoglio 1
end)

-- local HeliOPSAttivaConvoglio2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Convoglio 2", HeliOPSMenuMissioniConvoglio, function ()
--     -- Codice Attivazione Convoglio 2
--     SpawnConvoglio2:Spawn()
--     BlueHQ:MessageToCoalition("Convoglio 2 Attivato", 20, coalition.side.BLUE, "Convoglio")
--     -- Fine Codice Attivazione Convoglio 2
-- end)

-- local HeliOPSDisattivaConvoglio2 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Convoglio 2", HeliOPSMenuMissioniConvoglio, function ()
--     -- Codice Disattivazione Convoglio 2
--     local spawnedGroup = SpawnConvoglio2:GetFirstAliveGroup()
--     if spawnedGroup then
--         spawnedGroup:Destroy()
--     end
--     BlueHQ:MessageToCoalition("Convoglio 2 Disattivato", 20, coalition.side.BLUE, "Convoglio")
--     -- Fine Codice Disattivazione Convoglio 2
-- end)

-- local HeliOPSAttivaConvoglio3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Convoglio 3", HeliOPSMenuMissioniConvoglio, function ()
--     -- Codice Attivazione Convoglio 3
--     SpawnConvoglio3:Spawn()
--     BlueHQ:MessageToCoalition("Convoglio 3 Attivato", 20, coalition.side.BLUE, "Convoglio")
--     -- Fine Codice Attivazione Convoglio 3
-- end)

-- local HeliOPSDisattivaConvoglio3 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Convoglio 3", HeliOPSMenuMissioniConvoglio, function ()
--     -- Codice Disattivazione Convoglio 3
--     local spawnedGroup = SpawnConvoglio3:GetFirstAliveGroup()
--     if spawnedGroup then
--         spawnedGroup:Destroy()
--     end
--     -- resetta indice initlimit
--     SpawnConvoglio3:InitLimit( 6, 6 )
--     BlueHQ:MessageToCoalition("Convoglio 3 Disattivato", 20, coalition.side.BLUE, "Convoglio")
--     -- Fine Codice Disattivazione Convoglio 3
-- end)

-- local HeliOPSAttivaConvoglio4 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Convoglio 4", HeliOPSMenuMissioniConvoglio, function ()
--     -- Codice Attivazione Convoglio 4
--     SpawnConvoglio4:Spawn()
--     BlueHQ:MessageToCoalition("Convoglio 4 Attivato", 20, coalition.side.BLUE, "Convoglio")
--     -- Fine Codice Attivazione Convoglio 4
-- end)

-- local HeliOPSDisattivaConvoglio4 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Convoglio 4", HeliOPSMenuMissioniConvoglio, function ()
--     -- Codice Disattivazione Convoglio 4
--     local spawnedGroup = SpawnConvoglio4:GetFirstAliveGroup()
--     if spawnedGroup then
--         spawnedGroup:Destroy()
--     end
--     BlueHQ:MessageToCoalition("Convoglio 4 Disattivato", 20, coalition.side.BLUE, "Convoglio")
--     -- Fine Codice Disattivazione Convoglio 4
-- end)

-- Fine Radio Convoglio

-- voce Radio e azione Spawn/Despawn PattugliaHeli "PattugliaHeliScout"


SpawnPattugliaHeli = SPAWN:New("PattugliaHeliScout")
SpawnPattugliaHeli.InitKeepUnitNames = true
SpawnPattugliaHeli:InitLimit( 3, 200 )

local HeliOPSAttivaPattugliaHeli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Pattuglia Heli", HeliOPSMenuMissioniPattugliaHeli, function ()
    -- Codice Attivazione PattugliaHeli
    SpawnPattugliaHeli:Spawn()
    BlueHQ:MessageToCoalition("Pattuglia Heli Attivata", 20, coalition.side.BLUE, "PattugliaHeli")
    -- Fine Codice Attivazione PattugliaHeli
end)

local HeliOPSDisattivaPattugliaHeli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Pattuglia Heli", HeliOPSMenuMissioniPattugliaHeli, function ()
    -- Codice Disattivazione PattugliaHeli
    local spawnedGroup = SpawnPattugliaHeli:GetFirstAliveGroup()
    if spawnedGroup then
        spawnedGroup:Destroy()
    end
    BlueHQ:MessageToCoalition("Pattuglia Heli Disattivata", 20, coalition.side.BLUE, "PattugliaHeli")
    -- Fine Codice Disattivazione PattugliaHeli
end)


-- Funzione per spawanare i bastardi in modo random nella zona "ZonaBastardi"
BastardiRandom = SPAWN:New("StingerBastardi")
BastardiRandom:InitLimit( 8, 4000 )

function SpawnaBastardi()
    ZonatriggerBastardi = ZONE:FindByName("ZonaBastardi")
    BastardiRandom:SpawnInZone(ZonatriggerBastardi, true)
    --BlueHQ:MessageToCoalition("Bastardi Random Spawnati", 20, coalition.side.BLUE, "Bastardi")
end

-- Crea un scheduler per spawanare i bastardi ogni 30 minuti 
local TIMERSpawnStinger = SCHEDULER:New(nil, SpawnaBastardi, {}, 0, 1800)
TIMERSpawnStinger:Start()

