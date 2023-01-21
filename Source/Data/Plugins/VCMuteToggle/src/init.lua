local Args = {...}
local LocalPath = Args[1]

local VoiceChatInternal = game:GetService("VoiceChatInternal")
local ContextActionService = game:GetService("ContextActionService")

local TOGGLE_KEY = Enum.KeyCode.V
local MUTE_ICON = _H.Asset:Get(_H.Path:Join(LocalPath, "../assets", "textures", "mic_mute.png"))
local UNMUTE_ICON = _H.Asset:Get(_H.Path:Join(LocalPath, "../assets", "textures", "mic_unmute.png"))

local Maid = _H:Require(_H.Path:Join(LocalPath, "lib"),"Maid.lua")

local uiHandler = _H:Require(_H.Path:Join(LocalPath),"uiHandler.lua")

local VrcMute = {}
VrcMute.__index = VrcMute

function VrcMute.new()
	local self = {}
	setmetatable(self, VrcMute)
	
	self._maid = Maid.new()

	self._action = tostring(math.round(os.clock() + math.random(-10000, 10000))) .. "_VRC-muteMic"

	if VoiceChatInternal.VoiceChatState == Enum.VoiceChatState.Joined then
		self:Initialize()
	else
		self._maid:GiveTask(function()
			self._destroyed = true
		end)

		task.spawn(function()
			repeat
				task.wait()
			until VoiceChatInternal.VoiceChatState == Enum.VoiceChatState.Joined or self._destroyed
			
			if self._destroyed then
				return
			end

			self:Initialize()
		end)
	end

	return self
end

function VrcMute:Initialize()
	self._mute = VoiceChatInternal:IsPublishPaused()
	self._group = VoiceChatInternal:GetGroupId()
	self._muteIcon = self._maid:GiveTask(uiHandler.new(self._mute))

	ContextActionService:BindAction(self._action, function(_, state, _)
		if state == Enum.UserInputState.Begin then return end
		
		if VoiceChatInternal.VoiceChatState == Enum.VoiceChatState.Joined then
			self._mute = not self._mute
			
			VoiceChatInternal:Leave()
			--repeat task.wait() until VoiceChatInternal.VoiceChatState ~= Enum.VoiceChatState.Ended
			VoiceChatInternal:JoinByGroupIdToken(self._group, self._mute)
			
			self._muteIcon:ToggleMute()
			if not self._mute then
				self._muteIcon.muteIcon.Image = UNMUTE_ICON
				self._muteIcon.unmuteSound:Play()
			else
				self._muteIcon.muteIcon.Image = MUTE_ICON
				self._muteIcon.muteSound:Play()
			end
		else
			_R:Log("Client is still trying to join voice chat")
			_R:Log(VoiceChatInternal.VoiceChatState)
		end
	end, false, TOGGLE_KEY)

	self._maid:GiveTask(function()
		ContextActionService:UnbindAction(self._action)
	end)
end

function VrcMute:Destroy()
	self._maid:Destroy()
end

return VrcMute