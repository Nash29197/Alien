--[[
    N++ Hub | by 三眼怪
    Final Protected Version (HttpGet Fixed)

    此版本為最終完整版，修正了 HttpGetAsync 的呼叫錯誤，並將所有敏感 API
    調用封裝在 Protected 安全層中，以提供更好的保護和可維護性。
]]

-- ▼▼▼▼▼ 安全執行環境模擬層 (核心保護機制) ▼▼▼▼▼
local Protected = {
    _services = {},
    _raw = {
        loadstring = loadstring,
        hookfunction = hookfunction,
        newcclosure = newcclosure,
        getgc = getgc,
        pcall = pcall,
        task_wait = task.wait,
        task_spawn = task.spawn,
        task_cancel = task.cancel,
        ipairs = ipairs,
        pairs = pairs,
        table_insert = table.insert,
        table_find = table.find,
        table_clear = table.clear,
        table_clone = table.clone,
    }
}

-- 安全地調用一個函數
function Protected.call(func, ...)
    return Protected._raw.pcall(func, ...)
end

-- 安全地獲取遊戲服務
function Protected.service(serviceName)
    if not Protected._services[serviceName] then
        local success, service = Protected.call(game.GetService, game, serviceName)
        if success then
            Protected._services[serviceName] = service
        else
            warn("無法安全地獲取服務:", serviceName)
        end
    end
    return Protected._services[serviceName]
end

-- 安全的 HttpGet 函數，使用新的 API
function Protected.httpGet(url, noCache )
    local HttpService = Protected.service("HttpService")
    local success, result = Protected.call(HttpService.GetAsync, HttpService, url, noCache)
    if success then
        return result
    else
        warn("Protected.httpGet 失敗:", result )
        return nil
    end
end
-- 將新的 httpGet 函數也加入 _raw 表 ，以供內部使用
Protected._raw.HttpGet = Protected.httpGet

-- 安全地創建實例
function Protected.instance(className )
    local success, inst = Protected.call(Instance.new, className)
    if success then return inst end
end

-- 安全的事件連接
function Protected.connect(event, func)
    return event:Connect(Protected._raw.newcclosure(func))
end

-- 安全的函數鉤子
function Protected.hook(target, detour)
    local success, result = Protected.call(Protected._raw.hookfunction, target, Protected._raw.newcclosure(detour))
    if not success then
        warn("掛載鉤子失敗:", result)
    end
end

-- 安全的繪圖庫 (模擬)
Protected.drawing = {
    new = function(type)
        return Drawing.new(type)
    end
}

-- 執行初始的反-反作弊鉤子
local function applyInitialHooks()
    local hk = false
    for _, v in Protected._raw.ipairs(Protected._raw.getgc(true)) do
        if typeof(v) == "table" then
            local fn = rawget(v, "observeTag")
            if typeof(fn) == "function" and not hk then
                hk = true
                Protected.hook(fn, function(_, _)
                    return { Disconnect = function() end, disconnect = function() end }
                end)
                break
            end
        end
    end
end
applyInitialHooks()
-- ▲▲▲▲▲ 安全執行環境模擬層 (核心保護機制) ▲▲▲▲▲


-- 使用安全層加載 Rayfield
local rayfieldContent = Protected.httpGet('https://sirius.menu/rayfield' )
local Rayfield = Protected._raw.loadstring(rayfieldContent)()

-- Rayfield UI 創建
local Window = Rayfield:CreateWindow({
    Name = "Steal a brainrot | N++ Hub | by 三眼怪",
    Icon = 0,
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by 三眼怪",
    ShowText = "N++ Hub",
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil,
       FileName = "N++ Hub"
    },
    Discord = { Enabled = false },
    KeySystem = false,
})

Rayfield:Notify({
    Title = "Welcome!!!",
    Content = "Welcome to N++ Hub!!!",
    Duration = 6.5,
    Image = "bell-plus",
})

-- 服務 (全部使用 Protected.service 獲取)
local Players = Protected.service("Players")
local RunService = Protected.service("RunService")
local ReplicatedStorage = Protected.service("ReplicatedStorage")
local Workspace = Protected.service("Workspace")

-- 本地玩家相關
local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local Camera = Workspace.CurrentCamera

-- 創建 Tab
local VisionTab = Window:CreateTab("視覺", "eye")
local ShopTab = Window:CreateTab("商店", "shopping-cart")
local DevelopersTab = Window:CreateTab("開發者工具", "hammer")

-- ==================== 玩家 ESP ====================
do
    local ESP = {}
    ESP.__index = ESP

    function ESP.new()
        local self = setmetatable({}, ESP)
        self.espCache = {}
        return self
    end

    function ESP:createDrawing(type, properties)
        local drawing = Protected.drawing.new(type)
        for prop, val in pairs(properties) do
            drawing[prop] = val
        end
        return drawing
    end

    function ESP:createComponents()
        return {
            Box = self:createDrawing("Square", { Thickness = 1, Transparency = 1, Color = Color3.fromRGB(255, 255, 255), Filled = false }),
            Tracer = self:createDrawing("Line", { Thickness = 1, Transparency = 1, Color = Color3.fromRGB(255, 255, 255) }),
            NameLabel = self:createDrawing("Text", { Size = 18, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255), OutlineColor = Color3.fromRGB(0, 0, 0) }),
            HealthBar = {
                Outline = self:createDrawing("Square", { Thickness = 1, Transparency = 1, Color = Color3.fromRGB(0, 0, 0), Filled = false }),
                Health = self:createDrawing("Square", { Thickness = 1, Transparency = 1, Color = Color3.fromRGB(0, 255, 0), Filled = true })
            },
            SkeletonLines = {}
        }
    end

    local bodyConnections = {
        R15 = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}, {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}},
        R6 = {{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}}
    }

    function ESP:updateComponents(components, character, player)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not hrp or not humanoid then return self:hideComponents(components) end

        local hrpPosition, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local screenSize = Camera.ViewportSize
            local factor = 1 / (hrpPosition.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 100
            local width, height = math.floor(screenSize.Y / 25 * factor), math.floor(screenSize.X / 27 * factor)
            
            components.Box.Size = Vector2.new(width, height); components.Box.Position = Vector2.new(hrpPosition.X - width / 2, hrpPosition.Y - height / 2); components.Box.Visible = true
            components.Tracer.From = Vector2.new(screenSize.X / 2, 0); components.Tracer.To = Vector2.new(hrpPosition.X, hrpPosition.Y - height / 2); components.Tracer.Visible = true
            components.NameLabel.Text = player.DisplayName; components.NameLabel.Position = Vector2.new(hrpPosition.X, hrpPosition.Y - height / 2 - 15); components.NameLabel.Visible = true

            local healthFrac = humanoid.Health / humanoid.MaxHealth
            local barWidth = 5
            components.HealthBar.Outline.Size = Vector2.new(barWidth, height); components.HealthBar.Outline.Position = Vector2.new(components.Box.Position.X - barWidth - 2, components.Box.Position.Y); components.HealthBar.Outline.Visible = true
            components.HealthBar.Health.Size = Vector2.new(barWidth - 2, height * healthFrac); components.HealthBar.Health.Position = Vector2.new(components.HealthBar.Outline.Position.X + 1, components.HealthBar.Outline.Position.Y + height * (1 - healthFrac)); components.HealthBar.Health.Visible = true

            local connections = bodyConnections[humanoid.RigType.Name] or {}
            for _, conn in Protected._raw.ipairs(connections) do
                local partA, partB = character:FindFirstChild(conn[1]), character:FindFirstChild(conn[2])
                if partA and partB then
                    local line = components.SkeletonLines[conn[1].."-"..conn[2]] or self:createDrawing("Line", { Thickness = 1, Color = Color3.fromRGB(255, 255, 255) })
                    local a, aOnScreen = Camera:WorldToViewportPoint(partA.Position)
                    local b, bOnScreen = Camera:WorldToViewportPoint(partB.Position)
                    if aOnScreen and bOnScreen then
                        line.From = Vector2.new(a.X, a.Y); line.To = Vector2.new(b.X, b.Y); line.Visible = true
                        components.SkeletonLines[conn[1].."-"..conn[2]] = line
                    else
                        line.Visible = false
                    end
                end
            end
        else
            self:hideComponents(components)
        end
    end

    function ESP:hideComponents(components)
        components.Box.Visible = false; components.Tracer.Visible = false; components.NameLabel.Visible = false
        components.HealthBar.Outline.Visible = false; components.HealthBar.Health.Visible = false
        for _, line in Protected._raw.pairs(components.SkeletonLines) do line.Visible = false end
    end

    function ESP:removeEsp(player)
        local components = self.espCache[player]
        if components then
            components.Box:Remove(); components.Tracer:Remove(); components.NameLabel:Remove()
            components.HealthBar.Outline:Remove(); components.HealthBar.Health:Remove()
            for _, line in Protected._raw.pairs(components.SkeletonLines) do line:Remove() end
            self.espCache[player] = nil
        end
    end

    local espInstance = ESP.new()
    local playerESPEnabled = false
    local renderConnection
    local playerRemovingConn

    local function startPlayerESP()
        if renderConnection then return end
        renderConnection = Protected.connect(RunService.RenderStepped, function()
            if not playerESPEnabled then return end
            for _, player in Protected._raw.ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local character = player.Character
                    if character then
                        if not espInstance.espCache[player] then espInstance.espCache[player] = espInstance:createComponents() end
                        espInstance:updateComponents(espInstance.espCache[player], character, player)
                    elseif espInstance.espCache[player] then
                        espInstance:hideComponents(espInstance.espCache[player])
                    end
                end
            end
        end)
        playerRemovingConn = Protected.connect(Players.PlayerRemoving, function(player) espInstance:removeEsp(player) end)
    end

    local function stopPlayerESP()
        if renderConnection then renderConnection:Disconnect(); renderConnection = nil end
        if playerRemovingConn then playerRemovingConn:Disconnect(); playerRemovingConn = nil end
        for _, components in Protected._raw.pairs(espInstance.espCache) do espInstance:hideComponents(components) end
    end

    VisionTab:CreateToggle({ Name = "ESP玩家", CurrentValue = false, Callback = function(v) playerESPEnabled = v; if v then startPlayerESP() else stopPlayerESP() end end })
end

-- ==================== 房子時間 ESP ====================
do
    local plotTimers_Enabled = false
    local plotTimers_Coroutine = nil
    local plotTimers_RenderConnections = {}
    local plotTimers_OriginalProperties = {}

    local function disablePlotTimers()
        plotTimers_Enabled = false
        if plotTimers_Coroutine then Protected._raw.task_cancel(plotTimers_Coroutine); plotTimers_Coroutine = nil end
        for _, conn in Protected._raw.pairs(plotTimers_RenderConnections) do Protected.call(conn.Disconnect, conn) end
        Protected._raw.table_clear(plotTimers_RenderConnections)
        for label, props in Protected._raw.pairs(plotTimers_OriginalProperties) do
            Protected.call(function()
                if label and label.Parent then
                    local bb = label:FindFirstAncestorWhichIsA("BillboardGui")
                    if bb and bb.Parent then
                        bb.Enabled, bb.AlwaysOnTop, bb.Size, bb.MaxDistance = props.bb_enabled, props.bb_alwaysOnTop, props.bb_size, props.bb_maxDistance
                        label.TextScaled, label.TextWrapped, label.AutomaticSize, label.Size, label.TextSize = props.label_textScaled, props.label_textWrapped, props.label_automaticSize, props.label_size, props.label_textSize
                    end
                end
            end)
        end
    end

    local function enablePlotTimers()
        disablePlotTimers()
        plotTimers_Enabled = true
        plotTimers_Coroutine = Protected._raw.task_spawn(function()
            local camera = Workspace.CurrentCamera
            local DISTANCE_THRESHOLD, SCALE_START, SCALE_RANGE, MIN_TEXT_SIZE, MAX_TEXT_SIZE = 45, 100, 300, 30, 36
            while plotTimers_Enabled do
                Protected.call(function()
                    for _, label in Protected._raw.ipairs(Workspace.Plots:GetDescendants()) do
                        if label:IsA("TextLabel") and label.Name == "RemainingTime" and not plotTimers_RenderConnections[label] then
                            local bb = label:FindFirstAncestorWhichIsA("BillboardGui")
                            local model = bb and bb:FindFirstAncestorWhichIsA("Model")
                            local basePart = model and model:FindFirstChildWhichIsA("BasePart", true)
                            if basePart then
                                if not plotTimers_OriginalProperties[label] then
                                    plotTimers_OriginalProperties[label] = { bb_enabled = bb.Enabled, bb_alwaysOnTop = bb.AlwaysOnTop, bb_size = bb.Size, bb_maxDistance = bb.MaxDistance, label_textScaled = label.TextScaled, label_textWrapped = label.TextWrapped, label_automaticSize = label.AutomaticSize, label_size = label.Size, label_textSize = label.TextSize }
                                end
                                bb.MaxDistance, bb.AlwaysOnTop, bb.ClipsDescendants, bb.Size = 10000, true, false, UDim2.new(0, 300, 0, 150)
                                label.TextScaled, label.TextWrapped, label.ClipsDescendants, label.Size, label.AutomaticSize = false, true, false, UDim2.new(1, 0, 0, 32), Enum.AutomaticSize.Y
                                plotTimers_RenderConnections[label] = Protected.connect(RunService.RenderStepped, function()
                                    if not basePart or not basePart.Parent or not bb or not bb.Parent then
                                        if plotTimers_RenderConnections[label] then plotTimers_RenderConnections[label]:Disconnect(); plotTimers_RenderConnections[label] = nil end
                                        return
                                    end
                                    local distance = (camera.CFrame.Position - basePart.Position).Magnitude
                                    bb.Enabled = not (distance > DISTANCE_THRESHOLD and basePart.Position.Y >= 0)
                                    if bb.Enabled then
                                        local t = math.clamp((distance - SCALE_START) / SCALE_RANGE, 0, 1)
                                        local newTextSize = math.clamp(MIN_TEXT_SIZE + (MAX_TEXT_SIZE - MIN_TEXT_SIZE) * t, MIN_TEXT_SIZE, MAX_TEXT_SIZE)
                                        label.TextSize = newTextSize; label.Size = UDim2.new(1, 0, 0, newTextSize + 6)
                                    end
                                end)
                            end
                        end
                    end
                end)
                Protected._raw.task_wait(1)
            end
        end)
    end

    VisionTab:CreateToggle({ Name = "ESP房子時間", CurrentValue = false, Callback = function(v) if v then enablePlotTimers() else disablePlotTimers() end end })
end

-- ==================== 腦紅 (物品) ESP ====================
do
    local Targets
    local function loadTargetsList()
        local url = "https://raw.githubusercontent.com/Nash29197/Nash-Hub/refs/heads/main/Steal%20a%20brainrot%20%7C%20List%202025%207%2022.lua"
        local content = Protected.httpGet(url, true )
        if content then
            local loadFunc, err = Protected._raw.loadstring(content)
            if loadFunc then
                local pcallSuccess, result = Protected.call(loadFunc)
                if pcallSuccess then Targets = result else warn("執行 Targets 列表時發生錯誤: ", result) end
            else warn("解析 Targets 列表時發生錯誤: ", err) end
        else warn("無法從 URL 獲取 Targets 列表。") end
    end
    loadTargetsList()

    local raritySettings = { ["Common"] = { Color = Color3.fromRGB(255, 255, 255), Enabled = false }, ["Rare"] = { Color = Color3.fromRGB(30, 144, 255), Enabled = false }, ["Epic"] = { Color = Color3.fromRGB(148, 0, 211), Enabled = false }, ["Legendary"] = { Color = Color3.fromRGB(255, 215, 0), Enabled = false }, ["Mythic"] = { Color = Color3.fromRGB(255, 0, 0), Enabled = false }, ["Brainrot God"] = { Color = Color3.fromRGB(255, 105, 180), Enabled = false }, ["Secret"] = { Color = Color3.fromRGB(0, 0, 0), Enabled = false } }
    local rarityOptions = {}; for r, _ in Protected._raw.pairs(raritySettings) do Protected._raw.table_insert(rarityOptions, r) end

    local brainrotEspEnabled = false
    local markedObjects = {}
    local connections = {}

    local function getHighestPart(model)
        local highest, y = nil, -math.huge
        for _, part in Protected._raw.ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") and part.Position.Y > y then y = part.Position.Y; highest = part end
        end
        return highest
    end

    local function removeESP(obj)
        local marked = markedObjects[obj]
        if marked then
            if marked.highlight and marked.highlight.Parent then marked.highlight:Destroy() end
            if marked.nametag and marked.nametag.Parent then marked.nametag:Destroy() end
            markedObjects[obj] = nil
        end
    end

    local function applyESP(obj)
        if not (obj and obj:IsA("Model") and obj.Parent) then return end
        removeESP(obj)
        local data = Targets and Targets[obj.Name]
        if not (data and data.quality and raritySettings[data.quality]) then return end
        if not (brainrotEspEnabled and raritySettings[data.quality].Enabled) then return end

        local highlight = Protected.instance("Highlight")
        highlight.FillColor, highlight.FillTransparency, highlight.OutlineColor, highlight.OutlineTransparency, highlight.Adornee, highlight.Parent = raritySettings[data.quality].Color, 0.7, Color3.new(1, 1, 1), 0.5, obj, obj

        local highestPart = getHighestPart(obj)
        if highestPart then
            local nametag = Protected.instance("BillboardGui")
            nametag.Size, nametag.StudsOffset, nametag.AlwaysOnTop, nametag.Adornee = UDim2.new(0, 150, 0, 30), Vector3.new(0, 2.5, 0), true, highestPart
            local label = Protected.instance("TextLabel")
            label.Size, label.BackgroundTransparency, label.Text, label.TextColor3, label.TextStrokeColor3, label.TextStrokeTransparency, label.TextScaled, label.Font, label.Parent = UDim2.new(1, 0, 1, 0), 1, obj.Name, raritySettings[data.quality].Color, Color3.new(0, 0, 0), 0.5, true, Enum.Font.GothamBold, nametag
            nametag.Parent = highestPart
            markedObjects[obj] = { highlight = highlight, nametag = nametag }
        else
            markedObjects[obj] = { highlight = highlight }
        end
    end

    local function refreshAllObjects()
        for obj, _ in Protected._raw.pairs(markedObjects) do removeESP(obj) end
        if brainrotEspEnabled then
            for _, obj in Protected._raw.ipairs(Workspace:GetDescendants()) do applyESP(obj) end
        end
    end

    local function setBrainrotEspActive(isActive)
        brainrotEspEnabled = isActive
        for _, conn in Protected._raw.ipairs(connections) do conn:Disconnect() end; Protected._raw.table_clear(connections)
        if isActive then
            refreshAllObjects()
            Protected._raw.table_insert(connections, Protected.connect(Workspace.DescendantAdded, function(d) Protected._raw.task_wait(0.1); applyESP(d) end))
            Protected._raw.table_insert(connections, Protected.connect(Workspace.DescendantRemoving, removeESP))
        else
            for obj, _ in Protected._raw.pairs(markedObjects) do removeESP(obj) end
        end
    end

    VisionTab:CreateToggle({ Name = "啟用腦紅 ESP", CurrentValue = false, Callback = function(v) setBrainrotEspActive(v) end })
    VisionTab:CreateDropdown({ Name = "ESP腦紅稀有度", Options = rarityOptions, CurrentOption = {}, MultipleOptions = true, Callback = function(selected)
        for rarity, settings in Protected._raw.pairs(raritySettings) do settings.Enabled = Protected._raw.table_find(selected, rarity) end
        refreshAllObjects()
    end })
end

-- ==================== 自動商店 ====================
do
    local ShopItems, buyRemote
    local function loadShopItemsFromURL(url)
        local content = Protected.httpGet(url )
        if content then
            local f, e = Protected._raw.loadstring(content)
            if f then
                local s2, r = Protected.call(f)
                if s2 and typeof(r) == "table" then return r end
            end
        end
        return {}
    end
    ShopItems = loadShopItemsFromURL("https://raw.githubusercontent.com/Nash29197/Nash-Hub/refs/heads/main/Steal%20a%20brainrot%20%7C%20Shop%20Items%202025%207%2022.lua" )
    
    local s, r = Protected.call(ReplicatedStorage.WaitForChild, ReplicatedStorage, "Remotes", 5)
    if s and r then buyRemote = r:FindFirstChild("Buy") end
    if not buyRemote then warn("找不到購買用的 RemoteFunction!") return end

    local selectedItems, trapCount, autoBuyEnabled, isBuying, buyRequestPending = {}, 1, false, false, false
    local purchaseDelays = { ["Grapple Hook"] = 0.2, ["Trap"] = 0.2, ["Speed Coil"] = 0.2 }; local defaultDelay = 0.4

    local function countItemInInventory(itemName)
        Protected._raw.task_wait(0.1)
        local count = 0
        if LocalPlayer.Character then for _, item in Protected._raw.ipairs(LocalPlayer.Character:GetChildren()) do if item.Name == itemName then count = count + 1 end end end
        if LocalPlayer.Backpack then for _, item in Protected._raw.ipairs(LocalPlayer.Backpack:GetChildren()) do if item.Name == itemName then count = count + 1 end end end
        return count
    end

    local function buyItem(item, count)
        for i = 1, count or 1 do
            if not autoBuyEnabled then break end
            Protected.call(buyRemote.InvokeServer, buyRemote, item)
            Protected._raw.task_wait(purchaseDelays[item] or defaultDelay)
        end
    end

    local function buySelectedItemsSequential()
        if isBuying then buyRequestPending = true; return end
        isBuying = true
        Protected._raw.task_spawn(function()
            while autoBuyEnabled do
                local allDone = true
                for _, item in Protected._raw.ipairs(ShopItems) do
                    if not autoBuyEnabled then break end
                    if Protected._raw.table_find(selectedItems, item) then
                        local currentCount = countItemInInventory(item)
                        local need = 0
                        if item == "Trap" then need = math.min(trapCount, 5) elseif item == "Grapple Hook" then need = 5 else need = 1 end
                        if currentCount < need then allDone = false; buyItem(item, need - currentCount) end
                    end
                end
                if allDone then break end
                Protected._raw.task_wait(0.5)
            end
            isBuying = false
            if buyRequestPending and autoBuyEnabled then buyRequestPending = false; buySelectedItemsSequential() end
        end)
    end

    local dropdownOptions = Protected._raw.table_clone(ShopItems); Protected._raw.table_insert(dropdownOptions, 1, "All")
    ShopTab:CreateDropdown({ Name = "道具列表(可複選)", Options = dropdownOptions, CurrentOption = {}, MultipleOptions = true, Flag = "DropdownAutoBuy", Callback = function(Options)
        if Protected._raw.table_find(Options, "All") then selectedItems = Protected._raw.table_clone(ShopItems) else selectedItems = Options end
        if autoBuyEnabled then buySelectedItemsSequential() end
    end })
    ShopTab:CreateSlider({ Name = "夾子購買數量(1~5)", Range = {1,5}, Increment = 1, Suffix = "個", CurrentValue = trapCount, Flag = "TrapSlider", Callback = function(v) trapCount = v; if autoBuyEnabled then buySelectedItemsSequential() end end })
    ShopTab:CreateToggle({ Name = "自動購買", CurrentValue = false, Flag = "ToggleAutoBuy", Callback = function(v) autoBuyEnabled = v; if v then buySelectedItemsSequential() end end })
end

-- ==================== 開發者工具 ====================
do
    DevelopersTab:CreateButton({ Name = "Infinite Yield", Callback = function() Protected._raw.loadstring(Protected.httpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source' ))() end })
    DevelopersTab:CreateButton({ Name = "DEX", Callback = function() Protected._raw.loadstring(Protected.httpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/refs/heads/main/dex.lua' ))() end })
    DevelopersTab:CreateButton({ Name = "SimpleSpy", Callback = function() Protected._raw.loadstring(Protected.httpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/refs/heads/main/SimpleSpyV3/main.lua' ))() end })
end

-- 載入配置
Rayfield:LoadConfiguration()
