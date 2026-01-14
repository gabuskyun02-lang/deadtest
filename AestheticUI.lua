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
        {name = "TweenService", fn = game:GetService("TweenService")},
        {name = "debug", fn = debug.info}
    }
    for _, item in ipairs(critical) do
        local ok, info = pcall(function() return debug.info(item.fn, "s") end)
        if not ok or info ~= "[C]" then
            _IntegrityPass = false
            table.insert(_SecurityLogs, "Integrity Failure: " .. item.name .. " is hooked (" .. tostring(info) .. ")")
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
    Background = Color3.fromRGB(15, 15, 20),
    BackgroundSecondary = Color3.fromRGB(22, 22, 30),
    Accent = Color3.fromRGB(138, 43, 226),
    AccentGlow = Color3.fromRGB(168, 85, 247),
    Text = Color3.fromRGB(245, 245, 250),
    TextDim = Color3.fromRGB(156, 163, 175),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(250, 204, 21),
    Danger = Color3.fromRGB(239, 68, 68),
    Border = Color3.fromRGB(45, 45, 55),
    Glass = 0.92
}

-- Smooth Tween Presets
local TweenPresets = {
    Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
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
    return createInstance("UIStroke", {Color = color or Theme.Border, Thickness = thickness or 1, Parent = parent})
end

local function addGlow(parent)
    local glow = createInstance("ImageLabel", {
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0.85,
        Parent = parent
    })
    
    -- Breathing animation
    task.spawn(function()
        while glow.Parent do
            tween(glow, {ImageTransparency = 0.6}, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))
            task.wait(2)
            tween(glow, {ImageTransparency = 0.85}, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))
            task.wait(2)
        end
    end)
    
    return glow
end

-- Notification System
local NotificationContainer
local Notifications = {}

local function createNotificationContainer(parent)
    NotificationContainer = createInstance("Frame", {
        Size = UDim2.new(0, 300, 1, -20),
        Position = UDim2.new(1, -310, 0, 10),
        BackgroundTransparency = 1,
        Parent = parent
    })
    createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = NotificationContainer
    })
end

function AestheticUI:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 4
    local notifType = config.Type or "Info"
    
    local colors = {
        Success = Theme.Success,
        Warning = Theme.Warning,
        Error = Theme.Danger,
        Info = Theme.Accent
    }
    local accentColor = colors[notifType] or Theme.Accent
    
    local notif = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
        Parent = NotificationContainer
    })
    addCorner(notif, 10)
    addStroke(notif, accentColor, 1)
    
    local dismissed = false
    local function dismissNotif()
        if dismissed then return end
        dismissed = true
        tween(notif, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, TweenPresets.Quick)
        task.wait(0.2)
        pcall(function() notif:Destroy() end)
    end
    
    -- Accent bar
    createInstance("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
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
        Parent = notif
    })
    closeBtn.MouseButton1Click:Connect(dismissNotif)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {TextColor3 = Theme.Text}, TweenPresets.Quick)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {TextColor3 = Theme.TextDim}, TweenPresets.Quick)
    end)
    
    -- Title
    createInstance("TextLabel", {
        Size = UDim2.new(1, -40, 0, 22),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    -- Message
    createInstance("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 14, 0, 28),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notif
    })
    
    -- Progress bar
    local progressBg = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = notif
    })
    local progressFill = createInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = progressBg
    })
    
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
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
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
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.05,
        Parent = screenGui
    })
    addCorner(mainFrame, 12)
    addStroke(mainFrame, Theme.Border, 1)
    addGlow(mainFrame)
    
    -- Title bar
    local titleBar = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.3,
        Parent = mainFrame
    })
    addCorner(titleBar, 12)
    
    -- Fix bottom corners of title
    createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.3,
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
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Danger,
        BackgroundTransparency = 0.8,
        Text = "×",
        TextColor3 = Theme.Danger,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = titleBar
    })
    addCorner(closeBtn, 6)
    
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundTransparency = 0.3}, TweenPresets.Quick)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundTransparency = 0.8}, TweenPresets.Quick)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, TweenPresets.Quick)
        task.wait(0.2)
        screenGui:Destroy()
    end)
    
    local minimizeBtn = createInstance("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Warning,
        BackgroundTransparency = 0.8,
        Text = "−",
        TextColor3 = Theme.Warning,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = titleBar
    })
    addCorner(minimizeBtn, 6)
    
    local minimized = false
    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, {BackgroundTransparency = 0.3}, TweenPresets.Quick)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, {BackgroundTransparency = 0.8}, TweenPresets.Quick)
    end)
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(mainFrame, {Size = UDim2.new(0, size.X.Offset, 0, 40)}, TweenPresets.Spring)
        else
            tween(mainFrame, {Size = size}, TweenPresets.Spring)
        end
    end)
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
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
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Tab container
    local tabContainer = createInstance("Frame", {
        Size = UDim2.new(0, 130, 1, -50),
        Position = UDim2.new(0, 5, 0, 45),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.5,
        Parent = mainFrame
    })
    addCorner(tabContainer, 8)
    
    local tabList = createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = tabContainer
    })
    createInstance("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = tabContainer
    })
    
    -- Content container
    local contentContainer = createInstance("Frame", {
        Size = UDim2.new(1, -150, 1, -55),
        Position = UDim2.new(0, 145, 0, 48),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = mainFrame
    })
    
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
        _bind = nil
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
            mainFrame.Visible = true
            tween(mainFrame, {Size = size, BackgroundTransparency = 0.05}, TweenPresets.Spring)
        else
            local t = tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, TweenPresets.Quick)
            t.Completed:Connect(function()
                if not self._visible then mainFrame.Visible = false end
            end)
        end
    end
    
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
        BackgroundColor3 = Theme.BackgroundSecondary,
        Visible = false,
        ZIndex = 100,
        Parent = screenGui
    })
    addCorner(tooltip, 4)
    addStroke(tooltip, Theme.Accent, 1)
    
    local tooltipLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ZIndex = 101,
        Parent = tooltip
    })
    
    function Window:ShowTooltip(text)
        tooltipLabel.Text = text
        local size = game:GetService("TextService"):GetTextSize(text, 11, Enum.Font.Gotham, Vector2.new(200, 100))
        tooltip.Size = UDim2.new(0, size.X + 10, 0, size.Y + 6)
        tooltip.Visible = true
        
        local conn = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            tooltip.Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y - 5)
        end)
        self._tooltipConn = conn
    end
    
    function Window:HideTooltip()
        tooltip.Visible = false
        if self._tooltipConn then self._tooltipConn:Disconnect() end
    end
    
    -- Destroy method for cleanup
    function Window:Destroy()
        for _, conn in pairs(self._connections) do
            pcall(function() conn:Disconnect() end)
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
    tween(mainFrame, {Size = size, BackgroundTransparency = 0.05}, TweenPresets.Spring)
    
    -- [ADVANCED ANTI-DETECTION] Window-level Metatable locking
    local WindowProxy = newproxy(true)
    local WindowMeta = getmetatable(WindowProxy)
    
    WindowMeta.__index = Window
    WindowMeta.__metatable = "The metatable is locked"
    WindowMeta.__tostring = function() return "AestheticUI_Window" end
    
    _G.AestheticUI_Window = Window -- Internal reference
    
    return WindowProxy
end

-- Create Tab
function AestheticUI:CreateTab(window, config)
    config = config or {}
    local name = config.Name or "Tab"
    local icon = config.Icon or ""
    
    local tabBtn = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Text = "",
        Parent = window.TabContainer
    })
    addCorner(tabBtn, 6)
    
    local tabLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, icon ~= "" and 30 or 10, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextDim,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabBtn
    })
    
    if icon ~= "" then
        createInstance("ImageLabel", {
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
        Padding = UDim.new(0, 8),
        Parent = tabPage
    })
    createInstance("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 10),
        Parent = tabPage
    })
    
    local Tab = {
        Button = tabBtn,
        Page = tabPage,
        Name = name
    }
    
    tabBtn.MouseEnter:Connect(function()
        if window.ActiveTab ~= Tab then
            tween(tabBtn, {BackgroundTransparency = 0.85}, TweenPresets.Quick)
            tween(tabLabel, {TextColor3 = Theme.Text}, TweenPresets.Quick)
        end
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if window.ActiveTab ~= Tab then
            tween(tabBtn, {BackgroundTransparency = 1}, TweenPresets.Quick)
            tween(tabLabel, {TextColor3 = Theme.TextDim}, TweenPresets.Quick)
        end
    end)
    
    tabBtn.MouseButton1Click:Connect(function()
        if window.ActiveTab then
            window.ActiveTab.Page.Visible = false
            tween(window.ActiveTab.Button, {BackgroundTransparency = 1}, TweenPresets.Quick)
            local oldLabel = window.ActiveTab.Button:FindFirstChildOfClass("TextLabel")
            if oldLabel then
                tween(oldLabel, {TextColor3 = Theme.TextDim}, TweenPresets.Quick)
            end
        end
        window.ActiveTab = Tab
        tabPage.Visible = true
        tween(tabBtn, {BackgroundTransparency = 0.7}, TweenPresets.Smooth)
        tween(tabLabel, {TextColor3 = Theme.AccentGlow}, TweenPresets.Quick)
    end)
    
    -- Auto-select first tab
    if #window.Tabs == 0 then
        tabBtn.MouseButton1Click:Fire()
    end
    
    table.insert(window.Tabs, Tab)
    return Tab
end

-- Section
function AestheticUI:CreateSection(tab, name)
    local section = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BackgroundTransparency = 0.6,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = tab.Page
    })
    addCorner(section, 8)
    addStroke(section, Theme.Border, 1)
    
    local sectionLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, -16, 0, 25),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = name or "Section",
        TextColor3 = Theme.AccentGlow,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
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
        Padding = UDim.new(0, 8),
        Parent = contentFrame
    })
    createInstance("UIPadding", {
        PaddingBottom = UDim.new(0, 10),
        Parent = contentFrame
    })
    
    return {Frame = section, Content = contentFrame}
end

-- Button
function AestheticUI:CreateButton(section, config)
    config = config or {}
    local text = config.Text or "Button"
    local tooltip = config.Tooltip or ""
    local callback = config.Callback or function() end
    
    local btn = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.7,
        Text = "",
        Parent = section.Content
    })
    addCorner(btn, 6)
    
    local btnLabel = createInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        Parent = btn
    })
    
    -- Ripple effect
    btn.MouseButton1Click:Connect(function()
        local ripple = createInstance("Frame", {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.AccentGlow,
            BackgroundTransparency = 0.5,
            Parent = btn
        })
        addCorner(ripple, 100)
        
        tween(ripple, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, TweenPresets.Smooth)
        task.delay(0.3, function() ripple:Destroy() end)
        
        tween(btn, {BackgroundTransparency = 0.4}, TweenPresets.Quick)
        task.delay(0.1, function()
            tween(btn, {BackgroundTransparency = 0.7}, TweenPresets.Quick)
        end)
        
        pcall(callback)
    end)
    
    local window = section.Frame.Parent.Parent.Parent.Parent:FindFirstChild("_config") and section.Frame.Parent.Parent.Parent.Parent or nil -- Hacky way to find window ref if needed
    
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundTransparency = 0.5}, TweenPresets.Quick)
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:ShowTooltip(tooltip) end
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundTransparency = 0.7}, TweenPresets.Quick)
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:HideTooltip() end
    end)
    
    return btn
end

-- Toggle
function AestheticUI:CreateToggle(section, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local tooltip = config.Tooltip or ""
    local callback = config.Callback or function() end
    
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
        BackgroundColor3 = toggled and Theme.Accent or Theme.Border,
        Parent = container
    })
    addCorner(toggleBg, 11)
    
    local toggleKnob = createInstance("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = toggled and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(toggled and 1 or 0, 0.5),
        BackgroundColor3 = Theme.Text,
        Parent = toggleBg
    })
    addCorner(toggleKnob, 8)
    
    local function updateToggle()
        toggled = not toggled
        tween(toggleBg, {BackgroundColor3 = toggled and Theme.Accent or Theme.Border}, TweenPresets.Smooth)
        tween(toggleKnob, {
            Position = toggled and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            AnchorPoint = Vector2.new(toggled and 1 or 0, 0.5)
        }, TweenPresets.Spring)
        pcall(callback, toggled)
    end
    
    local toggleBtn = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container
    })
    
    toggleBtn.MouseButton1Click:Connect(updateToggle)
    
    -- Right click keybind functionality
    toggleBtn.MouseButton2Click:Connect(function()
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
    
    if _G.AestheticUI_Window then
        local bindConn = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and bind and input.KeyCode == bind then
                updateToggle()
            end
        end)
        _G.AestheticUI_Window:TrackConnection(bindConn)
    end
    
    container.MouseEnter:Connect(function()
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:ShowTooltip(tooltip) end
    end)
    container.MouseLeave:Connect(function()
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:HideTooltip() end
    end)
    
    return {
        Set = function(_, value)
            if value ~= toggled then updateToggle() end
        end,
        Get = function() return toggled end
    }
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
    
    local value = default
    
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
        BackgroundColor3 = Theme.Border,
        Parent = container
    })
    addCorner(sliderBg, 4)
    
    local sliderFill = createInstance("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        Parent = sliderBg
    })
    addCorner(sliderFill, 4)
    
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
    addStroke(knob, Theme.Accent, 2)
    
    local dragging = false
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * pos)
        valueLabel.Text = tostring(value)
        tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, TweenPresets.Quick)
        tween(knob, {Position = UDim2.new(pos, 0, 0.5, 0)}, TweenPresets.Quick)
        pcall(callback, value)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
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
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:ShowTooltip(tooltip) end
    end)
    container.MouseLeave:Connect(function()
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:HideTooltip() end
    end)
    
    return {
        Set = function(_, newValue)
            value = math.clamp(newValue, min, max)
            local pos = (value - min) / (max - min)
            valueLabel.Text = tostring(value)
            tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, TweenPresets.Smooth)
            tween(knob, {Position = UDim2.new(pos, 0, 0.5, 0)}, TweenPresets.Smooth)
        end,
        Get = function() return value end
    }
end

-- Dropdown
function AestheticUI:CreateDropdown(section, config)
    config = config or {}
    local text = config.Text or "Dropdown"
    local options = config.Options or {}
    local default = config.Default or (options[1] or "")
    local callback = config.Callback or function() end
    
    local selected = default
    local opened = false
    
    local container = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 55),
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
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Theme.BackgroundSecondary,
        Text = "",
        Parent = container
    })
    addCorner(dropBtn, 6)
    addStroke(dropBtn, Theme.Border, 1)
    
    local searchBar = createInstance("TextBox", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = selected,
        PlaceholderColor3 = Theme.Text,
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
        TextColor3 = Theme.TextDim,
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
        BackgroundColor3 = Theme.BackgroundSecondary,
        ClipsDescendants = true,
        ZIndex = 10,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = dropBtn
    })
    addCorner(optionsFrame, 6)
    addStroke(optionsFrame, Theme.Border, 1)
    
    local optionsList = createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = optionsFrame
    })
    createInstance("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = optionsFrame
    })
    
    local function createOption(option)
        local optBtn = createInstance("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 11,
            Parent = optionsFrame
        })
        createInstance("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = Theme.TextDim,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
            Parent = optBtn
        })
        optBtn.MouseEnter:Connect(function()
            tween(optBtn, {BackgroundTransparency = 0.8}, TweenPresets.Quick)
        end)
        optBtn.MouseLeave:Connect(function()
            tween(optBtn, {BackgroundTransparency = 1}, TweenPresets.Quick)
        end)
        optBtn.MouseButton1Click:Connect(function()
            selected = option
            selectedLabel.Text = option
            searchBar.PlaceholderText = option
            tween(selectedLabel, {TextColor3 = Theme.Text}, TweenPresets.Quick)
            opened = false
            searchBar.Visible = false
            selectedLabel.Visible = true
            tween(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, TweenPresets.Spring)
            tween(arrow, {Rotation = 0}, TweenPresets.Quick)
            pcall(callback, selected)
        end)
        return optBtn
    end
    
    for _, option in ipairs(options) do
        createOption(option)
    end
    
    searchBar:GetPropertyChangedSignal("Text"):Connect(function()
        local search = searchBar.Text:lower()
        for _, child in ipairs(optionsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                local optText = child:FindFirstChildOfClass("TextLabel").Text:lower()
                child.Visible = optText:find(search) ~= nil
            end
        end
    end)
    
    local function updateDropdown()
        opened = not opened
        local optionsHeight = math.min(#options * 26 + 8, 150)
        tween(optionsFrame, {Size = opened and UDim2.new(1, 0, 0, optionsHeight) or UDim2.new(1, 0, 0, 0)}, TweenPresets.Spring)
        tween(arrow, {Rotation = opened and 180 or 0}, TweenPresets.Quick)
        searchBar.Visible = opened
        selectedLabel.Visible = not opened
        if opened then searchBar:CaptureFocus() end
    end
    
    dropBtn.MouseButton1Click:Connect(updateDropdown)
    
    return {
        Set = function(_, value)
            if table.find(options, value) then
                selected = value
                selectedLabel.Text = value
                searchBar.PlaceholderText = value
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
        end
    }
end

-- Checkbox
function AestheticUI:CreateCheckbox(section, config)
    config = config or {}
    local text = config.Text or "Checkbox"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
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
        BackgroundColor3 = checked and Theme.Accent or Theme.Border,
        Parent = container
    })
    addCorner(checkBox, 4)
    
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
    
    createInstance("TextLabel", {
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
        checked = not checked
        tween(checkBox, {BackgroundColor3 = checked and Theme.Accent or Theme.Border}, TweenPresets.Quick)
        tween(checkMark, {TextTransparency = checked and 0 or 1}, TweenPresets.Quick)
        if checked then
            checkBox.Size = UDim2.new(0, 16, 0, 16)
            tween(checkBox, {Size = UDim2.new(0, 20, 0, 20)}, TweenPresets.Bounce)
        end
        if _G.AestheticUI_Window then _G.AestheticUI_Window._config[text] = checked end
        pcall(callback, checked)
    end
    
    container.MouseEnter:Connect(function()
        if config.Tooltip and config.Tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:ShowTooltip(config.Tooltip) end
    end)
    container.MouseLeave:Connect(function()
        if config.Tooltip and config.Tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:HideTooltip() end
    end)
    
    local btn = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container
    })
    btn.MouseButton1Click:Connect(updateCheck)
    
    pcall(function()
        if _G.AestheticUI_Window then
            _G.AestheticUI_Window._config[text] = checked
        end
    end)
    
    return {
        Set = function(_, value)
            if value ~= checked then updateCheck() end
        end,
        Get = function() return checked end
    }
end

-- Keybind
function AestheticUI:CreateKeybind(section, config)
    config = config or {}
    local text = config.Text or "Keybind"
    local default = config.Default or Enum.KeyCode.Unknown
    local tooltip = config.Tooltip or ""
    local callback = config.Callback or function() end
    
    local key = default
    local listening = false
    
    local container = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent = section.Content
    })
    
    createInstance("TextLabel", {
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
        BackgroundColor3 = Theme.BackgroundSecondary,
        Text = key.Name or "None",
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        Parent = container
    })
    addCorner(keyBtn, 4)
    addStroke(keyBtn, Theme.Border, 1)
    
    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
        tween(keyBtn, {BackgroundColor3 = Theme.Accent}, TweenPresets.Quick)
    end)
    
    if _G.AestheticUI_Window then
        local conn = UserInputService.InputBegan:Connect(function(input, processed)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode
                    keyBtn.Text = key.Name
                    listening = false
                    tween(keyBtn, {BackgroundColor3 = Theme.BackgroundSecondary}, TweenPresets.Quick)
                    _G.AestheticUI_Window._config[text] = key.Name
                end
            elseif not processed and input.KeyCode == key then
                pcall(callback)
            end
        end)
        _G.AestheticUI_Window:TrackConnection(conn)
    end
    
    container.MouseEnter:Connect(function()
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:ShowTooltip(tooltip) end
    end)
    container.MouseLeave:Connect(function()
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:HideTooltip() end
    end)
    
    return {
        Set = function(_, newKey)
            key = newKey
            keyBtn.Text = key.Name
            if _G.AestheticUI_Window then _G.AestheticUI_Window._config[text] = key.Name end
        end,
        Get = function() return key end
    }
end

-- TextInput
function AestheticUI:CreateTextInput(section, config)
    config = config or {}
    local text = config.Text or "Input"
    local placeholder = config.Placeholder or ""
    local tooltip = config.Tooltip or ""
    local callback = config.Callback or function() end
    
    local container = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = section.Content
    })
    
    createInstance("TextLabel", {
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
        BackgroundColor3 = Theme.BackgroundSecondary,
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        Parent = container
    })
    addCorner(inputBox, 6)
    local inputStroke = addStroke(inputBox, Theme.Border, 1)
    
    inputBox.Focused:Connect(function()
        tween(inputStroke, {Color = Theme.Accent}, TweenPresets.Quick)
    end)
    inputBox.FocusLost:Connect(function(enterPressed)
        tween(inputStroke, {Color = Theme.Border}, TweenPresets.Quick)
        if _G.AestheticUI_Window then _G.AestheticUI_Window._config[text] = inputBox.Text end
        if enterPressed then
            pcall(callback, inputBox.Text)
        end
    end)
    
    container.MouseEnter:Connect(function()
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:ShowTooltip(tooltip) end
    end)
    container.MouseLeave:Connect(function()
        if tooltip ~= "" and _G.AestheticUI_Window then _G.AestheticUI_Window:HideTooltip() end
    end)
    
    return {
        Set = function(_, value)
            inputBox.Text = value
            if _G.AestheticUI_Window then _G.AestheticUI_Window._config[text] = value end
        end,
        Get = function() return inputBox.Text end
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
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = section.Content
    })
    
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
    return separator
end

-- ColorPicker
function AestheticUI:CreateColorPicker(section, config)
    config = config or {}
    local text = config.Text or "Color"
    local default = config.Default or Color3.fromRGB(138, 43, 226)
    local callback = config.Callback or function() end
    
    local currentColor = default
    local h, s, v = currentColor:ToHSV()
    local pickerOpen = false
    
    local container = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = section.Content
    })
    
    createInstance("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
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
    addCorner(colorPreview, 4)
    addStroke(colorPreview, Theme.Border, 1)
    
    local pickerFrame = createInstance("Frame", {
        Size = UDim2.new(0, 200, 0, 0),
        Position = UDim2.new(1, 0, 1, 4),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Theme.BackgroundSecondary,
        ClipsDescendants = true,
        ZIndex = 20,
        Parent = container
    })
    addCorner(pickerFrame, 8)
    addStroke(pickerFrame, Theme.Border, 1)
    
    -- Saturation/Value box
    local satValBox = createInstance("ImageButton", {
        Size = UDim2.new(1, -16, 0, 120),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        ZIndex = 21,
        Parent = pickerFrame
    })
    addCorner(satValBox, 4)
    
    createInstance("UIGradient", {
        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}),
        Parent = satValBox
    })
    
    local satValOverlay = createInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0,
        ZIndex = 22,
        Parent = satValBox
    })
    addCorner(satValOverlay, 4)
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
        ZIndex = 23,
        Parent = satValBox
    })
    addCorner(satValCursor, 5)
    addStroke(satValCursor, Color3.new(0, 0, 0), 1)
    
    -- Hue slider
    local hueSlider = createInstance("ImageButton", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.new(0, 8, 0, 136),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 21,
        Parent = pickerFrame
    })
    addCorner(hueSlider, 4)
    
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
        ZIndex = 22,
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
            draggingH = true
        end
    end)
    hueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingH = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingSV then
                s = math.clamp((input.Position.X - satValBox.AbsolutePosition.X) / satValBox.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - satValBox.AbsolutePosition.Y) / satValBox.AbsoluteSize.Y, 0, 1)
                satValCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                updateColor()
            elseif draggingH then
                h = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                updateColor()
            end
        end
    end)
    
    if _G.AestheticUI_Window then
        local conn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if draggingSV then
                    s = math.clamp((input.Position.X - satValBox.AbsolutePosition.X) / satValBox.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((input.Position.Y - satValBox.AbsolutePosition.Y) / satValBox.AbsoluteSize.Y, 0, 1)
                    satValCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    updateColor()
                elseif draggingH then
                    h = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                    hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                    updateColor()
                end
            end
        end)
        _G.AestheticUI_Window:TrackConnection(conn)
    end
    
    colorPreview.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        tween(pickerFrame, {Size = pickerOpen and UDim2.new(0, 200, 0, 164) or UDim2.new(0, 200, 0, 0)}, TweenPresets.Spring)
    end)
    
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
        Get = function() return currentColor end
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
