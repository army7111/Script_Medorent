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

airbossRoosevelt:Start()