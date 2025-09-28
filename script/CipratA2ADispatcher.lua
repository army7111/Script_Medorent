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
