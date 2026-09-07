-- [[ X NANO V2.0.1 - PATCH FIXES ]]
-- 修复: 方向Bug | UI同步 | 内存泄漏 | 重生Chams丢失 | 卖家: vlilayz
-- ==================================================================
local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	UIS = game:GetService("UserInputService"),
	Lighting = game:GetService("Lighting"),
	TweenService = game:GetService("TweenService"),
	Workspace = game:GetService("Workspace"),
	StarterGui = game:GetService("StarterGui"),
}
local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
if not game:IsLoaded() then game.Loaded:Wait() end

local targetGui
if type(gethui) == "function" then targetGui = gethui()
else
	local s, c = pcall(function() return game:GetService("CoreGui") end)
	if s and c then targetGui = c else targetGui = LocalPlayer:WaitForChild("PlayerGui") end
end
if not targetGui then warn("X NANO: GUI Target failed!") return end

-- ==================================================================
-- CONFIGURATION & STORAGE
-- ==================================================================
local Config = {
	Keys = { Menu = Enum.KeyCode.Insert, Fly = Enum.KeyCode.Z, Noclip = Enum.KeyCode.V, Unload = Enum.KeyCode.End },
	Theme = {
		Main = Color3.fromRGB(10, 10, 15), Sec = Color3.fromRGB(20, 20, 25),
		Stroke = Color3.fromRGB(0, 255, 255), Team = Color3.fromRGB(0, 255, 100),
		Text = Color3.fromRGB(255, 255, 255), TextDim = Color3.fromRGB(150, 150, 150),
	},
	States = {
		ESP = false, Chams = false, XRay = false, Fullbright = false, Crosshair = false,
		Fly = false, SpeedHack = false, InfJump = false, Noclip = false, NoFall = false,
	},
	Vals = { FlySpeed = 150, WalkSpeed = 150, },
	Seller = { Discord = "vlilayz", Version = "V2.0.1" }
}

local Storage = {
	ESPObjects = {}, CrosshairLines = {}, ToggleFuncs = {}, MainFrame = nil,
	OriginalLighting = {}, Connections = {}, RenderConn = nil, HeartbeatConn = nil, InputConn = nil,
}

-- Helper to track connections for clean unload
local function TrackConn(conn)
	if conn then table.insert(Storage.Connections, conn) end
	return conn
end

-- ==================================================================
-- UTILITIES
-- ==================================================================
local Utils = {}
function Utils.Notify(title, text, dur)
	pcall(function() Services.StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 2}) end)
end

function Utils.IsTeammate(plr)
	if not plr or not LocalPlayer then return false end
	if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return true end
	if plr.TeamColor and LocalPlayer.TeamColor and plr.TeamColor == LocalPlayer.TeamColor then return true end
	return false
end

function Utils.ResetCollision()
	if LocalPlayer.Character then
		for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = true end
		end
	end
end

function Utils.ToggleXRay(state)
	for _, v in pairs(Services.Workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
			if state then
				if v.Transparency < 0.9 then
					if not v:GetAttribute("XR_Orig") then v:SetAttribute("XR_Orig", v.Transparency) end
					v.Transparency = 0.6
				end
			else
				local orig = v:GetAttribute("XR_Orig")
				if orig then v.Transparency = orig; v:SetAttribute("XR_Orig", nil) end
			end
		end
	end
end

function Utils.ToggleFullbright(state)
	if state then
		Storage.OriginalLighting = {
			Ambient = Services.Lighting.Ambient, Brightness = Services.Lighting.Brightness,
			OutdoorAmbient = Services.Lighting.OutdoorAmbient, ClockTime = Services.Lighting.ClockTime,
			FogEnd = Services.Lighting.FogEnd, FogStart = Services.Lighting.FogStart
		}
		Services.Lighting.Ambient = Color3.new(1, 1, 1)
		Services.Lighting.Brightness = 2
		Services.Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
		Services.Lighting.ClockTime = 14
		Services.Lighting.FogEnd = 100000
		Services.Lighting.FogStart = 0
	else
		if next(Storage.OriginalLighting) then
			for k, v in pairs(Storage.OriginalLighting) do Services.Lighting[k] = v end
		end
	end
end

function Utils.UpdateChams()
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local highlight = p.Character:FindFirstChild("X_Nano_Chams")
			if Config.States.Chams then
				if not highlight then
					highlight = Instance.new("Highlight", p.Character)
					highlight.Name = "X_Nano_Chams"
					highlight.FillTransparency = 0.5
					highlight.OutlineTransparency = 0
				end
				highlight.FillColor = Utils.IsTeammate(p) and Config.Theme.Team or Config.Theme.Stroke
				highlight.OutlineColor = highlight.FillColor
			else
				if highlight then highlight:Destroy() end
			end
		end
	end
end

function Utils.RemoveAllChams()
	for _, p in pairs(Services.Players:GetPlayers()) do
		if p.Character then
			local highlight = p.Character:FindFirstChild("X_Nano_Chams")
			if highlight then highlight:Destroy() end
		end
	end
end

-- ==================================================================
-- FEATURES & ESP
-- ==================================================================
local Features = {}
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
end

function Features.RemoveESP(plr)
	if Storage.ESPObjects[plr] then
		for _, d in pairs(Storage.ESPObjects[plr]) do pcall(function() d:Remove() end) end
		Storage.ESPObjects[plr] = nil
	end
end

function Features.RemoveAllESP()
	for plr, esp in pairs(Storage.ESPObjects) do
		for _, d in pairs(esp) do pcall(function() d:Remove() end) end
	end
	Storage.ESPObjects = {}
end

-- ==================================================================
-- UI SYSTEM
-- ==================================================================
local UI = {}
function UI.Init()
	local guiName = "X_NANO_V2.0"
	if targetGui:FindFirstChild(guiName) then targetGui[guiName]:Destroy() end
	
	local ScreenGui = Instance.new("ScreenGui", targetGui)
	ScreenGui.Name = guiName; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true; ScreenGui.DisplayOrder = 999999999
	TrackConn(ScreenGui.Destroying:Connect(function() Storage.MainFrame = nil end))

	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 420, 0, 520); Main.Position = UDim2.new(0.5, -210, 0.5, -260)
	Main.BackgroundColor3 = Config.Theme.Main; Main.Active = true; Main.Draggable = true
	Storage.MainFrame = Main

	local UIStroke = Instance.new("UIStroke", Main); UIStroke.Color = Config.Theme.Stroke; UIStroke.Thickness = 2
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

	local Title = Instance.new("TextLabel", Main)
	Title.Text = "X NANO " .. Config.Seller.Version; Title.Size = UDim2.new(1, 0, 0, 40)
	Title.BackgroundTransparency = 1; Title.TextColor3 = Config.Theme.Stroke; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 18

	local ContentFrame = Instance.new("ScrollingFrame", Main)
	ContentFrame.Size = UDim2.new(1, -20, 1, -80); ContentFrame.Position = UDim2.new(0, 10, 0, 45)
	ContentFrame.BackgroundTransparency = 1; ContentFrame.ScrollBarThickness = 4; ContentFrame.ScrollBarImageColor3 = Config.Theme.Stroke

	local List = Instance.new("UIListLayout", ContentFrame); List.Padding = UDim.new(0, 6)
	TrackConn(List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() 
		ContentFrame.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y) 
	end))

	local Footer = Instance.new("TextLabel", Main)
	Footer.Size = UDim2.new(1, -20, 0, 25); Footer.Position = UDim2.new(0, 10, 1, -30)
	Footer.BackgroundTransparency = 1; Footer.Text = "Licensed Premium | Seller: " .. Config.Seller.Discord
	Footer.TextColor3 = Config.Theme.TextDim; Footer.Font = Enum.Font.GothamBold; Footer.TextSize = 12

	local function AddSectionHeader(text)
		local Label = Instance.new("TextLabel", ContentFrame)
		Label.Size = UDim2.new(1, -5, 0, 25); Label.BackgroundTransparency = 1; Label.Text = text
		Label.TextColor3 = Config.Theme.Stroke; Label.Font = Enum.Font.GothamBlack; Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left
	end

	local function AddToggle(text, flag)
		local Btn = Instance.new("TextButton", ContentFrame)
		Btn.Size = UDim2.new(1, -5, 0, 40); Btn.BackgroundColor3 = Config.Theme.Sec; Btn.Text = ""; Btn.AutoButtonColor = false
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
		local Stroke = Instance.new("UIStroke", Btn); Stroke.Color = Config.Theme.Stroke; Stroke.Transparency = 0.8

		local Label = Instance.new("TextLabel", Btn)
		Label.Text = text; Label.Size = UDim2.new(0.7, 0, 1, 0); Label.Position = UDim2.new(0, 15, 0, 0)
		Label.BackgroundTransparency = 1; Label.TextColor3 = Config.Theme.Text; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 13; Label.TextXAlignment = Enum.TextXAlignment.Left

		local Indicator = Instance.new("Frame", Btn)
		Indicator.Size = UDim2.new(0, 36, 0, 18); Indicator.Position = UDim2.new(1, -48, 0.5, -9)
		Indicator.BackgroundColor3 = Color3.fromRGB(60,60,70); Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

		local Dot = Instance.new("Frame", Indicator)
		Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = UDim2.new(0, 2, 0.5, -7)
		Dot.BackgroundColor3 = Color3.fromRGB(120,120,130); Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

		local function Update(val)
			local c = val and Config.Theme.Stroke or Color3.fromRGB(120,120,130)
			local p = val and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
			Services.TweenService:Create(Dot, TweenInfo.new(0.25), {Position = p, BackgroundColor3 = c}):Play()
			Services.TweenService:Create(Stroke, TweenInfo.new(0.25), {Transparency = val and 0.2 or 0.8}):Play()
			
			if flag == "XRay" then Utils.ToggleXRay(val) end
			if flag == "Fullbright" then Utils.ToggleFullbright(val) end
			if flag == "Noclip" and not val then Utils.ResetCollision() end
			if flag == "Chams" then Utils.UpdateChams() end
		end
		
		Storage.ToggleFuncs[flag] = Update
		Update(Config.States[flag])
		TrackConn(Btn.MouseButton1Click:Connect(function() 
			Config.States[flag] = not Config.States[flag]
			Update(Config.States[flag]) 
		end))
	end

	local function AddSlider(text, min, max, def, cb)
		local Frame = Instance.new("Frame", ContentFrame)
		Frame.Size = UDim2.new(1, -5, 0, 50); Frame.BackgroundColor3 = Config.Theme.Sec
		Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

		local Label = Instance.new("TextLabel", Frame)
		Label.Text = text .. ": " .. def; Label.Size = UDim2.new(1, -20, 0, 20); Label.Position = UDim2.new(0, 10, 0, 5)
		Label.BackgroundTransparency = 1; Label.TextColor3 = Config.Theme.Text; Label.Font = Enum.Font.GothamBold; Label.TextSize = 12

		local SlideBar = Instance.new("TextButton", Frame)
		SlideBar.Size = UDim2.new(1, -20, 0, 6); SlideBar.Position = UDim2.new(0, 10, 0, 32)
		SlideBar.BackgroundColor3 = Color3.fromRGB(60,60,70); SlideBar.Text = ""
		Instance.new("UICorner", SlideBar).CornerRadius = UDim.new(0, 3)

		local Fill = Instance.new("Frame", SlideBar)
		Fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Config.Theme.Stroke
		Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

		local drag = false
		TrackConn(SlideBar.MouseButton1Down:Connect(function() drag = true end))
		TrackConn(Services.UIS.InputEnded:Connect(function(i) 
			if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end 
		end))
		TrackConn(Services.UIS.InputChanged:Connect(function(i)
			if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
				local p = math.clamp((i.Position.X - SlideBar.AbsolutePosition.X) / SlideBar.AbsoluteSize.X, 0, 1)
				Fill.Size = UDim2.new(p, 0, 1, 0)
				local v = math.floor(min + (max - min) * p)
				Label.Text = text .. ": " .. v
				cb(v)
			end
		end))
	end

	AddSectionHeader("️ VISUAL")
	AddToggle("ESP Master (Box+Name+HP)", "ESP")
	AddToggle("Chams (Highlight Glow)", "Chams")
	AddToggle("X-Ray (Wallhack)", "XRay")
	AddToggle("Fullbright (Night Vision)", "Fullbright")
	AddToggle("Crosshair", "Crosshair")

	AddSectionHeader(" MOVEMENT (STEALTH V4.2)")
	AddToggle("Fly Mode [Z] (Anti-Reset)", "Fly")
	AddSlider("Fly Speed", 10, 500, 150, function(v) Config.Vals.FlySpeed = v end)
	AddToggle("Speed Hack (Undetectable)", "SpeedHack")
	AddSlider("Walk Speed", 16, 500, 150, function(v) Config.Vals.WalkSpeed = v end)
	AddToggle("Noclip [V]", "Noclip")
	AddToggle("Infinite Jump", "InfJump")
	AddToggle("No Fall Damage", "NoFall")

	AddSectionHeader("⚙️ SYSTEM")
	local UnloadBtn = Instance.new("TextButton", ContentFrame)
	UnloadBtn.Size = UDim2.new(1, -5, 0, 45); UnloadBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
	UnloadBtn.Text = "🗑️ UNLOAD SCRIPT (End)"; UnloadBtn.TextColor3 = Color3.new(1,1,1); UnloadBtn.Font = Enum.Font.GothamBlack; UnloadBtn.TextSize = 14
	Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)
	TrackConn(UnloadBtn.MouseButton1Click:Connect(function() Runtime.Unload() end))
end

-- ==================================================================
-- RUNTIME (COMPLETE UNLOAD FIX V2)
-- ==================================================================
local Runtime = {}
function Runtime.Unload()
	Utils.Notify("🗑️ 卸载中", "正在清理 X NANO V2.0.1...")
	
	-- 1. Disconnect ALL tracked connections
	if Storage.RenderConn then Storage.RenderConn:Disconnect() end
	if Storage.HeartbeatConn then Storage.HeartbeatConn:Disconnect() end
	if Storage.InputConn then Storage.InputConn:Disconnect() end
	for _, conn in pairs(Storage.Connections) do pcall(function() conn:Disconnect() end) end
	Storage.Connections = {}

	-- 2. Reset states
	for k, _ in pairs(Config.States) do Config.States[k] = false end

	-- 3. Cleanup features
	pcall(function() Utils.ToggleXRay(false) end)
	pcall(function() Utils.ToggleFullbright(false) end)
	pcall(function() Utils.ResetCollision() end)
	pcall(function() Utils.RemoveAllChams() end)
	Features.RemoveAllESP()

	-- 4. Cleanup Crosshair
	for _, l in pairs(Storage.CrosshairLines) do pcall(function() l:Remove() end) end
	Storage.CrosshairLines = {}

	-- 5. Destroy GUIs
	for _, gui in pairs(targetGui:GetChildren()) do
		if string.find(gui.Name, "X_NANO") then gui:Destroy() end
	end
	pcall(function()
		for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
			if string.find(gui.Name, "X_NANO") then gui:Destroy() end
		end
		for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
			if string.find(gui.Name, "X_NANO") then gui:Destroy() end
		end
	end)

	print("✅ X NANO V2.0.1 COMPLETELY UNLOADED")
	task.spawn(function() task.wait(0.5); getgenv().X_NANO_V2_LOADED = nil end)
end

function Runtime.Init()
	-- Init Crosshair
	if Drawing then
		Storage.CrosshairLines.H = Drawing.new("Line"); Storage.CrosshairLines.H.Thickness = 1.5; Storage.CrosshairLines.H.Color = Config.Theme.Stroke; Storage.CrosshairLines.H.Visible = false
		Storage.CrosshairLines.V = Drawing.new("Line"); Storage.CrosshairLines.V.Thickness = 1.5; Storage.CrosshairLines.V.Color = Config.Theme.Stroke; Storage.CrosshairLines.V.Visible = false
	end

	-- Init ESP & Chams Listeners
	local function OnCharacterAdded(plr)
		TrackConn(plr.CharacterAdded:Connect(function()
			task.wait(0.1)
			if Config.States.Chams and plr ~= LocalPlayer then Utils.UpdateChams() end
		end))
	end

	for _, p in pairs(Services.Players:GetPlayers()) do 
		pcall(function() Features.CreateESP(p) end)
		OnCharacterAdded(p)
	end
	TrackConn(Services.Players.PlayerAdded:Connect(function(p) 
		pcall(function() Features.CreateESP(p) end)
		OnCharacterAdded(p)
	end))
	TrackConn(Services.Players.PlayerRemoving:Connect(function(p) 
		pcall(function() Features.RemoveESP(p) end) 
	end))

	-- Init UI
	UI.Init()

	-- RenderStepped (ESP & Crosshair)
	Storage.RenderConn = Services.RunService.RenderStepped:Connect(function()
		local CurrentCam = Services.Workspace.CurrentCamera
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		for plr, esp in pairs(Storage.ESPObjects) do
			esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false; esp.Distance.Visible = false
			if Config.States.ESP then
				local pChar = plr.Character
				local root = pChar and pChar:FindFirstChild("HumanoidRootPart")
				local head = pChar and pChar:FindFirstChild("Head")
				local hum = pChar and pChar:FindFirstChild("Humanoid")
				if pChar and root and head and hum and hum.Health > 0 then
					local vector, onScreen = CurrentCam:WorldToViewportPoint(root.Position)
					local drawColor = Utils.IsTeammate(plr) and Config.Theme.Team or Config.Theme.Stroke
					if onScreen then
						local headPos = CurrentCam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
						local height = math.abs(headPos.Y - CurrentCam:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
						local width = height / 1.8
						local boxX = vector.X - width/2; local boxY = vector.Y - height/2
						
						esp.Box.Visible = true; esp.Box.Size = Vector2.new(width, height); esp.Box.Position = Vector2.new(boxX, boxY); esp.Box.Color = drawColor
						esp.Name.Visible = true; esp.Name.Text = plr.Name; esp.Name.Position = Vector2.new(vector.X, boxY - 18); esp.Name.Color = drawColor
						
						esp.HealthBar.Visible = true
						local healthRatio = hum.Health / hum.MaxHealth
						esp.HealthBar.Color = Color3.new(1 - healthRatio, healthRatio, 0)
						esp.HealthBar.From = Vector2.new(boxX - 5, boxY + height)
						esp.HealthBar.To = Vector2.new(boxX - 5, boxY + height - height * healthRatio)
						
						if hrp then
							esp.Distance.Visible = true
							esp.Distance.Text = string.format("%.0fm", (root.Position - hrp.Position).Magnitude)
							esp.Distance.Position = Vector2.new(vector.X, boxY + height + 5); esp.Distance.Color = drawColor
						end
					end
				end
			end
		end

		if Config.States.Crosshair and Drawing then 
			local c = Vector2.new(CurrentCam.ViewportSize.X/2, CurrentCam.ViewportSize.Y/2)
			Storage.CrosshairLines.H.Visible = true; Storage.CrosshairLines.H.From = Vector2.new(c.X-10, c.Y); Storage.CrosshairLines.H.To = Vector2.new(c.X+10, c.Y)
			Storage.CrosshairLines.V.Visible = true; Storage.CrosshairLines.V.From = Vector2.new(c.X, c.Y-10); Storage.CrosshairLines.V.To = Vector2.new(c.X, c.Y+10)
		elseif Drawing then 
			Storage.CrosshairLines.H.Visible = false; Storage.CrosshairLines.V.Visible = false 
		end
	end)

	-- Heartbeat (Movement)
	Storage.HeartbeatConn = Services.RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		if not hrp or not hum then return end

		if Config.States.NoFall then
			if hrp.AssemblyLinearVelocity.Y < -30 then 
				hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -30, hrp.AssemblyLinearVelocity.Z) 
			end
		end

		if Config.States.Noclip then
			for _, v in pairs(char:GetDescendants()) do 
				if v:IsA("BasePart") then v.CanCollide = false end 
			end
		end

		-- Fly (FIXED: RelativeTo = World)
		if Config.States.Fly then
			local lv = hrp:FindFirstChild("X_Nano_Fly_LV")
			if not lv then
				lv = Instance.new("LinearVelocity"); lv.Name = "X_Nano_Fly_LV"
				local att = hrp:FindFirstChild("RootAttachment") or hrp:FindFirstChildOfClass("Attachment")
				if not att then att = Instance.new("Attachment", hrp) end
				lv.Attachment0 = att; lv.MaxForce = math.huge
				lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
				lv.RelativeTo = Enum.ActuatorRelativeTo.World -- FIX DIRECTION BUG
				lv.Parent = hrp
			end
			local dir = Vector3.zero; local cf = Camera.CFrame
			if Services.UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
			if Services.UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
			if Services.UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
			if Services.UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
			if Services.UIS:IsKeyDown(Enum.KeyCode.E) or Services.UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
			if Services.UIS:IsKeyDown(Enum.KeyCode.Q) or Services.UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end
			lv.VectorVelocity = dir.Magnitude > 0 and dir.Unit * Config.Vals.FlySpeed or Vector3.zero
			if hum:GetState() ~= Enum.HumanoidStateType.Physics then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end
			for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
		else
			local lv = hrp:FindFirstChild("X_Nano_Fly_LV")
			if lv then lv:Destroy() end
			if hum:GetState() == Enum.HumanoidStateType.Physics then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end) end
		end

		-- Speed (FIXED: RelativeTo = World)
		if Config.States.SpeedHack then
			local safeSpeed = math.min(Config.Vals.WalkSpeed, 32)
			hum.WalkSpeed = safeSpeed
			local lv = hrp:FindFirstChild("X_Nano_Speed_LV")
			if not lv then
				lv = Instance.new("LinearVelocity"); lv.Name = "X_Nano_Speed_LV"
				local att = hrp:FindFirstChild("RootAttachment") or hrp:FindFirstChildOfClass("Attachment")
				if not att then att = Instance.new("Attachment", hrp) end
				lv.Attachment0 = att; lv.MaxForce = 5000
				lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
				lv.RelativeTo = Enum.ActuatorRelativeTo.World -- FIX DIRECTION BUG
				lv.Parent = hrp
			end
			local moveDir = hum.MoveDirection
			if moveDir.Magnitude > 0.1 then
				local extraSpeed = Config.Vals.WalkSpeed - safeSpeed
				lv.LineVelocity = extraSpeed > 0 and extraSpeed or 0
				lv.LineDirection = moveDir
			else
				lv.LineVelocity = 0
			end
		else
			hum.WalkSpeed = 16
			local lv = hrp:FindFirstChild("X_Nano_Speed_LV")
			if lv then lv:Destroy() end
		end

		-- InfJump
		if Config.States.InfJump and Services.UIS:IsKeyDown(Enum.KeyCode.Space) then 
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
			hum.Jump = true 
		end
	end)

	-- Input (FIXED: UI Sync)
	Storage.InputConn = Services.UIS.InputBegan:Connect(function(i, g)
		if g then return end
		if i.KeyCode == Config.Keys.Menu and Storage.MainFrame then 
			Storage.MainFrame.Visible = not Storage.MainFrame.Visible 
		end
		if i.KeyCode == Config.Keys.Unload then Runtime.Unload(); return end
		
		if i.KeyCode == Config.Keys.Fly then 
			Config.States.Fly = not Config.States.Fly
			if Storage.ToggleFuncs["Fly"] then Storage.ToggleFuncs["Fly"](Config.States.Fly) end -- SYNC UI
		end
		if i.KeyCode == Config.Keys.Noclip then 
			Config.States.Noclip = not Config.States.Noclip
			if Storage.ToggleFuncs["Noclip"] then Storage.ToggleFuncs["Noclip"](Config.States.Noclip) end -- SYNC UI
			if not Config.States.Noclip then Utils.ResetCollision() end 
		end
	end)
end

-- ==================================================================
-- INITIALIZATION
-- ==================================================================
Runtime.Init()
Utils.Notify("✅ X NANO " .. Config.Seller.Version, "Loaded! Press INSERT")
print("X NANO " .. Config.Seller.Version .. " LOADED | Seller: " .. Config.Seller.Discord)
