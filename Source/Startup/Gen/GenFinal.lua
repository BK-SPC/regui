local jsonLib = require("json")

local CLI_ARGS = {...}
print(unpack(CLI_ARGS))
local START_JSON_PATH = CLI_ARGS[1]
local START_DATA_PATH = "../../../Update/" .. CLI_ARGS[2]
local SEPARATOR_CHAR = string.char(1,2,3)

print("reading start.json")
local startJson = jsonLib.decode(io.open(START_JSON_PATH,"rb"):read("*all"))
print("removing " .. START_DATA_PATH)
os.remove(START_DATA_PATH)
print("opening" .. START_DATA_PATH .. "with append binary mode")
local startData = io.open(START_DATA_PATH,"ab")

--https://gist.github.com/yi/01e3ab762838d567e65d

function string.fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

local startTime = os.clock()
print("writing binary")
startJson.InitScr = startJson.InitScr:gsub("0d0a","0a")
startData:write(string.fromhex(startJson.InitScr))
startData:write("INIT_END")
for Path,File in pairs(startJson.Files) do
    File = File:gsub("0d0a","0a")
    Path = Path:gsub("\\","/")
    File = string.fromhex(File)
    print(Path,#File)
    startData:write(Path)
    startData:write(SEPARATOR_CHAR)
    startData:write(#File)
    startData:write(SEPARATOR_CHAR)
    startData:write(File)
end
local msTaken = (os.clock() - startTime) * 1000
print(("done!, took %sms"):format(msTaken))