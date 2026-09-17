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

-- [[ X NANOM V3.4.1 - MOBILE TOUCH EDITION ]]
-- Positioning: Mobile Full Touch / Delta / Tablet & Phone Exclusive / Zero Keyboard Dependent
-- Mobile Exclusive: Draggable Floating Bubble | On-Screen Fly Controls | Large Touch Sliders | Smooth Lock | Safe Unload
-- Seller: vlilayz | Official Discord: https://discord.gg/mQ3ASbfP8j
-- ==================================================================
if _G.X_NANOM_INSTANCE and type(_G.X_NANOM_INSTANCE.Unload) == "function" then
	pcall(_G.X_NANOM_INSTANCE.Unload)
	task.wait(0.05)
end
local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	UIS = game:GetService("UserInputService"),
	Workspace = game:GetService("Workspace"),
	StarterGui = game:GetService("StarterGui"),
	TweenService = game:GetService("TweenService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
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
	Theme = {
		Main = Color3.fromRGB(12, 14, 18), Sec = Color3.fromRGB(22, 24, 32),
		Accent = Color3.fromRGB(0, 230, 255), Team = Color3.fromRGB(0, 255, 120),
		Text = Color3.fromRGB(245, 245, 250), Dim = Color3.fromRGB(140, 145, 160),
		Red = Color3.fromRGB(255, 65, 65)
	},
	States = {
		Aimbot = false, TeamCheck = true, ShowFOV = false,
		ESP = false, Chams = false, Tracers = false, Fullbright = false,
		Fly = false, Noclip = false, SpeedHack = false, InfJump = false, NoFall = false
	},
	Vals = {
		FOV = 160, Smoothness = 0.35, WalkSpeed = 80, FlySpeed = 100
	},
	Seller = {
		Discord = "vlilayz",
		Version = "V3.4.1 Mobile"
	}
}

local Storage = {
	Connections = {}, ESPObjects = {}, ToggleFuncs = {},
	FOVRingUI = nil, MainFrame = nil, MenuBubble = nil,
	FlyUpBtn = nil, FlyDownBtn = nil,
	FlyUpState = false, FlyDownState = false,
	OriginalLighting = {}, OriginalCollisions = {}, OriginalWalkSpeed = 16
}

local function TrackConn(c)
	if c then table.insert(Storage.Connections, c) end
	return c
end

local function Notify(title, text)
	pcall(function()
		Services.StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 2.5 })
	end)
end

-- ==================================================================
-- CORE LOGIC (SAFE FOR MOBILE)
-- ==================================================================
local function IsTeammate(plr)
	if not plr or not LocalPlayer then return false end
	if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return true end
	if plr.TeamColor and LocalPlayer.TeamColor and plr.TeamColor == LocalPlayer.TeamColor then return true end
	return false
end

local function IsAlive(plr, char)
	if not plr or not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if char:FindFirstChild("Dead") or char:FindFirstChild("Killed") then return false end
	if plr:FindFirstChild("Status") and plr.Status:FindFirstChild("Dead") and plr.Status.Dead.Value == true then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp or hrp.Transparency >= 0.99 then return false end
	return true
end

local function GetClosestTarget()
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local closestDist, target = Config.Vals.FOV, nil

	for _, p in pairs(Services.Players:GetPlayers()) do
		if p == LocalPlayer or not p.Character then continue end
		if not IsAlive(p, p.Character) then continue end
		if Config.States.TeamCheck and IsTeammate(p) then continue end
		local head = p.Character:FindFirstChild("Head")
		if not head then continue end

		local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
		if onScreen then
			local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
			if dist < closestDist then
				closestDist = dist
				target = head
			end
		end
	end
	return target
end

local function UpdateCollisions()
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

local function UpdateChams()
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local chams = p.Character:FindFirstChild("X_NanoM_Chams")
			if Config.States.Chams then
				if not chams then
					chams = Instance.new("Highlight")
					chams.Name = "X_NanoM_Chams"
					chams.FillTransparency = 0.5
					chams.OutlineTransparency = 0.1
					chams.Parent = p.Character
				end
				local col = (Config.States.TeamCheck and IsTeammate(p)) and Config.Theme.Team or Config.Theme.Accent
				chams.FillColor = col
				chams.OutlineColor = col
			elseif chams then
				chams:Destroy()
			end
		end
	end
end

local function ToggleFullbright(state)
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

-- ==================================================================
-- DRAWING: FOV & ESP (MOBILE LIGHTWEIGHT)
-- ==================================================================
local function CreateFOVRing()
	if targetGui:FindFirstChild("X_NANOM_FOV") then targetGui["X_NANOM_FOV"]:Destroy() end
	local gui = Instance.new("ScreenGui", targetGui)
	gui.Name = "X_NANOM_FOV"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true

	local ring = Instance.new("Frame", gui)
	ring.AnchorPoint = Vector2.new(0.5, 0.5); ring.Position = UDim2.new(0.5, 0, 0.5, 0)
	ring.Size = UDim2.new(0, Config.Vals.FOV * 2, 0, Config.Vals.FOV * 2)
	ring.BackgroundTransparency = 1; ring.Visible = false

	local stroke = Instance.new("UIStroke", ring)
	stroke.Color = Config.Theme.Accent; stroke.Thickness = 1.5; stroke.Transparency = 0.35
	Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
	Storage.FOVRingUI = ring
end

local function CreateESP(plr)
	if plr == LocalPlayer or Storage.ESPObjects[plr] or not Drawing then return end
	local esp = {
		Box = Drawing.new("Square"),
		Name = Drawing.new("Text")
	}
	esp.Box.Thickness = 1.5; esp.Box.Filled = false; esp.Box.Visible = false
	esp.Name.Size = 13; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Color = Color3.new(1, 1, 1); esp.Name.Visible = false

	if isNanoPlus then
		esp.HealthBar = Drawing.new("Line"); esp.HealthBar.Thickness = 1.5; esp.HealthBar.Visible = false
		esp.Distance = Drawing.new("Text"); esp.Distance.Size = 11; esp.Distance.Center = true; esp.Distance.Outline = true
		esp.Distance.Color = Color3.fromRGB(220, 220, 220); esp.Distance.Visible = false
		esp.Tracer = Drawing.new("Line"); esp.Tracer.Thickness = 1.2; esp.Tracer.Visible = false
	end
	Storage.ESPObjects[plr] = esp
end

local function RemoveESP(plr)
	if Storage.ESPObjects[plr] then
		pcall(function() Storage.ESPObjects[plr].Box:Remove() end)
		pcall(function() Storage.ESPObjects[plr].Name:Remove() end)
		if Storage.ESPObjects[plr].HealthBar then pcall(function() Storage.ESPObjects[plr].HealthBar:Remove() end) end
		if Storage.ESPObjects[plr].Distance then pcall(function() Storage.ESPObjects[plr].Distance:Remove() end) end
		if Storage.ESPObjects[plr].Tracer then pcall(function() Storage.ESPObjects[plr].Tracer:Remove() end) end
		Storage.ESPObjects[plr] = nil
	end
end

-- ==================================================================
-- UNLOAD SYSTEM (CLEAN TOUCH DISCONNECT)
-- ==================================================================
local function Unload()
	for _, c in pairs(Storage.Connections) do pcall(function() c:Disconnect() end) end
	Storage.Connections = {}
	for _, p in pairs(Services.Players:GetPlayers()) do RemoveESP(p) end

	Config.States.Chams = false; UpdateChams()
	Config.States.Fullbright = false; ToggleFullbright(false)
	Config.States.Fly = false; Config.States.Noclip = false; UpdateCollisions()

	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = Storage.OriginalWalkSpeed
		hum.PlatformStand = false
	end

	if Storage.MainFrame and Storage.MainFrame.Parent then Storage.MainFrame.Parent:Destroy() end
	if Storage.FOVRingUI and Storage.FOVRingUI.Parent then Storage.FOVRingUI.Parent:Destroy() end
	if Storage.MenuBubble and Storage.MenuBubble.Parent then Storage.MenuBubble.Parent:Destroy() end
	if Storage.FlyUpBtn and Storage.FlyUpBtn.Parent then Storage.FlyUpBtn.Parent:Destroy() end

	_G.X_NANOM_INSTANCE = nil
	Notify("X NANOM", "Successfully unloaded!")
end

-- ==================================================================
-- MOBILE TOUCH UI & VIRTUAL CONTROLS
-- ==================================================================
local activeKey = tostring(getgenv().Key or getgenv().ScriptKey or script_key or "")
local upperKey = string.upper(activeKey)
local isFounder = (upperKey == "X-NANO-PLUS-XT7789") or (string.find(upperKey, "XT7789") ~= nil)
local isSeller = (upperKey == "X-NANO-X")
local isNanoPlus = isFounder or isSeller

-- [TIER 1 & 2] NANO+ PRO-X SILENT AIM ENGINE
local HasNanoHook = false
if isNanoPlus then
	if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
		local safeUnpack = table.unpack or unpack
		pcall(function()
			local oldNamecall
			oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				local args = {...}
				if Config.States.SilentAim and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay") then
					local targetPart = GetClosestTarget()
					if targetPart and targetPart.Parent then
						local predPos = targetPart.Position
						if method == "Raycast" then
							args[2] = (predPos - args[1]).Unit * 5000
							return oldNamecall(self, safeUnpack(args))
						else
							local ray = args[1]
							args[1] = Ray.new(ray.Origin, (predPos - ray.Origin).Unit * 5000)
							return oldNamecall(self, safeUnpack(args))
						end
					end
				end
				return oldNamecall(self, ...)
			end)
		end)
	end
	pcall(function()
		if type(getrawmetatable) == "function" and type(setreadonly) == "function" then
			local mt = getrawmetatable(game)
			if mt then
				setreadonly(mt, false)
				local oldIdx = mt.__index
				mt.__index = function(t, k)
					if Config.States.SilentAim and (t:IsA("Mouse") or tostring(t) == "Mouse") then
						local tp = GetClosestTarget()
						if tp then
							if k == "Hit" then return CFrame.new(tp.Position)
							elseif k == "Target" then return tp end
						end
				end
					return oldIdx(t, k)
				end
				setreadonly(mt, true)
			end
		end
	end)
end

local function BuildMobileUI()
	local uiName = "X_NANOM_V3_0_0"
	if targetGui:FindFirstChild(uiName) then targetGui[uiName]:Destroy() end

	local ScreenGui = Instance.new("ScreenGui", targetGui)
	ScreenGui.Name = uiName; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true
	ScreenGui.DisplayOrder = 999999

	-- 1. Smooth Touch Draggable Floating Bubble with Magnet Edge Snapping [⚡]
	local Bubble = Instance.new("TextButton", ScreenGui)
	Bubble.Size = UDim2.new(0, 50, 0, 50)
	Bubble.Position = UDim2.new(0, 16, 0.35, 0)
	Bubble.BackgroundColor3 = Config.Theme.Main
	Bubble.BackgroundTransparency = 0.2
	Bubble.Text = "⚡"
	Bubble.TextColor3 = Config.Theme.Accent
	Bubble.TextSize = 22
	Bubble.Active = true
	Bubble.AutoButtonColor = false
	Instance.new("UICorner", Bubble).CornerRadius = UDim.new(1, 0)
	local bStroke = Instance.new("UIStroke", Bubble)
	bStroke.Color = Config.Theme.Accent
	bStroke.Thickness = 2
	bStroke.Transparency = 0.3
	Storage.MenuBubble = Bubble

	-- Status Glow Indicator Dot (Active = Green / Standby = Slate)
	local StatusDot = Instance.new("Frame", Bubble)
	StatusDot.Size = UDim2.new(0, 10, 0, 10)
	StatusDot.Position = UDim2.new(1, -11, 0, 1)
	StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 140)
	Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)
	local dotStroke = Instance.new("UIStroke", StatusDot)
	dotStroke.Color = Color3.fromRGB(15, 20, 28)
	dotStroke.Thickness = 1.5

	-- 2. Large Touchscreen Menu Panel (Thumb Friendly)
	local Card = Instance.new("Frame", ScreenGui)
	Card.Size = UDim2.new(0, 290, 0, 460)
	Card.Position = UDim2.new(0.5, -145, 0.5, -230)
	Card.BackgroundColor3 = Config.Theme.Main
	Card.Active = true
	Card.Draggable = true
	Card.Visible = false
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)
	local cStroke = Instance.new("UIStroke", Card)
	cStroke.Color = Config.Theme.Accent
	cStroke.Thickness = 1.8
	cStroke.Transparency = 0.4
	Storage.MainFrame = Card

	-- Drag & Magnetic Snap Logic
	local dragging = false
	local dragInput, dragStart, startPos
	local dragThreshold = 8
	local wasDragged = false

	Bubble.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			wasDragged = false
			dragStart = input.Position
			startPos = Bubble.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Bubble.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	Services.UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging and dragStart and startPos then
			local delta = input.Position - dragStart
			if delta.Magnitude > dragThreshold then
				wasDragged = true
			end
			Bubble.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	Services.UIS.InputEnded:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
			dragging = false
			if wasDragged then
				local screenSize = Camera.ViewportSize
				local currentX = Bubble.AbsolutePosition.X
				local currentY = Bubble.AbsolutePosition.Y
				local targetX = (currentX + 25 < screenSize.X / 2) and 16 or (screenSize.X - 66)
				local targetY = math.clamp(currentY, 40, screenSize.Y - 90)

				Services.TweenService:Create(Bubble, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Position = UDim2.new(0, targetX, 0, targetY)
				}):Play()
			end
		end
	end)

	-- Tap floating bubble to toggle menu visibility (only when not dragged)
	Bubble.MouseButton1Click:Connect(function()
		if not wasDragged then
			Card.Visible = not Card.Visible
			Bubble.Text = Card.Visible and "×" or "⚡"
			if Card.Visible then
				Card.Position = UDim2.new(0.5, -145, 0.5, -230)
			end
		end
	end)

	-- Header
	local Header = Instance.new("Frame", Card)
	Header.Size = UDim2.new(1, 0, 0, 42); Header.BackgroundColor3 = Config.Theme.Sec
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

	local Title = Instance.new("TextLabel", Header)
	if isFounder then
		Title.Text = "📱 X NANO<font color='#00e6ff'>+</font> <font color='#ffcd32'>[XT7789]</font>"; Title.RichText = true
	elseif isSeller then
		Title.Text = "📱 X NANO<font color='#00e6ff'>+</font> <font color='#00d2ff'>[CO-FOUNDER]</font>"; Title.RichText = true
	elseif isNanoPlus then
		Title.Text = "📱 X NANO<font color='#00e6ff'>+</font> <font color='#ffcd32'>[PRO-X]</font>"; Title.RichText = true
	else
		Title.Text = "📱 X NANO <font color='#8c8c96'>V3.4.1</font>"; Title.RichText = true
	end
	Title.Size = UDim2.new(1, -44, 1, 0); Title.Position = UDim2.new(0, 12, 0, 0)
	Title.BackgroundTransparency = 1; Title.TextColor3 = Config.Theme.Text
	Title.Font = Enum.Font.GothamBold; Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left

	local CloseBtn = Instance.new("TextButton", Header)
	CloseBtn.Size = UDim2.new(0, 32, 0, 32); CloseBtn.Position = UDim2.new(1, -36, 0, 5)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 50); CloseBtn.Text = "×"; CloseBtn.TextColor3 = Config.Theme.Dim
	CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 18; CloseBtn.AutoButtonColor = false
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
	CloseBtn.MouseButton1Click:Connect(function()
		Card.Visible = false
		Bubble.Text = "⚡"
	end)

	-- Scrollable Items (Touchscreen Optimized Sizing)
	local Content = Instance.new("ScrollingFrame", Card)
	Content.Size = UDim2.new(1, -16, 1, -52); Content.Position = UDim2.new(0, 8, 0, 46)
	Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 3
	Content.ScrollBarImageColor3 = Config.Theme.Accent
	local Layout = Instance.new("UIListLayout", Content); Layout.Padding = UDim.new(0, 7)

	local function AddToggle(text, stateKey, cb)
		local btn = Instance.new("TextButton", Content)
		btn.Size = UDim2.new(1, -4, 0, 40); btn.BackgroundColor3 = Config.Theme.Sec
		btn.Text = ""; btn.AutoButtonColor = false
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		local s = Instance.new("UIStroke", btn); s.Color = Config.Theme.Accent; s.Transparency = 0.85

		local lbl = Instance.new("TextLabel", btn)
		lbl.Text = text; lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
		lbl.BackgroundTransparency = 1; lbl.TextColor3 = Config.Theme.Text
		lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

		local ind = Instance.new("Frame", btn)
		ind.Size = UDim2.new(0, 36, 0, 20); ind.Position = UDim2.new(1, -46, 0.5, -10)
		ind.BackgroundColor3 = Color3.fromRGB(40, 42, 52); Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

		local dot = Instance.new("Frame", ind)
		dot.Size = UDim2.new(0, 16, 0, 16); dot.Position = UDim2.new(0, 2, 0.5, -8)
		dot.BackgroundColor3 = Color3.fromRGB(90, 95, 105); Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

		local function SetUI(v)
			Services.TweenService:Create(dot, TweenInfo.new(0.2), {
				Position = v and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
				BackgroundColor3 = v and Config.Theme.Accent or Color3.fromRGB(90, 95, 105)
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

	-- Touch Sliders (Supports Drag & Tap)
	local function AddSlider(text, min, max, valKey, cb)
		local frame = Instance.new("Frame", Content)
		frame.Size = UDim2.new(1, -4, 0, 48); frame.BackgroundColor3 = Config.Theme.Sec
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

		local lbl = Instance.new("TextLabel", frame)
		lbl.Text = text .. ": " .. tostring(Config.Vals[valKey])
		lbl.Size = UDim2.new(1, -20, 0, 18); lbl.Position = UDim2.new(0, 12, 0, 5)
		lbl.BackgroundTransparency = 1; lbl.TextColor3 = Config.Theme.Text
		lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

		local bar = Instance.new("TextButton", frame)
		bar.Size = UDim2.new(1, -24, 0, 8); bar.Position = UDim2.new(0, 12, 0, 28)
		bar.BackgroundColor3 = Color3.fromRGB(40, 42, 52); bar.Text = ""; bar.AutoButtonColor = false
		Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

		local fill = Instance.new("Frame", bar)
		fill.Size = UDim2.new((Config.Vals[valKey] - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = Config.Theme.Accent; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

		local dragging = false
		local function updateTouch(xPos)
			local p = math.clamp((xPos - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			local v = math.floor(min + (max - min) * p)
			fill.Size = UDim2.new(p, 0, 1, 0)
			Config.Vals[valKey] = v
			lbl.Text = text .. ": " .. tostring(v)
			if cb then cb(v) end
		end

		bar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true; updateTouch(i.Position.X)
			end
		end)
		TrackConn(Services.UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end))
		TrackConn(Services.UIS.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
				updateTouch(i.Position.X)
			end
		end))
	end

	-- 3. On-Screen Flight Virtual Touch Controls (▲ Up / ▼ Down)
	local FlyControlGui = Instance.new("Frame", ScreenGui)
	FlyControlGui.Size = UDim2.new(0, 70, 0, 150); FlyControlGui.Position = UDim2.new(1, -85, 0.5, -75)
	FlyControlGui.BackgroundTransparency = 1; FlyControlGui.Visible = false

	local UpBtn = Instance.new("TextButton", FlyControlGui)
	UpBtn.Size = UDim2.new(0, 65, 0, 65); UpBtn.Position = UDim2.new(0, 0, 0, 0)
	UpBtn.BackgroundColor3 = Config.Theme.Main; UpBtn.BackgroundTransparency = 0.25
	UpBtn.Text = "▲"; UpBtn.TextColor3 = Config.Theme.Accent; UpBtn.Font = Enum.Font.GothamBlack; UpBtn.TextSize = 28
	UpBtn.AutoButtonColor = false; Instance.new("UICorner", UpBtn).CornerRadius = UDim.new(1, 0)
	local uStroke = Instance.new("UIStroke", UpBtn); uStroke.Color = Config.Theme.Accent; uStroke.Thickness = 2

	local DownBtn = Instance.new("TextButton", FlyControlGui)
	DownBtn.Size = UDim2.new(0, 65, 0, 65); DownBtn.Position = UDim2.new(0, 0, 0, 80)
	DownBtn.BackgroundColor3 = Config.Theme.Main; DownBtn.BackgroundTransparency = 0.25
	DownBtn.Text = "▼"; DownBtn.TextColor3 = Config.Theme.Accent; DownBtn.Font = Enum.Font.GothamBlack; DownBtn.TextSize = 28
	DownBtn.AutoButtonColor = false; Instance.new("UICorner", DownBtn).CornerRadius = UDim.new(1, 0)
	local dStroke = Instance.new("UIStroke", DownBtn); dStroke.Color = Config.Theme.Accent; dStroke.Thickness = 2

	-- Touch input listeners
	UpBtn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			Storage.FlyUpState = true
			Services.TweenService:Create(UpBtn, TweenInfo.new(0.1), { BackgroundColor3 = Config.Theme.Accent, TextColor3 = Config.Theme.Main }):Play()
		end
	end)
	UpBtn.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			Storage.FlyUpState = false
			Services.TweenService:Create(UpBtn, TweenInfo.new(0.1), { BackgroundColor3 = Config.Theme.Main, TextColor3 = Config.Theme.Accent }):Play()
		end
	end)

	DownBtn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			Storage.FlyDownState = true
			Services.TweenService:Create(DownBtn, TweenInfo.new(0.1), { BackgroundColor3 = Config.Theme.Accent, TextColor3 = Config.Theme.Main }):Play()
		end
	end)
	DownBtn.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			Storage.FlyDownState = false
			Services.TweenService:Create(DownBtn, TweenInfo.new(0.1), { BackgroundColor3 = Config.Theme.Main, TextColor3 = Config.Theme.Accent }):Play()
		end
	end)

	Storage.FlyUpBtn = FlyControlGui

	-- Add Mobile Feature Items
	if isNanoPlus then
		AddToggle("🔥 Silent Aim [PRO-X]", "SilentAim")
	end
	AddToggle("🎯 Auto Lock Aimbot", "Aimbot")
	AddToggle("⭕ Show FOV Circle", "ShowFOV", function(v) if Storage.FOVRingUI then Storage.FOVRingUI.Visible = v end end)
	local maxFOV = isNanoPlus and 400 or 150
	local maxFly = isNanoPlus and 250 or 150
	local maxWalk = isNanoPlus and 200 or 150
	if not isNanoPlus then
		Config.Vals.FOV = math.min(Config.Vals.FOV, maxFOV)
		Config.Vals.FlySpeed = math.min(Config.Vals.FlySpeed, maxFly)
		Config.Vals.WalkSpeed = math.min(Config.Vals.WalkSpeed, maxWalk)
	end

	AddSlider("FOV Radius" .. (isNanoPlus and " (PRO-X)" or " (Max 150)"), 50, maxFOV, "FOV", function(v)
		if Storage.FOVRingUI then Storage.FOVRingUI.Size = UDim2.new(0, v * 2, 0, v * 2) end
	end)
	AddToggle("🛡️ Team Check", "TeamCheck")
	if isNanoPlus then
		AddToggle("📏 Snapline Tracers 👑 [Nano+]", "Tracers")
	end
	AddToggle("📦 Box ESP", "ESP", function(v)
        if not v and Drawing then
            for _, esp in pairs(Storage.ESPObjects) do
                if esp.Box then esp.Box.Visible = false end
                if esp.Name then esp.Name.Visible = false end
            end
        end
    end)
	AddToggle("✨ Chams Glow (Highlight)", "Chams", function() UpdateChams() end)
	AddToggle("💡 Fullbright", "Fullbright", function(v) ToggleFullbright(v) end)
	AddToggle("🦅 Touch Fly (▲▼ Controls)", "Fly", function(v)
		UpdateCollisions()
		if Storage.FlyUpBtn then Storage.FlyUpBtn.Visible = v end
	end)
	AddSlider("Fly Speed" .. (isNanoPlus and " (PRO-X)" or " (Max 150)"), 20, maxFly, "FlySpeed")
	AddToggle("👻 Noclip", "Noclip", function() UpdateCollisions() end)
	AddToggle("⚡ Speed Hack", "SpeedHack", function(v)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v and Config.Vals.WalkSpeed or Storage.OriginalWalkSpeed end
	end)
	AddSlider("Walk Speed" .. (isNanoPlus and " (PRO-X)" or " (Max 150)"), 20, maxWalk, "WalkSpeed", function(v)
		if Config.States.SpeedHack and LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = v end
		end
	end)
	AddToggle("🦘 Infinite Jump", "InfJump")
	AddToggle("🪂 No Fall Damage", "NoFall")

	-- One-Touch Safe Unload Button
	local UnloadBtn = Instance.new("TextButton", Content)
	UnloadBtn.Size = UDim2.new(1, -4, 0, 42); UnloadBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 25)
	UnloadBtn.Text = "🛑 UNLOAD SCRIPT"; UnloadBtn.TextColor3 = Config.Theme.Red
	UnloadBtn.Font = Enum.Font.GothamBold; UnloadBtn.TextSize = 13; UnloadBtn.AutoButtonColor = false
	Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)
	local uStroke2 = Instance.new("UIStroke", UnloadBtn); uStroke2.Color = Config.Theme.Red; uStroke2.Transparency = 0.5
	UnloadBtn.MouseButton1Click:Connect(function() Unload() end)

	Content.CanvasSize = UDim2.new(0, 0, 0, 560)
end

-- ==================================================================
-- RUNTIME
-- ==================================================================
local function Init()
	CreateFOVRing()
	BuildMobileUI()

	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then Storage.OriginalWalkSpeed = hum.WalkSpeed end

	for _, p in pairs(Services.Players:GetPlayers()) do CreateESP(p) end
	TrackConn(Services.Players.PlayerAdded:Connect(CreateESP))
	TrackConn(Services.Players.PlayerRemoving:Connect(RemoveESP))

	TrackConn(LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		local newHum = char:WaitForChild("Humanoid", 3)
		if newHum then Storage.OriginalWalkSpeed = newHum.WalkSpeed end
		if Config.States.SpeedHack and newHum then newHum.WalkSpeed = Config.Vals.WalkSpeed end
		UpdateCollisions()
	end))

	-- Stepped: NoFall & Noclip
	TrackConn(Services.RunService.Stepped:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local h = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not h then return end

		if Config.States.NoFall and hrp.AssemblyLinearVelocity.Y < -35 then
			hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -30, hrp.AssemblyLinearVelocity.Z)
			h.FallDistance = 0
		end

		if Config.States.Noclip then
			UpdateCollisions()
		end
	end))

	-- RenderStepped: Aimbot & ESP (Tier Refresh Rate: Nano=75Hz/60Hz, Nano+=Uncapped)
	local lastNanomRender = 0
	local maxNanomHz = isNanoPlus and 240 or 75
	TrackConn(Services.RunService.RenderStepped:Connect(function()
		local now = tick()
		if not isNanoPlus and (now - lastNanomRender < (1 / maxNanomHz)) then return end
		lastNanomRender = now
		-- Mobile Smooth Aimbot (Auto Lock within FOV)
		if Config.States.Aimbot then
			local target = GetClosestTarget()
			if target then
				Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, target.Position), Config.Vals.Smoothness)
			end
		end

		-- Box ESP
		if Config.States.ESP and Drawing then
			for plr, esp in pairs(Storage.ESPObjects) do
				local char = plr.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local head = char and char:FindFirstChild("Head")
				local h = char and char:FindFirstChildOfClass("Humanoid")

				if char and root and head and h and IsAlive(plr, plr.Character) then
					local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
					local color = (Config.States.TeamCheck and IsTeammate(plr)) and Config.Theme.Team or Config.Theme.Accent
					if onScreen then
						local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
						local height = math.abs(headPos.Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
						local width = height / 1.8

						esp.Box.Visible = true; esp.Box.Size = Vector2.new(width, height)
						esp.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2); esp.Box.Color = color

						esp.Name.Visible = true; esp.Name.Text = plr.DisplayName
						esp.Name.Position = Vector2.new(pos.X, esp.Box.Position.Y - 16); esp.Name.Color = color

						if isNanoPlus and esp.HealthBar then
							local curHp = h.Health
							local maxHp = h.MaxHealth
							local hpRatio = math.clamp(curHp / maxHp, 0, 1)
							esp.HealthBar.Visible = true
							esp.HealthBar.Color = Color3.fromRGB(math.floor(255 * (1 - hpRatio)), math.floor(255 * hpRatio), 0)
							esp.HealthBar.From = Vector2.new(esp.Box.Position.X - 5, esp.Box.Position.Y + height)
							esp.HealthBar.To = Vector2.new(esp.Box.Position.X - 5, esp.Box.Position.Y + height - height * hpRatio)
						end

						if isNanoPlus and esp.Distance then
							local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
							local dist = myHrp and math.floor((root.Position - myHrp.Position).Magnitude) or 0
							esp.Distance.Visible = true; esp.Distance.Text = string.format("%dm", dist)
							esp.Distance.Position = Vector2.new(pos.X, esp.Box.Position.Y + height + 2)
							esp.Distance.Color = color
						end

						if isNanoPlus and esp.Tracer and Config.States.Tracers then
							esp.Tracer.Visible = true
							esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
							esp.Tracer.To = Vector2.new(pos.X, pos.Y); esp.Tracer.Color = color
						elseif esp.Tracer then
							esp.Tracer.Visible = false
						end
					else
						esp.Box.Visible = false; esp.Name.Visible = false
						if esp.HealthBar then esp.HealthBar.Visible = false end
						if esp.Distance then esp.Distance.Visible = false end
						if esp.Tracer then esp.Tracer.Visible = false end
					end
				else
					esp.Box.Visible = false; esp.Name.Visible = false
					if esp.HealthBar then esp.HealthBar.Visible = false end
					if esp.Distance then esp.Distance.Visible = false end
					if esp.Tracer then esp.Tracer.Visible = false end
				end
			end
		end
	end))

	-- Heartbeat: Flight with Touch UP/DOWN Buttons
	TrackConn(Services.RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local h = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not h then return end

		if Config.States.Fly then
			h.PlatformStand = true
			local dir = Vector3.zero
			local cf = Camera.CFrame

			-- Touch ▲ Up and ▼ Down handling
			if Storage.FlyUpState then dir = dir + Vector3.new(0, 1, 0) end
			if Storage.FlyDownState then dir = dir - Vector3.new(0, 1, 0) end

			-- Virtual joystick drive: Move along camera perspective
			if h.MoveDirection.Magnitude > 0 then
				dir = dir + (cf.LookVector * h.MoveDirection.Z * -1) + (cf.RightVector * h.MoveDirection.X)
			end

			-- Physical keyboard fallback (if tablet is connected to keyboard)
			if Services.UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
			if Services.UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
			if Services.UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
			if Services.UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end

			hrp.AssemblyLinearVelocity = dir * Config.Vals.FlySpeed
		elseif h.PlatformStand then
			h.PlatformStand = false
		end

		if Config.States.InfJump and h:GetState() == Enum.HumanoidStateType.Freefall then
			h:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end))

	if isFounder then
		Notify("👑 X NANOM+ FOUNDER", "Master Key XT-7789 Verified! 400 FOV & Silent Aim Unlocked.", 4.5)
	elseif isSeller then
		Notify("💎 X NANOM+ PARTNER", "Co-Founder Key Verified! Silent Aim & Uncapped Limits Active.", 4)
	elseif isNanoPlus then
		Notify("📱 X NANOM+ [PRO-X]", "PRO-X Privileges Active! Silent Aim Unlocked.", 4)
	else
		Notify("📱 X NANOM V3.4.1", "Mobile Edition Ready! Tap [⚡] bubble to open menu!", 4)
	end
	print("==========================================")
	print("📱 X NANOM V3.4.1 MOBILE EDITION LOADED!")
	print("💬 DISCORD: " .. Config.Seller.Discord)
	print("==========================================")

	_G.X_NANOM_INSTANCE = {
		Unload = Unload,
		Storage = Storage,
		Config = Config
	}
end

Init()
