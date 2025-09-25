local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua" ))()
local Window = WindUI:CreateWindow({
    Title = "Alien-Pvb",
    Icon = "door-open",
    Author = "by @bos87k",
    Folder = "Alien-Pvb",
    Transparent = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
        end,
    },
})

Window:EditOpenButton({
    Title = "Alien",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

WindUI:Notify({
    Title = "Welcome!!!",
    Content = "Welcome to Alien!!!",
    Duration = 3,
    Icon = "bell-plus",
})

local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "user-round-cog",
    Locked = false,
})

local Section = PlayerTab:Section({ 
    Title = "Player",
    TextXAlignment = "Left",
    TextSize = 17,
})

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local normalSpeed = 16
local currentSprintSpeed = 16
local isSprintToggled = false

local function updateWalkSpeed()
    if not humanoid then return end

    if isSprintToggled then
        humanoid.WalkSpeed = currentSprintSpeed
    else
        humanoid.WalkSpeed = normalSpeed
    end
end

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    updateWalkSpeed()
end)

local SprintToggle = PlayerTab:Toggle({
    Title = "Speed",
    Desc = "ON or OFF speed boost",
    Default = false,
    Callback = function(state) 
        isSprintToggled = state
        updateWalkSpeed()
    end
})

local SpeedSlider = PlayerTab:Slider({
    Title = "Speed Boost",
    Desc = "Speed boost value",
    Step = 1,
    Value = {
        Min = 16,
        Max = 300,
        Default = 16,
    },
    Callback = function(value)
        currentSprintSpeed = value
        updateWalkSpeed()
    end
})

currentSprintSpeed = SpeedSlider.Value.Default
isSprintToggled = SprintToggle.Default
updateWalkSpeed()

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local normalJumpPower = 50
local currentJumpPower = 50
local isJumpToggled = false

local function updateJumpPower()
    if not humanoid then return end

    if isJumpToggled then
        humanoid.JumpPower = currentJumpPower
    else
        humanoid.JumpPower = normalJumpPower
    end
end

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    updateJumpPower()
end)

local JumpToggle = PlayerTab:Toggle({
    Title = "Jump",
    Desc = "ON or OFF jump boost",
    Default = false,
    Callback = function(state) 
        isJumpToggled = state
        updateJumpPower()
    end
})

local JumpSlider = PlayerTab:Slider({
    Title = "Jump Boost",
    Desc = "Jump boost value",
    Step = 5,
    Value = {
        Min = 50,
        Max = 300,
        Default = 50,
    },
    Callback = function(value)
        currentJumpPower = value
        updateJumpPower()
    end
})

currentJumpPower = JumpSlider.Value.Default
isJumpToggled = JumpToggle.Default
updateJumpPower()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local NoclipConnection = nil
local isNoclipActive = false

local function Noclip()
    if not LocalPlayer or not LocalPlayer.Character then return end

    local Character = LocalPlayer.Character
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local Toggle = PlayerTab:Toggle({
    Title = "Noclip",
    Desc = "Wall hack",
    Default = false,
    Callback = function(state) 
        isNoclipActive = state

        if isNoclipActive then
            NoclipConnection = RunService.Stepped:Connect(Noclip)
        else
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
            
            if LocalPlayer and LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

local MainTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "house",
    Locked = false,
})

local BagTab = Window:Tab({
    Title = "Auto Sell",
    Icon = "backpack", -- optional
    Locked = false,
})

local ShopTab = Window:Tab({
    Title = "Shop",
    Icon = "shopping-cart", -- optional
    Locked = false,
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local purchaseEvent = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

local isFarming = false
local selectedItems = {}
local farmConnection = nil

local realSeeds = {
    "Cactus Seed", "Strawberry Seed", "Pumpkin Seed", "Sunflower Seed",
    "Dragon Fruit Seed", "Eggplant Seed", "Watermelon Seed", "Cocotank Seed",
    "Carnivorous Plant Seed", "Mr Carrot Seed", "Tomatrio Seed"
}

local displayValues = { "None", "All" }
for _, seed in ipairs(realSeeds) do
    table.insert(displayValues, seed)
end

local Dropdown = ShopTab:Dropdown({
    Title = "Select Seed",
    Desc = "Choose the seed you want",
    Values = displayValues,
    Default = {},
    Multi = true,
    AllowNone = true,
    Callback = function(items) 
        local isAllSelected = table.find(items, "All")
        local isNoneSelected = table.find(items, "None")

        if isNoneSelected then
            selectedItems = {}
            ItemDropdown:UpdateValues({ "None" }) 
            ItemDropdown:UpdateValues({})
            return
        end

        if isAllSelected then
            selectedItems = realSeeds
            local allPlusSeeds = { "All" }
            for _, seed in ipairs(realSeeds) do
                table.insert(allPlusSeeds, seed)
            end
            ItemDropdown:UpdateValues(allPlusSeeds)
            return
        end

        local newSelection = {}
        for _, item in ipairs(items) do
            if item ~= "All" and item ~= "None" then
                table.insert(newSelection, item)
            end
        end
        selectedItems = newSelection
    end
})

local Toggle = ShopTab:Toggle({
    Title = "Auto Buy Seed",
    Desc = "ON or OFF Auto buy seed",
    Default = false,
    Callback = function(state) 
        isFarming = state

        if isFarming then
            if #selectedItems == 0 then
                isFarming = false
                FarmToggle:Update(false)
                return
            end
            
            farmConnection = RunService.Heartbeat:Connect(function()
                for _, itemToBuy in ipairs(selectedItems) do
                    local args = { [1] = { [1] = itemToBuy, [2] = "\7" } }
                    purchaseEvent:FireServer(unpack(args))
                end
            end)
        else
            if farmConnection then
                farmConnection:Disconnect()
                farmConnection = nil
            end
        end
    end
})

local ESPTab = Window:Tab({
    Title = "ESP",
    Icon = "eye", -- optional
    Locked = false,
})

local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "text", -- optional
    Locked = false,
})

local SettingTab = Window:Tab({
    Title = "Setting",
    Icon = "settings", -- optional
    Locked = false,
})

local DevTab = Window:Tab({
    Title = "DEV Tool",
    Icon = "terminal", -- optional
    Locked = false,
})
