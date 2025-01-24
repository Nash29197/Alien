---------- [ Library ] ----------
local Library = loadstring(game:HttpGet("https://pastebin.com/raw/b5QLVFiM"))()

---------- [ Window ] ----------
local Window = Library:CreateWindow('Satr - Hub')

---------- [ Creat Tab ] ----------

local Tab = {
    Home = Window:addTab('•Home'),
    Settings = Window:addTab('•Settings'),
    Teleport = Window:addTab('•Teleport'),
    Shop = Window:addTab('•Shop'),
    Misc = Window:addTab('•Misc'),
}

---------- [ Home Left Menu ] ----------

local Home_Left = Tab.Home:addSection()
local Changelog = Home_Left:addMenu("#Changelog")
Changelog:addChangelog("[Januari, 3 2025]")
Changelog:addChangelog('- Added Teleport')
Changelog:addChangelog('- Added Auto Sell Fisch')
Changelog:addChangelog('- Added Auto Fisching')

---------- [ Home Right Menu ] ----------

local Home_Right = Tab.Home:addSection()
local Main_Home = Home_Right:addMenu("#Home")

---------- [ Global Config ] ----------
local config = {
    fpsCap = 9999,
    disableChat = false,
    enableBigButton = false,
    bigButtonScaleFactor = 2,
    shakeSpeed = 0.05,
    FreezeWhileFishing = true,
    autoFishing = false,
    checkFishStatus = false,
    autoSellFish = false,
}

-- Set FPS cap
setfpscap(config.fpsCap)

---------- [ Service ] ----------
local players = game:GetService("Players")
local vim = game:GetService("VirtualInputManager")
local run_service = game:GetService("RunService")
local replicated_storage = game:GetService("ReplicatedStorage")
local localplayer = players.LocalPlayer
local playergui = localplayer.PlayerGui
local StarterGui = game:GetService("StarterGui")
local tweenService = game:GetService("TweenService")

---------- [ Disable Chat ] ----------
if config.disableChat then
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
end

---------- [ Utility Function ] ----------
local utility = {}; do
    function utility.simulate_click(x, y, mb)
        vim:SendMouseButtonEvent(x, y, (mb - 1), true, game, 1)
        vim:SendMouseButtonEvent(x, y, (mb - 1), false, game, 1)
    end

    function utility.auto_center_button(button)
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local centerX = (viewportSize.X - button.AbsoluteSize.X) / 2
        local centerY = (viewportSize.Y - button.AbsoluteSize.Y) / 2
        button.Position = UDim2.new(0, centerX, 0, centerY)
    end
end

local farm = {reel_tick = nil, cast_tick = nil, is_shaking = false}; do
    function farm.find_rod()
        local character = localplayer.Character
        if not character then return nil end

        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:find("rod") or tool.Name:find("Rod")) then
                return tool
            end
        end
        return nil
    end

    function farm.freeze_character(freeze)
        local character = localplayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if freeze then
                    humanoid.WalkSpeed = 0
                    humanoid.JumpPower = 0
                else
                    humanoid.WalkSpeed = 16
                    humanoid.JumpPower = 50
                end
            end
        end
    end

    function farm.cast()
        local character = localplayer.Character
        if not character then return end

        local rod = farm.find_rod()
        if not rod then return end

        local args = { [1] = 100, [2] = 1 }
        rod.events.cast:FireServer(unpack(args))
        farm.cast_tick = 0
    end

    function farm.shake()
        if farm.is_shaking then return end

        local shake_ui = playergui:FindFirstChild("shakeui")
        if shake_ui then
            local safezone = shake_ui:FindFirstChild("safezone")
            local button = safezone and safezone:FindFirstChild("button")

            if button then
                utility.auto_center_button(button)

                button.Size = UDim2.new(0.5, 0, 0.5, 0)

                if button.Visible then
                    farm.is_shaking = true
                    utility.simulate_click(
                        button.AbsolutePosition.X + button.AbsoluteSize.X / 2,
                        button.AbsolutePosition.Y + button.AbsoluteSize.Y / 2,
                        1
                    )
                    task.wait(0.1)
                    farm.is_shaking = false
                end
            end
        end
    end
    
    function farm.reel()
        local reel_ui = playergui:FindFirstChild("reel")
        if not reel_ui then return end

        local reel_bar = reel_ui:FindFirstChild("bar")
        if not reel_bar then return end

        local reel_client = reel_bar:FindFirstChild("reel")
        if not reel_client then return end

        if reel_client.Disabled == true then
            reel_client.Disabled = false
        end

        local update_colors = getsenv(reel_client).UpdateColors

        if update_colors then
            setupvalue(update_colors, 1, 100)
            replicated_storage.events.reelfinished:FireServer(getupvalue(update_colors, 1), true)
        end
    end
end

Main_Home:addToggle("Auto Fishing", config.autoFishing, function(state)
    config.autoFishing = state
    if state then
        StarterGui:SetCore("SendNotification", {
            Title = "Auto Fishing";
            Text = "Auto Fishing activated!";
            Duration = 5;
        })

        spawn(function()
            while config.autoFishing and task.wait(config.shakeSpeed) do
                local rod = farm.find_rod()
                if rod then
                    if config.FreezeWhileFishing then
                        farm.freeze_character(true)
                    end
                    farm.cast()
                    task.wait(0.5)
                    farm.shake()
                    farm.reel()
                else
                    farm.freeze_character(false)
                end
            end
        end)
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Auto Fishing";
            Text = "Auto Fishing deactivated!";
            Duration = 5;
        })
    end
end)

Main_Home:addButton("Sell All Fish", function()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local sellEvent = replicatedStorage:WaitForChild("events"):WaitForChild("selleverything")

    if sellEvent and sellEvent:IsA("RemoteFunction") then
        sellEvent:InvokeServer()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Success!";
            Text = "All fish have been sold!";
            Duration = 5;
        })
    else
        warn("Sell event not found or not a RemoteFunction!")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Error!";
            Text = "Sell event not found!";
            Duration = 5;
        })
    end
end)

Main_Home:addButton("Sell Fish (In Hand)", function()
    local workspaceService = game:GetService("Workspace")
    local npc = workspaceService:WaitForChild("world"):WaitForChild("npcs"):FindFirstChild("Merchant")

    if npc and npc:FindFirstChild("merchant") and npc.merchant:FindFirstChild("sell") then
        if npc.merchant.sell:IsA("RemoteFunction") then
            npc.merchant.sell:InvokeServer()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Success!";
                Text = "Fish in hand has been sold!";
                Duration = 5;
            })
        else
            warn("'sell' is not a RemoteFunction!")
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Error!";
                Text = "'sell' is not a valid RemoteFunction!";
                Duration = 5;
            })
        end
    else
        warn("Marc Merchant NPC or its structure is invalid!")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Error!";
            Text = "Marc Merchant or its structure is invalid!";
            Duration = 5;
        })
    end
end)

Main_Home:addButton("Show UI Buy Boat", function()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local shipwrightUI = playerGui:WaitForChild("hud"):WaitForChild("safezone"):FindFirstChild("shipwright")

    if shipwrightUI and shipwrightUI:IsA("GuiObject") then
        shipwrightUI.Visible = not shipwrightUI.Visible
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "UI Status";
            Text = shipwrightUI.Visible and "Buy Boat UI is now visible!" or "Buy Boat UI is now hidden!";
            Duration = 5;
        })
    else
        warn("Shipwright UI not found or is not a valid GuiObject!")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Error!";
            Text = "Shipwright UI not found!";
            Duration = 5;
        })
    end
end)

---------- [ Settings Menu ] ----------

local Settings_Left = Tab.Settings:addSection()
local Settings = Settings_Left:addMenu("Settings")

getgenv().JumpValue = config.JumpValue or 50
Settings:addTextbox("Jump Hack", getgenv().JumpValue, function(jumpfunc)
    getgenv().JumpValue = tonumber(jumpfunc)
    handleJumpHack()
end)

Settings:addToggle("Infinite Jump", getgenv().InfiniteJumpEnabled, function(Value)
    getgenv().InfiniteJumpEnabled = Value
    if getgenv().InfiniteJumpEnabled then
        game:GetService("UserInputService").JumpRequest:connect(function()
            game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
        end)
    end
end)

-- Toggle Water Walking
local waterWalkingEnabled = false
Settings:addToggle('Toggle Water Walking', function()
    waterWalkingEnabled = not waterWalkingEnabled

    -- Mengaktifkan atau menonaktifkan Water Walking
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    if waterWalkingEnabled then
        humanoid.PlatformStand = true  -- Mengatur untuk bisa berjalan di air
    else
        humanoid.PlatformStand = false  -- Kembalikan ke pengaturan normal
    end
end)

Settings:addToggle('No Clip', getgenv().NoClip, function(clipf)
    getgenv().NoClip = clipf
end)
spawn(function()
    pcall(function()
        game:GetService("RunService").Stepped:Connect(function()
            if getgenv().NoClip then
                for i,v in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end)
end)

-- Mendapatkan LocalPlayer
local LocalPlayer = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DayOnlyLoop = nil

Settings: addToggle('Infinite Oxygen', function(state)
    local player = game.Players.LocalPlayer
    local character = player and player.Character
    if character then
        local client = character:FindFirstChild("client")
        if client then
            local oxygen = client:FindFirstChild("oxygen")
            if oxygen then
                if state then
                    oxygen.Disabled = true  -- Menonaktifkan oksigen untuk efek tak terbatas
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Infinite Oxygen Activated";
                        Text = "Oxygen has been disabled.";
                        Duration = 5;
                    })
                else
                    oxygen.Disabled = false  -- Mengaktifkan kembali oksigen jika toggle dimatikan
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Infinite Oxygen Deactivated";
                        Text = "Oxygen is back to normal.";
                        Duration = 5;
                    })
                end
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Infinite Oxygen Failed";
                    Text = "Cannot find 'oxygen' object!";
                    Duration = 5;
                })
                warn("Tidak dapat menemukan 'oxygen' di dalam client!")
            end
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Infinite Oxygen Failed";
                Text = "Cannot find 'client' in character!";
                Duration = 5;
            })
            warn("Tidak dapat menemukan 'client' dalam karakter!")
        end
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Infinite Oxygen Failed";
            Text = "Player's character not found!";
            Duration = 5;
        })
        warn("Karakter pemain tidak ditemukan!")
    end
end)

-- Weather Clear
Settings:addToggle('Weather Clear', function(state)
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local world = replicatedStorage:WaitForChild("world")
    local weather = world:WaitForChild("weather")

    -- Validasi apakah objek weather ada
    if weather then
        local oldWeather = weather.Value
        if state then
            -- Set cuaca menjadi Clear
            weather.Value = 'Clear'
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Weather Clear Activated";
                Text = "The weather has been successfully set to clear.";
                Duration = 5;
            })
            warn("Cuaca telah diubah menjadi cerah.")
        else
            -- Kembalikan ke cuaca awal
            weather.Value = oldWeather
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Weather Clear Deactivated";
                Text = "The weather has been reset to its original state.";
                Duration = 5;
            })
            warn("Cuaca telah dikembalikan ke kondisi semula.")
        end
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Weather Clear Failed";
            Text = "Cannot find weather object in ReplicatedStorage!";
            Duration = 5;
        })
        warn("Tidak dapat menemukan objek 'weather' di ReplicatedStorage!")
    end
end)

-- Remove Fog
Settings:addButton('Remove Fog', function()
    local lighting = game:GetService("Lighting")
    local sky = lighting:FindFirstChild("Sky")
    if sky then
        -- Menyembunyikan fog dengan memindahkan Sky ke dalam Bloom jika ada
        sky.Parent = lighting:FindFirstChild("bloom") or lighting
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Fog Removed";
            Text = "Fog has been successfully removed from the environment.";
            Duration = 5;
        })
        warn("Fog telah dihapus dari lingkungan.")
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Remove Fog Failed";
            Text = "Sky object not found in Lighting!";
            Duration = 5;
        })
        warn("Tidak dapat menemukan objek 'Sky' di Lighting!")
    end
end)

-- Day Only
Settings:addToggle('Day Only', function(state)
    local lighting = game:GetService("Lighting")
    if not lighting then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Day Only Failed";
            Text = "Lighting service is unavailable!";
            Duration = 5;
        })
        warn("Layanan Lighting tidak tersedia!")
        return
    end

    -- Menjaga loop agar lebih terorganisir dan terkontrol
    if DayOnlyLoop then
        DayOnlyLoop:Disconnect()
        DayOnlyLoop = nil
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Day Only Deactivated";
            Text = "The game will cycle through day and night again.";
            Duration = 5;
        })
        warn("Mode Day Only telah dinonaktifkan.")
    else
        if state then
            -- Aktivasi mode Day Only (siang saja)
            DayOnlyLoop = game:GetService("RunService").Heartbeat:Connect(function()
                lighting.TimeOfDay = "12:00:00"  -- Tetap pada siang hari
            end)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Day Only Activated";
                Text = "The game will stay in daytime.";
                Duration = 5;
            })
            warn("Mode Day Only telah diaktifkan. Game akan selalu berada di siang hari.")
        end
    end
end)

getgenv().AntiAFK = true
Settings:addToggle("Anti AFK", getgenv().AntiAFK, function(Value)
    getgenv().AntiAFK = Value
end)

task.spawn(function ()
    while wait(.1) do
        if getgenv().AntiAFK then
            local vu = game:GetService("VirtualUser")
            game:GetService("Players").LocalPlayer.Idled:connect(function()
                vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                wait(1)
                vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

getgenv().AntiKickClient = true
Settings:addToggle("Anti Kick Client", getgenv().AntiKickClient, function(Value)
    getgenv().AntiKickClient = Value
end)
task.spawn(function()
    while wait() do
        if getgenv().AntiKickClient then
            loadstring(game:HttpGet('https://gitlab.com/Sky2836/BT/-/raw/main/antikickclient'))()
        end
    end
end)

Settings:addButton("FPS Boost", function()
    local decalsyeeted = false
    local g = game
    local w = g.Workspace
    local l = g.Lighting
    local t = w.Terrain
    t.WaterWaveSize = 0
    t.WaterWaveSpeed = 0
    t.WaterReflectance = 0
    t.WaterTransparency = 0
    l.GlobalShadows = false
    l.FogEnd = 9e9
    l.Brightness = 0
    settings().Rendering.QualityLevel = "Level01"
    for i, v in pairs(g:GetDescendants()) do
        if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then 
            v.Material = "Plastic"
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("MeshPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
            v.TextureID = 10385902758728957
        end
    end
    for i, e in pairs(l:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
            e.Enabled = false
        end
    end
end)

Settings:addButton("Destroy GUI", function()
    Library:DestroyGui()
end)

---------- [ Server Menu ] ----------

local Settings_Right = Tab.Settings:addSection()
local Settings_1 = Settings_Right:addMenu("Server")

Settings_1:addButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
end)

Settings_1:addButton("Server Hop", function()
    Hop()
end)
function Hop()
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour
    local Deleted = false
    function TPReturner()
        local Site;
        if foundAnything == "" then
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
        else
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
        end
        local ID = ""
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
            foundAnything = Site.nextPageCursor
        end
        local num = 0;
        for i,v in pairs(Site.data) do
            local Possible = true
            ID = tostring(v.id)
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _,Existing in pairs(AllIDs) do
                    if num ~= 0 then
                        if ID == tostring(Existing) then
                            Possible = false
                        end
                    else
                        if tonumber(actualHour) ~= tonumber(Existing) then
                            local delFile = pcall(function()
                                -- delfile("NotSameServers.json")
                                AllIDs = {}
                                table.insert(AllIDs, actualHour)
                            end)
                        end
                    end
                    num = num + 1
                end
                if Possible == true then
                    table.insert(AllIDs, ID)
                    wait(.1)
                    pcall(function()
                        -- writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                        wait()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                    end)
                    wait(.1)
                end
            end
        end
    end
    function Teleport() 
        while wait(.1) do
            pcall(function()
                TPReturner()
                if foundAnything ~= "" then
                    TPReturner()
                end
            end)
        end
    end
    Teleport()
end

Settings_1:addButton("Teleport To Lower Server", function()
    local maxplayers, gamelink, goodserver, data_table = math.huge, "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    if not _G.FailedServerID then _G.FailedServerID = {} end

    local function serversearch()
        data_table = game:GetService"HttpService":JSONDecode(game:HttpGetAsync(gamelink))
        for _, v in pairs(data_table.data) do
            pcall(function()
                if type(v) == "table" and v.id and v.playing and tonumber(maxplayers) > tonumber(v.playing) and not table.find(_G.FailedServerID, v.id) then
                    maxplayers = v.playing
                    goodserver = v.id
                end
            end)
        end
    end

    function getservers()
        pcall(serversearch)
        for i, v in pairs(data_table) do
            if i == "nextPageCursor" then
                if gamelink:find"&cursor=" then
                    local a = gamelink:find"&cursor="
                    local b = gamelink:sub(a)
                    gamelink = gamelink:gsub(b, "")
                end
                gamelink = gamelink .. "&cursor=" .. v
                pcall(getservers)
            end
        end
    end

    pcall(getservers)
    wait(.1)
    if goodserver == game.JobId or maxplayers == #game:GetService"Players":GetChildren() - 1 then
    end
    table.insert(_G.FailedServerID, goodserver)
    game:GetService"TeleportService":TeleportToPlaceInstance(game.PlaceId, goodserver)

    while wait(.1) do
        pcall(function()
            if not game:IsLoaded() then
                game.Loaded:Wait()
            end
            game.CoreGui.RobloxPromptGui.promptOverlay.DescendantAdded:Connect(function()
                local GUI = game.CoreGui.RobloxPromptGui.promptOverlay:FindFirstChild("ErrorPrompt")
                if GUI then
                    if GUI.TitleFrame.ErrorTitle.Text == "Disconnected" then
                        if #game.Players:GetPlayers() <= 1 then
                            game.Players.LocalPlayer:Kick("\nRejoining...")
                            wait(.1)
                            game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
                        else
                            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
                        end
                    end
                end
            end)
        end)
    end
end)

---------- [ Teleport Menu with Buttons ] ----------
local Teleport_Left = Tab.Teleport:addSection()
local Teleport = Teleport_Left:addMenu("Teleport")

local teleportLocations = {
    {"Sunstone Island", Vector3.new(-913.63, 137.29, -1129.90)},
    {"Roslit Bay", Vector3.new(-1501.68, 133, 416.21)},
    {"Random Islands", Vector3.new(237.69, 139.35, 43.10)},
    {"Moosewood", Vector3.new(433.80, 147.07, 261.80)},
    {"Executive Headquarters", Vector3.new(-36.46, -246.55, 205.77)},
    {"Enchant Room", Vector3.new(1310.05, -805.29, -162.35)},
    {"Statue Of Sovereignty", Vector3.new(22.10, 159.01, -1039.85)},
    {"Mushgrove Swamp", Vector3.new(2442.81, 130.90, -686.16)},
    {"Snowcap Island", Vector3.new(2589.53, 134.92, 2333.10)},
    {"Terrapin Island", Vector3.new(152.37, 154.91, 2000.92)},
    {"Enchant Relic", Vector3.new(1309.28, -802.43, -83.36)},
}

local function teleportTo(locationName, position)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(position)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Teleport Successful";
            Text = "Teleported to " .. locationName .. "!";
            Duration = 5;
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Teleport Failed";
            Text = "HumanoidRootPart not found!";
            Duration = 5;
        })
        warn("HumanoidRootPart not found!")
    end
end

-- Tambahkan tombol teleport untuk setiap lokasi
for _, location in ipairs(teleportLocations) do
    Teleport:addButton(location[1], function()
        teleportTo(location[1], location[2])
    end)
end

Teleport:addButton("Best Spot", function()
    local forceFieldPart = Instance.new("Part")
    forceFieldPart.Size = Vector3.new(10, 1, 10)
    forceFieldPart.Position = Vector3.new(1447.85, 131.50, -7649.65)
    forceFieldPart.Anchored = true
    forceFieldPart.BrickColor = BrickColor.new("White")
    forceFieldPart.Material = Enum.Material.SmoothPlastic
    forceFieldPart.Parent = game.Workspace

    local forceField = Instance.new("ForceField")
    forceField.Parent = forceFieldPart

    teleportTo("Best Spot", Vector3.new(1447.85, 133.50, -7649.65))
end)

local Shop_Left = Tab.Shop:addSection()
local Shopping = Shop_Left:addMenu("Shop")

Shopping:addButton("Coming Soon", function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Shop",
        Text = "Coming Soon",
        Duration = 5,
    })
    warn("Coming Soon")
end)

local Misc_Left = Tab.Misc:addSection()
local Misc_Player = Misc_Left:addMenu("Misc Player")

BypassGpsLoop = nil

-- Bypass Radar
Misc_Player:addButton('Bypass Radar', function()
    for _, v in pairs(game:GetService("CollectionService"):GetTagged("radarTag")) do
        if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
            v.Enabled = not v.Enabled  -- Toggle the visibility of radar elements
        end
    end
end)

-- Bypass GPS
Misc_Player:addButton('Bypass GPS', function()
    local XyzClone
    if not BypassGpsLoop then
        XyzClone = game:GetService("ReplicatedStorage").resources.items.items.GPS.GPS.gpsMain.xyz:Clone()
        XyzClone.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("backpack")
        
        BypassGpsLoop = game:GetService("RunService").Heartbeat:Connect(function()
            local Pos = GetPosition()
            local StringInput = string.format("%s,%s,%s", ExportValue(Pos[1]), ExportValue(Pos[2]), ExportValue(Pos[3]))
            XyzClone.Text = "<font color='#ff4949'>X</font><font color='#a3ff81'>Y</font><font color='#626aff'>Z</font>: "..StringInput
        end)
    else
        if game.Players.LocalPlayer.PlayerGui.hud.safezone.backpack:FindFirstChild("xyz") then
            game.Players.LocalPlayer.PlayerGui.hud.safezone.backpack:FindFirstChild("xyz"):Destroy()
        end
        if BypassGpsLoop then
            BypassGpsLoop:Disconnect()
            BypassGpsLoop = nil
        end
    end
end)

-- Bypass Sell All (Game Pass)
Misc_Player:addButton('Bypass Sell All (Game Pass)', function()
    local sellAllButton = game.Players.LocalPlayer.PlayerGui.hud.safezone.backpack.inventory.Sell.sellall
    if sellAllButton then
        sellAllButton.Disabled = true
        sellAllButton.MouseButton1Click:Connect(function()
            if sellAllButton.Disabled then
                ReplicatedStorage:WaitForChild("events"):WaitForChild("selleverything"):InvokeServer()
            end
        end)
    end
end)

local Misc_Left = Tab.Misc:addSection()
local Misc_Player = Misc_Left:addMenu("Misc Player")

-- Fly Mode
local flyingEnabled = false
Misc_Player:addToggle('Fly Mode', false, function(state)
    flyingEnabled = state
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart then
        if flyingEnabled then
            local flyLoop
            flyLoop = game:GetService("RunService").RenderStepped:Connect(function()
                humanoidRootPart.Velocity = Vector3.new(0, 50, 0)  -- Membuat karakter naik ke atas
            end)
            character:SetAttribute("FlyLoop", flyLoop)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Fly Mode Activated";
                Text = "You are now flying!";
                Duration = 5;
            })
        else
            if character:GetAttribute("FlyLoop") then
                character:GetAttribute("FlyLoop"):Disconnect()
                character:SetAttribute("FlyLoop", nil)
            end
            humanoidRootPart.Velocity = Vector3.zero  -- Menghentikan gerakan terbang
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Fly Mode Deactivated";
                Text = "You are no longer flying.";
                Duration = 5;
            })
        end
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Fly Mode Failed";
            Text = "HumanoidRootPart not found!";
            Duration = 5;
        })
        warn("HumanoidRootPart not found!")
    end
end)

-- Speed Hack for Boat
local speedHackEnabled = false
Misc_Player:addToggle('Speed Hack for Boat', false, function(state)
    speedHackEnabled = state
    local player = game.Players.LocalPlayer
    local boat = workspace:FindFirstChild("Boat")  -- Ganti dengan nama objek kapal di game Anda

    if boat and boat:IsA("Model") and boat.PrimaryPart then
        if speedHackEnabled then
            local bodyVelocity = Instance.new("BodyVelocity", boat.PrimaryPart)
            bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)  -- Membuat gaya maksimal
            bodyVelocity.Velocity = boat.PrimaryPart.CFrame.LookVector * 260  -- Kecepatan kapal (sesuaikan angka 100)
            game.Debris:AddItem(bodyVelocity, 5)  -- Hapus efek setelah 5 detik
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Speed Hack Activated";
                Text = "Your boat is now faster!";
                Duration = 5;
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Speed Hack Deactivated";
                Text = "Your boat speed is back to normal.";
                Duration = 5;
            })
        end
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Speed Hack Failed";
            Text = "Boat not found or invalid!";
            Duration = 5;
        })
        warn("Boat not found or invalid!")
    end
end)
