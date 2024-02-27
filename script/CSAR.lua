-- Crea un nuovo oggetto CSAR per il lato BLUE con il nome "CSARPilot" e il beacon "SOS-Beacon"
local MedorentCSAR = CSAR:New(coalition.side.BLUE, "CSARPilot", "SOS-Beacon")
MedorentCSAR.enableLoadSave = true -- Abilita il salvataggio e il caricamento delle missioni CSAR
MedorentCSAR.saveinterval = 60 -- Imposta l'intervallo di salvataggio delle missioni CSAR
MedorentCSAR.filename = "CSARMedorent.csv" -- Imposta il nome del file per il salvataggio delle missioni CSAR
MedorentCSAR.filepath = "C:\\temp\\MedorentCache\\CSARSAVES\\"
MedorentCSAR:__Load(10) -- Carica le missioni CSAR salvate
-- Imposta le opzioni del CSAR
MedorentCSAR.immortalcrew = true -- Equipaggio immortale
MedorentCSAR.invisiblecrew = true -- Equipaggio invisibile
MedorentCSAR.allowbronco = true -- Abilita il Bronco come mezzo di recupero
MedorentCSAR.topmenuname = "Medorent Combat Search & Rescue" -- Imposta il nome del menu principale
MedorentCSAR.useprefix = true -- Abilita il prefisso per i CSAR
MedorentCSAR.csarPrefix = {"CSAR","Helicargo"} -- Imposta i prefissi per i CSAR

-- Inizializza variabile activeCsarMissions

local activeCsarMissions = MedorentCSAR:_CountActiveDownedPilots()

-- Modifica messaggi Standard

function MedorentCSAR:OnAfterPilotDown(From, Event, To, SpawnedGroup, Frequency, Leadername, CoordinatesText)
    local activeCsarMissions = self:_CountActiveDownedPilots()
    MESSAGE:New(string.format("Il pilota %s è abbattuto! La frequenza per il CSAR è %s KHz, le coordinate sono %s.", Leadername, Frequency, CoordinatesText), 15):ToAll()
end
-- Funzione chiamata quando un pilota viene recuperato
function MedorentCSAR:OnAfterRescued(From, Event, To, HeliUnit, HeliName, PilotsSaved)
    local activeCsarMissions = self:_CountActiveDownedPilots()
    MESSAGE:New("Missione CSAR terminata con successo. Missioni attive:" .. activeCsarMissions, 30):ToAll()
end
-- Funzione chiamata quando Ci si avvicina ad un pilota Abbattuto
-- function MedorentCSAR:OnAfterApproach(from, event, to, heliname, groupname)
--     local activeCsarMissions = self:_CountActiveDownedPilots()
--     MESSAGE:New("Sento il rumore del motore! Richiedi un fumogeno o un flare se necessario.", 30):ToAll()
-- end
-- -- Funzione chiamata quando un pilota viene recuperato
-- function MedorentCSAR:OnAfterBoarded(from, event, to, heliname, groupname, description)
--     local activeCsarMissions = self:_CountActiveDownedPilots()
--     MESSAGE:New("Pilota a bordo. Torna alla base", 30):ToAll()
-- end
-- Funzione chiamata quando un pilota viene riportato in base
-- function MedorentCSAR:OnAfterRescued(from, event, to, heliunit, heliname, pilotssaved)
--     local activeCsarMissions = self:_CountActiveDownedPilots()
--     MESSAGE:New("Pilota recuperato. Ben Fatto! Missioni attive: " .. activeCsarMissions, 30):ToAll()
-- end

-- Fine Modifica messaggi Standard

-- Avvia il CSAR
MedorentCSAR:Start()

-- Crea una zona CSAR
local csarZone = ZONE:New("CSARMissionZone")

-- Funzione per avviare una nuova missione CSAR
local function startCsarMission()
    local activeCsarMissions = MedorentCSAR:_CountActiveDownedPilots()
    -- Controlla se ci sono meno di 3 missioni CSAR attive
    if activeCsarMissions <= 3 then
        -- Avvia una nuova missione CSAR nella zona CSAR
        MedorentCSAR:SpawnCSARAtZone(csarZone, coalition.side.BLUE, "DSMC_NoUp_", true, false, false, "CSAR-Random")
        MESSAGE:New("Missioni CSAR attive: " .. activeCsarMissions, 30):ToAll()
    end
end

-- Crea un scheduler per controllare le missioni CSAR attive ogni 60 secondi
local checkActiveMissionsScheduler = SCHEDULER:New(nil, startCsarMission, {},30,30)
checkActiveMissionsScheduler:Start()