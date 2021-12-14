local path = {}

function path:Join(...)
	local Vars = {...}
	local Path = table.concat(Vars,"/"):gsub("/%a+/%.%./","/"):gsub("\\","/")
	return Path
end

return path