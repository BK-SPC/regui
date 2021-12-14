local Startup,LOCAL_PATH,Orig = unpack(({...}))

local Wrapped = {
    Cache = {
        Content = {};
        List = {};
        Exists = {
            File = {},
            Folder = {}
        };
    };
}

function Wrapped:Read(Path)
    Startup:Log("Read",Path)
    if not self.Cache.Content[Path] then
        self.Cache.Content[Path] = Orig:r(Path)
    end
    return self.Cache.Content[Path]
end

function Wrapped:Write(Path,Content)
    Startup:Log("Write",Path)
    self.Cache.Content[Path] = Content
    local ParentDir = Path:gsub("%a+%..+","")
    if self.Cache.List[ParentDir] then
        local Filename = Path:gsub(".+/","")
        table.insert(self.Cache.List[ParentDir],Filename)
    end
    return Orig:w(Path,Content)
end

function Wrapped:MakeFolder(Path)
    Startup:Log("MakeFolder",Path)
    local ParentDir = Path:gsub("%a+%..+","")
    if self.Cache.List[ParentDir] then
        local Filename = Path:gsub(".+/","")
        table.insert(self.Cache.List[ParentDir],Filename)
    end
    return Orig:md(Path)
end

function Wrapped:DeleteFolder(Path)
    Startup:Log("DeleteFolder",Path)
    self.Cache.Exists.Folder[Path] = nil
    local ParentDir = Path:gsub("%a+%..+","")
    if self.Cache.List[ParentDir] then
        local Filename = Path:gsub(".+/","")
        for i,v in pairs(self.Cache.List[ParentDir]) do
            if v == Filename then
                table.remove(self.Cache.List[ParentDir],i)
            end
        end
    end
    return Orig:dd(Path)
end

function Wrapped:Delete(Path)
    Startup:Log("Delete",Path)
    self.Cache.Exists.File[Path] = nil
    local ParentDir = Path:gsub("%a+%..+","")
    if self.Cache.List[ParentDir] then
        local Filename = Path:gsub(".+/","")
        for i,v in pairs(self.Cache.List[ParentDir]) do
            if v == Filename then
                table.remove(self.Cache.List[ParentDir],i)
            end
        end
    end
    return Orig:d(Path)
end

function Wrapped:IsFile(Path)
    Startup:Log("IsFile",Path)
    if not self.Cache.Exists.File[Path] then
        self.Cache.Exists.File[Path] = Orig:ifi(Path)
    end
    return self.Cache.Exists.File[Path]
end

function Wrapped:IsFolder(Path)
    Startup:Log("IsFolder",Path)
    if not self.Cache.Exists.Folder[Path] then
        self.Cache.Exists.Folder[Path] = Orig:ifo(Path)
    end
    return self.Cache.Exists.Folder[Path]
end

function Wrapped:ListFiles(Path)
    Startup:Log("ListFiles",Path)
    if not self.Cache.List[Path] then
        self.Cache.List[Path] = Orig:l(Path)
    end
    return self.Cache.List[Path]
end

Startup:Log("IO-LEGACY LOADED")

return Wrapped