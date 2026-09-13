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

-- [[ X MINI V4.0.1 - PURE COMBAT & UTILITY EDITION ]]
-- 定位: 纯粹日常主力 / 双栏紧凑 / 高性价比 / 零多余负担
-- 架构: 双Tab (COMBAT & UTILITY) | 纯净平滑自瞄 | 完整ESP | 移动与辅助 | 零内存泄漏
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
        Trigger = Enum.KeyCode.T, Unload = Enum.KeyCode.End
    },
    Theme = {
        Main = Color3.fromRGB(12, 14, 20), Sec = Color3.fromRGB(20, 22, 32),
        Accent = Color3.fromRGB(0, 210, 255), Team = Color3.fromRGB(0, 255, 120),
        Text = Color3.fromRGB(245, 245, 250), Dim = Color3.fromRGB(140, 145, 160),
        Red = Color3.fromRGB(255, 70, 70), Warn = Color3.fromRGB(255, 190, 40)
    },
    States = {
        Aimbot = false, TeamCheck = true, WallCheck = false, RightClickOnly = true,
        ShowFOV = false, HeadExpander = false, TriggerBot = false,
        ESP = false, Chams = false, Fullbright = false, Crosshair = false,
        Fly = false, LegitFly = false, Noclip = false, SpeedHack = false,
        InfJump = false, NoFall = false, ClickTP = false, ItemESP = false, SilentAim = false
    },
    Vals = {
        FOV = 180, Smoothness = 0.3, WalkSpeed = 80, FlySpeed = 120,
        HeadSize = 15, TriggerDelay = 0.15
    }
}

local Storage = {
    Connections = {}, ESPObjects = {}, CrosshairLines = {}, ToggleFuncs = {},
    FOVRingUI = nil, MainFrame = nil, OriginalLighting = {}, OriginalCollisions = {},
    OriginalWalkSpeed = 16, IsRightMouseDown = false, TriggerCooldown = 0, ItemESPObjects = {},
    PlayerCache = {}
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
-- UTILITIES & CHECKS
-- ==================================================================
local Unload
local Utils = {}

local function CachePlayer(p)
    if not p or p == LocalPlayer then return end
    local char = p.Character
    if not char or not char.Parent then
        char = Services.Workspace:FindFirstChild(p.Name)
        if not char then
            for _, fName in ipairs({"Characters", "Players", "Alive"}) do
                local f = Services.Workspace:FindFirstChild(fName)
                if f then
                    local c = f:FindFirstChild(p.Name)
                    if c and c:IsA("Model") then char = c break end
                end
            end
        end
    end

    if not char or not char.Parent then
        Storage.PlayerCache[p] = nil
        return
    end

    local head = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or head
    local hum = char:FindFirstChildOfClass("Humanoid")

    if head and root then
        Storage.PlayerCache[p] = { Char = char, Head = head, Root = root, Hum = hum }
    else
        Storage.PlayerCache[p] = nil
    end
end

function Utils.IsTeammate(plr)
    if not plr or not LocalPlayer or plr == LocalPlayer then return false end
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
    local closestDist, bestTarget = Config.Vals.FOV, nil

    for p, data in pairs(Storage.PlayerCache) do
        if not data.Char.Parent then continue end
        if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end

        local hum = data.Hum
        if hum and hum.Health <= 0 and hum.MaxHealth > 0 then continue end

        local head = data.Head
        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen and pos.Z > 0 then
            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            if dist < closestDist then
                if not Config.States.WallCheck or Utils.IsVisible(head) then
                    closestDist = dist
                    bestTarget = head
                end
            end
        end
    end
    return bestTarget
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
    if not Config.States.Chams then
        for _, p in pairs(Services.Players:GetPlayers()) do
            if p.Character then
                local c = p.Character:FindFirstChild("X_Mini_Chams")
                if c then c:Destroy() end
            end
        end
        return
    end

    for p, data in pairs(Storage.PlayerCache) do
        local char = data.Char
        if char and char.Parent then
            local chams = char:FindFirstChild("X_Mini_Chams")
            local hum = data.Hum
            local isAlive = (not hum) or (hum.Health > 0) or (hum.MaxHealth <= 0)
            if isAlive then
                if not chams then
                    chams = Instance.new("Highlight")
                    chams.Name = "X_Mini_Chams"
                    chams.FillTransparency = 0.5
                    chams.OutlineTransparency = 0.1
                    chams.Parent = char
                end
                local isTeam = Config.States.TeamCheck and Utils.IsTeammate(p)
                local col = isTeam and Config.Theme.Team or Config.Theme.Accent
                chams.FillColor = col
                chams.OutlineColor = col
            elseif chams then
                chams:Destroy()
            end
        end
    end
end

-- ==================================================================
-- DRAWING: FOV, CROSSHAIR & ESP
-- ==================================================================
local function CreateFOVRing()
    pcall(function()
        if targetGui:FindFirstChild("X_MINI_FOV") then targetGui["X_MINI_FOV"]:Destroy() end
        local gui = Instance.new("ScreenGui")
        gui.Name = "X_MINI_FOV"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 999998
        local pOk = pcall(function() gui.Parent = targetGui end)
        if not pOk or not gui.Parent then
            gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
        end
        
        local ring = Instance.new("Frame", gui)
        ring.AnchorPoint = Vector2.new(0.5, 0.5); ring.Position = UDim2.new(0.5, 0, 0.5, 0)
        ring.Size = UDim2.new(0, Config.Vals.FOV * 2, 0, Config.Vals.FOV * 2)
        ring.BackgroundTransparency = 1; ring.Visible = false
        
        local stroke = Instance.new("UIStroke", ring)
        stroke.Color = Config.Theme.Accent; stroke.Thickness = 1.5; stroke.Transparency = 0.35
        Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
        Storage.FOVRingUI = ring
    end)
end

local function InitDrawings()
    if not Drawing then return end
    Storage.CrosshairLines.H = Drawing.new("Line")
    Storage.CrosshairLines.H.Thickness = 1.5
    Storage.CrosshairLines.H.Color = Config.Theme.Accent
    Storage.CrosshairLines.H.Visible = false

    Storage.CrosshairLines.V = Drawing.new("Line")
    Storage.CrosshairLines.V.Thickness = 1.5
    Storage.CrosshairLines.V.Color = Config.Theme.Accent
    Storage.CrosshairLines.V.Visible = false
end

local function CreateESP(plr)
    if plr == LocalPlayer or Storage.ESPObjects[plr] or not Drawing then return end
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Line")
    }
    esp.Box.Thickness = 1.5; esp.Box.Filled = false; esp.Box.Visible = false
    esp.Name.Size = 13; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.Color = Color3.new(1,1,1); esp.Name.Visible = false
    esp.HealthBar.Thickness = 1.5; esp.HealthBar.Color = Color3.new(0,1,0); esp.HealthBar.Visible = false
    Storage.ESPObjects[plr] = esp
end

local function RemoveESP(plr)
    if Storage.ESPObjects[plr] then
        for _, d in pairs(Storage.ESPObjects[plr]) do pcall(function() d:Remove() end) end
        Storage.ESPObjects[plr] = nil
    end
end


local function ClearItemESP()
    for obj, gui in pairs(Storage.ItemESPObjects) do
        if gui and gui.Parent then pcall(function() gui:Destroy() end) end
    end
    Storage.ItemESPObjects = {}
end

local function UpdateItemESP()
    if not Config.States.ItemESP then
        ClearItemESP()
        return
    end
    local myChar = LocalPlayer.Character
    local myHrp = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
    if not myHrp then return end

    local myPos = myHrp.Position
    local found = {}

    -- Zero-Lag Shallow Workspace Scan (Avoids scanning 50,000 descendants)
    for _, item in ipairs(Services.Workspace:GetChildren()) do
        if item:IsA("Tool") and item:FindFirstChild("Handle") then
            local dist = (item.Handle.Position - myPos).Magnitude
            if dist <= 500 then found[item.Handle] = { Name = item.Name, Dist = math.floor(dist) } end
        elseif item.Name == "Drops" or item.Name == "Items" or item.Name == "Loot" or item.Name == "Tools" then
            for _, sub in ipairs(item:GetChildren()) do
                local p = sub:IsA("BasePart") and sub or sub:FindFirstChildWhichIsA("BasePart")
                if p then
                    local dist = (p.Position - myPos).Magnitude
                    if dist <= 500 then found[p] = { Name = sub.Name, Dist = math.floor(dist) } end
                end
            end
        end
    end

    for part, data in pairs(found) do
        local bg = Storage.ItemESPObjects[part]
        if not bg or not bg.Parent then
            bg = Instance.new("BillboardGui")
            bg.Name = "X_ITEM_ESP"
            bg.AlwaysOnTop = true
            bg.Size = UDim2.new(0, 150, 0, 26)
            bg.Adornee = part
            bg.MaxDistance = 500
            
            local lbl = Instance.new("TextLabel", bg)
            lbl.Name = "Tag"
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(255, 215, 50)
            lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            lbl.TextStrokeTransparency = 0.2
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11
            lbl.Text = "📦 " .. data.Name .. " [" .. tostring(data.Dist) .. "m]"
            
            bg.Parent = targetGui
            Storage.ItemESPObjects[part] = bg
        else
            local lbl = bg:FindFirstChild("Tag")
            if lbl then
                lbl.Text = "📦 " .. data.Name .. " [" .. tostring(data.Dist) .. "m]"
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

-- ==================================================================
-- DUAL TAB UI (COMBAT & UTILITY)
-- ==================================================================
local activeKey = tostring(getgenv().Key or getgenv().ScriptKey or script_key or "")
local isMiniPlus = string.find(string.upper(activeKey), "X%-MINI%-PRO%-X") ~= nil

-- ==================================================================
-- MULTI-LAYER SILENT AIM ENGINE (EXCLUSIVE TO X-MINI-PRO-X)
-- ==================================================================
local HasMiniMetamethodHook = false

if isMiniPlus then
    -- [TIER 1] Metamethod __namecall Hook (Delta & Advanced PC Executors)
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

    -- [TIER 2] Mouse.Hit & Target Spoofing (Xeno / Free PC Executors)
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
                            if k == "Hit" then return CFrame.new(targetPart.Position)
                            elseif k == "Target" then return targetPart end
                        end
                    end
                    if type(oldIndex) == "function" then
                        return oldIndex(t, k)
                    elseif type(oldIndex) == "table" then
                        return oldIndex[k]
                    end
                    return nil
                end
                setreadonly(mt, true)
            end
        end
    end)
end

-- [TIER 3] Micro-Flick Silent Aim Fallback for Xeno
local function MiniMicroFlickSilentAim()
    if not isMiniPlus or not Config.States.SilentAim then return end
    local targetPart = Utils.GetClosestTarget()
    if not targetPart or not targetPart.Parent then return end

    local origCF = Camera.CFrame
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
    task.spawn(function()
        Services.RunService.RenderStepped:Wait()
        Camera.CFrame = origCF
    end)
end

local function BuildUI()
    local uiName = "X_MINI_V4_0_0"
    pcall(function()
        if targetGui:FindFirstChild(uiName) then targetGui[uiName]:Destroy() end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = uiName
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local pOk = pcall(function() ScreenGui.Parent = targetGui end)
    if not pOk or not ScreenGui.Parent then
        pcall(function()
            ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
        end)
    end

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 480, 0, 380)
    Main.Position = UDim2.new(0.5, -240, 0.5, -190)
    Main.BackgroundColor3 = Config.Theme.Main
    Main.Active = true; Main.Draggable = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Config.Theme.Accent; Stroke.Thickness = 1.5; Stroke.Transparency = 0.5
        Storage.MainFrame = Main

    -- Floating Open/Close Button (Always visible on screen, click to toggle menu)
    local ToggleBtn = Instance.new("TextButton", ScreenGui)
    ToggleBtn.Name = "X_Mini_Floating_Toggle"
    ToggleBtn.Size = UDim2.new(0, 42, 0, 42)
    ToggleBtn.Position = UDim2.new(0, 16, 0.45, 0)
    ToggleBtn.BackgroundColor3 = Config.Theme.Sec
    ToggleBtn.Text = "X"
    ToggleBtn.TextColor3 = Config.Theme.Accent
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 18
    ToggleBtn.Active = true
    ToggleBtn.Draggable = true
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
    local tbStroke = Instance.new("UIStroke", ToggleBtn)
    tbStroke.Color = Config.Theme.Accent
    tbStroke.Thickness = 1.5
    tbStroke.Transparency = 0.3

    ToggleBtn.MouseButton1Click:Connect(function()
        if Storage.MainFrame then
            Storage.MainFrame.Visible = not Storage.MainFrame.Visible
        end
    end)

    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 42); Header.BackgroundColor3 = Config.Theme.Sec
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel", Header)
    if isMiniPlus then
        Title.Text = "📦 X MINI<font color='#00d2ff'>+</font> <font color='#ffcd32'>[PRO-X]</font>"
    else
        Title.Text = "📦 X MINI <font color='#00d2ff'>V4.0</font>"
    end
    Title.RichText = true
    Title.Size = UDim2.new(0, 160, 1, 0); Title.Position = UDim2.new(0, 12, 0, 0)

    -- Header Unload Button
    local HdrUnloadBtn = Instance.new("TextButton", Header)
    HdrUnloadBtn.Name = "HeaderUnload"
    HdrUnloadBtn.Size = UDim2.new(0, 60, 0, 26); HdrUnloadBtn.Position = UDim2.new(1, -70, 0.5, -13)
    HdrUnloadBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    HdrUnloadBtn.Text = "UNLOAD"; HdrUnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    HdrUnloadBtn.Font = Enum.Font.GothamBold; HdrUnloadBtn.TextSize = 10
    Instance.new("UICorner", HdrUnloadBtn).CornerRadius = UDim.new(0, 6)
    local hubStroke = Instance.new("UIStroke", HdrUnloadBtn)
    hubStroke.Color = Color3.fromRGB(255, 80, 80); hubStroke.Thickness = 1
    HdrUnloadBtn.MouseButton1Click:Connect(function() if Unload then Unload() end end)
    Title.BackgroundTransparency = 1; Title.TextColor3 = Config.Theme.Text
    Title.Font = Enum.Font.GothamBold; Title.TextSize = 15; Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Tabs inside Header
    local TabBar = Instance.new("Frame", Header)
    TabBar.Size = UDim2.new(0, 190, 0, 28); TabBar.Position = UDim2.new(1, -270, 0.5, -14)
    TabBar.BackgroundTransparency = 1
    local TabList = Instance.new("UIListLayout", TabBar); TabList.FillDirection = Enum.FillDirection.Horizontal; TabList.Padding = UDim.new(0, 8)

    local Pages = {}
    local TabButtons = {}

    local function CreateTab(name)
        local page = Instance.new("ScrollingFrame", Main)
        page.Size = UDim2.new(1, -24, 1, -60); page.Position = UDim2.new(0, 12, 0, 50)
        page.BackgroundTransparency = 1; page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Config.Theme.Accent; page.Visible = false
        local pageLayout = Instance.new("UIListLayout", page); pageLayout.Padding = UDim.new(0, 6)
        
        local btn = Instance.new("TextButton", TabBar)
        btn.Size = UDim2.new(0, 95, 1, 0); btn.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
        btn.Text = name; btn.TextColor3 = Config.Theme.Dim; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
        btn.AutoButtonColor = false; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages) do p.Visible = false end
            for _, b in pairs(TabButtons) do
                Services.TweenService:Create(b, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(30, 32, 44), TextColor3 = Config.Theme.Dim }):Play()
            end
            page.Visible = true
            Services.TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Config.Theme.Accent, TextColor3 = Config.Theme.Main }):Play()
        end)

        table.insert(Pages, page)
        table.insert(TabButtons, btn)
        return page, btn
    end

    local CombatPage, CombatBtn = CreateTab("⚔️ COMBAT")
    local UtilityPage, UtilityBtn = CreateTab("🛠️ UTILITY")
    CombatPage.Visible = true; CombatBtn.BackgroundColor3 = Config.Theme.Accent; CombatBtn.TextColor3 = Config.Theme.Main

    -- Component Builders
    local function AddToggle(page, text, stateKey, cb)
        local btn = Instance.new("TextButton", page)
        btn.Size = UDim2.new(1, -6, 0, 36); btn.BackgroundColor3 = Config.Theme.Sec
        btn.Text = ""; btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", btn); s.Color = Config.Theme.Accent; s.Transparency = 0.85

        local lbl = Instance.new("TextLabel", btn)
        lbl.Text = text; lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.TextColor3 = Config.Theme.Text
        lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

        local ind = Instance.new("Frame", btn)
        ind.Size = UDim2.new(0, 32, 0, 16); ind.Position = UDim2.new(1, -44, 0.5, -8)
        ind.BackgroundColor3 = Color3.fromRGB(35, 38, 50); Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame", ind)
        dot.Size = UDim2.new(0, 12, 0, 12); dot.Position = UDim2.new(0, 2, 0.5, -6)
        dot.BackgroundColor3 = Color3.fromRGB(90, 95, 110); Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local function SetUI(v)
            Services.TweenService:Create(dot, TweenInfo.new(0.2), {
                Position = v and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
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
        frame.Size = UDim2.new(1, -6, 0, 44); frame.BackgroundColor3 = Config.Theme.Sec
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Text = text .. ": " .. tostring(Config.Vals[valKey])
        lbl.Size = UDim2.new(1, -20, 0, 18); lbl.Position = UDim2.new(0, 12, 0, 4)
        lbl.BackgroundTransparency = 1; lbl.TextColor3 = Config.Theme.Text
        lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("TextButton", frame)
        bar.Size = UDim2.new(1, -24, 0, 5); bar.Position = UDim2.new(0, 12, 0, 28)
        bar.BackgroundColor3 = Color3.fromRGB(35, 38, 50); bar.Text = ""; bar.AutoButtonColor = false
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

    -- ================= TAB 1: COMBAT =================
    AddToggle(CombatPage, "🎯 Smooth Aimbot", "Aimbot")
    AddToggle(CombatPage, "🖱️ Right Click to Aim [HOLD]", "RightClickOnly")
    AddToggle(CombatPage, "⭕ Show FOV Circle", "ShowFOV", function(v) if Storage.FOVRingUI then Storage.FOVRingUI.Visible = v end end)
    AddSlider(CombatPage, "FOV Size", 50, 500, "FOV", function(v)
        if Storage.FOVRingUI then Storage.FOVRingUI.Size = UDim2.new(0, v * 2, 0, v * 2) end
    end)
    AddToggle(CombatPage, "🛡️ Team Check", "TeamCheck")
    AddToggle(CombatPage, "🧱 Wall Check", "WallCheck")
    AddToggle(CombatPage, "🔫 TriggerBot [T]", "TriggerBot")
    AddToggle(CombatPage, "🎯 Head Hitbox Expander", "HeadExpander")
    AddSlider(CombatPage, "Head Size", 2, 35, "HeadSize")

    -- ================= TAB 2: UTILITY =================
    AddToggle(UtilityPage, "📦 Box ESP", "ESP", function(v)
        if not v and Drawing then
            for _, esp in pairs(Storage.ESPObjects) do
                if esp.Box then esp.Box.Visible = false end
                if esp.Name then esp.Name.Visible = false end
                if esp.HealthBar then esp.HealthBar.Visible = false end
            end
        end
    end)
    AddToggle(UtilityPage, "📦 Item & Loot ESP", "ItemESP", function(v) if not v then ClearItemESP() else task.spawn(UpdateItemESP) end end)
    AddToggle(UtilityPage, "✨ Chams (Highlight)", "Chams", function() Utils.UpdateChams() end)
    AddToggle(UtilityPage, "💡 Fullbright", "Fullbright", function(v) Utils.ToggleFullbright(v) end)
    AddToggle(UtilityPage, "➕ Crosshair", "Crosshair")
    AddToggle(UtilityPage, "🦅 Fly Mode [Z]", "Fly", function() Utils.UpdateCollisions() end)
    AddToggle(UtilityPage, "🪶 Legit Fly (Safe Glide)", "LegitFly")
    AddSlider(UtilityPage, "Fly Speed", 20, 400, "FlySpeed")
    AddToggle(UtilityPage, "👻 Noclip [V]", "Noclip", function() Utils.UpdateCollisions() end)
    AddToggle(UtilityPage, "⚡ Speed Hack", "SpeedHack", function(v)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v and Config.Vals.WalkSpeed or Storage.OriginalWalkSpeed end
    end)
    AddSlider(UtilityPage, "Walk Speed", 20, 300, "WalkSpeed", function(v)
        if Config.States.SpeedHack and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end)
    AddToggle(UtilityPage, "🦘 Infinite Jump", "InfJump")
    AddToggle(UtilityPage, "🪂 No Fall Damage", "NoFall")
    AddToggle(UtilityPage, "📍 Click TP [Ctrl+Click]", "ClickTP")

    -- Prominent In-Menu Unload Button
    local UnloadCard = Instance.new("TextButton", UtilityPage)
    UnloadCard.Name = "UnloadScriptBtn"
    UnloadCard.Size = UDim2.new(1, -6, 0, 38)
    UnloadCard.BackgroundColor3 = Color3.fromRGB(50, 18, 22)
    UnloadCard.Text = "❌ UNLOAD SCRIPT & CLEAN ALL [End]"
    UnloadCard.TextColor3 = Color3.fromRGB(255, 90, 90)
    UnloadCard.Font = Enum.Font.GothamBold
    UnloadCard.TextSize = 12
    Instance.new("UICorner", UnloadCard).CornerRadius = UDim.new(0, 6)
    local ucStroke = Instance.new("UIStroke", UnloadCard)
    ucStroke.Color = Color3.fromRGB(255, 70, 70); ucStroke.Thickness = 1.2; ucStroke.Transparency = 0.4
    UnloadCard.MouseButton1Click:Connect(function()
        if Unload then Unload() end
    end)

    CombatPage.CanvasSize = UDim2.new(0, 0, 0, 420)
    UtilityPage.CanvasSize = UDim2.new(0, 0, 0, 580)
end

-- ==================================================================
-- UNLOAD & CLEANUP
-- ==================================================================
Unload = function()
    for _, c in pairs(Storage.Connections) do pcall(function() c:Disconnect() end) end
    Storage.Connections = {}
    for _, p in pairs(Services.Players:GetPlayers()) do RemoveESP(p) end
    ClearItemESP()
    if Storage.CrosshairLines.H then pcall(function() Storage.CrosshairLines.H:Remove(); Storage.CrosshairLines.V:Remove() end) end

    Config.States.Chams = false; Utils.UpdateChams()
    Config.States.Fullbright = false; Utils.ToggleFullbright(false)
    Config.States.Fly = false; Config.States.Noclip = false; Utils.UpdateCollisions()

    -- Reset Head Expander
    for _, p in pairs(Services.Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            if head:GetAttribute("OrigHeadSize") then
                head.Size = head:GetAttribute("OrigHeadSize")
                head.Transparency = 0; head.CanCollide = true
            end
        end
    end

    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Storage.OriginalWalkSpeed; hum.PlatformStand = false end

    if Storage.MainFrame and Storage.MainFrame.Parent then Storage.MainFrame.Parent:Destroy() end
    if Storage.FOVRingUI and Storage.FOVRingUI.Parent then Storage.FOVRingUI.Parent:Destroy() end
    Notify("X MINI", "All modules successfully unloaded.")
end

-- ==================================================================
-- RUNTIME
-- ==================================================================
local function Init()
    CreateFOVRing()
    InitDrawings()
    BuildUI()

    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then Storage.OriginalWalkSpeed = hum.WalkSpeed end

    for _, p in pairs(Services.Players:GetPlayers()) do
        CreateESP(p)
        if p ~= LocalPlayer then
            CachePlayer(p)
            TrackConn(p.CharacterAdded:Connect(function() task.wait(0.2); CachePlayer(p) end))
        end
    end
    TrackConn(Services.Players.PlayerAdded:Connect(function(p)
        CreateESP(p)
        CachePlayer(p)
        TrackConn(p.CharacterAdded:Connect(function() task.wait(0.2); CachePlayer(p) end))
    end))
    TrackConn(Services.Players.PlayerRemoving:Connect(function(p)
        RemoveESP(p)
        Storage.PlayerCache[p] = nil
    end))

    TrackConn(LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local newHum = char:WaitForChild("Humanoid", 3)
        if newHum then Storage.OriginalWalkSpeed = newHum.WalkSpeed end
        if Config.States.SpeedHack and newHum then newHum.WalkSpeed = Config.Vals.WalkSpeed end
        Utils.UpdateCollisions()
        if Storage.MainFrame and not Storage.MainFrame:IsDescendantOf(game) then
            pcall(BuildUI)
        end
    end))

    -- Stepped: Physics, NoFall & Noclip
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

    -- RenderStepped: Aimbot, ESP, Crosshair
    TrackConn(Services.RunService.RenderStepped:Connect(function()
        -- Smooth Aimbot
        if Config.States.Aimbot then
            local canAim = not Config.States.RightClickOnly or Storage.IsRightMouseDown
            if canAim then
                local target = Utils.GetClosestTarget()
                if target then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, target.Position), Config.Vals.Smoothness)
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

        -- Drawing ESP (Ultra High-Performance Zero-Lag Loop)
        if Drawing then
            if Config.States.ESP then
                for plr, esp in pairs(Storage.ESPObjects) do
                    local data = Storage.PlayerCache[plr]
                    if data and data.Char.Parent then
                        local hum = data.Hum
                        local isAlive = (not hum) or (hum.Health > 0) or (hum.MaxHealth <= 0)
                        if isAlive then
                            local root = data.Root
                            local head = data.Head
                            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                            if onScreen and pos.Z > 0 then
                                local isTeam = Config.States.TeamCheck and Utils.IsTeammate(plr)
                                local color = isTeam and Config.Theme.Team or Config.Theme.Accent

                                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                                local height = math.abs(headPos.Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
                                local width = math.clamp(height / 1.8, 10, 300)

                                esp.Box.Visible = true; esp.Box.Size = Vector2.new(width, height)
                                esp.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2); esp.Box.Color = color

                                local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                                esp.Name.Visible = true; esp.Name.Text = plr.DisplayName .. " [" .. tostring(dist) .. "m]"
                                esp.Name.Position = Vector2.new(pos.X, esp.Box.Position.Y - 16); esp.Name.Color = color

                                esp.HealthBar.Visible = true
                                local hpPercent = (hum and hum.MaxHealth > 0) and math.clamp(hum.Health / hum.MaxHealth, 0, 1) or 1
                                esp.HealthBar.Color = Color3.fromRGB(math.floor(255 * (1 - hpPercent)), math.floor(255 * hpPercent), 0)
                                esp.HealthBar.From = Vector2.new(esp.Box.Position.X - 5, esp.Box.Position.Y + height)
                                esp.HealthBar.To = Vector2.new(esp.Box.Position.X - 5, esp.Box.Position.Y + height - height * hpPercent)
                            else
                                esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false
                            end
                        else
                            esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false
                        end
                    else
                        esp.Box.Visible = false; esp.Name.Visible = false; esp.HealthBar.Visible = false
                    end
                end
            else
                for _, esp in pairs(Storage.ESPObjects) do
                    if esp.Box then esp.Box.Visible = false end
                    if esp.Name then esp.Name.Visible = false end
                    if esp.HealthBar then esp.HealthBar.Visible = false end
                end
            end

            -- Crosshair
            if Config.States.Crosshair and Storage.CrosshairLines.H then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                Storage.CrosshairLines.H.Visible = true
                Storage.CrosshairLines.H.From = Vector2.new(center.X - 10, center.Y)
                Storage.CrosshairLines.H.To = Vector2.new(center.X + 10, center.Y)
                Storage.CrosshairLines.V.Visible = true
                Storage.CrosshairLines.V.From = Vector2.new(center.X, center.Y - 10)
                Storage.CrosshairLines.V.To = Vector2.new(center.X, center.Y + 10)
            elseif Storage.CrosshairLines.H then
                Storage.CrosshairLines.H.Visible = false; Storage.CrosshairLines.V.Visible = false
            end
        end
    end))

    -- Heartbeat: HeadExpander & Movement
    TrackConn(Services.RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        -- Head Expander
        if Config.States.HeadExpander then
            for _, p in pairs(Services.Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if Config.States.TeamCheck and Utils.IsTeammate(p) then continue end
                    local eHum = p.Character:FindFirstChildOfClass("Humanoid")
                    local eHead = p.Character:FindFirstChild("Head")
                    if eHum and eHead and eHum.Health > 0 then
                        if not eHead:GetAttribute("OrigHeadSize") then
                            eHead:SetAttribute("OrigHeadSize", eHead.Size)
                        end
                        eHead.Size = Vector3.new(Config.Vals.HeadSize, Config.Vals.HeadSize, Config.Vals.HeadSize)
                        eHead.Transparency = 0.6; eHead.CanCollide = false
                    end
                end
            end
        end

        -- Fly
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isMiniPlus and Config.States.SilentAim and not HasMiniMetamethodHook then
            MiniMicroFlickSilentAim()
        end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Storage.IsRightMouseDown = true
        end

        -- Menu Toggle: Process before gpe so Roblox CoreGui / chat sink does not swallow toggle
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isMiniPlus and Config.States.SilentAim and not HasMiniMetamethodHook then
            MiniMicroFlickSilentAim()
        end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Storage.IsRightMouseDown = false
        end
    end))

    task.spawn(function()
        while true do
            task.wait(1.0)
            -- Lightweight 1s cache sync for seamless round respawns
            for _, p in pairs(Services.Players:GetPlayers()) do
                if p ~= LocalPlayer and (not Storage.PlayerCache[p] or not Storage.PlayerCache[p].Char.Parent) then
                    CachePlayer(p)
                end
            end
            if Config.States.Chams then
                pcall(Utils.UpdateChams)
            end
            if Config.States.ItemESP then
                pcall(UpdateItemESP)
            end
        end
    end)

    if isMiniPlus then
        Notify("👑 X MINI+", "Press [Insert] or [Right-Ctrl] for Menu! Silent Aim unlocked.")
        print("👑 [X MINI+] PRIVILEGE UNLOCKED: Multi-Layer Silent Aim Active! [Insert] or [Right-Ctrl] for Menu")
    else
        Notify("X MINI V4.0", "Combat Edition Ready! [Insert] or [Right-Ctrl] for Menu [End] Unload")
    end
end

Init()
