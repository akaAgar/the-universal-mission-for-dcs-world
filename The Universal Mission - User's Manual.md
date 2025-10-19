<!------------------------- NEW PAGE ------------------------->
<div style="text-align:center">
<img style="width:100%" src="docs/logo.png" alt="The Universal Mission for DCS World" />
<p class="heavy" style="font-size:175%;">
User's manual
</p>
<p class="heavy">
The Universal Mission v0.3.251019<br />
Created and maintained by Ambroise Garel (<a href='mailto:akaagarmail@gmail.com'>akaagarmail@gmail.com</a>)
</p>
<p class="heavy">
<a href='https://github.com/akaAgar/the-universal-mission-for-dcs-world'>github.com/akaAgar/the-universal-mission-for-dcs-world</a><br />
</p>
</div>

<div style="page-break-after: always;"></div>
<!------------------------- NEW PAGE ------------------------->

<h2>Table of contents</h2>
<ul>
<li><a href="#page_welcome">Welcome to <em>The Universal Mission</em></a></li>
<li><a href="#page_howtoplay">How to use/play The Universal Mission?</a></li>
<li><a href="#page_menumission">Using the mission menu</a></li>
<li><a href="#page_advancedstuff">Advanced stuff you may want to try</a></li>
<li><a href="#page_multiplayer">A few notes regarding multiplayer</a></li>
</ul>

<div style="page-break-after: always;"></div>
<!------------------------- NEW PAGE ------------------------->

<div id="page_welcome"></div>
<h2>Welcome to <em>The Universal Mission</em></h2>

_The Universal Mission for DCS World_ is an attempt to create a fully dynamic single-player/PvE mission giving access to the whole content of DCS World in a structure similar to the one found in old "simulators", like the early Microprose games (think F-117 or the Strike Eagle serie).

These game had both fun and clear objectives, endless replayability and a career system that made sure that something was at stake: crash and die, and you'll lose all these hard-earned medals.

As the original creator of [_Briefing Room for DCS World_](https://github.com/DCS-BR-Tools/briefing-room-for-dcs) (now maintained by the talented John Harvey), I've always wanted to create an easy-to-use, enticing and fun mission generator for DCS, capable of creating CPU-light missions without requiring an external program.

I think _The Universal Mission_ is, finally, the proper way to approach this problem. The current version is still an early beta but most core features are already working.

I hope you'll like it.

<h3>Features</h3>

- Can generate any kind of mission: ground attack, interception, strike, airbase attack, CAS, CAP, and more
- Completely dynamic, no two missions are ever the same
- Entirely self-contained inside a .miz file, no need for any external program
- More than 325 voiced radio messages for immersive and realistic coms
- Supports both single-player and small-scale PvE on closed servers
- Persistent single player career mode, with awards and promotions. Dying won't reset your progress, but you have to come back to base alive for your kills and completed objectives to be saved to your profile, so watch out for SAMs on your way home
- All new AI wingman system, smarter and more immersive than DCS's original wingmen
- Uses advanced DCS World scripting functionalities (like the brand new Disposition singleton and net.dostring_in hacks) to achieve effects seldom seen in other scripts, such as graphic overlays and random but realistic placement of units in cities and forests without the use of handmade spawn points
- Various little details to make the DCS World more alive, like crew running away from destroyed vehicles

<h3>Limitations of current beta version</h3>

- The current version supports only modern (post-Cold War) units and Caucasus, Kola, Marianas, Persian Gulf and Syria theaters
  - Germany support will come soon, others will follow later
- Not all mission types are supported yet
- Career progress may be lost because of future updates, don't get too attached to it

<h3>Known bugs</h3>
- AWACS datalink info is now displayed on SA pages

<div style="page-break-after: always;"></div>
<!------------------------- NEW PAGE ------------------------->

<div id="page_howtoplay"></div>
<h2>How to use/play The Universal Mission?</h2>

<h3>First setup</h3>

- Download the latest release from this GitHub page.
- Copy the provided autoexec.cfg file to your **[Saved Games]\DCS\Config directory**
- Copy the .miz files for your theater(s) of choice to your **[Saved Games]\DCS\Missions directory**
- _**(Optional but strongly recommended)**_ Unsanitize the Lua IO module. You don't have to do this, but the persistent career system won't work if you don't. To do it, open the file **[DCS World installation directory]\Scripts\MissionScripting.lua** with a text editor and comment or remove the line "sanitizeModule('io')". Make sure you restart DCS World once you've modified the file.
  - Please note: should you want to backup, delete or transfer it, career progress is saved in **[DCS World installation directory]\TheUniversalMission.sav**

<h3>Customizing the mission to your taste</h3>

- _**(Optional but you'll probably want to do it)**_ Open the .miz file in the DCS World mission editor and change the player unit to pick your desired aircraft. The default player unit is a Su-25T (as it is the only free DCS airplane equipped with weapons) and you probably won't want to stick with it.

Please refer to the "Advanced stuff you may want to try" section to learn all the ways you can customize The Universal Mission.

<h3>Starting the mission</h3>

- Launch the mission from the mission editor or the "Mission" selection in the main DCS World menu
- You are now on the ramp or runway. Open the communication menu (see "Using the mission menu" below) and navigate to the F10/Other menu. From there, you can view and change mission settings. They include:
  - Who belong to the blue and red coalitions
  - The type of mission
  - The number and location of targets (you can use the F10 map to see where the available target zones are located).
  - The amount of enemy air force and air defense. The higher these settings, the more XP you'll recieve upon completion of a single-player mission
- When you're ready, pick the "Begin mission" option, wait a few seconds (precaching all the game assets can take some time, especially if you have a slow CPU), you're ready to go!
- Use the F10 mission and check the F10 map for additional information about the mission (see "Using the mission menu" below). Don't forget to come back to base alive, all awarded XP and completed objectives will only be saved to your pilot profile once you've landed

<div style="page-break-after: always;"></div>
<!------------------------- NEW PAGE ------------------------->

<div id="page_menumission"></div>
<h2>Using the mission menu</h2>

Most features of The Universal Mission require the use of the "F10. Other" menu. To access it, press the "Communication menu" key (check the key bindings), navigate to the root menu by pressing F11 ("Previous menu") if need, then press "F10" to access the "Other" menu.
The exact content of the menu will depend on the current phase of the mission.

<h3>On startup/when no mission is active</h3>

- **Display mission settings**: Displays the current mission settings, that will be applied if you choose to start the mission now.
- **Change mission settings**: Allows you to change the mission settings to your taste.
  - **Blue coalition**: Who is the blue coalition? Determines the type of units that will be spawned. Available factions (e.g. NATO) depend on the missions's time period and theater.
  - **Red coalition**: Who is the red coalition? Determines the type of units that will be spawned. Available factions (e.g. USSR) depend on the missions's time period and theater.
  - **Mission type**: What will your mission be?
    - **Antiship strike**: Sink enemy warships and cargo ships.
    - **Ground attack**: Interdiction missions against armor, artillery and convoys.
    - **Helicopter-specific tasks**: Tasks specifically designed for helicopters (lift/pick up friendly units, suppress infantry...)
    - **Helicopter hunt**: Shoot down enemy transport and attack helicopters.
    - **Interception**: Shoot down strategic airplanes (bombers, transports...) and enemy attack planes on interdiction missions.
    - **Offensive counter-air**: Bomb enemy airbases and destroy parked aircraft. **(Requires a target area with at least one enemy land airbase, or mission type will automatically be changed to ground attack)**
    - **SEAD**: Destroy enemy SAM sites.
    - **Strike**: Destroy enemy structures and civilian buildings occupied by enemy forces.
  - **Target location**: Where on the map will the targets be spawned? Approximate distance to possible regions is displayed in the menu.
    - Missions taking place in enemy territory award 30% more XP to account for increased SAM threat and proximity of enemy airbases.
    - Make sure to pick a region not too far away from your starting location if you don't like long ingresses.
    - Picking a region very close to your starting location (for instance, the one where your airbase is located in) can also be a bad idea, as you might takeoff in range of an enemy SAM.
    - Be aware that targets of antiship strikes will always be spawned in open seas, which can be quite far if you picked a landlocked target zone.
  - **Target count**: How many objectives will be spawned. More objectives means potentially more xp in a single sortie, so better medals, but also more work and more risk. Be aware that you can RTB to rearm/refuel at any time between objectives, but you won't accumulate as many single-sortie XP as if you complete objectives without going back to base, because XP is awarded to your profile and reset each time you land.
  - **Enemy air defense**: Amount, quality and skill of enemy surface-to-air units (AAA, MANPADS and SAM). A higher setting awards more XP.
  - **Enemy air force**: Amount, quality and skill of enemy combat air patrols. A higher setting awards more XP.
  - **Wingmen count**: How many wingmen will fly by your side (from zero to three). A small XP penalty is added for each additional wingman. Wingman won't get replaced if they get shot during a mission, but they will (with full payload) each time you land and takeoff again. Only shown in single-player missions.
  - **Friendly AI CAP**: Should AI fighter aicraft be spawned regularly to patrol the AO and shoot down potential threats? Disabling this option will award you more XP (only if "Enemy air force" is not set to "None") but also means you and your wingmen will be alone against the whole enemy air force.
- **View pilot career stats**: Displays a list of your achievements, as well as your medal case. Only available when playing single-player missions and if the Lua IO module has been unsanitized (see "First setup" above)
- **Begin mission**: Starts a mission with the current settings.

<h3>Other parameters</h3>

- _(Not yet implemented in this version)_ By changing the year in mission time parameters, the time period will be changed accordingly and the proper factions and AI units will be spawned during the mission. Time periods are:
  - 1945 and before: World War 2
  - 1946-1959: Korea War
  - 1960-1974: Vietnam War
  - 1975-1989: Late Cold War
  - 1990-now: Modern
- _(Not yet implemented in this version)_ Changing the weather to make it more cloudy or windy, or setting the mission to nighttime, will make the mission more difficult but also award more points.

<h3>During the mission</h3>

- **Mission status**: Displays a summary of the mission's status (list of objectives and progress on each objective).
- **Objectives**: Displays a list of special commands related to each of the mission's objectives. Be aware that some objectives may have no special commands associated with them.
  - **Smoke marker on target**: Asks for a friendly JTAC to pop a smoke marker on the target. Makes finding the target easier, but will cost you a small XP penalty. Only available for missions where a JTAC is available (it's pretty hard to throw a smoke grenade at an airplane or a ship in the middle of the sea).
- **Navigation**: Displays a list of commands related to navigational assistance.
  - **Navigation to nearest airbase**: Displays the coordinates of the nearest friendly airbase, its BRA ("fly X for Y") relative to the player's position and an estimated flight time and ETA.
  - **Navigation to objective [OBJECTIVE NAME]**: Displays the coordinates of the objective, its BRA ("fly X for Y") relative to the player's position and an estimated flight time and ETA. Some objectives types (e.g. strike missions) are provided with exact coordinates, but most will only have approximate coordiantes, so you'll have to search for targets yourself once in the objective area.
  - **Weather update**: Displays information about the weather (wind speed, temperature...) at the player location.
- **Flight**: Displays a list of commands for your wingmen. Only shown in single-player missions and if wingmen are available for this mission.
  - **Cover me!**: Tasks your wingmen to immediately engage any nearby air threats.
  - **Engage**: Tasks your wingmen to engage a certain type of targets. Targets must be detected by your wingmen (see "Report contacts" below), or they won't be able to engage them.
  - **Report contacts**: Asks your wingmen for a list of all detected contacts. According to range and sensors capabilities, their reports can go from perfect ID (e.g. "Su-27") to very generic descriptions (e.g. "fighter" or even "aircraft")
  - **Hold position**: Tasks your wingmen to orbit at their current position. All other tasking will be aborted.
  - **Change altitude**: Asks your wingmen to change their altitude. This altitude will be employed when attacking on orbiting but not when rejoining/forming up with you (in that case, they'll match your altitude).
  - **Status report**: Asks your wingmen for a complete report (damage sustained, fuel status, available payload).
  - **Rejoin**: Asks your wingmen to rejoin and follow you. All other tasking will be aborted. This is the default tasking when wingmen take off and when they complete another task.
- **AWACS**: Displays a list of commands for the AWACS. Only shown if an AWACS aircraft is available for this mission.
  - **Bogey dope**: Asks for the nearest enemy air threat
  - **Picture**: Asks for a summary of all detected enemy aircraft
- **Display mission score**: Displays the number of XP gained and objectives completed since your last takeoff. They will be added to your flight log (and any promotions/medals be awarded) the next time you land. If you crash, eject or abort the mission, all currently "stowed" XP and objectives will be lost. Only available when playing single-player missions and if the Lua IO module has been unsanitized (see "First setup" above)
- **Abort mission**: Aborts the current mission and forfeit all XP/objectives gained since last landing. The game will ask for confirmation so you don't select this option by mistake.

<div style="page-break-after: always;"></div>
<!------------------------- NEW PAGE ------------------------->

<div id="page_advancedstuff"></div>
<h2>Advanced stuff you may want to try</h2>

The Universal Mission is designed to be easily editable to suit your preferences. Here are a few things you could do after opening the .miz file in DCS World's mission editor.

<h3>Player aircraft</h3>

- Change the player aircraft starting condition (runway, parking or parking hot). Air starts are not recommended as all players must be on the ground to begin a new mission
- Move it to another airbase, change its coalition (make sure blue players are spawned on an airbase located in a BLUFOR zone are red players are spawned on an airbase located in a REDFOR zone)
  - You may also add an aircraft carrier or a FARP for the player to take off from
- Change its default loadout if you plan to play a specific kind of mission and don't want to lose time asking the ground crew to rearm your aircraft (e.g. if you know you want to play SEAD missions, you may as well stock up on AGM-88s)
- Add other aircraft to create a multiplayer mission to play with your friends. Keep in mind that the persistent career/player stats system will be disabled in multiplayer missions and that all player aircraft must belong to the same coalition (TUM does not support PvP)

<h3>Zones</h3>

- All zones whose names starts with BLUFOR or REDFOR decide the territory (and airbases) controlled by the blue and red coalitions
  - Be aware that any change to the airbases coalitions will be superseded by the BLUFOR and REFOR zones
- All zones whose names starts with WATER are seas, used to spawn ships
- Zones with a name not starting with BLUFOR, REDFOR or WATER are target zones. These are zones where objectives can be spawned, who can be selected in the "objective location" setting of the intermission F10 menu
  - Change, add or remove zones to create new possible target areas. A maximum of 10 target areas can be created, so they fit the F10 menu

<div style="page-break-after: always;"></div>
<!------------------------- NEW PAGE ------------------------->

<div id="page_multiplayer"></div>
<h2>A few notes regarding multiplayer</h2>

While The Universal Mission supports multiplayer and is perfectely suitable (and fun!) for playing with friends on a private server, it is **absolutely not suited for public servers** as missions settings can be edited by anyone at any time Using the mission menu.
Please also note that PvP is not supported at the moment and that the mission will not launch if both coalitions have player slots.
