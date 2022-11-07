Wharehouses = {
    Menus = {},
    Blue = {},
    Red = {}
}

if Ala15vToolBoxUtilLoaded then -- REVIEW
    Wharehouses.Menus.Blue = AddMenuCoalition("blue", "Warehouses")
    Wharehouses.Menus.Red = AddMenuCoalition("red", "Warehouses")
end

--[[
- @brief      This function will create a Warehouse.
-
- @example  --REVIEW    myWarehouse = NewWarehouse("wh1", "blue", {T90={number=20, type=nil}, Mi8={number=10, type=WAREHOUSE.Attribute.AIR_TRANSPORTHELO}}, nil, true)
- @example  --REVIEW    myWarehouse = NewWarehouse("wh2", "red", {T90={number=20, type=nil}, Ka50={number=15, type=nil}}, "zoneWh2", false)
-
- @param        wh                  <String>                                      This is the name of the structure that represent the warehouse
- @param        coalition           <String>      {OPTIONS: "blue", "red"}        This is the coalition side of the warehouse
- @param        assets              <Key=Integer,WAREHOUSE.Attribute>             This is the set of assets that will be added to the warehouse  -NOTE: the key is the group name (NO SPACES) of the template and it contains the total number assets added to the warehouse and the type
- @param        spZone              <String>    -NOTE: if not used type " nil "   This is the name of zone used by the warehouse as default spawn zone
- @param        defZone             <String>    -NOTE: if not used type " nil "   This is the name of zone used by the warehouse as selfdefend zone for triggering the event OnAfterAttacked
- @param        portZone            <String>    -NOTE: if not used type " nil "   This is the name of zone used by the warehouse as port zone for spawning ships
- @param        selfReqMenu         <Boolean>   -NOTE: Util.lua function needed   If true, a new radio menu will be created with radio commands to request units from that warehouse
-
- @return   warehouse   <WAREHOUSE>     The function return the hole WAREHOUSE object
-
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Functional.Warehouse.html
--]]

-- ANCHOR: NewWarehouse
env.info("ALA15vToolBox NewWarehouse declaration")
function NewWarehouse(wh, coalition, assets, spZone, defZone, portZone, selfReqMenu)
    env.info("ALA15vToolBox NewWarehouse function: Checking if the warehouse, " .. wh .. ", exists in the mission")
    if StaticObject.getByName(wh) then
        local whObj = STATIC:FindByName(wh)
        env.info("ALA15vToolBox NewWarehouse function: Checking if the warehouse, " .. wh .. ", is alive")
        if whObj:IsAlive() then
            env.info("ALA15vToolBox NewWarehouse function: Checking if the warehouse, " ..
                wh .. ", belongs to the coalition " .. coalition)
            if whObj:GetCoalitionName():lower() == coalition then
                -- SECTION: main
                local whName = wh
                if Ala15vToolBoxUtilLoaded then -- If Ala15vToolBoxUtilLoaded the whName will be wh name + mgrs coord
                    env.info("ALA15vToolBox NewWarehouse function: Combining warehouse name and mgrs coordinates")
                    whName = CreateName(wh, whObj:GetCoordinate())
                end

                local warehouse = WAREHOUSE:New(whObj, whName)
                -- SECTION: adding menu
                local whMenu
                if selfReqMenu and Ala15vToolBoxUtilLoaded and coalition == "blue" then
                    whMenu = AddMenuCoalition(coalition, whName, Wharehouses.Menus.Blue)
                end
                if selfReqMenu and Ala15vToolBoxUtilLoaded and coalition == "red" then
                    whMenu = AddMenuCoalition(coalition, whName, Wharehouses.Menus.Red)
                end
                -- !SECTION

                if spZone then
                    warehouse:SetSpawnZone(ZONE:New(spZone))
                end

                -- SECTION: adding assets
                env.info("ALA15vToolBox NewWarehouse function: Adding assets to the warehouse, " .. wh)
                for name, info in pairs(assets) do
                    env.info("ALA15vToolBox NewWarehouse function: Checking if the asset, " ..
                        name .. ", exists in the mission")
                    if Group.getByName(name) then
                        local asset = GROUP:FindByName(name)
                        if info.type == nil then
                            env.info("ALA15vToolBox NewWarehouse function: Adding standard asset")
                            warehouse:AddAsset(asset, info.number)
                        else
                            env.info("ALA15vToolBox NewWarehouse function: Adding asset of type: " .. info.type)
                            warehouse:AddAsset(asset, info.number, info.type)
                        end
                        -- SECTION: adding command menu
                        if selfReqMenu and Ala15vToolBoxUtilLoaded then
                            local whMenu = AddCommandCoalition(coalition, "Spawn " .. name, whMenu, NewWarehouseSelfReq,
                                warehouse, name)
                        end
                        -- !SECTION
                    else
                        env.error("ALA15vToolBox NewWarehouse function: The asset, " ..
                            name .. ", does not exist in the mission")
                    end
                end
                env.info("ALA15vToolBox NewWarehouse function: All the assets added to the warehouse, " .. wh)
                -- !SECTION

                warehouse:SetReportOff()

                if defZone then -- adding the provided defzone
                    if type(defZone) == "string" then
                        env.info("ALA15vToolBox NewWarehouse function: Adding defended zone, " ..
                            defZone .. " to the warehouse")
                        warehouse:SetWarehouseZone(ZONE:New(defZone))
                    else
                        env.info("ALA15vToolBox NewWarehouse function: Adding defended zone, " ..
                            defZone:GetName() .. " to the warehouse")
                        warehouse:SetWarehouseZone(defZone)
                    end
                end

                if portZone then
                    if type(portZone) == "string" then
                        env.info("ALA15vToolBox NewWarehouse function: Adding port zone, " ..
                            portZone .. " to the warehouse")
                        warehouse:SetPortZone(ZONE:New(portZone))
                    else
                        env.info("ALA15vToolBox NewWarehouse function: Adding port zone, " ..
                            portZone:GetName() .. " to the warehouse")
                        warehouse:SetPortZone(portZone)
                    end
                end

                -- Start warehouse
                warehouse:Start()

                -- Adding the warehouse object to the table
                if coalition == "blue" then
                    table.insert(Wharehouses.Blue, warehouse)
                end
                if coalition == "red" then
                    table.insert(Wharehouses.Red, warehouse)
                end
                -- Returning warehouse object for other uses
                return warehouse
                -- !SECTION
            else
                env.warning("ALA15vToolBox NewWarehouse function: The warehouse " ..
                    wh .. " does not belong to the coalition " .. coalition)
            end
        else
            env.warning("ALA15vToolBox NewWarehouse function: The warehouse " .. wh .. " is not alive")
        end
    else
        env.error("ALA15vToolBox NewWarehouse function: The warehouse " .. wh .. " does not exist")
    end
end

-- ANCHOR: NewWarehouseSelfReq
env.info("ALA15vToolBox NewWarehouse declaration done")

-- NOTE: WIP
env.info("ALA15vToolBox NewWarehouseSelfReq declaration")
function NewWarehouseSelfReq(wh, template)
    wh:AddRequest(wh, WAREHOUSE.Descriptor.GROUPNAME, template)
end

env.info("ALA15vToolBox NewWarehouseSelfReq declaration done")


--[[
- @brief      This function will detect all the static object with the given prefix and will create a full warehouse system for each static object found.
-
- @example    WarehouseAutoGen("wh", "whz", "blue", {T90={number=20, type=nil}, Mi8={number=10, type=WAREHOUSE.Attribute.AIR_TRANSPORTHELO}}, 10000, false, true)
- @example    WarehouseAutoGen("wh", "whz", "blue", {T90={number=20, type=nil}, Ka50={number=15, type=nil}}, 1500, false, true)
-
- @param        whPrefix            <String>                                      This is the prefix of the structures that will be detected as warehouses
- @param        zPrefix             <String>    -NOTE: it should accept a table   This is the prefix of the zones that the warehouses will try to control
- @param        coalition           <String>      {OPTIONS: "blue", "red"}        This is the coalition side of the warehouses
- @param        templates           <Key=Integer,WAREHOUSE.Attribute>             This is the set of assets that will be added to the warehouse  -NOTE: the key is the group name (NO SPACES) of the template and it contains the total number assets added to the warehouse and the type
- @param        coverRange          <Integer>                                     This is the range in meters where the warehouse will try to control
- @param        selfDefense         <Boolean>                                     If true, the warehouses will spawn 1/4 of the available units when enemy units get closer than 500 meters     -NOTE: the radius can be manually set with a trigger zone with prefix "defzone". Warehouses will detect any zone with that prefix if it is closer than 300 meters
- @param        selfReqMenu         <Boolean>   -NOTE: Util.lua function needed   If true, a new radio menu will be created with radio commands to request units from that warehouse
-
- @return
-
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Functional.Warehouse.html
--]]

-- NOTE: WIP
-- ANCHOR: WarehouseAutoGen
env.info("ALA15vToolBox WarehouseAutoGen declaration")
-- WarehouseAutoGen("wh", "wh", "blue", TEST, 500, false, true)
function WarehouseAutoGen(whPrefix, zPrefix, coalition, templates, coverRange, selfDefense, selfReqMenu)
    -- SECTION: databases
    local DBObject = SET_STATIC:New()
    DBObject:FilterCoalitions(coalition)
    DBObject:FilterPrefixes(whPrefix)
    DBObject:FilterOnce()

    DBdefZone = SET_ZONE:New()
    DBdefZone:FilterPrefixes("defzone")
    DBdefZone:FilterOnce()

    local DBZone = SET_ZONE:New()
    DBZone:FilterPrefixes(zPrefix)
    DBZone:FilterOnce()

    local DBspZone
    DBspZone = SET_ZONE:New()
    DBspZone:FilterPrefixes("spzone")
    DBspZone:FilterOnce()

    local DBportZone
    DBportZone = SET_ZONE:New()
    DBportZone:FilterPrefixes("portzone")
    DBportZone:FilterOnce()


    -- !SECTION

    -- SECTION: databases logs
    -- DBObject
    if DBObject:Count() < 1 then
        env.error("ALA15vToolBox WarehouseAutoGen: The amount of static objects filtering by coalition, " ..
            coalition .. ", and prefix, " .. whPrefix .. ", is equal to " .. DBObject:Count())
    else
        env.info("ALA15vToolBox WarehouseAutoGen: The amount of static objects filtering by coalition, " ..
            coalition .. ", and prefix, " .. whPrefix .. ", is equal to " .. DBObject:Count())
    end
    if DBObject:CountAlive() < 1 then
        env.error("ALA15vToolBox WarehouseAutoGen: The amount of ALIVE static objects filtering by coalition, " ..
            coalition .. ", and prefix, " .. whPrefix .. ", is equal to " .. DBObject:CountAlive())
    elseif DBObject:Count() ~= DBObject:CountAlive() then
        env.error("ALA15vToolBox WarehouseAutoGen: The amount of ALIVE static objects filtering by coalition, " ..
            coalition .. ", and prefix, " .. whPrefix .. ", is equal to " .. DBObject:CountAlive())
    else
        env.info("ALA15vToolBox WarehouseAutoGen: The amount of ALIVE static objects filtering by coalition, " ..
            coalition .. ", and prefix, " .. whPrefix .. ", is equal to " .. DBObject:CountAlive())
    end

    -- DBdefZone
    if DBdefZone:Count() < 1 then
        env.warning("ALA15vToolBox WarehouseAutoGen: The amount of defense zones filtering by prefix, defzone, is equal to "
            .. DBdefZone:Count())
    else
        env.info("ALA15vToolBox WarehouseAutoGen: The amount of defense zones filtering by prefix, defzone, is equal to "
            .. DBdefZone:Count())
    end

    -- DBZone
    if DBZone:Count() < 1 then
        env.warning("ALA15vToolBox WarehouseAutoGen: The amount of zones of interest filtering by prefix, " ..
            zPrefix .. ", is equal to " .. DBZone:Count())
    else
        env.info("ALA15vToolBox WarehouseAutoGen: The amount of zones of interest filtering by prefix, " ..
            zPrefix .. ", is equal to " .. DBZone:Count())
    end

    -- DBspZone
    if DBspZone:Count() < 1 then
        env.warning("ALA15vToolBox WarehouseAutoGen: The amount of spawn zones filtering by prefix, spzone, is equal to "
            .. DBspZone:Count())
    else
        env.info("ALA15vToolBox WarehouseAutoGen: The amount of spawn zones filtering by prefix, spzone, is equal to " ..
            DBspZone:Count())
    end

    -- DBportZone
    if DBportZone:Count() < 1 then
        env.warning("ALA15vToolBox WarehouseAutoGen: The amount of port zones filtering by prefix, portzone, is equal to "
            .. DBportZone:Count())
    else
        env.info("ALA15vToolBox WarehouseAutoGen: The amount of port zones filtering by prefix, portzone, is equal to "
            .. DBportZone:Count())
    end
    -- !SECTION

    for _, static in pairs(DBObject:GetSet()) do
        local static = static --Wrapper.Group#GROUP
        env.info("ALA15vToolBox WarehouseAutoGen: Started autogeneration of a new warehouse using the static, " ..
            static:GetName())
        if static:IsAlive() then
            local spawn = nil
            local spawnDist = 1000
            for _, zone in pairs(DBspZone:GetSet()) do
                local dist = UTILS.VecDist2D(static:GetVec2(), zone:GetVec2())
                if dist < spawnDist then
                    spawnDist = dist
                    spawn = zone:GetName()
                end
            end
            if spawn == nil then
                env.warning("ALA15vToolBox WarehouseAutoGen: No suitable spawn zone was found for the warehouse, " ..
                    static:GetName())
            else
                env.info("ALA15vToolBox WarehouseAutoGen: Selected spawn zone, " ..
                    spawn .. " at " .. spawnDist .. "m, for the warehouse, " ..
                    static:GetName())
            end


            local defZone = nil
            local defZoneDist = 300
            for _, zone in pairs(DBdefZone:GetSet()) do
                local dist = UTILS.VecDist2D(static:GetVec2(), zone:GetVec2())
                if dist < defZoneDist then
                    defZoneDist = dist
                    defZone = zone:GetName()
                end
            end
            if defZone == nil then
                env.warning("ALA15vToolBox WarehouseAutoGen: No suitable defense zone was found for the warehouse, " ..
                    static:GetName())

                --FIXED: GetVec2() instead of GetCoordinate()   REVIEW
                local newDefZone = ZONE_RADIUS:New("defzone_" .. static:GetName(), static:GetVec2(), 1000) -- REVIEW: radius default
                DBdefZone:AddZone(newDefZone)
                defZone = newDefZone
                env.info("ALA15vToolBox WarehouseAutoGen: Created and added to the database new defense zone with name, "
                    ..
                    defZone:GetName() .. ", for the warehouse, " ..
                    static:GetName())
            else
                env.info("ALA15vToolBox WarehouseAutoGen: Selected defense zone, " ..
                    defZone .. " at " .. defZoneDist .. "m, for the warehouse, " ..
                    static:GetName())
            end

            local portZone = nil
            local portZoneDist = 10000
            for _, zone in pairs(DBportZone:GetSet()) do
                local dist = UTILS.VecDist2D(static:GetVec2(), zone:GetVec2())
                if dist < portZoneDist then -- REVIEW: Distance
                    portZoneDist = dist
                    portZone = zone:GetName()
                end
            end
            if portZone == nil then
                env.info("ALA15vToolBox WarehouseAutoGen: No suitable port zone was found for the warehouse, " ..
                    static:GetName())
            else
                env.info("ALA15vToolBox WarehouseAutoGen: Selected port zone, " ..
                    portZone .. " at " .. portZoneDist .. "m, for the warehouse, " ..
                    static:GetName())
            end

            env.info("ALA15vToolBox WarehouseAutoGen: Running NewWarehouse() function for the static, " ..
                static:GetName())
            local warehouse = NewWarehouse(static:GetName(), coalition, templates, spawn, defZone, portZone, selfReqMenu)

            -- SECTION: OnAfterSelfRequest event
            -- TODO: do magic with the infantry
            function warehouse:OnAfterSelfRequest(From, Event, To, groupset, request)
                local groupset = groupset --Core.Set#SET_GROUP
                local request = request --Functional.Warehouse#WAREHOUSE.Pendingitem

                -- Get assignment of this request.
                local assignment = warehouse:GetAssignment(request) -- NOTE: the assignment is oriented to be a zone name

                if assignment == "selfDefense" then -- if the selfrequest comes from the attacked event
                    local zone -- FIXME
                    if type(defZone) == "string" then
                        zone = DBdefZone:FindZone(defZone)
                    else
                        zone = defZone
                    end


                    for _, group in pairs(groupset:GetSet()) do
                        local group = group --Wrapper.Group#GROUP

                        -- Route group to Battle zone.
                        local ToCoord = zone:GetRandomCoordinate()
                        group:RouteGroundTo(ToCoord, group:GetSpeedMax() * 0.8)

                    end
                else
                    local zone = DBZone:FindZone(assignment) -- FIXME

                    for _, group in pairs(groupset:GetSet()) do
                        local group = group --Wrapper.Group#GROUP

                        -- Route group to Battle zone.
                        local ToCoord = zone:GetRandomCoordinate()
                        if group:GetCategory() == Group.Category.GROUND then
                            group:RouteGroundOnRoad(ToCoord, group:GetSpeedMax() * 0.8)
                        else
                            local wDistance = UTILS.VecDist2D(static:GetVec2(), zone:GetVec2())
                            local BoxHY = wDistance + 40000
                            local SpaceX = 20000
                            local deltaX = 4000

                            local path = ASTAR:New()
                            path:SetStartCoordinate(ZONE:New(portZone):GetRandomCoordinate())
                            path:SetEndCoordinate(ToCoord)
                            path:SetValidNeighbourDistance(6000) --REVIEW
                            path:SetValidNeighbourLoS(4000) --REVIEW
                            path:CreateGrid(zone:GetSurfaceType(), BoxHY, SpaceX, deltaX, nil, false)

                            local points = {}
                            for _, point in pairs(path:GetPath(true, false)) do
                                table.insert(points, point.coordinate:WaypointNaval())
                            end

                            group:Route(points)

                            --group:RouteGroundTo(ToCoord, group:GetSpeedMax() * 0.8)
                        end

                    end

                end
            end

            -- !SECTION

            -- SECTION: OnAfterAssetDead event
            -- TODO: get closest warehouse
            function warehouse:OnAfterAssetDead(From, Event, To, asset, request)
                local asset = asset --Functional.Warehouse#WAREHOUSE.Assetitem
                local request = request --Functional.Warehouse#WAREHOUSE.Pendingitem

                -- Get assignment.
                local assignment = warehouse:GetAssignment(request)

                -- Get nearest warehouse with the asset type
                -- REVIEW: possible parameter numAssets
                local nearest, dist = warehouse:FindNearestWarehouse(3, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute,
                    nil, nil)

                if assignment ~= "selfDefense" then
                    -- Send asset to Battle zone either now or when they arrive.
                    warehouse:AddRequest(warehouse, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil, nil,
                        assignment)

                    -- Resupply from the nearest warehouse
                    if nearest then
                        if asset.attribute == WAREHOUSE.Attribute.GROUND_INFANTRY and
                            nearest:GetNumberOfAssets(WAREHOUSE.Descriptor.ATTRIBUTE,
                                WAREHOUSE.Attribute.AIR_TRANSPORTHELO) > 0 and nearest:GetAirbaseCategory() > 0 then
                            nearest:AddRequest(warehouse, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1,
                                WAREHOUSE.TransportType.HELICOPTER, nil, nil, "Resupply")

                        elseif asset.attribute == WAREHOUSE.Attribute.GROUND_INFANTRY then
                            nearest:AddRequest(warehouse, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1,
                                WAREHOUSE.TransportType.APC, nil, nil, "Resupply")

                        else
                            nearest:AddRequest(warehouse, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil, nil,
                                nil, "Resupply")
                        end
                    end
                end
            end

            -- !SECTION

            -- SECTION: OnAfterAttacked event
            -- selfDefense
            if selfDefense then
                function warehouse:OnAfterAttacked(From, Event, To, Coalition, Country) -- DONE: scan the zone in case it is already defended
                    local IsDefended = false --REVIEW
                    if defZone ~= nil then
                        local DBDef = SET_GROUP:New()
                        DBDef:FilterCoalitions(coalition)
                        if type(defZone) == "string" then
                            DBDef:FilterZones({ DBdefZone:FindZone(defZone) }) -- FIXED: zone in table
                        else
                            DBDef:FilterZones({ defZone }) -- FIXED: zone in table
                        end
                        DBDef:FilterOnce()

                        if DBDef:Count() > 3 then -- REVIEW: possible parameter??
                            IsDefended = true
                        end
                    end

                    if not IsDefended then -- If the zone is not well defended
                        warehouse:AddRequest(warehouse, WAREHOUSE.Descriptor.CATEGORY, Group.Category.GROUND,
                            WAREHOUSE.Quantity.QUARTER, nil, nil, nil, "selfDefense")
                    end
                end
            end
            -- !SECTION

            -- SECTION: OnAfterCaptured
            -- TODO
            -- !SECTION

            -- SECTION: SelfRequest
            for _, zone in pairs(DBZone:GetSet()) do
                local zoneSurfaceType = zone:GetSurfaceType()
                zone:Scan({ Object.Category.UNIT }, { Unit.Category.GROUND_UNIT })
                local IsOccupied = true --REVIEW
                if coalition == "blue" then
                    IsOccupied = zone:IsNoneInZoneOfCoalition(2)
                elseif coalition == "red" then
                    IsOccupied = zone:IsNoneInZoneOfCoalition(1)
                end
                -- TODO: DYNAMIC LIST
                if (UTILS.VecDist2D(static:GetVec2(), zone:GetVec2()) < coverRange) and
                    not (zoneSurfaceType == land.SurfaceType.SHALLOW_WATER or zoneSurfaceType == land.SurfaceType.WATER)
                    and IsOccupied then -- this check if the zone is in the cover range of the warehouse, if the zone is on the water and if there are units of the coalition
                    warehouse:AddRequest(warehouse, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_INFANTRY,
                        1, nil, nil, nil, zone:GetName())
                    warehouse:AddRequest(warehouse, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_APC, 1,
                        nil, nil, nil, zone:GetName())
                    warehouse:AddRequest(warehouse, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_TANK, 1,
                        nil, nil, nil, zone:GetName())
                    warehouse:AddRequest(warehouse, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_TRUCK, 1,
                        nil, nil, nil, zone:GetName())
                    warehouse:AddRequest(warehouse, WAREHOUSE.Descriptor.ATTRIBUTE, WAREHOUSE.Attribute.GROUND_AAA, 1,
                        nil, nil, nil, zone:GetName())
                elseif (UTILS.VecDist2D(static:GetVec2(), zone:GetVec2()) < coverRange) and
                    (zoneSurfaceType == land.SurfaceType.SHALLOW_WATER or zoneSurfaceType == land.SurfaceType.WATER) and
                    IsOccupied and portZone then
                    if zoneSurfaceType == land.SurfaceType.SHALLOW_WATER then
                        warehouse:AddRequest(warehouse, WAREHOUSE.Descriptor.ATTRIBUTE,
                            WAREHOUSE.Attribute.NAVAL_ARMEDSHIP, 2, nil, nil, nil, zone:GetName())
                    else
                        local closestRoad = zone:GetCoordinate(0):GetClosestPointToRoad()

                        warehouse:AddRequest(warehouse, WAREHOUSE.Descriptor.ATTRIBUTE,
                            WAREHOUSE.Attribute.NAVAL_WARSHIP,
                            1, nil, nil, nil, zone:GetName())
                        if zone:Get2DDistance(closestRoad) < 23000 then
                            warehouse:AddRequest(warehouse, WAREHOUSE.Descriptor.ATTRIBUTE,
                                WAREHOUSE.Attribute.NAVAL_ARMEDSHIP, 1, nil, nil, nil, zone:GetName())
                        end
                    end
                end
            end
            -- !SECTION
        else
            env.warning("ALA15vToolBox WarehouseAutoGen: The autogeneration of a new warehouse using the static, " ..
                static:GetName() .. ", can NOT procede. The static object is not alive")
        end

    end
end

env.info("ALA15vToolBox WarehouseAutoGen declaration done")

Ala15vToolBoxWarehouseLoaded = true -- In case it is needed to check if this module is loaded
