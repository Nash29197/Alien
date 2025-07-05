local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local visited = {}

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

-- 🎯 目標清單
local Targets = {
    ["Noobini Pizzanini"] = {enabled = true, quality = "Common"},
    ["Lirilí Larilá"] = {enabled = true, quality = "Common"},
    ["Tim Cheese"] = {enabled = true, quality = "Common"},
    ["Fluriflura"] = {enabled = true, quality = "Common"},
    ["Talpa Di Fero"] = {enabled = true, quality = "Common"},
    ["Svinina Bombardino"] = {enabled = true, quality = "Common"},
    ["Pipi Kiwi"] = {enabled = true, quality = "Common"},
    ["Trippi Troppi"] = {enabled = true, quality = "Rare"},
    ["Tung Tung Tung Sahur"] = {enabled = true, quality = "Rare"},
    ["Gangster Footera"] = {enabled = true, quality = "Rare"},
    ["Boneca Ambalabu"] = {enabled = true, quality = "Rare"},
    ["Ta Ta Ta Ta Sahur"] = {enabled = true, quality = "Rare"},
    ["Tric Trac Baraboom"] = {enabled = true, quality = "Rare"},
    ["Cappuccino Assassino"] = {enabled = true, quality = "Epic"},
    ["Brr Brr Patapim"] = {enabled = true, quality = "Epic"},
    ["Trulimero Trulicina"] = {enabled = true, quality = "Epic"},
    ["Bambini Crostini"] = {enabled = true, quality = "Epic"},
    ["Bananita Dolphinita"] = {enabled = true, quality = "Epic"},
    ["Perochello Lemonchello"] = {enabled = true, quality = "Epic"},
    ["Brri Brri Bicus Dicus Bombicus"] = {enabled = true, quality = "Epic"},
    ["Burbaloni Loliloli"] = {enabled = true, quality = "Legendary"},
    ["Chimpanzini Bananini"] = {enabled = true, quality = "Legendary"},
    ["Ballerina Cappuccina"] = {enabled = true, quality = "Legendary"},
    ["Chef Crabracadabra"] = {enabled = true, quality = "Legendary"},
    ["Glorbo Fruttodrillo"] = {enabled = true, quality = "Legendary"},
    ["Blueberrinni Octopusini"] = {enabled = true, quality = "Legendary"},
    ["Frigo Camelo"] = {enabled = true, quality = "Mythic"},
    ["Orangutini Ananassini"] = {enabled = true, quality = "Mythic"},
    ["Rhino Toasterino"] = {enabled = true, quality = "Mythic"},
    ["Bombardiro Crocodilo"] = {enabled = true, quality = "Mythic"},
    ["Bombombini Gusini"] = {enabled = true, quality = "Mythic"},
    ["Cocofanto Elefanto"] = {enabled = true, quality = "Brainrot God"},
    ["Gattatino Nyanino"] = {enabled = true, quality = "Brainrot God"},
    ["Girafa Celestre"] = {enabled = true, quality = "Brainrot God"},
    ["Tralalero Tralala"] = {enabled = true, quality = "Brainrot God"},
    ["Matteo"] = {enabled = true, quality = "Brainrot God"},
    ["Odin Din Din Dun"] = {enabled = true, quality = "Brainrot God"},
    ["Trenostruzzo Turbo 3000"] = {enabled = true, quality = "Brainrot God"},
    ["La Vacca Saturno Saturnita"] = {enabled = true, quality = "Secret"},
    ["Los Tralaleritos"] = {enabled = true, quality = "Secret"},
    ["Graipuss Medussi"] = {enabled = true, quality = "Secret"},
    ["La Grande Combinazione"] = {enabled = true, quality = "Secret"},
}

local RarityFilter = {}
if getgenv().Rarity then
    for rarity, data in pairs(getgenv().Rarity) do
        RarityFilter[rarity] = data.enabled
    end
else
    for _, r in ipairs({"Secret", "Brainrot God", "Mythic", "Legendary", "Epic", "Rare", "Common"}) do
        RarityFilter[r] = true
    end
end

local function GetEnabledTargets()
    local list = {}
    for name, data in pairs(Targets) do
        if data.enabled and RarityFilter[data.quality] then
            table.insert(list, {name = name, quality = data.quality})
        end
    end
    return list
end

local function FoundTarget()
    local enabledTargets = GetEnabledTargets()
    local foundList = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        for _, t in ipairs(enabledTargets) do
            if obj.Name == t.name then
                table.insert(foundList, {name = t.name, quality = t.quality})
            end
        end
    end
    return #foundList > 0, foundList
end

-- ✅ 隨機跳服（只選少於 8 人）
local function GetNextServer()
    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=100&sortOrder=Asc", PlaceId)
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success and result and result.data then
        local candidates = {}
        for _, server in ipairs(result.data) do
            if server.playing < 8 and not visited[server.id] and server.id ~= game.JobId then
                table.insert(candidates, server.id)
            end
        end
        if #candidates > 0 then
            local randomIndex = math.random(1, #candidates)
            local serverId = candidates[randomIndex]
            visited[serverId] = true
            return serverId
        end
    end
    return nil
end

-- ✅ ESP 區塊
local highlightColor = Color3.fromRGB(255, 0, 0)
local qualityColors = {
    ["Common"] = Color3.fromRGB(255, 255, 255),
    ["Rare"] = Color3.fromRGB(30, 144, 255),
    ["Epic"] = Color3.fromRGB(148, 0, 211),
    ["Legendary"] = Color3.fromRGB(255, 215, 0),
    ["Mythic"] = Color3.fromRGB(255, 0, 0),
    ["Secret"] = Color3.fromRGB(0, 0, 0),
}

local function getHighestPart(model)
    local highestPart = nil
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            if not highestPart or part.Position.Y > highestPart.Position.Y then
                highestPart = part
            end
        end
    end
    return highestPart
end

local function createNameTag(part, name, quality)
    if part:FindFirstChild("ESP_NameTag") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_NameTag"
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = part
    billboard.Parent = part

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = qualityColors[quality] or Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
end

local function addHighlightToAllParts(model, color)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and not part:FindFirstChild("ESP_Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.FillColor = color
            highlight.FillTransparency = 0
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.OutlineTransparency = 0
            highlight.Adornee = part
            highlight.Parent = part
        end
    end
end

local function addESP(obj)
    if not obj:IsA("Model") then return end
    local targetData = Targets[obj.Name]
    if not targetData or not targetData.enabled or not RarityFilter[targetData.quality] then return end
    addHighlightToAllParts(obj, highlightColor)
    local adorneePart = getHighestPart(obj)
    if adorneePart then
        createNameTag(adorneePart, obj.Name, targetData.quality)
    end
end

-- 掃描現有
for _, obj in ipairs(workspace:GetDescendants()) do
    addESP(obj)
end
-- 新增自動 ESP
workspace.DescendantAdded:Connect(addESP)

-- ✅ 跳服主程式
local function StartHopping()
    while true do
        task.wait(0.2)
        local found, foundList = FoundTarget()

        if found then
            if #foundList >= 2 then
                local lines = {}
                for _, t in ipairs(foundList) do
                    table.insert(lines, t.name .. "（" .. t.quality .. "）")
                end
                Notify("找到多個目標", table.concat(lines, "\n"), 8)
            else
                local t = foundList[1]
                Notify("找到目標", t.name .. "（" .. t.quality .. "）", 6)
            end
            break
        end

        local nextServer = GetNextServer()
        if nextServer then
            Notify("跳轉伺服器", "伺服器 ID：" .. nextServer, 3)
            local success, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceId, nextServer, LocalPlayer)
            end)
            if not success and string.find(err, "772") then
                warn("❌ 傳送失敗（772），已忽略")
            end
            task.wait(2)
        end
    end
end

StartHopping()
