--// 快取函數（Cache）
local select = select
local pcall, getgenv, next, Vector2, mathclamp, type, mousemoverel = select(1, pcall, getgenv, next, Vector2.new, math.clamp, type, mousemoverel or (Input and Input.MouseMove))

--// 防止腳本重複運行
pcall(function()
    getgenv().Aimbot.Functions:Exit()
end)

--// 設置全局變數環境
getgenv().Aimbot = {}
local Environment = getgenv().Aimbot

--// 獲取 Roblox 服務
local RunService = game:GetService("RunService") -- 遊戲運行服務
local UserInputService = game:GetService("UserInputService") -- 使用者輸入服務
local TweenService = game:GetService("TweenService") -- 動畫補間服務
local Players = game:GetService("Players") -- 玩家管理服務
local Camera = workspace.CurrentCamera -- 當前遊戲攝影機
local LocalPlayer = Players.LocalPlayer -- 本地玩家（自己）

--// 變數定義
local RequiredDistance, Typing, Running, Animation, ServiceConnections = 2000, false, false, nil, {}

--// 瞄準機制的設定參數
Environment.Settings = {
    Enabled = true, -- 是否啟用 Aimbot
    TeamCheck = false, -- 是否檢查隊伍（避免鎖定隊友）
    AliveCheck = true, -- 是否檢查對方是否存活
    WallCheck = false, -- 是否檢查是否有牆壁阻擋（可能會影響效能）
    Sensitivity = 0, -- 瞄準動畫的時間（秒）
    ThirdPerson = false, -- 是否使用鼠標移動模式來支援第三人稱（可能不太流暢）
    ThirdPersonSensitivity = 3, -- 第三人稱模式下的靈敏度（範圍 0.1 - 5）
    TriggerKey = "MouseButton2", -- 觸發瞄準的按鍵（右鍵）
    Toggle = false, -- 是否使用開關模式（按一下開，再按一下關）
    LockPart = "Head" -- 瞄準目標的身體部位（預設為頭部）
}

--// 瞄準範圍（FOV）設定
Environment.FOVSettings = {
    Enabled = true, -- 是否啟用 FOV 圈
    Visible = true, -- 是否顯示 FOV 圈
    Amount = 90, -- FOV 的半徑大小
    Color = Color3.fromRGB(255, 255, 255), -- FOV 顏色（白色）
    LockedColor = Color3.fromRGB(255, 70, 70), -- 瞄準時 FOV 顏色（紅色）
    Transparency = 0.5, -- FOV 透明度
    Sides = 60, -- FOV 圓形的邊數（越多越平滑）
    Thickness = 1, -- FOV 圓圈的線條厚度
    Filled = false -- 是否填滿 FOV 圈
}

--// 繪製 FOV 圈
Environment.FOVCircle = Drawing.new("Circle")

--// 取消瞄準
local function CancelLock()
    Environment.Locked = nil
    if Animation then Animation:Cancel() end
    Environment.FOVCircle.Color = Environment.FOVSettings.Color
end

--// 獲取距離最近的玩家
local function GetClosestPlayer()
    if not Environment.Locked then
        RequiredDistance = (Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000)

        for _, v in next, Players:GetPlayers() do
            if v ~= LocalPlayer then
                if v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
                    if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
                    if Environment.Settings.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
                    if Environment.Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[Environment.Settings.LockPart].Position}, v.Character:GetDescendants())) > 0 then continue end

                    local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Environment.Settings.LockPart].Position)
                    local Distance = (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Vector.X, Vector.Y)).Magnitude

                    if Distance < RequiredDistance and OnScreen then
                        RequiredDistance = Distance
                        Environment.Locked = v
                    end
                end
            end
        end
    elseif (Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2(Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).X, Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).Y)).Magnitude > RequiredDistance then
        CancelLock()
    end
end

--// 監聽鍵盤輸入（避免在打字時觸發）
ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

--// 主運行函數
local function Load()
    ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
        -- 更新 FOV 圈
        if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
            Environment.FOVCircle.Position = Vector2(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        else
            Environment.FOVCircle.Visible = false
        end

        -- 檢測最近的敵人
        if Running and Environment.Settings.Enabled then
            GetClosestPlayer()
        end
    end)
end

--// Aimbot 功能函數
Environment.Functions = {}

-- 結束 Aimbot 並清理變數
function Environment.Functions:Exit()
    for _, v in next, ServiceConnections do
        v:Disconnect()
    end

    if Environment.FOVCircle.Remove then Environment.FOVCircle:Remove() end

    getgenv().Aimbot.Functions = nil
    getgenv().Aimbot = nil

    Load = nil; GetClosestPlayer = nil; CancelLock = nil
end

-- 重新啟動 Aimbot
function Environment.Functions:Restart()
    for _, v in next, ServiceConnections do
        v:Disconnect()
    end
    Load()
end

-- 重設 Aimbot 設定
function Environment.Functions:ResetSettings()
    Environment.Settings = {
        Enabled = true,
        TeamCheck = false,
        AliveCheck = true,
        WallCheck = false,
        Sensitivity = 0,
        ThirdPerson = false,
        ThirdPersonSensitivity = 3,
        TriggerKey = "MouseButton2",
        Toggle = false,
        LockPart = "Head"
    }

    Environment.FOVSettings = {
        Enabled = true,
        Visible = true,
        Amount = 90,
        Color = Color3.fromRGB(255, 255, 255),
        LockedColor = Color3.fromRGB(255, 70, 70),
        Transparency = 0.5,
        Sides = 60,
        Thickness = 1,
        Filled = false
    }
end

--// 加載 Aimbot
Load()
