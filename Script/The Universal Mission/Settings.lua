-- ====================================================================================
-- TUM.SETTINGS - HANDLES THE MISSION SETTINGS
-- ====================================================================================
-- (enum) TUM.settings.id
-- TUM.settings.getName(id)
-- TUM.settings.getValue(id, returnAsString)
-- TUM.settings.setAllToDefaults()
-- TUM.settings.setValue(id, value, updateMenu)
-- ====================================================================================

TUM.settings = {}

TUM.settings.id = {
    AI_CAP = 1,
    COALITION_BLUE = 2,
    COALITION_RED = 3,
    ENEMY_AIR_DEFENSE = 4,
    ENEMY_AIR_FORCE = 5,
    MULTIPLAYER = 6,
    PLAYER_COALITION = 7,
    TARGET_COUNT = 8,
    TARGET_LOCATION = 9,
    TASKING = 10,
    TIME_PERIOD = 11,
    WINGMEN = 12,
}

do
    local settings = {}

    local SETTING_NAMES = {
        [TUM.settings.id.AI_CAP] = "Friendly AI CAP",
        [TUM.settings.id.COALITION_BLUE] = "Blue coalition",
        [TUM.settings.id.COALITION_RED] = "Red coalition",
        [TUM.settings.id.ENEMY_AIR_DEFENSE] = "Enemy air defense",
        [TUM.settings.id.ENEMY_AIR_FORCE] = "Enemy air force",
        [TUM.settings.id.MULTIPLAYER] = "Multiplayer",
        [TUM.settings.id.PLAYER_COALITION] = "Player coalition",
        [TUM.settings.id.TARGET_COUNT] = "Target count",
        [TUM.settings.id.TARGET_LOCATION] = "Target location",
        [TUM.settings.id.TASKING] = "Mission type",
        [TUM.settings.id.TIME_PERIOD] = "Time period",
        [TUM.settings.id.WINGMEN] = "Wingmen count"
    }

    local SETTING_VALUES = {
        [TUM.settings.id.AI_CAP] = { "Enabled", "Disabled" },
        [TUM.settings.id.COALITION_BLUE] = { },
        [TUM.settings.id.COALITION_RED] = { },
        [TUM.settings.id.ENEMY_AIR_DEFENSE] = { "None", "Green", "Regular", "Veteran", "Elite" },
        [TUM.settings.id.ENEMY_AIR_FORCE] = { "None", "Green", "Regular", "Veteran", "Elite" },
        [TUM.settings.id.PLAYER_COALITION] = { "Red", "Blue" }, -- Must match values in the coalition.side enum
        [TUM.settings.id.TARGET_COUNT] = { "1", "2", "3", "4" },
        [TUM.settings.id.TARGET_LOCATION] = { },
        [TUM.settings.id.TASKING] = { "Antiship strike", "Ground attack", "Helicopter hunt", "Interception", "OCA", "SEAD", "Strike" }, -- Must match values in the DCSEx.enums.taskFamily enum
        [TUM.settings.id.TIME_PERIOD] = { "World War 2", "Korea War", "Vietnam War", "Late Cold War", "Modern" }, -- Must match values in the DCSEx.enums.timePeriod enum
        [TUM.settings.id.WINGMEN] = { "None", "1", "2", "3" }
    }

    local targetLocation

    local function getFaction(side)
        if side == coalition.side.BLUE then
            return TUM.settings.getValue(TUM.settings.id.COALITION_BLUE, true)
        else
            return TUM.settings.getValue(TUM.settings.id.COALITION_RED, true)
        end
    end

    local function setAllToDefaults(coreSettings)
        settings = {
            [TUM.settings.id.AI_CAP] = 1, -- Enabled
            [TUM.settings.id.COALITION_BLUE] = 1,
            [TUM.settings.id.COALITION_RED] = 2,
            [TUM.settings.id.ENEMY_AIR_DEFENSE] = 3,
            [TUM.settings.id.ENEMY_AIR_FORCE] = 2,
            [TUM.settings.id.MULTIPLAYER] = coreSettings.multiplayer,
            [TUM.settings.id.PLAYER_COALITION] = coalition.side.BLUE,
            [TUM.settings.id.TARGET_COUNT] = 2,
            [TUM.settings.id.TARGET_LOCATION] = 1,
            [TUM.settings.id.TASKING] = DCSEx.enums.taskFamily.GROUND_ATTACK,
            [TUM.settings.id.TIME_PERIOD] = DCSEx.enums.timePeriod.MODERN,
            [TUM.settings.id.WINGMEN] = 2
        }

        -- TODO: set default time period according to mission year
        -- if env.mission.date.Year <= 1945 then
        --     settings[TUM.settings.id.TIME_PERIOD] = DCSEx.enums.timePeriod.WORLD_WAR_2
        -- elseif env.mission.date.Year < 1960 then
        --     settings[TUM.settings.id.TIME_PERIOD] = DCSEx.enums.timePeriod.KOREA_WAR
        -- elseif env.mission.date.Year < 1975 then
        --     settings[TUM.settings.id.TIME_PERIOD] = DCSEx.enums.timePeriod.VIETNAM_WAR
        -- elseif env.mission.date.Year < 1990 then
        --     settings[TUM.settings.id.TIME_PERIOD] = DCSEx.enums.timePeriod.COLD_WAR
        -- else
        --     settings[TUM.settings.id.TIME_PERIOD] = DCSEx.enums.timePeriod.MODERN
        -- end

        for i,id in pairs(SETTING_VALUES[TUM.settings.id.COALITION_BLUE]) do
            if id == Library.factions.defaults[coalition.side.BLUE] then settings[TUM.settings.id.COALITION_BLUE] = i end
            if id == Library.factions.defaults[coalition.side.RED] then settings[TUM.settings.id.COALITION_RED] = i end
        end

        if #DCSEx.envMission.getPlayerGroups(coalition.side.RED) > 0 then
            settings[TUM.settings.id.PLAYER_COALITION] = coalition.side.RED
        end
    end

    function TUM.settings.getSettingsName(id)
        return SETTING_NAMES[id]
    end

    function TUM.settings.getPossibleValues(id)
        return SETTING_VALUES[id];
    end

    function TUM.settings.getValue(id, returnAsString)
        returnAsString = returnAsString or false

        if returnAsString then
            return SETTING_VALUES[id][settings[id]]
        end

        return settings[id]
    end

    function TUM.settings.getPlayerCoalition()
        return settings[TUM.settings.id.PLAYER_COALITION]
    end

    function TUM.settings.getEnemyCoalition()
        return DCSEx.dcs.getOppositeCoalition(settings[TUM.settings.id.PLAYER_COALITION])
    end

    function TUM.settings.getPlayerFaction()
        return getFaction(TUM.settings.getPlayerCoalition())
    end

    function TUM.settings.getEnemyFaction()
        return getFaction(TUM.settings.getEnemyCoalition())
    end

    function TUM.settings.getSettingsSummary()
        local showScoreMultiplier = true
        if not DCSEx.io.canReadAndWrite() or TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then
            showScoreMultiplier = false
        end

        local settingsOrder = {
            TUM.settings.id.PLAYER_COALITION,
            TUM.settings.id.MULTIPLAYER,
            -1,
            TUM.settings.id.TIME_PERIOD,
            TUM.settings.id.COALITION_BLUE,
            TUM.settings.id.COALITION_RED,
            -1,
            TUM.settings.id.TASKING,
            TUM.settings.id.TARGET_LOCATION,
            TUM.settings.id.TARGET_COUNT,
            -1,
            TUM.settings.id.ENEMY_AIR_DEFENSE,
            TUM.settings.id.ENEMY_AIR_FORCE,
            -1,
            TUM.settings.id.WINGMEN,
            TUM.settings.id.AI_CAP,
        }

        local summary = ""
        for _,v in pairs(settingsOrder) do
            if v < 0 then
                summary = summary.."\n"
            else
                summary = summary.."\n"..SETTING_NAMES[v]:upper()..": "
                if type(settings[v]) == "boolean" then
                    if settings[v] then
                        summary = summary.."Enabled"
                    else
                        summary = summary.."Disabled"
                    end
                else
                    summary = summary..SETTING_VALUES[v][settings[v]]
                end

                if showScoreMultiplier then
                    local settingMultiplier = TUM.playerScore.getScoreMultiplier(v, settings[v])

                    if settingMultiplier ~= nil then -- Must add "~= nil" because can be 0
                        summary = summary.." ("
                        if settingMultiplier >= 0 then summary = summary.."+" end
                        summary = summary..tostring(math.ceil(settingMultiplier * 100)).."% xp)"
                    end
                end
            end
        end

        if showScoreMultiplier then
            summary = summary.."\n\nTotal XP modifier: "..tostring(math.ceil(TUM.playerScore.getTotalScoreMultiplier() * 100)).."%"
        end

        return summary
    end

    function TUM.settings.printSettingsSummary(clearView)
        trigger.action.outText("MISSION SETTINGS\n"..TUM.settings.getSettingsSummary(), 15, clearView or false)
        trigger.action.outSound("UI-Ok.ogg")
    end

    function TUM.settings.setValue(id, value, silent)
        silent = silent or false

        settings[id] = value

        if not silent then
            TUM.settings.printSettingsSummary(true)
            trigger.action.outSound("UI-Ok.ogg")
        end
    end

    function TUM.settings.onStartUp(coreSettings)
        -- Load mission zones
        SETTING_VALUES[TUM.settings.id.TARGET_LOCATION] = {}
        local missionZones = TUM.territories.getMissionZones()
        for _,m in ipairs(missionZones) do
            table.insert(SETTING_VALUES[TUM.settings.id.TARGET_LOCATION], m.name)
        end

        -- Load available coalitions
        SETTING_VALUES[TUM.settings.id.COALITION_BLUE] = { }
        SETTING_VALUES[TUM.settings.id.COALITION_RED] = { }
        for k,faction in pairs(Library.factions.tables) do
            if not faction.theaters or #faction.theaters == 0 or DCSEx.table.contains(faction.theaters, env.mission.theatre) then
                table.insert(SETTING_VALUES[TUM.settings.id.COALITION_BLUE], k)
                table.insert(SETTING_VALUES[TUM.settings.id.COALITION_RED], k)
            end
        end

        setAllToDefaults(coreSettings)
        TUM.settings.printSettingsSummary()
        return true
    end
end
