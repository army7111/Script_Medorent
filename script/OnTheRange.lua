-- Dichiarazione oggetti Target Range

local strafepit_gun={"StrafePit-1"}
local bombpit={"BombPit"}

-- Dichiarazione oggetto Range

Rayakrange=RANGE:New("RayakRange")

Rayakrange:AddStrafePit(strafepit_gun, nil, nil, nil, true, 5, nil)
Rayakrange:AddBombingTargets(bombpit, 10)
Rayakrange:TrackRocketsOFF()
Rayakrange:SetDefaultPlayerSmokeBomb(false)
-- FIX: Controllo esistenza oggetti prima di chiamare GetFoullineDistance
-- Gli oggetti "StrafePit-1" e "Foulline-1" devono esistere nel Mission Editor
-- Se non esistono, il range funzionerà comunque senza questa funzione
local strafePitObj = StaticObject.getByName("StrafePit-1")
local foullineObj = StaticObject.getByName("Foulline-1")
if strafePitObj and foullineObj then
    Rayakrange:GetFoullineDistance("StrafePit-1", "Foulline-1")
    env.info("RayakRange: Foulline distance configurata correttamente")
else
    env.info("RayakRange: ATTENZIONE - Oggetti Foulline-1 o StrafePit-1 mancanti nel ME")
end
Rayakrange:SetAutosaveOn()
Rayakrange:SetTargetSheet("C:\\temp\\MedorentCache\\RANGE\\","RayakRange")
-- Rayakrange:SetFunkManOn()  -- DISATTIVATO: Causa errori con desanitize disabilitato
-- Imposta cartella di salvataggio storico Range

-- Start Range
Rayakrange:Start()