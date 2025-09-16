-- ====================================================================================
-- TUM.OBJECTIVESMAKER - CREATE MISSION OBJECTIVES
-- ====================================================================================
-- ====================================================================================

TUM.objectivesMaker = {}

do
    local function pickRandomTask()
        local taskFamily = TUM.settings.getValue(TUM.settings.id.TASKING)

        local validTaskIDs = {}
        for k,t in pairs(Library.tasks) do
            if t.taskFamily == taskFamily then
                table.insert(validTaskIDs, k)
            end
        end

        if #validTaskIDs == 0 then return nil end

        return DCSEx.table.getRandom(validTaskIDs)
    end

    local function pickWaterPoint(nearThisPoint)
        local waterZones = TUM.territories.getWaterZones()
        if not waterZones or #waterZones == 0 then return nil end -- No "water" zones on this map

        local possiblePoints = {}

        for _=1,24 do
            local point = DCSEx.zones.getRandomPointInside(DCSEx.table.getRandom(waterZones), land.SurfaceType.WATER)
            if point then
                table.insert(possiblePoints, point)
            end
        end

        if #possiblePoints == 0 then return nil end

        possiblePoints = DCSEx.dcs.getNearestPoints(nearThisPoint, possiblePoints, 1)

        return possiblePoints[1]
    end

    function TUM.objectivesMaker.create()
        local zone = DCSEx.zones.getByName(TUM.settings.getValue(TUM.settings.id.TARGET_LOCATION, true))

        local taskID = pickRandomTask()
        if not taskID then
            TUM.log("Failed to find a valid task.", TUM.logger.logLevel.WARNING)
            return nil
        end
        local objectiveDB = Library.tasks[taskID]

        local parkingInfo = nil
        local spawnPoint2 = nil
        local spawnPoint3 = nil
        local isAirbaseTarget = false
        local isSceneryTarget = false

        if DCSEx.table.contains(objectiveDB.flags, DCSEx.enums.taskFlag.SCENERY_TARGET) then
            local validSceneries = DCSEx.world.getSceneriesInZone(zone, DCSEx.zones.getRadius(zone), 250)
            if not validSceneries or #validSceneries == 0 then
                TUM.log("Failed to find a valid scenery object to use as target.", TUM.logger.logLevel.WARNING)
                return nil
            end

            local pickedScenery = DCSEx.table.getRandom(validSceneries)
            spawnPoint3 = DCSEx.table.deepCopy(pickedScenery:getPoint())
            spawnPoint2 = DCSEx.math.vec3ToVec2(spawnPoint3)
            isSceneryTarget = true
        elseif DCSEx.table.contains(objectiveDB.flags, DCSEx.enums.taskFlag.AIRBASE_TARGET) then
            local validAirbases = DCSEx.zones.getAirbases(zone, TUM.settings.getEnemyCoalition())
            if #validAirbases == 0 then
                TUM.log("Failed to find a valid airbase to use as target.", TUM.logger.logLevel.WARNING)
                return nil
            end
            local pickedAirbase = DCSEx.table.getRandom(validAirbases)
            spawnPoint3 = DCSEx.table.deepCopy(pickedAirbase:getPoint())
            spawnPoint2 = DCSEx.math.vec3ToVec2(spawnPoint3)
            isAirbaseTarget = true
        elseif DCSEx.table.contains(objectiveDB.flags, DCSEx.enums.taskFlag.PARKED_AIRCRAFT_TARGET) then
            local validAirbases = DCSEx.zones.getAirbases(zone, TUM.settings.getEnemyCoalition())
            if #validAirbases == 0 then
                TUM.log("Failed to find a valid airbase to use as target.", TUM.logger.logLevel.WARNING)
                return nil
            end
            local pickedAirbase = DCSEx.table.getRandom(validAirbases)
            local parkings = pickedAirbase:getParking()
            local validParkings = {}
            for _,p in pairs(parkings) do
                if p.Term_Type == 104 then table.insert(validParkings, p) end
            end
            if #validParkings == 0 then
                TUM.log("Failed to find a valid airbase parking to spawn a target.", TUM.logger.logLevel.WARNING)
                return nil
            end
            local pickedParking = DCSEx.table.getRandom(validParkings)
            parkingInfo = { airbaseID = pickedAirbase:getID(), parkingID = pickedParking.Term_Index }
            spawnPoint3 = pickedParking.vTerminalPos
            spawnPoint2 = DCSEx.math.vec3ToVec2(spawnPoint3)
        elseif objectiveDB.surfaceType == land.SurfaceType.WATER then
            spawnPoint2 = pickWaterPoint(zone)
            if not spawnPoint2 then
                spawnPoint2 = DCSEx.world.getSpawnPoint(zone, objectiveDB.surfaceType, objectiveDB.safeRadius)
            end
        else
            spawnPoint2 = DCSEx.world.getSpawnPoint(zone, objectiveDB.surfaceType, objectiveDB.safeRadius)
        end

        if not spawnPoint2 then
            TUM.log("Failed to find a spawn point for objective.", TUM.logger.logLevel.WARNING)
            return nil
        end

        if not spawnPoint3 then spawnPoint3 = DCSEx.math.vec2ToVec3(spawnPoint2, "land") end

        if DCSEx.table.contains(objectiveDB.flags, DCSEx.enums.taskFlag.ON_ROADS) then
            spawnPoint2 = DCSEx.world.getClosestPointOnRoadsVec2(spawnPoint2)
        end

        local objective = {
            completed = false,
            completedUnitsID = {},
            isAirbaseTarget = isAirbaseTarget,
            isSceneryTarget = isSceneryTarget,
            markerID = DCSEx.world.getNextMarkerID(),
            markerTextID = DCSEx.world.getNextMarkerID(),
            name = Library.objectiveNames.get():upper(),
            parkingInfo = parkingInfo,
            point2 = DCSEx.table.deepCopy(spawnPoint2),
            point3 = DCSEx.table.deepCopy(spawnPoint3),
            preciseCoordinates = objectiveDB.waypointInaccuracy <= 0,
            taskID = taskID,
            unitsID = {}
        }

        if objectiveDB.waypointInaccuracy <= 0 then -- Exact coordinates are available
            objective.waypoint2 = DCSEx.table.deepCopy(objective.point2)
            objective.waypoint3 = DCSEx.table.deepCopy(objective.point3)
        else -- No exact coordinates available, create the waypoint near the target
            objective.waypoint2 = DCSEx.math.randomPointInCircle(objective.point2, objectiveDB.waypointInaccuracy)
            objective.waypoint3 = DCSEx.math.vec2ToVec3(objective.waypoint2, "land")
        end

        if not isAirbaseTarget and not isSceneryTarget then
            -- Check group options
            local groupOptions = {}
            if DCSEx.table.contains(objectiveDB.flags, DCSEx.enums.taskFlag.MOVING) then
                local destPoint = DCSEx.math.randomPointInCircle(objective.point2, 5000, 2500, land.SurfaceType.LAND)
                if destPoint then
                    groupOptions.isMoving = true
                    if DCSEx.table.contains(objectiveDB.flags, DCSEx.enums.taskFlag.ON_ROADS) then
                        groupOptions.onRoad = true
                        destPoint = DCSEx.world.getClosestPointOnRoadsVec2(destPoint)
                    end
                    groupOptions.moveTo = destPoint
                end
            end

            -- Parked aircraft only
            if parkingInfo then
                groupOptions.airbaseID = parkingInfo.airbaseID
                groupOptions.invisible = true -- Not ideal because wingmen can't be tasked with attacking targets, but only way I've found to prevent friendly CAP from attacking parked aircraft
                groupOptions.parkingID = parkingInfo.parkingID
            end

            local units = Library.factions.getUnits(TUM.settings.getEnemyFaction(), objectiveDB.targetFamilies, math.random(objectiveDB.targetCount[1], objectiveDB.targetCount[2]))

            local groupInfo = nil
            if objectiveDB.targetFamilies[1] == DCSEx.enums.unitFamily.STATIC_STRUCTURE then
                if units and #units >= 1 then
                    groupInfo = {}
                    groupInfo.unitsID = { DCSEx.unitGroupMaker.createStatic(TUM.settings.getEnemyCoalition(), objective.point2, units[1], "") }
                end
            else
                groupInfo = DCSEx.unitGroupMaker.create(TUM.settings.getEnemyCoalition(), DCSEx.dcs.getUnitCategoryFromFamily(objectiveDB.targetFamilies[1]), objective.point2, units, groupOptions)
            end

            if not groupInfo then
                TUM.log("Failed to spawn a group for objective.", TUM.logger.logLevel.WARNING)
                return nil
            end
            objective.groupID = groupInfo.groupID

            if DCSEx.table.contains(objectiveDB.flags, DCSEx.enums.taskFlag.DESTROY_TRACK_RADARS_ONLY) then
                objective.unitsID = {}
                for i=1,#groupInfo.unitTypeNames do
                    if Unit.getDescByName(groupInfo.unitTypeNames[i]).attributes["SAM TR"] then
                        table.insert(objective.unitsID, groupInfo.unitsID[i])
                    end
                end
                if #objective.unitsID == 0 then
                    objective.unitsID = DCSEx.table.deepCopy(groupInfo.unitsID)
                end
            else
                objective.unitsID = DCSEx.table.deepCopy(groupInfo.unitsID)
            end
        end

        ---------------------------------------------------------------------
        -- Create dot marker (accurate WPs) or circle marker (inaccurate WPs)
        ---------------------------------------------------------------------
        if objectiveDB.waypointInaccuracy <= 0 then
            trigger.action.markToAll(objective.markerID, "Objective "..objective.name.."\n\n"..DCSEx.world.getCoordinatesAsString(objective.point3, false), objective.point3, true)
        else
            local circleRadius = math.max(objectiveDB.waypointInaccuracy, 1000)
            trigger.action.circleToAll(
                -1, objective.markerID,
                objective.waypoint3, circleRadius,
                { 1, 1, 1, 1 }, { 1, 0, 0, 0.25 } , 2, true)
        end

        ---------------------
        -- Create text marker
        ---------------------
        local textPoint3 = DCSEx.table.deepCopy(objective.waypoint3)
        textPoint3.x = textPoint3.x + 224
        textPoint3.z = textPoint3.z + 224
        -- Text marker is created with an empty string, its content will be updated by TUM.MissionObjectives when it's added
        trigger.action.textToAll(-1, objective.markerTextID, textPoint3, { 1, 1, 1, 1 }, { 0, 0, 0, .5 }, 12, true, "")

        return objective
    end
end
