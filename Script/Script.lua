env.setErrorMessageBoxEnabled(true) -- Enable messageboxes for Lua errors

DCSEx = {}
Library = {}
TUM = {}

TUM.VERSION_NUMBER = 1
TUM.VERSION_STRING = "0.1.250722"

TUM.DEBUG_MODE = __DEBUG_MODE__

-------------------------------------
-- Prints and logs a debug message
-- @param message The message
-- @param logLevel Is it a warning, error or info messages (as defined in TUM.logger.logLevel). Info messages are not printed out unless debug mode is enabled.
-------------------------------------

function TUM.log(message, logLevel)
    logLevel = logLevel or TUM.logger.logLevel.INFO
    TUM.logger.print(logLevel, message)
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
        TUM.administrativeSettings.onStartUp() -- load the administrative settings

        local function startUpMission()
            TUM.hasStarted = false

            local coreSettings = {
                multiplayer = false
            }

            if not net or not net.dostring_in then
                TUM.log("Mission failed to execute. Please copy the provided \"autoexec.cfg\" file to the [Saved Games]\\DCS\\Config directory.\nThe file can be downloaded from github.com/akaAgar/the-universal-mission-for-dcs-world", TUM.logger.logLevel.ERROR)
                return nil
            end

            if #DCSEx.envMission.getPlayerGroups() == 0 then
                TUM.log("No \"Client\" aircraft slots have been found. Please fix this problem in the mission editor.", TUM.logger.logLevel.ERROR)
                return nil
            end

            if world:getPlayer() then
                TUM.log("A \"Player\" aircraft slot has been found. The Universal Mission only uses \"Client\" slots, even for single-player missions. Please fix this problem in the mission editor.", TUM.logger.logLevel.ERROR)
                return nil
            end

            coreSettings.multiplayer = (#DCSEx.envMission.getPlayerGroups() > 1)

            if #DCSEx.envMission.getPlayerGroups(coalition.side.BLUE) == 0 and #DCSEx.envMission.getPlayerGroups(coalition.side.RED) == 0 then
                TUM.log("Neither BLUE nor RED coalitions have player slots. Please make sure one coalition has player slots in the mission editor.", TUM.logger.logLevel.ERROR)
                return nil
            end

            if #DCSEx.envMission.getPlayerGroups(coalition.side.BLUE) > 0 and #DCSEx.envMission.getPlayerGroups(coalition.side.RED) > 0 then
                TUM.log("Both coalitions have player slots. The Universal Mission is a purely singleplayer/PvE experience and does not support PvP. Please make sure only one coalition has player slots in the mission editor.", TUM.logger.logLevel.ERROR)
                return nil
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
            TUM.airForce.onEvent(event)
            TUM.ambientWorld.onEvent(event)
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
    TUM.log("TUM has been loaded, but not initialized. Call TUM.initialize() to start the mission.", TUM.logger.logLevel.INFO)
end
