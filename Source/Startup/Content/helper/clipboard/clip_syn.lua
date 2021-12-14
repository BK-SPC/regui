local clipboard = {}

function clipboard:s(...)
    setclipboard(...)
end

return clipboard