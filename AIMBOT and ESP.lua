local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/miroeramaa/TurtleLib/main/TurtleUiLib.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V2/main/Resources/Scripts/Raw%20Main.lua"))()
getgenv().Aimbot.Settings.Enabled = false
getgenv().Aimbot.FOVSettings.Sides = 15
getgenv().Aimbot.FOVSettings.Visible = false
getgenv().Aimbot.FOVSettings.Thickness = 2

local combat = library:Window("Combat")
local visuals = library:Window("Visuals")
local misc = library:Window("Misc")
local InfiniteJump = false
local g_mod = false


_G.high_esp = false

combat:Button("Silent Aim", function()
	local localPlayer = game:GetService("Players").LocalPlayer
	local currentCamera = game:GetService("Workspace").CurrentCamera
	local mouse = localPlayer:GetMouse()

	local function getClosestPlayerToCursor(x, y)
		local closestPlayer = nil
		local shortestDistance = math.huge

		for i, v in pairs(game:GetService("Players"):GetPlayers()) do
			if v ~= localPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") then
				local pos = currentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
				local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(x, y)).magnitude

				if magnitude < shortestDistance then
					closestPlayer = v
					shortestDistance = magnitude
				end
			end
		end

		return closestPlayer
	end

	local mt = getrawmetatable(game)
	local oldIndex = mt.__index
	if setreadonly then setreadonly(mt, false) else make_writeable(mt, true) end
	local newClose = newcclosure or function(f) return f end

	mt.__index = newClose(function(t, k)
		if not checkcaller() and t == mouse and tostring(k) == "X" and string.find(getfenv(2).script.Name, "Client") and getClosestPlayerToCursor() then
			local closest = getClosestPlayerToCursor(oldIndex(t, k), oldIndex(t, "Y")).Character.Head
			local pos = currentCamera:WorldToScreenPoint(closest.Position)
			return pos.X
		end
		if not checkcaller() and t == mouse and tostring(k) == "Y" and string.find(getfenv(2).script.Name, "Client") and getClosestPlayerToCursor() then
			local closest = getClosestPlayerToCursor(oldIndex(t, "X"), oldIndex(t, k)).Character.Head
			local pos = currentCamera:WorldToScreenPoint(closest.Position)
			return pos.Y
		end
		if t == mouse and tostring(k) == "Hit" and string.find(getfenv(2).script.Name, "Client") and getClosestPlayerToCursor() then
			return getClosestPlayerToCursor(mouse.X, mouse.Y).Character.Head.CFrame
		end

		return oldIndex(t, k)
	end)

	if setreadonly then setreadonly(mt, true) else make_writeable(mt, false) end

end)

game:GetService("UserInputService").JumpRequest:Connect(function()
	if InfiniteJump == true then
		game:GetService "Players".LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
	end
end)

combat:Toggle("Aimbot", false, function(bool)
	getgenv().Aimbot.Settings.Enabled = bool
end)

combat:Toggle("FOV Circle", false, function(bool)
	getgenv().Aimbot.FOVSettings.Visible = bool
end)

combat:Slider("FOV",50,250,190, function(value)
	print(value)
	getgenv().Aimbot.FOVSettings.Amount = value
end)

combat:ColorPicker("FOV Color", Color3.fromRGB(255, 255, 255), function(color)
	getgenv().Aimbot.FOVSettings.Color = color
end)


misc:Button("SpeedBoost", function()
	local mt = getrawmetatable(game)
	local backup
	backup = hookfunction(mt.__newindex, newcclosure(function(self, key, value)
		if key == "WalkSpeed" then
			value = 23
		end
		return backup(self, key, value)
	end))
end)

misc:Toggle("Inf Jump", false, function(bool)
	InfiniteJump = bool
end)

misc:Toggle("GunMods", false, function(bool)
	g_mod = bool
end)


visuals:Toggle("ESP", false, function(bool)
	_G.high_esp = bool
	
	if bool == false then
		for _,v in pairs(game.Workspace:GetChildren()) do
			if v:FindFirstChildWhichIsA("Humanoid") then
				if v:FindFirstChildWhichIsA("Highlight") then
					v:FindFirstChildWhichIsA("Highlight"):Destroy()
				end
			end
		end
	end
end)

visuals:ColorPicker("ESP Color", Color3.fromRGB(255, 255, 255), function(color)
	for _,v in pairs(game.Workspace:GetDescendants()) do
		if v.Name == "penis" then
			pcall(function()
				v.FillColor = color
			end)
		end
	end
end)

game:GetService("RunService").Heartbeat:Connect(function()
	if _G.high_esp == true then
		for _,v in pairs(game.Workspace:GetChildren()) do
			if v:FindFirstChildWhichIsA("Humanoid") then
				if not v:FindFirstChildWhichIsA("Highlight") then
					local h = Instance.new("Highlight",v)
					h.Name = "penis"
					h.FillTransparency = 0.1
					h.OutlineTransparency = 1
					h.FillColor = Color3.new(0.666667, 0, 1)
				end
			end
		end
	end
end)

while wait(1) do
	if g_mod == true then
		for i, v in next, getgc(true) do
			if type(v) == "table" then
				if rawget(v, "LoadedAmmo") then
					v.LoadedAmmo = 10000000000
					v.RecoilFactor = 0
					v.Spread = 0
				end
				if rawget(v, "ReloadTime") then
					v.ReloadTime = 0
					v.EquipTime = 0
					v.LoadCapacity = 10000000000
				end
			end
		end
	end
end
