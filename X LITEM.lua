-- [[ X LITEM V1.0.0 - FREE MOBILE TOUCH EDITION ]]
-- Positioning: Free Lead Magnet / Mobile & Tablet Delta Optimized / Zero Keyboard Needed
-- Features: Floating Bubble [🪶] | Touch Fly [▲/▼ Controls] | Noclip | SpeedHack | InfJump | NoFall | Fullbright
-- Compatibility: Delta (Mobile iOS/Android) | Arceus X | Codex | Fluxus
-- Upgrade: Unlock Aimbot & ESP -> Nano (RM5) / Mini (RM10) / Pro (RM20)
-- Founder & Dev: XT-7789 | Seller Discord: vlilayz
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
	targetGui = gethui()
else
	local s, c = pcall(function() return game:GetService("CoreGui") end)
	if s and c then targetGui = c else targetGui = LocalPlayer:WaitForChild("PlayerGui") end
end
if not targetGui then warn("X LITEM: GUI Target failed!") return end

-- ==================================================================
-- CONFIGURATION & STORAGE
-- ==================================================================
local Config = {
	Theme = {
		Main = Color3.fromRGB(12, 14, 18),
		Sec = Color3.fromRGB(22, 24, 32),
		Accent = Color3.fromRGB(0, 230, 255),
		Text = Color3.fromRGB(245, 245, 250),
		Dim = Color3.fromRGB(140, 145, 160),
		Gold = Color3.fromRGB(255, 205, 50),
		Red = Color3.fromRGB(255, 65, 65)
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
	Seller = {
		Discord = "vlilayz",
		Founder = "XT-7789",
		Version = "V1.0.0 Mobile Free"
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
			Duration = dur or 2.5
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
-- MOBILE TOUCH UI & VIRTUAL CONTROLS
-- ==================================================================
local function BuildMobileUI()
	local uiName = "X_LITEM_FREE_V1"
	if targetGui:FindFirstChild(uiName) then targetGui[uiName]:Destroy() end

	local ScreenGui = Instance.new("ScreenGui", targetGui)
	ScreenGui.Name = uiName
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.DisplayOrder = 999999

	-- 1. 📱 屏幕常驻悬浮触控球 (Draggable Bubble)
	local Bubble = Instance.new("TextButton", ScreenGui)
	Bubble.Size = UDim2.new(0, 52, 0, 52)
	Bubble.Position = UDim2.new(0, 20, 0.35, 0)
	Bubble.BackgroundColor3 = Config.Theme.Main
	Bubble.BackgroundTransparency = 0.2
	Bubble.Text = "🪶"
	Bubble.TextColor3 = Config.Theme.Accent
	Bubble.TextSize = 24
	Bubble.Active = true
	Bubble.Draggable = true
	Bubble.AutoButtonColor = false
	Instance.new("UICorner", Bubble).CornerRadius = UDim.new(1, 0)

	local bStroke = Instance.new("UIStroke", Bubble)
	bStroke.Color = Config.Theme.Accent
	bStroke.Thickness = 2
	bStroke.Transparency = 0.3
	Storage.MenuBubble = Bubble

	-- 2. 📱 触控大屏菜单面板 (适合手机平板大拇指操作)
	local Card = Instance.new("Frame", ScreenGui)
	Card.Size = UDim2.new(0, 290, 0, 480)
	Card.Position = UDim2.new(0.5, -145, 0.5, -240)
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

	-- 点击悬浮球切换菜单显示
	Bubble.MouseButton1Click:Connect(function()
		Card.Visible = not Card.Visible
		Bubble.Text = Card.Visible and "×" or "🪶"
	end)

	-- Header
	local Header = Instance.new("Frame", Card)
	Header.Size = UDim2.new(1, 0, 0, 44)
	Header.BackgroundColor3 = Config.Theme.Sec
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

	local Title = Instance.new("TextLabel", Header)
	Title.Text = "🪶 X LITEM <font color='#00e6ff'>MOBILE</font> <font color='#ffcd32'>FREE</font>"
	Title.RichText = true
	Title.Size = UDim2.new(1, -44, 1, 0)
	Title.Position = UDim2.new(0, 12, 0, 0)
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Config.Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 13
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local CloseBtn = Instance.new("TextButton", Header)
	CloseBtn.Size = UDim2.new(0, 32, 0, 32)
	CloseBtn.Position = UDim2.new(1, -36, 0, 6)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
	CloseBtn.Text = "×"
	CloseBtn.TextColor3 = Config.Theme.Dim
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 18
	CloseBtn.AutoButtonColor = false
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
	CloseBtn.MouseButton1Click:Connect(function()
		Card.Visible = false
		Bubble.Text = "🪶"
	end)

	-- Scrollable Items (手指触控优化)
	local Content = Instance.new("ScrollingFrame", Card)
	Content.Size = UDim2.new(1, -16, 1, -54)
	Content.Position = UDim2.new(0, 8, 0, 48)
	Content.BackgroundTransparency = 1
	Content.ScrollBarThickness = 3
	Content.ScrollBarImageColor3 = Config.Theme.Accent
	local Layout = Instance.new("UIListLayout", Content)
	Layout.Padding = UDim.new(0, 7)

	local function AddToggle(text, stateKey, cb)
		local btn = Instance.new("TextButton", Content)
		btn.Size = UDim2.new(1, -4, 0, 40)
		btn.BackgroundColor3 = Config.Theme.Sec
		btn.Text = ""
		btn.AutoButtonColor = false
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
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
		ind.Size = UDim2.new(0, 36, 0, 20)
		ind.Position = UDim2.new(1, -46, 0.5, -10)
		ind.BackgroundColor3 = Color3.fromRGB(40, 42, 52)
		Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

		local dot = Instance.new("Frame", ind)
		dot.Size = UDim2.new(0, 16, 0, 16)
		dot.Position = UDim2.new(0, 2, 0.5, -8)
		dot.BackgroundColor3 = Color3.fromRGB(90, 95, 105)
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

		local function SetUI(v)
			Services.TweenService:Create(dot, TweenInfo.new(0.2), {
				Position = v and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
				BackgroundColor3 = v and Config.Theme.Accent or Color3.fromRGB(90, 95, 105)
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

	-- 触控大滑块 (支持手指拖拽与点击)
	local function AddSlider(text, min, max, valKey, cb)
		local frame = Instance.new("Frame", Content)
		frame.Size = UDim2.new(1, -4, 0, 48)
		frame.BackgroundColor3 = Config.Theme.Sec
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

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
		bar.Position = UDim2.new(0, 12, 0, 28)
		bar.BackgroundColor3 = Color3.fromRGB(40, 42, 52)
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

	-- 3. 📱 屏幕右侧飞行虚拟触控按键 (▲ 升空 / ▼ 下降)
	local FlyControlGui = Instance.new("Frame", ScreenGui)
	FlyControlGui.Size = UDim2.new(0, 70, 0, 150)
	FlyControlGui.Position = UDim2.new(1, -85, 0.5, -75)
	FlyControlGui.BackgroundTransparency = 1
	FlyControlGui.Visible = false

	local UpBtn = Instance.new("TextButton", FlyControlGui)
	UpBtn.Size = UDim2.new(0, 65, 0, 65)
	UpBtn.Position = UDim2.new(0, 0, 0, 0)
	UpBtn.BackgroundColor3 = Config.Theme.Main
	UpBtn.BackgroundTransparency = 0.25
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
	DownBtn.BackgroundTransparency = 0.25
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

	-- Add Movement Items
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

	-- 4. 🌟 UPGRADE PROMO BANNER (引导付费转化)
	local PromoBox = Instance.new("Frame", Content)
	PromoBox.Size = UDim2.new(1, -4, 0, 78)
	PromoBox.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
	Instance.new("UICorner", PromoBox).CornerRadius = UDim.new(0, 6)
	local pStroke = Instance.new("UIStroke", PromoBox)
	pStroke.Color = Config.Theme.Gold
	pStroke.Thickness = 1.2
	pStroke.Transparency = 0.4

	local PromoTitle = Instance.new("TextLabel", PromoBox)
	PromoTitle.Size = UDim2.new(1, -16, 0, 20)
	PromoTitle.Position = UDim2.new(0, 8, 0, 6)
	PromoTitle.BackgroundTransparency = 1
	PromoTitle.Text = "👑 UNLOCK AIMBOT & FULL ESP"
	PromoTitle.TextColor3 = Config.Theme.Gold
	PromoTitle.Font = Enum.Font.GothamBold
	PromoTitle.TextSize = 11
	PromoTitle.TextXAlignment = Enum.TextXAlignment.Left

	local PromoDesc = Instance.new("TextLabel", PromoBox)
	PromoDesc.Size = UDim2.new(1, -16, 0, 16)
	PromoDesc.Position = UDim2.new(0, 8, 0, 26)
	PromoDesc.BackgroundTransparency = 1
	PromoDesc.Text = "Nano (RM5) | Mini (RM10) | Pro (RM20)"
	PromoDesc.TextColor3 = Config.Theme.Dim
	PromoDesc.Font = Enum.Font.GothamMedium
	PromoDesc.TextSize = 11
	PromoDesc.TextXAlignment = Enum.TextXAlignment.Left

	local CopyDiscordBtn = Instance.new("TextButton", PromoBox)
	CopyDiscordBtn.Size = UDim2.new(1, -16, 0, 24)
	CopyDiscordBtn.Position = UDim2.new(0, 8, 0, 46)
	CopyDiscordBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 50)
	CopyDiscordBtn.Text = "📋 Copy Seller Discord: vlilayz"
	CopyDiscordBtn.TextColor3 = Config.Theme.Text
	CopyDiscordBtn.Font = Enum.Font.GothamBold
	CopyDiscordBtn.TextSize = 10
	CopyDiscordBtn.AutoButtonColor = false
	Instance.new("UICorner", CopyDiscordBtn).CornerRadius = UDim.new(0, 4)
	CopyDiscordBtn.MouseButton1Click:Connect(function()
		pcall(function()
			if setclipboard then
				setclipboard("vlilayz")
				Notify("📋 COPIED", "Seller Discord (vlilayz) copied to clipboard!")
			else
				Notify("💬 DISCORD", "Add Seller on Discord: vlilayz")
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
	Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)
	local uStroke2 = Instance.new("UIStroke", UnloadBtn)
	uStroke2.Color = Config.Theme.Red
	uStroke2.Transparency = 0.5
	UnloadBtn.MouseButton1Click:Connect(function() Unload() end)

	Content.CanvasSize = UDim2.new(0, 0, 0, 520)
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

	Notify("🪶 X LITEM", "Mobile Free Edition Loaded! Tap [🪶] bubble to open menu!")
	print("==========================================")
	print("📱 X LITEM V1.0.0 MOBILE FREE EDITION LOADED!")
	print("👑 FOUNDER & DEV : " .. Config.Seller.Founder)
	print("💬 DISCORD SELLER: " .. Config.Seller.Discord)
	print("==========================================")
end

Init()
