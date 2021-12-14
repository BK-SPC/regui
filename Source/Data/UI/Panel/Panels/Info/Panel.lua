local Args = {...}
local LocalPath = Args[1]

local Handler = _R.FeatureHandler
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Panel = {
    Object = _H.Asset:Insert(_H.Path:Join(LocalPath,"Panel.rbxm"))[1],
    Icon = _H.Asset:Get(_H.Path:Join(LocalPath,"Icon.png")),
    Name = "Info"
}

local UIEvents = {}
local ReloadScript = loadstring(game:HttpGet('https://raw.githubusercontent.com/BK-SPC/regui/main/Source/Test/Reload.lua'),"Reload.lua")
local Icon = _H.Asset:Get(_H.Path:Join(LocalPath,"Icon.png"))

function Panel:Shown()
    table.insert(UIEvents,self.Object.Buttons.Update.MouseButton1Up:Connect(function()
        StarterGui:SetCore('SendNotification', {
            Title = 'ReGUI',
            Text = 'Checking For Updates',
            Icon = Icon,
            Duration = 5,
        })
        _R:Update()
        StarterGui:SetCore('SendNotification', {
            Title = 'ReGUI',
            Text = 'Update Complete',
            Icon = Icon,
            Duration = 5,
        })
    end))
    table.insert(UIEvents,self.Object.Buttons.ForceUpdate.MouseButton1Up:Connect(function()
        StarterGui:SetCore('SendNotification', {
            Title = 'ReGUI',
            Text = 'Force Installing',
            Icon = Icon,
            Duration = 5,
        })
        _R:Update(true)
        StarterGui:SetCore('SendNotification', {
            Title = 'ReGUI',
            Text = 'Force Install Complete',
            Icon = Icon,
            Duration = 5,
        })
    end))
    table.insert(UIEvents,self.Object.Buttons.Debug.MouseButton1Up:Connect(function()
        _G.RGDebug = not _G.RGDebug
        if _G.RGDebug then
            StarterGui:SetCore('SendNotification', {
                Title = 'ReGUI',
                Text = 'Debug Enabled\nReinstall required',
                Icon = Icon,
                Duration = 5,
            })
        else
            StarterGui:SetCore('SendNotification', {
                Title = 'ReGUI',
                Text = 'Debug Disabled\nReinstall required',
                Icon = Icon,
                Duration = 5,
            })
        end
    end))
    table.insert(UIEvents,self.Object.Buttons.Reload.MouseButton1Up:Connect(function()
        StarterGui:SetCore('SendNotification', {
            Title = 'ReGUI',
            Text = 'Reloading',
            Icon = Icon,
            Duration = 5,
        })
        ReloadScript()
        StarterGui:SetCore('SendNotification', {
            Title = 'ReGUI',
            Text = 'Reloaded',
            Icon = Icon,
            Duration = 5,
        })
    end))
    self.Object.VersionBox.Text = ("LocalVersion: %s || LatestVersion: %s"):format(
        _H.Io:Read(
            _H.Path:Join(
                _R.Directory,
                "LocalVersion.txt"
            )
        ),
        _R.Startup:Read("latestVer")
    )
end

function Panel:Hidden()
    for _,UIEvent in pairs(UIEvents) do
        UIEvent:Disconnect()
    end
    UIEvents = {}
end

function Panel:Unload()
    for _,UIEvent in pairs(UIEvents) do
        UIEvent:Disconnect()
    end
    UIEvents = {}
end

return Panel