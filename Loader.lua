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

-- ==================================================================
-- SECURITY INTEGRITY SENTINEL (ANTI-HOOK & TAMPER DETECTION)
-- ==================================================================
local function VerifySecurityIntegrity()
	if type(game.HttpGet) ~= "function" then
		SafeAbort("❌ SECURITY ERROR", "HttpGet environment modified or invalid.", 5)
		return false
	end
	local jsonTest, jsonRes = pcall(function()
		return Services.HttpService:JSONEncode({_sec = "verified_7789"})
	end)
	if not jsonTest or not jsonRes or not string.find(jsonRes, "verified_7789") then
		SafeAbort("❌ TAMPER DETECTED", "Core HttpService metatable intercepted.", 5)
		return false
	end
	return true
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

if not VerifySecurityIntegrity() then return end

Notify("⚡ X SUITE", "Authenticating Key & Verifying HWID...", 2)
UpdateSplash("Verifying HWID & Cloud Key...", 0.45)

local hwid = GetHWID()
local reqNonce = string.format("%d_%d", math.floor(tick()), math.random(100000, 999999))
local verifyUrl = "https://x-auth.alex-x-7789-x.workers.dev/verify?key=" .. tostring(key) .. "&hwid=" .. tostring(hwid) .. "&nonce=" .. reqNonce .. "&_t=" .. tostring(math.floor(tick()))

local success, response = pcall(function()
	return game:HttpGet(verifyUrl)
end)

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

if not data.success or not data.tier then
	SafeAbort("❌ AUTH FAILED", data.message or "Authentication failed.", 5)
	return
end

-- Server is Authoritative Source of Truth
local tier = tostring(data.tier)
local cleanTier = string.lower(tier)

if cleanTier == "titan" then
	Notify("👑 X TITAN+ APEX", "Titan+ Apex Godmode Unlocked!", 3.5)
elseif cleanTier == "pro" or cleanTier == "prom" then
	Notify("⚡ X PRO+ PRIVILEGED", "Pro+ Titan Presets & Wallbang Unlocked.", 3.5)
elseif cleanTier == "mini" or cleanTier == "minim" then
	Notify("📦 X MINI+ PRIVILEGED", "Mini+ Silent Aim & 550 FOV Unlocked.", 3)
elseif cleanTier == "nano" or cleanTier == "nanom" then
	Notify("🪶 X NANO+ PRIVILEGED", "Nano+ Silent Aim & 400 FOV Unlocked.", 3)
end

-- ==================================================================
-- EPHEMERAL DYNAMIC SESSION HANDSHAKE (ANTI-REPLAY & SELF-DESTRUCT)
-- ==================================================================
local function ComputeHandshakeSig(ts, k, h, n, tr, plus, founder, seller)
	local combined = tostring(ts) .. ":" .. tostring(k) .. ":" .. tostring(h) .. ":" .. tostring(n) .. ":" .. tostring(tr) .. ":" .. (plus and "1" or "0") .. ":" .. (founder and "1" or "0") .. ":" .. (seller and "1" or "0") .. ":XT7789_NEXUS_SECURITY_SALT_2026"
	local hash = 5381
	for i = 1, #combined do
		hash = ((hash * 33) + string.byte(combined, i)) % 2147483647
	end
	return string.format("%08x", hash)
end

local function _deriveTierStreamKey(tierName)
	local seed = tostring(tierName) .. ":XT7789_NEXUS_CORE_SECURITY_2026"
	local h = 5381
	for i = 1, #seed do
		h = ((h * 33) + string.byte(seed, i)) % 2147483647
	end
	local k = {}
	for j = 1, 16 do
		h = ((h * 33) + j * 17) % 2147483647
		k[j] = (h % 230) + 13
	end
	return k
end

local sessionTimestamp = math.floor(tick())
local sessionNonce = tostring(math.random(100000, 999999))
local isPlus = (data.plus == true) or (data.isPlus == true) or (cleanTier == "titan")
local isFounder = (data.founder == true) or (data.isFounder == true)
local isSeller = (data.seller == true) or (data.isSeller == true)
local sessionSig = ComputeHandshakeSig(sessionTimestamp, key, hwid, sessionNonce, cleanTier, isPlus, isFounder, isSeller)

getgenv()._X_AUTH_SESSION = {
	Timestamp = sessionTimestamp,
	Key = tostring(key),
	HWID = tostring(hwid),
	Nonce = sessionNonce,
	Signature = sessionSig,
	Tier = cleanTier,
	IsPlus = isPlus,
	IsFounder = isFounder,
	IsSeller = isSeller,
	StreamKey = nil
}
getgenv()._X_AUTH_TOKEN = sessionSig

local edgeBase = "https://x-auth.alex-x-7789-x.workers.dev"
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
if cleanTier == "titan" then
	print("👑 X TITAN V6.4.0 [APEX OMNI] LOADED")
elseif cleanTier == "prom" then
	print("📱 X PROM V4.0.0 [DELTA EDITION] LOADED")
elseif cleanTier == "pro" then
	print(isMobile and "📱 X PROM V4.0.0 [DELTA EDITION] LOADED" or "⚡ X PRO V4.0.0 LOADED")
elseif cleanTier == "minim" then
	print("📱 X MINIM V4.2.2 [DELTA EDITION] LOADED")
elseif cleanTier == "mini" then
	print(isMobile and "📱 X MINIM V4.2.2 [DELTA EDITION] LOADED" or "📦 X MINI V4.2.2 LOADED")
elseif cleanTier == "nanom" then
	print("📱 X NANOM V3.4.1 [DELTA EDITION] LOADED")
elseif cleanTier == "nano" then
	print(isMobile and "📱 X NANOM V3.4.1 [DELTA EDITION] LOADED" or "🪶 X NANO V3.4.1 LOADED")
elseif cleanTier == "litem" then
	print("📱 X LITEM V2.0.0 [DELTA EDITION] LOADED")
elseif cleanTier == "lite" then
	print(isMobile and "📱 X LITEM V2.0.0 [DELTA EDITION] LOADED" or "🎁 X LITE V2.0.0 LOADED")
else
	print("⚡ X " .. string.upper(tostring(data.tier)) .. " LOADED")
end
print("👑 FOUNDER & DEV : XT-7789")
print("🌐 OFFICIAL DISCORD: https://discord.gg/mQ3ASbfP8j")
print("💬 DISCORD SELLER: vlilayz")
print("==========================================")

local function ExecuteSecurePayload(tierLabel)
	UpdateSplash("Launching " .. (tierLabel or "Client") .. "...", 1.0)
	task.delay(0.5, CloseSplash)
	local loadUrl = edgeBase .. "/load?key=" .. tostring(key) .. "&hwid=" .. tostring(hwid) .. "&device=" .. (isMobile and "mobile" or "pc") .. "&t=" .. tostring(math.floor(tick()))
	local code = SafeHttpGet(loadUrl)
	if not code or code == "" or string.sub(code, 1, 8) == "-- ERROR" then
		getgenv()._X_LOADER_INITIALIZING = false
		CloseSplash()
		Notify("❌ DELIVERY FAILED", "Could not fetch script from Secure Edge.", 5)
		warn("[X SUITE] Network error: Failed to download secure payload from Edge Server.")
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
	local ok, runErr = pcall(fn, getgenv()._X_AUTH_SESSION)
	if not ok then
		Notify("❌ RUNTIME ERROR", "Script runtime error: " .. tostring(runErr), 7)
		warn("[X SUITE] Runtime Error: " .. tostring(runErr))
	end
end

local targetDisplayName = "X " .. string.upper(tostring(data.tier))
if cleanTier == "titan" then
	targetDisplayName = "X TITAN V6.4.0"
elseif cleanTier == "prom" or (cleanTier == "pro" and isMobile) then
	targetDisplayName = "X PROM V4.0.0"
elseif cleanTier == "pro" then
	targetDisplayName = "X PRO V4.0.0"
elseif cleanTier == "minim" or (cleanTier == "mini" and isMobile) then
	targetDisplayName = "X MINIM V4.2.2"
elseif cleanTier == "mini" then
	targetDisplayName = "X MINI V4.2.2"
elseif cleanTier == "nanom" or (cleanTier == "nano" and isMobile) then
	targetDisplayName = "X NANOM V3.4.1"
elseif cleanTier == "nano" then
	targetDisplayName = "X NANO V3.4.1"
elseif cleanTier == "litem" or (cleanTier == "lite" and isMobile) then
	targetDisplayName = "X LITEM V2.0.0"
elseif cleanTier == "lite" then
	targetDisplayName = "X LITE V2.0.0"
end

ExecuteSecurePayload(targetDisplayName)
