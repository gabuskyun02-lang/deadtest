--[[
    WindUI Enhanced - Simple Test
    Tests card functionality with native Tab:Section
]]

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Load Enhanced
local Enhanced = loadstring(game:HttpGet("https://raw.githubusercontent.com/gabuskyun02-lang/deadtest/refs/heads/main/WindUI_Enhanced.lua"))()

-- Initialize
Enhanced:Initialize(WindUI)

-- Create window
local Window = Enhanced:CreateWindow({
    Title = "Card Test",
    Size = UDim2.fromOffset(880, 520)
})

-- Create a simple tab (flat structure for now)
local TestTab = Window:Tab({
    Title = "Test Tab",
    Icon = "star"
})

-- Test 1: Create card with Toggle
local Card1 = TestTab:CreateCard({
    Title = "COMBAT FEATURES",
    Description = "All combat-related settings",
    Glass = true
})

Card1:Toggle({
    Title = "Enable Kill Aura",
    Desc = "Automatically attack nearby enemies",
    Value = false,
    Callback = function(state)
        print("Kill Aura:", state)
    end
})

Card1:Slider({
    Title = "Attack Speed",
    Step = 1,
    Value = { Min = 1, Max = 10, Default = 5 },
    Callback = function(val)
        print("Attack Speed:", val)
    end
})

-- Test 2: Another card
local Card2 = TestTab:CreateCard({
    Title = "MOVEMENT",
    Glass = true
})

Card2:Toggle({
    Title = "Speed Boost",
    Value = false
})

Card2:Slider({
    Title = "WalkSpeed",
    Value = { Min = 16, Max = 200, Default = 16 }
})

-- Test 3: Card with dropdown and button
local Card3 = TestTab:CreateCard({
    Title = "UTILITIES"
})

Card3:Dropdown({
    Title = "Mode",
    List = {"Mode 1", "Mode 2", "Mode 3"},
    Default = "Mode 1"
})

Card3:Button({
    Title = "Execute Action",
    Callback = function()
        print("Button clicked!")
    end
})

Window:Notify({
    Title = "Test Complete",
    Content = "3 cards created successfully!",
    Duration = 5
})

print("[Test] Cards using Tab:Section should now be visible!")
