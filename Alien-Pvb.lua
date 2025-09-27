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

local VirtualUser = game:GetService('VirtualUser')
 
game:GetService('Players').LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

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
        Max = 150,
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

local FarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "house",
    Locked = false,
})

local AutoFarmToggle = false

local Toggle = FarmTab:Toggle({
    Title = "Auto Brainrot",
    Default = false,
    Callback = function(state)
        AutoFarmToggle = state
        print("Toggle Activated: " .. tostring(state))
    end
})

repeat task.wait() until game:IsLoaded()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Backpack = LocalPlayer:WaitForChild("Backpack")

local ClickInterval = 0.01
local HeldToolName = "Leather Grip Bat"

local BrainrotsCache = {}

local function UpdateBrainrotsCache()
    local folder = Workspace:WaitForChild("ScriptedMap"):WaitForChild("Brainrots")
    BrainrotsCache = {}
    for _, b in ipairs(folder:GetChildren()) do
        if b:FindFirstChild("BrainrotHitbox") then
            table.insert(BrainrotsCache, b)
        end
    end
end

local function GetNearestBrainrot()
    local nearest = nil
    local minDist = math.huge
    for _, b in ipairs(BrainrotsCache) do
        local hitbox = b:FindFirstChild("BrainrotHitbox")
        if hitbox then
            local dist = (HumanoidRootPart.Position - hitbox.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = b
            end
        end
    end
    return nearest
end

local function EquipBat()
    local tool = Backpack:FindFirstChild(HeldToolName) or Character:FindFirstChild(HeldToolName)
    if tool then
        tool.Parent = Character
    end
end

local function InstantWarpToBrainrot(brainrot)
    local hitbox = brainrot:FindFirstChild("BrainrotHitbox")
    if hitbox then
        local offset = Vector3.new(0, 1, 3)
        HumanoidRootPart.CFrame = CFrame.new(hitbox.Position + offset, hitbox.Position)
    end
end

local function AttackBrainrot(brainrot)
    local hitbox = brainrot:FindFirstChild("BrainrotHitbox")
    if hitbox then
        local args = {
            [1] = {
                [1] = {
                    ["target"] = hitbox
                }
            }
        }
        pcall(function()
            ReplicatedStorage.Remotes.AttacksServer.WeaponAttack:FireServer(unpack(args))
        end)
    end
end

task.spawn(function()
    while true do
        if AutoFarmToggle then
            EquipBat()
            UpdateBrainrotsCache()

            local target = GetNearestBrainrot()
            if target then
                InstantWarpToBrainrot(target)
                AttackBrainrot(target)
            end
        end
        task.wait(ClickInterval)
    end
end)

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

local Section = ShopTab:Section({ 
    Title = "Shop",
    TextXAlignment = "Left",
    TextSize = 17,
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

local seeds = {
    "Cactus Seed",
    "Strawberry Seed",
    "Sunflower Seed",
    "Pumpkin Seed",
    "Dragon Fruit Seed",
    "Eggplant Seed",
    "Watermelon Seed",
    "Grape Seed",
    "Cocotank Seed",
    "Carnivorous Plant Seed",
    "Mr Carrot Seed",
    "Tomatrio Seed",
    "Shroombino Seed"
}

local selectedSeeds = {}
local autoBuySelected = false
local autoBuyAll = false
local cooldown = 0.69

local SeedDropdown = ShopTab:Dropdown({
    Title = "Select Seeds",
    Values = seeds,
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(options)
        selectedSeeds = options
    end
})

local ToggleSelected = ShopTab:Toggle({
    Title = "Auto Buy Seeds",
    Default = false,
    Callback = function(state)
        autoBuySelected = state
    end
})

local ToggleAll = ShopTab:Toggle({
    Title = "Auto Buy All Seeds",
    Default = false,
    Callback = function(state)
        autoBuyAll = state
    end
})

task.spawn(function()
    while true do
        if autoBuyAll then
            for _, seed in ipairs(seeds) do
                if not autoBuyAll then break end
                local args = {
                    [1] = {
                        [1] = seed,
                        [2] = "\8"
                    }
                }
                RemoteEvent:FireServer(unpack(args))
                task.wait(cooldown)
            end
        elseif autoBuySelected and #selectedSeeds > 0 then
            for _, seed in ipairs(seeds) do
                if not autoBuySelected then break end
                if table.find(selectedSeeds, seed) then
                    local args = {
                        [1] = {
                            [1] = seed,
                            [2] = "\8"
                        }
                    }
                    RemoteEvent:FireServer(unpack(args))
                    task.wait(cooldown)
                end
            end
        end
        task.wait(0.1)
    end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

local tools = {
    "Water Bucket",
    "Frost Grenade",
    "Banana Gun",
    "Frost Blower",
    "Carrot Launcher"
}

local selectedTools = {}
local autoBuySelected = false
local autoBuyAll = false
local cooldown = 0.69

local ToolDropdown = ShopTab:Dropdown({
    Title = "Select Gears",
    Values = tools,
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(options)
        selectedTools = options
    end
})

local ToggleSelected = ShopTab:Toggle({
    Title = "Auto Buy Gears",
    Default = false,
    Callback = function(state)
        autoBuySelected = state
    end
})

local ToggleAll = ShopTab:Toggle({
    Title = "Auto Buy All Gears",
    Default = false,
    Callback = function(state)
        autoBuyAll = state
    end
})

task.spawn(function()
    while true do
        if autoBuyAll then
            for _, tool in ipairs(tools) do
                if not autoBuyAll then break end
                local args = {
                    [1] = {
                        [1] = tool,
                        [2] = "\26"
                    }
                }
                RemoteEvent:FireServer(unpack(args))
                task.wait(cooldown)
            end
        elseif autoBuySelected and #selectedTools > 0 then
            for _, tool in ipairs(tools) do
                if not autoBuySelected then break end
                if table.find(selectedTools, tool) then
                    local args = {
                        [1] = {
                            [1] = tool,
                            [2] = "\26"
                        }
                    }
                    RemoteEvent:FireServer(unpack(args))
                    task.wait(cooldown)
                end
            end
        end
        task.wait(0.1)
    end
end)

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
