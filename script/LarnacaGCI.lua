-- ===== LARNACA GCI SYSTEM =====
-- Sistema A2A Dispatcher per controllo spazio aereo di Cipro
-- CAP persistente (2x Su-30) + GCI reattivo (MiG-29)
-- Versione: 1.1 - Correzione BorderZone
-- Data: 20/09/2025

-- ==================================================
-- 1. CONFIGURAZIONE SISTEMA DETECTION
-- ==================================================
local DetectionSetGroup = SET_GROUP:New()
DetectionSetGroup:FilterPrefixes({"CiproEW"})  -- Prefisso unità EW nel ME
DetectionSetGroup:FilterStart()

-- Crea area di detection con raggio 30km per ogni unità EW
local Detection = DETECTION_AREAS:New(DetectionSetGroup, 30000)

-- ==================================================
-- 2. CREAZIONE A2A DISPATCHER
-- ==================================================
local A2ADispatcher = AI_A2A_DISPATCHER:New(Detection)

-- ==================================================
-- 3. CONFIGURAZIONE BORDER ZONE
-- ==================================================
-- IMPORTANTE: "CiproBorder" deve essere un GRUPPO nel ME con waypoint che definiscono il perimetro
local BorderZone = nil  -- Variabile globale per la zona

local borderGroup = GROUP:FindByName("CiproBorder")
if borderGroup then
    BorderZone = ZONE_POLYGON:New("CiproBorderZone", borderGroup)
    A2ADispatcher:SetBorderZone(BorderZone)
    env.info("LarnacaGCI: Border zone configurata da gruppo 'CiproBorder'")
else
    -- Fallback: prova a cercare una trigger zone
    local triggerZone = trigger.misc.getZone("CiproBorder")
    if triggerZone then
        -- Crea una zona circolare basata sulla trigger zone
        local zonePos = {x = triggerZone.point.x, y = 0, z = triggerZone.point.z}
        BorderZone = ZONE_RADIUS:New("CiproBorderZone", zonePos, triggerZone.radius or 50000)
        A2ADispatcher:SetBorderZone(BorderZone)
        env.info("LarnacaGCI: Border zone configurata da trigger zone 'CiproBorder'")
    else
        -- Ultima risorsa: crea zona default centrata su Larnaca
        env.warning("LarnacaGCI: 'CiproBorder' non trovato! Uso zona default su Larnaca")
        local larnacaVec2 = AIRBASE:FindByName(AIRBASE.Syria.Larnaca):GetVec2()
        BorderZone = ZONE_RADIUS:New("CiproBorderDefault", larnacaVec2, 60000)
        A2ADispatcher:SetBorderZone(BorderZone)
    end
end

-- ==================================================
-- 4. IMPOSTAZIONI GLOBALI DEFAULT
-- ==================================================
-- Queste impostazioni si applicano a TUTTI gli squadron se non sovrascritte
A2ADispatcher:SetDefaultTakeoff(AI_A2A_DISPATCHER.Takeoff.Air)  -- Default: spawn in aria
A2ADispatcher:SetDefaultTakeoffInAir(3000, 5000)                -- Altitudine spawn 3000-5000m
A2ADispatcher:SetDefaultLandingAtRunway()                        -- Atterraggio su pista
A2ADispatcher:SetDefaultFuelThreshold(0.25)                      -- RTB al 25% carburante

-- ==================================================
-- 5. DEFINIZIONE SQUADRONS
-- ==================================================

-- Squadron CAP: Su-30 da Larnaca
A2ADispatcher:SetSquadron(
    "CiproSU30Squadron",           -- Nome squadron
    AIRBASE.Syria.Larnaca,         -- Base di partenza
    {"RedCAPSu30"}                 -- Template group nel ME (Late Activation)
)

-- Squadron GCI: MiG-29 da Larnaca  
A2ADispatcher:SetSquadron(
    "RedGCIMig29",                 -- Nome squadron
    AIRBASE.Syria.Larnaca,         -- Base di partenza (stessa di Su-30)
    {"RedGCIMig29"}                -- Template group nel ME (Late Activation)
)

-- ==================================================
-- 6. CONFIGURAZIONE SPECIFICA PER SQUADRON
-- ==================================================

-- SU-30: Possono partire dal parking (Larnaca è grande)
A2ADispatcher:SetSquadronTakeoff("CiproSU30Squadron", AI_A2A_DISPATCHER.Takeoff.Hot)

-- MIG-29: Partono dalla pista come i Su-30 (Hot Start)
A2ADispatcher:SetSquadronTakeoff("RedGCIMig29", AI_A2A_DISPATCHER.Takeoff.Hot)

-- ==================================================
-- 7. CONFIGURAZIONE CAP PERSISTENTE (Su-30)
-- ==================================================
-- IMPORTANTE: Usa la BorderZone definita sopra
if BorderZone then
    A2ADispatcher:SetSquadronCap(
        "CiproSU30Squadron",    -- Squadron
        BorderZone,             -- Zona di pattugliamento
        4000,                   -- Altitudine minima (metri)
        8000,                   -- Altitudine massima (metri)  
        500,                    -- Velocità minima (km/h)
        800                     -- Velocità massima (km/h)
    )
    
    -- Mantieni sempre 2 Su-30 in CAP
    A2ADispatcher:SetSquadronCapInterval(
        "CiproSU30Squadron",    -- Squadron
        2,                      -- Numero di aerei sempre in CAP
        30,                     -- Tempo minimo tra spawn (secondi)
        60,                     -- Tempo massimo tra spawn (secondi)
        1                       -- Fill rate (velocità di rimpiazzo)
    )
else
    env.error("LarnacaGCI: BorderZone non definita, CAP non configurato!")
end

-- ==================================================
-- 8. CONFIGURAZIONE GCI REATTIVO (MiG-29)
-- ==================================================
A2ADispatcher:SetSquadronGci(
    "RedGCIMig29",          -- Squadron
    900,                    -- Velocità minima intercetto (km/h)
    1200                    -- Velocità massima intercetto (km/h)
)

-- Overhead: quanti MiG per ogni minaccia (1.0 = rapporto 1:1)
A2ADispatcher:SetSquadronOverhead("RedGCIMig29", 1.0)

-- Grouping: massimo aerei per flight
A2ADispatcher:SetSquadronGrouping("RedGCIMig29", 4)  -- Max 4 MiG per gruppo

-- ==================================================
-- 9. PARAMETRI TATTICI
-- ==================================================
A2ADispatcher:SetEngageRadius(80000)       -- Raggio ingaggio: 80km dal border
A2ADispatcher:SetGciRadius(150000)         -- Raggio reazione GCI: 150km
A2ADispatcher:SetDisengageRadius(120000)   -- Raggio disimpegno: 120km

-- ==================================================
-- 10. OPZIONI DEBUG E VISUALIZZAZIONE
-- ==================================================
-- Abilita display tattico per debug (decommentare se necessario)
-- A2ADispatcher:SetTacticalDisplay(true)

-- Event handlers per monitoraggio
function A2ADispatcher:OnAfterSpawn(From, Event, To, SpawnGroup, SpawnedGroup)
    if SpawnedGroup and SpawnedGroup:IsAlive() then
        local groupName = SpawnedGroup:GetName()
        local groupSize = SpawnedGroup:GetSize()
        local leader = SpawnedGroup:GetUnit(1)
        if leader then
            local coord = leader:GetCoordinate()
            local alt = coord:GetLandHeight()
            env.info(string.format("LarnacaGCI: SPAWN - %s (%d aerei) - Alt: %dm", groupName, groupSize, alt))
        else
            env.info(string.format("LarnacaGCI: SPAWN - %s (%d aerei)", groupName, groupSize))
        end
    end
end

function A2ADispatcher:OnAfterLand(From, Event, To, SpawnGroup, SpawnedGroup, AirbaseName)
    if SpawnedGroup and SpawnedGroup:IsAlive() then
        local groupName = SpawnedGroup:GetName()
        env.info(string.format("LarnacaGCI: LAND - %s at %s", groupName, AirbaseName or "unknown"))
    end
end

-- Event handler per crash monitoring
function A2ADispatcher:OnAfterCrash(From, Event, To, SpawnGroup, SpawnedGroup)
    if SpawnedGroup then
        local groupName = SpawnedGroup:GetName() or "Unknown"
        env.warning(string.format("LarnacaGCI: CRASH - %s", groupName))
    end
end

-- ==================================================
-- 11. AVVIO SISTEMA
-- ==================================================
A2ADispatcher:Start()

-- ==================================================
-- 12. LOG FINALE CONFIGURAZIONE
-- ==================================================
env.info("========================================")
env.info("=== LARNACA GCI SYSTEM ATTIVO ===")
env.info("========================================")
env.info("CAP Squadron: 2x Su-30 da Larnaca (Hot Start)")
env.info("GCI Squadron: MiG-29 da Larnaca (Hot Start)")
env.info("Detection: Unità con prefisso 'CiproEW'")
if BorderZone then
    env.info("Border Zone: " .. BorderZone:GetName())
else
    env.info("Border Zone: NON CONFIGURATA!")
end
env.info("Engage Range: 80km | GCI Range: 100km")
env.info("========================================")

-- ==================================================
-- REQUISITI NEL MISSION EDITOR:
-- ==================================================
-- OPZIONE A - Usa un GRUPPO per definire il perimetro:
--   1. Crea un gruppo chiamato "CiproBorder" (qualsiasi tipo)
--   2. Impostalo come "Late Activation"
--   3. I waypoint del gruppo definiscono i vertici del poligono
--
-- OPZIONE B - Usa una TRIGGER ZONE:
--   1. Crea una trigger zone circolare chiamata "CiproBorder"
--   2. Posizionala e dimensionala come desideri
--
-- ALTRI REQUISITI:
--   1. GRUPPO "RedCAPSu30": Late Activation, template Su-30 (da Larnaca, Hot Start)
--   2. GRUPPO "RedGCIMig29": Late Activation, template MiG-29 (da Larnaca, Hot Start)
--   3. UNITÀ EW: Con prefisso "CiproEW" per il sistema di detection
-- ==================================================