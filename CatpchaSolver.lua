local LP = game:GetService("Players").LocalPlayer
local captchaGui = LP.PlayerGui.CardCaptchaGame
local captcha = LP.PlayerGui.CardCaptchaGame.CaptchaGame

local captchaMap = {
    [15220541977] = 1,
    [15220896509] = 2,
    [15238170924] = 3,
    [15246149118] = 4,
    [15246674578] = 5,
    [15270045569] = 6,
    [15277668364] = 7,
    [15277827984] = 8,
    [15278319081] = 9,
    [15278574393] = 10,
    [15279290990] = 11,
    [15279858892] = 12,
    [15280238825] = 13,
    [15280730515] = 14,
    [15281069567] = 15,
}

function solve()
    local assetid = string.match(captcha.Top.Card.Image, "%d+")
    if assetid then
        task.wait(math.random(5, 15))
        game:GetService("ReplicatedStorage"):WaitForChild("CaptchaRemote"):WaitForChild("SetupCaptcha"):FireServer(captchaMap[assetid])
    end
end

captchaGui:GetPropertyChangedSignal("Enabled"):Connect(solve)
