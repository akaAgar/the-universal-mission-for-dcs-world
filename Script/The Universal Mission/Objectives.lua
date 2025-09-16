-- ====================================================================================
-- TUM.OBJECTIVES - HANDLES THE MISSION OBJECTIVES
-- ====================================================================================
-- ====================================================================================

TUM.objectives = {}

do
    local objectives = {}

    local function updateObjectiveText(index)
        if index < 1 or index > #objectives then return end

        local taskDB = Library.tasks[objectives[index].taskID]
        local suffix = ""
        if DCSEx.table.contains(taskDB.flags, DCSEx.enums.taskFlag.MOVING) then
            suffix = "\n(last position known to intel, target is moving)"
        end

        local text = "Objective "..objectives[index].name..":\n"..taskDB.description.short.." ("..TUM.objectives.getObjectiveProgress(index)..")"..suffix
        trigger.action.setMarkupText(objectives[index].markerTextID, text)
    end

    function TUM.objectives.add()
        local objective = TUM.objectivesMaker.create()

        if not objective then
            TUM.log("Failed to spawn a group for objective #"..tostring(#objectives + 1)..".", TUM.logger.logLevel.WARNING)
            return false
        end

        table.insert(objectives, objective)
        updateObjectiveText(#objectives)
        return true
    end

    function TUM.objectives.getCount()
        return #objectives
    end

    function TUM.objectives.getCompletedCount()
        if #objectives == 0 then return 0 end

        local count = 0
        for i=1,#objectives do
            if objectives[i].completed then count = count + 1 end
        end

        return count
    end

    function TUM.objectives.getCenter()
        local point2 = { x = 0, y = 0 }

        if #objectives == 0 then return point2 end

        for _,o in ipairs(objectives) do
            point2.x = point2.x + o.point2.x
            point2.y = point2.y + o.point2.y
        end

        point2.x = point2.x / #objectives
        point2.y = point2.y / #objectives

        return point2
    end

    function TUM.objectives.getRadius()
        if #objectives < 2 then return 10000 end -- Default to a 10km radius if no objectives or a single objective

        local center = TUM.objectives.getCenter()
        local radius = 0

        for _,o in ipairs(objectives) do
            local dist = DCSEx.math.getDistance2D(center, o.point2)
            if dist > radius then radius = dist end
        end

        return radius
    end

    function TUM.objectives.getObjective(index)
        if index < 1 or index > #objectives then return nil end
        return DCSEx.table.deepCopy(objectives[index])
    end

    function TUM.objectives.getObjectiveProgress(index, doublePercentage)
        doublePercentage = doublePercentage or false
        if index < 1 or index > #objectives then return "" end

        if TUM.DEBUG_MODE then
            return tostring(#objectives[index].completedUnitsID).."/"..tostring(math.max(1, #objectives[index].unitsID))
        else
            local percentage = 0
            if #objectives[index].unitsID > 0 then
                percentage = math.floor((#objectives[index].completedUnitsID / math.max(1, #objectives[index].unitsID)) * 100.0)
            end

            if doublePercentage then
                return tostring(percentage).."%%"
            else
                return tostring(percentage).."%"
            end
        end
    end

    function TUM.objectives.removeAll()
        TUM.log("Removing all objectives...")

        for _,o in ipairs(objectives) do
            if o.groupID then
                local g = DCSEx.world.getGroupByID(o.groupID)
                if g then g:destroy() end
            elseif o.unitsID then -- Some objects (such as static object) do not belong to a group, must be removed one by one
                for _,id in ipairs(o.unitsID) do
                    local u = DCSEx.world.getUnitByID(id)
                    if u then
                        u:destroy()
                    else
                        local s = DCSEx.world.getStaticObjectByID(id)
                        if s then s:destroy() end
                    end
                end
            end

            trigger.action.removeMark(o.markerID)
            trigger.action.removeMark(o.markerTextID)
        end

        objectives = {}
    end

    function TUM.objectives.areAllCompleted()
        if #objectives == 0 then return false end

        return TUM.objectives.getCompletedCount() == TUM.objectives.getCount()
    end

    function TUM.objectives.getSceneryObjectObjective(sceneryObject)
        if #objectives == 0 then return nil end
        if not sceneryObject then return nil end
        if Object.getCategory(sceneryObject) ~= Object.Category.SCENERY then return nil end

        for i=1,#objectives do
            if DCSEx.math.isSamePoint(sceneryObject:getPoint(), objectives[i].point3) then
                return i
            end
        end

        return nil
    end

    local function markObjectiveAsComplete(index)
        if index < 1 or index > #objectives then return end -- Out of bounds
        if objectives[index].completed then return end -- Objective already completed

        objectives[index].completed = true
        TUM.playerScore.awardCompletedObjective()

        if TUM.objectives.areAllCompleted() then
            TUM.mission.checkMissionStatus()
        else
            TUM.radio.playForCoalition(TUM.settings.getPlayerCoalition(), "commandObjectiveComplete", { objectives[index].name }, "Command", true)
        end

        DCSEx.dcs.outPicture("Pic-ObjectiveComplete.png", 5, true, 0, 1, 1, 25, 1)
        trigger.action.outSound("UI-MissionEnd.ogg")
    end

    local function onObjectiveEvent(index, event)
        if index < 1 or index > #objectives then return end -- Out of bounds
        if objectives[index].completed then return end -- Objective already completed

        if event.id ~= world.event.S_EVENT_DEAD and event.id ~= world.event.S_EVENT_UNIT_LOST then return end
        if not event.initiator then return end

        if objectives[index].isAirbaseTarget then
            if Object.getCategory(event.initiator) == Object.Category.BASE then
                if DCSEx.math.isSamePoint(event.initiator:getPoint(), objectives[index].point3) then
                    timer.scheduleFunction(markObjectiveAsComplete, index, timer.getTime() + 3)
                end
            end
        elseif objectives[index].isSceneryTarget then
            if Object.getCategory(event.initiator) == Object.Category.SCENERY then
                if DCSEx.math.isSamePoint(event.initiator:getPoint(), objectives[index].point3) then
                    timer.scheduleFunction(markObjectiveAsComplete, index, timer.getTime() + 3)
                end
            end
        else
            if Object.getCategory(event.initiator) == Object.Category.UNIT or Object.getCategory(event.initiator) == Object.Category.STATIC then
                local unitID = DCSEx.dcs.getObjectIDAsNumber(event.initiator)

                if DCSEx.table.contains(objectives[index].completedUnitsID, unitID) then return end
                if not DCSEx.table.contains(objectives[index].unitsID, unitID) then return end

                table.insert(objectives[index].completedUnitsID, unitID)
                if #objectives[index].completedUnitsID == #objectives[index].unitsID then
                    timer.scheduleFunction(markObjectiveAsComplete, index, timer.getTime() + 3)
                end
            end
        end

        updateObjectiveText(index)
    end

    function TUM.objectives.onEvent(event)
        for i,_ in ipairs(objectives) do
            onObjectiveEvent(i, event)
        end
    end
end
