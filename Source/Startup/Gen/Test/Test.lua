a = io.open("../../../../Update/Start.data","rb"):read("*a")
loadstring(
    a:gsub("INIT_END.*","")
)(
    a:sub(
        a:find("INIT_END") + 8,
        #a
    ),
    {
        Debug = true
    }
)

a = readfile("Start.data","rb")
loadstring(
    a:gsub("INIT_END.*","")
)(
    a:sub(
        a:find("INIT_END") + 8,
        #a
    ),
    {
        Debug = true
    }
)