--TESTING
local Path = "C:\\Users\\Alejandro\\Saved Games\\DCS.openbeta\\Missions"
local Filename = "CampaingTest"
local Spawn = false

if UTILS.FileExists(Path .. "\\" .. Filename) then
    local myGroups = UTILS.LoadSetOfGroups(Path, Filename, Spawn)
    local Data = UTILS.OneLineSerialize(myGroups)
    UTILS.SaveToFile(Path, "ObjetoCamp", Data)
    --for _, group in pairs(myGroups:GetSet()) do
    --    group:ReSpawn()
    --end
end

--local Set = SET_GROUP:New():FilterStart()
--UTILS.SaveSetOfGroups(Set, Path, Filename)


--local client = UNIT:FindByName("Aéreo-1-1")
--local Data = client:GetTemplatePayload()
--Data = UTILS.OneLineSerialize(Data)
--UTILS.SaveToFile(Path, Filename, Data)
