local ReplicatedStorage = game:GetService("ReplicatedStorage")
local captchaRemote = ReplicatedStorage:WaitForChild("CaptchaRemote")
local setupCaptchaRemote = captchaRemote:WaitForChild("SetupCaptcha")

setupCaptchaRemote.OnClientEvent:Connect(function(cardImage, lockoutStep, attemptsRemaining)

end)
