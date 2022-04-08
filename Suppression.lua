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

function CreateSuppression (group, debug)
  local Suppression = SUPPRESSION:New(GROUP:FindByName(group))
  Suppression:SetSuppressionTime(10, 30, 60)
  Suppression:Fallback(false)
  Suppression:Takecover(false)
  Suppression:SetDefaultAlarmState("Auto")
  Suppression:SetDefaultROE("Free")
  if(debug) then
    Suppression:DebugOn()
  end
  
  Suppression:__Start(5)
end