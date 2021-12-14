--Download the regui loader

local Url = "https://raw.githubusercontent.com/BK-SPC/regui/main/Update/Start.data"
if _G.RGDebug then
	Url = Url .. ".debug"
end
StartData = game:HttpGetAsync('https://raw.githubusercontent.com/BK-SPC/regui/main/Update/Start.data')
local Loader = loadstring(StartData:gsub("INIT_END.*",""))
--Revert stuff
_R.MenuController:Revert()

local LoadedFeatures = _R.FeatureHandler.Storage.LoadedPlugins
local LoadedPlugins = _R.ThirdPartyPluginHandler.Storage.LoadedPlugins

for FeatureName,Feature in pairs(LoadedFeatures) do
	if Feature.IsEnabled then
		Feature:Disable()
	end
end

for PluginName,Plugin in pairs(LoadedPlugins) do
	if Plugin.IsEnabled then
		Plugin:Disable()
	end
end

--Execute the loader

Loader(
    StartData:sub(
        StartData:find("INIT_END") + 8,
        #StartData
    ),
	{}
)