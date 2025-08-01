env.setErrorMessageBoxEnabled(true) -- Enable messageboxes for Lua errors

DCSEx = {}
Library = {}
TUM = {}

TUM.VERSION_NUMBER = 1
TUM.VERSION_STRING = "0.1.250722"

TUM.DEBUG_MODE = __DEBUG_MODE__

TUM.logLevel = {
    INFO = 0,
    WARNING = 1,
    ERROR = 2
}

-------------------------------------
-- Prints and logs a debug message
-- @param message The message
-- @param logLevel Is it a warning, error or info messages (as defined in TUM.logLevel). Info messages are not printed out unless debug mode is enabled.
-------------------------------------
function TUM.log(message, logLevel)
    logLevel = logLevel or TUM.logLevel.INFO

    if logLevel == TUM.logLevel.ERROR then
        trigger.action.outText("ERROR: "..message, 3600)
        env.warning("TUM - ERROR: "..message, false)
    elseif logLevel == TUM.logLevel.WARNING then
        trigger.action.outText("WARNING: "..message, 10)
        env.warning("TUM - WARNING: "..message, false)
    else
        if TUM.DEBUG_MODE then -- Info messages are only printed out if debug mode is enabled
            trigger.action.outText(message, 3)
        end

        env.info("TUM: "..message, false)
    end
end

--------------------------------------
--- Administrative settings
--------------------------------------

TUM.administrativeSettings = {
    -- This table defines the administrative settings for the script.
    -- These settings can modify the behavior of the script, and can be set by the mission maker via a specific trigger zone's parameters, or via script (defining the TUM.administrativeSettingsValues below)
    USE_SPECIFIC_RADIOMENU = 1,     -- Use a specific radio menu for the mission commands, or use the main one?
    INITIALIZE_AUTOMATICALLY = 2,   -- Automatically initialize the mission when the script is loaded. If false, you must call TUM.initialize() manually.
    IGNORE_ZONES_STARTINGWITH = 3,  -- If set, ignore all zones starting with this string. This is useful to avoid conflicts with other scripts that use the same zone names.
    ONLY_ZONES_STARTINGWITH = 4,    -- If set, only adds zones starting with this string. This is useful to avoid conflicts with other scripts that use the same zone names.
}

TUM.administrativeSettingsDefaultValues = {
    -- This table defines the default values for the administrative settings.
    -- The keys must match the keys in TUM.administrativeSettings
    [TUM.administrativeSettings.USE_SPECIFIC_RADIOMENU] = false,    -- Use a specific radio menu for the mission commands, or use the main one?
    [TUM.administrativeSettings.INITIALIZE_AUTOMATICALLY] = true,   -- Automatically initialize the mission when the script is loaded. If false, you must call TUM.initialize() manually.
    [TUM.administrativeSettings.IGNORE_ZONES_STARTINGWITH] = nil,   -- If set, ignore all zones starting with this string. This is useful to avoid conflicts with other scripts that use the same zone names.
    [TUM.administrativeSettings.ONLY_ZONES_STARTINGWITH] = nil,     -- If set, only adds zones starting with this string. This is useful to avoid conflicts with other scripts that use the same zone names.
}

TUM.administrativeSettingsValues = {
    -- This table defines the administrative settings values for the script.
    -- The keys must match the keys in TUM.administrativeSettings
    -- If set, these values will prevail over both the default values in TUM.administrativeSettings and the values set by the mission maker via a specific trigger zone's parameters.
}

--- Returns the value of the administrative setting with the given key
function TUM.administrativeSettings.getValue(key)
    if TUM.administrativeSettingsValues[key] ~= nil then
        return TUM.administrativeSettingsValues[key]
    else
        return TUM.administrativeSettingsDefaultValues[key]
    end
end

--- Sets the value of the administrative setting with the given key
function TUM.administrativeSettings.setValue(key, value)
    -- check if the key is in the administrative settings table
    local foundKey = false
    for _, v in pairs(TUM.administrativeSettings) do
        if v == key then
            foundKey = true
            break
        end
    end
    if not foundKey then
        TUM.log("Tried to set an unknown administrative setting: "..tostring(key), TUM.logLevel.ERROR)
        return nil
    end

    TUM.administrativeSettingsValues[key] = value
end

--- Takes all the values from (in order of priority):
---     1. The TUM.administrativeSettingsValues table (optionnaly set by script)
---     2. The trigger zone parameters (set by the mission maker)
---     3. The TUM.administrativeSettingsDefaultValues table (default values)
function TUM.administrativeSettings.initializeSettings()
    local ADMIN_ZONE_NAME = "TUM_Administrative_Settings"  -- The name of the administrative settings trigger zone
    local adminZone = DCSEx.zones.getByName(ADMIN_ZONE_NAME)

    for key, _ in pairs(TUM.administrativeSettings) do
        local value = nil
        if TUM.administrativeSettingsValues[TUM.administrativeSettings[key]] then -- Check if the value is set by script
            value = TUM.administrativeSettingsValues[TUM.administrativeSettings[key]]
        end
        if value == nil and adminZone then -- If the value is not set by script, check the trigger zone parameters
            local zoneValue = DCSEx.zones.getProperty(adminZone, key)
            if zoneValue ~= nil then
                value = zoneValue
            end
        end
        if value == nil then -- If the value is not set by script or trigger zone, use the default value
            value = TUM.administrativeSettingsDefaultValues[TUM.administrativeSettings[key]]
        end
        TUM.administrativeSettingsValues[TUM.administrativeSettings[key]] = value
    end
end

--------------------------------------
--- Radio menu for the mission commands
--------------------------------------
TUM.rootMenu = nil
function TUM.getOrCreateRootMenu(reset) -- Get or create the root menu for the mission commands; if reset is true, the menu will be cleared and recreated
    if reset then
        missionCommands.removeItem(TUM.rootMenu) -- Clear the menu
        TUM.rootMenu = nil
        TUM.getOrCreateRootMenu() -- Recreate the root menu
    end
    if not TUM.rootMenu then
        if TUM.administrativeSettings.getValue(TUM.administrativeSettings.USE_SPECIFIC_RADIOMENU) then
            local rootMenuTitle = "✈ TUM"
            TUM.rootMenu = missionCommands.addSubMenu(rootMenuTitle)
        end
    end
    return TUM.rootMenu
end

--------------------------------------

--[[DCS EXTENSIONS]]--

--[[LIBRARY]]--

--[[THE UNIVERSAL MISSION]]--

--------------------
-- Module startup --
--------------------

function TUM.initialize()
    do
        -- load the administrative settings
        TUM.administrativeSettings.initializeSettings()

        local function startUpMission()
            TUM.hasStarted = false

            local coreSettings = {
                multiplayer = false
            }

            if not net or not net.dostring_in then
                TUM.log("Mission failed to execute. Please copy the provided \"autoexec.cfg\" file to the [Saved Games]\\DCS\\Config directory.\nThe file can be downloaded from github.com/akaAgar/the-universal-mission-for-dcs-world", TUM.logLevel.ERROR)
                return nil
            end

            if #DCSEx.envMission.getPlayerGroups() == 0 then
                TUM.log("No \"Player\" or \"Client\" aircraft slots have been found. Please fix this problem in the mission editor.", TUM.logLevel.ERROR)
                return nil
            end

            if world:getPlayer() then
                coreSettings.multiplayer = false

                if #DCSEx.envMission.getPlayerGroups() > 1 then
                    TUM.log("Multiple players slots have been found in addition to the single-player \"Player\" aircraft. Please fix this problem in the mission editor.", TUM.logLevel.ERROR)
                    return nil
                end
            else
                coreSettings.multiplayer = true

                if #DCSEx.envMission.getPlayerGroups(coalition.side.BLUE) == 0 and #DCSEx.envMission.getPlayerGroups(coalition.side.RED) == 0 then
                    TUM.log("Neither BLUE nor RED coalitions have player slots. Please make sure one coalition has player slots in the mission editor.", TUM.logLevel.ERROR)
                    return nil
                end

                if #DCSEx.envMission.getPlayerGroups(coalition.side.BLUE) > 0 and #DCSEx.envMission.getPlayerGroups(coalition.side.RED) > 0 then
                    TUM.log("Both coalitions have player slots. The Universal Mission is a purely singleplayer/PvE experience and does not support PvP. Please make sure only one coalition has player slots in the mission editor.", TUM.logLevel.ERROR)
                    return nil
                end
            end

            if not TUM.territories.onStartUp() then return nil end
            if not TUM.settings.onStartUp(coreSettings) then return nil end -- Must be called after TUM.territories.onStartUp()
            if not TUM.playerCareer.onStartUp() then return nil end
            if not TUM.intermission.onStartUp() then return nil end
            if not TUM.airForce.onStartUp() then return nil end
            if not TUM.mizCleaner.onStartUp() then return nil end -- Must be called after TUM.settings.onStartUp()

            TUM.hasStarted = true

            return coreSettings
        end

        if not startUpMission() then
            trigger.action.outText("A critical error has happened, cannot start the mission.", 3600)
        end
    end

    -------------------
    -- Event handler --
    -------------------
    do
        local eventHandler = {}

        function eventHandler:onEvent(event)
            if not event then return end -- No event

            TUM.ambientRadio.onEvent(event) -- Must be first so other (more important) radio messages will interrupt the "ambient" ones
            TUM.ambientWorld.onEvent(event)
            TUM.objectives.onEvent(event)
            TUM.playerScore.onEvent(event)
            TUM.mission.onEvent(event)
            TUM.wingmen.onEvent(event)
            TUM.mizCleaner.onEvent(event) -- Must be last, can remove units which could cause bugs in other onEvent methods
        end

        function TUM.onEvent(event)
            eventHandler:onEvent(event)
        end

        if TUM.hasStarted then
            world.addEventHandler(eventHandler)
        end
    end

    --------------------------------------------
    -- Game clock, called every 10-20 seconds --
    --------------------------------------------
    do
        local clockTick = -1

        function TUM.onClockTick(arg, time)
            local nextTickTime = time + math.random(10, 20)
            clockTick = clockTick + 1

            TUM.wingmenTasking.onClockTick() -- No need to check the function return, it's just here to check if wingmen target is still alive

            if clockTick % 4 == 0 then
                if TUM.playerScore.onClockTick() then return nextTickTime end
                if TUM.mission.onClockTick() then return nextTickTime end
            elseif clockTick % 4 == 1 then
                if TUM.airForce.onClockTick(TUM.settings.getPlayerCoalition()) then return nextTickTime end
            elseif clockTick % 4 == 2 then
                if TUM.supportAWACS.onClockTick() then return nextTickTime end
            else
                if TUM.airForce.onClockTick(TUM.settings.getEnemyCoalition()) then return nextTickTime end
            end

            if TUM.wingmenContacts.onClockTick() then return nextTickTime end -- Called every tick if no other action has taken place

            return nextTickTime
        end

        if TUM.hasStarted then
            timer.scheduleFunction(TUM.onClockTick, nil, timer.getTime() + math.random(10, 15))
        end
    end
end

if TUM.administrativeSettings.getValue(TUM.administrativeSettings.INITIALIZE_AUTOMATICALLY) then
    TUM.initialize()
else
    TUM.log("TUM has been loaded, but not initialized. Call TUM.initialize() to start the mission.", TUM.logLevel.INFO)
end