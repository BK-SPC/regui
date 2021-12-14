local gui = {}

--https://gist.github.com/jrus/3197011
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function gui:Protect(GuiObject)
	--lazy way to get around this but it works and i dont even think its possible to recursively check anyways as that was patched i think
	--"then name it like 281y31987ra(&U*WDH789AWr870q3wger087adg872gead or something"
	GuiObject.Name = uuid()
end

function gui:GetProtectedHolder()
    return gethui()
end

gui.SW = true

return gui