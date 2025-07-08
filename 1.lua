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

-- JumpHeight 功能
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
            setJumpHeight(14) -- 加倍跳躍
        else
            resetJumpHeight()
        end
    end,
})

-- 低重力功能
local lowGravity = 150 -- 低重力數值
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

-- 無敵模式功能
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

-- 視覺 Tab (ESP)
local VisionTab = Window:CreateTab("👁️ 視覺", 0)

local highlightColor = Color3.fromRGB(255, 0, 0)
local qualityColors = {
    ["Common"] = Color3.fromRGB(255, 255, 255),
    ["Rare"] = Color3.fromRGB(30, 144, 255),
    ["Epic"] = Color3.fromRGB(148, 0, 211),
    ["Legendary"] = Color3.fromRGB(255, 215, 0),
    ["Mythic"] = Color3.fromRGB(255, 0, 0),
    ["Brainrot God"] = Color3.fromRGB(255, 105, 180),
    ["Secret"] = Color3.fromRGB(0, 0, 0),
}

local Targets = {
    ["Noobini Pizzanini"] = {quality = "Common"},
    ["Lirilì Larilà"] = {quality = "Common"},
    ["Tim Cheese"] = {quality = "Common"},
    ["Fluriflura"] = {quality = "Common"},
    ["Talpa Di Fero"] = {quality = "Common"},
    ["Svinina Bombardino"] = {quality = "Common"},
    ["Pipi Kiwi"] = {quality = "Common"},
    ["Trippi Troppi"] = {quality = "Rare"},
    ["Tung Tung Tung Sahur"] = {quality = "Rare"},
    ["Gangster Footera"] = {quality = "Rare"},
    ["Boneca Ambalabu"] = {quality = "Rare"},
    ["Ta Ta Ta Ta Sahur"] = {quality = "Rare"},
    ["Tric Trac Baraboom"] = {quality = "Rare"},
    ["Bandito Bobritto"] = {quality = "Rare"},
    ["Cappuccino Assassino"] = {quality = "Epic"},
    ["Brr Brr Patapim"] = {quality = "Epic"},
    ["Trulimero Trulicina"] = {quality = "Epic"},
    ["Bambini Crostini"] = {quality = "Epic"},
    ["Bananita Dolphinita"] = {quality = "Epic"},
    ["Perochello Lemonchello"] = {quality = "Epic"},
    ["Brri Brri Bicus Dicus Bombicus"] = {quality = "Epic"},
    ["Burbaloni Loliloli"] = {quality = "Legendary"},
    ["Chimpanzini Bananini"] = {quality = "Legendary"},
    ["Ballerina Cappuccina"] = {quality = "Legendary"},
    ["Chef Crabracadabra"] = {quality = "Legendary"},
    ["Glorbo Fruttodrillo"] = {quality = "Legendary"},
    ["Blueberrinni Octopusini"] = {quality = "Legendary"},
    ["Lionel Cactuseli"] = {quality = "Legendary"},
    ["Frigo Camelo"] = {quality = "Mythic"},
    ["Orangutini Ananassini"] = {quality = "Mythic"},
    ["Rhino Toasterino"] = {quality = "Mythic"},
    ["Bombardiro Crocodilo"] = {quality = "Mythic"},
    ["Bombombini Gusini"] = {quality = "Mythic"},
    ["Cavallo Virtuoso"] = {quality = "Mythic"},
    ["Cocofanto Elefanto"] = {quality = "Brainrot God"},
    ["Gattatino Nyanino"] = {quality = "Brainrot God"},
    ["Girafa Celestre"] = {quality = "Brainrot God"},
    ["Tralalero Tralala"] = {quality = "Brainrot God"},
    ["Matteo"] = {quality = "Brainrot God"},
    ["Odin Din Din Dun"] = {quality = "Brainrot God"},
    ["Trenostruzzo Turbo 3000"] = {quality = "Brainrot God"},
    ["Unclito Samito"] = {quality = "Brainrot God"},
    ["La Vacca Saturno Saturnita"] = {quality = "Secret"},
    ["Los Tralaleritos"] = {quality = "Secret"},
    ["Graipuss Medussi"] = {quality = "Secret"},
    ["La Grande Combinazione"] = {quality = "Secret"},
    ["Sammyni Spyderini"] = {quality = "Secret"},
    ["Garama and Madundung"] = {quality = "Secret"},
}

getgenv().Rarity = getgenv().Rarity or {}

local ESPMarked = {}

local function clearAllESP()
    for obj,_ in pairs(ESPMarked) do
        if obj and obj.Parent then
            local hl = obj:FindFirstChild("ESP_Highlight")
            if hl then hl:Destroy() end

            for _, part in ipairs(obj:GetChildren()) do
                if part:IsA("BasePart") then
                    local billboard = part:FindFirstChild("ESP_NameTag")
                    if billboard then billboard:Destroy() end
                end
            end
        end
        ESPMarked[obj] = nil
    end
end

local function shouldApplyESP(obj)
    if not obj or not obj:IsA("Model") then return false end
    if not Targets[obj.Name] then return false end
    local rarity = Targets[obj.Name].quality
    if not getgenv().Rarity[rarity] or not getgenv().Rarity[rarity].enabled then return false end
    return true
end

local function applyESP(obj)
    if ESPMarked[obj] then return end -- 避免重複標記
    if not shouldApplyESP(obj) then return end

    ESPMarked[obj] = true

    if obj:FindFirstChild("ESP_Highlight") then
        obj.ESP_Highlight:Destroy()
    end
    for _, part in ipairs(obj:GetChildren()) do
        if part:IsA("BasePart") then
            local billboard = part:FindFirstChild("ESP_NameTag")
            if billboard then
                billboard:Destroy()
            end
        end
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = highlightColor
    highlight.FillTransparency = 0
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.Adornee = obj
    highlight.Parent = obj

    local adorneePart = obj:FindFirstChild("HumanoidRootPart")
    if not adorneePart then
        local highestY = -math.huge
        for _, part in ipairs(obj:GetDescendants()) do
            if part:IsA("BasePart") and part.Position.Y > highestY then
                highestY = part.Position.Y
                adorneePart = part
            end
        end
    end

    if adorneePart then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_NameTag"
        billboard.Size = UDim2.new(0, 120, 0, 24)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = adorneePart
        billboard.Parent = adorneePart

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = obj.Name
        label.TextColor3 = qualityColors[Targets[obj.Name].quality] or Color3.new(1, 1, 1)
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0.5
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard
    end
end

local function refreshAllESP()
    clearAllESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if shouldApplyESP(obj) then
            applyESP(obj)
        end
    end
end

VisionTab:CreateDropdown({
    Name = "ESP腐腦",
    Options = {"Secret", "Brainrot God", "Mythic", "Legendary", "Epic", "Rare", "Common"},
    CurrentOption = {},  
    MultipleOptions = true,
    Flag = "ESP腐腦",
    Callback = function(Options)
        for _, rarity in ipairs({"Secret", "Brainrot God", "Mythic", "Legendary", "Epic", "Rare", "Common"}) do
            getgenv().Rarity[rarity] = {enabled = table.find(Options, rarity) ~= nil}
        end
        refreshAllESP()
    end
})

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        task.delay(0.3, function()
            if shouldApplyESP(obj) then
                applyESP(obj)
            end
        end)
    end
end)

task.spawn(function()
    while true do
        refreshAllESP()
        task.wait(1)
    end
end)

-- 商店 Tab
local ShopTab = Window:CreateTab("🛒 商店", 0)
local DevelopersTab = Window:CreateTab("🖥️ 開發者工具", 0)

local Button = Tab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end,
 })
Rayfield:LoadConfiguration()
