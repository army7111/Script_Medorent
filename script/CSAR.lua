-- Crea un nuovo oggetto CSAR per il lato BLUE con il nome "CSARPilot" e il beacon "SOS-Beacon"
MedorentCSAR = CSAR:New(coalition.side.BLUE, "CSARPilot", "SOS-Beacon")
MedorentCSAR.enableLoadSave = true -- Abilita il salvataggio e il caricamento delle missioni CSAR
MedorentCSAR.saveinterval = 900 -- Ottimizzazione: 600s → 900s (-33% I/O overhead)
MedorentCSAR.filename = "CSARMedorent.csv" -- Imposta il nome del file per il salvataggio delle missioni CSAR
MedorentCSAR.filepath = "C:\\temp\\MedorentCache\\CSARSAVES\\"
MedorentCSAR:__Load(10) -- Carica le missioni CSAR salvate

-- Imposta le opzioni del CSAR
MedorentCSAR.immortalcrew = true -- Equipaggio immortale
MedorentCSAR.invisiblecrew = true -- Equipaggio invisibile
MedorentCSAR.allowbronco = true -- Abilita il Bronco come mezzo di recupero
MedorentCSAR.topmenuname = "Medorent Combat Search & Rescue" -- Imposta il nome del menu principale
MedorentCSAR.useprefix = true -- Abilita il prefisso per i CSAR
MedorentCSAR.csarPrefix = {"Damascus"} -- Imposta i prefissi per i CSAR

-- FIX ISSUE #5: PARAMETRI MANCANTI PER RILASCIO ALLE BASI AEREE
MedorentCSAR.allowFARPRescue = true          -- CRITICO: Permette rilascio alle basi aeree/FARP
MedorentCSAR.FARPRescueDistance = 1500       -- CRITICO: Distanza massima dalla base (1.5km)
MedorentCSAR.mashprefix = {"MASH", "Ospedale", "Hospital"}  -- Zone MASH riconosciute

-- OTTIMIZZAZIONI PERFORMANCE CSAR
MedorentCSAR.approachdist_far = 8000   -- Ottimizzazione: 5000m → 8000m (meno controlli)
MedorentCSAR.approachdist_near = 4000  -- Ottimizzazione: 3000m → 4000m (meno controlli)

-- DEBUG: AGGIUNGI LOGGING PER EVENTI CRITICI
function MedorentCSAR:OnAfterLanded(From, Event, To, HeliName, Airbase)
    -- NUOVO: Debug per atterraggi
    local message = string.format("Elicottero %s atterrato alla base: %s", HeliName, Airbase:GetName())
    MESSAGE:New(message, 10):ToAll()
    env.info("CSAR DEBUG - Landed: " .. message)
end

function MedorentCSAR:OnAfterRescued(From, Event, To, HeliUnit, HeliName, PilotsSaved)
    -- MIGLIORATO: Messaggio più chiaro + debug
    local activeCsarMissions = self:_CountActiveDownedPilots()
    local message = string.format("CSAR COMPLETATO! %d piloti salvati da %s. Missioni attive: %d", 
                                 PilotsSaved, HeliName, activeCsarMissions)
    MESSAGE:New(message, 30):ToAll()
    env.info("CSAR DEBUG - Rescued: " .. message)
end

-- Inizializza variabile activeCsarMissions
local activeCsarMissions = MedorentCSAR:_CountActiveDownedPilots()

-- Modifica messaggi Standard
function MedorentCSAR:OnAfterPilotDown(From, Event, To, SpawnedGroup, Frequency, Leadername, CoordinatesText)
    MESSAGE:New(string.format("Il pilota %s è abbattuto! Frequenza CSAR: %s KHz, coordinate: %s.", 
                              Leadername, Frequency, CoordinatesText), 15):ToAll()
end

-- DEBUG: Evento per monitorare avvicinamenti
function MedorentCSAR:OnAfterApproach(from, event, to, heliname, groupname)
    local activeCsarMissions = self:_CountActiveDownedPilots()
    MESSAGE:New("Elicottero in avvicinamento al pilota abbattuto. Richiedi fumogeno se necessario.", 15):ToAll()
    env.info(string.format("CSAR DEBUG - Approach: %s approaching %s", heliname, groupname))
end

-- DEBUG: Evento per monitorare imbarco
function MedorentCSAR:OnAfterBoarded(from, event, to, heliname, groupname, description)
    MESSAGE:New("Pilota a bordo! Torna alla base più vicina per completare il CSAR.", 20):ToAll()
    env.info(string.format("CSAR DEBUG - Boarded: %s boarded to %s", groupname, heliname))
end

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

-- Ottimizzazione scheduler: controllo ogni 90 secondi invece di 30s (-67% overhead)
local checkActiveMissionsScheduler = SCHEDULER:New(nil, startCsarMission, {},90,1800)
checkActiveMissionsScheduler:Start()