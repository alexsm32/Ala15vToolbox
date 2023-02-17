--[[
Settings = {
    Alias = "Chief Rojo",
    MainPrefix = "RED",
    TeamCoalition = coalition.side.RED,
    Strategy = CHIEF.Strategy.DEFENSIVE,
    AgentPrefixes = {
        "EWR",
        "AWACS",
        "RECON"
    },
    Brigades =
    {
        {
            Prefix = "",
            Assets =
            {
                {
                    Template = "MBT",
                    Groups = 20,
                    Type = Group.Category.GROUND,
                    Capability = {
                        AUFTRAG.Type.GROUNDATTACK,
                        AUFTRAG.Type.PATROLZONE,
                        AUFTRAG.Type.ONGUARD
                    }
                },
                {
                    Template = "APC",
                    Groups = 15,
                    Type = Group.Category.GROUND,
                    Capability = {
                        AUFTRAG.Type.GROUNDATTACK,
                        AUFTRAG.Type.PATROLZONE,
                        AUFTRAG.Type.ONGUARD,
                        AUFTRAG.Type.OPSTRANSPORT
                    }
                },
                {
                    Template = "ATS",
                    Groups = 15,
                    Type = Group.Category.GROUND,
                    Capability = {
                        AUFTRAG.Type.GROUNDATTACK,
                        AUFTRAG.Type.PATROLZONE,
                        AUFTRAG.Type.ONGUARD
                    }
                },
                {
                    Template = "uh",
                    Groups = 15,
                    Type = Group.Category.HELICOPTER,
                    Attribute = GROUP.Attribute.AIR_TRANSPORTHELO,
                    Capability = {
                        AUFTRAG.Type.OPSTRANSPORT
                    }
                }
            }
        }
    },
    Airwings =
    {
        {
            Prefix = "",
            Assets =
            {
                {
                    Template = "uh",
                    Groups = 15,
                    Type = Group.Category.HELICOPTER,
                    Attribute = GROUP.Attribute.AIR_TRANSPORTHELO,
                    Capability = {
                        AUFTRAG.Type.OPSTRANSPORT
                    }
                }
            }
        }
    },
    Fleets =
    {
        {
            Prefix = "",
            Assets =
            {
                {
                    Template = "barco",
                    Groups = 15,
                    Type = Group.Category.SHIP,
                    Capability = {}
                }
            }
        }
    }
}
--]]
function GeneratePlatoon(TemplateGroupName, Ngroups, Nunits, Skill, PlatoonName, Capability)
    -- check exists
    env.info("ALA15vToolBox GeneratePlatoon function: Checking if the asset, " ..
    TemplateGroupName .. ", exists in the mission")
    if Group.getByName(TemplateGroupName) then
        -- check is ground unit
        env.info("ALA15vToolBox GeneratePlatoon function: Checking the template category is " .. Group.Category.GROUND)
        if Group.getByName(TemplateGroupName):getCategory() == Group.Category.GROUND then -- I should use moose first
            local Platoon = PLATOON:New(TemplateGroupName, Ngroups, PlatoonName)
            if Nunits then
                Platoon:SetGrouping(Nunits)
            end
            if Skill then
                Platoon:SetSkill(Skill)
            end
            for task, ability in pairs(Capability) do
                Platoon:AddMissionCapability(task, ability)
            end

            return Platoon
        else
            env.error("ALA15vToolBox GeneratePlatoon function: Template category: " ..
            Group.getByName(TemplateGroupName):getCategory() .. " Expected: " .. Group.Category.GROUND)

            return false
        end
    else
        env.error("ALA15vToolBox GeneratePlatoon function: The asset, " ..
        TemplateGroupName .. ", does not exist in the mission")

        return false
    end
end

function GenerateSquadron(TemplateGroupName, Ngroups, Nunits, Range, Skill, SquadronName, Capability, Scramble)
    -- check exists
    env.info("ALA15vToolBox GenerateSquadron function: Checking if the asset, " ..
    TemplateGroupName .. ", exists in the mission")
    if Group.getByName(TemplateGroupName) then
        -- check is ground unit
        env.info("ALA15vToolBox GenerateSquadron function: Checking the template category is " ..
        Group.Category.AIRPLANE .. "/" .. Group.Category.HELICOPTER)
        if (Group.getByName(TemplateGroupName):getCategory() == Group.Category.AIRPLANE) or
            (Group.getByName(TemplateGroupName):getCategory() == Group.Category.HELICOPTER) then -- I should use moose first
            local Squadron = SQUADRON:New(TemplateGroupName, Ngroups, SquadronName)
            if Nunits then
                Squadron:SetGrouping(Nunits)
            end
            if Range then
                Squadron:SetMissionRange(Range)
            end
            if Skill then
                Squadron:SetSkill(Skill)
            end
            Squadron:AddMissionCapability(Capability, 60)
            if Scramble then
                Squadron:AddMissionCapability({ AUFTRAG.Type.ALERT5 })
            end

            return Squadron
        else
            env.error("ALA15vToolBox GenerateSquadron function: Template category: " ..
            Group.getByName(TemplateGroupName):getCategory() ..
            " Expected: " .. Group.Category.AIRPLANE .. "/" .. Group.Category.HELICOPTER)

            return false
        end
    else
        env.error("ALA15vToolBox GenerateSquadron function: The asset, " ..
        TemplateGroupName .. ", does not exist in the mission")

        return false
    end
end

function GenerateFlotilla(TemplateGroupName, Ngroups, Nunits, Skill, FlotillaName, Capability)
    -- check exists
    env.info("ALA15vToolBox GenerateFlotilla function: Checking if the asset, " ..
    TemplateGroupName .. ", exists in the mission")
    if Group.getByName(TemplateGroupName) then
        -- check is ground unit
        env.info("ALA15vToolBox GenerateFlotilla function: Checking the template category is " .. Group.Category.SHIP)
        if Group.getByName(TemplateGroupName):getCategory() == Group.Category.SHIP then -- I should use moose first
            local Flotilla = FLOTILLA:New(TemplateGroupName, Ngroups, FlotillaName)
            if Nunits then
                Flotilla:SetGrouping(Nunits)
            end
            if Skill then
                Flotilla:SetSkill(Skill)
            end
            for task, ability in pairs(Capability) do
                Flotilla:AddMissionCapability(task, ability)
            end

            return Flotilla
        else
            env.error("ALA15vToolBox GenerateFlotilla function: Template category: " ..
            Group.getByName(TemplateGroupName):getCategory() ..
            " Expected: " .. Group.Category.SHIP)

            return false
        end
    else
        env.error("ALA15vToolBox GenerateFlotilla function: The asset, " ..
        TemplateGroupName .. ", does not exist in the mission")

        return false
    end
end

function GenerateBrigade(Brigade, Alias, SpawnZone, BrigadeCoalition) -- alias not needed?
    env.info("ALA15vToolBox GenerateBrigade function: Checking if the warehouse, " ..
    Brigade .. ", exists in the mission")
    if StaticObject.getByName(Brigade) then
        env.info("ALA15vToolBox GenerateBrigade function: Checking if the warehouse, " .. Brigade .. ", is alive")
        if STATIC:FindByName(Brigade):IsAlive() then
            env.info("ALA15vToolBox GenerateBrigade function: Checking if the warehouse, " ..
            Brigade .. ", belongs to the coalition " .. BrigadeCoalition)
            if STATIC:FindByName(Brigade):GetCoalition() == BrigadeCoalition then
                local Brigade = BRIGADE:New(Brigade, Alias) --Ops.Brigade#BRIGADE
                if SpawnZone then
                    Brigade:SetSpawnZone(ZONE:New(SpawnZone))
                end

                return Brigade
            else
                env.warning("ALA15vToolBox GenerateBrigade function: The warehouse, " ..
                Brigade .. ", does not belong to the coalition " .. BrigadeCoalition)

                return false
            end
        else
            env.warning("ALA15vToolBox GenerateBrigade function: The warehouse, " ..
            Brigade .. ", is not alive")

            return false
        end
    else
        env.error("ALA15vToolBox GenerateBrigade function: The warehouse, " ..
        Brigade .. ", does not exist in the mission")

        return false
    end
end

function GenerateAirwing(Airwing, Alias, AirwingCoalition) -- alias not needed?
    env.info("ALA15vToolBox GenerateAirwing function: Checking if the warehouse, " ..
    Airwing .. ", exists in the mission")
    if StaticObject.getByName(Airwing) then
        env.info("ALA15vToolBox GenerateAirwing function: Checking if the warehouse, " .. Airwing .. ", is alive")
        if STATIC:FindByName(Airwing):IsAlive() then
            env.info("ALA15vToolBox GenerateAirwing function: Checking if the warehouse, " ..
            Airwing .. ", belongs to the coalition " .. AirwingCoalition)
            if STATIC:FindByName(Airwing):GetCoalition() == AirwingCoalition then
                local Airwing = AIRWING:New(Airwing, Alias) --Ops.Airwing#AIRWING

                return Airwing
            else
                env.warning("ALA15vToolBox GenerateAirwing function: The warehouse, " ..
                Airwing .. ", does not belong to the coalition " .. AirwingCoalition)

                return false
            end
        else
            env.warning("ALA15vToolBox GenerateAirwing function: The warehouse, " .. Airwing .. ", is not alive")

            return false
        end
    else
        env.error("ALA15vToolBox GenerateAirwing function: The warehouse, " ..
        Airwing .. ", does not exist in the mission")

        return false
    end
end

function GenerateFleet(Fleet, Alias, PortZone, FleetCoalition, Pathfinding) -- alias not needed?
    env.info("ALA15vToolBox GenerateFleet function: Checking if the warehouse, " ..
    Fleet .. ", exists in the mission")
    if StaticObject.getByName(Fleet) then
        env.info("ALA15vToolBox GenerateFleet function: Checking if the warehouse, " .. Fleet .. ", is alive")
        if STATIC:FindByName(Fleet):IsAlive() then
            env.info("ALA15vToolBox GenerateFleet function: Checking if the warehouse, " ..
            Fleet .. ", belongs to the coalition " .. FleetCoalition)
            if STATIC:FindByName(Fleet):GetCoalition() == FleetCoalition then
                local Fleet = FLEET:New(Fleet, Alias) --Ops.Fleet#FLEET
                if PortZone then
                    Fleet:SetPortZone(ZONE:New(PortZone))
                end
                if Pathfinding then
                    Fleet:SetPathfinding(Pathfinding)
                end

                return Fleet
            else
                env.warning("ALA15vToolBox GenerateFleet function: The warehouse, " ..
                Fleet .. ", does not belong to the coalition " .. FleetCoalition)

                return false
            end
        else
            env.warning("ALA15vToolBox GenerateFleet function: The warehouse, " .. Fleet .. ", is not alive")

            return false
        end
    else
        env.error("ALA15vToolBox GenerateFleet function: The warehouse, " ..
        Fleet .. ", does not exist in the mission")

        return false
    end
end

function GenerateChief(ChiefCoalition, BorderZones, ConflictZones, AttackZones, Strategy, AgentSet, Alias)
    local Chief = CHIEF:New(ChiefCoalition, AgentSet, Alias)
    Chief:SetBorderZones(BorderZones)
    Chief:SetConflictZones(ConflictZones)
    Chief:SetAttackZones(AttackZones)
    Chief:SetStrategy(Strategy)

    Chief:AllowGroundTransport() -- NOTE: CHIEF:AllowGroundTransport() is deprecated and will be removed in the future!

    --Chief:__Start(5)
    return Chief
end

function GenerateTotalWar(Settings) -- TODO: Add conditions
    local MainPrefix = Settings.MainPrefix

    -- DONE: CAP Zones, AWACS Zones, Refuelling Zones
    local DBcapZone
    DBcapZone = SET_ZONE:New()
    DBcapZone:FilterPrefixes(MainPrefix .. " capzone")
    DBcapZone:FilterOnce()

    local DBawacsZone
    DBawacsZone = SET_ZONE:New()
    DBawacsZone:FilterPrefixes(MainPrefix .. " awacszone")
    DBawacsZone:FilterOnce()

    local DBtankerZone
    DBtankerZone = SET_ZONE:New()
    DBtankerZone:FilterPrefixes(MainPrefix .. " tankerzone")
    DBtankerZone:FilterOnce()

    -- TODO: supply refuelling zone???????????

    local DBspZone
    DBspZone = SET_ZONE:New()
    DBspZone:FilterPrefixes("spzone")
    DBspZone:FilterOnce()

    local DBportZone
    DBportZone = SET_ZONE:New()
    DBportZone:FilterPrefixes("portzone")
    DBportZone:FilterOnce()

    local DBstrategicZone
    DBstrategicZone = SET_ZONE:New()
    DBstrategicZone:FilterPrefixes("StrategicZone")
    DBstrategicZone:FilterOnce()

    local DBcheckPoint
    DBcheckPoint = SET_ZONE:New()
    DBcheckPoint:FilterPrefixes("CheckPoint")
    DBcheckPoint:FilterOnce()

    local DBsamSites
    DBsamSites = SET_ZONE:New()
    DBsamSites:FilterPrefixes("SamSite")
    DBsamSites:FilterOnce()

    local DBborderStrategicZones = SET_ZONE:New()
    local DBconflictStrategicZones = SET_ZONE:New()
    local DBattackStrategicZones = SET_ZONE:New()

    local DBborderCheckPoints = SET_ZONE:New()
    local DBconflictCheckPoints = SET_ZONE:New()

    local DBborderSamSites = SET_ZONE:New() --TODO
    local DBconflictSamSites = SET_ZONE:New()
    local DBattackSamSites = SET_ZONE:New()


    -- SECTION: ChiefCode
    -- SECTION: BorderZones
    local BorderZones = SET_ZONE:New()
    BorderZones:FilterPrefixes(MainPrefix .. " BorderZone")
    BorderZones:FilterOnce()

    local PolygonBorderZones = SET_GROUP:New()
    PolygonBorderZones:FilterPrefixes(MainPrefix .. " BorderZone")
    PolygonBorderZones:FilterOnce()

    for _, zone in pairs(PolygonBorderZones:GetSet()) do
        local zone = ZONE_POLYGON:New(zone:GetName(), zone)
        BorderZones:AddZone(zone)
    end

    -- StrategicZones
    for _, zone in pairs(BorderZones:GetSet()) do
        local border = zone
        for _, zone in pairs(DBstrategicZone:GetSet()) do
            local strategic = zone
            if border:IsCoordinateInZone(strategic:GetCoordinate()) then
                DBborderStrategicZones:AddZone(strategic)
            end
        end
    end

    -- CheckPoints
    for _, zone in pairs(BorderZones:GetSet()) do
        local border = zone
        for _, zone in pairs(DBcheckPoint:GetSet()) do
            local strategic = zone
            if border:IsCoordinateInZone(strategic:GetCoordinate()) then
                DBborderCheckPoints:AddZone(strategic)
            end
        end
    end

    -- SamSites
    for _, zone in pairs(BorderZones:GetSet()) do
        local border = zone
        for _, zone in pairs(DBsamSites:GetSet()) do
            local samSite = zone
            if border:IsCoordinateInZone(samSite:GetCoordinate()) then
                DBborderSamSites:AddZone(samSite)
            end
        end
    end

    -- !SECTION
    -- SECTION: ConflictZones
    local ConflictZones = SET_ZONE:New()
    ConflictZones:FilterPrefixes(MainPrefix .. " ConflictZones")
    ConflictZones:FilterOnce()

    local PolygonConflictZones = SET_GROUP:New()
    PolygonConflictZones:FilterPrefixes(MainPrefix .. " ConflictZones")
    PolygonConflictZones:FilterOnce()

    for _, zone in pairs(PolygonConflictZones:GetSet()) do
        local zone = ZONE_POLYGON:New(zone:GetName(), zone)
        ConflictZones:AddZone(zone)
    end

    -- StrategicZones
    for _, zone in pairs(ConflictZones:GetSet()) do
        local border = zone
        for _, zone in pairs(DBstrategicZone:GetSet()) do
            local strategic = zone
            if border:IsCoordinateInZone(strategic:GetCoordinate()) then
                DBconflictStrategicZones:AddZone(strategic)
            end
        end
    end

    -- CheckPoints
    for _, zone in pairs(ConflictZones:GetSet()) do
        local border = zone
        for _, zone in pairs(DBcheckPoint:GetSet()) do
            local strategic = zone
            if border:IsCoordinateInZone(strategic:GetCoordinate()) then
                DBconflictCheckPoints:AddZone(strategic)
            end
        end
    end

    -- SamSites
    for _, zone in pairs(ConflictZones:GetSet()) do
        local border = zone
        for _, zone in pairs(DBsamSites:GetSet()) do
            local samSite = zone
            if border:IsCoordinateInZone(samSite:GetCoordinate()) then
                DBconflictSamSites:AddZone(samSite)
            end
        end
    end

    -- !SECTION
    -- SECTION: AttackZones
    local AttackZones = SET_ZONE:New()
    AttackZones:FilterPrefixes(MainPrefix .. " AttackZones")
    AttackZones:FilterOnce()

    local PolygonAttackZones = SET_GROUP:New()
    PolygonAttackZones:FilterPrefixes(MainPrefix .. " AttackZones")
    PolygonAttackZones:FilterOnce()

    for _, zone in pairs(PolygonAttackZones:GetSet()) do
        local zone = ZONE_POLYGON:New(zone:GetName(), zone)
        AttackZones:AddZone(zone)
    end

    -- StrategicZones
    for _, zone in pairs(AttackZones:GetSet()) do
        local border = zone
        for _, zone in pairs(DBstrategicZone:GetSet()) do
            local strategic = zone
            if border:IsCoordinateInZone(strategic:GetCoordinate()) then
                DBattackStrategicZones:AddZone(strategic)
            end
        end
    end

    -- SamSites
    for _, zone in pairs(AttackZones:GetSet()) do
        local border = zone
        for _, zone in pairs(DBsamSites:GetSet()) do
            local samSite = zone
            if border:IsCoordinateInZone(samSite:GetCoordinate()) then
                DBattackSamSites:AddZone(samSite)
            end
        end
    end

    -- !SECTION
    -- SECTION: AgentSet
    local AgentSet = SET_GROUP:New()
    AgentSet:FilterPrefixes(Settings.AgentPrefixes)
    AgentSet:FilterStart()
    -- !SECTION
    local ChiefCoalition = Settings.TeamCoalition
    local Strategy = Settings.Strategy
    local Alias = Settings.Alias
    local Chief = GenerateChief(ChiefCoalition, BorderZones, ConflictZones, AttackZones, Strategy, AgentSet, Alias)

    --[[
    -- SECTION: Custom Response
    -- NOTE: Testing
    --Chief:SetResponseOnTarget(NassetsMin, NassetsMax, ThreatLevel, TargetCategory, MissionType, Nunits, Defcon, Strategy)

    --CHIEF.Strategy.DEFENSIVE
    Chief:SetResponseOnTarget(0, 1, 0, TARGET.Category.GROUND, nil, nil, CHIEF.DEFCON.RED, CHIEF.Strategy.DEFENSIVE)
    Chief:SetResponseOnTarget(0, 2, 3, TARGET.Category.GROUND, nil, nil, CHIEF.DEFCON.RED, CHIEF.Strategy.DEFENSIVE)
    Chief:SetResponseOnTarget(0, 2, 5, TARGET.Category.GROUND, AUFTRAG.Type.BAI, nil, CHIEF.DEFCON.RED, CHIEF.Strategy.DEFENSIVE)
    Chief:SetResponseOnTarget(1, 2, 8, TARGET.Category.GROUND, AUFTRAG.Type.SEAD, nil, CHIEF.DEFCON.RED, CHIEF.Strategy.DEFENSIVE)

    --CHIEF.Strategy.OFFENSIVE
    Chief:SetResponseOnTarget(1, 1, 0, TARGET.Category.GROUND, nil, nil, CHIEF.DEFCON.RED, CHIEF.Strategy.OFFENSIVE)
    Chief:SetResponseOnTarget(1, 2, 3, TARGET.Category.GROUND, nil, nil, CHIEF.DEFCON.RED, CHIEF.Strategy.OFFENSIVE)
    Chief:SetResponseOnTarget(1, 2, 5, TARGET.Category.GROUND, AUFTRAG.Type.BAI, nil, CHIEF.DEFCON.RED, CHIEF.Strategy.OFFENSIVE)
    Chief:SetResponseOnTarget(1, 2, 8, TARGET.Category.GROUND, AUFTRAG.Type.SEAD, nil, CHIEF.DEFCON.RED, CHIEF.Strategy.OFFENSIVE)

    Chief:SetResponseOnTarget(0, 1, 0, TARGET.Category.GROUND, nil, nil, CHIEF.DEFCON.YELLOW, CHIEF.Strategy.OFFENSIVE)
    Chief:SetResponseOnTarget(0, 2, 3, TARGET.Category.GROUND, AUFTRAG.Type.BAI, nil, CHIEF.DEFCON.YELLOW, CHIEF.Strategy.OFFENSIVE)
    Chief:SetResponseOnTarget(1, 2, 5, TARGET.Category.GROUND, AUFTRAG.Type.BAI, nil, CHIEF.DEFCON.YELLOW, CHIEF.Strategy.OFFENSIVE)
    Chief:SetResponseOnTarget(1, 2, 8, TARGET.Category.GROUND, AUFTRAG.Type.SEAD, nil, CHIEF.DEFCON.YELLOW, CHIEF.Strategy.OFFENSIVE)

    --CHIEF.Strategy.AGGRESSIVE
    Chief:SetResponseOnTarget(1, 2, 0, TARGET.Category.GROUND, nil, nil, CHIEF.DEFCON.RED, CHIEF.Strategy.AGGRESSIVE)
    Chief:SetResponseOnTarget(1, 3, 3, TARGET.Category.GROUND, nil, nil, CHIEF.DEFCON.RED, CHIEF.Strategy.AGGRESSIVE)
    Chief:SetResponseOnTarget(1, 3, 5, TARGET.Category.GROUND, AUFTRAG.Type.BAI, nil, CHIEF.DEFCON.RED, CHIEF.Strategy.AGGRESSIVE)
    Chief:SetResponseOnTarget(1, 3, 8, TARGET.Category.GROUND, AUFTRAG.Type.SEAD, nil, CHIEF.DEFCON.RED, CHIEF.Strategy.AGGRESSIVE)

    Chief:SetResponseOnTarget(1, 1, 0, TARGET.Category.GROUND, AUFTRAG.Type.BAI, nil, CHIEF.DEFCON.YELLOW, CHIEF.Strategy.AGGRESSIVE)
    Chief:SetResponseOnTarget(1, 2, 3, TARGET.Category.GROUND, AUFTRAG.Type.BAI, nil, CHIEF.DEFCON.YELLOW, CHIEF.Strategy.AGGRESSIVE)
    Chief:SetResponseOnTarget(1, 3, 5, TARGET.Category.GROUND, AUFTRAG.Type.BAI, nil, CHIEF.DEFCON.YELLOW, CHIEF.Strategy.AGGRESSIVE)
    Chief:SetResponseOnTarget(1, 2, 8, TARGET.Category.GROUND, AUFTRAG.Type.SEAD, nil, CHIEF.DEFCON.YELLOW, CHIEF.Strategy.AGGRESSIVE)

    Chief:SetResponseOnTarget(0, 1, 0, TARGET.Category.GROUND, AUFTRAG.Type.BAI, nil, CHIEF.DEFCON.GREEN, CHIEF.Strategy.AGGRESSIVE)
    Chief:SetResponseOnTarget(0, 1, 3, TARGET.Category.GROUND, AUFTRAG.Type.BAI, nil, CHIEF.DEFCON.GREEN, CHIEF.Strategy.AGGRESSIVE)
    Chief:SetResponseOnTarget(0, 2, 5, TARGET.Category.GROUND, AUFTRAG.Type.BAI, nil, CHIEF.DEFCON.GREEN, CHIEF.Strategy.AGGRESSIVE)
    Chief:SetResponseOnTarget(0, 2, 8, TARGET.Category.GROUND, AUFTRAG.Type.SEAD, nil, CHIEF.DEFCON.GREEN, CHIEF.Strategy.AGGRESSIVE)

    -- !SECTION
    ]]
    --
    -- !SECTION

    -- SECTION: BrigadeCode
    for _, Brigade in pairs(Settings.Brigades) do
        --local brigadePrefix = MainPrefix .. " " .. Brigade.Prefix
        local brigadePrefix = Brigade.Prefix
        local brigadeAssets = Brigade.Assets

        local statics = SET_STATIC:New()
        --DBObject:FilterCoalitions(coalition) -- REVIEW: Should I add this?
        statics:FilterPrefixes(brigadePrefix)
        statics:FilterZones(BorderZones)
        statics:FilterOnce()

        for _, static in pairs(statics:GetSet()) do
            local BrigadeName = static:GetName()
            local Alias = CreateName(Brigade.Prefix, static:GetCoordinate())

            local SpawnZone
            local SpawnDist = 1000
            for _, zone in pairs(DBspZone:GetSet()) do
                local dist = UTILS.VecDist2D(static:GetVec2(), zone:GetVec2())
                if dist < SpawnDist then
                    SpawnDist = dist
                    SpawnZone = zone:GetName()
                end
            end

            local Brigade = GenerateBrigade(BrigadeName, Alias, SpawnZone, ChiefCoalition)
            if Brigade then
                Brigade:SetMarker(true) --REVIEW

                for _, asset in pairs(brigadeAssets) do
                    local template = MainPrefix .. " " .. asset.Template
                    local groups
                    if Ala15vToolBoxEconomyLoaded and asset.Economy then
                        groups = GetWarehouseAssetProduction(Brigade:GetVec2(), asset.Economy.Factory,
                            asset.Economy.Range, asset.Economy.Rate, ChiefCoalition)
                    else
                        groups = asset.Groups
                    end
                    local units = asset.Units
                    local skill --REVIEW
                    --local type = asset.Type
                    local capabilities = asset.Capability

                    if groups > 0 then
                        local Platoon = GeneratePlatoon(template, groups, units, skill, Alias .. template, capabilities)
                        if Platoon then
                            Brigade:AddPlatoon(Platoon)
                        end
                    end
                end

                Chief:AddBrigade(Brigade)
                --[[
                -- SECTION: OnAfterAssetDead event
                function Brigade:OnAfterAssetDead(From, Event, To, asset, request)
                    local asset = asset --Functional.Warehouse#WAREHOUSE.Assetitem
                    local request = request --Functional.Warehouse#WAREHOUSE.Pendingitem

                    -- Get assignment.
                    local assignment = Brigade:GetAssignment(request)

                    -- Get nearest warehouse with the asset type
                    local nearest, dist = Brigade:FindNeighborWarehouse(3, WAREHOUSE.Descriptor.ATTRIBUTE,
                        asset.attribute,
                        nil, nil, 3000)

                    -- Resupply from the nearest warehouse
                    if nearest then
                        if asset.attribute == WAREHOUSE.Attribute.GROUND_INFANTRY then
                            nearest:AddRequest(Brigade, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1,
                                WAREHOUSE.TransportType.APC, nil, nil, "Resupply")
                        else
                            nearest:AddRequest(Brigade, WAREHOUSE.Descriptor.ATTRIBUTE, asset.attribute, 1, nil,
                                nil,
                                nil, "Resupply")
                        end
                    end
                end
                -- !SECTION
                ]]
                --
            end
        end
    end
    -- !SECTION

    -- SECTION: AirwingCode
    for _, Airwing in pairs(Settings.Airwings) do
        --local airwingPrefix = MainPrefix .. " " .. Airwing.Prefix
        local airwingPrefix = Airwing.Prefix
        local airwingAssets = Airwing.Assets

        local statics = SET_STATIC:New()
        --DBObject:FilterCoalitions(coalition) -- REVIEW: Should I add this?
        statics:FilterPrefixes(airwingPrefix)
        statics:FilterZones(BorderZones)
        statics:FilterOnce()

        for _, static in pairs(statics:GetSet()) do
            local AirwingName = static:GetName()
            local Alias = CreateName(Airwing.Prefix, static:GetCoordinate())

            local Airwing = GenerateAirwing(AirwingName, Alias, ChiefCoalition)
            if Airwing then
                Airwing:SetMarker(true) --REVIEW

                for _, asset in pairs(airwingAssets) do
                    local template = MainPrefix .. " " .. asset.Template
                    local groups
                    if Ala15vToolBoxEconomyLoaded and asset.Economy then
                        groups = GetWarehouseAssetProduction(Airwing:GetVec2(), asset.Economy.Factory,
                            asset.Economy.Range, asset.Economy.Rate, ChiefCoalition)
                    else
                        groups = asset.Groups
                    end
                    local units = asset.Units
                    local range = asset.Range
                    local skill --REVIEW
                    local scramble = asset.Scramble
                    local payloads = asset.Payloads
                    -- TODO: Attribute
                    --local type = asset.Type
                    local capabilities = asset.Capability

                    if groups > 0 then
                        local Squadron = GenerateSquadron(template, groups, units, range, skill, Alias .. template,
                            capabilities, scramble)
                        if Squadron then
                            Airwing:AddSquadron(Squadron)

                            for payload, capabilities in pairs(payloads) do
                                local payload = template .. " " .. payload
                                env.info("ALA15vToolBox GenerateTotalWar function: Checking if the asset, " ..
                                payload .. ", exists in the mission")
                                if Group.getByName(payload) then
                                    Airwing:NewPayload(payload, capabilities.Availabe, capabilities.Task,
                                        capabilities.Ability)
                                else
                                    env.error("ALA15vToolBox GenerateTotalWar function: The asset, " ..
                                    payload .. ", does not exist in the mission")
                                end
                            end
                        end
                    end
                end

                Chief:AddAirwing(Airwing)
            end
        end
    end
    -- !SECTION

    -- SECTION: FleetCode
    for _, Fleet in pairs(Settings.Fleets) do
        --local fleetPrefix = MainPrefix .. " " .. Fleet.Prefix
        local fleetPrefix = Fleet.Prefix
        local fleetAssets = Fleet.Assets

        local statics = SET_STATIC:New()
        --DBObject:FilterCoalitions(coalition) -- REVIEW: Should I add this?
        statics:FilterPrefixes(fleetPrefix)
        statics:FilterZones(BorderZones)
        statics:FilterOnce()

        for _, static in pairs(statics:GetSet()) do
            local FleetName = static:GetName()
            local Alias = CreateName(Fleet.Prefix, static:GetCoordinate())

            local PortZone
            local SpawnDist = 10000
            for _, zone in pairs(DBportZone:GetSet()) do
                local dist = UTILS.VecDist2D(static:GetVec2(), zone:GetVec2())
                if dist < SpawnDist then
                    SpawnDist = dist
                    PortZone = zone:GetName()
                end
            end

            local Fleet = GenerateFleet(FleetName, Alias, PortZone, ChiefCoalition, true)
            if Fleet then
                Fleet:SetMarker(true) --REVIEW

                for _, asset in pairs(fleetAssets) do
                    local template = MainPrefix .. " " .. asset.Template
                    local groups = asset.Groups
                    local units = asset.Units
                    local skill --REVIEW
                    --local type = asset.Type
                    local capabilities = asset.Capability
                    local weapons = asset.Weapons

                    local Flotilla = GenerateFlotilla(template, groups, units, skill, Alias .. template, capabilities)
                    if Flotilla then
                        for _, weapon in pairs(weapons) do
                            Flotilla:AddWeaponRange(weapon.Number, weapon.Range, weapon.Type)
                        end

                        Fleet:AddFlotilla(Flotilla)
                    end
                end

                Chief:AddFleet(Fleet)
            end
        end
    end
    -- !SECTION

    -- SECTION: Customized Reaction
    -- ANCHOR: In border zone
    for _, zone in pairs(DBborderStrategicZones:GetSet()) do
        local zoneName = zone:GetName()
        local splitName = {}
        for str in string.gmatch(zoneName, "%S+") do
            table.insert(splitName, str)
        end
        local priotity = tonumber(splitName[2])
        local importance = tonumber(splitName[3])
        local StrategicZone = OPSZONE:New(zoneName)

        --StrategicZone:SetDrawZone(false)  --REVIEW
        --StrategicZone:SetMarkZone(false)  --REVIEW

        local ResourceListEmpty, ResourceEmptyInf = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 1, 2,
            GROUP.Attribute.GROUND_INFANTRY)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.PATROLZONE, 1, 2,
            GROUP.Attribute.GROUND_IFV)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 2,
            GROUP.Attribute.GROUND_TRUCK)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 2,
            GROUP.Attribute.GROUND_AAA)

        -- Resource Infantry Bravo is transported by up to 2 APCs.
        Chief:AddTransportToResource(ResourceEmptyInf, 1, 2, { GROUP.Attribute.GROUND_TRUCK })


        local ResourceListOccupied, ResourceOccupiedInf = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 1, 1,
            GROUP.Attribute.GROUND_INFANTRY)
        -- We also add ARTY missions with at least one and at most two assets. We additionally require these to be MLRS groups (and not howitzers).
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.ARTY, 0, 2)
        -- Add at least one RECON mission that uses UAV type assets.
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.RECON, 0, 1, GROUP.Attribute.AIR_UAV)
        --REVIEW
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_TANK)
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.PATROLZONE, 1, 2,
            GROUP.Attribute.GROUND_IFV)
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.CASENHANCED, 0, 1)

        -- Resource Infantry Bravo is transported by up to 2 APCs.
        Chief:AddTransportToResource(ResourceOccupiedInf, 1, 2, { GROUP.Attribute.GROUND_TRUCK })

        Chief:AddStrategicZone(StrategicZone, priotity, importance, ResourceListOccupied, ResourceListEmpty)
    end

    for _, zone in pairs(DBborderCheckPoints:GetSet()) do
        local zoneName = zone:GetName()
        local splitName = {}
        for str in string.gmatch(zoneName, "%S+") do
            table.insert(splitName, str)
        end
        local priotity = tonumber(splitName[2])
        local importance = tonumber(splitName[3])
        local StrategicZone = OPSZONE:New(zoneName)

        --StrategicZone:SetDrawZone(false)  --REVIEW
        --StrategicZone:SetMarkZone(false)  --REVIEW

        local ResourceListEmpty, ResourceEmptyInf = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 1, 1,
            GROUP.Attribute.GROUND_INFANTRY)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 1, 1,
            GROUP.Attribute.GROUND_APC)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_TRUCK)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_AAA)

        -- Resource Infantry Bravo is transported by up to 2 APCs.
        Chief:AddTransportToResource(ResourceEmptyInf, 1, 1, { GROUP.Attribute.GROUND_TRUCK })


        local ResourceListOccupied, ResourceOccupiedInf = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 1, 1,
            GROUP.Attribute.GROUND_INFANTRY)
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.ONGUARD, 1, 2,
            GROUP.Attribute.GROUND_APC)

        -- Resource Infantry Bravo is transported by up to 2 APCs.
        Chief:AddTransportToResource(ResourceOccupiedInf, 1, 1, { GROUP.Attribute.GROUND_TRUCK })

        Chief:AddStrategicZone(StrategicZone, priotity, importance, ResourceListOccupied, ResourceListEmpty)
    end

    for _, zone in pairs(DBborderSamSites:GetSet()) do
        local zoneName = zone:GetName()
        local splitName = {}
        for str in string.gmatch(zoneName, "%S+") do
            table.insert(splitName, str)
        end
        local priotity = tonumber(splitName[2])
        local importance = tonumber(splitName[3])
        local StrategicZone = OPSZONE:New(zoneName)

        --StrategicZone:SetDrawZone(false)  --REVIEW
        --StrategicZone:SetMarkZone(false)  --REVIEW

        local ResourceListEmpty, ResourceEmpty = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 1, 2,
            GROUP.Attribute.GROUND_IFV)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 2,
            GROUP.Attribute.GROUND_TRUCK)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 1, 2,
            GROUP.Attribute.GROUND_AAA)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 1, 2,
            GROUP.Attribute.GROUND_SAM)


        local ResourceListOccupied, ResourceOccupied = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 1, 1,
            GROUP.Attribute.GROUND_IFV)
        -- We also add ARTY missions with at least one and at most two assets. We additionally require these to be MLRS groups (and not howitzers).
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.ARTY, 0, 2)
        -- Add at least one RECON mission that uses UAV type assets.
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.RECON, 0, 1, GROUP.Attribute.AIR_UAV)
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.CASENHANCED, 0, 1)



        Chief:AddStrategicZone(StrategicZone, priotity, importance, ResourceListOccupied, ResourceListEmpty)
    end

    -- ANCHOR: In conflict zone
    for _, zone in pairs(DBconflictStrategicZones:GetSet()) do
        local zoneName = zone:GetName()
        local splitName = {}
        for str in string.gmatch(zoneName, "%S+") do
            table.insert(splitName, str)
        end
        local priotity = tonumber(splitName[2]) - 30
        local importance = tonumber(splitName[3]) + 3
        local StrategicZone = OPSZONE:New(zoneName)

        --StrategicZone:SetDrawZone(false)  --REVIEW
        --StrategicZone:SetMarkZone(false)  --REVIEW

        local ResourceListEmpty, ResourceEmptyInf = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 1, 2,
            GROUP.Attribute.GROUND_INFANTRY)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.PATROLZONE, 1, 2,
            GROUP.Attribute.GROUND_IFV)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_TANK)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_TRUCK)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 2,
            GROUP.Attribute.GROUND_AAA)

        -- Resource Infantry Bravo is transported by up to 2 APCs.
        Chief:AddTransportToResource(ResourceEmptyInf, 1, 2, { GROUP.Attribute.GROUND_APC })


        local ResourceListOccupied, ResourceOccupiedCAS = Chief:CreateResource(AUFTRAG.Type.CASENHANCED, 1, 1)
        -- We also add ARTY missions with at least one and at most two assets. We additionally require these to be MLRS groups (and not howitzers).
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.ARTY, 0, 2)
        -- Add at least one RECON mission that uses UAV type assets.
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.RECON, 0, 1, GROUP.Attribute.AIR_UAV)
        -- Add at least one but at most two BOMBCARPET missions.
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.BOMBCARPET, 0, 2)
        --REVIEW
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.ONGUARD, 0, 2,
            GROUP.Attribute.GROUND_TANK)
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.PATROLZONE, 1, 2,
            GROUP.Attribute.GROUND_IFV)


        Chief:AddStrategicZone(StrategicZone, priotity, importance, ResourceListOccupied, ResourceListEmpty)
    end

    for _, zone in pairs(DBconflictCheckPoints:GetSet()) do
        local zoneName = zone:GetName()
        local splitName = {}
        for str in string.gmatch(zoneName, "%S+") do
            table.insert(splitName, str)
        end
        local priotity = tonumber(splitName[2]) - 30
        local importance = tonumber(splitName[3]) + 3
        local StrategicZone = OPSZONE:New(zoneName)

        --StrategicZone:SetDrawZone(false)  --REVIEW
        --StrategicZone:SetMarkZone(false)  --REVIEW

        local ResourceListEmpty, ResourceEmptyInf = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 1, 1,
            GROUP.Attribute.GROUND_INFANTRY)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 1, 1,
            GROUP.Attribute.GROUND_APC)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_TRUCK)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_AAA)

        -- Resource Infantry Bravo is transported by up to 2 APCs.
        Chief:AddTransportToResource(ResourceEmptyInf, 1, 1, { GROUP.Attribute.GROUND_APC })


        local ResourceListOccupied, ResourceOccupiedInf = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 1, 1,
            GROUP.Attribute.GROUND_INFANTRY)
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.ONGUARD, 1, 2,
            GROUP.Attribute.GROUND_APC)

        -- Resource Infantry Bravo is transported by up to 2 APCs.
        Chief:AddTransportToResource(ResourceOccupiedInf, 1, 1, { GROUP.Attribute.GROUND_APC })

        Chief:AddStrategicZone(StrategicZone, priotity, importance, ResourceListOccupied, ResourceListEmpty)
    end

    for _, zone in pairs(DBconflictSamSites:GetSet()) do
        local zoneName = zone:GetName()
        local splitName = {}
        for str in string.gmatch(zoneName, "%S+") do
            table.insert(splitName, str)
        end
        local priotity = tonumber(splitName[2]) - 30
        local importance = tonumber(splitName[3]) + 3
        local StrategicZone = OPSZONE:New(zoneName)

        --StrategicZone:SetDrawZone(false)  --REVIEW
        --StrategicZone:SetMarkZone(false)  --REVIEW

        local ResourceListEmpty, ResourceEmpty = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 1, 1,
            GROUP.Attribute.GROUND_IFV)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_TRUCK)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_AAA)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_SAM)


        local ResourceListOccupied, ResourceOccupied = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 1, 1,
            GROUP.Attribute.GROUND_IFV)
        -- We also add ARTY missions with at least one and at most two assets. We additionally require these to be MLRS groups (and not howitzers).
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.ARTY, 0, 1)
        -- Add at least one RECON mission that uses UAV type assets.
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.RECON, 0, 1, GROUP.Attribute.AIR_UAV)
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.CASENHANCED, 0, 1)



        Chief:AddStrategicZone(StrategicZone, priotity, importance, ResourceListOccupied, ResourceListEmpty)
    end

    -- ANCHOR: In attack zone
    for _, zone in pairs(DBattackStrategicZones:GetSet()) do
        local zoneName = zone:GetName()
        local splitName = {}
        for str in string.gmatch(zoneName, "%S+") do
            table.insert(splitName, str)
        end
        local priotity = tonumber(splitName[2]) - 60
        local importance = tonumber(splitName[3]) + 6
        local StrategicZone = OPSZONE:New(zoneName)

        --StrategicZone:SetDrawZone(false)  --REVIEW
        --StrategicZone:SetMarkZone(false)  --REVIEW

        local ResourceListEmpty, ResourceEmptyInf = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_INFANTRY)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.PATROLZONE, 1, 2,
            GROUP.Attribute.GROUND_IFV)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_TRUCK)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 2,
            GROUP.Attribute.GROUND_AAA)

        -- Resource Infantry Bravo is transported by up to 2 APCs.
        Chief:AddTransportToResource(ResourceEmptyInf, 1, 2, { GROUP.Attribute.AIR_TRANSPORTHELO })


        local ResourceListOccupied, ResourceOccupiedCAS = Chief:CreateResource(AUFTRAG.Type.CASENHANCED, 1, 2)
        -- Add at least one RECON mission that uses UAV type assets.
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.RECON, 1, 1, GROUP.Attribute.AIR_UAV)
        -- Add at least one but at most two BOMBCARPET missions.
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.BOMBCARPET, 0, 2)


        Chief:AddStrategicZone(StrategicZone, priotity, importance, ResourceListOccupied, ResourceListEmpty)
    end

    for _, zone in pairs(DBattackSamSites:GetSet()) do
        local zoneName = zone:GetName()
        local splitName = {}
        for str in string.gmatch(zoneName, "%S+") do
            table.insert(splitName, str)
        end
        local priotity = tonumber(splitName[2]) - 60
        local importance = tonumber(splitName[3]) + 6
        local StrategicZone = OPSZONE:New(zoneName)

        --StrategicZone:SetDrawZone(false)  --REVIEW
        --StrategicZone:SetMarkZone(false)  --REVIEW

        local ResourceListEmpty, ResourceEmpty = Chief:CreateResource(AUFTRAG.Type.ONGUARD, 1, 1,
            GROUP.Attribute.GROUND_IFV)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_TRUCK)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_AAA)
        Chief:AddToResource(ResourceListEmpty, AUFTRAG.Type.ONGUARD, 0, 1,
            GROUP.Attribute.GROUND_SAM)


        local ResourceListOccupied, ResourceOccupied = Chief:CreateResource(AUFTRAG.Type.RECON, 0, 1,
            GROUP.Attribute.AIR_UAV)
        -- We also add ARTY missions with at least one and at most two assets. We additionally require these to be MLRS groups (and not howitzers).
        Chief:AddToResource(ResourceListOccupied, AUFTRAG.Type.ARTY, 0, 1)
        -- Add at least one RECON mission that uses UAV type assets.


        Chief:AddStrategicZone(StrategicZone, priotity, importance, ResourceListOccupied, ResourceListEmpty)
    end
    -- !SECTION

    -- SECTION: Other Zones
    for _, zone in pairs(DBcapZone:GetSet()) do
        Chief:AddCapZone(zone, 20000, 350, 270, 30)
    end

    for _, zone in pairs(DBawacsZone:GetSet()) do
        Chief:AddAwacsZone(zone, 25000)
    end

    for _, zone in pairs(DBtankerZone:GetSet()) do
        Chief:AddTankerZone(zone, 18000)
    end
    -- !SECTION

    Chief:SetTacticalOverviewOn() -- REVIEW
    Chief:__Start(5)
    function Chief:OnAfterNewContact(From, Event, To, Contact)
        -- Gather info of contact.
        local ContactName = Chief:GetContactName(Contact)
        local ContactType = Chief:GetContactTypeName(Contact)
        local ContactThreat = Chief:GetContactThreatlevel(Contact)

        -- Text message.
        local text = string.format("Detected NEW contact: Name=%s, Type=%s, Threat Level=%d", ContactName, ContactType,
            ContactThreat)

        -- Show message in log file.
        env.info(text)
    end
end

Ala15vToolBoxTotalWarLoaded = true -- In case it is needed to check if this module is loaded
