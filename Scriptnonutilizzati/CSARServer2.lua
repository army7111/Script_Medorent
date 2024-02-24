-- Istanza CSAR per attivare la possibilità di CSAR dei piloti Umani --
-- Le unità che possono fare recupero si chiameranno " helicargo "

local Csar_StepUp = CSAR:New(coalition.side.BLUE,"Pilota Eiettato","PilotaEiettato")

-- Opzioni non default --

Csar_StepUp.csarPrefix = { "helicargo", "MEDEVAC"} -- #GROUP name prefixes used for useprefix=true - DO NOT use # in helicopter names in the Mission Editor! "helicargo"
Csar_StepUp.immortalcrew = true -- il pilota è immortale
Csar_StepUp.invisiblecrew = false -- il pilota è visibile
Csar_StepUp.allowDownedPilotCAcontrol = true -- chi ha Combined Arms può spostare il pilota abbattuto
Csar_StepUp.autosmoke = true -- Abilita l'emissione automatica di fumo quando il pilota è abbattuto
Csar_StepUp.coordtype = 2 -- Tipo di coordinate utilizzate per la comunicazione del pilota abbattuto (1 = coordinate lat/long, 2 = coordinate MGRS, 3 = coordinate UTM)
Csar_StepUp.coordaccuracy = 1 -- Precisione delle coordinate comunicate dal pilota abbattuto (1 = bassa, 2 = media, 3 = alta)
Csar_StepUp.coordformat = 1 -- Formato delle coordinate comunicate dal pilota abbattuto (1 = gradi decimali, 2 = gradi/minuti/secondi)
Csar_StepUp.pilotRuntoExtractPoint = true -- Il pilota abbattuto si dirige automaticamente verso il punto di estrazione
Csar_StepUp.extractDistance = 200 -- Distanza massima a cui il pilota abbattuto può essere estratto
Csar_StepUp.loadDistance = 10 -- Distanza massima a cui il pilota abbattuto può essere caricato a bordo
Csar_StepUp.smokecolor = 4 -- Colore del fumo emesso dal pilota abbattuto (0 is green, 1 is red, 2 is white, 3 is orange and 4 is blue.)
-- Csar_StepUp.allowDownedPilotCAcontrol = false -- Set to false if you don\'t want to allow control by Combined Arms.
-- Csar_StepUp.allowFARPRescue = true -- allows pilots to be rescued by landing at a FARP or Airbase. Else MASH only!
-- Csar_StepUp.FARPRescueDistance = 1000 -- you need to be this close to a FARP or Airport for the pilot to be rescued.
-- Csar_StepUp.autosmoke = false -- automatically smoke a downed pilot\'s location when a heli is near.
-- Csar_StepUp.autosmokedistance = 1000 -- distance for autosmoke
-- Csar_StepUp.coordtype = 1 -- Use Lat/Long DDM (0), Lat/Long DMS (1), MGRS (2), Bullseye imperial (3) or Bullseye metric (4) for coordinates.
-- Csar_StepUp.csarOncrash = false -- (WIP) If set to true, will generate a downed pilot when a plane crashes as well.
-- Csar_StepUp.enableForAI = false -- set to false to disable AI pilots from being rescued.
-- Csar_StepUp.pilotRuntoExtractPoint = true -- Downed pilot will run to the rescue helicopter up to Csar_StepUp.extractDistance in meters. 
-- Csar_StepUp.extractDistance = 500 -- Distance the downed pilot will start to run to the rescue helicopter.
-- Csar_StepUp.immortalcrew = true -- Set to true to make wounded crew immortal.
-- Csar_StepUp.invisiblecrew = false -- Set to true to make wounded crew insvisible.
-- Csar_StepUp.loadDistance = 75 -- configure distance for pilots to get into helicopter in meters.
-- Csar_StepUp.mashprefix = {"MASH"} -- prefixes of #GROUP objects used as MASHes.
-- Csar_StepUp.max_units = 6 -- max number of pilots that can be carried if #CSAR.AircraftType is undefined.
-- Csar_StepUp.messageTime = 15 -- Time to show messages for in seconds. Doubled for long messages.
-- Csar_StepUp.radioSound = "beacon.ogg" -- the name of the sound file to use for the pilots\' radio beacons. 
-- Csar_StepUp.smokecolor = 4 -- Color of smokemarker, 0 is green, 1 is red, 2 is white, 3 is orange and 4 is blue.
-- Csar_StepUp.useprefix = true  -- Requires CSAR helicopter #GROUP names to have the prefix(es) defined below.
-- Csar_StepUp.csarPrefix = { "helicargo", "MEDEVAC"} -- #GROUP name prefixes used for useprefix=true - DO NOT use # in helicopter names in the Mission Editor! 
-- Csar_StepUp.verbose = 0 -- set to > 1 for stats output for debugging.
--    limit amount of downed pilots spawned by **ejection** events
-- Csar_StepUp.limitmaxdownedpilots = true
-- Csar_StepUp.maxdownedpilots = 10 
--    allow to set far/near distance for approach and optionally pilot must open doors
-- Csar_StepUp.approachdist_far = 5000 -- switch do 10 sec interval approach mode, meters
-- Csar_StepUp.approachdist_near = 3000 -- switch to 5 sec interval approach mode, meters
-- Csar_StepUp.pilotmustopendoors = false -- switch to true to enable check of open doors
-- Csar_StepUp.suppressmessages = false -- switch off all messaging if you want to do your own
-- Csar_StepUp.rescuehoverheight = 20 -- max height for a hovering rescue in meters
-- Csar_StepUp.rescuehoverdistance = 10 -- max distance for a hovering rescue in meters
--    Country codes for spawned pilots
-- Csar_StepUp.countryblue= country.id.USA
-- Csar_StepUp.countryred = country.id.RUSSIA
-- Csar_StepUp.countryneutral = country.id.UN_PEACEKEEPERS
-- Csar_StepUp.topmenuname = "CSAR" -- set the menu entry name
-- Csar_StepUp.ADFRadioPwr = 1000 -- ADF Beacons sending with 1KW as default
-- Csar_StepUp.PilotWeight = 80 --  Loaded pilots weigh 80kgs each


local activeCsarMissions = 0

-- Funzione chiamata quando un pilota viene abbattuto
function Csar_StepUp:OnAfterPilotDown(From, Event, To, SpawnedGroup, Frequency, Leadername, CoordinatesText)
    local activeCsarMissions = self:_CountActiveDownedPilots()
    MESSAGE:New(string.format("Il pilota %s è abbattuto! La frequenza per il CSAR è %s KHz, le coordinate sono %s.", Leadername, Frequency, CoordinatesText), 15):ToAll()
end

-- Funzione chiamata quando un pilota viene recuperato
function Csar_StepUp:OnAfterRescued(From, Event, To, HeliUnit, HeliName, PilotsSaved)
    local activeCsarMissions = self:_CountActiveDownedPilots()
    MESSAGE:New("Missione CSAR terminata con successo. Missioni attive:" .. activeCsarMissions, 30):ToAll()
end

-- Avvia il CSAR
Csar_StepUp:Start()

-- Crea una zona CSAR
local csarZone = ZONE:New("CSARMissionZone")

-- Funzione per avviare una nuova missione CSAR
local function startCsarMission()
    local activeCsarMissions = Csar_StepUp:_CountActiveDownedPilots()
    
    -- Controlla se ci sono meno di 5 missioni CSAR attive
    if activeCsarMissions <= 4 then
        -- Avvia una nuova missione CSAR nella zona CSAR
        Csar_StepUp:SpawnCSARAtZone(csarZone, coalition.side.BLUE, "PilotaAbbattuto", true)
        MESSAGE:New("Missioni CSAR attive: " .. activeCsarMissions, 30):ToAll()
    end
end

-- Crea un scheduler per controllare le missioni CSAR attive ogni 60 secondi
local checkActiveMissionsScheduler = SCHEDULER:New(nil, startCsarMission, {}, 0, 60)
checkActiveMissionsScheduler:Start()