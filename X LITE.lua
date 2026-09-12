-- [[ X LITE V1.0.0 - FREE STARTER EDITION ]]
-- 定位: 免费引流 / 纯净机动 / 零封禁风险 / 全平台秒注入
-- 包含: Fly 自由飞行 [Z] | Noclip 穿墙 [V] | SpeedHack 加速 | InfJump 无限跳 | NoFall 防跌落
-- 兼容: Delta (Mobile) | Xeno | Solara (PC)
-- 升级: 欲解锁自瞄(Aimbot)与透视(ESP)，请升级 Nano (RM5) / Mini (RM10) / Pro (RM20)
-- 卖家: vlilayz
-- ==================================================================
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
	targetGui = gethui()
else
	local s, c = pcall(function() return game:GetService("CoreGui") end)
	if s and c then targetGui = c else targetGui = LocalPlayer:WaitForChild("PlayerGui") end
end
if not targetGui then warn("X LITE: GUI Target failed!") return end

-- ==================================================================
-- CONFIG & STORAGE
-- ==================================================================
local Config = {
	Keys = { Menu = Enum.KeyCode.Insert, Fly = Enum.KeyCode.Z, Noclip = Enum.KeyCode.V, Unload = Enum.KeyCode.End },
	Theme = {
		Main = Color3.fromRGB(12, 14, 18), Sec = Color3.fromRGB(20, 22, 28),
		Accent = Color3.fromRGB(0, 230, 255), Text = Color3.fromRGB(240, 240, 245),
		Dim = Color3.fromRGB(130, 135, 145), Gold = Color3.fromRGB(255, 205, 50)
	},
	States = {
		Fly = false, Noclip = false, SpeedHack = false, InfJump = false, NoFall = false
	},
	Vals = {
		FlySpeed = 100, WalkSpeed = 80
	},
	Seller = {
		Discord = "vlilayz",
		Version = "V1.0.0 Free"
	}
}

local Storage = {
	Connections = {}, ToggleFuncs = {}, MainFrame = nil,
	OriginalCollisions = {}, OriginalWalkSpeed = 16
}

local function TrackConn(c)
	if c then table.insert(Storage.Connections, c) end
	return c
end

local function Notify(title, text, dur)
	pcall(function()
		Services.StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = dur or 2.5 })
	end)
end

-- ==================================================================
-- MOVEMENT ENGINE
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

-- ==================================================================
-- ULTRA-CLEAN FLOATING CARD UI
-- ==================================================================
local function BuildUI()
	local uiName = "X_LITE_FREE_V1"
	if targetGui:FindFirstChild(uiName) then targetGui[uiName]:Destroy() end

	local ScreenGui = Instance.new("ScreenGui", targetGui)
	ScreenGui.Name = uiName; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true

	local Card = Instance.new("Frame", ScreenGui)
	Card.Size = UDim2.new(0, 250, 0, 390)
	Card.Position = UDim2.new(0.5, -125, 0.5, -195)
	Card.BackgroundColor3 = Config.Theme.Main
	Card.Active = true; Card.Draggable = true
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
	local Stroke = Instance.new("UIStroke", Card)
	Stroke.Color = Config.Theme.Accent; Stroke.Thickness = 1.5; Stroke.Transparency = 0.4
	Storage.MainFrame = Card

	-- Title Bar
	local Bar = Instance.new("Frame", Card)
	Bar.Size = UDim2.new(1, 0, 0, 36); Bar.BackgroundColor3 = Config.Theme.Sec
	Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 8)

	local Title = Instance.new("TextLabel", Bar)
	Title.Text = "🎁 X LITE <font color='#ffcd32'>FREE</font>"; Title.RichText = true
	Title.Size = UDim2.new(1, -40, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0)
	Title.BackgroundTransparency = 1; Title.TextColor3 = Config.Theme.Accent
	Title.Font = Enum.Font.GothamBold; Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left

	local Close = Instance.new("TextButton", Bar)
	Close.Size = UDim2.new(0, 26, 0, 26); Close.Position = UDim2.new(1, -30, 0, 5)
	Close.BackgroundColor3 = Color3.fromRGB(35, 38, 48); Close.Text = "×"; Close.TextColor3 = Config.Theme.Dim
	Close.Font = Enum.Font.GothamBold; Close.TextSize = 15; Close.AutoButtonColor = false
	Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 5)
	Close.MouseButton1Click:Connect(function() Card.Visible = false end)

	-- Scrollable Items
	local Content = Instance.new("ScrollingFrame", Card)
	Content.Size = UDim2.new(1, -16, 1, -115); Content.Position = UDim2.new(0, 8, 0, 42)
	Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 2
	Content.ScrollBarImageColor3 = Config.Theme.Accent
	local Layout = Instance.new("UIListLayout", Content); Layout.Padding = UDim.new(0, 5)

	local function AddToggle(text, stateKey, cb)
		local btn = Instance.new("TextButton", Content)
		btn.Size = UDim2.new(1, -4, 0, 32); btn.BackgroundColor3 = Config.Theme.Sec
		btn.Text = ""; btn.AutoButtonColor = false
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
		local s = Instance.new("UIStroke", btn); s.Color = Config.Theme.Accent; s.Transparency = 0.85

		local lbl = Instance.new("TextLabel", btn)
		lbl.Text = text; lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1; lbl.TextColor3 = Config.Theme.Text
		lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left

		local ind = Instance.new("Frame", btn)
		ind.Size = UDim2.new(0, 28, 0, 14); ind.Position = UDim2.new(1, -36, 0.5, -7)
		ind.BackgroundColor3 = Color3.fromRGB(40, 42, 50); Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

		local dot = Instance.new("Frame", ind)
		dot.Size = UDim2.new(0, 10, 0, 10); dot.Position = UDim2.new(0, 2, 0.5, -5)
		dot.BackgroundColor3 = Color3.fromRGB(90, 95, 105); Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

		local function SetUI(v)
			Services.TweenService:Create(dot, TweenInfo.new(0.2), {
				Position = v and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
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

	local function AddSlider(text, min, max, valKey, cb)
		local frame = Instance.new("Frame", Content)
		frame.Size = UDim2.new(1, -4, 0, 38); frame.BackgroundColor3 = Config.Theme.Sec
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

		local lbl = Instance.new("TextLabel", frame)
		lbl.Text = text .. ": " .. tostring(Config.Vals[valKey])
		lbl.Size = UDim2.new(1, -16, 0, 15); lbl.Position = UDim2.new(0, 10, 0, 3)
		lbl.BackgroundTransparency = 1; lbl.TextColor3 = Config.Theme.Text
		lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left

		local bar = Instance.new("TextButton", frame)
		bar.Size = UDim2.new(1, -20, 0, 4); bar.Position = UDim2.new(0, 10, 0, 24)
		bar.BackgroundColor3 = Color3.fromRGB(40, 42, 50); bar.Text = ""; bar.AutoButtonColor = false
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

	AddToggle("🦅 Fly Mode [Z]", "Fly", function() UpdateCollisions() end)
	AddSlider("Fly Speed", 20, 300, "FlySpeed")
	AddToggle("👻 Noclip [V]", "Noclip", function() UpdateCollisions() end)
	AddToggle("⚡ Speed Hack", "SpeedHack", function(v)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v and Config.Vals.WalkSpeed or Storage.OriginalWalkSpeed end
	end)
	AddSlider("Walk Speed", 20, 250, "WalkSpeed", function(v)
		if Config.States.SpeedHack and LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = v end
		end
	end)
	AddToggle("🦘 Infinite Jump", "InfJump")
	AddToggle("🪂 No Fall Damage", "NoFall")

	Content.CanvasSize = UDim2.new(0, 0, 0, 240)

	-- Promo / Upgrade Box at Bottom
	local Promo = Instance.new("Frame", Card)
	Promo.Size = UDim2.new(1, -16, 0, 64); Promo.Position = UDim2.new(0, 8, 1, -70)
	Promo.BackgroundColor3 = Config.Theme.Sec
	Instance.new("UICorner", Promo).CornerRadius = UDim.new(0, 6)
	local pStroke = Instance.new("UIStroke", Promo); pStroke.Color = Config.Theme.Gold; pStroke.Transparency = 0.6

	local pTitle = Instance.new("TextLabel", Promo)
	pTitle.Text = "⭐ 欲解锁 自瞄(Aimbot) 与 透视(ESP)?"; pTitle.Size = UDim2.new(1, 0, 0, 18); pTitle.Position = UDim2.new(0, 0, 0, 4)
	pTitle.BackgroundTransparency = 1; pTitle.TextColor3 = Config.Theme.Gold; pTitle.Font = Enum.Font.GothamBold; pTitle.TextSize = 10

	local pDesc = Instance.new("TextLabel", Promo)
	pDesc.Text = "Nano RM5 | Mini RM10 | Pro RM20\n💬 联系 Discord: " .. Config.Seller.Discord; pDesc.Size = UDim2.new(1, 0, 0, 36); pDesc.Position = UDim2.new(0, 0, 0, 22)
	pDesc.BackgroundTransparency = 1; pDesc.TextColor3 = Config.Theme.Text; pDesc.Font = Enum.Font.GothamMedium; pDesc.TextSize = 9
end

-- ==================================================================
-- UNLOAD
-- ==================================================================
local function Unload()
	for _, c in pairs(Storage.Connections) do pcall(function() c:Disconnect() end) end
	Storage.Connections = {}
	Config.States.Fly = false; Config.States.Noclip = false; UpdateCollisions()

	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = Storage.OriginalWalkSpeed
		hum.PlatformStand = false
	end

	if Storage.MainFrame and Storage.MainFrame.Parent then Storage.MainFrame.Parent:Destroy() end
	Notify("X LITE", "已完全卸载并清理内存。")
end

-- ==================================================================
-- RUNTIME
-- ==================================================================
local function Init()
	BuildUI()

	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then Storage.OriginalWalkSpeed = hum.WalkSpeed end

	TrackConn(LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		local newHum = char:WaitForChild("Humanoid", 3)
		if newHum then Storage.OriginalWalkSpeed = newHum.WalkSpeed end
		if Config.States.SpeedHack and newHum then newHum.WalkSpeed = Config.Vals.WalkSpeed end
		UpdateCollisions()
	end))

	-- Physics / Stepped
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

	-- Heartbeat
	TrackConn(Services.RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local h = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not h then return end

		if Config.States.Fly then
			h.PlatformStand = true
			local dir = Vector3.zero
			local cf = Camera.CFrame
			if Services.UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
			if Services.UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
			if Services.UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
			if Services.UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
			if Services.UIS:IsKeyDown(Enum.KeyCode.Space) or Services.UIS:IsKeyDown(Enum.KeyCode.E) then dir = dir + Vector3.new(0, 1, 0) end
			if Services.UIS:IsKeyDown(Enum.KeyCode.LeftShift) or Services.UIS:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Vector3.new(0, 1, 0) end
			hrp.AssemblyLinearVelocity = dir * Config.Vals.FlySpeed
		elseif h.PlatformStand then
			h.PlatformStand = false
		end

		if Config.States.InfJump and Services.UIS:IsKeyDown(Enum.KeyCode.Space) then
			h:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end))

	-- Hotkeys
	TrackConn(Services.UIS.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Config.Keys.Menu then
			if Storage.MainFrame then Storage.MainFrame.Visible = not Storage.MainFrame.Visible end
		elseif input.KeyCode == Config.Keys.Fly then
			if Storage.ToggleFuncs["Fly"] then Storage.ToggleFuncs["Fly"](not Config.States.Fly) end
		elseif input.KeyCode == Config.Keys.Noclip then
			if Storage.ToggleFuncs["Noclip"] then Storage.ToggleFuncs["Noclip"](not Config.States.Noclip) end
		elseif input.KeyCode == Config.Keys.Unload then
			Unload()
		end
	end))

	Notify("X LITE FREE", "免费版已启动！[Insert] 菜单 [End] 卸载\n升配请联系: " .. Config.Seller.Discord, 4)
	print("==========================================")
	print("🎁 X LITE V1.0.0 FREE EDITION LOADED!")
	print("🔥 UPGRADE TO NANO (RM5) / MINI (RM10) / PRO (RM20)")
	print("💬 DISCORD: " .. Config.Seller.Discord)
	print("==========================================")
end

Init()
