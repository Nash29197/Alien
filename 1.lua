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
local VisionTab = Window:CreateTab("視覺", 4483362458)

local highlightColor = Color3.fromRGB(255, 0, 0)
local qualityColors = {
    ["Common"] = Color3.fromRGB(255, 255, 255),
    ["Rare"] = Color3.fromRGB(30, 144, 255),
    ["Epic"] = Color3.fromRGB(148, 0, 211),
    ["Legendary"] = Color3.fromRGB(255, 215, 0),
    ["Mythic"] = Color3.fromRGB(255, 0, 0),
    ["Secret"] = Color3.fromRGB(0, 0, 0),
    ["Brainrot God"] = Color3.fromRGB(255, 105, 180),
}

local Targets = {
    ["Noobini Pizzanini"] = {quality = "Common"},
    ["Lirilí Larilá"] = {quality = "Common"},
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

-- 自動套 ESP 函數
local function applyESP(obj)
    if not obj:IsA("Model") then return end
    if not Targets[obj.Name] then return end
    local rarity = Targets[obj.Name].quality
    if not (getgenv().Rarity and getgenv().Rarity[rarity] and getgenv().Rarity[rarity].enabled) then return end

    local highestPart = nil
    for _, part in ipairs(obj:GetDescendants()) do
        if part:IsA("BasePart") then
            if not part:FindFirstChild("ESP_Highlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = highlightColor
                highlight.FillTransparency = 0
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.OutlineTransparency = 0
                highlight.Adornee = part
                highlight.Parent = part
            end

            if not highestPart or part.Position.Y > highestPart.Position.Y then
                highestPart = part
            end
        end
    end

    if highestPart and not highestPart:FindFirstChild("ESP_NameTag") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_NameTag"
        billboard.Size = UDim2.new(0, 100, 0, 20)
        billboard.StudsOffset = Vector3.new(0, 1.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = highestPart
        billboard.Parent = highestPart

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = obj.Name
        label.TextColor3 = qualityColors[rarity] or Color3.new(1, 1, 1)
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0.5
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard
    end
end

-- 清除 ESP（用於切換後刷新）
local function clearESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            for _, part in ipairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part:FindFirstChild("ESP_Highlight") then part.ESP_Highlight:Destroy() end
                    if part:FindFirstChild("ESP_NameTag") then part.ESP_NameTag:Destroy() end
                end
            end
        end
    end
end

-- 建立 Dropdown
VisionTab:CreateDropdown({
    Name = "ESP腐腦",
    Options = {"Secret", "Brainrot God", "Mythic", "Legendary", "Epic", "Rare", "Common"},
    CurrentOption = {"Brainrot God", "Mythic"},
    MultipleOptions = true,
    Flag = "ESP腐腦",
    Callback = function(Options)
        -- 更新篩選條件
        getgenv().Rarity = {}
        for _, rarity in ipairs({"Secret", "Brainrot God", "Mythic", "Legendary", "Epic", "Rare", "Common"}) do
            getgenv().Rarity[rarity] = {enabled = table.find(Options, rarity) ~= nil}
        end

        -- 先清除舊ESP
        clearESP()

        -- 重新套 ESP
        for _, obj in ipairs(workspace:GetDescendants()) do
            applyESP(obj)
        end
    end
})

-- 自動偵測新模型，並套用 ESP
workspace.DescendantAdded:Connect(function(obj)
    -- 延遲確保模型結構載入完成
    task.defer(function()
        applyESP(obj)
    end)
end)

 local ShopTab = Window:CreateTab("商店", 4483362458) -- Title, Image

Rayfield:LoadConfiguration()
