-- ====================================================================================
-- DCSEX.MATH - MATH AND MATH-RELATED FUNCTIONS
-- ====================================================================================
-- (Constant) DCSEx.math.TWO_PI
-- DCSEx.math.addVec(vecA, vecB)
-- DCSEx.math.clamp(val, min, max)
-- DCSEx.math.getBearing(point, refPoint, returnAsNESWstring)
-- DCSEx.math.getDistance2D(vec2a, vec2b)
-- DCSEx.math.getDistance3D(vec3a, vec3b)
-- DCSEx.math.getLength3D(vec3)
-- DCSEx.math.getRelativeHeading(point, refObject, format)
-- DCSEx.math.getVec2FromAngle(angle)
-- DCSEx.math.isPointInsideCircle(center, radius, vec2)
-- DCSEx.math.isPointInsidePolygon(polygon, vec2)
-- DCSEx.math.isSamePoint(pointA, pointB)
-- DCSEx.math.lerp(val0, val1, t)
-- DCSEx.math.multVec2(vec2, mult)
-- DCSEx.math.normalizeVec2(vec2)
-- DCSEx.math.randomBoolean()
-- DCSEx.math.randomFloat(min, max)
-- DCSEx.math.randomPointAtDistance(point, distance)
-- DCSEx.math.randomPointInCircle(center, radius, minRadius, surfaceType)
-- DCSEx.math.randomSign()
-- DCSEx.math.toBoolean(val)
-- DCSEx.math.vec2ToVec3(vec2, y)
-- DCSEx.math.vec3ToVec2(vec3)
-- ====================================================================================

DCSEx.math = {}

-------------------------------------
-- Two times Pi
-------------------------------------
DCSEx.math.TWO_PI = math.pi * 2

-------------------------------------
-- Returns the sum of two vec2 or vec3
-------------------------------------
-- @param vecA A vector
-- @param vecB Another vector
-- @return The sum of both vectors
-------------------------------------
function DCSEx.math.addVec(vecA, vecB)
    if vecA.z then
        return { x = vecA.x + vecB.x, y = vecA.y + vecB.y, z = vecA.z + vecB.z }
    end

    return { x = vecA.x + vecB.x, y = vecA.y + vecB.y }
end

-------------------------------------
-- Clamp a number value between min and max
-------------------------------------
-- @param value The value to clamp
-- @param min Minimum allowed value
-- @param max Maximum allowed value
-- @return Clamped value
-------------------------------------
function DCSEx.math.clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

-------------------------------------
-- Gets the bearing between two vectors, in degrees
-------------------------------------
-- @param point A vec2/vec3
-- @param refPoint Vec2/vec3 to use as a reference point
-- @param returnAsNESWstring Should the value be returned as a N/S/E/W string instead of a numeric value
-- @return Bearing, as a number, in degrees
-------------------------------------
function DCSEx.math.getBearing(point, refPoint, returnAsNESWstring)
    returnAsNESWstring = returnAsNESWstring or false

    refPoint = refPoint or {x = 0, y = 0}
    if point.z then point = DCSEx.math.vec3ToVec2(point) end -- Point is a vec3, convert it
    if refPoint.z then refPoint = DCSEx.math.vec3ToVec2(refPoint) end -- Point is a vec3, convert it

    local bearing = math.atan2(point.y - refPoint.y, point.x - refPoint.x)

    if bearing < 0 then
        bearing = bearing + DCSEx.math.TWO_PI
    end

    bearing = math.floor(bearing * (180 / math.pi))

    if returnAsNESWstring then
        bearing = math.floor((bearing / 45.0) + .5)
        local namesArray = { "north", "northeast", "east", "southeast", "south", "southwest", "west", "northwest" }
        return namesArray[(bearing % 8) + 1]
    end

    return bearing
end

-------------------------------------
-- Returns the pythagorean distance between two 2D points or the length of a single vector
-------------------------------------
-- @param vec2a A 2D point
-- @param vec2b (optional) Another 2D point
-- @return Distance between the points
-------------------------------------
function DCSEx.math.getDistance2D(vec2a, vec2b)
    vec2b = vec2b or { x = 0, y = 0 }
    if vec2a.z then vec2a = DCSEx.math.vec3ToVec2(vec2a) end
    if vec2b.z then vec2b = DCSEx.math.vec3ToVec2(vec2b) end

    return math.sqrt((vec2a.x - vec2b.x) ^ 2 + (vec2a.y - vec2b.y) ^ 2)
end

-------------------------------------
-- Returns the pythagorean distance between two 3D points or the length of a single vector
-------------------------------------
-- @param vec3a A 3D point
-- @param vec3b (optional) Another 3D point
-- @return Distance between the points
-------------------------------------
function DCSEx.math.getDistance3D(vec3a, vec3b)
    vec3b = vec3b or { x = 0, y = 0, z = 0 }

    return math.sqrt((vec3a.x - vec3b.x) ^ 2 + (vec3a.y - vec3b.y) ^ 2 + (vec3a.z - vec3b.z) ^ 2)
end

-------------------------------------
-- Returns the length of a 3D vector
-------------------------------------
-- @param vec3 A 3D vector
-- @return Length of the vector
-------------------------------------
function DCSEx.math.getLength3D(vec3)
    return math.sqrt(vec3.x ^ 2 + vec3.y ^ 2 + vec3.z ^ 2)
end

-------------------------------------
-- Returns the relative heading difference between refObject and a given point
-------------------------------------
-- @param point The point for which to check the relative heading
-- @param refObject The reference object against which relative heading should be measured
-- @param format (optional) Return format. Possible formats are "clock" (1 o'clock...) or "cardinal" (NNW...)
-- @return A number in degrees, or a string if a special format was provided
-------------------------------------
function DCSEx.math.getRelativeHeading(point, refObject, format)
    if not point then return nil end
    if not refObject then return nil end

    local unitpos = refObject:getPosition()
    local bearing = DCSEx.math.getBearing(point, unitpos:getPoint())

    local unitBearing = math.atan2(unitpos.x.z, unitpos.x.x)
    if unitBearing < 0 then unitBearing = unitBearing + DCSEx.math.TWO_PI end
    unitBearing = math.floor(unitBearing * (180 / math.pi))

    local relBearing = bearing - unitBearing
    if relBearing < 0 then relBearing = relBearing + 360 end

    if format == "oclock" then
        local oClock = math.floor(relBearing / 30)
        if oClock <= 0 then oClock = 12 end

        return tostring(oClock).." o'clock"
    elseif format == "cardinal" then
        return "TODO" -- TODO: cardinal
    end

    return math.floor(relBearing)
end

-------------------------------------
-- Returns an normalized vec2 from an angle/bearing in radians
-------------------------------------
-- @param unit Angle/bearing in radians
-- @return A normalized vec2
-------------------------------------
function DCSEx.math.getVec2FromAngle(angle)
    return {x = math.cos(angle), y = math.sin(angle)}
end

-------------------------------------
-- Is a point inside a circle?
-------------------------------------
-- @param center The center of the circle, as a vec2
-- @param radius The radius of the circle
-- @param vec2 A vec2
-- @return True if vec2 is inside the circle, false otherwise
-------------------------------------
function DCSEx.math.isPointInsideCircle(center, radius, vec2)
    return (vec2.x - center.x) ^ 2 + (vec2.y - center.y) ^ 2 < radius ^ 2
end

-------------------------------------
-- Is a point inside a polygon?
-------------------------------------
-- @param vec2[] A polygon, as a table of vec2
-- @param vec2 A vec2
-- @return True if vec2 is inside the polygon, false otherwise
-------------------------------------
function DCSEx.math.isPointInsidePolygon(polygon, vec2)
    if not polygon or not vec2 then return false end

    local oddNodes = false
    local j = #polygon
    for i = 1, #polygon do
        if (polygon[i].y < vec2.y and polygon[j].y >= vec2.y or polygon[j].y < vec2.y and polygon[i].y >= vec2.y) then
            if
                (polygon[i].x + (vec2.y - polygon[i].y) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) <
                    vec2.x)
             then
                oddNodes = not oddNodes
            end
        end
        j = i
    end

    return oddNodes
end

-------------------------------------
-- Compares two 2D or 3D points
-------------------------------------
-- @param pointA a Point2 or Point3
-- @param pointB another Point2 or Point3
-- @return True if points are the same, false otherwise
-------------------------------------
function DCSEx.math.isSamePoint(pointA, pointB)
    if pointA.x ~= pointB.x then return false end
    if pointA.y ~= pointB.y then return false end
    if pointA.z or pointB.z then
        if pointA.z ~= pointB.z then return false end
    end

    return true
end

-------------------------------------
-- Linearly interpolates two numbers
-------------------------------------
-- @param val0 Value vers l=0
-- @param val1 Value vers l=1
-- @param t Interpolation between 0 and 1
-- @return A number value
-------------------------------------
function DCSEx.math.lerp(val0, val1, t)
    return val0 + t * (val1 - val0);
end

-------------------------------------
-- Multiplies both the x and y components of a vec2 by a floating-point value
-------------------------------------
-- @param vec2 A vec2
-- @param mult A floating-point value
-- @return A vec2
-------------------------------------
function DCSEx.math.multVec2(vec2, mult)
    return {x = vec2.x * mult, y = vec2.y * mult}
end

-------------------------------------
-- Returns an normalized vec2
-------------------------------------
-- @param unit A vec2
-- @return A normalized vec2
-------------------------------------
function DCSEx.math.normalizeVec2(vec2)
    local length = DCSEx.math.getDistance2D(vec2)
    return {x = vec2.x / length, y = vec2.y / length}
end

-------------------------------------
-- Returns a random boolean
-------------------------------------
-- @return A boolean
-------------------------------------
function DCSEx.math.randomBoolean()
    return DCSEx.math.random(1, 2) == 1
end

-------------------------------------
-- Returns a random floating-point number between min and max
-------------------------------------
-- @param min Minimum floating-point value
-- @param max Maximum floating-point value
-- @return A number
-------------------------------------
function DCSEx.math.randomFloat(min, max)
    if min >= max then return min end
    return min + math.random() * (max - min)
end

-------------------------------------
-- Returns a random vec2 at a given distance of another vec2
-------------------------------------
-- @param point Reference point
-- @param distance Distance from the reference point
-- @return A vec2
-------------------------------------
function DCSEx.math.randomPointAtDistance(point, distance)
    local angle = math.random() * math.pi * 2.0

    local x = point.x + math.cos(angle) * distance
    local y = point.y + math.sin(angle) * distance
    return { x = x, y = y }
end

-------------------------------------
-- Returns a random vec2 in circle of a given center and radius
-------------------------------------
-- @param center Center of the circle as a vec2
-- @param radius Radius of the circle
-- @param minRadius (optional) Minimum inner radius circle in which points should not be spawned
-- @param surfaceType (optional) If not nil, point must be of given surface type
-- @return A vec2 or nil if no point was found
-------------------------------------
function DCSEx.math.randomPointInCircle(center, radius, minRadius, surfaceType)
    local minRadius = minRadius or 0
    local dist = minRadius + math.random() * (radius - minRadius)
    local angle = math.random() * math.pi * 2.0

    local point = nil
    for i=1,36 do
        local x = center.x + math.cos(angle) * dist
        local y = center.y + math.sin(angle) * dist

        point = { x = x, y = y }

        if not surfaceType then return point end
        if land.getSurfaceType(point) == surfaceType then return point end
        angle = angle + 0.174533 -- Increment angle by 10° (in radians)
    end

    return nil
end

-------------------------------------
-- Returns a random sign as a number, -1 or 1
-------------------------------------
-- @return -1 50% of the time, 1 50% of the time
-------------------------------------
function DCSEx.math.randomSign()
    if math.random() < .5 then
        return -1
    end
    return 1
end

-------------------------------------
-- Converts a value to a boolean
-------------------------------------
-- @param val Value to convert
-- @return A boolean, or nil if val was nil
-------------------------------------
function DCSEx.math.toBoolean(val)
    if val == nil then return nil end
    if not val then return false end
    if val == 0 then return false end
    if val:lower() == "false" or val:lower() == "no" or val:lower() == "off" then return false end

    return true
end

-------------------------------------
-- Converts a vec2 to a vec3
-------------------------------------
-- @param vec2 A vec2
-- @param y (Optional) A value for the vec3's y component or "land" to use land height
-- @return A vec3 where v3.x=v2.x, v3.y=y and v3.z=v2.y
-------------------------------------
function DCSEx.math.vec2ToVec3(vec2, y)
    -- Value was already a vec3
    if vec2.z then
        return {x = vec2.x, y = vec2.y, z = vec2.z}
    end

    y = y or 0
    if y == "land" then y = land.getHeight(vec2) end

    return {x = vec2.x, y = y, z = vec2.y}
end

-------------------------------------
-- Converts a vec3 to a vec2
-------------------------------------
-- @param vec3 A vec3
-- @return A vec2 where v2.x=v3.x and v2.y=v3.z
-------------------------------------
function DCSEx.math.vec3ToVec2(vec3)
    -- Value was already a vec2
    if not vec3.z then
        return {x = vec3.x, y = vec3.y}
    end

    return {x = vec3.x, y = vec3.z}
end
