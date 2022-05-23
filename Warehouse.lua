env.info("ALA15vToolBox NewWarehouse declaration")
function NewWarehouse(wh, coalition, assets, autoDefence)
    env.info("ALA15vToolBox NewWarehouse function: Checking if the warehouse, " .. wh .. ", exists in the mission")
    if Static.getByName(wh) then
        local whObj = STATIC:FindByName(wh)
        env.info("ALA15vToolBox NewWarehouse function: Checking if the warehouse, " .. wh .. ", is alive")
        if whObj:IsAlive() then
            env.info("ALA15vToolBox NewWarehouse function: Checking if the warehouse, " .. wh .. ", belongs to the coalition " .. coalition)
            if whObj:GetCoalitionName():lower() == coalition then
                -- SECTION: main
                local warehouse = WAREHOUSE:New(whObj, wh)

                -- SECTION: adding assets
                env.info("ALA15vToolBox NewWarehouse function: Adding assets to the warehouse, " .. wh)
                for name, info in pairs(assets) do
                    env.info("ALA15vToolBox NewWarehouse function: Checking if the asset, " .. name .. ", exists in the mission")
                    if GROUP:FindByName(name) then
                        local asset = GROUP:FindByName(name)
                        if info.type == nil then
                            env.info("ALA15vToolBox NewWarehouse function: Adding standard asset")
                            warehouse:AddAsset(asset, info.number)
                        else
                            env.info("ALA15vToolBox NewWarehouse function: Adding asset of type: " .. info.type)
                            warehouse:AddAsset("Huey", 5, info.type)
                        end
                    else
                        env.error("ALA15vToolBox NewWarehouse function: The asset, " .. name .. ", does not exist in the mission")
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

                -- Returning warehouse object for other uses
                return warehouse
                -- !SECTION
            else
                env.warning("ALA15vToolBox NewWarehouse function: The warehouse " .. wh .. " does not belong to the coalition " .. coalition)
            end
        else
            env.warning("ALA15vToolBox NewWarehouse function: The warehouse " .. wh .. " is not alive")
        end
    else
        env.error("ALA15vToolBox NewWarehouse function: The warehouse " .. wh .. " does not exist")
    end
end

env.info("ALA15vToolBox NewWarehouse declaration done")
