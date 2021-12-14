local Startup,LOCAL_PATH,Orig = unpack(({...}))

local Wrapped = {}

function Wrapped:Set(...)
    Orig:s(...)
end

return Wrapped