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

-- [[ X PRO V3.4.3 - PROFESSIONAL SUITE ]]
-- Founder & Developer: XT-7789 | Official Seller: vlilayz
-- High-Performance Zero-Lag Character Caching & 60+ FPS Optimization
-- ==============================================================================
if _G.X_PRO_INSTANCE then
	pcall(function()
		if _G.X_PRO_INSTANCE.Storage then
			local s = _G.X_PRO_INSTANCE.Storage
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
    StarterGui = game:GetService("StarterGui"),
    SoundService = game:GetService("SoundService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
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

-- ==================================================================
-- CONFIGURATION & STORAGE
-- ==================================================================
local Config = {
    Keys = {
        Menu = Enum.KeyCode.Insert, Fly = Enum.KeyCode.Z, Noclip = Enum.KeyCode.V,
        Trigger = Enum.KeyCode.T, Unload = Enum.KeyCode.End, LockTarget = Enum.KeyCode.F
    },
    Theme = {
        Main = Color3.fromRGB(12, 14, 20), Sec = Color3.fromRGB(20, 22, 32),
        Accent = Color3.fromRGB(0, 220, 255), Team = Color3.fromRGB(0, 255, 120),
        Text = Color3.fromRGB(245, 245, 250), Dim = Color3.fromRGB(140, 140, 155),
        LockColor = Color3.fromRGB(255, 60, 60), WallColor = Color3.fromRGB(255, 200, 0),
        RadarBG = Color3.fromRGB(15, 15, 22)
    },
    States = {
        Aimbot = false, SilentAim = false, SmartPrediction = true, AutoAimPart = true,
        RightClickToggle = true, TeamCheck = true, WallCheck = false,
        TriggerBot = false, ShowFOV = false, TacticalLock = false,
        ESP = false, ESPSkeleton = false, WeaponESP = true, OffscreenArrows = false,
        Tracers = false, Chams = false, Fullbright = false, Crosshair = false,
        Radar = false, HitSound = true, NoRecoil = false,
        Fly = false, LegitFly = false, SpeedHack = false, InfJump = false,
        Noclip = false, NoFall = false, ClickTP = false, AntiKillbrick = false, ItemESP = false, VehicleBoost = false, DetectUnspawned = true
    },
    Vals = {
        FOV = 180, Smoothness = 0.28, PredictionStrength = 0.14,
        TriggerDelay = 0.15, WalkSpeed = 85, FlySpeed = 120,
        RadarRange = 120, AimPart = "Head", OffscreenRadius = 240, VehicleSpeed = 140
    }
}

local Storage = {
    Connections = {}, ESPObjects = {}, SkeletonParts = {}, TracerLines = {},
    CrosshairLines = {}, OffscreenArrows = {}, ToggleFuncs = {}, FOVRingUI = nil, MainFrame = nil,
    OriginalLighting = {}, OriginalCollisions = {}, OriginalWalkSpeed = 16,
    LockedTarget = nil, IsRightMouseDown = false, TriggerCooldown = 0,
    RadarGui = nil, RadarFrame = nil, RadarObjects = {}, HitSoundObj = nil,
    AimParts = {"Head", "Torso", "HumanoidRootPart"}, AimPartIndex = 1, ItemESPObjects = {}
}

local function TrackConn(c)
    if c then table.insert(Storage.Connections, c) end
    return c
end

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

local function Notify(title, text, dur) Utils.Notify(title, text, dur) end


-- ==================================================================
-- SOUND FEEDBACK
-- ==================================================================
local function PlayHitSound()
    if not Config.States.HitSound then return end
    pcall(function()
        if not Storage.HitSoundObj then
            local snd = Instance.new("Sound")
            snd.SoundId = "rbxassetid://6534948092"
            snd.Volume = 0.8
            snd.Parent = Services.SoundService
            Storage.HitSoundObj = snd
        end
        Storage.HitSoundObj:Play()
    end)
end

-- ==================================================================
-- UTILITIES & PREDICTION
-- ==================================================================
local Unload
local Utils = {}

function Utils.GetPlayerCharacter(p)
    if not p then return nil end
    if p.Character and p.Character.Parent then return p.Character end
    local direct = Services.Workspace:FindFirstChild(p.Name)
    if direct and direct:IsA("Model") then return direct end
    for _, fName in ipairs({"Characters", "Players", "Alive", "Entities", "Spawns", "Map"}) do
        local f = Services.Workspace:FindFirstChild(fName)
        if f then
            local c = f:FindFirstChild(p.Name)
            if c and c:IsA("Model") then return c end
        end
    end
    return nil
end

function Utils.GetCharacterParts(char)
    if not char then return nil, nil, nil end
    local head = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") or char.PrimaryPart or head
    local hum = char:FindFirstChildOfClass("Humanoid")
    return head, root, hum
end

function Utils.GetCharacterData(plr)
	if not plr then return nil end
	local char = plr.Character
	if not char or not char.Parent or not char:IsDescendantOf(Services.Workspace) then
		char = Services.Workspace:FindFirstChild(plr.Name)
		if not char then
			local f = Services.Workspace:FindFirstChild("Characters") or Services.Workspace:FindFirstChild("Players")
			if f then char = f:FindFirstChild(plr.Name) end
		end
	end
	if not char or not char:IsDescendantOf(Services.Workspace) then return nil end

	local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char.PrimaryPart
	if not root then return nil end

	local head = char:FindFirstChild("Head") or root
	local hum = char:FindFirstChildOfClass("Humanoid")
	return {
		Char = char,
		Root = root,
		Head = head,
		Hum = hum
	}
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

function Utils.IsTeammate(plr)
    if not plr or not LocalPlayer or plr == LocalPlayer then return false end
    if plr.Team and plr.Team.Name == "FFA" then return false end
    if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return true end
    if plr.TeamColor and LocalPlayer.TeamColor and plr.TeamColor == LocalPlayer.TeamColor then return true end
    local pChar = Utils.GetPlayerCharacter(plr)
    local myChar = Utils.GetPlayerCharacter(LocalPlayer)
    if pChar and myChar then
        local t1 = pChar:GetAttribute("Team")
        local t2 = myChar:GetAttribute("Team")
        if t1 and t2 and t1 == t2 then return true end
    end
    return false
end

function Utils.IsVisible(targetHead)
    if not targetHead or not targetHead.Parent then return false end
    local origin = Camera.CFrame.Position
    local dir = (targetHead.Position - origin)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local ok, res = pcall(function() return Services.Workspace:Raycast(origin, dir, params) end)
    if not ok or not res then return true end
    if res.Instance and res.Instance:IsDescendantOf(targetHead.Parent) then return true end
    return false
end

function Utils.GetAimPart(char)
    if not char then return nil end
    if Config.States.AutoAimPart then
        local head = char:FindFirstChild("Head")
        if head and Utils.IsVisible(head) then return head end
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
        if torso then return torso end
    end
    return char:FindFirstChild(Config.Vals.AimPart) or char:FindFirstChild("Head")
end

function Utils.GetClosestTarget()
    if Config.States.TacticalLock and Storage.LockedTarget and Storage.LockedTarget.Parent then
        local hum = Storage.LockedTarget.Parent:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then return Storage.LockedTarget end
    end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestDist, target = Config.Vals.FOV, nil

    for _, p in pairs(Services.Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end
        local cData = Utils.GetCharacterData(p)
        if not cData or not cData.IsAlive then continue end

        local aimPart = Utils.GetAimPart(cData.Char)
        if not aimPart then continue end

        if Config.States.WallCheck and not Utils.IsVisible(aimPart) then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if onScreen then
            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            if dist < closestDist then
                closestDist = dist
                target = aimPart
            end
        end
    end
    return target
end

function Utils.UpdateCollisions()
    local char = LocalPlayer.Character
    if not char then return end
    local shouldNoclip = Config.States.Noclip
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            if shouldNoclip then
                if Storage.OriginalCollisions[v] == nil then
                    Storage.OriginalCollisions[v] = v.CanCollide
                end
                v.CanCollide = false
            elseif Storage.OriginalCollisions[v] ~= nil then
                v.CanCollide = Storage.OriginalCollisions[v]
                Storage.OriginalCollisions[v] = nil
            end
        end
    end
    if not shouldNoclip then Storage.OriginalCollisions = {} end
end

function Utils.ToggleFullbright(state)
    if state then
        if not Storage.OriginalLighting.Ambient then
            Storage.OriginalLighting.Ambient = Services.Lighting.Ambient
            Storage.OriginalLighting.Brightness = Services.Lighting.Brightness
            Storage.OriginalLighting.ClockTime = Services.Lighting.ClockTime
        end
        Services.Lighting.Ambient = Color3.new(1, 1, 1)
        Services.Lighting.Brightness = 2
        Services.Lighting.ClockTime = 14
    elseif Storage.OriginalLighting.Ambient then
        Services.Lighting.Ambient = Storage.OriginalLighting.Ambient
        Services.Lighting.Brightness = Storage.OriginalLighting.Brightness
        Services.Lighting.ClockTime = Storage.OriginalLighting.ClockTime
    end
end

function Utils.UpdateChams()
    for _, p in pairs(Services.Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local chams = p.Character:FindFirstChild("X_Pro_Chams")
            if Config.States.Chams then
                if not chams then
                    chams = Instance.new("Highlight")
                    chams.Name = "X_Pro_Chams"
                    chams.FillTransparency = 0.5
                    chams.OutlineTransparency = 0.1
                    chams.Parent = p.Character
                end
                local col = (Config.States.TeamCheck and Utils.IsTeammate(p)) and Config.Theme.Team or Config.Theme.Accent
                chams.FillColor = col
                chams.OutlineColor = col
            elseif chams then
                chams:Destroy()
            end
        end
    end
end

-- ==================================================================
-- TACTICAL 2D RADAR
-- ==================================================================
local function CreateRadar()
    if targetGui:FindFirstChild("X_PRO_RADAR") then targetGui["X_PRO_RADAR"]:Destroy() end
    local gui = Instance.new("ScreenGui", targetGui)
    gui.Name = "X_PRO_RADAR"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
    Storage.RadarGui = gui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 160, 0, 160); frame.Position = UDim2.new(0, 20, 0, 80)
    frame.BackgroundColor3 = Config.Theme.RadarBG; frame.Active = true; frame.Draggable = true
    frame.Visible = Config.States.Radar
    Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Config.Theme.Accent; stroke.Thickness = 1.5; stroke.Transparency = 0.4
    Storage.RadarFrame = frame

    local centerDot = Instance.new("Frame", frame)
    centerDot.Size = UDim2.new(0, 6, 0, 6); centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    centerDot.Position = UDim2.new(0.5, 0, 0.5, 0); centerDot.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", centerDot).CornerRadius = UDim.new(1, 0)

    local l1 = Instance.new("Frame", frame)
    l1.Size = UDim2.new(1, 0, 0, 1); l1.Position = UDim2.new(0, 0, 0.5, 0); l1.BackgroundColor3 = Color3.fromRGB(50, 50, 70); l1.BorderSizePixel = 0
    local l2 = Instance.new("Frame", frame)
    l2.Size = UDim2.new(0, 1, 1, 0); l2.Position = UDim2.new(0.5, 0, 0, 0); l2.BackgroundColor3 = Color3.fromRGB(50, 50, 70); l2.BorderSizePixel = 0
end

local function UpdateRadar()
    if not Config.States.Radar or not Storage.RadarFrame or not Storage.RadarFrame.Visible then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local myPos = hrp.Position
    local myLook = hrp.CFrame.LookVector
    local forwardYaw = math.atan2(-myLook.Z, myLook.X)

    for _, p in pairs(Services.Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local eRoot = p.Character:FindFirstChild("HumanoidRootPart")
            local eHum = p.Character:FindFirstChildOfClass("Humanoid")

            if eRoot and eHum and eHum.Health > 0 then
                local dot = Storage.RadarObjects[p]
                if not dot then
                    dot = Instance.new("Frame", Storage.RadarFrame)
                    dot.Size = UDim2.new(0, 6, 0, 6); dot.AnchorPoint = Vector2.new(0.5, 0.5)
                    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                    Storage.RadarObjects[p] = dot
                end

                local offset = eRoot.Position - myPos
                local dist = Vector2.new(offset.X, offset.Z).Magnitude
                local scale = 75 / Config.Vals.RadarRange

                if dist <= Config.Vals.RadarRange then
                    dot.Visible = true
                    local angle = math.atan2(-offset.Z, offset.X) - forwardYaw + math.pi / 2
                    local rX = math.cos(angle) * (dist * scale)
                    local rY = math.sin(angle) * (dist * scale)

                    dot.Position = UDim2.new(0.5, rX, 0.5, -rY)
                    dot.BackgroundColor3 = (Config.States.TeamCheck and Utils.IsTeammate(p)) and Config.Theme.Team or Config.Theme.LockColor
                else
                    dot.Visible = false
                end
            elseif Storage.RadarObjects[p] then
                Storage.RadarObjects[p].Visible = false
            end
        end
    end
end

-- ==================================================================
-- SKELETON ESP
-- ==================================================================
local SkeletonStructure = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local function UpdateSkeletonESP()
    if not Drawing or not Config.States.ESPSkeleton then
        for _, lines in pairs(Storage.SkeletonParts) do
            for _, l in pairs(lines) do l.Visible = false end
        end
        return
    end

    for _, p in pairs(Services.Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local lines = Storage.SkeletonParts[p]
                if not lines then lines = {}; Storage.SkeletonParts[p] = lines end

                local col = (Config.States.TeamCheck and Utils.IsTeammate(p)) and Config.Theme.Team or Config.Theme.Accent
                for i, pair in ipairs(SkeletonStructure) do
                    local p1 = p.Character:FindFirstChild(pair[1])
                    local p2 = p.Character:FindFirstChild(pair[2])
                    local line = lines[i]

                    if p1 and p2 then
                        local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position)
                        local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)

                        if vis1 and vis2 then
                            if not line then
                                line = Drawing.new("Line")
                                line.Thickness = 1.2
                                lines[i] = line
                            end
                            line.Visible = true
                            line.Color = col
                            line.From = Vector2.new(pos1.X, pos1.Y)
                            line.To = Vector2.new(pos2.X, pos2.Y)
                        elseif line then line.Visible = false end
                    elseif line then line.Visible = false end
                end
            elseif Storage.SkeletonParts[p] then
                for _, l in pairs(Storage.SkeletonParts[p]) do l.Visible = false end
            end
        end
    end
end

-- ==================================================================
-- MULTI-LAYER COMPATIBLE SILENT AIM ENGINE (Xeno & Delta Universal)
-- ==================================================================
local HasMetamethodHook = false

-- [TIER 1] Metamethod __namecall Hook (Delta / Advanced PC Executors)
if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
    local safeUnpack = table.unpack or unpack
    local ok, oldNamecall = pcall(function()
        return hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if Config.States.AntiKillbrick and method == "TakeDamage" and self:IsA("Humanoid") and self:IsDescendantOf(LocalPlayer.Character) then
                return
            end

            if Config.States.SilentAim and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist") then
                local targetPart = Utils.GetClosestTarget()
                if targetPart and targetPart.Parent then
                    local predPos = targetPart.Position
                    local root = targetPart.Parent:FindFirstChild("HumanoidRootPart")
                    if Config.States.SmartPrediction and root then
                        predPos = predPos + (root.AssemblyLinearVelocity * Config.Vals.PredictionStrength)
                    end

                    PlayHitSound()

                    if method == "Raycast" then
                        local origin = args[1]
                        args[2] = (predPos - origin).Unit * 5000
                        return oldNamecall(self, safeUnpack(args))
                    elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist" then
                        local ray = args[1]
                        args[1] = Ray.new(ray.Origin, (predPos - ray.Origin).Unit * 5000)
                        return oldNamecall(self, safeUnpack(args))
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
    if ok and oldNamecall then HasMetamethodHook = true end

    pcall(function()
        local oldNewIndex
        oldNewIndex = hookmetamethod(game, "__newindex", function(t, k, v)
            if Config.States.AntiKillbrick and not checkcaller() and t:IsA("Humanoid") and t:IsDescendantOf(LocalPlayer.Character) and k == "Health" then
                if type(v) == "number" and v < t.Health then return end
            end
            return oldNewIndex(t, k, v)
        end)
    end)
end

-- [TIER 2] Mouse.Hit & Target Spoofing (Xeno / Solara getrawmetatable Hook)
pcall(function()
    if type(getrawmetatable) == "function" and type(setreadonly) == "function" then
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local oldIndex = mt.__index
            mt.__index = function(t, k)
                if Config.States.SilentAim and (t:IsA("Mouse") or tostring(t) == "Mouse") then
                    local targetPart = Utils.GetClosestTarget()
                    if targetPart then
                        local predPos = targetPart.Position
                        local root = targetPart.Parent and targetPart.Parent:FindFirstChild("HumanoidRootPart")
                        if Config.States.SmartPrediction and root then
                            predPos = predPos + (root.AssemblyLinearVelocity * Config.Vals.PredictionStrength)
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

-- [TIER 3] Micro-Flick Bullet Snap (100% Works on ALL Free PC Executors with ZERO hooks)
local function MicroFlickSilentAim()
    if not Config.States.SilentAim then return end
    local targetPart = Utils.GetClosestTarget()
    if not targetPart or not targetPart.Parent then return end

    local predPos = targetPart.Position
    local root = targetPart.Parent:FindFirstChild("HumanoidRootPart")
    if Config.States.SmartPrediction and root then
        predPos = predPos + (root.AssemblyLinearVelocity * Config.Vals.PredictionStrength)
    end

    local origCF = Camera.CFrame
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, predPos)
    PlayHitSound()
    task.spawn(function()
        Services.RunService.RenderStepped:Wait()
        Camera.CFrame = origCF
    end)
end

-- ==================================================================
-- MODERN 3-TAB UI (V3.4.3)
-- ==================================================================
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

local function BuildUI()
    local uiName = "X_PRO_V3_0_0"
    if targetGui:FindFirstChild(uiName) then targetGui[uiName]:Destroy() end

    local ScreenGui = Instance.new("ScreenGui", targetGui)
    ScreenGui.Name = uiName; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 560, 0, 450); Main.Position = UDim2.new(0.5, -280, 0.5, -225)
    Main.BackgroundColor3 = Config.Theme.Main; Main.Active = true; Main.Draggable = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Config.Theme.Accent; Stroke.Thickness = 1.5; Stroke.Transparency = 0.4
    Storage.MainFrame = Main

    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 46); Header.BackgroundColor3 = Config.Theme.Sec
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel", Header)
    Title.Text = "⚡ X PRO <font color='#00dcff'>V3.4.3</font>"; Title.RichText = true
    Title.Size = UDim2.new(0, 130, 1, 0); Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1; Title.TextColor3 = Config.Theme.Text
    Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left

    local TabBar = Instance.new("Frame", Header)
    TabBar.Size = UDim2.new(0, 258, 0, 28); TabBar.Position = UDim2.new(0, 142, 0.5, -14)
    TabBar.BackgroundTransparency = 1
    local TabList = Instance.new("UIListLayout", TabBar); TabList.FillDirection = Enum.FillDirection.Horizontal; TabList.Padding = UDim.new(0, 6)

    -- Header Unload Button (Properly spaced, no overlap)
    local HdrUnloadBtn = Instance.new("TextButton", Header)
    HdrUnloadBtn.Name = "HeaderUnload"
    HdrUnloadBtn.Size = UDim2.new(0, 62, 0, 26); HdrUnloadBtn.Position = UDim2.new(1, -102, 0.5, -13)
    HdrUnloadBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    HdrUnloadBtn.Text = "UNLOAD"; HdrUnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    HdrUnloadBtn.Font = Enum.Font.GothamBold; HdrUnloadBtn.TextSize = 10
    Instance.new("UICorner", HdrUnloadBtn).CornerRadius = UDim.new(0, 6)
    local hubStroke = Instance.new("UIStroke", HdrUnloadBtn)
    hubStroke.Color = Color3.fromRGB(255, 80, 80); hubStroke.Thickness = 1
    HdrUnloadBtn.MouseButton1Click:Connect(function() if Unload then Unload() end end)

    -- Header Close Button (✕)
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Name = "HeaderClose"
    CloseBtn.Size = UDim2.new(0, 26, 0, 26); CloseBtn.Position = UDim2.new(1, -34, 0.5, -13)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Config.Theme.Text
    CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 13
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    local closeStroke = Instance.new("UIStroke", CloseBtn)
    closeStroke.Color = Config.Theme.Accent; closeStroke.Thickness = 1; closeStroke.Transparency = 0.6
    CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

    local Pages = {}
    local TabButtons = {}

    local function CreateTab(name)
        local page = Instance.new("ScrollingFrame", Main)
        page.Size = UDim2.new(1, -24, 1, -66); page.Position = UDim2.new(0, 12, 0, 54)
        page.BackgroundTransparency = 1; page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Config.Theme.Accent; page.Visible = false
        page.BorderSizePixel = 0
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        local pageLayout = Instance.new("UIListLayout", page); pageLayout.Padding = UDim.new(0, 6)
        local pagePadding = Instance.new("UIPadding", page)
        pagePadding.PaddingBottom = UDim.new(0, 16)
        pagePadding.PaddingRight = UDim.new(0, 6)

        local btn = Instance.new("TextButton", TabBar)
        btn.Size = UDim2.new(0, 82, 1, 0); btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        btn.Text = name; btn.TextColor3 = Config.Theme.Dim; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
        btn.AutoButtonColor = false; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages) do p.Visible = false end
            for _, b in pairs(TabButtons) do
                Services.TweenService:Create(b, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(28, 28, 38), TextColor3 = Config.Theme.Dim }):Play()
            end
            page.Visible = true
            Services.TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Config.Theme.Accent, TextColor3 = Config.Theme.Main }):Play()
        end)

        table.insert(Pages, page); table.insert(TabButtons, btn)
        return page, btn
    end

    local P1, B1 = CreateTab("🎯 COMBAT")
    local P2, B2 = CreateTab("👁️ VISUALS")
    local P3, B3 = CreateTab("🏃 MOVEMENT")
    P1.Visible = true; B1.BackgroundColor3 = Config.Theme.Accent; B1.TextColor3 = Config.Theme.Main

    local function AddToggle(page, text, stateKey, cb)
        local btn = Instance.new("TextButton", page)
        btn.Size = UDim2.new(1, 0, 0, 36); btn.BackgroundColor3 = Config.Theme.Sec
        btn.Text = ""; btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", btn); s.Color = Config.Theme.Accent; s.Transparency = 0.85

        local lbl = Instance.new("TextLabel", btn)
        lbl.Text = text; lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.TextColor3 = Config.Theme.Text
        lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

        local ind = Instance.new("Frame", btn)
        ind.Size = UDim2.new(0, 32, 0, 16); ind.Position = UDim2.new(1, -44, 0.5, -8)
        ind.BackgroundColor3 = Color3.fromRGB(35, 35, 48); Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame", ind)
        dot.Size = UDim2.new(0, 12, 0, 12); dot.Position = UDim2.new(0, 2, 0.5, -6)
        dot.BackgroundColor3 = Color3.fromRGB(90, 90, 105); Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local function SetUI(v)
            Services.TweenService:Create(dot, TweenInfo.new(0.2), {
                Position = v and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                BackgroundColor3 = v and Config.Theme.Accent or Color3.fromRGB(90, 90, 105)
            }):Play()
            Services.TweenService:Create(s, TweenInfo.new(0.2), { Transparency = v and 0.4 or 0.85 }):Play()
            if cb then cb(v) end
        end

        Storage.ToggleFuncs[stateKey] = function(v) Config.States[stateKey] = v; SetUI(v) end
        btn.MouseButton1Click:Connect(function()
            Config.States[stateKey] = not Config.States[stateKey]
            SetUI(Config.States[stateKey])
        end)
    end

    local function AddSlider(page, text, min, max, valKey, cb)
        local frame = Instance.new("Frame", page)
        frame.Size = UDim2.new(1, 0, 0, 44); frame.BackgroundColor3 = Config.Theme.Sec
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Text = text .. ": " .. tostring(Config.Vals[valKey])
        lbl.Size = UDim2.new(1, -20, 0, 18); lbl.Position = UDim2.new(0, 12, 0, 4)
        lbl.BackgroundTransparency = 1; lbl.TextColor3 = Config.Theme.Text
        lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("TextButton", frame)
        bar.Size = UDim2.new(1, -24, 0, 5); bar.Position = UDim2.new(0, 12, 0, 28)
        bar.BackgroundColor3 = Color3.fromRGB(35, 35, 48); bar.Text = ""; bar.AutoButtonColor = false
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((Config.Vals[valKey] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Config.Theme.Accent; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local dragging = false
        bar.MouseButton1Down:Connect(function() dragging = true end)
        TrackConn(Services.UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end))
        TrackConn(Services.UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local v = math.floor(min + (max - min) * p)
                fill.Size = UDim2.new(p, 0, 1, 0)
                Config.Vals[valKey] = v
                lbl.Text = text .. ": " .. tostring(v)
                if cb then cb(v) end
            end
        end))
    end

    -- TAB 1: COMBAT
    AddToggle(P1, "🎯 Dynamic Smooth Aimbot", "Aimbot")
    AddToggle(P1, "🔮 Smart Prediction (Velocity)", "SmartPrediction")
    AddToggle(P1, "🦴 Auto Aim Part (Head/Torso)", "AutoAimPart")
    AddToggle(P1, "👻 Silent Aim (Metamethod Hook)", "SilentAim")
    AddToggle(P1, "🔔 Hit Sound (Tactical Audio)", "HitSound")
    AddToggle(P1, "🛡️ No Camera Recoil", "NoRecoil")
    AddToggle(P1, "🔫 TriggerBot [T]", "TriggerBot")
    AddToggle(P1, "⭕ Show FOV Circle", "ShowFOV", function(v) if Storage.FOVRingUI then Storage.FOVRingUI.Visible = v end end)
    AddSlider(P1, "FOV Size", 50, 500, "FOV", function(v)
        if Storage.FOVRingUI then Storage.FOVRingUI.Size = UDim2.new(0, v * 2, 0, v * 2) end
    end)
    AddToggle(P1, "🛡️ Team Check", "TeamCheck")
    AddToggle(P1, "🧱 Wall Check", "WallCheck")

    -- TAB 2: VISUALS
    AddToggle(P2, "👻 Detect No-Spawn / Lobby", "DetectUnspawned")
    AddToggle(P2, "📦 Box ESP", "ESP", function(v)
        if not v and Drawing then
            for _, esp in pairs(Storage.ESPObjects) do
                if esp.Box then esp.Box.Visible = false end
                if esp.Name then esp.Name.Visible = false end
                if esp.HealthBar then esp.HealthBar.Visible = false end
                if esp.Weapon then esp.Weapon.Visible = false end
            end
        end
    end)
    AddToggle(P2, "📦 Item & Loot ESP", "ItemESP", function(v) if not v then ClearItemESP() else task.spawn(UpdateItemESP) end end)
    AddToggle(P2, "🔫 Weapon / Tool ESP", "WeaponESP")
    AddToggle(P2, "🦴 Skeleton ESP", "ESPSkeleton")
    AddToggle(P2, "🧭 Off-screen Target Arrows", "OffscreenArrows")
    AddToggle(P2, "📡 Tactical 2D Radar", "Radar", function(v)
        if Storage.RadarFrame then Storage.RadarFrame.Visible = v end
    end)
    AddToggle(P2, "✨ Chams (Highlight)", "Chams", function() Utils.UpdateChams() end)
    AddToggle(P2, "📏 Tracers", "Tracers")
    AddToggle(P2, "💡 Fullbright", "Fullbright", function(v) Utils.ToggleFullbright(v) end)
    AddToggle(P2, "➕ Crosshair", "Crosshair")

    -- TAB 3: MOVEMENT & MISC
    AddToggle(P3, "🦅 Fly Mode [Z]", "Fly", function() Utils.UpdateCollisions() end)
    AddToggle(P3, "🪶 Legit Fly (Safe Drift)", "LegitFly")
    AddSlider(P3, "Fly Speed", 20, 400, "FlySpeed")
    AddToggle(P3, "👻 Noclip [V]", "Noclip", function() Utils.UpdateCollisions() end)
    AddToggle(P3, "⚡ Speed Hack", "SpeedHack", function(v)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v and Config.Vals.WalkSpeed or Storage.OriginalWalkSpeed end
    end)
    AddSlider(P3, "Walk Speed", 20, 250, "WalkSpeed", function(v)
        if Config.States.SpeedHack and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end)
    AddToggle(P3, "🛡️ God Mode (Anti-Killbrick)", "AntiKillbrick")
    AddToggle(P3, "🪂 No Fall Damage", "NoFall")
    AddToggle(P3, "🦘 Infinite Jump", "InfJump")
    AddToggle(P3, "📍 Click TP [Ctrl+Click]", "ClickTP")
    AddToggle(P3, "🚗 Vehicle Speed Boost", "VehicleBoost")
    AddSlider(P3, "Vehicle Speed", 50, 350, "VehicleSpeed")

    -- Auto Canvas Sizing with bottom padding ensures every item is fully visible
    P1.CanvasSize = UDim2.new(0, 0, 0, 0)
    P2.CanvasSize = UDim2.new(0, 0, 0, 0)
    P3.CanvasSize = UDim2.new(0, 0, 0, 0)
end

-- ==================================================================
-- UNLOAD & CLEANUP
-- ==================================================================
Unload = function()
    for _, c in pairs(Storage.Connections) do pcall(function() c:Disconnect() end) end
    Storage.Connections = {}
    for _, p in pairs(Services.Players:GetPlayers()) do
        if Storage.ESPObjects[p] then
            for _, d in pairs(Storage.ESPObjects[p]) do pcall(function() d:Remove() end) end
        end
        if Storage.TracerLines[p] then pcall(function() Storage.TracerLines[p]:Remove() end) end
        if Storage.OffscreenArrows[p] then pcall(function() Storage.OffscreenArrows[p]:Remove() end) end
    end
    if Storage.CrosshairLines.H then pcall(function() Storage.CrosshairLines.H:Remove(); Storage.CrosshairLines.V:Remove() end) end
    for _, lines in pairs(Storage.SkeletonParts) do
        for _, l in pairs(lines) do pcall(function() l:Remove() end) end
    end

    Config.States.Chams = false; Utils.UpdateChams()
    Config.States.Fullbright = false; Utils.ToggleFullbright(false)
    Config.States.Fly = false; Config.States.Noclip = false; Utils.UpdateCollisions()

    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Storage.OriginalWalkSpeed; hum.PlatformStand = false end

    if Storage.MainFrame and Storage.MainFrame.Parent then Storage.MainFrame.Parent:Destroy() end
    if Storage.FOVRingUI and Storage.FOVRingUI.Parent then Storage.FOVRingUI.Parent:Destroy() end
    if Storage.RadarGui and Storage.RadarGui.Parent then Storage.RadarGui:Destroy() end
    Notify("X PRO V3.1", "All Pro modules successfully unloaded.")
end

-- ==================================================================
-- RUNTIME INITIALIZATION
-- ==================================================================
local function Init()
    local fovGui = Instance.new("ScreenGui", targetGui)
    fovGui.Name = "X_PRO_FOV"; fovGui.ResetOnSpawn = false; fovGui.IgnoreGuiInset = true
    local ring = Instance.new("Frame", fovGui)
    ring.AnchorPoint = Vector2.new(0.5, 0.5); ring.Position = UDim2.new(0.5, 0, 0.5, 0)
    ring.Size = UDim2.new(0, Config.Vals.FOV * 2, 0, Config.Vals.FOV * 2)
    ring.BackgroundTransparency = 1; ring.Visible = false
    local stroke = Instance.new("UIStroke", ring)
    stroke.Color = Config.Theme.Accent; stroke.Thickness = 1.5; stroke.Transparency = 0.35
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    Storage.FOVRingUI = ring

    if Drawing then
        Storage.CrosshairLines.H = Drawing.new("Line"); Storage.CrosshairLines.H.Thickness = 1.5; Storage.CrosshairLines.H.Color = Config.Theme.Accent; Storage.CrosshairLines.H.Visible = false
        Storage.CrosshairLines.V = Drawing.new("Line"); Storage.CrosshairLines.V.Thickness = 1.5; Storage.CrosshairLines.V.Color = Config.Theme.Accent; Storage.CrosshairLines.V.Visible = false
    end

    CreateRadar()
    BuildUI()

    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then Storage.OriginalWalkSpeed = hum.WalkSpeed end

    TrackConn(LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local newHum = char:WaitForChild("Humanoid", 3)
        if newHum then Storage.OriginalWalkSpeed = newHum.WalkSpeed end
        if Config.States.SpeedHack and newHum then newHum.WalkSpeed = Config.Vals.WalkSpeed end
        Utils.UpdateCollisions()
    end))

    -- Stepped Loop
    TrackConn(Services.RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if Config.States.NoFall and hrp.AssemblyLinearVelocity.Y < -35 then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -30, hrp.AssemblyLinearVelocity.Z)
            hum.FallDistance = 0
        end

        if Config.States.Fly or Config.States.Noclip then
            Utils.UpdateCollisions()
        end
    end))

    -- RenderStepped Loop
    TrackConn(Services.RunService.RenderStepped:Connect(function()
        -- Dynamic Smooth Aimbot
        if Config.States.Aimbot then
            local canAim = not Config.States.RightClickToggle or Storage.IsRightMouseDown
            if canAim then
                local target = Utils.GetClosestTarget()
                if target and target.Parent then
                    local targetPos = target.Position
                    local root = target.Parent:FindFirstChild("HumanoidRootPart")
                    if Config.States.SmartPrediction and root then
                        targetPos = targetPos + (root.AssemblyLinearVelocity * Config.Vals.PredictionStrength)
                    end
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPos), Config.Vals.Smoothness)
                end
            end
        end

        -- TriggerBot
        if Config.States.TriggerBot and tick() > Storage.TriggerCooldown then
            local target = Mouse.Target
            if target and target.Parent then
                local eHum = target.Parent:FindFirstChildOfClass("Humanoid")
                local targetPlayer = Services.Players:GetPlayerFromCharacter(target.Parent)
                if eHum and eHum.Health > 0 and target.Parent.Name ~= LocalPlayer.Name then
                    if not Config.States.TeamCheck or not Utils.IsTeammate(targetPlayer) then
                        Storage.TriggerCooldown = tick() + Config.Vals.TriggerDelay
                        PlayHitSound()
                        if type(mouse1click) == "function" then
                            mouse1click()
                        else
                            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                        end
                    end
                end
            end
        end

        -- ESP, Visuals, Offscreen Arrows (ZERO-LAG GUARDED)
        local anyESP = Config.States.ESP or Config.States.Tracers or Config.States.OffscreenArrows or Config.States.ESPSkeleton
        if Drawing and anyESP then
            UpdateSkeletonESP()

            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

            for _, plr in pairs(Services.Players:GetPlayers()) do
                local cData = (plr ~= LocalPlayer) and Utils.GetCharacterData(plr)
                if cData then
                    local root = cData.Root
                    local head = cData.Head
                    local hum = cData.Hum

                    local isAlive, isUnspawned = Utils.IsAlive(cData.Char, hum, plr)
                    if isAlive or (Config.States.DetectUnspawned and isUnspawned) then
                        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                        local color = isUnspawned and Color3.fromRGB(190, 130, 255) or ((Config.States.TeamCheck and Utils.IsTeammate(plr)) and Config.Theme.Team or Config.Theme.Accent)

                        -- Box + Weapon ESP
                        if Config.States.ESP then
                            local esp = Storage.ESPObjects[plr]
                            if not esp then
                                esp = {
                                    Box = Drawing.new("Square"),
                                    Name = Drawing.new("Text"),
                                    HealthBar = Drawing.new("Line"),
                                    Weapon = Drawing.new("Text")
                                }
                                esp.Box.Thickness = 1.5; esp.Box.Filled = false
                                esp.Name.Size = 13; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Color = Color3.new(1,1,1)
                                esp.HealthBar.Thickness = 1.5; esp.HealthBar.Color = Color3.new(0,1,0)
                                esp.Weapon.Size = 11; esp.Weapon.Center = true; esp.Weapon.Outline = true; esp.Weapon.Color = Config.Theme.Dim
                                Storage.ESPObjects[plr] = esp
                            end

                            local rootCFrame = root.CFrame
                            local topPos, topOn = Camera:WorldToViewportPoint((rootCFrame * CFrame.new(0, 2.4, 0)).Position)
                            local bottomPos, bottomOn = Camera:WorldToViewportPoint((rootCFrame * CFrame.new(0, -3.2, 0)).Position)
                            local isVisOnScreen = topOn or bottomOn

                            if isVisOnScreen and topPos.Z > 0 then
                                local height = math.abs(topPos.Y - bottomPos.Y)
                                local width = height / 1.6
                                local boxX = topPos.X - width / 2
                                local boxY = math.min(topPos.Y, bottomPos.Y)

                                esp.Box.Visible = true; esp.Box.Size = Vector2.new(width, height)
                                esp.Box.Position = Vector2.new(boxX, boxY); esp.Box.Color = color; esp.Box.Transparency = 1

                                esp.Name.Visible = true; esp.Name.Text = isUnspawned and (plr.DisplayName .. " [NO-SPAWN]") or plr.DisplayName
                                esp.Name.Position = Vector2.new(boxX + width / 2, boxY - 16); esp.Name.Color = color

                                esp.HealthBar.Visible = true
                                esp.HealthBar.From = Vector2.new(boxX - 5, boxY + height)
                                local curHp, maxHp = Utils.GetHealth(plr, cData.Char); esp.HealthBar.To = Vector2.new(boxX - 5, boxY + height - height * math.clamp(curHp / maxHp, 0, 1))

                                if Config.States.WeaponESP then
                                    local tool = plr.Character:FindFirstChildOfClass("Tool")
                                    esp.Weapon.Visible = true
                                    esp.Weapon.Text = tool and "[" .. tool.Name .. "]" or "[Unarmed]"
                                    esp.Weapon.Position = Vector2.new(boxX + width / 2, boxY + height + 2)
                                else
                                    esp.Weapon.Visible = false
                                end
                            else
                                esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false; esp.Weapon.Visible = false
                            end
                        elseif Storage.ESPObjects[plr] then
                            Storage.ESPObjects[plr].Box.Visible = false; Storage.ESPObjects[plr].Name.Visible = false
                            Storage.ESPObjects[plr].HealthBar.Visible = false; Storage.ESPObjects[plr].Weapon.Visible = false
                        end

                        -- Tracers
                        if Config.States.Tracers then
                            local line = Storage.TracerLines[plr]
                            if not line then
                                line = Drawing.new("Line"); line.Thickness = 1.2; Storage.TracerLines[plr] = line
                            end
                            if onScreen then
                                line.Visible = true; line.Color = color
                                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                line.To = Vector2.new(pos.X, pos.Y)
                            else line.Visible = false end
                        elseif Storage.TracerLines[plr] then Storage.TracerLines[plr].Visible = false end

                        -- Off-screen Indicator Arrow
                        if Config.States.OffscreenArrows then
                            local arrowOk = pcall(function()
                                local arrow = Storage.OffscreenArrows[plr]
                                if not arrow then
                                    arrow = Drawing.new("Triangle")
                                    arrow.Filled = true
                                    Storage.OffscreenArrows[plr] = arrow
                                end

                                if not onScreen and not (Config.States.TeamCheck and Utils.IsTeammate(plr)) then
                                    local rel = (root.Position - Camera.CFrame.Position)
                                    local forward = Camera.CFrame.LookVector
                                    local right = Camera.CFrame.RightVector
                                    local dotForward = forward:Dot(rel)
                                    local dotRight = right:Dot(rel)

                                    local angle = math.atan2(dotRight, dotForward)
                                    local arrowRadius = math.min(center.X, center.Y) * 0.75
                                    local arrowCenter = center + Vector2.new(math.sin(angle) * arrowRadius, -math.cos(angle) * arrowRadius)

                                    local tip = arrowCenter + Vector2.new(math.sin(angle) * 12, -math.cos(angle) * 12)
                                    local leftPt = arrowCenter + Vector2.new(math.sin(angle + 2.5) * 8, -math.cos(angle + 2.5) * 8)
                                    local rightPt = arrowCenter + Vector2.new(math.sin(angle - 2.5) * 8, -math.cos(angle - 2.5) * 8)

                                    arrow.PointA = tip
                                    arrow.PointB = leftPt
                                    arrow.PointC = rightPt
                                    arrow.Color = Config.Theme.LockColor
                                    arrow.Visible = true
                                else
                                    arrow.Visible = false
                                end
                            end)
                            if not arrowOk then Config.States.OffscreenArrows = false end
                        elseif Storage.OffscreenArrows[plr] then
                            pcall(function() Storage.OffscreenArrows[plr].Visible = false end)
                        end
                    end
                end
            end

            -- Crosshair
            if Config.States.Crosshair and Storage.CrosshairLines.H then
                Storage.CrosshairLines.H.Visible = true
                Storage.CrosshairLines.H.From = Vector2.new(center.X - 10, center.Y); Storage.CrosshairLines.H.To = Vector2.new(center.X + 10, center.Y)
                Storage.CrosshairLines.V.Visible = true
                Storage.CrosshairLines.V.From = Vector2.new(center.X, center.Y - 10); Storage.CrosshairLines.V.To = Vector2.new(center.X, center.Y + 10)
            elseif Storage.CrosshairLines.H then
                Storage.CrosshairLines.H.Visible = false; Storage.CrosshairLines.V.Visible = false
            end
        end

        UpdateRadar()
    end))

    -- Heartbeat Loop
    TrackConn(Services.RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if Config.States.Fly then
            hum.PlatformStand = true
            local dir = Vector3.zero
            local cf = Camera.CFrame
            if Services.UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
            if Services.UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
            if Services.UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
            if Services.UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
            if Services.UIS:IsKeyDown(Enum.KeyCode.Space) or Services.UIS:IsKeyDown(Enum.KeyCode.E) then dir = dir + Vector3.new(0, 1, 0) end
            if Services.UIS:IsKeyDown(Enum.KeyCode.LeftShift) or Services.UIS:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Vector3.new(0, 1, 0) end

            if Config.States.LegitFly then
                hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity:Lerp(dir * Config.Vals.FlySpeed, 0.15)
            else
                hrp.AssemblyLinearVelocity = dir * Config.Vals.FlySpeed
            end
        elseif hum.PlatformStand then
            hum.PlatformStand = false
        end

        
        -- Vehicle Speed Boost
        if Config.States.VehicleBoost and hum and hum.SeatPart then
            local seat = hum.SeatPart
            if seat:IsA("VehicleSeat") then
                seat.MaxSpeed = math.max(seat.MaxSpeed, Config.Vals.VehicleSpeed)
                seat.Torque = 1000000
            end
            local carRoot = seat.AssemblyRootPart or seat
            if carRoot then
                local isFwd = Services.UIS:IsKeyDown(Enum.KeyCode.W)
                local isBack = Services.UIS:IsKeyDown(Enum.KeyCode.S)
                if isFwd or isBack then
                    local dir = seat.CFrame.LookVector * (isFwd and 1 or -1)
                    local curVel = carRoot.AssemblyLinearVelocity
                    local target = dir * Config.Vals.VehicleSpeed
                    carRoot.AssemblyLinearVelocity = Vector3.new(target.X, curVel.Y, target.Z)
                end
            end
        end

        if Config.States.InfJump and Services.UIS:IsKeyDown(Enum.KeyCode.Space) then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))

    -- User Inputs
    TrackConn(Services.UIS.InputBegan:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Storage.IsRightMouseDown = true
        end

        -- Menu Toggle: Process before gpe
        if input.KeyCode == Config.Keys.Menu or input.KeyCode == Enum.KeyCode.RightControl then
            local focused = Services.UIS:GetFocusedTextBox()
            if not focused then
                if Storage.MainFrame then Storage.MainFrame.Visible = not Storage.MainFrame.Visible end
                return
            end
        end

        if gpe then return end
        if input.KeyCode == Config.Keys.Fly then
            if Storage.ToggleFuncs["Fly"] then Storage.ToggleFuncs["Fly"](not Config.States.Fly) end
        elseif input.KeyCode == Config.Keys.Noclip then
            if Storage.ToggleFuncs["Noclip"] then Storage.ToggleFuncs["Noclip"](not Config.States.Noclip) end
        elseif input.KeyCode == Config.Keys.Trigger then
            if Storage.ToggleFuncs["TriggerBot"] then Storage.ToggleFuncs["TriggerBot"](not Config.States.TriggerBot) end
        elseif input.KeyCode == Config.Keys.LockTarget then
            local t = Utils.GetClosestTarget()
            if t then
                Storage.LockedTarget = t
                Notify("🎯 Target Locked", "Locked: " .. (t.Parent and t.Parent.Name or "Unknown"))
            else
                Storage.LockedTarget = nil
                Notify("🎯 Target Unlocked", "Target lock released")
            end
        elseif input.KeyCode == Config.Keys.Unload then
            Unload()
        end

        -- Xeno / No-Hook Silent Aim Trigger
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Config.States.SilentAim and not HasMetamethodHook then
            MicroFlickSilentAim()
        end

        -- Click TP
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Config.States.ClickTP and Services.UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Mouse.Target then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end))

    TrackConn(Services.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Storage.IsRightMouseDown = false
        end
    end))

    task.spawn(function()
        while true do
            task.wait(0.5)
            if Config.States.Chams then
                pcall(Utils.UpdateChams)
            end
            if Config.States.ItemESP then
                pcall(UpdateItemESP)
            end
        end
    end)

    Notify("X PRO V3.4.3", "Tournament Pro Active! [Insert] Menu [F] Lock Target [End] Unload")
end

Init()
