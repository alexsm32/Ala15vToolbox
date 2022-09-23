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
- @param        autoDefence         <Boolean>                                     If true, the warehouse will spawn units when the enemy tries to capture the place
- @param        selfReqMenu         <Boolean>   -NOTE: Util.lua function needed   If true, a new radio menu will be created with radio commands to request units from that warehouse
-
- @return   warehouse   <WAREHOUSE>     The function return the hole WAREHOUSE object
-
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Functional.Warehouse.html
--]]


env.info("ALA15vToolBox NewWarehouse declaration")
function NewWarehouse(wh, coalition, assets, spZone, autoDefence, selfReqMenu)
    env.info("ALA15vToolBox NewWarehouse function: Checking if the warehouse, " .. wh .. ", exists in the mission")
    if StaticObject.getByName(wh) then
        local whObj = STATIC:FindByName(wh)
        env.info("ALA15vToolBox NewWarehouse function: Checking if the warehouse, " .. wh .. ", is alive")
        if whObj:IsAlive() then
            env.info("ALA15vToolBox NewWarehouse function: Checking if the warehouse, " ..
                wh .. ", belongs to the coalition " .. coalition)
            if whObj:GetCoalitionName():lower() == coalition then
                -- SECTION: main
                local warehouse = WAREHOUSE:New(whObj, wh)
                -- SECTION: adding menu
                local whMenu
                if selfReqMenu and Ala15vToolBoxUtilLoaded and coalition == "blue" then
                    whMenu = AddMenuCoalition(coalition, CreateName(wh, whObj:GetCoordinate()), Wharehouses.Menus.Blue) -- Menu name will be the wh name + mgrs coord
                end
                if selfReqMenu and Ala15vToolBoxUtilLoaded and coalition == "red" then
                    whMenu = AddMenuCoalition(coalition, CreateName(wh, whObj:GetCoordinate()), Wharehouses.Menus.Red)  -- Menu name will be the wh name + mgrs coord
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
                            local whMenu = AddCommandCoalition(coalition, "Spawn " .. name, whMenu, NewWarehouseSelfReq, warehouse, name)
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
                if autoDefence then
                    warehouse:SetAutoDefenceOn()
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

env.info("ALA15vToolBox NewWarehouse declaration done")

-- NOTE: WIP
env.info("ALA15vToolBox NewWarehouseSelfReq declaration")
function NewWarehouseSelfReq(wh, template)
    wh:AddRequest(wh, WAREHOUSE.Descriptor.GROUPNAME, template)
end

env.info("ALA15vToolBox NewWarehouseSelfReq declaration done")

Ala15vToolBoxWarehouseLoaded = true -- In case it is needed to check if this module is loaded
