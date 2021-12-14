-- luajit

local jsonLib = require("json")
--local minifyLib = require("minify")

local jsonPath = "../Install.json.debug"
local dataPath = "../Install.data.debug"
local dataSrcPath = "../../Source/Data/"
local jsonFileRead = io.open(jsonPath,"rb")
local dataFile = io.open(dataPath,"wb")
local decodedJson = jsonLib.decode(jsonFileRead:read())
local dataContents = ""

for i,installInstruction in pairs(decodedJson) do
	if installInstruction[1] == 1 then
		local file = io.open(dataSrcPath .. installInstruction[2],"rb")
		local data = file:read("*all")
		installInstruction[3] = #data - 1
		dataContents = dataContents .. data
	end
end
local newJson = jsonLib.encode(decodedJson)
dataFile:write(dataContents)
local jsonFileWrite = io.open(jsonPath,"wb")
jsonFileWrite:write(newJson)