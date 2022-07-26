--[[
- @brief      This function will create an AI A2A Dispatcher. NOTE: The AI_A2A_DISPATCHER can be use in many different ways. The way I am offering here is 1 airport = 1 squadron = 1 or more templates
-
- @example  --REVIEW    myA2A_Dis = A2A_Dispatcher("HQ", {"AWACS", "EWR"}, "red", false, "CCCP Border", {Lar = "Lar", Shiraz = "Shiraz Intl", BandarEJask = "Bandar-e-Jask"}, { "SQ CCCP L-39", "SQ CCCP Mig-23", "SQ CCCP Mig-21", "SQ CCCP Mig-29A" }, 20, 0.2, 2, "A2A Dispatcher North")
-
- @param      hq            <String>                                    This is the group name of the unit that represent the command center
- @param      radars        <String>                                    This is the prefix or set of prefixes that will be used to filter the detection groups
- @param      coalition     <String>      {OPTIONS: "blue", "red"}      This is the coalition side that the detection group filter will focus on
- @param      filter        <Boolean>                                   If true, only airplanes will be detected (not helicopters)
- @param      border        <String>                                    This is the group name of the unit with the route that represent the dispatcher border
- @param      airBases      <Key = AirbaseName>    -NOTE: the key is the squadron name and it contains the airport name      This is the set of squadrons and airports available for the dispatcher  --REVIEW
- @param      templates     <String>                                    This is the group name or set of group names of the template/s
- @param      aircrafts     <Integer>                                   This is the total number of aircrafts available for each squadron/airport
- @param      overhead      <Float>                                     This is the proportion of aircrafts the CGI will respon with. The product of this parameter and the number of detected enemy aircrafts represent the number of aircrafts the CGI will send
- @param      groupNumber   <Integer>                                   This is the number of aircrafts that form one group
- @param      menuName      <String>                                    This is the name of the menu under F10 Other>Dispatchers
-
- @return   A2ADispatcher   <AI_A2A_DISPATCHER>     The function return the hole AI_A2A_DISPATCHER object
-
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2A_Dispatcher.html
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Airbase.html
--]]


env.info("ALA15vToolBox A2A_Dispatcher declaration")
function A2A_Dispatcher(hq, radars, coalition, filter, border, airBases, templates, aircrafts, overhead, groupNumber, menuName)
    env.info("ALA15vToolBox A2A_Dispatcher function: Checking if the group, " .. hq .. ", exists in the mission")
    -- FIXED: null error when the group doesn't exist
    if Group.getByName(hq) then -- NOTE: this condition is important for campaings
        local HQ_Group = GROUP:FindByName(hq)
        env.info("ALA15vToolBox A2A_Dispatcher function: Checking if the group, " .. hq .. ", is alive")
        -- FIXED: check if command center group is alive
        if HQ_Group:IsAlive() then
            local HQ_CC = COMMANDCENTER:New(HQ_Group, "HQ")

            -- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
            -- Here we build the network with all the groups that have a name starting with DF CCCP AWACS and DF CCCP EWR.
            local DetectionSetGroup = SET_GROUP:New()
            DetectionSetGroup:FilterPrefixes(radars)
            DetectionSetGroup:FilterCoalitions(coalition)
            DetectionSetGroup:FilterStart()

            -- TODO: check if DetectionSetGroup:CountAlive() > 0 condition is necessary
            local Detection = DETECTION_AREAS:New(DetectionSetGroup, 100000)
            if filter then
                env.info("ALA15vToolBox A2A_Dispatcher function: Airplane filter activated")
                Detection:FilterCategories(Unit.Category.AIRPLANE)
            end

            -- FIXED: check if command center and DetectionSetGroup exist
            -- Setup the A2A dispatcher, and initialize it.
            local A2ADispatcher = AI_A2A_DISPATCHER:New(Detection)
            A2ADispatcher:SetCommandCenter(HQ_CC)

            -- Enable the tactical display panel.
            A2ADispatcher:SetTacticalMenu("Dispatchers", menuName)
            A2ADispatcher:SetTacticalDisplay(false)

            -- Initialize the dispatcher, setting up a border zone. This is a polygon,
            -- which takes the waypoints of a late activated group with the name CCCP Border as the boundaries of the border area.
            -- Any enemy crossing this border will be engaged.
            env.info("ALA15vToolBox A2A_Dispatcher function: Checking if the group, " .. border .. ", exists in the mission")
            if Group.getByName(border) then
                local CCCPBorderZone = ZONE_POLYGON:New(border, GROUP:FindByName(border))
                A2ADispatcher:SetBorderZone(CCCPBorderZone)
            else
                env.warning("ALA15vToolBox A2A_Dispatcher function: The group, " .. border .. ", does not exist in the mission")
            end

            -- Initialize the dispatcher, setting up a radius of 100km where any airborne friendly
            -- without an assignment within 100km radius from a detected target, will engage that target.
            A2ADispatcher:SetEngageRadius(120000)

            -- Setup the default fuel threshold.
            A2ADispatcher:SetDefaultFuelThreshold(0.30)

            -- Now Setup the default damage threshold.
            A2ADispatcher:SetDefaultDamageThreshold(0.50)

            env.info("ALA15vToolBox A2A_Dispatcher function: Adding squadrons")
            for name, airBase in pairs(airBases) do
                -- FIXED: check if airport is controlled by the coalition
                -- TODO: check if this works with carriers or heliports and add some extra condition
                -- TODO: use the model from AI_A2G_dis.lua
                -- TODO: add condition to check if templates exists
                env.info("ALA15vToolBox A2A_Dispatcher function: Checking if the airbase belongs to the coalition " .. coalition)
                if AIRBASE:FindByName(airBase):GetCoalitionName():lower() == coalition then -- NOTE: this condition is important for campaings
                    -- Setup the squadrons.
                    A2ADispatcher:SetSquadron(name, airBase, templates, aircrafts)
                    -- Setup the overhead
                    A2ADispatcher:SetSquadronOverhead(name, overhead)
                    -- Setup the Grouping
                    A2ADispatcher:SetSquadronGrouping(name, groupNumber)
                    -- Setup the Takeoff methods
                    A2ADispatcher:SetSquadronTakeoffFromParkingHot(name)
                    -- Setup the Landing methods
                    A2ADispatcher:SetSquadronLandingAtEngineShutdown(name)
                    -- GCI Squadron execution.
                    A2ADispatcher:SetSquadronGci2(name, 900, 2100, 200, 12000, "BARO")
                    -- Set the language of the squadrons to Russian.
                    A2ADispatcher:SetSquadronLanguage(name, "RU")
                    A2ADispatcher:SetSquadronRadioFrequency(name, 127.5)
                else
                    env.warning("ALA15vToolBox A2A_Dispatcher function: The airbase does not belong to the coalition " .. coalition)
                end
            end
            env.info("ALA15vToolBox A2A_Dispatcher function: All the squadrons added")

            env.info("ALA15vToolBox A2A_Dispatcher function: Returning A2ADispatcher")
            return A2ADispatcher
        else
            env.warning("ALA15vToolBox A2A_Dispatcher function: The group, " .. hq .. ", is not alive")
        end
    else
        env.error("ALA15vToolBox A2A_Dispatcher function: The group " .. hq .. " does not exist")
    end
end

env.info("ALA15vToolBox A2A_Dispatcher declaration done")


--[[
- @brief      This function will assign a cap zone to an A2A Dispatcher squadron
-
- @example    A2A_Dis_Patrol(myA2A_Dis, "zoneCAP1", "Hama")
-
- @param      A2ADispatcher   <AI_A2A_DISPATCHER>    This parameter must be filled with an AI_A2A_DISPATCHER object
- @param      zone   <String>   This is the name of the CAP zone
- @param      squadron   <String>   This is the name of the squadron that will cover this CAP zone
-
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2A_Dispatcher.html
--]]

env.info("ALA15vToolBox A2A_Dis_Patrol declaration")
-- FIXED: needed condition to check if squadron exists
function A2A_Dis_Patrol(A2ADispatcher, zone, squadron)
    env.info("ALA15vToolBox A2A_Dis_Patrol function: Checking if the dispatcher exists")
    if A2ADispatcher then -- NOTE: this condition is important for campaings
        env.info("ALA15vToolBox A2A_Dis_Patrol function: Checking if the squadron, " .. squadron .. ", exists")
        if A2ADispatcher.DefenderSquadrons[squadron] then   -- NOTE: this condition is important for campaings
            local CAPZone = ZONE:New(zone)
            A2ADispatcher:SetSquadronCap(squadron, CAPZone, 6000, 10000, 600, 800, 800, 1200, "BARO")
            A2ADispatcher:SetSquadronCapInterval(squadron, 1, 180, 600, 1)
        else
            env.error("ALA15vToolBox A2A_Dis_Patrol function: The squadron does not exists")
        end
    else
        env.error("ALA15vToolBox A2A_Dis_Patrol function: The dispatcher does not exist")
    end
end

env.info("ALA15vToolBox A2A_Dis_Patrol declaration done")
