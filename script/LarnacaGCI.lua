EwDetectionSetGroup = SET_GROUP:New()
EwDetectionSetGroup:FilterPrefixes( { "CiproEW" } )
EwDetectionSetGroup:FilterStart()
EwDetectionArea = DETECTION_AREAS:New( EwDetectionSetGroup, 100000 )
CiproBorder = ZONE_POLYGON:New( "CiproBorder", GROUP:FindByName( "CiproBorder" ) )


LarnacaGCI = AI_A2A_DISPATCHER:New( EwDetectionArea )
LarnacaGCI:SetBorderZone( CiproBorder )
LarnacaGCI:SetSquadron( "CiproSU30Squadron", AIRBASE.Syria.Larnaca, {"RedCAPSu30"} )
LarnacaGCI:SetSquadron( "RedGCIMig29", AIRBASE.Syria.Gecitkale, {"RedGCIMig29"} )
--   LarnacaGCI:SetDefaultTakeoffInAir()
LarnacaGCI:SetDefaultTakeoff( LarnacaGCI.Takeoff.Air )
--   LarnacaGCI:SetDefaultTakeoff( LarnacaGCI.Takeoff.Runway )
--   LarnacaGCI:SetDefaultTakeoff( LarnacaGCI.Takeoff.Hot )
--   LarnacaGCI:SetDefaultTakeoff( LarnacaGCI.Takeoff.Cold )
LarnacaGCI:SetDefaultFuelThreshold( 0.20 )
LarnacaGCI:SetDefaultLandingAtRunway()
LarnacaGCI:SetDisengageRadius( 100000 )
-------- Esecuzione CAP --------------------------------
LarnacaGCI:SetSquadronCap( "CiproSU30Squadron", CiproBorder, 1000, 10000, 750, 900, 800, 1000 )
LarnacaGCI:SetSquadronCapInterval( "CiproSU30Squadron", 5, 600, 900, 1 )

----------- Set GCI -------------------------------------

LarnacaGCI:SetSquadronGci( "RedGCIMig29", 600, 1200 )
LarnacaGCI:SetGciRadius(120000)
LarnacaGCI:SetDefaultOverhead( 1 )