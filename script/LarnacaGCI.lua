-- ===== LARNACA GCI SYSTEM =====
-- Sistema CAP + GCI per difesa dello spazio aereo di Cipro
-- CAP persistente (Su-30 da Ercan) + GCI reattivo (MiG-29 da Larnaca)
-- Versione: 3.1 - CAP su Ercan, GCI su Larnaca (due AIRWING separati)
-- Data: 26/03/2026
--
-- REQUISITI MISSION EDITOR:
--   STATIC OBJECT (RED): "RedAirWingErcan"   — piazzato a Ercan   (< 5km dalla pista)
--   STATIC OBJECT (RED): "RedAirWingLarnaca" — piazzato a Larnaca (< 5km dalla pista)
--   GRUPPO template (RED, Late Activation): "RedCAPSu30"  — 2x Su-30, parcheggiato a ERCAN
--   GRUPPO template (RED, Late Activation): "RedGCIMig29" — 2x MiG-29, parcheggiato a LARNACA
--   Unità EW: qualsiasi unità con prefisso "CiproEW"
--   Border zone: gruppo "CiproBorder" (waypoints = perimetro) o trigger zone "CiproBorder"

-- ==================================================
-- 1. CONFIGURAZIONE ZONA CONFINE
-- ==================================================
local BorderZone = nil

local borderGroup = GROUP:FindByName("CiproBorder")
if borderGroup then
    BorderZone = ZONE_POLYGON:New("CiproBorderZone", borderGroup)
    env.info("LarnacaGCI: Border zone configurata da gruppo 'CiproBorder'")
else
    local triggerZone = trigger.misc.getZone("CiproBorder")
    if triggerZone then
        local zoneVec2 = { x = triggerZone.point.x, y = triggerZone.point.z }
        BorderZone = ZONE_RADIUS:New("CiproBorderZone", zoneVec2, triggerZone.radius or 50000)
        env.info("LarnacaGCI: Border zone configurata da trigger zone 'CiproBorder'")
    else
        env.warning("LarnacaGCI: 'CiproBorder' non trovato, uso zona default (60km da Larnaca)")
        local larnacaVec2 = AIRBASE:FindByName(AIRBASE.Syria.Larnaca):GetVec2()
        BorderZone = ZONE_RADIUS:New("CiproBorderDefault", larnacaVec2, 60000)
    end
end

local capCenter = BorderZone:GetCoordinate()

-- ==================================================
-- 2. SQUADRONS: Su-30 CAP (Ercan) + MiG-29 GCI (Larnaca)
-- ==================================================

-- CAP Squadron — 2 Su-30 per volo, 4 cloni disponibili (rimpiazzo perdite)
-- Il gruppo template "RedCAPSu30" deve essere parcheggiato a ERCAN nel ME
local sqCAP = SQUADRON:New("RedCAPSu30", 4, "CiproCAP-Su30")
if not sqCAP then
    env.error("LarnacaGCI: ERRORE - Gruppo template 'RedCAPSu30' non trovato nel ME!")
else
    sqCAP:AddMissionCapability({ AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT }, 90)
    sqCAP:SetGrouping(2)          -- 2 Su-30 per formazione
    sqCAP:SetTakeoffHot()         -- Hot start dalla pista
    sqCAP:SetFuelLowThreshold(0.3)
    sqCAP:SetFuelLowRefuel(false) -- nessun tanker disponibile → RTB
    sqCAP:SetTurnoverTime(15, 30) -- 15-30 min manutenzione dopo atterraggio
    env.info("LarnacaGCI: Squadron CAP Su-30 configurato (4 slots, 2 per flight) → Ercan")
end

-- GCI Squadron — 2 MiG-29 per intercetto, max 2 intercetti contemporanei
-- Il gruppo template "RedGCIMig29" deve essere parcheggiato a LARNACA nel ME
local sqGCI = SQUADRON:New("RedGCIMig29", 2, "CiproGCI-Mig29")
if not sqGCI then
    env.error("LarnacaGCI: ERRORE - Gruppo template 'RedGCIMig29' non trovato nel ME!")
else
    sqGCI:AddMissionCapability({ AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.GCICAP }, 90)
    sqGCI:SetGrouping(2)          -- 2 MiG-29 per intercetto
    sqGCI:SetTakeoffHot()
    sqGCI:SetFuelLowThreshold(0.3)
    sqGCI:SetFuelLowRefuel(false)
    sqGCI:SetTurnoverTime(10, 20)
    env.info("LarnacaGCI: Squadron GCI MiG-29 configurato (2 slots, 2 per flight) → Larnaca")
end

-- ==================================================
-- 3a. AIRWING ERCAN: CAP Su-30
-- ==================================================
local _anchorErcan = StaticObject.getByName("RedAirWingErcan") or Unit.getByName("RedAirWingErcan")
if not _anchorErcan then
    env.error("LarnacaGCI: ERRORE CRITICO - 'RedAirWingErcan' non trovato nel ME!\n" ..
              "  → Aggiungere uno STATIC OBJECT (RED) chiamato 'RedAirWingErcan' a Ercan.")
    return
end

local AirWingCAP = AIRWING:New("RedAirWingErcan", "Ercan Red AirWing CAP")
if not AirWingCAP then
    env.error("LarnacaGCI: ERRORE - AIRWING Ercan non inizializzato.")
else
    AirWingCAP:SetTakeoffHot()
    AirWingCAP:SetDespawnAfterLanding()
    AirWingCAP:SetNumberCAP(1)   -- 1 volo CAP attivo (2 Su-30)

    if sqCAP then
        AirWingCAP:AddSquadron(sqCAP)
        AirWingCAP:NewPayload("RedCAPSu30", -1, { AUFTRAG.Type.GCICAP, AUFTRAG.Type.INTERCEPT }, 90)
    end

    -- Patrol point CAP sopra il centro della border zone
    -- MOOSE vuole PIEDI e NODI: 27000ft ≈ 8230m, 300kts
    AirWingCAP:AddPatrolPointCAP(capCenter, 27000, 300, 90, 40)

    AirWingCAP:Start()
    env.info("LarnacaGCI: AIRWING Ercan (CAP) avviato")
end

-- ==================================================
-- 3b. AIRWING LARNACA: GCI MiG-29
-- ==================================================
local _anchorLarnaca = StaticObject.getByName("RedAirWingLarnaca") or Unit.getByName("RedAirWingLarnaca")
if not _anchorLarnaca then
    env.error("LarnacaGCI: ERRORE CRITICO - 'RedAirWingLarnaca' non trovato nel ME!\n" ..
              "  → Aggiungere uno STATIC OBJECT (RED) chiamato 'RedAirWingLarnaca' a Larnaca.")
    return
end

local AirWingGCI = AIRWING:New("RedAirWingLarnaca", "Larnaca Red AirWing GCI")
if not AirWingGCI then
    env.error("LarnacaGCI: ERRORE - AIRWING Larnaca non inizializzato.")
else
    AirWingGCI:SetTakeoffHot()
    AirWingGCI:SetDespawnAfterLanding()

    if sqGCI then
        AirWingGCI:AddSquadron(sqGCI)
        AirWingGCI:NewPayload("RedGCIMig29", -1, { AUFTRAG.Type.INTERCEPT, AUFTRAG.Type.GCICAP }, 90)
    end

    AirWingGCI:Start()
    env.info("LarnacaGCI: AIRWING Larnaca (GCI) avviato")
end

-- ==================================================
-- 5. SISTEMA DETECTION per GCI reattivo
-- ==================================================
local DetectionSetGroup = SET_GROUP:New()
DetectionSetGroup:FilterPrefixes({ "CiproEW" })
DetectionSetGroup:FilterStart()

local Detection = DETECTION_AREAS:New(DetectionSetGroup, 100000)

-- Tabella anti-duplicazione GCI: { [groupName] = timestamp ultimo scramble }
-- Impedisce di lanciare più intercetti sullo stesso gruppo prima che il cooldown scada.
local gciLastScramble = {}
local GCI_COOLDOWN_SEC = 300  -- 5 minuti: non ri-scramblare lo stesso gruppo prima di allora

-- Callback: nuovo contatto rilevato; dispatcha intercetto via AirWingGCI
function Detection:OnAfterDetectedItem(From, Event, To, DetectedItem)
    if not AirWingGCI then return end
    if not DetectedItem or not DetectedItem.Set then return end

    local dispatched = {}
    DetectedItem.Set:ForEachUnit(function(unit)
        if not unit or not unit:IsAlive() then return end
        local grp = unit:GetGroup()
        if not grp or not grp:IsAlive() then return end
        local gName = grp:GetName()
        if dispatched[gName] then return end
        dispatched[gName] = true

        if grp:GetCoalition() ~= coalition.side.BLUE then return end

        -- Verifica distanza: GCI solo entro 120km dal centro della border zone
        local threatCoord = grp:GetCoordinate()
        if not threatCoord then return end
        local dist = BorderZone:GetCoordinate():Get2DDistance(threatCoord)
        if dist > 120000 then return end

        -- Anti-duplicazione: non ri-scramblare lo stesso gruppo prima del cooldown
        local now = timer.getTime()
        if gciLastScramble[gName] and (now - gciLastScramble[gName]) < GCI_COOLDOWN_SEC then
            return
        end
        gciLastScramble[gName] = now

        -- AirWingGCI (Larnaca) assegna l'intercetto a un MiG-29 disponibile
        local gciAuftrag = AUFTRAG:NewINTERCEPT(grp)
        AirWingGCI:AddMission(gciAuftrag)

        env.info(string.format("LarnacaGCI: GCI SCRAMBLE → %s (dist=%.0fkm)", gName, dist / 1000))
    end)
end

Detection:Start()

-- ==================================================
-- 6. LOG FINALE CONFIGURAZIONE
-- ==================================================
env.info("========================================")
env.info("=== LARNACA GCI SYSTEM ATTIVO ===")
env.info("========================================")
env.info("API: AIRWING + SQUADRON (MOOSE develop)")
env.info("CAP: 1 volo Su-30 permanente (2 aerei, Hot Start da ERCAN)")
env.info("GCI: 2x MiG-29 per intercetto, max 2 contemporanei, cooldown 5min (da LARNACA)")
env.info("Detection EW: prefisso 'CiproEW', raggio 100km")
env.info("Border Zone: " .. (BorderZone and BorderZone:GetName() or "NON CONFIGURATA!"))
env.info("AirWing Ercan  (CAP): " .. (AirWingCAP and "ATTIVO" or "ERRORE!"))
env.info("AirWing Larnaca (GCI): " .. (AirWingGCI and "ATTIVO" or "ERRORE!"))
env.info("========================================")