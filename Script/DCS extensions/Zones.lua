-- ====================================================================================
-- DCSEX.ZONES - FUNCTIONS RELATED TO MAP TRIGGER ZONES
-- ====================================================================================
-- DCSEx.zones.drawOnMap(zoneTable, lineColor, fillColor, lineType, drawName, readOnly)
-- DCSEx.zones.getAirbases(zone, coalition)
-- DCSEx.zones.getAll()
-- DCSEx.zones.getByName(name)
-- DCSEx.zones.getCenter(zoneTable)
-- DCSEx.zones.getProperty(zoneTable, propertyName, defaultValue)
-- DCSEx.zones.getPropertyBoolean(zoneTable, propertyName, defaultValue)
-- DCSEx.zones.getPropertyFloat(zoneTable, propertyName, defaultValue, min, max)
-- DCSEx.zones.getPropertyInt(zoneTable, propertyName, defaultValue, min, max)
-- DCSEx.zones.getPropertyParse(zoneTable, propertyName, stringTable, valueTable, defaultValue)
-- DCSEx.zones.getPropertyTable(zoneTable, propertyName)
-- DCSEx.zones.getRadius(zoneTable, useMaxForQuads)
-- DCSEx.zones.getRandomPointInside(zoneTable, surfaceType)
-- DCSEx.zones.getSurfaceArea(zoneTable)
-- DCSEx.zones.isPointInside(zoneTable, point)
-- ====================================================================================

DCSEx.zones = { }

-------------------------------------
-- Draws a zone on the F10, visible for all players
-------------------------------------
-- @param zoneTable The zone to draw
-- @param lineColor Line color as a RGBA table
-- @param fillColor Fill color as a RGBA table
-- @param lineType Type of line from the DCSEx.enums.lineType enum
-- @param drawName Should the name of the zone be drawn too (default: false)
-- @param drawName Should the zone marker be read only? (default: true)
-------------------------------------
function DCSEx.zones.drawOnMap(zoneTable, lineColor, fillColor, lineType, drawName, readOnly)
    drawName = drawName or false
    readOnly = readOnly or true

    if not zoneTable then return end
    local markerID = DCSEx.world.getNextMarkerID()

    -- Draw shapes on the F10 map
    if zoneTable.type == 2 then -- Zone is a quad
        trigger.action.quadToAll(
            -1,
            markerID,
            DCSEx.math.vec2ToVec3(zoneTable.verticies[1]),
            DCSEx.math.vec2ToVec3(zoneTable.verticies[2]),
            DCSEx.math.vec2ToVec3(zoneTable.verticies[3]),
            DCSEx.math.vec2ToVec3(zoneTable.verticies[4]),
            lineColor,
            fillColor,
            lineType,
            readOnly
        )
    else -- Zone is a circle
        trigger.action.circleToAll(
            -1,
            markerID,
            DCSEx.math.vec2ToVec3(zoneTable),
            zoneTable.radius,
            lineColor,
            fillColor,
            lineType,
            readOnly
        )
    end

    if drawName then
        local markerIDText = DCSEx.world.getNextMarkerID()
        trigger.action.textToAll(-1, markerIDText, DCSEx.math.vec2ToVec3(zoneTable), { 1, 1, 1, 1 }, { 0, 0, 0, .5 }, 18, readOnly, zoneTable.name)
        return { markerID, markerIDText }
    end

    return markerID
end

-------------------------------------
-- Returns all airbases in the zone
-------------------------------------
-- @param zoneTable Table of the zone in which to search
-- @param coalition Coalition (from the coalition.side enum) the airbase must belong to. Default is nil, which means "all coalitions"
-- @return Table of airbases
-------------------------------------
function DCSEx.zones.getAirbases(zoneTable, coalition)
    coalition = coalition or nil

    local coalitions = { coalition.side.RED, coalition.side.BLUE }
    if coalition then coalitions = { coalition } end

    local validAirbases = {}
    for _,side in ipairs(coalitions) do
        for _,ab in ipairs(coalition.getAirbases(side)) do
            if DCSEx.zones.isPointInside(zoneTable, ab:getPoint()) then
                table.insert(validAirbases, ab)
            end
        end
    end
    return validAirbases
end

-------------------------------------
-- Returns all trigger zones
-------------------------------------
-- @return Table of zones
-------------------------------------
function DCSEx.zones.getAll()
    if not env.mission.triggers then
        return {}
    end
    if not env.mission.triggers.zones then
        return {}
    end

    return DCSEx.table.deepCopy(env.mission.triggers.zones)
end

-------------------------------------
-- Finds and return a trigger zone by a certain name
-------------------------------------
-- @param name Case-insensitive name of the zone
-- @return Zone table or nil if no zone with this name was found
-------------------------------------
function DCSEx.zones.getByName(name)
    if not name then return nil end
    if not env.mission.triggers then return nil end
    if not env.mission.triggers.zones then return nil end

    name = name:lower()

    for _, z in pairs(env.mission.triggers.zones) do
        if z.name:lower() == name then
            return DCSEx.table.deepCopy(z)
        end
    end

    return nil
end

-------------------------------------
-- Returns the center of a zone
-------------------------------------
-- @param zoneTable The zone table, returned by TMMissionData.getZones() or TMMissionData.getZoneByName(name)
-- @return A vec2
-------------------------------------
function DCSEx.zones.getCenter(zoneTable)
    if not zoneTable then return nil end

    local x = zoneTable.x or 0
    local y = zoneTable.y or 0

    if zoneTable.type == 2 then -- Zone is a quad
        x = (zoneTable.verticies[1].x + zoneTable.verticies[2].x + zoneTable.verticies[3].x + zoneTable.verticies[4].x) / 4
        y = (zoneTable.verticies[1].y + zoneTable.verticies[2].y + zoneTable.verticies[3].y + zoneTable.verticies[4].y) / 4
    end

    return { x = x, y = y }
end

-------------------------------------
-- Returns the value of the property of a trigger zone, as a string
-------------------------------------
-- @param zoneTable The zone table, returned by DCSEx.zones.getAll() or DCSEx.zones.getByName(name)
-- @param propertyName Case-insensitive name of the property
-- @return The value of the property or nil if it doesn't exist
-------------------------------------
function DCSEx.zones.getProperty(zoneTable, propertyName, defaultValue)
    if not propertyName then return defaultValue end
    if not zoneTable then return defaultValue end
    if not zoneTable.properties then return defaultValue end

    propertyName = propertyName:lower()

    for _, p in pairs(zoneTable.properties) do
        if p.key:lower() == propertyName then
            return (p.value or defaultValue):lower()
        end
    end

    return defaultValue
end

-------------------------------------
-- Returns the value of the property of a trigger zone, parsed against a case-insensitive table of strings
-------------------------------------
-- @param zoneTable The zone table, returned by DCSEx.zones.getAll() or DCSEx.zones.getByName(name)
-- @param propertyName Case-insensitive name of the property
-- @param defaultValue Default value to return if no match was found
-- @return A boolean
-------------------------------------
function DCSEx.zones.getPropertyBoolean(zoneTable, propertyName, defaultValue)
    return DCSEx.zones.getPropertyParse(
        zoneTable,
        propertyName,
        {"true", "yes", "1", "on", "enabled", "false", "no", "0", "off", "disabled"},
        {true, true, true, true, true, false, false, false, false, false},
        defaultValue)
end

-------------------------------------
-- Returns the value of the property of a trigger zone, as a float
-------------------------------------
-- @param zoneTable The zone table, returned by DCSEx.zones.getAll() or DCSEx.zones.getByName(name)
-- @param propertyName Case-insensitive name of the property
-- @param defaultValue Default value to return if no match was found
-- @param min Minimum value
-- @param max Maximum value
-- @return A float
-------------------------------------
function DCSEx.zones.getPropertyFloat(zoneTable, propertyName, defaultValue, min, max)
    local value = tonumber(DCSEx.zones.getProperty(zoneTable, propertyName))
    if not value then return defaultValue end
    if min then value = math.max(min, value) end
    if max then value = math.min(max, value) end
    return value
end

-------------------------------------
-- Returns the value of the property of a trigger zone, as an integer
-------------------------------------
-- @param zoneTable The zone table, returned by DCSEx.zones.getAll() or DCSEx.zones.getByName(name)
-- @param propertyName Case-insensitive name of the property
-- @param defaultValue Default value to return if no match was found
-- @param min Minimum value
-- @param max Maximum value
-- @return An integer
-------------------------------------
function DCSEx.zones.getPropertyInt(zoneTable, propertyName, defaultValue, min, max)
    local value = DCSEx.zones.getPropertyFloat(zoneTable, propertyName, defaultValue, min, max)
    if not value then return nil end
    return math.floor(value)
end

-------------------------------------
-- Gets the value of a property of a trigger zone and parse it according to two correspondance tables
-------------------------------------
-- @param zoneTable The zone table, returned by DCSEx.zones.getAll() or DCSEx.zones.getByName(name)
-- @param propertyName Case-insensitive name of the property
-- @param stringTable A table of strings
-- @param valueTable A values, matching the strings table's indices
-- @param defaultValue Default value to return if no match was found
-- @return A value
-------------------------------------
function DCSEx.zones.getPropertyParse(zoneTable, propertyName, stringTable, valueTable, defaultValue)
    local value = DCSEx.zones.getProperty(zoneTable, propertyName) or ""
    value = value:lower()

    for i,_ in ipairs(stringTable) do
        if value == stringTable[i]:lower() then
            return valueTable[i]
        end
    end

    return defaultValue
end

-------------------------------------
-- Returns the value of the property of a trigger zone, as a table of comma-separated lowercase strings
-------------------------------------
-- @param zoneTable The zone table, returned by DCSEx.zones.getAll() or DCSEx.zones.getByName(name)
-- @param propertyName Case-insensitive name of the property
-- @return An table
-------------------------------------
function DCSEx.zones.getPropertyTable(zoneTable, propertyName)
    local value = DCSEx.zones.getProperty(zoneTable, propertyName)
    if not value then return {} end
    return string.split(value:lower(), ",")
end

-------------------------------------
-- Returns the radius of a zone, in meter
-------------------------------------
-- @param zoneTable The zone table, returned by DCSEx.zones.getAll() or DCSEx.zones.getByName(name)
-- @param useMaxForQuads If true, return largest distance between the center and a vertex. If false (default value), returns the mean distance. Only used if the zone is a quad.
-- @return An table
-------------------------------------
function DCSEx.zones.getRadius(zoneTable, useMaxForQuads)
    if not zoneTable then return 0 end
    useMaxForQuads = useMaxForQuads or false

    local radius = 0

    if zoneTable.type == 2 then -- Zone is a quad
        for _,v in ipairs(zoneTable.verticies) do
            if useMaxForQuads then
                radius = math.max(radius, DCSEx.math.getDistance2D(zoneTable, v))
            else
                radius = radius + DCSEx.math.getDistance2D(zoneTable, v)
            end
        end

        if #zoneTable.verticies > 0 and not useMaxForQuads then
            radius = radius / #zoneTable.verticies
        end
    else
        radius = zoneTable.radius
    end

    return radius
end

-- TODO: description + file header
function DCSEx.zones.getRandomPointInside(zoneTable, surfaceType)
    local radius = DCSEx.zones.getRadius(zoneTable)

    for _=1,64 do
        local point = DCSEx.math.randomPointInCircle(zoneTable, radius, surfaceType)

        if zoneTable.type == 2 then
            if not DCSEx.zones.isPointInside(zoneTable, point) then point = nil end
        end

        if point then return point end
    end

    return nil
end

-------------------------------------
-- Returns the surface area of a zone
-------------------------------------
-- @param zoneTable The zone table, returned by TMMissionData.getZones() or TMMissionData.getZoneByName(name)
-- @return A number, in squared meters
-------------------------------------
function DCSEx.zones.getSurfaceArea(zoneTable)
    if not zoneTable then return 0 end

    if zoneTable.type == 2 then -- Zone is a quad
        if not zoneTable.verticies then return 0 end
        local area = zoneTable.verticies[1].x * zoneTable.verticies[2].y + zoneTable.verticies[2].x * zoneTable.verticies[3].y + zoneTable.verticies[3].x * zoneTable.verticies[4].y + zoneTable.verticies[4].x * zoneTable.verticies[1].y - zoneTable.verticies[2].x * zoneTable.verticies[1].y - zoneTable.verticies[3].x * zoneTable.verticies[2].y - zoneTable.verticies[4].x * zoneTable.verticies[3].y - zoneTable.verticies[1].x * zoneTable.verticies[4].y
        return math.abs(area) / 2
    else -- Zone is a circle
        if not zoneTable.radius then return 0 end
        return (zoneTable.radius ^ 2) * math.pi
    end
end

-------------------------------------
-- Returns true if a point is inside a zone
-------------------------------------
-- @param zoneTable The zone table, returned by TMMissionData.getZones() or TMMissionData.getZoneByName(name)
-- @param point A point, as a vec3 or vec2
-- @return True if the point is inside the zone, false otherwise
-------------------------------------
function DCSEx.zones.isPointInside(zoneTable, point)
    if not point then return false end
    if point.z then point = DCSEx.math.vec3ToVec2(point) end -- Point was a vec3, convert to vec2

    if zoneTable.type == 2 then -- Zone is a quad
        return DCSEx.math.isPointInsidePolygon(zoneTable.verticies, point)
    else -- Zone is a circle
        return DCSEx.math.isPointInsideCircle({x = zoneTable.x, y = zoneTable.y}, zoneTable.radius, point)
    end
end
