-- ====================================================================================
-- DCSEX.ENUMS - VARIOUS ENUMS
-- ====================================================================================
-- DCSEx.enums.lineType
-- DCSEx.enums.taskEvent
-- DCSEx.enums.taskFamily
-- DCSEx.enums.taskFlag
-- DCSEx.enums.timePeriod
-- DCSEx.enums.unitFamily
-- DCSEx.enums.victoryCondition
-- ====================================================================================

DCSEx.enums = {}

-------------------------------------
-- Line types for map markers. This enum is missing from DCS
-------------------------------------
DCSEx.enums.lineType = {
    NO_LINE = 0,
    SOLID = 1,
    DASHED = 2,
    DOTTED = 3,
    DOT_DASH = 4,
    LONG_DASH = 5,
    TWO_DASH = 6,
}

-------------------------------------
-- Event to check to see if a task/objective is complete
-------------------------------------
DCSEx.enums.taskEvent = {
    DESTROY = 1,
    DESTROY_SCENERY = 2,
    LAND = 3,
}

-------------------------------------
-- Families of mission tasks
-------------------------------------
DCSEx.enums.taskFamily = {
    ANTISHIP = 1,
    -- CAP = 2, -- TODO
    -- CAS = 3, -- TODO
    GROUND_ATTACK = 2, -- 4
    -- HELICOPTER = XXX, -- 5
    -- HELO_HUNT = XXX, -- 6
    INTERCEPTION = 3, -- 7
    -- OCA = XXX, -- 8
    SEAD = 4, --9
    STRIKE = 5, -- 10
}

-------------------------------------
-- Special events for tasks
-------------------------------------
DCSEx.enums.taskFlag = {
    AIRBASE_TARGET = 1,
    ALLOW_JTAC = 2,
    DESTROY_TRACK_RADARS_ONLY = 3,
    MOVING = 4,
    ON_ROADS = 5,
    PARKED_AIRCRAFT_TARGET = 6,
    SCENERY_TARGET = 7,
}

-------------------------------------
-- Enumerates the various time periods during which DCS World missions can take place
-------------------------------------
DCSEx.enums.timePeriod = {
    WORLD_WAR_2 = 1,
    KOREA_WAR = 2,
    VIETNAM_WAR = 3,
    COLD_WAR = 4,
    MODERN = 5
}

-------------------------------------
-- Type of unit families. Hundreds digit must match the value in the Unit.Category enum
-------------------------------------
DCSEx.enums.unitFamily = {
    AIRDEFENSE_MANPADS = 251,
    AIRDEFENSE_AAA_MOBILE = 252,
    AIRDEFENSE_AAA_STATIC = 253,
    AIRDEFENSE_SAM_LONG = 254,
    AIRDEFENSE_SAM_MEDIUM = 255,
    AIRDEFENSE_SAM_SHORT = 256,
    AIRDEFENSE_SAM_SHORT_IR = 257,

    PLANE_ATTACK = 001,
    PLANE_AWACS = 002,
    PLANE_BOMBER = 003,
    PLANE_FIGHTER = 004,
    PLANE_INTERCEPTOR = 005,
    PLANE_TANKER = 006,
    PLANE_TRANSPORT = 007,
    PLANE_UAV = 008,

    GROUND_APC = 201,
    GROUND_ARTILLERY = 202,
    GROUND_INFANTRY = 203,
    GROUND_MBT = 204,
    GROUND_SS_MISSILE = 205,
    GROUND_UNARMED = 206,

    HELICOPTER_ATTACK = 101,
    HELICOPTER_TRANSPORT = 102,

    SHIP_CARGO = 301,
    SHIP_CARRIER = 302,
    SHIP_CRUISER = 303,
    SHIP_FRIGATE = 304,
    SHIP_LIGHT = 305,
    SHIP_MISSILE_BOAT = 306,
    SHIP_SUBMARINE = 307,

    STATIC_SCENERY = 401,
    STATIC_STRUCTURE = 402
}

-------------------------------------
-- Victory conditions for tasks/objectives
-------------------------------------
DCSEx.enums.victoryCondition = {
    DESTROY = 1,
    DESTROY_NO_AIR_DEFENSE = 2,
    DESTROY_SCENERY = 3,
    DESTROY_TRACK_RADARS_ONLY = 4, -- for SEAD tasks
    LAND_NEAR = 5
}
