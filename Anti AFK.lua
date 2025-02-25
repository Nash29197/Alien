local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())  -- 模擬右鍵點擊，避免 AFK
    print("⚡ 防 AFK 腳本已啟動，成功阻止被踢出！")
end)
