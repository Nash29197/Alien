-- ==================================================
-- 載入函式庫與服務 (統一在頂部宣告)
-- ==================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield' ))()

-- 服務
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- 本地玩家相關 (使用 WaitForChild 確保穩定性)
local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local Camera = Workspace.CurrentCamera

-- ==================================================
-- 建立主視窗
-- ==================================================
local Window = Rayfield:CreateWindow({
    Name = "Steal a brainrot | by 三眼怪",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by 三眼怪",
    ShowText = "Rayfield",
    Theme = "Default",
    ToggleUIKeybind = Enum.KeyCode.K,
    ConfigurationSaving = {
        Enabled = true,
        FileName = "Nash Hub"
    }
})

-- ==================================================
-- 視覺 Tab (Vision)
-- ==================================================
-- [FIXED] 移除了 CreateTab 中無效的第二個參數 "eye"
local VisionTab = Window:CreateTab("視覺")

-- --------------------------------------------------
-- 玩家 ESP (Player ESP)
-- --------------------------------------------------
do -- 使用 do...end 區塊將 ESP 功能封裝起來
    -- // 變數 //
    local ESP = {}
    ESP.__index = ESP
    local espInstance = ESP.new()
    local renderConnection = nil

    -- // 核心函式 //
    function ESP.new()
        local self = setmetatable({}, ESP)
        self.espCache = {}
        return self
    end

    function ESP:createDrawing(type, properties)
        -- 檢查 Drawing API 是否存在，如果不存在則建立一個假的函式以防止錯誤
        if not Drawing then
            return {
                Remove = function() end,
                Visible = false
            }
        end
        local drawing = Drawing.new(type)
        for prop, val in pairs(properties) do
            drawing[prop] = val
        end
        return drawing
    end

    function ESP:createComponents()
        return {
            Box = self:createDrawing("Square", { Thickness = 1, Transparency = 1, Color = Color3.fromRGB(255, 255, 255), Filled = false }),
            Tracer = self:createDrawing("Line", { Thickness = 1, Transparency = 1, Color = Color3.fromRGB(255, 255, 255) }),
            DistanceLabel = self:createDrawing("Text", { Size = 18, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255), OutlineColor = Color3.fromRGB(0, 0, 0) }),
            NameLabel = self:createDrawing("Text", { Size = 18, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255), OutlineColor = Color3.fromRGB(0, 0, 0) }),
            HealthBar = {
                Outline = self:createDrawing("Square", { Thickness = 1, Transparency = 1, Color = Color3.fromRGB(0, 0, 0), Filled = false }),
                Health = self:createDrawing("Square", { Thickness = 1, Transparency = 1, Color = Color3.fromRGB(0, 255, 0), Filled = true })
            },
            ItemLabel = self:createDrawing("Text", { Size = 18, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255), OutlineColor = Color3.fromRGB(0, 0, 0) }),
            SkeletonLines = {}
        }
    end

    local bodyConnections = {
        R15 = {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
            {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
            {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}
        },
        R6 = {
            {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
        }
    }

    function ESP:updateComponents(components, character, player)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")

        if not (hrp and humanoid and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
            return self:hideComponents(components)
        end

        local hrpPosition, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then return self:hideComponents(components) end

        local screenSize = Camera.ViewportSize
        local factor = 1 / (hrpPosition.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 100
        local width, height = math.floor(screenSize.Y / 25 * factor), math.floor(screenSize.X / 27 * factor)
        local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)

        -- 顯示所有元件
        for _, component in pairs(components) do
            if type(component) == "table" then
                for _, subComponent in pairs(component) do subComponent.Visible = true end
            else
                component.Visible = true
            end
        end

        -- Box & Tracer
        components.Box.Size = Vector2.new(width, height)
        components.Box.Position = Vector2.new(hrpPosition.X - width / 2, hrpPosition.Y - height / 2)
        components.Tracer.From = Vector2.new(screenSize.X / 2, 0)
        components.Tracer.To = Vector2.new(hrpPosition.X, hrpPosition.Y - height / 2)

        -- Labels
        components.NameLabel.Text = player.Name
        components.NameLabel.Position = Vector2.new(hrpPosition.X, hrpPosition.Y - height / 2 - 15)
        components.DistanceLabel.Text = string.format("[%dM]", distance)
        components.DistanceLabel.Position = Vector2.new(hrpPosition.X, hrpPosition.Y + height / 2 + 15)
        local tool = character:FindFirstChildOfClass("Tool") or player:FindFirstChild("Backpack"):FindFirstChildOfClass("Tool")
        components.ItemLabel.Text = tool and tool.Name or "N/A"
        components.ItemLabel.Position = Vector2.new(hrpPosition.X, hrpPosition.Y + height / 2 + 35)

        -- Health Bar
        local healthFrac = humanoid.Health / humanoid.MaxHealth
        local barWidth = 5
        components.HealthBar.Outline.Size = Vector2.new(barWidth, height)
        components.HealthBar.Outline.Position = Vector2.new(components.Box.Position.X - barWidth - 2, components.Box.Position.Y)
        components.HealthBar.Health.Size = Vector2.new(barWidth - 2, height * healthFrac)
        components.HealthBar.Health.Position = Vector2.new(components.HealthBar.Outline.Position.X + 1, components.HealthBar.Outline.Position.Y + height * (1 - healthFrac))

        -- Skeleton
        local connections = bodyConnections[humanoid.RigType.Name]
        if not connections then return end
        for _, conn in ipairs(connections) do
            local partA, partB = character:FindFirstChild(conn[1]), character:FindFirstChild(conn[2])
            if partA and partB then
                local line = components.SkeletonLines[conn[1].."-"..conn[2]] or self:createDrawing("Line", { Thickness = 1, Color = Color3.fromRGB(255, 255, 255) })
                local a, aOnScreen = Camera:WorldToViewportPoint(partA.Position)
                local b, bOnScreen = Camera:WorldToViewportPoint(partB.Position)
                if aOnScreen and bOnScreen then
                    line.From, line.To, line.Visible = Vector2.new(a.X, a.Y), Vector2.new(b.X, b.Y), true
                    components.SkeletonLines[conn[1].."-"..conn[2]] = line
                elseif line then
                    line.Visible = false
                end
            end
        end
    end

    function ESP:hideComponents(components)
        if not components then return end
        for _, component in pairs(components) do
            if type(component) == "table" then
                for _, subComponent in pairs(component) do subComponent.Visible = false end
            else
                component.Visible = false
            end
        end
    end

    function ESP:removeEsp(player)
        local components = self.espCache[player]
        if components then
            for _, component in pairs(components) do
                if type(component) == "table" then
                    for _, subComponent in pairs(component) do subComponent:Remove() end
                else
                    component:Remove()
                end
            end
            self.espCache[player] = nil
        end
    end

    -- // 控制函式 //
    local function startPlayerESP()
        if renderConnection then return end
        renderConnection = RunService.RenderStepped:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local character = player.Character
                    if character then
                        if not espInstance.espCache[player] then
                            espInstance.espCache[player] = espInstance:createComponents()
                        end
                        espInstance:updateComponents(espInstance.espCache[player], character, player)
                    else
                        espInstance:hideComponents(espInstance.espCache[player])
                    end
                end
            end
        end)
        Players.PlayerRemoving:Connect(function(player) espInstance:removeEsp(player) end)
    end

    local function stopPlayerESP()
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end
        for player, components in pairs(espInstance.espCache) do
            espInstance:hideComponents(components)
        end
    end

    -- // Rayfield UI 元素 //
    local Toggle = VisionTab:CreateToggle({
        Name = "ESP玩家",
        CurrentValue = false,
        Flag = "PlayerESP_Toggle",
        Callback = function(Value)
            if Value then
                startPlayerESP()
            else
                stopPlayerESP()
            end
        end,
    })
end -- 結束 do 區塊

-- === Plot Timers 美化功能相關變數 ===
local plotTimers_Enabled = false
local plotTimers_Coroutine = nil
local plotTimers_RenderConnections = {}
local plotTimers_OriginalProperties = {}

local function disablePlotTimers()
    plotTimers_Enabled = false
    if plotTimers_Coroutine then
        task.cancel(plotTimers_Coroutine)
        plotTimers_Coroutine = nil
    end

    for _, conn in pairs(plotTimers_RenderConnections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(plotTimers_RenderConnections)

    for label, props in pairs(plotTimers_OriginalProperties) do
        pcall(function()
            if label and label.Parent then
                local bb = label:FindFirstAncestorWhichIsA("BillboardGui")
                if bb and bb.Parent then
                    bb.Enabled = props.bb_enabled
                    bb.AlwaysOnTop = props.bb_alwaysOnTop
                    bb.Size = props.bb_size
                    bb.MaxDistance = props.bb_maxDistance

                    label.TextScaled = props.label_textScaled
                    label.TextWrapped = props.label_textWrapped
                    label.AutomaticSize = props.label_automaticSize
                    label.Size = props.label_size
                    label.TextSize = props.label_textSize
                end
            end
        end)
    end
end

local function enablePlotTimers()
    disablePlotTimers()

    plotTimers_Enabled = true
    plotTimers_Coroutine = task.spawn(function()
        local camera = workspace.CurrentCamera
        local DISTANCE_THRESHOLD = 45
        local SCALE_START, SCALE_RANGE = 100, 300
        local MIN_TEXT_SIZE, MAX_TEXT_SIZE = 30, 36

        while plotTimers_Enabled do
            pcall(function()
                for _, label in ipairs(workspace.Plots:GetDescendants()) do
                    repeat
                        if not (label:IsA("TextLabel") and label.Name == "RemainingTime") then break end
                        if plotTimers_RenderConnections[label] then break end

                        local bb = label:FindFirstAncestorWhichIsA("BillboardGui")
                        if not bb then break end

                        local model = bb:FindFirstAncestorWhichIsA("Model")
                        if not model then break end

                        local basePart = model:FindFirstChildWhichIsA("BasePart", true)
                        if not basePart then break end

                        if not plotTimers_OriginalProperties[label] then
                            plotTimers_OriginalProperties[label] = {
                                bb_enabled = bb.Enabled,
                                bb_alwaysOnTop = bb.AlwaysOnTop,
                                bb_size = bb.Size,
                                bb_maxDistance = bb.MaxDistance,
                                label_textScaled = label.TextScaled,
                                label_textWrapped = label.TextWrapped,
                                label_automaticSize = label.AutomaticSize,
                                label_size = label.Size,
                                label_textSize = label.TextSize,
                            }
                        end

                        bb.MaxDistance = 10000
                        bb.AlwaysOnTop = true
                        bb.ClipsDescendants = false
                        bb.Size = UDim2.new(0, 300, 0, 150)

                        label.TextScaled = false
                        label.TextWrapped = true
                        label.ClipsDescendants = false
                        label.Size = UDim2.new(1, 0, 0, 32)
                        label.AutomaticSize = Enum.AutomaticSize.Y

                        local conn = game:GetService("RunService").RenderStepped:Connect(function()
                            if not basePart or not basePart.Parent or not bb or not bb.Parent then
                                if plotTimers_RenderConnections[label] then
                                    plotTimers_RenderConnections[label]:Disconnect()
                                    plotTimers_RenderConnections[label] = nil
                                end
                                return
                            end

                            local distance = (camera.CFrame.Position - basePart.Position).Magnitude
                            if distance > DISTANCE_THRESHOLD and basePart.Position.Y >= 0 then
                                bb.Enabled = false
                                return
                            end

                            bb.Enabled = true
                            local t = math.clamp((distance - SCALE_START) / SCALE_RANGE, 0, 1)
                            local newTextSize = math.clamp(MIN_TEXT_SIZE + (MAX_TEXT_SIZE - MIN_TEXT_SIZE) * t, MIN_TEXT_SIZE, MAX_TEXT_SIZE)
                            label.TextSize = newTextSize
                            label.Size = UDim2.new(1, 0, 0, newTextSize + 6)
                        end)
                        plotTimers_RenderConnections[label] = conn
                    until true
                end
            end)
            task.wait(1)
        end
    end)
end

-- === 在 Visuals 分頁建立 Toggle 開關 ===
VisionTab:CreateToggle({
    Name = "ESP房子時間",
    CurrentValue = false,
    Flag = "ViewPlotTimers",
    Callback = function(value)
        if value then
            enablePlotTimers()
        else
            disablePlotTimers()
        end
    end,
})

-- [NEW] 從外部 URL 載入物品目標清單 (Targets)
local function loadTargetsList()
    local url = "https://raw.githubusercontent.com/Nash29197/Nash-Hub/refs/heads/main/Steal%20a%20brainrot%20%7C%20List%202025%207%2022.lua"
    local success, content = pcall(function( )
        return game:HttpGet(url, true) -- 第二個參數 true 表示不快取
    end)

    if success and content then
        local loadFunc, err = loadstring(content)
        if loadFunc then
            local pcallSuccess, pcallErr = pcall(loadFunc)
            if not pcallSuccess then
                warn("執行 Targets 列表時發生錯誤: ", pcallErr)
            end
        else
            warn("解析 Targets 列表時發生錯誤: ", err)
        end
    else
        warn("無法從 URL 獲取 Targets 列表: ", content)
    end
end

-- 執行載入函式
loadTargetsList()


-- 1. 整合稀有度設定
local raritySettings = {
    ["Common"] = { Color = Color3.fromRGB(255, 255, 255), Enabled = false },
    ["Rare"] = { Color = Color3.fromRGB(30, 144, 255), Enabled = false },
    ["Epic"] = { Color = Color3.fromRGB(148, 0, 211), Enabled = false },
    ["Legendary"] = { Color = Color3.fromRGB(255, 215, 0), Enabled = false },
    ["Mythic"] = { Color = Color3.fromRGB(255, 0, 0), Enabled = false },
    ["Brainrot God"] = { Color = Color3.fromRGB(255, 105, 180), Enabled = false },
    ["Secret"] = { Color = Color3.fromRGB(0, 0, 0), Enabled = false },
}
local rarityOptions = {}
for rarity, _ in pairs(raritySettings) do
    table.insert(rarityOptions, rarity)
end

-- 狀態變數
local brainrotEspEnabled = false
local markedObjects = {} -- 結構: { [model] = { highlight = highlightInstance, nametag = billboardGuiInstance } }
local connections = {} -- 用於儲存事件連接

-- 找出最高部位
local function getHighestPart(model)
    local highest, y = nil, -math.huge
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Position.Y > y then
            y = part.Position.Y
            highest = part
        end
    end
    return highest
end

-- 移除 ESP 效果
local function removeESP(obj)
    local marked = markedObjects[obj]
    if marked then
        if marked.highlight and marked.highlight.Parent then
            marked.highlight:Destroy()
        end
        if marked.nametag and marked.nametag.Parent then
            marked.nametag:Destroy()
        end
        markedObjects[obj] = nil
    end
end

-- 應用 ESP 效果
local function applyESP(obj)
    -- 基本驗證
    if not (obj and obj:IsA("Model") and obj.Parent) then return end
    
    -- 移除舊標記以防萬一
    removeESP(obj)

    -- 獲取物件資料和稀有度 (依賴於已載入的 Targets)
    local data = Targets and Targets[obj.Name]
    if not (data and data.quality and raritySettings[data.quality]) then return end
    
    -- 檢查總開關和稀有度篩選是否啟用
    if not (brainrotEspEnabled and raritySettings[data.quality].Enabled) then return end

    -- 建立 Highlight
    local highlight = Instance.new("Highlight")
    highlight.FillColor = raritySettings[data.quality].Color
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0.5
    highlight.Adornee = obj
    highlight.Parent = obj

    -- 建立名稱標籤
    local nametag
    local highestPart = getHighestPart(obj)
    if highestPart then
        nametag = Instance.new("BillboardGui")
        nametag.Size = UDim2.new(0, 150, 0, 30)
        nametag.StudsOffset = Vector3.new(0, 2.5, 0)
        nametag.AlwaysOnTop = true
        nametag.Adornee = highestPart
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = obj.Name
        label.TextColor3 = raritySettings[data.quality].Color
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0.5
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = nametag
        
        nametag.Parent = highestPart
    end

    -- 記錄已建立的物件
    markedObjects[obj] = { highlight = highlight, nametag = nametag }
end

-- 掃描並更新所有物件
local function refreshAllObjects()
    -- 先清除所有現有標記
    for obj, _ in pairs(markedObjects) do
        removeESP(obj)
    end
    
    -- 如果功能啟用，則重新掃描並應用
    if brainrotEspEnabled then
        for _, obj in ipairs(workspace:GetDescendants()) do
            applyESP(obj)
        end
    end
end

-- 啟用/停用 ESP 功能的總控制
local function setBrainrotEspActive(isActive)
    brainrotEspEnabled = isActive
    
    -- 斷開舊的事件連接
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    table.clear(connections)

    if isActive then
        -- 啟用時，重新整理並開始監聽
        refreshAllObjects()
        
        table.insert(connections, workspace.DescendantAdded:Connect(function(descendant)
            task.wait(0.1)
            applyESP(descendant)
        end))
        
        table.insert(connections, workspace.DescendantRemoving:Connect(removeESP))
        
    else
        -- 停用時，清除所有標記
        for obj, _ in pairs(markedObjects) do
            removeESP(obj)
        end
    end
end

-- ========= Rayfield UI 介面 =========

-- 2. 建立總開關
VisionTab:CreateToggle({
    Name = "啟用腦腐 ESP",
    CurrentValue = false,
    Flag = "BrainrotEspMasterToggle",
    Callback = function(value)
        setBrainrotEspActive(value)
    end,
})

-- 3. 建立稀有度篩選下拉選單
VisionTab:CreateDropdown({
    Name = "ESP腦腐稀有度",
    Options = rarityOptions,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ESP_RarityDropdown",
    Callback = function(selectedOptions)
        -- 更新每個稀有度的啟用狀態
        for rarity, settings in pairs(raritySettings) do
            settings.Enabled = table.find(selectedOptions, rarity)
        end
        -- 根據新的篩選條件重新整理顯示
        refreshAllObjects()
    end,
})

-- 商店 Tab
local ShopTab = Window:CreateTab("商店", 0)

-- 遠端載入商店物品清單
local function loadShopItemsFromURL(url)
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    if success and content then
        local chunk = loadstring(content)
        if typeof(chunk) == "function" then
            local ok, result = pcall(chunk)
            if ok and typeof(result) == "table" then
                return result
            end
        end
    end
    warn("無法載入商店物品清單，使用空表")
    return {}
end

local ShopItemsURL = "https://raw.githubusercontent.com/Nash29197/Nash-Hub/refs/heads/main/Steal%20a%20brainrot%20%7C%20Shop%20Items%202025%207%2022.lua"
local ShopItems = loadShopItemsFromURL(ShopItemsURL)

-- 狀態變數
local selectedItems = {}
local trapCount = 1
local autoBuyEnabled = false
local isBuying = false
local buyRequestPending = false

-- 延遲配置
local purchaseDelays = {
    ["Grapple Hook"] = 0.2,
    ["Trap"] = 0.2,
    ["Speed Coil"] = 0.2,
}
local defaultDelay = 0.4

-- 計算物品數量（背包 + 身上）
local function countItemInInventory(itemName)
    task.wait(0.1)
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

-- 安全購買單個物品
local function safeInvoke(itemName)
    local success, err = pcall(function()
        buyRemote:InvokeServer(itemName)
    end)
    if not success then warn("購買失敗:", itemName, err) end
    return success
end

-- 購買多個（1~N）物品
local function buyItem(item, count)
    count = count or 1
    for i = 1, count do
        if not autoBuyEnabled then break end
        safeInvoke(item)
        task.wait(purchaseDelays[item] or defaultDelay)
    end
end

-- 檢查是否所有已選物品皆滿足需求
local function allItemsBought()
    for _, item in ipairs(ShopItems) do
        if table.find(selectedItems, item) then
            local currentCount = countItemInInventory(item)
            if item == "Trap" then
                if currentCount < math.min(trapCount, 5) then return false end
            elseif item == "Grapple Hook" then
                if currentCount < 5 then return false end
            elseif currentCount < 1 then
                return false
            end
        end
    end
    return true
end

-- 主購買流程
local function buySelectedItemsSequential()
    if isBuying then
        buyRequestPending = true
        return
    end
    isBuying = true
    task.spawn(function()
        while autoBuyEnabled do
            for _, item in ipairs(ShopItems) do
                if not autoBuyEnabled then break end
                if table.find(selectedItems, item) then
                    local currentCount = countItemInInventory(item)
                    if item == "Trap" then
                        local need = math.min(trapCount, 5)
                        if currentCount < need then
                            buyItem(item, need - currentCount)
                        end
                    elseif item == "Grapple Hook" then
                        if currentCount < 5 then
                            buyItem(item, 5 - currentCount)
                        end
                    elseif currentCount < 1 then
                        buyItem(item, 1)
                    end
                end
            end

            if allItemsBought() then break end
            task.wait(0.5)
        end

        isBuying = false
        if buyRequestPending and autoBuyEnabled then
            buyRequestPending = false
            buySelectedItemsSequential()
        end
    end)
end

-- ========= 📦 UI 建構區塊（請配合你的 Rayfield ShopTab 使用） =========

ShopTab:CreateDropdown({
    Name = "道具列表(可複選)",
    Options = (function()
        local opts = table.clone(ShopItems)
        table.insert(opts, 1, "All")
        return opts
    end)(),
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "DropdownAutoBuy",
    Callback = function(Options)
        if table.find(Options, "All") then
            selectedItems = table.clone(ShopItems)
            if library and library.flags then
                library.flags["DropdownAutoBuy"] = selectedItems
            end
        else
            selectedItems = Options
        end
        if autoBuyEnabled then
            buySelectedItemsSequential()
        end
    end,
})

ShopTab:CreateSlider({
    Name = "夾子購買數量(1~5)",
    Range = {1,5}, Increment = 1, Suffix = "個",
    CurrentValue = trapCount,
    Flag = "TrapSlider",
    Callback = function(v)
        trapCount = v
        if autoBuyEnabled then buySelectedItemsSequential() end
    end
})

ShopTab:CreateToggle({
    Name = "自動購買",
    CurrentValue = false,
    Flag = "ToggleAutoBuy",
    Callback = function(v)
        autoBuyEnabled = v
        if v then buySelectedItemsSequential() end
    end
})

local DevelopersTab = Window:CreateTab("開發者工具", 0)

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
