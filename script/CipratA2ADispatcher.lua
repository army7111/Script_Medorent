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
BlueCCCipratPosi = GROUP:FindByName("BLUECCCipratUNIT")
BlueHQCipratt = COMMANDCENTER:New(BlueCCCipratPosi, "Cipro Attack Command Center", "Cipro Attack Command Center")
CiprattMission = MISSION:New(BlueHQCipratt, "Cipro Attack Missions", "Primary", "Missioni A2A Cipro", coalition.side.BLUE)

AwacsTrigger = ZONE:New("AWACSZone")
AwacsCipratt = AUFTRAG:NewAWACS(AwacsTrigger:GetCoordinate(), 30000, 400, 359, 30)

AwacsCipratt:SetTime("07:00", "20:00")
-- AwacsCipratt:SetTACAN(29, "AWA")
AwacsCipratt:SetRadio(247)
AwacsCipratt:SetImmortal(true)

AwacsCiprattGroup = FLIGHTGROUP:New("CipratEW-Awacs")
AwacsCiprattGroup:SetDefaultCallsign(CALLSIGN.AWACS.Darkstar, 1)
AwacsCiprattGroup:AddMission(AwacsCipratt)


CiprattGroup = SET_GROUP:New()
CiprattGroup:FilterPrefixes("CiprAt")
CiprattGroup:FilterCoalitions("blue")
CiprattGroup:FilterStart()

CiprattEWGroup = SET_GROUP:New()
CiprattEWGroup:FilterPrefixes("CipratEW")
CiprattEWGroup:FilterCoalitions("blue")
CiprattEWGroup:FilterStart()

CiprattDetection = DETECTION_AREAS:New(CiprattEWGroup, 6000)
CiprattDetection:SetFriendliesRange(10000)
CiprattDetection:SetRefreshTimeInterval(30)

CiprattA2ADispatcher = TASK_A2A_DISPATCHER:New(CiprattMission, CiprattGroup, CiprattDetection)
--CiprattA2ADispatcher:TraceOn()
CiprattA2ADispatcher:Start()
