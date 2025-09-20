local airbossStennis=AIRBOSS:New("CarrierStennis", "CVN-74 John C.Stennis")
airbossStennis:Load("C:\\temp\\MedorentCache\\AIRBOSS\\")
airbossStennis:SetAutoSave("C:\\temp\\MedorentCache\\AIRBOSS\\")
airbossStennis:Save("C:\\temp\\MedorentCache\\AIRBOSS\\")
airbossStennis:SetTrapSheet("C:\\temp\\MedorentCache\\AIRBOSS\\")
airbossStennis:SetSoundfilesFolder("C:\\temp\\MedorentCache\\AIRBOSSSoundfiles\\")
airbossStennis:AddRecoveryWindow("7:30", "19:00", 1, 15, true, 20, false)
airbossStennis:AddRecoveryWindow("19:00", "7:30+1", 3, 15, true, 20, false)
airbossStennis:SetTACAN(74, "X")
airbossStennis:SetICLS(14)
airbossStennis:SetRadioRelayLSO("LSORelayStennis")
airbossStennis:SetLSORadio(274)
airbossStennis:SetRadioRelayMarshal("MarshallRelayStennis")
airbossStennis:SetMarshalRadio(275)

-- OTTIMIZZAZIONI PERFORMANCE AIRBOSS STENNIS
airbossStennis:SetQueueUpdateTime(45)     -- Default 30s → 45s (-33% carico CPU)
airbossStennis:SetStatusUpdateTime(1.0)   -- Default 0.5s → 1.0s (-50% carico CPU)
airbossStennis:SetBeaconRefresh(1800)     -- Default 1200s → 1800s (-33% carico CPU)

-- FIX PER EventData.IniUnit=nil nei CRASH events (AIRBOSS07335)
function airbossStennis:OnEventCrash(EventData)
  if EventData.IniUnit ~= nil then
    local unit = EventData.IniUnit
    local unitName = unit:GetName() or "Unknown"
    -- Log solo aerei BLU (coalition 2) - AIRBOSS gestisce solo unità alleate
    if unit:GetCoalition() == coalition.side.BLUE then
      env.info(string.format("AIRBOSS CarrierStennis: CRASH rilevato - Unit BLU: %s", unitName))
    end
  else
    env.info("AIRBOSS CarrierStennis: CRASH event ignorato - EventData.IniUnit=nil")
  end
end

airbossStennis:Start()

local airbossRoosevelt=AIRBOSS:New("CarrierRoosevelt", "CVN-71 Theodore Roosevelt")
airbossRoosevelt:Load("C:\\temp\\MedorentCache\\AIRBOSS\\")
airbossRoosevelt:SetAutoSave("C:\\temp\\MedorentCache\\AIRBOSS\\")
airbossRoosevelt:Save("C:\\temp\\MedorentCache\\AIRBOSS\\")
airbossRoosevelt:SetTrapSheet("C:\\temp\\MedorentCache\\AIRBOSS\\")
airbossRoosevelt:SetSoundfilesFolder("C:\\temp\\MedorentCache\\AIRBOSSSoundfiles\\")
airbossRoosevelt:AddRecoveryWindow("7:30", "19:00", 1, 15, true, 20, false)
airbossRoosevelt:AddRecoveryWindow("19:00", "7:30+1", 3, 15, true, 20, false)
airbossRoosevelt:SetTACAN(71, "X")
airbossRoosevelt:SetICLS(11)
airbossRoosevelt:SetRadioRelayLSO("LSORelayRoosevelt")
airbossRoosevelt:SetLSORadio(271)
airbossRoosevelt:SetRadioRelayMarshal("MarshallRelayRoosevelt")
airbossRoosevelt:SetMarshalRadio(272)

-- OTTIMIZZAZIONI PERFORMANCE AIRBOSS ROOSEVELT
airbossRoosevelt:SetQueueUpdateTime(45)     -- Default 30s → 45s (-33% carico CPU)
airbossRoosevelt:SetStatusUpdateTime(1.0)   -- Default 0.5s → 1.0s (-50% carico CPU)
airbossRoosevelt:SetBeaconRefresh(1800)     -- Default 1200s → 1800s (-33% carico CPU)

-- FIX PER EventData.IniUnit=nil nei CRASH events (AIRBOSS07353)
function airbossRoosevelt:OnEventCrash(EventData)
  if EventData.IniUnit ~= nil then
    local unit = EventData.IniUnit
    local unitName = unit:GetName() or "Unknown"
    -- Log solo aerei BLU (coalition 2) - AIRBOSS gestisce solo unità alleate
    if unit:GetCoalition() == coalition.side.BLUE then
      env.info(string.format("AIRBOSS CarrierRoosevelt: CRASH rilevato - Unit BLU: %s", unitName))
    end
  else
    env.info("AIRBOSS CarrierRoosevelt: CRASH event ignorato - EventData.IniUnit=nil")
  end
end

airbossRoosevelt:Start()