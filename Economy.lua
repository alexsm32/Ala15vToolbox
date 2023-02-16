-- NOTE: This is work in progress. Documentation coming.......... in the future

function GetWarehouseAssetProduction(coor, factory, range, rate, coalition)
    local coalition = coalition
    local zone = ZONE_RADIUS:New("scanfactorieszone", coor, range)
    --zone:SetRadius(range)
    --zone:SetVec2(coor)

    if type(coalition) ~= "string" then
        coalition = string.lower(UTILS.GetCoalitionName(coalition))
    end

    local statics = SET_STATIC:New()
    statics:FilterCoalitions(coalition)
    statics:FilterPrefixes(factory)
    statics:FilterZones({zone})
    statics:FilterOnce()

    local FactoryCount = 0

    for _, static in pairs(statics:GetSet()) do
        if static:IsAlive() then
            FactoryCount = FactoryCount + 1
        end
    end
    return FactoryCount * rate
end
--[[
--TESTING   WIP     FUTURE PILOT ECONOMY
local Path = lfs.writedir() .. "Missions"
local Filename = "EconomyTest"
--local client = UNIT:FindByName("Aéreo-1-1")
--local Data = client:GetTemplatePayload()
--Data = UTILS.OneLineSerialize(Data)
--UTILS.SaveToFile(Path, Filename, Data)

--clients = SET_CLIENT:New():FilterStart()

pilots = {}

-- Crear la clase PilotRecord
PilotRecord = {}

-- Constructor de la clase
function PilotRecord:new(name)
    -- Crear un nuevo objeto de la clase
    local pilot = {}

    -- Establecer los valores iniciales del objeto
    pilot.Name = name

    pilot.Reputation = 0
    pilot.Debt = 0
    pilot.Income = 0

    pilot.ClearTakeOff = false

    -- Establecer la clase como prototipo del objeto
    setmetatable(pilot, self)
    self.__index = self

    pilots[name] = pilot
    -- Devolver el objeto
    return pilot
end

-- This method calculates the cost for the payload
function PilotRecord:GetPayloadCost(unit)
    local cost = 0
    local ammoCost = 0
    local fuelCost = 0
    local ammo = unit:GetAmmo()
    local fuel = unit:GetTemplateFuel() * unit:GetFuel()

    -- For each type of weapon
    if ammo then -- this prevent bad exceptions when there is not payload
        for _, weapon in pairs(ammo) do
            local count = weapon.count
            local type = weapon.desc.typeName
            local typeMultiplier = 1
            local warhead = nil

            if string.find(type, "shells") then
                typeMultiplier = 0.6
            elseif string.find(type, "nurs") then
                typeMultiplier = 2.5
            elseif string.find(type, "missiles") then
                typeMultiplier = 3
            end

            if weapon.desc.warhead then
                warhead = weapon.desc.warhead

                ammoCost = ammoCost + (count * (warhead.explosiveMass + warhead.mass) * typeMultiplier)
            else
                ammoCost = ammoCost + count * typeMultiplier
            end
        end
    end

    fuelCost = fuel -- TODO: Add some external factor
    cost = ammoCost + fuelCost

    return cost, ammoCost, fuelCost
end

function PilotRecord:GetReputation()
    return self.Reputation
end

function PilotRecord:GetDebt()
    return self.Debt
end

function PilotRecord:ClearToTakeOff(unit)
    local cost, ammoCost, fuelCost = self:GetPayloadCost(unit)

    self.Debt = cost

    trigger.action.outTextForCoalition(coalition.side.BLUE,
        "Your ammo cost is: " ..
        ammoCost .. "\nYour fuel cost is: " .. fuelCost, 10)

    if self.Reputation < self.Debt then
        self.ClearTakeOff = false
        return false
    else
        self.ClearTakeOff = true
        return true
    end
end

local EventHandler = EVENTHANDLER:New()
EventHandler:HandleEvent(EVENTS.PlayerEnterAircraft)

function EventHandler:OnEventPlayerEnterAircraft(EventData)
    -- Obtener el nombre del jugador
    local name = EventData.IniPlayerName
    local unit = EventData.IniUnit
    -- Obtener el uid del jugador
    --local uid = event.initiator:getID()

    local pilotRecord = PilotRecord:new(name)
    env.error(name .. " ha sido añadido a la lista.")

    trigger.action.outTextForCoalition(coalition.side.BLUE,
        name .. " ha sido añadido a la lista.", 10)

    --env.warning(UTILS.OneLineSerialize(unit))

    unit:HandleEvent(EVENTS.Takeoff)
    unit:HandleEvent(EVENTS.Land)

    function unit:OnEventTakeoff(EventData)
        -- get templatefuel + getfuel
        --local ammo = unit:GetTemplateFuel()
        --trigger.action.outTextForCoalition(coalition.side.BLUE,
        --UTILS.OneLineSerialize(ammo), 10)
        --env.warning(UTILS.OneLineSerialize(ammo))
        --local payload = unit:GetTemplatePayload()
        local isClearToTakeOff = pilotRecord:ClearToTakeOff(unit)
        if isClearToTakeOff then
            trigger.action.outTextForCoalition(coalition.side.BLUE,
                "You are clear to take off", 10)
        else
            trigger.action.outTextForCoalition(coalition.side.BLUE,
                "You are NOT clear to take off\nYour reputation is: " ..
                pilotRecord:GetReputation() .. "\nYour payload cost is: " .. pilotRecord:GetDebt(), 10)
        end
    end

    function unit:OnEventLand(EventData)
        local payload = unit:GetTemplatePayload()
    end
end
]]--

Ala15vToolBoxEconomyLoaded = true -- In case it is needed to check if this module is loaded
