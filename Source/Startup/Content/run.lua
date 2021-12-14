local Startup,LOCAL_PATH,LAUNCH_ARGS = unpack(({...}))

local Exploit = Startup:Execute("lib/getExploit.lua",LAUNCH_ARGS):Get()
local Helpers = Startup:Execute("lib/helperLoader.lua",Exploit)

local ReguiEnv = {
	GithubUrl = "https://raw.githubusercontent.com/BK-SPC/regui/main";
	Directory = "ReGUI-BKSPC-V1";
    Helper = Helpers;
    Exploit = Exploit;
	Log = function(self,...)
		if _G.RGDebug then
			print(...)
		end
	end;
	Run = function(self)
        print(typeof(_H.Require),typeof(_H.Path.Join))
		_H:Require(_H.Path:Join(self.Directory,"Data"),"Main.lua")
	end;
	MakeInstallGui = function(self)
		local function uuid()
			local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
			return string.gsub(template, '[xy]', function (c)
				local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
				return string.format('%x', v)
			end)
		end
		local InstallingGui = Instance.new("ScreenGui")
		InstallingGui.Name = uuid()
		InstallingGui.IgnoreGuiInset = true
		local MainWindow = Instance.new("Frame",InstallingGui)
		MainWindow.Name = "MainWindow"
		MainWindow.BackgroundColor3 = Color3.fromRGB(70, 75, 86)
		MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
		MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
		MainWindow.Size = UDim2.new(0.7, 0, 0.4, 0)
		MainWindow.SizeConstraint = Enum.SizeConstraint.RelativeYY
		local UICorner = Instance.new("UICorner",MainWindow)
		UICorner.CornerRadius = UDim.new(0.05, 0)
		local TopBar = Instance.new("Frame",MainWindow)
		TopBar.Name = "TopBar"
		TopBar.BackgroundColor3 = Color3.fromRGB(58.5, 63, 72)
		TopBar.Size = UDim2.new(1, 0, 0.05, 0)
		TopBar.BorderSizePixel = 0
		local Title = Instance.new("TextLabel",TopBar)
		Title.Name = "Title"
		Title.Text = "ReGui Installer"
		Title.BackgroundTransparency = 1
		Title.Size = UDim2.new(1, 0, 1, 0)
		Title.TextScaled = true
		Title.TextColor3 = Color3.new(1, 1, 1)
		local Status = Instance.new("TextLabel",MainWindow)
		Status.Name = "Status"
		Status.Text = ""
		Status.TextScaled = true
		Status.BackgroundTransparency = 1
		Status.AnchorPoint = Vector2.new(0.5, 0.5)
		Status.Position = UDim2.new(0.5, 0, 0.5, 0)
		Status.Size = UDim2.new(1, 0, 0.05, 0)
		Status.TextColor3 = Color3.new(1, 1, 1)
		return InstallingGui
	end;
	Update = function(self,Force)
		--//Check for the ReGUI-BKSPC-V1
		local InstallingGui = self:MakeInstallGui()
		self.Helper.Gui:Protect(InstallingGui)
		InstallingGui.Parent = game:GetService("CoreGui")
		local ReGuiExists = self.Helper.Io:IsFolder(self.Directory)
		local UpdateNeeded = false
		local Path = self.Helper.Path
		if not ReGuiExists then
			--//Create the ReGUI-BKSPC-V1 directory
			InstallingGui.MainWindow.Status.Text = ("Creating the %s directory"):format(self.Directory)
			self.Helper.Io:MakeFolder(self.Directory)
			--//Write LocalVersion.txt
			InstallingGui.MainWindow.Status.Text = "Writing LocalVersion.txt"
			self.Helper.Io:Write(
				Path:Join(self.Directory,"LocalVersion.txt"),
				Startup:Read("latestVer")
			)
			--//Create the ThirdPartyPlugins directory
			InstallingGui.MainWindow.Status.Text = "Creating the ThirdPartyPlugins directory"
			self.Helper.Io:MakeFolder(Path:Join(self.Directory,"ThirdPartyPlugins"))
		end
		InstallingGui.MainWindow.Status.Text = "Reading LocalVersion.txt"
		local LocalVersion = self.Helper.Io:Read(
			Path:Join(self.Directory,"LocalVersion.txt")
		)
		InstallingGui.MainWindow.Status.Text = "Fetching LatestVersion.txt"
		local LatestVersion = Startup:Read("latestVer")
		self:Log(LocalVersion,LatestVersion)
		UpdateNeeded = (LocalVersion ~= LatestVersion) or (not ReGuiExists) or Force
		if UpdateNeeded then
			local InstallDataUrl = Path:Join(self.GithubUrl,"Update","Install.data")
			local InstallInstructionsUrl = Path:Join(self.GithubUrl,"Update","Install.json")
			if _G.RGDebug then
				InstallDataUrl = InstallDataUrl .. ".debug"
				InstallInstructionsUrl = InstallInstructionsUrl .. ".debug"
			end
			--//Update LocalVersion.txt
			InstallingGui.MainWindow.Status.Text = "Writing LocalVersion.txt"
			self.Helper.Io:Write(
				Path:Join(self.Directory,"LocalVersion.txt"),
				LatestVersion
			)
			--//Get install instructions
			InstallingGui.MainWindow.Status.Text = "Fetching Install.json"
			local InstallInstructions = self.Helper.Http:Get(
				InstallInstructionsUrl,
				true
			)
			InstallingGui.MainWindow.Status.Text = "Fetching Install.data"
			local InstallData = self.Helper.Http:Get(
				InstallDataUrl
			)
			local DataOffset = 1
			if self.Helper.Io:IsFolder(Path:Join(self.Directory,"Data")) then
				--//Remove old Data folder
				InstallingGui.MainWindow.Status.Text = "Removing old data directory"
				self.Helper.Io:DeleteFolder(Path:Join(self.Directory,"Data"))
			end
			InstallingGui.MainWindow.Status.Text = "Creating the data directory"
			--//Create the Data directory
			self.Helper.Io:MakeFolder(Path:Join(self.Directory,"Data"))
			--//Download files
			local CompletedInstructions = 0
			local WaitCounter = 0
			for InstructionId,IOInstruction in pairs(InstallInstructions) do
				--[[
				IOInstruction : Table
					1 : Type (Number)
						1: File
						2: Folder
					2 : Path (String)
					3: DataLength (Number)
				]]
				if IOInstruction[1] == 1 then
					WaitCounter = WaitCounter + 1
					InstallingGui.MainWindow.Status.Text = "Write " .. IOInstruction[2]
					self.Helper.Io:Write(
						Path:Join(self.Directory,"Data",IOInstruction[2]),
						string.sub(
							InstallData,
							DataOffset,
							DataOffset + (IOInstruction[3])
						)
					)
					DataOffset = DataOffset + (IOInstruction[3] + 1)
					CompletedInstructions = CompletedInstructions + 1
				elseif IOInstruction[1] == 2 then
					WaitCounter = WaitCounter + 1
					InstallingGui.MainWindow.Status.Text = "Create " .. IOInstruction[2]
					self.Helper.Io:MakeFolder(
						Path:Join(self.Directory,"Data",IOInstruction[2])
					)
					CompletedInstructions = CompletedInstructions + 1
				end
				if WaitCounter >= 10 then
					game:GetService("RunService").RenderStepped:Wait()
					WaitCounter = 0
				end
			end
			repeat game:GetService("RunService").RenderStepped:Wait() until CompletedInstructions == #InstallInstructions
		end
		InstallingGui:Destroy()
	end;
    Startup = Startup;
}


Startup:Log("Creating env")
xpcall(function()
    getgenv()._ReGui = ReguiEnv
    getgenv()._R = ReguiEnv
    getgenv()._H = Helpers
    Startup:Log("Created env")
end,function(err)
    warn("ReGui failed to create env")
    error(err)
end)
if not _R then
    Startup:Log("env failed to create with no errors????????")
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not LAUNCH_ARGS.DontRun then
	if not LAUNCH_ARGS.DontUpdate then
		_R:Update(LAUNCH_ARGS.ForceUpdate)
	end
	_R:Run()
end