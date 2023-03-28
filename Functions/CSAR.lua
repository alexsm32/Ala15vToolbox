--[[
- @brief      This function will create rescue missions when a pilot (player) is downed
-
- @example    SetUpCSAR("blue", "pilot", {"helicargo", "MEDEVAC"}, true, true, true, false, {"MASH"})
- @example    SetUpCSAR("blue", "pilot", {"helicargo", "MEDEVAC"}, true, true, false, false, nil)
-
- @param                    side              <String>      {OPTIONS: "blue", "red"}      This is the coalition side for the CSAR missions
- @param                    template          <String>                                    This is the group name of the unit that will represent the downed pilot
- @param                    medevac           <String>                                    This is the group name prefix/es of the helicopter/s that will act as medevac
- @param                    immortal          <Boolean>                                   If true, the unit that represent the downed pilot will be immortal
- @param                    invisible         <Boolean>                                   If true, the unit that represent the downed pilot will be invisible
- @param                    autoSmoke         <Boolean>                                   If true, automatically smoke a downed pilot\'s location when a heli is near
- @param                    checkDoors        <Boolean>                                   If true, the script will check if the helicopter doors are opened before the downed pilot is allowed to get in
- @param    (OPTIONAL)      hospitals         <String>                                    This is the prefixes of #GROUP objects used as hospitals
-
-
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.CSAR.html
--]]

env.info("ALA15vToolBox SetUpCSAR declaration")
function SetUpCSAR(side, template, medevac, immortal, invisible, autoSmoke, checkDoors, hospitals)
    env.info("ALA15vToolBox SetUpCSAR function: Initializing CSAR ")
    local my_csar = nil
    if side == "red" then
        my_csar = CSAR:New(coalition.side.RED, template)
    else
        my_csar = CSAR:New(coalition.side.BLUE, template)
    end
    -- options
    my_csar.useprefix = true -- Requires CSAR helicopter #GROUP names to have the prefix(es) defined below.
    my_csar.csarPrefix = medevac -- #GROUP name prefixes used for useprefix=true - DO NOT use # in helicopter names in the Mission Editor!
    my_csar.immortalcrew = immortal -- downed pilot spawn is immortal
    my_csar.invisiblecrew = invisible -- downed pilot spawn is visible
    my_csar.allowFARPRescue = true -- allows pilots to be rescued by landing at a FARP or Airbase. Else MASH only!
    my_csar.autosmoke = autoSmoke -- automatically smoke a downed pilot\'s location when a heli is near.
    my_csar.autosmokedistance = 1000 -- distance for autosmoke
    my_csar.pilotRuntoExtractPoint = true -- Downed pilot will run to the rescue helicopter up to self.extractDistance in meters.
    my_csar.extractDistance = 500 -- Distance the downed pilot will start to run to the rescue helicopter.
    if not (hospitals == nil) then
        my_csar.mashprefix = hospitals -- prefixes of #GROUP objects used as MASHes.
    end
    my_csar.pilotmustopendoors = checkDoors -- switch to true to enable check of open doors

    -- start the FSM
    my_csar:__Start(5)
    env.info("ALA15vToolBox SetUpCSAR function: CSAR Initialized")
end

env.info("ALA15vToolBox SetUpCSAR declaration done")

Ala15vToolBoxCSARLoaded = true    -- In case it is needed to check if this module is loaded