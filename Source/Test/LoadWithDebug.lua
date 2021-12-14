_G.RGDebug = true
StartData = game:HttpGet('https://raw.githubusercontent.com/BK-SPC/regui/main/Update/Start.data.debug')
loadstring(
    StartData:gsub("INIT_END.*","")
)(
    StartData:sub(
        StartData:find("INIT_END") + 8,
        #StartData
    ),
    {
        Debug = true
    }
)