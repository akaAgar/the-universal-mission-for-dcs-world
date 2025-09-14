Library.radioMessages = {
    pilotEjecting = {
        "Mayday, mayday! Taking fire, punching out now!",
        "Engine's gone, I'm bailing! Mark my chute!",
        "Bird's on fire, I'm out, call SAR!",
        "Control's dead, ejecting! Watch for the seat!",
        "Lost hydraulics, can't hold her! Bailing out!"
    },
    pilotImHit = {
        "I'm hit!",
        "Taking fire!",
        "Bird's hurt, trying to hold altitude!",
        "Impact on fuselage, took a solid hit!",
        "Taking damage, warning lights all over!"
    },
    pilotKillAir = {
        "Splash one $1. Rejoining.",
        "Good hit, $1 down! Checking six.",
        "$1 down. I say again, splash one!",
        "Kill confirmed. $1's smoking.",
        "Splash one $1! Got him!",
        "Splash confirmed! Repeat, $1 down.",
        "$1 smoked, good kill.",
        "$1 splashed, no chute seen."
    }, -- "$1" should be "bandit" in audio version
    pilotKillGround = {
        "Splash one $1, repeat, target down. Eyes open for secondaries.",
        "$1 neutralized, big boom. Watch your altitude, debris kicking up.",
        "$1's a fireball, one less on the ground. Moving to next grid.",
        "Jackpot on that $1, burning good. Stay sharp for air defense.",
        "Scratch one $1, repeat scratch one.",
        "$1's toast, good effect on target. Rolling out.",
        "Got the $1, solid hit. Watch for air defense in that sector.",
        "Splash $1, good kill.",
        "$1's cooked, smoke's up."
    }, -- "$1" should be "vehicle" in audio version
    pilotKillInfantry = {
        "$1 neutralized.",
        "Enemy $1 taken out.",
        "Good effects on $1.",
        "Confirmed hit, $1 down.",
        "$1 position destroyed."
    }, -- "$1" should be "infantry" in audio version
    pilotKillShip = {
        "Splash confirmed! Enemy $1 going under.",
        "Direct hit! $1 burning and breaking up.",
        "$1's out of the fight! Big secondary explosion, she's listing hard.",
        "$1 neutralized, heavy smoke and debris in the water.",
        "Splash confirmed! Hull's cracking, $1's going down.",
        "$1's gone! Big fireball, multiple secondaries.",
        "$1's dead in the water! Zero movement on deck."
    }, -- "$1" should be "ship" in audio version
    pilotKillStrike = {
        "Target's gone, good splash. Structure's burning, over.",
        "Direct hit, building's collapsing. No secondary fire yet.",
        "Objective neutralized, smoke's up. Moving to egress.",
        "Good impact on target, structure is down.",
        "Target destroyed, heavy debris in the AO.",
        "Target's leveled, no movement inside.",
        "Structure is toast, solid hit.",
        "Good hit, building's breaking apart."
    },

    pilotLaunchGuns = { "Guns!", "Guns, guns!" },
    pilotLaunchBruiser = "Bruiser!",
    pilotLaunchFox1 = { "Fox 1!", "Fox 1!", "Fox 1, tracking bandit." },
    pilotLaunchFox2 = { "Fox 2!", "Fox 2!", "Fox 2, missile tracking." },
    pilotLaunchFox3 = { "Fox 3!", "Fox 3!", "Fox 3, cranking now." },
    pilotLaunchMagnum = "Magnum!",
    pilotLaunchPickle = { "Pickle!", "Bomb away!" },
    pilotLaunchRifle = { "Rifle!", "Missile away!"},
    pilotLaunchRocket = "Rockets!",

    pilotNewFriendlyAircraft = {
        "$1 CAP launched from $2, we're heading toward AO.",
        "$1 CAP just wheels-up from $2, we'll soon be on station.",
        "$1 airborne from $2, we're pushing to cover your AO.",
        "$1 CAP launched from $2, expect blue air in your vicinity shortly.",
        "$1 departed $2, we're setting up CAP near you."
    },

    pilotWarningAAA = { "Heads up, I'm seeing tracers. AAA fire.", "AAA lighting up, stay high.",  "Flight, we've got heavy flak incoming, break!", "AAA tracer fire, they've got our range, don't stay straight!", "AAA's hot under us. Stay fast, don't linger!" },
    pilotWarningMANPADS = { "MANPADS launch! Flare, flare, flare!", "Flight, MANPADS in the air. Dump flares, now!", "Coming from the ground, MANPADS hot!", "Go defensive, MANPADS off your nose! Flare, flare!", "MANPADS just came up from the deck, break hard and pop everything!" },
    pilotWarningSAMLaunch = { "Spike! SAM just launched, break!", "SAM up! Defensive now!", "Launch! SAM, coming fast, pump chaff, go cold!", "SAM in the air, break hard!", "SAM fired, visual smoke! Extend, extend!" },

    pilotWingmanChangeAltitude = {
        "$1, copy, adjusting now to $2.",
        "$1, roger, setting new altitude to $2.",
        "$1, altitude change confirmed, $2.",
        "$1, roger that, moving to new block at $2.",
        "$1, adjusting as ordered to $2."
    },
    pilotWingmanDown = {
        "$1! I'm hit bad! I can't hold it! Punching out now!",
        "$1! Mayday! Mayday! I'm on fire! Ejecting, ejecting!",
        "$1! They got me! Left wing's gone! I'm getting out!",
        "$1! They nailed me, fire in the pit! I'm outta here!",
        "$1! Fire in the cockpit! Can't see anything! Ejecting!",
        "$1! Mayday! No control! This is it, ejecting now!"
    },
    pilotWingmanEngageAir = {
        "$1, copy, engaging $2 now ($3).",
        "$1, tally one, pressing on $2 ($3).",
        "$1, roger, committing on $2 ($3).",
        "$1, confirm, going after $2 ($3).",
        "$1, affirm, moving in on $2 ($3)."
    }, -- "$2" should be "bandits" in audio version
    pilotWingmanEngageNoTarget = {
        "$1, negative tally, unable engage.",
        "$1, cannot comply, blind on target.",
        "$1, no joy on targets, cannot proceed.",
        "$1, negative contact, unable to commit.",
        "$1, that's a no, not seeing any targets."
    },
    pilotWingmanEngageStrike = {
        "$1, copy, engaging target structure ($2).",
        "$1, roger, moving in on the building now ($2).",
        "$1, copy that, setting up for strike ($2)."
    },
    pilotWingmanEngageSurface = {
        "$1, engaging $2 threat ($3).",
        "$1, rolling in on $2 position ($3).",
        "$1, affirm, moving in on $2 ($3).",
        "$1, on target, commencing attack on $2 ($3).",
        "$1, weapons hot, engaging $2 ($3).",
    }, -- "$2" should be "target" in audio version
    -- pilotWingmanGoToMarker = {
    --     "$1, copy. Pushing to waypoint now.",
    --     "$1, on route to the coords, maintaining current alt.",
    --     "$1, proceeding as briefed, on my way.",
    --     "$1, moving to grid as planned.",
    --     "$1, heading to the point."
    -- },
    -- pilotWingmanGoToMarkerNoMarker = {
    --     "$1, negative on coords, say again?",
    --     "$1, copy, but I don't have the point. Confirm?",
    --     "$1, can't push, no steerpoint."
    -- },
    pilotWingmanOrbit = {
        "$1. Wilco, holding here.",
        "$1. Copy, orbiting now.",
        "$1. Roger, in the hold.",
        "$1. Affirm, setting up the orbit.",
        "$1. Orbiting at position."
    },
    pilotWingmanRejoin = {
        "$1, off the perch, rejoining your side.",
        "$1, tally visual, coming to you.",
        "$1, clear, rejoining to route.",
        "$1, pushing up to formation.",
        "$1, visual, sliding back into position."
    },
    pilotWingmanRejoinTaskComplete = {
        "Tasking complete, moving to your wing.",
        "Task done, closing back on you.",
        "Work's done, moving to rejoin.",
        "Finished here, rejoining formation.",
        "Tasking handled, rejoining now."
    },
    pilotWingmanReportContacts = {
        "$1, tally contacts.$2",
        "$1, tally groups, pushing details.$2",
        "$1, visual on targets.$2",
        "$1, eyes on units.$2",
        "$1, contacts hot.$2",
        "$1, eyes on possible targets.$2",
        "$1, got activity out here.$2",
        "$1, picking something up.$2",
        "$1, contact confirmed.$2",
    },
    pilotWingmanReportContactsNew = {
        "Heads up, new contacts just popped up.$2",
        "Look out, tally fresh threats.$2",
        "Stay sharp, eyes on new group.$2",
        "Eyes open, additional threats spotted.$2",
        "Stay alert, new activity in our sector.$2",
        "Be aware, got more targets popping up.$2",
        "Fresh contacts out there, watch your sector.$2",
        "Stay focused, another set of contacts just popped.$2",
        "Tally something new, check your surroundings.$2",
    },
    pilotWingmanReportContactsNoJoy = {
        "$1, negative contacts.",
        "$1, clean all sectors.",
        "$1, sensors are clean.",
        "$1, nothing showing on my end.",
        "$1, area looks clear.",
    },
    pilotWingmanReportStatus = {
        "$1, status check coming up.\n\n$2",
        "$1, sending full sitrep now.\n\n$2",
        "$1, giving you flight status.\n\n$2",
        "$1, pushing current status.\n\n$2",
        "$1, copy, reporting in.\n\n$2"
    },
    pilotWingmanTakeOff = {
        "$1, wheels up, coming to join on your six.",
        "$1 airborne, joining on your side.",
        "$1 just lifted, moving to formation.",
        "$1, off the strip, coming to your wing.",
        "$1, off the deck, forming up now."
    },

    atcRequireNearestAirbase = {
        "Roger. Vectoring you to the nearest airbase.\n\n$1",
        "Copy. Coordinates to nearest field inbound.\n\n$1",
        "Roger. Guide you direct to the nearest recovery airfield.\n\n$1"
    },
    atcRequireNearestAirbaseNone = "No friendly airbase is available at the moment.",
    atcWeatherUpdate = {
        "Roger. Weather info coming up now.\n\n$1",
        "Copy. Weather report inbound.\n\n$1",
        "This is control, checking conditions now.\n\n$1",
        "Copy. Weather data on the way.\n\n$1"
    },
    atcSafeLanding = { "Be advised: $1 is wheels down at $2 and clear of runway.", "All aircraft, $1 has landed at $2 and vacated active. Runway is open for next inbound.", "Traffic, $1 is on deck at $2 and heading to parking. Runway clear.", "All flights, $1 just rolled out at $2 and cleared the active.", "Heads up, $1 landed at $2 and moving to the ramp. Runway available for next approach." },
    atcSafeLandingPlayer = { "$1, wheels on deck, welcome back. You may taxi to the parking area.", "$1, good copy on landing. Exit when able, proceed to the parking area.", "$1, touchdown confirmed. Continue to parking.", "$1, welcome home. Clear of runway and taxi to parking area.", "$1, nice landing. Taxi to parking when ready." },

    awacsPicture = {
        "$1, picture's up.$2",
        "$1, sending updated picture.$2",
        "$1, picture transmitted.$2",
        "$1, sending picture, over.$2",
        "$1, picture is live.$2",
    },
    awacsPictureClear = { "$1, picture clear.", "$1, picture is clean.", "$1, picture clear, nothing airborne.", "$1, picture clean at this time." },

    commandBlueOnBlue =
    {
        "Check fire! You hit a friendly!",
        "Break, break! You just tagged blue!",
        "Abort! You hit a friendly asset!",
        "Cease fire, check your IFF!",
        "Blue-on-blue, blue-on-blue!",
    },
    commandFriendlyDown = {
        "All flights, we lost a friendly. $1 is down. Eyes open, hostiles still active in the area.",
        "Friendly bird down, I repeat, friendly bird down. $1 went cold. Stay sharp, possible threat still live.",
        "All squadrons, heads up. $1 just took a hit and is down hard. Keep it tight.",
        "We've lost $1. No chute sighted. Threat's still out there.",
        "Friendly down. $1 is out of the fight. Maintain altitude discipline and check six.",
    },
    commandFriendlyPilotOnGround = "Ejected pilot is stranded on the ground. Launch CSAR operations immediately.",
    commandNewEnemyAircraft = {
        "Be advised, enemy fighters airborne from $2, heading unknown.",
        "To all flights, enemy fighters just launched from $2, expect contact in your sector.",
        "Flights, bogeys off $2, monitor radar and standby.",
        "Enemy birds wheels-up from $2, likely pushing toward your AO.",
        "Hostile aircraft launch confirmed from $2, maintain alert status."
    },
    commandMissionComplete = {
        "All flights, mission objectives confirmed complete. You're clear to RTB.",
        "All leads, targets neutralized. Good work out there. Proceed to home plate.",
        "All squadrons, job's done. Exit the AO on your current route and check in with tower on approach for recovery.",
        "All flights, tasking is finished. Return to base, tower will advise final.",
        "All squadrons, good job, we're outta here. Break off and RTB."
    },
    commandObjectiveComplete = {
        "All callsigns, objective $1 complete. Proceed to next objective.",
        "All flights, objective $1 is in the bag. Move to next phase as briefed.",
        "Flight leads, objective $1 secured. You're clear to proceed with the remainder.",
        "Work's done on objective $1. Push on to your next set.",
        "All flights, objective $1 wrapped, keep on the good work.",
        "All callsigns, objective $1's done. Proceed direct to next waypoint."
    },

    commandObjectiveCoordinates = "Copy, navigational assist for objective $1.\n\n$2",
    commandObjectiveCoordinatesPrecise = "Copy, navigational assist for objective $1.\n\n$2",

    commandObjectivesManyLeft = {
        "Stay focused, people. We still have work to do.\n\n$1",
        "Our work is not done yet, we have a lot to do.\n\n$1",
        "Flights, you've got a couple of tasks left, keep moving down the list.\n\n$1",
        "Still a few objectives outstanding, don't break until they're complete.\n\n$1",
        "Alright people, keep your focus, more work ahead before you can head home.\n\n$1",
        "All flights, maintain timeline. You've got more boxes to check before RTB.\n\n$1"
    },
    commandObjectivesOneLeft = {
        "All flights, you've got one last task before you're done.\n\n$1",
        "Flights, almost home. One objective remaining, then you're RTB.\n\n$1",
        "All flights, you're down to the final push. Complete this and you're done.\n\n$1",
        "All leads, one more on the board. Finish it and head back to base.\n\n$1",
        "Flights, you're not clear yet. One last objective to wrap up.\n\n$1",
        "Come on people, one last push and we're done.\n\n$1",
        "Just one objective to complete and we're done.\n\n$1"
    },

    jtacSmokeOK = {
        "$1, target marked with $2 smoke, over.",
        "$1, $2 smoke out, standby for visual confirmation.",
        "$1, target marked, $2 smoke on deck.",
        "$1, mark complete, look for $2 smoke north of the road.",
        "$1, $2 smoke is up, call visual when you have it."
    },
    jtacSmokeNoTarget = {
        "$1, no target to mark at this time, over.",
        "$1, negative mark, no target.",
        "$1, no joy on target, unable to mark.",
        "$1, no mark available, stand by for update.",
        "$1, negative smoke, target not established."
    },
    jtacSmokeAlreadyOut = {
        "$1, target already marked, smoke on deck.",
        "$1, mark's up, resmoke already in place, over.",
        "$1, smoke is already out, advise when visual.",
        "$1, you're good, mark is already on the target.",
        "$1, target already marked with smoke."
    },

    playerATCRequireNearestAirbase = {
        "Control, request vectors to nearest suitable base for recovery.",
        "Control, requesting nearest friendly airfield for landing, over.",
        "Control, negative on original destination, request alternate field nearest current position.",
        "Control, requesting location and frequency for closest towered airfield."
    },
    playerATCWeatherUpdate = {
        "Control, request latest weather update, over.",
        "Control, need current weather and visibility.",
        "Control, what's the weather looking like out there?",
        "Control, checking weather, particularly wind.",
    },

    playerAwacsBogeyDope = { "$1, request bogey dope.", "$1, bogey dope." },
    playerAwacsPicture = { "$1, request picture.", "$1, picture when able.", "$1, need a picture.", "$1, request full picture.", "$1, picture update." },
    playerCommandMissionStatus = {
        "Command, request update on mission status.",
        "Command, request SITREP on current mission status, over.",
        "Command, how's the mission picture? Any updates?",
        "Command, confirm progress on objectives, over.",
        "Command, need an update on situation, what's the status?",
        "Command, mission timeline check, are we on schedule?"
    },

    playerCommandRequireObjectives = {
        "Command, request objective $1 coordinates, over.",
        "Command, send me grid for objective $1.",
        "Command, need objective $1 location, over.",
        "Command, pass coordinates for objective $1.",
        "Command, confirm grid on objective $1."
    },
    playerWingmanChangeAltitude = {
        "Flight, adjust your altitude to $1.",
        "Flight, set new altitude to $1.",
        "Flight, stabilize at $1.",
        "Flight, update altitude profile to $1.",
        "Flight, altitude correction, go to $1."
    },
    playerWingmanCoverMe = {
        "Flight, need cover now.",
        "Flight, keep my six clean.",
        "Flight, engaged defensive, cover me!",
        "Flight, break off and clear my tail.",
        "Flight, keep bandits off me."
    },
    playerWingmanEngageAirDefense = {
        "Flight, prioritize $1, engage now.",
        "Flight, take down $1 systems.",
        "Flight, suppress $1 threats.",
        "Flight, $1 is yours, take it out.",
        "Flight, eliminate $1 positions."
    }, -- "$1" should be "air defense" in audio version
    playerWingmanEngageBandits = {
        "Flight, engage $1.",
        "Flight, you're cleared hot on $1.",
        "Flight, commit on $1 when ready.",
        "Flight, engage $1, your discretion.",
        "Flight, you're free to engage $1."
    }, -- "$1" should be "bandits" in audio version
    playerWingmanEngageGround = {
        "Flight, engage $1 targets.",
        "Flight, prosecute $1 targets ahead.",
        "Flight, engage all $1 contacts.",
        "Flight, strike $1 positions.",
        "Flight, take the lead on $1 targets.",
    }, -- "$1" should be "ground" in audio version
    playerWingmanEngageShips = {
        "Flight, engage enemy $1 now.",
        "Flight, strike $1 in your sector.",
        "Flight, take the lead on enemy $1.",
    }, -- "$1" should be "ships" in audio version
    playerWingmanEngageStrike = {
        "Flight, take out target building.",
        "Flight, hit target structure.",
        "Flight, clear to hit target building.",
        "Flight, strike target building, confirm visual.",
    },
    -- playerWingmanGoToMarker = {
    --     "Flight, proceed to waypoint.",
    --     "Flight, push to the hold point now.",
    --     "Flight, push to station and hold.",
    --     "Flight, set up in the assigned area.",
    --     "Flight, move to designated steerpoint."
    -- },
    playerWingmanOrbit = {
        "Flight, orbit at position.",
        "Flight, set up an orbit.",
        "Flight, hold on position.",
        "Flight, anchor on current position.",
        "Flight, orbit overhead."
    },
    playerWingmanRejoin = {
        "Flight, rejoin my side.",
        "Flight, push it up, rejoin formation.",
        "Flight, come back to route.",
        "Flight, tighten it up.",
        "Flight, rejoin tactical."
    },
    playerWingmanReportContacts = {
        "Flight, tally anything?",
        "Flight, got any hits?",
        "Flight, eyes or sensors on anything?",
        "Flight, see anything out there?",
        "Flight, any contacts your side?",
    },
    playerWingmanReportStatus = {
        "Flight, confirm you're set.",
        "Flight, how are you looking?",
        "Flight, report in.",
        "Flight, status check.",
        "Flight, talk me through your state."
    },
    playerJTACSmoke = {
        "$1, request smoke on objective $2, over.",
        "$1, mark objective $2 with smoke, how copy?",
        "$1, need a smoke mark on objective $2, standby for talk-on.",
        "$1, can you pop smoke on objective $2? Need visual confirmation.",
        "$1, give me a smoke mark near objective $2, confirm when ready.",
    },
}
