local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local rotationSpeed = 3600

local function degreesToRadians(deg)
    return math.rad(deg)
end

RunService.RenderStepped:Connect(function(deltaTime)
    local rotationAmount = degreesToRadians(rotationSpeed * deltaTime)
    
    local rotation = CFrame.Angles(0, rotationAmount, 0)

    rootPart.CFrame = rootPart.CFrame * rotation
end)
