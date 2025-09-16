Library.tasks.heloHuntAttack = {
   taskFamily = DCSEx.enums.taskFamily.HELO_HUNT,
   description =
   {
      briefing = {
         "Locate and neutralize all enemy rotary-wing assets in the area.",
         "Enemy attack helicopters are staging nearby, you are to eliminate them before they launch their attack.",
         "Intel confirms a group of hostile gunships in the area. You must render them combat-ineffective.",
         "Engage and destroy rotary assets nearby, crippling enemy air support.",
      },
      short = "Destroy enemy attack helicopters",
   },
   conditions = {
      difficultyMinimum = 0,
      eras = {},
   },
   completionEvent = DCSEx.enums.taskEvent.DESTROY,
   flags = { },
   minimumDistance = DCSEx.converter.nmToMeters(10.0),
   safeRadius = 100,
   surfaceType = nil,
   targetCount = { 2, 3 },
   targetFamilies = { DCSEx.enums.unitFamily.HELICOPTER_ATTACK },
   waypointInaccuracy = DCSEx.converter.nmToMeters(6.0)
}
