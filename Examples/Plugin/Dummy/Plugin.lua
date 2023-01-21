local Args = {...}
local LocalPath = Args[1]

local DummyPlugin = {
    Storage = {};
    IsEnabled = false;
    Enable = function(self)
        self.IsEnabled = true
        _ReGui:Log("DummyPlugin: Enabled")
    end;
    Disable = function(self)
        self.IsEnabled = false
        _ReGui:Log("DummyPlugin: Disabled")
    end;
}

return DummyPlugin