local http = {}

function http:g(Url)
    return game:HttpGetAsync(Url)
end

function http:p(Url)
    return game:HttpPostAsync(Url)
end

return http