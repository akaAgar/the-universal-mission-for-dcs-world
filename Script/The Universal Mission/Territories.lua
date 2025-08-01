-- ====================================================================================
-- TUM.TERRITORIES - HANDLES THE MISSION SPECIAL ZONES (COALITION TERRITORIES, WATER AND BATTLE ZONES)
-- ====================================================================================
-- (local) assignTerritoryToZone(coalitionID, zone)
-- TUM.territories.getCenter(side)
-- TUM.territories.getPointOwner(point)
-- TUM.territories.getRandomPoint(side, surfaceType)
-- TUM.territories.getSurfaceArea(side)
-- TUM.territories.onInitialize()
-- ====================================================================================

TUM.territories = {}

do
    local coalitionZones = { {}, {} }
    local missionZones = {}
    local waterZones = {}

    local function addZoneToCoalition(zone, side)
        table.insert(coalitionZones[side], zone)
        local airbases = world.getAirbases()

        for _,ab in pairs(airbases) do
            local airbasePoint2 = DCSEx.math.vec3ToVec2(ab:getPoint())

            if DCSEx.zones.isPointInside(zone, airbasePoint2) then
                if ab:getDesc().category ~= Airbase.Category.SHIP then -- Ignore ships
                    ab:setCoalition(side)
                end
            end
        end
    end

    function TUM.territories.getMissionZones()
        return DCSEx.table.deepCopy(missionZones)
    end

    function TUM.territories.getWaterZones()
        return DCSEx.table.deepCopy(waterZones)
    end

    -------------------------------------
    -- Returns the coalition to which belong a given point on the map.
    -- Return coalition.side.NEUTRAL if the point isn't in any coalition territory.
    -- @param point A vec2 or vec3
    -- @return A value from the coalition.side enum
    -------------------------------------
    function TUM.territories.getPointOwner(point)
        for side=1,2 do
            for _,z in ipairs(coalitionZones[side]) do
                if DCSEx.zones.isPointInside(z, point) then
                    return side
                end
            end
        end

        return coalition.side.NEUTRAL
    end

    function TUM.territories.getTerritoryZones(side)
        return DCSEx.table.deepCopy(coalitionZones[side])
    end

    function TUM.territories.getTerritoryCenter(side)
        local center = { x = 0, y = 0 }

        if #coalitionZones[side] == 0 then return center end

        for _,z in ipairs(coalitionZones[side]) do
            center.x = center.x + z.x
            center.y = center.y + z.y
        end

        -- TODO: bigger zones should skew the center in their favor

        center.x = center.x / #coalitionZones[side]
        center.y = center.y / #coalitionZones[side]

        return center
    end

    -- function TUM.territories.getCenter(side)
    --     return DCSEx.zones.getCenter(zones[side])
    -- end

    -- function TUM.territories.getSurfaceArea(side)
    --     return DCSEx.zones.getSurfaceArea(zones[side])
    -- end

    -- function TUM.territories.getZone(side)
    --     return DCSEx.table.deepCopy(zones[side])
    -- end

    function TUM.territories.getRandomPointInTerritory(side, surfaceType)
        if #coalitionZones[side] == 0 then return nil end

        local zone = DCSEx.table.getRandom(coalitionZones[side]) -- TODO: bigger zones should be selected more often

        return DCSEx.zones.getRandomPointInside(zone, surfaceType)
    end

    -------------------------------------
    -- Called on mission start up
    -- @return True if started up properly, false if an error happened
    -------------------------------------
    function TUM.territories.onStartUp()
        coalitionZones = { {}, {} }
        missionZones = {}
        waterZones = {}

        -- Disable autocapture for all bases and give them to the neutral coalition
        for _,ab in pairs(world.getAirbases()) do
            ab:autoCapture(false)
            if ab:getDesc().category ~= Airbase.Category.SHIP then -- Ignore ships
                ab:setCoalition(coalition.side.NEUTRAL)
            end
        end

        local zones = DCSEx.zones.getAll()
        for _,z in ipairs(zones) do
            if DCSEx.string.startsWith(z.name:lower(), "blufor") then
                addZoneToCoalition(z, coalition.side.BLUE)
            elseif DCSEx.string.startsWith(z.name:lower(), "redfor") then
                addZoneToCoalition(z, coalition.side.RED)
            elseif DCSEx.string.startsWith(z.name:lower(), "water") then
                table.insert(waterZones, z)
            else
                local onlyZonesStartingWith = TUM.administrativeSettings.getValue(TUM.administrativeSettings.ONLY_ZONES_STARTINGWITH)
                if onlyZonesStartingWith and #onlyZonesStartingWith > 0 then
                    if type(onlyZonesStartingWith) ~= "table" then
                        onlyZonesStartingWith = { onlyZonesStartingWith }
                    end
                    for _, zonePrefix in ipairs(onlyZonesStartingWith) do
                        if DCSEx.string.startsWith(z.name:lower(), zonePrefix:lower()) then
                            table.insert(missionZones, z)
                            break
                        end
                    end
                else
                    local ignoreZonesStartingWith = TUM.administrativeSettings.getValue(TUM.administrativeSettings.IGNORE_ZONES_STARTINGWITH)
                    if ignoreZonesStartingWith then
                        if not DCSEx.string.startsWith(z.name:lower(), ignoreZonesStartingWith:lower()) then
                            table.insert(missionZones, z)
                        end
                    else
                        table.insert(missionZones, z)
                    end
                end
            end
        end

        for side=1,2 do
            if #coalitionZones[side] == 0 or #coalition.getAirbases(side) == 0 then
                local name = DCSEx.dcs.getCoalitionAsString(side)
                local zoneName = "BLUFOR"
                if side == 1 then zoneName = "REDFOR" end

                TUM.log("Coalition "..name.." has no territory zones and/or controls no airfields. Please add zone with a name starting with "..zoneName.." in the mission editor and make sure at least one contains an airbase.", TUM.logLevel.ERROR)
                return false
            end
        end

        if #missionZones == 0 then
            TUM.log("No mission zones found. Create at least one mission zone in the mission editor.", TUM.logLevel.ERROR)
            return false
        end

        if #missionZones > 10 then
            TUM.log("Too many mission zones, extra zones removed.", TUM.logLevel.WARNING)
            while #missionZones > 10 do
                table.remove(missionZones, 11)
            end
        end

        -- zones = {}
        -- zones[coalition.side.BLUE] = DCSEx.zones.getByName("BLUFOR")
        -- zones[coalition.side.RED] = DCSEx.zones.getByName("REDFOR")

        -- if not zones[coalition.side.BLUE] then
        --     TUM.log("BLUFOR zone not found.", TUM.logLevel.ERROR)
        --     return false
        -- elseif not zones[coalition.side.RED] then
        --     TUM.log("REDFOR zone not found.", TUM.logLevel.ERROR)
        --     return false
        -- end

        -- -- TODO: square kilometers if "metric system" enabled?
        -- for side=1,2 do
        --     TUM.log(
        --         "Coalition "..DCSEx.dcs.getCoalitionAsString(side):upper().."'s territory is "..
        --         DCSEx.string.toStringThousandsSeparator(math.floor(TUM.territories.getSurfaceArea(side) / 2589988.110336)).." squared miles.")
        -- end

        return true
    end
end
