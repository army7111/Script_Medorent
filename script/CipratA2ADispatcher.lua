-- -- Awacs Example --
-- local AwacsPatrolZone = ZONE:New("AwacsPatrol")
-- local AwacsPatrolAuftrag = AUFTRAG:NewAWACS(AwacsPatrolZone:GetCoordinate(), 30000, 350, 232, 70)
-- AwacsPatrolAuftrag:SetTime("8:00", "20:00") -- l'orario di operazioni in Missione , l'awacs tornerà automaticamente alla base per refuel e ritornerà in volo
-- AwacsPatrolAuftrag:SetTACAN(29, "AWA") -- TACAN e codice morse 
-- AwacsPatrolAuftrag:SetRadio(247) -- Frequenza radio che utilizzerà l'awacs
-- AwacsPatrolAuftrag:SetImmortal(true) -- Impostato come immortale per evitare problemi

-- -- Ora verrà creato il FLIGHTGROUP , quindi verrà utilizzata una unità chiamata "RECON - E3" (nome del gruppo) messa nel ME con l'opzione "Late Activation" attivata.
-- local AwacsFlightGroup=FLIGHTGROUP:New("RECON - E3") -- dichiarazione variabile "AwacsFlightGroup" utilizzando la classe "FLIGHTGROUP"
-- AwacsFlightGroup:SetDefaultCallsign(CALLSIGN.AWACS.Darkstar, 1) -- impostazione del CALLSIGN che verrà utilizzato dall'Awacs 

-- AwacsFlightGroup:AddMission(AwacsPatrolAuftrag) -- Avvio script.
-- -- Fine Awacs Example --
-- Controllo sicurezza per Cipro Command Center
BlueCCCipratPosi = GROUP:FindByName("BLUECCCipratUNIT")
if BlueCCCipratPosi and BlueCCCipratPosi:IsAlive() then
    BlueHQCipratt = COMMANDCENTER:New(BlueCCCipratPosi, "Cipro Attack Command Center", "Cipro Attack Command Center")
    CiprattMission = MISSION:New(BlueHQCipratt, "Cipro Attack Missions", "Primary", "Missioni A2A Cipro", coalition.side.BLUE)
    env.info("CipratA2ADispatcher: Cipro Attack Command Center inizializzato correttamente")
else
    env.error("CipratA2ADispatcher: ERRORE CRITICO - Gruppo 'BLUECCCipratUNIT' non trovato nel ME")
    return -- Interrompi esecuzione script
end

-- AWACS gestito in MedorentAwacs.lua - rimosso da qui per evitare conflitti


CiprattGroup = SET_GROUP:New()
CiprattGroup:FilterPrefixes("Bassel Al-Assad_")
CiprattGroup:FilterCoalitions("blue")
CiprattGroup:FilterStart()

CiprattEWGroup = SET_GROUP:New()
CiprattEWGroup:FilterPrefixes("CipratEW")
CiprattEWGroup:FilterCoalitions("blue")
CiprattEWGroup:FilterStart()

CiprattDetection = DETECTION_AREAS:New(CiprattEWGroup, 6000)
-- OTTIMIZZAZIONI PERFORMANCE A2A DISPATCHER
CiprattDetection:SetFriendliesRange(8000)     -- 10000m → 8000m (meno calcoli)
CiprattDetection:SetRefreshTimeInterval(60)   -- 30s → 60s (-50% carico CPU)

CiprattA2ADispatcher = TASK_A2A_DISPATCHER:New(CiprattMission, CiprattGroup, CiprattDetection)
--CiprattA2ADispatcher:TraceOn()
CiprattA2ADispatcher:Start()
