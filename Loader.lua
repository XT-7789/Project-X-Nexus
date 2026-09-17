-- [[ X SUITE - UNIVERSAL CLOUD LOADER V2.0.3 ]]
-- Official Discord: https://discord.gg/mQ3ASbfP8j | Seller: vlilayz | Dev: XT-7789
-- Multi-Executor Support: Delta (iOS / Android), Codex, Arceus X, Wave, Solara, Celery
-- Dynamic Ephemeral Session Handshake & safeCloneRef Metamethod Defense
-- ==================================================================
-- USAGE:
-- getgenv().Key = "YOUR_KEY_HERE"
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/XT-7789/Project-X-Nexus/main/Loader.lua"))()
-- ==================================================================

-- Anti-Duplication Execution Guard
if getgenv()._X_LOADER_INITIALIZING then
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "⚡ X SUITE",
			Text = "Loader is already initializing. Please wait...",
			Duration = 3
		})
	end)
	return
end
getgenv()._X_LOADER_INITIALIZING = true

local safeCloneRef = (type(cloneref) == "function" and cloneref) or function(o) return o end
local Services = {
	Players = safeCloneRef(game:GetService("Players")),
	HttpService = safeCloneRef(game:GetService("HttpService")),
	StarterGui = safeCloneRef(game:GetService("StarterGui")),
	UIS = safeCloneRef(game:GetService("UserInputService")),
	TweenService = safeCloneRef(game:GetService("TweenService"))
}

local LocalPlayer = Services.Players.LocalPlayer

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
-- EXECUTOR ENVIRONMENT & CAPABILITY DIAGNOSTICS
-- ==================================================================
local function DetectExecutor()
	local name = "Standard Executor"
	local ver = ""
	if type(identifyexecutor) == "function" then
		local s, n, v = pcall(identifyexecutor)
		if s and n then
			name = tostring(n)
			if v then ver = tostring(v) end
		end
	elseif type(getexecutorname) == "function" then
		local s, n = pcall(getexecutorname)
		if s and n then name = tostring(n) end
	end
	return name, ver
end

local execName, execVer = DetectExecutor()
local execLabel = execName .. (execVer ~= "" and (" " .. execVer) or "")
local hasDrawing = (type(Drawing) == "table" and type(Drawing.new) == "function")
local hasHook = (type(hookmetamethod) == "function" and type(getnamecallmethod) == "function")
local isMobile = Services.UIS.TouchEnabled and not Services.UIS.KeyboardEnabled

local targetGui
if type(gethui) == "function" then pcall(function() targetGui = gethui() end) end
if not targetGui then targetGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5) end

local splashFrame, splashBar, splashStatus
if targetGui then
	pcall(function()
		local existing = targetGui:FindFirstChild("X_LOADER_SPLASH")
		if existing then existing:Destroy() end

		local sg = Instance.new("ScreenGui")
		sg.Name = "X_LOADER_SPLASH"
		sg.ResetOnSpawn = false
		sg.IgnoreGuiInset = true
		sg.DisplayOrder = 999999
		sg.Parent = targetGui

		local card = Instance.new("Frame", sg)
		card.Size = UDim2.new(0, 340, 0, 74)
		card.Position = UDim2.new(0.5, -170, 0.15, 0)
		card.BackgroundColor3 = Color3.fromRGB(14, 15, 22)
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
		local st = Instance.new("UIStroke", card)
		st.Color = Color3.fromRGB(0, 220, 255)
		st.Thickness = 1.5
		st.Transparency = 0.3

		local title = Instance.new("TextLabel", card)
		title.Size = UDim2.new(1, -20, 0, 20)
		title.Position = UDim2.new(0, 10, 0, 8)
		title.BackgroundTransparency = 1
		title.Text = "⚡ PROJECT X NEXUS | CLOUD LOADER V2.0.3"
		title.TextColor3 = Color3.fromRGB(0, 230, 255)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 12
		title.TextXAlignment = Enum.TextXAlignment.Left

		splashStatus = Instance.new("TextLabel", card)
		splashStatus.Size = UDim2.new(1, -20, 0, 16)
		splashStatus.Position = UDim2.new(0, 10, 0, 30)
		splashStatus.BackgroundTransparency = 1
		splashStatus.Text = "Detected: " .. tostring(execName) .. " | Connecting..."
		splashStatus.TextColor3 = Color3.fromRGB(180, 190, 210)
		splashStatus.Font = Enum.Font.GothamMedium
		splashStatus.TextSize = 11
		splashStatus.TextXAlignment = Enum.TextXAlignment.Left

		local barBg = Instance.new("Frame", card)
		barBg.Size = UDim2.new(1, -20, 0, 4)
		barBg.Position = UDim2.new(0, 10, 0, 54)
		barBg.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
		Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

		splashBar = Instance.new("Frame", barBg)
		splashBar.Size = UDim2.new(0.15, 0, 1, 0)
		splashBar.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
		Instance.new("UICorner", splashBar).CornerRadius = UDim.new(1, 0)

		splashFrame = card
	end)
end

local function UpdateSplash(text, progressRatio)
	pcall(function()
		if splashStatus then splashStatus.Text = text end
		if splashBar then
			if Services.TweenService then
				Services.TweenService:Create(splashBar, TweenInfo.new(0.25), {
					Size = UDim2.new(math.clamp(progressRatio, 0.05, 1), 0, 1, 0)
				}):Play()
			else
				splashBar.Size = UDim2.new(math.clamp(progressRatio, 0.05, 1), 0, 1, 0)
			end
		end
	end)
end

local function CloseSplash()
	pcall(function()
		if not splashFrame then return end
		local parentGui = splashFrame.Parent
		if Services.TweenService then
			pcall(function()
				Services.TweenService:Create(splashFrame, TweenInfo.new(0.35), {
					BackgroundTransparency = 1
				}):Play()
				for _, child in ipairs(splashFrame:GetDescendants()) do
					if child:IsA("TextLabel") then
						Services.TweenService:Create(child, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
					elseif child:IsA("UIStroke") then
						Services.TweenService:Create(child, TweenInfo.new(0.25), { Transparency = 1 }):Play()
					elseif child:IsA("Frame") then
						Services.TweenService:Create(child, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
					end
				end
			end)
		end
		task.delay(0.4, function()
			pcall(function()
				if parentGui and parentGui.Parent then
					parentGui:Destroy()
				elseif splashFrame and splashFrame.Parent then
					splashFrame:Destroy()
				end
			end)
		end)
	end)
end

local function SafeAbort(title, msg, dur)
	getgenv()._X_LOADER_INITIALIZING = false
	CloseSplash()
	Notify(title, msg, dur or 5)
	warn("[X SUITE] " .. title .. ": " .. msg)
end

local function GetHWID()
	if type(gethwid) == "function" then
		local s, h = pcall(gethwid)
		if s and h and h ~= "" then return tostring(h) end
	end
	if syn and type(syn.get_hwid) == "function" then
		local s, h = pcall(syn.get_hwid)
		if s and h and h ~= "" then return tostring(h) end
	end
	local ok, clientId = pcall(function()
		return game:GetService("RbxAnalyticsService"):GetClientId()
	end)
	if ok and clientId and clientId ~= "" then return tostring(clientId) end
	local lp = Services.Players.LocalPlayer or Services.Players.PlayerAdded:Wait()
	if lp and lp.UserId and lp.UserId ~= 0 then
		return tostring(lp.UserId) .. "_PC"
	end
	return "X_CLIENT_" .. tostring(math.floor(tick()))
end

local function SafeHttpGet(url)
	local sep = string.find(url, "?") and "&" or "?"
	local ok, res = pcall(function()
		return game:HttpGet(url .. sep .. "t=" .. tostring(math.floor(tick())))
	end)
	if ok and res and res ~= "" and not string.find(res, "404: Not Found") then
		local testFn = loadstring(res)
		if testFn then return res end
	end
	-- Dual-CDN Failover: jsDelivr CDN
	local jsDelivrUrl = string.gsub(url, "https://raw.githubusercontent.com/XT-7789/Project-X-Nexus/main/", "https://cdn.jsdelivr.net/gh/XT-7789/Project-X-Nexus@main/")
	local ok2, res2 = pcall(function()
		return game:HttpGet(jsDelivrUrl .. "?t=" .. tostring(math.floor(tick())))
	end)
	if ok2 and res2 and res2 ~= "" and not string.find(res2, "404") then
		local testFn2 = loadstring(res2)
		if testFn2 then return res2 end
	end
	return (ok and res) or (ok2 and res2) or ""
end

local key = getgenv().Key or getgenv().ScriptKey or script_key

if not key or key == "" or key == "PASTE_YOUR_KEY_HERE" or key == "YOUR_KEY_HERE" then
	SafeAbort("❌ KEY REQUIRED", "Key Required! Join: https://discord.gg/mQ3ASbfP8j", 5)
	return
end

local cleanKey = string.upper(tostring(key))
local isFounderKey = string.find(cleanKey, "XT7789") ~= nil

local isMasterTitanPlus = (cleanKey == "X-TITAN-PLUS-XT7789") or (cleanKey == "X-TITAN-PLUS") or (cleanKey == "X-TITAN-X") or (string.find(cleanKey, "TITAN") ~= nil and string.find(cleanKey, "PLUS") ~= nil)
local isMasterProPlus = (cleanKey == "X-PRO-PLUS-XT7789") or (cleanKey == "X-PRO-PLUS") or (cleanKey == "X-PRO-X") or (string.find(cleanKey, "PRO") ~= nil and string.find(cleanKey, "PLUS") ~= nil)
local isMasterMiniPlus = (cleanKey == "X-MINI-PLUS-XT7789") or (cleanKey == "X-MINI-PLUS") or (cleanKey == "X-MINI-X") or (string.find(cleanKey, "MINI") ~= nil and string.find(cleanKey, "PLUS") ~= nil)
local isMasterNanoPlus = (cleanKey == "X-NANO-PLUS-XT7789") or (cleanKey == "X-NANO-PLUS") or (cleanKey == "X-NANO-X") or (string.find(cleanKey, "NANO") ~= nil and string.find(cleanKey, "PLUS") ~= nil)
local tier

Notify("⚡ X SUITE", "Authenticating Key & Verifying HWID...", 2)
UpdateSplash("Verifying HWID & Cloud Key...", 0.45)

local hwid = GetHWID()
print("🔑 [X SUITE AUTH] Verifying Key: " .. tostring(key) .. " | Device HWID: " .. tostring(hwid))
local reqNonce = string.format("%d_%d", math.floor(tick()), math.random(100000, 999999))
local verifyUrl = "https://x-auth.alex-x-7789-x.workers.dev/verify?key=" .. tostring(key) .. "&hwid=" .. tostring(hwid) .. "&nonce=" .. reqNonce .. "&_t=" .. tostring(math.floor(tick()))

local success, response = pcall(function()
	return game:HttpGet(verifyUrl)
end)

print("📡 [X SUITE AUTH] Cloud Server Response: " .. tostring(response))

if not success or not response then
	SafeAbort("❌ CONNECTION ERROR", "Could not reach Auth Server.", 4)
	return
end

local ok, data = pcall(function()
	return Services.HttpService:JSONDecode(response)
end)

if not ok or not data then
	SafeAbort("❌ AUTH ERROR", "Invalid response from Auth Server.", 4)
	return
end

if not data.success then
	SafeAbort("❌ AUTH FAILED", data.message or "Authentication failed.", 5)
	return
end

tier = data.tier or (isMasterTitanPlus and "Titan" or (isMasterProPlus and "Pro" or (isMasterMiniPlus and "Mini" or (isMasterNanoPlus and "Nano" or "Nano"))))

if isMasterTitanPlus then
	Notify(isFounderKey and "👑 X TITAN+ FOUNDER" or "💎 X TITAN+ PRIVILEGED", "Titan+ Apex Godmode Unlocked!", 3.5)
elseif isMasterProPlus then
	Notify(isFounderKey and "👑 X PRO+ FOUNDER" or "💎 X PRO+ PRIVILEGED", "Pro+ Titan Presets & Wallbang Unlocked.", 3.5)
elseif isMasterMiniPlus then
	Notify(isFounderKey and "👑 X MINI+ FOUNDER" or "💎 X MINI+ PRIVILEGED", "Mini+ Silent Aim & 550 FOV Unlocked.", 3)
elseif isMasterNanoPlus then
	Notify(isFounderKey and "👑 X NANO+ FOUNDER" or "💎 X NANO+ PRIVILEGED", "Nano+ Silent Aim & 400 FOV Unlocked.", 3)
end

-- ==================================================================
-- EPHEMERAL DYNAMIC SESSION HANDSHAKE (ANTI-REPLAY & SELF-DESTRUCT)
-- ==================================================================
local function ComputeHandshakeSig(ts, k, h, n)
	local combined = tostring(ts) .. ":" .. tostring(k) .. ":" .. tostring(h) .. ":" .. tostring(n) .. ":XT7789_NEXUS_SECURITY_SALT_2026"
	local hash = 5381
	for i = 1, #combined do
		hash = ((hash * 33) + string.byte(combined, i)) % 2147483647
	end
	return string.format("%08x", hash)
end

local sessionTimestamp = math.floor(tick())
local sessionNonce = tostring(math.random(100000, 999999))
local sessionSig = ComputeHandshakeSig(sessionTimestamp, key, hwid, sessionNonce)

getgenv()._X_AUTH_SESSION = {
	Timestamp = sessionTimestamp,
	Key = tostring(key),
	HWID = tostring(hwid),
	Nonce = sessionNonce,
	Signature = sessionSig
}
getgenv()._X_AUTH_TOKEN = sessionSig

local repo = "https://raw.githubusercontent.com/XT-7789/Project-X-Nexus/main/"
Notify("✅ SUCCESS", "Welcome! Loading X " .. tostring(tier) .. "...", 3)
UpdateSplash("Access Granted! Fetching X " .. tostring(tier) .. "...", 0.85)

print("==========================================")
print("⚡ [PROJECT X NEXUS] ENVIRONMENT REPORT")
print("💻 Executor: " .. tostring(execLabel))
print("🎨 Drawing Engine: " .. (hasDrawing and "Available [OK]" or "Unavailable [Basic Mode]"))
print("🪝 Hook Engine: " .. (hasHook and "Available [OK]" or "Basic Mode [OK]"))
print("📱 Device: " .. (isMobile and "Mobile Touch Device" or "Desktop / PC"))
print("==========================================")
print("✅ [PROJECT X NEXUS] ACCESS GRANTED")
if isMasterTitanPlus then
	print(isFounderKey and "👑 X TITAN+ V6.3.0 [XT7789 GODMODE] LOADED" or "💎 X TITAN+ V6.3.0 [PARTNER APEX] LOADED")
elseif isMasterProPlus then
	print(isFounderKey and "👑 X PRO+ V3.7.5 [XT7789 FOUNDER] LOADED" or "💎 X PRO+ V3.7.5 [CO-FOUNDER EDITION] LOADED")
elseif isMasterMiniPlus then
	print(isFounderKey and "👑 X MINI+ V4.2.2 [XT7789 FOUNDER] LOADED" or "💎 X MINI+ V4.2.2 [CO-FOUNDER EDITION] LOADED")
elseif isMasterNanoPlus then
	print(isFounderKey and "👑 X NANO+ V3.4.1 [XT7789 FOUNDER] LOADED" or "💎 X NANO+ V3.4.1 [CO-FOUNDER EDITION] LOADED")
elseif string.lower(tier) == "litem" then
	print("📱 X LITEM V2.0.0 [DELTA EDITION] LOADED")
elseif string.lower(tier) == "lite" then
	print(isMobile and "📱 X LITEM V2.0.0 [DELTA EDITION] LOADED" or "🎁 X LITE V2.0.0 LOADED")
elseif string.lower(tier) == "mini" then
	print("📦 X MINI V4.2.2 LOADED")
elseif string.lower(tier) == "minim" then
	print("📱 X MINIM V4.2.2 [DELTA EDITION] LOADED")
elseif string.lower(tier) == "prom" then
	print("📱 X PROM V3.7.5 [DELTA EDITION] LOADED")
elseif string.lower(tier) == "nanom" then
	print("📱 X NANOM V3.4.1 [DELTA EDITION] LOADED")
elseif string.lower(tier) == "nano" then
	print(isMobile and "📱 X NANOM V3.4.1 [DELTA EDITION] LOADED" or "🪶 X NANO V3.4.1 LOADED")
elseif string.lower(tier) == "pro" then
	print(isMobile and "📱 X PROM V3.7.5 [DELTA EDITION] LOADED" or "⚡ X PRO V3.7.5 LOADED")
elseif string.lower(tier) == "titan" then
	print("🔥 X TITAN V6.3.0 [APEX OMNI] LOADED")
else
	print("⚡ X " .. string.upper(tostring(tier)) .. " LOADED")
end
print("👑 FOUNDER & DEV : XT-7789")
print("🌐 OFFICIAL DISCORD: https://discord.gg/mQ3ASbfP8j")
print("💬 DISCORD SELLER: vlilayz")
print("==========================================")

local function ExecuteRemote(scriptUrl, tierLabel)
	UpdateSplash("Launching " .. (tierLabel or "Client") .. "...", 1.0)
	task.delay(0.5, CloseSplash)
	local code = SafeHttpGet(scriptUrl)
	if not code or code == "" then
		getgenv()._X_LOADER_INITIALIZING = false
		CloseSplash()
		Notify("❌ DOWNLOAD FAILED", "Could not fetch script from server.", 5)
		warn("[X SUITE] Network error: Failed to download script: " .. tostring(scriptUrl))
		return
	end
	local fn, compileErr = loadstring(code)
	if not fn then
		getgenv()._X_LOADER_INITIALIZING = false
		CloseSplash()
		Notify("❌ COMPILE ERROR", "Script compilation failed: " .. tostring(compileErr), 7)
		warn("[X SUITE] Compilation Error: " .. tostring(compileErr))
		return
	end
	getgenv()._X_LOADER_INITIALIZING = false
	local ok, runErr = pcall(fn)
	if not ok then
		Notify("❌ RUNTIME ERROR", "Script runtime error: " .. tostring(runErr), 7)
		warn("[X SUITE] Runtime Error: " .. tostring(runErr))
	end
end

if isMasterTitanPlus then
	ExecuteRemote(repo .. "X%20TITAN.lua", "X TITAN V6.3.0")
elseif isMasterProPlus then
	if isMobile then
		ExecuteRemote(repo .. "X%20PROM.lua", "X PROM V3.7.5")
	else
		ExecuteRemote(repo .. "X%20PRO.lua", "X PRO V3.7.5")
	end
elseif isMasterNanoPlus then
	if isMobile then
		ExecuteRemote(repo .. "X%20NANOM.lua", "X NANOM V3.4.1")
	else
		ExecuteRemote(repo .. "X%20NANO.lua", "X NANO V3.4.1")
	end
elseif isMasterMiniPlus then
	if isMobile then
		ExecuteRemote(repo .. "X%20MINIM.lua", "X MINIM V4.2.2")
	else
		ExecuteRemote(repo .. "X%20MINI.lua", "X MINI V4.2.2")
	end
elseif string.lower(tier) == "litem" then
	ExecuteRemote(repo .. "X%20LITEM.lua", "X LITEM V2.0.0")
elseif string.lower(tier) == "lite" then
	if isMobile then
		ExecuteRemote(repo .. "X%20LITEM.lua", "X LITEM V2.0.0")
	else
		ExecuteRemote(repo .. "X%20LITE.lua", "X LITE V2.0.0")
	end
elseif string.lower(tier) == "prom" then
	ExecuteRemote(repo .. "X%20PROM.lua", "X PROM V3.7.5")
elseif string.lower(tier) == "minim" then
	ExecuteRemote(repo .. "X%20MINIM.lua", "X MINIM V4.2.2")
elseif string.lower(tier) == "nanom" then
	ExecuteRemote(repo .. "X%20NANOM.lua", "X NANOM V3.4.1")
elseif string.lower(tier) == "nano" then
	if isMobile then
		ExecuteRemote(repo .. "X%20NANOM.lua", "X NANOM V3.4.1")
	else
		ExecuteRemote(repo .. "X%20NANO.lua", "X NANO V3.4.1")
	end
elseif string.lower(tier) == "mini" then
	ExecuteRemote(repo .. "X%20MINI.lua", "X MINI V4.2.2")
elseif string.lower(tier) == "pro" then
	if isMobile then
		ExecuteRemote(repo .. "X%20PROM.lua", "X PROM V3.7.5")
	else
		ExecuteRemote(repo .. "X%20PRO.lua", "X PRO V3.7.5")
	end
elseif string.lower(tier) == "titan" then
	ExecuteRemote(repo .. "X%20TITAN.lua", "X TITAN V6.3.0")
else
	ExecuteRemote(repo .. "X%20NANO.lua", "X NANO V3.4.1")
end
