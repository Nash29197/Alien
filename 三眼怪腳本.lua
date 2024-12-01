local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "全遊戲通用腳本 by 三眼怪",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "三眼怪腳本",
   LoadingSubtitle = "by 三眼怪",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "三眼怪腳本"
   },
   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "全遊戲通用腳本|Key",
      Subtitle = "by 三眼怪",
      Note = "求我呀!!!", -- Use this to tell the user how to get a key
      FileName = "三眼怪 ON TOP", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"三眼怪 ON TOP"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("🏠HOME", nil) -- Title, Image
local MainSection = MainTab:CreateSection("主要功能")

Rayfield:Notify({
   Title = "歡迎來到三眼怪腳本!",
   Content = "作者 by 三眼怪",
   Duration = 6.5,
   Image = nil,
})

-- 存儲所有 Highlight 的表
local Highlights = {}

-- 創建切換按鈕
local Toggle = MainTab:CreateToggle({
    Name = "透視",
    CurrentValue = false,
    Flag = "三眼怪透視", -- 設置唯一的旗標，防止重疊
    Callback = function(Value)
        -- 如果 Value 為 true，啟用 ESP；如果為 false，禁用 ESP
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        -- 創建 ESP 的函數
        local function createESP(player)
            if player == LocalPlayer then return end -- 不對自己添加 ESP

            -- 當角色加載時執行
            player.CharacterAdded:Connect(function(character)
                -- 等待角色完全加載
                local highlight = Instance.new("Highlight")
                highlight.Adornee = character
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- 紅色
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- 白色
                highlight.Parent = character
                table.insert(Highlights, highlight) -- 存儲 Highlight
            end)

            -- 如果角色已經存在，立即添加 ESP
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = player.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Parent = player.Character
                table.insert(Highlights, highlight) -- 存儲 Highlight
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

        -- 禁用 ESP 的邏輯
        if not Value then
            -- 清除所有 Highlight
            for _, highlight in pairs(Highlights) do
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
            end
            Highlights = {} -- 重置表
            print("ESP Disabled")
        else
            print("ESP Enabled")
        end
    end,
})
