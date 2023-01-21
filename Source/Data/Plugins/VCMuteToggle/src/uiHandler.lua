local Args = { ... }
local LocalPath = Args[1]

local MUTE_ICON = _H.Asset:Get(_H.Path:Join(LocalPath, "../assets", "textures", "mic_mute.png"))
local UNMUTE_ICON = _H.Asset:Get(_H.Path:Join(LocalPath, "../assets", "textures", "mic_unmute.png"))
local MUTE_SOUND = _H.Asset:Get(_H.Path:Join(LocalPath, "../assets", "sound", "mic_mute.ogg"))
local UNMUTE_SOUND = _H.Asset:Get(_H.Path:Join(LocalPath, "../assets", "sound", "mic_unmute.ogg"))

local Maid = _H:Require(_H.Path:Join(LocalPath, "lib"),"Maid.lua")

local tweenHandler = _H:Require(_H.Path:Join(LocalPath), "tweenHandler.lua")

local uiHandler = {}
uiHandler.__index = uiHandler

function uiHandler.new(muted)
	local self = {}
	setmetatable(self, uiHandler)

	self._maid = Maid.new()

	self._screenGui = self._maid:GiveTask(Instance.new("ScreenGui"))
	self.muteIcon = self._maid:GiveTask(Instance.new("ImageLabel", self._screenGui))

	self._uiAspectRatioConstraint = self._maid:GiveTask(Instance.new("UIAspectRatioConstraint", self.muteIcon))
	self.muteSound = self._maid:GiveTask(Instance.new("Sound", self.muteIcon))
	self.unmuteSound = self._maid:GiveTask(Instance.new("Sound", self.muteIcon))

	self.muteIcon.Position = UDim2.new(0.2, 0, 0.9, 0)
	self.muteIcon.Size = UDim2.new(0.04, 0, 0.08, 0)
	self.muteIcon.AnchorPoint = Vector2.new(0.5, 1)
	self.muteIcon.BackgroundTransparency = 1
	
	if muted then
		self.muteIcon.Image = MUTE_ICON
	else
		self.muteIcon.Image = UNMUTE_ICON
	end

	self._uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height

	self.muteSound.SoundId = MUTE_SOUND
	self.unmuteSound.SoundId = UNMUTE_SOUND

	_H.Gui:Protect(self._screenGui)
	self._screenGui.Parent = game:GetService("CoreGui")

	self.tweenHandler = self._maid:GiveTask(tweenHandler.new(self.muteIcon))

	return self
end

function uiHandler:ToggleMute()
	self.tweenHandler:ToggleMute()
end

function uiHandler:Destroy()
	self._maid:Destroy()
end

return uiHandler
