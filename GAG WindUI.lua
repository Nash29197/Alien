local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua" ))()
local Window = WindUI:CreateWindow({
    Title = "Alien-Pvb",
    Icon = "door-open",
    Author = "by @bos87k",
    Folder = "N++ Hub",
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
    Title = "玩家",
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
    Desc = "Speed ​​boost value",
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

local player = game.Players.LocalPlayer
local humanoid = nil
local isInfiniteJumpToggled = false

local function onCharacterAdded(character)
    humanoid = character:WaitForChild("Humanoid")
    
    humanoid.StateChanged:Connect(function(oldState, newState)
        if isInfiniteJumpToggled and newState == Enum.HumanoidStateType.Jumping then
            humanoid:ChangeState(Enum.HumanoidStateType.Landed)
        end
    end)
end

player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
    onCharacterAdded(player.Character)
end

local InfiniteJumpToggle = PlayerTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Can Infinite Jump",
    Default = false,
    Callback = function(state) 
        isInfiniteJumpToggled = state
    end
})

isInfiniteJumpToggled = InfiniteJumpToggle.Default

local MainTab = Window:Tab({
    Title = "主選單",
    Icon = "house", -- optional
    Locked = false,
})

local BagTab = Window:Tab({
    Title = "背包管理",
    Icon = "backpack", -- optional
    Locked = false,
})

local ShopTab = Window:Tab({
    Title = "商店",
    Icon = "shopping-cart", -- optional
    Locked = false,
})

local ESPTab = Window:Tab({
    Title = "視覺",
    Icon = "eye", -- optional
    Locked = false,
})

local MiscTab = Window:Tab({
    Title = "雜項",
    Icon = "text", -- optional
    Locked = false,
})

local SettingTab = Window:Tab({
    Title = "設定",
    Icon = "settings", -- optional
    Locked = false,
})

local DevTab = Window:Tab({
    Title = "開發者工具",
    Icon = "terminal", -- optional
    Locked = false,
})
