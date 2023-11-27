BLUEHQ = GROUP:FindByName( "BLUEHQ" ) -- NON deve essere uno statico!
REDHQ = GROUP:FindByName( "REDHQ" )


RED_CC = COMMANDCENTER:New( REDHQ, "REDHQ" )
BLUE_CC = COMMANDCENTER:New( BLUEHQ, "BLUEHQ" )

BLU_MissionsHQ = MISSION:New( BLUE_CC, "Missions Dispatch", "Primary", coalition.side.RED )

BLU_MissionsHQ:Start()

CZEastCypro = ZONE:New( "CZ_EASTCYPRO" )
ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( CZEastCypro, coalition.side.RED )


--   "CZ_INCIRLIK"
--   "CZ_GAZIPASA"
--   "CZ_BASSELALASSAD"
--   "CZ_PAPHOS"
--   "CZ_AKROTIRI"
--   "CZ_PINARBASHI"
--   "CZ_LAKATAMIA"
--   "CZ_ERCAN"
--   "CZ_LARNACA"
--   "CZ_KINGSFIELD"
--   "CZ_GECITKALE"
--   "CZ_EASTCYPRO"


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
    if Coalition == coalition.side.BLUE then
      ZoneCaptureCoalition:Smoke( SMOKECOLOR.Blue )
      BLUE_CC:MessageTypeToCoalition( string.format( "%s è stata catturata da BLUE!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      RED_CC:MessageTypeToCoalition( string.format( "%s è stata catturata da BLUE!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    else
      ZoneCaptureCoalition:Smoke( SMOKECOLOR.Red )
      RED_CC:MessageTypeToCoalition( string.format( "%s è stata catturata da RED!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
      BLUE_CC:MessageTypeToCoalition( string.format( "%s è stata catturata da RED!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
    end
  end
end

ZoneCaptureCoalition:Start( 5, 30 )