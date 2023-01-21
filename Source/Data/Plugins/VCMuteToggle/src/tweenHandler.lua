local Args = { ... }
local LocalPath = Args[1]

local TweenService = game:GetService("TweenService") 

local MUTE_TWEEN_OUT_INFO = TweenInfo.new(
	.05,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

local MUTE_TWEEN_IN_INFO = TweenInfo.new(
	.1,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.In,
	0,
	false,
	0.1
)

local Maid = _H:Require(_H.Path:Join(_R.Directory,"Data","Modules"),"Maid.lua")

local tweenHandler = {}
tweenHandler.__index = tweenHandler

function tweenHandler.new(muteIcon)
	local self = {}
	setmetatable(self, tweenHandler)

	self._maid = Maid.new()

    local ORIGINAL_SIZE = muteIcon.Size
    local BIGGER_SIZE = ORIGINAL_SIZE + UDim2.new(0.018, 0, 0.026, 0)

    local MUTE_TWEEN_OUT_GOAL = {
        Size = BIGGER_SIZE
    }
    local MUTE_TWEEN_IN_GOAL = {
        Size = ORIGINAL_SIZE
    }

    self.muteTweenOut = self._maid:GiveTask(TweenService:Create(
        muteIcon,
        MUTE_TWEEN_OUT_INFO,
        MUTE_TWEEN_OUT_GOAL
    ))
	
    self.muteTweenIn = self._maid:GiveTask(TweenService:Create(
        muteIcon,
        MUTE_TWEEN_IN_INFO,
        MUTE_TWEEN_IN_GOAL
    ))

    return self
end

function tweenHandler:ToggleMute()
    self.muteTweenOut:Play()
	self.muteTweenOut.Completed:Wait()
	self.muteTweenIn:Play()
	self.muteTweenIn.Completed:Wait()
end

function tweenHandler:Destroy()
    self._maid:Destroy()
end

return tweenHandler