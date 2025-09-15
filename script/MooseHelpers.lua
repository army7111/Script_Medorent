-------------------------------------------------------------------
-- MOOSE Helper Functions - Nil-Safe Operations
-- Aggiunte per prevenire errori "attempt to index nil value"
-------------------------------------------------------------------

-- Namespace per helper functions
MooseHelpers = {}

-- Nil-safe group operations
function MooseHelpers.SafeGroupDestroy(group, groupName)
    if group and type(group) == "table" and group.IsAlive then
        if group:IsAlive() then
            group:Destroy()
            env.info(string.format("SafeGroupDestroy: %s distrutto con successo", groupName or "Unknown Group"))
            return true
        else
            env.info(string.format("SafeGroupDestroy: %s già morto", groupName or "Unknown Group"))
            return false
        end
    else
        env.info(string.format("SafeGroupDestroy: %s è nil o non valido", groupName or "Unknown Group"))
        return false
    end
end

-- Nil-safe unit operations
function MooseHelpers.SafeGetUnit(group, unitIndex, groupName)
    if not group or not group.GetUnit then
        env.info(string.format("SafeGetUnit: Group %s è nil o non ha GetUnit method", groupName or "Unknown"))
        return nil
    end
    
    if not group:IsAlive() then
        env.info(string.format("SafeGetUnit: Group %s non è alive", groupName or "Unknown"))
        return nil
    end
    
    local unit = group:GetUnit(unitIndex or 1)
    if not unit then
        env.info(string.format("SafeGetUnit: Unit %d nel group %s è nil", unitIndex or 1, groupName or "Unknown"))
        return nil
    end
    
    if not unit:IsAlive() then
        env.info(string.format("SafeGetUnit: Unit %d nel group %s non è alive", unitIndex or 1, groupName or "Unknown"))
        return nil
    end
    
    return unit
end

-- Nil-safe fuel check
function MooseHelpers.SafeGetFuel(unit, unitName)
    if not unit or not unit.GetFuel then
        env.info(string.format("SafeGetFuel: Unit %s è nil o non ha GetFuel method", unitName or "Unknown"))
        return nil
    end
    
    if not unit:IsAlive() then
        env.info(string.format("SafeGetFuel: Unit %s non è alive", unitName or "Unknown"))
        return nil
    end
    
    local fuel = unit:GetFuel()
    if not fuel or type(fuel) ~= "number" then
        env.info(string.format("SafeGetFuel: Fuel per unit %s è nil o non numerico: %s", unitName or "Unknown", tostring(fuel)))
        return nil
    end
    
    return fuel
end

-- Nil-safe spawn operations
function MooseHelpers.SafeSpawnInZone(spawnObject, zone, spawnName)
    if not spawnObject or not spawnObject.SpawnInZone then
        env.error(string.format("SafeSpawnInZone: Spawn object %s è nil o non valido", spawnName or "Unknown"))
        return nil
    end
    
    if not zone then
        env.error(string.format("SafeSpawnInZone: Zone per %s è nil", spawnName or "Unknown"))
        return nil
    end
    
    local spawnedGroup = spawnObject:SpawnInZone(zone)
    if not spawnedGroup then
        env.error(string.format("SafeSpawnInZone: Fallimento spawn di %s", spawnName or "Unknown"))
        return nil
    end
    
    env.info(string.format("SafeSpawnInZone: %s spawnato con successo", spawnName or "Unknown"))
    return spawnedGroup
end

-- Nil-safe GetFirstAliveGroup
function MooseHelpers.SafeGetFirstAliveGroup(spawnObject, spawnName)
    if not spawnObject or not spawnObject.GetFirstAliveGroup then
        env.info(string.format("SafeGetFirstAliveGroup: Spawn object %s è nil o non valido", spawnName or "Unknown"))
        return nil
    end
    
    local group = spawnObject:GetFirstAliveGroup()
    if not group then
        env.info(string.format("SafeGetFirstAliveGroup: Nessun gruppo alive per %s", spawnName or "Unknown"))
        return nil
    end
    
    if not group:IsAlive() then
        env.info(string.format("SafeGetFirstAliveGroup: Gruppo di %s non è alive", spawnName or "Unknown"))
        return nil
    end
    
    return group
end

-- Pattern per string concatenation sicura
function MooseHelpers.SafeStringConcat(...)
    local parts = {...}
    local result = ""
    
    for i, part in ipairs(parts) do
        if part == nil then
            result = result .. "nil"
        else
            result = result .. tostring(part)
        end
    end
    
    return result
end

-- Log delle operazioni critiche
function MooseHelpers.LogOperation(operation, success, details)
    local status = success and "SUCCESS" or "FAILED"
    env.info(string.format("[MOOSE_HELPERS] %s: %s - %s", operation, status, details or "No details"))
end

env.info("MooseHelpers: Funzioni helper caricate con successo")