--------------------------------------------------------------------------------
-- MISSIONE CAPTURE ZONE PvE - 6 CITTÀ
-- Ispirato alla logica 4YA/TTI per cambiamenti visivi mappa F10
-- Blue vs AI Red - Conquista territoriale
--------------------------------------------------------------------------------

-- Inizializzazione MOOSE e Command Centers
local BlueCC = COMMANDCENTER:New(GROUP:FindByName("BlueHQGroup"), "Blue Command", "Blue Forces HQ")
local RedCC = COMMANDCENTER:New(GROUP:FindByName("RedHQGroup"), "Red Command", "Red Forces HQ")

-- Mission Statistics
local missionStats = {
    blueControlledZones = 1,  -- Partono con 1 zona (base)
    redControlledZones = 5,   -- AI parte con 5 zone
    totalZones = 6,
    missionStartTime = timer.getTime(),
    zonesFlipped = 0
}

-- AFAC e AI Management
local afacGroups = {}        -- Traccia gruppi AFAC attivi
local redCounterAttacks = {} -- Traccia contrattacchi Red pianificati

-- Sistema Trasporto Truppe e Rinforzi
local transportSystem = {
    landingZones = {},       -- Zone di atterraggio per elicotteri
    troopTransports = {},    -- Elicotteri da trasporto attivi
    reinforcements = {},     -- Rinforzi deployati per città
    transportRequests = {}   -- Richieste di trasporto in coda
}

--------------------------------------------------------------------------------
-- CONFIGURAZIONE CITTÀ E ZONE CAPTURE
--------------------------------------------------------------------------------

-- Definizione delle 6 città con i loro parametri
local cities = {
    {
        name = "CITY_ALPHA_BASE",           -- Base di partenza Blue
        displayName = "Alpha Base",
        zone = "AlphaBaseCZ",
        coalition = coalition.side.BLUE,   -- Controllo iniziale
        airfield = true,                   -- Ha aeroporto
        strategic = true,                  -- Zona strategica
        reinforcementSpawn = "BlueReinforcementAlpha",
        patrolSpawn = nil,                 -- Nessuna pattuglia (base amica)
        landingZone = "AlphaLandingZone",  -- Zona atterraggio elicotteri
        reinforcementPoints = {            -- Punti spawn rinforzi trasportati
            "AlphaReinforcement1",
            "AlphaReinforcement2", 
            "AlphaReinforcement3"
        }
    },
    {
        name = "CITY_BRAVO",
        displayName = "Bravo City", 
        zone = "BravoCityCZ",
        coalition = coalition.side.RED,    -- Controllo iniziale AI
        airfield = false,
        strategic = false,
        reinforcementSpawn = "RedReinforcementBravo",
        patrolSpawn = "RedPatrolBravo",
        landingZone = "BravoLandingZone",  -- Zona atterraggio elicotteri
        reinforcementPoints = {            -- Punti spawn rinforzi trasportati
            "BravoReinforcement1",
            "BravoReinforcement2"
        }
    },
    {
        name = "CITY_CHARLIE", 
        displayName = "Charlie Industrial",
        zone = "CharlieCityCZ", 
        coalition = coalition.side.RED,
        airfield = false,
        strategic = true,                  -- Zona strategica (industrie)
        reinforcementSpawn = "RedReinforcementCharlie", 
        patrolSpawn = "RedPatrolCharlie",
        landingZone = "CharlieLandingZone", -- Zona atterraggio elicotteri
        reinforcementPoints = {             -- Punti spawn rinforzi trasportati
            "CharlieReinforcement1",
            "CharlieReinforcement2",
            "CharlieReinforcement3"
        }
    },
    {
        name = "CITY_DELTA",
        displayName = "Delta Port",
        zone = "DeltaCityCZ",
        coalition = coalition.side.RED, 
        airfield = false,
        strategic = true,                  -- Porto strategico
        reinforcementSpawn = "RedReinforcementDelta",
        patrolSpawn = "RedPatrolDelta",
        landingZone = "DeltaLandingZone",   -- Zona atterraggio elicotteri
        reinforcementPoints = {             -- Punti spawn rinforzi trasportati
            "DeltaReinforcement1",
            "DeltaReinforcement2",
            "DeltaReinforcement3"
        }
    },
    {
        name = "CITY_ECHO",
        displayName = "Echo Township", 
        zone = "EchoCityCZ",
        coalition = coalition.side.RED,
        airfield = false,
        strategic = false,
        reinforcementSpawn = "RedReinforcementEcho",
        patrolSpawn = "RedPatrolEcho",
        landingZone = "EchoLandingZone",    -- Zona atterraggio elicotteri
        reinforcementPoints = {             -- Punti spawn rinforzi trasportati
            "EchoReinforcement1",
            "EchoReinforcement2"
        }
    },
    {
        name = "CITY_FOXTROT_AIRBASE",      -- Base principale AI Red
        displayName = "Foxtrot Airbase",
        zone = "FoxtrotAirbaseCZ", 
        coalition = coalition.side.RED,
        airfield = true,                   -- Base aerea AI
        strategic = true,                  -- Obiettivo finale
        reinforcementSpawn = "RedReinforcementFoxtrot",
        patrolSpawn = "RedPatrolFoxtrot",
        landingZone = "FoxtrotLandingZone", -- Zona atterraggio elicotteri
        reinforcementPoints = {             -- Punti spawn rinforzi trasportati
            "FoxtrotReinforcement1",
            "FoxtrotReinforcement2",
            "FoxtrotReinforcement3"
        }
    }
}

-- CONFIGURAZIONE AFAC (Airborne Forward Air Controller)
local afacConfig = {
    spawnTemplate = "AFACTemplate",     -- Nome gruppo AFAC nel ME (Late Activation)
    orbitAltitude = 4500,              -- Altitudine orbit (metri)
    orbitRadius = 2000,                -- Raggio orbit (metri)  
    frequency = 251.0,                 -- Frequenza radio AFAC
    callsign = "Reaper",               -- Callsign AFAC
    maxAfacActive = 3                  -- Massimo 3 AFAC contemporanei
}

-- Configurazione AI Red Counter-Attack
local redAIConfig = {
    counterAttackInterval = 900,       -- Ogni 15 minuti (900s)
    attackGroupTemplate = "RedCounterAttackGroup", -- Template gruppo attacco
    transportTemplate = "RedTransportHeli",        -- Template elicotteri trasporto
    maxSimultaneousAttacks = 2,        -- Massimo 2 attacchi simultanei
    redMainBase = 6                    -- Indice città base Red (Foxtrot)
}

-- Configurazione Sistema Trasporto Truppe
local transportConfig = {
    -- Template per truppe trasportabili (Late Activation nel ME)
    infantryTemplate = "TransportInfantry",      -- Squad di fanteria
    lightVehicleTemplate = "TransportLightVeh",  -- Veicoli leggeri (Humvee, ecc)
    heavyVehicleTemplate = "TransportHeavyVeh",  -- Veicoli pesanti (APC, Tank)
    
    -- Capacità trasporto per tipo elicottero
    heliCapacity = {
        ["UH-60L"] = {infantry = 11, lightVehicle = 1, heavyVehicle = 0},
        ["Mi-8MT"] = {infantry = 24, lightVehicle = 1, heavyVehicle = 0},
        ["CH-47D"] = {infantry = 33, lightVehicle = 2, heavyVehicle = 1},
        ["Mi-26"] = {infantry = 90, lightVehicle = 3, heavyVehicle = 2}
    },
    
    -- Costi per tipo rinforzo (punti)
    reinforcementCosts = {
        infantry = 50,      -- 50 punti per squad fanteria
        lightVehicle = 150, -- 150 punti per veicolo leggero
        heavyVehicle = 300  -- 300 punti per veicolo pesante
    },
    
    -- Punti disponibili per città controllate
    pointsPerCity = 500,           -- 500 punti per città controllata
    pointsPerStrategicCity = 750,  -- 750 punti per città strategica
    maxStoredPoints = 2000         -- Massimo accumulo punti
}

--------------------------------------------------------------------------------
-- FUNZIONI AFAC MANAGEMENT
--------------------------------------------------------------------------------

-- Funzione per calcolare distanza tra due città
local function getDistanceBetweenCities(cityIndex1, cityIndex2)
    local zone1 = ZONE:New(cities[cityIndex1].zone)
    local zone2 = ZONE:New(cities[cityIndex2].zone)
    if zone1 and zone2 then
        return zone1:GetCoordinate():Get2DDistance(zone2:GetCoordinate())
    end
    return 999999 -- Distanza infinita se zone non trovate
end

-- Funzione per trovare città Blue più vicina alla base Red
local function findClosestBlueCity()
    local redBaseIndex = redAIConfig.redMainBase
    local closestDistance = 999999
    local closestCityIndex = nil
    
    for i, cityData in ipairs(cities) do
        if i ~= redBaseIndex and captureZones[i] and captureZones[i]:GetCoalition() == coalition.side.BLUE then
            local distance = getDistanceBetweenCities(redBaseIndex, i)
            if distance < closestDistance then
                closestDistance = distance
                closestCityIndex = i
            end
        end
    end
    
    return closestCityIndex, closestDistance
end

-- Funzione per deployare AFAC su città controllata Blue
local function deployAFAC(cityIndex)
    local cityData = cities[cityIndex]
    local zone = ZONE:New(cityData.zone)
    
    if not zone then
        env.error("AFAC Deploy: Zona " .. cityData.zone .. " non trovata")
        return nil
    end
    
    -- Controlla limite AFAC attivi
    local activeAfacCount = 0
    for _, afac in pairs(afacGroups) do
        if afac and afac:IsAlive() then
            activeAfacCount = activeAfacCount + 1
        end
    end
    
    if activeAfacCount >= afacConfig.maxAfacActive then
        BlueCC:MessageTypeToCoalition("[AFAC] Maximum AFAC limit reached (" .. afacConfig.maxAfacActive .. ")", MESSAGE.Type.Information)
        return nil
    end
    
    -- Spawn AFAC se template disponibile
    if spawnSystems[afacConfig.spawnTemplate] then
        local afacGroup = spawnSystems[afacConfig.spawnTemplate]:Spawn()
        if afacGroup then
            -- Imposta orbit sulla città
            local orbitCoord = zone:GetCoordinate():SetAltitude(afacConfig.orbitAltitude)
            local orbitTask = afacGroup:TaskOrbitCircleAtVec2(zone:GetVec2(), afacConfig.orbitAltitude, 120)
            afacGroup:SetTask(orbitTask, 1)
            
            -- Salva riferimento AFAC
            afacGroups[cityIndex] = afacGroup
            
            BlueCC:MessageTypeToCoalition(
                string.format("[AFAC] %s-%d on station over %s - Freq: %.1f", 
                    afacConfig.callsign, cityIndex, cityData.displayName, afacConfig.frequency), 
                MESSAGE.Type.Information
            )
            
            env.info("AFAC deployed over " .. cityData.displayName)
            return afacGroup
        end
    else
        env.error("AFAC Template '" .. afacConfig.spawnTemplate .. "' non trovato")
    end
    
    return nil
end

-- Funzione per rimuovere AFAC da città persa
local function removeAFAC(cityIndex)
    local afacGroup = afacGroups[cityIndex]
    if afacGroup and afacGroup:IsAlive() then
        afacGroup:Destroy(false)
        afacGroups[cityIndex] = nil
        BlueCC:MessageTypeToCoalition("[AFAC] " .. afacConfig.callsign .. "-" .. cityIndex .. " RTB due to area loss", MESSAGE.Type.Information)
        env.info("AFAC removed from " .. cities[cityIndex].displayName)
    end
end

--------------------------------------------------------------------------------
-- SISTEMA TRASPORTO TRUPPE E RINFORZI
--------------------------------------------------------------------------------

-- Funzione per inizializzare sistema trasporti
local function initializeTransportSystem()
    -- Inizializza punti rinforzo per Blue (base iniziale)
    transportSystem.reinforcements[1] = {
        points = transportConfig.pointsPerCity,
        infantry = 0,
        lightVehicle = 0, 
        heavyVehicle = 0
    }
    
    -- Crea zone di atterraggio per città controllate da Blue
    for i, city in ipairs(cities) do
        if city.coalition == coalition.side.BLUE then
            local landingZone = ZONE:New(city.landingZone)
            if landingZone then
                transportSystem.landingZones[i] = landingZone
                env.info("Landing zone initialized for " .. city.displayName)
            end
        end
    end
end

-- Funzione per calcolare punti disponibili per rinforzi
local function calculateAvailablePoints()
    local earnedPoints = 0
    local controlledCities = 0
    local spentPoints = 0
    
    for i, city in ipairs(cities) do
        if city.coalition == coalition.side.BLUE then
            controlledCities = controlledCities + 1
            if city.strategic then
                earnedPoints = earnedPoints + transportConfig.pointsPerStrategicCity
            else
                earnedPoints = earnedPoints + transportConfig.pointsPerCity
            end
            
            -- Calcola punti già spesi per questa città
            if transportSystem.reinforcements[i] then
                spentPoints = spentPoints + (transportSystem.reinforcements[i].pointsUsed or 0)
            end
        end
    end
    
    local availablePoints = math.min(earnedPoints, transportConfig.maxStoredPoints) - spentPoints
    return math.max(0, availablePoints), controlledCities
end

-- Funzione per rilevare atterraggio elicottero in zona
local function checkHeliLanding(heliGroup, cityIndex)
    if not heliGroup or not heliGroup:IsAlive() then return false end
    
    local heliUnit = heliGroup:GetUnit(1)
    if not heliUnit or not heliUnit:IsAlive() then return false end
    
    local heliCoord = heliUnit:GetCoordinate()
    local landingZone = transportSystem.landingZones[cityIndex]
    
    if landingZone and heliCoord:IsInZone(landingZone) then
        local velocity = heliUnit:GetVelocityMPS()
        local onGround = heliUnit:InAir() == false
        
        -- Considera atterrato se velocità < 5 m/s e altitudine < 10m
        if velocity < 5 and (onGround or heliCoord:GetLandHeight() < 10) then
            return true
        end
    end
    
    return false
end

-- Funzione per determinare tipo e capacità elicottero
local function getHeliCapacity(heliType)
    for heliModel, capacity in pairs(transportConfig.heliCapacity) do
        if string.find(heliType, heliModel) then
            return capacity
        end
    end
    -- Default per elicotteri non specificati
    return {infantry = 8, lightVehicle = 0, heavyVehicle = 0}
end

-- Funzione per deployare rinforzi trasportati (solo se hai punti sufficienti)
local function deployTransportedReinforcements(cityIndex, reinforcementType, quantity)
    local city = cities[cityIndex]
    if not city or city.coalition ~= coalition.side.BLUE then
        return false
    end
    
    if not city.reinforcementPoints or #city.reinforcementPoints == 0 then
        BlueCC:MessageTypeToCoalition("No reinforcement points available in " .. city.displayName, MESSAGE.Type.Warning)
        return false
    end
    
    -- Calcola costo totale
    local unitCost = transportConfig.reinforcementCosts[reinforcementType] or 0
    local totalCost = unitCost * quantity
    local availablePoints = calculateAvailablePoints()
    
    if totalCost > availablePoints then
        BlueCC:MessageTypeToCoalition(string.format("Insufficient points! Need %d, have %d", totalCost, availablePoints), MESSAGE.Type.Warning)
        return false
    end
    
    local templateName = nil
    if reinforcementType == "infantry" then
        templateName = transportConfig.infantryTemplate
    elseif reinforcementType == "lightVehicle" then
        templateName = transportConfig.lightVehicleTemplate
    elseif reinforcementType == "heavyVehicle" then
        templateName = transportConfig.heavyVehicleTemplate
    end
    
    if not templateName or not spawnSystems[templateName] then 
        BlueCC:MessageTypeToCoalition("Template not available: " .. (templateName or "unknown"), MESSAGE.Type.Warning)
        return false 
    end
    
    -- Spawn rinforzi nei punti disponibili
    local deployedUnits = 0
    for i = 1, quantity do
        local pointIndex = ((i - 1) % #city.reinforcementPoints) + 1
        local spawnPoint = city.reinforcementPoints[pointIndex]
        
        local reinforcementGroup = spawnSystems[templateName]:SpawnFromVec2(POINT_VEC2:New(ZONE:New(spawnPoint):GetCoordinate():GetVec2()))
        
        if reinforcementGroup then
            deployedUnits = deployedUnits + 1
            
            -- Aggiungi AI per movimento casuale nell'area
            reinforcementGroup:PatrolZones({ZONE:New(city.zone)}, 50, "Vee")
            
            env.info("Deployed " .. reinforcementType .. " #" .. i .. " in " .. city.displayName)
        end
    end
    
    -- Aggiorna statistiche rinforzi
    if not transportSystem.reinforcements[cityIndex] then
        transportSystem.reinforcements[cityIndex] = {infantry = 0, lightVehicle = 0, heavyVehicle = 0, pointsUsed = 0}
    end
    
    transportSystem.reinforcements[cityIndex][reinforcementType] = 
        transportSystem.reinforcements[cityIndex][reinforcementType] + deployedUnits
    transportSystem.reinforcements[cityIndex].pointsUsed = 
        (transportSystem.reinforcements[cityIndex].pointsUsed or 0) + (unitCost * deployedUnits)
    
    BlueCC:MessageTypeToCoalition(string.format("%d %s units deployed in %s (Cost: %d points)", 
        deployedUnits, reinforcementType, city.displayName, unitCost * deployedUnits), MESSAGE.Type.Information)
    return true
end

-- Funzione per processare elicottero da trasporto atterrato
local function processTransportHeli(heliGroup, cityIndex)
    local heliType = heliGroup:GetTypeName()
    local capacity = getHeliCapacity(heliType)
    local city = cities[cityIndex]
    
    -- Simula scarico automatico basato su capacità elicottero
    local totalCapacity = capacity.infantry + capacity.lightVehicle + capacity.heavyVehicle
    if totalCapacity > 0 then
        -- Deploy automatico basato su capacità
        if capacity.infantry > 0 then
            deployTransportedReinforcements(cityIndex, "infantry", math.floor(capacity.infantry / 8))
        end
        if capacity.lightVehicle > 0 then
            deployTransportedReinforcements(cityIndex, "lightVehicle", capacity.lightVehicle)
        end
        if capacity.heavyVehicle > 0 then
            deployTransportedReinforcements(cityIndex, "heavyVehicle", capacity.heavyVehicle)
        end
        
        BlueCC:MessageTypeToCoalition(heliType .. " delivered reinforcements to " .. city.displayName, MESSAGE.Type.Information)
    end
end

-- Funzione per aggiornare zone di atterraggio dopo conquista
local function updateLandingZonesOnCapture(cityIndex)
    local city = cities[cityIndex]
    if city.coalition == coalition.side.BLUE then
        -- Abilita zona di atterraggio per città appena conquistata
        local landingZone = ZONE:New(city.landingZone)
        if landingZone then
            transportSystem.landingZones[cityIndex] = landingZone
            BlueCC:MessageTypeToCoalition("Landing zone now available in " .. city.displayName, MESSAGE.Type.Information)
            env.info("Landing zone activated for " .. city.displayName)
        end
    else
        -- Rimuovi zona di atterraggio se città persa
        if transportSystem.landingZones[cityIndex] then
            transportSystem.landingZones[cityIndex] = nil
            BlueCC:MessageTypeToCoalition("Landing zone lost in " .. city.displayName, MESSAGE.Type.Warning)
        end
    end
end

--------------------------------------------------------------------------------
-- SISTEMA AI RED COUNTER-ATTACK
--------------------------------------------------------------------------------

-- Funzione per lanciare counter-attack Red sulla città più vicina
local function launchRedCounterAttack()
    local targetCityIndex, distance = findClosestBlueCity()
    
    if not targetCityIndex then
        env.info("Red Counter-Attack: Nessuna città Blue trovata per attacco")
        return
    end
    
    local targetCity = cities[targetCityIndex]
    local targetZone = ZONE:New(targetCity.zone)
    
    if not targetZone then
        env.error("Counter-Attack: Zona target " .. targetCity.zone .. " non trovata")
        return
    end
    
    -- Controlla limite attacchi simultanei
    local activeAttacks = 0
    for _, attack in pairs(redCounterAttacks) do
        if attack.active then
            activeAttacks = activeAttacks + 1
        end
    end
    
    if activeAttacks >= redAIConfig.maxSimultaneousAttacks then
        env.info("Red Counter-Attack: Limite attacchi simultanei raggiunto")
        return
    end
    
    -- Lancia attacco con gruppo terrestre
    if spawnSystems[redAIConfig.attackGroupTemplate] then
        local attackGroup = spawnSystems[redAIConfig.attackGroupTemplate]:Spawn()
        if attackGroup then
            -- Ordina movimento verso città target
            local targetCoord = targetZone:GetCoordinate()
            attackGroup:TaskRouteToCoordinate(targetCoord, 30) -- 30 km/h velocità
            
            -- Traccia attacco
            redCounterAttacks[targetCityIndex] = {
                group = attackGroup,
                target = targetCityIndex,
                launchTime = timer.getTime(),
                active = true
            }
            
            -- Messaggio attacco
            BlueCC:MessageTypeToCoalition(
                string.format("[INTEL] Enemy forces detected moving toward %s! Distance: %.1f km", 
                    targetCity.displayName, distance/1000), 
                MESSAGE.Type.Information
            )
            
            env.info("Red Counter-Attack launched against " .. targetCity.displayName)
            
            -- Opzionale: Spawn trasporto aereo se configurato
            if spawnSystems[redAIConfig.transportTemplate] then
                local transportGroup = spawnSystems[redAIConfig.transportTemplate]:Spawn()
                if transportGroup then
                    -- Ordina trasporto verso zona
                    transportGroup:TaskRouteToCoordinate(targetCoord, 100) -- 100 km/h velocità heli
                    env.info("Red air transport deployed to support counter-attack")
                end
            end
            
            -- Scheduler per cleanup attacco dopo 30 minuti
            SCHEDULER:New(nil, function()
                if redCounterAttacks[targetCityIndex] then
                    redCounterAttacks[targetCityIndex].active = false
                end
            end, {}, 1800) -- 30 minuti timeout
        end
    else
        env.error("Counter-Attack Template '" .. redAIConfig.attackGroupTemplate .. "' non trovato")
    end
end

--------------------------------------------------------------------------------
-- SISTEMA VISIVO MAPPA F10 (Stile 4YA/TTI)
--------------------------------------------------------------------------------

-- Tabella per tracciare i marker della mappa
local mapMarkers = {}
local markerID = 1000  -- ID base per i marker

-- Funzione per creare/aggiornare marker sulla mappa F10
local function updateMapMarker(city, newCoalition)
    local cityData = cities[city]
    local coordinate = ZONE:New(cityData.zone):GetCoordinate()
    
    -- Rimuovi marker esistente se presente
    if mapMarkers[city] then
        coordinate:RemoveMark(mapMarkers[city])
    end
    
    -- Determina colore e simbolo in base al controllo
    local markerText = ""
    local markColor = ""
    
    if newCoalition == coalition.side.BLUE then
        if cityData.airfield then
            markerText = "[BLUE] AIR " .. cityData.displayName .. " [BLUE CONTROLLED]"
        elseif cityData.strategic then
            markerText = "[BLUE] STR " .. cityData.displayName .. " [BLUE CONTROLLED]"
        else
            markerText = "[BLUE] CTY " .. cityData.displayName .. " [BLUE CONTROLLED]"
        end
    elseif newCoalition == coalition.side.RED then
        if cityData.airfield then
            markerText = "[RED] AIR " .. cityData.displayName .. " [RED CONTROLLED]" 
        elseif cityData.strategic then
            markerText = "[RED] STR " .. cityData.displayName .. " [RED CONTROLLED]"
        else
            markerText = "[RED] CTY " .. cityData.displayName .. " [RED CONTROLLED]"
        end
    else
        markerText = "[CONTESTED] " .. cityData.displayName .. " [FIGHTING]"
    end
    
    -- Crea nuovo marker
    mapMarkers[city] = coordinate:MarkToCoalitionBlue(markerText)
    markerID = markerID + 1
    
    -- Log per debugging
    env.info("F10 Map Updated: " .. cityData.displayName .. " -> " .. (newCoalition == 1 and "RED" or "BLUE"))
end

--------------------------------------------------------------------------------
-- CREAZIONE ZONE CAPTURE E SPAWN SYSTEMS
--------------------------------------------------------------------------------

local captureZones = {}
local spawnSystems = {}

-- Inizializza tutte le zone capture e spawn systems
for i, cityData in ipairs(cities) do
    -- Crea zona capture
    local zone = ZONE:New(cityData.zone)
    if zone then
        local captureZone = ZONE_CAPTURE_COALITION:New(zone, cityData.coalition)
        captureZones[i] = captureZone
        
        -- Crea sistema spawn per rinforzi se specificato
        if cityData.reinforcementSpawn then
            spawnSystems[cityData.reinforcementSpawn] = SPAWN:New(cityData.reinforcementSpawn):InitLimit(3, 99)
        end
        
        -- Crea sistema spawn per pattuglie se specificato
        if cityData.patrolSpawn then
            spawnSystems[cityData.patrolSpawn] = SPAWN:New(cityData.patrolSpawn):InitLimit(2, 99)
            -- Spawn iniziale pattuglia
            spawnSystems[cityData.patrolSpawn]:Spawn()
        end
    end
end

-- Inizializza spawn systems per AFAC e Counter-Attack
if GROUP:FindByName(afacConfig.spawnTemplate) then
    spawnSystems[afacConfig.spawnTemplate] = SPAWN:New(afacConfig.spawnTemplate):InitLimit(afacConfig.maxAfacActive, 99)
    env.info("AFAC Spawn System initialized: " .. afacConfig.spawnTemplate)
else
    env.error("AFAC Template Group '" .. afacConfig.spawnTemplate .. "' not found in Mission Editor")
end

if GROUP:FindByName(redAIConfig.attackGroupTemplate) then
    spawnSystems[redAIConfig.attackGroupTemplate] = SPAWN:New(redAIConfig.attackGroupTemplate):InitLimit(redAIConfig.maxSimultaneousAttacks, 99)
    env.info("Red Counter-Attack Spawn System initialized: " .. redAIConfig.attackGroupTemplate)
else
    env.error("Red Attack Template Group '" .. redAIConfig.attackGroupTemplate .. "' not found in Mission Editor")
end

if GROUP:FindByName(redAIConfig.transportTemplate) then
    spawnSystems[redAIConfig.transportTemplate] = SPAWN:New(redAIConfig.transportTemplate):InitLimit(2, 99)
    env.info("Red Transport Spawn System initialized: " .. redAIConfig.transportTemplate)
else
    env.info("Red Transport Template Group '" .. redAIConfig.transportTemplate .. "' not found (optional)")
end

-- Inizializza template per rinforzi trasportabili
if GROUP:FindByName(transportConfig.infantryTemplate) then
    spawnSystems[transportConfig.infantryTemplate] = SPAWN:New(transportConfig.infantryTemplate):InitLimit(20, 99)
    env.info("Infantry Transport Template initialized: " .. transportConfig.infantryTemplate)
else
    env.info("Infantry Template '" .. transportConfig.infantryTemplate .. "' not found (optional)")
end

if GROUP:FindByName(transportConfig.lightVehicleTemplate) then
    spawnSystems[transportConfig.lightVehicleTemplate] = SPAWN:New(transportConfig.lightVehicleTemplate):InitLimit(10, 99)
    env.info("Light Vehicle Transport Template initialized: " .. transportConfig.lightVehicleTemplate)
else
    env.info("Light Vehicle Template '" .. transportConfig.lightVehicleTemplate .. "' not found (optional)")
end

if GROUP:FindByName(transportConfig.heavyVehicleTemplate) then
    spawnSystems[transportConfig.heavyVehicleTemplate] = SPAWN:New(transportConfig.heavyVehicleTemplate):InitLimit(5, 99)
    env.info("Heavy Vehicle Transport Template initialized: " .. transportConfig.heavyVehicleTemplate)
else
    env.info("Heavy Vehicle Template '" .. transportConfig.heavyVehicleTemplate .. "' not found (optional)")
end

-- Continua inizializzazione zone capture
for i, cityData in ipairs(cities) do
    if not captureZones[i] then
        env.info("Skipping zone capture initialization for city " .. i .. " (zone not found)")
        goto continue
    end
    
    local captureZone = captureZones[i]
    
    -- Imposta marker iniziale sulla mappa
    updateMapMarker(i, cityData.coalition)
    
    env.info("Initialized capture zone: " .. cityData.displayName)
    
    ::continue::
end

-- Verifica inizializzazione completata
for i, captureZone in ipairs(captureZones) do
    if captureZone then
        
        -- Imposta marker iniziale sulla mappa
        updateMapMarker(i, cityData.coalition)
        
        env.info("Initialized capture zone: " .. cityData.displayName)
    else
        env.error("ERRORE: Zona '" .. cityData.zone .. "' non trovata per " .. cityData.displayName)
    end
end

--------------------------------------------------------------------------------
-- EVENTI CAPTURE ZONE
--------------------------------------------------------------------------------

-- Funzione per gestire cambi di controllo zona
local function onZoneCaptured(zoneIndex, newCoalition, oldCoalition)
    local cityData = cities[zoneIndex]
    
    -- Aggiorna statistiche missione
    if oldCoalition == coalition.side.BLUE and newCoalition == coalition.side.RED then
        missionStats.blueControlledZones = missionStats.blueControlledZones - 1
        missionStats.redControlledZones = missionStats.redControlledZones + 1
    elseif oldCoalition == coalition.side.RED and newCoalition == coalition.side.BLUE then
        missionStats.blueControlledZones = missionStats.blueControlledZones + 1
        missionStats.redControlledZones = missionStats.redControlledZones - 1
        missionStats.zonesFlipped = missionStats.zonesFlipped + 1
    end
    
    -- Aggiorna marker sulla mappa F10 (stile 4YA/TTI)
    updateMapMarker(zoneIndex, newCoalition)
    
    -- Messaggi e logica in base al controllo
    if newCoalition == coalition.side.BLUE then
        -- Zona catturata dai Blue
        BlueCC:MessageTypeToCoalition(
            string.format("[SUCCESS] %s CAPTURED! Zones controlled: %d/6", 
                cityData.displayName, missionStats.blueControlledZones), 
            MESSAGE.Type.Information
        )
        
        -- Spawn rinforzi Blue se disponibili
        if cityData.reinforcementSpawn and spawnSystems[cityData.reinforcementSpawn] then
            spawnSystems[cityData.reinforcementSpawn]:Spawn()
            BlueCC:MessageTypeToCoalition("[REINFORCEMENT] Units deployed to " .. cityData.displayName, MESSAGE.Type.Information)
        end
        
        -- Abilita zona atterraggio per trasporti
        updateLandingZonesOnCapture(zoneIndex)
        
        -- Deploy AFAC automatico su città strategiche
        if cityData.strategic then
            deployAFAC(zoneIndex)
        end
        
        -- Deploy AFAC su città conquistata (eccetto base principale)
        if zoneIndex ~= 1 then  -- Non sulla base Blue principale
            SCHEDULER:New(nil, function()
                deployAFAC(zoneIndex)
            end, {}, 30) -- Deploy AFAC dopo 30s dalla conquista
        end
        
        -- Verifica condizione vittoria
        if missionStats.blueControlledZones >= 6 then
            BlueCC:MessageTypeToCoalition("[VICTORY] MISSION ACCOMPLISHED! All zones under Blue control!", MESSAGE.Type.Information)
            -- Trigger evento vittoria
        elseif missionStats.blueControlledZones >= 4 then
            BlueCC:MessageTypeToCoalition("[PROGRESS] Excellent progress! " .. (6 - missionStats.blueControlledZones) .. " zones remaining.", MESSAGE.Type.Information)
        end
        
    elseif newCoalition == coalition.side.RED then
        -- Zona (ri)catturata dai Red AI
        BlueCC:MessageTypeToCoalition(
            string.format("[ALERT] %s LOST! Enemy counterattack successful. Zones controlled: %d/6", 
                cityData.displayName, missionStats.blueControlledZones), 
            MESSAGE.Type.Information
        )
        
        -- Spawn rinforzi Red AI
        if cityData.reinforcementSpawn and spawnSystems[cityData.reinforcementSpawn] then
            spawnSystems[cityData.reinforcementSpawn]:Spawn()
        end
        
        -- Spawn pattuglia aggiuntiva se zona strategica
        if cityData.strategic and cityData.patrolSpawn and spawnSystems[cityData.patrolSpawn] then
            spawnSystems[cityData.patrolSpawn]:Spawn()
        end
        
        -- Rimuovi AFAC se città persa dai Blue
        removeAFAC(zoneIndex)
        
        -- Disabilita zona atterraggio per trasporti
        updateLandingZonesOnCapture(zoneIndex)
    end
    
    -- Log dettagliato per debugging
    env.info(string.format("Zone Control Change: %s -> %s | Blue: %d/6 | Red: %d/6", 
        cityData.displayName, 
        (newCoalition == 1 and "RED" or "BLUE"),
        missionStats.blueControlledZones,
        missionStats.redControlledZones
    ))
end

-- Associa eventi alle zone capture
for i, captureZone in ipairs(captureZones) do
    if captureZone then
        -- Override del metodo OnAfterCaptured per ogni zona
        captureZone.OnAfterCaptured = function(self, From, Event, To)
            local newCoalition = self:GetCoalition()
            local oldCoalition = (newCoalition == coalition.side.BLUE) and coalition.side.RED or coalition.side.BLUE
            onZoneCaptured(i, newCoalition, oldCoalition)
            self:__Guard(30)  -- Riavvia monitoraggio dopo 30s
        end
        
        -- Gestione zone contestate
        captureZone.OnEnterEmpty = function(self, From, Event, To)
            updateMapMarker(i, coalition.side.NEUTRAL)  -- Marker neutro per zona contestata
            BlueCC:MessageTypeToCoalition("[COMBAT] " .. cities[i].displayName .. " is CONTESTED!", MESSAGE.Type.Information)
        end
        
        -- Avvia monitoraggio zona
        captureZone:Start(15, 30)  -- Check ogni 15s, timeout 30s
    end
end

--------------------------------------------------------------------------------
-- SCHEDULER AUTOMATICI E AI MANAGEMENT
--------------------------------------------------------------------------------

-- Spawn automatico pattuglie AI ogni 10 minuti
SCHEDULER:New(nil, function()
    for i, cityData in ipairs(cities) do
        -- Spawn solo per zone sotto controllo Red e con pattuglie definite
        if captureZones[i] and captureZones[i]:GetCoalition() == coalition.side.RED and cityData.patrolSpawn then
            if spawnSystems[cityData.patrolSpawn] then
                spawnSystems[cityData.patrolSpawn]:Spawn()
                env.info("Auto-spawned patrol for " .. cityData.displayName)
            end
        end
    end
end, {}, 600, 600)  -- Ogni 10 minuti

-- Scheduler Counter-Attack Red ogni 15 minuti
SCHEDULER:New(nil, function()
    -- Solo se ci sono città Blue da attaccare (escludendo la base principale)
    local blueControlledCount = 0
    for i, captureZone in ipairs(captureZones) do
        if captureZone and i ~= 1 and captureZone:GetCoalition() == coalition.side.BLUE then
            blueControlledCount = blueControlledCount + 1
        end
    end
    
    if blueControlledCount > 0 then
        launchRedCounterAttack()
        env.info("Red Counter-Attack scheduler triggered - Blue cities available: " .. blueControlledCount)
    else
        env.info("Red Counter-Attack scheduler: No Blue cities to attack")
    end
end, {}, redAIConfig.counterAttackInterval, redAIConfig.counterAttackInterval)  -- Ogni 15 minuti

-- Statistiche missione ogni 5 minuti
SCHEDULER:New(nil, function()
    local missionTime = timer.getTime() - missionStats.missionStartTime
    local minutes = math.floor(missionTime / 60)
    
    BlueCC:MessageTypeToCoalition(
        string.format("[STATUS] MISSION STATUS [%02d:%02d]\nBlue Zones: %d/6\nRed Zones: %d/6\nZones Captured: %d", 
            math.floor(minutes/60), minutes%60,
            missionStats.blueControlledZones,
            missionStats.redControlledZones, 
            missionStats.zonesFlipped
        ), 
        MESSAGE.Type.Information
    )
end, {}, 300, 300)  -- Ogni 5 minuti

--------------------------------------------------------------------------------
-- MENU F10 PER INFORMAZIONI
--------------------------------------------------------------------------------

-- Menu principale informazioni missione
local mainMenu = MENU_COALITION:New(coalition.side.BLUE, "Medorent Conquest")

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "[STATUS] Zone Status", mainMenu, function()
    local statusMsg = "ZONE CONTROL STATUS:\n"
    for i, cityData in ipairs(cities) do
        if captureZones[i] then
            local currentCoal = captureZones[i]:GetCoalition()
            local status = (currentCoal == coalition.side.BLUE) and "[BLUE]" or "[RED]"
            local icon = ""
            if cityData.airfield then
                icon = "[AIR]"
            elseif cityData.strategic then  
                icon = "[STR]"
            else
                icon = "[CTY]"
            end
            statusMsg = statusMsg .. string.format("%s %s %s\n", icon, cityData.displayName, status)
        end
    end
    BlueCC:MessageTypeToCoalition(statusMsg, MESSAGE.Type.Information)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "[STATS] Mission Stats", mainMenu, function()
    local missionTime = timer.getTime() - missionStats.missionStartTime
    local minutes = math.floor(missionTime / 60)
    
    BlueCC:MessageTypeToCoalition(
        string.format("[STATISTICS] MISSION STATISTICS:\nTime: %02d:%02d\nZones Captured: %d\nCurrent Control: %d/6\nProgress: %.1f%%", 
            math.floor(minutes/60), minutes%60,
            missionStats.zonesFlipped,
            missionStats.blueControlledZones,
            (missionStats.blueControlledZones/6)*100
        ), 
        MESSAGE.Type.Information
    )
end)

-- Menu AFAC Management
local afacMenu = MENU_COALITION:New(coalition.side.BLUE, "[AFAC] Air Support")

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "[STATUS] AFAC Status", afacMenu, function()
    local statusMsg = "AFAC STATUS REPORT:\n"
    local activeCount = 0
    
    for i, cityData in ipairs(cities) do
        if captureZones[i] and captureZones[i]:GetCoalition() == coalition.side.BLUE and i ~= 1 then
            local afacGroup = afacGroups[i]
            if afacGroup and afacGroup:IsAlive() then
                statusMsg = statusMsg .. string.format("[ACTIVE] %s-%d over %s - Freq: %.1f\n", 
                    afacConfig.callsign, i, cityData.displayName, afacConfig.frequency)
                activeCount = activeCount + 1
            else
                statusMsg = statusMsg .. string.format("[AVAILABLE] %s - No AFAC on station\n", cityData.displayName)
            end
        end
    end
    
    statusMsg = statusMsg .. string.format("\nActive AFAC: %d/%d", activeCount, afacConfig.maxAfacActive)
    BlueCC:MessageTypeToCoalition(statusMsg, MESSAGE.Type.Information)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "[INTEL] Enemy Activity", afacMenu, function()
    local intelMsg = "ENEMY ACTIVITY REPORT:\n"
    local activeAttacks = 0
    
    for cityIndex, attack in pairs(redCounterAttacks) do
        if attack.active and attack.group and attack.group:IsAlive() then
            local elapsedTime = timer.getTime() - attack.launchTime
            local minutes = math.floor(elapsedTime / 60)
            intelMsg = intelMsg .. string.format("[THREAT] Attack on %s - %d min ago\n", 
                cities[cityIndex].displayName, minutes)
            activeAttacks = activeAttacks + 1
        end
    end
    
    if activeAttacks == 0 then
        intelMsg = intelMsg .. "[CLEAR] No active enemy threats detected\n"
    end
    
    -- Prossimo counter-attack previsto
    intelMsg = intelMsg .. string.format("\nNext enemy activity in ~%d minutes", 
        math.ceil(redAIConfig.counterAttackInterval / 60))
    
    BlueCC:MessageTypeToCoalition(intelMsg, MESSAGE.Type.Information)
end)

-- Menu Trasporto Truppe
local transportMenu = MENU_COALITION:New(coalition.side.BLUE, "[TRANSPORT] Troop Transport")

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "[STATUS] Transport Status", transportMenu, function()
    local availablePoints, controlledCities = calculateAvailablePoints()
    local statusMsg = "TRANSPORT SYSTEM STATUS:\n"
    statusMsg = statusMsg .. string.format("Available Reinforcement Points: %d\n", availablePoints)
    statusMsg = statusMsg .. string.format("Cities with Landing Zones: %d\n\n", #transportSystem.landingZones)
    
    statusMsg = statusMsg .. "LANDING ZONES:\n"
    for i, city in ipairs(cities) do
        if city.coalition == coalition.side.BLUE and transportSystem.landingZones[i] then
            local reinforcements = transportSystem.reinforcements[i] or {infantry = 0, lightVehicle = 0, heavyVehicle = 0}
            statusMsg = statusMsg .. string.format("[AVAILABLE] %s - Infantry: %d, Light Veh: %d, Heavy Veh: %d\n", 
                city.displayName, reinforcements.infantry, reinforcements.lightVehicle, reinforcements.heavyVehicle)
        end
    end
    
    statusMsg = statusMsg .. "\nREINFORCEMENT COSTS:\n"
    statusMsg = statusMsg .. string.format("Infantry Squad: %d points\n", transportConfig.reinforcementCosts.infantry)
    statusMsg = statusMsg .. string.format("Light Vehicle: %d points\n", transportConfig.reinforcementCosts.lightVehicle) 
    statusMsg = statusMsg .. string.format("Heavy Vehicle: %d points\n", transportConfig.reinforcementCosts.heavyVehicle)
    
    BlueCC:MessageTypeToCoalition(statusMsg, MESSAGE.Type.Information)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "[GUIDE] Transport Guide", transportMenu, function()
    local guideMsg = "HELICOPTER TRANSPORT GUIDE:\n\n"
    guideMsg = guideMsg .. "1. Land your helicopter in any controlled city's landing zone\n"
    guideMsg = guideMsg .. "2. Stay on ground for 10+ seconds to deploy reinforcements\n"
    guideMsg = guideMsg .. "3. Reinforcements are automatically deployed based on helicopter capacity\n\n"
    guideMsg = guideMsg .. "HELICOPTER CAPACITIES:\n"
    for heliType, capacity in pairs(transportConfig.heliCapacity) do
        guideMsg = guideMsg .. string.format("%s: %d infantry, %d light veh, %d heavy veh\n",
            heliType, capacity.infantry, capacity.lightVehicle, capacity.heavyVehicle)
    end
    guideMsg = guideMsg .. "\nNote: Reinforcements cost points generated from controlled cities"
    
    BlueCC:MessageTypeToCoalition(guideMsg, MESSAGE.Type.Information)
end)

--------------------------------------------------------------------------------
-- INIZIALIZZAZIONE FINALE
--------------------------------------------------------------------------------

-- Inizializza sistema trasporto truppe
initializeTransportSystem()

-- Scheduler per monitoraggio elicotteri da trasporto
SCHEDULER:New(nil, function()
    -- Controlla tutti i gruppi elicotteri Blue attivi
    local blueHelis = SET_GROUP:New():FilterCategories("helicopter"):FilterCoalitions("blue"):FilterStart()
    
    blueHelis:ForEachGroup(function(heliGroup)
        if heliGroup and heliGroup:IsAlive() then
            -- Controlla se elicottero è atterrato in zona di trasporto
            for cityIndex, landingZone in pairs(transportSystem.landingZones) do
                if checkHeliLanding(heliGroup, cityIndex) then
                    -- Processa solo una volta per atterraggio
                    local heliName = heliGroup:GetName()
                    if not transportSystem.troopTransports[heliName] then
                        transportSystem.troopTransports[heliName] = {
                            processedAt = cityIndex,
                            timestamp = timer.getTime()
                        }
                        processTransportHeli(heliGroup, cityIndex)
                    end
                end
            end
            
            -- Rimuovi elicotteri processati che sono decollati
            local heliName = heliGroup:GetName()
            if transportSystem.troopTransports[heliName] then
                local cityIndex = transportSystem.troopTransports[heliName].processedAt
                if not checkHeliLanding(heliGroup, cityIndex) then
                    transportSystem.troopTransports[heliName] = nil
                end
            end
        end
    end)
end, {}, 2, 15) -- Controlla ogni 15 secondi a partire da 2 secondi

-- Inizializza sistema trasporto truppe
initializeTransportSystem()

-- Scheduler per accumulare punti rinforzo ogni 5 minuti
SCHEDULER:New(nil, function()
    local availablePoints, controlledCities = calculateAvailablePoints() 
    if controlledCities > 0 then
        env.info("Transport points updated: " .. availablePoints .. " points available from " .. controlledCities .. " cities")
    end
end, {}, 30, 300) -- Ogni 5 minuti a partire da 30 secondi

env.info("=== CAPTURE ZONE MISSION INITIALIZED ===")
env.info("Cities configured: " .. #cities)
env.info("Capture zones active: " .. #captureZones) 
env.info("F10 Map markers enabled (4YA/TTI style)")
env.info("AFAC system enabled - Max active: " .. afacConfig.maxAfacActive)
env.info("Red Counter-Attack every " .. (redAIConfig.counterAttackInterval/60) .. " minutes")
env.info("Troop transport system enabled - Landing zones: " .. #transportSystem.landingZones)
env.info("PvE Mode: Blue vs AI Red")
env.info("========================================")

BlueCC:MessageTypeToCoalition("[MISSION] CAPTURE ZONE MISSION ACTIVE!\nObjective: Capture all 6 zones\nAFAC support available on captured cities\nAI will counter-attack every 15 minutes\nTroop transport available to captured cities\nUse F10 map to track progress", MESSAGE.Type.Information)