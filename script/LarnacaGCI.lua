EwDetectionSetGroup = SET_GROUP:New()
EwDetectionSetGroup:FilterPrefixes( { "CiproEW" } )
EwDetectionSetGroup:FilterStart()
EwDetectionArea = DETECTION_AREAS:New( EwDetectionSetGroup, 100000 )

-- Controllo esistenza gruppo CiproBorder prima di creare ZONE_POLYGON
local ciproBorderGroup = GROUP:FindByName( "CiproBorder" )
if ciproBorderGroup and ciproBorderGroup:IsAlive() then
    CiproBorder = ZONE_POLYGON:New( "CiproBorder", ciproBorderGroup )
    env.info("LarnacaGCI: CiproBorder zone creata correttamente")
else
    env.warning("LarnacaGCI: ATTENZIONE - Gruppo 'CiproBorder' non trovato nel ME, verrà usata zone di default")
    -- Fallback: crea una zona circolare di default se il gruppo non esiste
    CiproBorder = ZONE:New( "DefaultBorderZone", COORDINATE:New(35.171667, 33.364722), 50000 ) -- Coordinate Cyprus area
end

LarnacaGCI = AI_A2A_DISPATCHER:New( EwDetectionArea )
-- Controllo sicurezza per SetBorderZone
if CiproBorder then
    LarnacaGCI:SetBorderZone( CiproBorder )
    env.info("LarnacaGCI: Border zone impostata correttamente")
else
    env.error("LarnacaGCI: ERRORE - Impossibile impostare border zone")
end
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