--[[
- @brief      This function will create a suppression logic for the given group
-
- @example    CreateSuppression("Ground-1", false)
-
- @param      group   <String>    This is the name of the group
- @param      debug   <Boolean>   If true the debug will be activated
-
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Functional.Suppression.html
--]]


env.info("ALA15vToolBox CreateSuppression declaration")
function CreateSuppression(group, debug)
  env.info("ALA15vToolBox CreateSuppression function: Initializing Suppression for the group " .. group)
  local Suppression = SUPPRESSION:New(GROUP:FindByName(group))
  Suppression:SetSuppressionTime(10, 30, 60)
  Suppression:Fallback(false)
  Suppression:Takecover(false)
  Suppression:SetDefaultAlarmState("Auto")
  Suppression:SetDefaultROE("Free")
  if (debug) then
    Suppression:DebugOn()
  end

  Suppression:__Start(5)
  env.info("ALA15vToolBox CreateSuppression function: Suppression Initialized")
end

env.info("ALA15vToolBox CreateSuppression declaration done")

Ala15vToolBoxSuppressionLoaded = true    -- In case it is needed to check if this module is loaded