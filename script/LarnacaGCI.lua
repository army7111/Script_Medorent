EwDetectionSetGroup = SET_GROUP:New()
EwDetectionSetGroup:FilterPrefixes( { "CiproEW" } )
EwDetectionSetGroup:FilterStart()
EwDetectionArea = DETECTION_AREAS:New( EwDetectionSetGroup, 10000 )
CiproBorder = ZONE_POLYGON:New( "CiproBorder", GROUP:FindByName( "CiproBorder" ) )


LarnacaGCI = AI_A2A_DISPATCHER:New( EwDetectionArea )
LarnacaGCI:SetBorderZone( CiproBorder )
LarnacaGCI:SetSquadron( "CiproSU30Squadron", AIRBASE.Syria.Larnaca, {"RedCAPSu30"} )
LarnacaGCI:SetDefaultTakeoffFromRunway()
LarnacaGCI:SetDefaultFuelThreshold( 0.30 )
LarnacaGCI:SetDefaultLandingAtRunway()
LarnacaGCI:SetDisengageRadius( 130000 )
-------- Esecuzione CAP --------------------------------
LarnacaGCI:SetSquadronCap( "CiproSU30Squadron", CiproBorder, 4000, 25000, 800, 1000, 800, 1000 )
LarnacaGCI:SetSquadronCapInterval( "CiproSU30Squadron", 2, 180, 900, 1 )

----------- Set GCI -------------------------------------
LarnacaGCI:SetDefaultOverhead( 2 )