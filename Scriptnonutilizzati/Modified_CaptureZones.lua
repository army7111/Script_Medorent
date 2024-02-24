
-- Function to update the color of a zone on the F10 map
function updateZoneColorOnMap(zone, uniqueID, color)
    local points = {}
    for _, point in ipairs(zone:GetZoneBorder()) do
        table.insert(points, point:GetVec2())
    end
    trigger.action.markupToAll(7, -1, uniqueID, points, color, {1, 0, 0, 0.1}, 3)
end
BLUEHQ = GROUP:FindByName( "BLUEHQ" ) -- NON deve essere uno statico!
REDHQ = GROUP:FindByName( "REDHQ" )


RED_CC = COMMANDCENTER:New( REDHQ, "REDHQ" )
BLUE_CC = COMMANDCENTER:New( BLUEHQ, "BLUEHQ" )

BLU_MissionsHQ = MISSION:New( BLUE_CC, "Missions Dispatch", "Primary", coalition.side.RED )

BLU_MissionsHQ:Start()


CZ_GAZIPASA = ZONE:New( "Gazipasa" )
CZCoalitionGazipasa = ZONE_CAPTURE_COALITION:New( CZ_GAZIPASA, coalition.side.RED )

-- OnCapture event handler for CZCoalitionGazipasa
function CZCoalitionGazipasa:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1000, newColor)
end

CZ_INCIRLIK = ZONE:New( "Incirlik" )
CZCoalitionIncirlik = ZONE_CAPTURE_COALITION:New( CZ_INCIRLIK, coalition.side.RED )

-- OnCapture event handler for CZCoalitionIncirlik
function CZCoalitionIncirlik:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1001, newColor)
end

CZ_BASSELALASSAD = ZONE:New( "BasselAlAssad" )
CZCoalitionBasselAlAssad = ZONE_CAPTURE_COALITION:New( CZ_BASSELALASSAD, coalition.side.BLUE )

-- OnCapture event handler for CZCoalitionBasselAlAssad
function CZCoalitionBasselAlAssad:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1002, newColor)
end

CZ_PAPHOS = ZONE:New( "Paphos" )
CZCoalitionPaphos = ZONE_CAPTURE_COALITION:New( CZ_PAPHOS, coalition.side.RED )

-- OnCapture event handler for CZCoalitionPaphos
function CZCoalitionPaphos:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1003, newColor)
end

CZ_AKROTIRI = ZONE:New( "Akrotiri" )
CZCoalitionAkrotiri = ZONE_CAPTURE_COALITION:New( CZ_AKROTIRI, coalition.side.RED )

-- OnCapture event handler for CZCoalitionAkrotiri
function CZCoalitionAkrotiri:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1004, newColor)
end

CZ_PINARBASHI = ZONE:New( "Pinarbashi" )
CZCoalitionPinarbashi = ZONE_CAPTURE_COALITION:New( CZ_PINARBASHI, coalition.side.RED )

-- OnCapture event handler for CZCoalitionPinarbashi
function CZCoalitionPinarbashi:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1005, newColor)
end

CZ_LAKATAMIA = ZONE:New( "Lakatamia" )
CZCoalitionLakatamia = ZONE_CAPTURE_COALITION:New( CZ_LAKATAMIA, coalition.side.RED )

-- OnCapture event handler for CZCoalitionLakatamia
function CZCoalitionLakatamia:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1006, newColor)
end

CZ_ERCAN = ZONE:New( "Ercan" )
CZCoalitionErcan = ZONE_CAPTURE_COALITION:New( CZ_ERCAN, coalition.side.RED )

-- OnCapture event handler for CZCoalitionErcan
function CZCoalitionErcan:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1007, newColor)
end

CZ_LARNACA = ZONE:New( "Larnaca" )
CZCoalitionLarnaca = ZONE_CAPTURE_COALITION:New( CZ_LARNACA, coalition.side.RED )

-- OnCapture event handler for CZCoalitionLarnaca
function CZCoalitionLarnaca:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1008, newColor)
end

CZ_KINGSFIELD = ZONE:New( "Kingsfield" )
CZCoalitionKingsfield = ZONE_CAPTURE_COALITION:New( CZ_KINGSFIELD, coalition.side.RED )

-- OnCapture event handler for CZCoalitionKingsfield
function CZCoalitionKingsfield:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1009, newColor)
end

CZ_GECITKALE = ZONE:New( "Gecitkale" )
CZCoalitionGecitkale = ZONE_CAPTURE_COALITION:New( CZ_GECITKALE, coalition.side.RED )

-- OnCapture event handler for CZCoalitionGecitkale
function CZCoalitionGecitkale:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1010, newColor)
end

CZ_EASTCYPRO = ZONE:New( "East Cypro" )
CZCoalitionEastCypro = ZONE_CAPTURE_COALITION:New( CZ_EASTCYPRO, coalition.side.RED )

-- OnCapture event handler for CZCoalitionEastCypro
function CZCoalitionEastCypro:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1011, newColor)
end



--------------------------- TEST ---------------------------

-- CaptureZone = ZONE:New( "Alpha" )
-- CaptureZoneCoalitionApha = ZONE_CAPTURE_COALITION:New( CaptureZone, coalition.side.RED )

-- OnCapture event handler for --
function --:OnCapture(From, Event, To)
    local newColor = self:GetCoalition() == coalition.side.BLUE and {0, 0, 1, 0.5} or {1, 0, 0, 0.5}
    updateZoneColorOnMap(self, 1012, newColor)
end

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