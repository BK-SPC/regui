local Startup,LOCAL_PATH,LAUNCH_ARGS = unpack(({...}))
Startup:Execute("consts.lua")()

local InstallerUI = {}

-- Prepare the installation UI
function InstallerUI:Prepare()
    local installGui = Instance.new("ScreenGui",_H.Gui:GetProtectedHolder())
    installGui.Name = "Regui"
    local mainContentFrame = Instance.new("Frame",installGui)
    mainContentFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainContentFrame.SizeConstraint = Enum.SizeConstraint.RelativeXY
    mainContentFrame.Size = UDim2.fromScale(0.4, 0.4)
    mainContentFrame.BackgroundColor3 = Color3.new()
end

return InstallerUI