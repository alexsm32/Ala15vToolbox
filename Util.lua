
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
    return prefix .. "_" .. mgrs[3] .. string.sub(mgrs[4], 1, 1) .. string.sub(mgrs[5], 1, 1)
end


function SpawnStaticCoor(template, nation, coor, heading, name)
    local static = SPAWNSTATIC:NewFromStatic(template, nation)
    static:SpawnFromCoordinate(coor, heading, name)
end

Ala15vToolBoxUtilLoaded = true -- In case it is needed to check if this module is loaded
