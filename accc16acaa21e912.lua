-- Wings UI reconstruction using AestheticUI

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function resolveAestheticUI()
    local env = (getgenv and getgenv()) or _G
    if env and env.AestheticUI then
        return env.AestheticUI
    end
    if _G and _G.AestheticUI then
        return _G.AestheticUI
    end
    if loadstring and game and game.HttpGet then
        local ok, lib = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/gabuskyun02-lang/deadtest/refs/heads/main/AestheticUI.lua"))()
        end)
        if ok and lib then
            return lib
        end
    end
    return nil
end

local AestheticUI = resolveAestheticUI()
if not AestheticUI then
    warn("AestheticUI not found. Load AestheticUI.lua or set _G.AestheticUI.")
    return
end

AestheticUI:SetTheme({
    Background = Color3.fromRGB(12, 18, 26),
    BackgroundSecondary = Color3.fromRGB(16, 22, 30),
    Surface = Color3.fromRGB(18, 26, 36),
    SurfaceAlt = Color3.fromRGB(21, 30, 42),
    Accent = Color3.fromRGB(68, 128, 255),
    AccentGlow = Color3.fromRGB(110, 170, 255),
    AccentSoft = Color3.fromRGB(52, 100, 210),
    Text = Color3.fromRGB(230, 235, 245),
    TextDim = Color3.fromRGB(165, 175, 190),
})

local Window = AestheticUI:CreateWindow({
    Title = "wings",
    Size = UDim2.new(0, 860, 0, 520),
})

-- Subtitle under title
do
    local theme = AestheticUI:GetTheme()
    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.new(0, 18, 0, 22)
    subtitle.Size = UDim2.new(0, 140, 0, 12)
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "Blade Ball"
    subtitle.TextColor3 = theme.TextDim
    subtitle.TextSize = 10
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = Window.MainFrame
end

local function addPresetSection(tab)
    local presets = AestheticUI:CreateSection(tab, {
        Name = "Presets",
        Actions = {
            { Text = "Save", Callback = function() end },
            { Text = "Load", Callback = function() end },
        },
    })
    AestheticUI:CreateDropdown(presets, {
        Text = "Preset",
        Options = { "None", "Default", "Legit", "Aggressive" },
        Default = "None",
    })
    return presets
end

local function createTwoColumns(tab)
    local page = tab.Page
    local columns = Instance.new("Frame")
    columns.Name = "Columns"
    columns.BackgroundTransparency = 1
    columns.Size = UDim2.new(1, 0, 0, 0)
    columns.AutomaticSize = Enum.AutomaticSize.Y
    columns.LayoutOrder = 2
    columns.Parent = page

    local columnsLayout = Instance.new("UIListLayout")
    columnsLayout.FillDirection = Enum.FillDirection.Horizontal
    columnsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    columnsLayout.Padding = UDim.new(0, 12)
    columnsLayout.Parent = columns

    local left = Instance.new("Frame")
    left.Name = "LeftColumn"
    left.BackgroundTransparency = 1
    left.Size = UDim2.new(0.5, -6, 0, 0)
    left.AutomaticSize = Enum.AutomaticSize.Y
    left.Parent = columns

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 12)
    leftLayout.Parent = left

    local right = Instance.new("Frame")
    right.Name = "RightColumn"
    right.BackgroundTransparency = 1
    right.Size = UDim2.new(0.5, -6, 0, 0)
    right.AutomaticSize = Enum.AutomaticSize.Y
    right.Parent = columns

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Padding = UDim.new(0, 12)
    rightLayout.Parent = right

    return { Left = { Page = left }, Right = { Page = right } }
end

-- Tabs
local GeneralTab = AestheticUI:CreateTab(Window, { Name = "General" })
local AutomationTab = AestheticUI:CreateTab(Window, { Name = "Automatization" })
local PlayerTab = AestheticUI:CreateTab(Window, { Name = "Player" })
local MiscTab = AestheticUI:CreateTab(Window, { Name = "Miscellaneous" })
local SettingsTab = AestheticUI:CreateTab(Window, { Name = "Settings" })

-- General
addPresetSection(GeneralTab)
local GeneralCols = createTwoColumns(GeneralTab)

local AutoParry = AestheticUI:CreateSection(GeneralCols.Left, "Auto-Parry")
AestheticUI:CreateToggle(AutoParry, { Text = "Enable Auto-Parry", Default = false })
AestheticUI:CreateDropdown(AutoParry, {
    Text = "Target Selection",
    Options = { "Closest to Player", "Closest to Cursor", "Random" },
    Default = "Closest to Player",
})
AestheticUI:CreateDropdown(AutoParry, {
    Text = "Parry Direction",
    Options = { "Straight", "Randomized", "Adaptive" },
    Default = "Straight",
})
AestheticUI:CreateToggle(AutoParry, { Text = "Allow Prediction", Default = false })
AestheticUI:CreateToggle(AutoParry, { Text = "On-Parry Visuals", Default = false })

local AutoSpam = AestheticUI:CreateSection(GeneralCols.Left, "Auto-Spam")
AestheticUI:CreateToggle(AutoSpam, { Text = "Enable Manual Spam", Default = false })
AestheticUI:CreateKeybind(AutoSpam, { Text = "Manual Spam", Default = Enum.KeyCode.RightShift })
AestheticUI:CreateDropdown(AutoSpam, {
    Text = "Mode",
    Options = { "Hold", "Toggle" },
    Default = "Hold",
})
AestheticUI:CreateSlider(AutoSpam, { Text = "Delay", Min = 0, Max = 300, Default = 100, Suffix = "ms" })

local AIMode = AestheticUI:CreateSection(GeneralCols.Right, "AI Mode")
AestheticUI:CreateToggle(AIMode, { Text = "Enable AI Mode", Default = false })
AestheticUI:CreateSlider(AIMode, { Text = "Stay Distance", Min = 5, Max = 30, Default = 15, Suffix = " studs" })
AestheticUI:CreateSlider(AIMode, { Text = "Wander Amount", Min = 3, Max = 20, Default = 8, Suffix = " studs" })
AestheticUI:CreateToggle(AIMode, { Text = "Dynamic Distance", Default = false })
AestheticUI:CreateToggle(AIMode, { Text = "Visualise Path", Default = false })

local GeneralMisc = AestheticUI:CreateSection(GeneralCols.Right, "Miscellaneous")
AestheticUI:CreateToggle(GeneralMisc, { Text = "Auto-Claim", Default = false })
AestheticUI:CreateToggle(GeneralMisc, { Text = "Auto Wheel Spin", Default = false })
AestheticUI:CreateDropdown(GeneralMisc, {
    Text = "Auto-Crate",
    Options = { "None", "Common", "Rare", "Legendary" },
    Default = "None",
})
AestheticUI:CreateButton(GeneralMisc, { Text = "Claim all Codes", Callback = function() end })

-- Automatization
addPresetSection(AutomationTab)
local AutoCols = createTwoColumns(AutomationTab)

local AutoTargets = AestheticUI:CreateSection(AutoCols.Left, "Targeting")
AestheticUI:CreateToggle(AutoTargets, { Text = "Auto Target", Default = false })
AestheticUI:CreateDropdown(AutoTargets, {
    Text = "Priority",
    Options = { "Closest", "Lowest HP", "Highest Threat" },
    Default = "Closest",
})
AestheticUI:CreateToggle(AutoTargets, { Text = "Ignore Friends", Default = true })

local AutoDefense = AestheticUI:CreateSection(AutoCols.Left, "Defense")
AestheticUI:CreateToggle(AutoDefense, { Text = "Auto Block", Default = false })
AestheticUI:CreateToggle(AutoDefense, { Text = "Perfect Timing", Default = true })
AestheticUI:CreateSlider(AutoDefense, { Text = "Reaction Window", Min = 50, Max = 250, Default = 120, Suffix = "ms" })

local AutoOffense = AestheticUI:CreateSection(AutoCols.Right, "Offense")
AestheticUI:CreateToggle(AutoOffense, { Text = "Auto Attack", Default = false })
AestheticUI:CreateDropdown(AutoOffense, {
    Text = "Attack Style",
    Options = { "Balanced", "Aggressive", "Defensive" },
    Default = "Balanced",
})
AestheticUI:CreateSlider(AutoOffense, { Text = "Combo Delay", Min = 0, Max = 250, Default = 60, Suffix = "ms" })

local AutoUtility = AestheticUI:CreateSection(AutoCols.Right, "Utility")
AestheticUI:CreateToggle(AutoUtility, { Text = "Auto Join Match", Default = false })
AestheticUI:CreateToggle(AutoUtility, { Text = "Auto Rejoin", Default = false })
AestheticUI:CreateDropdown(AutoUtility, {
    Text = "Queue",
    Options = { "Public", "Ranked", "Custom" },
    Default = "Public",
})

-- Player
addPresetSection(PlayerTab)
local PlayerCols = createTwoColumns(PlayerTab)

local Character = AestheticUI:CreateSection(PlayerCols.Left, "Character")
AestheticUI:CreateToggle(Character, { Text = "Spin-Bot", Default = false })
AestheticUI:CreateToggle(Character, { Text = "WalkSpeed", Default = false })
AestheticUI:CreateSlider(Character, { Text = "Speed", Min = 16, Max = 40, Default = 20, Suffix = " studs" })

local SkinChanger = AestheticUI:CreateSection(PlayerCols.Left, "Skin Changer")
AestheticUI:CreateDropdown(SkinChanger, {
    Text = "Sword Changer",
    Options = { "Base Sword", "Azure", "Crimson", "Void" },
    Default = "Base Sword",
})

local Desync = AestheticUI:CreateSection(PlayerCols.Right, "Desync")
AestheticUI:CreateToggle(Desync, { Text = "Enable Desync", Default = false })
AestheticUI:CreateSlider(Desync, { Text = "Desync Radius", Min = 5, Max = 100, Default = 50 })
AestheticUI:CreateDropdown(Desync, {
    Text = "Desync Mode",
    Options = { "Immortality", "Ghost", "Safe" },
    Default = "Immortality",
})
AestheticUI:CreateToggle(Desync, { Text = "Visualise Desync", Default = false })

-- Miscellaneous
addPresetSection(MiscTab)
local MiscCols = createTwoColumns(MiscTab)

local AFK = AestheticUI:CreateSection(MiscCols.Left, "AFK")
AestheticUI:CreateToggle(AFK, { Text = "Anti-AFK", Default = false })
AestheticUI:CreateToggle(AFK, { Text = "Anti-Mod", Default = false })
AestheticUI:CreateToggle(AFK, { Text = "Auto-Inject", Default = false })

local Sounds = AestheticUI:CreateSection(MiscCols.Right, "Sounds")
AestheticUI:CreateToggle(Sounds, { Text = "Enable Sounds", Default = false })
AestheticUI:CreateDropdown(Sounds, {
    Text = "Parry Attempt",
    Options = { "Don't Change", "Soft", "Sharp" },
    Default = "Don't Change",
})
AestheticUI:CreateDropdown(Sounds, {
    Text = "Parried",
    Options = { "Don't Change", "Echo", "Muted" },
    Default = "Don't Change",
})

local ServerHop = AestheticUI:CreateSection(MiscCols.Left, "Server-Hop")
AestheticUI:CreateButton(ServerHop, { Text = "Server-Hop", Callback = function() end })
AestheticUI:CreateButton(ServerHop, { Text = "Server-Hop (Low Players)", Callback = function() end })
AestheticUI:CreateToggle(ServerHop, { Text = "Auto Server-Hop", Default = false })

-- Settings
addPresetSection(SettingsTab)
local SettingsCols = createTwoColumns(SettingsTab)

local ThemeSection = AestheticUI:CreateSection(SettingsCols.Left, "Theme")
AestheticUI:CreateToggle(ThemeSection, { Text = "Outline", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Outline 2", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Background", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Logo Background", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Background 2", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Section Background", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Page Background", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Toggle", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Element", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Text", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Text 2", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Liner", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Hover Element", Default = true })
AestheticUI:CreateToggle(ThemeSection, { Text = "Accent", Default = true })

local SettingsSection = AestheticUI:CreateSection(SettingsCols.Right, "Settings")
AestheticUI:CreateButton(SettingsSection, { Text = "Unload", Callback = function() end })
AestheticUI:CreateKeybind(SettingsSection, { Text = "Menu keybind", Default = Enum.KeyCode.RightControl })
AestheticUI:CreateDropdown(SettingsSection, {
    Text = "Mode",
    Options = { "Toggle", "Hold" },
    Default = "Toggle",
})
AestheticUI:CreateSlider(SettingsSection, { Text = "DPI Scale", Min = 50, Max = 150, Default = 100, Suffix = "%" })
AestheticUI:CreateSlider(SettingsSection, { Text = "Fade time", Min = 0, Max = 1, Default = 0.2 })
AestheticUI:CreateSlider(SettingsSection, { Text = "Tween speed", Min = 0.1, Max = 1, Default = 0.3 })
AestheticUI:CreateDropdown(SettingsSection, {
    Text = "UI Tween style",
    Options = { "Quad", "Quart", "Sine", "Back" },
    Default = "Quad",
})
AestheticUI:CreateToggle(SettingsSection, { Text = "Dropdown Search", Default = true })
AestheticUI:CreateToggle(SettingsSection, { Text = "Watermark", Default = false })
AestheticUI:CreateToggle(SettingsSection, { Text = "Keybind List", Default = false })
AestheticUI:CreateDropdown(SettingsSection, {
    Text = "Tween direction",
    Options = { "Out", "In", "InOut" },
    Default = "Out",
})

-- Sidebar user card
do
    local theme = AestheticUI:GetTheme()
    local userCard = Instance.new("Frame")
    userCard.Name = "UserCard"
    userCard.BackgroundColor3 = theme.SurfaceAlt
    userCard.BackgroundTransparency = 0.2
    userCard.Size = UDim2.new(1, -16, 0, 48)
    userCard.Position = UDim2.new(0, 8, 1, -58)
    userCard.AnchorPoint = Vector2.new(0, 1)
    userCard.Parent = Window.TabContainer

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = userCard

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = theme.BorderSoft or Color3.fromRGB(40, 50, 64)
    cardStroke.Thickness = 1
    cardStroke.Parent = userCard

    local avatar = Instance.new("ImageLabel")
    avatar.BackgroundTransparency = 1
    avatar.Size = UDim2.new(0, 32, 0, 32)
    avatar.Position = UDim2.new(0, 8, 0.5, -16)
    avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    avatar.Parent = userCard

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position = UDim2.new(0, 48, 0, 8)
    nameLabel.Size = UDim2.new(1, -56, 0, 16)
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.Text = LocalPlayer.DisplayName
    nameLabel.TextColor3 = theme.Text
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = userCard

    local subLabel = Instance.new("TextLabel")
    subLabel.BackgroundTransparency = 1
    subLabel.Position = UDim2.new(0, 48, 0, 24)
    subLabel.Size = UDim2.new(1, -56, 0, 14)
    subLabel.Font = Enum.Font.Gotham
    subLabel.Text = "Lifetime | v0.0.0.7"
    subLabel.TextColor3 = theme.TextDim
    subLabel.TextSize = 10
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Parent = userCard
end
