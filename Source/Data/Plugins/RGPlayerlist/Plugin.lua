local Args = {...}
local LocalPath = Args[1]
local Io = _H.Io.new(LocalPath)

local DummyPlugin = {
    Storage = {};
    IsEnabled = false;
    Enable = function(self)
        self.IsEnabled = true
        self.Storage.MainGui = _H.Asset:Insert(Io:GetFullPath{"Model","MainGui.rbxm"})[1]
        --_H.Gui:Protect(self.Storage.MainGui)
        self.Storage.MainGui.Parent = game:GetService("CoreGui")
        self.Storage.UpdateBG = _H:Require(LocalPath,"UpdateBG.lua")
        self.Storage.Events = {}
        local OPH = _R.ObjectPoolHandler
        self.Storage.Objects = {
            PlrNoDN = OPH:New(_H.Asset:Insert(Io:GetFullPath{"Model","Player","PlrNoDN.rbxm"})[1]),
            PlrWithDN = OPH:New(_H.Asset:Insert(Io:GetFullPath{"Model","Player","PlrWithDN.rbxm"})[1]),
            Team = OPH:New(_H.Asset:Insert(Io:GetFullPath{"Model","Team","Team.rbxm"})[1]),
            BGStart = OPH:New(_H.Asset:Insert(Io:GetFullPath{"Model","BG","Start.rbxm"})[1]),
            BGMid = OPH:New(_H.Asset:Insert(Io:GetFullPath{"Model","BG","Mid.rbxm"})[1]),
            BGEnd = OPH:New(_H.Asset:Insert(Io:GetFullPath{"Model","BG","End.rbxm"})[1])
        }
        local Config = _R.FeatureHandler:GetPluginSettings()["RGPlayerlist"] or {}
        self.Storage.Plr = "PlrWithDN"
        self.Storage.DontUseDn = Config["Dont Use DisplayNames"]
        if self.Storage.DontUseDn ~= nil then
            if self.Storage.DontUseDn then
                self.Storage.Plr = "PlrNoDN"
            else
                self.Storage.Plr = "PlrWithDN"
            end
        else
            _R.FeatureHandler:SetPluginSetting("RGPlayerlist","Dont Use DisplayNames",false)
            self.Storage.DontUseDn = false
        end

        function self.Storage:ClearList()
            -- Clear the old list
            for _,Child in pairs(self.MainGui.Holder:GetChildren()) do
                if Child:IsA("Frame") then
                    if Child.Name == "TeamItem" then
                        local BG = Child.BGFrame:GetChildren()[1]
                        self.Objects[BG.Name]:Add(BG)
                        self.Objects.Team:Add(Child)
                    elseif Child.Name == "PlayerItem (DontUseDisplayNames)" then
                        local BG = Child.BGFrame:GetChildren()[1]
                        self.Objects[BG.Name]:Add(BG)
                        self.Objects.PlrNoDN:Add(Child)
                    elseif Child.Name == "PlayerItem (UseDisplayNames)" then
                        local BG = Child.BGFrame:GetChildren()[1]
                        self.Objects[BG.Name]:Add(BG)
                        self.Objects.PlrWithDN:Add(Child)
                    end
                end
            end
        end

        function self.Storage:UpdateList()

            self:ClearList()

            local List = {
                Players = {
                    Contents = {}
                }
            }

            local Items = 1

            for _,Player in pairs(game:GetService("Players"):GetPlayers()) do
                if not Player.Team then
                    -- Player has not been assigned to a team
                    table.insert(List.Players.Contents,Player)
                    Items = Items + 1
                else
                    if not List[Player.Team.Name] then
                        local H,S,V = Color3.toHSV(Player.Team.TeamColor.Color)
                        List[Player.Team.Name] = {
                            Contents = {},
                            Color = Color3.fromHSV(H,S,0.5)
                        }
                        Items = Items + 1
                    end
                    table.insert(List[Player.Team.Name].Contents,Player)
                    Items = Items + 1
                end
            end

            if #List.Players.Contents == 0 then
                List.Players = nil
                Items = Items - 1
            end

            local Counter = 0

            for TeamName,Team in pairs(List) do
                Counter = Counter + 1
                local TeamObject = self.Objects.Team:Get()
                TeamObject.Parent = self.MainGui.Holder
                TeamObject.LayoutOrder = Counter
                local BG = "BGMid"
                if Counter == 1 then
                    BG = "BGStart"
                elseif Counter == Items then
                    BG = "BGEnd"
                end
                BG = self.Objects[BG]:Get()
                BG.Parent = TeamObject.BGFrame
                self.UpdateBG:UpdateColors{
                    Object = BG,
                    Color = Team.Color,
                    Transparency = 0.5
                }
                self.UpdateBG:UpdatePosition{
                    Object = BG
                }
                TeamObject.Text.TextArea.Text = TeamName
                for _,Player in pairs(Team.Contents) do
                    Counter = Counter + 1
                    local Plr = self.Plr
                    if Plr == "PlrWithDN" and Player.DisplayName == Player.Name then
                        Plr = "PlrNoDN"
                    end
                    local PlayerObject = self.Objects[Plr]:Get()
                    PlayerObject.Parent = self.MainGui.Holder
                    PlayerObject.LayoutOrder = Counter
                    local BG2 = "BGMid"
                    if Counter == 1 then
                        BG2 = "BGStart"
                    elseif Counter == Items then
                        BG2 = "BGEnd"
                    end
                    BG2 = self.Objects[BG2]:Get()
                    BG2.Parent = PlayerObject.BGFrame
                    self.UpdateBG:UpdateColors{
                        Object = BG2,
                        Color = Team.Color,
                        Transparency = 0.75
                    }
                    self.UpdateBG:UpdatePosition{
                        Object = BG2
                    }
                    if Plr == "PlrNoDN" then
                        PlayerObject.Text.Username.Text = Player.Name
                    else
                        PlayerObject.Text.DisplayName.Text = Player.DisplayName
                        PlayerObject.Text.Username.Text = ("@%s"):format(Player.Name)
                    end
                end
            end
        end

        function self.Storage.OnPlayer(Player)
            self.Storage:UpdateList()
        end

        function self.Storage.OnPlayerRemoving(Player)
            self.Storage:UpdateList()
        end

        table.insert(self.Storage.Events,game:GetService("Players").PlayerAdded:Connect(self.Storage.OnPlayer))
        table.insert(self.Storage.Events,game:GetService("Players").PlayerRemoving:Connect(self.Storage.OnPlayerRemoving))

        self.Storage:UpdateList()
    end;
    Disable = function(self)
        self.IsEnabled = false
        for _,Event in pairs(self.Storage.Events) do
            Event:Disconnect()
        end
        self.Storage.Events = {}
        self.Storage:ClearList()
        for _,Pool in pairs(self.Storage.Objects) do
            Pool:Clean()
        end
        self.Storage.MainGui:Destroy()
    end;
}

return DummyPlugin