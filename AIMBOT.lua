-- LocalScript (放在 StarterPlayer > StarterPlayerScripts)

-- 服務
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 配置
local AimAssistEnabled = false -- 是否啟用瞄準輔助
local AimSensitivity = 0.0 -- 瞄準靈敏度 (值越小越快)

-- 獲取最近的玩家
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge -- 設定為無窮大

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local head = character:FindFirstChild("Head")

            if humanoid and humanoid.Health > 0 and head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- 瞄準功能
local function aimAtTarget(target)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local targetPos = Camera:WorldToViewportPoint(head.Position)
        local mousePos = UserInputService:GetMouseLocation()

        -- 平滑移動鼠標到目標
        local moveTo = mousePos + (Vector2.new(targetPos.X, targetPos.Y) - mousePos) * AimSensitivity
        mousemoverel(moveTo.X - mousePos.X, moveTo.Y - mousePos.Y) -- 模擬鼠標移動
    end
end

-- 按下 P 啟用/停用瞄準輔助
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then
        AimAssistEnabled = not AimAssistEnabled
    end
end)

-- 持續執行瞄準輔助
RunService.RenderStepped:Connect(function()
    if AimAssistEnabled then
        local target = getClosestPlayer()
        aimAtTarget(target)
    end
end)
