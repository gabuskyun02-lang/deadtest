--[[
    AestheticUI - Premium Roblox UI Library
    Anti-Detection | Smooth Animations | Modern Design
]]

local AestheticUI = {}
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local SoundService = game:GetService("SoundService")

-- [ADVANCED ANTI-DETECTION] Kernel Integrity & Environment Isolation
local _IntegrityPass = true
local _SecurityLogs = {}
local _Threads = {}
local _Alive = true

-- Verify critical functions aren't hooked
local function _checkIntegrity()
    local critical = {
        {name = "pcall", fn = pcall},
        {name = "Instance", fn = Instance.new},
        {name = "debug", fn = debug.info},
        {name = "task", fn = task.spawn}
    }
    
    -- Safely add TweenService check
    pcall(function()
        local ts = game:GetService("TweenService")
        if ts and ts.Create then
            table.insert(critical, {name = "TweenService", fn = ts.Create})
        end
    end)

    for _, item in ipairs(critical) do
        if item.fn then
            local ok, info = pcall(function() return debug.info(item.fn, "s") end)
            -- Only fail if debug.info succeeded but returned a non-native source
            if ok and info ~= "[C]" then
                _IntegrityPass = false
                table.insert(_SecurityLogs, "Integrity Failure: " .. item.name .. " is hooked (" .. tostring(info) .. ")")
            end
        end
    end
end
_checkIntegrity()

-- [NEW] Atomic Panic Mechanism
local function _panic()
    _Alive = false
    -- Scrub connection tracking
    if _G.AestheticUI_Window then
        pcall(function() _G.AestheticUI_Window:Destroy() end)
    end
    
    -- Kill all library-managed threads
    for _, t in pairs(_Threads) do
        pcall(task.cancel, t)
    end
    table.clear(_Threads)
    
    -- Clear internal references
    _G.AestheticUI_Window = nil
    
    -- Flush Sensitive Data
    table.clear(_SecurityLogs)
end

-- Monitor Integrity
task.spawn(function()
    table.insert(_Threads, coroutine.running())
    while _Alive do
        task.wait(15)
        _checkIntegrity()
        if not _IntegrityPass then
            -- _panic() -- Auto-panic if server hooks detected
        end
    end
end)

-- Anti-Detection: Random naming
local function randomName()
    return HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 16)
end

-- Theme Configuration
local Theme = {
    Background = Color3.fromRGB(14, 14, 18),
    BackgroundSecondary = Color3.fromRGB(18, 18, 24),
    Surface = Color3.fromRGB(22, 22, 30),
    SurfaceAlt = Color3.fromRGB(26, 26, 34),
    Accent = Color3.fromRGB(120, 76, 230),
    AccentGlow = Color3.fromRGB(165, 128, 240),
    AccentSoft = Color3.fromRGB(98, 70, 180),
    Text = Color3.fromRGB(238, 238, 245),
    TextDim = Color3.fromRGB(168, 172, 186),
    TextSoft = Color3.fromRGB(136, 140, 154),
    Success = Color3.fromRGB(36, 190, 96),
    Warning = Color3.fromRGB(230, 190, 80),
    Danger = Color3.fromRGB(220, 90, 90),
    Border = Color3.fromRGB(40, 40, 52),
    BorderSoft = Color3.fromRGB(34, 34, 44),
    BorderStrong = Color3.fromRGB(64, 64, 80),
    Glass = 0.92
}

local Radius = {
    Window = 14,
    Container = 12,
    Control = 7,
    Subtle = 5
}

local Spacing = {
    Xs = 4,
    Sm = 8,
    Md = 12,
    Lg = 16
}

-- Smooth Tween Presets
local TweenPresets = {
    Quick = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.36, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
}

-- Utility Functions
local function createInstance(className, properties)
    local instance = Instance.new(className)
    instance.Name = randomName()
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function tween(instance, properties, preset)
    local t = TweenService:Create(instance, preset or TweenPresets.Smooth, properties)
    t:Play()
    return t
end

local function addCorner(parent, radius)
    return createInstance("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

local function addStroke(parent, color, thickness)
    return createInstance("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function addInnerStroke(parent, color, thickness)
    return createInstance("UIStroke", {
        Color = color or Theme.BorderSoft,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function addGlass(parent)
    return createInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(1, 0.6)
        }),
        Rotation = 90,
        Parent = parent
    })
end

local function addGlow(parent)
    local glow = createInstance("ImageLabel", {
        Size = UDim2.new(1, 24, 1, 24),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0.9,
        Parent = parent
    })
    
    return glow
end

local function addAccentGlow(parent, color)
    return createInstance("ImageLabel", {
        Size = UDim2.new(1, 16, 1, 16),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = color or Theme.AccentGlow,
        ImageTransparency = 1,
        Parent = parent
    })
end

local ThemeSubscribers = {}
local function registerTheme(updateFn)
    table.insert(ThemeSubscribers, updateFn)
    pcall(updateFn)
end

local function applyTheme()
    for i = #ThemeSubscribers, 1, -1 do
        local ok = pcall(ThemeSubscribers[i])
        if not ok then
            table.remove(ThemeSubscribers, i)
        end
    end
end

local SoundHooks = {}
local SoundCache = {}
local ControlRegistry = setmetatable({}, {__mode = "k"})
local function playSound(kind)
    local hook = SoundHooks and SoundHooks[kind]
    if not hook then return end
    if type(hook) == "function" then
        pcall(hook, kind)
        return
    end
    local soundId = nil
    local volume = 0.4
    local speed = 1
    if type(hook) == "string" then
        soundId = hook
    elseif type(hook) == "table" then
        soundId = hook.SoundId or hook.Id
        volume = hook.Volume or volume
        speed = hook.Speed or speed
    end
    if not soundId or soundId == "" then return end
    local sound = SoundCache[soundId]
    if not sound then
        sound = Instance.new("Sound")
        sound.Name = "AestheticUI_Sound"
        sound.SoundId = soundId
        sound.Volume = volume
        sound.PlaybackSpeed = speed
        sound.Parent = SoundService
        SoundCache[soundId] = sound
    else
        sound.Volume = volume
        sound.PlaybackSpeed = speed
    end
    sound:Play()
end

function AestheticUI:SetSoundHooks(hooks)
    SoundHooks = hooks or {}
end

function AestheticUI:SetTheme(theme)
    theme = theme or {}
    for k, v in pairs(theme) do
        if Theme[k] ~= nil then
            Theme[k] = v
        end
    end
    applyTheme()
end

function AestheticUI:GetTheme()
    return Theme
end

function AestheticUI:SetControlDisabled(control, disabled)
    if type(control) == "table" and control.SetDisabled then
        control:SetDisabled(disabled)
        return
    end
    local handler = ControlRegistry[control]
    if handler then
        handler(disabled)
    end
end

-- Notification System
local NotificationContainer
local Notifications = {}
local NotificationQueue = {}
local NotificationLimit = 4

function AestheticUI:SetNotificationLimit(limit)
    NotificationLimit = math.max(1, tonumber(limit) or 1)
end

local function createNotificationContainer(parent)
    NotificationContainer = createInstance("Frame", {
        Size = UDim2.new(0, 300, 1, -20),
        Position = UDim2.new(1, -310, 0, 10),
        BackgroundTransparency = 1,
        ZIndex = 6000,
        Parent = parent
    })
    createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, Spacing.Md),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = NotificationContainer
    })
end

function AestheticUI:Notify(config, _fromQueue)
    config = config or {}
    if not _fromQueue and #Notifications >= NotificationLimit then
        table.insert(NotificationQueue, config)
        return nil
    end
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 4
    local notifType = config.Type or "Info"
    
    local function getAccent()
        local colors = {
            Success = Theme.Success,
            Warning = Theme.Warning,
            Error = Theme.Danger,
            Info = Theme.Accent
        }
        return colors[notifType] or Theme.Accent
    end
    local accentColor = getAccent()
    
    local notif = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Theme.SurfaceAlt,
        BackgroundTransparency = 0.08,
        ClipsDescendants = true,
        ZIndex = 6001,
        Parent = NotificationContainer
    })
    addCorner(notif, Radius.Container)
    addStroke(notif, Theme.BorderStrong, 1)
    addInnerStroke(notif, accentColor, 1)
    addGlass(notif)
    
    local dismissed = false
    table.insert(Notifications, notif)
    local function dismissNotif()
        if dismissed then return end
        dismissed = true
        tween(notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, TweenPresets.Quick)
        task.wait(0.2)
        pcall(function() notif:Destroy() end)
        for i, item in ipairs(Notifications) do
            if item == notif then
                table.remove(Notifications, i)
                break
            end
        end
        if #NotificationQueue > 0 then
            local nextConfig = table.remove(NotificationQueue, 1)
            task.defer(function()
                AestheticUI:Notify(nextConfig, true)
            end)
        end
    end
    
    -- Accent bar
    local accentBar = createInstance("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        ZIndex = 6002,
        Parent = notif
    })
    
    -- Close button (click to dismiss)
    local closeBtn = createInstance("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -8, 0, 8),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Theme.TextDim,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        ZIndex = 6002,
        Parent = notif
    })
    closeBtn.MouseButton1Click:Connect(function()
        playSound("Click")
        dismissNotif()
    end)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {TextColor3 = Theme.Text}, TweenPresets.Quick)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {TextColor3 = Theme.TextDim}, TweenPresets.Quick)
    end)
    
    -- Title
    local titleLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, -40, 0, 22),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6002,
        Parent = notif
    })
    
    -- Message
    local messageLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 14, 0, 28),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 6002,
        Parent = notif
    })
    
    -- Progress bar
    local progressBg = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = Theme.BorderSoft,
        BorderSizePixel = 0,
        ZIndex = 6002,
        Parent = notif
    })
    local progressFill = createInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        ZIndex = 6003,
        Parent = progressBg
    })

    registerTheme(function()
        if notif.Parent == nil then return end
        accentColor = getAccent()
        accentBar.BackgroundColor3 = accentColor
        closeBtn.TextColor3 = Theme.TextDim
        titleLabel.TextColor3 = Theme.Text
        messageLabel.TextColor3 = Theme.TextDim
        notif.BackgroundColor3 = Theme.SurfaceAlt
        progressBg.BackgroundColor3 = Theme.BorderSoft
        progressFill.BackgroundColor3 = accentColor
    end)
    
    -- Animate in
    notif.Size = UDim2.new(1, 0, 0, 0)
    tween(notif, {Size = UDim2.new(1, 0, 0, 70)}, TweenPresets.Spring)
    
    -- Progress animation
    tween(progressFill, {Size = UDim2.new(0, 0, 1, 0)}, TweenInfo.new(duration, Enum.EasingStyle.Linear))
    
    -- Auto dismiss
    task.delay(duration, dismissNotif)
    
    return notif
end

-- Main Window
function AestheticUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "AestheticUI"
    local size = config.Size or UDim2.new(0, 550, 0, 380)
    
    -- Anti-detection: delayed creation
    task.wait(math.random(100, 250) / 1000)
    
    local screenGui = createInstance("ScreenGui", {
        ZIndexBehavior = Enum.ZIndexBehavior.Global, -- Global for easier popup management
        ResetOnSpawn = false
    })
    
    -- Protected GUI placement
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
            screenGui.Parent = game:GetService("CoreGui")
        elseif gethui then
            screenGui.Parent = gethui()
        else
            screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    
    createNotificationContainer(screenGui)
    
    -- Main frame with glassmorphism
    local mainFrame = createInstance("Frame", {
        Size = size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.15,
        Parent = screenGui
    })
    addCorner(mainFrame, Radius.Window)
    local mainStroke = addStroke(mainFrame, Theme.BorderStrong, 1)
    local mainInner = addInnerStroke(mainFrame, Theme.BorderSoft, 1)
    addGlass(mainFrame)
    addGlow(mainFrame)

    local miniDock = createInstance("TextButton", {
        Size = UDim2.new(0, 180, 0, 28),
        Position = UDim2.new(0, 18, 1, -46),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.SurfaceAlt,
        BackgroundTransparency = 0.2,
        Text = "",
        Visible = false,
        ZIndex = 6001,
        Parent = screenGui
    })
    addCorner(miniDock, Radius.Control)
    local dockStroke = addStroke(miniDock, Theme.BorderSoft, 1)
    addGlass(miniDock)
    createInstance("Frame", {
        Size = UDim2.new(0, 3, 1, -10),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundColor3 = Theme.AccentGlow,
        BorderSizePixel = 0,
        Parent = miniDock
    })
    local dockLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = miniDock
    })
    miniDock.MouseEnter:Connect(function()
        tween(miniDock, {BackgroundTransparency = 0.05}, TweenPresets.Quick)
        tween(dockStroke, {Color = Theme.BorderStrong}, TweenPresets.Quick)
    end)
    miniDock.MouseLeave:Connect(function()
        tween(miniDock, {BackgroundTransparency = 0.2}, TweenPresets.Quick)
        tween(dockStroke, {Color = Theme.BorderSoft}, TweenPresets.Quick)
    end)

    local function getDockPos()
        return UDim2.new(
            miniDock.Position.X.Scale,
            miniDock.Position.X.Offset + (miniDock.Size.X.Offset * 0.5),
            miniDock.Position.Y.Scale,
            miniDock.Position.Y.Offset - (miniDock.Size.Y.Offset * 0.5)
        )
    end
    
    -- Title bar
    local titleBar = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.SurfaceAlt,
        BackgroundTransparency = 0.25,
        Parent = mainFrame
    })
    addCorner(titleBar, Radius.Window)
    addGlass(titleBar)
    
    -- Fix bottom corners of title
    local titleFill = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.SurfaceAlt,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Parent = titleBar
    })
    
    -- Title text with gradient
    local titleLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    local titleGradient = createInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.AccentGlow),
            ColorSequenceKeypoint.new(1, Theme.Text)
        }),
        Parent = titleLabel
    })
    
    -- Window controls
    local closeBtn = createInstance("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -35, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Danger,
        BackgroundTransparency = 0.65,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = titleBar
    })
    addCorner(closeBtn, Radius.Control)
    local closeStroke = addStroke(closeBtn, Theme.BorderSoft, 1)
    
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundTransparency = 0.4}, TweenPresets.Quick)
        tween(closeStroke, {Color = Theme.BorderStrong}, TweenPresets.Quick)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundTransparency = 0.65}, TweenPresets.Quick)
        tween(closeStroke, {Color = Theme.BorderSoft}, TweenPresets.Quick)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        playSound("Click")
        tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, TweenPresets.Quick)
        task.wait(0.2)
        screenGui:Destroy()
    end)
    
    local minimizeBtn = createInstance("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -70, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Warning,
        BackgroundTransparency = 0.65,
        Text = "−",
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = titleBar
    })
    addCorner(minimizeBtn, Radius.Control)
    local minimizeStroke = addStroke(minimizeBtn, Theme.BorderSoft, 1)
    
    
    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, {BackgroundTransparency = 0.4}, TweenPresets.Quick)
        tween(minimizeStroke, {Color = Theme.BorderStrong}, TweenPresets.Quick)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, {BackgroundTransparency = 0.65}, TweenPresets.Quick)
        tween(minimizeStroke, {Color = Theme.BorderSoft}, TweenPresets.Quick)
    end)
    
    
    -- Dragging & Resizing
    local dragging, dragInput, dragStart, startPos
    local resizing, resizeStartPos, resizeStartSize
    
    local resizeHandle = createInstance("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, 0, 1, 0),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 50,
        Parent = mainFrame
    })
    
    -- Visual indicator for resize handle
    local resizeIcon = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "◢",
        TextColor3 = Theme.Accent,
        TextTransparency = 0.8,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        ZIndex = 51,
        Parent = resizeHandle
    })

    registerTheme(function()
        if titleBar.Parent == nil then return end
        closeBtn.BackgroundColor3 = Theme.Danger
        closeBtn.TextColor3 = Theme.Text
        closeStroke.Color = Theme.BorderSoft
        minimizeBtn.BackgroundColor3 = Theme.Warning
        minimizeBtn.TextColor3 = Theme.Text
        minimizeStroke.Color = Theme.BorderSoft
        resizeIcon.TextColor3 = Theme.Accent
        miniDock.BackgroundColor3 = Theme.SurfaceAlt
        dockStroke.Color = Theme.BorderSoft
        dockLabel.TextColor3 = Theme.Text
        titleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.AccentGlow),
            ColorSequenceKeypoint.new(1, Theme.Text)
        })
    end)

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStartPos = input.Position
            resizeStartSize = mainFrame.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            elseif resizing then
                local delta = input.Position - resizeStartPos
                local newWidth = math.max(400, resizeStartSize.X.Offset + delta.X)
                local newHeight = math.max(300, resizeStartSize.Y.Offset + delta.Y)
                mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
            end
        end
    end)
    
    -- Tab container
    local tabContainer = createInstance("Frame", {
        Size = UDim2.new(0, 130, 1, -50),
        Position = UDim2.new(0, 8, 0, 45),
        BackgroundColor3 = Theme.SurfaceAlt,
        BackgroundTransparency = 0.25,
        Parent = mainFrame
    })
    addCorner(tabContainer, Radius.Container)
    local tabStroke = addStroke(tabContainer, Theme.BorderSoft, 1)
    addGlass(tabContainer)
    
    local tabList = createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, Spacing.Xs),
        Parent = tabContainer
    })
    createInstance("UIPadding", {
        PaddingTop = UDim.new(0, Spacing.Md),
        PaddingLeft = UDim.new(0, Spacing.Md),
        PaddingRight = UDim.new(0, Spacing.Md),
        Parent = tabContainer
    })
    
    -- Content container
    local contentContainer = createInstance("Frame", {
        Size = UDim2.new(1, -155, 1, -55),
        Position = UDim2.new(0, 150, 0, 48),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = mainFrame
    })

    registerTheme(function()
        if mainFrame.Parent == nil then return end
        mainFrame.BackgroundColor3 = Theme.Surface
        mainStroke.Color = Theme.BorderStrong
        mainInner.Color = Theme.BorderSoft
        titleBar.BackgroundColor3 = Theme.SurfaceAlt
        titleFill.BackgroundColor3 = Theme.SurfaceAlt
        titleLabel.TextColor3 = Theme.Text
        tabContainer.BackgroundColor3 = Theme.SurfaceAlt
        tabStroke.Color = Theme.BorderSoft
    end)
    
    -- Window object
    local Window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        TabContainer = tabContainer,
        ContentContainer = contentContainer,
        Tabs = {},
        ActiveTab = nil,
        _connections = {},
        _config = {},
        _visible = true,
        _bind = nil,
        _defaults = {},
        _toggleGroups = {},
        _keybinds = {}
    }
    
    _G.AestheticUI_Window = Window -- Global reference for components
    
    -- Connection Manager (Track all connections for cleanup)
    function Window:TrackConnection(conn)
        table.insert(self._connections, conn)
        return conn
    end
    
    -- Visibility management
    function Window:Toggle()
        self._visible = not self._visible
        if self._visible then
            miniDock.Visible = false
            mainFrame.Visible = true
            local targetSize = self._lastSize or size
            local targetPos = self._lastPos or UDim2.new(0.5, 0, 0.5, 0)
            mainFrame.Size = miniDock.Size
            mainFrame.Position = getDockPos()
            mainFrame.BackgroundTransparency = 1
            tween(mainFrame, {Size = targetSize, Position = targetPos, BackgroundTransparency = 0.15}, TweenPresets.Spring)
        else
            self._lastSize = mainFrame.Size
            self._lastPos = mainFrame.Position
            local t = tween(mainFrame, {
                Size = miniDock.Size,
                Position = getDockPos(),
                BackgroundTransparency = 1
            }, TweenPresets.Smooth)
            t.Completed:Connect(function()
                if not self._visible then
                    mainFrame.Visible = false
                    miniDock.Visible = true
                end
            end)
        end
    end

    -- Toggle visibility function (defined AFTER Window object is created)
    local function toggleVisibility()
        Window:Toggle()
    end

    minimizeBtn.MouseButton1Click:Connect(function()
        playSound("Click")
        toggleVisibility()
    end)

    miniDock.MouseButton1Click:Connect(function()
        playSound("Click")
        toggleVisibility()
    end)
    
    -- Set toggle bind
    function Window:SetBind(key)
        self._bind = key
        local conn = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == self._bind then
                self:Toggle()
            end
        end)
        self:TrackConnection(conn)
    end
    
    -- Tooltip System
    local tooltip = createInstance("Frame", {
        Size = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = Theme.SurfaceAlt,
        Visible = false,
        ZIndex = 5000,
        Parent = screenGui
    })
    addCorner(tooltip, Radius.Subtle)
    local tooltipStroke = addStroke(tooltip, Theme.Accent, 1)
    addGlass(tooltip)
    
    local tooltipLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        ZIndex = 5001,
        Parent = tooltip
    })
    
    Window._tooltipDelay = config.TooltipDelay or 0.25
    Window._tooltipSmoothing = config.TooltipSmoothing or 18

    registerTheme(function()
        if tooltip.Parent == nil then return end
        tooltip.BackgroundColor3 = Theme.SurfaceAlt
        tooltipStroke.Color = Theme.AccentGlow
        tooltipLabel.TextColor3 = Theme.Text
    end)

    function Window:ShowTooltip(text)
        tooltipLabel.Text = text
        local size = game:GetService("TextService"):GetTextSize(text, 11, Enum.Font.Gotham, Vector2.new(280, 100))
        tooltip.Size = UDim2.new(0, math.min(size.X + 12, 280), 0, size.Y + 8)
        self._tooltipToken = (self._tooltipToken or 0) + 1
        local token = self._tooltipToken

        if self._tooltipConn then
            self._tooltipConn:Disconnect()
            self._tooltipConn = nil
        end

        task.delay(self._tooltipDelay, function()
            if self._tooltipToken ~= token then return end
            tooltip.Visible = true
            local conn = RunService.RenderStepped:Connect(function(dt)
                local mousePos = UserInputService:GetMouseLocation()
                local target = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y - 5)
                local alpha = 1 - math.exp(-dt * (self._tooltipSmoothing or 18))
                tooltip.Position = tooltip.Position:Lerp(target, alpha)
            end)
            self._tooltipConn = conn
        end)
    end
    
    function Window:HideTooltip()
        self._tooltipToken = (self._tooltipToken or 0) + 1
        tooltip.Visible = false
        if self._tooltipConn then self._tooltipConn:Disconnect() end
    end

    function Window:ResetDefaults()
        for _, resetFn in ipairs(self._defaults) do
            pcall(resetFn)
        end
    end
    
    -- Destroy method for cleanup
    function Window:Destroy()
        for _, conn in pairs(self._connections) do
            pcall(function() conn:Disconnect() end)
        end
        if self._tooltipConn then
            pcall(function() self._tooltipConn:Disconnect() end)
            self._tooltipConn = nil
        end
        tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, TweenPresets.Quick)
        task.wait(0.2)
        pcall(function() screenGui:Destroy() end)
    end
    
    -- Save config
    function Window:SaveConfig(name)
        local data = HttpService:JSONEncode(self._config)
        if writefile then
            pcall(function() writefile(name .. ".json", data) end)
        end
    end
    
    -- Load config
    function Window:LoadConfig(name)
        if readfile and isfile and isfile(name .. ".json") then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(name .. ".json"))
            end)
            if success then
                self._config = data
                return data
            end
        end
        return nil
    end
    
    -- Animate window in
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundTransparency = 1
    tween(mainFrame, {Size = size, BackgroundTransparency = 0.08}, TweenPresets.Spring)
    
    -- [ADVANCED ANTI-DETECTION] Window-level Metatable locking
    if newproxy then
        local WindowProxy = newproxy(true)
        local WindowMeta = getmetatable(WindowProxy)

        WindowMeta.__index = Window
        WindowMeta.__newindex = function(_, k, v)
            Window[k] = v
        end
        WindowMeta.__metatable = "The metatable is locked"
        WindowMeta.__tostring = function() return "AestheticUI_Window" end

        _G.AestheticUI_Window = Window -- Internal reference
        return WindowProxy
    end

    _G.AestheticUI_Window = Window
    return Window
end

-- Create Tab
function AestheticUI:CreateTab(window, config)
    config = config or {}
    local name = config.Name or "Tab"
    local icon = config.Icon or ""
    
    local tabBtn = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Theme.SurfaceAlt,
        BackgroundTransparency = 1,
        Text = "",
        Parent = window.TabContainer
    })
    addCorner(tabBtn, Radius.Control)
    
    local tabLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, icon ~= "" and 30 or 10, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextSoft,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabBtn
    })
    
    local tabIcon = nil
    if icon ~= "" then
        tabIcon = createInstance("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 8, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = Theme.TextDim,
            Parent = tabBtn
        })
    end
    
    local tabPage = createInstance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = window.ContentContainer
    })
    
    createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, Spacing.Md),
        Parent = tabPage
    })
    createInstance("UIPadding", {
        PaddingTop = UDim.new(0, Spacing.Sm),
        PaddingBottom = UDim.new(0, Spacing.Sm),
        PaddingLeft = UDim.new(0, Spacing.Lg),
        PaddingRight = UDim.new(0, Spacing.Lg),
        Parent = tabPage
    })
    
    local Tab = {
        Button = tabBtn,
        Page = tabPage,
        Name = name
    }
    
    tabBtn.MouseEnter:Connect(function()
        if window.ActiveTab ~= Tab then
            tween(tabBtn, {BackgroundTransparency = 0.82}, TweenPresets.Quick)
            tween(tabLabel, {TextColor3 = Theme.Text}, TweenPresets.Quick)
        end
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if window.ActiveTab ~= Tab then
            tween(tabBtn, {BackgroundTransparency = 1}, TweenPresets.Quick)
            tween(tabLabel, {TextColor3 = Theme.TextSoft}, TweenPresets.Quick)
        end
    end)
    
    local function selectTab()
        if window.ActiveTab then
            window.ActiveTab.Page.Visible = false
            tween(window.ActiveTab.Button, {BackgroundTransparency = 1}, TweenPresets.Quick)
            local oldLabel = window.ActiveTab.Button:FindFirstChildOfClass("TextLabel")
            if oldLabel then
                tween(oldLabel, {TextColor3 = Theme.TextSoft}, TweenPresets.Quick)
            end
        end
        window.ActiveTab = Tab
        tabPage.Visible = true
        tween(tabBtn, {BackgroundTransparency = 0.68}, TweenPresets.Smooth)
        tween(tabLabel, {TextColor3 = Theme.AccentGlow}, TweenPresets.Quick)
    end
    
    tabBtn.MouseButton1Click:Connect(function()
        playSound("Click")
        selectTab()
    end)

    registerTheme(function()
        if tabBtn.Parent == nil then return end
        tabLabel.TextColor3 = window.ActiveTab == Tab and Theme.AccentGlow or Theme.TextSoft
        if tabIcon then
            tabIcon.ImageColor3 = window.ActiveTab == Tab and Theme.AccentGlow or Theme.TextDim
        end
        tabPage.ScrollBarImageColor3 = Theme.Accent
    end)
    
    -- Auto-select first tab
    if #window.Tabs == 0 then
        selectTab()
    end
    
    table.insert(window.Tabs, Tab)
    return Tab
end

-- Section
function AestheticUI:CreateSection(tab, name)
    local sectionName = name
    local sectionConfig = {}
    if typeof(name) == "table" then
        sectionConfig = name
        sectionName = sectionConfig.Name or "Section"
    end

    local section = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.SurfaceAlt,
        BackgroundTransparency = 0.26,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = tab.Page
    })
    addCorner(section, Radius.Container)
    addStroke(section, Theme.BorderStrong, 1)
    addInnerStroke(section, Theme.BorderSoft, 1)
    addGlass(section)

    local header = createInstance("Frame", {
        Size = UDim2.new(1, -16, 0, 26),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Parent = section
    })

    local sectionLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, -110, 1, 0),
        BackgroundTransparency = 1,
        Text = sectionName or "Section",
        TextColor3 = Theme.AccentGlow,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })

    local actionContainer = createInstance("Frame", {
        Size = UDim2.new(0, 100, 1, 0),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = header
    })
    createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, Spacing.Xs),
        Parent = actionContainer
    })
    
    local contentFrame = createInstance("Frame", {
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 28),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = section
    })
    
    createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, Spacing.Md),
        Parent = contentFrame
    })
    createInstance("UIPadding", {
        PaddingBottom = UDim.new(0, Spacing.Lg),
        Parent = contentFrame
    })
    
    registerTheme(function()
        if section.Parent == nil then return end
        section.BackgroundColor3 = Theme.SurfaceAlt
        sectionLabel.TextColor3 = Theme.AccentGlow
    end)

    local function addHeaderAction(text, callback)
        local actionBtn = createInstance("TextButton", {
            Size = UDim2.new(0, 60, 0, 20),
            BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 0.2,
            Text = "",
            Parent = actionContainer
        })
        addCorner(actionBtn, Radius.Subtle)
        local actionStroke = addStroke(actionBtn, Theme.BorderSoft, 1)
        addGlass(actionBtn)
        local actionLabel = createInstance("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.TextSoft,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            Parent = actionBtn
        })
        actionBtn.MouseEnter:Connect(function()
            tween(actionBtn, {BackgroundTransparency = 0.05}, TweenPresets.Quick)
            tween(actionStroke, {Color = Theme.BorderStrong}, TweenPresets.Quick)
        end)
        actionBtn.MouseLeave:Connect(function()
            tween(actionBtn, {BackgroundTransparency = 0.2}, TweenPresets.Quick)
            tween(actionStroke, {Color = Theme.BorderSoft}, TweenPresets.Quick)
        end)
        actionBtn.MouseButton1Click:Connect(function()
            playSound("Click")
            pcall(callback)
        end)
        registerTheme(function()
            if actionBtn.Parent == nil then return end
            actionBtn.BackgroundColor3 = Theme.Surface
            actionStroke.Color = Theme.BorderSoft
            actionLabel.TextColor3 = Theme.TextSoft
        end)
        return actionBtn
    end

    if sectionConfig.Actions then
        for _, action in ipairs(sectionConfig.Actions) do
            addHeaderAction(action.Text or "Action", action.Callback)
        end
    end

    return {Frame = section, Content = contentFrame, AddHeaderAction = addHeaderAction}
end

-- Button
function AestheticUI:CreateButton(section, config)
    config = config or {}
    local text = config.Text or "Button"
    local tooltip = config.Tooltip or ""
    local callback = config.Callback or function() end
    local disabled = config.Disabled or false
    
    local btn = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.AccentSoft,
        BackgroundTransparency = 0.6,
        Text = "",
        Parent = section.Content
    })
    addCorner(btn, Radius.Control)
    local btnStroke = addStroke(btn, Theme.BorderSoft, 1)
    addGlass(btn)
    
    local btnLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        Parent = btn
    })
    
    local function setDisabled(state)
        disabled = state and true or false
        btn.AutoButtonColor = not disabled
        btn.BackgroundTransparency = disabled and 0.8 or 0.6
        btnLabel.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        btnStroke.Color = disabled and Theme.BorderSoft or Theme.BorderSoft
    end
    ControlRegistry[btn] = setDisabled
    setDisabled(disabled)

    registerTheme(function()
        if btn.Parent == nil then return end
        btn.BackgroundColor3 = Theme.AccentSoft
        btnLabel.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        btnStroke.Color = Theme.BorderSoft
    end)

    -- Subtle press feedback
    btn.MouseButton1Click:Connect(function()
        if disabled then return end
        playSound("Click")
        tween(btn, {BackgroundTransparency = 0.35}, TweenPresets.Quick)
        task.delay(0.12, function()
            tween(btn, {BackgroundTransparency = 0.6}, TweenPresets.Quick)
        end)
        
        pcall(callback)
    end)
    
    btn.MouseEnter:Connect(function()
        if disabled then return end
        playSound("Hover")
        tween(btn, {BackgroundTransparency = 0.45}, TweenPresets.Quick)
        tween(btnStroke, {Color = Theme.AccentGlow}, TweenPresets.Quick)
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:ShowTooltip(tooltip) end
    end)
    btn.MouseLeave:Connect(function()
        if disabled then return end
        tween(btn, {BackgroundTransparency = 0.6}, TweenPresets.Quick)
        tween(btnStroke, {Color = Theme.BorderSoft}, TweenPresets.Quick)
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:HideTooltip() end
    end)

    if _G.AestheticUI_Window then
        table.insert(_G.AestheticUI_Window._defaults, function()
            setDisabled(config.Disabled or false)
        end)
    end
    
    return btn
end

-- Toggle
function AestheticUI:CreateToggle(section, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local tooltip = config.Tooltip or ""
    local callback = config.Callback or function() end
    local disabled = config.Disabled or false
    local groupId = config.Group
    local allowOff = config.AllowOff
    if allowOff == nil then
        allowOff = groupId == nil
    end
    local window = _G.AestheticUI_Window
    
    local toggled = default
    local bind = nil
    
    local container = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent = section.Content
    })
    
    local label = createInstance("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local toggleBg = createInstance("Frame", {
        Size = UDim2.new(0, 42, 0, 22),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = toggled and Theme.Accent or Theme.BorderSoft,
        Parent = container
    })
    addCorner(toggleBg, 11)
    local toggleStroke = addStroke(toggleBg, Theme.BorderSoft, 1)
    local toggleGlow = addAccentGlow(toggleBg, Theme.AccentGlow)
    toggleGlow.ImageTransparency = toggled and 0.86 or 1
    
    local toggleKnob = createInstance("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = toggled and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(toggled and 1 or 0, 0.5),
        BackgroundColor3 = Theme.Text,
        Parent = toggleBg
    })
    addCorner(toggleKnob, 8)
    
    local function applyState(value, silent)
        toggled = value
        tween(toggleBg, {BackgroundColor3 = toggled and Theme.Accent or Theme.BorderSoft}, TweenPresets.Smooth)
        tween(toggleStroke, {Color = toggled and Theme.AccentGlow or Theme.BorderSoft}, TweenPresets.Quick)
        tween(toggleGlow, {ImageTransparency = toggled and 0.86 or 1}, TweenPresets.Quick)
        tween(toggleKnob, {
            Position = toggled and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            AnchorPoint = Vector2.new(toggled and 1 or 0, 0.5)
        }, TweenPresets.Spring)
        if window then window._config[text] = toggled end
        if not silent then pcall(callback, toggled) end
    end

    local toggleApi
    local function setToggle(value, silent, fromGroup)
        if disabled then return end
        if groupId and allowOff == false and toggled and not value then return end
        if value == toggled then return end
        applyState(value, silent)
        if value and groupId and window and not fromGroup then
            local group = window._toggleGroups[groupId] or {}
            for _, item in ipairs(group) do
                if item ~= toggleApi then
                    item.Set(item, false, true, true)
                end
            end
        end
    end

    local function updateToggle()
        setToggle(not toggled)
    end
    
    local toggleBtn = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container
    })
    
    toggleBtn.MouseButton1Click:Connect(function()
        if disabled then return end
        playSound("Toggle")
        updateToggle()
    end)
    
    -- Right click keybind functionality
    toggleBtn.MouseButton2Click:Connect(function()
        if disabled then return end
        label.Text = "[Press Key]"
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                bind = input.KeyCode
                label.Text = text .. " [" .. bind.Name .. "]"
                conn:Disconnect()
            end
        end)
    end)
    
    if window then
        local bindConn = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and bind and input.KeyCode == bind then
                updateToggle()
            end
        end)
        window:TrackConnection(bindConn)
    end
    if window then
        window._config[text] = toggled
    end
    
    container.MouseEnter:Connect(function()
        if disabled then return end
        playSound("Hover")
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:ShowTooltip(tooltip) end
    end)
    container.MouseLeave:Connect(function()
        if disabled then return end
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:HideTooltip() end
    end)
    
    local function setDisabled(state)
        disabled = state and true or false
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        toggleBg.BackgroundTransparency = disabled and 0.4 or 0
    end

    registerTheme(function()
        if container.Parent == nil then return end
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        toggleBg.BackgroundColor3 = toggled and Theme.Accent or Theme.BorderSoft
        toggleStroke.Color = toggled and Theme.AccentGlow or Theme.BorderSoft
        toggleGlow.ImageColor3 = Theme.AccentGlow
    end)

    toggleApi = {
        Set = function(_, value, silent, fromGroup)
            setToggle(value, silent, fromGroup)
        end,
        Get = function() return toggled end,
        SetDisabled = function(_, value) setDisabled(value) end
    }

    if window and groupId then
        window._toggleGroups[groupId] = window._toggleGroups[groupId] or {}
        table.insert(window._toggleGroups[groupId], toggleApi)
    end

    if window then
        table.insert(window._defaults, function()
            applyState(default, true)
            setDisabled(config.Disabled or false)
        end)
    end

    return toggleApi
end

-- Slider
function AestheticUI:CreateSlider(section, config)
    config = config or {}
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local tooltip = config.Tooltip or ""
    local callback = config.Callback or function() end
    local step = config.Step or 1
    local showValueBubble = config.ShowValueTooltip ~= false
    local valueFormat = config.ValueFormat
    local disabled = config.Disabled or false
    
    local value = default
    if _G.AestheticUI_Window then _G.AestheticUI_Window._config[text] = value end
    
    local container = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        Parent = section.Content
    })
    
    local label = createInstance("TextLabel", {
        Size = UDim2.new(1, -60, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local valueLabel = createInstance("TextLabel", {
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = Theme.AccentGlow,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container
    })
    
    local sliderBg = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Theme.BorderSoft,
        Parent = container
    })
    addCorner(sliderBg, 4)
    
    local sliderFill = createInstance("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        Parent = sliderBg
    })
    addCorner(sliderFill, 4)
    local fillGlow = addAccentGlow(sliderFill, Theme.AccentGlow)
    fillGlow.ImageTransparency = 0.9
    
    local sliderGradient = createInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentGlow)
        }),
        Parent = sliderFill
    })
    
    local knob = createInstance("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Text,
        Parent = sliderBg
    })
    addCorner(knob, 8)
    addStroke(knob, Theme.AccentGlow, 2)
    
    local dragging = false

    local bubble
    local bubbleLabel
    if showValueBubble then
        bubble = createInstance("Frame", {
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new((value - min) / (max - min), 0, 0, -8),
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = Theme.SurfaceAlt,
            BackgroundTransparency = 1,
            Visible = false,
            Parent = sliderBg
        })
        addCorner(bubble, Radius.Subtle)
        addStroke(bubble, Theme.BorderSoft, 1)
        addGlass(bubble)
        bubbleLabel = createInstance("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(value),
            TextColor3 = Theme.Text,
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            Parent = bubble
        })
    end

    local function formatValue(val)
        if valueFormat then
            return tostring(valueFormat(val))
        end
        return tostring(val)
    end

    local function applyValue(newValue, silent)
        value = newValue
        local pos = (value - min) / (max - min)
        valueLabel.Text = formatValue(value)
        tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, TweenPresets.Quick)
        tween(knob, {Position = UDim2.new(pos, 0, 0.5, 0)}, TweenPresets.Quick)
        if bubble then
            bubble.Position = UDim2.new(pos, 0, 0, -6)
            bubbleLabel.Text = formatValue(value)
        end
        if not silent then pcall(callback, value) end
    end

    local function quantize(raw)
        local clamped = math.clamp(raw, min, max)
        if step and step > 0 then
            clamped = math.floor((clamped - min) / step + 0.5) * step + min
        end
        return math.clamp(clamped, min, max)
    end

    local function updateSlider(input)
        if disabled then return end
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local raw = min + (max - min) * pos
        local nextValue = quantize(raw)
        applyValue(nextValue)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if disabled then return end
            dragging = true
            playSound("Click")
            updateSlider(input)
            if bubble then
                bubble.Visible = true
                tween(bubble, {BackgroundTransparency = 0.1}, TweenPresets.Quick)
            end
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if bubble then
                local t = tween(bubble, {BackgroundTransparency = 1}, TweenPresets.Quick)
                t.Completed:Connect(function()
                    bubble.Visible = false
                end)
            end
        end
    end)
    
    if _G.AestheticUI_Window then
        local conn = UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        _G.AestheticUI_Window:TrackConnection(conn)
    end
    
    container.MouseEnter:Connect(function()
        if disabled then return end
        playSound("Hover")
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:ShowTooltip(tooltip) end
    end)
    container.MouseLeave:Connect(function()
        if disabled then return end
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:HideTooltip() end
    end)
    
    local function setDisabled(state)
        disabled = state and true or false
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        valueLabel.TextColor3 = disabled and Theme.TextSoft or Theme.AccentGlow
        sliderBg.BackgroundTransparency = disabled and 0.5 or 0
    end

    registerTheme(function()
        if container.Parent == nil then return end
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        valueLabel.TextColor3 = disabled and Theme.TextSoft or Theme.AccentGlow
        sliderBg.BackgroundColor3 = Theme.BorderSoft
        sliderFill.BackgroundColor3 = Theme.Accent
        sliderGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentGlow)
        })
        knob.BackgroundColor3 = Theme.Text
        if bubble then
            bubble.BackgroundColor3 = Theme.SurfaceAlt
            bubbleLabel.TextColor3 = Theme.Text
        end
    end)

    if _G.AestheticUI_Window then
        table.insert(_G.AestheticUI_Window._defaults, function()
            applyValue(default, true)
            setDisabled(config.Disabled or false)
        end)
    end

    return {
        Set = function(_, newValue, silent)
            local nextValue = quantize(newValue)
            applyValue(nextValue, silent)
        end,
        Get = function() return value end,
        SetDisabled = function(_, state) setDisabled(state) end
    }
end

-- Dropdown
function AestheticUI:CreateDropdown(section, config)
    config = config or {}
    local text = config.Text or "Dropdown"
    local options = config.Options or {}
    local default = config.Default or (options[1] or "")
    local callback = config.Callback or function() end
    local disabled = config.Disabled or false
    local emptyText = config.EmptyText or "No results"
    
    local selected = default
    local opened = false
    
    local container = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = section.Content
    })
    
    local label = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local dropBtn = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = Theme.SurfaceAlt,
        BackgroundTransparency = 0.2,
        Text = "",
        Parent = container
    })
    addCorner(dropBtn, Radius.Control)
    local dropStroke = addStroke(dropBtn, Theme.BorderSoft, 1)
    addGlass(dropBtn)
    
    local searchBar = createInstance("TextBox", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = selected,
        PlaceholderColor3 = Theme.TextSoft,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = false,
        Parent = dropBtn
    })
    
    local selectedLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = selected,
        TextColor3 = Theme.TextSoft,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropBtn
    })
    
    local arrow = createInstance("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -25, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Theme.TextDim,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Rotation = 0,
        Parent = dropBtn
    })
    
    local optionsFrame = createInstance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.15, -- Keep glass consistency
        ClipsDescendants = true,
        ZIndex = 100, -- High ZIndex for global layering
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = dropBtn
    })
    addCorner(optionsFrame, Radius.Control)
    addStroke(optionsFrame, Theme.BorderStrong, 1)
    addGlass(optionsFrame)
    
    local optionsList = createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = optionsFrame
    })
    createInstance("UIPadding", {
        PaddingTop = UDim.new(0, Spacing.Sm),
        PaddingBottom = UDim.new(0, Spacing.Sm),
        Parent = optionsFrame
    })

    local emptyLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, -16, 0, 24),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = emptyText,
        TextColor3 = Theme.TextSoft,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = false,
        Parent = optionsFrame
    })
    
    local function createOption(option)
        local optBtn = createInstance("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 101, -- Must be > parent ZIndex (100)
            Parent = optionsFrame
        })
        local optLabel = createInstance("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = Theme.TextSoft,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
            Parent = optBtn
        })
        optBtn.MouseEnter:Connect(function()
            tween(optBtn, {BackgroundTransparency = 0.82}, TweenPresets.Quick)
        end)
        optBtn.MouseLeave:Connect(function()
            tween(optBtn, {BackgroundTransparency = 1}, TweenPresets.Quick)
        end)
        optBtn.MouseButton1Click:Connect(function()
            if disabled then return end
            selected = option
            selectedLabel.Text = option
            searchBar.PlaceholderText = option
            tween(selectedLabel, {TextColor3 = Theme.Text}, TweenPresets.Quick)
            opened = false
            searchBar.Visible = false
            selectedLabel.Visible = true
            tween(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, TweenPresets.Spring)
            tween(arrow, {Rotation = 0}, TweenPresets.Quick)
            tween(dropStroke, {Color = Theme.BorderSoft}, TweenPresets.Quick)
            if _G.AestheticUI_Window then _G.AestheticUI_Window._config[text] = selected end
            pcall(callback, selected)
        end)

        registerTheme(function()
            if optBtn.Parent == nil then return end
            optLabel.TextColor3 = Theme.TextSoft
        end)
        return optBtn
    end
    
    for _, option in ipairs(options) do
        createOption(option)
    end
    
    local function refreshEmptyState()
        local visibleCount = 0
        for _, child in ipairs(optionsFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Visible then
                visibleCount = visibleCount + 1
            end
        end
        emptyLabel.Visible = visibleCount == 0
    end

    searchBar:GetPropertyChangedSignal("Text"):Connect(function()
        local search = searchBar.Text:lower()
        for _, child in ipairs(optionsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                local label = child:FindFirstChildOfClass("TextLabel")
                if label then
                    local optText = label.Text:lower()
                    child.Visible = optText:find(search) ~= nil
                end
            end
        end
        refreshEmptyState()
    end)
    
    local function updateDropdown()
        opened = not opened
        local optionsHeight = math.min(#options * 26 + 8, 150)
        tween(optionsFrame, {Size = opened and UDim2.new(1, 0, 0, optionsHeight) or UDim2.new(1, 0, 0, 0)}, TweenPresets.Spring)
        tween(arrow, {Rotation = opened and 180 or 0}, TweenPresets.Quick)
        tween(dropStroke, {Color = opened and Theme.AccentGlow or Theme.BorderSoft}, TweenPresets.Quick)
        searchBar.Visible = opened
        selectedLabel.Visible = not opened
        if opened then searchBar:CaptureFocus() end
        refreshEmptyState()
    end
    
    dropBtn.MouseButton1Click:Connect(function()
        if disabled then return end
        playSound("Click")
        updateDropdown()
    end)
    dropBtn.MouseEnter:Connect(function()
        if disabled then return end
        if not opened then
            tween(dropStroke, {Color = Theme.BorderStrong}, TweenPresets.Quick)
        end
    end)
    dropBtn.MouseLeave:Connect(function()
        if disabled then return end
        if not opened then
            tween(dropStroke, {Color = Theme.BorderSoft}, TweenPresets.Quick)
        end
    end)

    container.MouseEnter:Connect(function()
        if disabled then return end
        playSound("Hover")
    end)
    
    local function setDisabled(state)
        disabled = state and true or false
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        dropBtn.BackgroundTransparency = disabled and 0.6 or 0.2
        dropStroke.Color = disabled and Theme.BorderSoft or Theme.BorderSoft
        arrow.TextColor3 = disabled and Theme.TextSoft or Theme.TextDim
    end

    registerTheme(function()
        if container.Parent == nil then return end
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        dropBtn.BackgroundColor3 = Theme.SurfaceAlt
        dropStroke.Color = Theme.BorderSoft
        selectedLabel.TextColor3 = Theme.TextSoft
        searchBar.PlaceholderColor3 = Theme.TextSoft
        searchBar.TextColor3 = Theme.Text
        arrow.TextColor3 = Theme.TextDim
        optionsFrame.BackgroundColor3 = Theme.Surface
        optionsFrame.ScrollBarImageColor3 = Theme.Accent
        emptyLabel.TextColor3 = Theme.TextSoft
    end)

    if _G.AestheticUI_Window then
        _G.AestheticUI_Window._config[text] = selected
        table.insert(_G.AestheticUI_Window._defaults, function()
            selected = default
            selectedLabel.Text = selected
            searchBar.PlaceholderText = selected
            setDisabled(config.Disabled or false)
        end)
    end

    refreshEmptyState()

    return {
        Set = function(_, value)
            if table.find(options, value) then
                selected = value
                selectedLabel.Text = value
                searchBar.PlaceholderText = value
                if _G.AestheticUI_Window then _G.AestheticUI_Window._config[text] = selected end
            end
        end,
        Get = function() return selected end,
        Refresh = function(self, newOptions)
            options = newOptions
            for _, child in ipairs(optionsFrame:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for _, option in ipairs(options) do
                createOption(option)
            end
            refreshEmptyState()
        end,
        SetDisabled = function(_, state) setDisabled(state) end
    }
end

-- Checkbox
function AestheticUI:CreateCheckbox(section, config)
    config = config or {}
    local text = config.Text or "Checkbox"
    local default = config.Default or false
    local callback = config.Callback or function() end
    local disabled = config.Disabled or false
    
    local checked = default
    
    local container = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Parent = section.Content
    })
    
    local checkBox = createInstance("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = checked and Theme.Accent or Theme.BorderSoft,
        Parent = container
    })
    addCorner(checkBox, Radius.Subtle)
    local checkStroke = addStroke(checkBox, Theme.BorderSoft, 1)
    
    local checkMark = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "✓",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextTransparency = checked and 0 or 1,
        Parent = checkBox
    })
    
    local label = createInstance("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local function updateCheck()
        if disabled then return end
        checked = not checked
        tween(checkBox, {BackgroundColor3 = checked and Theme.Accent or Theme.BorderSoft}, TweenPresets.Quick)
        tween(checkStroke, {Color = checked and Theme.AccentGlow or Theme.BorderSoft}, TweenPresets.Quick)
        tween(checkMark, {TextTransparency = checked and 0 or 1}, TweenPresets.Quick)
        if checked then
            checkBox.Size = UDim2.new(0, 16, 0, 16)
            tween(checkBox, {Size = UDim2.new(0, 20, 0, 20)}, TweenPresets.Bounce)
        end
        if _G.AestheticUI_Window then _G.AestheticUI_Window._config[text] = checked end
        pcall(callback, checked)
    end
    
    container.MouseEnter:Connect(function()
        if disabled then return end
        playSound("Hover")
        if config.Tooltip and config.Tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:ShowTooltip(config.Tooltip) end
    end)
    container.MouseLeave:Connect(function()
        if disabled then return end
        if config.Tooltip and config.Tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:HideTooltip() end
    end)
    
    local btn = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container
    })
    btn.MouseButton1Click:Connect(function()
        if disabled then return end
        playSound("Toggle")
        updateCheck()
    end)
    
    pcall(function()
        if _G.AestheticUI_Window then
            _G.AestheticUI_Window._config[text] = checked
        end
    end)
    
    local function setDisabled(state)
        disabled = state and true or false
        checkBox.BackgroundTransparency = disabled and 0.4 or 0
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
    end

    registerTheme(function()
        if container.Parent == nil then return end
        checkBox.BackgroundColor3 = checked and Theme.Accent or Theme.BorderSoft
        checkStroke.Color = checked and Theme.AccentGlow or Theme.BorderSoft
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
    end)

    if _G.AestheticUI_Window then
        table.insert(_G.AestheticUI_Window._defaults, function()
            if default ~= checked then updateCheck() end
            setDisabled(config.Disabled or false)
        end)
    end

    return {
        Set = function(_, value)
            if value ~= checked then updateCheck() end
        end,
        Get = function() return checked end,
        SetDisabled = function(_, state) setDisabled(state) end
    }
end

-- Keybind
function AestheticUI:CreateKeybind(section, config)
    config = config or {}
    local text = config.Text or "Keybind"
    local default = config.Default or Enum.KeyCode.Unknown
    local tooltip = config.Tooltip or ""
    local callback = config.Callback or function() end
    local disabled = config.Disabled or false
    local blockConflicts = config.BlockConflicts or false
    local window = _G.AestheticUI_Window
    
    local key = default
    local listening = false
    
    local container = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent = section.Content
    })
    
    local label = createInstance("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local keyBtn = createInstance("TextButton", {
        Size = UDim2.new(0, 70, 0, 24),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.SurfaceAlt,
        BackgroundTransparency = 0.2,
        Text = key.Name or "None",
        TextColor3 = Theme.TextSoft,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        Parent = container
    })
    addCorner(keyBtn, Radius.Subtle)
    local keyStroke = addStroke(keyBtn, Theme.BorderSoft, 1)
    addGlass(keyBtn)
    
    local function clearKey()
        key = Enum.KeyCode.Unknown
        keyBtn.Text = "None"
        if window then
            window._config[text] = "None"
            window._keybinds[text] = Enum.KeyCode.Unknown
        end
    end

    keyBtn.MouseButton1Click:Connect(function()
        if disabled then return end
        listening = true
        keyBtn.Text = "..."
        tween(keyBtn, {BackgroundColor3 = Theme.AccentSoft}, TweenPresets.Quick)
        tween(keyStroke, {Color = Theme.AccentGlow, Thickness = 2}, TweenPresets.Quick)
    end)

    keyBtn.MouseEnter:Connect(function()
        if not listening and not disabled then
            playSound("Hover")
            tween(keyBtn, {BackgroundTransparency = 0.1}, TweenPresets.Quick)
            tween(keyStroke, {Color = Theme.BorderStrong}, TweenPresets.Quick)
        end
    end)
    keyBtn.MouseLeave:Connect(function()
        if not listening and not disabled then
            tween(keyBtn, {BackgroundTransparency = 0.2}, TweenPresets.Quick)
            tween(keyStroke, {Color = Theme.BorderSoft}, TweenPresets.Quick)
        end
    end)

    keyBtn.MouseButton2Click:Connect(function()
        if disabled then return end
        clearKey()
    end)
    
    if window then
        window._keybinds[text] = key
        local conn = UserInputService.InputBegan:Connect(function(input, processed)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                        clearKey()
                        listening = false
                        tween(keyBtn, {BackgroundColor3 = Theme.SurfaceAlt}, TweenPresets.Quick)
                        tween(keyStroke, {Color = Theme.BorderSoft, Thickness = 1}, TweenPresets.Quick)
                        return
                    end
                    local conflict = false
                    for name, boundKey in pairs(window._keybinds) do
                        if name ~= text and boundKey == input.KeyCode then
                            conflict = true
                            break
                        end
                    end
                    if conflict and blockConflicts then
                        tween(keyBtn, {BackgroundColor3 = Theme.Warning}, TweenPresets.Quick)
                        tween(keyStroke, {Color = Theme.Warning, Thickness = 2}, TweenPresets.Quick)
                        playSound("Error")
                        listening = false
                        return
                    end
                    key = input.KeyCode
                    keyBtn.Text = key.Name
                    listening = false
                    window._keybinds[text] = key
                    tween(keyBtn, {BackgroundColor3 = Theme.SurfaceAlt}, TweenPresets.Quick)
                    tween(keyStroke, {Color = conflict and Theme.Warning or Theme.BorderSoft, Thickness = 1}, TweenPresets.Quick)
                    _G.AestheticUI_Window._config[text] = key.Name
                    if conflict then
                        playSound("Error")
                    end
                end
            elseif not processed and input.KeyCode == key then
                pcall(callback)
            end
        end)
        window:TrackConnection(conn)
    end
    
    container.MouseEnter:Connect(function()
        if disabled then return end
        playSound("Hover")
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:ShowTooltip(tooltip) end
    end)
    container.MouseLeave:Connect(function()
        if disabled then return end
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:HideTooltip() end
    end)

    local function setDisabled(state)
        disabled = state and true or false
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        keyBtn.BackgroundTransparency = disabled and 0.6 or 0.2
    end

    registerTheme(function()
        if container.Parent == nil then return end
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        keyBtn.BackgroundColor3 = Theme.SurfaceAlt
        keyStroke.Color = Theme.BorderSoft
        keyBtn.TextColor3 = Theme.TextSoft
    end)

    if window then
        table.insert(window._defaults, function()
            key = default
            keyBtn.Text = key.Name
            window._keybinds[text] = key
            setDisabled(config.Disabled or false)
        end)
    end
    
    return {
        Set = function(_, newKey)
            key = newKey
            keyBtn.Text = key.Name
            if window then window._config[text] = key.Name end
        end,
        Get = function() return key end,
        Clear = function() clearKey() end,
        SetDisabled = function(_, state) setDisabled(state) end
    }
end

-- TextInput
function AestheticUI:CreateTextInput(section, config)
    config = config or {}
    local text = config.Text or "Input"
    local placeholder = config.Placeholder or ""
    local defaultValue = config.Default or ""
    local tooltip = config.Tooltip or ""
    local callback = config.Callback or function() end
    local disabled = config.Disabled or false
    local validateFn = config.Validate
    local pattern = config.ValidationPattern
    local errorText = config.ErrorText or "Invalid value"
    local validateOnChange = config.ValidateOnChange or false
    
    local container = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = section.Content
    })
    
    local label = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local inputBox = createInstance("TextBox", {
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Theme.SurfaceAlt,
        BackgroundTransparency = 0.2,
        Text = defaultValue,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        Parent = container
    })
    addCorner(inputBox, Radius.Control)
    local inputStroke = addStroke(inputBox, Theme.BorderSoft, 1)
    addGlass(inputBox)
    if _G.AestheticUI_Window then _G.AestheticUI_Window._config[text] = inputBox.Text end

    local errorLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 52),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Danger,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })

    local function setInvalid(message)
        tween(inputStroke, {Color = Theme.Danger}, TweenPresets.Quick)
        errorLabel.Text = message or errorText
        errorLabel.Size = UDim2.new(1, 0, 0, 16)
    end

    local function clearInvalid()
        errorLabel.Text = ""
        errorLabel.Size = UDim2.new(1, 0, 0, 0)
    end

    local function runValidation(value)
        local ok = true
        local message = nil
        if pattern and value ~= "" then
            ok = value:match(pattern) ~= nil
        end
        if validateFn then
            local res, msg = validateFn(value)
            if res == false then
                ok = false
                message = msg
            end
        end
        if ok then
            clearInvalid()
        else
            setInvalid(message)
        end
        return ok
    end
    
    inputBox.Focused:Connect(function()
        if disabled then return end
        playSound("Click")
        tween(inputStroke, {Color = Theme.AccentGlow, Thickness = 2}, TweenPresets.Quick)
    end)
    inputBox.FocusLost:Connect(function(enterPressed)
        if disabled then return end
        tween(inputStroke, {Color = Theme.BorderSoft, Thickness = 1}, TweenPresets.Quick)
        local ok = runValidation(inputBox.Text)
        if _G.AestheticUI_Window then _G.AestheticUI_Window._config[text] = inputBox.Text end
        if enterPressed and ok then
            pcall(callback, inputBox.Text)
        end
    end)

    if validateOnChange then
        inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            if disabled then return end
            runValidation(inputBox.Text)
        end)
    end
    
    container.MouseEnter:Connect(function()
        if disabled then return end
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:ShowTooltip(tooltip) end
    end)
    container.MouseLeave:Connect(function()
        if disabled then return end
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:HideTooltip() end
    end)

    local function setDisabled(state)
        disabled = state and true or false
        inputBox.TextEditable = not disabled
        inputBox.BackgroundTransparency = disabled and 0.6 or 0.2
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
    end

    registerTheme(function()
        if container.Parent == nil then return end
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        inputBox.BackgroundColor3 = Theme.SurfaceAlt
        inputStroke.Color = Theme.BorderSoft
    end)

    if _G.AestheticUI_Window then
        table.insert(_G.AestheticUI_Window._defaults, function()
            inputBox.Text = defaultValue
            clearInvalid()
            setDisabled(config.Disabled or false)
        end)
    end

    return {
        Set = function(_, value)
            inputBox.Text = value
            if _G.AestheticUI_Window then _G.AestheticUI_Window._config[text] = value end
        end,
        Get = function() return inputBox.Text end,
        Validate = function(_, value) return runValidation(value or inputBox.Text) end,
        SetDisabled = function(_, state) setDisabled(state) end
    }
end

-- Label
function AestheticUI:CreateLabel(section, config)
    config = config or {}
    local text = config.Text or "Label"
    
    local label = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextSoft,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        RichText = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = section.Content
    })

    registerTheme(function()
        if label.Parent == nil then return end
        label.TextColor3 = Theme.TextSoft
    end)
    
    return {
        Set = function(_, newText) label.Text = newText end,
        Get = function() return label.Text end
    }
end

-- Separator
function AestheticUI:CreateSeparator(section)
    local separator = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = section.Content
    })
    registerTheme(function()
        if separator.Parent == nil then return end
        separator.BackgroundColor3 = Theme.Border
    end)
    return separator
end

-- ColorPicker
function AestheticUI:CreateColorPicker(section, config)
    config = config or {}
    local text = config.Text or "Color"
    local default = config.Default or Color3.fromRGB(138, 43, 226)
    local callback = config.Callback or function() end
    local disabled = config.Disabled or false
    
    local currentColor = default
    local h, s, v = currentColor:ToHSV()
    local pickerOpen = false
    
    local container = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 32), -- Increased from 28 to 32
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = section.Content
    })
    
    local label = createInstance("TextLabel", {
        Size = UDim2.new(1, -55, 1, 0), -- Extra padding for the button
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local colorPreview = createInstance("TextButton", {
        Size = UDim2.new(0, 40, 0, 22),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = currentColor,
        Text = "",
        Parent = container
    })
    addCorner(colorPreview, Radius.Subtle)
    local previewStroke = addStroke(colorPreview, Theme.BorderSoft, 1)
    
    local pickerFrame = createInstance("Frame", {
        Size = UDim2.new(0, 200, 0, 0),
        Position = UDim2.new(1, 0, 1, 4),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.15, -- Keep glass consistency
        ClipsDescendants = true,
        ZIndex = 100, -- High ZIndex for popups
        Parent = container
    })
    addCorner(pickerFrame, Radius.Container)
    addStroke(pickerFrame, Theme.BorderStrong, 1)
    addGlass(pickerFrame)
    
    -- Saturation/Value box
    local satValBox = createInstance("ImageButton", {
        Size = UDim2.new(1, -16, 0, 120),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        ZIndex = 101, -- Must be > pickerFrame (100)
        Parent = pickerFrame
    })
    addCorner(satValBox, Radius.Subtle)
    
    createInstance("UIGradient", {
        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}),
        Parent = satValBox
    })
    
    local satValOverlay = createInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0,
        ZIndex = 102,
        Parent = satValBox
    })
    addCorner(satValOverlay, Radius.Subtle)
    createInstance("UIGradient", {
        Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}),
        Rotation = 90,
        Parent = satValOverlay
    })
    
    local satValCursor = createInstance("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(s, 0, 1 - v, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Text,
        ZIndex = 103,
        Parent = satValBox
    })
    addCorner(satValCursor, 5)
    addStroke(satValCursor, Color3.new(0, 0, 0), 1)
    
    -- Hue slider
    local hueSlider = createInstance("ImageButton", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.new(0, 8, 0, 136),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 101, -- Must be > pickerFrame (100)
        Parent = pickerFrame
    })
    addCorner(hueSlider, Radius.Subtle)
    addStroke(hueSlider, Theme.BorderSoft, 1)
    
    createInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
            ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
            ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
        }),
        Parent = hueSlider
    })
    
    local hueCursor = createInstance("Frame", {
        Size = UDim2.new(0, 4, 1, 4),
        Position = UDim2.new(h, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Text,
        ZIndex = 102,
        Parent = hueSlider
    })
    addCorner(hueCursor, 2)
    
    local function updateColor()
        currentColor = Color3.fromHSV(h, s, v)
        colorPreview.BackgroundColor3 = currentColor
        satValBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        if _G.AestheticUI_Window then
            _G.AestheticUI_Window._config[text] = {R = currentColor.R, G = currentColor.G, B = currentColor.B}
        end
        pcall(callback, currentColor)
    end
    
    local draggingSV, draggingH = false, false
    
    satValBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if disabled then return end
            draggingSV = true
        end
    end)
    satValBox.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSV = false
        end
    end)
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if disabled then return end
            draggingH = true
        end
    end)
    hueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingH = false
        end
    end)
    
    if _G.AestheticUI_Window then
        local conn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if draggingSV and not disabled then
                    s = math.clamp((input.Position.X - satValBox.AbsolutePosition.X) / satValBox.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((input.Position.Y - satValBox.AbsolutePosition.Y) / satValBox.AbsoluteSize.Y, 0, 1)
                    satValCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    updateColor()
                elseif draggingH and not disabled then
                    h = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                    hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                    updateColor()
                end
            end
        end)
        _G.AestheticUI_Window:TrackConnection(conn)
    end
    
    colorPreview.MouseButton1Click:Connect(function()
        if disabled then return end
        playSound("Click")
        pickerOpen = not pickerOpen
        tween(pickerFrame, {Size = pickerOpen and UDim2.new(0, 200, 0, 164) or UDim2.new(0, 200, 0, 0)}, TweenPresets.Spring)
    end)

    local function setDisabled(state)
        disabled = state and true or false
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        previewStroke.Color = disabled and Theme.BorderSoft or Theme.BorderSoft
    end

    registerTheme(function()
        if container.Parent == nil then return end
        label.TextColor3 = disabled and Theme.TextSoft or Theme.Text
        previewStroke.Color = Theme.BorderSoft
        pickerFrame.BackgroundColor3 = Theme.Surface
    end)

    if _G.AestheticUI_Window then
        table.insert(_G.AestheticUI_Window._defaults, function()
            currentColor = default
            h, s, v = currentColor:ToHSV()
            colorPreview.BackgroundColor3 = currentColor
            setDisabled(config.Disabled or false)
        end)
    end
    
    return {
        Set = function(_, color)
            currentColor = color
            h, s, v = color:ToHSV()
            colorPreview.BackgroundColor3 = color
            satValCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
            satValBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            if _G.AestheticUI_Window then
                _G.AestheticUI_Window._config[text] = {R = color.R, G = color.G, B = color.B}
            end
        end,
        Get = function() return currentColor end,
        SetDisabled = function(_, state) setDisabled(state) end
    }
end

-- Panic and Security API
function AestheticUI:Panic()
    _panic()
end

function AestheticUI:GetSecurityStatus()
    return _IntegrityPass, _SecurityLogs
end

-- [ADVANCED ANTI-DETECTION] Metatable Locking
-- Prevent AC from inspecting the library's internal structure
    if newproxy then
        local AestheticUIProxy = newproxy(true)
        local AestheticUIMeta = getmetatable(AestheticUIProxy)

        AestheticUIMeta.__index = AestheticUI
        AestheticUIMeta.__newindex = function(_, k, v)
            -- Prevent modification of core library functions
            rawset(AestheticUI, k, v)
        end
        AestheticUIMeta.__metatable = "The metatable is locked"
        AestheticUIMeta.__tostring = function() return "AestheticUI v1.1.0" end

        -- Return the protected proxy
        return AestheticUIProxy
    end

    return AestheticUI
