--[[
- @brief      This function will create a tanker that will orbit around the carrier offering refueling
-
- @example    CarrierTanker("CNV-75", "Arco", "hot", 127.1, 11, "TKR")
-
- @param      carrier       <String>                                        This is the unit name of the carrier
- @param      tanker        <String>                                        This is the group name of the tanker template
- @param      takeOff       <String>    {OPTIONS: "air", "hot", "cold"}     This is how the tanker will appear
- @param      radio         <Float>                                         This is the radio frequency that the tanker will use
- @param      tacan         <Integer>                                       This is the tacan that the tanker will use (ALWAYS "Y")
- @param      tacanName     <String>                                        This is the text transmited through the tacan

- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RecoveryTanker.html
--]]

-- TODO: write in dcs.log

env.info("ALA15vToolBox CarrierTanker declaration")
function CarrierTanker(carrier, tanker, takeOff, radio, tacan, tacanName)
    env.info("ALA15vToolBox CarrierTanker function: Checking if the unit, " .. carrier .. ", exists in the mission")
    if Unit.getByName(carrier) then -- NOTE: this condition is important for campaings
        local carrierUnit = UNIT:FindByName(carrier)
        env.info("ALA15vToolBox CarrierTanker function: Checking if the unit, " .. carrier .. ", is alive")
        if carrierUnit:IsAlive() then
            env.info("ALA15vToolBox CarrierTanker function: Checking if the group, " .. tanker .. ", exists in the mission")
            if Group.getByName(tanker) then
                local recoveryTanker = RECOVERYTANKER:New(carrierUnit, tanker)
                if takeOff == "air" then
                    recoveryTanker:SetTakeoffAir()
                elseif takeOff == "hot" then
                    recoveryTanker:SetTakeoffHot()
                else
                    recoveryTanker:SetTakeoffCold()
                end
                recoveryTanker:SetTACAN(tacan, tacanName)
                recoveryTanker:SetRadio(radio)
                recoveryTanker:Start()
            else
                env.error("ALA15vToolBox CarrierTanker function: The group, " .. tanker .. ", does not exist in the mission")
            end
        else
            env.warning("ALA15vToolBox CarrierTanker function: The unit, " .. carrier .. ", is not alive")
        end
    else
        env.error("ALA15vToolBox CarrierTanker function: The unit " .. carrier .. " does not exist")
    end
end

env.info("ALA15vToolBox CarrierTanker declaration done")

--[[
- @brief      This function will create an awacs that will orbit around the carrier offering information of contacts
-
- @example    CarrierAwacs("CNV-75", "Wizard", "hot", 127.1, 20000, "1")
-
- @param      carrier       <String>                                        This is the unit name of the carrier
- @param      awacs         <String>                                        This is the group name of the awacs template
- @param      takeOff       <String>    {OPTIONS: "air", "hot", "cold"}     This is how the awacs will appear
- @param      radio         <Float>                                         This is the radio frequency that the awacs will use
- @param      alt           <Integer>                                       This is the altitude that the awacs will fly
- @param      tailnum       <String>                                        This is the tail number that the awacs will use

- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RecoveryTanker.html
--]]

env.info("ALA15vToolBox CarrierAwacs declaration")
function CarrierAwacs(carrier, awacs, takeOff, radio, alt, tailnum)
    env.info("ALA15vToolBox CarrierAwacs function: Checking if the unit, " .. carrier .. ", exists in the mission")
    if Unit.getByName(carrier) then -- NOTE: this condition is important for campaings
        local carrierUnit = UNIT:FindByName(carrier)
        env.info("ALA15vToolBox CarrierAwacs function: Checking if the unit, " .. carrier .. ", is alive")
        if carrierUnit:IsAlive() then
            env.info("ALA15vToolBox CarrierAwacs function: Checking if the group, " .. awacs .. ", exists in the mission")
            if Group.getByName(awacs) then
                local carrierAwacs = RECOVERYTANKER:New(carrier, awacs)
                carrierAwacs:SetAWACS()
                carrierAwacs:SetCallsign(CALLSIGN.AWACS.Wizard, tailnum)
                if takeOff == "air" then
                    carrierAwacs:SetTakeoffAir()
                elseif takeOff == "hot" then
                    carrierAwacs:SetTakeoffHot()
                else
                    carrierAwacs:SetTakeoffCold()
                end
                carrierAwacs:SetAltitude(alt)
                carrierAwacs:SetRadio(radio)
                carrierAwacs:Start()
            else
                env.error("ALA15vToolBox CarrierAwacs function: The group, " .. awacs .. ", does not exist in the mission")
            end
        else
            env.warning("ALA15vToolBox CarrierAwacs function: The unit, " .. carrier .. ", is not alive")
        end
    else
        env.error("ALA15vToolBox CarrierAwacs function: The unit " .. carrier .. " does not exist")
    end
end

env.info("ALA15vToolBox CarrierAwacs declaration done")

--[[
- @brief      This function will create a rescue helicopter that will follow the carrier
-
- @example    CarrierHeli("CNV-75", "Angel", "hot")
-
- @param      carrier       <String>                                        This is the unit name of the carrier
- @param      heli          <String>                                        This is the group name of the rescue helicopter template
- @param      takeOff       <String>    {OPTIONS: "air", "hot", "cold"}     This is how the helicopter will appear
-
- @see        https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.RescueHelo.html
--]]

env.info("ALA15vToolBox CarrierHeli declaration")
function CarrierHeli(carrier, heli, takeOff)
    env.info("ALA15vToolBox CarrierHeli function: Checking if the unit, " .. carrier .. ", exists in the mission")
    if Unit.getByName(carrier) then -- NOTE: this condition is important for campaings
        local carrierUnit = UNIT:FindByName(carrier)
        env.info("ALA15vToolBox CarrierHeli function: Checking if the unit, " .. carrier .. ", is alive")
        if carrierUnit:IsAlive() then
            env.info("ALA15vToolBox CarrierHeli function: Checking if the group, " .. heli .. ", exists in the mission")
            if Group.getByName(heli) then
                local rescueHelo = RESCUEHELO:New(carrierUnit, heli)
                if takeOff == "air" then
                    rescueHelo:SetTakeoffAir()
                elseif takeOff == "hot" then
                    rescueHelo:SetTakeoffHot()
                else
                    rescueHelo:SetTakeoffCold()
                end

                rescueHelo:Start()
            else
                env.error("ALA15vToolBox CarrierHeli function: The group, " .. heli .. ", does not exist in the mission")
            end
        else
            env.warning("ALA15vToolBox CarrierHeli function: The unit, " .. carrier .. ", is not alive")
        end
    else
        env.error("ALA15vToolBox CarrierHeli function: The unit " .. carrier .. " does not exist")
    end
end

env.info("ALA15vToolBox CarrierHeli declaration done")
