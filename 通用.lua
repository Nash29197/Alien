local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()

local NebulaIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/Loader.lua"))() --loads modules that allow 100% support for Lucide and Material Icons)

local Window = Starlight:CreateWindow({
    Name = "N++ Hub",
    Subtitle = "v1.0",
    Icon = 123456789, -- Replace with your icon ID

    LoadingSettings = {
        Title = "N++ Hub",
        Subtitle = "by 三眼怪",
    },

    ConfigurationSettings = { -- Not Implemented Yet
        FolderName = "N++ Hub"
    },
})

local Window = Starlight:CreateWindow({
    Name = "N++ Hub",
    Subtitle = "v1.0",
    Icon = 123456789, -- Replace with your icon ID

    LoadingSettings = {
        Title = "N++ Hub",
        Subtitle = "by 三眼怪",
    },

    ConfigurationSettings = { -- Not Implemented Yet
        FolderName = "N++ Hub"
    },
})

local TabSection = Window:CreateTabSection("Tab Section")

local Tab = TabSection:CreateTab({
    Name = "Tab",
    Icon = NebulaIcons:GetIcon('view_in_ar', 'Material'), --[[ Icon, Source (Lucide/Material) NOTE: For Lucide, replace spaces with dash eg alarm-smoke and Material with underscore eg view_in_ar]]
    Columns = 2,
}, "INDEX") --last param will be the for config

local Groupbox = Tab:CreateGroupbox({
    Name = "Groupbox",
    Column = 1,
}, "INDEX")

local Button = Groupbox:CreateButton({
    Name = "Cool Button",
    Icon = NebulaIcons:GetIcon('check', 'Material'),
    Tooltip = "This is A Tooltip!",
    Style = 1,
    Callback = function()
         print("hi")
    end,
}, "INDEX")

local Button = Groupbox:CreateButton({
    Name = "Regular Button",
    Icon = NebulaIcons:GetIcon('check', 'Material'),
    Tooltip = "This is A Tooltip!",
    Style = 2,
    Callback = function()
         print("hi from Regular Button!")
    end,
}, "INDEX")

local Toggle = Groupbox:CreateToggle({
    Name = "Toggle",
    CurrentValue = false,
    Style = 1,
    Callback = function(Value)
        print("ToggleValue =", Value)
    end,
}, "INDEX")

local Checkbox = Groupbox:CreateToggle({
    Name = "Checkbox",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        print("Checkbox =", Value)
    end,
}, "INDEX")

local Slider = Groupbox:CreateSlider({
    Name = "Slider",
    Icon = NebulaIcons:GetIcon('bar-chart', 'Lucide'),
    Range = {0, 100},
    Increment = 1,
    Callback = function(v)
        print("Slider Val =", v)
    end,
}, "INDEX")


local Input = Groupbox:CreateInput({
    Name = "Dynamic Input",
    Icon = NebulaIcons:GetIcon('text-cursor-input', 'Lucide'),
    CurrentValue = "",
    PlaceholderText = "Placeholder Text",
    Callback = function(Text)
            print("Current Text =", Text)
    end,
}, "INDEX")


local Label = Groupbox:CreateButton({
    Name = "Label"
}, "INDEX")

local Paragraph = Groupbox:CreateParagraph({
    Name = "Paragraph",
    Content = [[Content of your paragraph goes here. Lorem Ipsum Dolor Sit Amet. Lorem Ipsum Dolor Sit Amet. Lorem Ipsum Dolor Sit Amet. Lorem Ipsum Dolor Sit Amet. Lorem. Ipsum Dolor Sit Amet. Lorem Ipsum Dolor Sit Amet. Lorem Ipsum Dolor Sit Amet. 

    Also Supports Multi Lining
    ]]

}, "INDEX")

local KeyLabel = Groupbox:CreateButton({
    Name = "Keybind"
}, "INDEX")
local Bind = KeyLabel:AddBind({
    HoldToInteract = false,
    CurrentValue = "Q",
    Callback = function(v)
    print("Keybind =", v)
    end,
}, "INDEX")


local DLabel = Groupbox:CreateButton({
    Name = "Regular Dropdown"
}, "INDEX")
local Dropdown = DLabel:AddDropdown({
    Options = {"Option 1", "Option 2"},
    CurrentOptions = {"Option 1"},
    Callback = function(Options)
        print("Option =", Options)
    end,
}, "INDEX")


local PLabel = Groupbox:CreateButton({
    Name = "Player Dropdown"
}, "INDEX")

local PlayersDropdown = PLabel:CreateDropdown({
    Options = {},
    CurrentOptions = {},
    Special = 1, -- Optional flag if supported by the UI library
    Callback = function(Selected)
        print("Selected Player:", Selected)
    end,
}, "INDEX")


local TLabel = Groupbox:CreateButton({
    Name = "Team Dropdown"
}, "INDEX")

local Dropdown = TLabel:AddDropdown({
    Options = {},
    CurrentOptions = {},
    Callback = function(v)
        print("Team Selected:", v)
    end,
}, "INDEX")