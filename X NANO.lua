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

-- [[ X NANO V3.0.0 - ULTRA LIGHTWEIGHT EDITION ]]
-- 定位: 极速启动 / 低配友好 / 核心战斗 / 零卡顿
-- 包含: 平滑自瞄(带FOV) | 极简ESP(Box+Chams) | 极速移动(Fly/Noclip/Speed/Jump) | 干净卸载
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
	pcall(function() targetGui = gethui() end)
end
if not targetGui then
	local canCore = false
	pcall(function()
		local test = Instance.new("ScreenGui")
		test.Name = "_X_TEST_"
		test.Parent = game:GetService("CoreGui")
		test:Destroy()
		canCore = true
	end)
	if canCore then
		targetGui = game:GetService("CoreGui")
	else
		targetGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
	end
end
if not targetGui then
	pcall(function() targetGui = LocalPlayer:WaitForChild("PlayerGui") end)
end
if not targetGui then warn("X NANO: GUI Target failed!") return end

-- ==================================================================
-- CONFIG & STORAGE
-- ==================================================================
local Config = {
	Keys = { Menu = Enum.KeyCode.Insert, Fly = Enum.KeyCode.Z, Noclip = Enum.KeyCode.V, Unload = Enum.KeyCode.End },
	Theme = {
		Main = Color3.fromRGB(12, 12, 16), Sec = Color3.fromRGB(20, 20, 26),
		Accent = Color3.fromRGB(0, 230, 255), Team = Color3.fromRGB(0, 255, 120),
		Text = Color3.fromRGB(240, 240, 240), Dim = Color3.fromRGB(140, 140, 150)
	},
	States = {
		Aimbot = false, TeamCheck = true, ShowFOV = false,
		ESP = false, Chams = false,
		Fly = false, Noclip = false, SpeedHack = false, InfJump = false, NoFall = false
	},
	Vals = {
		FOV = 150, Smoothness = 0.35, WalkSpeed = 80, FlySpeed = 100
	}
}

local Storage = {
	Connections = {}, ESPObjects = {}, ToggleFuncs = {},
	FOVRingUI = nil, MainFrame = nil, OriginalCollisions = {},
	OriginalWalkSpeed = 16
}

local function TrackConn(c)
	if c then table.insert(Storage.Connections, c) end
	return c
end

local function Notify(title, text)
	pcall(function()
		Services.StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 2 })
	end)
end

-- ==================================================================
-- CORE LOGIC (SAFE & ROBUST)
-- ==================================================================
local function IsTeammate(plr)
	if not plr or not LocalPlayer then return false end
	if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return true end
	if plr.TeamColor and LocalPlayer.TeamColor and plr.TeamColor == LocalPlayer.TeamColor then return true end
	return false
end

local function GetClosestTarget()
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local closestDist, target = Config.Vals.FOV, nil

	for _, p in pairs(Services.Players:GetPlayers()) do
		if p == LocalPlayer or not p.Character then continue end
		if Config.States.TeamCheck and IsTeammate(p) then continue end
		local hum = p.Character:FindFirstChildOfClass("Humanoid")
		local head = p.Character:FindFirstChild("Head")
		if not hum or not head or hum.Health <= 0 then continue end

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

local function UpdateChams()
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local chams = p.Character:FindFirstChild("X_Nano_Chams")
			if Config.States.Chams then
				if not chams then
					chams = Instance.new("Highlight")
					chams.Name = "X_Nano_Chams"
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

-- ==================================================================
-- DRAWING ESP & FOV
-- ==================================================================
local function CreateESP(plr)
	if plr == LocalPlayer or Storage.ESPObjects[plr] or not Drawing then return end
	local esp = {
		Box = Drawing.new("Square"),
		Name = Drawing.new("Text")
	}
	esp.Box.Thickness = 1.5
	esp.Box.Filled = false
	esp.Box.Visible = false
	esp.Name.Size = 13
	esp.Name.Center = true
	esp.Name.Outline = true
	esp.Name.Color = Color3.new(1, 1, 1)
	esp.Name.Visible = false
	Storage.ESPObjects[plr] = esp
end

local function RemoveESP(plr)
	if Storage.ESPObjects[plr] then
		pcall(function() Storage.ESPObjects[plr].Box:Remove() end)
		pcall(function() Storage.ESPObjects[plr].Name:Remove() end)
		Storage.ESPObjects[plr] = nil
	end
end

local function CreateFOVRing()
	if targetGui:FindFirstChild("X_NANO_FOV") then targetGui["X_NANO_FOV"]:Destroy() end
	local gui = Instance.new("ScreenGui", targetGui)
	gui.Name = "X_NANO_FOV"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
	
	local ring = Instance.new("Frame", gui)
	ring.AnchorPoint = Vector2.new(0.5, 0.5); ring.Position = UDim2.new(0.5, 0, 0.5, 0)
	ring.Size = UDim2.new(0, Config.Vals.FOV * 2, 0, Config.Vals.FOV * 2)
	ring.BackgroundTransparency = 1; ring.Visible = false
	
	local stroke = Instance.new("UIStroke", ring)
	stroke.Color = Config.Theme.Accent; stroke.Thickness = 1.5; stroke.Transparency = 0.3
	Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
	
	Storage.FOVRingUI = ring
end

-- ==================================================================
-- ULTRA COMPACT CARD UI
-- ==================================================================
local function BuildUI()
	local uiName = "X_NANO_V3_0_0"
	if targetGui:FindFirstChild(uiName) then targetGui[uiName]:Destroy() end

	local ScreenGui = Instance.new("ScreenGui", targetGui)
	ScreenGui.Name = uiName; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true

	local Card = Instance.new("Frame", ScreenGui)
	Card.Size = UDim2.new(0, 260, 0, 440)
	Card.Position = UDim2.new(0.5, -130, 0.5, -220)
	Card.BackgroundColor3 = Config.Theme.Main
	Card.Active = true; Card.Draggable = true
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
	local Stroke = Instance.new("UIStroke", Card)
	Stroke.Color = Config.Theme.Accent; Stroke.Thickness = 1.5; Stroke.Transparency = 0.4
	Storage.MainFrame = Card

	-- Title Bar
	local Bar = Instance.new("Frame", Card)
	Bar.Size = UDim2.new(1, 0, 0, 38); Bar.BackgroundColor3 = Config.Theme.Sec
	Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 8)
	
	local Title = Instance.new("TextLabel", Bar)
	Title.Text = "⚡ X NANO <font color='#8c8c96'>V3.0</font>"; Title.RichText = true
	Title.Size = UDim2.new(1, -40, 1, 0); Title.Position = UDim2.new(0, 12, 0, 0)
	Title.BackgroundTransparency = 1; Title.TextColor3 = Config.Theme.Accent
	Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left

	local Close = Instance.new("TextButton", Bar)
	Close.Size = UDim2.new(0, 28, 0, 28); Close.Position = UDim2.new(1, -32, 0, 5)
	Close.BackgroundColor3 = Color3.fromRGB(35, 35, 42); Close.Text = "×"; Close.TextColor3 = Config.Theme.Dim
	Close.Font = Enum.Font.GothamBold; Close.TextSize = 16; Close.AutoButtonColor = false
	Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)
	Close.MouseButton1Click:Connect(function() Card.Visible = false end)

	-- Scrollable Items
	local Content = Instance.new("ScrollingFrame", Card)
	Content.Size = UDim2.new(1, -16, 1, -50); Content.Position = UDim2.new(0, 8, 0, 44)
	Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 2
	Content.ScrollBarImageColor3 = Config.Theme.Accent
	local Layout = Instance.new("UIListLayout", Content)
	Layout.Padding = UDim.new(0, 6)

	local function AddToggle(text, stateKey, cb)
		local btn = Instance.new("TextButton", Content)
		btn.Size = UDim2.new(1, 0, 0, 32); btn.BackgroundColor3 = Config.Theme.Sec
		btn.Text = ""; btn.AutoButtonColor = false
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
		local s = Instance.new("UIStroke", btn); s.Color = Config.Theme.Accent; s.Transparency = 0.85

		local lbl = Instance.new("TextLabel", btn)
		lbl.Text = text; lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1; lbl.TextColor3 = Config.Theme.Text
		lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

		local ind = Instance.new("Frame", btn)
		ind.Size = UDim2.new(0, 28, 0, 14); ind.Position = UDim2.new(1, -38, 0.5, -7)
		ind.BackgroundColor3 = Color3.fromRGB(40, 40, 48); Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

		local dot = Instance.new("Frame", ind)
		dot.Size = UDim2.new(0, 10, 0, 10); dot.Position = UDim2.new(0, 2, 0.5, -5)
		dot.BackgroundColor3 = Color3.fromRGB(90, 90, 100); Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

		local function SetUI(v)
			Services.TweenService:Create(dot, TweenInfo.new(0.2), {
				Position = v and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
				BackgroundColor3 = v and Config.Theme.Accent or Color3.fromRGB(90, 90, 100)
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
		frame.Size = UDim2.new(1, 0, 0, 40); frame.BackgroundColor3 = Config.Theme.Sec
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

		local lbl = Instance.new("TextLabel", frame)
		lbl.Text = text .. ": " .. tostring(Config.Vals[valKey])
		lbl.Size = UDim2.new(1, -16, 0, 16); lbl.Position = UDim2.new(0, 10, 0, 4)
		lbl.BackgroundTransparency = 1; lbl.TextColor3 = Config.Theme.Text
		lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left

		local bar = Instance.new("TextButton", frame)
		bar.Size = UDim2.new(1, -20, 0, 4); bar.Position = UDim2.new(0, 10, 0, 26)
		bar.BackgroundColor3 = Color3.fromRGB(40, 40, 48); bar.Text = ""; bar.AutoButtonColor = false
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

	-- Add Nano Feature Set
	AddToggle("🎯 Aimbot (Smooth)", "Aimbot")
	AddToggle("⭕ Show FOV", "ShowFOV", function(v) if Storage.FOVRingUI then Storage.FOVRingUI.Visible = v end end)
	AddSlider("FOV Radius", 50, 400, "FOV", function(v)
		if Storage.FOVRingUI then Storage.FOVRingUI.Size = UDim2.new(0, v * 2, 0, v * 2) end
	end)
	AddToggle("🛡️ Team Check", "TeamCheck")
	AddToggle("📦 Box ESP", "ESP", function(v)
        if not v and Drawing then
            for _, esp in pairs(Storage.ESPObjects) do
                if esp.Box then esp.Box.Visible = false end
                if esp.Name then esp.Name.Visible = false end
            end
        end
    end)
	AddToggle("✨ Chams (Glow)", "Chams", function() UpdateChams() end)
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

	Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end

-- ==================================================================
-- UNLOAD & CLEANUP
-- ==================================================================
local function Unload()
	for _, c in pairs(Storage.Connections) do pcall(function() c:Disconnect() end) end
	Storage.Connections = {}
	for _, p in pairs(Services.Players:GetPlayers()) do RemoveESP(p) end
	Config.States.Chams = false; UpdateChams()
	Config.States.Fly = false; Config.States.Noclip = false; UpdateCollisions()

	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = Storage.OriginalWalkSpeed
		hum.PlatformStand = false
	end

	if Storage.MainFrame and Storage.MainFrame.Parent then Storage.MainFrame.Parent:Destroy() end
	if Storage.FOVRingUI and Storage.FOVRingUI.Parent then Storage.FOVRingUI.Parent:Destroy() end
	Notify("X NANO", "Successfully unloaded and cleaned memory.")
end

-- ==================================================================
-- RUNTIME LOOPS
-- ==================================================================
local function Init()
	CreateFOVRing()
	BuildUI()

	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then Storage.OriginalWalkSpeed = hum.WalkSpeed end

	for _, p in pairs(Services.Players:GetPlayers()) do CreateESP(p) end
	TrackConn(Services.Players.PlayerAdded:Connect(CreateESP))
	TrackConn(Services.Players.PlayerRemoving:Connect(RemoveESP))

	-- Character Respawn Handling
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
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		if Config.States.NoFall and hrp.AssemblyLinearVelocity.Y < -35 then
			hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -30, hrp.AssemblyLinearVelocity.Z)
			hum.FallDistance = 0
		end

		if Config.States.Fly or Config.States.Noclip then
			UpdateCollisions()
		end
	end))

	-- RenderStepped: Aimbot & ESP
	TrackConn(Services.RunService.RenderStepped:Connect(function()
		-- Aimbot
		if Config.States.Aimbot then
			local target = GetClosestTarget()
			if target then
				Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, target.Position), Config.Vals.Smoothness)
			end
		end

		-- Box ESP
		if Drawing then
			if Config.States.ESP then
				for plr, esp in pairs(Storage.ESPObjects) do
					local char = plr.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")
					local head = char and char:FindFirstChild("Head")
					local hum = char and char:FindFirstChildOfClass("Humanoid")

					if char and root and head and hum and hum.Health > 0 then
						local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
						local color = (Config.States.TeamCheck and IsTeammate(plr)) and Config.Theme.Team or Config.Theme.Accent
						if onScreen then
							local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
							local height = math.abs(headPos.Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
							local width = height / 1.8

							esp.Box.Visible = true
							esp.Box.Size = Vector2.new(width, height)
							esp.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
							esp.Box.Color = color

							esp.Name.Visible = true
							esp.Name.Text = plr.DisplayName
							esp.Name.Position = Vector2.new(pos.X, esp.Box.Position.Y - 16)
							esp.Name.Color = color
						else
							esp.Box.Visible = false; esp.Name.Visible = false
						end
					else
						esp.Box.Visible = false; esp.Name.Visible = false
					end
				end
			else
				for _, esp in pairs(Storage.ESPObjects) do
					if esp.Box then esp.Box.Visible = false end
					if esp.Name then esp.Name.Visible = false end
				end
			end
		end
	end))

	-- Heartbeat: Movement & Inputs
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
			hrp.AssemblyLinearVelocity = dir * Config.Vals.FlySpeed
		elseif hum.PlatformStand then
			hum.PlatformStand = false
		end

		if Config.States.InfJump and Services.UIS:IsKeyDown(Enum.KeyCode.Space) then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end))

	-- Hotkeys
	TrackConn(Services.UIS.InputBegan:Connect(function(input, gpe)
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
		elseif input.KeyCode == Config.Keys.Unload then
			Unload()
		end
	end))

	Notify("X NANO V3.0", "Loaded! [Insert] Menu [End] Unload")
end

Init()
