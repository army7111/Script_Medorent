-- Configurazione CSAR Medorent
MedorentCSAR = CSAR:New(coalition.side.BLUE, "CSARPilot", "MedorentCSAR")

-- Configurazione base
MedorentCSAR.immortalcrew = true
MedorentCSAR.invisiblecrew = false
MedorentCSAR.useprefix = false
MedorentCSAR.suppressmessages = false
MedorentCSAR.topmenuname = "CSAR"

-- Configurazione salvataggio
MedorentCSAR.enableLoadSave = true
MedorentCSAR.saveinterval = 600
MedorentCSAR.filename = "CSARMedorent.csv"
MedorentCSAR.filepath = "C:\\temp\\MedorentCache\\CSARSAVES\\"

-- Configurazione operazioni
MedorentCSAR.allowFARPRescue = true
MedorentCSAR.FARPRescueDistance = 1000
MedorentCSAR.mashprefix = {"MASH"}
MedorentCSAR.extractDistance = 500
MedorentCSAR.loadDistance = 75
MedorentCSAR.coordtype = 2  -- Usa coordinate MGRS

-- Configurazione zone di consegna
MedorentCSAR.rescuehoverheight = 20  -- Altezza hover per il salvataggio
MedorentCSAR.rescuehoverdistance = 10  -- Distanza hover per il salvataggio
MedorentCSAR.csarOncrash = true  -- Genera CSAR automaticamente sui crash
MedorentCSAR.pilotRuntoExtractPoint = true  -- I piloti corrono verso il punto di estrazione

-- Eventi CSAR
function MedorentCSAR:OnAfterPilotDown(From, Event, To, SpawnedGroup, Frequency, Leadername, CoordinatesText)
    MESSAGE:New(string.format("Pilota abbattuto: %s - Frequenza: %s KHz - Posizione: %s", 
                              Leadername, Frequency, CoordinatesText), 60):ToAll()
end

function MedorentCSAR:OnAfterApproach(from, event, to, heliname, groupname)
    MESSAGE:New("Elicottero in avvicinamento al pilota abbattuto.", 10):ToAll()
end

function MedorentCSAR:OnAfterBoarded(from, event, to, heliname, groupname, description)
    MESSAGE:New("Pilota a bordo! Ritorna alla base.", 15):ToAll()
end

function MedorentCSAR:OnAfterRescued(From, Event, To, HeliUnit, HeliName, PilotsSaved)
    MESSAGE:New(string.format("CSAR completato! %d piloti salvati da %s.", PilotsSaved, HeliName), 20):ToAll()
end

-- Avvio sistema
MedorentCSAR:Start()

-- Auto-spawn piloti abbattuti
local csarZone = ZONE:New("CSARMissionZone")

local function spawnCSARMission()
    local activePilots = MedorentCSAR:_CountActiveDownedPilots()
    local targetPilots = 3
    
    -- Spawna piloti fino a raggiungere il target
    while activePilots < targetPilots do
        MedorentCSAR:SpawnCSARAtZone(csarZone, coalition.side.BLUE, "Pilota abbattuto", true)
        activePilots = activePilots + 1
    end
end

SCHEDULER:New(nil, spawnCSARMission, {}, 30, -1)