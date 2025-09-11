-- ====================================================================================
-- TUM.RADIO - HANDLES FUNCTIONS TO PLAY RADIO MESSAGES
-- ====================================================================================
-- (const, local) ANSWER_DELAY
-- (local) function doRadioMessage(args, time)
-- TUM.radio.playForAll(messageID, replacements, callsign, delayed, functionToRun, functionParameters)
-- TUM.radio.playForCoalition(coalitionID, messageID, replacements, callsign, delayed, functionToRun, functionParameters)
-- TUM.radio.playForGroup(groupID, messageID, replacements, callsign, delayed, functionToRun, functionParameters)
-- TUM.radio.playForUnit(unitID, messageID, replacements, callsign, delayed, functionToRun, functionParameters)
-- ====================================================================================

TUM.radio = {}

do
    -- Min/max time to get a answer to a radio message, in seconds
    local ANSWER_DELAY = { 3.0, 5.0 }

    -------------------------------------
    -- Executes a radio message
    -- @param args Message parameters
    -- @param time Game time at the moment the message is played
    -------------------------------------
    local function doRadioMessage(args, time)
        if not args or not args.messageID then return nil end

        local callsign = args.callsign
        if not callsign then
            local unit = DCSEx.world.getUnitByID(args.unitID)
            if not unit then
                callsign = "Flight"
            else
                callsign = unit:getCallsign()
            end
        end

        local message = ""
        local oggFile = args.messageID
        if type(Library.radioMessages[args.messageID]) == "table" then
            local index = DCSEx.table.getRandomIndex(Library.radioMessages[args.messageID])
            oggFile = oggFile..tostring(index)
            message = Library.radioMessages[args.messageID][index]
        else
            message = Library.radioMessages[args.messageID]
        end

        if args.replacements then
            for i,r in ipairs(args.replacements) do
                message = message:gsub("$"..tostring(i), tostring(r))
            end
        end
        message = DCSEx.string.firstToUpper(message)

        local duration = DCSEx.string.getReadingTime(message) * args.displayTimeMultiplier

        -- Print message
        trigger.action.outTextForUnit(args.unitID, callsign:upper()..": "..message, duration, false)

        -- Play sound
        trigger.action.outSoundForUnit(args.unitID, "Radio-"..oggFile..".ogg")

        if args.functionToRun then -- a function was provided, run it
            args.functionToRun(args.functionParameters)
        end

        return nil -- disable scheduling, if any
    end

    -------------------------------------
    -- Plays a message to all players in a coalition
    -- @param messageID ID of the radio message in scrambe.db.radioMessages
    -- @param replacements String placeholders ($1, $2...) replacements in the message
    -- @param callsign Name of the person speaking or nil to use unitID's callsign
    -- @param delayed Should the message be delayed (used for message answers)
    -- @param functionToRun Function to run when the message is played
    -- @param functionParameters Parameters for the function to run when the message is played
    -- @param displayTimeMultiplier Multiplier for how long the message should be displayed (2.0=twice as long, 0.5=half as long). Default is 1.0
    -------------------------------------
    function TUM.radio.playForAll(messageID, replacements, callsign, delayed, functionToRun, functionParameters, displayTimeMultiplier)
        local players = DCSEx.world.getAllPlayers()

        for _, unit in pairs(players) do
            TUM.radio.playForUnit(DCSEx.dcs.getObjectIDAsNumber(unit), messageID, replacements, callsign, delayed, functionToRun, functionParameters, displayTimeMultiplier)
        end
    end

    -------------------------------------
    -- Plays a message to all players in a given coalition
    -- @param coalitionID ID of the coalition (coalition.side.XXX)
    -- @param messageID ID of the radio message in scrambe.db.radioMessages
    -- @param replacements String placeholders ($1, $2...) replacements in the message
    -- @param callsign Name of the person speaking or nil to use unitID's callsign
    -- @param delayed Should the message be delayed (used for message answers)
    -- @param functionToRun Function to run when the message is played
    -- @param functionParameters Parameters for the function to run when the message is played
    -- @param displayTimeMultiplier Multiplier for how long the message should be displayed (2.0=twice as long, 0.5=half as long). Default is 1.0
    -------------------------------------
    function TUM.radio.playForCoalition(coalitionID, messageID, replacements, callsign, delayed, functionToRun, functionParameters, displayTimeMultiplier)
        local players = coalition.getPlayers(coalitionID)

        for _,u in pairs(players) do
            TUM.radio.playForUnit(DCSEx.dcs.getObjectIDAsNumber(u), messageID, replacements, callsign, delayed, functionToRun, functionParameters, displayTimeMultiplier)
        end
    end

    -------------------------------------
    -- Plays a message to players from a certain group
    -- @param groupID ID of the group sending/receiving the message
    -- @param messageID ID of the radio message in scrambe.db.radioMessages
    -- @param replacements String placeholders ($1, $2...) replacements in the message
    -- @param callsign Name of the person speaking or nil to use unitID's callsign
    -- @param delayed Should the message be delayed (used for message answers)
    -- @param functionToRun Function to run when the message is played
    -- @param functionParameters Parameters for the function to run when the message is played
    -- @param displayTimeMultiplier Multiplier for how long the message should be displayed (2.0=twice as long, 0.5=half as long). Default is 1.0
    -------------------------------------
    function TUM.radio.playForGroup(groupID, messageID, replacements, callsign, delayed, functionToRun, functionParameters, displayTimeMultiplier)
        local group = DCSEx.world.getGroupByID(groupID)
        if not group then return end -- group does not exist

        for _,u in pairs(group:getUnits()) do
            TUM.radio.playForUnit(DCSEx.dcs.getObjectIDAsNumber(u), messageID, replacements, callsign, delayed, functionToRun, functionParameters, displayTimeMultiplier)
        end
    end

    -------------------------------------
    -- Plays a message for a given unit only
    -- @param unitID ID of the unit receiving the message
    -- @param messageID ID of the radio message in scrambe.db.radioMessages
    -- @param replacements String placeholders ($1, $2...) replacements in the message
    -- @param callsign Name of the person speaking or nil to use unitID's callsign
    -- @param replacements Table of two tables used for string replacements. E.g. { {"UNIT_NAME", "TIME"}, {"Enfield11", "12:30"}}
    -- @param delayed Should the message be delayed (used for message answers)
    -- @param functionToRun Function to run when the message is played
    -- @param functionParameters Parameters for the function to run when the message is played
    -- @param displayTimeMultiplier Multiplier for how long the message should be displayed (2.0=twice as long, 0.5=half as long). Default is 1.0
    -------------------------------------
    function TUM.radio.playForUnit(unitID, messageID, replacements, callsign, delayed, functionToRun, functionParameters, displayTimeMultiplier)
        if not messageID then return end
        if not Library.radioMessages[messageID] then return end
        delayed = delayed or false

        if replacements and type(replacements) ~= "table" then
            replacements = { replacements }
        end

        local radioArgs = {
            callsign = callsign,
            displayTimeMultiplier = math.max(0.1, displayTimeMultiplier or 1.0),
            functionToRun = functionToRun,
            functionParameters = functionParameters,
            messageID = messageID,
            replacements = replacements,
            unitID = unitID
        }

        if delayed then -- message is delayed, schedule it
            timer.scheduleFunction(
                doRadioMessage,
                radioArgs,
                timer.getTime() + DCSEx.math.randomFloat(ANSWER_DELAY[1], ANSWER_DELAY[2])
            )
        else -- no delay, play the message at once
            doRadioMessage(radioArgs, nil)
        end
    end
end
