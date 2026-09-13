-- [[ PROJECT X NEXUS - PROTECTED DISTRIBUTION ]]
-- Official Seller: vlilayz
local _0xAUTH = getgenv()._X_AUTH_TOKEN
local _0xKEY = getgenv().Key or getgenv().ScriptKey or script_key
if not _0xAUTH or _0xAUTH ~= "X_NEXUS_VERIFIED_7789" or not _0xKEY then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ ACCESS DENIED",
            Text = "Direct execution blocked! Please use Loader.lua with a valid key. Contact Discord: vlilayz",
            Duration = 6
        })
    end)
    warn("[X SUITE] Security Alert: Direct loadstring blocked! You must purchase a key and use Loader.lua")
    return
end

-- [[ X TITAN V4.6.0 - PATCH: P0/P1/P2 ALL FIXED & OPTIMIZED ]]
-- P0: SilentAim Raycast Filter (No more broken game interactions)
-- P1: CFrameSpeed dt math & Fly/Desync Mutual Exclusion
-- P2: RenderStepped Target Caching & Collision Loop Optimization
-- ==============================================================================
local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	UIS = game:GetService("UserInputService"),
	Lighting = game:GetService("Lighting"),
	TweenService = game:GetService("TweenService"),
	Workspace = game:GetService("Workspace"),
	StarterGui = game:GetService("StarterGui")
}
local LocalPlayer = Services.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
if not game:IsLoaded() then game.Loaded:Wait() end

local targetGui
if type(gethui) == "function" then targetGui = gethui()
else
	local s, c = pcall(function() return game:GetService("CoreGui") end)
	if s and c then targetGui = c else targetGui = LocalPlayer:WaitForChild("PlayerGui") end
end
if not targetGui then warn("X TITAN: GUI Target failed!") return end

-- ==============================================================================
-- CONFIGURATION & STORAGE (V4.6.0)
-- ==============================================================================
local Config = {
	Keys = {
		Menu = Enum.KeyCode.Insert, Fly = Enum.KeyCode.Z, Noclip = Enum.KeyCode.V,
		Trigger = Enum.KeyCode.T, DestroyMap = Enum.KeyCode.P, Hide = Enum.KeyCode.X,
		RestoreMap = Enum.KeyCode.L, TacticalTP = Enum.KeyCode.B,
		ToggleLockMenu = Enum.KeyCode.LeftAlt, Unload = Enum.KeyCode.End,
		LockTarget = Enum.KeyCode.F
	},
	Theme = {
		Main = Color3.fromRGB(10, 10, 15), Sec = Color3.fromRGB(20, 20, 25),
		Stroke = Color3.fromRGB(0, 255, 255), Team = Color3.fromRGB(0, 255, 100),
		Text = Color3.fromRGB(255, 255, 255), TextDim = Color3.fromRGB(150, 150, 150),
		LockColor = Color3.fromRGB(255, 50, 50), WallColor = Color3.fromRGB(255, 200, 0),
		ThreatHigh = Color3.fromRGB(255, 40, 40), ThreatMed = Color3.fromRGB(255, 180, 0), ThreatLow = Color3.fromRGB(40, 255, 100)
	},
	States = {
		Aimbot = false, SilentAim = false, HeadExpander = false, Hitbox = false,
		TriggerBot = false, TeamCheck = true, WallCheck = false,
		ESP = false, ESPSkeleton = false, Tracers = false, VisibilityCheck = true, Chams = false,
		XRay = false, Fullbright = false, Crosshair = false, DynamicCrosshair = true,
		Fly = false, SpeedHack = false, InfJump = false, Noclip = false, NoFall = false,
		AntiKillbrick = false, AntiVoid = true, HitSound = true, ClickTP = false, SkyHide = false, MapDestroyer = false,
		KillAura = false, TPAura = false, Desync = false, AntiAimSpin = false, AntiAimHeadJitter = false,
		RightClickToggle = true, ShowFOV = false, TacticalLock = false,
		ShowLockStatus = true, SmartPrediction = true, AutoAimPart = true,
		LegitFly = false, ServerDesync = false, CFrameSpeed = false, Radar = false
	},
	Vals = {
		FOV = 200, WalkSpeed = 150, FlySpeed = 150, HitboxSize = 15, HeadSize = 25,
		AimbotSmoothness = 0.3, PredictionStrength = 0.16, DesyncPower = 5,
		AuraRange = 25, TPBehindDist = 4, TriggerDelay = 0.15,
		AntiAimSpinSpeed = 10, AntiAimJitterRadius = 5, AimPart = "Head",
		Deadzone = 5, PingCompensation = 0.05, RadarRange = 100, LegitFlySmooth = 0.1
	}
}

local Storage = {
	Checkpoints = {P1=nil, P2=nil, P3=nil},
	ESPObjects = {}, SkeletonParts = {}, TracerLines = {},
	ToggleFuncs = {}, FOVRingUI = nil, MainFrame = nil,
	RealVelocity = Vector3.zero, RealCFrame = nil,
	OriginalLighting = {}, HitboxLastUpdate = 0,
	AuraTarget = nil, CurrentSpectate = nil, SnapPlayer = nil,
	LockedTarget = nil, IsHiding = false, HideCFrame = nil,
	DestroyedParts = {}, MapStorageFolder = nil,
	AimParts = {"Head", "Torso", "HumanoidRootPart"}, AimPartIndex = 1,
	PlayerListFrame = nil, Connections = {}, Loops = {},
	TriggerBotCooldown = 0,
	LastTargetVel = {}, LastTargetTick = {},
	RadarObjects = {}, RadarGui = nil, RadarFrame = nil,
	TacticalHUD = nil, CurrentHPRatio = 0,
	CrosshairLines = {Top=nil, Bottom=nil, Left=nil, Right=nil},
	HitmarkerLines = {TL=nil, TR=nil, BL=nil, BR=nil},
	HitmarkerAlpha = 0,
	MenuDebounce = false, ActiveSlider = nil, SliderDrag = false,
	OriginalWalkSpeed = 16,
	OriginalFallenHeight = -500,
	HookActive = false,
	HookOldNamecall = nil,
	IsUnloaded = false,
	RootAttachmentOwned = false,
	WalkSpeedSnapshotPending = false,
	LastSafeCFrame = nil,
	HitSoundObj = nil
}

_G.X_TITAN_CURRENT_INSTANCE = {
	Config = Config,
	Storage = Storage,
	Utils = nil,
	Features = nil
}

-- ==============================================================================
-- UTILITIES (V4.6.0)
-- ==============================================================================
local Utils = {}
_G.X_TITAN_CURRENT_INSTANCE.Utils = Utils

function Utils.Notify(title, text, dur)
	pcall(function() Services.StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 2}) end)
end

function Utils.IsTeammate(plr)
	if not plr or not LocalPlayer then return false end
	if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return true end
	if plr.TeamColor and LocalPlayer.TeamColor and plr.TeamColor == LocalPlayer.TeamColor then return true end
	return false
end

function Utils.GetCurrentCamera()
	local cam = Services.Workspace.CurrentCamera
	if not cam then
		for _, v in pairs(Services.Workspace:GetChildren()) do
			if v:IsA("Camera") then return v end
		end
	end
	return cam
end

function Utils.IsVisible(targetHead)
	if not targetHead or not targetHead.Parent then return false end
	local Camera = Utils.GetCurrentCamera()
	if not Camera then return false end
	local origin = Camera.CFrame.Position
	local direction = (targetHead.Position - origin)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	local success, result = pcall(function() return Services.Workspace:Raycast(origin, direction * 1000, params) end)
	if not success or not result then return true end
	if result.Instance and result.Instance:IsDescendantOf(targetHead.Parent) then return true end
	return false
end

function Utils.GetPing()
	local ping = 0
	pcall(function()
		local stats = game:GetService("Stats")
		if stats and stats.Network and stats.Network.ServerStatsItem then
			ping = stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end
	end)
	return ping
end


function Utils.PlayHitSound()
	if not Config.States.HitSound then return end
	pcall(function()
		if not Storage.HitSoundObj then
			local snd = Instance.new("Sound")
			snd.SoundId = "rbxassetid://6534948092"
			snd.Volume = 0.85
			snd.Parent = Services.SoundService
			Storage.HitSoundObj = snd
		end
		Storage.HitSoundObj:Play()
	end)
end

function Utils.CalculateThreatScore(plr, myHRP)
	if not plr.Character or not myHRP then return 0 end
	local eHRP = plr.Character:FindFirstChild("HumanoidRootPart")
	local eHead = plr.Character:FindFirstChild("Head")
	if not eHRP or not eHead then return 0 end
	local dist = (eHRP.Position - myHRP.Position).Magnitude
	local score = 1000 / math.max(dist, 1)
	local targetLook = eHead.CFrame.LookVector
	local toMe = (myHRP.Position - eHead.Position).Unit
	if targetLook:Dot(toMe) > 0.85 then score = score + 800 end
	local vel = eHRP.AssemblyLinearVelocity.Magnitude
	if vel > 20 then score = score + 200 end
	return score
end

function Utils.GetSmartAimPart(character)
	if not character then return nil end
	local Camera = Utils.GetCurrentCamera()
	if not Camera then return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head") end
	local head = character:FindFirstChild("Head")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("HumanoidRootPart")
	if Config.States.AutoAimPart and head and torso then
		local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
		if onScreen then
			local torsoPos = Camera:WorldToViewportPoint(torso.Position)
			if math.abs(headPos.Y - torsoPos.Y) * 0.4 < 20 then return torso end
		end
	end
	if Config.Vals.AimPart == "Head" and head then return head end
	if Config.Vals.AimPart == "Torso" and torso then return torso end
	return character:FindFirstChild("HumanoidRootPart") or head or torso
end

function Utils.GetClosestToCenter()
	local Camera = Utils.GetCurrentCamera()
	if not Camera then return nil, false end
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	
	if Storage.LockedTarget and Storage.LockedTarget.Character then
		local tChar = Storage.LockedTarget.Character
		local tHum = tChar:FindFirstChild("Humanoid")
		if tHum and tHum.Health > 0 then
			local aimPart = Utils.GetSmartAimPart(tChar)
			if aimPart then
				local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
				if onScreen then
					if Config.States.WallCheck and not Utils.IsVisible(aimPart) then return aimPart, true end
					return aimPart, false
				end
			end
		else
			Utils.Notify("🔓 Target Eliminated", "Target lock released: " .. Storage.LockedTarget.Name)
			Storage.LockedTarget = nil
			Storage.CurrentHPRatio = 0
		end
	end
	
	local highestThreat, targetPart = -1, nil
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p == LocalPlayer or not p.Character then continue end
		if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end
		local aimPart = Utils.GetSmartAimPart(p.Character)
		if not aimPart then continue end
		local hum = p.Character:FindFirstChild("Humanoid")
		if not hum or hum.Health <= 0 then continue end
		local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
		if onScreen then
			local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
			if screenDist <= Config.Vals.FOV then
				if Config.States.WallCheck and not Utils.IsVisible(aimPart) then continue end
				local threatScore = Utils.CalculateThreatScore(p, myHRP)
				if threatScore > highestThreat then
					highestThreat = threatScore
					targetPart = aimPart
				end
			end
		end
	end
	return targetPart, false
end

function Utils.SaveCollision(char, mode)
	if not char then return end
	local attrName = (mode == "touch") and "X_OrigCanTouch" or "X_OrigCanCollide"
	local propName = (mode == "touch") and "CanTouch" or "CanCollide"
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			if v:GetAttribute(attrName) == nil then
				v:SetAttribute(attrName, v[propName])
			end
		end
	end
end

function Utils.RestoreCollision(char, mode)
	if not char then return end
	local attrName = (mode == "touch") and "X_OrigCanTouch" or "X_OrigCanCollide"
	local propName = (mode == "touch") and "CanTouch" or "CanCollide"
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			local orig = v:GetAttribute(attrName)
			if orig ~= nil then
				v[propName] = orig
				v:SetAttribute(attrName, nil)
			end
		end
	end
end

function Utils.ResetCollision()
	local char = LocalPlayer.Character
	if char then
		Utils.RestoreCollision(char, "collide")
		Utils.RestoreCollision(char, "touch")
	end
end

function Utils.SetPoint(n)
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		Storage.Checkpoints[n] = LocalPlayer.Character.HumanoidRootPart.CFrame
		Utils.Notify("📍 Checkpoint Saved", "Location saved to slot: " .. n)
	end
end

function Utils.TPPoint(n)
	if Storage.Checkpoints[n] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character.HumanoidRootPart.CFrame = Storage.Checkpoints[n]
		Utils.Notify("⚡ Teleported", "Teleported to slot: " .. n)
	end
end

function Utils.ToggleXRay(state)
	for _, v in pairs(Services.Workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
			if state then
				if v.Transparency < 0.9 then
					if v:GetAttribute("XR_Orig") == nil then v:SetAttribute("XR_Orig", v.Transparency) end
					v.Transparency = 0.6
				end
			else
				local orig = v:GetAttribute("XR_Orig")
				if orig ~= nil then v.Transparency = orig; v:SetAttribute("XR_Orig", nil) end
			end
		end
	end
end

function Utils.ToggleFullbright(state)
	if state then
		if not Storage.OriginalLighting.Ambient then
			Storage.OriginalLighting = {
				Ambient = Services.Lighting.Ambient, Brightness = Services.Lighting.Brightness,
				OutdoorAmbient = Services.Lighting.OutdoorAmbient, ClockTime = Services.Lighting.ClockTime,
				FogEnd = Services.Lighting.FogEnd, FogStart = Services.Lighting.FogStart
			}
		end
		Services.Lighting.Ambient = Color3.new(1, 1, 1); Services.Lighting.Brightness = 2
		Services.Lighting.OutdoorAmbient = Color3.new(1, 1, 1); Services.Lighting.ClockTime = 14
		Services.Lighting.FogEnd = 100000; Services.Lighting.FogStart = 0
	else
		if Storage.OriginalLighting.Ambient then
			Services.Lighting.Ambient = Storage.OriginalLighting.Ambient
			Services.Lighting.Brightness = Storage.OriginalLighting.Brightness
			Services.Lighting.OutdoorAmbient = Storage.OriginalLighting.OutdoorAmbient
			Services.Lighting.ClockTime = Storage.OriginalLighting.ClockTime
			Services.Lighting.FogEnd = Storage.OriginalLighting.FogEnd
			Services.Lighting.FogStart = Storage.OriginalLighting.FogStart
			Storage.OriginalLighting = {}
		end
	end
end

-- ==============================================================================
-- FEATURES & ESP
-- ==============================================================================
local Features = {}
_G.X_TITAN_CURRENT_INSTANCE.Features = Features

function Features.SpectatePlayer(name)
	local target = nil
	for _, p in pairs(Services.Players:GetPlayers()) do
		if string.sub(string.lower(p.Name), 1, string.len(name)) == string.lower(name)
		or string.sub(string.lower(p.DisplayName), 1, string.len(name)) == string.lower(name) then
			target = p; break
		end
	end
	if target then
		Storage.CurrentSpectate = target
		local cam = Utils.GetCurrentCamera()
		if cam and target.Character and target.Character:FindFirstChild("Humanoid") then
			cam.CameraSubject = target.Character.Humanoid
		end
		Utils.Notify("👁️ Spectate", "Spectating: " .. target.DisplayName, 3)
	else
		Utils.Notify("❌ Error", "Player not found!")
	end
end

function Features.StopSpectate()
	Storage.CurrentSpectate = nil
	local cam = Utils.GetCurrentCamera()
	if cam and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		cam.CameraSubject = LocalPlayer.Character.Humanoid
		Utils.Notify("👁️ Spectate", "Spectate stopped")
	end
end

function Features.UpdateChams()
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local highlight = p.Character:FindFirstChild("X_Chams")
			if Config.States.Chams then
				if not highlight then
					highlight = Instance.new("Highlight", p.Character)
					highlight.Name = "X_Chams"; highlight.FillTransparency = 0.5; highlight.OutlineTransparency = 0
				end
				highlight.FillColor = Utils.IsTeammate(p) and Config.Theme.Team or Config.Theme.Stroke
				highlight.OutlineColor = highlight.FillColor
			else
				if highlight then highlight:Destroy() end
			end
		end
	end
end

function Features.CreateESP(plr)
	if plr == LocalPlayer or Storage.ESPObjects[plr] then return end
	if not Drawing then return end
	local esp = {
		Box = Drawing.new("Square"), Name = Drawing.new("Text"),
		HealthBar = Drawing.new("Line"), Distance = Drawing.new("Text")
	}
	esp.Box.Thickness = 1.5; esp.Box.Color = Config.Theme.Stroke; esp.Box.Filled = false; esp.Box.Visible = false
	esp.Name.Size = 14; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Color = Color3.new(1,1,1); esp.Name.Visible = false
	esp.HealthBar.Thickness = 1.5; esp.HealthBar.Color = Color3.new(0,1,0); esp.HealthBar.Visible = false
	esp.Distance.Size = 12; esp.Distance.Center = true; esp.Distance.Outline = true; esp.Distance.Color = Color3.new(1,1,1); esp.Distance.Visible = false
	Storage.ESPObjects[plr] = esp
	Storage.SkeletonParts[plr] = {
		HeadToTorso = Drawing.new("Line"), TorsoToLeftArm = Drawing.new("Line"),
		TorsoToRightArm = Drawing.new("Line"), TorsoToLeftLeg = Drawing.new("Line"),
		TorsoToRightLeg = Drawing.new("Line")
	}
	for _, part in pairs(Storage.SkeletonParts[plr]) do
		part.Thickness = 1.2; part.Color = Config.Theme.Stroke; part.Visible = false
	end
end

function Features.RemoveESP(plr)
	if Storage.ESPObjects[plr] then
		for _, d in pairs(Storage.ESPObjects[plr]) do pcall(function() d:Remove() end) end
		Storage.ESPObjects[plr] = nil
	end
	if Storage.SkeletonParts[plr] then
		for _, part in pairs(Storage.SkeletonParts[plr]) do pcall(function() part:Remove() end) end
		Storage.SkeletonParts[plr] = nil
	end
	if Storage.TracerLines[plr] then
		pcall(function() Storage.TracerLines[plr]:Remove() end)
		Storage.TracerLines[plr] = nil
	end
end

function Features.UpdateHitboxes()
	local now = tick()
	if now - Storage.HitboxLastUpdate < 0.1 then return end
	Storage.HitboxLastUpdate = now
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end
			local eHead = p.Character:FindFirstChild("Head")
			local eBody = p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("HumanoidRootPart")
			
			if Config.States.HeadExpander and eHead then
				if eHead:GetAttribute("OrigSize") == nil then
					eHead:SetAttribute("OrigSize", eHead.Size)
					eHead:SetAttribute("OrigTransparency", eHead.Transparency)
					eHead:SetAttribute("OrigCanCollide", eHead.CanCollide)
					eHead:SetAttribute("OrigMassless", eHead.Massless)
				end
				eHead.Size = Vector3.new(Config.Vals.HeadSize, Config.Vals.HeadSize, Config.Vals.HeadSize)
				eHead.Transparency = 0.7; eHead.CanCollide = false; eHead.Massless = true
			elseif eHead and eHead:GetAttribute("OrigSize") ~= nil then
				eHead.Size = eHead:GetAttribute("OrigSize")
				local ot = eHead:GetAttribute("OrigTransparency")
				eHead.Transparency = (ot ~= nil) and ot or 0
				local origCollide = eHead:GetAttribute("OrigCanCollide")
				if origCollide ~= nil then eHead.CanCollide = origCollide end
				local origMassless = eHead:GetAttribute("OrigMassless")
				if origMassless ~= nil then eHead.Massless = origMassless end
				eHead:SetAttribute("OrigSize", nil); eHead:SetAttribute("OrigTransparency", nil)
				eHead:SetAttribute("OrigCanCollide", nil); eHead:SetAttribute("OrigMassless", nil)
			end
			
			if Config.States.Hitbox and eBody then
				if eBody:GetAttribute("OrigSize") == nil then
					eBody:SetAttribute("OrigSize", eBody.Size)
					eBody:SetAttribute("OrigTransparency", eBody.Transparency)
					eBody:SetAttribute("OrigCanCollide", eBody.CanCollide)
					eBody:SetAttribute("OrigMassless", eBody.Massless)
				end
				eBody.Size = Vector3.new(Config.Vals.HitboxSize, Config.Vals.HitboxSize, Config.Vals.HitboxSize)
				eBody.Transparency = 0.7; eBody.CanCollide = false; eBody.Massless = true
			elseif eBody and eBody:GetAttribute("OrigSize") ~= nil then
				eBody.Size = eBody:GetAttribute("OrigSize")
				local ot = eBody:GetAttribute("OrigTransparency")
				eBody.Transparency = (ot ~= nil) and ot or 0
				local origCollide = eBody:GetAttribute("OrigCanCollide")
				if origCollide ~= nil then eBody.CanCollide = origCollide end
				local origMassless = eBody:GetAttribute("OrigMassless")
				if origMassless ~= nil then eBody.Massless = origMassless end
				eBody:SetAttribute("OrigSize", nil); eBody:SetAttribute("OrigTransparency", nil)
				eBody:SetAttribute("OrigCanCollide", nil); eBody:SetAttribute("OrigMassless", nil)
			end
		end
	end
end

function Features.GetAuraTarget()
	local target, dist = nil, Config.Vals.AuraRange
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil end
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
			if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end
			if p.Character.Humanoid.Health > 0 then
				local d = (p.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
				if d < dist then dist = d; target = p.Character end
			end
		end
	end
	return target
end

-- ==============================================================================
-- UI SYSTEM (V4.6.0)
-- ==============================================================================
local UI = {}
function UI.Init()
	local guiName = "X_TITAN_V458"
	if targetGui:FindFirstChild(guiName) then targetGui[guiName]:Destroy() end
	
	local ScreenGui = Instance.new("ScreenGui", targetGui)
	ScreenGui.Name = guiName; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true; ScreenGui.DisplayOrder = 999999999
	
	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 620, 0, 460); Main.Position = UDim2.new(0.5, -310, 0.5, -230)
	Main.BackgroundColor3 = Config.Theme.Main; Main.Active = true; Main.Draggable = true
	Storage.MainFrame = Main
	
	local UIStroke = Instance.new("UIStroke", Main); UIStroke.Color = Config.Theme.Stroke; UIStroke.Thickness = 2
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
	
	local SidePanel = Instance.new("Frame", Main)
	SidePanel.Size = UDim2.new(0, 140, 1, 0); SidePanel.BackgroundColor3 = Config.Theme.Sec
	Instance.new("UICorner", SidePanel).CornerRadius = UDim.new(0, 8)
	
	local Title = Instance.new("TextLabel", SidePanel)
	Title.Text = "X TITAN V4.6.0"; Title.Size = UDim2.new(1, 0, 0, 45); Title.BackgroundTransparency = 1
	Title.TextColor3 = Config.Theme.Stroke; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 16
	
	local TabHolder = Instance.new("Frame", SidePanel)
	TabHolder.Size = UDim2.new(1, -16, 1, -60); TabHolder.Position = UDim2.new(0, 8, 0, 50); TabHolder.BackgroundTransparency = 1
	local TabLayout = Instance.new("UIListLayout", TabHolder); TabLayout.Padding = UDim.new(0, 4)
	
	local PageHolder = Instance.new("Frame", Main)
	PageHolder.Size = UDim2.new(1, -155, 1, -10); PageHolder.Position = UDim2.new(0, 150, 0, 5); PageHolder.BackgroundTransparency = 1
	
	local uiOrderCounter = 0
	local function getNextOrder() uiOrderCounter = uiOrderCounter + 1; return uiOrderCounter end
	
	local function CreatePage(name)
		local Page = Instance.new("ScrollingFrame", PageHolder)
		Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false
		Page.ScrollBarThickness = 4; Page.ScrollBarImageColor3 = Config.Theme.Stroke
		local List = Instance.new("UIListLayout", Page); List.Padding = UDim.new(0, 4); List.SortOrder = Enum.SortOrder.LayoutOrder
		List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10)
		end)
		local TabBtn = Instance.new("TextButton", TabHolder)
		TabBtn.Size = UDim2.new(1, 0, 0, 30); TabBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
		TabBtn.Text = name; TabBtn.TextColor3 = Config.Theme.TextDim; TabBtn.Font = Enum.Font.GothamBold; TabBtn.TextSize = 11; TabBtn.AutoButtonColor = false
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
		TabBtn.MouseButton1Click:Connect(function()
			for _,v in pairs(PageHolder:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
			for _,v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(30,30,35); v.TextColor3 = Config.Theme.TextDim end end
			Page.Visible = true; TabBtn.BackgroundColor3 = Config.Theme.Stroke; TabBtn.TextColor3 = Config.Theme.Main
		end)
		return Page, TabBtn, getNextOrder
	end
	
	local function AddToggle(page, text, flag, getOrder)
		local Btn = Instance.new("TextButton", page)
		Btn.LayoutOrder = getOrder(); Btn.Size = UDim2.new(1, -4, 0, 34); Btn.BackgroundColor3 = Config.Theme.Sec; Btn.Text = "  "; Btn.AutoButtonColor = false
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
		local Stroke = Instance.new("UIStroke", Btn); Stroke.Color = Config.Theme.Stroke; Stroke.Transparency = 0.8
		local Label = Instance.new("TextLabel", Btn)
		Label.Text = text; Label.Size = UDim2.new(0.72, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0)
		Label.BackgroundTransparency = 1; Label.TextColor3 = Config.Theme.Text; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left
		local Indicator = Instance.new("Frame", Btn)
		Indicator.Size = UDim2.new(0, 32, 0, 16); Indicator.Position = UDim2.new(1, -42, 0.5, -8); Indicator.BackgroundColor3 = Color3.fromRGB(60,60,70)
		Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
		local Dot = Instance.new("Frame", Indicator)
		Dot.Size = UDim2.new(0, 12, 0, 12); Dot.Position = UDim2.new(0, 2, 0.5, -6); Dot.BackgroundColor3 = Color3.fromRGB(120,120,130)
		Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
		
		local function Update(val)
			local c = val and Config.Theme.Stroke or Color3.fromRGB(120,120,130)
			local p = val and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
			Services.TweenService:Create(Dot, TweenInfo.new(0.25), {Position = p, BackgroundColor3 = c}):Play()
			Services.TweenService:Create(Stroke, TweenInfo.new(0.25), {Transparency = val and 0.2 or 0.8}):Play()
			Config.States[flag] = val
			if flag == "XRay" then Utils.ToggleXRay(val) end
			if flag == "Fullbright" then Utils.ToggleFullbright(val) end
			if flag == "AntiKillbrick" and not val then
				Services.Workspace.FallenPartsDestroyHeight = Storage.OriginalFallenHeight
			end
			if flag == "Chams" then Features.UpdateChams() end
		end
		Storage.ToggleFuncs[flag] = Update; Update(Config.States[flag])
		Btn.MouseButton1Click:Connect(function() Update(not Config.States[flag]) end)
	end
	
	local function AddSlider(page, text, min, max, def, cb, getOrder)
		local Frame = Instance.new("Frame", page)
		Frame.LayoutOrder = getOrder(); Frame.Size = UDim2.new(1, -4, 0, 42); Frame.BackgroundColor3 = Config.Theme.Sec
		Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
		local Label = Instance.new("TextLabel", Frame)
		Label.Text = text .. ": " .. def; Label.Size = UDim2.new(1, -16, 0, 16); Label.Position = UDim2.new(0, 8, 0, 4)
		Label.BackgroundTransparency = 1; Label.TextColor3 = Config.Theme.Text; Label.Font = Enum.Font.GothamBold; Label.TextSize = 10
		local SlideBar = Instance.new("TextButton", Frame)
		SlideBar.Size = UDim2.new(1, -16, 0, 4); SlideBar.Position = UDim2.new(0, 8, 0, 26); SlideBar.BackgroundColor3 = Color3.fromRGB(60,60,70); SlideBar.Text = "  "
		Instance.new("UICorner", SlideBar).CornerRadius = UDim.new(0, 2)
		local Fill = Instance.new("Frame", SlideBar)
		Fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Config.Theme.Stroke
		Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
		local SliderData = {Bar = SlideBar, Fill = Fill, Label = Label, Min = min, Max = max, Callback = cb, Text = text}
		function SliderData:SetValue(val)
			val = math.clamp(val, min, max); local pct = (val - min) / (max - min)
			Fill.Size = UDim2.new(pct, 0, 1, 0); Label.Text = text .. ": " .. math.floor(val)
			if cb then cb(math.floor(val)) end
		end
		SlideBar.MouseButton1Down:Connect(function() Storage.ActiveSlider = SliderData; Storage.SliderDrag = true end)
		SliderData:SetValue(def)
	end
	
	local sliderChangedConn = Services.UIS.InputChanged:Connect(function(i)
		if Storage.SliderDrag and Storage.ActiveSlider and i.UserInputType == Enum.UserInputType.MouseMovement then
			local s = Storage.ActiveSlider
			local pct = math.clamp((i.Position.X - s.Bar.AbsolutePosition.X) / s.Bar.AbsoluteSize.X, 0, 1)
			s:SetValue(math.floor(s.Min + (s.Max - s.Min) * pct))
		end
	end)
	table.insert(Storage.Connections, sliderChangedConn)
	
	local sliderEndedConn = Services.UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 and Storage.SliderDrag then
			Storage.SliderDrag = false; Storage.ActiveSlider = nil
		end
	end)
	table.insert(Storage.Connections, sliderEndedConn)
	
	local function AddDual(page, t1, cb1, t2, cb2, getOrder)
		local F = Instance.new("Frame", page)
		F.LayoutOrder = getOrder(); F.Size = UDim2.new(1, -4, 0, 32); F.BackgroundTransparency = 1
		local B1 = Instance.new("TextButton", F); B1.Size = UDim2.new(0.48, 0, 1, 0); B1.BackgroundColor3 = Config.Theme.Sec
		B1.Text = t1; B1.TextColor3 = Config.Theme.Text; B1.Font = Enum.Font.GothamBold; B1.TextSize = 9
		Instance.new("UICorner", B1).CornerRadius = UDim.new(0, 6); B1.MouseButton1Click:Connect(function() cb1() end)
		local B2 = Instance.new("TextButton", F); B2.Size = UDim2.new(0.48, 0, 1, 0); B2.Position = UDim2.new(0.52, 0, 0, 0)
		B2.BackgroundColor3 = Config.Theme.Sec; B2.Text = t2; B2.TextColor3 = Config.Theme.Text; B2.Font = Enum.Font.GothamBold; B2.TextSize = 9
		Instance.new("UICorner", B2).CornerRadius = UDim.new(0, 6); B2.MouseButton1Click:Connect(function() cb2() end)
	end
	
	local function AddSection(page, text, getOrder)
		local Label = Instance.new("TextLabel", page); Label.LayoutOrder = getOrder()
		Label.Size = UDim2.new(1, -4, 0, 18); Label.BackgroundTransparency = 1
		Label.Text = "-- " .. text .. " --"; Label.TextColor3 = Config.Theme.Stroke; Label.Font = Enum.Font.GothamBlack; Label.TextSize = 10
		Label.TextXAlignment = Enum.TextXAlignment.Left
	end
	
	local function AddKeybindInfo(page, section, binds, getOrder)
		AddSection(page, section, getOrder)
		for _, bind in ipairs(binds) do
			local F = Instance.new("Frame", page)
			F.LayoutOrder = getOrder(); F.Size = UDim2.new(1, -4, 0, 22); F.BackgroundTransparency = 1
			local L = Instance.new("TextLabel", F); L.Size = UDim2.new(0.6, 0, 1, 0); L.Position = UDim2.new(0, 10, 0, 0)
			L.BackgroundTransparency = 1; L.Text = bind[1]; L.TextColor3 = Config.Theme.Text; L.Font = Enum.Font.GothamBold; L.TextSize = 10
			L.TextXAlignment = Enum.TextXAlignment.Left
			local K = Instance.new("TextLabel", F); K.Size = UDim2.new(0.35, 0, 1, 0); K.Position = UDim2.new(0.65, 0, 0, 0)
			K.BackgroundTransparency = 1; K.Text = bind[2]; K.TextColor3 = Config.Theme.Stroke; K.Font = Enum.Font.GothamBlack; K.TextSize = 10
			K.TextXAlignment = Enum.TextXAlignment.Right
		end
	end
	
	local P1, T1, getOrder1 = CreatePage("COMBAT"); P1.Visible = true; T1.BackgroundColor3 = Config.Theme.Stroke; T1.TextColor3 = Config.Theme.Main
	local P2, T2, getOrder2 = CreatePage("VISUAL")
	local P3, T3, getOrder3 = CreatePage("MOVEMENT")
	local P4, T4, getOrder4 = CreatePage("PLAYER")
	local P5, T5, getOrder5 = CreatePage("OTHER")
	local P6, T6, getOrder6 = CreatePage("KEYBINDS")
	
	AddSection(P1, "AIMBOT & THREAT", getOrder1)
	AddToggle(P1, "Hold Right Click Aimbot", "RightClickToggle", getOrder1)
	AddToggle(P1, "Aimbot (Esports V4.5)", "Aimbot", getOrder1)
	AddSlider(P1, "Base Smoothness", 1, 90, 30, function(v) Config.Vals.AimbotSmoothness = v / 100 end, getOrder1)
	AddSlider(P1, "Prediction", 0, 50, 16, function(v) Config.Vals.PredictionStrength = v / 100 end, getOrder1)
	AddToggle(P1, "Smart Prediction (Ping)", "SmartPrediction", getOrder1)
	AddToggle(P1, "Auto Aim Part", "AutoAimPart", getOrder1)
	AddDual(P1, "Cycle Aim Part", function()
		Storage.AimPartIndex = Storage.AimPartIndex % #Storage.AimParts + 1
		Config.Vals.AimPart = Storage.AimParts[Storage.AimPartIndex]
		Utils.Notify("Aim Part", "Switched to: " .. Config.Vals.AimPart)
	end, "Current: Head", function() end, getOrder1)
	
	AddSection(P1, "SILENT & TRIGGER", getOrder1)
	AddToggle(P1, "Silent Aim 🔥", "SilentAim", getOrder1)
	AddToggle(P1, "TriggerBot [T]", "TriggerBot", getOrder1)
	
	AddSection(P1, "AURA & LOCK", getOrder1)
	AddToggle(P1, "Kill Aura", "KillAura", getOrder1)
	AddToggle(P1, "TP Aura", "TPAura", getOrder1)
	
	AddSection(P1, "HITBOX", getOrder1)
	AddToggle(P1, "Head Expander", "HeadExpander", getOrder1)
	AddSlider(P1, "Head Size", 2, 50, 25, function(v) Config.Vals.HeadSize = v end, getOrder1)
	AddToggle(P1, "Body Expander", "Hitbox", getOrder1)
	AddSlider(P1, "Body Size", 2, 50, 15, function(v) Config.Vals.HitboxSize = v end, getOrder1)
	
	AddSection(P1, "FILTERS & FOV", getOrder1)
	AddToggle(P1, "Team Check", "TeamCheck", getOrder1)
	AddToggle(P1, "Wall Check", "WallCheck", getOrder1)
	AddToggle(P1, "Show FOV", "ShowFOV", getOrder1)
	AddSlider(P1, "FOV Size", 50, 800, 200, function(v) Config.Vals.FOV = v end, getOrder1)
	
	AddSection(P2, "HUD & CROSSHAIR", getOrder2)
	AddToggle(P2, "Show Lock Status", "ShowLockStatus", getOrder2)
	AddToggle(P2, "Dynamic Crosshair", "DynamicCrosshair", getOrder2)
	AddToggle(P2, "Static Crosshair", "Crosshair", getOrder2)
	
	AddSection(P2, "ESP", getOrder2)
	AddToggle(P2, "ESP Master", "ESP", getOrder2)
	AddToggle(P2, "ESP Skeleton", "ESPSkeleton", getOrder2)
	AddToggle(P2, "360° Tracers", "Tracers", getOrder2)
	AddToggle(P2, "Visibility Check", "VisibilityCheck", getOrder2)
	AddToggle(P2, "Chams", "Chams", getOrder2)
	AddToggle(P2, "X-Ray", "XRay", getOrder2)
	AddToggle(P2, "Fullbright", "Fullbright", getOrder2)
	
	AddSection(P2, "RADAR", getOrder2)
	AddToggle(P2, "📡 Smart Threat Radar", "Radar", getOrder2)
	AddSlider(P2, "Radar Range", 50, 500, 100, function(v) Config.Vals.RadarRange = v end, getOrder2)
	
	AddSection(P3, "FLY & SPEED", getOrder3)
	AddToggle(P3, "Fly Mode [Z]", "Fly", getOrder3)
	AddToggle(P3, "️ Legit Fly", "LegitFly", getOrder3)
	AddSlider(P3, "Fly Speed", 10, 1500, 150, function(v) Config.Vals.FlySpeed = v end, getOrder3)
	AddToggle(P3, "Speed Hack", "SpeedHack", getOrder3)
	AddToggle(P3, "🛡️ CFrame Speed", "CFrameSpeed", getOrder3)
	AddSlider(P3, "Walk Speed", 16, 1500, 150, function(v) Config.Vals.WalkSpeed = v end, getOrder3)
	
	AddSection(P3, "MISC", getOrder3)
	AddToggle(P3, "Noclip [V]", "Noclip", getOrder3)
	AddToggle(P3, "Infinite Jump", "InfJump", getOrder3)
	AddToggle(P3, "God Mode", "AntiKillbrick", getOrder3)
	AddToggle(P3, "No Fall Damage", "NoFall", getOrder3)
	AddToggle(P3, "Sky Hide [X]", "SkyHide", getOrder3)
	AddToggle(P3, "Click TP [Ctrl+Click]", "ClickTP", getOrder3)
	
	AddSection(P3, "CHECKPOINTS", getOrder3)
	AddDual(P3, "📍 SET P1", function() Utils.SetPoint("P1") end, "⚡ TP P1", function() Utils.TPPoint("P1") end, getOrder3)
	AddDual(P3, "📍 SET P2", function() Utils.SetPoint("P2") end, "⚡ TP P2", function() Utils.TPPoint("P2") end, getOrder3)
	AddDual(P3, "📌 SET P3", function() Utils.SetPoint("P3") end, "⚡ TP P3", function() Utils.TPPoint("P3") end, getOrder3)
	
	AddSection(P3, "MAP", getOrder3)
	AddDual(P3, "💥 Destroy [P]", function()
		local Camera = Utils.GetCurrentCamera()
		if not Camera then return end
		local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
		local ray = Camera:ViewportPointToRay(center.X, center.Y)
		local params = RaycastParams.new(); params.FilterDescendantsInstances = {LocalPlayer.Character}; params.FilterType = Enum.RaycastFilterType.Exclude
		local result = Services.Workspace:Raycast(ray.Origin, ray.Direction * 500, params)
		if result and result.Position then
			if not Storage.MapStorageFolder then Storage.MapStorageFolder = Instance.new("Folder", Services.Workspace); Storage.MapStorageFolder.Name = "X_Titan_MapStorage" end
			local region = Region3.new(result.Position - Vector3.new(15,15,15), result.Position + Vector3.new(15,15,15))
			local parts = Services.Workspace:FindPartsInRegion3(region, LocalPlayer.Character, 100); local count = 0
			for _, part in pairs(parts) do
				if part.Name ~= "Baseplate" and part.Name ~= "Terrain" and not part.Parent:FindFirstChild("Humanoid") and part.Parent ~= Storage.MapStorageFolder then
					table.insert(Storage.DestroyedParts, {Part = part, Parent = part.Parent}); part.Parent = Storage.MapStorageFolder; count = count + 1
				end
			end
			Utils.Notify("💥 Map Destroyer", "Removed " .. count .. " obstacle parts")
		end
	end, "🔄 Restore [L]", function()
		local count = 0
		for _, data in pairs(Storage.DestroyedParts) do
			if data.Part and data.Parent then pcall(function() data.Part.Parent = data.Parent end); count = count + 1 end
		end
		table.clear(Storage.DestroyedParts)
		if Storage.MapStorageFolder then Storage.MapStorageFolder:Destroy(); Storage.MapStorageFolder = nil end
		Utils.Notify("🔄 Map Restored", "Restored " .. count .. " obstacle parts")
	end, getOrder3)
	
	AddSection(P4, "PLAYER LIST", getOrder4)
	local PlayerListFrame = Instance.new("ScrollingFrame", P4)
	PlayerListFrame.LayoutOrder = getOrder4()
	PlayerListFrame.Size = UDim2.new(1, -4, 0, 320); PlayerListFrame.BackgroundColor3 = Config.Theme.Sec
	PlayerListFrame.ScrollBarThickness = 4; PlayerListFrame.ScrollBarImageColor3 = Config.Theme.Stroke
	Instance.new("UICorner", PlayerListFrame).CornerRadius = UDim.new(0, 6)
	local ListLayout = Instance.new("UIListLayout", PlayerListFrame); ListLayout.Padding = UDim.new(0, 4)
	Storage.PlayerListFrame = PlayerListFrame
	
	local function RefreshPlayerList()
		for _, child in pairs(PlayerListFrame:GetChildren()) do if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end end
		local allPlayers = Services.Players:GetPlayers()
		table.sort(allPlayers, function(a, b)
			local tA = a.Team and a.Team.Name or "Neutral"; local tB = b.Team and b.Team.Name or "Neutral"
			if tA == tB then return string.lower(a.Name) < string.lower(b.Name) end; return tA < tB
		end)
		for _, p in ipairs(allPlayers) do
			if p == LocalPlayer then continue end
			local teamName = p.Team and p.Team.Name or "Neutral"
			local teamColor = p.Team and p.Team.TeamColor.Color or Config.Theme.Text
			local hpText = "💀 DEAD"
			if p.Character and p.Character:FindFirstChild("Humanoid") then
				local hum = p.Character.Humanoid; if hum and hum.Health > 0 then hpText = "❤️ " .. math.floor(hum.Health) end
			end
			local Row = Instance.new("Frame", PlayerListFrame); Row.Size = UDim2.new(1, -8, 0, 28); Row.BackgroundTransparency = 1
			local PBtn = Instance.new("TextButton", Row); PBtn.Size = UDim2.new(0.75, 0, 1, 0); PBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
			PBtn.Text = string.format("%s (@%s) [%s] %s", p.DisplayName, p.Name, teamName, hpText)
			PBtn.TextColor3 = teamColor; PBtn.Font = Enum.Font.GothamBold; PBtn.TextSize = 10; PBtn.AutoButtonColor = true
			PBtn.TextXAlignment = Enum.TextXAlignment.Left
			Instance.new("UIPadding", PBtn).PaddingLeft = UDim.new(0, 8); Instance.new("UICorner", PBtn).CornerRadius = UDim.new(0, 4)
			PBtn.MouseButton1Click:Connect(function() Features.SpectatePlayer(p.Name) end)
			local TPBtn = Instance.new("TextButton", Row); TPBtn.Size = UDim2.new(0.23, 0, 1, 0); TPBtn.Position = UDim2.new(0.77, 0, 0, 0)
			TPBtn.BackgroundColor3 = Config.Theme.Sec; TPBtn.Text = "⚡ TP"; TPBtn.TextColor3 = Config.Theme.Stroke; TPBtn.Font = Enum.Font.GothamBlack; TPBtn.TextSize = 10
			Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(0, 4)
			local Stroke = Instance.new("UIStroke", TPBtn); Stroke.Color = Config.Theme.Stroke; Stroke.Transparency = 0.5
			TPBtn.MouseButton1Click:Connect(function()
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
					Utils.Notify("⚡ Player TP", "Teleported to: " .. p.Name)
				end
			end)
		end
		PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
	end
	RefreshPlayerList()
	
	local playerAddedConn = Services.Players.PlayerAdded:Connect(RefreshPlayerList)
	table.insert(Storage.Connections, playerAddedConn)
	local playerRemovingConn = Services.Players.PlayerRemoving:Connect(function(p)
		Features.RemoveESP(p)
		RefreshPlayerList()
	end)
	table.insert(Storage.Connections, playerRemovingConn)
	
	AddDual(P4, "🔄 REFRESH", function() RefreshPlayerList() end, "👁️ UNSPECTATE", function() Features.StopSpectate() end, getOrder4)
	
	AddSection(P5, "DESYNC & ANTI-AIM", getOrder5)
	AddToggle(P5, "True Desync (Local)", "Desync", getOrder5)
	AddToggle(P5, "🛡️ Server Desync", "ServerDesync", getOrder5)
	AddSlider(P5, "Desync Radius", 1, 20, 5, function(v) Config.Vals.DesyncPower = v end, getOrder5)
	AddToggle(P5, "Anti-Aim Spin", "AntiAimSpin", getOrder5)
	AddToggle(P5, "Anti-Aim Head Jitter", "AntiAimHeadJitter", getOrder5)
	AddSlider(P5, "Spin Speed", 1, 30, 10, function(v) Config.Vals.AntiAimSpinSpeed = v end, getOrder5)
	AddSlider(P5, "Jitter Radius", 1, 20, 5, function(v) Config.Vals.AntiAimJitterRadius = v end, getOrder5)
	
	AddSection(P5, "SYSTEM", getOrder5)
	local UnloadBtn = Instance.new("TextButton", P5)
	UnloadBtn.LayoutOrder = getOrder5()
	UnloadBtn.Size = UDim2.new(1, -4, 0, 40); UnloadBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
	UnloadBtn.Text = "🗑️ UNLOAD SCRIPT (End)"; UnloadBtn.TextColor3 = Color3.new(1,1,1)
	UnloadBtn.Font = Enum.Font.GothamBlack; UnloadBtn.TextSize = 12
	Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)
	UnloadBtn.MouseButton1Click:Connect(function() Runtime.Unload() end)
	
	AddKeybindInfo(P6, "COMBAT", {{"Aimbot", "Right Click"}, {"TriggerBot", "T"}, {"Lock Target", "F (Press)"}}, getOrder6)
	AddKeybindInfo(P6, "MOVEMENT", {{"Fly Mode", "Z"}, {"Noclip", "V"}, {"Sky Hide", "X"}, {"Click TP", "Ctrl + Click"}, {"Destroy Map", "P"}, {"Restore Map", "L"}}, getOrder6)
	AddKeybindInfo(P6, "PLAYER & UI", {{"Open Menu", "Insert"}, {"Tactical TP", "B"}}, getOrder6)
	AddKeybindInfo(P6, "SYSTEM", {{"Unload Script", "End"}}, getOrder6)
end

-- ==============================================================================
-- CORE EXPLOIT HOOKS (V4.6.0 - P0 FIXED)
-- ==============================================================================
if not _G.X_TITAN_HOOK_INITIALIZED and type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
	_G.X_TITAN_HOOK_INITIALIZED = true
	local safeUnpack = table.unpack or unpack
	local oldNamecall
	
	oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local instance = _G.X_TITAN_CURRENT_INSTANCE
		if not instance then return oldNamecall(self, ...) end
		
		local CurrentConfig = instance.Config
		local CurrentStorage = instance.Storage
		local CurrentUtils = instance.Utils
		
		if CurrentStorage.IsUnloaded then return oldNamecall(self, ...) end
		
		local method = getnamecallmethod()
		local args = table.pack(...)
		local argN = args.n
		
		if CurrentConfig.States.AntiKillbrick and method == "TakeDamage" and self:IsA("Humanoid") and self:IsDescendantOf(LocalPlayer.Character) then
			return
		end
		
		if method == "Raycast" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" or method == "FindPartOnRay" then
			-- [P0 FIX] SilentAim Filter: Prevent breaking game interactions (doors, pickups, UI)
			local shouldProcessSilent = false
			if CurrentConfig.States.SilentAim then
				local origin = nil
				if method == "Raycast" then origin = args[1]
				else local ray = args[1]; origin = ray and ray.Origin end
				
				if origin then
					local myChar = LocalPlayer.Character
					local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
					local myTool = myChar and myChar:FindFirstChildOfClass("Tool")
					local toolHandle = myTool and myTool:FindFirstChild("Handle")
					
					-- Check if ray originates from player's weapon or hand area
					if myHRP and origin then
						local distToHRP = (origin - myHRP.Position).Magnitude
						local distToTool = toolHandle and (origin - toolHandle.Position).Magnitude or math.huge
						if distToHRP < 10 or distToTool < 5 then
							shouldProcessSilent = true
						end
					end
					
					-- Optional: getcallingscript check if available
					if type(getcallingscript) == "function" then
						local calling = getcallingscript()
						if calling then
							local n = string.lower(calling.Name)
							if n:find("gun") or n:find("weapon") or n:find("shoot") or n:find("client") or n:find("fire") then
								shouldProcessSilent = true
							elseif n:find("ui") or n:find("door") or n:find("interact") or n:find("pickup") then
								shouldProcessSilent = false
							end
						end
					end
				end
			end
			
			if shouldProcessSilent then
				local target, isWall = CurrentUtils.GetClosestToCenter()
				if target and target.Parent then
					local head = target.Parent:FindFirstChild("Head")
					local eRoot = target.Parent:FindFirstChild("HumanoidRootPart")
					if head then
						local predPos = head.Position
						if eRoot then predPos = predPos + (eRoot.AssemblyLinearVelocity * CurrentConfig.Vals.PredictionStrength) end
						if method == "Raycast" then
							local origin = args[1]; local direction = (predPos - origin).Unit * 5000; args[2] = direction
						else
							local ray = args[1]; local origin = ray.Origin; local direction = (predPos - origin).Unit * 5000
							args[1] = Ray.new(origin, direction)
						end
					end
				end
			end
			
			local results = table.pack(oldNamecall(self, safeUnpack(args, 1, argN)))
			if results.n > 0 and results[1] then
				local hitInstance = nil
				local r1 = results[1]
				if typeof(r1) == "RaycastResult" then
					hitInstance = r1.Instance
				elseif type(r1) == "table" and r1.Instance then
					hitInstance = r1.Instance
				elseif typeof(r1) == "Instance" then
					hitInstance = r1
				end
				if hitInstance then
					local hitChar = hitInstance:FindFirstAncestorOfClass("Model")
					local hitHum = hitChar and hitChar:FindFirstChildOfClass("Humanoid")
					if hitHum and hitHum.Health > 0 and hitChar ~= LocalPlayer.Character then
						local hitPlr = Services.Players:GetPlayerFromCharacter(hitChar)
						if not CurrentConfig.States.TeamCheck or not CurrentUtils.IsTeammate(hitPlr) then
							CurrentStorage.HitmarkerAlpha = 1.0
						end
					end
				end
			end
			return safeUnpack(results, 1, results.n)
		end
		return oldNamecall(self, ...)
	end)
	Storage.HookActive = true
	Storage.HookOldNamecall = oldNamecall
end

local auraLoop = task.spawn(function()
	while task.wait(0.05) do
		if Storage.IsUnloaded then break end
		local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then Storage.AuraTarget = nil; continue end
		local target = Features.GetAuraTarget(); Storage.AuraTarget = target
		if target and target:FindFirstChild("HumanoidRootPart") then
			if Config.States.TPAura then
				hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, -Config.Vals.TPBehindDist)
				hrp.AssemblyLinearVelocity = Vector3.zero
			end
			if Config.States.KillAura or Config.States.TPAura then
				local tool = char:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end
				hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(target.HumanoidRootPart.Position.X, hrp.Position.Y, target.HumanoidRootPart.Position.Z))
			end
		else Storage.AuraTarget = nil end
	end
end)
table.insert(Storage.Loops, auraLoop)

-- ==============================================================================
-- RUNTIME (V4.6.0)
-- ==============================================================================
local Runtime = {}
function Runtime.Unload()
	Utils.Notify("⚠️ Unload", "Unloading X TITAN V4.6.0...")
	Storage.IsUnloaded = true
	for _, loop in pairs(Storage.Loops) do pcall(function() task.cancel(loop) end) end
	Storage.Loops = {}
	for _, conn in pairs(Storage.Connections) do pcall(function() conn:Disconnect() end) end
	Storage.Connections = {}
	for k, _ in pairs(Config.States) do Config.States[k] = false end
	
	local char = LocalPlayer.Character
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			for _, name in ipairs({"X_Fly_LV", "X_Hide_LV", "X_Speed_LV"}) do
				local old = hrp:FindFirstChild(name); if old then old:Destroy() end
			end
			local rootAtt = hrp:FindFirstChild("RootAttachment")
			if rootAtt and rootAtt:GetAttribute("X_TitanOwned") then
				rootAtt:Destroy()
			end
		end
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			hum.WalkSpeed = Storage.OriginalWalkSpeed
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
		end
		Utils.RestoreCollision(char, "collide")
		Utils.RestoreCollision(char, "touch")
	end
	
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p.Character then
			for _, partName in ipairs({"Head", "Torso", "UpperTorso", "HumanoidRootPart"}) do
				local part = p.Character:FindFirstChild(partName)
				if part and part:GetAttribute("OrigSize") ~= nil then
					part.Size = part:GetAttribute("OrigSize")
					local ot = part:GetAttribute("OrigTransparency")
					part.Transparency = (ot ~= nil) and ot or 0
					local oc = part:GetAttribute("OrigCanCollide")
					if oc ~= nil then part.CanCollide = oc end
					local om = part:GetAttribute("OrigMassless")
					if om ~= nil then part.Massless = om end
					part:SetAttribute("OrigSize", nil); part:SetAttribute("OrigTransparency", nil)
					part:SetAttribute("OrigCanCollide", nil); part:SetAttribute("OrigMassless", nil)
				end
			end
		end
	end
	
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p.Character then
			local chams = p.Character:FindFirstChild("X_Chams")
			if chams then chams:Destroy() end
		end
	end
	
	Utils.ToggleXRay(false); Utils.ToggleFullbright(false)
	for plr, esp in pairs(Storage.ESPObjects) do for _, d in pairs(esp) do pcall(function() d:Remove() end) end end
	for plr, skel in pairs(Storage.SkeletonParts) do for _, d in pairs(skel) do pcall(function() d:Remove() end) end end
	for _, l in pairs(Storage.TracerLines) do pcall(function() l:Remove() end) end
	for _, line in pairs(Storage.CrosshairLines) do if line then pcall(function() line:Remove() end) end end
	for _, line in pairs(Storage.HitmarkerLines) do if line then pcall(function() line:Remove() end) end end
	
	if Storage.OriginalLighting.Ambient then
		Services.Lighting.Ambient = Storage.OriginalLighting.Ambient
		Services.Lighting.Brightness = Storage.OriginalLighting.Brightness
		Services.Lighting.OutdoorAmbient = Storage.OriginalLighting.OutdoorAmbient
		Services.Lighting.ClockTime = Storage.OriginalLighting.ClockTime
		Services.Lighting.FogEnd = Storage.OriginalLighting.FogEnd
		Services.Lighting.FogStart = Storage.OriginalLighting.FogStart
	end
	
	Services.Workspace.FallenPartsDestroyHeight = Storage.OriginalFallenHeight or -500
	if #Storage.DestroyedParts > 0 then
		for _, data in pairs(Storage.DestroyedParts) do
			if data.Part and data.Parent then pcall(function() data.Part.Parent = data.Parent end) end
		end
		table.clear(Storage.DestroyedParts)
	end
	if Storage.MapStorageFolder then Storage.MapStorageFolder:Destroy(); Storage.MapStorageFolder = nil end
	
	Storage.CurrentSpectate = nil
	local cam = Utils.GetCurrentCamera()
	if cam and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		cam.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
	end
	
	if Storage.RadarGui then Storage.RadarGui:Destroy() end
	for _, gui in pairs(targetGui:GetChildren()) do
		if string.find(gui.Name, "X_TITAN") or string.find(gui.Name, "X_FOV") or string.find(gui.Name, "X_RADAR") or string.find(gui.Name, "X_TacticalHUD") then
			gui:Destroy()
		end
	end
	
	Storage.LockedTarget = nil; Storage.AuraTarget = nil
	Storage.LastTargetVel = {}; Storage.LastTargetTick = {}
	Storage.ESPObjects = {}; Storage.SkeletonParts = {}; Storage.TracerLines = {}
	Storage.RadarObjects = {}
	print("X TITAN V4.6.0 UNLOADED SUCCESSFULLY")
end

local function InitRadar()
	if Storage.RadarGui then return end
	local RadarGui = Instance.new("ScreenGui", targetGui)
	RadarGui.Name = "X_RADAR_V458"; RadarGui.IgnoreGuiInset = true; RadarGui.DisplayOrder = 9999998
	Storage.RadarGui = RadarGui
	
	local RadarFrame = Instance.new("Frame", RadarGui)
	RadarFrame.Size = UDim2.new(0, 180, 0, 180); RadarFrame.Position = UDim2.new(1, -200, 1, -200)
	RadarFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0); RadarFrame.BackgroundTransparency = 0.7
	RadarFrame.Visible = Config.States.Radar
	Instance.new("UICorner", RadarFrame).CornerRadius = UDim.new(1, 0)
	local RadarStroke = Instance.new("UIStroke", RadarFrame); RadarStroke.Color = Config.Theme.Stroke; RadarStroke.Thickness = 2
	Storage.RadarFrame = RadarFrame
	
	local CenterDot = Instance.new("Frame", RadarFrame)
	CenterDot.Size = UDim2.new(0, 5, 0, 5); CenterDot.Position = UDim2.new(0.5, -2.5, 0.5, -2.5)
	CenterDot.BackgroundColor3 = Config.Theme.Stroke; Instance.new("UICorner", CenterDot).CornerRadius = UDim.new(1, 0)
	
	local radarInputConn = RadarFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mousePos = input.Position; local radarPos = RadarFrame.AbsolutePosition
			local center = Vector2.new(radarPos.X + 90, radarPos.Y + 90)
			local clickPos = Vector2.new(mousePos.X - center.X, mousePos.Y - center.Y)
			local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not myHRP then return end
			
			local closestPlr, closestScore = nil, math.huge
			for _, p in pairs(Services.Players:GetPlayers()) do
				if p == LocalPlayer or not p.Character then continue end
				local eHRP = p.Character:FindFirstChild("HumanoidRootPart")
				if not eHRP then continue end
				local relativePos = myHRP.CFrame:PointToObjectSpace(eHRP.Position)
				local dist = math.sqrt(relativePos.X^2 + relativePos.Z^2)
				if dist > Config.Vals.RadarRange then continue end
				local scale = 90 / Config.Vals.RadarRange
				local x = relativePos.X * scale; local z = -relativePos.Z * scale
				local dotPos = Vector2.new(x, z)
				local score = (dotPos - clickPos).Magnitude
				if score < 15 and score < closestScore then closestScore = score; closestPlr = p end
			end
			if closestPlr then
				Storage.LockedTarget = closestPlr; Storage.CurrentHPRatio = 0
				Utils.Notify("🎯 Radar Lock", "Target locked: " .. closestPlr.Name)
			end
		end
	end)
	table.insert(Storage.Connections, radarInputConn)
end

local function UpdateRadar()
	if not Storage.RadarFrame then return end
	Storage.RadarFrame.Visible = Config.States.Radar
	if not Config.States.Radar then return end
	
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	
	for plr, obj in pairs(Storage.RadarObjects) do
		if not Services.Players:FindFirstChild(plr.Name) or not plr.Character then
			pcall(function() obj:Destroy() end); Storage.RadarObjects[plr] = nil
		else obj.Visible = false end
	end
	
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p == LocalPlayer or not p.Character then continue end
		local eHRP = p.Character:FindFirstChild("HumanoidRootPart")
		if not eHRP then continue end
		local relativePos = myHRP.CFrame:PointToObjectSpace(eHRP.Position)
		local dist = math.sqrt(relativePos.X^2 + relativePos.Z^2)
		if dist > Config.Vals.RadarRange then
			local obj = Storage.RadarObjects[p]; if obj then obj.Visible = false end; continue
		end
		local obj = Storage.RadarObjects[p]
		if not obj then
			obj = Instance.new("Frame", Storage.RadarFrame)
			obj.Size = UDim2.new(0, 5, 0, 5); obj.AnchorPoint = Vector2.new(0.5, 0.5)
			Instance.new("UICorner", obj).CornerRadius = UDim.new(1, 0)
			Storage.RadarObjects[p] = obj
		end
		local scale = 90 / Config.Vals.RadarRange
		local x = relativePos.X * scale; local z = -relativePos.Z * scale
		obj.Position = UDim2.new(0.5, x, 0.5, z); obj.Visible = true
		if Utils.IsTeammate(p) then obj.BackgroundColor3 = Config.Theme.Team
		elseif Utils.IsVisible(p.Character:FindFirstChild("Head")) then obj.BackgroundColor3 = Config.Theme.LockColor
		else obj.BackgroundColor3 = Config.Theme.TextDim end
	end
end

function Runtime.Init()
	if _G.X_TITAN_RUNTIME_INITIALIZED then
		print("X TITAN: Detected existing instance, unloading first...")
		local oldInstance = _G.X_TITAN_CURRENT_INSTANCE
		if oldInstance and oldInstance.Storage and not oldInstance.Storage.IsUnloaded then
			pcall(function()
				oldInstance.Storage.IsUnloaded = true
				for _, loop in pairs(oldInstance.Storage.Loops) do pcall(function() task.cancel(loop) end) end
				for _, conn in pairs(oldInstance.Storage.Connections) do pcall(function() conn:Disconnect() end) end
			end)
		end
	end
	_G.X_TITAN_RUNTIME_INITIALIZED = true
	Storage.IsUnloaded = false
	
	if LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
		if hum then Storage.OriginalWalkSpeed = hum.WalkSpeed end
	end
	Storage.OriginalFallenHeight = Services.Workspace.FallenPartsDestroyHeight
	
	local FOVGui = Instance.new("ScreenGui", targetGui); FOVGui.Name = "X_FOV_V458"; FOVGui.IgnoreGuiInset = true; FOVGui.DisplayOrder = 9999999
	local FOVFrame = Instance.new("Frame", FOVGui)
	FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5); FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	FOVFrame.BackgroundTransparency = 1; FOVFrame.Visible = false
	local FStroke = Instance.new("UIStroke", FOVFrame); FStroke.Color = Config.Theme.Stroke; FStroke.Thickness = 1.5
	Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0); Storage.FOVRingUI = FOVFrame
	
	local TacticalHUDGui = Instance.new("ScreenGui", targetGui)
	TacticalHUDGui.Name = "X_TacticalHUD_V458"; TacticalHUDGui.IgnoreGuiInset = true; TacticalHUDGui.DisplayOrder = 9999998
	local MainPanel = Instance.new("Frame", TacticalHUDGui)
	MainPanel.Size = UDim2.new(0, 260, 0, 75); MainPanel.AnchorPoint = Vector2.new(0.5, 0)
	MainPanel.Position = UDim2.new(0.5, 0, 0.65, 0); MainPanel.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
	MainPanel.BackgroundTransparency = 0.15; MainPanel.Visible = false
	Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 6)
	local PanelStroke = Instance.new("UIStroke", MainPanel); PanelStroke.Color = Config.Theme.Stroke; PanelStroke.Thickness = 1.5
	local Header = Instance.new("TextLabel", MainPanel)
	Header.Size = UDim2.new(1, -10, 0, 22); Header.Position = UDim2.new(0, 5, 0, 5)
	Header.BackgroundTransparency = 1; Header.Font = Enum.Font.GothamBlack; Header.TextSize = 13
	Header.TextXAlignment = Enum.TextXAlignment.Left; Header.TextColor3 = Config.Theme.Text
	local HPBarBG = Instance.new("Frame", MainPanel)
	HPBarBG.Size = UDim2.new(1, -10, 0, 8); HPBarBG.Position = UDim2.new(0, 5, 0, 32)
	HPBarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 45); Instance.new("UICorner", HPBarBG).CornerRadius = UDim.new(1, 0)
	local HPBarFill = Instance.new("Frame", HPBarBG)
	HPBarFill.Size = UDim2.new(1, 0, 1, 0); HPBarFill.BackgroundColor3 = Config.Theme.Stroke; Instance.new("UICorner", HPBarFill).CornerRadius = UDim.new(1, 0)
	local Footer = Instance.new("TextLabel", MainPanel)
	Footer.Size = UDim2.new(1, -10, 0, 18); Footer.Position = UDim2.new(0, 5, 0, 48)
	Footer.BackgroundTransparency = 1; Footer.Font = Enum.Font.GothamBold; Footer.TextSize = 11
	Footer.TextXAlignment = Enum.TextXAlignment.Left; Footer.TextColor3 = Config.Theme.TextDim
	Storage.TacticalHUD = {Main = MainPanel, Stroke = PanelStroke, Header = Header, HPFill = HPBarFill, Footer = Footer}
	
	if Drawing then
		local function createLine() local l = Drawing.new("Line"); l.Thickness = 1.5; l.Color = Config.Theme.Stroke; l.Visible = false; return l end
		Storage.CrosshairLines.Top = createLine(); Storage.CrosshairLines.Bottom = createLine()
		Storage.CrosshairLines.Left = createLine(); Storage.CrosshairLines.Right = createLine()
		local hm1, hm2, hm3, hm4 = createLine(), createLine(), createLine(), createLine()
		hm1.Color = Color3.new(1,1,1); hm2.Color = Color3.new(1,1,1); hm3.Color = Color3.new(1,1,1); hm4.Color = Color3.new(1,1,1)
		Storage.HitmarkerLines.TL = hm1; Storage.HitmarkerLines.TR = hm2
		Storage.HitmarkerLines.BL = hm3; Storage.HitmarkerLines.BR = hm4
	end
	
	for _, p in pairs(Services.Players:GetPlayers()) do pcall(function() Features.CreateESP(p) end) end
	UI.Init()
	InitRadar()
	
	local espAddedConn = Services.Players.PlayerAdded:Connect(function(p) task.wait(1); Features.CreateESP(p) end)
	table.insert(Storage.Connections, espAddedConn)
	local espRemovedConn = Services.Players.PlayerRemoving:Connect(function(p) Features.RemoveESP(p) end)
	table.insert(Storage.Connections, espRemovedConn)
	
	local respawnConn = LocalPlayer.CharacterAdded:Connect(function(char)
		local hum = char:FindFirstChild("Humanoid")
		if hum and not Config.States.SpeedHack then
			Storage.OriginalWalkSpeed = hum.WalkSpeed
			Storage.WalkSpeedSnapshotPending = false,
	LastSafeCFrame = nil,
	HitSoundObj = nil
		else
			Storage.WalkSpeedSnapshotPending = true
			local humanoidAddedConn
			humanoidAddedConn = char.ChildAdded:Connect(function(child)
				if child:IsA("Humanoid") and not Config.States.SpeedHack then
					Storage.OriginalWalkSpeed = child.WalkSpeed
					Storage.WalkSpeedSnapshotPending = false,
	LastSafeCFrame = nil,
	HitSoundObj = nil
					humanoidAddedConn:Disconnect()
				end
			end)
			task.delay(5, function()
				if humanoidAddedConn then pcall(function() humanoidAddedConn:Disconnect() end) end
				Storage.WalkSpeedSnapshotPending = false,
	LastSafeCFrame = nil,
	HitSoundObj = nil
			end)
		end
		task.wait(1)
		Storage.IsHiding = false; Storage.HideCFrame = nil
		Storage.LockedTarget = nil; Storage.CurrentHPRatio = 0
		if Storage.TacticalHUD then Storage.TacticalHUD.Main.Visible = false end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			for _, name in ipairs({"X_Fly_LV", "X_Hide_LV", "X_Speed_LV"}) do
				local old = hrp:FindFirstChild(name); if old then old:Destroy() end
			end
			local rootAtt = hrp:FindFirstChild("RootAttachment")
			if rootAtt and rootAtt:GetAttribute("X_TitanOwned") then rootAtt:Destroy() end
		end
		Utils.RestoreCollision(char, "collide")
		Utils.RestoreCollision(char, "touch")
		if Config.States.Chams then Features.UpdateChams() end
	end)
	table.insert(Storage.Connections, respawnConn)
	
	-- ======================================================================
	-- RENDERSTEPPED (V4.6.0 - P2 FIXED: Target Caching)
	-- ======================================================================
	local renderConn = Services.RunService.RenderStepped:Connect(function()
		local CurrentCam = Utils.GetCurrentCamera()
		if not CurrentCam then return end
		local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local center = Vector2.new(CurrentCam.ViewportSize.X/2, CurrentCam.ViewportSize.Y/2)
		
		-- [P2 FIX] Cache target calculation to save CPU
		local cachedTarget, cachedIsWall = nil, false
		if Config.States.Aimbot or Config.States.TriggerBot or Config.States.ShowFOV or Storage.LockedTarget then
			cachedTarget, cachedIsWall = Utils.GetClosestToCenter()
		end
		
		if Storage.FOVRingUI then
			Storage.FOVRingUI.Visible = Config.States.ShowFOV
			if Config.States.ShowFOV then
				Storage.FOVRingUI.Size = UDim2.new(0, Config.Vals.FOV * 2, 0, Config.Vals.FOV * 2)
				if cachedTarget then 
					Storage.FOVRingUI.UIStroke.Color = cachedIsWall and Config.Theme.WallColor or Config.Theme.LockColor
				else 
					Storage.FOVRingUI.UIStroke.Color = Config.Theme.Stroke 
				end
			end
		end
		
		if Storage.TacticalHUD then
			local showHUD = Config.States.ShowLockStatus and Storage.LockedTarget ~= nil
			Storage.TacticalHUD.Main.Visible = showHUD
			if showHUD and Storage.LockedTarget.Character then
				local lockedPlr = Storage.LockedTarget
				local hum = lockedPlr.Character:FindFirstChild("Humanoid")
				local hrp_t = lockedPlr.Character:FindFirstChild("HumanoidRootPart")
				local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if hum and hrp_t and myHRP then
					local dist = math.floor((hrp_t.Position - myHRP.Position).Magnitude)
					local targetRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
					Storage.CurrentHPRatio = Storage.CurrentHPRatio + (targetRatio - Storage.CurrentHPRatio) * 0.2
					local hpColor = Color3.new(1 - Storage.CurrentHPRatio, Storage.CurrentHPRatio, 0)
					Storage.TacticalHUD.HPFill.Size = UDim2.new(Storage.CurrentHPRatio, 0, 1, 0)
					Storage.TacticalHUD.HPFill.BackgroundColor3 = hpColor
					local threat, tColor = "LOW", Config.Theme.ThreatLow
					if dist < 30 then threat, tColor = "HIGH", Config.Theme.ThreatHigh
					elseif dist < 80 then threat, tColor = "MED", Config.Theme.ThreatMed end
					local breath = math.sin(tick() * 3) * 0.2 + 0.8
					if threat == "HIGH" then tColor = Color3.fromRGB(255, 40 * breath, 40 * breath)
					elseif threat == "MED" then tColor = Color3.fromRGB(255, 180 * breath, 0) end
					Storage.TacticalHUD.Header.Text = string.format("[%s] %s", threat, lockedPlr.Name)
					Storage.TacticalHUD.Header.TextColor3 = tColor
					Storage.TacticalHUD.Footer.Text = string.format("DIST: %dm | AIM: %s", dist, Config.Vals.AimPart)
					Storage.TacticalHUD.Stroke.Color = tColor
				end
			end
		end
		
		if Drawing then
			local spread = 6
			local crosshairColor = Config.Theme.Stroke
			if Config.States.DynamicCrosshair then
				if Config.States.Fly or Config.States.SpeedHack then spread = 18
				elseif hrp and hrp.AssemblyLinearVelocity.Magnitude > 10 then spread = 12 end
				if Storage.LockedTarget or Config.States.Aimbot then spread = 2; crosshairColor = Config.Theme.LockColor end
			end
			local showCross = Config.States.Crosshair or Config.States.DynamicCrosshair
			local t, b, l, r = Storage.CrosshairLines.Top, Storage.CrosshairLines.Bottom, Storage.CrosshairLines.Left, Storage.CrosshairLines.Right
			if showCross then
				t.Visible = true; t.From = Vector2.new(center.X, center.Y - spread - 4); t.To = Vector2.new(center.X, center.Y - spread); t.Color = crosshairColor
				b.Visible = true; b.From = Vector2.new(center.X, center.Y + spread + 4); b.To = Vector2.new(center.X, center.Y + spread); b.Color = crosshairColor
				l.Visible = true; l.From = Vector2.new(center.X - spread - 4, center.Y); l.To = Vector2.new(center.X - spread, center.Y); l.Color = crosshairColor
				r.Visible = true; r.From = Vector2.new(center.X + spread + 4, center.Y); r.To = Vector2.new(center.X + spread, center.Y); r.Color = crosshairColor
			else
				t.Visible = false; b.Visible = false; l.Visible = false; r.Visible = false
			end
			
			if Storage.HitmarkerAlpha > 0 then
				local hmSize = 6 + (1 - Storage.HitmarkerAlpha) * 4
				local hmColor = Color3.new(1, 1, 1)
				local tl = Storage.HitmarkerLines.TL
				local tr = Storage.HitmarkerLines.TR
				local bl = Storage.HitmarkerLines.BL
				local br = Storage.HitmarkerLines.BR
				tl.Visible = true; tl.From = Vector2.new(center.X - hmSize, center.Y - hmSize); tl.To = Vector2.new(center.X - 2, center.Y - 2); tl.Color = hmColor
				tr.Visible = true; tr.From = Vector2.new(center.X + hmSize, center.Y - hmSize); tr.To = Vector2.new(center.X + 2, center.Y - 2); tr.Color = hmColor
				bl.Visible = true; bl.From = Vector2.new(center.X - hmSize, center.Y + hmSize); bl.To = Vector2.new(center.X - 2, center.Y + 2); bl.Color = hmColor
				br.Visible = true; br.From = Vector2.new(center.X + hmSize, center.Y + hmSize); br.To = Vector2.new(center.X + 2, center.Y + 2); br.Color = hmColor
				Storage.HitmarkerAlpha = math.max(0, Storage.HitmarkerAlpha - 0.05)
			else
				for _, line in pairs(Storage.HitmarkerLines) do line.Visible = false end
			end
		end
		
		UpdateRadar()
		
		if Config.States.ServerDesync and Storage.RealCFrame and hrp then hrp.CFrame = Storage.RealCFrame end
		if Config.States.Desync and hrp and Storage.RealCFrame and not Config.States.ServerDesync then
			hrp.CFrame = Storage.RealCFrame; hrp.AssemblyLinearVelocity = Storage.RealVelocity
		end
		
		if Config.States.TPAura and Storage.AuraTarget and Storage.AuraTarget:FindFirstChild("HumanoidRootPart") then
			CurrentCam.CFrame = CFrame.lookAt(CurrentCam.CFrame.Position, Storage.AuraTarget.HumanoidRootPart.Position)
		end
		
		if Storage.CurrentSpectate then
			local tChar = Storage.CurrentSpectate.Character
			if tChar and Services.Players:FindFirstChild(Storage.CurrentSpectate.Name) then
				local tHum = tChar:FindFirstChild("Humanoid")
				if tHum and tHum.Health > 0 then
					if CurrentCam.CameraSubject ~= tHum then CurrentCam.CameraSubject = tHum end
				else Features.StopSpectate() end
			else Features.StopSpectate() end
		end
		
		if Config.States.Aimbot then
			-- Use cached target
			if cachedTarget and cachedTarget.Parent then
				local targetPos = cachedTarget.Position
				local eRoot = cachedTarget.Parent:FindFirstChild("HumanoidRootPart")
				local predTime = Config.Vals.PredictionStrength
				if Config.States.SmartPrediction then
					local ping = Utils.GetPing() / 1000; predTime = predTime + ping * Config.Vals.PingCompensation
				end
				if eRoot then
					local currentVel = eRoot.AssemblyLinearVelocity
					local prevVel = Storage.LastTargetVel[eRoot] or currentVel
					local currentTick = tick(); local lastTick = Storage.LastTargetTick[eRoot] or currentTick
					local dt = math.max(currentTick - lastTick, 0.001); Storage.LastTargetTick[eRoot] = currentTick
					local accel = (currentVel - prevVel) / dt; Storage.LastTargetVel[eRoot] = currentVel
					targetPos = targetPos + (currentVel * predTime) + (0.5 * accel * predTime * predTime)
				end
				local screenPos, onScreen = CurrentCam:WorldToViewportPoint(targetPos)
				local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
				if screenDist < Config.Vals.Deadzone then
					CurrentCam.CFrame = CFrame.lookAt(CurrentCam.CFrame.Position, targetPos)
				else
					local baseSmooth = Config.Vals.AimbotSmoothness; local dynamicAlpha = 1.0 - baseSmooth
					if screenDist > 150 then dynamicAlpha = math.clamp(dynamicAlpha + 0.4, 0.15, 1.0)
					elseif screenDist < 30 then dynamicAlpha = math.clamp(dynamicAlpha - 0.2, 0.05, 1.0) end
					CurrentCam.CFrame = CurrentCam.CFrame:Lerp(CFrame.lookAt(CurrentCam.CFrame.Position, targetPos), dynamicAlpha)
				end
			end
		end
		
		if Config.States.TriggerBot then
			-- Use cached target
			if cachedTarget and cachedTarget.Parent and (not Config.States.WallCheck or Utils.IsVisible(cachedTarget)) then
				if tick() - Storage.TriggerBotCooldown > Config.Vals.TriggerDelay then
					mouse1click(); Storage.TriggerBotCooldown = tick()
				end
			end
		end
		
		for plr, esp in pairs(Storage.ESPObjects) do
			local pChar = plr.Character; local root = pChar and pChar:FindFirstChild("HumanoidRootPart")
			local head = pChar and pChar:FindFirstChild("Head"); local hum = pChar and pChar:FindFirstChild("Humanoid")
			esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false; esp.Distance.Visible = false
			if Storage.SkeletonParts[plr] then for _, part in pairs(Storage.SkeletonParts[plr]) do part.Visible = false end end
			if Storage.TracerLines[plr] then Storage.TracerLines[plr].Visible = false end
			if pChar and root and head and hum and hum.Health > 0 then
				local vector, onScreen = CurrentCam:WorldToViewportPoint(root.Position)
				local drawColor = Config.Theme.Stroke
				if Storage.LockedTarget == plr then drawColor = Config.Theme.LockColor
				elseif Config.States.TeamCheck and Utils.IsTeammate(plr) then drawColor = Config.Theme.Team end
				if Config.States.VisibilityCheck and not Utils.IsVisible(head) then drawColor = Color3.new(0.5, 0.5, 0.5) end
				if Config.States.Tracers then
					local from = Vector2.new(CurrentCam.ViewportSize.X/2, CurrentCam.ViewportSize.Y/2)
					local to = Vector2.new(vector.X, vector.Y)
					if not onScreen then
						local dir = to - from
						if dir.Magnitude > 0 then
							local t = math.huge
							if dir.X > 0 then t = math.min(t, (CurrentCam.ViewportSize.X - from.X) / dir.X)
							elseif dir.X < 0 then t = math.min(t, -from.X / dir.X) end
							if dir.Y > 0 then t = math.min(t, (CurrentCam.ViewportSize.Y - from.Y) / dir.Y)
							elseif dir.Y < 0 then t = math.min(t, -from.Y / dir.Y) end
							to = from + dir * t
						end
					end
					local ln = Storage.TracerLines[plr] or Drawing.new("Line"); Storage.TracerLines[plr] = ln
					ln.Visible = true; ln.Thickness = 1.5; ln.Color = drawColor; ln.From = from; ln.To = to
				end
				if onScreen then
					local headPos = CurrentCam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
					local height = math.abs(headPos.Y - CurrentCam:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
					local width = height / 1.8; local boxX = vector.X - width/2; local boxY = vector.Y - height/2
					if Config.States.ESP then
						esp.Box.Visible = true; esp.Box.Size = Vector2.new(width, height); esp.Box.Position = Vector2.new(boxX, boxY); esp.Box.Color = drawColor
						esp.Name.Visible = true; esp.Name.Text = plr.Name; esp.Name.Position = Vector2.new(vector.X, boxY - 18); esp.Name.Color = drawColor
						esp.HealthBar.Visible = true; local healthRatio = hum.Health / hum.MaxHealth
						esp.HealthBar.Color = Color3.new(1 - healthRatio, healthRatio, 0)
						esp.HealthBar.From = Vector2.new(boxX - 5, boxY + height); esp.HealthBar.To = Vector2.new(boxX - 5, boxY + height - height * healthRatio)
						esp.Distance.Visible = true; esp.Distance.Text = string.format("%.0fm", (root.Position - (hrp and hrp.Position or root.Position)).Magnitude)
						esp.Distance.Position = Vector2.new(vector.X, boxY + height + 5); esp.Distance.Color = drawColor
					end
					if Config.States.ESPSkeleton and Storage.SkeletonParts[plr] then
						local torso = pChar:FindFirstChild("Torso") or pChar:FindFirstChild("UpperTorso") or root
						local lArm = pChar:FindFirstChild("Left Arm") or pChar:FindFirstChild("LeftUpperArm")
						local rArm = pChar:FindFirstChild("Right Arm") or pChar:FindFirstChild("RightUpperArm")
						local lLeg = pChar:FindFirstChild("Left Leg") or pChar:FindFirstChild("LeftUpperLeg")
						local rLeg = pChar:FindFirstChild("Right Leg") or pChar:FindFirstChild("RightUpperLeg")
						local torsoPos = CurrentCam:WorldToViewportPoint(torso.Position)
						local lArmPos = lArm and CurrentCam:WorldToViewportPoint(lArm.Position) or Vector2.new(torsoPos.X - 20, torsoPos.Y)
						local rArmPos = rArm and CurrentCam:WorldToViewportPoint(rArm.Position) or Vector2.new(torsoPos.X + 20, torsoPos.Y)
						local lLegPos = lLeg and CurrentCam:WorldToViewportPoint(lLeg.Position) or Vector2.new(torsoPos.X - 10, torsoPos.Y + 30)
						local rLegPos = rLeg and CurrentCam:WorldToViewportPoint(rLeg.Position) or Vector2.new(torsoPos.X + 10, torsoPos.Y + 30)
						local skel = Storage.SkeletonParts[plr]
						skel.HeadToTorso.Visible = true; skel.HeadToTorso.From = Vector2.new(headPos.X, headPos.Y); skel.HeadToTorso.To = Vector2.new(torsoPos.X, torsoPos.Y); skel.HeadToTorso.Color = drawColor
						skel.TorsoToLeftArm.Visible = true; skel.TorsoToLeftArm.From = Vector2.new(torsoPos.X, torsoPos.Y); skel.TorsoToLeftArm.To = Vector2.new(lArmPos.X, lArmPos.Y); skel.TorsoToLeftArm.Color = drawColor
						skel.TorsoToRightArm.Visible = true; skel.TorsoToRightArm.From = Vector2.new(torsoPos.X, torsoPos.Y); skel.TorsoToRightArm.To = Vector2.new(rArmPos.X, rArmPos.Y); skel.TorsoToRightArm.Color = drawColor
						skel.TorsoToLeftLeg.Visible = true; skel.TorsoToLeftLeg.From = Vector2.new(torsoPos.X, torsoPos.Y); skel.TorsoToLeftLeg.To = Vector2.new(lLegPos.X, lLegPos.Y); skel.TorsoToLeftLeg.Color = drawColor
						skel.TorsoToRightLeg.Visible = true; skel.TorsoToRightLeg.From = Vector2.new(torsoPos.X, torsoPos.Y); skel.TorsoToRightLeg.To = Vector2.new(rLegPos.X, rLegPos.Y); skel.TorsoToRightLeg.Color = drawColor
					end
				end
			end
		end
	end)
	table.insert(Storage.Connections, renderConn)
	
	-- ======================================================================
	-- HEARTBEAT (V4.6.0: P1 FIXED - dt math & Fly/Desync Mutex)
	-- ======================================================================
	local heartbeatConn = Services.RunService.Heartbeat:Connect(function(dt)
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		if not hrp or not hum then return end
		
		if Storage.WalkSpeedSnapshotPending and not Config.States.SpeedHack then
			local currentHum = char:FindFirstChild("Humanoid")
			if currentHum then
				Storage.OriginalWalkSpeed = currentHum.WalkSpeed
				Storage.WalkSpeedSnapshotPending = false,
	LastSafeCFrame = nil,
	HitSoundObj = nil
			end
		end
		
		if Config.States.NoFall then
			if hrp.AssemblyLinearVelocity.Y < -30 then
				hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -30, hrp.AssemblyLinearVelocity.Z)
			end
		end
		
		-- [P1 FIX] Fly + Desync Mutual Exclusion
		local isActuatorActive = Config.States.Fly or Storage.IsHiding
		if not isActuatorActive then
			if Config.States.ServerDesync then
				Storage.RealCFrame = hrp.CFrame; local rad = Config.Vals.DesyncPower
				hrp.CFrame = hrp.CFrame * CFrame.new(math.random(-rad, rad), math.random(-rad/2, rad/2), math.random(-rad, rad))
			elseif Config.States.Desync then
				Storage.RealCFrame = hrp.CFrame; Storage.RealVelocity = hrp.AssemblyLinearVelocity; local rad = Config.Vals.DesyncPower
				hrp.CFrame = hrp.CFrame * CFrame.new(math.random(-rad, rad), math.random(-rad/2, rad/2), math.random(-rad, rad))
			end
		end
		
		if Config.States.AntiAimSpin then
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(tick() * Config.Vals.AntiAimSpinSpeed % 360), 0)
		end
		if Config.States.AntiAimHeadJitter then
			local head = char:FindFirstChild("Head")
			if head then
				head.CFrame = head.CFrame * CFrame.new(Vector3.new(
					math.random(-Config.Vals.AntiAimJitterRadius, Config.Vals.AntiAimJitterRadius),
					math.random(-Config.Vals.AntiAimJitterRadius, Config.Vals.AntiAimJitterRadius),
					math.random(-Config.Vals.AntiAimJitterRadius, Config.Vals.AntiAimJitterRadius)
				) * 0.1)
			end
		end
		
		if Config.States.Hitbox or Config.States.HeadExpander then Features.UpdateHitboxes() end
		
		local rootAtt = hrp:FindFirstChild("RootAttachment")
		if not rootAtt then
			rootAtt = Instance.new("Attachment", hrp); rootAtt.Name = "RootAttachment"
			rootAtt:SetAttribute("X_TitanOwned", true)
			Storage.RootAttachmentOwned = true
		end
		
		-- [P2 FIX] Optimized Collision Loop
		local needsNoCollide = Config.States.Noclip or Config.States.Fly or Storage.IsHiding
		local needsNoTouch = Config.States.AntiKillbrick
		if needsNoCollide then
			Utils.SaveCollision(char, "collide")
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
			end
		else
			Utils.RestoreCollision(char, "collide")
		end
		if needsNoTouch then
			Utils.SaveCollision(char, "touch")
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") and v.CanTouch then v.CanTouch = false end
			end
			Services.Workspace.FallenPartsDestroyHeight = 0/0
		else
			Utils.RestoreCollision(char, "touch")
		end
		
		if Storage.IsHiding then
			local flyLV = hrp:FindFirstChild("X_Fly_LV")
			if flyLV then flyLV:Destroy() end
			local lv = hrp:FindFirstChild("X_Hide_LV")
			if not lv then
				lv = Instance.new("LinearVelocity"); lv.Name = "X_Hide_LV"
				lv.Attachment0 = rootAtt; lv.MaxForce = math.huge
				lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector; lv.Parent = hrp
			end
			local dir = Vector3.zero; local cam = Utils.GetCurrentCamera()
			if cam then
				local cf = cam.CFrame
				if Services.UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
				if Services.UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
				if Services.UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
				if Services.UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
			end
			if Services.UIS:IsKeyDown(Enum.KeyCode.E) or Services.UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
			if Services.UIS:IsKeyDown(Enum.KeyCode.Q) or Services.UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end
			lv.VectorVelocity = dir.Magnitude > 0 and dir.Unit * Config.Vals.FlySpeed or Vector3.zero
		elseif Config.States.Fly then
			local hideLV = hrp:FindFirstChild("X_Hide_LV")
			if hideLV then hideLV:Destroy() end
			local lv = hrp:FindFirstChild("X_Fly_LV")
			if not lv then
				lv = Instance.new("LinearVelocity"); lv.Name = "X_Fly_LV"
				lv.Attachment0 = rootAtt; lv.MaxForce = math.huge
				lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector; lv.Parent = hrp
			end
			local dir = Vector3.zero; local cam = Utils.GetCurrentCamera()
			if cam then
				local cf = cam.CFrame
				if Services.UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
				if Services.UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
				if Services.UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
				if Services.UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
			end
			if Services.UIS:IsKeyDown(Enum.KeyCode.E) or Services.UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
			if Services.UIS:IsKeyDown(Enum.KeyCode.Q) or Services.UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end
			if Config.States.LegitFly then
				local targetVel = dir.Magnitude > 0 and dir.Unit * Config.Vals.FlySpeed or Vector3.zero
				local currentVel = lv.VectorVelocity or Vector3.zero
				if math.abs(targetVel.Y - currentVel.Y) > 50 then
					targetVel = Vector3.new(targetVel.X, currentVel.Y + math.sign(targetVel.Y - currentVel.Y) * 50, targetVel.Z)
				end
				lv.VectorVelocity = currentVel:Lerp(targetVel, Config.Vals.LegitFlySmooth)
			else
				lv.VectorVelocity = dir.Magnitude > 0 and dir.Unit * Config.Vals.FlySpeed or Vector3.zero
			end
			local currentState = hum:GetState()
			if currentState ~= Enum.HumanoidStateType.Physics then
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
			end
		else
			local lv = hrp:FindFirstChild("X_Fly_LV"); if lv then lv:Destroy() end
			local lvH = hrp:FindFirstChild("X_Hide_LV"); if lvH then lvH:Destroy() end
			local currentState = hum:GetState()
			if currentState == Enum.HumanoidStateType.Physics then
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
			end
		end
		
		if Config.States.SpeedHack then
			if Config.States.CFrameSpeed then
				hum.WalkSpeed = Storage.OriginalWalkSpeed; local moveDir = hum.MoveDirection
				if moveDir.Magnitude > 0.1 then 
					-- [P1 FIX] Use dt for frame-independent speed
					hrp.CFrame = hrp.CFrame + moveDir * (Config.Vals.WalkSpeed * dt) 
				end
			else
				local safeSpeed = math.min(Config.Vals.WalkSpeed, 32); hum.WalkSpeed = safeSpeed
				local lv = hrp:FindFirstChild("X_Speed_LV")
				if not lv then
					lv = Instance.new("LinearVelocity"); lv.Name = "X_Speed_LV"
					lv.Attachment0 = rootAtt; lv.MaxForce = 5000
					lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Line; lv.Parent = hrp
				end
				local moveDir = hum.MoveDirection
				if moveDir.Magnitude > 0.1 then
					local extra = Config.Vals.WalkSpeed - safeSpeed
					lv.LineVelocity = extra > 0 and extra or 0; lv.LineDirection = moveDir
				else lv.LineVelocity = 0 end
			end
		else
			hum.WalkSpeed = Storage.OriginalWalkSpeed
			local lv = hrp:FindFirstChild("X_Speed_LV"); if lv then lv:Destroy() end
		end
		
		if Config.States.InfJump and Services.UIS:IsKeyDown(Enum.KeyCode.Space) then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
	table.insert(Storage.Connections, heartbeatConn)
	
	-- ======================================================================
	-- INPUT
	-- ======================================================================
	local inputBeganConn = Services.UIS.InputBegan:Connect(function(i, g)
		if g then return end
		if i.KeyCode == Config.Keys.Menu and Storage.MainFrame then
			if not Storage.MenuDebounce then
				Storage.MenuDebounce = true; Storage.MainFrame.Visible = not Storage.MainFrame.Visible
				task.delay(0.2, function() Storage.MenuDebounce = false end)
			end
		end
		if i.KeyCode == Config.Keys.Unload then Runtime.Unload(); return end
		if i.UserInputType == Enum.UserInputType.MouseButton2 and Config.States.RightClickToggle then Config.States.Aimbot = true end
		if i.KeyCode == Config.Keys.Fly then
			Config.States.Fly = not Config.States.Fly
			if Storage.ToggleFuncs.Fly then Storage.ToggleFuncs.Fly(Config.States.Fly) end
		end
		if i.KeyCode == Config.Keys.Noclip then
			Config.States.Noclip = not Config.States.Noclip
			if Storage.ToggleFuncs.Noclip then Storage.ToggleFuncs.Noclip(Config.States.Noclip) end
		end
		if i.KeyCode == Config.Keys.Trigger then
			Config.States.TriggerBot = not Config.States.TriggerBot
			if Storage.ToggleFuncs.TriggerBot then Storage.ToggleFuncs.TriggerBot(Config.States.TriggerBot) end
		end
		if i.KeyCode == Config.Keys.LockTarget then
			local Camera = Utils.GetCurrentCamera()
			if not Camera then return end
			if Storage.LockedTarget and Storage.LockedTarget.Character then
				local tHum = Storage.LockedTarget.Character:FindFirstChild("Humanoid")
				if tHum and tHum.Health > 0 then
					local oldName = Storage.LockedTarget.Name; Storage.LockedTarget = nil; Storage.CurrentHPRatio = 0
					Utils.Notify("🔓 Target Unlocked", "Unlocked: " .. oldName)
					local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local highestThreat, nextTarget = -1, nil
					for _, p in pairs(Services.Players:GetPlayers()) do
						if p == LocalPlayer or not p.Character then continue end
						if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end
						local aimPart = Utils.GetSmartAimPart(p.Character)
						if not aimPart then continue end
						local pHum = p.Character:FindFirstChild("Humanoid")
						if not pHum or pHum.Health <= 0 then continue end
						local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
						if onScreen and (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude <= Config.Vals.FOV then
							local score = Utils.CalculateThreatScore(p, myHRP)
							if score > highestThreat then highestThreat = score; nextTarget = p end
						end
					end
					if nextTarget then Storage.LockedTarget = nextTarget; Utils.Notify("🎯 Target Locked", "Locked: " .. nextTarget.Name) end
				else
					Storage.LockedTarget = nil; Storage.CurrentHPRatio = 0
					Utils.Notify("🔓 Target Dead", "Target lock released")
				end
			else
				local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local highestThreat, target = -1, nil
				for _, p in pairs(Services.Players:GetPlayers()) do
					if p == LocalPlayer or not p.Character then continue end
					if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end
					local aimPart = Utils.GetSmartAimPart(p.Character)
					if not aimPart then continue end
					local pHum = p.Character:FindFirstChild("Humanoid")
					if not pHum or pHum.Health <= 0 then continue end
					local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
					if onScreen and (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude <= Config.Vals.FOV then
						local score = Utils.CalculateThreatScore(p, myHRP)
						if score > highestThreat then highestThreat = score; target = p end
					end
				end
				if target then
					Storage.LockedTarget = target; Storage.CurrentHPRatio = 0
					Utils.Notify("🎯 Target Locked", "Locked: " .. target.Name .. " (Persistent)")
				else Utils.Notify("❌ No Target", "No valid target inside FOV!") end
			end
		end
		if i.KeyCode == Config.Keys.Hide and Config.States.SkyHide then
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				if Storage.IsHiding then
					Storage.IsHiding = false
					if Storage.HideCFrame then hrp.CFrame = Storage.HideCFrame; Storage.HideCFrame = nil end
					Utils.Notify("🪂 Descent", "Returned to ground origin!")
				else
					Storage.HideCFrame = hrp.CFrame; Storage.IsHiding = true
					hrp.CFrame = hrp.CFrame * CFrame.new(0, 3000, 0)
					Utils.Notify("🛸 UFO Sky Hide", "Flight active. Press [X] to return", 3)
				end
			end
		end
		if i.UserInputType == Enum.UserInputType.MouseButton1 and Config.States.ClickTP and Services.UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Mouse.Target then
				LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
			end
		end
		if i.KeyCode == Config.Keys.TacticalTP then
			local target, _ = Utils.GetClosestToCenter()
			if target and target.Parent then
				local tp = Services.Players:GetPlayerFromCharacter(target.Parent)
				if tp then
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local eHRP = tp.Character and tp.Character:FindFirstChild("HumanoidRootPart")
					if hrp and eHRP then
						hrp.CFrame = eHRP.CFrame * CFrame.new(0, 0, -Config.Vals.TPBehindDist)
						Utils.Notify("⚡ Tactical TP", "Teleported behind: " .. tp.Name)
					end
				end
			end
		end
		if i.KeyCode == Config.Keys.DestroyMap then
			local Camera = Utils.GetCurrentCamera()
			if not Camera then return end
			local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
			local ray = Camera:ViewportPointToRay(center.X, center.Y)
			local params = RaycastParams.new(); params.FilterDescendantsInstances = {LocalPlayer.Character}; params.FilterType = Enum.RaycastFilterType.Exclude
			local result = Services.Workspace:Raycast(ray.Origin, ray.Direction * 500, params)
			if result and result.Position then
				if not Storage.MapStorageFolder then Storage.MapStorageFolder = Instance.new("Folder", Services.Workspace); Storage.MapStorageFolder.Name = "X_Titan_MapStorage" end
				local region = Region3.new(result.Position - Vector3.new(15,15,15), result.Position + Vector3.new(15,15,15))
				local parts = Services.Workspace:FindPartsInRegion3(region, LocalPlayer.Character, 100); local count = 0
				for _, part in pairs(parts) do
					if part.Name ~= "Baseplate" and part.Name ~= "Terrain" and not part.Parent:FindFirstChild("Humanoid") and part.Parent ~= Storage.MapStorageFolder then
						table.insert(Storage.DestroyedParts, {Part = part, Parent = part.Parent}); part.Parent = Storage.MapStorageFolder; count = count + 1
					end
				end
				Utils.Notify("💥 Map Destroyer", "Removed " .. count .. " obstacle parts")
			end
		end
		if i.KeyCode == Config.Keys.RestoreMap then
			local count = 0
			for _, data in pairs(Storage.DestroyedParts) do
				if data.Part and data.Parent then pcall(function() data.Part.Parent = data.Parent end); count = count + 1 end
			end
			table.clear(Storage.DestroyedParts)
			if Storage.MapStorageFolder then Storage.MapStorageFolder:Destroy(); Storage.MapStorageFolder = nil end
			Utils.Notify("🔄 Map Restored", "Restored " .. count .. " obstacle parts")
		end
		if i.KeyCode == Config.Keys.ToggleLockMenu then
			Config.States.ShowFOV = not Config.States.ShowFOV
			Utils.Notify("🎯 HUD", Config.States.ShowFOV and "Visible" or "Hidden")
		end
	end)
	table.insert(Storage.Connections, inputBeganConn)
	
	local inputEndedConn = Services.UIS.InputEnded:Connect(function(i, g)
		if g then return end
		if i.UserInputType == Enum.UserInputType.MouseButton2 and Config.States.RightClickToggle then Config.States.Aimbot = false end
	end)
	table.insert(Storage.Connections, inputEndedConn)
end

Runtime.Init()
Utils.Notify("✅ X TITAN V4.6.0", "VIP Exclusive Suite Online. Press [Insert] for Menu")
print("X TITAN V4.6.0 PATCH LOADED SUCCESSFULLY")