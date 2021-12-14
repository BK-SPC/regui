local Args = {...}
local LocalPath = Args[1]

local Handler = _R.ThirdPartyPluginHandler
local TweenService = game:GetService("TweenService")

local Panel = {
    Object = _H.Asset:Insert(_H.Path:Join(LocalPath,"Panel.rbxm"))[1],
    Icon = _H.Asset:Get(_H.Path:Join(LocalPath,"Icon.png")),
    Name = "ThirdParty Plugins"
}

local function GetPluginList()
    local Plugins = Handler:GetPlugins()
    local NewList = {}
    local EnabledPlugins = Handler:WasEnabled()
    for i,PluginName in pairs(Plugins) do
        NewList[PluginName] = {
            Meta = Handler:GetPluginMeta(PluginName);
            IsEnabled = EnabledPlugins[PluginName];
            IsLoaded = false;
        }
        if EnabledPlugins[PluginName] then
            NewList[PluginName] = Handler:Load(PluginName)
            NewList[PluginName].Meta = Handler:GetPluginMeta(PluginName)
            NewList[PluginName].IsLoaded = true
        end
    end
    return NewList
end

local PluginsList
local PluginItemPlaceholder = _H.Asset:Insert(_H.Path:Join(LocalPath,"..","Shared","PluginItem.rbxm"))[1]

local ToggleTweenInfo = TweenInfo.new(
    .5, -- Time
    Enum.EasingStyle.Back, -- EasingStyle
    Enum.EasingDirection.InOut, -- EasingDirection
    0, -- RepeatCount (when less than zero the tween will loop indefinitely)
    false, -- Reverses (tween will reverse once reaching it's goal)
    0 -- DelayTime
)

local ToggleEnabledGoal = {
    Position = UDim2.new(0.65,0,0,0);
    ImageColor3 = Color3.fromRGB(50,181,255);
}
local ToggleEnabledColor = {
    ImageColor3 = Color3.fromRGB(50,181,255);
}


local ToggleDisabledGoal = {
    Position = UDim2.new(0.35,0,0,0);
    ImageColor3 = Color3.fromRGB(255, 62, 60);
}

local ToggleDisabledColor = {
    ImageColor3 = Color3.fromRGB(255, 62, 60);
}

local UIEvents = {}
local function UpdatePluginList()
    --//Update the plugins table
    PluginsList = GetPluginList()
    --//Disconnect any unneeded events
    for _,UIEvent in pairs(UIEvents) do
        UIEvent:Disconnect()
    end
    --//Clear out the old plugin items
    for _,Obj in pairs(Panel.Object:GetChildren()) do
        if Obj:IsA("Frame") then
            Obj:Destroy()
        end
    end

    --//Create the plugin items
    for PluginName,Plugin in pairs(PluginsList) do
        local PluginItem = PluginItemPlaceholder:Clone()
        PluginItem.Contents.PluginIconFrame.PluginIcon.Image = Plugin.Meta.Thumb.StaticThumb
        if Plugin.Meta.Thumb.AnimThumb then
            PluginItem.Contents.PluginIconFrame.PluginVideo.Video = Plugin.Meta.Thumb.AnimThumb
            PluginItem.Contents.PluginIconFrame.PluginVideo.Visible = false
            table.insert(UIEvents,PluginItem.Contents.MouseEnter:Connect(function()
                PluginItem.Contents.PluginIconFrame.PluginVideo.Visible = true
                PluginItem.Contents.PluginIconFrame.PluginVideo.TimePosition = 0
                PluginItem.Contents.PluginIconFrame.PluginVideo.Volume = 0.25
                PluginItem.Contents.PluginIconFrame.PluginVideo:Play()
            end))

            table.insert(UIEvents,PluginItem.Contents.MouseLeave:Connect(function()
                PluginItem.Contents.PluginIconFrame.PluginVideo.Visible = false
                PluginItem.Contents.PluginIconFrame.PluginVideo:Pause()
            end))
        else
            PluginItem.Contents.PluginIconFrame.PluginVideo:Destroy()
        end
        PluginItem.Contents.TextArea.Title.Text = Plugin.Meta.Title
        PluginItem.Contents.TextArea.Desc.Text = Plugin.Meta.Desc
        PluginItem.Contents.TextArea.Creator.Text = "Created by: " .. Plugin.Meta.Creator

        PluginItem.Contents.ToggleFrame.Visible = true
        PluginItem.Contents.ToggleFrame.RGToggleInner.Image = _H.Asset:Get(_H.Path:Join(LocalPath,"..","Shared","RGToggle","RGToggleInner.png"))
        PluginItem.Contents.ToggleFrame.RGToggleOutline.Image = _H.Asset:Get(_H.Path:Join(LocalPath,"..","Shared","RGToggle","RGToggleOutline.png"))
        PluginItem.Contents.ToggleFrame.RGToggleBall.Image = _H.Asset:Get(_H.Path:Join(LocalPath,"..","Shared","RGToggle","RGToggleBall.png"))

        table.insert(UIEvents,PluginItem.Contents.ToggleFrame.RGToggleBall.MouseButton1Up:Connect(function()
            if Plugin.IsEnabled then
                local BallTween = TweenService:Create(PluginItem.Contents.ToggleFrame.RGToggleBall, ToggleTweenInfo, ToggleDisabledGoal)
                local ColorTween1 = TweenService:Create(PluginItem.Contents.ToggleFrame.RGToggleInner, ToggleTweenInfo, ToggleDisabledColor)
                local ColorTween2 = TweenService:Create(PluginItem.Contents.ToggleFrame.RGToggleOutline, ToggleTweenInfo, ToggleDisabledColor)
                BallTween:Play()
                ColorTween1:Play()
                ColorTween2:Play()
                -- redundant parameter my ass
                task.spawn(function()
                    -- honestly have no idea wtf Handler:Unload() does
                    Plugin:Disable(i)
                    Handler:Unload()
                end)
            else
                local BallTween = TweenService:Create(PluginItem.Contents.ToggleFrame.RGToggleBall, ToggleTweenInfo, ToggleEnabledGoal)
                local ColorTween1 = TweenService:Create(PluginItem.Contents.ToggleFrame.RGToggleInner, ToggleTweenInfo, ToggleEnabledColor)
                local ColorTween2 = TweenService:Create(PluginItem.Contents.ToggleFrame.RGToggleOutline, ToggleTweenInfo, ToggleEnabledColor)
                BallTween:Play()
                ColorTween1:Play()
                ColorTween2:Play()
                if not Plugin.IsLoaded then
                    PluginsList[PluginName] = Handler:Load(PluginName)
                    PluginsList[PluginName].Meta = Handler:GetPluginMeta(PluginName)
                    PluginsList[PluginName].IsLoaded = true
                    Plugin = PluginsList[PluginName]
                end
                -- redundant parameter my ass
                task.spawn(function()
                    Plugin:Enable()
                end)
            end
            Handler:SetWasEnabled(PluginName,Plugin.IsEnabled)
        end))

        if Plugin.IsEnabled then
            for Key,Value in pairs(ToggleEnabledGoal) do
                PluginItem.Contents.ToggleFrame.RGToggleBall[Key] = Value
            end
            for Key,Value in pairs(ToggleEnabledColor) do
                PluginItem.Contents.ToggleFrame.RGToggleInner[Key] = Value
                PluginItem.Contents.ToggleFrame.RGToggleOutline[Key] = Value
            end
            --Handler:Unload(PluginName)
            --Plugins[PluginName].IsLoaded = false
        else
            for Key,Value in pairs(ToggleDisabledGoal) do
                PluginItem.Contents.ToggleFrame.RGToggleBall[Key] = Value
            end
            for Key,Value in pairs(ToggleDisabledColor) do
                PluginItem.Contents.ToggleFrame.RGToggleInner[Key] = Value
                PluginItem.Contents.ToggleFrame.RGToggleOutline[Key] = Value
            end
        end

        PluginItem.Parent = Panel.Object
    end
end

function Panel:Shown()
    UpdatePluginList()
end

function Panel:Hidden()

end

function Panel:Unload()
    for _,UIEvent in pairs(UIEvents) do
        UIEvent:Disconnect()
    end
end

return Panel