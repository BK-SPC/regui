local Args = {...}
local LocalPath = Args[1]

_R:Log("Data/Main.lua started")
_R:Log("Load: FeatureHandler")
_R.FeatureHandler = _H:Require(_H.Path:Join(LocalPath,"Modules"),"FeatureHandler.lua")
_R:Log("Loaded: FeatureHandler")
_R.ThirdPartyPluginHandler = _H:Require(_H.Path:Join(LocalPath,"Modules"),"ThirdPartyPluginHandler.lua")
_R:Log("Loaded: ThirdPartyPluginHandler")
_R.LibDeflate = _H:Require(_H.Path:Join(LocalPath,"Modules"),"LibDeflate.lua")
_R:Log("Loaded: LibDeflate")
_R.CacheHandler = _H:Require(_H.Path:Join(LocalPath,"Modules"),"CacheHandler.lua")
_R:Log("Loaded: CacheHandler")
_R.ObjectPoolHandler = _H:Require(_H.Path:Join(LocalPath,"Modules"),"ObjectPoolHandler.lua")
_R:Log("Loaded: ObjectPoolHandler")
_R.FeatureHandler:Init()
_R.ThirdPartyPluginHandler:Init()
--//Modify the EscMenu
_R.MenuController = _H:Require(_H.Path:Join(LocalPath,"UI","Popup"),"MenuController.lua")
_R.MenuController:Init()