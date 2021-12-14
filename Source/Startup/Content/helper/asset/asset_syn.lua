local asset = {}

function asset:g(Path)
    return getsynasset(Path)
end

function asset:i(Path)
    return game:GetObjects(getsynasset(Path))
end

return asset