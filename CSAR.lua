-- Crea un nuovo oggetto CSAR per il lato BLUE con il nome "CSARPilot" e il beacon "SOS-Beacon"
local MedorentCSAR = CSAR:New(coalition.side.BLUE, "CSARPilot", "SOS-Beacon")

-- Imposta l'equipaggio come immortale e invisibile
MedorentCSAR.immortalcrew = true
MedorentCSAR.invisiblecrew = true

-- Abilita il Bronco come mezzo di recupero
MedorentCSAR.allowbronco = true

-- Imposta il nome del menu principale
MedorentCSAR.topmenuname = "Medorent Combat Search & Rescue"

-- Abilita l'uso del prefisso "CSAR"
MedorentCSAR.useprefix = true
MedorentCSAR.csarPrefix = "CSAR"

-- Contatore delle missioni CSAR attive
local activeCsarMissions = 0

-- Funzione chiamata quando un pilota viene abbattuto
function MedorentCSAR:OnAfterPilotDown(From, Event, To, SpawnedGroup, Frequency, Leadername, CoordinatesText)
    activeCsarMissions = activeCsarMissions + 1
    MESSAGE:New(string.format("Il pilota %s è abbattuto! La frequenza per il CSAR è %s KHz, le coordinate sono %s.", Leadername, Frequency, CoordinatesText), 15):ToAll()
end

-- Funzione chiamata quando un pilota viene recuperato
function MedorentCSAR:OnAfterRescued(From, Event, To, HeliUnit, HeliName, PilotsSaved)
    activeCsarMissions = activeCsarMissions - 2
    MESSAGE:New("Missione CSAR terminata con successo. Missioni attive:" .. activeCsarMissions, 30):ToAll()
end

-- Avvia il CSAR
MedorentCSAR:Start()

-- Crea una zona CSAR
local csarZone = ZONE:New("CSARMissionZone")

-- Funzione per avviare una nuova missione CSAR
local function startCsarMission()
    -- Controlla se ci sono meno di 5 missioni CSAR attive
    if activeCsarMissions < 5 then
        -- Avvia una nuova missione CSAR nella zona CSAR
        MedorentCSAR:SpawnCSARAtZone(csarZone, coalition.side.BLUE, "PilotaAbbattuto", true)
        activeCsarMissions = activeCsarMissions + 1
        MESSAGE:New("Missioni CSAR attive: " .. activeCsarMissions, 30):ToAll()
    end
end

-- Crea un scheduler per controllare le missioni CSAR attive ogni 60 secondi
local checkActiveMissionsScheduler = SCHEDULER:New(nil, startCsarMission, {}, 0, 60)
checkActiveMissionsScheduler:Start()
