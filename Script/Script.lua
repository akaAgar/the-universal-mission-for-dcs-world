env.setErrorMessageBoxEnabled(true) -- Enable messageboxes for Lua errors

DCSEx = {}
Library = {}
TUM = {}

TUM.VERSION_NUMBER = 1
TUM.VERSION_STRING = "0.1.250722"

TUM.DEBUG_MODE = __DEBUG_MODE__

--------------------------------------
--- Logging system
--------------------------------------

TUM.logLevel = {
    TRACE = -2,
    DEBUG = -1,
    INFO = 0,
    WARNING = 1,
    ERROR = 2
}

TUM.Logger = {}

function TUM.Logger.splitText(text)
    local tbl = {}
    while text:len() > 4000 do
        local sub = text:sub(1, 4000)
        text = text:sub(4001)
        table.insert(tbl, sub)
    end
    table.insert(tbl, text)
    return tbl
end

function TUM.Logger.formatText(text, ...)
    if not text then
        return ""
    end
    if type(text) ~= 'string' then
        text = TUM.p(text)
    else
        local args = ...
        if args and args.n and args.n > 0 then
            local pArgs = {}
            for i=1,args.n do
                pArgs[i] = TUM.p(args[i])
            end
                text = text:format(unpack(pArgs))
            end
        end
    local fName = nil
    local cLine = nil
    if debug and debug.getinfo then
        local dInfo = debug.getinfo(3)
        fName = dInfo.name
        cLine = dInfo.currentline
        -- local fsrc = dinfo.short_src
        --local fLine = dInfo.linedefined
    end
    if fName and cLine then
        return fName .. '|' .. cLine .. ': ' .. text
    elseif cLine then
        return cLine .. ': ' .. text
    else
        return ' ' .. text
    end
end

function TUM.Logger.print(level, text)
    local texts = TUM.Logger.splitText(text)
    local levelChar = 'E'
    local logFunction = function(messageForLogfile, messageForUser)
        trigger.action.outText("ERROR: "..messageForUser, 3600)
        env.error(messageForLogfile)
    end
    if level == TUM.logLevel.WARNING then
        levelChar = 'W'
        logFunction = function(messageForLogfile, messageForUser)
            trigger.action.outText("WARNING: "..messageForUser, 10)
            env.warning(messageForLogfile)
        end
    elseif level == TUM.logLevel.INFO then
        levelChar = 'I'
        logFunction = function(messageForLogfile, messageForUser)
            if TUM.DEBUG_MODE then -- Info messages are only printed out if debug mode is enabled
                trigger.action.outText(messageForUser, 3)
            end
            env.info(messageForLogfile)
        end
    elseif level == TUM.logLevel.DEBUG then
        levelChar = 'D'
        logFunction = env.info
    elseif level == TUM.logLevel.TRACE then
        levelChar = 'T'
        logFunction = env.info
    end
    for i = 1, #texts do
        if i == 1 then
            local theText =  'TUM|' .. levelChar .. '|' .. texts[i]
            logFunction(theText, texts[i])
        else
            local theText = texts[i]
            logFunction(theText, theText)
        end
    end
end

function TUM.Logger.error(text, ...)
    text = TUM.Logger.formatText(text, arg)
    local mText = text
    if debug and debug.traceback then
        mText = mText .. "\n" .. debug.traceback()
    end
    TUM.Logger.print(TUM.logLevel.ERROR, mText)
end

function TUM.Logger.warn(text, ...)
    text = TUM.Logger.formatText(text, arg)
    TUM.Logger.print(TUM.logLevel.WARNING, text)
end

function TUM.Logger.info(text, ...)
    text = TUM.Logger.formatText(text, arg)
    TUM.Logger.print(TUM.logLevel.INFO, text)
end

function TUM.Logger.debug(text, ...)
    if TUM.DEBUG_MODE then
        text = TUM.Logger.formatText(text, arg)
        TUM.Logger.print(TUM.logLevel.DEBUG, text)
    end
end

function TUM.Logger.trace(text, ...)
    if TUM.DEBUG_MODE then
        text = TUM.Logger.formatText(text, arg)
        TUM.Logger.print(TUM.logLevel.TRACE, text)
    end
end

-------------------------------------
-- Prints and logs a debug message
-- @param message The message
-- @param logLevel Is it a warning, error or info messages (as defined in TUM.logLevel). Info messages are not printed out unless debug mode is enabled.
-------------------------------------

function TUM.log(message, logLevel)
    logLevel = logLevel or TUM.logLevel.INFO
    TUM.Logger.print(logLevel, message)
end

--[[DCS EXTENSIONS]]--

--[[LIBRARY]]--

--[[THE UNIVERSAL MISSION]]--

--------------------
-- Module startup --
--------------------

do
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
