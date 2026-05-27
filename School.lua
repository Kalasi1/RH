local services = setmetatable({},{__index = function(_,serv) return game:GetService(serv) end})
local classRemotes = services.ReplicatedStorage.Classes
local prevConnections = {}
local localPlayer = services.Players.LocalPlayer
local replicatedStorage = services.ReplicatedStorage

-- ========== DORM SLEEP ROUTINE ==========
local DORM_MODEL_NAME = "DormDoorNew5"
local hasClaimedOuter = false
local hasClaimedInner = false

local function setAnchored(anchor)
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = anchor end
end

local function waitForCharacter()
    while not localPlayer.Character do task.wait(0.5) end
    setAnchored(true)
    task.wait(1)
end

local function clickWithRetry(getButtonFunc, maxWait)
    maxWait = maxWait or 10
    local start = tick()
    while tick() - start < maxWait do
        local btn = getButtonFunc()
        if btn and btn:FindFirstChild("ClickDetector") then
            fireclickdetector(btn.ClickDetector)
            task.wait(1)
            return true
        end
        task.wait(0.5)
    end
    return false
end

local function teleportToCF(cf, waitSec)
    local char = localPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = cf
    if waitSec then task.wait(waitSec) end
    return true
end

local waitingCF = CFrame.new(25.3167267, 53.0552788, -286.714722, -0.216675967, 4.25862048e-08, -0.976243556, 6.17389446e-08, 1, 2.99196437e-08, 0.976243556, -5.37893818e-08, -0.216675967)
local insideCF = CFrame.new(-6922.93994, 10014.2715, -386.101746, 0.283114344, -3.35143575e-08, -0.95908618, 2.64535549e-09, 1, -3.41631647e-08, 0.95908618, 7.13495796e-09, 0.283114344)
local bedSurfaceCF = CFrame.new(-6942.38086, 10013.2285, -307.33725, 0.99999404, 0, 0.00345287542, 0, 1, 0, -0.00345287542, 0, 0.99999404)
local bedCF = bedSurfaceCF + Vector3.new(0, 4, 0)
local awayCF = CFrame.new(-6913.31982, 10012.6641, -321.106262, 0.501167297, 0, 0.865350425, 0, 1, 0, -0.865350425, 0, 0.501167297)

local function getOuterButton()
    local model = workspace:FindFirstChild(DORM_MODEL_NAME)
    if model then return model:FindFirstChild("DormOwnershipButton") end
    return nil
end

local function getInnerButton()
    local model = workspace:FindFirstChild(DORM_MODEL_NAME)
    if not model then return nil end
    local claimDoor = model:FindFirstChild("Dorm2") and model.Dorm2:FindFirstChild("ClaimDoor")
    if claimDoor then return claimDoor:FindFirstChild("DormRoomOwnershipButton") end
    return nil
end

local function performDormSleep()
    waitForCharacter()

    if not hasClaimedOuter then
        -- First time: claim outer door
        teleportToCF(waitingCF, 5)
        if clickWithRetry(getOuterButton, 10) then
            task.wait(5)
            hasClaimedOuter = true
        else
            setAnchored(false)
            return
        end
        teleportToCF(insideCF, 5)
        if clickWithRetry(getInnerButton, 10) then
            task.wait(5)
            hasClaimedInner = true
        else
            setAnchored(false)
            return
        end
    else
        -- Already claimed: go directly to bed
        teleportToCF(bedCF, 3)
    end

    setAnchored(false)
    task.wait(5)
    replicatedStorage.Bed.Anim:FireServer("Sleep", "All Tucked In", true)
    task.wait(120)  -- sleep for 2 minutes
    teleportToCF(awayCF, 2)
end

-- ========== CLASS AUTOMATION ==========
function fireBack(remote, times, ...)
    local args = {...}
    return remote.OnClientEvent:Connect(function()
        for i = 0, times do
            remote:FireServer(unpack(args))
        end
    end)
end

local classFuncs = {
    swimming = function()
        return {
            classRemotes.Timer.OnClientEvent:Connect(function()
                local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 10, 0)
                hrp.Anchored = true
                task.wait(55)
                if hrp then hrp.Anchored = false end
            end)
        }
    end,
    
    art = function() 
        local function getCanvasData()
            local canvas = {}
            for _,part in next, workspace.ArtClassReal.MainEasel.CanvasToCopy:GetChildren() do
                canvas[part.Name] = part.BrickColor.Number
            end
            return canvas
        end
        local function fillCanvas()
            for name,num in next, getCanvasData() do
                replicatedStorage.Tools.Paint.SetColor:FireServer(workspace.ArtClassReal.Easel.Canvas:FindFirstChild(name), BrickColor.new(num))
            end
        end
        return {
            classRemotes.BookCheck.OnClientEvent:Connect(function()
                task.wait(1)
                fillCanvas()
            end)
        }
    end,
    
    computer = function()
        return {fireBack(classRemotes.Computer, 1, 1)}
    end,

    chemistry = function()
        return {fireBack(classRemotes.Chemistry, 1, "SequenceDone")}
    end,

    pe = function()
        return {
            classRemotes.Timer.OnClientEvent:Connect(function()
                localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1604, 20, 9)
                task.wait(1)
                if not workspace:FindFirstChild("PE Class") then return end
                fireclickdetector(workspace["PE Class"].Bell.ClickDetector, 4)
            end)   
        }
    end,
    
    english = function()
        local correctWords = {"Argument", "Enough", "Until", "Amateur", "Library", "Embarrassing", "Tongue", "Dessert", "February", "Accommodate", "a lot", "Beautiful"}
        local frame = localPlayer.PlayerGui.EnglishClass.Frame
        return {
            frame.question:GetPropertyChangedSignal("Text"):Connect(function()
                if frame.question.Text == "Please wait..." then return end
                task.wait(0.1)
                for _, name in {"A", "B", "C", "D"} do
                    local answer = frame[name].Answer.Value
                    if table.find(correctWords, answer) then
                        classRemotes.English:FireServer(answer)
                        break
                    end
                end
            end)
        }
    end,

    baking = function()
        local flavorFrame = localPlayer.PlayerGui.Baking.FlavorSelect
        local linerFrame = localPlayer.PlayerGui.Baking.LinerSelect
        local icingFrame = localPlayer.PlayerGui.Baking.IcingSelect
        local addedIndex = 0

        fireBackData = {
            {replicatedStorage.Cooking.Butter, 1},
            {replicatedStorage.Cooking.Sugar, 15},
            {replicatedStorage.Cooking.Mixer, 1, 300},
            {replicatedStorage.Cooking.Flour, 15},
            {replicatedStorage.Cooking.Milk, 1}
        }

        function getFireBackConns()
            local connections = {}
            for _,data in next, fireBackData do
                table.insert(connections, fireBack(data[1], data[2], data[3]))
            end
            return connections
        end

        function getFrameConns()
            local connections = {}
            for i,frame in next, {flavorFrame, linerFrame, icingFrame} do
                table.insert(connections, frame:GetPropertyChangedSignal("Visible"):Connect(function()
                    if frame.Visible then
                        task.wait(.6)
                        getconnections(frame:FindFirstChildOfClass("TextButton").MouseButton1Click)[1]:Fire()
                        if i == 3 then
                            task.wait(.6)
                            replicatedStorage.Cooking.Toppings:FireServer("Done", "")
                            localPlayer.PlayerGui.Baking.Enabled = false
                        end
                    end
                end))
            end
            return connections
        end

        function getAllConns()
            local t1 = getFireBackConns()
            local t2 = getFrameConns()
            for _,connection in next, t2 do
                table.insert(t1, connection)
            end
            return t1
        end

        return {
            classRemotes.BookCheck.OnClientEvent:Connect(function()
                fireclickdetector(workspace.BakingCounters.CounterStuff.ClaimButton.ClickDetector, 5)
            end),
            replicatedStorage.Cooking.Egg.OnClientEvent:Connect(function(p1)
                if not p1 then return end
                fireclickdetector(workspace.BakingCounters.CounterStuff.BakingCupcakesIngredients.egg.ClickDetector, 3)
                task.wait(3.5)
                fireclickdetector(workspace.BakingCounters.CounterStuff.BakingCupcakesIngredients.egg.ClickDetector, 3)
            end),
            localPlayer.Character.ChildAdded:Connect(function(child)
                if child.Name == "Cupcake Pan" then
                    if addedIndex == 0 then
                        localPlayer.Character.Humanoid:MoveTo(workspace.BakingCounters.CounterStuff.Oven.Door.Position)
                    else
                        localPlayer.Character.Humanoid:MoveTo(workspace.BakingCounters.CounterStuff.Place.Position)
                    end
                    addedIndex += 1
                end
            end),
            unpack(getAllConns())
        }
    end
}

classRemotes.Starting.OnClientEvent:Connect(function(class)
    local class = string.lower(string.gsub(class, " class", ""))
    if not classFuncs[class] then return end
    replicatedStorage.Classes.Starting:FireServer()
    local newConnections = classFuncs[class]() or {}
    for _,connection in next, prevConnections do
        connection:Disconnect()
    end
    prevConnections = {}
    for _,connection in next, newConnections do
        table.insert(prevConnections, connection)
    end
end)

-- ========== HOMEWORK (NO TELEPORT) ==========
localPlayer.ChildAdded:Connect(function(child)
    if child.Name == "Homework" then
        repeat task.wait() until child:FindFirstChildOfClass("BoolValue")
        for i,homework in next, child:GetChildren() do
            homework.Complete:FireServer()
            task.wait(.5)
            fireclickdetector(workspace:WaitForChild("Homeworkbox_" .. homework.Name, 10).Click.ClickDetector, 3)
            -- Teleport to BeachHouse removed
        end
    end
end)

-- ========== TIME-BASED DORM SLEEP (instead of BeachHouse) ==========
local time = localPlayer.PlayerGui.SchoolHUD.MainFrame.Time.Time
time:GetPropertyChangedSignal("Value"):Connect(function()
    local hour = time.Value
    if hour == 6 then
        task.spawn(performDormSleep)
    end
end)

-- ========== LOCKER BOOKS ==========
local function getLocker()
    local closestMag = math.huge; local closestLocker
    for _,door in next, workspace:GetDescendants() do
        if door:IsA("MeshPart") and door.Name == "LockerDoor" then
            local mag = (door.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
            if mag < closestMag then closestMag = mag; closestLocker = door end
        end
    end
    return closestLocker
end

local function getBooks()
	print("getting books")
    repeat task.wait() until #localPlayer.Locker:GetChildren() == 5
    task.wait(10)
    local locker = getLocker()
    fireclickdetector(locker.ClickDetector)
    replicatedStorage.Lockers.Code:FireServer(locker, "0000", "Create")
    for _,book in next, localPlayer.Locker:GetChildren() do
        replicatedStorage.Lockers.Contents:InvokeServer("Take", book)
    end
    localPlayer.PlayerGui.Locker.Enabled = false
end

getBooks()
