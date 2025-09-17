Library.tasks.ocaStrategicAircraftStrike = {
   taskFamily = DCSEx.enums.taskFamily.OCA,
   description =
   {
      briefing = {
         ""
      },
      short = "Destroy enemy aircraft on the ramp",
   },
   conditions = {
      difficultyMinimum = 0,
      eras = {},
   },
   completionEvent = DCSEx.enums.taskEvent.DAMAGE,
   flags = { DCSEx.enums.taskFlag.ALLOW_JTAC, DCSEx.enums.taskFlag.PARKED_AIRCRAFT_TARGET },
   minimumDistance = 0.0,
   safeRadius = 0,
   surfaceType = land.SurfaceType.LAND,
   targetCount = { 1, 1 },
   targetFamilies = { DCSEx.enums.unitFamily.PLANE_BOMBER, DCSEx.enums.unitFamily.PLANE_TRANSPORT },
   waypointInaccuracy = 0.0
}
