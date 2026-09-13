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

-- [[ X PRO V3.0.0 - COMPETITIVE & TOURNAMENT SUITE ]]
-- Official Seller: vlilayz | Tier: PRO (RM 20)
-- 100% English UI | Zero Memory Leak | High Performance
-- Features: Smart Prediction | Auto Bone Target | Silent Aim Metamethod | Skeleton ESP | 2D Tactical Radar | Weapon ESP | Off-screen Target Arrows | TriggerBot | LegitFly | Anti-Killbrick
-- ==================================================================
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
    targetGui = gethui()
else
    local s, c = pcall(function() return game:GetService("CoreGui") end)
    if s and c then targetGui = c else targetGui = LocalPlayer:WaitForChild("PlayerGui") end
end
if not targetGui then warn("X PRO: GUI Target failed!") return end

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
        ESP = false, ESPSkeleton = false, WeaponESP = true, OffscreenArrows = true,
        Tracers = false, Chams = false, Fullbright = false, Crosshair = false,
        Radar = false, HitSound = true, NoRecoil = false,
        Fly = false, LegitFly = false, SpeedHack = false, InfJump = false,
        Noclip = false, NoFall = false, ClickTP = false, AntiKillbrick = false
    },
    Vals = {
        FOV = 180, Smoothness = 0.28, PredictionStrength = 0.14,
        TriggerDelay = 0.15, WalkSpeed = 85, FlySpeed = 120,
        RadarRange = 120, AimPart = "Head", OffscreenRadius = 240
    }
}

local Storage = {
    Connections = {}, ESPObjects = {}, SkeletonParts = {}, TracerLines = {},
    CrosshairLines = {}, OffscreenArrows = {}, ToggleFuncs = {}, FOVRingUI = nil, MainFrame = nil,
    OriginalLighting = {}, OriginalCollisions = {}, OriginalWalkSpeed = 16,
    LockedTarget = nil, IsRightMouseDown = false, TriggerCooldown = 0,
    RadarGui = nil, RadarFrame = nil, RadarObjects = {}, HitSoundObj = nil,
    AimParts = {"Head", "Torso", "HumanoidRootPart"}, AimPartIndex = 1
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
        if p == LocalPlayer or not p.Character then continue end
        if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local aimPart = Utils.GetAimPart(p.Character)
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
-- EXPLOIT HOOKS (SILENT AIM & ANTI-KILLBRICK)
-- ==================================================================
if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
    local safeUnpack = table.unpack or unpack
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
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

    local oldNewIndex
    oldNewIndex = hookmetamethod(game, "__newindex", function(t, k, v)
        if Config.States.AntiKillbrick and not checkcaller() and t:IsA("Humanoid") and t:IsDescendantOf(LocalPlayer.Character) and k == "Health" then
            if type(v) == "number" and v < t.Health then return end
        end
        return oldNewIndex(t, k, v)
    end)
end

-- ==================================================================
-- MODERN 3-TAB UI (V3.0.0)
-- ==================================================================
local function BuildUI()
    local uiName = "X_PRO_V3_0_0"
    if targetGui:FindFirstChild(uiName) then targetGui[uiName]:Destroy() end

    local ScreenGui = Instance.new("ScreenGui", targetGui)
    ScreenGui.Name = uiName; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 530, 0, 430); Main.Position = UDim2.new(0.5, -265, 0.5, -215)
    Main.BackgroundColor3 = Config.Theme.Main; Main.Active = true; Main.Draggable = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Config.Theme.Accent; Stroke.Thickness = 1.5; Stroke.Transparency = 0.4
    Storage.MainFrame = Main

    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 44); Header.BackgroundColor3 = Config.Theme.Sec
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel", Header)
    Title.Text = "⚡ X PRO <font color='#00dcff'>V3.0.0</font> <font color='#8c8c9b'>| TOURNAMENT</font>"; Title.RichText = true
    Title.Size = UDim2.new(0, 240, 1, 0); Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1; Title.TextColor3 = Config.Theme.Text
    Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left

    local TabBar = Instance.new("Frame", Header)
    TabBar.Size = UDim2.new(0, 260, 0, 28); TabBar.Position = UDim2.new(1, -270, 0.5, -14)
    TabBar.BackgroundTransparency = 1
    local TabList = Instance.new("UIListLayout", TabBar); TabList.FillDirection = Enum.FillDirection.Horizontal; TabList.Padding = UDim.new(0, 6)

    local Pages = {}
    local TabButtons = {}

    local function CreateTab(name)
        local page = Instance.new("ScrollingFrame", Main)
        page.Size = UDim2.new(1, -24, 1, -62); page.Position = UDim2.new(0, 12, 0, 52)
        page.BackgroundTransparency = 1; page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Config.Theme.Accent; page.Visible = false
        local pageLayout = Instance.new("UIListLayout", page); pageLayout.Padding = UDim.new(0, 6)

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
        btn.Size = UDim2.new(1, -6, 0, 36); btn.BackgroundColor3 = Config.Theme.Sec
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
        frame.Size = UDim2.new(1, -6, 0, 44); frame.BackgroundColor3 = Config.Theme.Sec
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
    AddToggle(P2, "📦 Box ESP", "ESP")
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

    P1.CanvasSize = UDim2.new(0, 0, 0, 520)
    P2.CanvasSize = UDim2.new(0, 0, 0, 440)
    P3.CanvasSize = UDim2.new(0, 0, 0, 480)
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
    Notify("X PRO V3.0", "All Pro modules successfully unloaded.")
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

        -- ESP, Visuals, Offscreen Arrows
        if Drawing then
            UpdateSkeletonESP()

            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

            for _, plr in pairs(Services.Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    local head = plr.Character:FindFirstChild("Head")
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")

                    if root and head and hum and hum.Health > 0 then
                        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                        local color = (Config.States.TeamCheck and Utils.IsTeammate(plr)) and Config.Theme.Team or Config.Theme.Accent

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

                            if onScreen then
                                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                                local height = math.abs(headPos.Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
                                local width = height / 1.8

                                esp.Box.Visible = true; esp.Box.Size = Vector2.new(width, height)
                                esp.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2); esp.Box.Color = color

                                esp.Name.Visible = true; esp.Name.Text = plr.DisplayName
                                esp.Name.Position = Vector2.new(pos.X, esp.Box.Position.Y - 16); esp.Name.Color = color

                                esp.HealthBar.Visible = true
                                esp.HealthBar.From = Vector2.new(esp.Box.Position.X - 5, esp.Box.Position.Y + height)
                                esp.HealthBar.To = Vector2.new(esp.Box.Position.X - 5, esp.Box.Position.Y + height - height * math.clamp(hum.Health / hum.MaxHealth, 0, 1))

                                if Config.States.WeaponESP then
                                    local tool = plr.Character:FindFirstChildOfClass("Tool")
                                    esp.Weapon.Visible = true
                                    esp.Weapon.Text = tool and "[" .. tool.Name .. "]" or "[Unarmed]"
                                    esp.Weapon.Position = Vector2.new(pos.X, esp.Box.Position.Y + height + 2)
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
                        elseif Storage.OffscreenArrows[plr] then
                            Storage.OffscreenArrows[plr].Visible = false
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

        if Config.States.InfJump and Services.UIS:IsKeyDown(Enum.KeyCode.Space) then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))

    -- User Inputs
    TrackConn(Services.UIS.InputBegan:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Storage.IsRightMouseDown = true
        end

        if gpe then return end
        if input.KeyCode == Config.Keys.Menu then
            if Storage.MainFrame then Storage.MainFrame.Visible = not Storage.MainFrame.Visible end
        elseif input.KeyCode == Config.Keys.Fly then
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

    Notify("X PRO V3.0.0", "Tournament Pro Active! [Insert] Menu [F] Lock Target [End] Unload")
end

Init()
