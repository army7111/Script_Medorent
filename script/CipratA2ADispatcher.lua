local BlueCCCipratPosi = GROUP:FindByName("BLUECCCipratUNIT")
local BlueHQCipratt = COMMANDCENTER:New(BlueCCCipratPosi, "Cipro Attack Command Center", "Cipro Attack Command Center")
local CiprattMission = MISSION:New(BlueHQCipratt, "Cipro Attack Missions", "Primary", "Missioni A2A Cipro", coalition.side.BLUE)

-- -- Awacs --
-- AwacsPatrolAuftrag:SetTime("8:00", "20:00") -- l'orario di operazioni in Missione , l'awacs tornerà automaticamente alla base per refuel e ritornerà in volo
-- AwacsPatrolAuftrag:SetTACAN(29, "AWA") -- TACAN e codice morse 
-- AwacsPatrolAuftrag:SetRadio(247) -- Frequenza radio che utilizzerà l'awacs
-- AwacsPatrolAuftrag:SetImmortal(true) -- Impostato come immortale per evitare problemi

-- -- Ora verrà creato il FLIGHTGROUP , quindi verrà utilizzata una unità chiamata "RECON - E3" (nome del gruppo) messa nel ME con l'opzione "Late Activation" attivata.
-- local AwacsFlightGroup=FLIGHTGROUP:New("RECON - E3") -- dichiarazione variabile "AwacsFlightGroup" utilizzando la classe "FLIGHTGROUP"
-- AwacsFlightGroup:SetDefaultCallsign(CALLSIGN.AWACS.Darkstar, 1) -- impostazione del CALLSIGN che verrà utilizzato dall'Awacs 

-- AwacsFlightGroup:AddMission(AwacsPatrolAuftrag) -- Avvio script.

local AwacsTrigger = ZONE:New("AWACSZone")
local AwacsCipratt = AUFTRAG:NewAWACS(AwacsTrigger:GetCoordinate() , 25000, 300, 270, 30)
AwacsCipratt:SetTime("01:00", "23:00")
AwacsCipratt:SetTACAN(29, "AWA")
AwacsCipratt:SetRadio(247)
AwacsCipratt:SetImmortal(true)

local AwacsCiprattGroup = FLIGHTGROUP:New("CipratEW-Awacs")
AwacsCiprattGroup:SetDefaultCallsign(CALLSIGN.AWACS.Darkstar, 1)
AwacsCiprattGroup:AddMission(AwacsCipratt)

-- Fine Func Awacs --
local CiprattGroup = SET_GROUP:New()
CiprattGroup:FilterPrefixes("Ciprat")
CiprattGroup:FilterCoalitions("blue")
CiprattGroup:FilterStart()

local CiprattEWGroup = SET_GROUP:New()
CiprattEWGroup:FilterPrefixes("CipratEW")
CiprattEWGroup:FilterCoalitions("blue")
CiprattEWGroup:FilterStart()

local CiprattDetection = DETECTION_AREAS:New(CiprattEWGroup, 6000)
CiprattDetection:SetFriendliesRange(10000)
CiprattDetection:SetRefreshTimeInterval(30)

local CiprattA2ADispatcher = TASK_A2A_DISPATCHER:New(CiprattMission, CiprattGroup, CiprattDetection)
