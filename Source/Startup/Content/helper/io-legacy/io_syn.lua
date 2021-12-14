local Io = {}

function Io:r(Path)
    return readfile(Path:gsub("\\","/"))
end

function Io:w(Path,Content)
    return writefile(Path:gsub("\\","/"),Content)
end

function Io:md(Path)
    return makefolder(Path:gsub("\\","/"))
end

function Io:dd(Path)
    return delfolder(Path:gsub("\\","/"))
end

function Io:d(Path)
    return delfile(Path:gsub("\\","/"))
end

function Io:ifi(Path)
    return isfile(Path:gsub("\\","/"))
end

function Io:ifo(Path)
    return isfolder(Path:gsub("\\","/"))
end

function Io:l(Path)
    Path = Path:gsub("\\","/")
    local listTbl = listfiles(Path)
    for i,v in pairs(listTbl) do
        listTbl[i] = v:gsub("\\","/")
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