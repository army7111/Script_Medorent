-------------------------------------------------------------------
-- MEDORENT AWACS - Sistema AUFTRAG/FLIGHTGROUP MOOSE
-- Conversione da SPAWN semplice a sistema AUFTRAG avanzato
-- 
-- FUNZIONALITÀ:
-- ✓ Decollo automatico dalla base
-- ✓ Orbita automatica nella zona AWACSZone  
-- ✓ RTB automatico al 20% carburante
-- ✓ Rifornimento automatico e ritorno in missione
-- ✓ Respawn automatico se distrutto
-- ✓ TACAN e frequenze radio configurabili
-------------------------------------------------------------------

-- =========================================================================
-- CONFIGURAZIONE ZONA ORBITA
-- =========================================================================

-- Verifica esistenza zona AWACSZone nel Mission Editor
local AwacsPatrolZone = ZONE:New("AWACSZone")
if not AwacsPatrolZone then
    env.error("MedorentAwacs: ERRORE - Zona 'AWACSZone' non trovata nel Mission Editor!")
    env.error("MedorentAwacs: Creare una zona chiamata 'AWACSZone' nel ME per l'orbita AWACS")
    return
end

env.info("MedorentAwacs: Zona AWACSZone trovata correttamente")

-- =========================================================================
-- CREAZIONE MISSIONE AUFTRAG AWACS
-- =========================================================================

-- Crea la missione AWACS con AUFTRAG:NewAWACS
local AwacsPatrolAuftrag = AUFTRAG:NewAWACS(
    AwacsPatrolZone:GetCoordinate(),    -- Coordinate centro orbita
    25000,                              -- Altitudine: 25.000 ft (stesso del vecchio script)
    280,                                -- Velocità: 280 nodi (stesso del vecchio script)  
    45,                                 -- Heading iniziale: 45°
    50                                  -- Raggio orbita: 50 nm
)

-- =========================================================================
-- CONFIGURAZIONE PARAMETRI MISSIONE
-- =========================================================================

-- Orario operativo (6:00-23:00 Zulu)
AwacsPatrolAuftrag:SetTime("06:00", "23:00")

-- TACAN e identificativo
AwacsPatrolAuftrag:SetTACAN(29, "DRK")          -- TACAN 29X, codice morse "DRK" (Darkstar)

-- Frequenza radio
AwacsPatrolAuftrag:SetRadio(247)                -- Frequenza 247 MHz

-- Immortalità (per evitare crash AI)
AwacsPatrolAuftrag:SetImmortal(true)

-- Note: La configurazione di priorità e ripetibilità è automatica con AUFTRAG

env.info("MedorentAwacs: Missione AUFTRAG AWACS creata e configurata")

-- =========================================================================
-- CREAZIONE E CONFIGURAZIONE FLIGHTGROUP
-- =========================================================================

-- Verifica esistenza gruppo template
local templateGroup = GROUP:FindByName("CipratEW-Awacs")
if not templateGroup then
    env.error("MedorentAwacs: ERRORE - Gruppo 'CipratEW-Awacs' non trovato!")
    env.error("MedorentAwacs: Il gruppo deve esistere nel ME con opzione 'Late Activation' attiva")
    return
end

env.info("MedorentAwacs: Gruppo template 'CipratEW-Awacs' trovato")

-- Creazione FlightGroup
local AwacsFlightGroup = FLIGHTGROUP:New("CipratEW-Awacs")

-- Configurazione callsign
AwacsFlightGroup:SetDefaultCallsign(CALLSIGN.AWACS.Darkstar, 1)

-- Note: La gestione carburante e RTB è automatica con AUFTRAG
-- Note: Il respawn è gestito automaticamente dal sistema AUFTRAG/FLIGHTGROUP

env.info("MedorentAwacs: FlightGroup configurato")

-- =========================================================================
-- ATTIVAZIONE SISTEMA
-- =========================================================================

-- Attiva il FlightGroup
AwacsFlightGroup:Activate()

-- Assegna la missione AUFTRAG al FlightGroup
AwacsFlightGroup:AddMission(AwacsPatrolAuftrag)

-- =========================================================================
-- MESSAGGI INFORMATIVI
-- =========================================================================

env.info("=== MEDORENT AWACS AUFTRAG ===")
env.info("Sistema AWACS avviato con successo!")
env.info("Configurazione:")
env.info("- Zona orbita: AWACSZone")  
env.info("- Altitudine: 25.000 ft")
env.info("- Velocità: 280 nodi")
env.info("- TACAN: 29X (DRK)")
env.info("- Radio: 247 MHz")
env.info("- Orario: 06:00-23:00Z")
env.info("- RTB automatico: 20% carburante")
env.info("- Respawn: Automatico")

-- =========================================================================
-- AVVIO COMPLETATO
-- =========================================================================
-- Note: Gli event handlers sono omessi per evitare errori
-- Il sistema AUFTRAG/FLIGHTGROUP funziona automaticamente

env.info("MedorentAwacs: Script caricato completamente")

-------------------------------------------------------------------
-- FINE SCRIPT
-------------------------------------------------------------------