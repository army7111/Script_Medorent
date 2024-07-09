local ZoneTankerArco=ZONE:New("ZoneArco")
local ZoneTankerShell=ZONE:New("ZoneShell")
local ZoneTankerTexaco=ZONE:New("ZoneTexaco")


-- Dichiarazione AUFTRAG
local TankerAuftragArco=AUFTRAG:NewTANKER(ZoneTankerArco:GetCoordinate(), 23000, 310, 44, 50, 0) -- Coordinate , Altitudine, Velocità, Heading, Lunghezza Leg Racetrack, Tipologia Boom=0 Basket=1
TankerAuftragArco:SetTime("5:00", "20:00")
TankerAuftragArco:SetTACAN(12, "ARC")
TankerAuftragArco:SetRadio(262)
TankerAuftragArco:SetImmortal(true)

local TankerAuftragShell=AUFTRAG:NewTANKER(ZoneTankerShell:GetCoordinate(), 12000, 230, 44, 50, 0)
TankerAuftragShell:SetTime("5:00", "20:00")
TankerAuftragShell:SetTACAN(11, "SHE")
TankerAuftragShell:SetRadio(261)
TankerAuftragShell:SetImmortal(true)

local TankerAuftragTexaco=AUFTRAG:NewTANKER(ZoneTankerTexaco:GetCoordinate(), 25000, 310, 44, 50, 1)
TankerAuftragTexaco:SetTime("5:00", "20:00")
TankerAuftragTexaco:SetTACAN(13, "TXC")
TankerAuftragTexaco:SetRadio(263)
TankerAuftragTexaco:SetImmortal(true)

-- Creazione FlightGroup
local TankerAuftragArcoGroup=FLIGHTGROUP:New("TankerArco")
TankerAuftragArcoGroup:SetDefaultCallsign(CALLSIGN.Tanker.Arco, 1)
TankerAuftragArcoGroup:Activate()

local TankerAuftragShellGroup=FLIGHTGROUP:New("TankerShell")
TankerAuftragShellGroup:SetDefaultCallsign(CALLSIGN.Tanker.Shell, 1)
TankerAuftragShellGroup:Activate()

local TankerAuftragTexacoGroup=FLIGHTGROUP:New("TankerTexaco")
TankerAuftragTexacoGroup:SetDefaultCallsign(CALLSIGN.Tanker.Texaco, 1)
TankerAuftragTexacoGroup:Activate()

-- Assegna Missioni ai piloti
TankerAuftragArcoGroup:AddMission(TankerAuftragArco)
TankerAuftragShellGroup:AddMission(TankerAuftragShell)
TankerAuftragTexacoGroup:AddMission(TankerAuftragTexaco)

-- Menu per lista INFO (Tacan e Frequenze)

MenuTanker=MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Tanker Info", nil , function ()
    BlueHQ:MessageToCoalition("Tanker Shell: Tacan 11X, Frequenza 261", 20, coalition.side.BLUE, "Tanker")
    BlueHQ:MessageToCoalition("Tanker Arco: Tacan 12X, Frequenza 262", 20, coalition.side.BLUE, "Tanker")
    BlueHQ:MessageToCoalition("Tanker Texaco: Tacan 13X, Frequenza 263", 20, coalition.side.BLUE, "Tanker")
end )
