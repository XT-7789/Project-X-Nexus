-- [[ X LITEM V1.1.0 - FREE DELTA MOBILE EDITION ]]
-- Platform: Exclusively Engineered & Optimized for DELTA EXECUTOR (iOS & Android)
-- UI & Controls: Draggable Bubble [🪶] | Touch Fly [▲/▼ Controls] | Noclip | SpeedHack | InfJump | NoFall | Fullbright
-- Official Discord: https://discord.gg/mQ3ASbfP8j | Seller: vlilayz | Dev: XT-7789
-- ==================================================================
local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	UIS = game:GetService("UserInputService"),
	Workspace = game:GetService("Workspace"),
	StarterGui = game:GetService("StarterGui"),
	TweenService = game:GetService("TweenService"),
	Lighting = game:GetService("Lighting")
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
if not targetGui then warn("[X LITEM DELTA]: GUI Target failed!") return end

-- ==================================================================
-- CONFIGURATION & STORAGE
-- ==================================================================
local Config = {
	Theme = {
		Main = Color3.fromRGB(12, 14, 20),
		Sec = Color3.fromRGB(20, 24, 34),
		Accent = Color3.fromRGB(0, 230, 255),
		Text = Color3.fromRGB(245, 245, 252),
		Dim = Color3.fromRGB(140, 148, 165),
		Gold = Color3.fromRGB(255, 205, 50),
		Red = Color3.fromRGB(255, 70, 70),
		Green = Color3.fromRGB(70, 230, 130)
	},
	States = {
		Fly = false,
		Noclip = false,
		SpeedHack = false,
		InfJump = false,
		NoFall = false,
		Fullbright = false
	},
	Vals = {
		FlySpeed = 100,
		WalkSpeed = 80
	},
	Links = {
		Discord = "https://discord.gg/mQ3ASbfP8j",
		Seller = "vlilayz",
		Founder = "XT-7789",
		Version = "V1.1.0 Delta Edition"
	}
}

local Storage = {
	Connections = {},
	ToggleFuncs = {},
	MainFrame = nil,
	MenuBubble = nil,
	FlyControlGui = nil,
	FlyUpState = false,
	FlyDownState = false,
	OriginalLighting = {},
	OriginalCollisions = {},
	OriginalWalkSpeed = 16
}

local function TrackConn(c)
	if c then table.insert(Storage.Connections, c) end
	return c
end

local function Notify(title, text, dur)
	pcall(function()
		Services.StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = dur or 3
		})
	end)
end

-- ==================================================================
-- MOVEMENT & ENVIRONMENT ENGINE
-- ==================================================================
local function UpdateCollisions()
	local char = LocalPlayer.Character
	if not char then return end
	local shouldNoclip = Config.States.Fly or Config.States.Noclip
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

local function ToggleFullbright(enable)
	if enable then
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
-- UNLOAD SYSTEM (CLEAN TOUCH DISCONNECT)
-- ==================================================================
local function Unload()
	for _, c in pairs(Storage.Connections) do
		pcall(function() c:Disconnect() end)
	end
	Storage.Connections = {}

	Config.States.Fullbright = false
	ToggleFullbright(false)

	Config.States.Fly = false
	Config.States.Noclip = false
	UpdateCollisions()

	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = Storage.OriginalWalkSpeed
		hum.PlatformStand = false
	end

	if Storage.MainFrame and Storage.MainFrame.Parent then
		Storage.MainFrame.Parent:Destroy()
	end
	if Storage.MenuBubble and Storage.MenuBubble.Parent then
		Storage.MenuBubble.Parent:Destroy()
	end
	if Storage.FlyControlGui and Storage.FlyControlGui.Parent then
		Storage.FlyControlGui.Parent:Destroy()
	end

	Notify("🪶 X LITEM", "Successfully unloaded!")
end

-- ==================================================================
-- MOBILE TOUCH UI FOR DELTA EXECUTOR
-- ==================================================================
local function BuildMobileUI()
	local uiName = "X_LITEM_DELTA_V11"
	if targetGui:FindFirstChild(uiName) then targetGui[uiName]:Destroy() end

	local ScreenGui = Instance.new("ScreenGui", targetGui)
	ScreenGui.Name = uiName
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.DisplayOrder = 999999

	-- 1. 📱 常驻拖拽触控球 (Delta Optimized Floating Bubble)
	local Bubble = Instance.new("TextButton", ScreenGui)
	Bubble.Size = UDim2.new(0, 52, 0, 52)
	Bubble.Position = UDim2.new(0, 20, 0.35, 0)
	Bubble.BackgroundColor3 = Config.Theme.Main
	Bubble.BackgroundTransparency = 0.15
	Bubble.Text = "🪶"
	Bubble.TextColor3 = Config.Theme.Accent
	Bubble.TextSize = 24
	Bubble.Active = true
	Bubble.Draggable = true
	Bubble.AutoButtonColor = false
	Instance.new("UICorner", Bubble).CornerRadius = UDim.new(1, 0)

	local bStroke = Instance.new("UIStroke", Bubble)
	bStroke.Color = Config.Theme.Accent
	bStroke.Thickness = 2.2
	bStroke.Transparency = 0.25
	Storage.MenuBubble = Bubble

	-- 2. 📱 触控大屏面板
	local Card = Instance.new("Frame", ScreenGui)
	Card.Size = UDim2.new(0, 300, 0, 510)
	Card.Position = UDim2.new(0.5, -150, 0.5, -255)
	Card.BackgroundColor3 = Config.Theme.Main
	Card.Active = true
	Card.Draggable = true
	Card.Visible = false
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)

	local cStroke = Instance.new("UIStroke", Card)
	cStroke.Color = Config.Theme.Accent
	cStroke.Thickness = 1.8
	cStroke.Transparency = 0.35
	Storage.MainFrame = Card

	-- 点击悬浮球切换菜单
	Bubble.MouseButton1Click:Connect(function()
		Card.Visible = not Card.Visible
		Bubble.Text = Card.Visible and "×" or "🪶"
		Bubble.TextColor3 = Card.Visible and Config.Theme.Red or Config.Theme.Accent
	end)

	-- Header
	local Header = Instance.new("Frame", Card)
	Header.Size = UDim2.new(1, 0, 0, 48)
	Header.BackgroundColor3 = Config.Theme.Sec
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

	local Title = Instance.new("TextLabel", Header)
	Title.Text = "🪶 X LITEM <font color='#00e6ff'>DELTA</font> <font color='#ffcd32'>FREE</font>"
	Title.RichText = true
	Title.Size = UDim2.new(1, -50, 0, 26)
	Title.Position = UDim2.new(0, 14, 0, 3)
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Config.Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 13
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local Subtitle = Instance.new("TextLabel", Header)
	Subtitle.Text = "⚡ Delta Mobile Exclusive | V1.1.0"
	Subtitle.Size = UDim2.new(1, -50, 0, 16)
	Subtitle.Position = UDim2.new(0, 14, 0, 26)
	Subtitle.BackgroundTransparency = 1
	Subtitle.TextColor3 = Config.Theme.Dim
	Subtitle.Font = Enum.Font.GothamMedium
	Subtitle.TextSize = 10
	Subtitle.TextXAlignment = Enum.TextXAlignment.Left

	local CloseBtn = Instance.new("TextButton", Header)
	CloseBtn.Size = UDim2.new(0, 34, 0, 34)
	CloseBtn.Position = UDim2.new(1, -40, 0, 7)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(36, 40, 52)
	CloseBtn.Text = "×"
	CloseBtn.TextColor3 = Config.Theme.Dim
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 18
	CloseBtn.AutoButtonColor = false
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
	CloseBtn.MouseButton1Click:Connect(function()
		Card.Visible = false
		Bubble.Text = "🪶"
		Bubble.TextColor3 = Config.Theme.Accent
	end)

	-- Scrollable Items
	local Content = Instance.new("ScrollingFrame", Card)
	Content.Size = UDim2.new(1, -16, 1, -60)
	Content.Position = UDim2.new(0, 8, 0, 54)
	Content.BackgroundTransparency = 1
	Content.ScrollBarThickness = 3
	Content.ScrollBarImageColor3 = Config.Theme.Accent
	local Layout = Instance.new("UIListLayout", Content)
	Layout.Padding = UDim.new(0, 7)

	local function AddToggle(text, stateKey, cb)
		local btn = Instance.new("TextButton", Content)
		btn.Size = UDim2.new(1, -4, 0, 42)
		btn.BackgroundColor3 = Config.Theme.Sec
		btn.Text = ""
		btn.AutoButtonColor = false
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
		local s = Instance.new("UIStroke", btn)
		s.Color = Config.Theme.Accent
		s.Transparency = 0.85

		local lbl = Instance.new("TextLabel", btn)
		lbl.Text = text
		lbl.Size = UDim2.new(0.7, 0, 1, 0)
		lbl.Position = UDim2.new(0, 12, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Config.Theme.Text
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left

		local ind = Instance.new("Frame", btn)
		ind.Size = UDim2.new(0, 38, 0, 22)
		ind.Position = UDim2.new(1, -48, 0.5, -11)
		ind.BackgroundColor3 = Color3.fromRGB(38, 42, 54)
		Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

		local dot = Instance.new("Frame", ind)
		dot.Size = UDim2.new(0, 18, 0, 18)
		dot.Position = UDim2.new(0, 2, 0.5, -9)
		dot.BackgroundColor3 = Color3.fromRGB(90, 95, 110)
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

		local function SetUI(v)
			Services.TweenService:Create(dot, TweenInfo.new(0.2), {
				Position = v and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
				BackgroundColor3 = v and Config.Theme.Accent or Color3.fromRGB(90, 95, 110)
			}):Play()
			Services.TweenService:Create(s, TweenInfo.new(0.2), {
				Transparency = v and 0.4 or 0.85
			}):Play()
			if cb then cb(v) end
		end

		Storage.ToggleFuncs[stateKey] = function(v)
			Config.States[stateKey] = v
			SetUI(v)
		end

		btn.MouseButton1Click:Connect(function()
			Config.States[stateKey] = not Config.States[stateKey]
			SetUI(Config.States[stateKey])
		end)
	end

	local function AddSlider(text, min, max, valKey, cb)
		local frame = Instance.new("Frame", Content)
		frame.Size = UDim2.new(1, -4, 0, 50)
		frame.BackgroundColor3 = Config.Theme.Sec
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 7)

		local lbl = Instance.new("TextLabel", frame)
		lbl.Text = text .. ": " .. tostring(Config.Vals[valKey])
		lbl.Size = UDim2.new(1, -20, 0, 18)
		lbl.Position = UDim2.new(0, 12, 0, 5)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Config.Theme.Text
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left

		local bar = Instance.new("TextButton", frame)
		bar.Size = UDim2.new(1, -24, 0, 8)
		bar.Position = UDim2.new(0, 12, 0, 30)
		bar.BackgroundColor3 = Color3.fromRGB(38, 42, 54)
		bar.Text = ""
		bar.AutoButtonColor = false
		Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

		local fill = Instance.new("Frame", bar)
		fill.Size = UDim2.new((Config.Vals[valKey] - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = Config.Theme.Accent
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

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
				dragging = true
				updateTouch(i.Position.X)
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

	-- 3. 📱 飞行触控虚拟控件 (▲ 升空 / ▼ 下降)
	local FlyControlGui = Instance.new("Frame", ScreenGui)
	FlyControlGui.Size = UDim2.new(0, 70, 0, 150)
	FlyControlGui.Position = UDim2.new(1, -85, 0.5, -75)
	FlyControlGui.BackgroundTransparency = 1
	FlyControlGui.Visible = false

	local UpBtn = Instance.new("TextButton", FlyControlGui)
	UpBtn.Size = UDim2.new(0, 65, 0, 65)
	UpBtn.Position = UDim2.new(0, 0, 0, 0)
	UpBtn.BackgroundColor3 = Config.Theme.Main
	UpBtn.BackgroundTransparency = 0.2
	UpBtn.Text = "▲"
	UpBtn.TextColor3 = Config.Theme.Accent
	UpBtn.Font = Enum.Font.GothamBlack
	UpBtn.TextSize = 28
	UpBtn.AutoButtonColor = false
	Instance.new("UICorner", UpBtn).CornerRadius = UDim.new(1, 0)
	local uStroke = Instance.new("UIStroke", UpBtn)
	uStroke.Color = Config.Theme.Accent
	uStroke.Thickness = 2

	local DownBtn = Instance.new("TextButton", FlyControlGui)
	DownBtn.Size = UDim2.new(0, 65, 0, 65)
	DownBtn.Position = UDim2.new(0, 0, 0, 80)
	DownBtn.BackgroundColor3 = Config.Theme.Main
	DownBtn.BackgroundTransparency = 0.2
	DownBtn.Text = "▼"
	DownBtn.TextColor3 = Config.Theme.Accent
	DownBtn.Font = Enum.Font.GothamBlack
	DownBtn.TextSize = 28
	DownBtn.AutoButtonColor = false
	Instance.new("UICorner", DownBtn).CornerRadius = UDim.new(1, 0)
	local dStroke = Instance.new("UIStroke", DownBtn)
	dStroke.Color = Config.Theme.Accent
	dStroke.Thickness = 2

	UpBtn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			Storage.FlyUpState = true
			Services.TweenService:Create(UpBtn, TweenInfo.new(0.1), {
				BackgroundColor3 = Config.Theme.Accent,
				TextColor3 = Config.Theme.Main
			}):Play()
		end
	end)
	UpBtn.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			Storage.FlyUpState = false
			Services.TweenService:Create(UpBtn, TweenInfo.new(0.1), {
				BackgroundColor3 = Config.Theme.Main,
				TextColor3 = Config.Theme.Accent
			}):Play()
		end
	end)

	DownBtn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			Storage.FlyDownState = true
			Services.TweenService:Create(DownBtn, TweenInfo.new(0.1), {
				BackgroundColor3 = Config.Theme.Accent,
				TextColor3 = Config.Theme.Main
			}):Play()
		end
	end)
	DownBtn.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			Storage.FlyDownState = false
			Services.TweenService:Create(DownBtn, TweenInfo.new(0.1), {
				BackgroundColor3 = Config.Theme.Main,
				TextColor3 = Config.Theme.Accent
			}):Play()
		end
	end)

	Storage.FlyControlGui = FlyControlGui

	-- Add Movement Toggles
	AddToggle("🦅 Touch Fly (▲▼ Controls)", "Fly", function(v)
		UpdateCollisions()
		if Storage.FlyControlGui then Storage.FlyControlGui.Visible = v end
	end)
	AddSlider("Fly Speed", 20, 250, "FlySpeed")
	AddToggle("👻 Noclip (Walk Walls)", "Noclip", function() UpdateCollisions() end)
	AddToggle("⚡ Speed Hack", "SpeedHack", function(v)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v and Config.Vals.WalkSpeed or Storage.OriginalWalkSpeed end
	end)
	AddSlider("Walk Speed", 20, 200, "WalkSpeed", function(v)
		if Config.States.SpeedHack and LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = v end
		end
	end)
	AddToggle("🦘 Infinite Jump", "InfJump")
	AddToggle("🪂 No Fall Damage", "NoFall")
	AddToggle("💡 Fullbright Nightvision", "Fullbright", function(v) ToggleFullbright(v) end)

	-- 4. 🌟 UPGRADE PROMO BANNER (引导付费转化 + 官方 DISCORD 一键复制)
	local PromoBox = Instance.new("Frame", Content)
	PromoBox.Size = UDim2.new(1, -4, 0, 110)
	PromoBox.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
	Instance.new("UICorner", PromoBox).CornerRadius = UDim.new(0, 8)
	local pStroke = Instance.new("UIStroke", PromoBox)
	pStroke.Color = Config.Theme.Gold
	pStroke.Thickness = 1.3
	pStroke.Transparency = 0.35

	local PromoTitle = Instance.new("TextLabel", PromoBox)
	PromoTitle.Size = UDim2.new(1, -16, 0, 20)
	PromoTitle.Position = UDim2.new(0, 10, 0, 6)
	PromoTitle.BackgroundTransparency = 1
	PromoTitle.Text = "👑 UNLOCK AIMBOT & FULL ESP"
	PromoTitle.TextColor3 = Config.Theme.Gold
	PromoTitle.Font = Enum.Font.GothamBold
	PromoTitle.TextSize = 12
	PromoTitle.TextXAlignment = Enum.TextXAlignment.Left

	local PromoDesc = Instance.new("TextLabel", PromoBox)
	PromoDesc.Size = UDim2.new(1, -16, 0, 16)
	PromoDesc.Position = UDim2.new(0, 10, 0, 26)
	PromoDesc.BackgroundTransparency = 1
	PromoDesc.Text = "Nano (RM5) | Mini (RM10) | Pro (RM20) | Titan"
	PromoDesc.TextColor3 = Config.Theme.Dim
	PromoDesc.Font = Enum.Font.GothamMedium
	PromoDesc.TextSize = 11
	PromoDesc.TextXAlignment = Enum.TextXAlignment.Left

	local CopyDiscordBtn = Instance.new("TextButton", PromoBox)
	CopyDiscordBtn.Size = UDim2.new(1, -20, 0, 28)
	CopyDiscordBtn.Position = UDim2.new(0, 10, 0, 46)
	CopyDiscordBtn.BackgroundColor3 = Color3.fromRGB(30, 42, 65)
	CopyDiscordBtn.Text = "🌐 Copy Official Discord Server"
	CopyDiscordBtn.TextColor3 = Config.Theme.Accent
	CopyDiscordBtn.Font = Enum.Font.GothamBold
	CopyDiscordBtn.TextSize = 11
	CopyDiscordBtn.AutoButtonColor = false
	Instance.new("UICorner", CopyDiscordBtn).CornerRadius = UDim.new(0, 6)
	local dStroke1 = Instance.new("UIStroke", CopyDiscordBtn)
	dStroke1.Color = Config.Theme.Accent
	dStroke1.Transparency = 0.5

	CopyDiscordBtn.MouseButton1Click:Connect(function()
		pcall(function()
			if setclipboard then
				setclipboard(Config.Links.Discord)
				Notify("📋 COPIED", "Official Discord copied! (" .. Config.Links.Discord .. ")")
			else
				Notify("💬 DISCORD", Config.Links.Discord)
			end
		end)
	end)

	local CopySellerBtn = Instance.new("TextButton", PromoBox)
	CopySellerBtn.Size = UDim2.new(1, -20, 0, 24)
	CopySellerBtn.Position = UDim2.new(0, 10, 0, 78)
	CopySellerBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
	CopySellerBtn.Text = "💬 Copy Seller Discord: " .. Config.Links.Seller
	CopySellerBtn.TextColor3 = Config.Theme.Dim
	CopySellerBtn.Font = Enum.Font.GothamMedium
	CopySellerBtn.TextSize = 10
	CopySellerBtn.AutoButtonColor = false
	Instance.new("UICorner", CopySellerBtn).CornerRadius = UDim.new(0, 6)

	CopySellerBtn.MouseButton1Click:Connect(function()
		pcall(function()
			if setclipboard then
				setclipboard(Config.Links.Seller)
				Notify("📋 COPIED", "Seller Discord copied! (" .. Config.Links.Seller .. ")")
			else
				Notify("💬 SELLER", Config.Links.Seller)
			end
		end)
	end)

	-- 5. 🛑 触控一键安全卸载按钮
	local UnloadBtn = Instance.new("TextButton", Content)
	UnloadBtn.Size = UDim2.new(1, -4, 0, 42)
	UnloadBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 25)
	UnloadBtn.Text = "🛑 UNLOAD SCRIPT"
	UnloadBtn.TextColor3 = Config.Theme.Red
	UnloadBtn.Font = Enum.Font.GothamBold
	UnloadBtn.TextSize = 13
	UnloadBtn.AutoButtonColor = false
	Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 7)
	local uStroke2 = Instance.new("UIStroke", UnloadBtn)
	uStroke2.Color = Config.Theme.Red
	uStroke2.Transparency = 0.5
	UnloadBtn.MouseButton1Click:Connect(function() Unload() end)

	Content.CanvasSize = UDim2.new(0, 0, 0, 560)
end

-- ==================================================================
-- RUNTIME LOOPS
-- ==================================================================
local function Init()
	BuildMobileUI()

	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then Storage.OriginalWalkSpeed = hum.WalkSpeed end

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

		if Config.States.Fly or Config.States.Noclip then
			UpdateCollisions()
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

			-- 触控 ▲ 升空 与 ▼ 下降
			if Storage.FlyUpState then dir = dir + Vector3.new(0, 1, 0) end
			if Storage.FlyDownState then dir = dir - Vector3.new(0, 1, 0) end

			-- 移动端触控虚拟摇杆驱动：沿镜头方向移动
			if h.MoveDirection.Magnitude > 0 then
				dir = dir + (cf.LookVector * h.MoveDirection.Z * -1) + (cf.RightVector * h.MoveDirection.X)
			end

			-- 键盘兜底（平板外接键盘）
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

	Notify("📱 X LITEM DELTA", "Free Edition Loaded! Tap [🪶] to open menu | Join: " .. Config.Links.Discord)
	print("==========================================")
	print("📱 X LITEM V1.1.0 DELTA MOBILE FREE EDITION LOADED!")
	print("👑 FOUNDER & DEV : " .. Config.Links.Founder)
	print("🌐 DISCORD SERVER: " .. Config.Links.Discord)
	print("💬 SELLER DISCORD: " .. Config.Links.Seller)
	print("==========================================")
end

Init()
