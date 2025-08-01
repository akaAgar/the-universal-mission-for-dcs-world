-- ====================================================================================
-- TUM.PLAYERCAREER - HANDLES THE PERSISTENT PILOT CAREER IN SINGLE-PLAYER MISSIONS
-- ====================================================================================
-- (local const) MAX_RIBBONS
-- (local const) MEDAL_BOX_DISPLAY_TIME
-- (local const) OBJECTIVES_PER_RIBBON
-- (local const) MEDALS
-- (local const) RANKS
-- (local table) careerStats
-- (local) fixIncompleteStats()
-- (local) getHighestMedal()
-- (local) getRibbonCount()
-- TUM.playerCareer.awardScore(score, objectives)
-- TUM.playerCareer.createMenu()
-- TUM.playerCareer.displayMedalBox(printSummary)
-- TUM.playerCareer.getCareerSummary()
-- TUM.playerCareer.load()
-- TUM.playerCareer.onStartUp()
-- TUM.playerCareer.reset()
-- TUM.playerCareer.save()
-- ====================================================================================

TUM.playerCareer = {}

do
    local MAX_RIBBONS = 40 -- Maximum number of ribbons
    local MEDAL_BOX_DISPLAY_TIME = 15 -- in seconds
    local OBJECTIVES_PER_RIBBON = 4 -- How many completed objectives to gain a new ribbon?

    local MEDALS = {
        { "Air medal", 150 },
        { "Bronze star", 225 },
        { "Airman's medal", 300 },
        { "Distinguished Flying Cross", 375 },
        { "Silver Star for Valor", 450 },
        { "Air Force Cross", 525 },
        { "Congressional Medal of Honor", 600 },
    }

    local RANKS = {
        { "2d Lt.", "Second lieutenant", 0 },
        { "1st Lt.", "First lieutenant", 400 },
        { "Capt.", "Captain", 1600 },
        { "Maj.", "Major", 6400 },
        { "Lt Col.", "Lieutenant colonel", 16000 },
        { "Col.", "Colonel", 32000 },
    }

    local careerStats = {}

    -------------------------------------
    -- Adds missing fields, if any, to the careerStats table
    -------------------------------------
    local function fixIncompleteStats()
        if not careerStats then careerStats = { } end
        if not careerStats.bestSortie then careerStats.bestSortie = 0 end
        if not careerStats.completedObjectives then careerStats.completedObjectives = 0 end
        if not careerStats.completedSorties then careerStats.completedSorties = 0 end
        if not careerStats.medals then careerStats.medals = 0 end
        if not careerStats.medalWounded then careerStats.medalWounded = false end
        if not careerStats.rank then careerStats.rank = 1 end
        if not careerStats.score then careerStats.score = 0 end
        careerStats.version = TUM.VERSION_NUMBER
    end

    -------------------------------------
    -- Returns the highest medal a player has obtained for scoring a high number of points during a single sortie
    -- @return A number (index in the MEDALS table)
    -------------------------------------
    local function getHighestMedal()
        local medal = 0
        for i=1,#MEDALS do
            if careerStats.bestSortie >= MEDALS[i][2] then
                medal = i
            end
        end

        return medal
    end

    -------------------------------------
    -- Returns the current number a ribbons a player was awarded for completing objectives
    -- @return A number
    -------------------------------------
    local function getRibbonCount()
        return DCSEx.math.clamp(math.floor(careerStats.completedObjectives / OBJECTIVES_PER_RIBBON), 0, MAX_RIBBONS)
    end

    -------------------------------------
    -- Awards career points. Only works in single-player missions
    -- @param score Number of career points to award
    -- @param objectives Number of completed objectives to award
    -- @return True if a ribbon, medal or promotion was awarded, false otherwise
    -------------------------------------
    function TUM.playerCareer.awardScore(score, objectives)
        if not DCSEx.io.canReadAndWrite() then return false end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return false end -- No career in multiplayer
        score = math.max(0, math.floor(score or 0))

        fixIncompleteStats()

        local oldRibbonCount = getRibbonCount()
        careerStats.bestSortie = math.max(careerStats.bestSortie, score)
        careerStats.score = careerStats.score + score
        careerStats.completedObjectives = careerStats.completedObjectives + objectives
        trigger.action.outText(DCSEx.string.toStringThousandsSeparator(score).." xp and "..tostring(objectives).." completed objective(s) were registered in your flight log.", 5)
        local newRibbonCount = getRibbonCount()

        local somethingWasAwarded = false

        -- Check for promotions
        if careerStats.rank < #RANKS and careerStats.score >= RANKS[careerStats.rank + 1][3] then
            careerStats.rank = careerStats.rank + 1
            somethingWasAwarded = true
            trigger.action.outText("✪ You have been promoted to the rank of "..RANKS[careerStats.rank][2]..".", MEDAL_BOX_DISPLAY_TIME)
        end

        -- Check for medals
        for i=1,#MEDALS do
            if i > careerStats.medals and score >= MEDALS[i][2] then
                trigger.action.outText("✪ You have been awarded the "..MEDALS[i][1]..".", MEDAL_BOX_DISPLAY_TIME)
                careerStats.medals = i
                somethingWasAwarded = true
                break
            end
        end

        -- Check for ribbons
        if newRibbonCount > oldRibbonCount then
            trigger.action.outText("✪ You have been awarded a battle ribbon.", MEDAL_BOX_DISPLAY_TIME)
            somethingWasAwarded = true
        end

        TUM.playerCareer.save()

        if somethingWasAwarded then
            TUM.playerCareer.displayMedalBox(false)
        end

        TUM.playerScore.reset(false)

        return somethingWasAwarded
    end

    -------------------------------------
    -- Appends the career menu to the F10 menu. Only works in single-player missions
    -------------------------------------
    function TUM.playerCareer.createMenu()
        local rootMenu = TUM.getOrCreateRootMenu()
        if not DCSEx.io.canReadAndWrite() then return end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No career in multiplayer

        missionCommands.addCommand("✪ View pilot career stats", rootMenu, TUM.playerCareer.displayMedalBox, true)
    end

    -------------------------------------
    -- Displays the player's medal box and carrer summary. Only works in single-player missions
    -------------------------------------
    function TUM.playerCareer.displayMedalBox(printSummary)
        if not DCSEx.io.canReadAndWrite() then return end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No career in multiplayer
        fixIncompleteStats()

        if printSummary then
            trigger.action.outText(TUM.playerCareer.getCareerSummary(), MEDAL_BOX_DISPLAY_TIME, true)
        end

        DCSEx.dcs.outPicture("Pic-MedalBox.png", MEDAL_BOX_DISPLAY_TIME, true, 0, 2, 2, 50, 1)
        DCSEx.dcs.outPicture("Pic-Rank"..tostring(careerStats.rank)..".png", MEDAL_BOX_DISPLAY_TIME, false, 0, 2, 2, 50, 1)

        local ribbonCount = getRibbonCount()
        for i=1,ribbonCount do
            DCSEx.dcs.outPicture("Pic-Ribbon"..tostring(i)..".png", MEDAL_BOX_DISPLAY_TIME, false, 0, 2, 2, 50, 1)
        end

        for i=1,careerStats.medals do
            DCSEx.dcs.outPicture("Pic-Medal"..tostring(i)..".png", MEDAL_BOX_DISPLAY_TIME, false, 0, 2, 2, 50, 1)
        end
        trigger.action.outSound("UI-Career.ogg")
    end

    -------------------------------------
    -- Returns the player career summary as a string. Only works in single-player missions
    -- @return A string
    -------------------------------------
    function TUM.playerCareer.getCareerSummary()
        if not DCSEx.io.canReadAndWrite() then return "" end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return "" end -- No career in multiplayer
        fixIncompleteStats()

        local playerName = "Player"
        local players = DCSEx.world.getAllPlayers()
        if #players > 0 then
            playerName = players[1]:getPlayerName()
        end

        local summary = ""
        summary = summary.."CAREER STATS FOR "..RANKS[careerStats.rank][1]:upper().." "..playerName:upper()..":\n"
        summary = summary.."=======================\n"
        summary = summary.."- Rank: "..RANKS[careerStats.rank][2].."\n"
        summary = summary.."- Best sortie XP: "..DCSEx.string.toStringThousandsSeparator(careerStats.bestSortie).."\n"
        summary = summary.."- Total career XP: "..DCSEx.string.toStringThousandsSeparator(careerStats.score).."\n"
        summary = summary.."- Completed objectives: "..tostring(careerStats.completedObjectives).."\n"

        if careerStats.medals == 0 then
            summary = summary.."- Medals: None"
        else
            summary = summary.."- Medals:"
            for i=1,careerStats.medals do
                summary = summary.."\n  - "..MEDALS[i][1]
            end
        end

        local ribbonCount = getRibbonCount()
        if ribbonCount < MAX_RIBBONS or careerStats.rank < #RANKS or careerStats.medals < #MEDALS then
            summary = summary.."\n"

            if careerStats.rank < #RANKS then
                summary = summary.."\n- Next promotion: "..DCSEx.string.toStringThousandsSeparator(RANKS[careerStats.rank + 1][3]).." xp"
            end

            if ribbonCount < MAX_RIBBONS then
                summary = summary.."\n- Next ribbon: "..tostring((ribbonCount + 1) * OBJECTIVES_PER_RIBBON).." objectives"
            end

            if careerStats.medals < #MEDALS then
                summary = summary.."\n- Next medal: "..DCSEx.string.toStringThousandsSeparator(MEDALS[careerStats.medals + 1][2]).." xp in a single flight"
            end
        end

        return summary
    end

    -------------------------------------
    -- Loads the player career from the disk. Only works in single-player missions
    -- @return True if everything worked (or disabled because of MP), false if an error happened
    -------------------------------------
    function TUM.playerCareer.load()
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return true end -- No career in multiplayer
        if not DCSEx.io.canReadAndWrite() then return false end

        local jsonString = DCSEx.io.load("TheUniversalMission.sav")
        if jsonString then
            -- TODO: what if Json is malformed?
            careerStats = net.json2lua(jsonString)
            if not careerStats then
                careerStats = {}
                fixIncompleteStats()
                TUM.log("Failed to load player career data, career data reset.")
            else
                TUM.log("Player career data loaded successfully.")
            end
        else
            fixIncompleteStats()
            return false
        end

        fixIncompleteStats()
    end

    -------------------------------------
    -- Called on mission start up
    -- @return True if started up properly, false if an error happened
    -------------------------------------
    function TUM.playerCareer.onStartUp()
        fixIncompleteStats()
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return true end -- No career in multiplayer

        if DCSEx.io.canReadAndWrite() then
            TUM.log("Lua IO module available, can read and write.")
            TUM.playerCareer.load()
        else
            local msg = "IO module is disabled, CANNOT read and write persistant data. Player progress will NOT be saved.\n"
            msg = msg.."To enable the IO module, comment or remove the \"sanitizeModule('io')\" line in \n"
            msg = msg.."[DCSWorld installation directory]\\Scripts\\MissionScripting.lua and restart the game."

            TUM.log(msg, TUM.logLevel.WARNING)
        end

        return true
    end

    -------------------------------------
    -- Resets the player career stats and save them. Only works in single-player missions
    -------------------------------------
    function TUM.playerCareer.reset()
        if not DCSEx.io.canReadAndWrite() then return end -- IO disabled, career and scoring disabled
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No career in multiplayer

        careerStats = nil
        fixIncompleteStats()
        TUM.playerCareer.save()
    end

    -------------------------------------
    -- Save the player career to the disk. Only works in single-player missions
    -- @return True if everything worked (or disabled), false if an error happened
    -------------------------------------
    function TUM.playerCareer.save()
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return true end -- No career in multiplayer
        if not DCSEx.io.canReadAndWrite() then return true end -- IO disabled, career and scoring disabled

        fixIncompleteStats()

        if DCSEx.io.save("TheUniversalMission.sav", net.lua2json(careerStats)) then
            return true
        else
            return false
        end
    end
end
