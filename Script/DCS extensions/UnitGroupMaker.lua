-- ====================================================================================
-- DCSEX.UNITGROUPMAKER - CREATES AND ADDS GROUPS TO THE GAME WORLD
-- ====================================================================================
-- (local) createGroupTable(groupID, groupCategory, options)
-- (local) getDefaultUnitSpread(groupCategory)
-- (local) getNextGroupID()
-- (local) getNextUnitID()
-- (local) setAircraftTaskAwacs(groupTable)
-- (local) setAircraftTaskCAP(groupTable)
-- (local) setAircraftTaskFollow(groupTable, followedGroupID, xyDistance)
-- (local) setAircraftTaskOrbit(groupTable, options)
-- (local) setCommand(groupTable, actionID, actionValue)
-- (local) setOption(groupTable, optionID, optionValue)
-- DCSEx.unitGroupMaker.createStatic(side, point2, typeName, shapeName, heading, dead)
-- DCSEx.unitGroupMaker.create(coalitionID, groupCategory, vec2, unitTypes, options)
-- ====================================================================================

DCSEx.unitGroupMaker = {}

do
    local nextGroupID = 1 -- ID of the next generated group
    local nextUnitID = 1 -- ID of the next generated unit
    local dataLinkID = 201 -- Next datalink ID

    local function createGroupTable(groupID, groupCategory, options)
        local groupTable = {
            groupId = groupID,
            hidden = options.hidden,
            name = options.name,
            route = {points = {}},
            start_time = 0,
            taskSelected = true,
            uncontrollable = true,
            visible = false,
            units = {},
        }

        if groupCategory == Group.Category.GROUND then
            groupTable.task = "Ground Nothing"
            groupTable.tasks = {}
        elseif groupCategory == Group.Category.AIRPLANE or groupCategory == Group.Category.HELICOPTER then
            groupTable.uncontrolled = options.uncontrolled or false
        end

        return groupTable
    end

    local function getDefaultUnitSpread(groupCategory)
        if groupCategory == Group.Category.AIRPLANE or groupCategory == Group.Category.HELICOPTER then
            return 150 -- TODO: improve
        elseif groupCategory == Group.Category.SHIP then
            return math.random(250, 400)
        else
            return math.random(20, 30)
        end
    end

    -- Returns the next available group ID and increment the number
    local function getNextGroupID()
        nextGroupID = nextGroupID + 1
        return nextGroupID - 1
    end

    -- Returns the next available unit ID and increment the number
    local function getNextUnitID()
        nextUnitID = nextUnitID + 1
        return nextUnitID - 1
    end

    local function setAircraftTaskAwacs(groupTable)
        groupTable.frequency = 251000000
        groupTable.task = "AWACS"

        table.insert(groupTable.route.points[1].task.params.tasks,
        {
            ["enabled"] = true,
            ["auto"] = true,
            ["id"] = "AWACS",
            ["number"] = #groupTable.route.points[1].task.params.tasks + 1,
            ["params"] = { },
        })

        return groupTable
    end

    local function setAircraftTaskCAP(groupTable)
        groupTable.task = "CAP"

        table.insert(groupTable.route.points[1].task.params.tasks,
        {
            ["enabled"] = true,
            ["auto"] = true,
            ["id"] = "EngageTargets",
            ["number"] = #groupTable.route.points[1].task.params.tasks + 1,
            ["params"] = {
                maxDist = DCSEx.converter.nmToMeters(60),
                maxDistEnabled = false,
                -- targetTypes = { "Planes", "Helicopters" },
                targetTypes = { "Fighters", "Interceptors", "Multirole fighters" },
                priority = 0
            },
        })

        return groupTable
    end

    local function setAircraftTaskFollow(groupTable, followedGroupID, xyDistance)
        xyDistance = xyDistance or 800
        groupTable.task = "Escort"

        table.insert(groupTable.route.points[1].task.params.tasks,
        {
            ["enabled"] = true,
            ["auto"] = true,
            ["id"] = "Follow",
            ["number"] = #groupTable.route.points[1].task.params.tasks + 1,
            ["params"] = {
                groupId = followedGroupID,
                pos = { x = -xyDistance, y = 0, z = -xyDistance },
                lastWptIndexFlag  = false,
                lastWptIndex = -1
             },
        })

        return groupTable
    end

    local function setAircraftTaskOrbit(groupTable, options)
        -- TODO: oval orbit
        table.insert(groupTable.route.points[#groupTable.route.points].task.params.tasks,
        {
            ["enabled"] = true,
            ["auto"] = false,
            ["id"] = "Orbit",
            ["number"] = #groupTable.route.points[#groupTable.route.points].task.params.tasks + 1,
            ["params"] =
            {
                ["altitude"] = options.altitude,
                ["pattern"] = "Circle",
                ["speed"] = options.speed,
            },
        })

        return groupTable
    end

    local function setCommand(groupTable, actionID, actionValue)
        table.insert(
            groupTable.route.points[1].task.params.tasks,
            {
                ["auto"] = false,
                ["enabled"] = true,
                ["id"] = "WrappedAction",
                ["number"] = #groupTable.route.points[1].task.params.tasks + 1,
                ["params"] = { ["action"] = { ["id"] = actionID, ["params"] = { ["value"] = actionValue, }, }, },
            })
    end

    local function setOption(groupTable, optionID, optionValue)
        table.insert(
            groupTable.route.points[1].task.params.tasks,
            {
                ["auto"] = false,
                ["enabled"] = true,
                ["id"] = "WrappedAction",
                ["number"] = #groupTable.route.points[1].task.params.tasks + 1,
                ["params"] = { ["action"] = { ["id"] = "Option", ["params"] = { ["name"] = optionID, ["value"] = optionValue, }, }, },
            })
    end

    function DCSEx.unitGroupMaker.createStatic(side, point2, typeName, shapeName, heading, dead)
        heading = heading or DCSEx.converter.degreesToRadians(math.random(0, 359))
        dead = dead or false
        local unitID = getNextUnitID()

        local staticObj = {
            ["heading"] = 0,
            ["groupId"] = getNextGroupID(),
            ["shape_name"] = shapeName,
            ["type"] = typeName,
            ["unitId"] = unitID,
            ["rate"] = 100,
            ["name"] = "Structure #"..tostring(unitID),
            ["category"] = "Fortifications",
            ["y"] = point2.y,
            ["x"] = point2.x,
            ["dead"] = dead,
        }

        coalition.addStaticObject(DCSEx.dcs.getCJTFForCoalition(side), staticObj)

        return unitID
    end

    function DCSEx.unitGroupMaker.create(coalitionID, groupCategory, vec2, unitTypes, options)
        if not unitTypes or #unitTypes == 0 then return nil end -- No unit types provided
        if type(unitTypes) == "string" then unitTypes = { unitTypes } end -- Single unit type provided, make it a table of size 1

        local aircraftDB = nil -- Aircraft entry in the DB for airplane/helicopter units
        local destVec2 = nil -- Destination point (for moving units)
        local groupID = getNextGroupID() -- Get a new unique ID for the group
        local isAirUnit = false

        local hidden = options.hidden or false
        if not TUM.DEBUG_MODE and coalitionID ~= TUM.settings.getPlayerCoalition() then
            hidden = true
        end

        -- Setup options
        options = options or {}
        --options.heading = nil
        options.altitudeType = options.altitudeType or "BARO"
        options.hidden = hidden
        options.isMoving = false
        options.livery = options.livery or "default"
        options.name = DCSEx.unitNamesMaker.getName(groupID, unitTypes)
        options.pointAction = "Turning Point"
        options.skill = options.skill or "Average"
        options.speed = 5.5555556
        options.spreadDistance = options.spreadDistance or getDefaultUnitSpread(groupCategory)
        options.spreadOffset = options.spreadOffset or 0

        -- Movement point (for units with a second WP)
        if options.moveTo then
            options.isMoving = true
            destVec2 = DCSEx.table.deepCopy(options.moveTo)
        elseif options.moveBy then
            options.isMoving = true
            local angle = DCSEx.converter.degreesToRadians(math.random(0, 359))
            destVec2 = { x = vec2.x + math.cos(angle) * options.moveBy, y = vec2.y + math.sin(angle) * options.moveBy }
        end

        -- Category specific options
        if groupCategory == Group.Category.GROUND then
            options.pointAction = "Off Road"

            local desc = Unit.getDescByName(unitTypes[1])
            if desc and desc.attributes and desc.attributes.Infantry then options.speed = 1.66667 end

            -- Check position and formation for moving ground units
            if options.isMoving then
                if options.onRoad then
                    options.pointAction = "On Road"
                    vec2 = DCSEx.world.getClosestPointOnRoadsVec2(vec2)
                    destVec2 = DCSEx.world.getClosestPointOnRoadsVec2(destVec2)
                else
                    options.pointAction = options.formation or DCSEx.table.getRandom({"Rank", "Cone", "Vee", "Diamond", "EchelonL", "EchelonR"})
                end
            end

            options.livery = "default" -- TODO: getSeasonalLivery()
        elseif groupCategory == Group.Category.AIRPLANE or groupCategory == Group.Category.HELICOPTER then
            isAirUnit = true

            -- Plane/helicopter groups always use a single unit type
            for i=1,#unitTypes do
                unitTypes[i] = unitTypes[1]
            end

            -- Get unit info from aircraft database
            aircraftDB = Library.aircraft[unitTypes[1]]
            if not aircraftDB then return nil end -- Unit wasn't found in the database, abort group creation

            -- Pick a random livery if available
            -- if aircraftDB.liveries and aircraftDB.liveries[coalitionID] then
            --     options.livery = table.getRandom(aircraftDB.liveries[coalitionID])
            -- end

            options.altitude = options.altitude or aircraftDB.altitude or DCSEx.converter.feetToMeters(15000)
            options.altitudeType = "BARO"
            options.speed = DCSEx.math.randomFloat(0.9, 1.1) * (aircraftDB.speed or 250)
        end

        -- First unit of the group is a template, use a group template instead of enumerating the types in unitTypes
        local groupTemplate = nil
        if Library.groupTemplates[unitTypes[1]] then
            groupTemplate = DCSEx.table.deepCopy(Library.groupTemplates[unitTypes[1]])
            unitTypes = {}
            for i=1,#groupTemplate do
                table.insert(unitTypes, groupTemplate[i].name)
            end
        end

        -- Create group table
        local groupTable = createGroupTable(groupID, groupCategory, options)
        groupTable.x = vec2.x
        groupTable.y = vec2.y

        -- Initial waypoint
        table.insert(
            groupTable.route.points,
            {
                action = options.pointAction,
                alt = options.altitude,
                alt_type = options.altitudeType,
                ETA = 0.0,
                ETA_locked = false,
                formation_template = "",
                name = "WP1",
                speed = options.speed,
                speed_locked = true,
                task = {id = "ComboTask", params = {tasks = {}}},
                type = "Turning Point",
                x = vec2.x,
                y = vec2.y
            }
        )

        if options.takeOff and (groupCategory == Group.Category.AIRPLANE or groupCategory == Group.Category.HELICOPTER) then
            groupTable.route.points[1].alt = 750
            groupTable.route.points[1].alt_type = "RADIO"
        end

        if destVec2 then -- There's a destination, add a second waypoint
            local destPoint = {
                action = options.pointAction,
                alt_type = options.altitudeType,
                alt = options.altitude,
                ETA = 0.0,
                ETA_locked = false,
                formation_template = "",
                name = "WP2",
                speed = options.speed,
                task = {
                    id = "ComboTask",
                    params = { tasks = { } }
                },
                type = "Turning Point",
                x = destVec2.x,
                y = destVec2.y,
                speed_locked = true
            }

            -- Ground/ship groups loop between their waypoints
            if groupCategory == Group.Category.GROUND or groupCategory == Group.Category.SHIP then
                if not options.noLoop then
                    table.insert(
                        destPoint.task.params.tasks,
                        {
                            enabled = true,
                            auto = false,
                            id = "GoToWaypoint",
                            number = 1,
                            params = {
                                fromWaypointIndex = 2,
                                nWaypointIndx = 1
                            }
                        })
                end
            end

            table.insert(groupTable.route.points, destPoint)
        end

        -- Add various options/commands
        if options.disableWeapons then setOption(groupTable, AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD) end -- Values are from the AI.Option.Ground tables, but they're the same for all (ROE=0, WEAPON_HOLD=4)
        if options.immortal then setCommand(groupTable, "SetImmortal", true) end
        if options.invisible then setCommand(groupTable, "SetInvisible", true) end
        if options.silenced then setOption(groupTable, AI.Option.Air.id.SILENCE, true) end
        if options.unlimitedFuel then setCommand(groupTable, "SetUnlimitedFuel", true) end

        local groupCallsign = nil

        if isAirUnit then
            -- setOption(groupTable, AI.Option.Air.id.FORCED_ATTACK, true)
            -- setOption(groupTable, AI.Option.Air.id.RTB_ON_BINGO, false)
            if options.prohibitJettison then setOption(groupTable, AI.Option.Air.id.PROHIBIT_JETT, true) end

            if options.taskAwacs then setAircraftTaskAwacs(groupTable) end
            if options.taskCAP then setAircraftTaskCAP(groupTable) end
            if options.taskFollow then
                setAircraftTaskFollow(groupTable, options.taskFollow)
            else
                setAircraftTaskOrbit(groupTable, options)
            end

            -- For parked aircraft
            if options.airbaseID and options.parkingID then
                groupTable.route.points[1].action = "From Parking Area"
                groupTable.route.points[1].airdromeId = options.airbaseID
                groupTable.route.points[1].type = "TakeOffParking"
                groupTable.uncontrolled = true
            end

            if options.callsign then
                groupCallsign = options.callsign
            else
                groupCallsign = DCSEx.unitCallsignMaker.getCallsign(unitTypes[1])
            end

            groupTable.name = groupCallsign.name
        end

        -- Group name already exists
        while Group.getByName(groupTable.name) do
            groupTable.name = groupTable.name.."-"
        end

        local unitsID = {}

        -----------------------
        -- Create units
        -----------------------
        for i=1,#unitTypes do
            local unitID = getNextUnitID()
            table.insert(unitsID, unitID)

            local unitHeading, unitOffset

            if groupTemplate then -- Use offset and heading from the group
                unitHeading = groupTemplate[i].heading
                unitOffset = { x = groupTemplate[i].dx, y = groupTemplate[i].dy }
            else -- Create offset and heading
                unitHeading = options.heading or DCSEx.math.randomFloat(0, DCSEx.math.TWO_PI)
                unitOffset =
                DCSEx.math.multVec2(
                    DCSEx.math.getVec2FromAngle(unitHeading),
                    options.spreadDistance * (options.spreadOffset + i - 1)
                )
            end

            local unitType = unitTypes[i]

            local unitTable = {
                coldAtStart = false,
                heading = unitHeading,
                livery = options.livery,
                name = options.name.." #"..tostring(i),
                playerCanDrive = false,
                skill = options.skill,
                transportable = {randomTransportable = false},
                type = unitType,
                unitId = unitID,
                x = vec2.x + unitOffset.x,
                y = vec2.y + unitOffset.y
            }

            if options.onRoad then
                local posOnRoads = DCSEx.world.getClosestPointOnRoadsVec2(unitTable)
                unitTable.x = posOnRoads.x
                unitTable.y = posOnRoads.y
            end

            if isAirUnit and aircraftDB then
                unitTable.hardpoint_racks = true
                unitTable.psi = 1.7703702498393

                local callsignUnitIndex = i + (options.callsignOffset or 0)
                unitTable.callsign = DCSEx.table.deepCopy(groupCallsign)
                unitTable.callsign.name = unitTable.callsign.name..tostring(callsignUnitIndex)
                unitTable.callsign[3] = callsignUnitIndex
                unitTable.callsign[4] = unitTable.callsign.name
                unitTable.name = unitTable.callsign.name

                -- Special properties for unit
                unitTable.AddPropAircraft = {}
                if aircraftDB.properties then
                    unitTable.AddPropAircraft = DCSEx.table.deepCopy(aircraftDB.properties)
                end

                -- For parked aircraft
                if options.airbaseID and options.parkingID then
                    unitTable.parking = tostring(options.parkingID)
                end

                -- Setup datalink
                local datalinkString = tostring(dataLinkID)
                if #datalinkString == 3 then
                    datalinkString = "00"..datalinkString
                elseif #datalinkString == 4 then
                    datalinkString = "0"..datalinkString
                end
                unitTable.AddPropAircraft["STN_L16"] = datalinkString
                dataLinkID = dataLinkID + 1

                -- Common payload (fuel, gun ammo, etc)
                if aircraftDB.payload then
                    unitTable.payload = DCSEx.table.deepCopy(aircraftDB.payload)
                end

                if aircraftDB.pylons then
                    local payload = "attack" -- Default payload is "attack", because it's usually a good mix of A-G and A-A munitions

                    if options.payload then -- A payload was specified
                        payload = options.payload
                    else -- No payload was specified, deduce payload from tasking
                        if options.taskAntiship then
                            payload = "antiship"
                        elseif options.taskCAP then
                            payload = "cap"
                        elseif options.taskSEAD then
                            payload = "sead"
                        elseif options.taskStrike then
                            payload = "strike"
                        end
                    end

                    unitTable.payload.pylons = DCSEx.table.deepCopy(aircraftDB.pylons[payload])
                end
            end

            -- Unit name already exists
            while Unit.getByName(unitTable.name) do
                unitTable.name = unitTable.name.."-"
            end

            table.insert(groupTable.units, unitTable)
        end

        coalition.addGroup(DCSEx.dcs.getCJTFForCoalition(coalitionID), groupCategory, groupTable)

        return {
            callsign = groupCallsign,
            groupID = groupID,
            unitsID = unitsID,
            unitTypeNames = DCSEx.table.deepCopy(unitTypes) -- Not always the same as the unitTypes input parameter, because of group templates
        }
    end

    ------------------------------------------------------
    -- INITIALIZE THE GROUP MAKER
    -- Look for maximum groupID and unitID already in use to make sure we don't use an existing ID when spawning units
    ------------------------------------------------------
    local groupData = DCSEx.envMission.getGroups()

    for _,g in ipairs(groupData) do
        if g.groupId >= nextGroupID then
            nextGroupID = g.groupId + 1
        end

        for __,u in ipairs(g.units) do
            if u.unitId >= nextUnitID then
                nextUnitID = u.unitId + 1
            end
        end
    end
end
