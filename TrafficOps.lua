--[[
- @brief      This function will create an ATIS system for the given airport
-
- @example    Atis(AIRBASE.Caucasus.Kutaisi, 143.00, "Radio Relay Kutaisi", {263.0, 134.0}, 44, 113.60, 109.75, nil, nil)
-
- @param                    airPort         <Wrapper.Airbase>                              This is the airport
- @param                    radio           <Float>                                        This is the radio frequency that the relay will use to transmit
- @param                    vehicle         <String>                                       This is vehicle group name that will act as relay
- @param                    freq            <Float>                                        This is the frequencies available on the airport
- @param    (OPTIONAL)      tacan           <Integer>   -NOTE: if not used type " nil "    This is the tacan available on the airport
- @param    (OPTIONAL)      vor             <Float>     -NOTE: if not used type " nil "    This is the vor frequency available on the airport
- @param    (OPTIONAL)      ils             <Float>     -NOTE: if not used type " nil "    This is the ils frequency available on the airport
- @param    (OPTIONAL)      ndbOut          <Float>     -NOTE: if not used type " nil "    This is the outer ndb frequency available on the airport
- @param    (OPTIONAL)      ndbIn           <Float>     -NOTE: if not used type " nil "    This is the inner ndb frequency available on the airport

- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.Atis.html
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Airbase.html
- @see        https://github.com/FlightControl-Master/MOOSE_SOUND
--]]

-- TODO: write in dcs.log

function Atis(airPort, radio, vehicle, freq, tacan, vor, ils, ndbOut, ndbIn)
    local atis = ATIS:New(airPort, radio)
    if Group.getByName(vehicle) then    -- NOTE: this condition is important for campaings
        atis:SetRadioRelayUnitName(vehicle) -- REVIEW: how necessary is this??
    end
    atis:SetTowerFrequencies(freq)
    -- TODO: simplify conditions
    if not (tacan == nil) then
        atis:SetTACAN(tacan)
    end
    if not (vor == nil) then
        atis:SetVOR(vor)
    end
    if not (ils == nil) then
        atis:AddILS(ils)
    end
    if not (ndbOut == nil and ndbIn == nil) then
        atis:AddNDBouter(ndbOut)
        atis:AddNDBinner(ndbIn)
    end
    atis:Start()
end

--[[
- @brief      This function will create random air traffic with the given parameters
-
- @example    RandomTraffic("RAT_A320", {"Aeroflot", "Aeroflot 1", "Air Asia", "Air Berlin"}, false, true, {"Batumi", "Soganlug", "Tiflis-Lochini"}, {"Gudauta", "Gelendzhik", "Krasnodar-Pashkovsky"}, 5, 10, 7900)
-
- @param        template            <String>            This is the group name of the aircraft template
- @param        skins               <String>            This is the skin name or set of skin names that will be used
- @param        iff                 <Boolean>           If true, the aircraft will activate the data link or similar (in case of have it)
- @param        invisible           <Boolean>           If true, the aircraft will be set as invisible
- @param        departure           <String>            This is the airport name or set of airport names from where the aircraft will take off
- @param        destination         <String>            This is the airport name or set of airport names where the aircraft is landing
- @param        number              <Integer>           This is the total number of aircrafts that will fly at same time
- @param        startDelay          <Integer>           This is the number of seconds before start
- @param        stopDelay           <Integer>           This is the number of seconds before stop

- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Functional.Rat.html
--]]

function RandomTraffic(template, skins, iff, invisible, departure, destination, number, startDelay, stopDelay)
    local rat = RAT:New(template):ATC_Messages(false)
    rat:Livery(skins)
    rat:SetDeparture(departure)
    rat:SetDestination(destination)
    rat:StatusReports(false)
    if invisible then
        rat:Invisible()
    end
    if iff then
        rat:SetEPLRS(true)
    end
    local manager = RATMANAGER:New(number) --REVIEW
    manager:Add(rat, number)
    manager:Start(startDelay)
    manager:Stop(stopDelay)
end
