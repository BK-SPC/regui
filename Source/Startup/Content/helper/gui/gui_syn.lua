local gui = {}

function gui:Protect(GuiObject)
	return syn.protect_gui(GuiObject)
end

local protectedHolder = Instance.new("Folder")
syn.protect_gui(protectedHolder)
protectedHolder.Parent = game:FindService("CoreGui")

function gui:GetProtectedHolder()
    return protectedHolder
end

return gui