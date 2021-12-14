local Startup,LOCAL_PATH,Helpers = unpack(({...}))

local Require = {}

function Require:Require(ModulePath,ModuleName)
	local Path = Helpers.Path:Join(ModulePath,ModuleName)
	local Content = Helpers.Io:Read(Path)
	local LoadedString,Err = loadstring(Content,Path)
	if not LoadedString then
		Startup:Log(Path,"failed to load",Err)
	else
		return LoadedString(ModulePath)
	end
end

function Helpers:Require(...)
    return Require:Require(...)
end

return Require