local Consts = {
    -- gsub pattern for handling "../" correctly as this fails with a lot of exploits
    GSUB_PATH_DDS_PARENT = {"/[^/]/%.%./","/"};
    -- gsub pattern for getting the parent directory
    GSUB_PATH_PARENT = {"%a+%..+",""};
    -- gsub pattern for removing backslashes
    GSUB_PATH_NO_BS = {"\\","/"};
    -- default ui colors for regui
    GUI_DEFAULT_THEME = {
        MAIN_COLOR = Color3.fromRGB(93, 104, 133);
        MAIN_COLOR2 = Color3.fromRGB(105, 117, 149);
        BUTTON_COLOR = Color3.fromRGB(130, 143, 191);
    };
}

return function(DontModEnv)

    if not DontModEnv then
        --Modify the environment to define the consts
        for i,v in pairs(Consts) do
            getfenv()[i] = v
        end
    end

    --Return the consts table
    return Consts

end