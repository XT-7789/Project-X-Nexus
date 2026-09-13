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
	if gethwid then return tostring(gethwid()) end
	if syn and syn.get_hwid then return tostring(syn.get_hwid()) end
	local ok, clientId = pcall(function()
		return game:GetService("RbxAnalyticsService"):GetClientId()
	end)
	if ok and clientId and clientId ~= "" then return tostring(clientId) end
	return tostring(LocalPlayer.UserId) .. "_DEV"
end

local key = getgenv().Key or getgenv().ScriptKey or script_key

if not key or key == "" or key == "PASTE_YOUR_KEY_HERE" or key == "YOUR_KEY_HERE" then
	Notify("❌ X SUITE", "Key Required! Please set getgenv().Key before executing.", 5)
	warn("[X SUITE] Error: Key required! Purchase keys from Discord: vlilayz")
	return
end

Notify("⚡ X SUITE", "Authenticating Key & Verifying HWID...", 2)

local hwid = GetHWID()
local verifyUrl = "https://x-auth.alex-x-7789-x.workers.dev/verify?key=" .. tostring(key) .. "&hwid=" .. tostring(hwid)

local success, response = pcall(function()
	return game:HttpGet(verifyUrl)
end)

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

-- Set one-time security authentication token for guarded scripts
getgenv()._X_AUTH_TOKEN = "X_NEXUS_VERIFIED_7789"

local repo = "https://raw.githubusercontent.com/XT-7789/Project-X-Nexus/main/"
local isMobile = Services.UIS.TouchEnabled and not Services.UIS.KeyboardEnabled

-- Success! Dispatch correct script tier
local tier = data.tier or "Nano"
Notify("✅ SUCCESS", "Welcome! Loading X " .. tostring(tier) .. "...", 3)
print("==========================================")
print("✅ [PROJECT X NEXUS] ACCESS GRANTED")
if string.lower(tier) == "mini" then
	print("📦 X MINI V4.0.0 LOADED")
elseif string.lower(tier) == "minim" then
	print("📱 X MINIM V4.0.0 LOADED")
elseif string.lower(tier) == "prom" then
	print("📱 X PROM V3.0.0 LOADED")
elseif string.lower(tier) == "nanom" then
	print("📱 X NANOM V3.0.0 LOADED")
elseif string.lower(tier) == "nano" then
	print(isMobile and "📱 X NANOM V3.0.0 LOADED" or "🪶 X NANO V3.0.0 LOADED")
elseif string.lower(tier) == "pro" then
	print(isMobile and "📱 X PROM V3.0.0 LOADED" or "⚡ X PRO V3.0.0 LOADED")
elseif string.lower(tier) == "titan" then
	print("🔥 X TITAN V5.0.0 (TITAN GOD) LOADED")
else
	print("⚡ X " .. string.upper(tostring(tier)) .. " LOADED")
end
print("👑 FOUNDER & DEV : XT-7789")
print("💬 DISCORD SELLER: vlilayz")
print("==========================================")

if string.lower(tier) == "prom" then
	loadstring(game:HttpGet(repo .. "X%20PROM.lua"))()
elseif string.lower(tier) == "minim" then
	loadstring(game:HttpGet(repo .. "X%20MINIM.lua"))()
elseif string.lower(tier) == "nanom" then
	loadstring(game:HttpGet(repo .. "X%20NANOM.lua"))()
elseif string.lower(tier) == "nano" then
	if isMobile then
		loadstring(game:HttpGet(repo .. "X%20NANOM.lua"))()
	else
		loadstring(game:HttpGet(repo .. "X%20NANO.lua"))()
	end
elseif string.lower(tier) == "mini" then
	loadstring(game:HttpGet(repo .. "X%20MINI"))()
elseif string.lower(tier) == "pro" then
	if isMobile then
		loadstring(game:HttpGet(repo .. "X%20PROM.lua"))()
	else
		loadstring(game:HttpGet(repo .. "X%20PRO.lua"))()
	end
elseif string.lower(tier) == "titan" then
	loadstring(game:HttpGet(repo .. "X%20TITAN.lua"))()
else
	loadstring(game:HttpGet(repo .. "X%20NANO.lua"))()
end
