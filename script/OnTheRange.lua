-- Dichiarazione oggetti Target Range

local strafepit_gun={"StrafePit-1"}
local bombpit={"BombPit"}

-- Dichiarazione oggetto Range

Rayakrange=RANGE:New("RayakRange")
Rayakrange:AddStrafePit(strafepit_gun, nil, nil, nil, true, 5, nil)
Rayakrange:AddBombingTargets(bombpit, 10)
Rayakrange:SetDefaultPlayerSmokeBomb(false)
Rayakrange:GetFoullineDistance("StrafePit-1", "Foulline-1")
Rayakrange:SetAutoSaveOn(true)
Rayakrange:SetTargetSheet("C:\\temp\\MedorentCache","RayakRange")
-- Imposta cartella di salvataggio storico Range

Rayakrange:SetSaveFolder("C:\\temp\\MedorentCache")

-- Start Range
Rayakrange:Start()