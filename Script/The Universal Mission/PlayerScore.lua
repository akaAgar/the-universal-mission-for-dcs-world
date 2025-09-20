-- ====================================================================================
-- TUM.PLAYERSCORE - HANDLES ALL SCORING DURING SINGLE-PLAYER MISSIONS
-- ====================================================================================
-- (const) SKILL_MULTIPLIER_BONUS
-- (const) SCORE_REMINDER_INTERVAL
-- (local) getKillValue(killedObject)
-- (local) onKillEvent(event)
-- (local) onLandEvent(event)
-- (local) onResetEvent(event)
-- (local) printReminder()
-- TUM.playerScore.award(amount, message, silent)
-- TUM.playerScore.getCompletedObjectives()
-- TUM.playerScore.getScore()
-- TUM.playerScore.getScoreMultiplier(settingID, settingValue)
-- TUM.playerScore.getTotalScoreMultiplier()
-- TUM.playerScore.onClockTick(clockTick)
-- TUM.playerScore.onEvent(event)
-- TUM.playerScore.reset(showMessage, reason)
-- TUM.playerScore.showScore()
-- ====================================================================================

TUM.playerScore = {}

do
    local ENEMY_DEFENSE_MULTIPLIER_BONUS = { -0.1, 0.1, 0.3, 0.5, 0.7 }

    local SCORE_REMINDER_INTERVAL = 5 -- in minutes

    local completedObjectives = 0
    local score = 0
    local scoreReminderIntervalLeft = SCORE_REMINDER_INTERVAL

    local function getKillValue(killedObject)
        if not killedObject then return 0 end

        if Object.getCategory(killedObject) == Object.Category.BASE then return 60 end
        if Object.getCategory(killedObject) == Object.Category.STATIC then return 60 end
        if Object.getCategory(killedObject) == Object.Category.SCENERY then
            for i=1,TUM.objectives.getCount() do
                local obj = TUM.objectives.getObjective(i)
                if obj then
                    if obj.isSceneryTarget then
                        if DCSEx.math.isSamePoint(killedObject:getPoint(), obj.point3) then
                            return 60
                        end
                    end
                end
            end

            return 0
        end
        if Object.getCategory(killedObject) ~= Object.Category.UNIT then return 0 end

        local objectDesc = killedObject:getDesc()
        if not objectDesc or not objectDesc.attributes then return 10 end -- No description, assume a default value of 10 points

        local groundMultiplier = 1
        if not killedObject:inAir() then
            -- Aircraft killed on the ground are worth less points, except AWACS, bombers and transports
            if not objectDesc.attributes["AWACS"] and not objectDesc.attributes["Transports"] and not objectDesc.attributes["Strategic bombers"] then
                groundMultiplier = 0.5
            end
        end

        -- Misc
        if objectDesc.attributes["Missiles"] then return 10 end
        if objectDesc.attributes["UAVs"] then return math.floor(15 * groundMultiplier) end

        -- Fixed wing
        if objectDesc.attributes["Fighters"] then return math.floor(40 * groundMultiplier) end
        if objectDesc.attributes["Interceptors"] then return math.floor(40 * groundMultiplier) end
        if objectDesc.attributes["Interceptors"] then return math.floor(40 * groundMultiplier) end
        if objectDesc.attributes["Planes"] then return math.floor(25 * groundMultiplier) end

        -- Rotary wing
        if objectDesc.attributes["Attack helicopters"] then return math.floor(25 * groundMultiplier) end
        if objectDesc.attributes["Helicopters"] then return math.floor(15 * groundMultiplier) end

        -- Default air
        if objectDesc.attributes["Air"] then return math.floor(20 * groundMultiplier) end

        -- Ships
        if objectDesc.attributes["Aircraft Carriers"] then return 300 end
        if objectDesc.attributes["Cruisers"] then return 250 end
        if objectDesc.attributes["Destroyers"] then return 150 end
        if objectDesc.attributes["Frigates"] then return 150 end
        if objectDesc.attributes["Corvettes"] then return 100 end
        if objectDesc.attributes["Heavy armed ships"] then return 75 end
        if objectDesc.attributes["Ships"] then return 25 end

        -- Air defense
        if objectDesc.attributes["MANPADS AUX"] then return 5 end
        if objectDesc.attributes["MANPADS"] then return 10 end
        if objectDesc.attributes["SR SAM"] then return 20 end
        if objectDesc.attributes["IR Guided SAM"] then return 15 end
        if objectDesc.attributes["SAM TR"] then return 25 end
        if objectDesc.attributes["SAM SR"] then return 15 end
        if objectDesc.attributes["Armed Air Defence"] then return 10 end
        if objectDesc.attributes["SAM elements"] then return 5 end
        if objectDesc.attributes["SAM related"] then return 5 end

        -- Ground vehicles
        if objectDesc.attributes["Modern Tanks"] then return 20 end
        if objectDesc.attributes["Tanks"] then return 15 end
        if objectDesc.attributes["Modern Tanks"] then return 25 end
        if objectDesc.attributes["HeavyArmoredUnits"] then return 20 end
        if objectDesc.attributes["LightArmoredUnits"] then return 15 end
        if objectDesc.attributes["NonArmoredUnits"] then return 10 end
        if objectDesc.attributes["Unarmed vehicles"] then return 10 end

        -- Infantry
        if objectDesc.attributes["Infantry"] then return 3 end

        return 10 -- Don't know what this thing is, assume a default value of 10 points
    end

    -------------------------------------
    -- Called by TUM.playerScore.onEvent when a KILL event is triggered
    -- @param event The DCS World event
    -------------------------------------
    local function onKillEvent(event)
        if not event.target then return end
        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end
        if not event.initiator:getPlayerName() then return end

        local killValue = getKillValue(event.target)
        if killValue <= 0 then return end

        -- Higher reward for higher threat levels
        local scoreMultiplier = TUM.playerScore.getTotalScoreMultiplier()
        killValue = math.max(1, math.floor(killValue * scoreMultiplier))

        -- Penalty for destroying friendly or civilian units
        local prefix = ""
        if Object.getCategory(event.target) == Object.Category.UNIT then
            if event.initiator:getCoalition() == event.target:getCoalition() then
                prefix = "friendly "
                killValue = killValue * -5.0
            elseif event.target:getCoalition() == coalition.side.NEUTRAL then
                prefix = "neutral "
                killValue = killValue * -2.0
            end
        end

        TUM.playerScore.award(killValue, "destroyed "..prefix..Library.objectNames.get(event.target))
    end

    -------------------------------------
    -- Called by TUM.playerScore.onEvent when a LAND event is triggered
    -- @param event The DCS World event
    -------------------------------------
    local function onLandEvent(event)
        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end
        if not event.initiator:getPlayerName() then return end

        local muteRadioMessage = false
        if score > 0 or completedObjectives > 0 then
            muteRadioMessage = TUM.playerCareer.awardScore(score, completedObjectives)
        end

        -- Single-player landing radio message is handled here instead of in AmbientRadio to avoid
        -- "conflicts" with the "awardScore" message if both the medal case and the radio message are
        -- triggered at the same time (delaying the radio message wouldn't be a solution as this would
        -- interrupt the medal case music very quickly)
        if not muteRadioMessage then
            local baseName = "AIRBASE"
            if event.place then
                baseName = event.place:getName():upper()
            end

            TUM.radio.playForAll("atcSafeLandingPlayer", {event.initiator:getCallsign(), baseName}, baseName.." ATC")
        end
    end

    -------------------------------------
    -- Called by TUM.playerScore.onEvent when any event causing a score reset (crash, ejection, slot change...) is triggered
    -- @param event The DCS World event
    -------------------------------------
    local function onResetEvent(event)
        if not event.initiator:getPlayerName() then return end

        local reason = nil
        if event.id == world.event.S_EVENT_CRASH then
            reason = "you crashed"
        elseif event.id == world.event.S_EVENT_PILOT_DEAD then
            reason = "you were killed"
        elseif event.id == world.event.S_EVENT_EJECTION then
            reason = "you ejected"
        elseif event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
            reason = "you've taken control of a new aircraft"
        end

        TUM.playerScore.reset(true, reason)
    end

    -------------------------------------
    -- Print a reminder that the player has to land for their current score and completed objectives to be added to their flight profile
    -- @return True if a reminded was printed, false if it was not needed (no score to award, etc)
    -------------------------------------
    local function printReminder()
        if score <= 0 and completedObjectives <= 0 then return false end -- Nothing to remind the player of

        local msg = ""
        if score > 0 and completedObjectives > 0 then
            msg = string.format("You've been awarded %s point(s) and have completed %d objective(s).", DCSEx.string.toStringThousandsSeparator(score), completedObjectives)
        elseif score > 0 then
            msg = string.format("You've been awarded %s point(s).", DCSEx.string.toStringThousandsSeparator(score))
        else
            msg = string.format("You have completed %d objective(s).", completedObjectives)
        end

        trigger.action.outText("[REMINDER] "..msg.." All progress will be recorded to your flight log upon landing.", 5)
        trigger.action.outSound("UI-Ok.ogg")
        return true
    end

    -------------------------------------
    -- Awards points to the player. Only works in single-player missions
    -- @param amount Number of points to award
    -- @param message Message to display (why are these points awarded?). If missing, no message will be displayed.
    -------------------------------------
    function TUM.playerScore.award(amount, message)
        if not DCSEx.io.canReadAndWrite() then return end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No scoring in multiplayer

        score = score + amount

        if message then
            TUM.log("Awarded "..DCSEx.string.toStringThousandsSeparator(amount).." points ("..message..").")
        end
    end

    -------------------------------------
    -- Awards a new completed objective to the player. Only works in single-player missions
    -------------------------------------
    function TUM.playerScore.awardCompletedObjective()
        if not DCSEx.io.canReadAndWrite() then return end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No scoring in multiplayer

        completedObjectives = completedObjectives + 1
    end

    -------------------------------------
    -- Returns the current number of completed objectives. Only works in single-player missions
    -- @return A number
    -------------------------------------
    function TUM.playerScore.getCompletedObjectives()
        if not DCSEx.io.canReadAndWrite() then return 0 end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return 0 end -- No scoring in multiplayer

        return completedObjectives
    end

    -------------------------------------
    -- Returns the current player score. Only works in single-player missions
    -- @return A number
    -------------------------------------
    function TUM.playerScore.getScore()
        if not DCSEx.io.canReadAndWrite() then return 0 end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return 0 end -- No scoring in multiplayer

        return score
    end

    -------------------------------------
    -- Returns the value to add to the global score multiplier according to a given setting
    -- @param settingID ID of the setting (from the TUM.settings.id enum)
    -- @param settingValue The setting value, or nil to use the current value
    -- @return A number in the -1.0 to +1.0 range, or nil if this setting has no effect on XP gains
    -------------------------------------
    function TUM.playerScore.getScoreMultiplier(settingID, settingValue)
        if not DCSEx.io.canReadAndWrite() then return 0 end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return 0 end -- No scoring in multiplayer

        settingValue = TUM.settings.getValue(settingID)

        if settingID == TUM.settings.id.ENEMY_AIR_DEFENSE or settingID == TUM.settings.id.ENEMY_AIR_FORCE then
            return ENEMY_DEFENSE_MULTIPLIER_BONUS[settingValue]
        elseif settingID == TUM.settings.id.WINGMEN then
            return 0 - 0.10 * (settingValue - 1)
        elseif settingID == TUM.settings.id.TARGET_LOCATION then
            local zoneName = TUM.settings.getValue(TUM.settings.id.TARGET_LOCATION, true)
            local tgtZone = DCSEx.zones.getByName(zoneName)
            if not tgtZone then return 0 end
            if TUM.territories.getPointOwner(tgtZone) == TUM.settings.getEnemyCoalition() then return 0.3 end
            return 0
        elseif settingID == TUM.settings.id.AI_CAP then
            if settingValue == 2 and TUM.settings.getValue(TUM.settings.id.ENEMY_AIR_FORCE) > 1 then return 0.15 end
            return 0
        end

        return nil
    end

    -------------------------------------
    -- Returns the global score multiplier according the current settings
    -- @return A number (where 1.0 means default value, 0.5 is -50%, etc)
    -------------------------------------
    function TUM.playerScore.getTotalScoreMultiplier()
        if not DCSEx.io.canReadAndWrite() then return 1.0 end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return 1.0 end -- No scoring in multiplayer

        local scoreMultiplier = 1.0
        for _,v in pairs(TUM.settings.id) do
            scoreMultiplier = scoreMultiplier + (TUM.playerScore.getScoreMultiplier(v) or 0.0)
        end

        return math.max(0.0, scoreMultiplier)
    end

    ----------------------------------------------------------
    -- Called on every mission update tick (every 10-20 seconds)
    -- @return True if something was done this tick, false otherwise
    ----------------------------------------------------------    
    function TUM.playerScore.onClockTick()
        if not DCSEx.io.canReadAndWrite() then return false end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return false end -- No scoring in multiplayer
        if score == 0 and completedObjectives == 0 then return false end -- Nothing to remind the player of

        scoreReminderIntervalLeft = scoreReminderIntervalLeft - 1
        if scoreReminderIntervalLeft == 0 then
            scoreReminderIntervalLeft = SCORE_REMINDER_INTERVAL
            return printReminder()
        end

        return false
    end

    -------------------------------------
    -- Called when an event is raised
    -- @param event The DCS World event
    -------------------------------------
    function TUM.playerScore.onEvent(event)
        if not event.initiator then return end
        if not DCSEx.io.canReadAndWrite() then return end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No scoring in multiplayer

        if event.id == world.event.S_EVENT_KILL then
            onKillEvent(event)
            return
        end

        if event.id == world.event.S_EVENT_LAND and event.place then
            onLandEvent(event)
            return
        end

        if event.id == world.event.S_EVENT_CRASH or event.id == world.event.S_EVENT_PILOT_DEAD or event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT or event.id == world.event.S_EVENT_EJECTION then
            onResetEvent(event)
            return
        end
    end

    -------------------------------------
    -- Resets the player score to 0
    -- @param showMessage Should a message be displayed (if any points are lost)?
    -- @param reason The reason for the point loss, displayed in the message
    -------------------------------------
    function TUM.playerScore.reset(showMessage, reason)
        if completedObjectives == 0 and score == 0 then return end

        if not DCSEx.io.canReadAndWrite() then return end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No scoring in multiplayer

        if showMessage then
            local msg = ""

            if reason then
                msg = "Unstowed progress lost because "..reason.."."
            else
                msg = "Unstowed progress lost."
            end

            msg = msg.." You lost "..DCSEx.string.toStringThousandsSeparator(score).." xp and "..tostring(completedObjectives).." completed objective(s)."
            trigger.action.outText(msg, 5)
            trigger.action.outSound("UI-Error.ogg")
        else
            TUM.log("Mission score reset.")
        end

        completedObjectives = 0
        score = 0
    end

    -------------------------------------
    -- Shows the current mission score
    -------------------------------------
    function TUM.playerScore.showScore()
        if not DCSEx.io.canReadAndWrite() then return end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No scoring in multiplayer

        local scoreMsg = "CURRENT PROGRESS (will be awarded to your career profile on landing):\n"
        scoreMsg = scoreMsg.."XP: "..DCSEx.string.toStringThousandsSeparator(score).."\n"
        scoreMsg = scoreMsg.."Completed objectives: "..tostring(completedObjectives)

        trigger.action.outText(scoreMsg, 5)
        trigger.action.outSound("UI-Ok.ogg")
    end
end
