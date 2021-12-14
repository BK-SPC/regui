local Startup,LOCAL_PATH,Exploit = unpack(({...}))

Startup:Log("Loading Helpers")

local HttpService = game:GetService("HttpService")
local helpers = HttpService:JSONDecode(Startup:Read("helpers.json"))
local LoadedHelpers = {}

for i,helper in pairs(helpers) do
    local UsedVersion = Exploit
    local DebugName
    if not helper.Versions[UsedVersion] then
        UsedVersion = helper.Fallback
        DebugName = helper.Name .. "@" .. UsedVersion .. " (Fallback)"
    else
        DebugName = helper.Name .. "@" .. UsedVersion
    end
    Startup:Log("Load Helper:",DebugName)
    local OrigHelper = Startup:Execute(helper.Versions[UsedVersion],LoadedHelpers)
    local Wrapper
    if helper.Wrapper then
        Wrapper = Startup:Execute(helper.Wrapper,OrigHelper)
    end
    LoadedHelpers[helper.Name] = Wrapper or OrigHelper
end

Startup:Log("Loaded Helpers")

return LoadedHelpers