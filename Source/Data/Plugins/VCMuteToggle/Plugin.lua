local Args = {...}
local LocalPath = Args[1]

--Modules
local VrcMute = _H:Require(_H.Path:Join(LocalPath,"src"),"init.lua")

local VrcMutePlugin
VrcMutePlugin = {
    Storage = {};
    IsEnabled = false;
    Enable = function(self)
        self.IsEnabled = true
		self.Mute = VrcMute.new()
    end;
    
    Disable = function(self)
        self.IsEnabled = false
		self.Mute:Destroy()
		self.Mute = nil
    end;
}

return VrcMutePlugin