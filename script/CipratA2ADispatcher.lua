-- COMMANDCENTER/MISSION/TASK_A2A_DISPATCHER rimossi da MOOSE develop
-- Detection EW attiva, task assignment automatico non disponibile
env.warning("CipratA2ADispatcher: COMMANDCENTER/TASK_A2A_DISPATCHER non in MOOSE develop - solo detection EW attiva")

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

-- TASK_A2A_DISPATCHER non disponibile in MOOSE develop
env.warning("CipratA2ADispatcher: Task dispatcher non avviato")
