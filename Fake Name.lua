-- LocalScript 放置於 StarterPlayerScripts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

player.CharacterAdded:Connect(function(character)
    -- 等待角色頭部加載完成
    local head = character:WaitForChild("Head")
    -- 創建 BillboardGui
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Parent = head
    billboardGui.Size = UDim2.new(5, 0, 1, 0)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true
    
    -- 創建文本標籤
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboardGui
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "你的自訂名稱" -- 這裡填寫您想要的名字
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = true
end)
