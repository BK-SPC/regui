local Args = {...}
local LocalPath = Args[1]

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local MenuController = {}

function MenuController:ShowPopup()
    self.InAnim = true
    self.BG.Visible = true
    self.RGPopupFrame.Visible = true
    local BGFadeTween = TweenService:Create(
        self.BG,
        TweenInfo.new(
            self.AnimDur, -- time,
            Enum.EasingStyle.Sine, -- easingStyle
            Enum.EasingDirection.InOut, -- easingDirection
            0, -- repeatCount
            false, -- reverses
            0 -- delayTime
        ),
        {
            BackgroundTransparency = 0.6
        }
    )
    local PopupTween = TweenService:Create(
        self.Scale,
        TweenInfo.new(
            self.AnimDur * 1.2, -- time,
            Enum.EasingStyle.Back, -- easingStyle
            Enum.EasingDirection.Out, -- easingDirection
            0, -- repeatCount
            false, -- reverses
            0 -- delayTime
        ),
        {
            Scale = 1
        }
    )
    BGFadeTween:Play()
    PopupTween:Play()
    wait(self.AnimDur)
    self.InAnim = false
end

function MenuController:HidePopup()
    self.InAnim = true
    self.BG.Visible = true
    self.RGPopupFrame.Visible = true
    local BGFadeTween = TweenService:Create(
        self.BG,
        TweenInfo.new(
            self.AnimDur, -- time,
            Enum.EasingStyle.Sine, -- easingStyle
            Enum.EasingDirection.Out, -- easingDirection
            0, -- repeatCount
            false, -- reverses
            0 -- delayTime
        ),
        {
            BackgroundTransparency = 1
        }
    )
    local PopupTween = TweenService:Create(
        self.Scale,
        TweenInfo.new(
            self.AnimDur, -- time,
            Enum.EasingStyle.Sine, -- easingStyle
            Enum.EasingDirection.In, -- easingDirection
            0, -- repeatCount
            false, -- reverses
            0 -- delayTime
        ),
        {
            Scale = 0
        }
    )
    BGFadeTween:Play()
    PopupTween:Play()
    wait(self.AnimDur)
    self.BG.Visible = false
    self.RGPopupFrame.Visible = false
    self.InAnim = false
end

function MenuController:Init()
    self.AnimDur = 0.25
    self.PopupButton = _H.Asset:Insert(_H.Path:Join(LocalPath,"..","EscMenu","RGButton","RGHintButton.rbxm"))[1]
    self.PopupButtonImage = _H.Asset:Get(_H.Path:Join(LocalPath,"..","EscMenu","RGButton","Icon.png"))
    self.PopupButton.RGHint.Image = self.PopupButtonImage
    _H.Gui:Protect(self.PopupButton)
    self.PopupButton.Parent = CoreGui:WaitForChild("RobloxGui"):WaitForChild("SettingsShield"):WaitForChild("SettingsShield")
    self.Events = {}
    self.PopupGui = _H.Asset:Insert(_H.Path:Join(LocalPath,"PopupGui.rbxm"))[1]
    _H.Gui:Protect(self.PopupGui)
    self.PopupGui.Parent = CoreGui
    self.RGPopupFrame = self.PopupGui.RGPopupFrame
    self.Scale = self.RGPopupFrame.PopupScale
    self.Scale.Scale = 0
    self.BG = self.PopupGui.BG
    self.BG.Visible = false
    self.BG.BackgroundTransparency = 1
    self.RGPopupFrame.Visible = false
    self.InAnim = false
    table.insert(self.Events,self.BG.MouseButton1Up:Connect(function()
        if not self.InAnim then
            self:HidePopup()
        end
    end))
    table.insert(self.Events,self.PopupButton.MouseButton1Up:Connect(function()
        if not self.InAnim then
            self:ShowPopup()
        end
    end))
    self.PanelHandler = _H:Require(_H.Path:Join(LocalPath,"..","Panel"),"PanelHandler.lua"):Init()
    self.PanelHandler.Gui.Parent = self.RGPopupFrame.MainContent
end

function MenuController:Revert()
    for _,Event in pairs(self.Events) do
        Event:Disconnect()
    end
    self.PopupButton:Destroy()
    self.PopupGui:Destroy()
end

return MenuController