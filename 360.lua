local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- 旋轉速度（度/秒）
local rotationSpeed = 3600 -- 每秒旋轉 60 度

-- 將角度轉換為弧度
local function degreesToRadians(deg)
	return math.rad(deg)
end

-- 每幀更新
RunService.RenderStepped:Connect(function(deltaTime)
	local rotationAmount = degreesToRadians(rotationSpeed * deltaTime)
	
	-- 建立旋轉的 CFrame
	local rotation = CFrame.Angles(0, rotationAmount, 0)

	-- 將旋轉套用在 HumanoidRootPart 的 CFrame
	rootPart.CFrame = rootPart.CFrame * rotation
end)
