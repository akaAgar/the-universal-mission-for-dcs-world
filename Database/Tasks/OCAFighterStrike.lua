Library.tasks.ocaFighterStrike = {
   taskFamily = DCSEx.enums.taskFamily.OCA,
   description =
   {
      briefing = {
         "Destroying enemy fighters on the ramp will prevent immediate sortie generation and blunt their ability to provide CAS against our advancing forces.",
         "A ramp strike against enemy aircraft will pre-empt an imminent scramble warning we have intel for, preventing a coordinated mass launch.",
         "Removing enemy fighters on the ramp will degrade enemy air superiority over the battlespace and protects our medevac and resupply corridors.",
         "Priority is to eliminate immediate airborne threats on the ramp to safeguard coalition force freedom of maneuver.",
      },
      short = "Destroy enemy fighter on the ramp",
   },
   conditions = {
      difficultyMinimum = 0,
      eras = {},
   },
   completionEvent = DCSEx.enums.taskEvent.DESTROY,
   flags = { DCSEx.enums.taskFlag.ALLOW_JTAC, DCSEx.enums.taskFlag.PARKED_AIRCRAFT_TARGET },
   minimumDistance = 0.0,
   safeRadius = 0,
   surfaceType = land.SurfaceType.LAND,
   targetCount = { 1, 1 },
   targetFamilies = { DCSEx.enums.unitFamily.PLANE_FIGHTER },
   waypointInaccuracy = 0.0
}
