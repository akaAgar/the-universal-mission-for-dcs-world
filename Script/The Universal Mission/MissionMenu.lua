-- ====================================================================================
-- TUM.MISSION - HANDLES THE F10 MENU DISPLAYED DURING A MISSION
-- ====================================================================================
-- ====================================================================================

TUM.missionMenu = {}

do
    local function doCommandAbortMission()
        TUM.mission.endMission(TUM.mission.endCause.ABORTED)
    end

    local function doCommandMissionStatus()
        TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "playerCommandMissionStatus", nil, TUM.mission.getPlayerCallsign(), false)
        TUM.mission.playMissionSummaryRadioMessage(false, true)
    end

    local function doCommandNearestAirbase()
        TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "playerATCRequireNearestAirbase", nil, TUM.mission.getPlayerCallsign(), false)
        TUM.atc.requestNavAssistanceToAirbase(false)
    end

    local function doCommandObjectiveLocation(index)
        local obj = TUM.objectives.getObjective(index)
        if not obj then return end

        TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "playerCommandRequireObjectives", { obj.name }, TUM.mission.getPlayerCallsign(), false)
        TUM.atc.requestNavAssistanceToObjective(index, true)
    end

    local function doCommandWeatherUpdate()
        TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "playerATCWeatherUpdate", nil, TUM.mission.getPlayerCallsign(), false)
        TUM.atc.requestWeatherUpdate(false)
    end

    function TUM.missionMenu.create()
        local rootMenu = TUM.getOrCreateRootMenu(true) -- Clear the menu
        missionCommands.addCommand("☱ Mission status", rootMenu, doCommandMissionStatus, nil)

        local objectivesMenuRoot = missionCommands.addSubMenu("❖ Objectives", rootMenu)
        local navigationMenuRoot = missionCommands.addSubMenu("➽ Navigation", rootMenu)
        -- missionCommands.addCommand("Nav to nearest airbase", navigationMenuRoot, doCommandNearestAirbase, nil)

        for i=1,TUM.objectives.getCount() do
            local obj = TUM.objectives.getObjective(i)
            if obj then
                local objNameAndDescription = obj.name.." ("..Library.tasks[obj.taskID].description.short..")"
                local objRoot = missionCommands.addSubMenu("Objective "..objNameAndDescription, objectivesMenuRoot)
                TUM.supportJTAC.setupJTACOnObjective(i, objRoot)

                missionCommands.addCommand("Nav to objective "..objNameAndDescription, navigationMenuRoot, doCommandObjectiveLocation, i)
            end
        end
        -- missionCommands.addCommand("Weather update", navigationMenuRoot, doCommandWeatherUpdate, nil)

        TUM.wingmenMenu.create()
        TUM.supportAWACS.createMenu()

        if not TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then -- If not multiplayer, add "show mission score" command
            missionCommands.addCommand("★ Display mission score", rootMenu, TUM.playerScore.showScore, nil)
        end

        local abortRoot = missionCommands.addSubMenu("⬣ Abort mission", rootMenu)
        if not TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) and DCSEx.io.canReadAndWrite() then
            missionCommands.addCommand("✓ Confirm (all xp since last landing will be lost!)", abortRoot, doCommandAbortMission, nil)
        else
            missionCommands.addCommand("✓ Confirm", abortRoot, doCommandAbortMission, nil)
        end
        missionCommands.addCommand("✕ Cancel", abortRoot, DCSEx.dcs.doNothing, nil)

        TUM.debugMenu.createMenu() -- Append debug menu to other menus (if debug mode enabled)
    end
end
