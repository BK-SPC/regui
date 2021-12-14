local Startup,LOCAL_PATH,Helpers = unpack(({...}))
Startup:Execute("consts.lua")()

local PaletteManager = {}

function PaletteManager:GetTheme()
    return GUI_DEFAULT_PALETTE
end

return PaletteManager