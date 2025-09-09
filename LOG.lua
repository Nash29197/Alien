local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local WebhookUrl = "https://discord.com/api/webhooks/1389953544009814106/83Lx-nyCheX0oe9e-4e_cIJF_TU4JPxMGiYSxomG8RoGCa6S_bJeQOfFzS8CzwnI-nXg"

Players.PlayerAdded:Connect(function(player)
	local region = "Unknown"
	local success, result = pcall(function()
		return LocalizationService:GetCountryRegionForPlayerAsync(player)
	end)
	if success and result then
		region = result
	end

	local device = "Unknown"
	if UserInputService.TouchEnabled then
		device = "Mobile"
	elseif UserInputService.GamepadEnabled then
		device = "Console (Gamepad)"
	elseif UserInputService.MouseEnabled then
		device = "PC (Desktop)"
	end

	local gameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
	local gameName = gameInfo.Name
	local gameId = game.PlaceId

	local isPremium = "No"
	if player.MembershipType == Enum.MembershipType.Premium then
		isPremium = "Yes"
	end

	local embed = {
		title = player.DisplayName .. " has joined " .. gameName .. " (" .. gameId .. ")",
		description = "",
		color = 16711680,
		fields = {
			{ name = "Username", value = player.Name, inline = true },
			{ name = "User ID", value = tostring(player.UserId), inline = true },
			{ name = "Country", value = region, inline = true },
			{ name = "Join Date", value = player.AccountAge .. " days ago", inline = true },
			{ name = "Device", value = device, inline = true },
			{ name = "Premium", value = isPremium, inline = true },
		},
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	}

	local data = {
		embeds = { embed }
	}

	local jsonData = HttpService:JSONEncode(data)

	local success, err = pcall(function()
		HttpService:PostAsync(WebhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
	end)

	if not success then
		warn("Failed to send webhook: " .. tostring(err))
	end
end)
