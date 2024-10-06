-- Dichiarazione Trigger
local triggerConvogli1 = ZONE:FindByName("TriggerConv1")
local triggerConvogli2 = ZONE:FindByName("TriggerConv2")
local triggerConvogli3 = ZONE:FindByName("TriggerConv3")
local triggerConvogli4 = ZONE:FindByName("TriggerConv4")


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

-- Dichiarazione SPAWN per i convogli
SpawnConvoglio1 = SPAWN:NewWithAlias("REDCON-V1", "Convoglio1"):InitLimit( 6, 1)
SpawnConvoglio2 = SPAWN:NewWithAlias("REDCON-V1-1", "Convoglio2"):InitLimit( 6, 1)
SpawnConvoglio3 = SPAWN:NewWithAlias("REDCON-V1-2", "Convoglio3"):InitLimit( 6, 1)
SpawnConvoglio4 = SPAWN:NewWithAlias("REDCON-V1-3", "Convoglio4"):InitLimit( 6, 1)

local HeliOPSAttivaConvogli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva/Riattiva Sistema Convogli", HeliOPSMenuMissioniConvoglio, function ()
    -- Codice Attivazione Convoglio 1
        SpawnConvoglio1:SpawnInZone(triggerConvogli1)
        SpawnConvoglio2:SpawnInZone(triggerConvogli2)
        SpawnConvoglio3:SpawnInZone(triggerConvogli3)
        SpawnConvoglio4:SpawnInZone(triggerConvogli4)
        -- Fine Dichiarazione SPAWN per i convogli
    
    BlueHQ:MessageToCoalition("Convogli Attivati", 20, coalition.side.BLUE, "Convoglio")
    -- Fine Codice Attivazione Convogli
end)

local HeliOPSDisattivaConvogli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Sistema Convogli", HeliOPSMenuMissioniConvoglio, function ()
    -- Codice Disattivazione Convoglio 1
    if SpawnConvoglio1 then
        local spawnedGroup1 = SpawnConvoglio1:GetLastAliveGroup()
        spawnedGroup1:Destroy()
        BlueHQ:MessageToCoalition("Convoglio 1 Disattivato", 20, coalition.side.BLUE, "Convoglio")
    end

    if SpawnConvoglio2 then
        local spawnedGroup2 = SpawnConvoglio2:GetLastAliveGroup()
        spawnedGroup2:Destroy()
        BlueHQ:MessageToCoalition("Convoglio 2 Disattivato", 20, coalition.side.BLUE, "Convoglio")
    end

    if SpawnConvoglio3 then
        local spawnedGroup3 = SpawnConvoglio3:GetLastAliveGroup()
        spawnedGroup3:Destroy()
        BlueHQ:MessageToCoalition("Convoglio 3 Disattivato", 20, coalition.side.BLUE, "Convoglio")
    end

    if SpawnConvoglio4 then
        local spawnedGroup4 = SpawnConvoglio4:GetLastAliveGroup()
        spawnedGroup4:Destroy()
        BlueHQ:MessageToCoalition("Convoglio 4 Disattivato", 20, coalition.side.BLUE, "Convoglio")
    end

    --SpawnConvoglio1:SpawnScheduleStop()
    --SpawnConvoglio2:SpawnScheduleStop()
    --SpawnConvoglio3:SpawnScheduleStop()
    --SpawnConvoglio4:SpawnScheduleStop()
    BlueHQ:MessageToCoalition("Convogli Disattivati Correttamente", 20, coalition.side.BLUE, "Convoglio")
    -- Fine Codice Disattivazione Convogli 
end)


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
BastardiRandom:InitLimit( 8, 100 )

function SpawnaBastardi()
    ZonatriggerBastardi = ZONE:FindByName("ZonaBastardi")
    BastardiRandom:SpawnInZone(ZonatriggerBastardi, true)
    --BlueHQ:MessageToCoalition("Bastardi Random Spawnati", 20, coalition.side.BLUE, "Bastardi")
end

-- Crea un scheduler per spawanare i bastardi ogni 30 minuti 
local TIMERSpawnStinger = SCHEDULER:New(nil, SpawnaBastardi, {}, 0, 1800)
TIMERSpawnStinger:Start()