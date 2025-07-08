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
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- 等待角色完全加載
if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until player.Character and player.Character:FindFirstChild("Humanoid")

local MainTab = Window:CreateTab("🙂 玩家", 0)

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
            setWalkSpeed(48)
        else
            resetWalkSpeed()
        end
    end,
})

local HumanModCons = {}

local function setJumpHeight(height)
    local Char = player.Character or workspace:FindFirstChild(player.Name)
    local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")

    local function JumpHeightChange()
        if Char and Human then
            Human.JumpHeight = height
        end
    end

    JumpHeightChange()

    if HumanModCons.jhLoop then HumanModCons.jhLoop:Disconnect() end
    if HumanModCons.jhCA then HumanModCons.jhCA:Disconnect() end

    if Human then
        HumanModCons.jhLoop = Human:GetPropertyChangedSignal("JumpHeight"):Connect(JumpHeightChange)
    end

    HumanModCons.jhCA = player.CharacterAdded:Connect(function(nChar)
        Char = nChar
        Human = nChar:WaitForChild("Humanoid")
        JumpHeightChange()
        if HumanModCons.jhLoop then HumanModCons.jhLoop:Disconnect() end
        HumanModCons.jhLoop = Human:GetPropertyChangedSignal("JumpHeight"):Connect(JumpHeightChange)
    end)
end

local function resetJumpHeight()
    local Char = player.Character or workspace:FindFirstChild(player.Name)
    local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
    if Human then
        Human.JumpHeight = 7.2 -- 預設值
    end
    if HumanModCons.jhLoop then HumanModCons.jhLoop:Disconnect() end
    if HumanModCons.jhCA then HumanModCons.jhCA:Disconnect() end
end

MainTab:CreateToggle({
    Name = "🐇跳躍MAX",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            setJumpHeight(13) -- 加倍跳躍
        else
            resetJumpHeight()
        end
    end,
})

local lowGravity = 130 -- 低重力數值
local BodyForceName = "LowGravityForce"

local function applyLowGravity()
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    if hrp:FindFirstChild(BodyForceName) then
        hrp[BodyForceName]:Destroy()
    end

    local bodyForce = Instance.new("BodyForce")
    bodyForce.Name = BodyForceName

    local gravityForce = Vector3.new(0, workspace.Gravity * hrp:GetMass(), 0)
    local gravityScale = lowGravity / workspace.Gravity
    bodyForce.Force = gravityForce * (1 - gravityScale)
    bodyForce.Parent = hrp
end

local function resetGravity()
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild(BodyForceName) then
        hrp[BodyForceName]:Destroy()
    end
end

MainTab:CreateToggle({
    Name = "🌑低重力",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            applyLowGravity()
            -- 角色重生時持續套用低重力
            if not player.CharacterAdded:Wait().ConnectApplied then
                player.CharacterAdded:Connect(function()
                    wait(1)
                    applyLowGravity()
                end)
                player.CharacterAdded.ConnectApplied = true
            end
        else
            resetGravity()
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

local ShopTab = Window:CreateTab("🛒 商店", 0) 

Rayfield:LoadConfiguration()
