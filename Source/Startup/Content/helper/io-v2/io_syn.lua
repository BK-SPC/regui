local Startup,LOCAL_PATH = unpack(({...}))
Startup:Execute("consts.lua")()

local Io = {}

function Io:r(Path)
    return readfile(Path)
end

function Io:w(Path,Content)
    return writefile(Path,Content)
end

function Io:md(Path)
    return makefolder(Path)
end

function Io:dd(Path)
    return delfolder(Path)
end

function Io:d(Path)
    return delfile(Path)
end

function Io:ifi(Path)
    return isfile(Path)
end

function Io:ifo(Path)
    return isfolder(Path)
end

function Io:l(Path)
    local listTbl = listfiles(Path)
    for i,v in pairs(listTbl) do
        listTbl[i] = v:gsub(unpack(GSUB_PATH_NO_BS))
        if listTbl[i]:sub(#listTbl[i],#listTbl[i]) == "/" then
            listTbl[i] = listTbl[i]:sub(2,#listTbl[i])
        end
        if not listTbl[i]:find(Path) then
            if Path:sub(#Path,#Path) == "/" then
                listTbl[i] = ("%s%s"):format(Path,listTbl[i])
            else
                listTbl[i] = ("%s/%s"):format(Path,listTbl[i])
            end
        end
    end
    return listTbl
end

return Io