function AddMenuCoalition(menuCoalition, text, father)
    local menu
    if type(text) == "string" then
        if father then
            if menuCoalition == "red" then
                menu = MENU_COALITION:New(coalition.side.RED, text, father)
            else
                menu = MENU_COALITION:New(coalition.side.BLUE, text, father)
            end
        else
            if menuCoalition == "red" then
                menu = MENU_COALITION:New(coalition.side.RED, text)
            else
                menu = MENU_COALITION:New(coalition.side.BLUE, text)
            end
        end
        return menu
    end
end

function AddCommandCoalition(menuCoalition, text, father, command, arg1, arg2)
    local commandM
    if type(text) == "string" then
        if menuCoalition == "red" then
            commandM = MENU_COALITION_COMMAND:New(coalition.side.RED, text, father, command, arg1, arg2)
        else
            commandM = MENU_COALITION_COMMAND:New(coalition.side.BLUE, text, father, command, arg1, arg2)
        end
        return commandM
    end
end

function CreateName(prefix, coord)
    local mgrs = {}
    for value in string.gmatch(coord:GetName(), "%S+") do
        table.insert(mgrs, value)
    end
    return mgrs[3] .. string.sub(mgrs[4], 1, 1) .. string.sub(mgrs[5], 1, 1) .. "_" .. prefix
end

function SpawnStaticCoor(template, nation, coor, heading, name)
    local static = SPAWNSTATIC:NewFromStatic(template, nation)
    static:SpawnFromCoordinate(coor, heading, name)
end

function StaticRepair(stPrefix, cratePrefix, crates, range, coalition)
    local DBObject = SET_STATIC:New()
    DBObject:FilterCoalitions(coalition)
    DBObject:FilterPrefixes(stPrefix)
    DBObject:FilterOnce()
    for _, static in pairs(DBObject:GetSet()) do
        if not static:IsAlive() then
            local scanZone = ZONE_RADIUS:New("scanzone" .. static:GetName(), static:GetVec2(), range)

            local DBCrate = SET_STATIC:New()
            DBCrate:FilterCoalitions(coalition)
            DBCrate:FilterZones({ scanZone })
            DBCrate:FilterPrefixes(cratePrefix)
            DBCrate:FilterOnce()

            if DBCrate:Count() >= crates then
                -- TODO: for loop to delete crates
                local removedCrates = 0
                for _, crate in pairs(DBCrate:GetSet()) do
                    if removedCrates < crates then -- This condition prevents deleating more crates than necessary
                        crate:Destroy() -- Remove the crates used to repair
                        removedCrates = removedCrates + 1
                    end
                end

                static:Destroy() -- First remove the destroyed structure
                static:ReSpawn() -- Then respawn the structure
                env.info("ALA15vToolBox StaticRepair: Repaired the structure with name, " ..
                    static:GetName())
            end
        end
    end
end

Ala15vToolBoxUtilLoaded = true -- In case it is needed to check if this module is loaded
