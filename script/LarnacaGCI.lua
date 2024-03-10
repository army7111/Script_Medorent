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
LarnacaGCI:SetSquadronCap( "CiproSU30Squadron", CiproBorder, 1000, 10000, 750, 900, 800, 1000 )
LarnacaGCI:SetSquadronCapInterval( "CiproSU30Squadron", 4, 180, 600, 1 )

----------- Set GCI -------------------------------------
LarnacaGCI:SetDefaultOverhead( 1.5 )