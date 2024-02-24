BLUEHQ = GROUP:FindByName( "BLUEHQ" ) -- NON deve essere uno statico!
REDHQ = GROUP:FindByName( "REDHQ" )


RED_CC = COMMANDCENTER:New( REDHQ, "REDHQ" )
BLUE_CC = COMMANDCENTER:New( BLUEHQ, "BLUEHQ" )

BLU_MissionsHQ = MISSION:New( BLUE_CC, "Missions Dispatch", "Primary", coalition.side.RED )

BLU_MissionsHQ:Start()


CZ_GAZIPASA = ZONE:New( "Gazipasa" )
CZCoalitionGazipasa = ZONE_CAPTURE_COALITION:New( CZ_GAZIPASA, coalition.side.RED )

CZ_INCIRLIK = ZONE:New( "Incirlik" )
CZCoalitionIncirlik = ZONE_CAPTURE_COALITION:New( CZ_INCIRLIK, coalition.side.RED )

CZ_BASSELALASSAD = ZONE:New( "BasselAlAssad" )
CZCoalitionBasselAlAssad = ZONE_CAPTURE_COALITION:New( CZ_BASSELALASSAD, coalition.side.BLUE )

CZ_PAPHOS = ZONE:New( "Paphos" )
CZCoalitionPaphos = ZONE_CAPTURE_COALITION:New( CZ_PAPHOS, coalition.side.RED )

CZ_AKROTIRI = ZONE:New( "Akrotiri" )
CZCoalitionAkrotiri = ZONE_CAPTURE_COALITION:New( CZ_AKROTIRI, coalition.side.RED )

CZ_PINARBASHI = ZONE:New( "Pinarbashi" )
CZCoalitionPinarbashi = ZONE_CAPTURE_COALITION:New( CZ_PINARBASHI, coalition.side.RED )

CZ_LAKATAMIA = ZONE:New( "Lakatamia" )
CZCoalitionLakatamia = ZONE_CAPTURE_COALITION:New( CZ_LAKATAMIA, coalition.side.RED )

CZ_ERCAN = ZONE:New( "Ercan" )
CZCoalitionErcan = ZONE_CAPTURE_COALITION:New( CZ_ERCAN, coalition.side.RED )

CZ_LARNACA = ZONE:New( "Larnaca" )
CZCoalitionLarnaca = ZONE_CAPTURE_COALITION:New( CZ_LARNACA, coalition.side.RED )

CZ_KINGSFIELD = ZONE:New( "Kingsfield" )
CZCoalitionKingsfield = ZONE_CAPTURE_COALITION:New( CZ_KINGSFIELD, coalition.side.RED )

CZ_GECITKALE = ZONE:New( "Gecitkale" )
CZCoalitionGecitkale = ZONE_CAPTURE_COALITION:New( CZ_GECITKALE, coalition.side.RED )

CZ_EASTCYPRO = ZONE:New( "East Cypro" )
CZCoalitionEastCypro = ZONE_CAPTURE_COALITION:New( CZ_EASTCYPRO, coalition.side.RED )



--------------------------- TEST ---------------------------

-- CaptureZone = ZONE:New( "Alpha" )
-- CaptureZoneCoalitionApha = ZONE_CAPTURE_COALITION:New( CaptureZone, coalition.side.RED )

-- Funzione per inizializzare una zona specifica
-- function InitializeSingleZone(zoneName)
--   local zone = ZONE_BASE:New(zoneName)
--   zone:SetColor({1, 0, 0}, 0.3) -- Imposta il colore a rosso, per esempio
--   zone:SetFillColor({1, 0, 0}, 0.15) -- Imposta il colore di riempimento a rosso
-- end

-- Nome della zona da testare
-- local testZoneName = "CZ_EASTCYPRO"

-- Chiamare la funzione con il nome della zona di test
-- InitializeSingleZone(testZoneName)




function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
    if From ~= To then
      local Coalition = self:GetCoalition()
      self:E( { Coalition = Coalition } )
      if Coalition == coalition.side.BLUE then
        ZoneCaptureCoalition:Smoke( SMOKECOLOR.Blue )
        BLUE_CC:MessageTypeToCoalition( string.format( "%s è sotto la protezione BLUE", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        RED_CC:MessageTypeToCoalition( string.format( "%s è sotto la protezione BLUE", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      else
        ZoneCaptureCoalition:Smoke( SMOKECOLOR.Red )
        RED_CC:MessageTypeToCoalition( string.format( "%s è sotto la protezione RED", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        BLUE_CC:MessageTypeToCoalition( string.format( "%s è sotto la protezione RED", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      end
    end
  end

function ZoneCaptureCoalition:OnEnterEmpty()
   self:Smoke( SMOKECOLOR.Green )
   BLUE_CC:MessageTypeToCoalition( string.format( "%s non è protetta, e può essere catturata!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
   RED_CC:MessageTypeToCoalition( string.format( "%s non è protetta, e può essere catturata!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
end

function ZoneCaptureCoalition:OnEnterAttacked()
    ZoneCaptureCoalition:Smoke( SMOKECOLOR.White )
    local Coalition = self:GetCoalition()
    self:E({Coalition = Coalition})
    if Coalition == coalition.side.BLUE then
      BLUE_CC:MessageTypeToCoalition( string.format( "%s è sotto attacco RED!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      RED_CC:MessageTypeToCoalition( string.format( "Stiamo attaccando %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    else
      RED_CC:MessageTypeToCoalition( string.format( "%s è sotto attacco BLUE!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      BLUE_CC:MessageTypeToCoalition( string.format( "Stiamo attaccando %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    end
end

function ZoneCaptureCoalition:OnEnterCaptured( From, Event, To )
  if From ~= To then
    local Coalition = self:GetCoalition()
    self:E( { Coalition = Coalition } )
    local zone = ZONE_BASE:New(self:GetZoneName())
    if Coalition == coalition.side.BLUE then
      --ZoneCaptureCoalition:Smoke( SMOKECOLOR.Blue )
      BLUE_CC:MessageTypeToCoalition( string.format( "%s è stata catturata da BLUE!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      RED_CC:MessageTypeToCoalition( string.format( "%s è stata catturata da BLUE!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      zone:SetColor({0, 0, 1}, 0.3) -- Imposta il colore della zona a blu
      zone:SetFillColor({0, 0, 1}, 0.15) -- Imposta il colore di riempimento della zona a blu
    else
      --ZoneCaptureCoalition:Smoke( SMOKECOLOR.Red )
      RED_CC:MessageTypeToCoalition( string.format( "%s è stata catturata da RED!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      BLUE_CC:MessageTypeToCoalition( string.format( "%s è stata catturata da RED!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      zone:SetColor({1, 0, 0}, 0.3) -- Imposta il colore della zona a rosso
      zone:SetFillColor({1, 0, 0}, 0.15) -- Imposta il colore di riempimento della zona a rosso
    end
  end
end

ZoneCaptureCoalition:Start( 5, 30 )