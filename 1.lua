local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Steal a brainrot | by 三眼怪",
    LoadingTitle = "Nash Hub",
    LoadingSubtitle = "by 三眼怪",
    ShowText = "Rayfield",
    Theme = "Default",
    ToggleUIKeybind = Enum.KeyCode.K,
    ConfigurationSaving = {
        Enabled = true,
        FileName = "Nash Hub"
    }
})

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 等待角色完全加載
if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until player.Character and player.Character:FindFirstChild("Humanoid")

local MainTab = Window:CreateTab("玩家", 4483362458)

-- WalkSpeed 功能
local HumanModCons = {}

local function setWalkSpeed(speed)
    local Char = player.Character or workspace:FindFirstChild(player.Name)
    local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")

    local function WalkSpeedChange()
        if Char and Human then
            Human.WalkSpeed = speed
        end
    end

    WalkSpeedChange()

    if HumanModCons.wsLoop then HumanModCons.wsLoop:Disconnect() end
    if HumanModCons.wsCA then HumanModCons.wsCA:Disconnect() end

    if Human then
        HumanModCons.wsLoop = Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
    end

    HumanModCons.wsCA = player.CharacterAdded:Connect(function(nChar)
        Char = nChar
        Human = nChar:WaitForChild("Humanoid")
        WalkSpeedChange()
        if HumanModCons.wsLoop then HumanModCons.wsLoop:Disconnect() end
        HumanModCons.wsLoop = Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
    end)
end

local function resetWalkSpeed()
    local Char = player.Character or workspace:FindFirstChild(player.Name)
    local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
    if Human then
        Human.WalkSpeed = 16
    end
    if HumanModCons.wsLoop then HumanModCons.wsLoop:Disconnect() end
    if HumanModCons.wsCA then HumanModCons.wsCA:Disconnect() end
end

MainTab:CreateToggle({
    Name = "⚡速度MAX",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            setWalkSpeed(50)
        else
            resetWalkSpeed()
        end
    end,
})

-- 無限跳功能
local jumpConnection = nil
local function setInfiniteJump(enabled)
    if enabled then
        jumpConnection = UserInputService.JumpRequest:Connect(function()
            local Char = player.Character
            local Humanoid = Char and Char:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if jumpConnection then jumpConnection:Disconnect() jumpConnection = nil end
    end
end

MainTab:CreateToggle({
    Name = "☁️無限跳躍",
    CurrentValue = false,
    Callback = function(Value)
        setInfiniteJump(Value)
    end,
})

-- God Mode 功能
local godModeToggle = false
local godConnections = {}
local godHeartbeat

local function enableGodMode()
    local function apply(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        humanoid.BreakJointsOnDeath = false
        humanoid.RequiresNeck = false

        for _, conn in ipairs(getconnections(humanoid.Died)) do
            conn:Disable()
            table.insert(godConnections, conn)
        end

        table.insert(godConnections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end))

        godHeartbeat = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end

    apply(player.Character or player.CharacterAdded:Wait())
    table.insert(godConnections, player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        apply(char)
    end))
end

local function disableGodMode()
    for _, conn in ipairs(godConnections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    godConnections = {}

    if godHeartbeat then godHeartbeat:Disconnect() godHeartbeat = nil end

    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.BreakJointsOnDeath = true
        humanoid.RequiresNeck = true
    end
end

MainTab:CreateToggle({
    Name = "👑無敵模式",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            enableGodMode()
        else
            disableGodMode()
        end
    end,
})

-- 額外預留頁籤
Window:CreateTab("視覺", 4483362458)
Window:CreateTab("商店", 4483362458)

Rayfield:LoadConfiguration()
