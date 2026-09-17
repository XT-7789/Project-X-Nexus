-- [[ PROJECT X NEXUS - PROTECTED DISTRIBUTION ]]
-- Founder & Developer: XT-7789 | Official Seller: vlilayz
-- Security Protocol: Ephemeral Dynamic Session Handshake (V2.0.3)
local _rawSession = getgenv()._X_AUTH_SESSION
getgenv()._X_AUTH_SESSION = nil
getgenv()._X_AUTH_TOKEN = nil

local function _deny(reason)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ ACCESS DENIED",
            Text = "Direct execution blocked! (" .. tostring(reason) .. ") Please execute via Loader.lua",
            Duration = 6
        })
    end)
    warn("[X SUITE] Security Alert: " .. tostring(reason) .. " - Direct loadstring blocked!")
end

if type(_rawSession) ~= "table" then
    _deny("Missing Auth Session")
    return
end

local _ts = tonumber(_rawSession.Timestamp)
local _k = tostring(_rawSession.Key or "")
local _h = tostring(_rawSession.HWID or "")
local _n = tostring(_rawSession.Nonce or "")
local _sig = tostring(_rawSession.Signature or "")

local _now = math.floor(tick())
if not _ts or math.abs(_now - _ts) > 30 then
    _deny("Session Expired")
    return
end

local function _hash(s)
    local h = 5381
    for i = 1, #s do
        h = ((h * 33) + string.byte(s, i)) % 2147483647
    end
    return string.format("%08x", h)
end

local _expectedSig = _hash(tostring(_ts) .. ":" .. _k .. ":" .. _h .. ":" .. _n .. ":XT7789_NEXUS_SECURITY_SALT_2026")
if _sig ~= _expectedSig then
    _deny("Invalid Signature")
    return
end

-- [[ X TITAN V6.3.0 - GEN-6 TITAN GOD (APEX OMNI) ]]
-- Founder & Developer: XT-7789 | Official Seller: vlilayz
-- P1: Sticky Track & Hysteresis Lock (Target Switching Anti-Jitter)
-- P2: Frame-Rate Independent DeltaTime Exponential Damped Smoothing
-- P3: Target Visibility Status HUD Indicator ([LOCKED] / [OCCLUDED])
-- P4: cloneref Anti-Detection Metamethod & Synchronized Hitmarkers
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
local safeCloneRef = (type(cloneref) == "function" and cloneref) or function(o) return o end
local Services = {
	Players = safeCloneRef(game:GetService("Players")),
	RunService = safeCloneRef(game:GetService("RunService")),
	UIS = safeCloneRef(game:GetService("UserInputService")),
	Lighting = safeCloneRef(game:GetService("Lighting")),
	TweenService = safeCloneRef(game:GetService("TweenService")),
	Workspace = safeCloneRef(game:GetService("Workspace")),
	StarterGui = safeCloneRef(game:GetService("StarterGui")),
	SoundService = safeCloneRef(game:GetService("SoundService")),
	Stats = safeCloneRef(game:GetService("Stats")),
	HttpService = safeCloneRef(game:GetService("HttpService"))
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
-- CONFIGURATION & STORAGE (V6.3.0)
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
		ESP = false, ESP3D = false, ESPSkeleton = false, ESPLookRay = false, MultiBoneAim = true, Tracers = false, Resolver = true, VisibilityCheck = false, Chams = false,
		XRay = false, Fullbright = false, Crosshair = false, DynamicCrosshair = true,
		Fly = false, SpeedHack = false, InfJump = false, Noclip = false, NoFall = false,
		AntiKillbrick = false, AntiVoid = true, HitSound = true, TouchFling = false, TargetFling = false, AntiFling = true, Wallbang = true, OrbitAura = false, ClickTP = false, SkyHide = false, MapDestroyer = false,
		KillAura = false, TPAura = false, Desync = false, AntiAimSpin = false, AntiAimHeadJitter = false,
		RightClickToggle = true, ShowFOV = false, TacticalLock = false,
		ShowLockStatus = true, SmartPrediction = true, AutoAimPart = false,
		LegitFly = false, ServerDesync = false, CFrameSpeed = false, Radar = false, ItemESP = false, VehicleBoost = false, VehicleFly = false,
		WeaponESP = true, OffscreenArrows = false, NoRecoil = false, DetectUnspawned = true,
		ShowDistance = true, ShowHealth = true, ShowName = true,
		AimbotFailover = true, BillboardTags = false,
		AdaptiveFPS = true, Hitmarker = true, StickyAim = true, TargetStatus = true
	},
	Vals = {
		FOV = 200, OrbitDistance = 8, OrbitSpeed = 8, FlingPower = 100000, WalkSpeed = 150, FlySpeed = 150, HitboxSize = 15, HeadSize = 25,
		AimbotSmoothness = 0.3, PredictionStrength = 0.16, DesyncPower = 5,
		AuraRange = 25, TPBehindDist = 4, TriggerDelay = 0.15,
		AntiAimSpinSpeed = 10, AntiAimJitterRadius = 5, AimPart = "Head",
		Deadzone = 5, PingCompensation = 0.05, RadarRange = 100, LegitFlySmooth = 0.1, VehicleSpeed = 180,
		ESPRefreshRate = 0.3, ESPBoxThickness = 1.5, ESPTextSize = 13, ItemScanInterval = 1.5, TracerOrigin = "Bottom",
		AimbotPlan = "Auto", ESPEngine = "Auto",
		TargetPriority = "Crosshair", HitSoundPreset = "Neverlose", StickyFOVMult = 1.35, StickyGrace = 0.25, StickyHysteresis = 2500
	}
}

local Storage = {
	Checkpoints = {P1=nil, P2=nil, P3=nil},
	ESPObjects = {}, SkeletonParts = {}, Box3DObjects = {}, LookRayLines = {}, OffscreenDistTexts = {}, TracerLines = {},
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
	StickyTarget = nil,
	StickyTargetPart = nil,
	StickyLostTick = 0,
	TargetStatusDrawing = nil,
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
	LastAdaptiveEspTick = 0,
	CachedTargetPart = nil,
	CachedIsWall = false,
	CrosshairVisible = false,
	CharCache = {},
	VisCache = {},
	NativePlayerTags = {},
	AimbotCameraOverrideCount = 0, CameraOverrideDetected = false, DrawingBroken = false,
	AimbotPlans = {"Auto", "Plan A (Camera)", "Plan B (MouseMove)", "Plan C (Silent)"}, AimbotPlanIndex = 1,
	ESPEngines = {"Auto", "Plan A (Drawing)", "Plan B (3D Chams)", "Plan C (Billboard)"}, ESPEngineIndex = 1,
	TargetPriorities = {"Crosshair", "LowestHP", "Distance3D", "Threat"}, TargetPriorityIndex = 1,
	HitSoundPresets = {"Neverlose", "Skeet", "Rust", "Ding", "Pop"}, HitSoundIndex = 1
}

_G.X_TITAN_CURRENT_INSTANCE = {
	Config = Config,
	Storage = Storage,
	Utils = nil,
	Features = nil
}

-- ==============================================================================
-- UTILITIES (V6.3.0)
-- ==============================================================================
-- ==============================================================================
-- KEY & FOUNDER AUTHENTICATION (TITAN+ PRO-X APEX)
-- ==============================================================================
local activeKey = tostring(getgenv().Key or getgenv().ScriptKey or script_key or "")
local upperKey = string.upper(activeKey)
local isFounder = (upperKey == "X-TITAN-PLUS-XT7789") or (string.find(upperKey, "XT7789") ~= nil)
local isSeller = (upperKey == "X-TITAN-X")
local isTitanPlus = isFounder or isSeller

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
	if cached and (now - cached.LastResolve < (Config.Vals.ESPRefreshRate or 0.25)) then
		if cached.Char and cached.Char.Parent and cached.Root and cached.Root.Parent then
			if cached.Hum then
				cached.CurHp = cached.Hum.Health
				cached.MaxHp = (cached.Hum.MaxHealth > 0) and cached.Hum.MaxHealth or 100
			end
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

	local curHp, maxHp = 100, 100
	if hum then
		curHp = hum.Health
		maxHp = (hum.MaxHealth > 0) and hum.MaxHealth or 100
	else
		curHp, maxHp = Utils.GetHealth(plr, char)
	end

	local data = cached or {}
	data.Char = char
	data.Head = head
	data.Root = root
	data.Hum = hum
	data.IsAlive = isAlive
	data.IsUnspawned = isUnspawned
	data.CurHp = curHp
	data.MaxHp = maxHp
	data.LastResolve = now
	if not data.Weapon or (now - (data.LastWeaponCheck or 0) > 0.6) then
		data.Weapon = Utils.GetEquippedWeapon(plr, char)
		data.LastWeaponCheck = now
	end

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
	local cParent = char.Parent
	if cParent and cParent ~= Services.Workspace then
		local pName = cParent.Name
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

	-- 4. [PERF FAST-PATH]: Standard Roblox Humanoid (Covers 98% of standard games with ZERO string lookups)
	hum = hum or char:FindFirstChildOfClass("Humanoid")
	if hum then
		if hum.Health <= 0 then return false, false end
		local state = hum:GetState()
		if state == Enum.HumanoidStateType.Dead then return false, false end
		if (state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll) and (hum.Health <= 1 or not hum.RequiresNeck) then
			return false, false
		end
		-- Fast direct attribute check (no table iteration)
		if char:GetAttribute("Dead") == true or char:GetAttribute("IsDead") == true or char:GetAttribute("Ragdoll") == true or char:GetAttribute("Downed") == true then
			return false, false
		end
		local head = char:FindFirstChild("Head")
		if not head or not head.Parent then return false, false end
		if isFarawayLobby then return false, true end
		return true, false
	end

	-- 5. Fallback for non-Humanoid custom bodies (Arsenal NRPBS, Frontlines, etc.)
	if plr and (game.PlaceId == 286090429 or game.GameId == 111958650 or plr:FindFirstChild("NRPBS")) then
		local nrpbs = plr:FindFirstChild("NRPBS")
		if nrpbs then
			local hpVal = nrpbs:FindFirstChild("Health")
			if hpVal and hpVal:IsA("ValueBase") and (tonumber(hpVal.Value) or 0) <= 0 then
				return false, false
			end
		end
	end

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

	for _, dAttr in ipairs({"Dead", "IsDead", "Ragdoll", "Ragdolled", "Downed", "Knocked", "Killed", "Unconscious", "Fainted"}) do
		if char:GetAttribute(dAttr) == true or (plr and plr:GetAttribute(dAttr) == true) then
			return false, false
		end
	end

	local curHp, _ = Utils.GetHealth(plr, char)
	if curHp <= 0 then return false, false end

	local head = char:FindFirstChild("Head")
	if not head or not head.Parent then return false, false end
	local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	if torso and not hum then
		local neck = head:FindFirstChild("Neck") or torso:FindFirstChild("Neck") or head:FindFirstChildOfClass("Motor6D") or torso:FindFirstChildOfClass("Motor6D")
		if not neck then return false, false end
	end

	if isFarawayLobby then return false, true end
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

local cachedFilterChar = nil
local cachedFilterCam = nil
local function UpdateRaycastFilter(cam)
	local c = LocalPlayer.Character
	if c ~= cachedFilterChar or cam ~= cachedFilterCam then
		cachedFilterChar = c
		cachedFilterCam = cam
		local filter = {}
		if cachedFilterChar then table.insert(filter, cachedFilterChar) end
		if cachedFilterCam then table.insert(filter, cachedFilterCam) end
		SharedRaycastParams.FilterDescendantsInstances = filter
	end
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

	UpdateRaycastFilter(Camera)
	local success, result = pcall(Services.Workspace.Raycast, Services.Workspace, origin, direction, SharedRaycastParams)
	local isVis = false
	if not success or not result then
		isVis = true
	elseif result.Instance and result.Instance:IsDescendantOf(targetHead.Parent) then
		isVis = true
	elseif Config.States.Wallbang and result.Instance then
		-- [WALLBANG PENETRATION]: Penetrate non-collidable, glass, wood, or thin cover
		local inst = result.Instance
		if not inst.CanCollide or inst.Transparency > 0.35 or inst.Material == Enum.Material.Glass or inst.Material == Enum.Material.Wood or inst.Size.Magnitude < 4 then
			isVis = true
		end
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
		local stats = Services.Stats or safeCloneRef(game:GetService("Stats"))
		if stats and stats.Network and stats.Network.ServerStatsItem then
			ping = stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end
	end)
	return ping
end


local HitSoundMap = {
	Neverlose = "rbxassetid://6534948092",
	Skeet = "rbxassetid://4817809188",
	Rust = "rbxassetid://5043539516",
	Ding = "rbxassetid://2865227271",
	Pop = "rbxassetid://198598793"
}

function Utils.PlayHitSound()
	if Config.States.Hitmarker then
		Storage.HitmarkerAlpha = 1.0
	end
	if not Config.States.HitSound then return end
	pcall(function()
		local soundId = HitSoundMap[Config.Vals.HitSoundPreset] or "rbxassetid://6534948092"
		if not Storage.HitSoundObj or Storage.HitSoundObj.SoundId ~= soundId then
			if Storage.HitSoundObj then Storage.HitSoundObj:Destroy() end
			local snd = Instance.new("Sound")
			snd.SoundId = soundId
			snd.Volume = 0.95
			snd.Parent = Services.SoundService or Services.Workspace
			Storage.HitSoundObj = snd
		end
		Storage.HitSoundObj:Play()
	end)
end

local ConfigFolder = "ProjectX_Titan_Configs"

function Utils.SaveConfig(name)
	if type(writefile) ~= "function" then
		Utils.Notify("⚠️ Storage Notice", "Executor does not support writefile.")
		return false
	end
	local ok = pcall(function()
		if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(ConfigFolder) then
			makefolder(ConfigFolder)
		end
		local payload = {
			States = Config.States,
			Vals = Config.Vals
		}
		writefile(ConfigFolder .. "/" .. name .. ".json", Services.HttpService:JSONEncode(payload))
		Utils.Notify("💾 Config Saved", "Preset saved as: " .. name)
	end)
	return ok
end

function Utils.LoadConfig(name)
	if type(readfile) ~= "function" or type(isfile) ~= "function" then
		Utils.Notify("⚠️ Storage Notice", "Executor does not support readfile.")
		return false
	end
	local path = ConfigFolder .. "/" .. name .. ".json"
	if not isfile(path) then
		Utils.Notify("❌ Config Missing", "Preset file not found: " .. name)
		return false
	end
	local ok = pcall(function()
		local content = readfile(path)
		local data = Services.HttpService:JSONDecode(content)
		if data and data.States then
			for k, v in pairs(data.States) do
				if Config.States[k] ~= nil then Config.States[k] = v end
			end
		end
		if data and data.Vals then
			for k, v in pairs(data.Vals) do
				if Config.Vals[k] ~= nil then Config.Vals[k] = v end
			end
		end
		Utils.Notify("📂 Config Loaded", "Preset active: " .. name)
	end)
	return ok
end

function Utils.ApplyPreset(presetName)
	if presetName == "Legit" then
		Config.States.Aimbot = true
		Config.Vals.AimbotSmoothness = 0.65
		Config.Vals.FOV = 120
		Config.Vals.TargetPriority = "Crosshair"
		Config.States.WallCheck = true
		Config.States.SilentAim = false
		Config.States.HeadExpander = false
		Config.States.Hitbox = false
		Config.States.ESP = true
		Config.States.Chams = false
		Utils.Notify("⚡ Preset Applied", "Legit Esports profile active.")
	elseif presetName == "Rage" then
		Config.States.Aimbot = true
		Config.Vals.AimbotSmoothness = 0.05
		Config.Vals.FOV = 600
		Config.Vals.TargetPriority = "Threat"
		Config.States.WallCheck = false
		Config.States.Wallbang = true
		Config.States.SilentAim = true
		Config.States.HeadExpander = true
		Config.States.Hitbox = true
		Config.States.ESP = true
		Config.States.Chams = true
		Utils.Notify("🔥 Preset Applied", "God Rage profile active.")
	elseif presetName == "CQB" then
		Config.States.Aimbot = true
		Config.Vals.AimbotSmoothness = 0.2
		Config.Vals.FOV = 280
		Config.Vals.TargetPriority = "Distance3D"
		Config.States.WallCheck = true
		Config.States.ESP = true
		Utils.Notify("🎯 Preset Applied", "CQB Close-Quarters profile active.")
	elseif presetName == "HvHGod" then
		Config.States.Aimbot = true
		Config.Vals.AimbotSmoothness = 0.0
		Config.Vals.FOV = 1000
		Config.Vals.TargetPriority = "Threat"
		Config.States.WallCheck = false
		Config.States.Wallbang = true
		Config.States.SilentAim = true
		Config.States.HeadExpander = true
		Config.Vals.HeadSize = 80
		Config.States.Hitbox = true
		Config.Vals.HitboxSize = 80
		Config.States.TriggerBot = true
		Config.States.ESP = true
		Config.States.ESPSkeleton = true
		Config.States.Tracers = true
		Config.States.Chams = true
		Config.States.Desync = true
		Config.States.AntiAimSpin = true
		Utils.Notify("👑 Preset Applied", "HvH Godmode (Dominator) active!")
	elseif presetName == "SilentGhost" then
		Config.States.Aimbot = false
		Config.States.SilentAim = true
		Config.Vals.FOV = 350
		Config.States.ShowFOV = false
		Config.States.WallCheck = false
		Config.States.Wallbang = true
		Config.States.HeadExpander = false
		Config.States.Hitbox = false
		Config.States.ESP = true
		Config.States.Chams = true
		Config.States.VisibilityCheck = true
		Utils.Notify("👻 Preset Applied", "Silent Ghost (Stealth Domination) active!")
	end
end

function Utils.GetEquippedWeapon(plr, char)
	if not char then return "Unarmed" end
	
	-- Heuristic 1: Standard Roblox Tool directly in Character
	local tool = char:FindFirstChildOfClass("Tool")
	if tool and tool.Name and tool.Name ~= "" then
		return tool.Name
	end
	
	-- Heuristic 2: Character/Player Attributes
	local attrKeys = {"EquippedWeapon", "CurrentWeapon", "Weapon", "EquippedTool", "ActiveWeapon", "HeldItem", "Gun"}
	for _, k in ipairs(attrKeys) do
		local a = char:GetAttribute(k) or (plr and plr:GetAttribute(k))
		if a and type(a) == "string" and a ~= "" and a ~= "None" then
			return a
		end
	end
	
	-- Heuristic 3: ValueObjects inside Character or Player
	for _, k in ipairs(attrKeys) do
		local obj = char:FindFirstChild(k) or (plr and plr:FindFirstChild(k))
		if obj then
			if obj:IsA("StringValue") and obj.Value ~= "" and obj.Value ~= "None" then
				return obj.Value
			elseif obj:IsA("ObjectValue") and obj.Value then
				return obj.Value.Name
			end
		end
	end
	
	-- Heuristic 4: Dedicated Weapon / Equipment Folders
	local folders = {"Weapons", "Equipped", "Gun", "Guns", "CurrentWeapon", "Armory", "Equipment"}
	for _, fName in ipairs(folders) do
		local f = char:FindFirstChild(fName)
		if f then
			if f:IsA("Tool") or f:IsA("Model") then
				return f.Name
			end
			for _, c in ipairs(f:GetChildren()) do
				if (c:IsA("Model") or c:IsA("Tool") or c:IsA("BasePart")) and c.Name ~= "" and c.Name ~= "None" then
					return c.Name
				end
			end
		end
	end
	
	-- Heuristic 5: Motor6D / Weld Attachment in Hands (Custom Viewmodels/Rigs)
	local hands = {
		char:FindFirstChild("RightHand"), char:FindFirstChild("Right Arm"),
		char:FindFirstChild("LeftHand"), char:FindFirstChild("Left Arm")
	}
	for _, hand in ipairs(hands) do
		if hand then
			for _, j in ipairs(hand:GetChildren()) do
				if j:IsA("Motor6D") or j:IsA("Weld") or j:IsA("WeldConstraint") then
					local part = j.Part1 or j.Part0
					if part and part ~= hand then
						local pName = part.Name:lower()
						if not pName:find("arm") and not pName:find("hand") and not pName:find("torso") and not pName:find("root") then
							local m = part:FindFirstAncestorWhichIsA("Model")
							if m and m ~= char and m.Parent == char then
								return m.Name
							elseif part.Parent == char and part.Name ~= "Handle" then
								return part.Name
							elseif part.Parent and part.Parent ~= char and part.Parent ~= Services.Workspace then
								return part.Parent.Name
							end
						end
					end
				end
			end
		end
	end
	
	-- Heuristic 6: Direct Child Models with Weapon Indicators
	for _, child in ipairs(char:GetChildren()) do
		if child:IsA("Model") and child.Name ~= char.Name and not child:FindFirstChildOfClass("Humanoid") and not child:IsA("Accessory") then
			local cName = child.Name:lower()
			if child:FindFirstChild("Handle") or child:FindFirstChild("Muzzle") or child:FindFirstChild("Sight") or child:FindFirstChild("Barrel") or child:FindFirstChild("Mag") or child:FindFirstChild("Magazine") or child:FindFirstChild("Ammo") then
				return child.Name
			end
			if cName:find("gun") or cName:find("rifle") or cName:find("pistol") or cName:find("sword") or cName:find("knife") or cName:find("bow") or cName:find("blade") or cName:find("shotgun") or cName:find("sniper") or cName:find("smg") then
				return child.Name
			end
		end
	end
	
	return "Unarmed"
end

function Utils.CalculateThreatScore(plr, myHRP, screenDist)
	if not plr.Character or not myHRP then return 0 end
	local eHRP = plr.Character:FindFirstChild("HumanoidRootPart")
	local eHead = plr.Character:FindFirstChild("Head")
	if not eHRP or not eHead then return 0 end
	local dist = (eHRP.Position - myHRP.Position).Magnitude
	-- [CQB PRIORITY]: Close targets pose immediate lethal danger
	local score = 3000 / math.max(dist, 1)
	local targetLook = eHead.CFrame.LookVector
	local toMe = (myHRP.Position - eHead.Position).Unit
	if targetLook:Dot(toMe) > 0.85 then score = score + 800 end
	local vel = eHRP.AssemblyLinearVelocity.Magnitude
	if vel > 20 then score = score + 200 end
	if screenDist then
		score = score + math.max(0, 300 - screenDist)
	end
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

	-- [GEN-6.1 MULTI-BONE DYNAMIC ADAPTIVE TARGETING]
	if Config.States.MultiBoneAim and Camera then
		local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
		local checkBoneNames = {
			"Head", "UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart",
			"RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm",
			"Right Arm", "Left Arm"
		}
		local bestPart, bestDist = nil, 99999
		for _, bName in ipairs(checkBoneNames) do
			local bone = character:FindFirstChild(bName)
			if bone and bone:IsA("BasePart") then
				local pos, onScreen = Camera:WorldToViewportPoint(bone.Position)
				if onScreen and pos.Z > 0 then
					local isVis = true
					if Config.States.WallCheck then
						isVis = Utils.IsVisible(bone, nil)
					end
					if isVis then
						local sDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
						if bName == "Head" then sDist = sDist * 0.85 end -- Priority bias for headshots
						if sDist < bestDist then
							bestDist = sDist
							bestPart = bone
						end
					end
			end
		end
		end
		if bestPart then return bestPart end
	end

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
	
	-- Manual Target Lock has absolute priority
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
	
	-- [STICKY TRACK & HYSTERESIS RETENTION ENGINE]
	-- While sticky aim is engaged, maintain lock on current sticky target inside expanded boundary
	if Config.States.StickyAim and Storage.StickyTarget and Storage.StickyTarget.Parent then
		local sPlr = Storage.StickyTarget
		local sChar = sPlr.Character
		local isAlive = sChar and Utils.IsAlive(sPlr, sChar)
		local isTeam = Config.States.TeamCheck and Utils.IsTeammate(sPlr)
		if isAlive and not isTeam then
			local sPart = Utils.GetSmartAimPart(sChar)
			if sPart then
				local sPos, sOnScreen = Camera:WorldToViewportPoint(sPart.Position)
				if sOnScreen and sPos.Z > 0 then
					local sDist = (Vector2.new(sPos.X, sPos.Y) - center).Magnitude
					local retFOV = Config.Vals.FOV * (Config.Vals.StickyFOVMult or 1.35)
					local isVis = Utils.IsVisible(sPart, sPlr)
					if sDist <= retFOV then
						if not Config.States.WallCheck or isVis then
							Storage.StickyLostTick = tick()
							Storage.StickyTargetPart = sPart
							return sPart, false
						else
							-- Occluded: verify grace period
							if (tick() - Storage.StickyLostTick) <= (Config.Vals.StickyGrace or 0.25) then
								return sPart, true
							else
								Storage.StickyTarget = nil
							end
						end
					else
						-- Outside expanded retention FOV: verify grace period
						if (tick() - Storage.StickyLostTick) <= (Config.Vals.StickyGrace or 0.25) then
							return sPart, not isVis
						else
							Storage.StickyTarget = nil
						end
					end
				else
					-- Temporarily offscreen: grace buffer
					if (tick() - Storage.StickyLostTick) > (Config.Vals.StickyGrace or 0.25) then
						Storage.StickyTarget = nil
					end
				end
			else
				Storage.StickyTarget = nil
			end
		else
			Storage.StickyTarget = nil
		end
	end
	
	local highestThreat, targetPart, bestPlayer, bestIsWall = -1, nil, nil, false
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
			local targetDist3D = myHRP and (aimPart.Position - myHRP.Position).Magnitude or 100
			-- CQB FOV Retention Buffer: close targets receive expanded FOV buffer
			local effectiveFOV = Config.Vals.FOV
			if targetDist3D < 35 or Storage.LockedTarget == p or Storage.StickyTarget == p then
				effectiveFOV = effectiveFOV * (1.0 + math.clamp((35 - targetDist3D) / 35, 0.1, 0.5))
			end
			if screenDist <= effectiveFOV then
				local isVis = Utils.IsVisible(aimPart, p)
				if Config.States.WallCheck and not isVis then continue end
				local score = 0
				local priority = Config.Vals.TargetPriority or "Crosshair"
				if priority == "Crosshair" then
					score = (effectiveFOV - screenDist) * 10
				elseif priority == "LowestHP" then
					local curHp, maxHp = Utils.GetHealth(p, cData.Char)
					score = 10000 - curHp
				elseif priority == "Distance3D" then
					score = 5000 / math.max(targetDist3D, 1)
				else -- "Threat"
					score = Utils.CalculateThreatScore(p, myHRP, screenDist)
				end
				
				-- [HYSTERESIS ANTI-JITTER LOCK]:
				-- Strongly bias toward the currently locked sticky target to eliminate camera jitter
				if Config.States.StickyAim and Storage.StickyTarget == p then
					score = score + (Config.Vals.StickyHysteresis or 2500)
				end
				
				if score > highestThreat then
					highestThreat = score
					targetPart = aimPart
					bestPlayer = p
					bestIsWall = not isVis
				end
			end
		end
	end
	
	if bestPlayer and targetPart then
		if Config.States.StickyAim then
			Storage.StickyTarget = bestPlayer
			Storage.StickyTargetPart = targetPart
			Storage.StickyLostTick = tick()
		end
		return targetPart, bestIsWall
	end
	
	if Config.States.StickyAim and (tick() - Storage.StickyLostTick) > (Config.Vals.StickyGrace or 0.25) then
		Storage.StickyTarget = nil
		Storage.StickyTargetPart = nil
	end
	return nil, false
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
					highlight.Name = "X_Chams"; highlight.FillTransparency = 0.55; highlight.OutlineTransparency = 0.15
				end
				if Utils.IsTeammate(p) then
					highlight.FillColor = Config.Theme.Team
					highlight.OutlineColor = Config.Theme.Team
				else
					local head = p.Character:FindFirstChild("Head")
					local isVis = head and Utils.IsVisible(head, p)
					highlight.FillColor = isVis and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 160, 20)
					highlight.OutlineColor = isVis and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 200, 60)
				end
			else
				if highlight then highlight:Destroy() end
			end
		end
	end
end

function Features.UpdateNativeTags()
	local wantTags = Config.States.BillboardTags or (Config.States.ESP and (Storage.DrawingBroken or Config.Vals.ESPEngine == "Plan C (Billboard)" or Config.Vals.ESPEngine == "Auto"))
	if not wantTags then
		for p, gui in pairs(Storage.NativePlayerTags) do
			pcall(function() gui:Destroy() end)
		end
		table.clear(Storage.NativePlayerTags)
		return
	end
	
	local itemGuiParent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or targetGui
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p == LocalPlayer then continue end
		local char = p.Character
		if not char or not char.Parent then
			if Storage.NativePlayerTags[p] then
				pcall(function() Storage.NativePlayerTags[p]:Destroy() end)
				Storage.NativePlayerTags[p] = nil
			end
			continue
		end
		
		local isAlive, isUnspawned = Utils.IsAlive(p, char)
		if not (isAlive or (Config.States.DetectUnspawned and isUnspawned)) then
			if Storage.NativePlayerTags[p] then
				pcall(function() Storage.NativePlayerTags[p]:Destroy() end)
				Storage.NativePlayerTags[p] = nil
			end
			continue
		end
		
		if Config.States.TeamCheck and Utils.IsTeammate(p) then
			if Storage.NativePlayerTags[p] then
				pcall(function() Storage.NativePlayerTags[p]:Destroy() end)
				Storage.NativePlayerTags[p] = nil
			end
			continue
		end
		
		local cData = Utils.GetCharacterData(p)
		if not cData or not (cData.IsAlive or (Config.States.DetectUnspawned and cData.IsUnspawned)) then
			if Storage.NativePlayerTags[p] then
				pcall(function() Storage.NativePlayerTags[p]:Destroy() end)
				Storage.NativePlayerTags[p] = nil
			end
			continue
		end
		local head = cData.Head or cData.Root
		if not head then continue end
		
		local bg = Storage.NativePlayerTags[p]
		local drawColor = cData.IsUnspawned and Color3.fromRGB(190, 130, 255) or ((Storage.LockedTarget == p) and Config.Theme.LockColor or Config.Theme.Stroke)
		local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local dist = myHRP and math.floor((head.Position - myHRP.Position).Magnitude) or 0
		local curHp = cData.CurHp or 100
		local maxHp = cData.MaxHp or 100
		local wName = cData.Weapon or "Unarmed"
		
		if not bg or not bg.Parent then
			bg = Instance.new("BillboardGui")
			bg.Name = "X_TITAN_TAG_" .. p.Name
			bg.AlwaysOnTop = true
			bg.Size = UDim2.new(0, 160, 0, 48)
			bg.StudsOffset = Vector3.new(0, 2.8, 0)
			bg.Adornee = head
			bg.MaxDistance = 1500
			
			local tagLabel = Instance.new("TextLabel", bg)
			tagLabel.Name = "NameTag"
			tagLabel.Size = UDim2.new(1, 0, 0, 16)
			tagLabel.Position = UDim2.new(0, 0, 0, 0)
			tagLabel.BackgroundTransparency = 1
			tagLabel.Font = Enum.Font.GothamBold
			tagLabel.TextSize = 12
			tagLabel.TextColor3 = drawColor
			tagLabel.TextStrokeTransparency = 0.2
			tagLabel.Text = p.DisplayName .. " [" .. tostring(dist) .. "m]"
			
			local hpBar = Instance.new("Frame", bg)
			hpBar.Name = "HPBar"
			hpBar.Size = UDim2.new(0.8, 0, 0, 3)
			hpBar.Position = UDim2.new(0.1, 0, 0, 18)
			hpBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			hpBar.BorderSizePixel = 0
			
			local hpFill = Instance.new("Frame", hpBar)
			hpFill.Name = "Fill"
			local ratio = math.clamp(curHp / maxHp, 0, 1)
			hpFill.Size = UDim2.new(ratio, 0, 1, 0)
			hpFill.BackgroundColor3 = Color3.new(1 - ratio, ratio, 0)
			hpFill.BorderSizePixel = 0
			
			local wLabel = Instance.new("TextLabel", bg)
			wLabel.Name = "WepTag"
			wLabel.Size = UDim2.new(1, 0, 0, 14)
			wLabel.Position = UDim2.new(0, 0, 0, 24)
			wLabel.BackgroundTransparency = 1
			wLabel.Font = Enum.Font.GothamMedium
			wLabel.TextSize = 10
			wLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
			wLabel.TextStrokeTransparency = 0.3
			wLabel.Text = "[" .. wName .. "]"
			
			bg.Parent = itemGuiParent
			Storage.NativePlayerTags[p] = bg
		else
			bg.Adornee = head
			local tagLabel = bg:FindFirstChild("NameTag")
			if tagLabel then
				tagLabel.TextColor3 = drawColor
				tagLabel.Text = p.DisplayName .. " [" .. tostring(dist) .. "m]"
			end
			local hpBar = bg:FindFirstChild("HPBar")
			if hpBar then
				local hpFill = hpBar:FindFirstChild("Fill")
				if hpFill then
					local ratio = math.clamp(curHp / maxHp, 0, 1)
					hpFill.Size = UDim2.new(ratio, 0, 1, 0)
					hpFill.BackgroundColor3 = Color3.new(1 - ratio, ratio, 0)
				end
			end
			local wLabel = bg:FindFirstChild("WepTag")
			if wLabel then
				wLabel.Text = "[" .. wName .. "]"
			end
		end
	end
	
	for p, bg in pairs(Storage.NativePlayerTags) do
		if not Services.Players:FindFirstChild(p.Name) or not p.Character then
			pcall(function() bg:Destroy() end)
			Storage.NativePlayerTags[p] = nil
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
	-- 14-Bone Anatomical Skeleton
	local skelLines = {}
	for i = 1, 14 do
		local line = Drawing.new("Line")
		line.Thickness = 1.5
		line.Color = Config.Theme.Stroke
		line.Visible = false
		table.insert(skelLines, line)
	end
	Storage.SkeletonParts[plr] = skelLines

	-- 12-Line 3D Oriented Bounding Box Wireframe
	local box3DLines = {}
	for i = 1, 12 do
		local line = Drawing.new("Line")
		line.Thickness = 1.5
		line.Color = Config.Theme.Stroke
		line.Visible = false
		table.insert(box3DLines, line)
	end
	Storage.Box3DObjects[plr] = box3DLines

	-- 3D Look Vector Ray
	local lookRay = Drawing.new("Line")
	lookRay.Thickness = 1.5
	lookRay.Color = Config.Theme.Accent or Color3.fromRGB(0, 220, 255)
	lookRay.Visible = false
	Storage.LookRayLines[plr] = lookRay

	-- Offscreen Distance Tag
	local offText = Drawing.new("Text")
	offText.Size = 11
	offText.Center = true
	offText.Outline = true
	offText.Color = Color3.fromRGB(255, 255, 255)
	offText.Visible = false
	Storage.OffscreenDistTexts[plr] = offText
end

function Features.RemoveESP(plr)
	if Storage.NativePlayerTags[plr] then
		pcall(function() Storage.NativePlayerTags[plr]:Destroy() end)
		Storage.NativePlayerTags[plr] = nil
	end
	if Storage.ESPObjects[plr] then
		for _, d in pairs(Storage.ESPObjects[plr]) do pcall(function() d:Remove() end) end
		Storage.ESPObjects[plr] = nil
	end
	if Storage.SkeletonParts[plr] then
		for _, part in pairs(Storage.SkeletonParts[plr]) do pcall(function() part:Remove() end) end
		Storage.SkeletonParts[plr] = nil
	end
	if Storage.Box3DObjects[plr] then
		for _, line in pairs(Storage.Box3DObjects[plr]) do pcall(function() line:Remove() end) end
		Storage.Box3DObjects[plr] = nil
	end
	if Storage.TracerLines[plr] then
		pcall(function() Storage.TracerLines[plr]:Remove() end)
		Storage.TracerLines[plr] = nil
	end
	if Storage.OffscreenArrows[plr] then
		pcall(function() Storage.OffscreenArrows[plr]:Remove() end)
		Storage.OffscreenArrows[plr] = nil
	end
	if Storage.LookRayLines[plr] then
		pcall(function() Storage.LookRayLines[plr]:Remove() end)
		Storage.LookRayLines[plr] = nil
	end
	if Storage.OffscreenDistTexts[plr] then
		pcall(function() Storage.OffscreenDistTexts[plr]:Remove() end)
		Storage.OffscreenDistTexts[plr] = nil
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
-- UI SYSTEM (V6.3.0)
-- ==============================================================================
-- ITEM & LOOT ESP SUBSYSTEM (V6.3.0)
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

	-- Universal Item & Loot Scanner
	local lootKeywords = {
		"drop", "item", "loot", "tool", "weapon", "pickup", "chest",
		"crate", "box", "interact", "debris", "ground", "entity",
		"spawn", "collect", "cash", "money", "prop"
	}

	local function isLootContainer(name)
		local lname = name:lower()
		for _, kw in ipairs(lootKeywords) do
			if lname:find(kw) then return true end
		end
		return false
	end

	local function scanContainer(container)
		if not container then return end
		local children = container:GetChildren()
		for _, sub in ipairs(children) do
			if sub:IsA("Tool") then
				local p = sub:FindFirstChild("Handle") or sub:FindFirstChildWhichIsA("BasePart")
				if p then addItem(p, sub.Name, "tool") end
			elseif sub:IsA("BasePart") then
				local prompt = sub:FindFirstChildWhichIsA("ProximityPrompt", true)
				if prompt and prompt.Enabled then
					local title = prompt.ObjectText ~= "" and prompt.ObjectText or prompt.ActionText
					if title == "" or title == "Interact" or title == "Use" or title == "Pick Up" then title = sub.Name end
					addItem(sub, title, "prompt")
				else
					addItem(sub, sub.Name, "item")
				end
			elseif sub:IsA("Model") and not sub:FindFirstChildOfClass("Humanoid") then
				local prompt = sub:FindFirstChildWhichIsA("ProximityPrompt", true)
				local p = sub.PrimaryPart or sub:FindFirstChild("Handle") or sub:FindFirstChildWhichIsA("BasePart")
				if p then
					if prompt and prompt.Enabled then
						local title = prompt.ObjectText ~= "" and prompt.ObjectText or prompt.ActionText
						if title == "" or title == "Interact" or title == "Use" or title == "Pick Up" then title = sub.Name end
						addItem(p, title, "prompt")
					else
						addItem(p, sub.Name, "container")
					end
				end
			end
		end
	end

	for _, item in ipairs(Services.Workspace:GetChildren()) do
		if item:IsA("Tool") then
			local p = item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")
			if p then addItem(p, item.Name, "tool") end
		elseif item:IsA("BasePart") then
			local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
			if prompt and prompt.Enabled then
				local title = prompt.ObjectText ~= "" and prompt.ObjectText or prompt.ActionText
				if title == "" or title == "Interact" or title == "Use" or title == "Pick Up" then title = item.Name end
				addItem(item, title, "prompt")
			end
			local click = item:FindFirstChildWhichIsA("ClickDetector", true)
			if click then addItem(item, item.Name, "click") end
		elseif (item:IsA("Folder") or item:IsA("Model")) and not item:FindFirstChildOfClass("Humanoid") then
			if isLootContainer(item.Name) then
				scanContainer(item)
			end
		end
	end

	local debris = Services.Workspace:FindFirstChild("Debris")
	if debris and (debris:IsA("Folder") or debris:IsA("Model")) then
		scanContainer(debris)
	end

	-- Reliable parent for BillboardGuis across all executors (Delta, Arceus X, Solara, Wave)
	local itemGuiParent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or targetGui

	for part, data in pairs(found) do
		local bg = Storage.ItemESPObjects[part]
		local icon = (data.Type == "prompt" and "✨ ") or (data.Type == "tool" and "🔫 ") or (data.Type == "click" and "🖱️ ") or "📦 "
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
			
			bg.Parent = itemGuiParent
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
	local guiName = "X_TITAN_V581"
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
	if isFounder then
		Title.Text = "🔥 X TITAN<font color='#ff0055'>+</font> <font color='#ffcd32'>[XT7789]</font>"; Title.RichText = true
	elseif isSeller then
		Title.Text = "🔥 X TITAN<font color='#ff0055'>+</font> <font color='#00d2ff'>[CO-FOUNDER]</font>"; Title.RichText = true
	elseif isTitanPlus then
		Title.Text = "🔥 X TITAN<font color='#ff0055'>+</font> <font color='#ffcd32'>[PRO-X APEX]</font>"; Title.RichText = true
	else
		Title.Text = "⚡ X TITAN"; Title.RichText = false
	end
	Title.Size = UDim2.new(1, -16, 0, 24); Title.Position = UDim2.new(0, 12, 0, 12)
	Title.BackgroundTransparency = 1; Title.TextColor3 = Config.Theme.Stroke
	Title.Font = Enum.Font.GothamBlack; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left

	local Subtitle = Instance.new("TextLabel", SidePanel)
	if isFounder then
		Subtitle.Text = "👑 GODMODE APEX • V6.1.1"
		Subtitle.TextColor3 = Color3.fromRGB(255, 205, 50)
	elseif isSeller then
		Subtitle.Text = "💎 CO-FOUNDER VIP • V6.1.1"
		Subtitle.TextColor3 = Color3.fromRGB(0, 210, 255)
	elseif isTitanPlus then
		Subtitle.Text = "⚡ PRO-X APEX • V6.1.1"
		Subtitle.TextColor3 = Color3.fromRGB(255, 205, 50)
	else
		Subtitle.Text = "VOID WALKER • V6.1.1"
		Subtitle.TextColor3 = Config.Theme.TextDim
	end
	Subtitle.Size = UDim2.new(1, -16, 0, 14); Subtitle.Position = UDim2.new(0, 12, 0, 34)
	Subtitle.BackgroundTransparency = 1
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
				if flag == "ItemESP" then
					if not val then
						if ClearItemESP then ClearItemESP() end
					else
						if UpdateItemESP then task.spawn(UpdateItemESP) end
					end
				end
				if flag == "WeaponESP" and not val and Drawing then
					for _, esp in pairs(Storage.ESPObjects) do
						if esp.Weapon then esp.Weapon.Visible = false end
					end
				end
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
	
		local function AddKeybindRebind(page, actionName, keyFlag, getOrder)
		local F = Instance.new("Frame", page)
		F.LayoutOrder = getOrder(); F.Size = UDim2.new(1, -4, 0, 26); F.BackgroundColor3 = Config.Theme.Sec
		Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
		local stroke = Instance.new("UIStroke", F); stroke.Color = Config.Theme.Stroke; stroke.Transparency = 0.85
		
		local L = Instance.new("TextLabel", F); L.Size = UDim2.new(0.55, 0, 1, 0); L.Position = UDim2.new(0, 10, 0, 0)
		L.BackgroundTransparency = 1; L.Text = actionName; L.TextColor3 = Config.Theme.Text; L.Font = Enum.Font.GothamBold; L.TextSize = 10
		L.TextXAlignment = Enum.TextXAlignment.Left
		
		local Btn = Instance.new("TextButton", F); Btn.Size = UDim2.new(0.4, 0, 0.8, 0); Btn.Position = UDim2.new(0.58, 0, 0.1, 0)
		Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45); Btn.TextColor3 = Config.Theme.Stroke; Btn.Font = Enum.Font.GothamBlack; Btn.TextSize = 10
		Btn.Text = Config.Keys[keyFlag] and Config.Keys[keyFlag].Name or "None"
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
		
		Btn.MouseButton1Click:Connect(function()
			Btn.Text = "[Press Key...]"
			Btn.TextColor3 = Color3.fromRGB(255, 220, 80)
			local conn
			conn = Services.UIS.InputBegan:Connect(function(inp, gpe)
				if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode ~= Enum.KeyCode.Unknown then
					conn:Disconnect()
					Config.Keys[keyFlag] = inp.KeyCode
					Btn.Text = inp.KeyCode.Name
					Btn.TextColor3 = Config.Theme.Stroke
					Utils.Notify("⌨️ Keybind Set", actionName .. " bound to: " .. inp.KeyCode.Name)
				end
			end)
		end)
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
	AddToggle(P1, "⚡ Auto Aimbot Failover (Plan B)", "AimbotFailover", getOrder1)
	local bPlan1, bPlan2
	local function UpdateAimbotPlanUI()
		if bPlan2 then
			bPlan2.Text = "Mode: " .. Config.Vals.AimbotPlan
			bPlan2.TextColor3 = Config.Theme.Stroke
		end
	end
	local function CycleAimbotPlan()
		Storage.AimbotPlanIndex = (Storage.AimbotPlanIndex % #Storage.AimbotPlans) + 1
		Config.Vals.AimbotPlan = Storage.AimbotPlans[Storage.AimbotPlanIndex]
		Storage.CameraOverrideDetected = false
		Storage.AimbotCameraOverrideCount = 0
		UpdateAimbotPlanUI()
		Utils.Notify("🎯 Aimbot Plan", "Mode set to: " .. Config.Vals.AimbotPlan)
	end
	bPlan1, bPlan2 = AddDual(P1, "🎯 Cycle Aimbot Plan", CycleAimbotPlan, "Mode: " .. Config.Vals.AimbotPlan, CycleAimbotPlan, getOrder1)
	UpdateAimbotPlanUI()
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
	
	local bPrio1, bPrio2
	local function UpdatePriorityUI()
		if bPrio2 then
			bPrio2.Text = "Priority: " .. Config.Vals.TargetPriority
			bPrio2.TextColor3 = Config.Theme.Stroke
		end
	end
	local function CycleTargetPriority()
		Storage.TargetPriorityIndex = (Storage.TargetPriorityIndex % #Storage.TargetPriorities) + 1
		Config.Vals.TargetPriority = Storage.TargetPriorities[Storage.TargetPriorityIndex]
		UpdatePriorityUI()
		Utils.Notify("🎯 Target Priority", "Priority set to: " .. Config.Vals.TargetPriority)
	end
	bPrio1, bPrio2 = AddDual(P1, "🎯 Cycle Priority", CycleTargetPriority, "Priority: " .. Config.Vals.TargetPriority, CycleTargetPriority, getOrder1)
	UpdatePriorityUI()
	
	local bHit1, bHit2
	local function UpdateHitSoundUI()
		if bHit2 then
			bHit2.Text = "Sound: " .. Config.Vals.HitSoundPreset
			bHit2.TextColor3 = Config.Theme.Stroke
		end
	end
	local function CycleHitSound()
		Storage.HitSoundIndex = (Storage.HitSoundIndex % #Storage.HitSoundPresets) + 1
		Config.Vals.HitSoundPreset = Storage.HitSoundPresets[Storage.HitSoundIndex]
		UpdateHitSoundUI()
		Utils.Notify("🔊 Hit Sound", "Audio preset: " .. Config.Vals.HitSoundPreset)
		Utils.PlayHitSound()
	end
	bHit1, bHit2 = AddDual(P1, "🔊 Cycle Hit Sound", CycleHitSound, "Sound: " .. Config.Vals.HitSoundPreset, CycleHitSound, getOrder1)
	UpdateHitSoundUI()
	
	AddSection(P1, "SILENT & TRIGGER", getOrder1)
	AddToggle(P1, "Silent Aim 🔥", "SilentAim", getOrder1)
	AddToggle(P1, "TriggerBot [T]", "TriggerBot", getOrder1)
	AddToggle(P1, "🎯 Tactical Hitmarker", "Hitmarker", getOrder1)
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
	AddToggle(P1, "🧲 Sticky Target Retention", "StickyAim", getOrder1)
	AddToggle(P1, "🎯 Multi-Bone Dynamic Aim [Titan+]", "MultiBoneAim", getOrder1)
	AddToggle(P1, "🛡️ Anti-Desync Resolver", "Resolver", getOrder1)
	local maxTitanFOV = isTitanPlus and 1000 or 800
	AddSlider(P1, "FOV Size" .. (isTitanPlus and " (TITAN+ APEX)" or ""), 50, maxTitanFOV, 200, function(v) Config.Vals.FOV = v end, getOrder1)
	
	AddSection(P2, "HUD & CROSSHAIR", getOrder2)
	AddToggle(P2, "Show Lock Status", "ShowLockStatus", getOrder2)
	AddToggle(P2, "👁️ Target Status Indicator", "TargetStatus", getOrder2)
	AddToggle(P2, "Dynamic Crosshair", "DynamicCrosshair", getOrder2)
	AddToggle(P2, "Static Crosshair", "Crosshair", getOrder2)
	
	AddSection(P2, "ESP", getOrder2)
	AddToggle(P2, "ESP Master", "ESP", getOrder2)
	AddToggle(P2, "👻 Detect No-Spawn / Lobby", "DetectUnspawned", getOrder2)
	AddToggle(P2, "🏷️ Native Billboard Tags (Plan C)", "BillboardTags", getOrder2)
	local bEng1, bEng2
	local function UpdateESPEngineUI()
		if bEng2 then
			bEng2.Text = "Engine: " .. Config.Vals.ESPEngine
			bEng2.TextColor3 = Config.Theme.Stroke
		end
	end
	local function CycleESPEngine()
		Storage.ESPEngineIndex = (Storage.ESPEngineIndex % #Storage.ESPEngines) + 1
		Config.Vals.ESPEngine = Storage.ESPEngines[Storage.ESPEngineIndex]
		UpdateESPEngineUI()
		Utils.Notify("👁️ ESP Engine", "Engine set to: " .. Config.Vals.ESPEngine)
	end
	bEng1, bEng2 = AddDual(P2, "👁️ Cycle ESP Engine", CycleESPEngine, "Engine: " .. Config.Vals.ESPEngine, CycleESPEngine, getOrder2)
	UpdateESPEngineUI()
	AddToggle(P2, "📦 Item & Loot ESP", "ItemESP", getOrder2)
	AddToggle(P2, "🔫 Weapon / Tool ESP", "WeaponESP", getOrder2)
	AddToggle(P2, "📦 3D Box Wireframe ESP", "ESP3D", getOrder2)
	AddToggle(P2, "👀 View Angle Ray (Look Vector)", "ESPLookRay", getOrder2)
	AddToggle(P2, "🦴 Full Anatomical Skeleton ESP", "ESPSkeleton", getOrder2)
	AddToggle(P2, "🧭 Off-screen Target Arrows", "OffscreenArrows", getOrder2)
	AddToggle(P2, "360° Tracers", "Tracers", getOrder2)
	AddToggle(P2, "Visibility Check", "VisibilityCheck", getOrder2)
	AddToggle(P2, "🛡️ Tactical Chams (Vis/Wall)", "Chams", getOrder2)
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
	
	AddSection(P5, "💾 CONFIG PRESETS & STORAGE", getOrder5)
	AddDual(P5, "💾 Save Default", function() Utils.SaveConfig("titan_default") end, "📂 Load Default", function() Utils.LoadConfig("titan_default") end, getOrder5)
	AddDual(P5, "⚡ Preset: Legit", function() Utils.ApplyPreset("Legit") end, "🔥 Preset: Rage", function() Utils.ApplyPreset("Rage") end, getOrder5)
	AddDual(P5, "🎯 Preset: CQB", function() Utils.ApplyPreset("CQB") end, "💾 Save Custom", function() Utils.SaveConfig("titan_custom") end, getOrder5)
	if isTitanPlus then
		AddDual(P5, "👑 Preset: HvH Godmode", function() Utils.ApplyPreset("HvHGod") end, "👻 Preset: Silent Ghost", function() Utils.ApplyPreset("SilentGhost") end, getOrder5)
	end
	
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
	
	AddSection(P6, "⌨️ INTERACTIVE REBINDING", getOrder6)
	AddKeybindRebind(P6, "Fly Mode Key", "Fly", getOrder6)
	AddKeybindRebind(P6, "Noclip Key", "Noclip", getOrder6)
	AddKeybindRebind(P6, "Open Menu Key", "Menu", getOrder6)
	AddKeybindRebind(P6, "TriggerBot Key", "Trigger", getOrder6)
	AddKeybindRebind(P6, "Sky Hide Key", "Hide", getOrder6)
	AddKeybindRebind(P6, "Destroy Map Key", "DestroyMap", getOrder6)
	
	AddKeybindInfo(P6, "DEFAULT CONTROLS", {{"Aimbot", "Right Click"}, {"Lock Target", "F (Press)"}, {"Tactical TP", "B"}, {"Click TP", "Ctrl + Click"}, {"Unload Script", "End"}}, getOrder6)
	
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
	Utils.Notify("⚠️ Unload", "Unloading X TITAN V6.3.0 - GEN-6 TITAN GOD (APEX OMNI)...")
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
	for _, t in pairs(Storage.NativePlayerTags) do pcall(function() t:Destroy() end) end
	for plr, skel in pairs(Storage.SkeletonParts) do for _, d in pairs(skel) do pcall(function() d:Remove() end) end end
	for _, l in pairs(Storage.TracerLines) do pcall(function() l:Remove() end) end
	for _, a in pairs(Storage.OffscreenArrows) do pcall(function() a:Remove() end) end
	Storage.OffscreenArrows = {}
	for _, l in pairs(Storage.LookRayLines or {}) do pcall(function() l:Remove() end) end
	Storage.LookRayLines = {}
	for _, t in pairs(Storage.OffscreenDistTexts or {}) do pcall(function() t:Remove() end) end
	Storage.OffscreenDistTexts = {}
	for _, line in pairs(Storage.CrosshairLines) do if line then pcall(function() line:Remove() end) end end
	for _, line in pairs(Storage.HitmarkerLines) do if line then pcall(function() line:Remove() end) end end
	if Storage.TargetStatusDrawing then pcall(function() Storage.TargetStatusDrawing:Remove() end); Storage.TargetStatusDrawing = nil end
	
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
	print("X TITAN V6.3.0 - GEN-6 TITAN GOD (APEX OMNI) UNLOADED SUCCESSFULLY")
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
		if Utils.IsTeammate(p) then 
			obj.BackgroundColor3 = Config.Theme.Team
		else
			local vis = Storage.VisCache[p] and Storage.VisCache[p].Visible
			obj.BackgroundColor3 = vis and Config.Theme.LockColor or Config.Theme.TextDim
		end
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
	
	local FOVGui = Instance.new("ScreenGui", targetGui); FOVGui.Name = "X_FOV_V521"; FOVGui.IgnoreGuiInset = true; FOVGui.DisplayOrder = 9999999
	local FOVFrame = Instance.new("Frame", FOVGui)
	FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5); FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	FOVFrame.BackgroundTransparency = 1; FOVFrame.Visible = false
	local FStroke = Instance.new("UIStroke", FOVFrame); FStroke.Color = Config.Theme.Stroke; FStroke.Thickness = 1.5
	Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0); Storage.FOVRingUI = FOVFrame
	
	-- [TOP-RIGHT WATERMARK HUD: ANONYMIZED (NO USERNAME)]
	local WatermarkGui = Instance.new("ScreenGui", targetGui)
	WatermarkGui.Name = "X_TITAN_WATERMARK_V580"
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
	WmTitle.Text = "⚡ PROJECT X TITAN • V6.1.1"
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
	TacticalHUDGui.Name = "X_TacticalHUD_V580"; TacticalHUDGui.IgnoreGuiInset = true; TacticalHUDGui.DisplayOrder = 9999998

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
		
		local statusTxt = Drawing.new("Text")
		statusTxt.Size = 13
		statusTxt.Center = true
		statusTxt.Outline = true
		statusTxt.OutlineColor = Color3.fromRGB(0, 0, 0)
		statusTxt.Color = Config.Theme.LockColor
		statusTxt.Visible = false
		Storage.TargetStatusDrawing = statusTxt
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
			local cAdded = p.CharacterAdded:Connect(function(newChar)
				task.wait(0.3)
				UpdatePlayerCache(p)
				if newChar then
					local chAdd = newChar.ChildAdded:Connect(function(child)
						if child:IsA("Tool") or child:IsA("Model") then
							local cd = Storage.CharCache[p]
							if cd then cd.LastWeaponCheck = 0 end
						end
					end)
					table.insert(Storage.Connections, chAdd)
					local chRem = newChar.ChildRemoved:Connect(function(child)
						if child:IsA("Tool") or child:IsA("Model") then
							local cd = Storage.CharCache[p]
							if cd then cd.LastWeaponCheck = 0 end
						end
					end)
					table.insert(Storage.Connections, chRem)
				end
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
	local renderConn = Services.RunService.RenderStepped:Connect(function(dt)
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
			
			if Config.States.Hitmarker and Storage.HitmarkerAlpha > 0 then
				local hmSize = 7 + (1 - Storage.HitmarkerAlpha) * 4
				local hmAlpha = math.clamp(Storage.HitmarkerAlpha, 0.2, 1)
				local tl = Storage.HitmarkerLines.TL
				local tr = Storage.HitmarkerLines.TR
				local bl = Storage.HitmarkerLines.BL
				local br = Storage.HitmarkerLines.BR
				if tl and tr and bl and br then
					tl.Visible = true; tl.Transparency = hmAlpha; tl.From = Vector2.new(center.X - hmSize, center.Y - hmSize); tl.To = Vector2.new(center.X - 2, center.Y - 2)
					tr.Visible = true; tr.Transparency = hmAlpha; tr.From = Vector2.new(center.X + hmSize, center.Y - hmSize); tr.To = Vector2.new(center.X + 2, center.Y - 2)
					bl.Visible = true; bl.Transparency = hmAlpha; bl.From = Vector2.new(center.X - hmSize, center.Y + hmSize); bl.To = Vector2.new(center.X - 2, center.Y + 2)
					br.Visible = true; br.Transparency = hmAlpha; br.From = Vector2.new(center.X + hmSize, center.Y + hmSize); br.To = Vector2.new(center.X + 2, center.Y + 2)
				end
				Storage.HitmarkerAlpha = math.max(0, Storage.HitmarkerAlpha - 0.05)
			else
				for _, line in pairs(Storage.HitmarkerLines) do if line and line.Visible then line.Visible = false end end
			end
			
			-- [TACTICAL TARGET VISIBILITY STATUS INDICATOR]
			if Storage.TargetStatusDrawing then
				if Config.States.TargetStatus and cachedTarget and cachedTarget.Parent and not (Storage.MainFrame and Storage.MainFrame.Visible) then
					local tPlr = Services.Players:GetPlayerFromCharacter(cachedTarget.Parent)
					local tName = tPlr and tPlr.Name or cachedTarget.Parent.Name
					local dist = math.floor((CurrentCam.CFrame.Position - cachedTarget.Position).Magnitude)
					local curHp, maxHp = Utils.GetHealth(tPlr, cachedTarget.Parent)
					local hpPct = math.floor(math.clamp(curHp / maxHp, 0, 1) * 100)
					Storage.TargetStatusDrawing.Visible = true
					Storage.TargetStatusDrawing.Position = Vector2.new(center.X, center.Y + 24)
					if cachedIsWall then
						Storage.TargetStatusDrawing.Color = Config.Theme.WallColor
						Storage.TargetStatusDrawing.Text = string.format("[🔴 OCCLUDED] %s | %dm | %d%%", tName, dist, hpPct)
					else
						Storage.TargetStatusDrawing.Color = Config.Theme.LockColor
						Storage.TargetStatusDrawing.Text = string.format("[🟢 LOCKED] %s | %dm | %d%%", tName, dist, hpPct)
					end
				elseif Storage.TargetStatusDrawing.Visible then
					Storage.TargetStatusDrawing.Visible = false
				end
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
			-- [V6.3.0 STICKY AIMBOT & EXPONENTIAL DT SMOOTHING]: Dynamic ballistic damping & close-range responsiveness
			if cachedTarget and cachedTarget.Parent then
				local targetPos = cachedTarget.Position
				local eRoot = cachedTarget.Parent:FindFirstChild("HumanoidRootPart")
				local dist3D = (CurrentCam.CFrame.Position - targetPos).Magnitude
				
				local predTime = Config.Vals.PredictionStrength
				if Config.States.SmartPrediction then
					local ping = Utils.GetPing() / 1000
					predTime = predTime + ping * Config.Vals.PingCompensation
				end
				
				-- [CQB BALLISTIC DAMPING]:
				-- At short distance (< 40 studs), bullet travel time is nearly zero in hitscan & high-velocity engines.
				-- Excessive velocity prediction at short distance causes violent overshooting and erratic camera flips.
				-- At dist <= 8 studs: prediction is zero (direct bone lock).
				-- From 8 to 40 studs: prediction scales smoothly up to 100%.
				local distFactor = math.clamp((dist3D - 8) / 32, 0.0, 1.0)
				predTime = predTime * distFactor
				
				if eRoot and predTime > 0.001 then
					local vel = eRoot.AssemblyLinearVelocity
					-- Damp sudden vertical jump velocity jerks in close quarters
					local velY = (dist3D < 25) and (vel.Y * 0.35) or vel.Y
					targetPos = targetPos + Vector3.new(vel.X, velY, vel.Z) * predTime
				end
				
				local screenPos, onScreen = CurrentCam:WorldToViewportPoint(targetPos)
				local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
				
				-- [EXPONENTIAL DELTATIME DAMPED SMOOTHING (FPS-INDEPENDENT)]:
				-- Guarantees identical camera responsiveness across 30 FPS to 240+ FPS
				local safeDt = (dt and dt > 0 and dt < 0.1) and dt or 0.0166
				local responsiveness = math.clamp(1.0 - Config.Vals.AimbotSmoothness, 0.05, 1.0)
				local lambda = (responsiveness / math.max(0.01, 1.01 - responsiveness)) * 32.0
				if dist3D < 40 then
					local cqbBoost = (1.0 - (dist3D / 40)) * 1.5
					lambda = lambda * (1.0 + cqbBoost)
				end
				if screenDist > 120 then
					lambda = lambda * 1.4
				end
				local expSmooth = math.clamp(1.0 - math.exp(-lambda * safeDt), 0.05, 1.0)
				
				-- [MULTI-PLAN AIMBOT EXECUTION & FAILOVER WATCHDOG]
				local aimPlan = Config.Vals.AimbotPlan or "Auto"
				local executePlanB = (aimPlan == "Plan B (MouseMove)") or (aimPlan == "Auto" and Storage.CameraOverrideDetected and Config.States.AimbotFailover)
				
				if executePlanB then
					-- Plan B: MouseMoveRel Hardware/Virtual Input Emulation (Bypasses Locked Camera CFrame)
					local dx = screenPos.X - center.X
					local dy = screenPos.Y - center.Y
					local moveRate = math.clamp(expSmooth * 0.9, 0.08, 0.85)
					if type(mousemoverel) == "function" then
						mousemoverel(dx * moveRate, dy * moveRate)
					elseif Services.VirtualInputManager then
						pcall(function()
							Services.VirtualInputManager:SendMouseMoveEvent(screenPos.X, screenPos.Y, game)
						end)
					else
						-- Fallback to camera if mouse input is not supported
						CurrentCam.CFrame = CurrentCam.CFrame:Lerp(CFrame.lookAt(CurrentCam.CFrame.Position, targetPos), expSmooth)
					end
				else
					-- Plan A: High-Precision Camera CFrame Interpolation
					local oldCF = CurrentCam.CFrame
					local targetCF = CFrame.lookAt(CurrentCam.CFrame.Position, targetPos)
					if screenDist < Config.Vals.Deadzone then
						CurrentCam.CFrame = targetCF
					else
						CurrentCam.CFrame = CurrentCam.CFrame:Lerp(targetCF, expSmooth)
					end
					
					-- Failover Watchdog: check if game script immediately overwrites Camera CFrame
					if (aimPlan == "Auto" and Config.States.AimbotFailover and not Storage.CameraOverrideDetected) then
						task.defer(function()
							if Config.States.Aimbot and cachedTarget then
								local afterVec = CurrentCam.CFrame.LookVector
								local expectedVec = targetCF.LookVector
								local deltaExpected = (afterVec - expectedVec).Magnitude
								local deltaOld = (afterVec - oldCF.LookVector).Magnitude
								if deltaExpected > 0.85 and deltaOld < 0.05 then
									Storage.AimbotCameraOverrideCount = (Storage.AimbotCameraOverrideCount or 0) + 1
									if Storage.AimbotCameraOverrideCount >= 5 then
										Storage.CameraOverrideDetected = true
										Utils.Notify("⚡ AIMBOT FAILOVER", "Camera locked by game script! Switched to Plan B (MouseMoveRel)", 4)
									end
								else
									Storage.AimbotCameraOverrideCount = 0
								end
							end
						end)
					end
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
		
		-- [ADAPTIVE ZERO-LAG ESP ENGINE] Skip entire loop if visual features are disabled
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
				local nowTick = tick()
				local isCombatActive = Config.States.Aimbot or Storage.LockedTarget ~= nil or cachedTarget ~= nil
				local shouldThrottle = Config.States.AdaptiveFPS and not isCombatActive and ((nowTick - Storage.LastAdaptiveEspTick) < 0.016)

				if not shouldThrottle then
					Storage.LastAdaptiveEspTick = nowTick
					for _, plr in pairs(Services.Players:GetPlayers()) do
					if plr == LocalPlayer then continue end
					local cData = Utils.GetCharacterData(plr)
					if not cData then continue end
					local pChar = cData.Char
					local root = cData.Root
					local head = cData.Head
					local isAlive, isUnspawned = cData.IsAlive, cData.IsUnspawned
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

					-- [ADAPTIVE FRUSTUM CULLING]: Instant skip for offscreen players when OffscreenArrows is disabled
					if (not onScreen or topPos.Z <= 0) and not Config.States.OffscreenArrows then
						if esp.Box.Visible then
							pcall(function()
								esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false; esp.Distance.Visible = false
								if esp.Weapon then esp.Weapon.Visible = false end
								if Storage.SkeletonParts[plr] then for _, part in pairs(Storage.SkeletonParts[plr]) do if part.Visible then part.Visible = false end end end
								if Storage.Box3DObjects[plr] then for _, l in pairs(Storage.Box3DObjects[plr]) do if l.Visible then l.Visible = false end end end
								if Storage.LookRayLines[plr] and Storage.LookRayLines[plr].Visible then Storage.LookRayLines[plr].Visible = false end
								if Storage.TracerLines[plr] and Storage.TracerLines[plr].Visible then Storage.TracerLines[plr].Visible = false end
							end)
						end
						continue
					end

					local drawColor = Config.Theme.Stroke
					if isUnspawned then
						drawColor = Color3.fromRGB(190, 130, 255)
					elseif Storage.LockedTarget == plr then
						if isTitanPlus then
							local pulse = (math.sin(tick() * 10) + 1) * 0.5
							drawColor = Color3.fromRGB(255, math.floor(40 + 175 * pulse), 0)
						else
							drawColor = Config.Theme.LockColor
						end
					elseif Config.States.TeamCheck and Utils.IsTeammate(plr) then
						drawColor = Config.Theme.Team
					elseif isTitanPlus then
						local myRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head"))
						local d3d = myRoot and (root.Position - myRoot.Position).Magnitude or 100
						local hPart = pChar:FindFirstChild("Head")
						local isLookingAtMe = false
						if hPart and myRoot then
							local toMe = (myRoot.Position - hPart.Position).Unit
							if hPart.CFrame.LookVector:Dot(toMe) > 0.8 then isLookingAtMe = true end
						end
						if d3d < 30 or isLookingAtMe then
							drawColor = Color3.fromRGB(255, 45, 45)
						elseif d3d < 75 then
							drawColor = Color3.fromRGB(255, 185, 40)
						end
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
								local distTxt = Storage.OffscreenDistTexts and Storage.OffscreenDistTexts[plr]
								if distTxt then
									distTxt.Position = arrowCenter + Vector2.new(math.sin(angle) * -12, -math.cos(angle) * -12)
									distTxt.Text = string.format("%.0fm", rel.Magnitude)
									distTxt.Color = drawColor
									distTxt.Visible = true
								end
							else
								arrow.Visible = false
								if Storage.OffscreenDistTexts and Storage.OffscreenDistTexts[plr] then
									Storage.OffscreenDistTexts[plr].Visible = false
								end
							end
						end)
						if not arrowOk then Config.States.OffscreenArrows = false end
					elseif Storage.OffscreenArrows[plr] then
						pcall(function()
							Storage.OffscreenArrows[plr].Visible = false
							if Storage.OffscreenDistTexts and Storage.OffscreenDistTexts[plr] then
								Storage.OffscreenDistTexts[plr].Visible = false
							end
						end)
					end

					if onScreen and topPos.Z > 0 then
						local height = math.abs(topPos.Y - bottomPos.Y)
						local width = height / 1.6
						local boxX = topPos.X - width / 2
						local boxY = math.min(topPos.Y, bottomPos.Y)

						if Config.States.ESP then
							pcall(function()
								esp.Box.Visible = true; esp.Box.Size = Vector2.new(width, height); esp.Box.Position = Vector2.new(boxX, boxY); esp.Box.Color = drawColor; esp.Box.Transparency = 1
								local boxThick = Config.Vals.ESPBoxThickness or 1.5
								if Storage.LockedTarget == plr then
									local pulse = (math.sin(tick() * 8) + 1) * 0.5
									boxThick = boxThick + pulse * 1.5
								end
								esp.Box.Thickness = boxThick
								esp.Name.Visible = (Config.States.ShowName ~= false); esp.Name.Size = Config.Vals.ESPTextSize or 13; esp.Name.Text = isUnspawned and (plr.DisplayName .. " [NO-SPAWN]") or plr.DisplayName; esp.Name.Position = Vector2.new(boxX + width / 2, boxY - 16); esp.Name.Color = drawColor
								esp.HealthBar.Visible = (Config.States.ShowHealth ~= false); local curHp = cData.CurHp or 100; local maxHp = cData.MaxHp or 100; local healthRatio = math.clamp(curHp / maxHp, 0, 1)
								esp.HealthBar.Color = Color3.new(1 - healthRatio, healthRatio, 0)
								esp.HealthBar.From = Vector2.new(boxX - 5, boxY + height); esp.HealthBar.To = Vector2.new(boxX - 5, boxY + height - height * healthRatio)
								esp.Distance.Visible = (Config.States.ShowDistance ~= false); esp.Distance.Size = (Config.Vals.ESPTextSize or 13) - 1; esp.Distance.Text = string.format("%.0fm", (root.Position - (hrp and hrp.Position or root.Position)).Magnitude)
								esp.Distance.Position = Vector2.new(boxX + width / 2, boxY + height + 2); esp.Distance.Color = drawColor
								if Config.States.WeaponESP and esp.Weapon then
									local now = tick()
									if not cData.Weapon or (now - (cData.LastWeaponCheck or 0) > 0.6) then
										cData.Weapon = Utils.GetEquippedWeapon(plr, pChar)
										cData.LastWeaponCheck = now
									end
									local wName = cData.Weapon or "Unarmed"
									esp.Weapon.Visible = true
									esp.Weapon.Text = "[" .. wName .. "]"
									local distOffset = (Config.States.ShowDistance ~= false) and 16 or 2
									esp.Weapon.Position = Vector2.new(boxX + width / 2, boxY + height + distOffset)
									esp.Weapon.Color = (wName ~= "Unarmed") and Color3.fromRGB(255, 230, 100) or Color3.fromRGB(180, 180, 180)
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

						-- [GEN-6 3D ORIENTED BOUNDING BOX ESP]
						if Config.States.ESP3D and Storage.Box3DObjects[plr] then
							pcall(function()
								local cf, size = pChar:GetBoundingBox()
								local sx, sy, sz = size.X * 0.5, size.Y * 0.5, size.Z * 0.5
								local corners = {
									cf * Vector3.new(-sx, -sy, -sz), cf * Vector3.new( sx, -sy, -sz),
									cf * Vector3.new( sx, -sy,  sz), cf * Vector3.new(-sx, -sy,  sz),
									cf * Vector3.new(-sx,  sy, -sz), cf * Vector3.new( sx,  sy, -sz),
									cf * Vector3.new( sx,  sy,  sz), cf * Vector3.new(-sx,  sy,  sz)
								}
								local sPts = {}
								local anyVis = false
								for idx, pt in ipairs(corners) do
									local sp, onS = CurrentCam:WorldToViewportPoint(pt)
									sPts[idx] = sp
									if onS and sp.Z > 0 then anyVis = true end
								end
								if anyVis then
									local edges = {
										{1,2}, {2,3}, {3,4}, {4,1},
										{5,6}, {6,7}, {7,8}, {8,5},
										{1,5}, {2,6}, {3,7}, {4,8}
									}
									local b3d = Storage.Box3DObjects[plr]
									local thick = Config.Vals.ESPBoxThickness or 1.5
									for i, e in ipairs(edges) do
										local l = b3d[i]
										local pA = sPts[e[1]]
										local pB = sPts[e[2]]
										if pA and pB and pA.Z > 0 and pB.Z > 0 then
											l.Visible = true
											l.From = Vector2.new(pA.X, pA.Y)
											l.To = Vector2.new(pB.X, pB.Y)
											l.Color = drawColor
											l.Thickness = thick
										else
											l.Visible = false
										end
									end
								else
									for _, l in pairs(Storage.Box3DObjects[plr]) do l.Visible = false end
								end
							end)
						elseif Storage.Box3DObjects[plr] then
							pcall(function() for _, l in pairs(Storage.Box3DObjects[plr]) do l.Visible = false end end)
						end

						-- [GEN-6.1 LOOK VECTOR RAY ESP]
						if Config.States.ESPLookRay and Storage.LookRayLines[plr] then
							pcall(function()
								local head = pChar:FindFirstChild("Head")
								if head then
									local hPos, hOn = CurrentCam:WorldToViewportPoint(head.Position)
									local rayEnd = head.Position + (head.CFrame.LookVector * 5.0)
									local ePos, eOn = CurrentCam:WorldToViewportPoint(rayEnd)
									if (hOn or eOn) and hPos.Z > 0 and ePos.Z > 0 then
										local l = Storage.LookRayLines[plr]
										l.Visible = true
										l.From = Vector2.new(hPos.X, hPos.Y)
										l.To = Vector2.new(ePos.X, ePos.Y)
										l.Color = (Storage.LockedTarget == plr) and Config.Theme.LockColor or drawColor
										l.Thickness = 1.5
									else
										Storage.LookRayLines[plr].Visible = false
									end
								else
									Storage.LookRayLines[plr].Visible = false
								end
							end)
						elseif Storage.LookRayLines[plr] then
							pcall(function() Storage.LookRayLines[plr].Visible = false end)
						end

						-- [GEN-6 FULL ANATOMICAL SKELETON ESP: R15 & R6]
						if Config.States.ESPSkeleton and Storage.SkeletonParts[plr] then
							pcall(function()
								local pairsList = {}
								local isR15 = pChar:FindFirstChild("UpperTorso") ~= nil
								if isR15 then
									pairsList = {
										{"Head", "UpperTorso"},
										{"UpperTorso", "LowerTorso"},
										{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
										{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
										{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
										{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
									}
								else
									pairsList = {
										{"Head", "Torso"},
										{"Torso", "Left Arm"},
										{"Torso", "Right Arm"},
										{"Torso", "Left Leg"},
										{"Torso", "Right Leg"}
									}
								end

								local skel = Storage.SkeletonParts[plr]
								for i = 1, 14 do
									local l = skel[i]
									local pair = pairsList[i]
									if pair then
										local pA = pChar:FindFirstChild(pair[1])
										local pB = pChar:FindFirstChild(pair[2])
										if pA and pB then
											local posA, visA = CurrentCam:WorldToViewportPoint(pA.Position)
											local posB, visB = CurrentCam:WorldToViewportPoint(pB.Position)
											if (visA or visB) and posA.Z > 0 and posB.Z > 0 then
												l.Visible = true
												l.From = Vector2.new(posA.X, posA.Y)
												l.To = Vector2.new(posB.X, posB.Y)
												l.Color = drawColor
												l.Thickness = Config.Vals.ESPBoxThickness or 1.5
											else
												l.Visible = false
											end
										else
											l.Visible = false
										end
									else
										l.Visible = false
									end
								end
							end)
						elseif Storage.SkeletonParts[plr] then
							pcall(function() for _, part in pairs(Storage.SkeletonParts[plr]) do if part.Visible then part.Visible = false end end end)
						end
					else
						pcall(function()
							esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false; esp.Distance.Visible = false
							if esp.Weapon then esp.Weapon.Visible = false end
							if Storage.SkeletonParts[plr] then for _, part in pairs(Storage.SkeletonParts[plr]) do if part.Visible then part.Visible = false end end end
							if Storage.Box3DObjects[plr] then for _, l in pairs(Storage.Box3DObjects[plr]) do if l.Visible then l.Visible = false end end end
							if Storage.LookRayLines[plr] and Storage.LookRayLines[plr].Visible then Storage.LookRayLines[plr].Visible = false end
						end)
					end
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
			local now = tick()
			if now - (Storage.LastNoRecoilCheck or 0) > 0.25 then
				Storage.LastNoRecoilCheck = now
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

-- [ZERO-LAG]: Item updates handled cleanly by periodic itemLoop (prevents DescendantAdded projectile flood stutter)

local nativeTagLoop = task.spawn(function()
	while true do
		task.wait(0.25)
		if Storage.IsUnloaded then break end
		if Config.States.BillboardTags or (Config.States.ESP and (Storage.DrawingBroken or Config.Vals.ESPEngine == "Plan C (Billboard)" or Config.Vals.ESPEngine == "Auto")) then
			pcall(Features.UpdateNativeTags)
		end
	end
end)
table.insert(Storage.Loops, nativeTagLoop)

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
				local stats = Services.Stats or safeCloneRef(game:GetService("Stats"))
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
if isFounder then
	Utils.Notify("👑 X TITAN+ APEX GODMODE", "Master Key XT-7789 Active! 1000 FOV & All God Presets Unlocked.", 4.5)
	print("👑 [X TITAN+] MASTER FOUNDER XT-7789 UNLOCKED")
elseif isSeller then
	Utils.Notify("💎 X TITAN+ PARTNER", "Co-Founder Key Active! Apex Godmode & Presets Unlocked.", 4)
	print("💎 [X TITAN+] PARTNER UNLOCKED")
elseif isTitanPlus then
	Utils.Notify("🔥 X TITAN+ [PRO-X APEX]", "PRO-X Apex Godmode Active! 1000 FOV & Presets Unlocked.", 4)
	print("🔥 [X TITAN+] PRO-X APEX UNLOCKED")
else
	Utils.Notify("✅ X TITAN V6.1.1 - GEN-6 TITAN GOD (APEX OMNI)", "VIP Exclusive Suite Online. Press [Insert] for Menu", 4)
	print("X TITAN V6.3.0 - GEN-6 TITAN GOD (APEX OMNI) LOADED SUCCESSFULLY")
end