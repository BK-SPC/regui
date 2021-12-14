-- luajit

local jsonLib = require("json")
--local minifyLib = require("minify")

local jsonPath = "../Install.json"
local dataPath = "../Install.data"
local dataSrcPath = "../../Source/Data/"
local miniPath = "luaMiniTempDir/"
local jsonFileRead = io.open(jsonPath,"rb")
local dataFile = io.open(dataPath,"wb")
local decodedJson = jsonLib.decode(jsonFileRead:read())
local dataContents = ""

local function processScript(source)
	-- more string.gsub magic lol
	-- removes all "print", "warn", "debug.profile*", and "_ReGui:Log" calls from the install
	-- also replaces all "_ReGui", and "_ReGui.Helper" calls with "_R" and "_H"
	local charset = "[^\"^'^%(^%)]"
	return source:gsub("debug%.profile%l+%(\"" .. charset .. "*\"%)",""):gsub("_ReGui:Log%(\"" .. charset .. "*\"%)",""):gsub("print%(\"" .. charset .. "*\"%)",""):gsub("warn%(\"" .. charset .. "*\"%)",""):gsub("_ReGui%.Helper","_H"):gsub("_ReGui","_R")
end

for i,installInstruction in pairs(decodedJson) do
	if installInstruction[1] == 1 then
		local data
		if installInstruction[2]:find(".json") then
			local file = io.open(dataSrcPath .. installInstruction[2],"rb")
			data = jsonLib.encode(jsonLib.decode(file:read("*all")))
		elseif installInstruction[2]:find(".lua") then
			local luaPath = miniPath .. tostring(i) .. ".lua"
			print(luaPath)
			local file = io.open(luaPath,"rb")
			data = processScript(file:read("*all"))
			file:close()
			print("remove " .. luaPath)
			os.remove(luaPath)
		else
			local file = io.open(dataSrcPath .. installInstruction[2],"rb")
			data = file:read("*all")
		end
		installInstruction[3] = #data - 1
		dataContents = dataContents .. data
	end
end
local newJson = jsonLib.encode(decodedJson)
dataFile:write(dataContents)
local jsonFileWrite = io.open(jsonPath,"wb")
jsonFileWrite:write(newJson)