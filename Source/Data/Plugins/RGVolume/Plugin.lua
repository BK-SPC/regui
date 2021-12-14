local Args = {...}
local LocalPath = Args[1]
local Io = _H.Io.new(LocalPath)

--Services 
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

--Modules
local Lerp = _H:Require(_H.Path:Join(_ReGui.Directory,"Data","Modules"),"Lerp.lua")

--Constants
local ENCRYPTED_ASSET_NAME = "00000000"

local VolPlugin
VolPlugin = {
    Storage = {};
    IsEnabled = false;
    Enable = function(self)
        self.IsEnabled = true
        self.Storage.IsLAltHeld = false
        self.Storage.IsShiftHeld = false
        self.Storage.Events = {}
        self.Storage.VolMod = 0
        self.Storage.LastModified = 0
        self.Storage.LastAudioInfoUpdate = 0
        self.Storage.CurAudio = nil
        self.Storage.GUI = _H.Asset:Insert(Io:GetFullPath{"MainVolGui.rbxm"})[1]
        _H.Gui:Protect(self.Storage.GUI)
        self.Storage.GUI.Parent = game:GetService("CoreGui")
        self.Storage.Sounds = Io:ListFiles("Sounds")
        local Config = _R.FeatureHandler:GetPluginSettings()["RGVolume"] or {}
        local Sound = Config.Sound
        if not Sound then
            Sound = "Sine.ogg"
            _R.FeatureHandler:SetPluginSetting("RGVolume","Sound",Sound)
        end
        self.Storage.GUI.VolumeChanged.SoundId = _H.Asset:Get(Io:GetFullPath{"Sounds",Sound})
        self.Storage.GUI.VolumeFrame.Speaker.Image = _H.Asset:Get(Io:GetFullPath{"Icons.png"})
        self.Storage.GUI.VolumeFrame.Speaker.Blur.Image = _H.Asset:Get(Io:GetFullPath{"BluredIcons.png"})
        self.Storage.ProductInfoCache = _R.CacheHandler:Get("ProductInfoCache")
        self.Visualizer = 0
        self.FrameYSize = 0
        
        self.Storage.Stages = {
            -- Muted Icon
            {
                -1,
                4
            },
            -- 1 Bar Icon
            {
                0,
                1
            },
            -- 2 Bar Icon
            {
                4,
                2
            },
            -- 3 Bar Icon
            {
                7,
                3
            }
        }

        self.Storage.StageOffsets = {
            Vector2.new(0,0),
            Vector2.new(512,0),
            Vector2.new(0,512),
            Vector2.new(512,512)
        }
        function self.Storage:GetStage(Value)
            debug.profilebegin("RGVolumeGetState")
            local Stage = 1
            for _,StageItem in pairs(self.Stages) do
                if Value > StageItem[1] / 10 then
                    Stage = StageItem[2]
                else
                    break
                end
            end
            debug.profileend("RGVolumeGetState")
            return Stage
        end

        function self.Storage:UpdateIcon()
            debug.profilebegin("RGVolumeUpdateIcon")
            local CurStage = self:GetStage(UserGameSettings.MasterVolume)
            local Offset = self.StageOffsets[CurStage]
            self.GUI.VolumeFrame.Speaker.ImageRectOffset = Offset
            self.GUI.VolumeFrame.Speaker.Blur.ImageRectOffset = Offset / 4
            debug.profileend("RGVolumeUpdateIcon")
        end

        function self.Storage:UpdateBar()
            debug.profilebegin("RGVolumeUpdateBar")
            self.GUI.VolumeFrame.VolumeBar.Fill.Size = UDim2.new(UserGameSettings.MasterVolume,0,1,0)
            debug.profileend("RGVolumeUpdateBar")
        end

        self.Storage.Fade = {}

        for _,Dec in pairs(self.Storage.GUI:GetDescendants()) do
            if Dec:IsA("Frame") then
                self.Storage.Fade[Dec] = {Dec,{Dec.BackgroundTransparency},{"BackgroundTransparency"}}
            elseif Dec:IsA("TextButton") or Dec:IsA("TextLabel") then
                self.Storage.Fade[Dec] = {Dec,{Dec.TextTransparency,Dec.TextStrokeTransparency,Dec.BackgroundTransparency},{"TextTransparency","TextStrokeTransparency","BackgroundTransparency"}}
            elseif Dec:IsA("ImageLabel") or Dec:IsA("ImageButton") then
                self.Storage.Fade[Dec] = {Dec,{Dec.ImageTransparency,Dec.BackgroundTransparency},{"ImageTransparency","BackgroundTransparency"}}
            end
        end

        function self.Storage:UpdateFade(DeltaTime)
            debug.profilebegin("RGVolumeUpdateFade")
            local Goal = math.clamp(((os.clock() - self.LastModified) - 1)*4,0,1)
            for _,FadeItem in pairs(self.Fade) do
                for Index,OGValue in pairs(FadeItem[2]) do
                    FadeItem[1][FadeItem[3][Index]] = Lerp(
                        FadeItem[1][FadeItem[3][Index]],
                        Lerp(
                            OGValue,
                            1,
                            Goal
                        ),
                        DeltaTime*25
                    )
                end
            end
            self.GUI.Enabled = Goal < 0.99
            if not self.GUI.Enabled then
                self.FrameYSize = 0
            end
            debug.profileend("RGVolumeUpdateFade")
        end

        self.Storage.Events.InputBeganEvent = UserInputService.InputBegan:Connect(function(Input,GameProcessed)
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode.LeftAlt then
                _ReGui:Log("Left Alt Held")
                self.Storage.IsLAltHeld = true
            elseif Input.UserInputType == Enum.UserInputType.Keyboard and (Input.KeyCode == Enum.KeyCode.Equals or Input.KeyCode == Enum.KeyCode.Minus) and self.Storage.IsLAltHeld then
                if Input.KeyCode == Enum.KeyCode.Equals then
                    _ReGui:Log("VolMod + 1")
                    self.Storage.VolMod = self.Storage.VolMod + 1
                else
                    _ReGui:Log("VolMod - 1")
                    self.Storage.VolMod = self.Storage.VolMod - 1
                end
            elseif Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode.LeftShift then
                self.Storage.IsShiftHeld = true
            end
        end)

        self.Storage.Events.InputEndedEvent = UserInputService.InputEnded:Connect(function(Input,GameProcessed)
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode.LeftAlt then
                _ReGui:Log("Left Alt Released")
                self.Storage.IsLAltHeld = false
            elseif Input.UserInputType == Enum.UserInputType.Keyboard and (Input.KeyCode == Enum.KeyCode.Equals or Input.KeyCode == Enum.KeyCode.Minus) then
                if self.Storage.IsLAltHeld then
                    if Input.KeyCode == Enum.KeyCode.Equals then
                        _ReGui:Log("VolMod - 1")
                        self.Storage.VolMod = self.Storage.VolMod - 1
                    else
                        _ReGui:Log("VolMod + 1")
                        self.Storage.VolMod = self.Storage.VolMod + 1
                    end
                else
                    self.Storage.VolMod = 0
                    _ReGui:Log("VolMod = 0")
                end
            elseif Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode.LeftShift then
                self.Storage.IsShiftHeld = false
            end
        end)

        function self.Storage:IsGlobal(Sound)
            return not (Sound.Parent:IsA("BasePart") or Sound.Parent:IsA("Attachment"))
        end

        function self.Storage:GetId(AssetString)
            local result,_ = AssetString:gsub("[^0-9]","")
            return tonumber(result)
        end
        
        function self.Storage:GetCurAudio()
            debug.profilebegin("RGVolumeGetCurAudio")
            self.LastAudioInfoUpdate = os.clock()
            local CurBestMatch = nil
            for _,Sound in pairs(self.KnownSounds) do
                if Sound and Sound.Playing and self:IsGlobal(Sound) then
                    if CurBestMatch then
                        if (Sound.PlaybackLoudness + 100) * Sound.Volume > (CurBestMatch.PlaybackLoudness + 100) * CurBestMatch.Volume then
                            CurBestMatch = Sound
                        end
                    else
                        CurBestMatch = Sound
                    end
                end
            end
            debug.profileend("RGVolumeGetCurAudio")
            if CurBestMatch then
                local Id = self:GetId(CurBestMatch.SoundId)
                local ProductInfo = self.ProductInfoCache:GetItem(Id)
                if not ProductInfo then
                    ProductInfo = MarketplaceService:GetProductInfo(Id,Enum.InfoType.Asset)
                    self.ProductInfoCache:RegisterItem(Id,ProductInfo)
                end
                return {
                    Object = CurBestMatch,
                    Id = Id,
                    ProductInfo = self.ProductInfoCache:GetItem(Id)
                }
            end
            debug.profileend("RGVolumeGetCurAudio")
            return nil
        end

        self.Storage.Events.OnRender = RunService.RenderStepped:Connect(function(DeltaTime)
            debug.profilebegin("RGVolumeRender")
            if self.Storage.VolMod ~= 0 then
                self.Storage.LastModified = os.clock()
            end
            self.Storage.VolMod = math.clamp(self.Storage.VolMod,-1,1)
            local Mod = self.Storage.VolMod
            if not self.Storage.IsShiftHeld then
                Mod = Mod / 1.5
            else
                Mod = Mod * 1.5
            end
            UserGameSettings.MasterVolume = math.clamp(UserGameSettings.MasterVolume + (Mod * DeltaTime),0,1)
            if self.Storage.VolMod ~= 0 then
                if not self.Storage.GUI.VolumeChanged.Playing then
                    self.Storage.GUI.VolumeChanged:Play()
                end
            else
                if self.Storage.GUI.VolumeChanged.Playing then
                    self.Storage.GUI.VolumeChanged:Stop()
                end
            end
            self.Storage:UpdateIcon()
            self.Storage:UpdateBar()
            self.Storage:UpdateFade(DeltaTime)
            if self.Storage.GUI.Enabled and os.clock() - self.Storage.LastAudioInfoUpdate > 0.5 then
                coroutine.resume(coroutine.create(function()
                    self.Storage.CurAudio = self.Storage:GetCurAudio()
                    self.Storage.GUI.VolumeFrame.DetectedSongTitle.Text = self.Storage.CurAudio.ProductInfo.Name
                    -- Alternatively 'game:GetService("ContentProvider"):ListEncryptedAssets()' could be used for this
                    if self.Storage.CurAudio.ProductInfo.Name == ENCRYPTED_ASSET_NAME then
                        self.Storage.GUI.VolumeFrame.DetectedSongTitle.Text = "Encrypted Asset"
                    end
                    self.Storage.GUI.VolumeFrame.DetectedSongId.Text = ("(%s)"):format(tostring(self.Storage.CurAudio.Id))
                end))
            end
            if self.Storage.CurAudio then
                self.Visualizer = Lerp(self.Visualizer, self.Storage.CurAudio.Object.PlaybackLoudness / 350, DeltaTime * 25)
                if self.Storage.GUI.Enabled then
                    self.Storage.GUI.VolumeFrame.Speaker.Blur.ImageTransparency = (self.Visualizer * -1) + 1
                end
            else
                self.Visualizer = 0
            end
            self.Storage.GUI.VolumeFrame.CopyIdButton.Visible = self.Storage.CurAudio ~= nil
            self.Storage.GUI.VolumeFrame.DetectedSongId.Visible = self.Storage.CurAudio ~= nil
            self.Storage.GUI.VolumeFrame.DetectedSongTitle.Visible = self.Storage.CurAudio ~= nil
            self.FrameYSize = Lerp(self.FrameYSize,self.Storage.GUI.VolumeFrame.List.AbsoluteContentSize.Y, DeltaTime * 10)
            self.Storage.GUI.VolumeFrame.Size = UDim2.new(0.4,0,0.05,self.FrameYSize)
            debug.profileend("RGVolumeRender")
        end)

        self.Storage.KnownSounds = {}

        local function OnNewDec(Dec)
            if Dec:IsA("Sound") then
                self.Storage.KnownSounds[Dec] = Dec
            end
        end

        local function DisposeDec(Dec)
            if Dec:IsA("Sound") then
                if self.Storage.CurAudio and self.Storage.CurAudio.Object == Dec then
                    self.Storage.CurAudio = nil
                end
                self.Storage.KnownSounds[Dec] = nil
            end
        end

        self.Storage.Events.OnDecAdd = game.DescendantAdded:Connect(OnNewDec)
        self.Storage.Events.OnDecRem = game.DescendantRemoving:Connect(DisposeDec)

        self.Storage.Events.Copy = self.Storage.GUI.VolumeFrame.CopyIdButton.MouseButton1Up:Connect(function()
            _H.Clipboard:Set(self.Storage.CurAudio.Object.SoundId)
            game:FindService('StarterGui'):SetCore('SendNotification', {
                Title = 'ReGui Audio Controls',
                Text = 'Copied to clipboard',
                Icon = self.Meta.Thumb.StaticThumb,
                Duration = 5,
            })
        end)

        self.Storage.Events.MouseMoved = self.Storage.GUI.VolumeFrame.MouseMoved:Connect(function()
            if UserInputService.MouseBehavior == Enum.MouseBehavior.Default then
                self.Storage.LastModified = os.clock()
            end
        end)

        for _,Dec in pairs(game:GetDescendants()) do
            OnNewDec(Dec)
        end
        
    end;
    
    Disable = function(self)
        self.IsEnabled = false
        self.Storage.IsLAltHeld = false
        self.Storage.IsShiftHeld = false
        self.Storage.VolMod = 0
        for _,Event in pairs(self.Storage.Events) do
            Event:Disconnect()
        end
        self.Storage.Events = {}
        self.Storage.KnownSounds = {}
        self.Storage.GUI:Destroy()
    end;
}

return VolPlugin