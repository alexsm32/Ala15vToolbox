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

function CarrierTanker(carrier, tanker, takeOff, radio, tacan, tacanName)
    if Unit.getByName(carrier) then -- NOTE: this condition is important for campaings
        local carrierUnit = UNIT:FindByName(carrier)
        if carrierUnit:IsAlive() then
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
        end

    end
end

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

function CarrierAwacs(carrier, awacs, takeOff, radio, alt, tailnum)
    if Unit.getByName(carrier) then -- NOTE: this condition is important for campaings
        local carrierUnit = UNIT:FindByName(carrier)
        if carrierUnit:IsAlive() then
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
        end

    end
end

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

function CarrierHeli(carrier, heli, takeOff)
    if Unit.getByName(carrier) then -- NOTE: this condition is important for campaings
        local carrierUnit = UNIT:FindByName(carrier)
        if carrierUnit:IsAlive() then
            local rescueHelo = RESCUEHELO:New(carrierUnit, heli)
            if takeOff == "air" then
                rescueHelo:SetTakeoffAir()
            elseif takeOff == "hot" then
                rescueHelo:SetTakeoffHot()
            else
                rescueHelo:SetTakeoffCold()
            end

            rescueHelo:Start()
        end

    end
end
