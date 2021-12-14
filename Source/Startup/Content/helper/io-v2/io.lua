local Startup,LOCAL_PATH,Orig = unpack(({...}))
Startup:Execute("consts.lua")()

local Io = {}
Io.__index = Io
Io.Cache = {
    Content = {};
    List = {};
    Exists = {
        File = {},
        Folder = {}
    };
};
Io.BaseDir = ""

local function HandlePath(Input)
    Startup:Log("Handle Path",Input)
    if typeof(Input) == "table" then
        local Path = ""
        for i,v in pairs(Input) do
            if i == 1 then
                Path = v
            else
                Path = Path .. "/" .. v
            end
        end
        return Path:gsub(unpack(GSUB_PATH_NO_BS)):gsub(unpack(GSUB_PATH_DDS_PARENT))
    elseif typeof(Input) == "string" then
        return Input:gsub(unpack(GSUB_PATH_NO_BS)):gsub(unpack(GSUB_PATH_DDS_PARENT))
    else
        error("Invalid path given, must be a string or a table")
    end
end

function Io.new(BaseDirectory)
    BaseDirectory = HandlePath(BaseDirectory)
    if BaseDirectory:sub(#BaseDirectory,#BaseDirectory) ~= "/" then
        BaseDirectory = BaseDirectory .. "/"
    end
    local self = {}
    setmetatable(self, Io)

    self.BaseDir = BaseDirectory or ""

    return self
end

function Io:GetFullPath(Path)
    Startup:Log("Get Full Path",Path)
    return self.BaseDir .. HandlePath(Path)
end

function Io:Read(Path)
    Path = self.BaseDir .. HandlePath(Path)
    Startup:Log("Read",Path)
    if not self.Cache.Content[Path] then
        self.Cache.Content[Path] = Orig:r(Path)
    end
    return self.Cache.Content[Path]
end

function Io:Write(Path,Content)
    Path = self.BaseDir .. HandlePath(Path)
    Startup:Log("Write",Path)
    self.Cache.Content[Path] = Content
    local ParentDir = Path:gsub(unpack(GSUB_PATH_PARENT))
    if self.Cache.List[ParentDir] then
        local Filename = Path:gsub(unpack(GSUB_PATH_DDS_PARENT))
        table.insert(self.Cache.List[ParentDir],Filename)
    end
    return Orig:w(Path,Content)
end

function Io:MakeFolder(Path)
    Path = self.BaseDir .. HandlePath(Path)
    Startup:Log("MakeFolder",Path)
    local ParentDir = Path:gsub(unpack(GSUB_PATH_PARENT))
    if self.Cache.List[ParentDir] then
        local Filename = Path:gsub(unpack(GSUB_PATH_DDS_PARENT))
        table.insert(self.Cache.List[ParentDir],Filename)
    end
    return Orig:md(Path)
end

function Io:DeleteFolder(Path)
    Path = self.BaseDir .. HandlePath(Path)
    Startup:Log("DeleteFolder",Path)
    self.Cache.Exists.Folder[Path] = nil
    local ParentDir = Path:gsub(unpack(GSUB_PATH_PARENT))
    if self.Cache.List[ParentDir] then
        local Filename = Path:gsub(unpack(GSUB_PATH_DDS_PARENT))
        for i,v in pairs(self.Cache.List[ParentDir]) do
            if v == Filename then
                table.remove(self.Cache.List[ParentDir],i)
            end
        end
    end
    return Orig:dd(Path)
end

function Io:Delete(Path)
    Path = self.BaseDir .. HandlePath(Path)
    Startup:Log("Delete",Path)
    self.Cache.Exists.File[Path] = nil
    local ParentDir = Path:gsub(unpack(GSUB_PATH_PARENT))
    if self.Cache.List[ParentDir] then
        local Filename = Path:gsub(unpack(GSUB_PATH_DDS_PARENT))
        for i,v in pairs(self.Cache.List[ParentDir]) do
            if v == Filename then
                table.remove(self.Cache.List[ParentDir],i)
            end
        end
    end
    return Orig:d(Path)
end

function Io:IsFile(Path)
    Path = self.BaseDir .. HandlePath(Path)
    Startup:Log("IsFile",Path)
    if not self.Cache.Exists.File[Path] then
        self.Cache.Exists.File[Path] = Orig:ifi(Path)
    end
    return self.Cache.Exists.File[Path]
end

function Io:IsFolder(Path)
    Path = self.BaseDir .. HandlePath(Path)
    Startup:Log("IsFolder",Path)
    if not self.Cache.Exists.Folder[Path] then
        self.Cache.Exists.Folder[Path] = Orig:ifo(Path)
    end
    return self.Cache.Exists.Folder[Path]
end

function Io:ListFiles(Path)
    Path = self.BaseDir .. HandlePath(Path)
    Startup:Log("ListFiles",Path)
    if not self.Cache.List[Path] then
        self.Cache.List[Path] = Orig:l(Path)
    end
    return self.Cache.List[Path]
end

Startup:Log("IO-V2 LOADED")

return Io