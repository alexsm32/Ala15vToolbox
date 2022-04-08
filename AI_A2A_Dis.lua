--[[
- @brief      This function will create an AI A2A Dispatcher. NOTE: The AI_A2A_DISPATCHER can be use in many different ways. The way I am offering here is 1 airport = 1 squadron = 1 or more templates
-
- @example    myA2A_Dis = A2A_Dispatcher ("HQ", {"AWACS", "EWR"}, "red", "CCCP Border", {Hama = AIRBASE.Syria.Hama, Al_Qusayr = AIRBASE.Syria.Al_Qusayr}, { "SQ CCCP L-39", "SQ CCCP Mig-23", "SQ CCCP Mig-21", "SQ CCCP Mig-29A" }, 20, 0.2, 2, "A2A Dispatcher North")
-
- @param      hq            <String>                                    This is the group name of the unit that represent the command center
- @param      radars        <String>                                    This is the prefix or set of prefixes that will be used to filter the detection groups
- @param      coalition     <String>      {OPTIONS: "blue", "red"}      This is the coalition side that the detection group filter will focus on
- @param      border        <String>                                    This is the group name of the unit with the route that represent the dispatcher border
- @param      airBases      <Key = Wrapper.Airbase>    -NOTE: the key is the squadron name and it contains the airport      This is the set of squadrons and airports available for the dispatcher
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


function A2A_Dispatcher (hq, radars, coalition, border, airBases, templates, aircrafts, overhead, groupNumber, menuName)
    local HQ_Group = GROUP:FindByName( hq )
    local HQ_CC = COMMANDCENTER:New( HQ_Group, "HQ" )

    -- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
    -- Here we build the network with all the groups that have a name starting with DF CCCP AWACS and DF CCCP EWR.
    local DetectionSetGroup = SET_GROUP:New()
    DetectionSetGroup:FilterPrefixes(radars)
    DetectionSetGroup:FilterCoalitions(coalition)
    DetectionSetGroup:FilterStart()

    local Detection = DETECTION_AREAS:New( DetectionSetGroup, 100000 )

    -- Setup the A2A dispatcher, and initialize it.
    A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )
    A2ADispatcher:SetCommandCenter( HQ_CC )

    -- Enable the tactical display panel.
    A2ADispatcher:SetTacticalMenu( "Dispatchers", menuName )
    A2ADispatcher:SetTacticalDisplay( false )

    -- Initialize the dispatcher, setting up a border zone. This is a polygon, 
    -- which takes the waypoints of a late activated group with the name CCCP Border as the boundaries of the border area.
    -- Any enemy crossing this border will be engaged.
    CCCPBorderZone = ZONE_POLYGON:New( border, GROUP:FindByName( border ) )
    A2ADispatcher:SetBorderZone( CCCPBorderZone )

    -- Initialize the dispatcher, setting up a radius of 100km where any airborne friendly 
    -- without an assignment within 100km radius from a detected target, will engage that target.
    A2ADispatcher:SetEngageRadius( 120000 )


    for name,airBase in pairs(airBases) do
        -- Setup the squadrons.
        A2ADispatcher:SetSquadron( name, airBase, templates, aircrafts )
        -- Setup the overhead
        A2ADispatcher:SetSquadronOverhead( name, overhead )
        -- Setup the Grouping
        A2ADispatcher:SetSquadronGrouping( name, groupNumber )
        -- Setup the Takeoff methods
        A2ADispatcher:SetSquadronTakeoffFromParkingHot( name )
        -- Setup the Landing methods
        A2ADispatcher:SetSquadronLandingAtEngineShutdown( name )
        -- GCI Squadron execution.
        A2ADispatcher:SetSquadronGci2( name, 900, 2100, 200, 12000, "BARO" )
        -- Set the language of the squadrons to Russian.
        A2ADispatcher:SetSquadronLanguage( name, "RU" )
        A2ADispatcher:SetSquadronRadioFrequency( name, 127.5 )
    end

    return A2ADispatcher
end

--[[
- @brief      This function will assign a cap zone to an A2A Dispatcher squadron
-
- @example    A2A_Dis_Patrol (myA2A_Dis, "zoneCAP1", "Hama")
-
- @param      A2ADispatcher   <AI_A2A_DISPATCHER>    This parameter must be filled with an AI_A2A_DISPATCHER object
- @param      zone   <String>   This is the name of the CAP zone
- @param      squadron   <String>   This is the name of the squadron that will cover this CAP zone
-
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2A_Dispatcher.html
--]]

-- REVIEW
function A2A_Dis_Patrol (A2ADispatcher, zone, squadron)
    CAPZone = ZONE:New( zone )
    A2ADispatcher:SetSquadronCap( squadron, CAPZone, 6000, 10000, 600, 800, 800, 1200, "BARO" )
    A2ADispatcher:SetSquadronCapInterval( squadron, 1, 180, 600, 1 )
end