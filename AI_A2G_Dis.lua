--[[
- @brief      This function will create an AI A2G Dispatcher. NOTE: The AI_A2G_DISPATCHER can be use in many different ways. The way I am offering here is 1 airport = 1 or more squadrons = 1 template
-
- @example  --REVIEW -   myA2G_Dis = A2G_Dispatcher("HQ", {"RECON"}, "red", 200000, "Lar", {Su25={template="Su-25T", number=20, task="BAI"}, Ka50={template="Ka-50", number=10, task="CAS"}}, 0.2, 2, "A2G Dispatcher Lar")
- @example  --REVIEW -   myA2G_Dis = A2G_Dispatcher("HQ", nil, "red", 200000, "Lar", {Su25={template="Su-25T", number=20, task="SEAD"}, Ka50={template="Ka-50", number=10, task="CAS"}}, 0.2, 2, "A2G Dispatcher Lar")
-
- @param                    hq            <String>                                       This is the group name of the unit that represent the command center
- @param    (OPTIONAL)      radars        <String>      --NOTE: if not used type " nil " This is the prefix or set of prefixes that will be used to filter the detection groups. If nil, it will use all the ground units
- @param                    coalition     <String>      {OPTIONS: "blue", "red"}         This is the coalition side that the detection group filter will focus on
- @param                    radius        <Integer>                                      This is the radius from the command center that will represent the area deffended
- @param                    airBases      <String>                                       This is the airport available for the dispatcher
- @param                    templates     <Key = String,Integer,String>     {TASKS: "BAI", "CAS", "SEAD"}     --NOTE: the key is the squadron name and it contains the template names and number of aircrafts    This is the set of squadrons, templates, number of aircrafts and task available for the dispatcher
- @param                    overhead      <Float>                                        This is the proportion of aircrafts the CGI will respon with. The product of this parameter and the number of detected enemy aircrafts represent the number of aircrafts the CGI will send
- @param                    groupNumber   <Integer>                                      This is the number of aircrafts that form one group
- @param                    menuName      <String>                                       This is the name of the menu under F10 Other>Dispatchers
-
- @return   A2GDispatcher   <AI_A2G_DISPATCHER>     The function return the hole AI_A2G_DISPATCHER object
-
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2G_Dispatcher.html
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Airbase.html
--]]


env.info("ALA15vToolBox A2G_Dispatcher declaration")
function A2G_Dispatcher(hq, radars, coalition, radius, airBase, templates, overhead, groupNumber, menuName)
    env.info("ALA15vToolBox A2G_Dispatcher function: Checking if the group, " .. hq .. ", exists in the mission")
    if Group.getByName(hq) then -- NOTE: this condition is important for campaings
        local HQ_Group = GROUP:FindByName(hq)
        env.info("ALA15vToolBox A2G_Dispatcher function: Checking if the group, " .. hq .. ", is alive")
        if HQ_Group:IsAlive() then
            local HQ_CC = COMMANDCENTER:New(HQ_Group, "HQ")

            local DetectionSetGroup = SET_GROUP:New()
            DetectionSetGroup:FilterCoalitions(coalition)
            if radars then
                env.info("ALA15vToolBox A2G_Dispatcher function: Filtering DetectionSetGroup using prefix/es provided")
                DetectionSetGroup:FilterPrefixes(radars)
            else
                env.info("ALA15vToolBox A2G_Dispatcher function: Filtering DetectionSetGroup using category Ground")
                DetectionSetGroup:FilterCategoryGround() -- REVIEW
            end
            DetectionSetGroup:FilterStart()

            local Detection = DETECTION_AREAS:New(DetectionSetGroup, 2000)

            -- Setup the A2A dispatcher, and initialize it.
            local A2GDispatcher = AI_A2G_DISPATCHER:New(Detection)

            -- The Command Center (HQ) is the defense point and will also handle the communication to the coalition.

            -- Add defense coordinates.
            A2GDispatcher:AddDefenseCoordinate("HQ", HQ_Group:GetCoordinate())
            A2GDispatcher:SetDefenseReactivityHigh() -- High defense reactivity. So far proximity of a threat will trigger a defense action.
            A2GDispatcher:SetDefenseRadius(radius) -- Defense radius wide enough to also trigger defenses far away.

            -- Communication to the players within the coalition. The HQ services the communication of the defense actions.
            A2GDispatcher:SetCommandCenter(HQ_CC)

            -- Setup the default fuel threshold.
            A2GDispatcher:SetDefaultFuelThreshold(0.30)

            -- Now Setup the default damage threshold.
            A2GDispatcher:SetDefaultDamageThreshold(0.50)

            -- Show a tactical display.
            A2GDispatcher:SetTacticalMenu("Dispatchers", menuName)
            A2GDispatcher:SetTacticalDisplay(false)

            -- SECTION: Adding squadrons
            -- TODO: check if this works with carriers or heliports and add some extra condition
            env.info("ALA15vToolBox A2G_Dispatcher function: Checking if the airbase belongs to the coalition " .. coalition)
            if AIRBASE:FindByName(airBase):GetCoalitionName():lower() == coalition then -- NOTE: this condition is important for campaings
                env.info("ALA15vToolBox A2G_Dispatcher function: Adding squadrons")
                for name, info in pairs(templates) do
                    env.info("ALA15vToolBox A2G_Dispatcher function: Checking if the group, " .. info.template .. ", exists in the mission")
                    if Group.getByName(info.template) then
                        -- Setup the squadrons.
                        A2GDispatcher:SetSquadron(name, airBase, info.template, info.number)
                        -- Setup squadron task
                        if info.task == "BAI" then
                            env.info("ALA15vToolBox A2G_Dispatcher function: Adding squadron " .. name .. " with task BAI")
                            A2GDispatcher:SetSquadronBai(name)
                        elseif info.task == "SEAD" then
                            env.info("ALA15vToolBox A2G_Dispatcher function: Adding squadron " .. name .. " with task SEAD")
                            A2GDispatcher:SetSquadronSead(name)
                        else
                            env.info("ALA15vToolBox A2G_Dispatcher function: Adding squadron " .. name .. " with task CAS")
                            A2GDispatcher:SetSquadronCas(name)
                        end
                        -- Setup the overhead
                        A2GDispatcher:SetSquadronOverhead(name, overhead)
                        -- Setup the Grouping
                        A2GDispatcher:SetSquadronGrouping(name, groupNumber)
                        -- Setup the Takeoff methods
                        A2GDispatcher:SetSquadronTakeoffFromParkingHot(name)
                        -- Setup the Landing methods
                        A2GDispatcher:SetSquadronLandingAtEngineShutdown(name)
                        -- We set for each squadron a takeoff interval, as each helicopter will launch from a FARP.
                        -- This to prevent helicopters to clutter.
                        -- Each helicopter group is taking off the FARP in hot start.
                        A2GDispatcher:SetSquadronTakeoffInterval(name, 30)
                        -- Set the language of the squadrons to Russian.
                        -- KNOWNISSUE: ALERT   WRADIO: Error in wMessage::buildSpeech(), event = wMsgFlightDepartingStation: [string "./Scripts/Speech/phrase.lua"]:343: assertion failed!
                        -- A2GDispatcher:SetSquadronRadioFrequency(name, 127.5) -- NOTE: under test
                        -- !KNOWNISSUE
                    else
                        env.error("ALA15vToolBox A2G_Dispatcher function: The group, " .. info.template .. ", does not exist in the mission")
                    end
                end
                env.info("ALA15vToolBox A2G_Dispatcher function: All the squadrons added")
            else
                env.warning("ALA15vToolBox A2G_Dispatcher function: The airbase does not belong to the coalition " .. coalition)
            end
            -- !SECTION

            -- Returning the A2GDispatcher object for other uses
            env.info("ALA15vToolBox A2G_Dispatcher function: Returning A2GDispatcher")
            return A2GDispatcher
        else
            env.warning("ALA15vToolBox A2G_Dispatcher function: The group, " .. hq .. ", is not alive")
        end
    else
        env.error("ALA15vToolBox A2G_Dispatcher function: The group " .. hq .. " does not exist")
    end
end

env.info("ALA15vToolBox A2G_Dispatcher declaration done")


--[[
- @brief      This function will assign a cas zone to an A2G Dispatcher squadron
-
- @example    A2G_Dis_CasPatrol(myA2G_Dis, "zoneCAS1", "Ka50")
-
- @param      A2GDispatcher     <AI_A2G_DISPATCHER>     This parameter must be filled with an AI_A2G_DISPATCHER object
- @param      zone              <String>                This is the name of the CAS zone
- @param      squadron          <String>                This is the name of the squadron that will cover this CAS zone
-
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2G_Dispatcher.html
--]]

env.info("ALA15vToolBox A2G_Dis_CasPatrol declaration")
-- FIXED: needed condition to check if squadron exists
function A2G_Dis_CasPatrol(A2GDispatcher, zone, squadron)
    env.info("ALA15vToolBox A2G_Dis_CasPatrol function: Checking if the dispatcher exists")
    if A2GDispatcher then -- NOTE: this condition is important for campaings
        env.info("ALA15vToolBox A2G_Dis_CasPatrol function: Checking if the squadron, " .. squadron .. ", exists")
        if A2GDispatcher.DefenderSquadrons[squadron] then   -- NOTE: this condition is important for campaings
            local CAPZone = ZONE:New(zone)
            A2GDispatcher:SetSquadronCasPatrol2(squadron, CAPZone, nil, nil, 480, 1000, "RADIO", nil, nil, 350, 1000, "RADIO") -- REVIEW
            A2GDispatcher:SetSquadronCasPatrolInterval(squadron, 1, 180, 600, 1)
        else
            env.error("ALA15vToolBox A2G_Dis_CasPatrol function: The squadron does not exists")
        end
    else
        env.error("ALA15vToolBox A2G_Dis_CasPatrol function: The dispatcher does not exist")
    end
end

env.info("ALA15vToolBox A2G_Dis_CasPatrol declaration done")


--[[
- @brief      This function will assign a sead zone to an A2G Dispatcher squadron
-
- @example    A2G_Dis_SeadPatrol(myA2G_Dis, "zoneSEAD1", "Su25")
-
- @param      A2GDispatcher     <AI_A2G_DISPATCHER>     This parameter must be filled with an AI_A2G_DISPATCHER object
- @param      zone              <String>                This is the name of the SEAD zone
- @param      squadron          <String>                This is the name of the squadron that will cover this SEAD zone
-
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2G_Dispatcher.html
--]]

env.info("ALA15vToolBox A2G_Dis_SeadPatrol declaration")
-- FIXED: needed condition to check if squadron exists
function A2G_Dis_SeadPatrol(A2GDispatcher, zone, squadron)
    env.info("ALA15vToolBox A2G_Dis_SeadPatrol function: Checking if the dispatcher exists")
    if A2GDispatcher then -- NOTE: this condition is important for campaings
        env.info("ALA15vToolBox A2G_Dis_SeadPatrol function: Checking if the squadron, " .. squadron .. ", exists")
        if A2GDispatcher.DefenderSquadrons[squadron] then   -- NOTE: this condition is important for campaings
            local CAPZone = ZONE:New(zone)
            A2GDispatcher:SetSquadronSeadPatrol2(squadron, CAPZone, nil, nil, 4000, 10000, "BARO", nil, nil, 2000, 3000, "RADIO")
            A2GDispatcher:SetSquadronSeadPatrolInterval(squadron, 1, 180, 600, 1)
        else
            env.error("ALA15vToolBox A2G_Dis_SeadPatrol function: The squadron does not exists")
        end
    else
        env.error("ALA15vToolBox A2G_Dis_SeadPatrol function: The dispatcher does not exist")
    end
end

env.info("ALA15vToolBox A2G_Dis_SeadPatrol declaration done")

Ala15vToolBoxAIA2GDisLoaded = true  -- In case it is needed to check if this module is loaded