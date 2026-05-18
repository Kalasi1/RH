local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- Wait for GUI
local captchaGui = LP.PlayerGui:WaitForChild("CardCaptchaGame")
local captcha = captchaGui:WaitForChild("CaptchaGame")
local topCard = captcha:WaitForChild("Top"):WaitForChild("Card")
local remote = game:GetService("ReplicatedStorage"):WaitForChild("CaptchaRemote"):WaitForChild("SetupCaptcha")

local SERVER_URL = "http://localhost:5000/solve"

local function solve()
    local url = topCard.Image
    local assetId = string.match(url, "id=(%d+)")
    if not assetId then
        warn("No asset ID found")
        return
    end
    
    print("Solving captcha for ID:", assetId)
    
    local success, response = pcall(function()
        return game:HttpGet(SERVER_URL .. "?id=" .. assetId)
    end)
    
    if not success then
        warn("HTTP request failed:", response)
        return
    end
    
    local data = HttpService:JSONDecode(response)
    if data and data.success and data.index then
        print("Match found! Firing button", data.index)
        remote:FireServer(data.index)
    else
        warn("Server error:", data and data.error or "Unknown")
    end
end

-- Trigger when captcha appears
captchaGui:GetPropertyChangedSignal("Enabled"):Connect(function()
    if captchaGui.Enabled then
        task.wait(0.5)
        pcall(solve)
    end
end)

print("Captcha solver ready. Waiting for captcha...")
