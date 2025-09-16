-- ====================================================================================
-- TUM.SUPPORTJTAC - HANDLES FRIENDLY JTAC SMOKE MARKERS AND LASING
-- ====================================================================================
-- (local) destroyAllLasers()
-- (local) doCommandLaser(index)
-- (local) doCommandLaserStop(index)
-- (local) doCommandSmoke(index)
-- (local) spawnSmoke(args)
-- (local) updateLaserPositions()
-- TUM.supportJTAC.setupJTACOnObjective(index, menuRoot)
-- ====================================================================================

TUM.supportJTAC = {}

do
    local JTAC_CALLSIGNS = {
        "Anvil",
        "Axeman",
        "Badger",
        "Darknight",
        "Deathstar",
        "Eyeball",
        "Ferret",
        "Finger",
        "Firefly",
        "Hammer",
        "Jaguar",
        "Mantis",
        "Moonbeam",
        "Pinpoint",
        "Playboy",
        "Pointer",
        "Shaba",
        "Warrior",
        "Whiplash",
    }

    local LASER_CODE = 1688
    local LASER_DESIGNATION_PENALTY = -15
    local SMOKE_DURATION = 300 -- in seconds
    local SMOKE_MARKER_PENALTY = -25

    local jtacName = {}
    local lastSmoke = {}
    local laserSpots = {}
    local laserTargets = {}

    local function destroyAllLasers()
        if #laserSpots == 0 and #laserTargets == 0 then return end

        for _,l in pairs(laserSpots) do
            if l then l:destroy() end
        end

        laserSpots = {}
        laserTargets = {}
    end

    local function doCommandLaser(index)
        local obj = TUM.objectives.getObjective(index)
        if not obj then return end

        if laserSpots[index] then
            laserSpots[index]:destroy()
            laserSpots[index] = nil
        end

        local sourceObject = nil
        local targetPoint = {x = 0, y = 0, z = 0}

        laserSpots[index] = Spot.createLaser(sourceObject, {x = 0, y = 1, z = 0}, targetPoint, LASER_CODE)
    end

    local function doCommandLaserStop(index)
        local obj = TUM.objectives.getObjective(index)
        if not obj then return end

        TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "playerJTACLaserStop", { jtacName[index], obj.name }, TUM.mission.getPlayerCallsign(), false)

        -- Not lasing this objective at the moment
        if not laserSpots[index] then
            TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "jtacLaserStopNoLaser", { jtacName[index], obj.name }, jtacName[index], true)
            return
        end

        laserSpots[index]:destroy()
        laserSpots[index] = nil
        TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "jtacLaserStop", { jtacName[index], obj.name }, jtacName[index], true)
    end

    local function doCommandSmoke(index)
        local obj = TUM.objectives.getObjective(index)
        if not obj then return end

        -- Pick a smoke color
        local smokeColor = DCSEx.table.getRandom({ trigger.smokeColor.Red, trigger.smokeColor.Orange }) -- TODO: green or blue smoke when marking friendlies
        local smokeColorName = "red"
        if smokeColor == trigger.smokeColor.Orange then smokeColorName = "orange" end

        TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "playerJTACSmoke", { jtacName[index], obj.name }, TUM.mission.getPlayerCallsign(), false)

        if not lastSmoke[index] then lastSmoke[index] = -3600 end
        if lastSmoke[index] + SMOKE_DURATION > timer.getAbsTime() then
            TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "jtacSmokeAlreadyOut", { jtacName[index], obj.name }, jtacName[index], true)
            return
        end

        if obj.completed then
            TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "jtacSmokeNoTarget", { jtacName[index] }, jtacName[index], true)
            return
        end

        if obj.isAirbaseTarget or obj.isSceneryTarget then
            TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "jtacSmokeOK", { jtacName[index], smokeColorName }, jtacName[index], true, spawnSmoke, { point3 = obj.point3, smokeColor = smokeColor })
        else
            for _,id in ipairs(obj.unitsID) do
                if not DCSEx.table.contains(obj.completedUnitsID, id) then
                    local unit = DCSEx.world.getUnitByID(id)
                    if unit and unit:isActive() and unit:getLife() > 0 then
                        TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "jtacSmokeOK", { jtacName[index], smokeColorName }, jtacName[index], true, spawnSmoke, { point3 = unit:getPoint(), smokeColor = smokeColor })
                        lastSmoke[index] = timer.getAbsTime()
                        TUM.playerScore.award(SMOKE_MARKER_PENALTY, "called for smoke marker")
                        return
                    end
                end
            end
        end

        TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "jtacSmokeNoTarget", { jtacName[index] }, jtacName[index], true)
    end

    local function spawnSmoke(args)
        trigger.action.smoke(args.point3, args.smokeColor)
    end

    local function updateLaserPositions()
        -- Not in a mission? Destroy all lasers
        if TUM.mission.getStatus() == TUM.mission.status.NONE then
            destroyAllLasers()
            return timer.getTime() + 0.5
        end

        for i=1,TUM.objectives.getCount() do
            -- TODO
        end

        return timer.getTime() + 0.5
    end

    function TUM.supportJTAC.setupJTACOnObjective(index, menuRoot)
        local obj = TUM.objectives.getObjective(index)
        if not obj then return end

        jtacName[index] = DCSEx.table.getRandom(JTAC_CALLSIGNS)
        lastSmoke[index] = -3600
        local objectiveDB = Library.tasks[obj.taskID]
        if not DCSEx.table.contains(objectiveDB.flags, DCSEx.enums.taskFlag.ALLOW_JTAC) then return end -- No JTAC for this objective

        missionCommands.addCommand("Smoke marker on target ("..tostring(SMOKE_MARKER_PENALTY).."xp)", menuRoot, doCommandSmoke, index)
        missionCommands.addCommand("Designate target with laser (code "..tostring(LASER_CODE)..", "..tostring(LASER_DESIGNATION_PENALTY).."xp)", menuRoot, doCommandLaser, index)
        missionCommands.addCommand("Stop designating target with laser", menuRoot, doCommandLaserStop, index)
    end

    -- Schedule the laser updating function to be called every 0.5 seconds 
    timer.scheduleFunction(updateLaserPositions, {}, timer.getTime() + 0.5)
end
