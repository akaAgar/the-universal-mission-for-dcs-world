# The Universal Mission for DCS World

**Current version: open beta 0.3.250914** (see the "version history" section at the end of this file for a list of the latest changes)

**This is a BETA version, there may be bugs and there WILL be unbalanced stuff.**

The Universal Mission for DCS World is a fully dynamic single-player/PvE mission giving access to the whole content of DCS World.

### Features

- Can generate any kind of mission: ground attack, interception, strike, airbase attack, CAS, CAP, and more
- Completely dynamic, no two missions are ever the same
- Entirely self-contained inside a .miz file, no need for any external program
- More than 325 voiced radio messages for immersive and realistic coms
- Supports both single-player and small-scale PvE on closed servers
- Persistent single player career mode, with awards and promotions. Dying won't reset your progress, but you have to come back to base alive for your kills and completed objectives to be saved to your profile, so watch out for SAMs on your way home
- All new AI wingman system, smarter and more immersive than DCS's original wingmen
- Uses advanced DCS World scripting functionalities (like the brand new Disposition singleton and net.dostring_in hacks) to achieve effects seldom seen in other scripts, such as graphic overlays and random but realistic placement of units in cities and forests without the use of handmade spawn points
- Various little details to make the DCS world more alive, like crew running away from destroyed vehicles

[![Screen shot of the mission settings menu](./docs/mission-settings-tn.jpg)](./docs/mission-settings.jpg)
[![Screen shot of the target zone system](./docs/target-zones-tn.jpg)](./docs/target-zones.jpg)
[![Screen shot of the career mode's medal case display](./docs/career-mode-tn.jpg)](./docs/career-mode.jpg)

#### Limitations of current beta version

**Please read the "planned development" section below for more information.**

- The current version supports only modern (post-Cold War) units and Caucasus, Germany, Kola, Marianas, Persian Gulf and Syria theaters
- Not all mission types are supported yet
- Career progress may be lost because of future updates, don't get too attached to it

<h4>Known bugs in latest release</h4>

- AWACS datalink info not displayed properly on SA pages

## How to use/play The Universal Mission?

**Please refer to the [User's manual](https://github.com/akaAgar/the-universal-mission-for-dcs-world/blob/main/The%20Universal%20Mission%20-%20User's%20Manual.md) for additional information.**

### First setup

- Download the latest release from this GitHub page.
- Copy the provided autoexec.cfg file to your **[Saved Games]\DCS\Config directory**
  - Please note: as of DCS 2.9.18.12899, it seems the autoexec.cfg file [is no longer needed](https://www.digitalcombatsimulator.com/en/news/changelog/release/2.9.18.12899/) but I advise you to copy it anyway, ED might change its mind again.
- Copy the .miz files for your theater(s) of choice to your **[Saved Games]\DCS\Missions directory**
- _**(Optional but strongly recommended)**_ Unsanitize the Lua IO module. You don't have to do this, but the persistent career system won't work if you don't. To do it, open the file **[DCS World installation directory]\Scripts\MissionScripting.lua** with a text editor and comment or remove the line "sanitizeModule('io')". Make sure you restart DCS World once you've modified the file.
  - Please note: should you want to backup, delete or transfer it, career progress is saved in **[DCS World installation directory]\TheUniversalMission.sav**

### Customizing the mission to your taste

- _**(Optional but you'll probably want to do it)**_ Open the .miz file in the DCS World mission editor and change the player unit to pick your desired aircraft. The default player unit is a Su-25T (as it is the only free DCS airplane equipped with weapons) and you probably won't want to stick with it.

Please refer to the "Advanced stuff you may want to try" section to learn all the ways you can customize The Universal Mission.

### Starting the mission

- Launch the mission from the mission editor or the "Mission" selection in the main DCS World menu
- You are now on the ramp or runway. Open the communication menu (see "Using the mission menu" below) and navigate to the F10/Other menu. From there, you can view and change mission settings. They include:
  - Who belong to the blue and red coalitions
  - The type of mission
  - The number and location of targets (you can use the F10 map to see where the available target zones are located).
  - The amount of enemy air force and air defense. The higher these settings, the more XP you'll recieve upon completion of a single-player mission
- When you're ready, pick the "Begin mission" option, wait a few seconds (precaching all the game assets can take some time, especially if you have a slow CPU), you're ready to go!
- Use the F10 mission and check the F10 map for additional information about the mission (see "Using the mission menu" below). Don't forget to come back to base alive, all awarded XP and completed objectives will only be saved to your pilot profile once you've landed

### A few notes regarding multiplayer

While The Universal Mission supports multiplayer and is perfectely suitable (and fun!) for playing with friends on a private server, it is **absolutely not suited for public servers** as missions settings can be edited by anyone at any time Using the mission menu.
Please also note that PvP is not supported at the moment and that the mission will not launch if both coalitions have player slots.

## Planned development

<h3>Planned for next version (can be subject to change)</h3>

- Additional content
  - [ ] More objectives types
    - [ ] Helicopter-specific tasking (land and pick up units, suppress infantry...)
    - [x] Helicopter hunt
    - [ ] Offensive counter-air
- Balance improvements
  - [ ] Tweaked XP requirements for medals/promotions
- Bug fixes
  - [x] AWACS datalinked now showing on SA pages
  - [x] AWACS can now detect enemy helicopters
- Extras
  - [ ] GitHub page
- Improvements
  - [ ] Better weather reports (cloud cover, rain, etc)
- Misc
  - [x] AWACS unit now spawned when mission is loaded
- New features
  - [ ] Administrative settings menu
  - [ ] Friendly air defenses
- Quality of life/minor tweaks
  - [ ] AI wingmen "Two was shot down!" call when witnessing another wingman killed
  - [ ] AI wingmen "Winchester!" call when out of ammo

### High priority

- Additional/improved radio messages
  - More "flavor" radio messages ("fence in" when player approaches the AO, etc) so the world will feel more alive
- Better balancing of the player career awards and promotions
- Better use of context for "ambient" radio messages (should only warn of a SAM launch if an AI pilot is there to witness it, etc)
- Improved score multiplier taking into account various aspects of mission difficulty (weather, nighttime ops...)
- Laser designation of targets by JTAC
- New objectives: helicopter (drop/pickup units...), CAP, CAS
- Support for all missing DCS World theaters
- Support for more factions and five different time periods (World War 2, Korea war, Vietnam war, late Cold war, Modern)

### Medium priority

- Combined Arms support
- Modded units support (other than player-controlled aircraft, those are already supported: just add them to the mission)
- Spawning of tankers for long-range missions
- (maybe) Text (not voiceover) localization, if there's enough popular demand

### Low priority

- Advanced options such as "use metric units" or "use bullseye rather than player position for coordinates transmission" (the later awarding more XP when enabled, because of the need for higher situational awareness)
- Female voice option for the player
- Full ATC system. Don't expect anything BMS-like but it will be a LOT better than the vanilla DCS one
- (maybe) AI CSAR helos to pick up stranded/ejected pilots
- (maybe) PvP support

## Misc

- **Released under the GNU GPL 3.0 licence**
- Uses YoloWingPixie's [DCS World Schema API](https://github.com/YoloWingPixie/dcs-world-schema)
- AI use/disclosure
  - [ChatGPT](https://chatgpt.com/): used to generate first draft of radio messages
  - [ElevenLabs](https://elevenlabs.io/fr): used to generate radio messages voiceover

## How to build the miz files

_**(this is for developpers only, end users should just download the latest release)**_

I use a PHP script to "build" the .miz files as PHP is a pretty handy tool capable both of handling all required replacements and pack the miz files.

If you want to build the .miz files yourself, you'll need to:

- [Download PHP](https://www.php.net/) and install it
- Add the PHP directory it to your system PATH so the batch file will find it
- In the PHP directory, rename php.ini-production to php.ini, edit it and uncomment or delete the "extension=mbstring" line to enable the MBString extension that my script uses.
- Then run Make.bat in the source directory (or, alternatively, open the source directory in VSCode and press Ctrl+Alt+B)
- You will be asked if you want to build only the Persian Gulf debug mission (useful, as build is quicker and PG is one of the fastest loading maps in DCS World), debug versions of all theaters or release version of all theaters.
  - Debug version of the mission give access to debugging options in the F10 menu and output additional logs during the mission. Debug missions are generated with an F-16C player aircraft as it's a good jack-of-all-trades to test various things, but you're free to change it in the mission editor.
- .Miz files will be generated in the project root directory, and a copy will be sent to your DCS World "missions" directory (if it exists)
- If you use VSCode, be aware that .miz files are ignored in the explorer (as per .vscode/settings.json settings) to unclutter the explorer panel, so don't be suprise if you don't see them when building from VSCode.

## Want to contribute to the project?

The core script is quite simple and small, I probably won't need too much help with it (of course you're free to suggest improvements and submit pull requests).

**What I'll need help with most is:**

- Feedback, feedback, feedback. Especially regarding bug (don't forget to write down the various script line numbers mentioned in the error message!) mission balancing and career progression.
  - You can contact me through GitHub or send me a mail at akaagarmail@gmail.com
- You can also [buy me a coffee](https://buymeacoffee.com/akaagar)!

## Version history

- **0.3.250914** (09/14/2025)
  - **MAJOR CHANGE:**
    - Use of "Client" slots instead of "Player" slots even in single-player missions, allowing the player to respawn on death/ejection instead of having to start the whole mission again
    - "Player" slots should not be used anymore. Single-player missions must now use a single "Client" slot instead
  - Additional content
    - Added new units (Currenthill unit pack) from DCS 2.9.19.13478
    - Support for "Cold War Germany" theater
  - Balance improvements
    - Enemy CAP respawn rate now decreases as more enemy planes are shot down
  - Bug fixes
    - Some player callsigns were causing a script error at startup
    - Fixed wrong filename in "enemy infantry killed" messages
    - Removed unused zones from the "autoexec.cfg" file
  - Extras
    - First draft of the PDF manual
  - New features
    - Additional commands in the "navigation" menu
      - Vector to nearest airfield
      - Weather report
    - Mission now autostarts (if it wasn't started yet) when all players have taken off
  - Quality of life/minor tweaks
    - Increased AWACS aircraft spawn altitude
    - Target coordinates radio message displayed for a longer time so players have time to write them down or enter them in their flight computer
- **0.2.250729** (07/29/2025)
  - **MAJOR CHANGE:** Added all new wingman system
    - Far for perfect but a lot better than DCS's default wingmen
    - Many more engage/orbit/go to commands (see "Using the mission menu" above)
    - All new contacts report system: more realistic (see "AI units reports" changes below in this changelog) and does not spam the player with "new contact" messages
    - AI wingmen added using mission editor are now despawned on mission start to avoid conflict with TUM's own wingman system
  - Added 138 new radio messages, with voiceover
    - 120+ wingmen commands and replies
    - Additional voiceovers for Fox 1/2/3 calls
    - "Infantry kill" BDA report
  - Added error message on mission start when autoexec.cfg is missing and script cannot proceed
  - Added payload table for all DCS World aircraft (datamined from Briefing Room, many thanks to @john681611)
  - Added "Using the mission menu" section to this README file, detailing all available commands
  - Added "weapons introduction date" table for upcoming "time period" setting (datamined from Briefing Room, many thanks to @john681611)
  - All AI aircraft now despawned on landing to free CPU cycles and allow space for new aircraft
  - AWACS aircraft now spawned near the centerpoint of mission player slots
  - Changed AWACS aircraft detection logic (a tiny bit less realistic but more efficient)
  - Changed some UTF-8 symbols in F10 menu, added UTF-8 symbol for "Objectives" submenu
  - Fixed missing airbase name in "aircraft landed safely" messages
  - Friendly CAP flights now take off from near the centerpoint of mission player slots
  - Improved display of XP modifiers in menu
  - Improved the script used to build the project
  - Improved wording of many lines and commands, correct a bunch of typos
  - Increased minimum aircraft spawn altitude to avoir crashes in nearby hills
  - Infantry escaping from destroyed vehicles is now hidden on F10 map, as it should be
  - Interception objectives are now marked as complete when target is shot down
  - Missions taking place in enemy territory now award 30% more XP to account for increased SAM threat and proximity of enemy airbases
  - Moved "Request objective coordinates" radio commands to new "Navigation" submenu, which will include additional navigational assist in future versions
  - Lowered MANPADS count and skill (MANPADS are overpowered in DCS, especially SA-18)
  - "New friendly/enemy aircraft taking off" radio messages now mention their BRAA relative to the player, number of bandits taking off now displayed as a word instead of digits
  - "Rifle!" and "Missile away!" radio calls now both used for any kind of A/G missiles (except antiship and antiradiation missiles, who
  - Tons of internal logic bugfixes and tweaks
  - Tweaked XP bonus/penalty for various mission settings
  - Vastly improved the way AI units reports on contact tracks. According to range and sensors capabilities, can go from perfect ID (e.g. "Su-27") to very generic descriptions (e.g. "fighter" or even "aircraft")
- **0.1.250723** (07/23/2025)
  - Added new "autoexec.cfg" file required by DCS 2.9.18.12722. You have to copy it to **[Saved Games]\DCS\Config directory** or the script won't work.
  - Fixed a bug with convoys sometimes stuck in trees and buildings
  - Fixed a bug with "intermission" menu not showing properly on mission completion
  - Fixed a bug with non carrier-capable aircraft spawning on carriers
  - Fixed a bug with "rockets!" radio call causing an error message
  - Improved wording on the "XP awarded" and "all XP will be lost" messages
- **0.1.250722-update1** (07/22/2025)
  - Added Kola theater
  - Added Marianas theater
  - Added message when XP is awarded to player after landing
  - Fixed bug when friendly non-unit object is hit
  - Slightly lowered XP required for medals and promotions
- **0.1.250722** (07/22/2025)
  - Initial public release
