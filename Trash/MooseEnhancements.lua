--- Find, not the nearest warehouse, but close enough in service, i.e. warehouses which are not started, stopped or destroyed are not considered.
-- Optionally, only warehouses with (specific) assets can be included in the search or warehouses of a certain coalition.
-- @param #WAREHOUSE self
-- @param MinAssets (Optional) Minimum number of assets the warehouse should have. Default 0.
-- @param #string Descriptor (Optional) Descriptor describing the selected assets which should be in stock. See @{#WAREHOUSE.Descriptor} for possible values.
-- @param DescriptorValue (Optional) Descriptor value selecting the type of assets which should be in stock.
-- @param DCS#Coalition.side Coalition (Optional) Coalition side of the warehouse. Default is the same coalition as the present warehouse. Set to false for any coalition.
-- @param Core.Point#COORDINATE RefCoordinate (Optional) Coordinate to which the closest warehouse is searched. Default is the warehouse calling this function.
-- @return #WAREHOUSE The the nearest warehouse object. Or nil if no warehouse is found.
-- @return #number The distance to the nearest warehouse in meters. Or nil if no warehouse is found.
function WAREHOUSE:FindNeighborWarehouse(MinAssets, Descriptor, DescriptorValue, Coalition, RefCoordinate, StartDist)
    -- Defaults
    if Descriptor ~= nil and DescriptorValue ~= nil then
        MinAssets = MinAssets or 1
    else
        MinAssets = MinAssets or 0
    end

    -- Coalition - default only the same as this warehouse.
    local anycoalition = nil
    if Coalition ~= nil then
        if Coalition == false then
            anycoalition = true
        else
            -- Nothing to do
        end
    else
        if self ~= nil then
            Coalition = self:GetCoalition()
        else
            anycoalition = true
        end
    end

    -- Coordinate of this warehouse or user specified reference.
    local coord = RefCoordinate or self:GetCoordinate()

    -- Loop over all warehouses.
    local nearest = nil
    local distmin = nil
    for wid, warehouse in pairs(_WAREHOUSEDB.Warehouses) do
        local warehouse = warehouse --#WAREHOUSE

        -- Distance from this warehouse to the other warehouse.
        local dist = coord:Get2DDistance(warehouse:GetCoordinate())

        if dist > 0 then
            -- Check if coalition is right.
            local samecoalition = anycoalition or Coalition == warehouse:GetCoalition()

            -- Check that warehouse is in service.
            if samecoalition and not (warehouse:IsNotReadyYet() or warehouse:IsStopped() or warehouse:IsDestroyed()) then
                -- Get number of assets. Whole stock is returned if no descriptor/value is given.
                local nassets = warehouse:GetNumberOfAssets(Descriptor, DescriptorValue)

                --env.info(string.format("FF warehouse %s nassets = %d  for %s=%s", warehouse.alias, nassets, tostring(Descriptor), tostring(DescriptorValue)))

                -- Assume we have enough.
                local enough = true
                -- If specifc assets need to be present...
                if Descriptor and DescriptorValue then
                    -- Check that enough assets (default 1) are available.
                    enough = nassets >= MinAssets
                end

                -- Check distance.
                if enough and (distmin == nil or dist < distmin) and dist > StartDist then
                    distmin = dist
                    nearest = warehouse
                end
            end
        end
    end

    return nearest, distmin
end
