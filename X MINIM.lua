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

-- [[ X MINIM V4.0.0 - MOBILE COMBAT SUITE ]]
-- Official Seller: vlilayz | Tier: MINIM (RM 10)
-- Optimized for Delta Mobile / Android / iOS / Tablet
-- 100% Zero Keyboard Required | Touch-Friendly UI | Floating Bubble
-- Features: Touch Auto-Aim | Head Expander | TriggerBot | Box+Health ESP | Chams | Touch Fly with Virtual Buttons | Noclip | SpeedHack
-- ==================================================================
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UIS = game:GetService("UserInputService"),
    Lighting = game:GetService("Lighting"),
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
if not targetGui then warn("X MINIM: GUI Target failed!") return end

-- ==================================================================
-- CONFIGURATION & STORAGE
-- ==================================================================
local Config = {
    Theme = {
        Main = Color3.fromRGB(12, 14, 22), Sec = Color3.fromRGB(20, 22, 34),
        Accent = Color3.fromRGB(0, 210, 255), Team = Color3.fromRGB(0, 255, 120),
        Text = Color3.fromRGB(245, 245, 250), Dim = Color3.fromRGB(140, 145, 160),
        Red = Color3.fromRGB(255, 70, 70), Warn = Color3.fromRGB(255, 190, 40)
    },
    States = {
        Aimbot = false, TeamCheck = true, WallCheck = false,
        ShowFOV = false, HeadExpander = false, TriggerBot = false,
        ESP = false, Chams = false, Fullbright = false, Crosshair = false,
        Fly = false, Noclip = false, SpeedHack = false,
        InfJump = false, NoFall = false, ItemESP = false, SilentAim = false
    },
    Vals = {
        FOV = 180, Smoothness = 0.32, WalkSpeed = 80, FlySpeed = 120,
        HeadSize = 15, TriggerDelay = 0.15
    }
}

local Storage = {
    Connections = {}, ESPObjects = {}, CrosshairLines = {}, ToggleFuncs = {},
    FOVRingUI = nil, MainFrame = nil, MenuBubble = nil,
    FlyUpBtn = nil, FlyDownBtn = nil, FlyUpState = false, FlyDownState = false,
    OriginalLighting = {}, OriginalCollisions = {}, OriginalWalkSpeed = 16,
    TriggerCooldown = 0, HeadBackup = {}, ItemESPObjects = {}
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
-- UTILITIES & CHECKS
-- ==================================================================
local Utils = {}

function Utils.IsTeammate(plr)
    if not plr or not LocalPlayer then return false end
    if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return true end
    if plr.TeamColor and LocalPlayer.TeamColor and plr.TeamColor == LocalPlayer.TeamColor then return true end
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

function Utils.GetClosestTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestDist, target = Config.Vals.FOV, nil

    for _, p in pairs(Services.Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        local head = p.Character:FindFirstChild("Head")
        if not hum or not head or hum.Health <= 0 then continue end

        if Config.States.WallCheck and not Utils.IsVisible(head) then continue end

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

function Utils.UpdateHeadExpander()
    for _, p in pairs(Services.Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                if Config.States.HeadExpander and not (Config.States.TeamCheck and Utils.IsTeammate(p)) then
                    if not Storage.HeadBackup[head] then
                        Storage.HeadBackup[head] = { Size = head.Size, Transparency = head.Transparency, CanCollide = head.CanCollide }
                    end
                    head.Size = Vector3.new(Config.Vals.HeadSize, Config.Vals.HeadSize, Config.Vals.HeadSize)
                    head.Transparency = 0.5
                    head.CanCollide = false
                elseif Storage.HeadBackup[head] then
                    local bk = Storage.HeadBackup[head]
                    head.Size = bk.Size
                    head.Transparency = bk.Transparency
                    head.CanCollide = bk.CanCollide
                    Storage.HeadBackup[head] = nil
                end
            end
        end
    end
end

function Utils.UpdateCollisions()
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
            local chams = p.Character:FindFirstChild("X_Minim_Chams")
            if Config.States.Chams then
                if not chams then
                    chams = Instance.new("Highlight")
                    chams.Name = "X_Minim_Chams"
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
-- MOBILE TOUCH UI & FLOATING BUBBLE
-- ==================================================================
local activeKey = tostring(getgenv().Key or getgenv().ScriptKey or script_key or "")
local isMiniPlus = string.find(string.upper(activeKey), "X%-MINI%-PRO%-X") ~= nil

-- ==================================================================
-- MULTI-LAYER SILENT AIM ENGINE (EXCLUSIVE TO X-MINI-PRO-X)
-- ==================================================================
local HasMiniMetamethodHook = false

if isMiniPlus then
    if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
        local safeUnpack = table.unpack or unpack
        local ok, oldNamecall = pcall(function()
            return hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}

                if Config.States.SilentAim and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "FindPartOnRayWithWhitelist") then
                    local targetPart = Utils.GetClosestTarget()
                    if targetPart and targetPart.Parent then
                        local predPos = targetPart.Position
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
        if ok and oldNamecall then HasMiniMetamethodHook = true end
    end
end

local function BuildMobileUI()
    local uiName = "X_MINIM_V4_0_0"
    if targetGui:FindFirstChild(uiName) then targetGui[uiName]:Destroy() end

    local ScreenGui = Instance.new("ScreenGui", targetGui)
    ScreenGui.Name = uiName; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true

    -- Floating Draggable Bubble [⚡]
    local Bubble = Instance.new("TextButton", ScreenGui)
    Bubble.Size = UDim2.new(0, 48, 0, 48); Bubble.Position = UDim2.new(0, 18, 0.4, 0)
    Bubble.BackgroundColor3 = Config.Theme.Main; Bubble.Text = "⚡"; Bubble.TextColor3 = Config.Theme.Accent
    Bubble.Font = Enum.Font.GothamBold; Bubble.TextSize = 22; Bubble.Active = true; Bubble.Draggable = true
    Instance.new("UICorner", Bubble).CornerRadius = UDim.new(1, 0)
    local bubbleStroke = Instance.new("UIStroke", Bubble)
    bubbleStroke.Color = Config.Theme.Accent; bubbleStroke.Thickness = 2
    Storage.MenuBubble = Bubble

    -- Main UI Frame
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 480, 0, 340); Main.Position = UDim2.new(0.5, -240, 0.5, -170)
    Main.BackgroundColor3 = Config.Theme.Main; Main.Active = true; Main.Draggable = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Config.Theme.Accent; MainStroke.Thickness = 1.5; MainStroke.Transparency = 0.3
    Storage.MainFrame = Main

    Bubble.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)

    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 42); Header.BackgroundColor3 = Config.Theme.Sec
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel", Header)
    Title.Text = "📱 X MINIM <font color='#00d2ff'>V4.0.0</font> <font color='#8c91a0'>| MOBILE SUITE</font>"; Title.RichText = true
    Title.Size = UDim2.new(0, 240, 1, 0); Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1; Title.TextColor3 = Config.Theme.Text
    Title.Font = Enum.Font.GothamBold; Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50); CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Config.Theme.Text; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

    -- Tab Bar
    local TabBar = Instance.new("Frame", Header)
    TabBar.Size = UDim2.new(0, 180, 0, 26); TabBar.Position = UDim2.new(1, -226, 0.5, -13)
    TabBar.BackgroundTransparency = 1
    local TabList = Instance.new("UIListLayout", TabBar); TabList.FillDirection = Enum.FillDirection.Horizontal; TabList.Padding = UDim.new(0, 6)

    local Pages = {}
    local TabButtons = {}

    local function CreateTab(name)
        local page = Instance.new("ScrollingFrame", Main)
        page.Size = UDim2.new(1, -20, 1, -56); page.Position = UDim2.new(0, 10, 0, 48)
        page.BackgroundTransparency = 1; page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Config.Theme.Accent; page.Visible = false
        local pageLayout = Instance.new("UIListLayout", page); pageLayout.Padding = UDim.new(0, 6)

        local btn = Instance.new("TextButton", TabBar)
        btn.Size = UDim2.new(0, 84, 1, 0); btn.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
        btn.Text = name; btn.TextColor3 = Config.Theme.Dim; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
        btn.AutoButtonColor = false; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages) do p.Visible = false end
            for _, b in pairs(TabButtons) do
                Services.TweenService:Create(b, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(28, 30, 42), TextColor3 = Config.Theme.Dim }):Play()
            end
            page.Visible = true
            Services.TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Config.Theme.Accent, TextColor3 = Config.Theme.Main }):Play()
        end)

        table.insert(Pages, page); table.insert(TabButtons, btn)
        return page, btn
    end

    local P1, B1 = CreateTab("🎯 COMBAT")
    local P2, B2 = CreateTab("🛠️ UTILITY")
    P1.Visible = true; B1.BackgroundColor3 = Config.Theme.Accent; B1.TextColor3 = Config.Theme.Main

    -- Builders
    local function AddToggle(page, text, stateKey, cb)
        local btn = Instance.new("TextButton", page)
        btn.Size = UDim2.new(1, -6, 0, 36); btn.BackgroundColor3 = Config.Theme.Sec
        btn.Text = ""; btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", btn); s.Color = Config.Theme.Accent; s.Transparency = 0.85

        local lbl = Instance.new("TextLabel", btn)
        lbl.Text = text; lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.TextColor3 = Config.Theme.Text
        lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

        local ind = Instance.new("Frame", btn)
        ind.Size = UDim2.new(0, 34, 0, 18); ind.Position = UDim2.new(1, -44, 0.5, -9)
        ind.BackgroundColor3 = Color3.fromRGB(35, 37, 52); Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame", ind)
        dot.Size = UDim2.new(0, 14, 0, 14); dot.Position = UDim2.new(0, 2, 0.5, -7)
        dot.BackgroundColor3 = Color3.fromRGB(90, 95, 110); Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local function SetUI(v)
            Services.TweenService:Create(dot, TweenInfo.new(0.2), {
                Position = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                BackgroundColor3 = v and Config.Theme.Accent or Color3.fromRGB(90, 95, 110)
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
        frame.Size = UDim2.new(1, -6, 0, 46); frame.BackgroundColor3 = Config.Theme.Sec
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Text = text .. ": " .. tostring(Config.Vals[valKey])
        lbl.Size = UDim2.new(1, -20, 0, 18); lbl.Position = UDim2.new(0, 10, 0, 4)
        lbl.BackgroundTransparency = 1; lbl.TextColor3 = Config.Theme.Text
        lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("TextButton", frame)
        bar.Size = UDim2.new(1, -20, 0, 8); bar.Position = UDim2.new(0, 10, 0, 28)
        bar.BackgroundColor3 = Color3.fromRGB(35, 37, 52); bar.Text = ""; bar.AutoButtonColor = false
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((Config.Vals[valKey] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Config.Theme.Accent; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local dragging = false
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        TrackConn(Services.UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
        TrackConn(Services.UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
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
    if isMiniPlus then
        AddToggle(P1, "👻 Silent Aim 🔥 [Mini+]", "SilentAim")
    end
    AddToggle(P1, "🎯 Auto Lock Aimbot", "Aimbot")
    AddToggle(P1, "💀 Head Hitbox Expander", "HeadExpander", function() Utils.UpdateHeadExpander() end)
    AddSlider(P1, "Head Hitbox Size", 5, 40, "HeadSize", function() Utils.UpdateHeadExpander() end)
    AddToggle(P1, "🔫 TriggerBot (Auto Fire)", "TriggerBot")
    AddToggle(P1, "⭕ Show FOV Circle", "ShowFOV", function(v) if Storage.FOVRingUI then Storage.FOVRingUI.Visible = v end end)
    AddSlider(P1, "FOV Radius", 50, 400, "FOV", function(v)
        if Storage.FOVRingUI then Storage.FOVRingUI.Size = UDim2.new(0, v * 2, 0, v * 2) end
    end)
    AddToggle(P1, "🛡️ Team Check", "TeamCheck")
    AddToggle(P1, "🧱 Wall Check", "WallCheck")

    -- TAB 2: UTILITY & VISUALS
    AddToggle(P2, "📦 Box + Health ESP", "ESP", function(v)
        if not v and Drawing then
            for _, esp in pairs(Storage.ESPObjects) do
                if esp.Box then esp.Box.Visible = false end
                if esp.Name then esp.Name.Visible = false end
                if esp.HealthBar then esp.HealthBar.Visible = false end
            end
        end
    end)
    AddToggle(P2, "📦 Item & Loot ESP", "ItemESP", function(v) if not v then ClearItemESP() else task.spawn(UpdateItemESP) end end)
    AddToggle(P2, "✨ Chams (Highlight)", "Chams", function() Utils.UpdateChams() end)
    AddToggle(P2, "💡 Fullbright", "Fullbright", function(v) Utils.ToggleFullbright(v) end)
    AddToggle(P2, "➕ Crosshair", "Crosshair")
    AddToggle(P2, "🦅 Fly Mode (Touch ▲▼)", "Fly", function(v)
        Utils.UpdateCollisions()
        if Storage.FlyUpBtn then Storage.FlyUpBtn.Visible = v end
        if Storage.FlyDownBtn then Storage.FlyDownBtn.Visible = v end
    end)
    AddSlider(P2, "Fly Speed", 20, 300, "FlySpeed")
    AddToggle(P2, "👻 Noclip", "Noclip", function() Utils.UpdateCollisions() end)
    AddToggle(P2, "⚡ Speed Hack", "SpeedHack", function(v)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v and Config.Vals.WalkSpeed or Storage.OriginalWalkSpeed end
    end)
    AddSlider(P2, "Walk Speed", 20, 200, "WalkSpeed", function(v)
        if Config.States.SpeedHack and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end)
    AddToggle(P2, "🦘 Infinite Jump", "InfJump")
    AddToggle(P2, "🪂 No Fall Damage", "NoFall")

    -- One-Touch Unload Button
    local UnloadBtn = Instance.new("TextButton", P2)
    UnloadBtn.Size = UDim2.new(1, -6, 0, 38); UnloadBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 40)
    UnloadBtn.Text = "🛑 UNLOAD X MINIM"; UnloadBtn.TextColor3 = Color3.new(1, 1, 1)
    UnloadBtn.Font = Enum.Font.GothamBold; UnloadBtn.TextSize = 12
    Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)
    UnloadBtn.MouseButton1Click:Connect(function()
        if _G.X_MINIM_UNLOAD then _G.X_MINIM_UNLOAD() end
    end)

    P1.CanvasSize = UDim2.new(0, 0, 0, 410)
    P2.CanvasSize = UDim2.new(0, 0, 0, 520)

    -- Virtual Touch Fly Controls (▲ / ▼)
    local flyControls = Instance.new("Frame", ScreenGui)
    flyControls.Name = "FlyControls"; flyControls.Size = UDim2.new(0, 64, 0, 130)
    flyControls.Position = UDim2.new(1, -80, 0.45, 0); flyControls.BackgroundTransparency = 1

    local upBtn = Instance.new("TextButton", flyControls)
    upBtn.Size = UDim2.new(0, 58, 0, 58); upBtn.Position = UDim2.new(0, 0, 0, 0)
    upBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 36); upBtn.Text = "▲"; upBtn.TextColor3 = Config.Theme.Accent
    upBtn.Font = Enum.Font.GothamBold; upBtn.TextSize = 22; upBtn.Visible = false
    Instance.new("UICorner", upBtn).CornerRadius = UDim.new(1, 0)
    local upStroke = Instance.new("UIStroke", upBtn); upStroke.Color = Config.Theme.Accent; upStroke.Thickness = 1.5

    local downBtn = Instance.new("TextButton", flyControls)
    downBtn.Size = UDim2.new(0, 58, 0, 58); downBtn.Position = UDim2.new(0, 0, 0, 68)
    downBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 36); downBtn.Text = "▼"; downBtn.TextColor3 = Config.Theme.Accent
    downBtn.Font = Enum.Font.GothamBold; downBtn.TextSize = 22; downBtn.Visible = false
    Instance.new("UICorner", downBtn).CornerRadius = UDim.new(1, 0)
    local downStroke = Instance.new("UIStroke", downBtn); downStroke.Color = Config.Theme.Accent; downStroke.Thickness = 1.5

    upBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            Storage.FlyUpState = true
        end
    end)
    upBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            Storage.FlyUpState = false
        end
    end)

    downBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            Storage.FlyDownState = true
        end
    end)
    downBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            Storage.FlyDownState = false
        end
    end)

    Storage.FlyUpBtn = upBtn
    Storage.FlyDownBtn = downBtn
end

-- ==================================================================
-- UNLOAD & CLEANUP
-- ==================================================================
local function Unload()
    for _, c in pairs(Storage.Connections) do pcall(function() c:Disconnect() end) end
    Storage.Connections = {}

    for _, p in pairs(Services.Players:GetPlayers()) do
        if Storage.ESPObjects[p] then
            for _, d in pairs(Storage.ESPObjects[p]) do pcall(function() d:Remove() end) end
        end
    end
    if Storage.CrosshairLines.H then pcall(function() Storage.CrosshairLines.H:Remove(); Storage.CrosshairLines.V:Remove() end) end

    ClearItemESP()
    Config.States.HeadExpander = false; Utils.UpdateHeadExpander()
    Config.States.Chams = false; Utils.UpdateChams()
    Config.States.Fullbright = false; Utils.ToggleFullbright(false)
    Config.States.Fly = false; Config.States.Noclip = false; Utils.UpdateCollisions()

    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Storage.OriginalWalkSpeed; hum.PlatformStand = false end

    if Storage.MainFrame and Storage.MainFrame.Parent then Storage.MainFrame.Parent:Destroy() end
    if Storage.FOVRingUI and Storage.FOVRingUI.Parent then Storage.FOVRingUI.Parent:Destroy() end
    Notify("X MINIM", "Mobile Suite successfully unloaded.")
end
_G.X_MINIM_UNLOAD = Unload

-- ==================================================================
-- RUNTIME INITIALIZATION
-- ==================================================================
local function Init()
    local fovGui = Instance.new("ScreenGui", targetGui)
    fovGui.Name = "X_MINIM_FOV"; fovGui.ResetOnSpawn = false; fovGui.IgnoreGuiInset = true
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

    BuildMobileUI()

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
        -- Mobile Auto-Aim
        if Config.States.Aimbot then
            local target = Utils.GetClosestTarget()
            if target and target.Parent then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, target.Position), Config.Vals.Smoothness)
            end
        end

        -- TriggerBot
        if Config.States.TriggerBot and tick() > Storage.TriggerCooldown then
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local unitRay = Camera:ViewportPointToRay(center.X, center.Y)
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.IgnoreWater = true

            local res = Services.Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
            if res and res.Instance and res.Instance.Parent then
                local eHum = res.Instance.Parent:FindFirstChildOfClass("Humanoid")
                local targetPlayer = Services.Players:GetPlayerFromCharacter(res.Instance.Parent)
                if eHum and eHum.Health > 0 and res.Instance.Parent.Name ~= LocalPlayer.Name then
                    if not Config.States.TeamCheck or not Utils.IsTeammate(targetPlayer) then
                        Storage.TriggerCooldown = tick() + Config.Vals.TriggerDelay
                        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        if type(mouse1click) == "function" then mouse1click() end
                    end
                end
            end
        end

        -- ESP & Crosshair
        if Drawing then
            if Config.States.ESP then
                for _, plr in pairs(Services.Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local root = plr.Character:FindFirstChild("HumanoidRootPart")
                        local head = plr.Character:FindFirstChild("Head")
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")

                        if root and head and hum and hum.Health > 0 then
                            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                            local color = (Config.States.TeamCheck and Utils.IsTeammate(plr)) and Config.Theme.Team or Config.Theme.Accent

                            local esp = Storage.ESPObjects[plr]
                            if not esp then
                                esp = { Box = Drawing.new("Square"), Name = Drawing.new("Text"), HealthBar = Drawing.new("Line") }
                                esp.Box.Thickness = 1.5; esp.Box.Filled = false
                                esp.Name.Size = 12; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Color = Color3.new(1,1,1)
                                esp.HealthBar.Thickness = 1.5; esp.HealthBar.Color = Color3.new(0,1,0)
                                Storage.ESPObjects[plr] = esp
                            end

                            if onScreen then
                                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                                local height = math.abs(headPos.Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
                                local width = height / 1.8

                                esp.Box.Visible = true; esp.Box.Size = Vector2.new(width, height)
                                esp.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2); esp.Box.Color = color

                                esp.Name.Visible = true; esp.Name.Text = plr.DisplayName
                                esp.Name.Position = Vector2.new(pos.X, esp.Box.Position.Y - 15); esp.Name.Color = color

                                esp.HealthBar.Visible = true
                                esp.HealthBar.From = Vector2.new(esp.Box.Position.X - 5, esp.Box.Position.Y + height)
                                esp.HealthBar.To = Vector2.new(esp.Box.Position.X - 5, esp.Box.Position.Y + height - height * math.clamp(hum.Health / hum.MaxHealth, 0, 1))
                            else
                                esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false
                            end
                        elseif Storage.ESPObjects[plr] then
                            Storage.ESPObjects[plr].Box.Visible = false; Storage.ESPObjects[plr].Name.Visible = false; Storage.ESPObjects[plr].HealthBar.Visible = false
                        end
                    elseif Storage.ESPObjects[plr] then
                        Storage.ESPObjects[plr].Box.Visible = false; Storage.ESPObjects[plr].Name.Visible = false; Storage.ESPObjects[plr].HealthBar.Visible = false
                    end
                end
            else
                for _, esp in pairs(Storage.ESPObjects) do
                    if esp.Box then esp.Box.Visible = false end
                    if esp.Name then esp.Name.Visible = false end
                    if esp.HealthBar then esp.HealthBar.Visible = false end
                end
            end

            if Config.States.Crosshair and Storage.CrosshairLines.H then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                Storage.CrosshairLines.H.Visible = true
                Storage.CrosshairLines.H.From = Vector2.new(center.X - 10, center.Y); Storage.CrosshairLines.H.To = Vector2.new(center.X + 10, center.Y)
                Storage.CrosshairLines.V.Visible = true
                Storage.CrosshairLines.V.From = Vector2.new(center.X, center.Y - 10); Storage.CrosshairLines.V.To = Vector2.new(center.X, center.Y + 10)
            elseif Storage.CrosshairLines.H then
                Storage.CrosshairLines.H.Visible = false; Storage.CrosshairLines.V.Visible = false
            end
        end
    end))

    -- Heartbeat Loop (Movement & Touch Fly)
    TrackConn(Services.RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if Config.States.Fly then
            hum.PlatformStand = true
            local dir = hum.MoveDirection
            local upVel = 0
            if Storage.FlyUpState then upVel = 1 elseif Storage.FlyDownState then upVel = -1 end
            hrp.AssemblyLinearVelocity = Vector3.new(dir.X * Config.Vals.FlySpeed, upVel * Config.Vals.FlySpeed, dir.Z * Config.Vals.FlySpeed)
        elseif hum.PlatformStand then
            hum.PlatformStand = false
        end

        if Config.States.InfJump and hum:GetState() == Enum.HumanoidStateType.Freefall then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))

    Notify("X MINIM V4.0.0", "Delta Mobile Ready! Tap [⚡] to toggle menu")
end

Init()
