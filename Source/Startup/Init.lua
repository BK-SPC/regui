-- Constants

local STARTUP_CONTENT,LAUNCH_ARGS = unpack(({...}))
LAUNCH_ARGS = LAUNCH_ARGS or {}
LAUNCH_ARGS.Debug = LAUNCH_ARGS.Debug or _G.RGDebug

local Startup = {
    Files = {

    };
    Log = function(self,...)
        print(...)
    end;
}

function Startup:Read(Path)
    Startup:Log("Startup:Read",Path)
    return self.Files[Path]
end

function Startup:Execute(Path,...)
    Startup:Log("Startup:Execute",Path)
    return loadstring(self:Read(Path),Path)(self,Path:gsub("%a+%..+",""),...)
end

function Startup:Write(Path,Content)
    Startup:Log("Startup:Write",Path)
    self.Files[Path] = Content
end

if not LAUNCH_ARGS.Debug then
    Startup.Log = function() end
else
    Startup:Log("Debuging is enabled!")
end
local SEPARATOR_CHAR = string.char(1,2,3)
local MODE_FILEPATH = 1
local MODE_FILESIZE = 2
local MODE_FILECONTENT = 3

-- Decode the Startup stuff

Startup:Log("Decoding Startup stuff")

local offset = 0
local mode = 1
local filePath = ""
local fileSize = ""
local fileContent = ""

Startup:Log(("Size: %sb"):format(#STARTUP_CONTENT))

while offset <= #STARTUP_CONTENT do
    if STARTUP_CONTENT:sub(offset,offset + (#SEPARATOR_CHAR - 1)) == SEPARATOR_CHAR then
        mode = mode + 1
        offset = offset + #SEPARATOR_CHAR
        if mode == MODE_FILESIZE then
            Startup:Log("GOT PATH:",filePath)
        elseif mode == MODE_FILECONTENT then
            Startup:Log("GOT SIZE:",fileSize)
        end
    else
        local currentChar = STARTUP_CONTENT:sub(offset,offset)
        if mode == MODE_FILEPATH then
            filePath = filePath .. currentChar
            offset = offset + 1
        elseif mode == MODE_FILESIZE then
            fileSize = fileSize .. currentChar
            offset = offset + 1
        elseif mode == MODE_FILECONTENT then
            local size = tonumber(fileSize)
            fileContent = STARTUP_CONTENT:sub(offset,offset + size - 1)
            Startup:Write(filePath,fileContent)
            --Startup:Log("GOT CONTENT:",string.format("%q",fileContent))
            offset = offset + size
            filePath = ""
            fileSize = ""
            fileContent = ""
            mode = MODE_FILEPATH
        else
            Startup:Log("INVALID_MODE",mode)
        end
    end
end

Startup:Log("Decoded Startup stuff")

Startup:Execute("run.lua",LAUNCH_ARGS)