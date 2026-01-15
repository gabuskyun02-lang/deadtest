--[[
    WindUI Enhanced - Example Usage
    
    This demonstrates how to use the Enhanced wrapper
    to create the UI structure shown in screenshot
]]

-- ============================================================
-- STEP 1: Load WindUI Original
-- ============================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ============================================================
-- STEP 2: Load Enhanced Wrapper
-- ============================================================
local Enhanced = loadstring(game:HttpGet("https://raw.githubusercontent.com/gabuskyun02-lang/deadtest/refs/heads/main/WindUI_Enhanced.lua"))()

-- ============================================================
-- STEP 3: Initialize Wrapper
-- ============================================================
Enhanced:Initialize(WindUI)

-- ============================================================
-- STEP 4: Create Window with Enhanced Features
-- ============================================================
local Window = Enhanced:CreateWindow({
    Title = "wings",
    Author = "Blade Ball",
    Folder = "WingsHub",
    Size = UDim2.fromOffset(880, 520),
    Theme = "Glassmorphism",  -- Enable glass morphism
    SideBarWidth = 220
})

-- ============================================================
-- EXAMPLE: Create Nested Structure like Screenshot
-- ============================================================

-- Create GENERAL Section (collapsible)
local GeneralSection = Window:CreateSection({
    Title = "GENERAL",
    Icon = "home",
    Collapsible = true,
    Opened = true
})

-- Add tabs to GENERAL section
local GeneralTab = GeneralSection:AddTab({
    Title = "General",
    Icon = "settings"
})

local AutomatizationTab = GeneralSection:AddTab({
    Title = "Automatization",
    Icon = "bot"
})

local PlayerTab = GeneralSection:AddTab({
    Title = "Player",
    Icon = "user"
})

-- Create MISCELLANEOUS Section
local MiscSection = Window:CreateSection({
    Title = "MISCELLANEOUS",
    Icon = "star",
    Collapsible = true,
    Opened = false
})

local MiscTab = MiscSection:AddTab({
    Title = "Miscellaneous",
    Icon = "package"
})

local SettingsTab = MiscSection:AddTab({
    Title = "Settings",
    Icon = "sliders"
})

-- ============================================================
-- EXAMPLE: Create Cards in Tabs (like screenshot)
-- ============================================================

-- AUTO-PARRY Card (example from screenshot)
local AutoParryCard = GeneralTab:CreateCard({
    Title = "AUTO-PARRY",
    Description = "Automatic parry system",
    Glass = true
})

AutoParryCard:Toggle({
    Title = "Enable Auto-Parry",
    Value = false,
    Callback = function(state)
        print("Auto-Parry:", state)
    end
})

AutoParryCard:Dropdown({
    Title = "Target Selection",
    List = {"Closest to Player", "Closest to Ball", "Random"},
    Default = "Closest to Player",
    Callback = function(value)
        print("Target Selection:", value)
    end
})

AutoParryCard:Dropdown({
    Title = "Parry Direction",
    List = {"Straight", "Curved", "Smart"},
    Default = "Straight",
    Callback = function(value)
        print("Parry Direction:", value)
    end
})

-- AI MODE Card
local AIModeCard = GeneralTab:CreateCard({
    Title = "AI MODE",
    Glass = true
})

AIModeCard:Toggle({
    Title = "Enable AI Mode",
    Value = false,
    Callback = function(state)
        print("AI Mode:", state)
    end
})

AIModeCard:Slider({
    Title = "Stay Distance",
    Step = 1,
    Value = { Min = 5, Max = 50, Default = 15 },
    Callback = function(value)
        print("Stay Distance:", value .. "studs")
    end
})

AIModeCard:Slider({
    Title = "Wander Amount",
    Step = 1,
    Value = { Min = 1, Max = 20, Default = 8 },
    Callback = function(value)
        print("Wander Amount:", value .. "studs")
    end
})

-- AUTO-SPAM Card
local AutoSpamCard = GeneralTab:CreateCard({
    Title = "AUTO-SPAM",
    Glass = true
})

AutoSpamCard:Toggle({
    Title = "Enable Manual Spam",
    Value = false,
    Callback = function(state)
        print("Manual Spam:", state)
    end
})

AutoSpamCard:Keybind({
    Title = "Manual Spam",
    Default = Enum.KeyCode.RightShift,
    Callback = function(value)
        print("Spam keybind:", value.Name)
    end
})

AutoSpamCard:Dropdown({
    Title = "Mode",
    List = {"Hold", "Toggle", "Press"},
    Default = "Hold",
    Callback = function(value)
        print("Spam Mode:", value)
    end
})

AutoSpamCard:Slider({
    Title = "Delay",
    Step = 10,
    Value = { Min = 0, Max = 500, Default = 100 },
    Callback = function(value)
        print("Delay:", value .. "ms")
    end
})

-- MISCELLANEOUS Card
local MiscCard = MiscTab:CreateCard({
    Title = "MISCELLANEOUS",
    Glass = true
})

MiscCard:Toggle({
    Title = "Auto-Claim",
    Value = false,
    Callback = function(state)
        print("Auto-Claim:", state)
    end
})

MiscCard:Toggle({
    Title = "Auto Wheel Spin",
    Value = false,
    Callback = function(state)
        print("Auto Wheel Spin:", state)
    end
})

MiscCard:Button({
    Title = "Claim all Codes",
    Callback = function()
        print("Claiming all codes...")
    end
})

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================
Window:Notify({
    Title = "WindUI Enhanced",
    Content = "UI loaded successfully with enhanced features!",
    Duration = 5
})

print("[Example] WindUI Enhanced loaded successfully!")
print("[Example] Structure: 2 sections, 5 tabs, 4 cards")
