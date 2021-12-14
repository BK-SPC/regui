local Io = _H.Io.new(_R.Directory)

local PluginHandler = {
    
    Storage = {
        LoadedPlugins = {};
    };

    GetPluginMeta = function(self,PluginName)
        local Meta =  game:GetService("HttpService"):JSONDecode(
            Io:Read({"Data","Plugins",PluginName,"Plugin.json"})
        )
        for Key,Value in pairs(Meta.Thumb) do
            Meta.Thumb[Key] = _ReGui.Helper.Asset:Get(
                Io:GetFullPath{"Data","Plugins",PluginName,Value}
            );
        end
        return Meta
    end;

    --//TODO: Create a GUI for plugin settings

    GetPluginSettings = function(self)
        Io.Cache.Content = {}
        local JSONPath = "PluginSettings.json"
        local PluginSettings
        if Io:IsFile(JSONPath) then
            PluginSettings = game:GetService("HttpService"):JSONDecode(Io:Read(JSONPath))
        else
            PluginSettings = {}
            Io:Write(JSONPath,game:GetService("HttpService"):JSONEncode(PluginSettings))
        end

        return PluginSettings
    end;

    SetPluginSetting = function(self,PluginName,Key,Value)
        local JSONPath = "PluginSettings.json"
        local PluginSettings

        if Io:IsFile(JSONPath) then
            PluginSettings = game:GetService("HttpService"):JSONDecode(Io:Read(JSONPath))
        else
            PluginSettings = {}
            Io:Write(JSONPath,game:GetService("HttpService"):JSONEncode(PluginSettings))
        end

        if not PluginSettings[PluginName] then
            PluginSettings[PluginName] = {}
        end
        PluginSettings[PluginName][Key] = Value
        Io:Write(JSONPath,game:GetService("HttpService"):JSONEncode(PluginSettings))
    end;

    GetPlugins = function(self)
        local PluginsPath = Io:GetFullPath{"Data","Plugins"}
        local PluginList = Io:ListFiles{"Data","Plugins"}
        local FinalList = {}
        for _,PluginName in pairs(PluginList) do
            PluginName = string.sub(PluginName,#PluginsPath+2,#PluginName)
            if Io:IsFile{"Data","Plugins",PluginName,"Plugin.lua"} then
                table.insert(FinalList,PluginName)
            else
                _ReGui:Log(PluginName .. " is missing \"Plugin.lua\"")
            end
        end
        return FinalList
    end;

    IsLoaded = function(self)
        return self.Storage.LoadedPlugins[PluginName] ~= nil
    end;

    Unload = function(self,PluginName)
        local Plugin = self.Storage.LoadedPlugins[PluginName]
        if Plugin then
            if Plugin.IsEnabled then
                Plugin:Disable()
            end
            self.Storage.LoadedPlugins[PluginName] = nil
        end
    end;

    Load = function(self,PluginName)
        if not self.Storage.LoadedPlugins[PluginName] then
            self.Storage.LoadedPlugins[PluginName] = _ReGui.Helper:Require(_ReGui.Helper.Path:Join(_ReGui.Directory,"Data","Plugins",PluginName),"Plugin.lua")
            self.Storage.LoadedPlugins[PluginName].Meta = self:GetPluginMeta(PluginName)
            self.Storage.LoadedPlugins[PluginName].Settings = self:GetPluginSettings()[PluginName] or {}
        end
        return self.Storage.LoadedPlugins[PluginName]
    end;

    WasEnabled = function(self)
        local JSONPath = "EnabledPlugins.json"
        local EnabledPlugins
        if Io:IsFile(JSONPath) then
            EnabledPlugins = game:GetService("HttpService"):JSONDecode(Io:Read(JSONPath))
        else
            EnabledPlugins = {}
            Io:Write(JSONPath,game:GetService("HttpService"):JSONEncode(EnabledPlugins))
        end

        return EnabledPlugins
    end;

    SetWasEnabled = function(self,PluginName,Enabled)
        local JSONPath = "EnabledPlugins.json"
        local EnabledPlugins

        if Io:IsFile(JSONPath) then
            EnabledPlugins = game:GetService("HttpService"):JSONDecode(Io:Read(JSONPath))
        else
            EnabledPlugins = {}
            Io:Write(JSONPath,game:GetService("HttpService"):JSONEncode(EnabledPlugins))
        end

        EnabledPlugins[PluginName] = Enabled
        Io:Write(JSONPath,game:GetService("HttpService"):JSONEncode(EnabledPlugins))
    end;

    Init = function(self)
        local Plugins = self:GetPlugins()
        local EnabledPlugins = self:WasEnabled()
        for _,Plugin in pairs(Plugins) do
            if EnabledPlugins[Plugin] then
                task.spawn(function()
                    self:Load(Plugin):Enable()
                end)
            end
        end
    end;
}

return PluginHandler