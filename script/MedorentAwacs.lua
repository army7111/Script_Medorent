-------------------------------------------------------------------
-- Script per AWACS “ciclico”: decolla, fa orbit, at <20% fuel => RTB, despawn, respawn
-------------------------------------------------------------------

-- Definiamo uno SPAWN che parte dal gruppo “CipratEW-Awacs” (late activated)
local CipratAwacsSpawn = SPAWN:New("CipratEW-Awacs")
  :InitLimit(1, 99)  -- limite a 99 respawn
  :OnSpawnGroup(
    function( spawnedGroup ) 
      -- (Opzionale) Se vuoi impartire un'orbita sulla zona AWACSZone via script:
      local zona = ZONE:New("AWACSZone")
      if zona then
        -- Esempio di orbita a 25.000ft e 220 nodi
        local orbitTask = spawnedGroup:TaskOrbitCircleAtVec2(zona:GetVec2(), 7620, 280)
        spawnedGroup:SetTask(orbitTask, 1)
      end

      -- Creo uno scheduler che ogni 60 secondi controlla il fuel
      local checkFuel
      checkFuel = SCHEDULER:New(nil, 
        function()
          if spawnedGroup and spawnedGroup:IsAlive() then
            -- prendo la prima unità
            local unit = spawnedGroup:GetUnit(1)
            if unit then
              local fuel = unit:GetFuel()
              -- Se il fuel scende al di sotto del 20% => RTB e poi atterraggio
              if fuel <= 0.20 then
                env.info("AWACS: Carburante <20%, rientro alla base.")
                spawnedGroup:CommandRTB()

                -- Stoppo il check del carburante
                checkFuel:Stop()

                -- Pianifico un controllo tra un po’ (es. 2-3 minuti) per vedere se è atterrato
                SCHEDULER:New(nil, 
                  function()
                    -- Se è atterrato (oppure morto) => lo distruggo e respawno
                    if not spawnedGroup:IsAlive() or (not unit:InAir()) then
                      env.info("AWACS: Aereo a terra, lo despawno e genero nuovo AWACS.")
                      spawnedGroup:Destroy(false) 
                      CipratAwacsSpawn:Spawn()
                    end
                  end,
                {}, 120) -- controlla dopo 120s
              end
            end
          else
            -- Se per qualche motivo è morto, fermo lo scheduler
            checkFuel:Stop()
          end
        end,
      {}, 30, 300) 
      -- (partenza del check dopo 30s, e ripetizione ogni 300s)
    end
  )

-- Infine spawn iniziale (prima istanza).
CipratAwacsSpawn:Spawn()
