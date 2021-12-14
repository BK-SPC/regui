local asset = {}

function asset:g(Path)
    return getcustomasset(Path)
end

function asset:i(Path)
    return game:GetObjects(getcustomasset(Path))
end

return asset