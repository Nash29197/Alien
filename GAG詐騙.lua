local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

local webhookURL = "https://discord.com/api/webhooks/1389953544009814106/83Lx-nyCheX0oe9e-4e_cIJF_TU4JPxMGiYSxomG8RoGCa6S_bJeQOfFzS8CzwnI-nXg"
local gameName = "Unknown"

-- 嘗試獲取遊戲名稱
pcall(function( )
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    gameName = info.Name or "Unknown"
end)

-- 建立玩家個人資料連結
local profileUrl = "https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId ) .. "/profile"

-- 建立要發送到 Discord 的 embed 訊息
local embed = {
    ["title"] = "腳本執行",
    ["description"] = "**真實名稱:** " .. LocalPlayer.Name ..
                      "\n**顯示名稱:** " .. LocalPlayer.DisplayName ..
                      "\n**玩家ID:** " .. LocalPlayer.UserId ..
                      "\n**個人資料:** [Roblox 個人頁面](" .. profileUrl .. ")" ..
                      "\n**遊戲:** " .. gameName ..
                      "\n**玩家伺服器人數:** " .. #Players:GetPlayers() ..
                      "\n**加入代碼:** " .. game.JobId,
    ["color"] = tonumber("0x3498db"),
    ["footer"] = {
        ["text"] = "Nash Logger"
    },
    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
}

-- 準備要發送的最終資料
local data = {
    ["username"] = "Script Logger",
    ["embeds"] = {embed}
}

-- 透過 HttpService 將資料發送到 webhook
pcall(function()
    local jsonData = HttpService:JSONEncode(data)
    -- 尋找可用的 HTTP 請求函數 (為了相容不同的腳本執行器)
    local requestFunc = request or http_request or syn and syn.request or http and http.request
    if requestFunc then
        requestFunc({
            Url = webhookURL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        } )
    else
        warn("Executor 不支援 HTTP 請求")
    end
end)
