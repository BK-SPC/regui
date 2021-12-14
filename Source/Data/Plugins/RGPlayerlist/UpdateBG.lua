local UpdateBG = {

    UpdateColorFunctions = {
        BGStart = function(Options)
            Options.Object.Lower.BackgroundTransparency = Options.Transparency
            Options.Object.Upper.RoundedEdge.BackgroundTransparency = Options.Transparency
            Options.Object.Upper.RoundedEdge.BackgroundColor3 = Options.Color
            Options.Object.Lower.BackgroundColor3 = Options.Color
        end,
    
        BGMid = function(Options)
            Options.Object.BackgroundTransparency = Options.Transparency
            Options.Object.BackgroundColor3 = Options.Color
        end,
    
        BGEnd = function(Options)
            Options.Object.Lower.BackgroundTransparency = Options.Transparency
            Options.Object.Upper.RoundedEdge.BackgroundTransparency = Options.Transparency
            Options.Object.Upper.RoundedEdge.BackgroundColor3 = Options.Color
            Options.Object.Lower.BackgroundColor3 = Options.Color
        end
    },

    UpdatePositionFunctions = {
        BGStart = function(Options)
            local HalfOffset = math.floor(Options.Object.AbsoluteSize.Y/2)
            Options.Object.Upper.Size = UDim2.new(1,0,0,HalfOffset)
            Options.Object.Lower.Size = UDim2.new(1,0,0,HalfOffset)
            Options.Object.Lower.Position = UDim2.new(0,0,0,HalfOffset)
        end,
    
        BGMid = function(Options)
    
        end,
    
        BGEnd = function(Options)
            local HalfOffset = math.floor(Options.Object.AbsoluteSize.Y/2)
            Options.Object.Lower.Size = UDim2.new(1,0,0,HalfOffset)
            Options.Object.Upper.Size = UDim2.new(1,0,0,HalfOffset)
            Options.Object.Upper.Position = UDim2.new(0,0,0,HalfOffset)
        end
    },
    
    UpdateColors = function(self,Options)
        if typeof(Options) == "table" then
            if Options.Object then
                if self.UpdateColorFunctions[Options.Object.Name] then
                    print("UpdateBG: Applying Defaults")
                    Options.Transparency = Options.Transparency or 0.5
                    Options.Color = Options.Color or Color3.fromRGB(70, 75, 86)
                    self.UpdateColorFunctions[Options.Object.Name](Options)
                else
                    error("Options.Object is not a valid BG")
                end
            else
                error("Options.Object is not specified")
            end
        else
            error("Options dictionary is not specified")
        end
    end,

    UpdatePosition = function(self,Options)
        if typeof(Options) == "table" then
            if Options.Object then
                if self.UpdatePositionFunctions[Options.Object.Name] then
                    self.UpdatePositionFunctions[Options.Object.Name](Options)
                else
                    error("Options.Object is not a valid BG")
                end
            else
                error("Options.Object is not specified")
            end
        else
            error("Options dictionary is not specified")
        end
    end
}

return UpdateBG