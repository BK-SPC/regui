local Args = {...}
local LocalPath = Args[1]

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UDimUp = UDim2.new(0.5,0,1.5,0)
local UDimCenter = UDim2.new(0.5,0,0.5,0)
local UDimDown = UDim2.new(0.5,0,-0.5,0)

local PanelHandler = {}

function PanelHandler:UpdateIndexes()
    for i,Panel in pairs(self.LoadedPanels) do
        Panel.Index = i
        if self.PanelButtons[i] then
            self.PanelButtons[i].LayoutOrder = i
        end
    end
end

function PanelHandler:LoadPanel(Panel)
    table.insert(self.LoadedPanels,Panel)
    self:UpdateIndexes()
    return Panel
end

function PanelHandler:UnloadPanel(Panel)
    Panel:Unload()
    if Panel.ClickEvent then
        Panel.ClickEvent:Disconnect()
        self.PanelButtons[Panel.Index] = nil
    end
    self.LoadedPanels[Panel.Index] = nil
    self:UpdateIndexes()
end

function PanelHandler:SetPanel(Panel)
    if self.CurPanel then
        self.CurPanel:Hidden()
    end
    for _,PanelButton in pairs(self.Gui.PanelContents.Main:GetChildren()) do
        PanelButton.Parent = nil
    end
    self.Gui.PanelContents.Title.Text = Panel.Name
    Panel.Object.Parent = self.Gui.PanelContents.Main
    Panel.Object.Position = UDimCenter
    self.CurPanel = Panel
    Panel:Shown()
end

function PanelHandler:ChangePanel(NewPanel)
    local LastPanel = self.CurPanel
    if not LastPanel then
        return self:SetPanel(NewPanel)
    end
    local LastPanelTarget
    local NewPanelTarget
    if LastPanel.Index < NewPanel.Index then
        LastPanelTarget = UDimDown
        NewPanelTarget = UDimCenter
        NewPanel.Object.Position = UDimUp
    elseif LastPanel.Index > NewPanel.Index then
        LastPanelTarget = UDimUp
        NewPanelTarget = UDimCenter
        NewPanel.Object.Position = UDimDown
    else
        return self:SetPanel(NewPanel)
    end
    local LastPanelTween = TweenService:Create(
        LastPanel.Object,
        TweenInfo.new(
            self.AnimDur, -- time,
            Enum.EasingStyle.Exponential, -- easingStyle
            Enum.EasingDirection.InOut, -- easingDirection
            0, -- repeatCount
            false, -- reverses
            0 -- delayTime
        ),
        {
            Position = LastPanelTarget
        }
    )
    local NewPanelTween = TweenService:Create(
        NewPanel.Object,
        TweenInfo.new(
            self.AnimDur, -- time,
            Enum.EasingStyle.Exponential, -- easingStyle
            Enum.EasingDirection.InOut, -- easingDirection
            0, -- repeatCount
            false, -- reverses
            0 -- delayTime
        ),
        {
            Position = NewPanelTarget
        }
    )
    LastPanelTween:Play()
    NewPanelTween:Play()
    LastPanel.Object.Parent = self.Gui.PanelContents.Main
    NewPanel.Object.Parent = self.Gui.PanelContents.Main
    self.CurPanel = NewPanel
    LastPanel:Hidden()
    NewPanel:Shown()
    self.Gui.PanelContents.Title.Text = NewPanel.Name
    self.InAnim = true
    wait(self.AnimDur)
    self.InAnim = false
    LastPanel.Parent = nil
end

function PanelHandler:SpawnPanelButton(Panel)
    local PanelButton = self.PanelButton:Clone()
    PanelButton.Name = Panel.Name
    PanelButton.PanelButton.Image = Panel.Icon
    PanelButton.Parent = self.Gui.PanelsFrame.Contents
    self.PanelButtons[Panel.Index] = PanelButton
    Panel.ClickEvent = PanelButton.PanelButton.MouseButton1Up:Connect(function()
        if not self.InAnim then
            self:ChangePanel(Panel)
        end
    end)
    self:UpdateIndexes()
    return PanelButton
end

function PanelHandler:RemovePanelButton(Panel)
    if Panel.ClickEvent then
        Panel.ClickEvent:Disconnect()
        self.PanelButtons[Panel.Index] = nil
    end
end

function PanelHandler:Init()
    self.AnimDur = 0.5
    self.Gui = _H.Asset:Insert(_H.Path:Join(LocalPath,"PanelMenu.rbxm"))[1]
    self.Gui.PanelContents.Title.Text = ""
    self.LoadedPanels = {}
    self.PanelButtons = {}
    self.PanelButton = _H.Asset:Insert(_H.Path:Join(LocalPath,"PanelButton.rbxm"))[1]
    local DefaultPanels = HttpService:JSONDecode(_H.Io:Read(_H.Path:Join(LocalPath,"Panels.json")))
    for _,DefaultPanel in pairs(DefaultPanels) do
        self:SpawnPanelButton(self:LoadPanel(_H:Require(_H.Path:Join(LocalPath,"Panels",DefaultPanel),"Panel.lua")))
    end
    return self
end

return PanelHandler