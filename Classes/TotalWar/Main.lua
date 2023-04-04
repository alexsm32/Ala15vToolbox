-- ANCHOR: Class declaration
TotalWar = {
    ClassName = "TotalWar",
    uid = nil,
    Alias = nil,
    LogHeader = "",
    Settings = nil,
    Chief = nil,
    Zones = {
        BorderZones = nil,
        ConflictZones = nil,
        AttackZones = nil,
        SpZones = nil,
        PortZones = nil
    }
}

-- ANCHOR: Constructor
function TotalWar:New(Settings)
    local Settings = Settings
    -- Inherit everthing from FSM class.
    local self = BASE:Inherit(self, FSM:New()) -- #Economy

    self.Settings = Settings
    self.Alias = Settings.Alias
    self.uid = #Ala15vToolbox.TotalWar.TotalWarDB + 1
    self.LogHeader = string.format("ALA15vToolBox TotalWar %s | ", self.Alias)
    self.Zones.BorderZones = SET_ZONE:New()
    self.Zones.ConflictZones = SET_ZONE:New()
    self.Zones.AttackZones = SET_ZONE:New()
    self.Zones.SpZones = SET_ZONE:New()
    self.Zones.PortZones = SET_ZONE:New()

    -- SECTION: FSM Transitions
    -- Start State.
    self:SetStartState("NotReadyYet")

    -- Add FSM transitions.
    --                 From State   -->         Event        -->     To State
    self:AddTransition("NotReadyYet", "Start", "Starting")      -- Start the TotalWar from scratch.

    self:AddTransition("NotReadyYet", "ScanBorderZones", "*")   -- Scan Border Zones.
    self:AddTransition("NotReadyYet", "ScanConflictZones", "*") -- Scan Conflict Zones.
    self:AddTransition("NotReadyYet", "ScanAttackZones", "*")   -- Scan Attack Zones.
    self:AddTransition("NotReadyYet", "ScanSpZones", "*")       -- Scan Spawn Zones.
    self:AddTransition("NotReadyYet", "ScanPortZones", "*")     -- Scan Port Zones.

    self:AddTransition("Starting", "AddCapZones", "*")          -- Add Cap Zones to the Chief.
    self:AddTransition("Starting", "AddAwacsZones", "*")        -- Add Awacs Zones to the Chief.
    self:AddTransition("Starting", "AddTankerZones", "*")       -- Add Tanker Zones to the Chief.
    self:AddTransition("Starting", "AddStrategicZones", "*")    -- Add Strategic Zones to the Chief.
    self:AddTransition("Starting", "AddBrigades", "*")          -- Add Brigades to the Chief.
    self:AddTransition("Starting", "AddAirwings", "*")          -- Add Airwings to the Chief.
    self:AddTransition("Starting", "AddFleets", "*")            -- Add Fleets to the Chief.

    self:AddTransition("Starting", "Ready", "Running")          -- Everything is ready.
    -- !SECTION

    table.insert(Ala15vToolbox.TotalWar.TotalWarDB, self) -- Inserting the new class into the main TotalWar DataBase
    return self
end

function TotalWar:onleaveNotReadyYet(From, Event, To)
    -- Checking all components are loaded
    local Main = Ala15vToolbox.TotalWar.Main
    local Methods = Ala15vToolbox.TotalWar.Methods
    local Zones = Ala15vToolbox.TotalWar.Zones
    local Brigades = Ala15vToolbox.TotalWar.Brigades
    local Airwings = Ala15vToolbox.TotalWar.Airwings
    local Fleets = Ala15vToolbox.TotalWar.Fleets
    local RandomReaction = Ala15vToolbox.TotalWar.RandomReaction

    -- TODO: Add logs
    return (Main and Methods and Zones and Brigades and Airwings and Fleets and RandomReaction) -- If FALSE it will stop the transition
end

function TotalWar:onbeforeStart(From, Event, To)
    local Settings = self.Settings

    -- Scan zones
    self:ScanBorderZones()
    self:ScanConflictZones()
    self:ScanAttackZones()
    self:ScanSpZones()
    self:ScanPortZones()

    local BorderZones = self.Zones.BorderZones
    local ConflictZones = self.Zones.ConflictZones
    local AttackZones = self.Zones.AttackZones

    -- Scan agent set
    local AgentSet = SET_GROUP:New()
    AgentSet:FilterPrefixes(Settings.AgentPrefixes)
    AgentSet:FilterStart()

    -- Generate a new chief
    local Coalition = Settings.TeamCoalition
    local Strategy = Settings.Strategy
    local Alias = Settings.Alias
    self.Chief = self:GenerateChief(Coalition, BorderZones, ConflictZones, AttackZones, Strategy, AgentSet, Alias)

    return true
end

function TotalWar:onafterStart(From, Event, To)
    self:AddBrigades()
    self:AddAirwings()
    self:AddFleets()
    self:AddStrategicZones()
    self:AddCapZones()
    self:AddAwacsZones()
    self:AddTankerZones()

    self:Ready()
end

function TotalWar:onafterReady(From, Event, To)
    self.Chief:Start()
end

Ala15vToolbox.TotalWar.Main = true
