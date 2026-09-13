-- [[ X SUITE - UNIVERSAL CLOUD LOADER ]]
-- Seller: vlilayz | Supported: Delta (Mobile) / Xeno / Solara (PC)
-- ==================================================================
-- USAGE:
-- getgenv().Key = "YOUR_KEY_HERE"
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/XT-7789/Project-X-Nexus/main/Loader.lua"))()
-- ==================================================================

local Services = {
	Players = game:GetService("Players"),
	HttpService = game:GetService("HttpService"),
	StarterGui = game:GetService("StarterGui"),
	UIS = game:GetService("UserInputService")
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
	return game:HttpGet(url .. sep .. "t=" .. tostring(math.floor(tick())))
end

local key = getgenv().Key or getgenv().ScriptKey or script_key

if not key or key == "" or key == "PASTE_YOUR_KEY_HERE" or key == "YOUR_KEY_HERE" then
	Notify("❌ X SUITE", "Key Required! Please set getgenv().Key before executing.", 5)
	warn("[X SUITE] Error: Key required! Purchase keys from Discord: vlilayz")
	return
end

local isMasterMiniPlus = (string.upper(tostring(key)) == "X-MINI-PRO-X")
local isMasterNanoPlus = (string.upper(tostring(key)) == "X-NANO-PRO-X")
local tier

Notify("⚡ X SUITE", "Authenticating Key & Verifying HWID...", 2)

local hwid = GetHWID()
print("🔑 [X SUITE AUTH] Verifying Key: " .. tostring(key) .. " | Device HWID: " .. tostring(hwid))
local verifyUrl = "https://x-auth.alex-x-7789-x.workers.dev/verify?key=" .. tostring(key) .. "&hwid=" .. tostring(hwid)

local success, response = pcall(function()
	return game:HttpGet(verifyUrl)
end)

print("📡 [X SUITE AUTH] Cloud Server Response: " .. tostring(response))

if not success or not response then
	Notify("❌ X SUITE", "Connection Error! Could not reach Auth Server.", 4)
	warn("[X SUITE] Connection Error: " .. tostring(response))
	return
end

local ok, data = pcall(function()
	return Services.HttpService:JSONDecode(response)
end)

if not ok or not data then
	Notify("❌ X SUITE", "Invalid response from Auth Server.", 4)
	return
end

if not data.success then
	Notify("❌ AUTH FAILED", data.message or "Authentication failed.", 5)
	warn("[X SUITE] Auth Error: " .. tostring(data.message))
	return
end

tier = data.tier or (isMasterNanoPlus and "Nano" or (isMasterMiniPlus and "Mini" or "Nano"))

if isMasterNanoPlus then
	Notify("👑 X NANO+ PRIVILEGED", "Founder Key X-NANO-PRO-X Verified! Silent Aim Unlocked.", 3)
elseif isMasterMiniPlus then
	Notify("👑 X MINI+ PRIVILEGED", "Founder Key X-MINI-PRO-X Verified! Silent Aim Unlocked.", 3)
end

-- Set one-time security authentication token for guarded scripts
getgenv()._X_AUTH_TOKEN = "X_NEXUS_VERIFIED_7789"

local repo = "https://raw.githubusercontent.com/XT-7789/Project-X-Nexus/main/"
local isMobile = Services.UIS.TouchEnabled and not Services.UIS.KeyboardEnabled
Notify("✅ SUCCESS", "Welcome! Loading X " .. tostring(tier) .. "...", 3)
print("==========================================")
print("✅ [PROJECT X NEXUS] ACCESS GRANTED")
if isMasterNanoPlus then
	print("👑 X NANO+ V3.1.0 [PRO-X EDITION] LOADED - SILENT AIM UNLOCKED")
elseif isMasterMiniPlus then
	print("👑 X MINI+ V4.0.1 [PRO-X EDITION] LOADED - SILENT AIM UNLOCKED")
elseif string.lower(tier) == "litem" then
	print("📱 X LITEM V1.0.0 LOADED")
elseif string.lower(tier) == "lite" then
	print(isMobile and "📱 X LITEM V1.0.0 LOADED" or "🎁 X LITE V1.0.0 LOADED")
elseif string.lower(tier) == "mini" then
	print("📦 X MINI V4.0.1 LOADED")
elseif string.lower(tier) == "minim" then
	print("📱 X MINIM V4.0.1 LOADED")
elseif string.lower(tier) == "prom" then
	print("📱 X PROM V3.2.1 LOADED")
elseif string.lower(tier) == "nanom" then
	print("📱 X NANOM V3.1.0 LOADED")
elseif string.lower(tier) == "nano" then
	print(isMobile and "📱 X NANOM V3.1.0 LOADED" or "🪶 X NANO V3.1.0 LOADED")
elseif string.lower(tier) == "pro" then
	print(isMobile and "📱 X PROM V3.2.1 LOADED" or "⚡ X PRO V3.2.1 LOADED")
elseif string.lower(tier) == "titan" then
	print("🔥 X TITAN V5.3.1 [VOID WALKER] LOADED")
else
	print("⚡ X " .. string.upper(tostring(tier)) .. " LOADED")
end
print("👑 FOUNDER & DEV : XT-7789")
print("💬 DISCORD SELLER: vlilayz")
print("==========================================")

if isMasterNanoPlus then
	if isMobile then
		loadstring(SafeHttpGet(repo .. "X%20NANOM.lua"))()
	else
		loadstring(SafeHttpGet(repo .. "X%20NANO.lua"))()
	end
elseif isMasterMiniPlus then
	if isMobile then
		loadstring(SafeHttpGet(repo .. "X%20MINIM.lua"))()
	else
		loadstring(SafeHttpGet(repo .. "X%20MINI.lua"))()
	end
elseif string.lower(tier) == "litem" then
	loadstring(SafeHttpGet(repo .. "X%20LITEM.lua"))()
elseif string.lower(tier) == "lite" then
	if isMobile then
		loadstring(SafeHttpGet(repo .. "X%20LITEM.lua"))()
	else
		loadstring(SafeHttpGet(repo .. "X%20LITE.lua"))()
	end
elseif string.lower(tier) == "prom" then
	loadstring(SafeHttpGet(repo .. "X%20PROM.lua"))()
elseif string.lower(tier) == "minim" then
	loadstring(SafeHttpGet(repo .. "X%20MINIM.lua"))()
elseif string.lower(tier) == "nanom" then
	loadstring(SafeHttpGet(repo .. "X%20NANOM.lua"))()
elseif string.lower(tier) == "nano" then
	if isMobile then
		loadstring(SafeHttpGet(repo .. "X%20NANOM.lua"))()
	else
		loadstring(SafeHttpGet(repo .. "X%20NANO.lua"))()
	end
elseif string.lower(tier) == "mini" then
	loadstring(SafeHttpGet(repo .. "X%20MINI.lua"))()
elseif string.lower(tier) == "pro" then
	if isMobile then
		loadstring(SafeHttpGet(repo .. "X%20PROM.lua"))()
	else
		loadstring(SafeHttpGet(repo .. "X%20PRO.lua"))()
	end
elseif string.lower(tier) == "titan" then
	loadstring(SafeHttpGet(repo .. "X%20TITAN.lua"))()
else
	loadstring(SafeHttpGet(repo .. "X%20NANO.lua"))()
end
