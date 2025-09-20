-- =========================================================================
-- MEDORENT AWACS AVANZATO - MOOSE Framework
-- Autore: GitHub Copilot Assistant
-- Data: Dicembre 2024
-- Versione: 1.0
-- =========================================================================
-- Questo script implementa un AWACS AI completo utilizzando la classe AWACS di MOOSE che:
-- 1. Decolla automaticamente dalla base
-- 2. Orbita in una zona prestabilita secondo parametri configurabili
-- 3. Torna alla base automaticamente quando il carburante è basso
-- 4. Fornisce controllo del traffico aereo completo con TTS
-- 5. Gestisce CAP (Combat Air Patrol) automatici
-- 6. Include comunicazioni radio realistiche
-- =========================================================================

-- =========================================================================
-- CONFIGURAZIONE PRINCIPALE
-- =========================================================================
local AWACS_AVANZATO = {
    -- Informazioni generali
    nome_istanza = "AWACS Overlord",
    coalizione = "blue", -- "blue", "red", o "neutral"
    
    -- Base operativa (deve esistere sulla mappa)
    airbase_casa = "Kutaisi", -- Cambia con il nome della tua base
    
    -- Zone richieste (DEVONO essere create nell'editor di missione)
    zona_orbita_awacs = "AWACS_Orbit_Zone",    -- Zona circolare dove orbita l'AWACS
    zona_fez = "Fighter_Zone",                 -- Fighter Engagement Zone (zona da difendere)
    zona_cap_station = "CAP_Station_Zone",     -- Zona dove stazionano i CAP
    
    -- Parametri di volo AWACS
    callsign_awacs = CALLSIGN.AWACS.Overlord,  -- Callsign AWACS
    numero_callsign = 1,                       -- Numero del callsign
    altitudine_awacs = 28,                     -- Altitudine in migliaia di piedi (28 = 28000 ft)
    velocita_awacs = 280,                      -- Velocità in nodi
    rotta_awacs = 360,                         -- Direzione orbita (gradi)
    lunghezza_tratta = 30,                     -- Lunghezza tratta orbita (miglia nautiche)
    
    -- Gestione carburante e tempi
    soglia_carburante_bassa = 0.25,            -- 25% carburante = RTB
    ore_servizio_awacs = 5,                    -- Ore di servizio prima del cambio turno
    ore_servizio_cap = 3,                      -- Ore di servizio CAP
    
    -- Configurazione radio
    frequenza_primaria = 255.0,                -- Frequenza principale MHz
    modulazione = radio.modulation.AM,         -- AM o FM
    
    -- Configurazione TTS/SRS
    srs_path = "C:\\Program Files\\DCS-SimpleRadio-Standalone\\ExternalAudio",
    srs_porta = 5002,
    srs_genere = "female",                     -- "male" o "female"
    srs_lingua = "en-GB",                      -- Lingua TTS
    
    -- Configurazione CAP automatici
    abilita_cap_ai = true,                     -- Abilita pattuglie CAP automatiche
    numero_cap_massimi = 4,                    -- Numero massimo di CAP AI attivi
    callsign_cap = CALLSIGN.Aircraft.Springfield, -- Callsign per i CAP
    velocita_cap = 350,                        -- Velocità CAP in nodi
    
    -- Template gruppi (DEVONO esistere nell'editor come Late Activated)
    template_awacs = "AWACS_Template",         -- Nome template AWACS
    template_cap = "CAP_Template",             -- Nome template CAP (opzionale)
    template_scorta = "Escort_Template",       -- Nome template scorta (opzionale)
    
    -- Configurazioni avanzate
    era_moderna = true,                        -- true = Era moderna (BVR, EPLRS), false = Guerra fredda
    scorta_awacs = false,                      -- Abilita scorta caccia per l'AWACS
    numero_scorte = 2,                         -- Numero aerei di scorta
    guida_giocatore = true,                    -- Fornisce guida aggiuntiva ai giocatori
    messaggi_schermo = true,                   -- Mostra messaggi a schermo
    debug_mode = false,                        -- Modalità debug per log dettagliati
}

-- =========================================================================
-- VARIABILI GLOBALI
-- =========================================================================
local MedorentAirWing = nil
local AwacsController = nil
local SquadronAwacs = nil
local SquadronCAP = nil
local SquadronEscort = nil
local ScriptAttivo = false

-- =========================================================================
-- FUNZIONI DI UTILITÀ
-- =========================================================================

-- Logging migliorato
local function LogInfo(messaggio)
    env.info("AWACS AVANZATO: " .. messaggio)
    if AWACS_AVANZATO.debug_mode then
        MESSAGE:New("DEBUG: " .. messaggio, 5):ToAll()
    end
end

-- Verifica esistenza zone
local function VerificaZone()
    local zona_orbita = ZONE:FindByName(AWACS_AVANZATO.zona_orbita_awacs)
    local zona_fez = ZONE:FindByName(AWACS_AVANZATO.zona_fez) 
    local zona_cap = ZONE:FindByName(AWACS_AVANZATO.zona_cap_station)
    
    if not zona_orbita then
        MESSAGE:New("ERRORE: Zona orbita AWACS '" .. AWACS_AVANZATO.zona_orbita_awacs .. "' non trovata!", 20):ToAll()
        return false
    end
    
    if not zona_fez then
        MESSAGE:New("ERRORE: Fighter Engagement Zone '" .. AWACS_AVANZATO.zona_fez .. "' non trovata!", 20):ToAll()
        return false
    end
    
    if not zona_cap then
        MESSAGE:New("ERRORE: Zona CAP '" .. AWACS_AVANZATO.zona_cap_station .. "' non trovata!", 20):ToAll()
        return false
    end
    
    LogInfo("Tutte le zone verificate con successo")
    return true
end

-- =========================================================================
-- SETUP AIRWING E SQUADRON
-- =========================================================================
local function SetupAirWing()
    LogInfo("Configurazione AirWing in corso...")
    
    -- Crea l'AirWing principale
    MedorentAirWing = AIRWING:New("Medorent AirWing", "Medorent Air Operations")
    MedorentAirWing:SetMarker(false)
    MedorentAirWing:SetAirbase(AIRBASE:FindByName(AWACS_AVANZATO.airbase_casa))
    MedorentAirWing:SetRespawnAfterDestroyed(1200) -- 20 minuti di respawn
    MedorentAirWing:SetTakeoffAir() -- Può decollare in aria se necessario
    
    -- 1. Squadron AWACS
    SquadronAwacs = SQUADRON:New(AWACS_AVANZATO.template_awacs, 1, "AWACS Squadron")
    SquadronAwacs:AddMissionCapability({AUFTRAG.Type.ORBIT}, 100)
    SquadronAwacs:SetFuelLowRefuel(true)
    SquadronAwacs:SetFuelLowThreshold(AWACS_AVANZATO.soglia_carburante_bassa)
    SquadronAwacs:SetTurnoverTime(15, 30)
    SquadronAwacs:SetRadio(AWACS_AVANZATO.frequenza_primaria, AWACS_AVANZATO.modulazione)
    MedorentAirWing:AddSquadron(SquadronAwacs)
    MedorentAirWing:NewPayload(AWACS_AVANZATO.template_awacs, -1, {AUFTRAG.Type.ORBIT}, 100)
    
    -- 2. Squadron CAP (se abilitato)
    if AWACS_AVANZATO.abilita_cap_ai and AWACS_AVANZATO.template_cap then
        SquadronCAP = SQUADRON:New(AWACS_AVANZATO.template_cap, 8, "AI CAP Squadron")
        SquadronCAP:AddMissionCapability({
            AUFTRAG.Type.ALERT5, 
            AUFTRAG.Type.CAP, 
            AUFTRAG.Type.GCICAP, 
            AUFTRAG.Type.INTERCEPT
        }, 85)
        SquadronCAP:SetFuelLowRefuel(true)
        SquadronCAP:SetFuelLowThreshold(0.3)
        SquadronCAP:SetTurnoverTime(10, 20)
        SquadronCAP:SetTakeoffAir()
        SquadronCAP:SetRadio(AWACS_AVANZATO.frequenza_primaria + 1, AWACS_AVANZATO.modulazione)
        MedorentAirWing:AddSquadron(SquadronCAP)
        MedorentAirWing:NewPayload(AWACS_AVANZATO.template_cap, -1, {
            AUFTRAG.Type.ALERT5,
            AUFTRAG.Type.CAP,
            AUFTRAG.Type.GCICAP,
            AUFTRAG.Type.INTERCEPT
        }, 85)
        LogInfo("Squadron CAP configurato")
    end
    
    -- 3. Squadron Scorta (se abilitato)
    if AWACS_AVANZATO.scorta_awacs and AWACS_AVANZATO.template_scorta then
        SquadronEscort = SQUADRON:New(AWACS_AVANZATO.template_scorta, AWACS_AVANZATO.numero_scorte, "Escort Squadron")
        SquadronEscort:AddMissionCapability({AUFTRAG.Type.ESCORT}, 100)
        SquadronEscort:SetFuelLowRefuel(true)
        SquadronEscort:SetFuelLowThreshold(0.35)
        SquadronEscort:SetTurnoverTime(10, 20)
        SquadronEscort:SetTakeoffAir()
        SquadronEscort:SetRadio(AWACS_AVANZATO.frequenza_primaria + 2, AWACS_AVANZATO.modulazione)
        MedorentAirWing:AddSquadron(SquadronEscort)
        MedorentAirWing:NewPayload(AWACS_AVANZATO.template_scorta, -1, {AUFTRAG.Type.ESCORT}, 100)
        LogInfo("Squadron Scorta configurato")
    end
    
    LogInfo("AirWing configurato con successo")
    return true
end

-- =========================================================================
-- SETUP AWACS CONTROLLER
-- =========================================================================
local function SetupAWACSController()
    LogInfo("Configurazione AWACS Controller...")
    
    -- Ottieni le zone
    local zona_fez = ZONE:FindByName(AWACS_AVANZATO.zona_fez)
    
    -- Crea l'istanza AWACS
    AwacsController = AWACS:New(
        AWACS_AVANZATO.nome_istanza,
        MedorentAirWing,
        AWACS_AVANZATO.coalizione,
        AWACS_AVANZATO.airbase_casa,
        AWACS_AVANZATO.zona_orbita_awacs,
        zona_fez,
        AWACS_AVANZATO.zona_cap_station,
        AWACS_AVANZATO.frequenza_primaria,
        AWACS_AVANZATO.modulazione
    )
    
    -- Configurazione dettagli AWACS
    AwacsController:SetAwacsDetails(
        AWACS_AVANZATO.callsign_awacs,
        AWACS_AVANZATO.numero_callsign,
        AWACS_AVANZATO.altitudine_awacs,
        AWACS_AVANZATO.velocita_awacs,
        AWACS_AVANZATO.rotta_awacs,
        AWACS_AVANZATO.lunghezza_tratta
    )
    
    -- Configurazione TTS/SRS
    AwacsController:SetSRS(
        AWACS_AVANZATO.srs_path,
        AWACS_AVANZATO.srs_genere,
        AWACS_AVANZATO.srs_lingua,
        AWACS_AVANZATO.srs_porta
    )
    
    -- Configurazione tempi di servizio
    AwacsController:SetTOS(AWACS_AVANZATO.ore_servizio_awacs, AWACS_AVANZATO.ore_servizio_cap)
    
    -- Configurazione era (moderna o guerra fredda)
    if AWACS_AVANZATO.era_moderna then
        AwacsController:SetModernEra()
        LogInfo("Configurato per era moderna (BVR, EPLRS)")
    else
        AwacsController:SetColdWar()
        LogInfo("Configurato per guerra fredda (VID only)")
    end
    
    -- Configurazioni CAP AI
    if AWACS_AVANZATO.abilita_cap_ai then
        AwacsController:SetAICAPDetails(
            AWACS_AVANZATO.callsign_cap,
            AWACS_AVANZATO.numero_cap_massimi,
            AWACS_AVANZATO.ore_servizio_cap,
            AWACS_AVANZATO.velocita_cap
        )
        LogInfo("CAP AI configurati: " .. AWACS_AVANZATO.numero_cap_massimi .. " unità massime")
    end
    
    -- Configurazione scorta
    if AWACS_AVANZATO.scorta_awacs then
        AwacsController:SetEscort(
            AWACS_AVANZATO.numero_scorte,
            ENUMS.Formation.FixedWing.LineAbreast.Group,
            {x=-1000, y=100, z=500}, -- Offset formazione
            50 -- Distanza massima ingaggio
        )
        LogInfo("Scorta AWACS configurata: " .. AWACS_AVANZATO.numero_scorte .. " caccia")
    end
    
    -- Altre configurazioni
    AwacsController:SetPlayerGuidance(AWACS_AVANZATO.guida_giocatore)
    AwacsController:SuppressScreenMessages(not AWACS_AVANZATO.messaggi_schermo)
    AwacsController:SetRadarBlur(15) -- 15% blur radar
    AwacsController:SetReassignmentPause(180) -- 3 minuti pausa riassegnamento
    
    -- Configurazioni debug
    if AWACS_AVANZATO.debug_mode then
        AwacsController.debug = true
        AwacsController.verbose = 2
    end
    
    LogInfo("AWACS Controller configurato completamente")
    return true
end

-- =========================================================================
-- EVENT HANDLERS
-- =========================================================================
local function SetupEventHandlers()
    LogInfo("Configurazione Event Handlers...")
    
    -- Event handler per cambio turno AWACS
    function AwacsController:OnAfterAwacsShiftChange(From, Event, To)
        MESSAGE:New("AWACS: Cambio turno - nuovo AWACS operativo", 10):ToAll()
        LogInfo("Cambio turno AWACS completato")
    end
    
    -- Event handler per assegnazione CAP
    function AwacsController:OnAfterAssignedAnchor(From, Event, To)
        LogInfo("CAP assegnato a posizione anchor")
    end
    
    -- Event handler per nuovi contatti
    function AwacsController:OnAfterNewContact(From, Event, To)
        if AWACS_AVANZATO.debug_mode then
            LogInfo("Nuovo contatto rilevato dall'AWACS")
        end
    end
    
    -- Event handler per intercetti
    function AwacsController:OnAfterIntercept(From, Event, To)
        LogInfo("Intercetto assegnato dal controllo AWACS")
    end
    
    LogInfo("Event Handlers configurati")
end

-- =========================================================================
-- FUNZIONE PRINCIPALE DI AVVIO
-- =========================================================================
function AvviaMedorentAwacsAvanzato()
    
    if ScriptAttivo then
        MESSAGE:New("AWACS Avanzato già attivo!", 8):ToAll()
        return
    end
    
    MESSAGE:New("=== AVVIO AWACS MEDORENT AVANZATO ===", 12):ToAll()
    LogInfo("Inizializzazione script AWACS avanzato...")
    
    -- 1. Verifica zone
    if not VerificaZone() then
        MESSAGE:New("ERRORE: Verifica zone fallita. Script terminato.", 15):ToAll()
        return
    end
    
    -- 2. Setup AirWing
    if not SetupAirWing() then
        MESSAGE:New("ERRORE: Setup AirWing fallito.", 15):ToAll()
        return
    end
    
    -- 3. Avvia AirWing e aspetta che sia pronto
    MedorentAirWing:__Start(3)
    
    -- 4. Aspetta che l'AirWing sia avviato, poi configura l'AWACS
    local schedulerSetup = SCHEDULER:New(nil, function()
        if MedorentAirWing:IsStarted() then
            
            -- Setup AWACS Controller
            if not SetupAWACSController() then
                MESSAGE:New("ERRORE: Setup AWACS Controller fallito.", 15):ToAll()
                return
            end
            
            -- Setup Event Handlers
            SetupEventHandlers()
            
            -- Avvia l'AWACS
            AwacsController:__Start(5)
            
            -- Conferma avvio
            ScriptAttivo = true
            MESSAGE:New("AWACS AVANZATO OPERATIVO!", 15):ToAll()
            MESSAGE:New("Frequenza: " .. AWACS_AVANZATO.frequenza_primaria .. " MHz", 8):ToAll()
            MESSAGE:New("Callsign: " .. "Overlord " .. AWACS_AVANZATO.numero_callsign, 8):ToAll()
            MESSAGE:New("Altitudine: " .. AWACS_AVANZATO.altitudine_awacs .. ".000 ft", 8):ToAll()
            MESSAGE:New("Zona orbita: " .. AWACS_AVANZATO.zona_orbita_awacs, 8):ToAll()
            
            LogInfo("AWACS Avanzato completamente operativo")
            return nil -- Ferma lo scheduler
            
        end
    end, {}, 2, 10) -- Controlla ogni 2 secondi per 10 volte massimo
    
end

-- =========================================================================
-- FUNZIONI DI CONTROLLO
-- =========================================================================

-- Ottieni status dettagliato
function GetAwacsStatusAvanzato()
    if not AwacsController then
        MESSAGE:New("AWACS non inizializzato", 5):ToAll()
        return
    end
    
    local status = AwacsController:GetState() or "Sconosciuto"
    local nome = AwacsController:GetName() or "N/A"
    
    MESSAGE:New("=== STATUS AWACS AVANZATO ===", 10):ToAll()
    MESSAGE:New("Nome: " .. nome, 6):ToAll()
    MESSAGE:New("Stato: " .. status, 6):ToAll()
    MESSAGE:New("Script Attivo: " .. (ScriptAttivo and "SÌ" or "NO"), 6):ToAll()
    
    LogInfo("Status AWACS richiesto - Stato: " .. status)
end

-- Ferma il sistema AWACS
function FermaAwacsAvanzato()
    MESSAGE:New("Arresto AWACS Avanzato...", 8):ToAll()
    
    if AwacsController then
        AwacsController:__Stop(2)
        AwacsController = nil
    end
    
    if MedorentAirWing then
        MedorentAirWing:__Stop(2)
        MedorentAirWing = nil
    end
    
    ScriptAttivo = false
    LogInfo("AWACS Avanzato fermato")
    MESSAGE:New("AWACS Avanzato fermato", 8):ToAll()
end

-- Riavvia il sistema
function RiavviaAwacsAvanzato()
    MESSAGE:New("Riavvio AWACS Avanzato...", 8):ToAll()
    
    FermaAwacsAvanzato()
    
    SCHEDULER:New(nil, function()
        AvviaMedorentAwacsAvanzato()
    end, {}, 8)
end

-- =========================================================================
-- AVVIO AUTOMATICO
-- =========================================================================

-- Messaggio di caricamento
MESSAGE:New("=== AWACS MEDORENT AVANZATO ===", 15):ToAll()
MESSAGE:New("Script caricato. Sistema MOOSE AWACS completo.", 12):ToAll()
MESSAGE:New("", 8):ToAll()
MESSAGE:New("REQUISITI ZONE (devono esistere nell'editor):", 10):ToAll()
MESSAGE:New("• " .. AWACS_AVANZATO.zona_orbita_awacs .. " - Zona orbita AWACS", 6):ToAll()
MESSAGE:New("• " .. AWACS_AVANZATO.zona_fez .. " - Fighter Engagement Zone", 6):ToAll()
MESSAGE:New("• " .. AWACS_AVANZATO.zona_cap_station .. " - CAP Station", 6):ToAll()
MESSAGE:New("", 6):ToAll()
MESSAGE:New("REQUISITI TEMPLATE (Late Activated):", 8):ToAll()
MESSAGE:New("• " .. AWACS_AVANZATO.template_awacs .. " - Template AWACS", 6):ToAll()
if AWACS_AVANZATO.abilita_cap_ai then
    MESSAGE:New("• " .. AWACS_AVANZATO.template_cap .. " - Template CAP", 6):ToAll()
end
if AWACS_AVANZATO.scorta_awacs then
    MESSAGE:New("• " .. AWACS_AVANZATO.template_scorta .. " - Template Scorta", 6):ToAll()
end
MESSAGE:New("", 6):ToAll()
MESSAGE:New("Avvio automatico in 15 secondi...", 8):ToAll()

-- Avvio automatico dopo 15 secondi
SCHEDULER:New(nil, AvviaMedorentAwacsAvanzato, {}, 15)

-- =========================================================================
-- COMANDI CONSOLE DEBUG
-- =========================================================================
-- Utilizzabili tramite F10 -> Other -> Debug Console:
--
-- dostring("AvviaMedorentAwacsAvanzato()")  -- Avvia il sistema
-- dostring("GetAwacsStatusAvanzato()")      -- Mostra status
-- dostring("FermaAwacsAvanzato()")          -- Ferma il sistema  
-- dostring("RiavviaAwacsAvanzato()")        -- Riavvia il sistema
--
-- Per debug:
-- dostring("AWACS_AVANZATO.debug_mode = true") -- Abilita debug
-- dostring("AWACS_AVANZATO.debug_mode = false") -- Disabilita debug
-- =========================================================================

LogInfo("Script AWACS Avanzato caricato completamente")

-- Fine script