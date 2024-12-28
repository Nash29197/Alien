-- 取得遊戲中的服務
local players = game:GetService("Players") -- 玩家服務，用於管理遊戲中的玩家
local teams = game:GetService("Teams") -- 隊伍服務，用於管理遊戲中的隊伍

-- 當前的攝影機，玩家的視角
local camera = workspace.CurrentCamera

-- 計算最近的玩家角色
local function get_closest_player()
    local closest, closest_distance = nil, math.huge -- 初始化最近的角色與距離

    for _, character in workspace:GetChildren() do
        -- 確認角色是否屬於玩家，並是否具有 HumanoidRootPart
        local player = players:FindFirstChild(character.Name)
        local root_part = character:FindFirstChild("HumanoidRootPart")
        if not player or not root_part then continue end

        -- 確認玩家是否有隊伍屬性，並排除與本地玩家同隊的角色
        local team_attribute = player:GetAttribute("Team")
        if not team_attribute or teams[team_attribute] == players.LocalPlayer.Team then
            continue
        end

        -- 將角色的位置轉換為螢幕座標，並確認角色是否在螢幕內
        local position, on_screen = camera:WorldToViewportPoint(root_part.Position)
        if not on_screen then continue end

        -- 計算角色與螢幕中心的距離
        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local distance = (Vector2.new(position.X, position.Y) - center).Magnitude

        -- 更新最近的角色
        if distance < closest_distance then
            closest, closest_distance = character, distance
        end
    end

    return closest -- 返回最近的角色
end

-- 主程式邏輯
do
    -- 定義事件表，用於識別事件
    local events = {
        ["ShootEvent"] = function(arg)
            -- 確認參數是否是與本地玩家相關的實例
            return typeof(arg) == "Instance" and arg.Name and arg.Name:find(players.LocalPlayer.Name)
        end,
    }

    -- 攔截並修改 __namecall 方法
    local old_namecall
    old_namecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod() -- 獲取呼叫的方法名稱

        if method == "Fire" and self.Name == "Sync" then
            for event, identify in pairs(events) do
                -- 處理 "ShootEvent" 並確認參數
                if event == "ShootEvent" and identify(select(3, ...)) then
                    -- 找到最近的玩家並修改參數
                    local closest_player = get_closest_player()
                    local ammo, cframe, id, weapon, projectile = ...
                    if closest_player and closest_player:FindFirstChild("Head") then
                        cframe = closest_player.Head.CFrame -- 將射擊目標設置為最近敵人的頭部
                    end
                    return old_namecall(self, select(1, ...), ammo, cframe, id, weapon, projectile)
                end
            end
        end

        -- 如果不是目標事件，執行原始方法
        return old_namecall(self, ...)
    end)
end
