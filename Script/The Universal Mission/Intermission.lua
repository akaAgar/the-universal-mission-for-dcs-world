-- ====================================================================================
--  TUM.INTERMISSION - HANDLES THE MENU DISPLAYED BETWEEN MISSIONS
-- ====================================================================================
-- TUM.intermission.createMenu()
-- TUM.intermission.onInitialize()
-- ====================================================================================

TUM.intermission = {}

do
    local missionZonesMarkers = {}

    local function doCommandStartMission()
        local players = DCSEx.world.getAllPlayers()

        if #players == 0 then
            trigger.action.outText("No player slots occupied. At least one client slot must be occupied by a player to start the mission.", 5)
            trigger.action.outSound("UI-Error.ogg")
            return
        end

        if not TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then
            for _,p in ipairs(players) do
                if p:inAir() then
                    trigger.action.outText("Cannot start a single player mission while the player is in the air. Please land before starting the mission.", 5)
                    trigger.action.outSound("UI-Error.ogg")
                    return
                end
            end
        end

        trigger.action.outText("Generating mission and loading assets, this can take some time...", 5)

        -- Add a little delay for the "Generating mission..." message be printed out. Once generation begins, the main DCS thread will be to busy to output anything.
        timer.scheduleFunction(TUM.mission.beginMission, false, timer.getTime() + 1)
    end

    local function setSetting(args)
        if not args.id or not args.value then return end

        TUM.settings.setValue(args.id, args.value, false)
        TUM.intermission.createMenu()
    end

    local function createSubMenu(id, parentMenu)
        local rootMenu = nil

        rootMenu = missionCommands.addSubMenu(TUM.settings.getSettingsName(id)..": "..TUM.settings.getValue(id, true), parentMenu)
        for i,v in ipairs(TUM.settings.getPossibleValues(id)) do
            local commandText = v
            if id == TUM.settings.id.TARGET_LOCATION then
                local playerCenter = DCSEx.world.getUnitsCenter(DCSEx.world.getAllPlayers())
                local distance = math.floor(DCSEx.converter.metersToNM(DCSEx.math.getDistance2D(playerCenter, DCSEx.zones.getByName(v))))
                commandText = commandText.."(≈"..tostring(distance).." nm)"
            end

            missionCommands.addCommand(commandText, rootMenu, setSetting, { id = id, value = i, redrawMenu = true })
        end
    end

    function TUM.intermission.createMissionZonesMarkers()
        TUM.intermission.removeMissionZonesMarkers()

        local missionZones = TUM.territories.getMissionZones()
        for _,z in ipairs(missionZones) do
            local zoneOwner = TUM.territories.getPointOwner(z)
            local color = DCSEx.dcs.getCoalitionColor(zoneOwner)

            local ids = DCSEx.zones.drawOnMap(z, { color[1], color[2], color[3], 1 }, { color[1], color[2], color[3], .5 }, DCSEx.enums.lineType.SOLID, true, true)
            if ids then
                table.insert(missionZonesMarkers, ids[1])
                table.insert(missionZonesMarkers, ids[2])
            end
        end
    end

    function TUM.intermission.removeMissionZonesMarkers()
        for _,id in ipairs(missionZonesMarkers) do
            trigger.action.removeMark(id)
        end

        missionZonesMarkers = {}
    end

    -------------------------------------
    -- Creates the mission briefing menu
    -------------------------------------
    function TUM.intermission.createMenu()
        local rootMenu = TUM.getOrCreateRootMenu(true) -- Clear the menu

        local briefingText = "Welcome to The Universal Mission for DCS World, a highly customizable mission available for single-player and PvE.\n\nOpen the communication menu and select the ''F10. Other'' option to access mission settings."
        DCSEx.envMission.setBriefing(coalition.side.RED, briefingText)
        DCSEx.envMission.setBriefing(coalition.side.BLUE, briefingText)

        TUM.intermission.createMissionZonesMarkers() -- Show the available mission zones on the F10 map

        missionCommands.addCommand("ℹ Display mission settings", rootMenu, TUM.settings.printSettingsSummary, false)

        local settingsMenu = missionCommands.addSubMenu("✎ Change mission settings", rootMenu)
        createSubMenu(TUM.settings.id.COALITION_BLUE, settingsMenu)
        createSubMenu(TUM.settings.id.COALITION_RED, settingsMenu)
        createSubMenu(TUM.settings.id.TASKING, settingsMenu)
        createSubMenu(TUM.settings.id.TARGET_LOCATION, settingsMenu)
        createSubMenu(TUM.settings.id.TARGET_COUNT, settingsMenu)
        createSubMenu(TUM.settings.id.ENEMY_AIR_DEFENSE, settingsMenu)
        createSubMenu(TUM.settings.id.ENEMY_AIR_FORCE, settingsMenu)
        createSubMenu(TUM.settings.id.WINGMEN, settingsMenu)
        createSubMenu(TUM.settings.id.AI_CAP, settingsMenu)
        TUM.playerCareer.createMenu()
        missionCommands.addCommand("➤ Begin mission", rootMenu, doCommandStartMission, nil)
        TUM.debugMenu.createMenu() -- Append debug menu to other menus (if debug mode enabled)
    end

    -------------------------------------
    -- Called on mission start up
    -- @return True if started up properly, false if an error happened
    -------------------------------------
    function TUM.intermission.onStartUp()
        TUM.intermission.createMenu() -- Create the briefing menu
        return true
    end
end
