local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 創建 ESP 的函數
local function createESP(player)
    -- 確保不對自己添加 ESP
    if player == LocalPlayer then return end

    -- 當角色加載時執行
    player.CharacterAdded:Connect(function(character)
        local highlight = Instance.new("Highlight") -- 使用 Highlight 功能
        highlight.Adornee = character -- 綁定到角色模型
        highlight.FillColor = Color3.fromRGB(255, 0, 0) -- 設置填充顏色 (紅色)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- 設置邊框顏色 (白色)
        highlight.Parent = character -- 將 Highlight 添加到角色
    end)

    -- 如果角色已經存在，立即添加 ESP
    if player.Character then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Parent = player.Character
    end
end

-- 初始化：為當前所有玩家添加 ESP
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

-- 當新玩家加入時，為其添加 ESP
Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)
