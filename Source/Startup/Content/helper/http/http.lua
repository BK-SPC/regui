local Startup,LOCAL_PATH,Orig = unpack(({...}))

local HttpService = game:GetService("HttpService")
local Wrapped = {}

function Wrapped:Get(Url,AutoDecode)
    Startup:Log("GET:/" .. Url)
    local Response = Orig:g(Url)
	if AutoDecode then
		Response = self:JSONDecode(Response)
	end
    return Response
end

function Wrapped:Post(Url,Body)
    Startup:Log("POST:/" .. Url)
    return Orig:p(Url)
end

function Wrapped:JSONDecode(...)
    return HttpService:JSONDecode(...)
end

function Wrapped:JSONEncode(...)
    return HttpService:JSONEncode(...)
end

return Wrapped