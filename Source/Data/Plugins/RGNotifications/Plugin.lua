local Args = {...}
local LocalPath = Args[1]
local Io = _H.Io.new(LocalPath)

local NotifPlugin
NotifPlugin = {
    Storage = {};
    IsEnabled = false;
    Enable = function(self)
        self.IsEnabled = true
        self.Storage.NotifUI = _H.Asset:Insert(Io:GetFullPath("RGNotifyUI.rbxm"))[1]
        _H.Gui:Protect(self.Storage.NotifUI)
        self.Storage.NotifUI.Parent = game:GetService("CoreGui")
        self.Storage.NotifSlots = {}

        local Config = _R.FeatureHandler:GetPluginSettings()["RGNotifications"] or {}
        local Scale = Config.Scale
        if not Scale then
            Scale = .75
            _R.FeatureHandler:SetPluginSetting("RGNotifications","Scale",.75)
        end
        --self.Storage.NotifUI.NotifsArea.Size = UDim2.fromScale(self.Storage.NotifUI.NotifsArea.Size.X.Scale * Scale,self.Storage.NotifUI.NotifsArea.Size.Y.Scale)

        local OutTweenInfo = TweenInfo.new(
            .5, -- Time
            Enum.EasingStyle.Back, -- EasingStyle
            Enum.EasingDirection.InOut, -- EasingDirection
            0, -- RepeatCount (when less than zero the tween will loop indefinitely)
            false, -- Reverses (tween will reverse once reaching it's goal)
            0 -- DelayTime
        )

        local InTweenInfo = TweenInfo.new(
            .5, -- Time
            Enum.EasingStyle.Back, -- EasingStyle
            Enum.EasingDirection.InOut, -- EasingDirection
            0, -- RepeatCount (when less than zero the tween will loop indefinitely)
            false, -- Reverses (tween will reverse once reaching it's goal)
            0 -- DelayTime
        )

        local OGNotifBase = _H.Asset:Insert(Io:GetFullPath("NotifBase.rbxm"))[1]
        local UIScale = Instance.new("UIScale",OGNotifBase)
        UIScale.Scale = Scale

        function self.Storage:NotifSend(ConfigTable)
            --//Run this in a xpcall so if the JSONEncode fails the notif will still work
            --//Because emojis cause JSONEncode errors for some reason idk why
            --//also this doesn't yield so xpcall is faster than pcall
            xpcall(function()
                _R:Log(game:GetService("HttpService"):JSONEncode(ConfigTable))
            end,function(Error)
                _R:Log("[Error] " .. Error)
            end)
            local TweenService = game:GetService("TweenService")
            local NotifBase = OGNotifBase:Clone()
            NotifBase.Icon.Image = ConfigTable.Icon or _H.Asset:Get(Io:GetFullPath("NotifBell.png"))
            NotifBase.TimerBar.Cover.Fade.Image = _H.Asset:Get(Io:GetFullPath("RGNotifCover.png"))
            if ConfigTable.Button1 then
                if not ConfigTable.Button2 then
                    NotifBase.Button1:Destroy()
                    NotifBase.ButtonSep:Destroy()
                    NotifBase.Button2.Text = ConfigTable.Button1
                else
                    NotifBase.Button1.Text = ConfigTable.Button1
                    NotifBase.Button2.Text = ConfigTable.Button2
                end
            else
                NotifBase.Button1:Destroy()
                NotifBase.Button2:Destroy()
                NotifBase.ButtonSep:Destroy()
            end
            NotifBase.Title.Text = ConfigTable.Title
            NotifBase.Main.Text = ConfigTable.Text
            local Slot = 0
            local SearchingForSlot = true
            while SearchingForSlot do
                Slot = Slot + 1
                if self.NotifSlots[tostring(Slot)] ~= true then
                    self.NotifSlots[tostring(Slot)] = true
                    SearchingForSlot = false
                end
            end
            NotifBase.Position = UDim2.new(
                NotifBase.Position.X.Scale,
                NotifBase.Position.X.Offset,
                (1 - ((0.275 * Scale) * (Slot-1))),
                0
            )
            ConfigTable.Duration = ConfigTable.Duration or 5
            local TimeStart = os.clock()
            local TimeEnd = os.clock() + ConfigTable.Duration
            local RenderStepped
            local Cover = NotifBase.TimerBar.Cover
            local Fade = Cover.Fade
            local Descendants = NotifBase:GetDescendants()
            --table.insert(Descendants,NotifBase)
            local InTween = TweenService:Create(NotifBase, InTweenInfo, {
                Position = NotifBase.Position
            })
            NotifBase.Position = UDim2.new(2,0,NotifBase.Position.Y.Scale,NotifBase.Position.Y.Offset)
            InTween:Play()
            local NotifEvents = {}
            RenderStepped = game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
                debug.profilebegin("RGNotifRender")
                if not NotifBase then
                    RenderStepped:Disconnect()
                    return
                end
                Cover.Position = UDim2.new((os.clock() - TimeStart) / ConfigTable.Duration,0)
                if os.clock() - TimeEnd >= -0.5 then
                    debug.profilebegin("Fade")
                    for _,Descendant in pairs(Descendants) do
                        if Descendant:IsA("ImageLabel") then
                            Descendant.ImageTransparency = Descendant.ImageTransparency + (DeltaTime*2)
                        elseif Descendant:IsA("Frame") and Descendant.Name ~= "TimerBarBgFix" then
                            Descendant.BackgroundTransparency = Descendant.BackgroundTransparency + (DeltaTime*2)
                        elseif Descendant:IsA("TextButton") then
                            Descendant.BackgroundTransparency = Descendant.BackgroundTransparency + (DeltaTime*2)
                            Descendant.TextTransparency = Descendant.TextTransparency + (DeltaTime*2)
                        elseif Descendant:IsA("TextLabel") then
                            Descendant.TextTransparency = Descendant.TextTransparency + (DeltaTime*2)
                        end
                    end
                    debug.profileend("Fade")
                end
                if os.clock() - TimeEnd >= 0 then
                    RenderStepped:Disconnect()
                    for _,Descendant in pairs(Descendants) do
                        if not Descendant:IsA("UICorner") and Descendant.Name ~= "TimerBarBgFix" then
                            Descendant:Destroy()
                        end
                    end
                    local OutTween = TweenService:Create(NotifBase, OutTweenInfo, {
                        Position = UDim2.new(2,0,NotifBase.Position.Y.Scale,NotifBase.Position.Y.Offset)
                    })
                    NotifBase.Size = UDim2.fromScale(NotifBase.Size.X.Scale * Scale,NotifBase.Size.Y.Scale * Scale)
                    OutTween:Play()
                    self.NotifSlots[tostring(Slot)] = false
                else
                    self.NotifSlots[tostring(Slot)] = true
                end
                debug.profileend("RGNotifRender")
            end)
            if NotifBase:FindFirstChild("Button1") then
                table.insert(NotifEvents,NotifBase.Button1.MouseButton1Up:Connect(function()
                    TimeEnd = os.clock() + .5
                    if ConfigTable.Callback then
                        ConfigTable.Callback:Invoke(NotifBase.Button1.Text)
                    end
                end))
            end
            if NotifBase:FindFirstChild("Button2") then
                table.insert(NotifEvents,NotifBase.Button2.MouseButton1Up:Connect(function()
                    TimeEnd = os.clock() + .5
                    if ConfigTable.Callback then
                        ConfigTable.Callback:Invoke(NotifBase.Button2.Text)
                    end
                end))
            end
            coroutine.resume(coroutine.create(function()
                game:GetService("RunService").RenderStepped:Wait()
                NotifBase.Title.TextSize = NotifBase.Title.AbsoluteSize.Y / Scale
                NotifBase.Main.TextSize = (NotifBase.Title.AbsoluteSize.Y / Scale) * 0.75
                if ConfigTable.Button1 then
                    if not ConfigTable.Button2 then
                        NotifBase.Button2.TextSize = (NotifBase.Title.AbsoluteSize.Y / Scale) * 0.75
                    else
                        NotifBase.Button1.TextSize = (NotifBase.Title.AbsoluteSize.Y / Scale) * 0.75
                        NotifBase.Button2.TextSize = (NotifBase.Title.AbsoluteSize.Y / Scale) * 0.75
                    end
                end
                wait(ConfigTable.Duration + 1)
                self.NotifSlots[tostring(Slot)] = false
                NotifBase:Destroy()
            end))
            NotifBase.Parent = self.NotifUI.NotifsArea
        end

        self.Storage.NotifSendEvent = Instance.new("BindableEvent")
        self.Storage.NotifSendEvent.Event:Connect(function(...)
            self.Storage:NotifSend(...)
        end)
        --[[
        self.AlignRS = game:GetService("RunService").RenderStepped:Connect(function(DeltaTime)
            local Index = 0
            for NotifBase,_ in pairs(self.Storage.NotifObjs) do
                NotifBase.Position = UDim2.new(
                    NotifBase.Position.X.Scale,
                    NotifBase.Position.X.Offset,
                    (1 - (0.275 * Index)),
                    0
                )
                Index += 1
            end
        end)
        ]]
        --//Dont hook if we're already hooked
        if not self.IsHooked then
            --//Hook SendNotification
            self.IsHooked = true
            local StarterGui = game:GetService("StarterGui")
            local StarterGuiMt = getrawmetatable(StarterGui)
            local OldNameCall = StarterGuiMt.__namecall
            self.Storage.OldNameCall = OldNameCall
            
            setreadonly(StarterGuiMt, false)
            
            StarterGuiMt.__namecall = newcclosure(function(Self, ...)
                local Args = {...}
                local NamecallMethod = getnamecallmethod()

                if NamecallMethod == "SetCore" and Args[1] == "SendNotification" and NotifPlugin.IsEnabled then
                    return NotifPlugin.Storage.NotifSendEvent:Fire(Args[2])
                end
            
                return OldNameCall(Self, ...)
            end)
            
            setreadonly(StarterGuiMt, true)
        end
    end;
    Disable = function(self)
        self.IsEnabled = false
        self.Storage.NotifUI:Destroy()
        --self.AlignRS:Disconnect()
    end;
}

return NotifPlugin