-- ====================================================================================
-- TUM.WINGMENMENU - HANDLES THE WINGMEN'S F10 MENU
-- ====================================================================================
-- ====================================================================================

TUM.wingmenMenu = {}

do
    local function radioCommandChangeAltitude(args)
        local player = world:getPlayer()
        if not player then return end

        TUM.radio.playForAll("playerWingmanChangeAltitude", { args.altitudeText }, player:getCallsign(), false)

        TUM.wingmenTasking.commandChangeAltitude(args.altitudeFraction, true)
    end

    local function radioCommandCoverMe()
        local player = world:getPlayer()
        if not player then return end

        TUM.radio.playForAll("playerWingmanCoverMe", nil, player:getCallsign(), false)

        TUM.wingmenTasking.commandEngage(Group.Category.AIRPLANE, { "Fighters", "Interceptors", "Multirole fighters" } , true)
    end

    local function radioCommandEngage(args)
        local player = world:getPlayer()
        if not player then return end

        args.radioTargetName = args.radioTargetName or "hostile"

        TUM.radio.playForAll("playerWingmanEngage"..args.radioMessageSuffix, { args.radioTargetName }, player:getCallsign(), false)
        TUM.wingmenTasking.commandEngage(args.category, args.attributes, true)
    end

    -- local function radioCommandGoToMapMarker()
    --     local player = world:getPlayer()
    --     if not player then return end
    --     TUM.radio.playForAll("playerWingmanGoToMarker", nil, player:getCallsign(), false)

    --     TUM.wingmenTasking.commandGoToMapMarker(TUM.wingmenTasking.DEFAULT_MARKER_TEXT, true)
    -- end

    local function radioCommandOrbit()
        local player = world:getPlayer()
        if not player then return end
        TUM.radio.playForAll("playerWingmanOrbit", nil, player:getCallsign(), false)

        TUM.wingmenTasking.commandOrbit(true)
    end

    local function radioCommandRejoin()
        local player = world:getPlayer()
        if not player then return end
        TUM.radio.playForAll("playerWingmanRejoin", nil, player:getCallsign(), false)

        TUM.wingmenTasking.commandRejoin(nil, true)
    end

    local function radioCommandReportContacts()
        local player = world:getPlayer()
        if not player then return false end
        TUM.radio.playForAll("playerWingmanReportContacts", nil, player:getCallsign(), false)

        TUM.wingmenTasking.commandReportContacts(nil, false, true)
    end

    local function radioCommandReportStatus()
        local player = world:getPlayer()
        if not player then return end
        TUM.radio.playForAll("playerWingmanReportStatus", nil, player:getCallsign(), false)

        TUM.wingmenTasking.commandReportStatus(true)
    end

    function TUM.wingmenMenu.create()
        local rootMenu = TUM.getOrCreateRootMenu()
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No wingmen in multiplayer
        if TUM.settings.getValue(TUM.settings.id.WINGMEN) <= 1 then return end -- No wingmen
        local isWW2 = (TUM.settings.getValue(TUM.settings) == DCSEx.enums.timePeriod.WORLD_WAR_2) -- Some options are different when time period is WW2

        local rootPath = missionCommands.addSubMenu("✈ Flight", rootMenu)
        missionCommands.addCommand("Cover me!", rootPath, radioCommandCoverMe, nil)

        ------------------------------------------------------
        -- "Engage targets" submenu
        ------------------------------------------------------
        local engagePath = missionCommands.addSubMenu("Engage", rootPath)
        local engageSubPath = nil

        -- Aircraft -- (radioTargetName must be plural)
        engageSubPath = missionCommands.addSubMenu("Aircraft", engagePath)
        missionCommands.addCommand("Any aircraft", engageSubPath, radioCommandEngage, { attributes = nil, category = Group.Category.AIRPLANE, radioMessageSuffix = "Bandits", radioTargetName = "bandits" })
        missionCommands.addCommand("Fighters", engageSubPath, radioCommandEngage, { attributes = { "Fighters", "Interceptors", "Multirole fighters" }, category = Group.Category.AIRPLANE, radioMessageSuffix = "Bandits", radioTargetName = "fighters" })
        missionCommands.addCommand("Bombers and transports", engageSubPath, radioCommandEngage, { attributes = { "Bombers", "Transports", "AWACS" }, category = Group.Category.AIRPLANE, radioMessageSuffix = "Bandits", radioTargetName = "strategic aircraft" })
        if not isWW2 then
            missionCommands.addCommand("Helicopters", engageSubPath, radioCommandEngage, { attributes = nil, category = Group.Category.HELICOPTER, radioMessageSuffix = "Bandits", radioTargetName = "helos" })
        end

        -- Ground -- (radioTargetName must be singular)
        engageSubPath = missionCommands.addSubMenu("Ground", engagePath)
        missionCommands.addCommand("Any ground vehicles", engageSubPath, radioCommandEngage, { attributes = {"Tanks", "Trucks", "Artillery", "IFV", "APC"}, category = Group.Category.GROUND, radioMessageSuffix = "Ground", radioTargetName = "ground" })
        missionCommands.addCommand("Armor", engageSubPath, radioCommandEngage, { attributes = {"Tanks", "IFV", "APC"}, category = Group.Category.GROUND, radioMessageSuffix = "Ground", radioTargetName = "armor" })
        missionCommands.addCommand("Armor (APCs only)", engageSubPath, radioCommandEngage, { attributes = {"IFV", "APC"}, category = Group.Category.GROUND, radioMessageSuffix = "Ground", radioTargetName = "armor" })
        missionCommands.addCommand("Armor (tanks only)", engageSubPath, radioCommandEngage, { attributes = {"Tanks"}, category = Group.Category.GROUND, radioMessageSuffix = "Ground", radioTargetName = "armor" })
        missionCommands.addCommand("Artillery", engageSubPath, radioCommandEngage, { attributes = {"Artillery"}, category = Group.Category.GROUND, radioMessageSuffix = "Ground", radioTargetName = "artillery" })
        missionCommands.addCommand("Infantry", engageSubPath, radioCommandEngage, { attributes = {"Infantry"}, category = Group.Category.GROUND, radioMessageSuffix = "Ground", radioTargetName = "infantry" })
        missionCommands.addCommand("Trucks", engageSubPath, radioCommandEngage, { attributes = {"Trucks"}, category = Group.Category.GROUND, radioMessageSuffix = "Ground", radioTargetName = "truck" })

        -- Air defense -- (radioTargetName must be singular)
        engageSubPath = missionCommands.addSubMenu("Air defense", engagePath)
        missionCommands.addCommand("Any air defense", engageSubPath, radioCommandEngage, { attributes = { "Air Defence" }, category = Group.Category.GROUND, radioMessageSuffix = "AirDefense", radioTargetName = "air defense" })
        missionCommands.addCommand("AAA", engageSubPath, radioCommandEngage, { attributes = { "AAA" }, category = Group.Category.GROUND, radioMessageSuffix = "AirDefense", radioTargetName = "AAA" })
        if not isWW2 then
            missionCommands.addCommand("MANPADS", engageSubPath, radioCommandEngage, { attributes = { "MANPADS" }, category = Group.Category.GROUND, radioMessageSuffix = "AirDefense", radioTargetName = "MANPADS" })
            missionCommands.addCommand("Short range SAMs", engageSubPath, radioCommandEngage, { attributes = { "SR SAM", "IR Guided SAM" }, category = Group.Category.GROUND, radioMessageSuffix = "AirDefense", radioTargetName = "short-range SAM" })
            missionCommands.addCommand("Short range SAMs (IR only)", engageSubPath, radioCommandEngage, { attributes = { "IR Guided SAM" }, category = Group.Category.GROUND, radioMessageSuffix = "AirDefense", radioTargetName = "IR SAM" })
            missionCommands.addCommand("Short range SAMs (radar only)", engageSubPath, radioCommandEngage, { attributes = { "SR SAM" }, category = Group.Category.GROUND, radioMessageSuffix = "AirDefense", radioTargetName = "SHORAD" })
            missionCommands.addCommand("Long-range SAMs", engageSubPath, radioCommandEngage, { attributes = { "LR SAM", "MR SAM" }, category = Group.Category.GROUND, radioMessageSuffix = "AirDefense", radioTargetName = "long-range SAM" })
        end

        -- Ships -- (radioTargetName must be plural)
        engageSubPath = missionCommands.addSubMenu("Ships", engagePath)
        missionCommands.addCommand("Any ship", engageSubPath, radioCommandEngage, { attributes = nil, category = Group.Category.SHIP, radioMessageSuffix = "Ships", radioTargetName = "ships" })
        missionCommands.addCommand("Armed ships", engageSubPath, radioCommandEngage, { attributes = { "Armed ships" }, category = Group.Category.SHIP, radioMessageSuffix = "Ships", radioTargetName = "armed ships" })
        missionCommands.addCommand("Cargo ships", engageSubPath, radioCommandEngage, { attributes = { "Unarmed ships" }, category = Group.Category.SHIP, radioMessageSuffix = "Ships", radioTargetName = "cargo ships" })

        -- Structures
        missionCommands.addCommand("Structures", engagePath, radioCommandEngage, { attributes = nil, category = "strike", radioMessageSuffix = "Strike", radioTargetName = "building" })
        ------------------------------------------------------

        -- missionCommands.addCommand("Go to map marker "..TUM.wingmenTasking.DEFAULT_MARKER_TEXT:upper(), rootPath, radioCommandGoToMapMarker, nil)
        missionCommands.addCommand("Report contacts", rootPath, radioCommandReportContacts, nil)
        missionCommands.addCommand("Hold position", rootPath, radioCommandOrbit, nil)

        ------------------------------------------------------
        -- "Change altitude" submenu
        ------------------------------------------------------
        local altitudePath = missionCommands.addSubMenu("Change altitude", rootPath)
        local baseAltitude = DCSEx.converter.metersToFeet(Library.aircraft[world.getPlayer():getTypeName()].altitude)
        local altitudeFactions = { 0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5 }
        for _,f in ipairs(altitudeFactions) do
            local altText = DCSEx.string.toStringThousandsSeparator(math.floor((baseAltitude * f) / 100) * 100).."ft"
            if f == 0 then altText = "nap-of-the-earth" end
            missionCommands.addCommand(DCSEx.string.firstToUpper(altText), altitudePath, radioCommandChangeAltitude, { altitudeFraction = f, altitudeText = altText })
        end

        missionCommands.addCommand("Status report", rootPath, radioCommandReportStatus, nil)
        missionCommands.addCommand("Rejoin", rootPath, radioCommandRejoin, nil)
    end
end
