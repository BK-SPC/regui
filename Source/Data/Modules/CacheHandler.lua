local HttpService = game:GetService("HttpService")

local CacheHandler = {}

local Io = _H.Io.new({_R.Directory,"Cache"})

if not Io:IsFolder("") then
    Io:MakeFolder("")
end

function CacheHandler:Get(CacheName)
    local ReturnedCache = {
        Storage = {
            Contents = {}
        }
    }

    local CacheDataPath = CacheName .. ".json.deflate"
    
    if Io:IsFile(CacheDataPath) then
        local Start = os.clock()
        ReturnedCache.Storage.Contents = HttpService:JSONDecode(_ReGui.LibDeflate:DecompressDeflate(Io:Read(CacheDataPath)))
        _R:Log("Decompressed Cache, Took:" .. tostring(math.floor((os.clock()-Start)*1000)) .. " MS")
    end

    function ReturnedCache:GetItem(Key)
        return self.Storage.Contents[tostring(Key)]
    end

    function ReturnedCache:RegisterItem(Key,Value)
        self.Storage.Contents[tostring(Key)] = Value
        local Start = os.clock()
        Io:Write(CacheDataPath,_ReGui.LibDeflate:CompressDeflate(HttpService:JSONEncode(self.Storage.Contents)))
        _R:Log("Compressed Cache, Took:" .. tostring(math.floor((os.clock()-Start)*1000)) .. " MS")
    end

    return ReturnedCache
end

return CacheHandler