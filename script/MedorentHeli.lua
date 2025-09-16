local HeliReconDetection = nil
local PlayerTaskDispatcher = nil
local HeliReconLaserSpot = nil
local LaserCode = 1687
local AutoLaserEnabled = false

local triggerConvogli1 = ZONE:FindByName("TriggerConv1")
local triggerConvogli2 = ZONE:FindByName("TriggerConv2")
local triggerConvogli3 = ZONE:FindByName("TriggerConv3")
local triggerConvogli4 = ZONE:FindByName("TriggerConv4")

local ConvoyStatus = {
    convoy1 = { active = false, group = nil, spawn = nil },
    convoy2 = { active = false, group = nil, spawn = nil },
    convoy3 = { active = false, group = nil, spawn = nil },
    convoy4 = { active = false, group = nil, spawn = nil }
}

BlueCCPositionable = GROUP:FindByName("BLUE_HELICOMHQ")
BlueHQ = COMMANDCENTER:New(BlueCCPositionable, "HeliOPS Command Center", "HeliOPS Command Center")

local HeliMissions = MISSION:New(BlueHQ, "HeliOPS Missions", "Primary", "Missioni Heli Medorent", coalition.side.BLUE)

local OPSHeli = SET_GROUP:New()
OPSHeli:FilterCoalitions("blue")
OPSHeli:FilterCategories("helicopter")
OPSHeli:FilterStart()

BlueHQ:MessageToCoalition("Benvenuti nel Command Center HeliOPS", 30, "Benvenuti")

local HeliOPSMenu = MENU_COALITION:New(coalition.side.BLUE, "HeliOPS")
local HeliOPSMenuLaser = MENU_COALITION:New(coalition.side.BLUE, "Sistema Laser HeliRecon", HeliOPSMenu)
local HeliOPSMenuMissioni = MENU_COALITION:New(coalition.side.BLUE, "Missione Convogli Heli", HeliOPSMenu)
local HeliOPSMenuMissioniUtility = MENU_COALITION:New(coalition.side.BLUE, "Utility", HeliOPSMenuMissioni)
local HeliOPSMenuMissioniPattugliaHeli = MENU_COALITION:New(coalition.side.BLUE, "Pattuglia Heli RED", HeliOPSMenuMissioni)

local HeliOPSMenuMissioniConvoglio = MENU_COALITION:New(coalition.side.BLUE, "Convogli", HeliOPSMenuMissioni)


ConvoyStatus.convoy1.spawn = SPAWN:NewWithAlias("REDCON-V1", "Convoglio1")
ConvoyStatus.convoy2.spawn = SPAWN:NewWithAlias("REDCON-V1-1", "Convoglio2") 
ConvoyStatus.convoy3.spawn = SPAWN:NewWithAlias("REDCON-V1-2", "Convoglio3")
ConvoyStatus.convoy4.spawn = SPAWN:NewWithAlias("REDCON-V1-3", "Convoglio4")

SpawnHeliRecon = SPAWN:New("HeliRecon")
SpawnHeliRecon.InitKeepUnitNames = true
SpawnHeliRecon:InitLimit(1, 100)

local HeliReconDetection = nil
local PlayerTaskDispatcher = nil
local HeliReconLaserSpot = nil
local LaserCode = 1686
local AutoLaserEnabled = false

function InitializePlayerTaskSystem()
    local heliReconGroup = SpawnHeliRecon:GetFirstAliveGroup()
    if heliReconGroup and heliReconGroup:IsAlive() then
        if not HeliReconDetection then
            -- Configurazione Detection per HeliRecon
            local detectionSet = SET_GROUP:New()
            detectionSet:FilterPrefixes("HeliRecon")
            detectionSet:FilterStart()
            
            HeliReconDetection = DETECTION_AREAS:New(detectionSet, 6000)
            HeliReconDetection:SetRefreshTimeInterval(20)
            HeliReconDetection:FilterCategories(Unit.Category.GROUND_UNIT)
            HeliReconDetection:Start()
            
            -- Configurazione Task Dispatcher per GIOCATORI
            PlayerTaskDispatcher = TASK_A2G_DISPATCHER:New(HeliMissions, OPSHeli, HeliReconDetection)
            PlayerTaskDispatcher:SetSendMessages(true)
            PlayerTaskDispatcher:Start()
            
            -- Configurazione Sistema Laser HeliRecon
            InitializeLaserSystem(heliReconGroup)
            
            BlueHQ:MessageToCoalition("Sistema Task Giocatori: Detection + Task Dispatcher + Laser System attivi per tutti gli elicotteri blu controllati da player", 15, coalition.side.BLUE)
            env.info("Player Task System initialized - Tasks will be assigned to all blue helicopter players (including dynamic spawn from Damascus airport)")
            return true
        end
    end
    return false
end

function InitializeLaserSystem(heliReconGroup)
    if heliReconGroup and heliReconGroup:IsAlive() then
        -- Crea il sistema SPOT per il laser designation
        HeliReconLaserSpot = SPOT:New(heliReconGroup:GetUnit(1))
        
        -- Aggiungi evento per laser automatico quando vengono rilevati nuovi target
        if AutoLaserEnabled then
            HeliReconDetection:HandleEvent(EVENTS.DetectedNew, function(Detection, DetectedItem)
                LaserDetectedTargets(DetectedItem)
            end)
        end
        
        env.info(string.format("HeliRecon Laser System initialized - Laser Code: %d, Auto Laser: %s", LaserCode, AutoLaserEnabled and "ON" or "OFF"))
        BlueHQ:MessageToCoalition(string.format("Sistema Laser HeliRecon attivo - Codice Laser: %d", LaserCode), 10, coalition.side.BLUE)
    end
end

function LaserDetectedTargets(DetectedItem)
    if not HeliReconLaserSpot or not DetectedItem then return end
    
    local detectedUnits = DetectedItem.Set
    if detectedUnits and detectedUnits:Count() > 0 then
        -- Lasa il primo target rilevato nell'area
        local firstUnit = detectedUnits:GetFirst()
        if firstUnit and firstUnit:IsAlive() then
            local targetCoord = firstUnit:GetCoordinate()
            HeliReconLaserSpot:LaseOnCoordinate(targetCoord, LaserCode, 60) -- Lasa per 60 secondi
            
            local targetName = firstUnit:GetName() or "Target Sconosciuto"
            BlueHQ:MessageToCoalition(string.format("HeliRecon LASER ATTIVO su: %s (Codice: %d)", targetName, LaserCode), 8, coalition.side.BLUE)
            env.info(string.format("HeliRecon lasing target: %s at coordinates %s", targetName, targetCoord:ToStringLLDMS()))
        end
    end
end

function ManualLaserTarget()
    local heliReconGroup = SpawnHeliRecon:GetFirstAliveGroup()
    if not heliReconGroup or not heliReconGroup:IsAlive() then
        BlueHQ:MessageToCoalition("ERRORE: HeliRecon non attivo per laser manuale", 10, coalition.side.BLUE)
        return
    end
    
    if not HeliReconDetection then
        BlueHQ:MessageToCoalition("ERRORE: Sistema Detection non attivo", 10, coalition.side.BLUE)
        return
    end
    
    if not HeliReconLaserSpot then
        BlueHQ:MessageToCoalition("ERRORE: Sistema Laser non inizializzato", 10, coalition.side.BLUE)
        return
    end
    
    -- Trova il target più vicino al HeliRecon
    local reconCoord = heliReconGroup:GetCoordinate()
    local detectedItems = HeliReconDetection:GetDetectedItems()
    local nearestTarget = nil
    local nearestDistance = 999999
    
    for _, detectedItem in pairs(detectedItems) do
        local detectedUnits = detectedItem.Set
        if detectedUnits and detectedUnits:Count() > 0 then
            detectedUnits:ForEachUnit(function(unit)
                if unit and unit:IsAlive() then
                    local targetCoord = unit:GetCoordinate()
                    local distance = reconCoord:Get2DDistance(targetCoord)
                    
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestTarget = unit
                    end
                end
            end)
        end
    end
    
    if nearestTarget then
        local targetCoord = nearestTarget:GetCoordinate()
        HeliReconLaserSpot:LaseOnCoordinate(targetCoord, LaserCode, 45) -- Lasa per 45 secondi
        
        local targetName = nearestTarget:GetName() or "Target"
        BlueHQ:MessageToCoalition(string.format("LASER MANUALE attivato su: %s (Distanza: %.0fm, Codice: %d)", targetName, nearestDistance, LaserCode), 10, coalition.side.BLUE)
        env.info(string.format("Manual laser activated on: %s at distance %.0fm", targetName, nearestDistance))
    else
        BlueHQ:MessageToCoalition("Nessun target rilevato per laser manuale", 8, coalition.side.BLUE)
    end
end

function StopLaser()
    if HeliReconLaserSpot then
        HeliReconLaserSpot:LaseOff()
        BlueHQ:MessageToCoalition("Laser HeliRecon DISATTIVATO", 8, coalition.side.BLUE)
        env.info("HeliRecon laser deactivated")
    else
        BlueHQ:MessageToCoalition("Nessun laser attivo da disattivare", 8, coalition.side.BLUE)
    end
end

function ToggleAutoLaser()
    AutoLaserEnabled = not AutoLaserEnabled
    local status = AutoLaserEnabled and "ATTIVATO" or "DISATTIVATO"
    BlueHQ:MessageToCoalition(string.format("Laser Automatico HeliRecon: %s", status), 10, coalition.side.BLUE)
    env.info(string.format("Auto Laser toggled: %s", status))
end

function SetLaserCode(newCode)
    LaserCode = newCode
    BlueHQ:MessageToCoalition(string.format("Codice Laser cambiato a: %d", LaserCode), 8, coalition.side.BLUE)
    env.info(string.format("Laser code changed to: %d", LaserCode))
    
    -- Se c'è un laser attivo, fermalo e riavvialo con il nuovo codice
    if HeliReconLaserSpot and HeliReconLaserSpot:IsLasing() then
        BlueHQ:MessageToCoalition("Riavvio laser con nuovo codice...", 5, coalition.side.BLUE)
    end
end



function ShutdownPlayerTaskSystem()
    if PlayerTaskDispatcher then
        PlayerTaskDispatcher:Stop()
        PlayerTaskDispatcher = nil
    end
    if HeliReconDetection then
        HeliReconDetection:Stop()
        HeliReconDetection = nil
    end
    if HeliReconLaserSpot then
        HeliReconLaserSpot:LaseOff()
        HeliReconLaserSpot = nil
    end
    BlueHQ:MessageToCoalition("Sistema Task Giocatori + Laser completamente disattivato", 15, coalition.side.BLUE)
end

local function SpawnSingleConvoy(convoyId, zone)
    local convoy = ConvoyStatus[convoyId]
    

    if not convoy or not convoy.spawn then
        BlueHQ:MessageToCoalition(string.format("ERRORE %s: configurazione spawn non valida", convoyId), 10, coalition.side.BLUE)
        return false
    end

    if not zone then
        BlueHQ:MessageToCoalition(string.format("ERRORE %s: zona spawn non trovata", convoyId), 10, coalition.side.BLUE)
        return false
    end

    if convoy.active and convoy.group and convoy.group:IsAlive() then
        BlueHQ:MessageToCoalition(string.format("ATTENZIONE %s già attivo!", convoyId), 10, coalition.side.BLUE)
        return false
    end

    local newGroup = convoy.spawn:SpawnInZone(zone)
    if newGroup and newGroup:IsAlive() then
        convoy.group = newGroup
        convoy.active = true
        BlueHQ:MessageToCoalition(string.format("SUCCESSO %s attivato con successo", convoyId), 10, coalition.side.BLUE)
        
        function newGroup:OnEventDead()
            env.info(string.format("CONVOY DEBUG: %s destroyed", convoyId))
            if convoy then
                convoy.active = false
                convoy.group = nil
            end
        end
        
        return true
    else
        BlueHQ:MessageToCoalition(string.format("ERRORE spawn %s", convoyId), 10, coalition.side.BLUE)
        return false
    end
end

local function DestroySingleConvoy(convoyId)
    local convoy = ConvoyStatus[convoyId]
    
    if not convoy then
        BlueHQ:MessageToCoalition(string.format("ERRORE %s: configurazione non trovata", convoyId), 10, coalition.side.BLUE)
        return false
    end
    
    if convoy.active and convoy.group and convoy.group:IsAlive() then
        convoy.group:Destroy()
        convoy.active = false
        convoy.group = nil
        BlueHQ:MessageToCoalition(string.format("DISATTIVATO %s", convoyId), 10, coalition.side.BLUE)
        return true
    else
        BlueHQ:MessageToCoalition(string.format("ATTENZIONE %s già inattivo", convoyId), 10, coalition.side.BLUE)
        return false
    end
end

local HeliOPSAttivaConvogli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva/Riattiva TUTTI i Convogli", HeliOPSMenuMissioniConvoglio, function ()
    local activated = 0
    
    if SpawnSingleConvoy("convoy1", triggerConvogli1) then activated = activated + 1 end
    if SpawnSingleConvoy("convoy2", triggerConvogli2) then activated = activated + 1 end  
    if SpawnSingleConvoy("convoy3", triggerConvogli3) then activated = activated + 1 end
    if SpawnSingleConvoy("convoy4", triggerConvogli4) then activated = activated + 1 end
    
    BlueHQ:MessageToCoalition(string.format("Sistema Convogli: %d/4 attivati", activated), 20, coalition.side.BLUE)
end)

local HeliOPSDisattivaConvogli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva TUTTI i Convogli", HeliOPSMenuMissioniConvoglio, function ()
    local deactivated = 0
    
    if DestroySingleConvoy("convoy1") then deactivated = deactivated + 1 end
    if DestroySingleConvoy("convoy2") then deactivated = deactivated + 1 end
    if DestroySingleConvoy("convoy3") then deactivated = deactivated + 1 end
    if DestroySingleConvoy("convoy4") then deactivated = deactivated + 1 end
    
    BlueHQ:MessageToCoalition(string.format("Sistema Convogli: %d/4 disattivati", deactivated), 20, coalition.side.BLUE)
end)

local HeliOPSMenuConvoyIndividual = MENU_COALITION:New(coalition.side.BLUE, "Controllo Individuale", HeliOPSMenuMissioniConvoglio)
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

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Status Convogli", HeliOPSMenuMissioniConvoglio, function()
    local status = "STATUS CONVOGLI:\n"
    for id, convoy in pairs(ConvoyStatus) do
        local state = convoy.active and "ATTIVO" or "INATTIVO"
        status = status .. string.format("%s: %s\n", id:upper(), state)
    end
    BlueHQ:MessageToCoalition(status, 15, coalition.side.BLUE)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva HeliRecon Spotter", HeliOPSMenuMissioniUtility, function()
    local existingGroup = SpawnHeliRecon:GetFirstAliveGroup()
    if existingGroup and existingGroup:IsAlive() then
        BlueHQ:MessageToCoalition("HeliRecon Spotter già attivo!", 10, coalition.side.BLUE)
        return
    end
    
    local spawnedGroup = SpawnHeliRecon:Spawn()
    if spawnedGroup then
        BlueHQ:MessageToCoalition("HeliRecon Spotter attivato", 10, coalition.side.BLUE)
        env.info("DEBUG: HeliRecon spawned successfully - " .. spawnedGroup:GetName())
        
        SCHEDULER:New(nil, function()
            if InitializePlayerTaskSystem() then
                BlueHQ:MessageToCoalition("Sistema Task Giocatori: HeliRecon + Detection + Task Dispatcher per TUTTI gli elicotteri blu attivi", 15, coalition.side.BLUE)
            else
                BlueHQ:MessageToCoalition("AVVISO: Player Task System non inizializzato - Retry tra 10 sec", 10, coalition.side.BLUE)
            end
        end, {}, 3)
    else
        BlueHQ:MessageToCoalition("ERRORE: Spawn HeliRecon fallito - Verificare gruppo nel Mission Editor", 15, coalition.side.BLUE)
        env.info("ERROR: SpawnHeliRecon:Spawn() returned nil - Check Mission Editor group 'HeliRecon'")
    end
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva HeliRecon Spotter", HeliOPSMenuMissioniUtility, function()
    local spawnedGroup = SpawnHeliRecon:GetFirstAliveGroup()
    if spawnedGroup and spawnedGroup:IsAlive() then
        ShutdownPlayerTaskSystem()
        spawnedGroup:Destroy()
        BlueHQ:MessageToCoalition("HeliRecon Spotter e Sistema Task Giocatori disattivati", 15, coalition.side.BLUE)
    else
        ShutdownPlayerTaskSystem()
        BlueHQ:MessageToCoalition("Nessun HeliRecon attivo - Sistema Task Giocatori disattivato", 10, coalition.side.BLUE)
    end
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Status Sistema Task Giocatori", HeliOPSMenuMissioniUtility, function()
    local spawnedGroup = SpawnHeliRecon:GetFirstAliveGroup()
    local status = "STATUS SISTEMA TASK GIOCATORI:\n"
    if spawnedGroup and spawnedGroup:IsAlive() then
        local unitCount = spawnedGroup:GetSize()
        status = status .. string.format("HeliRecon Spotter: ATTIVO (%d unità)\n", unitCount)
        status = status .. string.format("Detection System: %s\n", HeliReconDetection and "ATTIVO" or "INATTIVO")
        status = status .. string.format("Player Task Dispatcher: %s\n", PlayerTaskDispatcher and "ATTIVO" or "INATTIVO")
        status = status .. string.format("Laser System: %s\n", HeliReconLaserSpot and "ATTIVO" or "INATTIVO")
        status = status .. string.format("Laser Code: %d\n", LaserCode)
        status = status .. string.format("Auto Laser: %s\n", AutoLaserEnabled and "ON" or "OFF")
        status = status .. "Sistema: OPERATIVO per task giocatori\n"
        status = status .. "Target: TUTTI gli elicotteri blu (spawn dinamico incluso)"
    else
        status = status .. "HeliRecon Spotter: INATTIVO\n"
        status = status .. "Detection System: INATTIVO\n"
        status = status .. "Player Task Dispatcher: INATTIVO\n"
        status = status .. "Laser System: INATTIVO\n"
        status = status .. "Sistema: Pronto per attivazione"
    end
    BlueHQ:MessageToCoalition(status, 15, coalition.side.BLUE)
end)

-- Menu Sistema Laser HeliRecon (ora sotto HeliOPS principale)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Laser Manuale Target Più Vicino", HeliOPSMenuLaser, function()
    ManualLaserTarget()
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Laser", HeliOPSMenuLaser, function()
    StopLaser()
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Toggle Auto-Laser ON/OFF", HeliOPSMenuLaser, function()
    ToggleAutoLaser()
end)

-- Sottomenu per Codici Laser Predefiniti
local HeliOPSMenuLaserCodes = MENU_COALITION:New(coalition.side.BLUE, "Cambia Codice Laser", HeliOPSMenuLaser)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Codice 1687 (Default)", HeliOPSMenuLaserCodes, function()
    SetLaserCode(1687)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Codice 1234", HeliOPSMenuLaserCodes, function()
    SetLaserCode(1234)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Codice 1111", HeliOPSMenuLaserCodes, function()
    SetLaserCode(1111)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Codice 1578", HeliOPSMenuLaserCodes, function()
    SetLaserCode(1578)
end)

MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Status Laser System", HeliOPSMenuLaser, function()
    local heliReconGroup = SpawnHeliRecon:GetFirstAliveGroup()
    local laserStatus = "STATUS SISTEMA LASER HELIRECON:\n"
    
    if heliReconGroup and heliReconGroup:IsAlive() then
        local reconCoord = heliReconGroup:GetCoordinate()
        local reconUnit = heliReconGroup:GetUnit(1)
        
        laserStatus = laserStatus .. string.format("HeliRecon: ATTIVO (%s)\n", heliReconGroup:GetName())
        laserStatus = laserStatus .. string.format("Posizione: %s\n", reconCoord:ToStringLLDMS())
        laserStatus = laserStatus .. string.format("Altitudine: %.0fm\n", reconCoord.y)
        laserStatus = laserStatus .. string.format("Laser System: %s\n", HeliReconLaserSpot and "OPERATIVO" or "NON INIZIALIZZATO")
        laserStatus = laserStatus .. string.format("Laser Attivo: %s\n", HeliReconLaserSpot and HeliReconLaserSpot:IsLasing() and "SI" or "NO")
        laserStatus = laserStatus .. string.format("Codice Laser: %d\n", LaserCode)
        laserStatus = laserStatus .. string.format("Auto-Laser: %s\n", AutoLaserEnabled and "ATTIVO" or "DISATTIVO")
        
        if HeliReconDetection then
            local detectedCount = 0
            local totalUnits = 0
            local nearestDistance = 999999
            local detectedItems = HeliReconDetection:GetDetectedItems()
            
            for _, detectedItem in pairs(detectedItems) do
                detectedCount = detectedCount + 1
                local detectedUnits = detectedItem.Set
                if detectedUnits and detectedUnits:Count() > 0 then
                    detectedUnits:ForEachUnit(function(unit)
                        if unit and unit:IsAlive() then
                            totalUnits = totalUnits + 1
                            local distance = reconCoord:Get2DDistance(unit:GetCoordinate())
                            if distance < nearestDistance then
                                nearestDistance = distance
                            end
                        end
                    end)
                end
            end
            
            laserStatus = laserStatus .. string.format("Detection: ATTIVO (%d aree, %d unità)\n", detectedCount, totalUnits)
            if nearestDistance < 999999 then
                laserStatus = laserStatus .. string.format("Target più vicino: %.0fm", nearestDistance)
            else
                laserStatus = laserStatus .. "Nessun target rilevato"
            end
        else
            laserStatus = laserStatus .. "Detection: NON ATTIVO"
        end
    else
        laserStatus = laserStatus .. "HeliRecon: NON ATTIVO\n"
        laserStatus = laserStatus .. "Attivare prima HeliRecon Spotter"
    end
    
    BlueHQ:MessageToCoalition(laserStatus, 20, coalition.side.BLUE)
end)



SpawnPattugliaHeli = SPAWN:New("PattugliaHeliScout")
SpawnPattugliaHeli.InitKeepUnitNames = true
SpawnPattugliaHeli:InitLimit( 3, 200 )

local HeliOPSAttivaPattugliaHeli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Pattuglia Heli", HeliOPSMenuMissioniPattugliaHeli, function ()
    SpawnPattugliaHeli:Spawn()
    BlueHQ:MessageToCoalition("Pattuglia Heli Attivata", 20, coalition.side.BLUE, "PattugliaHeli")
end)

local HeliOPSDisattivaPattugliaHeli = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Pattuglia Heli", HeliOPSMenuMissioniPattugliaHeli, function ()
    local spawnedGroup = SpawnPattugliaHeli:GetFirstAliveGroup()
    if spawnedGroup and spawnedGroup:IsAlive() then
        spawnedGroup:Destroy()
        BlueHQ:MessageToCoalition("Pattuglia Heli Disattivata", 20, coalition.side.BLUE, "PattugliaHeli")
    else
        BlueHQ:MessageToCoalition("Nessuna Pattuglia Heli attiva da disattivare", 10, coalition.side.BLUE, "PattugliaHeli")
    end
end)

BastardiRandom = SPAWN:New("StingerBastardi")
BastardiRandom:InitLimit( 8, 100 )

function SpawnaBastardi()
    ZonatriggerBastardi = ZONE:FindByName("ZonaBastardi")
    BastardiRandom:SpawnInZone(ZonatriggerBastardi, true)
end

local TIMERSpawnStinger = SCHEDULER:New(nil, SpawnaBastardi, {}, 0, 1800)
TIMERSpawnStinger:Start()