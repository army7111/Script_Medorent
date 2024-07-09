-- Dichiarazione oggetti Target Range

local strafepit_gun={"StrafePit-1"}
local bombpit={"BombPit"}

-- Dichiarazione oggetto Range

Rayakrange=RANGE:New("RayakRange")

Rayakrange:AddStrafePit(strafepit_gun, nil, nil, nil, true, 5, nil)
Rayakrange:AddBombingTargets(bombpit, 10)
Rayakrange:TrackRocketsOFF()
Rayakrange:SetDefaultPlayerSmokeBomb(false)
Rayakrange:GetFoullineDistance("StrafePit-1", "Foulline-1")
Rayakrange:SetAutosaveOn()
Rayakrange:SetTargetSheet("C:\\temp\\MedorentCache\\RANGE\\","RayakRange")
--Rayakrange:SetFunkManOn()
-- Imposta cartella di salvataggio storico Range

-- Start Range
Rayakrange:Start()