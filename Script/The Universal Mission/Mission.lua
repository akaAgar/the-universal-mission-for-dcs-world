-- ====================================================================================
-- TUM.MISSION - HANDLES THE MAIN MISSION
-- ====================================================================================
-- ====================================================================================

TUM.mission = {}

TUM.mission.status = {
    NONE = 0,
    IN_PROGRESS = 1,
    COMPLETED = 2,
    FAILED = 3,
}

TUM.mission.endCause = { -- Why did the mission end?
    ABORTED = 1,
    COMPLETED = 2,
    FAILED = 3
}

do
    local OBJECTIVES_REMINDER_INTERVAL = 5
    local missionStatus = TUM.mission.status.NONE
    local objectivesReminderIntervalLeft = OBJECTIVES_REMINDER_INTERVAL

    function TUM.mission.getStatus()
        return missionStatus
    end

    local function closeMission(removeAllUnits)
        if removeAllUnits then
            TUM.wingmen.removeAll()
            TUM.airForce.removeAll()
            TUM.ambientWorld.removeAll()
            TUM.enemyAirDefense.removeAll()
            TUM.objectives.removeAll()
        end

        missionStatus = TUM.mission.status.NONE
        TUM.intermission.createMenu()
    end

    function TUM.mission.checkMissionStatus(silent)
        silent = silent or false
        if missionStatus ~= TUM.mission.status.IN_PROGRESS then return end

        if TUM.objectives.areAllCompleted() then
            missionStatus = TUM.mission.status.COMPLETED

            DCSEx.dcs.outPicture("Pic-MissionComplete.png", 5, true, 0, 1, 1, 25, 1)
            trigger.action.outSound("UI-MissionEnd.ogg")

            if not silent then
                TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "commandMissionComplete", nil, "Command", true)
            end
        end
    end

    function TUM.mission.beginMission(silent)
        silent = silent or false

        closeMission(true)
        TUM.intermission.removeMissionZonesMarkers()

        for _=1,TUM.settings.getValue(TUM.settings.id.TARGET_COUNT) do
            TUM.objectives.add()
        end

        if TUM.objectives.getCount() == 0 then
            TUM.log("Couldn't create any objective, mission creation failed.", TUM.logger.logLevel.WARNING)
            closeMission(true)
            return
        end

        TUM.supportAWACS.create() -- Create the AWACS aircraft if it wasn't airborne already
        TUM.enemyAirDefense.create() -- Must be called once objectives have been created
        TUM.airForce.create() -- Must be called once objectives have been created
        TUM.missionMenu.create() -- Must be called once objectives have been created

        local briefingOrder = DCSEx.table.shuffle({1, 2, 3, 4, 5}) -- Just to make sure the same description is used twice

        local briefingText = ""
        for i=1,TUM.objectives.getCount() do
            local obj = TUM.objectives.getObjective(i)
            briefingText = briefingText.."Objective "..obj.name..":\n"
            local descriptions = Library.tasks[obj.taskID].description.briefing

            briefingText = briefingText..descriptions[DCSEx.math.clamp(briefingOrder[i], 1, #descriptions)]
            if i < TUM.objectives.getCount() then
                briefingText = briefingText.."\n\n"
            end
        end

        DCSEx.envMission.setBriefing(TUM.settings.getPlayerCoalition(), briefingText)
        DCSEx.envMission.setBriefing(TUM.settings.getEnemyCoalition(), "")

        missionStatus = TUM.mission.status.IN_PROGRESS

        if not silent then
            DCSEx.dcs.outPicture("Pic-MissionStart.png", 5, true, 0, 1, 1, 25, 1)
            trigger.action.outSound("UI-MissionStart.ogg")
        end

        trigger.action.outText("MISSION OBJECTIVES:\n\n"..TUM.mission.getSummaryString(), 10)

        objectivesReminderIntervalLeft = OBJECTIVES_REMINDER_INTERVAL
    end

    function TUM.mission.getPlayerCallsign()
        local player = DCSEx.world.getFirstPlayer(TUM.settings.getPlayerCoalition())
        if player then return player:getCallsign() end
        return "Flight"
    end

    function TUM.mission.getSummaryString(onlyShowIncomplete, doublePercentage)
        onlyShowIncomplete = onlyShowIncomplete or false
        if missionStatus == TUM.mission.status.NONE then return "" end

        local missionSummary = ""
        local validObjCount = 1
        for i=1,TUM.objectives.getCount() do
            local o = TUM.objectives.getObjective(i)

            if o then
                if not o.completed or not onlyShowIncomplete then
                    local bulletCharacter = "⬤"
                    if validObjCount == 1 then bulletCharacter = "❶"
                    elseif validObjCount == 2 then bulletCharacter = "❷"
                    elseif validObjCount == 3 then bulletCharacter = "❸"
                    elseif validObjCount == 4 then bulletCharacter = "❹"
                    elseif validObjCount == 5 then bulletCharacter = "❺"
                    elseif validObjCount == 6 then bulletCharacter = "❻"
                    elseif validObjCount == 7 then bulletCharacter = "❼"
                    elseif validObjCount == 8 then bulletCharacter = "❽"
                    elseif validObjCount == 9 then bulletCharacter = "❾"
                    elseif validObjCount == 10 then bulletCharacter = "❿"
                    end

                    missionSummary = missionSummary..bulletCharacter.." Objective "..o.name..": "..Library.tasks[o.taskID].description.short
                    if not o.completed then
                        missionSummary = missionSummary.." ("..TUM.objectives.getObjectiveProgress(i, doublePercentage)..")"
                    else
                        missionSummary = missionSummary.." [DONE!]"
                    end

                    if i < TUM.objectives.getCount() then
                        missionSummary = missionSummary.."\n"
                    end

                    validObjCount = validObjCount + 1
                end
            end
        end

        return missionSummary
    end

    function TUM.mission.endMission(endCause)
        endCause = endCause or TUM.mission.endCause.ABORTED

        if endCause == TUM.mission.endCause.ABORTED then
            DCSEx.dcs.outPicture("Pic-MissionAborted.png", 5, true, 0, 1, 1, 25, 1)
            TUM.playerScore.reset(true, "mission aborted")
        elseif endCause == TUM.mission.endCause.COMPLETED then
            DCSEx.dcs.outPicture("Pic-MissionComplete.png", 5, true, 0, 1, 1, 25, 1)
        elseif endCause == TUM.mission.endCause.FAILED then
            DCSEx.dcs.outPicture("Pic-MissionFailed.png", 5, true, 0, 1, 1, 25, 1)
        end
        trigger.action.outSound("UI-MissionEnd.ogg")

        closeMission(true)
    end

    ----------------------------------------------------------
    -- Called on every mission update tick (every 15 seconds)
    -- @return True if a radio message or other output was triggered, false otherwise
    ----------------------------------------------------------
    function TUM.mission.onClockTick()
        if TUM.mission.getStatus() == TUM.mission.status.NONE then return false end -- Not currenly in a mission
        if TUM.objectives.getCount() <= 0 then return false end -- No objectives

        objectivesReminderIntervalLeft = objectivesReminderIntervalLeft - 1
        if objectivesReminderIntervalLeft > 0 then return false end

        objectivesReminderIntervalLeft = OBJECTIVES_REMINDER_INTERVAL

        TUM.mission.playMissionSummaryRadioMessage(true, false)
        return true
    end

    -------------------------------------
    -- Called when an event is raised
    -- @param event The DCS World event
    -------------------------------------
    function TUM.mission.onEvent(event)
        if not event.initiator then return end
        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end -- Initiator is not an unit
        if not event.initiator:getPlayerName() then return end -- Initiator is not a player

        -- Start mission (it wasn't started yet) when all players have taken off
        if event.id == world.event.S_EVENT_TAKEOFF then
            if missionStatus == TUM.mission.status.NONE and #DCSEx.world.getPlayersOnGround(TUM.settings.getPlayerCoalition()) == 0 then
                TUM.intermission.doCommandStartMission(true)
                -- Force wingman spawning because the "on player takeoff spawn wingman" function won't be called as mission wasn't started yet when the "take off" even was raised
                timer.scheduleFunction(TUM.wingmen.create, nil, timer.getTime() + 3)
            end
        end

        if missionStatus == TUM.mission.status.NONE then return end

        -- All objectives complete and all players on the ground? Mission is complete
        if event.id == world.event.S_EVENT_RUNWAY_TOUCH or event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT or event.id == world.event.S_EVENT_PLAYER_LEAVE_UNIT then
            if TUM.objectives.areAllCompleted() and #DCSEx.world.getPlayersInAir(TUM.settings.getPlayerCoalition()) == 0 then
                TUM.mission.endMission(TUM.mission.endCause.COMPLETED)
            end
        end

        -- When the player dies in single-player, remind them that they can respawn
        -- (because no one knows the "respawn" shortcut key in DCS and it's not possible to respawn by
        -- changing slots when there's only one)
        if not TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then
            if event.id == world.event.S_EVENT_CRASH or event.id == world.event.S_EVENT_EJECTION or event.id == world.event.S_EVENT_PILOT_DEAD then
                -- TUM.mission.endMission(TUM.mission.endCause.FAILED)
                trigger.action.outText("Your aircraft has been downed.\nPress Right CTRL+Right Shift+Tab (default) to respawn.", 10)
            end
        end
    end

    function TUM.mission.playMissionSummaryRadioMessage(onlyShowIncomplete, delayed)
        onlyShowIncomplete = onlyShowIncomplete or false
        delayed = delayed or false

        local incompleteObjectives = TUM.objectives.getCount() - TUM.objectives.getCompletedCount()

        local messageID = "commandMissionComplete"
        if incompleteObjectives > 1 then
            messageID = "commandObjectivesManyLeft"
        elseif incompleteObjectives == 1 then
            messageID = "commandObjectivesOneLeft"
        end

        TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), messageID, { TUM.mission.getSummaryString(onlyShowIncomplete, true) }, "COMMAND", delayed)
    end
end