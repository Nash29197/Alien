--// library script private
getgenv().namehub = "Private"
local UserInputService = game:GetService('UserInputService')
local LocalPlayer = game:GetService('Players').LocalPlayer
local TweenService = game:GetService('TweenService')
local HttpService = game:GetService('HttpService')
local CoreGui = game:GetService('CoreGui')

local Mouse = LocalPlayer:GetMouse();


local Library = {
	connections = {};
    Flags = {};
    Enabled = true;
    slider_drag = false;
    core = nil;
    dragging = false;
    drag_position = nil;
    start_position = nil;
}


if not isfolder("cac hub") then
    makefolder("cac hub")
end

function Library:disconnect()
	for _, value in Library.connections do
		if not Library.connections[value] then
			continue
		end

		Library.connections[value]:Disconnect()
		Library.connections[value] = nil
	end
end

function Library:clear()
	for _, object in CoreGui:GetChildren() do
		if object.Name ~= "cac" then
			continue
		end
	
		object:Destroy()
	end
end

function Library:exist()
    if not Library.core then return end
    if not Library.core.Parent then return end
    return true
end

function Library:save_flags()
    if not Library.exist() then return end

    local flags = HttpService:JSONEncode(Library.Flags)
    writefile(`cac hub/{game.GameId}.lua`, flags)
end

function Library:load_flags()
    if not isfile(`cac hub/{game.GameId}.lua`) then Library.save_flags() return end

    local flags = readfile(`cac hub/{game.GameId}.lua`)
    if not flags then Library.save_flags() return end

    Library.Flags = HttpService:JSONDecode(flags)
end

Library.load_flags()
Library.clear()

function Library:open()
	self.Container.Visible = true
	self.Shadow.Visible = true
	self.Mobile.Modal = true

	TweenService:Create(self.Container, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
		Size = UDim2.new(0, 699, 0, 426)
	}):Play()

	TweenService:Create(self.Shadow, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
		Size = UDim2.new(0, 776, 0, 509)
	}):Play()
end

function Library:close()
	TweenService:Create(self.Shadow, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
		Size = UDim2.new(0, 0, 0, 0)
	}):Play()

	local main_tween = TweenService:Create(self.Container, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
		Size = UDim2.new(0, 0, 0, 0)
	})

	main_tween:Play()
	main_tween.Completed:Once(function()
		if Library.enabled then
			return
		end

		self.Container.Visible = false
		self.Shadow.Visible = false
		self.Mobile.Modal = false
	end)
end

function Library:drag()
	if not Library.drag_position then
		return
	end
	
	if not Library.start_position then
		return
	end
	
	local delta = self.input.Position - Library.drag_position
	local position = UDim2.new(Library.start_position.X.Scale, Library.start_position.X.Offset + delta.X, Library.start_position.Y.Scale, Library.start_position.Y.Offset + delta.Y)

	TweenService:Create(self.container.Container, TweenInfo.new(0.2), {
		Position = position
	}):Play()

    TweenService:Create(self.container.Shadow, TweenInfo.new(0.2), {
		Position = position
	}):Play()
end

function Library:visible()
	Library.enabled = not Library.enabled

	if Library.enabled then
		Library.open(self)
	else
		Library.close(self)
	end
end

function Library:new()
	local container = Instance.new("ScreenGui")
	container.Name = "cac"
    container.Parent = CoreGui

    Library.core = container

	local Shadow = Instance.new("ImageLabel")
	Shadow.Name = "Shadow"
	Shadow.Parent = container
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Shadow.BackgroundTransparency = 1.000
	Shadow.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Shadow.BorderSizePixel = 0
	Shadow.Position = UDim2.new(0.508668244, 0, 0.5, 0)
	Shadow.Size = UDim2.new(0, 776, 0, 509)
	Shadow.ZIndex = 0
	Shadow.Image = "rbxassetid://17290899982"

	local Container = Instance.new("Frame")
	Container.Name = "Container"
	Container.Parent = container
	Container.AnchorPoint = Vector2.new(0.5, 0.5)
	Container.BackgroundColor3 = Color3.fromRGB(19, 20, 24)
	Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Container.BorderSizePixel = 0
	Container.ClipsDescendants = true
	Container.Position = UDim2.new(0.5, 0, 0.5, 0)
	Container.Size = UDim2.new(0, 699, 0, 426)

	local ContainerCorner = Instance.new("UICorner")
	ContainerCorner.CornerRadius = UDim.new(0, 20)
	ContainerCorner.Parent = container.Container

	local Top = Instance.new("ImageLabel")
	Top.Name = "Top"
	Top.Parent = Container
	Top.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Top.BackgroundTransparency = 1.000
	Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Top.BorderSizePixel = 0
	Top.Size = UDim2.new(0, 699, 0, 39)
	Top.Image = ""

	local Logo = Instance.new("ImageLabel")
	Logo.Name = "Logo"
	Logo.Parent = Top
	Logo.AnchorPoint = Vector2.new(0.5, 0.5)
	Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Logo.BackgroundTransparency = 1.000
	Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Logo.BorderSizePixel = 0
	Logo.Position = UDim2.new(0.0387367606, 0, 0.5, 0)
	Logo.Size = UDim2.new(0, 30, 0, 25)
	Logo.Image = ""
	
	local TextLabel = Instance.new("TextLabel")
	TextLabel.Parent = Top
	TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1.000
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Position = UDim2.new(0.0938254446, 0, 0.496794879, 0)
	TextLabel.Size = UDim2.new(0, 75, 0, 16)
	TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
	TextLabel.Text = getgenv().namehub
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextScaled = true
	TextLabel.TextSize = 14.000
	TextLabel.TextWrapped = true
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left

	local Line = Instance.new("Frame")
	Line.Name = "Line"
	Line.Parent = Container
	Line.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
	Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Line.BorderSizePixel = 0
	Line.Position = UDim2.new(0.296137333, 0, 0.0915492922, 0)
	Line.Size = UDim2.new(0, 2, 0, 387)

    local tabs = Instance.new("ScrollingFrame")
	tabs.Name = "Tabs"
	tabs.Active = true
	tabs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	tabs.BackgroundTransparency = 1.000
	tabs.BorderColor3 = Color3.fromRGB(0, 0, 0)
	tabs.BorderSizePixel = 0
	tabs.Position = UDim2.new(0, 0, 0.0915492922, 0)
	tabs.Size = UDim2.new(0, 209, 0, 386)
	tabs.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
	tabs.ScrollBarThickness = 0
    tabs.Parent = container.Container

	local tabslist = Instance.new("UIListLayout")
	tabslist.Parent = tabs
	tabslist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabslist.SortOrder = Enum.SortOrder.LayoutOrder
	tabslist.Padding = UDim.new(0, 9)

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = tabs
	UIPadding.PaddingTop = UDim.new(0, 15)

	local tabsCorner = Instance.new("UICorner")
	tabsCorner.Parent = tabs

    local mobile_button = Instance.new("TextButton")
	mobile_button.Name = "Mobile"
	mobile_button.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
	mobile_button.BorderColor3 = Color3.fromRGB(0, 0, 0)
	mobile_button.BorderSizePixel = 0
	mobile_button.Position = UDim2.new(0.0210955422, 0, 0.91790241, 0)
	mobile_button.Size = UDim2.new(0, 122, 0, 38)
	mobile_button.AutoButtonColor = false
	mobile_button.Modal = true
	mobile_button.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
	mobile_button.Text = ""
	mobile_button.TextColor3 = Color3.fromRGB(0, 0, 0)
	mobile_button.TextSize = 14.000
    mobile_button.Parent = container

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 13)
	UICorner.Parent = mobile_button

	local shadowMobile = Instance.new("ImageLabel")
	shadowMobile.Name = "Shadow"
	shadowMobile.Parent = mobile_button
	shadowMobile.AnchorPoint = Vector2.new(0.5, 0.5)
	shadowMobile.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	shadowMobile.BackgroundTransparency = 1.000
	shadowMobile.BorderColor3 = Color3.fromRGB(0, 0, 0)
	shadowMobile.BorderSizePixel = 0
	shadowMobile.Position = UDim2.new(0.5, 0, 0.5, 0)
	shadowMobile.Size = UDim2.new(0, 144, 0, 58)
	shadowMobile.ZIndex = 0
	shadowMobile.Image = "rbxassetid://17183270335"
	shadowMobile.ImageTransparency = 0.200

	local State = Instance.new("TextLabel")
	State.Name = "State"
	State.Parent = mobile_button
	State.AnchorPoint = Vector2.new(0.5, 0.5)
	State.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	State.BackgroundTransparency = 1.000
	State.BorderColor3 = Color3.fromRGB(0, 0, 0)
	State.BorderSizePixel = 0
	State.Position = UDim2.new(0.646000028, 0, 0.5, 0)
	State.Size = UDim2.new(0, 64, 0, 15)
	State.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
	State.Text = "Open"
	State.TextColor3 = Color3.fromRGB(255, 255, 255)
	State.TextScaled = true
	State.TextSize = 14.000
	State.TextWrapped = true
	State.TextXAlignment = Enum.TextXAlignment.Left

	local Icon = Instance.new("ImageLabel")
	Icon.Name = "Icon"
	Icon.Parent = mobile_button
	Icon.AnchorPoint = Vector2.new(0.5, 0.5)
	Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Icon.BackgroundTransparency = 1.000
	Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Icon.BorderSizePixel = 0
	Icon.Position = UDim2.new(0.268000007, 0, 0.5, 0)
	Icon.Size = UDim2.new(0, 15, 0, 15)
	Icon.Image = "rbxassetid://17183279677"
    container.Container.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Library.dragging = true
            Library.drag_position = input.Position
            Library.start_position = container.Container.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Library.dragging = false
                    Library.drag_position = nil
                    Library.start_position = nil
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            Library.drag({
                input = input,
                container = container
            })
        end
    end)

    UserInputService.InputBegan:Connect(function(input: InputObject, process: boolean)
        if process then return end

        if not Library.exist() then return end

        if input.KeyCode == Enum.KeyCode.Insert then
            Library.visible(container)
        end
    end)

    mobile_button.MouseButton1Click:Connect(function()
        Library.visible(container)
    end)

    local Tab = {}

    function Tab:update_sections()
        self.left_section.Visible = true
        self.right_section.Visible = true

        for _, object in container.Container:GetChildren() do
            if not object.Name:find("Section") then
                continue
            end

            if object == self.left_section then 
                continue
            end

            if object == self.right_section then
                continue
            end

            object.Visible = false
        end
    end

    function Tab:open_tab()
		Tab.update_sections({
			left_section = self.left_section,
			right_section = self.right_section
		})

		TweenService:Create(self.tab.Fill, TweenInfo.new(0.4), {
			BackgroundTransparency = 0
		}):Play()

		TweenService:Create(self.tab.Glow, TweenInfo.new(0.4), {
			ImageTransparency = 0
		}):Play()

		TweenService:Create(self.tab.TextLabel, TweenInfo.new(0.4), {
			TextTransparency = 0
		}):Play()

		TweenService:Create(self.tab.Logo, TweenInfo.new(0.4), {
			ImageTransparency = 0
		}):Play()

		for _, object in tabs:GetChildren() do
			if object.Name ~= 'Tab' then
				continue
			end

			if object == self.tab then
				continue
			end

			TweenService:Create(object.Fill, TweenInfo.new(0.4), {
				BackgroundTransparency = 1
			}):Play()

			TweenService:Create(object.Glow, TweenInfo.new(0.4), {
				ImageTransparency = 1
			}):Play()
	
			TweenService:Create(object.TextLabel, TweenInfo.new(0.4), {
				TextTransparency = 0.5
			}):Play()
	
			TweenService:Create(object.Logo, TweenInfo.new(0.4), {
				ImageTransparency = 0.5
			}):Play()
		end
	end

    function Tab:create_tab()
        local tab = Instance.new("TextButton")
		tab.Name = "Tab"
		tab.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
		tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
		tab.BorderSizePixel = 0
		tab.Size = UDim2.new(0, 174, 0, 40)
		tab.ZIndex = 2
		tab.AutoButtonColor = false
		tab.Font = Enum.Font.SourceSans
		tab.Text = ""
		tab.TextColor3 = Color3.fromRGB(0, 0, 0)
		tab.TextSize = 14.000
		tab.Parent = tabs

		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = UDim.new(0, 5)
		tabCorner.Parent = tab

		local TextLabel = Instance.new("TextLabel")
		TextLabel.Parent = tab
		TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.BackgroundTransparency = 1.000
		TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel.BorderSizePixel = 0
		TextLabel.Position = UDim2.new(0.58965224, 0, 0.5, 0)
		TextLabel.Size = UDim2.new(0, 124, 0, 15)
		TextLabel.ZIndex = 3
		TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
		TextLabel.Text = self
		TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.TextScaled = true
		TextLabel.TextSize = 14.000
		TextLabel.TextTransparency = 0.300
		TextLabel.TextWrapped = true
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left

		local Logo = Instance.new("ImageLabel")
		Logo.Name = "Logo"
		Logo.Parent = tab
		Logo.AnchorPoint = Vector2.new(0.5, 0.5)
		Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Logo.BackgroundTransparency = 1.000
		Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Logo.BorderSizePixel = 0
		Logo.Position = UDim2.new(0.130999997, 0, 0.5, 0)
		Logo.Size = UDim2.new(0, 17, 0, 17)
		Logo.ZIndex = 3
		Logo.Image = "rbxassetid://17290697757"
		Logo.ImageTransparency = 0.3001

		local Glow = Instance.new("ImageLabel")
		Glow.Name = "Glow"
		Glow.Parent = tab
		Glow.AnchorPoint = Vector2.new(0.5, 0.5)
		Glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Glow.BackgroundTransparency = 1.000
		Glow.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Glow.BorderSizePixel = 0
		Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
		Glow.Size = UDim2.new(0, 190, 0, 53)
		Glow.Image = "rbxassetid://17290723539"
		Glow.ImageTransparency = 1.000

		local Fill = Instance.new("Frame")
		Fill.Name = "Fill"
		Fill.Parent = tab
		Fill.AnchorPoint = Vector2.new(0.5, 0.5)
		Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Fill.BackgroundTransparency = 1.000
		Fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Fill.BorderSizePixel = 0
		Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
		Fill.Size = UDim2.new(0, 174, 0, 40)
		Fill.ZIndex = 2
		local UICorner_2 = Instance.new("UICorner")
		UICorner_2.CornerRadius = UDim.new(0, 10)
		UICorner_2.Parent = Fill

		local UIGradient = Instance.new("UIGradient")
		UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(66, 89, 182)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(37, 57, 137))}
		UIGradient.Rotation = 20
		UIGradient.Parent = Fill

		local left_section = Instance.new("ScrollingFrame")
		left_section.Name = "LeftSection"
		left_section.Active = true
		left_section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		left_section.BackgroundTransparency = 1.000
		left_section.BorderColor3 = Color3.fromRGB(0, 0, 0)
		left_section.BorderSizePixel = 0
		left_section.Position = UDim2.new(0.326180249, 0, 0.126760557, 0)
		left_section.Size = UDim2.new(0, 215, 0, 372)
		left_section.AutomaticCanvasSize = Enum.AutomaticSize.XY
		left_section.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
		left_section.ScrollBarThickness = 0

		local leftsectionlist = Instance.new("UIListLayout")
		leftsectionlist.Parent = left_section
		leftsectionlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		leftsectionlist.SortOrder = Enum.SortOrder.LayoutOrder
		leftsectionlist.Padding = UDim.new(0, 7)

		local right_section = Instance.new("ScrollingFrame")
		right_section.Name = "RightSection"
		right_section.Active = true
		right_section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		right_section.BackgroundTransparency = 1.000
		right_section.BorderColor3 = Color3.fromRGB(0, 0, 0)
		right_section.BorderSizePixel = 0
		right_section.Position = UDim2.new(0.662374794, 0, 0.126760557, 0)
		right_section.Size = UDim2.new(0, 215, 0, 372)
		right_section.AutomaticCanvasSize = Enum.AutomaticSize.XY
		right_section.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
		right_section.ScrollBarThickness = 0

		local rightsectionlist = Instance.new("UIListLayout")
		rightsectionlist.Parent = right_section

		rightsectionlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		rightsectionlist.SortOrder = Enum.SortOrder.LayoutOrder
		rightsectionlist.Padding = UDim.new(0, 7)

		if container.Container:FindFirstChild('RightSection') then
			left_section.Visible = false
			right_section.Visible = false
		else
			Tab.open_tab({
				tab = tab,
				left_section = left_section,
				right_section = right_section
			})
		end

		left_section.Parent = container.Container
		right_section.Parent = container.Container

		tab.MouseButton1Click:Connect(function()
			Tab.open_tab({
				tab = tab,
				left_section = left_section,
				right_section = right_section
			})
		end)

        local Module = {}

        function Module:create_title()
			local section = self.section == 'left' and left_section or right_section

			local title = Instance.new("TextLabel")
			title.Name = "Title"
			title.AnchorPoint = Vector2.new(0.5, 0.5)
			title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			title.BackgroundTransparency = 1.000
			title.BorderColor3 = Color3.fromRGB(0, 0, 0)
			title.BorderSizePixel = 0
			title.Position = UDim2.new(0.531395316, 0, 0.139784947, 0)
			title.Size = UDim2.new(0, 201, 0, 15)
			title.ZIndex = 2
			title.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
			title.TextColor3 = Color3.fromRGB(255, 255, 255)
			title.TextScaled = true
			title.TextSize = 14.000
			title.TextWrapped = true
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = section
			title.Text = self.name
		end

		function Module:enable_toggle()
			TweenService:Create(self.Checkbox.Fill, TweenInfo.new(0.4), {
				BackgroundTransparency = 0
			}):Play()

			TweenService:Create(self.Checkbox.Glow, TweenInfo.new(0.4), {
				ImageTransparency = 0
			}):Play()
		end

		function Module:disable_toggle()
			TweenService:Create(self.Checkbox.Fill, TweenInfo.new(0.4), {
				BackgroundTransparency = 1
			}):Play()

			TweenService:Create(self.Checkbox.Glow, TweenInfo.new(0.4), {
				ImageTransparency = 1
			}):Play()
		end

		function Module:update_toggle()
			if self.state then
				Module.enable_toggle(self.toggle)
			else
				Module.disable_toggle(self.toggle)
			end
		end

        function Module:create_toggle()
			local section = self.section == 'left' and left_section or right_section

			local toggle = Instance.new("TextButton")
			toggle.Name = "Toggle"
			toggle.Parent = section
			toggle.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
			toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
			toggle.BorderSizePixel = 0
			toggle.Size = UDim2.new(0, 215, 0, 37)
			toggle.AutoButtonColor = false
			toggle.Font = Enum.Font.SourceSans
			toggle.Text = ""
			toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
			toggle.TextSize = 14.000
			local UICorner = Instance.new("UICorner")
			UICorner.CornerRadius = UDim.new(0, 10)
			UICorner.Parent = toggle
	
			local Checkbox = Instance.new("Frame")
			Checkbox.Name = "Checkbox"
			Checkbox.Parent = toggle
			Checkbox.AnchorPoint = Vector2.new(0.5, 0.5)
			Checkbox.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
			Checkbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Checkbox.BorderSizePixel = 0
			Checkbox.Position = UDim2.new(0.915000021, 0, 0.5, 0)
			Checkbox.Size = UDim2.new(0, 17, 0, 17)		

			local UICorner_2 = Instance.new("UICorner")
			UICorner_2.CornerRadius = UDim.new(0, 4)
			UICorner_2.Parent = Checkbox

			local Glow = Instance.new("ImageLabel")
			Glow.Name = "Glow"
			Glow.Parent = Checkbox
			Glow.AnchorPoint = Vector2.new(0.5, 0.5)
			Glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Glow.BackgroundTransparency = 1.000
			Glow.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Glow.BorderSizePixel = 0
			Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
			Glow.Size = UDim2.new(0, 27, 0, 27)
			Glow.Image = "rbxassetid://17290798394"
			Glow.ImageTransparency = 1.000

			local Fill = Instance.new("Frame")
			Fill.Name = "Fill"
			Fill.Parent = Checkbox
			Fill.AnchorPoint = Vector2.new(0.5, 0.5)
			Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Fill.BackgroundTransparency = 1.000
			Fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Fill.BorderSizePixel = 0
			Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
			Fill.Size = UDim2.new(0, 17, 0, 17)

			local UICorner_3 = Instance.new("UICorner")
			UICorner_3.CornerRadius = UDim.new(0, 4)
			UICorner_3.Parent = Fill

			local UIGradient = Instance.new("UIGradient")
			UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(66, 89, 182)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(37, 57, 137))}
			UIGradient.Rotation = 20
			UIGradient.Parent = Fill

			local TextLabel = Instance.new("TextLabel")
			TextLabel.Parent = toggle
			TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0.444953382, 0, 0.5, 0)
			TextLabel.Size = UDim2.new(0, 164, 0, 15)
			TextLabel.ZIndex = 2
			TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.TextScaled = true
			TextLabel.TextSize = 14.000
			TextLabel.TextWrapped = true
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel.Text = self.name

			if not Library.Flags[self.flag] then
				Library.Flags[self.flag] = self.enabled
			end

			self.callback(Library.Flags[self.flag])
			
			Module.update_toggle({
				state = Library.Flags[self.flag],
				toggle = toggle
			})

			toggle.MouseButton1Click:Connect(function()
				Library.Flags[self.flag] = not Library.Flags[self.flag]
				Library.save_flags()

				Module.update_toggle({
					state = Library.Flags[self.flag],
					toggle = toggle
				})

				self.callback(Library.Flags[self.flag])
			end)
		end


        function Module:update_slider()
			local result = math.clamp((Mouse.X - self.slider.Box.AbsolutePosition.X) / self.slider.Box.AbsoluteSize.X, 0, 1)

			if not result then
				return
			end

			local number = math.floor(((self.maximum_value - self.minimum_value) * result) + self.minimum_value)
			local slider_size = math.clamp(result, 0.001, 0.999)
			
			self.slider.Box.Fill.UIGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(slider_size, 0),
				NumberSequenceKeypoint.new(math.min(slider_size + 0.001, 1), 1),
				NumberSequenceKeypoint.new(1, 1)
			})
			
			self.slider.Box.Glow.UIGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(slider_size, 0),
				NumberSequenceKeypoint.new(math.min(slider_size + 0.03, 1), 1),
				NumberSequenceKeypoint.new(1, 1)
			})

			Library.Flags[self.flag] = number

			self.slider.Number.Text = number
			self.callback(number)
		end

		function Module:slider_loop()
			Library.slider_drag = true
			
			while Library.slider_drag do
				Module.update_slider(self)
				
				task.wait()
			end
		end


        function Module:create_slider()
			local drag = false
			local section = self.section == 'left' and left_section or right_section

			local slider = Instance.new("TextButton")
			slider.Name = "Slider"
			slider.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
			slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
			slider.BorderSizePixel = 0
			slider.Size = UDim2.new(0, 215, 0, 48)
			slider.AutoButtonColor = false
			slider.Font = Enum.Font.SourceSans
			slider.Text = ""
			slider.TextColor3 = Color3.fromRGB(0, 0, 0)
			slider.TextSize = 14.000
			slider.Parent = section

			local UICorner = Instance.new("UICorner")
			UICorner.CornerRadius = UDim.new(0, 10)
			UICorner.Parent = slider

			local Box = Instance.new("Frame")
			Box.Name = "Box"
			Box.Parent = slider
			Box.AnchorPoint = Vector2.new(0.5, 0.5)
			Box.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
			Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Box.BorderSizePixel = 0
			Box.Position = UDim2.new(0.508023143, 0, 0.708333313, 0)
			Box.Size = UDim2.new(0, 192, 0, 6)

			local UICorner_2 = Instance.new("UICorner")
			UICorner_2.CornerRadius = UDim.new(0, 15)
			UICorner_2.Parent = Box

			local Glow = Instance.new("ImageLabel")
			Glow.Name = "Glow"
			Glow.Parent = Box
			Glow.AnchorPoint = Vector2.new(0.5, 0.5)
			Glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Glow.BackgroundTransparency = 1.000
			Glow.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Glow.BorderSizePixel = 0
			Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
			Glow.Size = UDim2.new(0, 204, 0, 17)
			Glow.ZIndex = 2
			Glow.Image = "rbxassetid://17381990533"

			local UIGradient = Instance.new("UIGradient")
			UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.50, 0.00), NumberSequenceKeypoint.new(0.53, 1.00), NumberSequenceKeypoint.new(1.00, 1.00)}
			UIGradient.Parent = Glow

			local Fill = Instance.new("ImageLabel")
			Fill.Name = "Fill"
			Fill.Parent = Box
			Fill.AnchorPoint = Vector2.new(0, 0.5)
			Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Fill.BackgroundTransparency = 1.000
			Fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Fill.BorderSizePixel = 0
			Fill.Position = UDim2.new(0, 0, 0.5, 0)
			Fill.Size = UDim2.new(0, 192, 0, 6)
			Fill.Image = "rbxassetid://17382033116"

			local UICorner_3 = Instance.new("UICorner")
			UICorner_3.CornerRadius = UDim.new(0, 4)
			UICorner_3.Parent = Fill

			local UIGradient_2 = Instance.new("UIGradient")
			UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.50, 0.00), NumberSequenceKeypoint.new(0.50, 1.00), NumberSequenceKeypoint.new(1.00, 1.00)}
			UIGradient_2.Parent = Fill
			
			local Hitbox = Instance.new("TextButton")
			Hitbox.Name = "Hitbox"
			Hitbox.Parent = Box
			Hitbox.AnchorPoint = Vector2.new(0.5, 0.5)
			Hitbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Hitbox.BackgroundTransparency = 1.000
			Hitbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Hitbox.BorderSizePixel = 0
			Hitbox.Position = UDim2.new(0.5, 0, 0.5, 0)
			Hitbox.Size = UDim2.new(0, 200, 0, 13)
			Hitbox.ZIndex = 3
			Hitbox.AutoButtonColor = false
			Hitbox.Font = Enum.Font.SourceSans
			Hitbox.Text = ""
			Hitbox.TextColor3 = Color3.fromRGB(0, 0, 0)
			Hitbox.TextSize = 14.000

			local TextLabel = Instance.new("TextLabel")
			TextLabel.Parent = slider
			TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0.414720833, 0, 0.375, 0)
			TextLabel.Size = UDim2.new(0, 151, 0, 15)
			TextLabel.ZIndex = 2
			TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.TextScaled = true
			TextLabel.TextSize = 14.000
			TextLabel.TextWrapped = true
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left

			local Number = Instance.new("TextLabel")
			Number.Name = "Number"
			Number.Parent = slider
			Number.AnchorPoint = Vector2.new(0.5, 0.5)
			Number.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Number.BackgroundTransparency = 1.000
			Number.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Number.BorderSizePixel = 0
			Number.Position = UDim2.new(0.854255736, 0, 0.375, 0)
			Number.Size = UDim2.new(0, 38, 0, 15)
			Number.ZIndex = 2
			Number.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
			Number.TextColor3 = Color3.fromRGB(255, 255, 255)
			Number.TextScaled = true
			Number.TextSize = 14.000
			Number.TextWrapped = true
			Number.TextXAlignment = Enum.TextXAlignment.Right


			TextLabel.Text = self.name
			Number.Text = self.value

			if not Library.Flags[self.flag] then
				Library.Flags[self.flag] = self.value
			end

			slider.Number.Text = Library.Flags[self.flag]
			self.callback(Library.Flags[self.flag])

			slider.Box.Hitbox.MouseButton1Down:Connect(function()
				if Library.slider_drag then
					return
				end

				Module.slider_loop({
					slider = slider,
					flag = self.flag,
					callback = self.callback,

					maximum_value = self.maximum_value,
					minimum_value = self.minimum_value,
				})
			end)
			
			UserInputService.InputEnded:Connect(function(input: InputObject, process: boolean)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Library.slider_drag = false
					Library.save_flags()
				end
			end)
		end

        function Module:create_dropdown()
			local section = self.section == 'left' and left_section or right_section
			local list_size = 6
			local open = false

			local option = Instance.new("TextButton")
			option.Name = "Option"
			option.Active = false
			option.AnchorPoint = Vector2.new(0.5, 0.5)
			option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			option.BackgroundTransparency = 1.000
			option.BorderColor3 = Color3.fromRGB(0, 0, 0)
			option.BorderSizePixel = 0
			option.Position = UDim2.new(0.47283414, 0, 0.309523821, 0)
			option.Selectable = false
			option.Size = UDim2.new(0, 176, 0, 13)
			option.ZIndex = 2
			option.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
			option.TextColor3 = Color3.fromRGB(255, 255, 255)
			option.TextScaled = true
			option.TextSize = 14.000
			option.TextTransparency = 0.500
			option.TextWrapped = true
			option.TextXAlignment = Enum.TextXAlignment.Left

			local dropdown = Instance.new("TextButton")
			dropdown.Parent = section
			dropdown.Name = "Dropdown"
			dropdown.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
			dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
			dropdown.BorderSizePixel = 0
			dropdown.Size = UDim2.new(0, 215, 0, 36)
			dropdown.AutoButtonColor = false
			dropdown.Font = Enum.Font.SourceSans
			dropdown.Text = ""
			dropdown.TextColor3 = Color3.fromRGB(0, 0, 0)
			dropdown.TextSize = 14.000

			local UICorner = Instance.new("UICorner")
			UICorner.CornerRadius = UDim.new(0, 10)
			UICorner.Parent = dropdown

			local UIListLayout = Instance.new("UIListLayout")
			UIListLayout.Parent = dropdown
			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			
			local UIPadding = Instance.new("UIPadding")
			UIPadding.Parent = dropdown
			UIPadding.PaddingTop = UDim.new(0, 6)
			
			local Box = Instance.new("Frame")
			Box.Name = "Box"
			Box.Parent = dropdown
			Box.AnchorPoint = Vector2.new(0.5, 0)
			Box.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
			Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Box.BorderSizePixel = 0
			Box.Position = UDim2.new(0.5, 0, 0.150000006, 0)
			Box.Size = UDim2.new(0, 202, 0, 25)
			Box.ZIndex = 2

			local UICorner_2 = Instance.new("UICorner")
			UICorner_2.CornerRadius = UDim.new(0, 6)
			UICorner_2.Parent = Box

			local Options = Instance.new("Frame")
			Options.Name = "Options"
			Options.Parent = Box
			Options.AnchorPoint = Vector2.new(0.5, 0)
			Options.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
			Options.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Options.BorderSizePixel = 0
			Options.ClipsDescendants = true
			Options.Position = UDim2.new(0.5, 0, 0.75999999, 0)
			Options.Size = UDim2.new(0, 202, 0, 0)

			local UICorner_3 = Instance.new("UICorner")
			UICorner_3.CornerRadius = UDim.new(0, 6)
			UICorner_3.Parent = Options

			local UIPadding_2 = Instance.new("UIPadding")
			UIPadding_2.Parent = Options
			UIPadding_2.PaddingLeft = UDim.new(0, 15)
			UIPadding_2.PaddingTop = UDim.new(0, 10)

			local UIListLayout_2 = Instance.new("UIListLayout")
			UIListLayout_2.Parent = Options
			UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_2.Padding = UDim.new(0, 10)

			local TextLabel = Instance.new("TextLabel")
			TextLabel.Parent = Box
			TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0.430000007, 0, 0.5, 0)
			TextLabel.Size = UDim2.new(0, 151, 0, 13)
			TextLabel.ZIndex = 2
			TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.TextScaled = true
			TextLabel.TextSize = 14.000
			TextLabel.TextWrapped = true
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left

			local Arrow = Instance.new("ImageLabel")
			Arrow.Name = "Arrow"
			Arrow.Parent = Box
			Arrow.Active = true
			Arrow.AnchorPoint = Vector2.new(0.5, 0.5)
			Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Arrow.BackgroundTransparency = 1.000
			Arrow.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Arrow.BorderSizePixel = 0
			Arrow.Position = UDim2.new(0.920000017, 0, 0.5, 0)
			Arrow.Size = UDim2.new(0, 12, 0, 12)
			Arrow.ZIndex = 2
			Arrow.Image = "rbxassetid://17400678941"

			dropdown.Box.TextLabel.Text = self.name

			local Dropdown = {}

			function Dropdown:open()
				dropdown.Box.TextLabel.Text = Library.Flags[self.flag]

				TweenService:Create(dropdown.Box.Options, TweenInfo.new(0.4), {
					Size = UDim2.new(0, 202, 0, list_size)
				}):Play()

				TweenService:Create(dropdown, TweenInfo.new(0.4), {
					Size = UDim2.new(0, 215, 0, 30 + list_size)
				}):Play()

				TweenService:Create(dropdown.Box.Arrow, TweenInfo.new(0.4), {
					Rotation = 180
				}):Play()
			end
			
			function Dropdown:close()
				dropdown.Box.TextLabel.Text = self.name
				TweenService:Create(dropdown.Box.Options, TweenInfo.new(0.4), {
					Size = UDim2.new(0, 202, 0, 0)
				}):Play()

				TweenService:Create(dropdown, TweenInfo.new(0.4), {
					Size = UDim2.new(0, 215, 0, 36)
				}):Play()

				TweenService:Create(dropdown.Box.Arrow, TweenInfo.new(0.4), {
					Rotation = 0
				}):Play()
			end

			function Dropdown:clear()
				for _, object in dropdown.Box.Options:GetChildren() do
					if object.Name ~= 'Option' then
						continue
					end

					object:Destroy()
				end
			end

			function Dropdown:select_option()
				TweenService:Create(self.new_option, TweenInfo.new(0.4), {
					TextTransparency = 0
				}):Play()

				for _, object in dropdown.Box.Options:GetChildren() do
					if object.Name ~= 'Option' then
						continue
					end

					if object.Text == Library.Flags[self.flag] then
						continue
					end

					TweenService:Create(object, TweenInfo.new(0.4), {
						TextTransparency = 0.5
					}):Play()
				end

				dropdown.Box.TextLabel.Text = self.new_option.Text
			end

			function Dropdown:update()
				Dropdown.clear()

				for _, value in self.options do
					list_size += 23

					local new_option = option:Clone()
					new_option.Parent = dropdown.Box.Options
					new_option.Text = value
	
					if value == Library.Flags[self.flag] then
						new_option.TextTransparency = 0
					end
	
					new_option.MouseButton1Click:Connect(function()
						Library.Flags[self.flag] = value
						
						if list_open then
							dropdown.Box.TextLabel.Text = Library.Flags[self.flag]
						end
						self.callback(Library.Flags[self.flag])
						Library.save_flags()

						Dropdown.select_option({
							new_option = new_option,
							flag = self.flag
						})
					end)
				end
			end

			if not Library.Flags[self.flag] then
				Library.Flags[self.flag] = self.option
			end
			
			self.callback(Library.Flags[self.flag])
			Dropdown.update(self)

			dropdown.MouseButton1Click:Connect(function()
				open = not open

				if open then
					Dropdown.open(self)
				else
					Dropdown.close(self)
				end
			end)

			return Dropdown
		end

        function Module:create_textbox()
            local section = self.section == 'left' and left_section or right_section
			local Textbox = {}
            local textbox = Instance.new("TextButton")
			textbox.Name = "TextBox"
			textbox.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
			textbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
			textbox.BorderSizePixel = 0
			textbox.Size = UDim2.new(0, 215, 0, 36)
			textbox.AutoButtonColor = false
			textbox.Font = Enum.Font.SourceSans
			textbox.Text = ""
			textbox.TextColor3 = Color3.fromRGB(0, 0, 0)
			textbox.TextSize = 14.000				
            textbox.Parent = section

			local UICorner = Instance.new("UICorner")
			UICorner.CornerRadius = UDim.new(0, 10)
			UICorner.Parent = textbox

			local UIListLayout = Instance.new("UIListLayout")
			UIListLayout.Parent = textbox
			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local UIPadding = Instance.new("UIPadding")
			UIPadding.Parent = textbox
			UIPadding.PaddingTop = UDim.new(0, 6)
			
			local Box = Instance.new("Frame")
			Box.Name = "Box"
			Box.Parent = textbox
			Box.AnchorPoint = Vector2.new(0.5, 0)
			Box.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
			Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Box.BorderSizePixel = 0
			Box.Position = UDim2.new(0.5, 0, 0.150000006, 0)
			Box.Size = UDim2.new(0, 202, 0, 25)
			Box.ZIndex = 2

			
			local UICorner_2 = Instance.new("UICorner")
			UICorner_2.CornerRadius = UDim.new(0, 6)
			UICorner_2.Parent = Box

			local TextHolder = Instance.new("TextBox")
			TextHolder.Name = "TextHolder"
			TextHolder.Parent = Box
			TextHolder.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
			TextHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextHolder.BorderSizePixel = 0
			TextHolder.Position = UDim2.new(0.0445544571, 0, 0.239999995, 0)
			TextHolder.Size = UDim2.new(0, 182, 0, 13)
			TextHolder.ZIndex = 2
			TextHolder.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
			TextHolder.Text = ""
			TextHolder.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextHolder.TextSize = 14.000
			TextHolder.TextXAlignment = Enum.TextXAlignment.Left
			textbox.Box.TextHolder.PlaceholderText = self.name

			if not Library.Flags[self.flag] then
				Library.Flags[self.flag] = self.value
			else
				textbox.Box.TextHolder.Text = Library.Flags[self.flag]
			end

			self.callback(Library.Flags[self.flag])
			textbox.Box.TextHolder.FocusLost:Connect(function()
				self.callback(textbox.Box.TextHolder.Text)
				Library.save_flags()
			end)

			function Textbox:update(text)
				textbox.Box.TextHolder.Text = text
				self.callback(text)
			end

            return Textbox;
        end
		function Module:create_keybind()
			local section = self.section == 'left' and left_section or right_section
			local keybind = Instance.new("TextButton")
			keybind.Name = "Keybind"
			keybind.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
			keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
			keybind.BorderSizePixel = 0
			keybind.Position = UDim2.new(-0.0186046511, 0, 0.440860212, 0)
			keybind.Size = UDim2.new(0, 215, 0, 37)
			keybind.AutoButtonColor = false
			keybind.Font = Enum.Font.SourceSans
			keybind.Text = ""
			keybind.TextColor3 = Color3.fromRGB(0, 0, 0)
			keybind.TextSize = 14.000
			keybind.Parent = section

			local UICorner = Instance.new("UICorner")

			UICorner.CornerRadius = UDim.new(0, 10)
			UICorner.Parent = keybind
			
			local TextLabel = Instance.new("TextLabel")
			TextLabel.Parent = keybind
			TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0.424475819, 0, 0.5, 0)
			TextLabel.Size = UDim2.new(0, 155, 0, 15)
			TextLabel.ZIndex = 2
			TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.TextScaled = true
			TextLabel.TextSize = 14.000
			TextLabel.TextWrapped = true
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left

			local Box = Instance.new("Frame")
			Box.Name = "Box"
			Box.Parent = keybind
			Box.AnchorPoint = Vector2.new(0.5, 0.5)
			Box.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
			Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Box.BorderSizePixel = 0
			Box.Position = UDim2.new(0.875459313, 0, 0.472972959, 0)
			Box.Size = UDim2.new(0, 27, 0, 21)

			local UICorner_2 = Instance.new("UICorner")
			UICorner_2.CornerRadius = UDim.new(0, 4)
			UICorner_2.Parent = Box

			
			local TextLabel_2 = Instance.new("TextLabel")
			TextLabel_2.Parent = Box
			TextLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel_2.BackgroundTransparency = 1.000
			TextLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel_2.BorderSizePixel = 0
			TextLabel_2.Position = UDim2.new(0.630466938, 0, 0.5, 0)
			TextLabel_2.Size = UDim2.new(0, 29, 0, 15)
			TextLabel_2.ZIndex = 2
			TextLabel_2.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
			TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel_2.TextScaled = true
			TextLabel_2.TextSize = 14.000
			TextLabel_2.TextWrapped = true

			keybind.TextLabel.Text = self.name
			keybind.Box.TextLabel.Text = self.keycode.Name

			if not Library.Flags[self.flag] then
				Library.Flags[self.flag] = self.keycode.Name
			end

			keybind.MouseButton1Click:Connect(function()
				keybind.Box.TextLabel.Text = '...'
				local a,b = UserInputService.InputBegan:Wait();
				if a.KeyCode.Name ~= 'Unknown' then
					keybind.Box.TextLabel.Text = a.KeyCode.Name
					Library.Flags[self.flag] = a.KeyCode.Name
					Library.save_flags()
				end
			end)

			UserInputService.InputBegan:Connect(function(current, pressed)
				if not pressed then
					if current.KeyCode.Name == Library.Flags[self.flag] then
						self.callback(Library.Flags[self.flag])
					end
				end
			end)
		end
        return Module
    end
    return Tab
end

local main = Library.new()
local tab = main.create_tab('Main')

tab.create_title({
	name = 'AutoParry',
	section = 'left'
})
tab.create_toggle({
	name = 'Enabled',
	flag = 'autoparry',

	section = 'left',
	enabled = false,

	callback = function(state: boolean)
		print(`{state}`)
	end
})
tab.create_dropdown({
	name = 'Direction',
	flag = 'Direction',
	section = 'left',

	option = 'Custom',
	options = {'Custom', 'High', 'Random'},

	callback = function(value: string)
		print(value)
	end
})
tab.create_title({
	name = 'Visualizer',
	section = 'right'
})
tab.create_toggle({
	name = 'Enabled',
	flag = 'visualise',

	section = 'right',
	enabled = false,

	callback = function(state: boolean)
	print(`{state}`)
	end
})
tab.create_title({
	name = 'HitSound',
	section = 'left'
})
tab.create_toggle({
	name = 'Enabled',
	flag = 'hitsound',

	section = 'left',
	enabled = false,

	callback = function(state: boolean)
		print(`{state}`)
	end
})
tab.create_dropdown({
	name = 'Sound',
	flag = 'soundpick',
	section = 'left',

	option = 'Neverlose',
	options = {'Click', 'Neverlose', 'Bonk'},

	callback = function(value: string)
		print(value)
	end
})
tab.create_title({
	name = 'AI',
	section = 'right'
})
tab.create_toggle({
	name = 'Enabled',
	flag = 'AI',

	section = 'right',
	enabled = false,

	callback = function(state: boolean)
    print(`{state}`)
	end
})
tab.create_title({
	name = 'Spin',
	section = 'right'
})
tab.create_toggle({
	name = 'Enabled',
	flag = 'spin',

	section = 'right',
	enabled = false,

	callback = function(state: boolean)
		print(`{state}`)
	end
})
tab.create_slider({
	name = 'Speed',
	flag = 'spinspeed',

	section = 'right',

	value = 25,
	minimum_value = 0,
	maximum_value = 100,

	callback = function(value: number)
		print(value)
	end
})
tab.create_title({
	name = 'Auto Open Crate',
	section = 'left'
})
tab.create_toggle({
	name = 'Enabled',
	flag = 'swordbox',

	section = 'left',
	enabled = false,

	callback = function(state: boolean)
		print(`{state}`)
	end
})
tab.create_dropdown({
	name = 'Crate',
	flag = 'selectbox',
	section = 'left',

	option = 'Sword Crate',
	options = {'Explosion Crate', 'Sword Crate'},

	callback = function(value: string)
		print(value)
	end
})
tab.create_title({
	name = 'Auto Rewards',
	section = 'right'
})
tab.create_toggle({
	name = 'Enabled',
	flag = 'rewarde',

	section = 'right',
	enabled = false,

	callback = function(state: boolean)
		print(`{state}`)
	end
})
tab.create_dropdown({
	name = 'Rewards',
	flag = 'selectrewards',
	section = 'right',

	option = 'Playtime Rewards',
	options = {'Playtime Rewards', 'Clan Rewards', 'Login Rewards', 'All'},

	callback = function(value: string)
	    print(value)
	end
})
return library