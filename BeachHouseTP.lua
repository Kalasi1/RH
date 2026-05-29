local placeId = game.PlaceId
repeat
    game:GetService("ReplicatedStorage").SceptorTeleport:FireServer("New Royale")
    task.wait(5)
until game.PlaceId ~= placeId
