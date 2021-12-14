local Startup,LOCAL_PATH,Orig = unpack(({...}))

local asset = {}

function asset:Get(Path)
	--Automatically removes "../" using string.gsub magic (that took me longer to figure how to use than it should of) as it is sometimes unsupported
	Path = Path:gsub("/[^/^\\^%.]+/%.%./","/"):gsub("\\","/")
    return Orig:g(Path)
end

function asset:Insert(Path)
	--Automatically removes "../" using string.gsub magic (that took me longer to figure how to use than it should of) as it is sometimes unsupported
	Path = Path:gsub("/[^/^\\^%.]+/%.%./","/"):gsub("\\","/")
    return Orig:i(Path)
end

return asset