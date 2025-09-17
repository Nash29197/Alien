-------------- 22222222222222222


--// Init
-- local Mode = "Web"

-- -- if not getgenv().Import then
-- --     getgenv().Import = function(RunMode, filePath)
-- --         if RunMode == "Developer" then
-- --             local dirPath = "PhantomFlux-V2/"
-- --             local fullPath = dirPath .. filePath

-- --             if not isfolder(dirPath) then
-- --                 error("[Import]: Folder not found: " .. dirPath)
-- --             end
-- --             if not isfile(fullPath) then
-- --                 error("[Import]: File not found: " .. fullPath)
-- --             end

-- --             local source = readfile(fullPath)
-- --             if not source then
-- --                 error("[Import]: Failed to read file: " .. fullPath)
-- --             end

-- --             local func, err = loadstring(source)
-- --             if not func then
-- --                 error("[Import]: Failed to compile script: " .. err)
-- --             end
-- --             return func()

-- --         elseif RunMode == "Web" then
-- --             local baseUrl = "https://raw.githubusercontent.com/hajibeza/Module/main/"
-- --             local fullUrl = baseUrl .. filePath

-- --             local success, response = pcall(function()
-- --                 return game:HttpGet(fullUrl)
-- --             end)

-- --             if not success or not response then
-- --                 error("[Import]: Failed to fetch file from URL: " .. fullUrl)
-- --             end
-- --             if response:find("<html>") then
-- --                 error("[Import]: Invalid response content: " .. fullUrl)
-- --             end

-- --             local func, err = loadstring(response)
-- --             if not func then
-- --                 error("[Import]: Failed to compile script: " .. err)
-- --             end

-- --             return func()

-- --         else
-- --             error("[Import]: Invalid RunMode")
-- --         end
-- --     end
-- -- end

-- -- local Import = getgenv().Import

-- Load Modules
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dyumra/GAG/refs/heads/main/GAG_Lib.lua"))()
local Utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/dyumra/GAG/refs/heads/main/GAG_Utility.lua"))()
local Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/dyumra/GAG/refs/heads/main/GAG_Module.lua"))()

local Collection = {
	["Auto Harvest"] = {
		TargetPlants = { "All" },
		TargetMutations = { "All" },
		PerformanceMode = false,
	},

	["Auto Plant"] = {
		TargetPlants = { "All" },
		PlantMethod = "Random",
		Delay = 0.1,
	},

	["Auto Sell"] = {
		Delay = 15,
		SellType = "OnDelay",
	},

	["Auto Buy Seeds"] = {
		TargetSeeds = { "Carrot" },
		Delay = 2.5,
	},

	["Auto Buy Gears"] = {
		TargetGears = { "Watering Can" },
		Delay = 2.5,
	},

	["Auto Buy Eggs"] = {
		TargetEggs = { "Common Egg" },
		Delay = 2.5,
	},

	["Auto Input Pets"] = {
		TargetPet = "",
	},

	["Auto Quest"] = {},

	["Auto Move"] = {
		TargetPlants = { "All" },
		MoveMethod = "UnderPlayer",
		Delay = 0.1,
	},

	["Teleport"] = {
		Place = "Middle",
	},

	["Crafters"] = {
		["Seed Crafting"] = {
			Seed = "Peace Lily",
		},

		["Gear Crafting"] = {
			Gear = " Lightning Rod",
		},
		["Event Crafting"] = {
			Item = "Ancient Seed Pack",
		},
	},

	["Player Movement"] = {
		["WalkSpeed"] = { Enabled = false, Speed = 16 },
		["JumpPower"] = { Enabled = false, Power = 16 },
		["Gravity"] = { Enabled = false, Gravity = 16 },
	},

	["Servers"] = {
		JobID = game.JobId,
		PlaceID = game.PlaceId,
	},
}

local BackPack = Utility.BackPack
local HumanoidRootPart = Utility.HumanoidRootPart
local Humanoid = Utility.Humanoid
local LocalPlayer = Utility.LocalPlayer
local Character = Utility.Character
local Mouse = Utility.Mouse

--// Setup
local Window = Library:Setup()

local AboutUs = Library:CreateTab("Information", "info")
local Farming = Library:CreateTab("Farming", "wheat")
local Stock = Library:CreateTab("Stock", "store")
local Player = Library:CreateTab("Player", "user")
local Visual = Library:CreateTab("Visual", "eye")
local Event = Library:CreateTab("Event", "calendar")
local Misc = Library:CreateTab("Misc", "ellipsis")
local Divider = Window:Divider()
local Exclusive = Library:CreateTab("Exclusive", "sparkles")

Window:SelectTab(1)

--// About Us / Server Hop
Module:Init(function()
	Library:CreateSection(AboutUs, "Server Hop")

	Library:CreateButton(AboutUs, {
		Title = "Server Hop",
		Locked = false,
		Callback = function()
			local PlaceId = game.PlaceId
			local JobId = game.JobId

			Module:ServerHop(PlaceId, JobId, false)
		end,
	})

	Library:CreateButton(AboutUs, {
		Title = "Find Old Server",
		Locked = false,
		Callback = function()
			local PlaceId = game.PlaceId
			local JobId = game.JobId

			Module:ServerHop(PlaceId, JobId, true)
		end,
	})

	Library:CreateButton(AboutUs, {
		Title = "Copy PlaceId",
		Locked = false,
		Callback = function()
			local PlaceId = game.PlaceId
			setclipboard(tostring(PlaceId))
		end,
	})

	Library:CreateButton(AboutUs, {
		Title = "Copy JobId",
		Locked = false,
		Callback = function()
			local JobId = game.JobId

			setclipboard(tostring(JobId))
		end,
	})

	Library:CreateSection(AboutUs, "About Us")

	Library:SetupAboutUs(AboutUs)
end)

--// Farming
Module:Init(function() --// Auto Harvest
	Library:CreateSection(Farming, "Auto Harvest")
	local TargetPlants = Collection["Auto Harvest"].TargetPlants
	local TargetMutations = "All"

	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0
	local Delay = 2

	local Performance = true

	Library:CreateDropdown(Farming, {
		Title = "Plants to Harvest",
		Values = Module:SortArray(Utility.Fruits),
		Value = { "All" },
		Multi = true,
		AllowNone = true,
		Callback = function(option)
			TargetPlants = option
		end,
	})

	Library:CreateDropdown(Farming, {
		Title = "Required Mutations",
		Values = Module:SortArray(Utility.Mutations),
		Value = { "All" },
		Multi = true,
		AllowNone = true,
		Callback = function(option)
			TargetMutations = option
		end,
	})

	Farming:Toggle({
		Title = "Auto Harvest Fruits",
		Desc = "Automatically Harvest Plants Based On Your Filters",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				Connection = ConnectionInit:Connect("Heartbeat", function()
					if not State then
						return
					end
					if Module:IsMaxInventory() then
						return
					end
					local Current = tick()
					if Current - LastTick < Delay then
						return
					end
					LastTick = Current

					local Farm, Important = Module:GetFarm()

					if not Farm or not Important then
						warn("[AutoHarvest]: Farm not found")
						return
					end

					local Plants = Module:GetPlants(Farm)

					for _, v in pairs(Plants) do
						if type(TargetPlants) == "table" then
							if table.find(TargetPlants, "All") then
								Module:HarvestPlant(v)
							else
								if table.find(TargetPlants, v.Name) then
									if table.find(TargetMutations, "All") then
										Module:HarvestPlant(v)
									else
										for _, v2 in pairs(TargetMutations) do
											if Module:HasMutation(v, v2) then
												Module:HarvestPlant(v)
											end
										end
									end
								end
							end
						end
					end
				end)
			else
				ConnectionInit:Disconnect(Connection)
				Connection = nil
			end
		end,
	})
end)

Module:Init(function() --// Auto Plant
	Library:CreateSection(Farming, "Auto Plant")

	local PlantMethod = Collection["Auto Plant"].PlantMethod
	local TargetPlants = Collection["Auto Plant"].TargetPlants
	local Delay = Collection["Auto Plant"].Delay

	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil

	local LastTick = 0

	local PlantsToPlant = Library:CreateDropdown(Farming, {
		Title = "Plants to Plant",
		Values = Module:SortArray(Utility.Fruits),
		Value = { "All" },
		Multi = true,
		AllowNone = true,
		Callback = function(option)
			TargetPlants = option
		end,
	})

	local PlantMethods = Library:CreateDropdown(Farming, {
		Title = "Plant Method",
		Values = { "Random", "UnderPlayer", "UnderMouse" },
		Value = "Random",
		Multi = false,
		AllowNone = true,
		Callback = function(option)
			PlantMethod = option
		end,
	})

	Farming:Toggle({
		Title = "Auto Plant",
		Desc = "Automatically Plant Stuff Based On Your Farm",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				Connection = ConnectionInit:Connect("Heartbeat", function()
					if not State then
						return
					end

					local Current = tick()
					if Current - LastTick < Delay then
						return
					end

					LastTick = Current

					local Seeds = Module:GetSeeds()

					if type(TargetPlants) == "table" then
						if table.find(TargetPlants, "All") then
							for _, v in pairs(Seeds) do
								if v:IsA("Tool") then
									local FruitName = v.Name:match("^(.-) Seed")

									if FruitName then
										Utility.Humanoid:EquipTool(v)
										Module:Plant(Module:GetPosition(PlantMethod), FruitName)
									end
								end
							end
						else
							for _, v in pairs(Seeds) do
								if v:IsA("Tool") then
									local FruitName = v.Name:match("^(.-) Seed")

									if FruitName and table.find(TargetPlants, FruitName) then
										Utility.Humanoid:EquipTool(v)
										Module:Plant(Module:GetPosition(PlantMethod), FruitName)
									end
								end
							end
						end
					end
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})
end)

Module:Init(function() --// Auto Sell
	Library:CreateSection(Farming, "Auto Selling")
	local Delay = Collection["Auto Sell"].Delay --// Delay in seconds

	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0

	Library:CreateSlider(Farming, {
		Title = "Sell Delay (Seconds)",
		Desc = "Change Delay Between Each Sell",
		Step = 0.1,
		Value = {
			Min = 0.1,
			Max = 100,
			Default = 15,
		},
		Callback = function(Value)
			Delay = tonumber(Value)
		end,
	})

	Farming:Toggle({
		Title = "Auto Sell",
		Desc = "Automatically Sell Your Plants",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)
				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay then
						return
					end
					LastTick = Current

					if not HumanoidRootPart then
						return
					end

					local LastCFrame = HumanoidRootPart.CFrame
					HumanoidRootPart.CFrame = CFrame.new(88.1068573, 2.99999976, 0.248745888)

					task.wait(0.25)
					Utility.GameEvents:WaitForChild("Sell_Inventory"):FireServer()

					task.wait(1.25)

					HumanoidRootPart.CFrame = LastCFrame
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})
end)

Module:Init(function() --// Enabled Proxys
	Library:CreateSection(Farming, "Proximity Prompts")

	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0

	local Delay = Collection["Auto Sell"].Delay
	local Farm, Imp = Module:GetFarm()

	Farming:Toggle({
		Title = "Enable Multiple Proxy's",
		Desc = "Lets You Harvest More Plants At Once",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay then
						return
					end
					LastTick = Current

					local Plants = Module:GetPlants(Imp)
					for _, v in pairs(Plants) do
						local Proxy = Module:GetProxy(v)

						if Proxy then
							Proxy.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
						end
					end
				end)
			else
				if Connection then
					local Plants = Module:GetPlants(Imp)
					for _, v in pairs(Plants) do
						local Proxy = Module:GetProxy(v)

						if Proxy then
							Proxy.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
						end
					end

					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})
end)

--// Stock
Module:Init(function() --// Show UI's
	Library:CreateSection(Stock, "Enable Ui's")

	Stock:Toggle({
		Title = "Enable Seeds Shop UI",
		Desc = "Shows The Seed Shop UI",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			Utility.PlayerGui.Seed_Shop.Enabled = State
		end,
	})

	Stock:Toggle({
		Title = "Enable Gear Shop UI",
		Desc = "Shows The Gear Shop UI",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			Utility.PlayerGui.Gear_Shop.Enabled = State
		end,
	})

	Stock:Toggle({
		Title = "Enable Event Shop UI",
		Desc = "Shows The Event UI",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			Utility.PlayerGui.EventShop_UI.Enabled = State
		end,
	})

	Stock:Toggle({
		Title = "Enable Cosmetic Shop UI",
		Desc = "Shows The Cosmetic UI",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			Utility.PlayerGui.CosmeticShop_UI.Enabled = State
		end,
	})

	Stock:Toggle({
		Title = "Enable Pet Egg Shop UI",
		Desc = "Shows The Pet Egg UI",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			Utility.PlayerGui.PetShop_UI.Enabled = State
		end,
	})
end)

Module:Init(function() --// Auto Buy Seeds
	Library:CreateSection(Stock, "Auto Buy Seeds")
	local TargetSeeds = Collection["Auto Buy Seeds"].TargetSeeds
	local Delay2 = Collection["Auto Buy Seeds"].Delay

	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0

	local ConnectionInit2 = Module:SpawnConnection() --// For the Auto Buy All
	local Connection2 = nil
	local LastTick2 = 0

	Library:CreateDropdown(Stock, {
		Title = "Seeds to buy",
		Values = Module:SortArray(Utility.SeedStock),
		Value = { "Carrot" },
		Multi = true,
		AllowNone = true,
		Callback = function(option)
			TargetSeeds = option
		end,
	})

	Stock:Toggle({
		Title = "Auto Buy Seeds",
		Desc = "Automatically Buys Seeds In Stock",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick = Current

					if type(TargetSeeds) == "table" and #TargetSeeds > 0 then
						for _, v in pairs(TargetSeeds) do
							Module:BuySeed(v)
						end
					end
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})

	Stock:Toggle({
		Title = "Auto Buy All Seeds",
		Desc = "Automatically Buys All The Seeds In Stock",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit2:Disconnect(Connection2)

				Connection2 = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick2 = Current

					for _, v in pairs(Utility.SeedStock) do
						Module:BuySeed(v)
					end
				end)
			else
				if Connection2 then
					ConnectionInit2:Disconnect(Connection2)
					Connection2 = nil
				end
			end
		end,
	})
end)

Module:Init(function() --// Auto Buy Gears
	Library:CreateSection(Stock, "Auto Buy Gears")
	local TargetGears = Collection["Auto Buy Gears"].TargetGears
	local Delay2 = Collection["Auto Buy Gears"].Delay

	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0

	local ConnectionInit2 = Module:SpawnConnection() --// For the Auto Buy All
	local Connection2 = nil
	local LastTick2 = 0

	Library:CreateDropdown(Stock, {
		Title = "Gears to buy",
		Values = Module:SortArray(Utility.GearStock),
		Value = { "Watering Can" },
		Multi = true,
		AllowNone = true,
		Callback = function(option)
			TargetGears = option
		end,
	})

	Stock:Toggle({
		Title = "Auto Buy Gears",
		Desc = "Automatically Buys Gears In Stock",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick = Current

					if type(TargetGears) == "table" and #TargetGears > 0 then
						for _, v in pairs(TargetGears) do
							Module:BuyGear(v)
						end
					end
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})

	Stock:Toggle({
		Title = "Auto Buy All Gears",
		Desc = "Automatically Buys All The Gears In Stock",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit2:Disconnect(Connection2)

				Connection2 = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick2 = Current

					for _, v in pairs(Utility.SeedStock) do
						Module:BuyGear(v)
					end
				end)
			else
				if Connection2 then
					ConnectionInit2:Disconnect(Connection2)
					Connection2 = nil
				end
			end
		end,
	})
end)

Module:Init(function() --// Auto Buy Gears
	Library:CreateSection(Stock, "Auto Buy Eggs")
	local TargetEggs = Collection["Auto Buy Eggs"].TargetEggs
	local Delay2 = Collection["Auto Buy Eggs"].Delay

	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0

	local ConnectionInit2 = Module:SpawnConnection() --// For the Auto Buy All
	local Connection2 = nil
	local LastTick2 = 0

	Library:CreateDropdown(Stock, {
		Title = "Eggs to buy",
		Values = Module:SortArray(Utility.EggStock),
		Value = { "Common Egg" },
		Multi = true,
		AllowNone = true,
		Callback = function(option)
			TargetEggs = option
		end,
	})

	Stock:Toggle({
		Title = "Auto Buy Eggs",
		Desc = "Automatically Buys Eggs In Stock",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick = Current

					if type(TargetEggs) == "table" and #TargetEggs > 0 then
						for _, v in pairs(TargetEggs) do
							Module:BuyEgg(v)
						end
					end
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})

	Stock:Toggle({
		Title = "Auto Buy All Eggs",
		Desc = "Automatically Buys All The Eggs In Stock",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit2:Disconnect(Connection2)

				Connection2 = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick2 = Current

					for _, v in pairs(Utility.SeedStock) do
						Module:BuyEgg(v)
					end
				end)
			else
				if Connection2 then
					ConnectionInit2:Disconnect(Connection2)
					Connection2 = nil
				end
			end
		end,
	})
end)

--// Player
Module:Init(function() --// Player Movement
	Library:CreateSection(Player, "Player Movement")
	local WalkSpeed = Collection["Player Movement"].WalkSpeed
	local JumpPower = Collection["Player Movement"].JumpPower
	local Gravity = Collection["Player Movement"].Gravity

	Player:Toggle({
		Title = "Change WalkSpeed",
		Desc = "Shows The Seed Shop UI",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			WalkSpeed.Enabled = State
		end,
	})

	Library:CreateSlider(Player, {
		Title = "Speed",
		Desc = "Change The Speed You Want",
		Step = 0.1,
		Value = {
			Min = 0,
			Max = 500,
			Default = 16,
		},
		Callback = function(Value)
			WalkSpeed.Speed = Value

			if WalkSpeed.Enabled then
				Humanoid.WalkSpeed = WalkSpeed.Speed
			end
		end,
	})

	Player:Toggle({
		Title = "Change JumpPower",
		Desc = "Changes Your Jump Power",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			JumpPower.Enabled = State
		end,
	})

	Library:CreateSlider(Player, {
		Title = "Power",
		Desc = "Change The Power You Want",
		Step = 0.1,
		Value = {
			Min = 0,
			Max = 500,
			Default = 50,
		},
		Callback = function(Value)
			JumpPower.Speed = Value

			if JumpPower.Enabled then
				Humanoid.JumpPower = JumpPower.Power
			end
		end,
	})

	Player:Toggle({
		Title = "Change Gravity",
		Desc = "Changes The Game's Gravity",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			Gravity.Enabled = State
		end,
	})

	Library:CreateSlider(Player, {
		Title = "Gravity",
		Desc = "Change The Gravity However Want",
		Step = 0.1,
		Value = {
			Min = 0,
			Max = 500,
			Default = 192.1,
		},
		Callback = function(Value)
			Gravity.Gravity = Value

			if Gravity.Enabled then
				Utility.Workspace.Gravity = Gravity.Gravity
			end
		end,
	})
end)

Module:Init(function() --// Other, Player
	Library:CreateSection(Player, "Infinite Jump")
	Player:Toggle({
		Title = "Infinite Jump",
		Desc = "[Semi Flight] Lets you air jump",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			Utility.UserInputService.JumpRequest:connect(function()
				if State then
					Humanoid:ChangeState("Jumping")
				end
			end)
		end,
	})
end)

--// Visuals
Module:Init(function() --// Pet Spawner: Creds Sudais
	Visual:Section({ Title = "Pet Spawner" })
	local Name = ""
	local Weight = ""
	local Age = ""

	Library:CreateInput(Visual, {
		Title = "Input Pet Name",
		Placeholder = "E.g., Red Fox, Racoon, etc",
		Value = "",
		Callback = function(Text)
			Name = Text
		end,
	})

	Visual:Input({
		Title = "Input Pet Weight",
		Placeholder = "E.g., 8.5",
		Value = "",
		Callback = function(Text)
			Weight = Text
		end,
	})

	Visual:Input({
		Title = "Input Pet Age",
		Placeholder = "e.g., 100",
		Value = "",
		Callback = function(Text)
			Age = Text
		end,
	})

	Visual:Button({
		Title = "Spawn Pet",
		Callback = function()
			if not Name or Name == "" then
				Library.Async:Notify({
					Title = "Invalid Input",
					Content = "Please Enter a Valid Pet Name",
					Duration = 3,
					Icon = "alert-triangle",
				})
				return
			end

			local Model = Utility.PetAssets:FindFirstChild(Name)
			if not Model or not Model:IsA("Model") then
				Library.Async:Notify({
					Title = "Invalid Pet",
					Content = "The Pet: '" .. Name .. "' is invalid (Case sensitive)",
					Duration = 4,
					Icon = "x-circle",
				})

				return
			end

			local SelectedWeight = tonumber(Weight) or 1.5
			local SelectedAge = tonumber(Age) or 1.5
			Module:CreatePet(Name, SelectedAge, SelectedWeight)
			Library.Async:Notify({
				Title = "Pet Spawned",
				Content = "Spawned '" .. Name .. "' in backpack and equipped!",
				Duration = 3,
				Icon = "check-circle",
			})
		end,
	})

	Visual:Paragraph({
		Title = "How to Use",
		Desc = "Type a valid Pet name (e.g., 'Red Fox') and click 'Spawn Pet' to spawn and equip it.",
	})
end)

Module:Init(function() --// Egg Spawner: Creds Sudais
	local Egg = ""
	Visual:Section({
		Title = "Egg Spawner",
	})

	Visual:Input({
		Title = "Enter Egg Name",
		Placeholder = "e.g., Anti Bee Egg",
		Value = "",
		Callback = function(EggName)
			Egg = EggName
		end,
	})

	Visual:Button({
		Title = "Spawn Egg",
		Callback = function()
			if not Egg or Egg == "" then
				Library.Async:Notify({
					Title = "Invalid egg name",
					Content = "Please enter a valid egg name.",
					Duration = 3,
				})
				return
			end

			local Models = Utility.ReplicatedStorage.Assets.Models.EggModels
			if not Models then
				warn("Missing folder")
				return
			end

			local Model = Models:FindFirstChild(Egg)
			if not Model then
				Library.Async:Notify({
					Title = "Invalid Egg",
					Content = Egg .. " not found.",
					Duration = 3,
				})
				return
			end

			local EggTool = Instance.new("Tool")
			EggTool.Name = Egg .. " Egg [x1]"
			EggTool.RequiresHandle = true
			EggTool.Parent = BackPack

			local Handle = nil

			if Model:IsA("BasePart") then
				Handle = Model:Clone()
				Handle.Name = "Handle"
				Handle.Anchored = false
				Handle.CanCollide = false
				Handle.Parent = EggTool
			elseif Model:IsA("Model") then
				if Model.PrimaryPart then
					Handle = Model.PrimaryPart:Clone()
					Handle.Name = "Handle"
					Handle.Anchored = false
					Handle.CanCollide = false
					Handle.Parent = EggTool

					local ClonedModel = Model:Clone()
					for _, v in pairs(ClonedModel:GetChildren()) do
						if v:IsA("BasePart") and v ~= Model.PrimaryPart then
							v.Parent = EggTool
							v.Anchored = false
							v.CanCollide = false
							local Weld = Instance.new("WeldConstraint")
							Weld.Part0 = Handle
							Weld.Part1 = v
							Weld.Parent = EggTool
						end
					end
					ClonedModel:Destroy()
				else
					Handle = Instance.new("Part")
					Handle.Name = "Handle"
					Handle.Size = Vector3.new(0.5, 1, 0.5)
					Handle.Transparency = 1
					Handle.Anchored = false
					Handle.CanCollide = false
					Handle.Parent = EggTool

					local ClonedModel = Model:Clone()
					ClonedModel.Parent = EggTool

					for _, Part in pairs(ClonedModel:GetDescendants()) do
						if Part:IsA("BasePart") then
							Part.Anchored = false
							Part.CanCollide = false
							local Weld = Instance.new("WeldConstraint")
							Weld.Part0 = Handle
							Weld.Part1 = Part
							Weld.Parent = EggTool
						end
					end
				end
			else
				Library.Async:Notify({
					Title = "RWdnIG5vdCBmb3VuZA==",
					Content = "RWdnIG1vZGVsIGlzIG5vdCBhIFBhcnQgb3IgTW9kZWwu",
					Duration = 3,
				})
				EggTool:Destroy()

				return
			end

			if Handle then
				Humanoid:EquipTool(EggTool)
			end
		end,
	})
end)

Module:Init(function() --// Seed Pack Spawner: Creds Sudais (yes, pasted from the egg spawner)
	local Pack = ""
	Visual:Section({
		Title = "SeedPack Spawner",
	})

	Visual:Input({
		Title = "Enter SeedPack Name",
		Placeholder = "e.g., Flower Seed Pack",
		Value = "",
		Callback = function(PackName)
			Pack = PackName
		end,
	})

	Visual:Button({
		Title = "Spawn SeedPack",
		Callback = function()
			if not Pack or Pack == "" then
				Library.Async:Notify({
					Title = "Invalid pack name",
					Content = "Please enter a valid pack name.",
					Duration = 3,
				})
				return
			end

			local Models = Utility.ReplicatedStorage.Assets.Models.EggModels
			if not Models then
				warn("Missing folder")
				return
			end

			local Model = Models:FindFirstChild(Pack)
			if not Model then
				Library.Async:Notify({
					Title = "Invalid Pack",
					Content = Pack .. " not found.",
					Duration = 3,
				})
				return
			end

			local PackTool = Instance.new("Tool")
			PackTool.Name = Pack .. " [x1]"
			PackTool.RequiresHandle = true
			PackTool.Parent = BackPack

			local Handle = nil

			if Model:IsA("BasePart") then
				Handle = Model:Clone()
				Handle.Name = "Handle"
				Handle.Anchored = false
				Handle.CanCollide = false
				Handle.Parent = PackTool
			elseif Model:IsA("Model") then
				if Model.PrimaryPart then
					Handle = Model.PrimaryPart:Clone()
					Handle.Name = "Handle"
					Handle.Anchored = false
					Handle.CanCollide = false
					Handle.Parent = PackTool

					local ClonedModel = Model:Clone()
					for _, v in pairs(ClonedModel:GetChildren()) do
						if v:IsA("BasePart") and v ~= Model.PrimaryPart then
							v.Parent = PackTool
							v.Anchored = false
							v.CanCollide = false
							local Weld = Instance.new("WeldConstraint")
							Weld.Part0 = Handle
							Weld.Part1 = v
							Weld.Parent = PackTool
						end
					end
					ClonedModel:Destroy()
				else
					Handle = Instance.new("Part")
					Handle.Name = "Handle"
					Handle.Size = Vector3.new(0.5, 1, 0.5)
					Handle.Transparency = 1
					Handle.Anchored = false
					Handle.CanCollide = false
					Handle.Parent = PackTool

					local ClonedModel = Model:Clone()
					ClonedModel.Parent = PackTool

					for _, v in pairs(ClonedModel:GetDescendants()) do
						if v:IsA("BasePart") then
							v.Anchored = false
							v.CanCollide = false
							local Weld = Instance.new("WeldConstraint")
							Weld.Part0 = Handle
							Weld.Part1 = v
							Weld.Parent = PackTool
						end
					end
				end
			else
				Library.Async:Notify({
					Title = "RWdnIG5vdCBmb3VuZA==",
					Content = "RWdnIG1vZGVsIGlzIG5vdCBhIFBhcnQgb3IgTW9kZWwu",
					Duration = 3,
				})
				PackTool:Destroy()

				return
			end

			if Handle then
				Humanoid:EquipTool(PackTool)
			end
		end,
	})
end)

Module:Init(function() --// Seed Spawner: Creds Sudais
	Visual:Section({ Title = "Seed Spawner" })
	local SeedName = ""

	Visual:Input({
		Title = "Enter Seed Name",
		Placeholder = "e.g., Carrot",
		Value = "",
		Callback = function(Name)
			SeedName = Name
			Library.Async:Notify({
				Title = "Seed Set",
				Content = "Ready to spawn: " .. Name,
				Duration = 3,
				Icon = "check",
			})
		end,
	})

	Visual:Button({
		Title = "Spawn Seed",
		Callback = function()
			if not SeedName or SeedName == "" then
				Library.Async:Notify({
					Title = "Invalid Seed Nmae",
					Content = "Please enter a valid seed name.",
					Duration = 3,
					Icon = "alert-triangle",
				})
				return
			end

			local SeedModels = game:GetObjects("rbxassetid://125869296102137")[1] --// sudais when no more chatgpt :pray:
			if not SeedModels then
				warn("Seed Models not found")
				return
			end

			local Seed = SeedModels:FindFirstChild(SeedName)
			if not Seed then
				warn("Seed not found")
				return
			end

			local FakeTool = Instance.new("Tool")
			FakeTool.Name = SeedName .. " Seed [x1]"
			FakeTool.RequiresHandle = true
			FakeTool.Parent = BackPack

			local Handle = Seed:Clone()
			Handle.Name = "Handle"
			Handle.Size = Handle.Size * 1.5
			Handle.Parent = FakeTool

			Humanoid:EquipTool(FakeTool)
			Library.Async:Notify({
				Title = "Success",
				Content = "You are now holding: " .. FakeTool.Name,
				Duration = 3,
				Icon = "check-circle",
			})
			Library.Async:Notify({
				Title = "Error",
				Content = "No Humanoid found in character to equip tool.",
				Duration = 3,
				Icon = "x-circle",
			})
		end,
	})

	Visual:Paragraph({
		Title = "How To Use",
		Desc = "Type a valid Seed Name eg.. Candy Blossom And Click Spawn Seed to Spawn it",
	})
end)

--// Event
Module:Init(function()
    Library:CreateSection(Event, "Fairy Event")

    local ConnectionInit = Module:SpawnConnection()
    local Connection = nil
    local LastTick = 0
    local Delay12 = 1
    local Item2_Event = {}

    Library:CreateDropdown(Event, { 
        Title = "Upgrade Event",
        Values = { "Glimmer Multiplier", "Loose Fairy Spawn Amount", "Fairy Event Duration", "Fairy Spawn Amount" },
        Value = {},
        Multi = true,
        AllowNone = true,
        Callback = function(option1)
            Item2_Event = option1
        end,
    })

    Event:Toggle({
        Title = "Auto Buy Fairy Upgrade",
        Desc = "Automatically Upgrade Fairy Event",
        Icon = "check",
        Type = "Checkbox",
        Default = false,
        Callback = function(State)
            if State then
                if Connection then
                    ConnectionInit:Disconnect(Connection)
                    Connection = nil
                end

                Connection = ConnectionInit:Connect("Heartbeat", function()
                    local Current = tick()
                    if Current - LastTick >= Delay12 then
                        LastTick = Current
                        if #Item2_Event > 0 then
                            local args = Item2_Event
                            game:GetService("ReplicatedStorage")
                                :WaitForChild("GameEvents")
                                :WaitForChild("FairyService")
                                :WaitForChild("Upgrade")
                                :FireServer(unpack(args))
                        end
                    end
                end)
            else
                if Connection then
                    ConnectionInit:Disconnect(Connection)
                    Connection = nil
                end
            end
        end,
    })

	Event:Toggle({
		Title = "Auto Submit Fairy Event",
		Desc = "Automatically Submit Ur Plants",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < 1 then
						return
					end
					LastTick = Current
					-- game:GetService("ReplicatedStorage").Modules.UpdateService.Parent = workspace
					Utility.GameEvents:WaitForChild("FairyService"):WaitForChild("SubmitFairyFountainAllPlants"):FireServer()
                    Utility.GameEvents:WaitForChild("FairyService"):WaitForChild("SubmitAllPlants"):FireServer()
                    Utility.GameEvents:WaitForChild("FairyService"):WaitForChild("SubmitHeldPlant"):FireServer()
					Utility.GameEvents:WaitForChild("FairyService"):WaitForChild("SubmitFairyFountainHeldPlant"):FireServer()
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})

	Event:Toggle({
		Title = "Auto Claim Reward Fairy Event",
		Desc = "Automatically Claim Reward Fairy Event",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < 1 then
						return
					end
					LastTick = Current
					-- game:GetService("ReplicatedStorage").Modules.UpdateService.Parent = workspace
					-- Utility.GameEvents:WaitForChild("BeanstalkRESubmitAllPlant"):FireServer()
					Utility.GameEvents:WaitForChild("ClaimFairyReward"):FireServer()
					-- Utility.GameEvents:WaitForChild("BeanstalkRESubmitHeldPlant"):FireServer()
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})
end)

-------------------------------------------------------------------------------

Module:Init(function()
	Library:CreateSection(Event, "Beanstalk Event")
	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0

	Library:CreateDropdown(Event, {
		Title = "Item Event",
		Values = Module:SortArray(Utility.EventItem),
		Value = {},
		Multi = true,
		AllowNone = true,
		Callback = function(option)
			Item_Event = option
		end,
	})

	Event:Toggle({
		Title = "Auto Buy Beanstalk Event Item",
		Desc = "Automatically Buy Beanstalk Event Item",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick = Current

					if type(Item_Event) == "table" and #Item_Event > 0 then
						for _, v in pairs(Item_Event) do
							Module:BuyEventItem(v)
						end
					end
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})

	Event:Toggle({
		Title = "Auto Submit Beanstalk Event",
		Desc = "Automatically Submit Ur Plants",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < 1 then
						return
					end
					LastTick = Current
					-- game:GetService("ReplicatedStorage").Modules.UpdateService.Parent = workspace
					Utility.GameEvents:WaitForChild("BeanstalkRESubmitAllPlant"):FireServer()
					Utility.GameEvents:WaitForChild("BeanstalkREClaimFence"):FireServer()
					Utility.GameEvents:WaitForChild("BeanstalkRESubmitHeldPlant"):FireServer()
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})

	Event:Toggle({
		Title = "Auto Claim Reward Beanstalk Event",
		Desc = "Automatically Claim Reward Beanstalk Event",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < 1 then
						return
					end
					LastTick = Current
					-- game:GetService("ReplicatedStorage").Modules.UpdateService.Parent = workspace
					-- Utility.GameEvents:WaitForChild("BeanstalkRESubmitAllPlant"):FireServer()
					Utility.GameEvents:WaitForChild("BeanstalkREClaimReward"):FireServer()
					-- Utility.GameEvents:WaitForChild("BeanstalkRESubmitHeldPlant"):FireServer()
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})

	Event:Toggle({
		Title = "Auto Restock Beanstalk Shop",
		Desc = "Automatically Restock Plants In The Beanstalk Shop",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < 1 then
						return
					end
					LastTick = Current
					-- game:GetService("ReplicatedStorage").Modules.UpdateService.Parent = workspace
					Utility.GameEvents:WaitForChild("BuyEventShopRestock"):FireServer()
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})
end)

Module:Init(function()
	Library:CreateSection(Event, "Zen Event")
	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0

	Event:Toggle({
		Title = "Auto Submit Zen Event",
		Desc = "Automatically Inputs Ur Plants In The Zen Event",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < 5 then
						return
					end
					LastTick = Current

					Utility.GameEvents:WaitForChild("ZenQuestRemoteEvent"):FireServer("SubmitAllPlants")
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})
end)

Module:Init(function() --// Auto Buy Zen Items
	Library:CreateSection(Event, "Zen Event")
	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0
	local DelayBuy = 10

	Event:Toggle({
		Title = "Auto Buy Zen Items",
		Desc = "Automatically purchases all items from the Zen Event shop",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < DelayBuy then
						return
					end
					LastTick = Current

					local ReplicatedStorage = game:GetService("ReplicatedStorage")
					local BuyEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock")

					local zenShopItems = {
						"Zen Seed Pack",
						"Zen Egg",
						"Hot Spring",
						"Zen Sand",
						"Zenflare Stage 1",
						"Zen Crate Stage 2",
						"Soft Sunshine Stage 3",
						"Koi Stage 4",
						"Zen Gnome Crate Stage 5",
						"Spiked Mango Stage 6",
						"Pet Shard Tranquil Stage 7"
					}

					for _, itemName in ipairs(zenShopItems) do
						BuyEvent:FireServer(itemName)
						task.wait(0.2)
					end
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})
end)

Module:Init(function()
	Library:CreateSection(Event, "Zen Event")
	local ConnectionInit = Module:SpawnConnection()
	local ConnectionResetStock = nil

	Event:Toggle({
		Title = "Auto Reset Zen Shop Stock",
		Desc = "Automatically resets Zen Event shop stock",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				if ConnectionResetStock then
					ConnectionInit:Disconnect(ConnectionResetStock)
					ConnectionResetStock = nil
				end

				ConnectionResetStock = ConnectionInit:Connect("Heartbeat", function()
					local ReplicatedStorage = game:GetService("ReplicatedStorage")
					local RestockEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEventShopRestock")
					RestockEvent:FireServer()
					task.wait(0.5)
				end)
			else
				if ConnectionResetStock then
					ConnectionInit:Disconnect(ConnectionResetStock)
					ConnectionResetStock = nil
				end
			end
		end,
	})
end)

Module:Init(function()
	Library:CreateSection(Event, "Corrupted Event")
	local ConnectionInit = Module:SpawnConnection()
	local ConnectionSubmit = nil

	Event:Toggle({
		Title = "Auto Submit to Kitsune",
		Desc = "Automatically submit Tranquil to Kitsune when have",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State then
				if ConnectionSubmit then
					ConnectionInit:Disconnect(ConnectionSubmit)
					ConnectionSubmit = nil
				end

				ConnectionSubmit = ConnectionInit:Connect("Heartbeat", function()
					local player = game.Players.LocalPlayer
					local backpack = player:FindFirstChild("Backpack")
					local character = player.Character or player.CharacterAdded:Wait()
					local tranquil = (backpack and backpack:FindFirstChild("Tranquil")) or (character and character:FindFirstChild("Tranquil"))

					if tranquil and tranquil.Parent ~= character then
						tranquil.Parent = character
					end

					if character:FindFirstChild("Tranquil") then
						game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("ZenQuestRemoteEvent"):FireServer("SubmitToFox")
					end
				end)
			else
				if ConnectionSubmit then
					ConnectionInit:Disconnect(ConnectionSubmit)
					ConnectionSubmit = nil
				end
			end
		end
	})
end)

Module:Init(function()
	Library:CreateSection(Event, "Corrupted Event")

	local ConnectionInit = Module:SpawnConnection()
	local ConnectionChest = nil

	Event:Toggle({
		Title = "Auto Open Kitsune Chest",
		Desc = "Automatically open 'Kitsune Chest' if have in backpack",
		Icon = "gift",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State then
				if ConnectionChest then
					ConnectionInit:Disconnect(ConnectionChest)
					ConnectionChest = nil
				end

				local Players = game:GetService("Players")
				local VirtualInput = game:GetService("VirtualInputManager")
				local player = Players.LocalPlayer
				local backpack = player:WaitForChild("Backpack")

				local function equipTool(tool)
					if player.Character and tool and tool:IsA("Tool") then
						tool.Parent = player.Character
					end
				end

				local function clickScreen()
					VirtualInput:SendMouseButtonEvent(500, 500, 0, true, game, 1)
					task.wait(0.05)
					VirtualInput:SendMouseButtonEvent(500, 500, 0, false, game, 1)
				end

				ConnectionChest = ConnectionInit:Connect("Heartbeat", function()
					local kitsuneChest = backpack:FindFirstChild("Kitsune Chest")
					if kitsuneChest then
						equipTool(kitsuneChest)
						task.wait(0.3)
						clickScreen()
					end
				end)
			else
				if ConnectionChest then
					ConnectionInit:Disconnect(ConnectionChest)
					ConnectionChest = nil
				end
			end
		end
	})
end)

--// Misc
Module:Init(function() --// Auto Move Plants
	Library:CreateSection(Misc, "Auto Move Plants (Trowel Required)")
	local TargetPlants = Collection["Auto Move"].TargetPlants
	local MoveMethod = Collection["Auto Move"].MoveMethod
	local Delay2 = Collection["Auto Move"].Delay

	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0

	local Farm, Important = Module:GetFarm()

	Library:CreateDropdown(Misc, {
		Title = "Plants To Move",
		Values = Module:SortArray(Utility.Fruits),
		Value = { "All" },
		Multi = true,
		AllowNone = true,
		Callback = function(option)
			TargetPlants = option
		end,
	})

	Library:CreateDropdown(Misc, {
		Title = "Move Method",
		Values = { "UnderPlayer", "UnderMouse", "Random" },
		Value = "UnderPlayer",
		Multi = false,
		AllowNone = true,
		Callback = function(option)
			MoveMethod = option
		end,
	})

	Misc:Toggle({
		Title = "Auto Move Plants",
		Desc = "Automatically Moves Plants In The Selected Place",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick = Current

					local Plants = Module:GetPhysicalPlants()
					local Trowel = Module:GetTrowel(true)

					if Trowel then
						if table.find(TargetPlants, "All") then
							for _, v in pairs(Plants) do
								Module:MovePlant(Trowel, v, MoveMethod)
							end
						else
							for _, v in pairs(Plants) do
								if table.find(TargetPlants, v.Name) then
									Module:MovePlant(Trowel, v, MoveMethod)
								end
							end
						end
					end
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end

				local Plants = Module:GetPhysicalPlants()
				for _, v in pairs(Plants) do
					if v:GetAttribute("Moved") ~= nil then
						v:SetAttribute("Moved", nil)
					end
				end
			end
		end,
	})
end)

Module:Init(function() --// Teleport to places
	Library:CreateSection(Misc, "Teleport to places")
	local TpZone = Collection.Teleport.Place

	Library:CreateDropdown(Misc, {
		Title = "Teleport Zones",
		Values = { "Gear Shop", "Pet Shop", "Middle", "Cosmetics Shop", "Crafting Zone" },
		Value = "Middle",
		Multi = false,
		AllowNone = true,
		Callback = function(option)
			TpZone = option
		end,
	})

	Library:CreateButton(Misc, {
		Title = "Tp To Zone",
		Desc = "Teleports you to the selected zone",
		Locked = false,
		Callback = function()
			for i, v in pairs(Utility.Positions) do
				if i == TpZone then
					HumanoidRootPart.CFrame = v
				end
			end
		end,
	})
end)

Module:Init(function()
	Library:CreateSection(Event, "Zen Event")

	local zenShopItems = {
		"Zen Seed Pack",
		"Zen Egg",
		"Hot Spring",
		"Zen Sand",
		"Zenflare Stage 1",
		"Zen Crate Stage 2",
		"Soft Sunshine Stage 3",
		"Koi Stage 4",
		"Zen Gnome Crate Stage 5",
		"Spiked Mango Stage 6",
		"Pet Shard Tranquil Stage 7"
	}

	local SelectedItem = zenShopItems[1]

	Library:CreateDropdown(Event, {
		Title = "Select Zen Item",
		Desc = "Choose an item from the Zen Event shop",
		Values = zenShopItems,
		Value = SelectedItem,
		Multi = false,
		AllowNone = false,
		Callback = function(option)
			SelectedItem = option
		end,
	})

	Library:CreateButton(Event, {
		Title = "Buy Selected Zen Item",
		Desc = "Buys the item you selected from Zen Event shop",
		Callback = function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local BuyEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock")
			if SelectedItem then
				BuyEvent:FireServer(SelectedItem)
			else
				warn("please choose any items to buy")
			end
		end,
	})
end)

Module:Init(function() --// Auto Hatch Eggs
	Library:CreateSection(Misc, "Hatching Eggs")
	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0
	local Delay2 = 5

	local Farm, Imp = Module:GetFarm()

	Misc:Toggle({
		Title = "Auto Hatch Eggs",
		Desc = "Automatically hatches all the ready eggs in ur garden",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick = Current

					for _, v in pairs(Imp:FindFirstChild("Objects_Physical"):GetChildren()) do
						if v.Name == "PetEgg" and v:GetAttribute("READY", true) then
							Module:ManagePetService("HatchPet", v)
						end
					end
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})

	Library:CreateButton(Misc, {
		Title = "Hatch All Pets",
		Desc = "Hatches all the ready eggs in ur garden",
		Locked = false,
		Callback = function()
			for _, v in pairs(Imp:FindFirstChild("Objects_Physical"):GetChildren()) do
				if v.Name == "PetEgg" and v:GetAttribute("READY", true) then
					Module:ManagePetService("HatchPet", v)
				end
			end
		end,
	})
end)

Module:Init(function() --// Auto Place Eggs
	Library:CreateSection(Misc, "Placing Eggs")

	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0
	local Delay2 = 1
	local Farm, Imp = Module:GetFarm()

	Misc:Toggle({
		Title = "Auto Place Eggs",
		Desc = "Automatically Places All The Eggs In Ur Inventory",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick = Current

					local Has, Apply = Module:HasItem("Egg", true)

					if Has then
						Module:ManagePetService("CreateEgg", Module:GetPosition("Random"))
					else
						for _, v in pairs(Character:GetChildren()) do
							if v:IsA("Tool") and v.Name:find("Egg") then
								Module:ManagePetService("CreateEgg", Module:GetPosition("Random"))
							end
						end
					end
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})

	local HatchAllButton = Library:CreateButton(Misc, {
		Title = "Place All Eggs",
		Desc = "places all the eggs in ur inventory",
		Locked = false,
		Callback = function()
			local Has, Apply = Module:HasItem("Egg", true)

			if Has then
				Module:ManagePetService("CreateEgg", Module:GetPosition("Random"))
			else
				for _, v in pairs(Character:GetChildren()) do
					if v:IsA("Tool") and v.Name:find("Egg") then
						Module:ManagePetService("CreateEgg", Module:GetPosition("Random"))
					end
				end
			end
		end,
	})
end)

Module:Init(function() --// Auto Open Crates
	Library:CreateSection(Misc, "Opening Crates")
	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0
	local Delay2 = 5

	local Farm, Imp = Module:GetFarm()

	Misc:Toggle({
		Title = "Auto Open Crates",
		Desc = "Automatically opens all the ready crates in ur garden",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick = Current

					for _, v in pairs(Imp:FindFirstChild("Objects_Physical"):GetChildren()) do
						if v.Name == "CosmeticCrate" and v:GetAttribute("READY", true) then
							Module:ManageCrateService("OpenCrate", v)
						end
					end
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})

	Library:CreateButton(Misc, {
		Title = "Open All Crates",
		Desc = "Opens all the ready crates in ur garden",
		Locked = false,
		Callback = function()
			for _, v in pairs(Imp:FindFirstChild("Objects_Physical"):GetChildren()) do
				if v.Name == "CosmeticCrate" and v:GetAttribute("READY", true) then
					Module:ManageCrateService("OpenCrate", v)
				end
			end
		end,
	})
end)

Module:Init(function() --// Auto Place Crates
	Library:CreateSection(Misc, "Placing Crates")
	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0
	local Delay2 = 1
	local Farm, Imp = Module:GetFarm()

	Misc:Toggle({
		Title = "Auto Place Crates",
		Desc = "Automatically places all the crates in ur inventory",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick = Current

					local Has, Apply = Module:HasItem("Crate", true)

					if Has then
						Module:ManageCrateService("CreateCrate", Module:GetPosition("Random"))
					else
						for _, v in pairs(Character:GetChildren()) do
							if v:IsA("Tool") and v.Name:find("Crate") then
								Module:ManagePetService("CreateCrate", Module:GetPosition("Random"))
							end
						end
					end
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})

	Library:CreateButton(Misc, {
		Title = "Place All Crates",
		Desc = "Places All The Crates In Ur Inventory",
		Locked = false,
		Callback = function()
			local Has, Apply = Module:HasItem("Crate", true)

			if Has then
				Module:ManageCrateService("CreateCrate", Module:GetPosition("Random"))
			else
				for _, v in pairs(Character:GetChildren()) do
					if v:IsA("Tool") and v.Name:find("Crate") then
						Module:ManagePetService("CreateCrate", Module:GetPosition("Random"))
					end
				end
			end
		end,
	})
end)

Module:Init(function()
	Library:CreateSection(Misc, "Team Pet")
	local HttpService = game:GetService("HttpService")
	local Folder_name = "Phantom Flux"
	local folderPath = "Phantom Flux/GAG"

	local function ensureFolder(path)
		if not isfolder(path) then
			makefolder(path)
			print("[Folder]: Created folder:", path)
		end
	end

	ensureFolder(Folder_name)
	ensureFolder(folderPath)
	
	local jsonFiles = {}

	if listfiles then
		for _, filePath in pairs(listfiles(folderPath)) do
			if filePath:lower():sub(-5) == ".json" then
				local fileName = filePath:match("[^/\\]+$")
				table.insert(jsonFiles, fileName)
			end
		end

		print("Found " .. #jsonFiles .. " JSON file(s).")
		for _, file in pairs(jsonFiles) do
			print(file)
		end
	else
		warn("Your executor does not support listfiles()")
	end

	local function loadJson(fileName)
		local filePath = folderPath .. "/" .. fileName

		if isfile(filePath) then
			local content = readfile(filePath)

			local success, data = pcall(function()
				return HttpService:JSONDecode(content)
			end)

			if success then
				print("[File]: Loaded JSON:", filePath)
				return data
			else
				warn("[File]: Failed to decode JSON:", filePath)
				return nil
			end
		else
			warn("[File]: Not found:", filePath)
			return nil
		end
	end

	local function createFile(fileName, content)
		ensureFolder(Folder_name)
		ensureFolder(folderPath)

		local filePath = folderPath .. "/" .. fileName .. ".json"
		if type(content) == "table" then
			content = HttpService:JSONEncode(content)
		elseif type(content) ~= "string" then
			content = tostring(content)
		end

		if not isfile(filePath) then
			writefile(filePath, content or "")
			print("[File]: Created file:", filePath)
		else
			warn("[File]: Already exists:", filePath)
		end
	end

	local function deleteFile(fileName)
		local filePath = folderPath .. "/" .. fileName

		if isfile(filePath) then
			delfile(filePath)
			print("[File]: Deleted -> " .. filePath)
		else
			warn("[File]: File not found -> " .. filePath)
		end
	end
	
	local function Get_Current_Pet()
		local Pet_In_Team = {}
		for index, value in pairs(workspace.PetsPhysical:GetChildren()) do
			local Get_Owner_Name = value:GetAttribute("OWNER")
			local Get_Pet_UID = value:GetAttribute("UUID")
			if Get_Owner_Name == LocalPlayer.Name then
				table.insert(Pet_In_Team,Get_Pet_UID)
			end
		end

		-- table.foreach(Pet_In_Team,print)
		return Pet_In_Team
	end

	local Pet_Dropdown = Library:CreateDropdown(Misc, {
		Title = "Select Pet Team",
		Values = jsonFiles,
		Value = "",
		Multi = false,
		AllowNone = true,
		Callback = function(option)
			Pet_Team = option
		end,
	})

	Library:CreateButton(Misc, {
		Title = "Refresh Pet Team",
		Desc = "Refresh Pet Team file",
		Locked = false,
		Callback = function()
			local jsonFiles = {}
			if listfiles then
				for _, filePath in pairs(listfiles(folderPath)) do
					if filePath:lower():sub(-5) == ".json" then
						local fileName = filePath:match("[^/\\]+$")
						table.insert(jsonFiles, fileName)
					end
				end
			end
        	Pet_Dropdown:Refresh(jsonFiles)
		end,
	})

	Library:CreateInput(Misc, {
		Title = "Enter Pet Team Name",
		Placeholder = "Any Name you want.",
		Value = "",
		Callback = function(Text)
			Pet_Team_Name = Text
		end,
	})

	Library:CreateButton(Misc, {
		Title = "Create Pet Team",
		Desc = "Create Json file for Your Pet Team",
		Locked = false,
		Callback = function()
			createFile(Pet_Team_Name, Get_Current_Pet())
		end,
	})

	Library:CreateButton(Misc, {
		Title = "Delete Pet Team",
		Desc = "Delete Select Json file ",
		Locked = false,
		Callback = function()
			deleteFile(Pet_Team)
		end,
	})

	Library:CreateButton(Misc, {
		Title = "Deploy Pet",
		Desc = "Deploy pet team from your json file",
		Locked = false,
		Callback = function()
			local Current_Pet = Get_Current_Pet()
			for i,v in pairs(Current_Pet) do
				local args = {
					"UnequipPet",
					v
				}
				game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("PetsService"):FireServer(unpack(args))
			end

			wait(0.5)

			local petTeam = loadJson(Pet_Team)

			if petTeam then
				for i, pet in ipairs(petTeam) do
					local args = {
						"EquipPet",
						pet,
						CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position)
					}
					game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("PetsService"):FireServer(unpack(args))
				end
			end
		end,
	})
end)

Module:Init(function() --// Auto Feed Pets, Creds MrScam
	Library:CreateSection(Misc, "Auto Feed Pets")
	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0
	local Delay2 = 1

	getgenv().Setting = {
		["Dont Sell If It Is Mutated"] = {},
		PercentageToFeed = 80,
	}

	function GetPetData(PetUUID)
		local TimeoutTime = tick()
		local Pet = nil
		repeat
			task.wait(1)
			local result = Utility.ActivePetsService:GetPetData(LocalPlayer.Name, PetUUID)
			if result then
				Pet = result
			end
		until Pet ~= nil or tick() - TimeoutTime > 30
		return Pet
	end

	function GetCurrentHungerPercentage(PetUUId)
		local Data = GetPetData(PetUUId)
		local CurrentHunger, DefaultHunger = Data.PetData.Hunger, Utility.PetList[Data.PetType].DefaultHunger
		return (CurrentHunger / DefaultHunger) * 100
	end

	function CheckHoldableMutations(Holdable)
		local MutationList = Setting["Dont Sell If It Is Mutated"]
		if #MutationList <= 0 then
			return true
		end
		for _, Mutation in pairs(MutationList) do
			if Holdable:GetAttribute(Mutation) or string.find(Holdable.Name, Mutation) then
				return false
			end
		end

		return true
	end

	function GetPlantCanFeed()
		local Item = LocalPlayer.Character:FindFirstChildOfClass("Tool")
		if Item then
			if Item:GetAttribute("b") == "j" and not Item:GetAttribute("d") and CheckHoldableMutations(Item) then
				return Item
			end
		end

		local Plants = {}
		for _, Item in pairs(LocalPlayer.Backpack:GetChildren()) do
			if Item:GetAttribute("b") == "j" and not Item:GetAttribute("d") and CheckHoldableMutations(Item) then
				table.insert(Plants, Item)
			end
		end
		return Plants
	end

	function FeedPet(PetUUId)
		local Plants = GetPlantCanFeed()
		if type(Plants) == "table" and #Plants <= 0 then
			return
		end
		repeat
			wait()
			if type(Plants) ~= "table" then
				Utility.ActivePetService:FireServer("Feed", PetUUId)
			elseif #Plants > 0 then
				for _, Item in Plants do
					if Item.Parent == LocalPlayer.Backpack then
						Item.Parent = LocalPlayer.Character
						wait(0.2)
					end
					Utility.ActivePetService:FireServer("Feed", PetUUId)
				end
			end
			local Plants = GetPlantCanFeed()
		until (type(Plants) == "table" and #Plants <= 0)
			or (GetCurrentHungerPercentage(PetUUId) > Setting.PercentageToFeed or 70)
	end

	function GetEquippedPetsUUId()
		if #Utility.DataService:GetData().PetsData.EquippedPets <= 0 then
			return nil
		end
		local PetUUIdList = {}
		for _, PetUUId in Utility.DataService:GetData().PetsData.EquippedPets do
			table.insert(PetUUIdList, PetUUId)
		end
		return PetUUIdList
	end

	Misc:Toggle({
		Title = "Auto Feed Pets",
		Desc = "Automatically Feeds The Pets In Ur Garden",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick = Current
					if GetEquippedPetsUUId() and State then
						local ListPet = GetEquippedPetsUUId()
						for _, PetUUId in ListPet do
							local PerCentage = GetCurrentHungerPercentage(PetUUId)
							if PerCentage <= Setting.PercentageToFeed or 70 then
								FeedPet(PetUUId)
							end
						end
					end
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})
end)

Module:Init(function() --// Steal Fruits
	Library:CreateSection(Misc, "Stealing Features")
	local BestFruit

	Library:CreateButton(Misc, {
		Title = "Find Best Fruit",
		Desc = "Finds the best fruit in the server",
		Locked = false,
		Callback = function()
			local Fruit, Value = Module:GetBestFruit()

			if Fruit then
				BestFruit = Fruit

				Module:Init(function()
					Module:SendNotification('<font color="rgb(173,216,230)">Fruit Found!</font>')
					Module:SendNotification(
						'<font color="rgb(173,216,230)">You can now use the other features below</font>'
					)
					Module:SendNotification("Fruit Name: " .. Fruit.Name .. " Fruit Value: " .. tostring(Value) .. "")
				end)
			else
				warn("Couldn't Find Fruit")
			end
		end,
	})

	Library:CreateButton(Misc, {
		Title = "Teleport To The Best Fruit",
		Desc = "Teleport to the best fruit in the server",
		Locked = false,
		Callback = function()
			local Fruit = Module:GetBestFruit()

			if Fruit then
				local Primary = Fruit.PrimaryPart

				if Primary then
					HumanoidRootPart.CFrame = Primary.CFrame
				else
					warn("no primarypart")
				end
			else
				warn("Please Click 'Find the best fruit' Before Using This")
			end
		end,
	})

	Library:CreateButton(Misc, {
		Title = "Steal Best Fruit ( use tp first )",
		Desc = "Steal the best fruit in the server",
		Locked = false,
		Callback = function()
			local Fruit = Module:GetBestFruit()

			if Fruit then
				local Proxy = Module:GetProxy(Fruit)

				if Proxy then
					fireproximityprompt(Proxy)
				end
			else
				warn("Please Click 'Find the best fruit' Before Using This")
			end
		end,
	})
end)

Module:Init(function() --// Claim Gifts: creds void
	Library:CreateSection(Misc, "Gifts")
	local ConnectionInit = Module:SpawnConnection()
	local Connection = nil
	local LastTick = 0
	local Delay2 = 2

	Misc:Toggle({
		Title = "Auto Place Crates",
		Desc = "Automatically places all the crates in ur inventory",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(State)
			if State == true then
				ConnectionInit:Disconnect(Connection)

				Connection = ConnectionInit:Connect("Heartbeat", function()
					local Current = tick()
					if Current - LastTick < Delay2 then
						return
					end
					LastTick = Current

					local FriendGiftEvent = Utility.ReplicatedStorage.GameEvents.FriendGiftEvent
					FriendGiftEvent.OnClientEvent:Connect(function()
						if State then
							replicatesignal(
								Utility.PlayerGui.Gift_Notification.Frame:WaitForChild("Gift_Notification").Holder.Frame.Accept.MouseButton1Click
							)
						end
					end)
				end)
			else
				if Connection then
					ConnectionInit:Disconnect(Connection)
					Connection = nil
				end
			end
		end,
	})
end)

--// Exclusive
Module:Init(function() --// Pet Freezer
	Library:CreateSection(Exclusive, "Freeze Pets (works on mooncats)")

	Library:CreateButton(Exclusive, {
		Title = "Pet Freezer",
		Desc = "Freeze all the pets in the game",
		Locked = false,
		Callback = function()
			local PetsPhysical = Utility.Workspace.PetsPhysical

			for _, v in pairs(PetsPhysical:GetChildren()) do
				if v:IsA("Part") then
					v.Anchored = false
				end
			end
		end,
	})

	Library:CreateButton(Exclusive, {
		Title = "Pet UnFreezer",
		Desc = "UnFreeze all the pets in the game",
		Locked = false,
		Callback = function()
			local PetsPhysical = Utility.Workspace.PetsPhysical

			for _, v in pairs(PetsPhysical:GetChildren()) do
				if v:IsA("Part") then
					v.Anchored = true
				end
			end
		end,
	})
end)

Module:Init(function() --// Auto Craft Seeds
	Library:CreateSection(Exclusive, "Auto Craft Seeds")
	local SeedToCraft = Collection.Crafters["Seed Crafting"].Seed
	print(type(Utility.Crafting["Seed Recipes"]))

	Library:CreateDropdown(Exclusive, {
		Title = "Seed to Craft",
		Values = Module:SortArray(Utility.Crafting["Seed Recipes"]),
		Value = "Peace Lily",
		Multi = false,
		AllowNone = true,
		Callback = function(option)
			SeedToCraft = option
		end,
	})

	Library:CreateButton(Exclusive, {
		Title = "Craft Selected Seed",
		Desc = "Crafts the seed you selected",
		Locked = false,
		Callback = function()
			Module:Craft(SeedToCraft, 1)
		end,
	})
end)

Module:Init(function() --// Auto Craft Gears
	Library:CreateSection(Exclusive, "Auto Craft Gears")
	local GearToCraft = Collection.Crafters["Gear Crafting"].Gear

	Library:CreateDropdown(Exclusive, {
		Title = "Gear to Craft",
		Values = Module:SortArray(Utility.Crafting["Gear Recipes"]),
		Value = GearToCraft,
		Multi = false,
		AllowNone = true,
		Callback = function(option)
			GearToCraft = option
		end,
	})

	Library:CreateButton(Exclusive, {
		Title = "Craft Selected Seed",
		Desc = "Crafts the seed you selected",
		Locked = false,
		Callback = function()
			Module:Craft(GearToCraft, 2)
		end,
	})
end)

Module:Init(function() --// Auto Craft Event Items
	Library:CreateSection(Exclusive, "Auto Craft Event Items")
	local ItemToCraft = Collection.Crafters["Event Crafting"].Item

	Library:CreateDropdown(Exclusive, {
		Title = "Item to Craft",
		Values = Module:SortArray(Utility.Crafting["Dino Recipes"]),
		Value = ItemToCraft,
		Multi = false,
		AllowNone = true,
		Callback = function(option)
			ItemToCraft = option
		end,
	})

	Library:CreateButton(Exclusive, {
		Title = "Craft Selected Item",
		Desc = "Crafts the item you selected",
		Locked = false,
		Callback = function()
			Module:Craft(ItemToCraft, 3)
		end,
	})
end)

Module:Init(function() --// Exit //--
	Module:SendNotification('<font color="rgb(173,216,230)">Thanks for using DYHUB!</font>')
	Module:SendNotification('<font color="rgb(173,216,230)">Join Our Discord For More Updates</font>')
	Module:SendNotification('<font color="rgb(173,216,230)">Scripted by severitysvc :heart: </font>')
end)


