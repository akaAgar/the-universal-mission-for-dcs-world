-- ====================================================================================
-- DCSEX.UNITCALLSIGNMAKER - GENERATES CALLSIGNS FOR NEW UNITS
-- ====================================================================================

DCSEx.unitCallsignMaker = {}

do
    local CALLSIGN_TYPE = {
        DEFAULT = 1,
        A10 = 2,
        AH64 = 3,
        AWACS = 4,
        B1B = 5,
        B52 = 6,
        F15E = 7,
        F16 = 8,
        F18 = 9,
        JTAC = 10,
        TANKER = 11,
        TRANSPORT = 12,
    }

    local CALLSIGNS = {
        [CALLSIGN_TYPE.DEFAULT] = {
            [1] = "Enfield",
            [2] = "Springfield",
            [3] = "Uzi",
            [4] = "Colt",
            [5] = "Dodge",
            [6] = "Ford",
            [7] = "Chevy",
            [8] = "Pontiac",
        },
        [CALLSIGN_TYPE.A10] = {
            [9] = "Hawg",
            [10] = "Boar",
            [11] = "Pig",
            [12] = "Tusk",
        },
        [CALLSIGN_TYPE.AH64] = {
            [9] = "Army Air",
            [10] = "Apache",
            [11] = "Crow",
            [12] = "Sioux",
            [13] = "Gatling",
            [14] = "Gunslinger",
            [15] = "Hammerhead",
            [16] = "Bootleg",
            [17] = "Palehorse",
            [18] = "Carnivor",
            [19] = "Saber",
        },
        [CALLSIGN_TYPE.AWACS] = {
            [1] = "Overlord",
            [2] = "Magic",
            [3] = "Wizard",
            [4] = "Focus",
            [5] = "Darkstar",
        },
        [CALLSIGN_TYPE.B1B] = {
            [9] = "Bone",
            [10] = "Dark",
            [11] = "Vader",
        },
        [CALLSIGN_TYPE.B52] = {
            [9] = "Buff",
            [10] = "Dump",
            [11] = "Kenworth",
        },
        [CALLSIGN_TYPE.F15E] = {
            [9] = "Dude",
            [10] = "Thud",
            [11] = "Gunny",
            [12] = "Trek",
            [13] = "Sniper",
            [14] = "Sled",
            [15] = "Best",
            [16] = "Jazz",
            [17] = "Rage",
            [18] = "Tahoe",
        },
        [CALLSIGN_TYPE.F16] = {
            [9] = "Viper",
            [10] = "Venom",
            [11] = "Lobo",
            [12] = "Cowboy",
            [13] = "Python",
            [14] = "Rattler",
            [15] = "Panther",
            [16] = "Wolf",
            [17] = "Weasel",
            [18] = "Wild",
            [19] = "Ninja",
            [20] = "Jedi",
        },
        [CALLSIGN_TYPE.F18] = {
            [9] = "Hornet",
            [10] = "Squid",
            [11] = "Ragin",
            [12] = "Roman",
            [13] = "Sting",
            [14] = "Jury",
            [15] = "Joker",
            [16] = "Ram",
            [17] = "Hawk",
            [18] = "Devil",
            [19] = "Check",
            [20] = "Snake",
        },
        [CALLSIGN_TYPE.JTAC] = {
            [1] = "Axeman",
            [2] = "Darknight",
            [3] = "Warrior",
            [4] = "Pointer",
            [5] = "Eyeball",
            [6] = "Moonbeam",
            [7] = "Whiplash",
            [8] = "Finger",
            [9] = "Pinpoint",
            [10] = "Ferret",
            [11] = "Shaba",
            [12] = "Playboy",
            [13] = "Hammer",
            [14] = "Jaguar",
            [15] = "Deathstar",
            [16] = "Anvil",
            [17] = "Firefly",
            [18] = "Mantis",
            [19] = "Badger"
        },
        [CALLSIGN_TYPE.TANKER] = {
            [1] = "Texaco",
            [2] = "Arco",
            [3] = "Shell",
        },
        [CALLSIGN_TYPE.TRANSPORT] = {
            [9] = "Heavy",
            [10] = "Trash",
            [11] = "Cargo",
            [12] = "Ascot",
        },
    }

    local currentCallsigns = {}
    for _,i in pairs(CALLSIGN_TYPE) do
        currentCallsigns[i] = { 1, 1, 1, 1, 1, 1, 1, 1, 1 }
    end

    local function getCallsignTypeByUnitType(unitType)
        if not unitType then return CALLSIGN_TYPE.DEFAULT end

        -- TODO: complete
        if unitType == "AH-64A" or unitType == "AH-64D" or unitType == "AH-64D_BLK_II" then return CALLSIGN_TYPE.A10 end
        if unitType == "A-10A" or unitType == "A-10C" or unitType == "A-10C_2" then return CALLSIGN_TYPE.A10 end
        if unitType == "F-15E" or unitType == "F-15ESE" then return CALLSIGN_TYPE.F15E end
        if unitType == "F-16A" or unitType == "F-16A MLU" or unitType == "F-16C bl.50" or unitType == "F-16C bl.52d" or unitType == "F-16C_50" then return CALLSIGN_TYPE.F16 end
        if unitType == "FA-18C" or unitType == "FA-18C_hornet" then return CALLSIGN_TYPE.F18 end
        -- if unitType == "A-50" or unitType == "E-2C" or unitType == "E-3A" then return CALLSIGN_TYPE.AWACS end

        local unitDesc = Unit.getDescByName(unitType)
        if not unitDesc then return CALLSIGN_TYPE.DEFAULT end

        if unitDesc.attributes["AWACS"] then return CALLSIGN_TYPE.AWACS end
        if unitDesc.attributes["Tankers"] then return CALLSIGN_TYPE.TANKER end

        return CALLSIGN_TYPE.DEFAULT
    end

    local function incrementCallsign(callsignName, callsignNumber)
        if not callsignName then return end
        callsignNumber = math.max(1, callsignNumber or 1)

        for k,_ in pairs(CALLSIGNS) do
            for i,_ in pairs(CALLSIGNS[k]) do
                if CALLSIGNS[k][i]:lower() == callsignName:lower() then
                    currentCallsigns[k][i] = math.max(currentCallsigns[k][i], callsignNumber + 1)
                    if (currentCallsigns[k][i] > 9) then currentCallsigns[k][i] = 1 end -- More than 9? Loop back to 1.
                    -- TUM.log("Callsign "..CALLSIGNS[k][i].." set to "..tostring(callsignNumber))
                    return
                end
            end
        end
    end

    function DCSEx.unitCallsignMaker.getCallsign(unitType)
        local csType = getCallsignTypeByUnitType(unitType)

        local csNameIndex = DCSEx.table.getRandom(DCSEx.table.getKeys(CALLSIGNS[csType]))
        if not currentCallsigns[csType][csNameIndex] then currentCallsigns[csType][csNameIndex] = 1 end
        local csNumber = currentCallsigns[csType][csNameIndex]

        currentCallsigns[csType][csNameIndex] = currentCallsigns[csType][csNameIndex] + 1
        if currentCallsigns[csType][csNameIndex] > 9 then currentCallsigns[csType][csNameIndex] = 1 end

        local callsignTable = {
            [1] = csNameIndex,
            [2] = csNumber,
            -- [3] = 1,
            ["name"] = CALLSIGNS[csType][csNameIndex]..tostring(csNumber),
        }

        return callsignTable
    end

    function DCSEx.unitCallsignMaker.getNextGroupCallSign(callsign)
        if not callsign then return nil end
        local callsignName = callsign:sub(1, #callsign - 2):lower()
        local callsignGroupNumber = tonumber(callsign:sub(#callsign - 2, #callsign - 1))
        local callsignUnitNumber = tonumber(callsign:sub(#callsign - 1, #callsign))

        for csType,_ in pairs(CALLSIGNS) do
            for csNameIndex,_ in pairs(CALLSIGNS[csType]) do
                if CALLSIGNS[csType][csNameIndex]:lower() == callsignName then
                    return {
                        [1] = csNameIndex,
                        [2] = callsignGroupNumber,
                        [3] = callsignUnitNumber,
                        ["name"] = CALLSIGNS[csType][csNameIndex]..tostring(callsignGroupNumber),
                    }
                end
            end
        end

        return nil
    end

    do
        local missionGroups = DCSEx.envMission.getGroups()
        for _,g in ipairs(missionGroups) do
            if g.units and g.units[1] then
                local unit = g.units[1]
                if unit.callsign and type(unit.callsign) == "table" and unit.callsign.name then
                    local callsignName = unit.callsign.name:sub(1, #unit.callsign.name - 2)
                    incrementCallsign(callsignName, unit.callsign[2])
                end
            end
        end
    end
end
