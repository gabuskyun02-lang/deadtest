--[[
    WindUI Enhanced - Full Structure Test
    Tests both sections AND cards
]]

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Load Enhanced
local Enhanced = loadstring(game:HttpGet("https://raw.githubusercontent.com/gabuskyun02-lang/deadtest/refs/heads/main/WindUI_Enhanced.lua"))()

-- Initialize
Enhanced:Initialize(WindUI)

-- Create window
local Window = Enhanced:CreateWindow({
    Title = "FULL TEST",
    Author = "Testing Sections + Cards",
    Size = UDim2.fromOffset(880, 520)
})

print("=== Testing Nested Sections ===")

-- Create GENERAL Section
local GeneralSection = Window:CreateSection({
    Title = "GENERAL",
    Icon = "home",
    Opened = true
})

-- Add tabs to section
local GeneralTab = GeneralSection:AddTab({
    Title = "General",
    Icon = "settings"
})

-- Create cards in tab
local CombatCard = GeneralTab:CreateCard({
    Title = "COMBAT FEATURES"
})

CombatCard:Toggle({
    Title = "Kill Aura",
    Value = false
})

CombatCard:Slider({
    Title = "Attack Range",
    Value = { Min = 5, Max = 50, Default = 15 }
})

-- Another tab in same section
local AutoTab = GeneralSection:AddTab({
    Title = "Automatization",
    Icon = "bot"
})

local FarmCard = AutoTab:CreateCard({
    Title = "AUTO-FARM"
})

FarmCard:Toggle({
    Title = "Enable Auto-Farm",
    Value = false
})

-- Create MISC Section
local MiscSection = Window:CreateSection({
    Title = "MISCELLANEOUS",
    Icon = "star",
    Opened = false
})

local MiscTab = MiscSection:AddTab({
    Title = "Miscellaneous",
    Icon = "package"
})

local UtilCard = MiscTab:CreateCard({
    Title = "UTILITIES"
})

UtilCard:Button({
    Title = "Claim Codes",
    Callback = function()
        print("Claimed!")
    end
})

Window:Notify({
    Title = "Test Complete",
    Content = "Sections + Cards tested!",
    Duration = 5
})

print("=== Structure Created ===")
print("- 2 Sections (GENERAL, MISCELLANEOUS)")
print("- 3 Tabs (General, Automatization, Miscellaneous)")
print("- 3 Cards with various elements")
