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
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
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

local playerESPEnabled = false
local playerESPConnections = {}
local playerESPList = {}
local espColor = Color3.fromRGB(0, 255, 0)

local function clearPlayerESP()
    for char, _ in pairs(playerESPList) do
        if char and char.Parent then
            local hl = char:FindFirstChild("ESP_Highlight")
            if hl then hl:Destroy() end

            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    local bb = part:FindFirstChild("ESP_NameTag")
                    if bb then bb:Destroy() end
                end
            end
        end
        playerESPList[char] = nil
    end
end

local function applyPlayerESP(character, player)
    if not character or not player or player == Players.LocalPlayer then return end
    if playerESPList[character] then return end
    playerESPList[character] = true

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = espColor
    highlight.FillTransparency = 0.25
    highlight.OutlineColor = espColor
    highlight.OutlineTransparency = 0
    highlight.Adornee = character
    highlight.Parent = character

    local adorneePart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    if adorneePart then
        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_NameTag"
        bb.Size = UDim2.new(0, 100, 0, 24)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = adorneePart
        bb.Parent = adorneePart

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.DisplayName
        label.TextColor3 = espColor
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0.5
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = bb
    end
end

local function startPlayerESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character then
            applyPlayerESP(p.Character, p)
        end
    end

    table.insert(playerESPConnections, Players.PlayerAdded:Connect(function(p)
        table.insert(playerESPConnections, p.CharacterAdded:Connect(function(char)
            task.wait(1)
            if playerESPEnabled then
                applyPlayerESP(char, p)
            end
        end))
    end))

    table.insert(playerESPConnections, RunService.RenderStepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Players.LocalPlayer and p.Character then
                applyPlayerESP(p.Character, p)
            end
        end
    end))
end

local function stopPlayerESP()
    clearPlayerESP()
    for _, c in ipairs(playerESPConnections) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
    end
    playerESPConnections = {}
end

VisionTab:CreateToggle({
    Name = "ESP玩家",
    CurrentValue = false,
    Callback = function(Value)
        playerESPEnabled = Value
        if Value then
            startPlayerESP()
        else
            stopPlayerESP()
        end
    end,
})


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
    Name = "ESP腦腐",
    Options = {"Secret", "Brainrot God", "Mythic", "Legendary", "Epic", "Rare", "Common"},
    CurrentOption = {},  
    MultipleOptions = true,
    Flag = "ESP腦腐",
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

local ShopItems = {
    "Slap",
    "Speed Coil",
    "Trap",
    "Iron Slap",
    "Gravity Coil",
    "Bee Launcher",
    "Gold Slap",
    "Coil Combo",
    "Rage Table",
    "Diamond Slap",
    "Grapple Hook",
    "Taser Gun",
    "Emerald Slap",
    "Invisibility Cloak",
    "Boogie Bomb",
    "Ruby Slap",
    "Medusa's Head",
    "Dark Matter Slap",
    "Web Slinger",
    "Flame Slap",
    "Quantum Cloner",
    "All Seeing Sentry",
    "Nuclear Slap",
    "Rainbowrath Sword",
    "Galaxy Slap",
    "Laser Cape",
    "Glitched Slap",
    "Body Swap Potion",
    "Splatter Slap",
    "Painball Gun",
}

local selectedItems = {}
local trapCount = 1
local autoBuyEnabled = false

local isBuying = false     -- 標記是否正在購買
local buyRequestPending = false  -- 標記是否有新的購買請求等待

local RepStorage = game:GetService("ReplicatedStorage")
local buyRemote = RepStorage:WaitForChild("Packages")
                      :WaitForChild("Net")
                      :WaitForChild("RF/CoinsShopService/RequestBuy")

local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()

local purchaseDelays = {
    ["Grapple Hook"] = 1.5,
    ["Trap"] = 1.0,
    ["Speed Coil"] = 1.0,
}

local function countItemInInventory(itemName)
    local count = 0
    for _, item in ipairs(backpack:GetChildren()) do
        if item.Name == itemName then
            count = count + 1
        end
    end
    for _, item in ipairs(character:GetChildren()) do
        if item.Name == itemName then
            count = count + 1
        end
    end
    return count
end

local function safeInvoke(itemName)
    local args = {itemName}
    local success, err = pcall(function()
        buyRemote:InvokeServer(unpack(args))
    end)
    if not success then
        warn("購買失敗:", itemName, err)
    end
end

local function buyItem(item, count)
    count = count or 1
    for i = 1, count do
        safeInvoke(item)
        local delay = purchaseDelays[item] or 0.5
        task.wait(delay)
    end
end

local function buySelectedItemsSequential()
    if isBuying then
        buyRequestPending = true
        return
    end
    isBuying = true

    task.spawn(function()
        -- 依照 ShopItems 排序，挑出使用者選擇的物品購買
        local toBuyList = {}
        for _, shopItem in ipairs(ShopItems) do
            if table.find(selectedItems, shopItem) then
                table.insert(toBuyList, shopItem)
            end
        end

        for _, item in ipairs(toBuyList) do
            local currentCount = countItemInInventory(item)
            if item == "Trap" then
                local needed = math.min(trapCount, 5)
                local toBuy = math.max(0, needed - currentCount)
                if toBuy > 0 then
                    buyItem(item, toBuy)
                end
            elseif item == "Grapple Hook" then
                local maxGrapple = 5
                local toBuy = math.max(0, maxGrapple - currentCount)
                if toBuy > 0 then
                    buyItem(item, toBuy)
                end
            else
                if currentCount < 1 then
                    buyItem(item, 1)
                end
            end
        end

        isBuying = false

        if buyRequestPending then
            buyRequestPending = false
            buySelectedItemsSequential()
        end
    end)
end

ShopTab:CreateDropdown({
    Name = "🛒 選擇要購買的物品",
    Options = ShopItems,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "DropdownAutoBuy",
    Callback = function(Options)
        selectedItems = Options
        if autoBuyEnabled then
            buySelectedItemsSequential()
        end
    end,
})

ShopTab:CreateSlider({
    Name = "購買 Trap 數量",
    Range = {1, 5},
    Increment = 1,
    Suffix = "個",
    CurrentValue = 1,
    Flag = "TrapSlider",
    Callback = function(Value)
        trapCount = Value
        if autoBuyEnabled and table.find(selectedItems, "Trap") then
            buySelectedItemsSequential()
        end
    end,
})

ShopTab:CreateToggle({
    Name = "✅ 自動購買所選物品",
    CurrentValue = false,
    Flag = "ToggleAutoBuy",
    Callback = function(Value)
        autoBuyEnabled = Value
        if autoBuyEnabled then
            buySelectedItemsSequential()
        end
    end,
})

local DevelopersTab = Window:CreateTab("🖥️ 開發者工具", 0)

DevelopersTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end,
})

DevelopersTab:CreateButton({
    Name = "DEX",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/refs/heads/main/dex.lua'))()
    end,
})

DevelopersTab:CreateButton({
    Name = "SimpleSpy",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/refs/heads/main/SimpleSpyV3/main.lua'))()
    end,
})

Rayfield:LoadConfiguration()
