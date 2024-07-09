RedSamNasiSpawn = SPAWN:New("REDSAM-Nasi")
RedSamPPNasi = SPAWN:New("REDSAM-PPNasi")
RedReinforcementNasi = SPAWN:New("REDNasiReinforce")
BlueNasiConv = SPAWN:New("BLUENAS-ConvoglioBLUE")
REDNasiZone3Guard = SPAWN:New("REDNasiZone3Guard")
REDNasiZone2Guard = SPAWN:New("REDNasiZone2Guard")
REDNasiZone1Guard = SPAWN:New("REDNasiZone1Guard")

CaptureZone1 = ZONE_CAPTURE_COALITION:New( ZONE:New("NasiZone1"), coalition.side.RED )
CaptureZone2 = ZONE_CAPTURE_COALITION:New( ZONE:New("NasiZone2"), coalition.side.RED )
CaptureZone3 = ZONE_CAPTURE_COALITION:New( ZONE:New("NasiZone3"), coalition.side.RED )

MenuMissioniNasi = MENU_COALITION:New(coalition.side.BLUE, "Missione An Nasiriyah", nil)

BlueNasiConvGROUP = nil

AttivaMissioneNasi = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Attiva Missione An Nasiriyah", MenuMissioniNasi, function()
    -- Registra gli eventi di cattura per ogni zona
    CaptureZone1:Start(30, 30) -- Controlla ogni 20 secondi
    CaptureZone2:Start(30, 30) -- Controlla ogni 30 secondi
    CaptureZone3:Start(30, 30) -- Controlla ogni 40 secondi
    BlueNasiConv:Spawn()
    BlueNasiConv:InitLimit(10, 10)
    BlueNasiConvUNIT = UNIT:FindByName("BLUENASConvoglioBLUECC")
    BlueNasiConvUNIT:HandleEvent( EVENTS.Dead )
    BlueNasiConvUNIT:HandleEvent( EVENTS.Hit )
    CaptureZone3:TraceOnOff(true)
    RedSamNasiSpawn:Spawn()
    RedSamNasiSpawn:InitLimit(3, 100)

    RedSamPPNasi:Spawn()
    RedSamPPNasi:InitLimit(4, 100)

    REDNasiZone1Guard:Spawn()
    REDNasiZone1Guard:InitLimit(4, 100)

    REDNasiZone2Guard:Spawn()
    REDNasiZone2Guard:InitLimit(4, 100)

    REDNasiZone3Guard:Spawn()
    REDNasiZone3Guard:InitLimit(4, 100)

    function BlueNasiConvUNIT:OnEventHit( EventData )
        BlueHQ:MessageToCoalition("Il C2 nel convoglio per An Nasiriyah è sotto attacco!", 30)
    end

    function BlueNasiConvUNIT:OnEventDead( EventData )
    BlueHQ:MessageToCoalition("Il C2 nel convoglio per An Nasiriyah è stato distrutto! Missione Fallita!", 30)
    local spawnedBlueNasiConv = BlueNasiConv:GetFirstAliveGroup()
    local spawnedRedSamNasi = RedSamNasiSpawn:GetFirstAliveGroup()
    local spawnedRedReinforcementNasi = RedReinforcementNasi:GetFirstAliveGroup()
    local spawnedRedSamPPNasi = RedSamPPNasi:GetFirstAliveGroup()
    local spawnedRedZone1Guard = REDNasiZone1Guard:GetFirstAliveGroup()
    local spawnedRedZone2Guard = REDNasiZone2Guard:GetFirstAliveGroup()
    local spawnedRedZone3Guard = REDNasiZone3Guard:GetFirstAliveGroup()

    if spawnedRedZone1Guard then
        spawnedRedZone1Guard:Destroy()      
    end
    if spawnedRedZone2Guard then
        spawnedRedZone2Guard:Destroy()        
    end
    if spawnedRedZone3Guard then
        spawnedRedZone3Guard:Destroy()
    end
    if spawnedBlueNasiConv then
        spawnedBlueNasiConv:Destroy()
    end
    if spawnedRedSamNasi then
        spawnedRedSamNasi:Destroy()
    end
    if spawnedRedReinforcementNasi then
        spawnedRedReinforcementNasi:Destroy()
    end
    if spawnedRedSamPPNasi then
        spawnedRedSamPPNasi:Destroy()
    end

end

    BlueHQ:MessageToCoalition("Convoglio Partito da Al-Dumayr diretto ad An Nasiriyah - ETA 1h9m - Difendetelo! ", 20, coalition.side.BLUE)
    BlueHQ:MessageToCoalition("Se il mezzo di Comando nel convoglio verrà distrutto, la missione sarà considerata FALLITA. ", 20, coalition.side.BLUE)
end)

DisattivaMissioneNasi = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Disattiva Missione An Nasiriyah", MenuMissioniNasi, function()
    local spawnedBlueNasiConv = BlueNasiConv:GetFirstAliveGroup()
    local spawnedRedSamNasi = RedSamNasiSpawn:GetFirstAliveGroup()
    local spawnedRedReinforcementNasi = RedReinforcementNasi:GetFirstAliveGroup()
    local spawnedRedSamPPNasi = RedSamPPNasi:GetFirstAliveGroup()
    local spawnedRedZone1Guard = REDNasiZone1Guard:GetFirstAliveGroup()
    local spawnedRedZone2Guard = REDNasiZone2Guard:GetFirstAliveGroup()
    local spawnedRedZone3Guard = REDNasiZone3Guard:GetFirstAliveGroup()

    if spawnedRedZone1Guard then
        spawnedRedZone1Guard:Destroy()
    end
    if spawnedRedZone2Guard then
        spawnedRedZone2Guard:Destroy()
    end
    if spawnedRedZone3Guard then
        spawnedRedZone3Guard:Destroy()
    end
    if spawnedBlueNasiConv then
        spawnedBlueNasiConv:Destroy()
    end
    if spawnedRedSamNasi then
        spawnedRedSamNasi:Destroy()
    end
    if spawnedRedReinforcementNasi then
        spawnedRedReinforcementNasi:Destroy()
    end
    if spawnedRedSamPPNasi then
        spawnedRedSamPPNasi:Destroy()
    end
    CaptureZone1:Stop()
    CaptureZone2:Stop()
    CaptureZone3:Stop()

    BlueHQ:MessageToCoalition("Missione An Nasiriyah disattivata", 20)
end)


--- Logica Eventi di cattura ---

-- Primo Checkpoint

function CaptureZone3:OnEnterAttacked(From, Event, To)
    --if From == coalition.side.BLUE then
        BlueHQ:MessageToCoalition("Il primo checkpoint è sotto attacco! ", 20)
        
        -- Inserire la logica Warehouse
    --end
end

function CaptureZone3:OnEnterCaptured(From, Event, To)
    --if From == coalition.side.BLUE then
        BlueHQ:MessageToCoalition("Il primo checkpoint è stato catturato! Procedete verso il secondo", 20)
        -- Inserire la logica Warehouse
    --end
end

-- Secondo Checkpoint

function CaptureZone2:OnEnterAttacked(From, Event, To)
    --if From == coalition.side.BLUE then
        BlueHQ:MessageToCoalition("Il secondo checkpoint è sotto attacco! ", 20)
        -- Inserire la logica Warehouse
    --end
end

function CaptureZone2:OnEnterCaptured(From, Event, To)
    --if From == coalition.side.BLUE then
        BlueHQ:MessageToCoalition("Il secondo checkpoint è stato catturato! Procedete verso il terzo", 20)
        -- Inserire la logica Warehouse
    --end
end
-- Terzo Checkpoint

function CaptureZone1:OnEnterAttacked(From, Event, To)
    --if From == coalition.side.BLUE then
        BlueHQ:MessageToCoalition("Il terzo checkpoint è sotto attacco! ", 20)
        -- Inserire la logica Warehouse
    --end
end

function CaptureZone1:OnEnterCaptured(From, Event, To)
    --if From == coalition.side.BLUE then
        BlueHQ:MessageToCoalition("Il terzo checkpoint è stato catturato! Ora Bisogna liberare l'aeroporto prima dell'arrivo del convoglio", 20)
        -- Inserire la logica Warehouse
    --end
end