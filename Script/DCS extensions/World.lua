-- ====================================================================================
-- DCSEX.WORLD - FUNCTIONS RELATED TO THE GAME WORLD
-- ====================================================================================
-- DCSEx.world.collidesWithScenery(vec2, radius)
-- DCSEx.world.destroyGroupByID(groupID)
-- DCSEx.world.explodeUnit(unitID, amount)
-- DCSEx.world.getAllPlayers()
-- DCSEx.world.getAllSceneryBuildings(minHealth)
-- DCSEx.world.getAllUnits(coalitionID, unitCategory)
-- DCSEx.world.getClosestPointOnRoadsVec2(vec2)
-- DCSEx.world.getCoordinatesAsString(point, hideElevation)
-- DCSEx.world.getCurrentMarkerID()
-- DCSEx.world.getFirstPlayer(side)
-- DCSEx.world.getGroupByID(groupID)
-- DCSEx.world.getGroupCenter(group)
-- DCSEx.world.getMarkerByText(text, coalition)
-- DCSEx.world.getNextMarkerID()
-- DCSEx.world.getPlayersInAir(side)
-- DCSEx.world.getPlayersOnGround(side)
-- DCSEx.world.getSceneriesInZone(center, radius, minHealth)
-- DCSEx.world.getSpawnPoint(zone, surfaceType, safeRadius)
-- DCSEx.world.getStaticObjectByID(staticID)
-- DCSEx.world.getTerrainHeightDiff(coord, searchRadius)
-- DCSEx.world.getUnitByID(unitID)
-- DCSEx.world.getUnitsCenter(units)
-- DCSEx.world.isGroupAlive(g, unitsMustBeInAir)
-- DCSEx.world.setUnitLifePercent(unitID, life)
-- ====================================================================================

DCSEx.world = { }

do
    -- TODO: get max marker already in use from envMission
    local nextMarkerId = 1 -- Next map marker ID

    -------------------------------------
    -- Returns true if vec2 is less than radius meters away from any scenery object
    -------------------------------------
    -- @param vec2 A 2d point
    -- @param radius A range, in meters
    -- @return True if vec2 is closer than radius meters from any object, false otherwise
    -------------------------------------
    function DCSEx.world.collidesWithScenery(vec2, radius)
        radius = radius or 8
        local foundOne = false

        local volS = {
            id = world.VolumeType.SPHERE,
            params = {
            point = DCSEx.math.vec2ToVec3(vec2, "land"),
            radius = radius
            }
        }

        local ifFound = function(foundItem, val)
            foundOne = true
            return true
        end

        world.searchObjects(Object.Category.SCENERY, volS, ifFound)

        return foundOne
    end

    -------------------------------------
    -- Destroys a group
    -------------------------------------
    -- @param groupID ID of the group to destroy
    -------------------------------------
    function DCSEx.world.destroyGroupByID(groupID)
        if not groupID then return end
        local g = DCSEx.world.getGroupByID(groupID)
        if g then g:destroy() end
    end

    -------------------------------------
    -- Spawns an explosion where an unit is located
    -------------------------------------
    -- @param unitID ID of the unit
    -- @param amount Intensity of the explosion
    -------------------------------------
    function DCSEx.world.explodeUnit(unitID, amount)
        net.dostring_in("mission", string.format("a_explosion_unit(%d, %f)", unitID, amount))
    end

    -------------------------------------
    -- Returns a table of all player-controlled units currently in the game
    -------------------------------------
    -- @return A table of unit objects
    -------------------------------------
    function DCSEx.world.getAllPlayers()
        local players = {}

        for coalitionID=0,2 do
            local coalPlayers = coalition.getPlayers(coalitionID)
            for _,p in pairs(coalPlayers) do
                table.insert(players, p)
            end
        end

        return players
    end

    -------------------------------------
    -- Returns a table of all map scenery buildings.
    -- This function is rather CPU-heavy, better run it once on mission start and store the results in a table.
    -------------------------------------
    -- @param minHealth Minimum health a building must have to be included in the table
    -- @return A table of scenery objects
    -------------------------------------
    function DCSEx.world.getAllSceneryBuildings(minHealth)
        minHealth = minHealth or 0
        local sceneries = {}

        local scenerySearchvolume = {
            id = world.VolumeType.SPHERE,
            params = { point = { x = env.mission.map.centerX, y = 0, z = env.mission.map.centerY }, radius = 10000000 }
        }

        local function ifSceneryFound(foundScenery, val)
            local desc = foundScenery:getDesc()
            if desc and desc.attributes and desc.attributes.Buildings then
                if desc.life >= minHealth then
                    table.insert(sceneries, foundScenery)
                end
            end
            return true
        end

        world.searchObjects(Object.Category.SCENERY, scenerySearchvolume, ifSceneryFound)

        return sceneries
    end

    -------------------------------------
    -- Returns all units belonging to a given category
    -------------------------------------
    -- @param coalitionID Coalition ID (coalition.side.XXX) or nil to search all coalitions
    -- @param unitCategory An unit category (Group.Category.XXX)
    -- @return A table of unit tables
    -------------------------------------
    function DCSEx.world.getAllUnits(coalitionID, unitCategory)
        local units = {}

        local searchedCoalitions = { 0, 1, 2 }
        if coalitionID then searchedCoalitions = { coalitionID } end

        for _,c in pairs(searchedCoalitions) do -- Enumerate coalitions
            for _, g in pairs(coalition.getGroups(c, unitCategory)) do
                for __, u in pairs(g:getUnits()) do
                    table.insert(units, u)
                end
            end
        end

        return units
    end

    -------------------------------------
    -- Returns the closest point to roads as a vec2.
    -- An alternative to ED's zany land.getClosestPointOnRoads which returns two integers (!!???)
    -------------------------------------
    -- @param vec2 Coordinates to look for
    -- @return A vec2 with the closest point on roads
    -------------------------------------
    function DCSEx.world.getClosestPointOnRoadsVec2(vec2)
        local roadX, roadY = land.getClosestPointOnRoads("roads", vec2.x, vec2.y)
        return {x = roadX, y = roadY}
    end

    -------------------------------------
    -- Returns the LL/MGRS coordinates of a point, as a string
    -- Based on code by Bushmanni - https://forums.eagle.ru/showthread.php?t=99480
    -------------------------------------
    -- @param point The point, as a vec2 or vec3
    -- @param hideElevation (optional) Show elevation NOT be displayed? Default: false
    -- @return A string
    -------------------------------------
    function DCSEx.world.getCoordinatesAsString(point, hideElevation)
        hideElevation = hideElevation or false

        if not point.z then point = DCSEx.math.vec2ToVec3(point, "land") end
        local cooString = ""

        local LLposN, LLposE, alt = coord.LOtoLL(point)
        local LLposfixN, LLposdegN = math.modf(LLposN)
        LLposdegN = LLposdegN * 60
        local LLposdegN2, LLposdegN3 = math.modf(LLposdegN)
        local LLposdegN3Decimal = LLposdegN3 * 1000
        LLposdegN3 = LLposdegN3 * 60

        local LLposfixE, LLposdegE = math.modf(LLposE)
        LLposdegE = LLposdegE * 60
        local LLposdegE2, LLposdegE3 = math.modf(LLposdegE)
        local LLposdegE3Decimal = LLposdegE3 * 1000
        LLposdegE3 = LLposdegE3 * 60

        local LLns = "N"
        if LLposfixN < 0 then
            LLns = "S"
        end
        local LLew = "E"
        if LLposfixE < 0 then
            LLew = "W"
        end

        local LLposNstring = LLns .. " " .. string.format("%.2i°%.2i'%.2i''", LLposfixN, LLposdegN2, LLposdegN3)
        local LLposEstring = LLew .. " " .. string.format("%.3i°%.2i'%.2i''", LLposfixE, LLposdegE2, LLposdegE3)
        cooString = "L/L: " .. LLposNstring .. " " .. LLposEstring

        local LLposNstring = LLns .. " " .. string.format("%.2i°%.2i.%.3i", LLposfixN, LLposdegN2, LLposdegN3Decimal)
        local LLposEstring = LLew .. " " .. string.format("%.3i°%.2i.%.3i", LLposfixE, LLposdegE2, LLposdegE3Decimal)
        cooString = cooString .. "\nL/L: " .. LLposNstring .. " " .. LLposEstring

        local mgrs = coord.LLtoMGRS(LLposN, LLposE)
        local mgrsString =
            mgrs.MGRSDigraph .. " " .. mgrs.UTMZone .. " " .. tostring(mgrs.Easting) .. " " .. tostring(mgrs.Northing)
        cooString = cooString .. "\nMGRS: " .. mgrsString

        if not hideElevation then
            cooString = cooString .. "\nELEVATION: " .. math.floor(alt * 3.281) .. "ft / " .. math.floor(alt) .. " meters"
        end

        return cooString
    end

    -------------------------------------
    -- Returns the last map marker ID generated by DCSEx.world.getNextMarkerID(), if any
    -------------------------------------
    -- @return A numeric ID, or nil
    -------------------------------------
    function DCSEx.world.getCurrentMarkerID()
        if nextMarkerId == 1 then return nil end
        return nextMarkerId - 1
    end

    -------------------------------------
    -- Returns the first player found
    -------------------------------------
    -- @param side The coalition the player must belong to, or nil to search for any player
    -- @return A player unit object, or nil if no player was found
    -------------------------------------
    function DCSEx.world.getFirstPlayer(side)
        local players = {}
        if side then
            players = coalition.getPlayers(side)
        else
            players = DCSEx.world.getAllPlayers()
        end

        if not players or #players == 0 then return nil end
        return players[1]
    end

    -------------------------------------
    -- Searches and return a group by its ID
    -------------------------------------
    -- @param groupID ID of the group
    -- @return A group table, or nil if no group with this ID was found
    -------------------------------------
    function DCSEx.world.getGroupByID(groupID)
        for coalitionID = 1, 2 do
            for _, grp in pairs(coalition.getGroups(coalitionID)) do
                if DCSEx.dcs.getGroupIDAsNumber(grp) == groupID then
                    return grp
                end
            end
        end

        return nil
    end

    -------------------------------------
    -- Searches and return a map marker by its text (case-insensitive)
    -------------------------------------
    -- @param text Text to look for (case insensitive)
    -- @param coalition Coalition the marker must belong to, or nil to search all coalitions
    -- @return A map marker table, or nil if no marker was found
    -------------------------------------
    function DCSEx.world.getMarkerByText(text, coalition)
        if not text then return nil end
        text = text:lower()
        local markers = world.getMarkPanels()

        for _,m in ipairs(markers) do
            local markerText = m.text or ""
            markerText = markerText:lower()
            if markerText == text then
                if not coalition or m.coalition == coalition then
                    return m
                end
            end
        end

        return nil
    end

    -------------------------------------
    -- Returns a new unique map marker ID
    -------------------------------------
    -- @return A numeric ID
    -------------------------------------
    function DCSEx.world.getNextMarkerID()
        nextMarkerId = nextMarkerId + 1
        return nextMarkerId - 1
    end

    -------------------------------------
    -- Returns a table of all player units currently in the air (not on ramp/ground/runway)
    -------------------------------------
    -- @param side Coalition the players must belong to, or nil to search all coalitions
    -- @return A table of player objects
    -------------------------------------
    function DCSEx.world.getPlayersInAir(side)
        local players = {}
        if side then
            players = coalition.getPlayers(side)
        else
            players = DCSEx.world.getAllPlayers()
        end

        local playersInAir = {}
        for _,p in ipairs(players) do
            if p:inAir() then
                table.insert(playersInAir, p)
            end
        end

        return playersInAir
    end

    -------------------------------------
    -- Returns a table of all player units currently NOT in the air (on ramp/ground/runway)
    -------------------------------------
    -- @param side Coalition the players must belong to, or nil to search all coalitions
    -- @return A table of player objects
    -------------------------------------
    function DCSEx.world.getPlayersOnGround(side)
        local players = {}
        if side then
            players = coalition.getPlayers(side)
        else
            players = DCSEx.world.getAllPlayers()
        end

        local playersOnGround = {}
        for _,p in ipairs(players) do
            if not p:inAir() then
                table.insert(playersOnGround, p)
            end
        end

        return playersOnGround
    end

    -------------------------------------
    -- Returns a valid spawn point for a ground unit (not stuck in trees, buildings...) or a naval unit
    -------------------------------------
    -- @param zone Trigger zone in which to look for a spawn point
    -- @param surface Type of surface (land.SurfaceType enum) to look for, or any to return any point (good for air units)
    -- @param safeRadius Saferadius in meters from any obstacle (default: 100)
    -- @return A 2D point, or nil if none was found
    -------------------------------------
    function DCSEx.world.getSpawnPoint(zone, surfaceType, safeRadius)
        safeRadius = safeRadius or 100

        -- Only two surface types are really useful to us: land and water
        if surfaceType == land.SurfaceType.SHALLOW_WATER then
            surfaceType = land.SurfaceType.WATER
        elseif surfaceType == land.SurfaceType.ROAD or surfaceType == land.SurfaceType.RUNWAY then
            surfaceType = land.SurfaceType.LAND
        end

        local loopsLeft = 512

        while loopsLeft > 0 do
            local basePoint = DCSEx.zones.getRandomPointInside(zone)

            if not surfaceType then -- Nil surfaceType means: any point is fine
                return basePoint
            end

            if surfaceType == land.SurfaceType.WATER then
                if basePoint and land.getSurfaceType(basePoint) == land.SurfaceType.WATER then
                    return basePoint
                end
            else
                if safeRadius <= 0 then
                    return basePoint
                end

                basePoint = DCSEx.math.vec2ToVec3(basePoint, "land")

                local spawnPoints = Disposition.getSimpleZones(basePoint, math.max(1852, safeRadius * 5), safeRadius, 1)
                if #spawnPoints > 0 and land.getSurfaceType(spawnPoints[1]) == land.SurfaceType.LAND then
                    return spawnPoints[1]
                end
            end

            loopsLeft = loopsLeft - 1
        end

        return nil
    end

    -------------------------------------
    -- Returns a table of all scenery objects in a given radius
    -------------------------------------
    -- @param center 2D point on which to center object search
    -- @param radius Radius (in meters) around the center in which to search
    -- @param minHealth Minimum health for a scenery object to be valid. Allow filtering of small objects like bollards (default: 0)
    -- @return A table of scenery objects
    -------------------------------------
    function DCSEx.world.getSceneriesInZone(center, radius, minHealth)
        minHealth = minHealth or 0
        local sceneries = {}

        local scenerySearchvolume = {
            id = world.VolumeType.SPHERE,
            params = { point = DCSEx.math.vec2ToVec3(center, "land"), radius = radius }
        }

        local function ifSceneryFound(foundScenery, val)
            local desc = foundScenery:getDesc()
            if desc and desc.attributes and desc.attributes.Buildings then
                if desc.life >= minHealth then
                    table.insert(sceneries, foundScenery)
                end
            end
            return true
        end

        world.searchObjects(Object.Category.SCENERY, scenerySearchvolume, ifSceneryFound)

        return sceneries
    end

    -------------------------------------
    -- Returns the maximum height difference in a given radius around a point
    -------------------------------------
    -- @param coord 2D point in which to search
    -- @param searchRadius Radius in meters
    -- @return A numeric value, in meters
    -------------------------------------
    function DCSEx.world.getTerrainHeightDiff(coord, searchRadius)
		local samples = {}
        searchRadius = searchRadius or 5

		samples[#samples + 1] = land.getHeight(coord)
		for i = 0, 360, 30 do
			samples[#samples + 1] = land.getHeight({x = (coord.x + (math.sin(math.rad(i))*searchRadius)), y = (coord.y + (math.cos(math.rad(i))*searchRadius))})
			if searchRadius >= 20 then -- if search radius is sorta large, take a sample halfway between center and outer edge
				samples[#samples + 1] = land.getHeight({x = (coord.x + (math.sin(math.rad(i))*(searchRadius/2))), y = (coord.y + (math.cos(math.rad(i))*(searchRadius/2)))})
			end
		end
		local tMax, tMin = 0, 1000000
		for _, height in pairs(samples) do
			if height > tMax then
				tMax = height
			end
			if height < tMin then
				tMin = height
			end
		end

        return tMax - tMin
	end

    -------------------------------------
    -- Returns the 2D center of unit group
    -------------------------------------
    -- @param group A group of unit
    -- @return The 2D point center of all units' positions or 0,0 if no units were found
    -------------------------------------
    function DCSEx.world.getGroupCenter(group)
        return DCSEx.world.getUnitsCenter(group:getUnits())
    end

    -------------------------------------
    -- Searches and return a coalition static object by its ID
    -------------------------------------
    -- @param unitID ID of the static object
    -- @return An static object, or nil if no unit with this ID was found
    -------------------------------------
    function DCSEx.world.getStaticObjectByID(staticID)
        for coalitionID = 1,2 do
            for _,s in pairs(coalition.getStaticObjects(coalitionID)) do
                if DCSEx.dcs.getObjectIDAsNumber(s) == staticID then
                    return s
                end
            end
        end

        return nil
    end

    -------------------------------------
    -- Searches and returns an unit by its ID
    -------------------------------------
    -- @param unitID ID of the unit
    -- @return An unit, or nil if no unit with this ID was found
    -------------------------------------
    function DCSEx.world.getUnitByID(unitID)
        for coalitionID = 1, 2 do
            for _, g in pairs(coalition.getGroups(coalitionID)) do
                local units = g:getUnits()
                for _, u in pairs(units) do
                    if DCSEx.dcs.getObjectIDAsNumber(u) == unitID then
                        return u
                    end
                end
            end
        end

        return nil
    end

    -------------------------------------
    -- Returns the 2D center of a number of units
    -------------------------------------
    -- @param units A table of units
    -- @return The 2D point center of all units' positions or 0,0 if no units were found
    -------------------------------------
    function DCSEx.world.getUnitsCenter(units)
        if not units or #units == 0 then return { x = 0, y = 0 } end

        local center = { x = 0, y = 0 }
        for _,u in pairs(units) do
            local uPt2 = DCSEx.math.vec3ToVec2(u:getPoint())
            center.x = center.x + uPt2.x
            center.y = center.y + uPt2.y
        end

        center.x = center.x / #units
        center.y = center.y / #units

        return center
    end

    -------------------------------------
    -- Returns true if a group exists and any of its units are alive, false otherwise
    -------------------------------------
    -- @param g A group
    -- @param unitsMustBeInAir Are units on the ground ignored? (default: false)
    -- @return True if a group exists and any of its units are alive, false otherwise
    -------------------------------------
    function DCSEx.world.isGroupAlive(g, unitsMustBeInAir)
        if not g then return false end
        if not g:isExist() then return false end
        if g:getSize() == 0 then return false end

        unitsMustBeInAir = unitsMustBeInAir or false

        local atLeastOneActiveUnit = false
        local units = g:getUnits()
        if not units or #units == 0 then return false end
        for _,u in pairs(units) do
            if u:isExist() and u:getLife() > 0 then
                if u:inAir() or not unitsMustBeInAir then
                    atLeastOneActiveUnit = true
                end
            end
        end

        return atLeastOneActiveUnit
    end

    -------------------------------------
    -- Sets the health of an unit
    -------------------------------------
    -- @param unitID ID of the unit
    -- @param life Life percentage
    -------------------------------------
    function DCSEx.world.setUnitLifePercent(unitID, life)
        net.dostring_in("mission", string.format("a_unit_set_life_percentage(%d, %f)", unitID, life))
    end

    -- function DCSEx.world.destroySceneryInZone(zone, destructionPercent)
    --     destructionPercent = destructionPercent or 0
    --     net.dostring_in("mission", string.format("a_scenery_destruction_zone(%d, %f)", zone.zoneId, destructionPercent))
    -- end

    -- function DCSEx.world.highlightUnit(unitID, enabled)
    --     if enabled then
    --         enabled = "true"
    --     else
    --         enabled = "false"
    --     end

    --     net.dostring_in("mission", string.format("a_unit_highlight(%d, %s)", unitID, enabled))
    -- end

    -- function DCSEx.world.shellingZone(zone, tnt, shellsCount)
    --     net.dostring_in("mission", string.format("a_shelling_zone(%d, %f, %d)", zone.zoneId, tnt, shellsCount))
    -- end

    -- function DCSEx.world.findSpawnPoint(vec2, minRadius, maxRadius, surfaceType, radiusWithoutScenery, territorySide, expandSearch)
    --     expandSearch = expandSearch or true

    --     for _=0,16 do
    --         for _=0,16 do
    --             local spawnPoint = nil

    --             spawnPoint = DCSEx.math.randomPointInCircle(
    --                 vec2,
    --                 DCSEx.converter.nmToMeters(maxRadius),
    --                 DCSEx.converter.nmToMeters(minRadius),
    --                 surfaceType)

    --             if spawnPoint and radiusWithoutScenery then
    --                 if DCSEx.world.collidesWithScenery(spawnPoint, radiusWithoutScenery) then
    --                     spawnPoint = nil
    --                 end
    --             end

    --             if spawnPoint and territorySide then
    --                 if scramble.territories.getOwner(spawnPoint) ~= territorySide then
    --                     spawnPoint = nil
    --                 end
    --             end

    --             if spawnPoint then return spawnPoint end
    --         end

    --         if not expandSearch then return nil end

    --         minRadius = minRadius * 0.9
    --         maxRadius = maxRadius * 1.2
    --     end

    --     return nil
    -- end
end
