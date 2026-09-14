-- [[ PROJECT X NEXUS - PROTECTED DISTRIBUTION ]]
-- Founder & Developer: XT-7789 | Official Seller: vlilayz
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

-- [[ X TITAN V5.7.0 - TITAN GOD (APEX OMNI) ]]
-- Founder & Developer: XT-7789 | Official Seller: vlilayz
-- P1: CFrameSpeed dt math & Fly/Desync Mutual Exclusion
-- P2: Zero-Lag Character Caching, Throttled Raycasts & High-FPS Engine
-- ==============================================================================
if _G.X_TITAN_INSTANCE then
	pcall(function()
		if _G.X_TITAN_INSTANCE.Runtime and _G.X_TITAN_INSTANCE.Runtime.Unload then
			_G.X_TITAN_INSTANCE.Runtime.Unload()
		elseif _G.X_TITAN_INSTANCE.Storage then
			local s = _G.X_TITAN_INSTANCE.Storage
			s.IsUnloaded = true
			for _, l in pairs(s.Loops or {}) do pcall(function() task.cancel(l) end) end
			for _, c in pairs(s.Connections or {}) do pcall(function() c:Disconnect() end) end
		end
	end)
	task.wait(0.05)
end
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
if type(gethui) == "function" then
    pcall(function() targetGui = gethui() end)
end
if not targetGui then
    targetGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
end
if not targetGui then
    pcall(function() targetGui = LocalPlayer:WaitForChild("PlayerGui") end)
end
if not targetGui then warn("X SUITE: GUI Target failed!") return end

-- ==============================================================================
-- CONFIGURATION & STORAGE (V5.7.0)
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
		ESP = false, ESPSkeleton = false, Tracers = false, VisibilityCheck = false, Chams = false,
		XRay = false, Fullbright = false, Crosshair = false, DynamicCrosshair = true,
		Fly = false, SpeedHack = false, InfJump = false, Noclip = false, NoFall = false,
		AntiKillbrick = false, AntiVoid = true, HitSound = true, TouchFling = false, TargetFling = false, AntiFling = true, Wallbang = true, OrbitAura = false, RainbowChams = false,  ClickTP = false, SkyHide = false, MapDestroyer = false,
		KillAura = false, TPAura = false, Desync = false, AntiAimSpin = false, AntiAimHeadJitter = false,
		RightClickToggle = true, ShowFOV = false, TacticalLock = false,
		ShowLockStatus = true, SmartPrediction = true, AutoAimPart = false,
		LegitFly = false, ServerDesync = false, CFrameSpeed = false, Radar = false, ItemESP = false, VehicleBoost = false, VehicleFly = false,
		WeaponESP = true, OffscreenArrows = false, NoRecoil = false, DetectUnspawned = true,
		ShowDistance = true, ShowHealth = true, ShowName = true
	},
	Vals = {
		FOV = 200, OrbitDistance = 8, OrbitSpeed = 8, FlingPower = 100000, WalkSpeed = 150, FlySpeed = 150, HitboxSize = 15, HeadSize = 25,
		AimbotSmoothness = 0.3, PredictionStrength = 0.16, DesyncPower = 5,
		AuraRange = 25, TPBehindDist = 4, TriggerDelay = 0.15,
		AntiAimSpinSpeed = 10, AntiAimJitterRadius = 5, AimPart = "Head",
		Deadzone = 5, PingCompensation = 0.05, RadarRange = 100, LegitFlySmooth = 0.1, VehicleSpeed = 180,
		ESPRefreshRate = 0.3, ESPBoxThickness = 1.5, ESPTextSize = 13, ItemScanInterval = 1.5, TracerOrigin = "Bottom"
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
	DestroyedParts = {}, MapStorageFolder = nil, ItemESPObjects = {},
	AimParts = {"Head", "Torso", "HumanoidRootPart"}, AimPartIndex = 1,
	PlayerListFrame = nil, Connections = {}, Loops = {},
	TriggerBotCooldown = 0,
	LastTargetVel = {}, LastTargetTick = {},
	OffscreenArrows = {},
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
	HitSoundObj = nil,
	PlayerCache = {},
	ESPHidden = false,
	NoCollideActive = false,
	NoTouchActive = false,
	LastRadarUpdate = 0,
	LastHUDUpdate = 0,
	LastTargetScan = 0,
	CachedTargetPart = nil,
	CachedIsWall = false,
	CrosshairVisible = false,
	CharCache = {},
	VisCache = {}
}

_G.X_TITAN_CURRENT_INSTANCE = {
	Config = Config,
	Storage = Storage,
	Utils = nil,
	Features = nil
}

-- ==============================================================================
-- UTILITIES (V5.7.0)
-- ==============================================================================
local Utils = {}
_G.X_TITAN_CURRENT_INSTANCE.Utils = Utils

local NotifyStorage = {
	Container = nil,
	ActiveCards = {}
}

local function InitNotifyContainer()
	if NotifyStorage.Container and NotifyStorage.Container.Parent then return NotifyStorage.Container end
	local gui = targetGui:FindFirstChild("X_NOTIFICATIONS")
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "X_NOTIFICATIONS"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 999999
		gui.Parent = targetGui
	end
	
	local frame = gui:FindFirstChild("NotifyList")
	if not frame then
		frame = Instance.new("Frame")
		frame.Name = "NotifyList"
		frame.Size = UDim2.new(0, 260, 1, -20)
		frame.Position = UDim2.new(1, -270, 0, 10)
		frame.BackgroundTransparency = 1
		local list = Instance.new("UIListLayout", frame)
		list.FillDirection = Enum.FillDirection.Vertical
		list.VerticalAlignment = Enum.VerticalAlignment.Bottom
		list.HorizontalAlignment = Enum.HorizontalAlignment.Right
		list.Padding = UDim.new(0, 8)
		frame.Parent = gui
	end
	NotifyStorage.Container = frame
	return frame
end

function Utils.Notify(title, text, dur)
	dur = dur or 2.5
	local ok, container = pcall(InitNotifyContainer)
	if not ok or not container then
		pcall(function() print("[" .. tostring(title) .. "] " .. tostring(text)) end)
		return
	end

	-- De-duplicate / update existing notification with same title smoothly
	if NotifyStorage.ActiveCards[title] then
		local cardData = NotifyStorage.ActiveCards[title]
		if cardData.Card and cardData.Card.Parent then
			cardData.Desc.Text = tostring(text)
			cardData.Expiry = tick() + dur
			if cardData.ProgressBar then
				cardData.ProgressBar.Size = UDim2.new(1, 0, 0, 2)
				Services.TweenService:Create(cardData.ProgressBar, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()
			end
			local flashColor = (string.find(text, "CLOSED") or string.find(text, "DISABLED")) and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(0, 220, 255)
			Services.TweenService:Create(cardData.Stroke, TweenInfo.new(0.12), {Color = flashColor}):Play()
			Services.TweenService:Create(cardData.Bar, TweenInfo.new(0.12), {BackgroundColor3 = flashColor}):Play()
			return
		end
	end

	-- Color palette based on context
	local accent = (Config.Theme and (Config.Theme.Stroke or Config.Theme.Accent)) or Color3.fromRGB(0, 220, 255)
	if string.find(title, "❌") or string.find(text, "CLOSED") or string.find(title, "Unload") or string.find(text, "DISABLED") or string.find(text, "Descent") then
		accent = Color3.fromRGB(255, 75, 85)
	elseif string.find(title, "✅") or string.find(text, "OPENED") or string.find(text, "ENABLED") or string.find(text, "SUCCESS") then
		accent = Color3.fromRGB(50, 225, 135)
	elseif string.find(title, "🎯") or string.find(title, "⚡") or string.find(title, "👑") then
		accent = Color3.fromRGB(0, 220, 255)
	elseif string.find(title, "⚠️") or string.find(title, "📦") or string.find(title, "💥") then
		accent = Color3.fromRGB(255, 200, 60)
	end

	local card = Instance.new("Frame")
	card.Name = "ToastCard"
	card.Size = UDim2.new(0, 250, 0, 52)
	card.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
	card.BackgroundTransparency = 1
	card.ClipsDescendants = true
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke", card)
	stroke.Color = accent
	stroke.Thickness = 1.2
	stroke.Transparency = 1

	local bar = Instance.new("Frame", card)
	bar.Name = "AccentBar"
	bar.Size = UDim2.new(0, 4, 1, 0)
	bar.BackgroundColor3 = accent
	bar.BorderSizePixel = 0

	local tLbl = Instance.new("TextLabel", card)
	tLbl.Name = "Title"
	tLbl.Size = UDim2.new(1, -16, 0, 18)
	tLbl.Position = UDim2.new(0, 12, 0, 8)
	tLbl.BackgroundTransparency = 1
	tLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	tLbl.Font = Enum.Font.GothamBold
	tLbl.TextSize = 12
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.Text = tostring(title)
	tLbl.TextTransparency = 1

	local dLbl = Instance.new("TextLabel", card)
	dLbl.Name = "Text"
	dLbl.Size = UDim2.new(1, -16, 0, 16)
	dLbl.Position = UDim2.new(0, 12, 0, 27)
	dLbl.BackgroundTransparency = 1
	dLbl.TextColor3 = Color3.fromRGB(185, 190, 205)
	dLbl.Font = Enum.Font.GothamMedium
	dLbl.TextSize = 11
	dLbl.TextXAlignment = Enum.TextXAlignment.Left
	dLbl.Text = tostring(text)
	dLbl.TextTransparency = 1

	local pBar = Instance.new("Frame", card)
	pBar.Name = "Progress"
	pBar.Size = UDim2.new(1, 0, 0, 2)
	pBar.Position = UDim2.new(0, 0, 1, -2)
	pBar.BackgroundColor3 = accent
	pBar.BorderSizePixel = 0
	pBar.BackgroundTransparency = 0.2

	card.Parent = container

	local cardInfo = {
		Card = card,
		Stroke = stroke,
		Bar = bar,
		Desc = dLbl,
		ProgressBar = pBar,
		AccentColor = accent,
		Expiry = tick() + dur
	}
	NotifyStorage.ActiveCards[title] = cardInfo

	-- Slide & Fade in
	Services.TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.08}):Play()
	Services.TweenService:Create(stroke, TweenInfo.new(0.25), {Transparency = 0.25}):Play()
	Services.TweenService:Create(tLbl, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
	Services.TweenService:Create(dLbl, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
	Services.TweenService:Create(pBar, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()

	task.spawn(function()
		while tick() < cardInfo.Expiry do
			task.wait(0.1)
			if not card.Parent then return end
		end
		if card and card.Parent then
			Services.TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
			Services.TweenService:Create(stroke, TweenInfo.new(0.22), {Transparency = 1}):Play()
			Services.TweenService:Create(tLbl, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
			Services.TweenService:Create(dLbl, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
			task.wait(0.22)
			if card and card.Parent then card:Destroy() end
			if NotifyStorage.ActiveCards[title] == cardInfo then
				NotifyStorage.ActiveCards[title] = nil
			end
		end
	end)
end


function Utils.IsTeammate(plr)
	if not plr or not LocalPlayer or plr == LocalPlayer then return true end
	-- Arsenal & Universal FFA check: In FFA mode, everyone is an opponent even if assigned to FFA team
	if plr.Team and plr.Team.Name == "FFA" then return false end
	if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return true end
	if plr.TeamColor and LocalPlayer.TeamColor and plr.TeamColor == LocalPlayer.TeamColor then return true end
	return false
end

local SharedRaycastParams = RaycastParams.new()
SharedRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
SharedRaycastParams.IgnoreWater = true

function Utils.GetCharacterData(plr)
	if not plr then return nil end
	local now = tick()
	local cached = Storage.CharCache[plr]
	if cached and (now - cached.LastResolve < (Config.Vals.ESPRefreshRate or 0.3)) then
		if cached.Char and cached.Char.Parent and cached.Root and cached.Root.Parent then
			-- Real-time alive check so death is registered instantly
			local isAlive, isUnspawned = Utils.IsAlive(plr, cached.Char, cached.Hum)
			cached.IsAlive = isAlive
			cached.IsUnspawned = isUnspawned
			return cached
		end
	end

	local char = plr.Character
	if not (char and char.Parent and char:IsDescendantOf(Services.Workspace)) then
		char = Services.Workspace:FindFirstChild(plr.Name)
		if not char then
			local f = Services.Workspace:FindFirstChild("Characters") or Services.Workspace:FindFirstChild("Players")
			if f then char = f:FindFirstChild(plr.Name) end
		end
	end
	if not (char and char.Parent and char:IsDescendantOf(Services.Workspace)) then
		Storage.CharCache[plr] = nil
		return nil
	end

	local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char.PrimaryPart
	if not root then
		Storage.CharCache[plr] = nil
		return nil
	end

	local head = char:FindFirstChild("Head") or root
	local hum = char:FindFirstChildOfClass("Humanoid")
	local isAlive, isUnspawned = Utils.IsAlive(plr, char, hum)

	-- If found via Workspace search and it is not alive, do NOT adopt as player character (reject dead corpses)
	if (plr.Character == nil or plr.Character ~= char) and not isAlive then
		Storage.CharCache[plr] = nil
		return nil
	end

	if cached then
		cached.Char = char
		cached.Root = root
		cached.Head = head
		cached.Hum = hum
		cached.IsAlive = isAlive
		cached.IsUnspawned = isUnspawned
		cached.LastResolve = now
		return cached
	end

	local data = {
		Char = char,
		Root = root,
		Head = head,
		Hum = hum,
		IsAlive = isAlive,
		IsUnspawned = isUnspawned,
		LastResolve = now
	}
	Storage.CharCache[plr] = data
	return data
end

function Utils.GetHealth(plr, char)
	if not plr then return 0, 100 end
	char = char or plr.Character

	-- Arsenal NRPBS Health System
	local nrpbs = plr:FindFirstChild("NRPBS")
	if nrpbs then
		local hpVal = nrpbs:FindFirstChild("Health")
		local maxHpVal = nrpbs:FindFirstChild("MaxHealth")
		if hpVal and hpVal:IsA("ValueBase") then
			local cur = tonumber(hpVal.Value) or 0
			local max = (maxHpVal and maxHpVal:IsA("ValueBase") and tonumber(maxHpVal.Value)) or 100
			return cur, (max > 0 and max or 100)
		end
	end

	-- Standard Roblox Humanoid Health
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			local cur = hum.Health
			local max = hum.MaxHealth > 0 and hum.MaxHealth or 100
			return cur, max
		end
		-- Custom Body Games (Phantom Forces, Frontlines, Doors, Custom Rigs)
		local hpVal = char:FindFirstChild("Health") or char:FindFirstChild("HP") or char:FindFirstChild("hp") or (plr and plr:FindFirstChild("Status") and plr.Status:FindFirstChild("Health"))
		if hpVal and hpVal:IsA("ValueBase") and tonumber(hpVal.Value) then
			return math.max(0, tonumber(hpVal.Value)), 100
		end
		local hpAttr = char:GetAttribute("Health") or char:GetAttribute("HP")
		if hpAttr and tonumber(hpAttr) then
			local maxAttr = char:GetAttribute("MaxHealth") or char:GetAttribute("MaxHP") or 100
			return math.max(0, tonumber(hpAttr)), math.max(1, tonumber(maxAttr))
		end
	end
	return 100, 100
end

function Utils.IsAlive(arg1, arg2, arg3)
	local plr, char, hum
	if type(arg1) == "userdata" and arg1:IsA("Player") then
		plr = arg1
		char = arg2 or plr.Character
	else
		char = arg1
		hum = arg2
		plr = arg3 or (char and Services.Players:GetPlayerFromCharacter(char))
	end
	if not char or not char.Parent then return false, false end

	-- 1. If player has an active character assigned that differs from char, this char is an obsolete dead corpse
	if plr and plr.Character and plr.Character ~= char then
		return false, false
	end

	-- 2. Check if parented to corpse/debris/graveyard containers
	if char.Parent then
		local pName = char.Parent.Name
		if pName == "Debris" or pName == "Corpses" or pName == "Corpse" or pName == "Dead" or pName == "Ragdolls" or pName == "Ragdoll" or pName == "DeadBodies" or pName == "Graveyard" or pName == "Trash" then
			return false, false
		end
	end

	-- 3. Vital root part & boundary check
	local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char.PrimaryPart
	if not root or not root.Parent then return false, false end

	local rPos = root.Position
	if rPos.Y < -3000 or math.abs(rPos.X) > 200000 or math.abs(rPos.Z) > 200000 then
		return false, false
	end

	local isFarawayLobby = (rPos.Y > 3000 or math.abs(rPos.X) > 30000 or math.abs(rPos.Z) > 30000)

	-- 4. Arsenal & specialized game NRPBS checks
	if plr and (game.PlaceId == 286090429 or game.GameId == 111958650 or plr:FindFirstChild("NRPBS")) then
		local nrpbs = plr:FindFirstChild("NRPBS")
		if nrpbs then
			local hpVal = nrpbs:FindFirstChild("Health")
			if hpVal and hpVal:IsA("ValueBase") and (tonumber(hpVal.Value) or 0) <= 0 then
				return false, false
			end
		end
		if not char:FindFirstChild("Spawned") then
			return false, true
		end
	end

	-- 5. Universal Dead & Ragdoll markers (children, folders, scripts, values)
	local deadNames = {"Dead", "Ragdoll", "Ragdolled", "Died", "Corpse", "Downed", "Knocked", "Death", "KO", "Ko", "Fainted", "BleedOut", "Unconscious", "Eliminated", "IsDead", "Killed"}
	for _, dName in ipairs(deadNames) do
		local marker = char:FindFirstChild(dName)
		if marker then
			if marker:IsA("BoolValue") then
				if marker.Value == true then return false, false end
			elseif marker:IsA("IntValue") or marker:IsA("NumberValue") then
				if marker.Value == 1 or marker.Value == true then return false, false end
			else
				return false, false
			end
		end
	end

	-- 6. Universal Dead & Ragdoll Attributes
	for _, dAttr in ipairs({"Dead", "IsDead", "Ragdoll", "Ragdolled", "Downed", "Knocked", "Killed", "Unconscious", "Fainted"}) do
		if char:GetAttribute(dAttr) == true or (plr and plr:GetAttribute(dAttr) == true) then
			return false, false
		end
	end

	-- 7. Universal Health Calculation (NRPBS, Humanoid, HP Value, Attributes)
	local curHp, _ = Utils.GetHealth(plr, char)
	if curHp <= 0 then
		return false, false
	end

	-- 8. Roblox Humanoid State & Health
	hum = hum or char:FindFirstChildOfClass("Humanoid")
	if hum then
		if hum.Health <= 0 then
			return false, false
		end
		local ok, state = pcall(function() return hum:GetState() end)
		if ok then
			if state == Enum.HumanoidStateType.Dead then
				return false, false
			end
			if (state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll) then
				if hum.Health <= 1 or not hum.RequiresNeck then
					return false, false
				end
			end
		end
	else
		-- In Roblox standard games, an active alive character MUST have a Humanoid!
		local hasCustomHpSystem = (plr and plr:FindFirstChild("NRPBS")) or char:FindFirstChild("Health") or char:FindFirstChild("HP") or char:GetAttribute("Health") or char:GetAttribute("HP")
		if not hasCustomHpSystem and not isFarawayLobby then
			return false, false
		end
	end

	-- 9. Check BreakJointsOnDeath (severed head / broken neck)
	local head = char:FindFirstChild("Head")
	if not head or not head.Parent then
		return false, false
	end
	local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	if torso and not hum then
		local neck = head:FindFirstChild("Neck") or torso:FindFirstChild("Neck") or head:FindFirstChildOfClass("Motor6D") or torso:FindFirstChildOfClass("Motor6D")
		if not neck then
			return false, false
		end
	end

	if isFarawayLobby then
		return false, true
	end

	return true, false
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

function Utils.IsVisible(targetHead, targetPlr)
	if not targetHead or not targetHead.Parent then return false end
	local now = tick()
	if targetPlr then
		local c = Storage.VisCache[targetPlr]
		if c and (now - c.LastCheck < 0.25) then
			return c.Visible
		end
	end

	local Camera = Utils.GetCurrentCamera()
	if not Camera then return false end
	local origin = Camera.CFrame.Position
	local direction = (targetHead.Position - origin)

	SharedRaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
	local success, result = pcall(function() return Services.Workspace:Raycast(origin, direction, SharedRaycastParams) end)
	local isVis = false
	if not success or not result then
		isVis = true
	elseif result.Instance and result.Instance:IsDescendantOf(targetHead.Parent) then
		isVis = true
	end

	if targetPlr then
		local c = Storage.VisCache[targetPlr]
		if c then
			c.LastCheck = now
			c.Visible = isVis
		else
			Storage.VisCache[targetPlr] = { LastCheck = now, Visible = isVis }
		end
	end
	return isVis
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
	local head = character:FindFirstChild("Head")
	local upperTorso = character:FindFirstChild("UpperTorso")
	local lowerTorso = character:FindFirstChild("LowerTorso")
	local torso = character:FindFirstChild("Torso") or upperTorso or lowerTorso
	local hrp = character:FindFirstChild("HumanoidRootPart")

	-- [PLAN A & SMART ADAPTIVE]: If AutoAimPart is active, pick optimal part by visibility/distance
	if Config.States.AutoAimPart and head and (torso or hrp) then
		if Camera then
			local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local torsoPos = Camera:WorldToViewportPoint((torso or hrp).Position)
				if math.abs(headPos.Y - torsoPos.Y) * 0.4 < 20 then
					return torso or hrp
				end
			end
		end
		return head
	end

	-- [MANUAL SELECTION]: Strict user choice with automatic Plan C fallbacks
	if Config.Vals.AimPart == "Head" then
		if head then return head end
		-- Plan C fallback if Head is missing/destroyed
		if upperTorso then return upperTorso end
		if torso then return torso end
		if hrp then return hrp end
	elseif Config.Vals.AimPart == "Torso" then
		if torso then return torso end
		if upperTorso then return upperTorso end
		if hrp then return hrp end
		if head then return head end
	elseif Config.Vals.AimPart == "HumanoidRootPart" then
		if hrp then return hrp end
		if torso then return torso end
		if head then return head end
	end

	-- [PLAN C EMERGENCY FALLBACK]: Return any valid physical BasePart
	if hrp then return hrp end
	if head then return head end
	if torso then return torso end
	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") and part.Transparency < 1 and part.Size.Magnitude > 0.5 then
			return part
		end
	end
	return nil
end

function Utils.GetClosestToCenter()
	local Camera = Utils.GetCurrentCamera()
	if not Camera then return nil, false end
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	
	if Storage.LockedTarget and Storage.LockedTarget.Character then
		local tChar = Storage.LockedTarget.Character
		if Utils.IsAlive(Storage.LockedTarget, tChar) then
			local aimPart = Utils.GetSmartAimPart(tChar)
			if aimPart then
				local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
				if onScreen and pos.Z > 0 then
					if Config.States.WallCheck and not Utils.IsVisible(aimPart, Storage.LockedTarget) then return aimPart, true end
					return aimPart, false
				end
			end
		else
			Utils.Notify("🔓 Target Eliminated", "Target lock released: " .. Storage.LockedTarget.Name)
			Storage.LockedTarget = nil
			Storage.CurrentHPRatio = 0
			if Storage.TacticalHUD then Storage.TacticalHUD.Main.Visible = false end
		end
	end
	
	local highestThreat, targetPart = -1, nil
	for _, p in ipairs(Services.Players:GetPlayers()) do
		if p == LocalPlayer then continue end
		if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end
		local cData = Utils.GetCharacterData(p)
		if not cData or not cData.IsAlive then continue end
		local aimPart = Utils.GetSmartAimPart(cData.Char)
		if not aimPart then continue end
		local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
		if onScreen and pos.Z > 0 then
			local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
			if screenDist <= Config.Vals.FOV then
				if Config.States.WallCheck and not Utils.IsVisible(aimPart, p) then continue end
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


function Features.FlingPlayer(targetPlr)
	if not targetPlr or not targetPlr.Character then return end
	local myChar = LocalPlayer.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local tHRP = targetPlr.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP or not tHRP then return end
	local origCF = myHRP.CFrame
	local start = tick()
	Utils.Notify("🌪️ Target Yeet", "Flinging: " .. targetPlr.Name)
	while tick() - start < 0.4 do
		Services.RunService.Heartbeat:Wait()
		if not myHRP or not tHRP or not tHRP.Parent then break end
		myHRP.CFrame = tHRP.CFrame * CFrame.Angles(math.random()*6, math.random()*6, math.random()*6)
		myHRP.AssemblyLinearVelocity = Vector3.new(90000, 90000, 90000)
		myHRP.AssemblyAngularVelocity = Vector3.new(90000, 90000, 90000)
	end
	myHRP.AssemblyLinearVelocity = Vector3.zero
	myHRP.AssemblyAngularVelocity = Vector3.zero
	myHRP.CFrame = origCF
	Utils.Notify("✅ Yeet Complete", targetPlr.Name .. " launched into orbit!")
end

function Features.VoidDropTarget(targetPlr)
	if not targetPlr or not targetPlr.Character then return end
	local myChar = LocalPlayer.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local tHRP = targetPlr.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP or not tHRP then return end
	local origCF = myHRP.CFrame
	local fallenH = -500
	pcall(function() fallenH = Services.Workspace.FallenPartsDestroyHeight end)
	Utils.Notify("🕳️ Void Drop", "Dragging " .. targetPlr.Name .. " to void...")
	tHRP.AssemblyLinearVelocity = Vector3.new(0, -80000, 0)
	myHRP.CFrame = CFrame.new(tHRP.Position.X, fallenH + 25, tHRP.Position.Z)
	task.wait(0.2)
	myHRP.CFrame = origCF
	myHRP.AssemblyLinearVelocity = Vector3.zero
	Utils.Notify("✅ Void Executed", targetPlr.Name .. " dropped to void!")
end

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
		HealthBar = Drawing.new("Line"), Distance = Drawing.new("Text"),
		Weapon = Drawing.new("Text")
	}
	esp.Box.Thickness = 1.5; esp.Box.Color = Config.Theme.Stroke; esp.Box.Filled = false; esp.Box.Transparency = 1; esp.Box.Visible = false
	esp.Name.Size = 13; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Color = Color3.new(1,1,1); esp.Name.Visible = false
	esp.HealthBar.Thickness = 1.5; esp.HealthBar.Color = Color3.new(0,1,0); esp.HealthBar.Visible = false
	esp.Distance.Size = 12; esp.Distance.Center = true; esp.Distance.Outline = true; esp.Distance.Color = Color3.new(1,1,1); esp.Distance.Visible = false
	esp.Weapon.Size = 11; esp.Weapon.Center = true; esp.Weapon.Outline = true; esp.Weapon.Color = Color3.fromRGB(255, 230, 100); esp.Weapon.Visible = false
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
	if Storage.OffscreenArrows[plr] then
		pcall(function() Storage.OffscreenArrows[plr]:Remove() end)
		Storage.OffscreenArrows[plr] = nil
	end
end

function Features.UpdateOffscreenArrows()
	local Camera = Utils.GetCurrentCamera()
	if not Camera then return end
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local radius = math.min(center.X, center.Y) * 0.65
	local camCF = Camera.CFrame

	for _, p in pairs(Services.Players:GetPlayers()) do
		if p == LocalPlayer then continue end
		local char = p.Character
		if not char or not char.Parent then
			if Storage.OffscreenArrows[p] then Storage.OffscreenArrows[p].Visible = false end
			continue
		end

		if not Utils.IsAlive(p, char) then
			if Storage.OffscreenArrows[p] then Storage.OffscreenArrows[p].Visible = false end
			continue
		end

		if Config.States.TeamCheck and Utils.IsTeammate(p) then
			if Storage.OffscreenArrows[p] then Storage.OffscreenArrows[p].Visible = false end
			continue
		end

		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("Head")
		if not root then
			if Storage.OffscreenArrows[p] then Storage.OffscreenArrows[p].Visible = false end
			continue
		end

		local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
		if onScreen then
			-- Already visible on screen, hide offscreen arrow
			if Storage.OffscreenArrows[p] then Storage.OffscreenArrows[p].Visible = false end
			continue
		end

		-- Target is OFF-SCREEN: Calculate 360 degree angle from camera orientation
		local toEnemy = (root.Position - camCF.Position)
		local dotRight = toEnemy:Dot(camCF.RightVector)
		local dotUp = toEnemy:Dot(camCF.UpVector)
		local angle = math.atan2(-dotUp, dotRight)

		local arrowCenter = center + Vector2.new(math.cos(angle), math.sin(angle)) * radius
		local tip = center + Vector2.new(math.cos(angle), math.sin(angle)) * (radius + 14)
		local p1 = center + Vector2.new(math.cos(angle + 0.22), math.sin(angle + 0.22)) * (radius - 6)
		local p2 = center + Vector2.new(math.cos(angle - 0.22), math.sin(angle - 0.22)) * (radius - 6)

		local dist = math.floor(toEnemy.Magnitude)
		local threatColor = Config.Theme.ThreatLow
		if dist < 40 then threatColor = Config.Theme.ThreatHigh
		elseif dist < 90 then threatColor = Config.Theme.ThreatMed end

		if Drawing then
			if not Storage.OffscreenArrows[p] then
				local tri = Drawing.new("Triangle")
				tri.Filled = true
				tri.Thickness = 1
				Storage.OffscreenArrows[p] = tri
			end
			local tri = Storage.OffscreenArrows[p]
			tri.PointA = tip
			tri.PointB = p1
			tri.PointC = p2
			tri.Color = threatColor
			tri.Visible = true
		end
	end
end

function Features.UpdateHitboxes()
	local now = tick()
	if now - Storage.HitboxLastUpdate < 0.1 then return end
	Storage.HitboxLastUpdate = now
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			if not Utils.IsAlive(p, p.Character) then continue end
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
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			if not Utils.IsAlive(p, p.Character) then continue end
			if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end
			local d = (p.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
			if d < dist then dist = d; target = p.Character end
		end
	end
	return target
end

-- ==============================================================================
-- UI SYSTEM (V5.7.0)
-- ==============================================================================
-- ITEM & LOOT ESP SUBSYSTEM (V5.7.0)
local function ClearItemESP()
	for _, bg in pairs(Storage.ItemESPObjects) do
		pcall(function() bg:Destroy() end)
	end
	table.clear(Storage.ItemESPObjects)
end

local function UpdateItemESP()
	if not Config.States.ItemESP then
		ClearItemESP()
		return
	end
	local myChar = LocalPlayer.Character
	local myHrp = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar.PrimaryPart)
	if not myHrp then return end

	local myPos = myHrp.Position
	local found = {}

	local function addItem(part, name, itemType)
		if not part or not part:IsA("BasePart") or not part:IsDescendantOf(Services.Workspace) then return end
		local dist = (part.Position - myPos).Magnitude
		if dist <= 1000 then
			found[part] = { Name = name, Dist = math.floor(dist), Type = itemType or "item" }
		end
	end

	-- Fast O(N) scan only on Workspace direct children and loot containers (ZERO LAG)
	for _, item in ipairs(Services.Workspace:GetChildren()) do
		if item:IsA("Tool") and item:FindFirstChild("Handle") then
			addItem(item.Handle, item.Name, "tool")
		elseif item:IsA("BasePart") and item:FindFirstChildOfClass("ProximityPrompt") then
			local prompt = item:FindFirstChildOfClass("ProximityPrompt")
			if prompt and prompt.Enabled then
				local title = prompt.ObjectText ~= "" and prompt.ObjectText or prompt.ActionText
				if title == "" or title == "Interact" or title == "Use" or title == "Pick Up" then title = item.Name end
				addItem(item, title, "prompt")
			end
		elseif item:IsA("Model") and (item.Name == "Drops" or item.Name == "Items" or item.Name == "Loot" or item.Name == "Tools" or item.Name == "Pickups" or item.Name == "Chests" or item.Name == "Weapons" or item.Name == "Debris") then
			for _, sub in ipairs(item:GetChildren()) do
				local p = sub:IsA("BasePart") and sub or sub:FindFirstChildWhichIsA("BasePart")
				if p then addItem(p, sub.Name, "container") end
			end
		end
	end

	for part, data in pairs(found) do
		local bg = Storage.ItemESPObjects[part]
		local icon = (data.Type == "prompt" and "✨ ") or (data.Type == "tool" and "🔫 ") or "📦 "
		local color = (data.Type == "tool" and Color3.fromRGB(100, 220, 255)) or (data.Type == "prompt" and Color3.fromRGB(255, 230, 80)) or Color3.fromRGB(255, 200, 60)
		if not bg or not bg.Parent then
			bg = Instance.new("BillboardGui")
			bg.Name = "X_ITEM_ESP"
			bg.AlwaysOnTop = true
			bg.Size = UDim2.new(0, 160, 0, 24)
			bg.Adornee = part
			bg.MaxDistance = 1000
			
			local lbl = Instance.new("TextLabel", bg)
			lbl.Name = "Tag"
			lbl.Size = UDim2.new(1, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.TextColor3 = color
			lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			lbl.TextStrokeTransparency = 0.2
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 11
			lbl.Text = icon .. data.Name .. " [" .. tostring(data.Dist) .. "m]"
			
			bg.Parent = targetGui
			Storage.ItemESPObjects[part] = bg
		else
			local lbl = bg:FindFirstChild("Tag")
			if lbl then
				lbl.Text = icon .. data.Name .. " [" .. tostring(data.Dist) .. "m]"
			end
		end
	end

	for part, bg in pairs(Storage.ItemESPObjects) do
		if not found[part] or not part.Parent then
			pcall(function() bg:Destroy() end)
			Storage.ItemESPObjects[part] = nil
		end
	end
end

local UI = {}
function UI.Init()
	local guiName = "X_TITAN_V570"
	if targetGui:FindFirstChild(guiName) then targetGui[guiName]:Destroy() end
	
	local ScreenGui = Instance.new("ScreenGui", targetGui)
	ScreenGui.Name = guiName; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true; ScreenGui.DisplayOrder = 999999999
	
	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 640, 0, 480); Main.Position = UDim2.new(0.5, -320, 0.5, -240)
	Main.BackgroundColor3 = Config.Theme.Main; Main.Active = true; Main.Draggable = true
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
	local UIStroke = Instance.new("UIStroke", Main); UIStroke.Color = Config.Theme.Stroke; UIStroke.Thickness = 1.5; UIStroke.Transparency = 0.35
	Storage.MainFrame = Main

	-- Floating Open/Close Button (Always visible on screen, click to toggle menu)
	local ToggleBtn = Instance.new("TextButton", ScreenGui)
	ToggleBtn.Name = "X_Titan_Floating_Toggle"
	ToggleBtn.Size = UDim2.new(0, 42, 0, 42)
	ToggleBtn.Position = UDim2.new(0, 16, 0.45, 0)
	ToggleBtn.BackgroundColor3 = Config.Theme.Sec
	ToggleBtn.Text = "X"
	ToggleBtn.TextColor3 = Config.Theme.Stroke
	ToggleBtn.Font = Enum.Font.GothamBold
	ToggleBtn.TextSize = 18
	ToggleBtn.Active = true
	ToggleBtn.Draggable = true
	Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
	local tbStroke = Instance.new("UIStroke", ToggleBtn)
	tbStroke.Color = Config.Theme.Stroke
	tbStroke.Thickness = 1.5
	tbStroke.Transparency = 0.3

	ToggleBtn.MouseButton1Click:Connect(function()
		if Storage.MainFrame then
			Storage.MainFrame.Visible = not Storage.MainFrame.Visible
			ToggleBtn.Text = Storage.MainFrame.Visible and "✕" or "X"
			ToggleBtn.TextColor3 = Storage.MainFrame.Visible and Color3.fromRGB(255, 80, 80) or Config.Theme.Stroke
			tbStroke.Color = Storage.MainFrame.Visible and Color3.fromRGB(255, 80, 80) or Config.Theme.Stroke
			Utils.Notify("📱 Menu", Storage.MainFrame.Visible and "OPENED" or "CLOSED", 1)
		end
	end)
	
	local SidePanel = Instance.new("Frame", Main)
	SidePanel.Size = UDim2.new(0, 155, 1, 0); SidePanel.BackgroundColor3 = Config.Theme.Sec
	Instance.new("UICorner", SidePanel).CornerRadius = UDim.new(0, 10)
	
	local Title = Instance.new("TextLabel", SidePanel)
	Title.Text = "⚡ X TITAN"; Title.Size = UDim2.new(1, -16, 0, 24); Title.Position = UDim2.new(0, 12, 0, 12)
	Title.BackgroundTransparency = 1; Title.TextColor3 = Config.Theme.Stroke
	Title.Font = Enum.Font.GothamBlack; Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left

	local Subtitle = Instance.new("TextLabel", SidePanel)
	Subtitle.Text = "VOID WALKER • V5.7.0"; Subtitle.Size = UDim2.new(1, -16, 0, 14); Subtitle.Position = UDim2.new(0, 12, 0, 34)
	Subtitle.BackgroundTransparency = 1; Subtitle.TextColor3 = Config.Theme.TextDim
	Subtitle.Font = Enum.Font.GothamBold; Subtitle.TextSize = 9; Subtitle.TextXAlignment = Enum.TextXAlignment.Left
	
	local TabHolder = Instance.new("Frame", SidePanel)
	TabHolder.Size = UDim2.new(1, -16, 1, -100); TabHolder.Position = UDim2.new(0, 8, 0, 56); TabHolder.BackgroundTransparency = 1
	local TabLayout = Instance.new("UIListLayout", TabHolder); TabLayout.Padding = UDim.new(0, 4)

	local SideUnloadBtn = Instance.new("TextButton", SidePanel)
	SideUnloadBtn.Name = "SideUnload"
	SideUnloadBtn.Size = UDim2.new(1, -16, 0, 30); SideUnloadBtn.Position = UDim2.new(0, 8, 1, -38)
	SideUnloadBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	SideUnloadBtn.Text = "❌ UNLOAD [End]"; SideUnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	SideUnloadBtn.Font = Enum.Font.GothamBold; SideUnloadBtn.TextSize = 11
	Instance.new("UICorner", SideUnloadBtn).CornerRadius = UDim.new(0, 6)
	SideUnloadBtn.MouseButton1Click:Connect(function()
		Runtime.Unload()
	end)
	
	local PageHolder = Instance.new("Frame", Main)
	PageHolder.Size = UDim2.new(1, -170, 1, -14); PageHolder.Position = UDim2.new(0, 162, 0, 7); PageHolder.BackgroundTransparency = 1
	
	local uiOrderCounter = 0
	local function getNextOrder() uiOrderCounter = uiOrderCounter + 1; return uiOrderCounter end
	
	local function CreatePage(name)
		local Page = Instance.new("ScrollingFrame", PageHolder)
		Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false
		Page.ScrollBarThickness = 4; Page.ScrollBarImageColor3 = Config.Theme.Stroke
		Page.BorderSizePixel = 0
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		pcall(function() Page.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
		
		local List = Instance.new("UIListLayout", Page); List.Padding = UDim.new(0, 5); List.SortOrder = Enum.SortOrder.LayoutOrder
		local Pad = Instance.new("UIPadding", Page)
		Pad.PaddingBottom = UDim.new(0, 24)
		Pad.PaddingRight = UDim.new(0, 6)
		Pad.PaddingTop = UDim.new(0, 2)
		
		local function refreshCanvas()
			local y = List.AbsoluteContentSize.Y
			if y > 50 then
				Page.CanvasSize = UDim2.new(0, 0, 0, y + 30)
			else
				Page.CanvasSize = UDim2.new(0, 0, 0, 0)
			end
		end
		List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvas)
		Page:GetPropertyChangedSignal("Visible"):Connect(function()
			if Page.Visible then
				Page.CanvasPosition = Vector2.new(0, 0)
				task.defer(refreshCanvas)
			end
		end)
		
		local TabBtn = Instance.new("TextButton", TabHolder)
		TabBtn.Size = UDim2.new(1, 0, 0, 32); TabBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
		TabBtn.Text = name; TabBtn.TextColor3 = Config.Theme.TextDim; TabBtn.Font = Enum.Font.GothamBold; TabBtn.TextSize = 11; TabBtn.AutoButtonColor = false
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
		TabBtn.MouseButton1Click:Connect(function()
			for _,v in pairs(PageHolder:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
			for _,v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(30,30,35); v.TextColor3 = Config.Theme.TextDim end end
			Page.Visible = true; TabBtn.BackgroundColor3 = Config.Theme.Stroke; TabBtn.TextColor3 = Config.Theme.Main
			Page.CanvasPosition = Vector2.new(0, 0)
			task.defer(refreshCanvas)
		end)
		return Page, TabBtn, getNextOrder
	end
	
	local function AddToggle(page, text, flag, getOrder)
		local Btn = Instance.new("TextButton", page)
		Btn.LayoutOrder = getOrder(); Btn.Size = UDim2.new(1, -4, 0, 36); Btn.BackgroundColor3 = Config.Theme.Sec; Btn.Text = "  "; Btn.AutoButtonColor = false
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
		local Stroke = Instance.new("UIStroke", Btn); Stroke.Color = Config.Theme.Stroke; Stroke.Transparency = 0.85
		local Label = Instance.new("TextLabel", Btn)
		Label.Text = text; Label.Size = UDim2.new(0.74, 0, 1, 0); Label.Position = UDim2.new(0, 12, 0, 0)
		Label.BackgroundTransparency = 1; Label.TextColor3 = Config.Theme.Text; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left
		local Indicator = Instance.new("Frame", Btn)
		Indicator.Size = UDim2.new(0, 34, 0, 18); Indicator.Position = UDim2.new(1, -46, 0.5, -9); Indicator.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
		local indStroke = Instance.new("UIStroke", Indicator); indStroke.Color = Config.Theme.Stroke; indStroke.Transparency = 0.75; indStroke.Thickness = 1
		local Dot = Instance.new("Frame", Indicator)
		Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = UDim2.new(0, 2, 0.5, -7); Dot.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
		Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
		
		local function Update(val, skipNotify)
			local c = val and Config.Theme.Stroke or Color3.fromRGB(150, 150, 160)
			local bgC = val and Color3.fromRGB(0, 60, 75) or Color3.fromRGB(45, 45, 55)
			local p = val and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
			Services.TweenService:Create(Dot, TweenInfo.new(0.2), {Position = p, BackgroundColor3 = c}):Play()
			Services.TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = bgC}):Play()
			Services.TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = val and 0.4 or 0.85}):Play()
			Config.States[flag] = val
			pcall(function()
				if flag == "XRay" and Utils.ToggleXRay then Utils.ToggleXRay(val) end
				if flag == "Fullbright" and Utils.ToggleFullbright then Utils.ToggleFullbright(val) end
				if flag == "AntiKillbrick" and not val and Storage.OriginalFallenHeight then
					Services.Workspace.FallenPartsDestroyHeight = Storage.OriginalFallenHeight
				end
				if flag == "Chams" and Features.UpdateChams then Features.UpdateChams() end
				if flag == "ItemESP" and not val and ClearItemESP then ClearItemESP() end
				if flag == "ESP" and not val and Drawing then
					for _, esp in pairs(Storage.ESPObjects) do
						pcall(function()
							esp.Box.Visible = false; esp.Name.Visible = false
							esp.HealthBar.Visible = false; esp.Distance.Visible = false
							if esp.Weapon then esp.Weapon.Visible = false end
						end)
					end
				end
				if flag == "Radar" and Storage.RadarFrame then
					Storage.RadarFrame.Visible = val
					if not val then
						for _, obj in pairs(Storage.RadarObjects) do if obj.Visible then obj.Visible = false end end
					end
				end
				if flag == "ShowFOV" and Storage.FOVRingUI then
					Storage.FOVRingUI.Visible = val
				end
				if flag == "ShowLockStatus" and Storage.TacticalHUD then
					Storage.TacticalHUD.Main.Visible = val and (Storage.LockedTarget ~= nil)
				end
			end)
			if not skipNotify and Utils and Utils.Notify then
				pcall(function()
					Utils.Notify(text, val and "ENABLED" or "DISABLED", 1.5)
				end)
			end
		end
		Storage.ToggleFuncs[flag] = Update; Update(Config.States[flag], true)
		Btn.MouseButton1Click:Connect(function() Update(not Config.States[flag]) end)
	end
	
	local function AddSlider(page, text, min, max, def, cb, getOrder)
		local Frame = Instance.new("Frame", page)
		Frame.LayoutOrder = getOrder(); Frame.Size = UDim2.new(1, -4, 0, 46); Frame.BackgroundColor3 = Config.Theme.Sec
		Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
		local fStroke = Instance.new("UIStroke", Frame); fStroke.Color = Config.Theme.Stroke; fStroke.Transparency = 0.85
		
		local Label = Instance.new("TextLabel", Frame)
		Label.Text = text; Label.Size = UDim2.new(0.72, 0, 0, 18); Label.Position = UDim2.new(0, 10, 0, 4)
		Label.BackgroundTransparency = 1; Label.TextColor3 = Config.Theme.Text; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 11
		Label.TextXAlignment = Enum.TextXAlignment.Left

		local ValLabel = Instance.new("TextLabel", Frame)
		ValLabel.Text = tostring(def); ValLabel.Size = UDim2.new(0.24, 0, 0, 18); ValLabel.Position = UDim2.new(0.74, -10, 0, 4)
		ValLabel.BackgroundTransparency = 1; ValLabel.TextColor3 = Config.Theme.Stroke; ValLabel.Font = Enum.Font.GothamBold; ValLabel.TextSize = 11
		ValLabel.TextXAlignment = Enum.TextXAlignment.Right

		local SlideBar = Instance.new("TextButton", Frame)
		SlideBar.Size = UDim2.new(1, -20, 0, 6); SlideBar.Position = UDim2.new(0, 10, 0, 28); SlideBar.BackgroundColor3 = Color3.fromRGB(45,45,55); SlideBar.Text = "  "
		Instance.new("UICorner", SlideBar).CornerRadius = UDim.new(1, 0)
		local barStroke = Instance.new("UIStroke", SlideBar); barStroke.Color = Config.Theme.Stroke; barStroke.Transparency = 0.85

		local Fill = Instance.new("Frame", SlideBar)
		Fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Config.Theme.Stroke
		Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
		
		local SliderData = {Bar = SlideBar, Fill = Fill, Label = Label, ValLabel = ValLabel, Min = min, Max = max, Callback = cb, Text = text}
		function SliderData:SetValue(val)
			val = math.clamp(val, min, max); local pct = (val - min) / (max - min)
			Fill.Size = UDim2.new(pct, 0, 1, 0); ValLabel.Text = tostring(math.floor(val))
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
		Instance.new("UICorner", B1).CornerRadius = UDim.new(0, 6)
		local b1Stroke = Instance.new("UIStroke", B1); b1Stroke.Color = Config.Theme.Stroke; b1Stroke.Transparency = 0.85
		if cb1 then B1.MouseButton1Click:Connect(function() cb1() end) end
		local B2 = Instance.new("TextButton", F); B2.Size = UDim2.new(0.48, 0, 1, 0); B2.Position = UDim2.new(0.52, 0, 0, 0)
		B2.BackgroundColor3 = Config.Theme.Sec; B2.Text = t2; B2.TextColor3 = Config.Theme.Text; B2.Font = Enum.Font.GothamBold; B2.TextSize = 9
		Instance.new("UICorner", B2).CornerRadius = UDim.new(0, 6)
		local b2Stroke = Instance.new("UIStroke", B2); b2Stroke.Color = Config.Theme.Stroke; b2Stroke.Transparency = 0.85
		if cb2 then B2.MouseButton1Click:Connect(function() cb2() end) end
		return B1, B2
	end
	
	local function AddSection(page, text, getOrder)
		local SecFrame = Instance.new("Frame", page); SecFrame.LayoutOrder = getOrder()
		SecFrame.Size = UDim2.new(1, -4, 0, 26); SecFrame.BackgroundTransparency = 1
		
		local Bar = Instance.new("Frame", SecFrame)
		Bar.Size = UDim2.new(0, 3, 0, 14); Bar.Position = UDim2.new(0, 2, 0.5, -7)
		Bar.BackgroundColor3 = Config.Theme.Stroke; Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

		local Label = Instance.new("TextLabel", SecFrame)
		Label.Size = UDim2.new(1, -16, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0)
		Label.BackgroundTransparency = 1; Label.Text = string.upper(text); Label.TextColor3 = Config.Theme.Stroke
		Label.Font = Enum.Font.GothamBlack; Label.TextSize = 11; Label.TextXAlignment = Enum.TextXAlignment.Left
	end
	
	local function AddKeybindInfo(page, section, binds, getOrder)
		AddSection(page, section, getOrder)
		for _, bind in ipairs(binds) do
			local F = Instance.new("Frame", page)
			F.LayoutOrder = getOrder(); F.Size = UDim2.new(1, -4, 0, 22); F.BackgroundTransparency = 1
			local L = Instance.new("TextLabel", F); L.Size = UDim2.new(0.55, 0, 1, 0); L.Position = UDim2.new(0, 10, 0, 0)
			L.BackgroundTransparency = 1; L.Text = bind[1]; L.TextColor3 = Config.Theme.Text; L.Font = Enum.Font.GothamBold; L.TextSize = 10
			L.TextXAlignment = Enum.TextXAlignment.Left
			local K = Instance.new("TextLabel", F); K.Size = UDim2.new(0.4, 0, 1, 0); K.Position = UDim2.new(0.6, -20, 0, 0)
			K.BackgroundTransparency = 1; K.Text = bind[2]; K.TextColor3 = Config.Theme.Stroke; K.Font = Enum.Font.GothamBlack; K.TextSize = 10
			K.TextXAlignment = Enum.TextXAlignment.Right
		end
	end
	
	local P1, T1, getOrder1 = CreatePage("🎯 COMBAT"); P1.Visible = true; T1.BackgroundColor3 = Config.Theme.Stroke; T1.TextColor3 = Config.Theme.Main
	local P2, T2, getOrder2 = CreatePage("👁️ VISUAL")
	local P3, T3, getOrder3 = CreatePage("🏃 MOVEMENT")
	local P4, T4, getOrder4 = CreatePage("👥 PLAYER")
	local P5, T5, getOrder5 = CreatePage("⚙️ OTHER")
	local P6, T6, getOrder6 = CreatePage("⌨️ KEYBINDS")
	
	
	AddSection(P1, "GOD TIER FLING & RAGE [V5.0]", getOrder1)
	AddToggle(P1, "🌪️ Touch Fling (God Yeet)", "TouchFling", getOrder1)
	AddToggle(P1, "🛡️ Anti-Fling Immortality", "AntiFling", getOrder1)
	AddToggle(P1, "🎯 100% Wallbang (Penetrate All)", "Wallbang", getOrder1)
	AddToggle(P1, "🌀 Orbit Stalker Aura", "OrbitAura", getOrder1)
	AddSlider(P1, "Orbit Distance", 3, 30, 8, function(v) Config.Vals.OrbitDistance = v end, getOrder1)
	AddSlider(P1, "Orbit Speed", 1, 25, 8, function(v) Config.Vals.OrbitSpeed = v end, getOrder1)

	AddSection(P1, "AIMBOT & THREAT", getOrder1)
	AddToggle(P1, "Hold Right Click Aimbot", "RightClickToggle", getOrder1)
	AddToggle(P1, "Aimbot (Esports V4.5)", "Aimbot", getOrder1)
	AddSlider(P1, "Base Smoothness", 1, 90, 30, function(v) Config.Vals.AimbotSmoothness = v / 100 end, getOrder1)
	AddSlider(P1, "Prediction", 0, 50, 16, function(v) Config.Vals.PredictionStrength = v / 100 end, getOrder1)
	AddToggle(P1, "Smart Prediction (Ping)", "SmartPrediction", getOrder1)
	AddToggle(P1, "Auto Aim Part", "AutoAimPart", getOrder1)
	local bAim1, bAim2
	local function UpdateAimPartButtonUI()
		if bAim2 then
			bAim2.Text = "Target: " .. Config.Vals.AimPart
			bAim2.TextColor3 = Config.Theme.Stroke
		end
	end
	local function CycleAimPart()
		Storage.AimPartIndex = Storage.AimPartIndex % #Storage.AimParts + 1
		Config.Vals.AimPart = Storage.AimParts[Storage.AimPartIndex]
		UpdateAimPartButtonUI()
		Utils.Notify("🎯 Aim Part", "Target Part set to: " .. Config.Vals.AimPart)
	end
	bAim1, bAim2 = AddDual(P1, "🎯 Cycle Aim Part", CycleAimPart, "Target: " .. Config.Vals.AimPart, CycleAimPart, getOrder1)
	UpdateAimPartButtonUI()
	
	AddSection(P1, "SILENT & TRIGGER", getOrder1)
	AddToggle(P1, "Silent Aim 🔥", "SilentAim", getOrder1)
	AddToggle(P1, "TriggerBot [T]", "TriggerBot", getOrder1)
	AddToggle(P1, "🛡️ No Camera Recoil", "NoRecoil", getOrder1)
	
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
	AddToggle(P2, "👻 Detect No-Spawn / Lobby", "DetectUnspawned", getOrder2)
	AddToggle(P2, "📦 Item & Loot ESP", "ItemESP", getOrder2)
	AddToggle(P2, "🔫 Weapon / Tool ESP", "WeaponESP", getOrder2)
	AddToggle(P2, "🦴 Skeleton ESP", "ESPSkeleton", getOrder2)
	AddToggle(P2, "🧭 Off-screen Target Arrows", "OffscreenArrows", getOrder2)
	AddToggle(P2, "360° Tracers", "Tracers", getOrder2)
	AddToggle(P2, "Visibility Check", "VisibilityCheck", getOrder2)
	AddToggle(P2, "Chams", "Chams", getOrder2)
	AddToggle(P2, "🌈 Dynamic Rainbow Chams", "RainbowChams", getOrder2)
	AddToggle(P2, "X-Ray", "XRay", getOrder2)
	AddToggle(P2, "Fullbright", "Fullbright", getOrder2)
	
	AddSection(P2, "👑 VIP ENGINE & ESP CUSTOMIZATION", getOrder2)
	AddSlider(P2, "⚡ ESP Polling Delay (1=0.1s, 10=1.0s)", 1, 10, 3, function(v) Config.Vals.ESPRefreshRate = v / 10 end, getOrder2)
	AddSlider(P2, "📦 Item Scan Delay (sec)", 5, 30, 15, function(v) Config.Vals.ItemScanInterval = v / 10 end, getOrder2)
	AddSlider(P2, "✏️ ESP Line Thickness", 10, 40, 15, function(v)
		Config.Vals.ESPBoxThickness = v / 10
		for _, e in pairs(Storage.ESPObjects) do if e.Box then e.Box.Thickness = Config.Vals.ESPBoxThickness end end
	end, getOrder2)
	AddSlider(P2, "🔤 ESP Text Size", 9, 18, 13, function(v)
		Config.Vals.ESPTextSize = v
		for _, e in pairs(Storage.ESPObjects) do
			if e.Name then e.Name.Size = v end
			if e.Distance then e.Distance.Size = v - 1 end
		end
	end, getOrder2)
	AddDual(P2, "🎯 Tracer Origin", function()
		if Config.Vals.TracerOrigin == "Bottom" then Config.Vals.TracerOrigin = "Center"
		elseif Config.Vals.TracerOrigin == "Center" then Config.Vals.TracerOrigin = "Mouse"
		else Config.Vals.TracerOrigin = "Bottom" end
		Utils.Notify("Tracer Origin", "Origin set to: " .. Config.Vals.TracerOrigin)
	end, "🎨 Cycle VIP Theme", function()
		local themes = {"Cyan", "Crimson", "Toxic", "Violet", "Gold"}
		local colors = {
			Cyan = Color3.fromRGB(0, 255, 255),
			Crimson = Color3.fromRGB(255, 55, 85),
			Toxic = Color3.fromRGB(50, 255, 120),
			Violet = Color3.fromRGB(190, 80, 255),
			Gold = Color3.fromRGB(255, 200, 40)
		}
		Storage.ThemeIndex = ((Storage.ThemeIndex or 1) % #themes) + 1
		local tName = themes[Storage.ThemeIndex]
		Config.Theme.Stroke = colors[tName]
		if Storage.FOVRingUI and Storage.FOVRingUI:FindFirstChild("UIStroke") then Storage.FOVRingUI.UIStroke.Color = colors[tName] end
		Utils.Notify("🎨 Theme Applied", "VIP Theme set to: " .. tName)
	end, getOrder2)
	AddToggle(P2, "Show Player Names", "ShowName", getOrder2)
	AddToggle(P2, "Show Health Bar", "ShowHealth", getOrder2)
	AddToggle(P2, "Show Distance", "ShowDistance", getOrder2)
	AddToggle(P2, "🏹 360 Off-Screen Threat Arrows", "OffscreenArrows", getOrder2)

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
	
	AddSection(P3, "VEHICLE & DRIVE", getOrder3)
	AddToggle(P3, "🚗 Vehicle Speed Boost", "VehicleBoost", getOrder3)
	AddToggle(P3, "🛸 Vehicle Aerial Fly", "VehicleFly", getOrder3)
	AddSlider(P3, "Vehicle Speed", 50, 400, 180, function(v) Config.Vals.VehicleSpeed = v end, getOrder3)

	AddSection(P3, "CHECKPOINTS", getOrder3)
	AddDual(P3, "📍 SET P1", function() Utils.SetPoint("P1") end, "⚡ TP P1", function() Utils.TPPoint("P1") end, getOrder3)
	AddDual(P3, "📍 SET P2", function() Utils.SetPoint("P2") end, "⚡ TP P2", function() Utils.TPPoint("P2") end, getOrder3)
	AddDual(P3, "📍 SET P3", function() Utils.SetPoint("P3") end, "⚡ TP P3", function() Utils.TPPoint("P3") end, getOrder3)
	
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
			if p.Character then
				local isAlive = Utils.IsAlive(p, p.Character)
				local curHp, _ = Utils.GetHealth(p, p.Character)
				hpText = isAlive and ("❤️ " .. math.floor(curHp)) or "💀 DEAD"
			end
			local Row = Instance.new("Frame", PlayerListFrame); Row.Size = UDim2.new(1, -8, 0, 28); Row.BackgroundTransparency = 1
			local PBtn = Instance.new("TextButton", Row); PBtn.Size = UDim2.new(0.62, 0, 1, 0); PBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
			PBtn.Text = string.format("%s (@%s) [%s] %s", p.DisplayName, p.Name, teamName, hpText)
			PBtn.TextColor3 = teamColor; PBtn.Font = Enum.Font.GothamBold; PBtn.TextSize = 10; PBtn.AutoButtonColor = true
			PBtn.TextXAlignment = Enum.TextXAlignment.Left
			Instance.new("UIPadding", PBtn).PaddingLeft = UDim.new(0, 8); Instance.new("UICorner", PBtn).CornerRadius = UDim.new(0, 4)
			PBtn.MouseButton1Click:Connect(function() Features.SpectatePlayer(p.Name) end)
			
			local YeetBtn = Instance.new("TextButton", Row); YeetBtn.Size = UDim2.new(0.12, 0, 1, 0); YeetBtn.Position = UDim2.new(0.64, 0, 0, 0)
			YeetBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40); YeetBtn.Text = "🌪️"; YeetBtn.TextColor3 = Color3.new(1,1,1); YeetBtn.Font = Enum.Font.GothamBlack; YeetBtn.TextSize = 10
			Instance.new("UICorner", YeetBtn).CornerRadius = UDim.new(0, 4)
			YeetBtn.MouseButton1Click:Connect(function() Features.FlingPlayer(p) end)

			local TPBtn = Instance.new("TextButton", Row); TPBtn.Size = UDim2.new(0.21, 0, 1, 0); TPBtn.Position = UDim2.new(0.78, 0, 0, 0)
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
		pcall(function() PlayerListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
		local pListY = ListLayout.AbsoluteContentSize.Y
		PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(pListY + 10, 400))
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
	
	-- Ensure all tabs have non-zero canvas size so elements are immediately visible
	for _, page in ipairs({P1, P2, P3, P4, P5, P6}) do
		pcall(function()
			page.AutomaticCanvasSize = Enum.AutomaticSize.Y
			local l = page:FindFirstChildOfClass("UIListLayout")
			local y = l and l.AbsoluteContentSize.Y or 0
			if y > 50 then
				page.CanvasSize = UDim2.new(0, 0, 0, y + 25)
			else
				page.CanvasSize = UDim2.new(0, 0, 2.5, 0)
			end
		end)
	end
end

-- ==============================================================================
-- CORE EXPLOIT HOOKS (V5.6.0 - ALL BUGS FIXED)
-- ==============================================================================
local HasTitanMetamethodHook = false

-- [TIER 2] Mouse.Hit & Target Spoofing (Xeno / Free PC Executors)
pcall(function()
	if type(getrawmetatable) == "function" and type(setreadonly) == "function" then
		local mt = getrawmetatable(game)
		if mt then
			setreadonly(mt, false)
			local oldIndex = mt.__index
			mt.__index = function(t, k)
				local inst = _G.X_TITAN_CURRENT_INSTANCE
				if inst and inst.Config and inst.Config.States.SilentAim and (t:IsA("Mouse") or tostring(t) == "Mouse") then
					local targetPart, _ = inst.Utils.GetClosestToCenter()
					if targetPart then
						local predPos = targetPart.Position
						local root = targetPart.Parent and targetPart.Parent:FindFirstChild("HumanoidRootPart")
						if inst.Config.States.SmartPrediction and root then
							predPos = predPos + (root.AssemblyLinearVelocity * inst.Config.Vals.PredictionStrength)
						end
						if k == "Hit" then return CFrame.new(predPos)
						elseif k == "Target" then return targetPart end
					end
				end
				return oldIndex(t, k)
			end
			setreadonly(mt, true)
		end
	end
end)

-- [TIER 3] Micro-Flick Silent Aim Fallback for Xeno
local function TitanMicroFlickSilentAim()
	local inst = _G.X_TITAN_CURRENT_INSTANCE
	if not inst or not inst.Config or not inst.Config.States.SilentAim then return end
	local targetPart, _ = inst.Utils.GetClosestToCenter()
	if not targetPart or not targetPart.Parent then return end

	local predPos = targetPart.Position
	local root = targetPart.Parent:FindFirstChild("HumanoidRootPart")
	if inst.Config.States.SmartPrediction and root then
		predPos = predPos + (root.AssemblyLinearVelocity * inst.Config.Vals.PredictionStrength)
	end

	local Camera = inst.Utils.GetCurrentCamera()
	if not Camera then return end
	local origCF = Camera.CFrame
	Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, predPos)
	if inst.Config.States.HitSound then inst.Utils.PlayHitSound() end
	task.spawn(function()
		Services.RunService.RenderStepped:Wait()
		Camera.CFrame = origCF
	end)
end

if not _G.X_TITAN_HOOK_INITIALIZED and type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
	_G.X_TITAN_HOOK_INITIALIZED = true
	HasTitanMetamethodHook = true
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
						local cam = CurrentUtils.GetCurrentCamera()
						local distToCam = cam and (origin - cam.CFrame.Position).Magnitude or math.huge
						if distToHRP < 15 or distToTool < 8 or distToCam < 8 then
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
					local predPos = target.Position
					local eRoot = target.Parent:FindFirstChild("HumanoidRootPart")
					if eRoot and CurrentConfig.States.SmartPrediction then
						local predTime = CurrentConfig.Vals.PredictionStrength
						local ping = CurrentUtils.GetPing() / 1000
						predTime = predTime + ping * CurrentConfig.Vals.PingCompensation
						predPos = predPos + (eRoot.AssemblyLinearVelocity * predTime)
					end
					if method == "Raycast" then
						local origin = args[1]; local direction = (predPos - origin).Unit * 5000; args[2] = direction
					else
						local ray = args[1]; local origin = ray.Origin; local direction = (predPos - origin).Unit * 5000
						args[1] = Ray.new(origin, direction)
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
					local hitPlr = Services.Players:GetPlayerFromCharacter(hitChar)
					if hitPlr and hitPlr ~= LocalPlayer and CurrentUtils.IsAlive(hitPlr, hitChar) then
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
		local char = LocalPlayer.Character; local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart"))
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
-- RUNTIME (V5.6.0)
-- ==============================================================================
local Runtime = {}
function Runtime.Unload()
	Utils.Notify("⚠️ Unload", "Unloading X TITAN V5.7.0 - TITAN GOD (APEX OMNI)...")
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
	
	ClearItemESP()
	table.clear(Storage.PlayerCache)
	table.clear(Storage.CharCache)
	table.clear(Storage.VisCache)
	Utils.ToggleXRay(false); Utils.ToggleFullbright(false)
	for plr, esp in pairs(Storage.ESPObjects) do for _, d in pairs(esp) do pcall(function() d:Remove() end) end end
	for plr, skel in pairs(Storage.SkeletonParts) do for _, d in pairs(skel) do pcall(function() d:Remove() end) end end
	for _, l in pairs(Storage.TracerLines) do pcall(function() l:Remove() end) end
	for _, a in pairs(Storage.OffscreenArrows) do pcall(function() a:Remove() end) end
	Storage.OffscreenArrows = {}
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
	print("X TITAN V5.7.0 - TITAN GOD (APEX OMNI) UNLOADED SUCCESSFULLY")
end

local function InitRadar()
	if Storage.RadarGui then return end
	local RadarGui = Instance.new("ScreenGui", targetGui)
	RadarGui.Name = "X_RADAR_V521"; RadarGui.IgnoreGuiInset = true; RadarGui.DisplayOrder = 9999998
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
	local isRadarOn = Config.States.Radar
	Storage.RadarFrame.Visible = isRadarOn
	if not isRadarOn then
		for _, obj in pairs(Storage.RadarObjects) do
			if obj.Visible then obj.Visible = false end
		end
		return
	end
	
	local now = tick()
	if (now - Storage.LastRadarUpdate) < 0.05 then return end
	Storage.LastRadarUpdate = now
	
	local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end
	
	for plr, obj in pairs(Storage.RadarObjects) do
		if not Storage.PlayerCache[plr] or not plr.Character then
			pcall(function() obj:Destroy() end); Storage.RadarObjects[plr] = nil
		else obj.Visible = false end
	end
	
	for p, data in pairs(Storage.PlayerCache) do
		if not data.Char.Parent then continue end
		local eHRP = data.Root
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
		elseif Utils.IsVisible(data.Head, p) then obj.BackgroundColor3 = Config.Theme.LockColor
		else obj.BackgroundColor3 = Config.Theme.TextDim end
	end
end

function 
	-- Top-Right Watermark FPS & Ping updater (Anonymized: No Username)
	task.spawn(function()
		local fpsCount = 0
		local lastFpsTick = tick()
		Services.RunService.RenderStepped:Connect(function()
			fpsCount = fpsCount + 1
		end)
		while true do
			task.wait(0.5)
			if Storage.IsUnloaded then break end
			local now = tick()
			local currentFps = math.floor(fpsCount / (now - lastFpsTick))
			fpsCount = 0
			lastFpsTick = now
			
			local pingMs = 0
			pcall(function()
				local stats = game:GetService("Stats")
				local net = stats and stats:FindFirstChild("Network")
				if net and net:FindFirstChild("ServerStatsItem") and net.ServerStatsItem:FindFirstChild("Data Ping") then
					pingMs = math.floor(net.ServerStatsItem["Data Ping"]:GetValue())
				end
			end)
			if pingMs == 0 then pingMs = 28 end

			if Storage.WatermarkLabel then
				Storage.WatermarkLabel.Text = string.format("FPS: %d  |  PING: %dms", currentFps, pingMs)
				if currentFps >= 50 then
					Storage.WatermarkLabel.TextColor3 = Color3.fromRGB(90, 240, 140)
				elseif currentFps >= 30 then
					Storage.WatermarkLabel.TextColor3 = Color3.fromRGB(245, 200, 60)
				else
					Storage.WatermarkLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
				end
			end
		end
	end)

	Runtime.Init()
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
	
	local FOVGui = Instance.new("ScreenGui", targetGui); FOVGui.Name = "X_FOV_V521"; FOVGui.IgnoreGuiInset = true; FOVGui.DisplayOrder = 9999999
	local FOVFrame = Instance.new("Frame", FOVGui)
	FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5); FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	FOVFrame.BackgroundTransparency = 1; FOVFrame.Visible = false
	local FStroke = Instance.new("UIStroke", FOVFrame); FStroke.Color = Config.Theme.Stroke; FStroke.Thickness = 1.5
	Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0); Storage.FOVRingUI = FOVFrame
	
	-- [TOP-RIGHT WATERMARK HUD: ANONYMIZED (NO USERNAME)]
	local WatermarkGui = Instance.new("ScreenGui", targetGui)
	WatermarkGui.Name = "X_TITAN_WATERMARK_V570"
	WatermarkGui.ResetOnSpawn = false
	WatermarkGui.IgnoreGuiInset = true
	WatermarkGui.DisplayOrder = 9999999

	local WmFrame = Instance.new("Frame", WatermarkGui)
	WmFrame.Size = UDim2.new(0, 205, 0, 36)
	WmFrame.Position = UDim2.new(1, -215, 0, 14)
	WmFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
	WmFrame.BackgroundTransparency = 0.25
	Instance.new("UICorner", WmFrame).CornerRadius = UDim.new(0, 6)
	local wmStroke = Instance.new("UIStroke", WmFrame)
	wmStroke.Color = Config.Theme.Stroke
	wmStroke.Thickness = 1.2
	wmStroke.Transparency = 0.4

	local WmTitle = Instance.new("TextLabel", WmFrame)
	WmTitle.Size = UDim2.new(1, -12, 0, 16)
	WmTitle.Position = UDim2.new(0, 8, 0, 3)
	WmTitle.BackgroundTransparency = 1
	WmTitle.Text = "⚡ PROJECT X TITAN • V5.7.0"
	WmTitle.TextColor3 = Config.Theme.Stroke
	WmTitle.Font = Enum.Font.GothamBlack
	WmTitle.TextSize = 10
	WmTitle.TextXAlignment = Enum.TextXAlignment.Left

	local WmStats = Instance.new("TextLabel", WmFrame)
	WmStats.Size = UDim2.new(1, -12, 0, 14)
	WmStats.Position = UDim2.new(0, 8, 0, 18)
	WmStats.BackgroundTransparency = 1
	WmStats.Text = "FPS: 60 | PING: 25ms"
	WmStats.TextColor3 = Color3.fromRGB(200, 210, 230)
	WmStats.Font = Enum.Font.GothamMedium
	WmStats.TextSize = 9
	WmStats.TextXAlignment = Enum.TextXAlignment.Left
	Storage.WatermarkLabel = WmStats

	-- [CYBERNETIC ROBOT TACTICAL HUD & LEADER LINE]
	local TacticalHUDGui = Instance.new("ScreenGui", targetGui)
	TacticalHUDGui.Name = "X_TacticalHUD_V570"; TacticalHUDGui.IgnoreGuiInset = true; TacticalHUDGui.DisplayOrder = 9999998

	-- Futuristic Angled Leader Line (Center Reticle to Target Card)
	local LineH1 = Instance.new("Frame", TacticalHUDGui)
	LineH1.Size = UDim2.new(0, 45, 0, 2); LineH1.BackgroundColor3 = Config.Theme.Stroke; LineH1.BorderSizePixel = 0; LineH1.Visible = false
	local LineDiag = Instance.new("Frame", TacticalHUDGui)
	LineDiag.Size = UDim2.new(0, 50, 0, 2); LineDiag.BackgroundColor3 = Config.Theme.Stroke; LineDiag.BorderSizePixel = 0; LineDiag.Visible = false
	local LineH2 = Instance.new("Frame", TacticalHUDGui)
	LineH2.Size = UDim2.new(0, 60, 0, 2); LineH2.BackgroundColor3 = Config.Theme.Stroke; LineH2.BorderSizePixel = 0; LineH2.Visible = false

	local MainPanel = Instance.new("Frame", TacticalHUDGui)
	MainPanel.Size = UDim2.new(0, 275, 0, 82); MainPanel.AnchorPoint = Vector2.new(0, 0.5)
	MainPanel.Position = UDim2.new(0.5, 140, 0.5, -40); MainPanel.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
	MainPanel.BackgroundTransparency = 0.2; MainPanel.Visible = false
	Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 8)
	local PanelStroke = Instance.new("UIStroke", MainPanel); PanelStroke.Color = Config.Theme.Stroke; PanelStroke.Thickness = 1.4

	local SubTag = Instance.new("TextLabel", MainPanel)
	SubTag.Size = UDim2.new(1, -12, 0, 14); SubTag.Position = UDim2.new(0, 8, 0, 4)
	SubTag.BackgroundTransparency = 1; SubTag.Text = "◈ ROBOT CYBER HUD // TARGET LOCK ◈"
	SubTag.TextColor3 = Config.Theme.Stroke; SubTag.Font = Enum.Font.GothamBold; SubTag.TextSize = 9; SubTag.TextXAlignment = Enum.TextXAlignment.Left

	local Header = Instance.new("TextLabel", MainPanel)
	Header.Size = UDim2.new(1, -12, 0, 20); Header.Position = UDim2.new(0, 8, 0, 18)
	Header.BackgroundTransparency = 1; Header.Font = Enum.Font.GothamBlack; Header.TextSize = 13
	Header.TextXAlignment = Enum.TextXAlignment.Left; Header.TextColor3 = Config.Theme.Text

	local HPBarBG = Instance.new("Frame", MainPanel)
	HPBarBG.Size = UDim2.new(1, -16, 0, 7); HPBarBG.Position = UDim2.new(0, 8, 0, 42)
	HPBarBG.BackgroundColor3 = Color3.fromRGB(35, 38, 46); Instance.new("UICorner", HPBarBG).CornerRadius = UDim.new(1, 0)
	local HPBarFill = Instance.new("Frame", HPBarBG)
	HPBarFill.Size = UDim2.new(1, 0, 1, 0); HPBarFill.BackgroundColor3 = Config.Theme.Stroke; Instance.new("UICorner", HPBarFill).CornerRadius = UDim.new(1, 0)

	local Footer = Instance.new("TextLabel", MainPanel)
	Footer.Size = UDim2.new(1, -12, 0, 18); Footer.Position = UDim2.new(0, 8, 0, 54)
	Footer.BackgroundTransparency = 1; Footer.Font = Enum.Font.GothamBold; Footer.TextSize = 10
	Footer.TextXAlignment = Enum.TextXAlignment.Left; Footer.TextColor3 = Config.Theme.TextDim

	Storage.TacticalHUD = {
		Main = MainPanel, Stroke = PanelStroke, Header = Header, HPFill = HPBarFill, Footer = Footer,
		Line1 = LineH1, LineDiag = LineDiag, Line2 = LineH2
	}
	
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
	local function UpdatePlayerCache(p)
		if not p or p == LocalPlayer then return end
		local char = p.Character
		if not char or not char.Parent then
			Storage.PlayerCache[p] = nil
			return
		end
		local head = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or head
		local hum = char:FindFirstChildOfClass("Humanoid")
		if head and root then
			local existing = Storage.PlayerCache[p]
			Storage.PlayerCache[p] = {
				Char = char,
				Head = head,
				Root = root,
				Hum = hum,
				IsVisible = existing and existing.IsVisible or false,
				LastVisCheck = existing and existing.LastVisCheck or 0
			}
		else
			Storage.PlayerCache[p] = nil
		end
	end

	table.clear(Storage.PlayerCache)
	table.clear(Storage.CharCache)
	table.clear(Storage.VisCache)
	for _, p in ipairs(Services.Players:GetPlayers()) do
		if p ~= LocalPlayer then
			UpdatePlayerCache(p)
			local cAdded = p.CharacterAdded:Connect(function()
				task.wait(0.3)
				UpdatePlayerCache(p)
			end)
			table.insert(Storage.Connections, cAdded)
			local cRemoved = p.CharacterRemoving:Connect(function()
				Storage.PlayerCache[p] = nil
				if Storage.LockedTarget == p then
					Storage.LockedTarget = nil
					Storage.CurrentHPRatio = 0
					if Storage.TacticalHUD then Storage.TacticalHUD.Main.Visible = false end
				end
			end)
			table.insert(Storage.Connections, cRemoved)
		end
	end

	local cachePAdded = Services.Players.PlayerAdded:Connect(function(p)
		local cAdded = p.CharacterAdded:Connect(function()
			task.wait(0.3)
			UpdatePlayerCache(p)
		end)
		table.insert(Storage.Connections, cAdded)
		local cRemoved = p.CharacterRemoving:Connect(function()
			Storage.PlayerCache[p] = nil
			if Storage.LockedTarget == p then
				Storage.LockedTarget = nil
				Storage.CurrentHPRatio = 0
				if Storage.TacticalHUD then Storage.TacticalHUD.Main.Visible = false end
			end
		end)
		table.insert(Storage.Connections, cRemoved)
		UpdatePlayerCache(p)
	end)
	table.insert(Storage.Connections, cachePAdded)

	local cachePRemoved = Services.Players.PlayerRemoving:Connect(function(p)
		Storage.PlayerCache[p] = nil
		Storage.CharCache[p] = nil
		Storage.VisCache[p] = nil
		Features.RemoveESP(p)
	end)
	table.insert(Storage.Connections, cachePRemoved)
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
			Storage.WalkSpeedSnapshotPending = false
			Storage.LastSafeCFrame = nil
			Storage.HitSoundObj = nil
		else
			Storage.WalkSpeedSnapshotPending = true
			local humanoidAddedConn
			humanoidAddedConn = char.ChildAdded:Connect(function(child)
				if child:IsA("Humanoid") and not Config.States.SpeedHack then
					Storage.OriginalWalkSpeed = child.WalkSpeed
					Storage.WalkSpeedSnapshotPending = false
			Storage.LastSafeCFrame = nil
			Storage.HitSoundObj = nil
					humanoidAddedConn:Disconnect()
				end
			end)
			task.delay(5, function()
				if humanoidAddedConn then pcall(function() humanoidAddedConn:Disconnect() end) end
				Storage.WalkSpeedSnapshotPending = false
			Storage.LastSafeCFrame = nil
			Storage.HitSoundObj = nil
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
	-- RENDERSTEPPED (V5.0.0 - P2 FIXED: Target Caching)
	-- ======================================================================
	local renderConn = Services.RunService.RenderStepped:Connect(function()
		local CurrentCam = Utils.GetCurrentCamera()
		if not CurrentCam then return end
		local char = LocalPlayer.Character; local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart"))
		local center = Vector2.new(CurrentCam.ViewportSize.X/2, CurrentCam.ViewportSize.Y/2)
		
		-- [ZERO-LAG] Throttled Target Search (Max 60Hz evaluation, full frame lerp)
		local cachedTarget, cachedIsWall = nil, false
		if Config.States.Aimbot or Config.States.TriggerBot or Config.States.ShowFOV or Storage.LockedTarget then
			local now = tick()
			if (now - Storage.LastTargetScan) > 0.04 then
				Storage.LastTargetScan = now
				cachedTarget, cachedIsWall = Utils.GetClosestToCenter()
				Storage.CachedTargetPart = cachedTarget
				Storage.CachedIsWall = cachedIsWall
			else
				cachedTarget = Storage.CachedTargetPart
				cachedIsWall = Storage.CachedIsWall
			end
		end
		
		if Storage.FOVRingUI then
			if Config.States.ShowFOV then
				Storage.FOVRingUI.Visible = true
				Storage.FOVRingUI.Size = UDim2.new(0, Config.Vals.FOV * 2, 0, Config.Vals.FOV * 2)
				if cachedTarget then 
					Storage.FOVRingUI.UIStroke.Color = cachedIsWall and Config.Theme.WallColor or Config.Theme.LockColor
				else 
					Storage.FOVRingUI.UIStroke.Color = Config.Theme.Stroke 
				end
			elseif Storage.FOVRingUI.Visible then
				Storage.FOVRingUI.Visible = false
			end
		end
		
		if Storage.TacticalHUD then
			local showHUD = Config.States.ShowLockStatus and Storage.LockedTarget ~= nil
			if showHUD and Storage.LockedTarget and Storage.LockedTarget.Character then
				Storage.TacticalHUD.Main.Visible = true
				local now = tick()
				if (now - Storage.LastHUDUpdate) > 0.05 then
					Storage.LastHUDUpdate = now
					local lockedPlr = Storage.LockedTarget
					if not Utils.IsAlive(lockedPlr, lockedPlr.Character) then
						Storage.LockedTarget = nil
						Storage.CurrentHPRatio = 0
						Storage.TacticalHUD.Main.Visible = false
					else
						local hrp_t = lockedPlr.Character:FindFirstChild("HumanoidRootPart")
						local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						if hrp_t and myHRP then
							local dist = math.floor((hrp_t.Position - myHRP.Position).Magnitude)
							local curHp, maxHp = Utils.GetHealth(lockedPlr, lockedPlr.Character)
							local targetRatio = math.clamp(curHp / maxHp, 0, 1)
							Storage.CurrentHPRatio = Storage.CurrentHPRatio + (targetRatio - Storage.CurrentHPRatio) * 0.2
							local hpColor = Color3.new(1 - Storage.CurrentHPRatio, Storage.CurrentHPRatio, 0)
							Storage.TacticalHUD.HPFill.Size = UDim2.new(Storage.CurrentHPRatio, 0, 1, 0)
							Storage.TacticalHUD.HPFill.BackgroundColor3 = hpColor
							local threat, tColor = "LOW", Config.Theme.ThreatLow
							if dist < 30 then threat, tColor = "HIGH", Config.Theme.ThreatHigh
							elseif dist < 80 then threat, tColor = "MED", Config.Theme.ThreatMed end
							local breath = math.sin(now * 3) * 0.2 + 0.8
							if threat == "HIGH" then tColor = Color3.fromRGB(255, 40 * breath, 40 * breath)
							elseif threat == "MED" then tColor = Color3.fromRGB(255, 180 * breath, 0) end
							Storage.TacticalHUD.Header.Text = string.format("[%s] %s", threat, lockedPlr.Name)
							Storage.TacticalHUD.Header.TextColor3 = tColor
							Storage.TacticalHUD.Footer.Text = string.format("DIST: %dm | AIM: %s", dist, Config.Vals.AimPart)
							Storage.TacticalHUD.Stroke.Color = tColor
						end
					end
				end
			elseif Storage.TacticalHUD.Main.Visible then
				Storage.TacticalHUD.Main.Visible = false
			end
		end
		
		if Drawing then
			local showCross = (Config.States.Crosshair or Config.States.DynamicCrosshair) and not (Storage.MainFrame and Storage.MainFrame.Visible)
			if showCross then
				local spread = 6
				local crosshairColor = Config.Theme.Stroke
				if Config.States.DynamicCrosshair then
					if Config.States.Fly or Config.States.SpeedHack then spread = 18
					elseif hrp and hrp.AssemblyLinearVelocity.Magnitude > 10 then spread = 12 end
					if Storage.LockedTarget or Config.States.Aimbot then spread = 2; crosshairColor = Config.Theme.LockColor end
				end
				local t, b, l, r = Storage.CrosshairLines.Top, Storage.CrosshairLines.Bottom, Storage.CrosshairLines.Left, Storage.CrosshairLines.Right
				if t and b and l and r then
					t.Visible = true; t.From = Vector2.new(center.X, center.Y - spread - 4); t.To = Vector2.new(center.X, center.Y - spread); t.Color = crosshairColor
					b.Visible = true; b.From = Vector2.new(center.X, center.Y + spread + 4); b.To = Vector2.new(center.X, center.Y + spread); b.Color = crosshairColor
					l.Visible = true; l.From = Vector2.new(center.X - spread - 4, center.Y); l.To = Vector2.new(center.X - spread, center.Y); l.Color = crosshairColor
					r.Visible = true; r.From = Vector2.new(center.X + spread + 4, center.Y); r.To = Vector2.new(center.X + spread, center.Y); r.Color = crosshairColor
				end
				Storage.CrosshairVisible = true
			elseif Storage.CrosshairVisible then
				Storage.CrosshairVisible = false
				local t, b, l, r = Storage.CrosshairLines.Top, Storage.CrosshairLines.Bottom, Storage.CrosshairLines.Left, Storage.CrosshairLines.Right
				if t then t.Visible = false end
				if b then b.Visible = false end
				if l then l.Visible = false end
				if r then r.Visible = false end
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
				for _, line in pairs(Storage.HitmarkerLines) do if line.Visible then line.Visible = false end end
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
			-- Magnetic tracking without acceleration noise
			if cachedTarget and cachedTarget.Parent then
				local targetPos = cachedTarget.Position
				local eRoot = cachedTarget.Parent:FindFirstChild("HumanoidRootPart")
				local predTime = Config.Vals.PredictionStrength
				if Config.States.SmartPrediction then
					local ping = Utils.GetPing() / 1000
					predTime = predTime + ping * Config.Vals.PingCompensation
				end
				if eRoot then
					targetPos = targetPos + (eRoot.AssemblyLinearVelocity * predTime)
				end
				local screenPos, onScreen = CurrentCam:WorldToViewportPoint(targetPos)
				local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
				if screenDist < Config.Vals.Deadzone then
					CurrentCam.CFrame = CFrame.lookAt(CurrentCam.CFrame.Position, targetPos)
				else
					-- Smooth magnetic aim tracking (clamped 0.08 to 1.0)
					local smoothFactor = math.clamp(1.0 - Config.Vals.AimbotSmoothness, 0.08, 1.0)
					if screenDist > 120 then smoothFactor = math.clamp(smoothFactor + 0.25, 0.12, 1.0) end
					CurrentCam.CFrame = CurrentCam.CFrame:Lerp(CFrame.lookAt(CurrentCam.CFrame.Position, targetPos), smoothFactor)
				end
			end
		end
		
		if Config.States.TriggerBot then
			-- Use cached target (with alive validation)
			local trigPlr = cachedTarget and cachedTarget.Parent and Services.Players:GetPlayerFromCharacter(cachedTarget.Parent)
			if cachedTarget and cachedTarget.Parent and trigPlr and Utils.IsAlive(trigPlr, cachedTarget.Parent) and (not Config.States.WallCheck or Utils.IsVisible(cachedTarget)) then
				if tick() - Storage.TriggerBotCooldown > Config.Vals.TriggerDelay then
					mouse1click(); Storage.TriggerBotCooldown = tick()
				end
			end
		end
		
		-- [ZERO-LAG ESP ENGINE] Skip entire loop if visual features are disabled
		local anyESP = Config.States.ESP or Config.States.ESPSkeleton or Config.States.Tracers or Config.States.OffscreenArrows
		if Drawing then
			if not anyESP then
				if not Storage.ESPHidden then
					Storage.ESPHidden = true
					for _, esp in pairs(Storage.ESPObjects) do
						pcall(function()
							esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false; esp.Distance.Visible = false
							if esp.Weapon then esp.Weapon.Visible = false end
						end)
					end
					for _, lines in pairs(Storage.SkeletonParts) do
						pcall(function() for _, l in pairs(lines) do l.Visible = false end end)
					end
					for _, ln in pairs(Storage.TracerLines) do
						pcall(function() ln.Visible = false end)
					end
					for _, a in pairs(Storage.OffscreenArrows) do
						pcall(function() a.Visible = false end)
					end
				end
			else
				Storage.ESPHidden = false
				for _, plr in pairs(Services.Players:GetPlayers()) do
					if plr == LocalPlayer then continue end
					local cData = Utils.GetCharacterData(plr)
					if not cData then continue end
					local pChar = cData.Char
					local root = cData.Root
					local head = cData.Head
					local isAlive, isUnspawned = Utils.IsAlive(plr, pChar)
					local esp = Storage.ESPObjects[plr]

					if not (isAlive or (Config.States.DetectUnspawned and isUnspawned)) then
						if esp then
							pcall(function()
								esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false; esp.Distance.Visible = false
								if esp.Weapon then esp.Weapon.Visible = false end
							end)
						end
						if Storage.SkeletonParts[plr] then pcall(function() for _, l in pairs(Storage.SkeletonParts[plr]) do l.Visible = false end end) end
						if Storage.TracerLines[plr] then pcall(function() Storage.TracerLines[plr].Visible = false end) end
						if Storage.OffscreenArrows[plr] then pcall(function() Storage.OffscreenArrows[plr].Visible = false end) end
						continue
					end

					if not esp then
						Features.CreateESP(plr)
						esp = Storage.ESPObjects[plr]
					end
					if not esp then continue end

					local rootCFrame = root.CFrame
					local topPos, topOn = CurrentCam:WorldToViewportPoint((rootCFrame * CFrame.new(0, 2.4, 0)).Position)
					local bottomPos, bottomOn = CurrentCam:WorldToViewportPoint((rootCFrame * CFrame.new(0, -3.2, 0)).Position)
					local onScreen = topOn or bottomOn

					local drawColor = Config.Theme.Stroke
					if isUnspawned then
						drawColor = Color3.fromRGB(190, 130, 255)
					elseif Storage.LockedTarget == plr then
						drawColor = Config.Theme.LockColor
					elseif Config.States.TeamCheck and Utils.IsTeammate(plr) then
						drawColor = Config.Theme.Team
					end
					if Config.States.VisibilityCheck and onScreen and topPos.Z > 0 and not isUnspawned and not Utils.IsVisible(head, plr) then
						drawColor = Color3.new(0.5, 0.5, 0.5)
					end

					if Config.States.Tracers then
						pcall(function()
							local ln = Storage.TracerLines[plr] or Drawing.new("Line"); Storage.TracerLines[plr] = ln
							if onScreen and topPos.Z > 0 then
								ln.Visible = true; ln.Thickness = Config.Vals.ESPBoxThickness or 1.5; ln.Color = drawColor
								local tOrigin = center
								if Config.Vals.TracerOrigin == "Bottom" then
									tOrigin = Vector2.new(center.X, CurrentCam.ViewportSize.Y)
								elseif Config.Vals.TracerOrigin == "Mouse" then
									local mPos = Services.UIS:GetMouseLocation()
									tOrigin = Vector2.new(mPos.X, mPos.Y)
								end
								ln.From = tOrigin; ln.To = Vector2.new(bottomPos.X, bottomPos.Y)
							else
								ln.Visible = false
							end
						end)
					elseif Storage.TracerLines[plr] and Storage.TracerLines[plr].Visible then
						pcall(function() Storage.TracerLines[plr].Visible = false end)
					end

					-- Off-screen Target Arrows (Guarded)
					if Config.States.OffscreenArrows then
						local arrowOk = pcall(function()
							local arrow = Storage.OffscreenArrows[plr]
							if not arrow then
								arrow = Drawing.new("Triangle"); arrow.Filled = true; Storage.OffscreenArrows[plr] = arrow
							end
							if (not onScreen or topPos.Z <= 0) and not (Config.States.TeamCheck and Utils.IsTeammate(plr)) then
								local rel = (root.Position - CurrentCam.CFrame.Position)
								local forward = CurrentCam.CFrame.LookVector
								local right = CurrentCam.CFrame.RightVector
								local dotForward = forward:Dot(rel); local dotRight = right:Dot(rel)
								local angle = math.atan2(dotRight, dotForward)
								local arrowRadius = math.min(CurrentCam.ViewportSize.X/2, CurrentCam.ViewportSize.Y/2) * 0.75
								local arrowCenter = center + Vector2.new(math.sin(angle) * arrowRadius, -math.cos(angle) * arrowRadius)
								local tip = arrowCenter + Vector2.new(math.sin(angle) * 12, -math.cos(angle) * 12)
								local leftPt = arrowCenter + Vector2.new(math.sin(angle + 2.5) * 8, -math.cos(angle + 2.5) * 8)
								local rightPt = arrowCenter + Vector2.new(math.sin(angle - 2.5) * 8, -math.cos(angle - 2.5) * 8)
								arrow.PointA = tip; arrow.PointB = leftPt; arrow.PointC = rightPt
								arrow.Color = drawColor; arrow.Visible = true
							else
								arrow.Visible = false
							end
						end)
						if not arrowOk then Config.States.OffscreenArrows = false end
					elseif Storage.OffscreenArrows[plr] then
						pcall(function() Storage.OffscreenArrows[plr].Visible = false end)
					end

					if onScreen and topPos.Z > 0 then
						local height = math.abs(topPos.Y - bottomPos.Y)
						local width = height / 1.6
						local boxX = topPos.X - width / 2
						local boxY = math.min(topPos.Y, bottomPos.Y)

						if Config.States.ESP then
							pcall(function()
								esp.Box.Visible = true; esp.Box.Size = Vector2.new(width, height); esp.Box.Position = Vector2.new(boxX, boxY); esp.Box.Color = drawColor; esp.Box.Transparency = 1
								esp.Box.Thickness = Config.Vals.ESPBoxThickness or 1.5
								esp.Name.Visible = (Config.States.ShowName ~= false); esp.Name.Size = Config.Vals.ESPTextSize or 13; esp.Name.Text = isUnspawned and (plr.DisplayName .. " [NO-SPAWN]") or plr.DisplayName; esp.Name.Position = Vector2.new(boxX + width / 2, boxY - 16); esp.Name.Color = drawColor
								esp.HealthBar.Visible = (Config.States.ShowHealth ~= false); local curHp, maxHp = Utils.GetHealth(plr, pChar); local healthRatio = math.clamp(curHp / maxHp, 0, 1)
								esp.HealthBar.Color = Color3.new(1 - healthRatio, healthRatio, 0)
								esp.HealthBar.From = Vector2.new(boxX - 5, boxY + height); esp.HealthBar.To = Vector2.new(boxX - 5, boxY + height - height * healthRatio)
								esp.Distance.Visible = (Config.States.ShowDistance ~= false); esp.Distance.Size = (Config.Vals.ESPTextSize or 13) - 1; esp.Distance.Text = string.format("%.0fm", (root.Position - (hrp and hrp.Position or root.Position)).Magnitude)
								esp.Distance.Position = Vector2.new(boxX + width / 2, boxY + height + 2); esp.Distance.Color = drawColor
								if Config.States.WeaponESP and esp.Weapon then
									local tool = pChar:FindFirstChildOfClass("Tool") or pChar:FindFirstChild("Gun") or pChar:FindFirstChild("EquippedTool")
									local wName = tool and tool.Name or "Unarmed"
									esp.Weapon.Visible = true
									esp.Weapon.Text = "[" .. wName .. "]"
									esp.Weapon.Position = Vector2.new(boxX + width / 2, boxY + height + 16)
									esp.Weapon.Color = Color3.fromRGB(255, 230, 100)
								elseif esp.Weapon then
									esp.Weapon.Visible = false
								end
							end)
						else
							pcall(function()
								esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false; esp.Distance.Visible = false
								if esp.Weapon then esp.Weapon.Visible = false end
							end)
						end

						if Config.States.ESPSkeleton and Storage.SkeletonParts[plr] then
							pcall(function()
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
								local headPos = CurrentCam:WorldToViewportPoint(head.Position); skel.HeadToTorso.Visible = true; skel.HeadToTorso.From = Vector2.new(headPos.X, headPos.Y); skel.HeadToTorso.To = Vector2.new(torsoPos.X, torsoPos.Y); skel.HeadToTorso.Color = drawColor
								skel.TorsoToLeftArm.Visible = true; skel.TorsoToLeftArm.From = Vector2.new(torsoPos.X, torsoPos.Y); skel.TorsoToLeftArm.To = Vector2.new(lArmPos.X, lArmPos.Y); skel.TorsoToLeftArm.Color = drawColor
								skel.TorsoToRightArm.Visible = true; skel.TorsoToRightArm.From = Vector2.new(torsoPos.X, torsoPos.Y); skel.TorsoToRightArm.To = Vector2.new(rArmPos.X, rArmPos.Y); skel.TorsoToRightArm.Color = drawColor
								skel.TorsoToLeftLeg.Visible = true; skel.TorsoToLeftLeg.From = Vector2.new(torsoPos.X, torsoPos.Y); skel.TorsoToLeftLeg.To = Vector2.new(lLegPos.X, lLegPos.Y); skel.TorsoToLeftLeg.Color = drawColor
								skel.TorsoToRightLeg.Visible = true; skel.TorsoToRightLeg.From = Vector2.new(torsoPos.X, torsoPos.Y); skel.TorsoToRightLeg.To = Vector2.new(rLegPos.X, rLegPos.Y); skel.TorsoToRightLeg.Color = drawColor
							end)
						elseif Storage.SkeletonParts[plr] then
							pcall(function() for _, part in pairs(Storage.SkeletonParts[plr]) do if part.Visible then part.Visible = false end end end)
						end
					else
						pcall(function()
							esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false; esp.Distance.Visible = false
							if Storage.SkeletonParts[plr] then for _, part in pairs(Storage.SkeletonParts[plr]) do if part.Visible then part.Visible = false end end end
						end)
					end
				end
			end
		end
	end)
	table.insert(Storage.Connections, renderConn)
	
	-- ======================================================================
	-- HEARTBEAT (V5.0.0: P1 FIXED - dt math & Fly/Desync Mutex)
	-- ======================================================================
	local heartbeatConn = Services.RunService.Heartbeat:Connect(function(dt)
		if not Utils.IsAlive(LocalPlayer, LocalPlayer.Character) then
			if LocalPlayer.Character then
				local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local bv = hrp:FindFirstChild("X_Fly_BV"); if bv then bv:Destroy() end
					local bg = hrp:FindFirstChild("X_Fly_BG"); if bg then bg:Destroy() end
					local lv = hrp:FindFirstChild("X_Speed_LV"); if lv then lv:Destroy() end
				end
			end
			return
		end
		-- [V5.6.0] Rainbow Chams & HUD Accent
		if Config.States.NoRecoil and LocalPlayer.Character then
			pcall(function()
				local myChar = LocalPlayer.Character
				for _, item in ipairs(myChar:GetChildren()) do
					if item:IsA("Tool") or item.Name == "Gun" then
						for _, v in ipairs(item:GetDescendants()) do
							if v:IsA("NumberValue") and (string.find(string.lower(v.Name), "recoil") or string.find(string.lower(v.Name), "spread")) then
								v.Value = 0
							end
						end
					end
				end
			end)
		end

		if Config.States.RainbowChams then
			local rainbow = Color3.fromHSV((tick() * 0.4) % 1, 0.9, 1)
			Config.Theme.Stroke = rainbow
		end

		-- [V5.6.0] Touch Fling Logic (PlayerCache Optimized)
		if Config.States.TouchFling and hrp then
			for p, data in pairs(Storage.PlayerCache) do
				if not (Config.States.TeamCheck and Utils.IsTeammate(p)) then
					local tHRP = data.Root
					if tHRP and (tHRP.Position - hrp.Position).Magnitude < 8 then
						hrp.AssemblyAngularVelocity = Vector3.new(999999, 999999, 999999)
						tHRP.AssemblyLinearVelocity = Vector3.new(math.random(-50000, 50000), 100000, math.random(-50000, 50000))
					end
				end
			end
		end

		-- [V5.6.0] Orbit Stalker Aura
		if Config.States.OrbitAura and Storage.LockedTarget and Storage.LockedTarget.Character and hrp then
			local tHRP = Storage.LockedTarget.Character:FindFirstChild("HumanoidRootPart")
			if tHRP then
				local angle = tick() * Config.Vals.OrbitSpeed
				local offset = Vector3.new(math.cos(angle) * Config.Vals.OrbitDistance, 3, math.sin(angle) * Config.Vals.OrbitDistance)
				hrp.CFrame = CFrame.lookAt(tHRP.Position + offset, tHRP.Position)
				hrp.AssemblyLinearVelocity = Vector3.zero
			end
		end

		-- [V5.6.0] Anti-Fling Immortality (PlayerCache Optimized)
		if Config.States.AntiFling and hrp then
			for p, data in pairs(Storage.PlayerCache) do
				local otherHRP = data.Root
				if otherHRP and (otherHRP.Position - hrp.Position).Magnitude < 15 then
					if otherHRP.AssemblyLinearVelocity.Magnitude > 70 or otherHRP.AssemblyAngularVelocity.Magnitude > 70 then
						for _, part in pairs(data.Char:GetDescendants()) do
							if part:IsA("BasePart") then part.CanCollide = false end
						end
						hrp.AssemblyAngularVelocity = Vector3.zero
					end
				end
			end
		end

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		if not hrp or not hum then return end
		
		if Storage.WalkSpeedSnapshotPending and not Config.States.SpeedHack then
			local currentHum = char:FindFirstChild("Humanoid")
			if currentHum then
				Storage.OriginalWalkSpeed = currentHum.WalkSpeed
				Storage.WalkSpeedSnapshotPending = false
			Storage.LastSafeCFrame = nil
			Storage.HitSoundObj = nil
			end
		end
		
		
		-- Vehicle Speed Boost & Aerial Fly
		if Config.States.VehicleBoost and hum and hum.SeatPart then
			local seat = hum.SeatPart
			if seat:IsA("VehicleSeat") then
				seat.MaxSpeed = math.max(seat.MaxSpeed, Config.Vals.VehicleSpeed)
				seat.Torque = 2000000
				seat.TurnSpeed = math.max(seat.TurnSpeed, 2.5)
			end
			local carRoot = seat.AssemblyRootPart or seat
			if carRoot then
				local isFwd = Services.UIS:IsKeyDown(Enum.KeyCode.W) or (hum.MoveDirection.Magnitude > 0 and hum.MoveDirection:Dot(seat.CFrame.LookVector) >= -0.1)
				local isBack = Services.UIS:IsKeyDown(Enum.KeyCode.S) or (hum.MoveDirection.Magnitude > 0 and hum.MoveDirection:Dot(seat.CFrame.LookVector) < -0.1)
				if isFwd or isBack then
					local dir = seat.CFrame.LookVector * (isFwd and 1 or -1)
					local curVel = carRoot.AssemblyLinearVelocity
					local target = dir * Config.Vals.VehicleSpeed
					carRoot.AssemblyLinearVelocity = Vector3.new(target.X, curVel.Y, target.Z)
				end
				if Config.States.VehicleFly then
					local vFlyDir = 0
					if Services.UIS:IsKeyDown(Enum.KeyCode.Space) or Services.UIS:IsKeyDown(Enum.KeyCode.E) then
						vFlyDir = 1
					elseif Services.UIS:IsKeyDown(Enum.KeyCode.LeftShift) or Services.UIS:IsKeyDown(Enum.KeyCode.Q) then
						vFlyDir = -1
					end
					if vFlyDir ~= 0 then
						carRoot.AssemblyLinearVelocity = Vector3.new(carRoot.AssemblyLinearVelocity.X, vFlyDir * (Config.Vals.VehicleSpeed * 0.75), carRoot.AssemblyLinearVelocity.Z)
					end
				end
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
		
		-- [ZERO-LAG COLLISION ENGINE] Only modify/restore when active states change
		local needsNoCollide = Config.States.Noclip or Storage.IsHiding
		local needsNoTouch = Config.States.AntiKillbrick
		if needsNoCollide then
			if not Storage.NoCollideActive then
				Storage.NoCollideActive = true
				Utils.SaveCollision(char, "collide")
			end
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
			end
		elseif Storage.NoCollideActive then
			Storage.NoCollideActive = false
			Utils.RestoreCollision(char, "collide")
		end
		if needsNoTouch then
			if not Storage.NoTouchActive then
				Storage.NoTouchActive = true
				Utils.SaveCollision(char, "touch")
				Services.Workspace.FallenPartsDestroyHeight = 0/0
			end
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") and v.CanTouch then v.CanTouch = false end
			end
		elseif Storage.NoTouchActive then
			Storage.NoTouchActive = false
			Utils.RestoreCollision(char, "touch")
			Services.Workspace.FallenPartsDestroyHeight = Storage.OriginalFallenHeight or -500
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
		if (i.KeyCode == Config.Keys.Menu or i.KeyCode == Enum.KeyCode.RightControl or i.KeyCode == Enum.KeyCode.RightShift) and Storage.MainFrame then
			local focused = Services.UIS:GetFocusedTextBox()
			if not focused then
				if not Storage.MenuDebounce then
					Storage.MenuDebounce = true
					Storage.MainFrame.Visible = not Storage.MainFrame.Visible
					local floatBtn = targetGui:FindFirstChild("X_Titan_Floating_Toggle", true)
					if floatBtn then
						floatBtn.Text = Storage.MainFrame.Visible and "✕" or "X"
						floatBtn.TextColor3 = Storage.MainFrame.Visible and Color3.fromRGB(255, 80, 80) or Config.Theme.Stroke
						local strk = floatBtn:FindFirstChildOfClass("UIStroke")
						if strk then strk.Color = Storage.MainFrame.Visible and Color3.fromRGB(255, 80, 80) or Config.Theme.Stroke end
					end
					Utils.Notify("📱 Menu", Storage.MainFrame.Visible and "OPENED" or "CLOSED", 1)
					task.delay(0.2, function() Storage.MenuDebounce = false end)
				end
				return
			end
		end
		if g then return end
		if i.KeyCode == Config.Keys.Unload then Runtime.Unload(); return end
		if i.UserInputType == Enum.UserInputType.MouseButton2 and Config.States.RightClickToggle then Config.States.Aimbot = true end
		if i.KeyCode == Config.Keys.Fly then
			if Storage.ToggleFuncs.Fly then
				Storage.ToggleFuncs.Fly(not Config.States.Fly)
			else
				Config.States.Fly = not Config.States.Fly
				Utils.Notify("✈️ Fly Mode", Config.States.Fly and "ENABLED" or "DISABLED", 1.5)
			end
		end
		if i.KeyCode == Config.Keys.Noclip then
			if Storage.ToggleFuncs.Noclip then
				Storage.ToggleFuncs.Noclip(not Config.States.Noclip)
			else
				Config.States.Noclip = not Config.States.Noclip
				Utils.Notify("👻 Noclip", Config.States.Noclip and "ENABLED" or "DISABLED", 1.5)
			end
		end
		if i.KeyCode == Config.Keys.Trigger then
			if Storage.ToggleFuncs.TriggerBot then
				Storage.ToggleFuncs.TriggerBot(not Config.States.TriggerBot)
			else
				Config.States.TriggerBot = not Config.States.TriggerBot
				Utils.Notify("⚡ TriggerBot", Config.States.TriggerBot and "ENABLED" or "DISABLED", 1.5)
			end
		end
		if i.KeyCode == Config.Keys.LockTarget then
			local Camera = Utils.GetCurrentCamera()
			if not Camera then return end
			if Storage.LockedTarget then
				local oldName = Storage.LockedTarget.Name
				Storage.LockedTarget = nil
				Storage.CurrentHPRatio = 0
				if Storage.TacticalHUD then Storage.TacticalHUD.Main.Visible = false end
				Utils.Notify("🔓 Target Unlocked", "Released focus on: " .. oldName)
			else
				local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local highestThreat, target = -1, nil
				for p, data in pairs(Storage.PlayerCache) do
					if not data.Char.Parent then continue end
					if not Utils.IsAlive(p, data.Char) then continue end
					if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end
					local aimPart = Utils.GetSmartAimPart(data.Char)
					if not aimPart then continue end
					local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
					if onScreen and pos.Z > 0 and (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude <= Config.Vals.FOV then
						local score = Utils.CalculateThreatScore(p, myHRP)
						if score > highestThreat then highestThreat = score; target = p end
					end
				end
				if target then
					Storage.LockedTarget = target
					Storage.CurrentHPRatio = 0
					Utils.Notify("🎯 Target Locked", "Locked: " .. target.Name .. " (1-Target Focus)")
				else
					Utils.Notify("❌ No Target", "No valid enemy inside FOV circle!")
				end
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
		if i.UserInputType == Enum.UserInputType.MouseButton1 and Config.States.SilentAim and not HasTitanMetamethodHook then
			TitanMicroFlickSilentAim()
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
			if Storage.ToggleFuncs.ShowFOV then
				Storage.ToggleFuncs.ShowFOV(not Config.States.ShowFOV)
			else
				Config.States.ShowFOV = not Config.States.ShowFOV
				if Storage.FOVRingUI then Storage.FOVRingUI.Visible = Config.States.ShowFOV end
				Utils.Notify("🎯 FOV Ring", Config.States.ShowFOV and "ENABLED" or "DISABLED", 1.5)
			end
		end
	end)
	table.insert(Storage.Connections, inputBeganConn)
	
	local inputEndedConn = Services.UIS.InputEnded:Connect(function(i, g)
		if g then return end
		if i.UserInputType == Enum.UserInputType.MouseButton2 and Config.States.RightClickToggle then Config.States.Aimbot = false end
	end)
	table.insert(Storage.Connections, inputEndedConn)
end

local itemLoop = task.spawn(function()
	while true do
		task.wait(Config.Vals.ItemScanInterval or 1.5)
		if Storage.IsUnloaded then break end
		if Config.States.ItemESP then
			pcall(UpdateItemESP)
		end
	end
end)
table.insert(Storage.Loops, itemLoop)


	-- Top-Right Watermark FPS & Ping updater (Anonymized: No Username)
	task.spawn(function()
		local fpsCount = 0
		local lastFpsTick = tick()
		Services.RunService.RenderStepped:Connect(function()
			fpsCount = fpsCount + 1
		end)
		while true do
			task.wait(0.5)
			if Storage.IsUnloaded then break end
			local now = tick()
			local currentFps = math.floor(fpsCount / (now - lastFpsTick))
			fpsCount = 0
			lastFpsTick = now
			
			local pingMs = 0
			pcall(function()
				local stats = game:GetService("Stats")
				local net = stats and stats:FindFirstChild("Network")
				if net and net:FindFirstChild("ServerStatsItem") and net.ServerStatsItem:FindFirstChild("Data Ping") then
					pingMs = math.floor(net.ServerStatsItem["Data Ping"]:GetValue())
				end
			end)
			if pingMs == 0 then pingMs = 28 end

			if Storage.WatermarkLabel then
				Storage.WatermarkLabel.Text = string.format("FPS: %d  |  PING: %dms", currentFps, pingMs)
				if currentFps >= 50 then
					Storage.WatermarkLabel.TextColor3 = Color3.fromRGB(90, 240, 140)
				elseif currentFps >= 30 then
					Storage.WatermarkLabel.TextColor3 = Color3.fromRGB(245, 200, 60)
				else
					Storage.WatermarkLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
				end
			end
		end
	end)

	Runtime.Init()
_G.X_TITAN_INSTANCE = { Config = Config, Storage = Storage, Utils = Utils, Features = Features, Runtime = Runtime }
Utils.Notify("✅ X TITAN V5.7.0 - TITAN GOD (APEX OMNI)", "VIP Exclusive Suite Online. Press [Insert] for Menu")
print("X TITAN V5.7.0 - TITAN GOD (APEX OMNI) PATCH LOADED SUCCESSFULLY")