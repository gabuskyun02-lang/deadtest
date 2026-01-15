--[[
    WindUI Enhanced - Wrapper Extension
    
    Adds features on top of WindUI:
    - ✨ Nested collapsible sections
    - 📦 Card-based grouping system  
    - 🎨 Glassmorphism styling
    - 📏 Better defaults & spacing
    
    Usage:
        local WindUI = loadstring(game:HttpGet("windui-url"))()
        local Enhanced = loadstring(readfile("WindUI_Enhanced.lua"))()
        Enhanced:Initialize(WindUI)
        
        local Window = Enhanced:CreateWindow({ ... })
        local Section = Window:CreateSection({ ... })
        local Tab = Section:AddTab({ ... })
        local Card = Tab:CreateCard({ ... })
]]

local Enhanced = {}
Enhanced.WindUI = nil
Enhanced.Version = "1.0.0"

-- Glassmorphism color palette
Enhanced.GlassTheme = {
    -- Dark base with transparency
    CardBackground = Color3.fromRGB(30, 35, 45),
    CardBackgroundTransparency = 0.3,
    CardBorder = Color3.fromRGB(60, 70, 85),
    CardBorderTransparency = 0.5,
    
    -- Section colors
    SectionHeader = Color3.fromRGB(25, 30, 40),
    SectionHeaderTransparency = 0.2,
    SectionDivider = Color3.fromRGB(70, 80, 95),
    
    -- Text colors
    TitleText = Color3.fromRGB(240, 245, 255),
    DescText = Color3.fromRGB(180, 190, 210),
    
    -- Accent
    Accent = Color3.fromRGB(100, 150, 255),
    AccentHover = Color3.fromRGB(120, 170, 255)
}

-- ============================================================
-- INITIALIZATION
-- ============================================================

function Enhanced:Initialize(windui)
    if not windui then
        error("[WindUI Enhanced] WindUI instance required for initialization")
    end
    
    self.WindUI = windui
    print("[WindUI Enhanced] Initialized successfully (v" .. self.Version .. ")")
    return self
end

-- ============================================================
-- ENHANCED WINDOW CREATION
-- ============================================================

function Enhanced:CreateWindow(options)
    if not self.WindUI then
        error("[WindUI Enhanced] Call Initialize() first before creating window")
    end
    
    -- Set better defaults
    options = options or {}
    options.Size = options.Size or UDim2.fromOffset(880, 520)
    options.SideBarWidth = options.SideBarWidth or 220
    
    -- Apply glassmorphism theme if requested
    if options.Theme == "Glassmorphism" then
        options.Theme = "Dark"  -- Use Dark as base
    end
    
    -- Create window using original WindUI
    local window = self.WindUI:CreateWindow(options)
    
    -- Add enhanced properties
    window._Enhanced = true
    window._Sections = {}
    window._SectionIndex = 0
    window._GlassTheme = options.Theme == "Glassmorphism"
    
    -- Inject CreateSection method
    window.CreateSection = function(self, sectionOptions)
        return Enhanced:_CreateSection(window, sectionOptions)
    end
    
    print("[WindUI Enhanced] Window created with enhanced features")
    return window
end

-- ============================================================
-- SECTION SYSTEM (Nested Collapsible Sidebar Groups)
-- ============================================================

function Enhanced:_CreateSection(window, options)
    options = options or {}
    
    local section = {
        Title = options.Title or "Section",
        Icon = options.Icon,
        Collapsible = options.Collapsible ~= false,
        Opened = options.Opened ~= false,
        Tabs = {},
        Window = window,
        Index = window._SectionIndex
    }
    
    window._SectionIndex = window._SectionIndex + 1
    
    -- Add tab management
    section.AddTab = function(self, tabOptions)
        tabOptions = tabOptions or {}
        
        -- Create tab using original WindUI
        local tab = window:Tab(tabOptions)
        
        -- Store reference
        table.insert(section.Tabs, tab)
        
        -- Add enhanced features to tab
        Enhanced:_EnhanceTab(tab, window)
        
        -- Initially hide if section is collapsed
        if not section.Opened then
            pcall(function()
                if tab.Frame then
                    tab.Frame.Visible = false
                end
            end)
        end
        
        return tab
    end
    
    -- Toggle collapse/expand
    section.Toggle = function(self)
        section.Opened = not section.Opened
        
        -- Show/hide tabs
        for _, tab in ipairs(section.Tabs) do
            pcall(function()
                if tab.Frame then
                    tab.Frame.Visible = section.Opened
                end
            end)
        end
    end
    
    -- Store section
    table.insert(window._Sections, section)
    
    print("[WindUI Enhanced] Section created: " .. section.Title)
    return section
end

-- ============================================================
-- TAB ENHANCEMENT (Add Card Support)
-- ============================================================

function Enhanced:_EnhanceTab(tab, window)
    tab._Enhanced = true
    tab._Cards = {}
    tab._GlassTheme = window._GlassTheme
    
    -- Inject CreateCard method
    tab.CreateCard = function(self, cardOptions)
        return Enhanced:_CreateCard(tab, cardOptions)
    end
    
    return tab
end

-- ============================================================
-- CARD CONTAINER SYSTEM
-- ============================================================

function Enhanced:_CreateCard(tab, options)
    options = options or {}
    
    local card = {
        Title = options.Title or "Card",
        Description = options.Description,
        Glass = options.Glass ~= false and tab._GlassTheme,
        Elements = {},
        Tab = tab
    }
    
    -- Create card UI container
    card.Container = self:_CreateCardUI(card, tab)
    
    -- Wrap element creation methods
    card.Toggle = function(self, toggleOptions)
        local toggle = tab:Toggle(toggleOptions)
        Enhanced:_MoveElementToCard(toggle, card)
        table.insert(card.Elements, toggle)
        return toggle
    end
    
    card.Slider = function(self, sliderOptions)
        local slider = tab:Slider(sliderOptions)
        Enhanced:_MoveElementToCard(slider, card)
        table.insert(card.Elements, slider)
        return slider
    end
    
    card.Dropdown = function(self, dropdownOptions)
        local dropdown = tab:Dropdown(dropdownOptions)
        Enhanced:_MoveElementToCard(dropdown, card)
        table.insert(card.Elements, dropdown)
        return dropdown
    end
    
    card.Button = function(self, buttonOptions)
        local button = tab:Button(buttonOptions)
        Enhanced:_MoveElementToCard(button, card)
        table.insert(card.Elements, button)
        return button
    end
    
    card.Paragraph = function(self, paragraphOptions)
        local paragraph = tab:Paragraph(paragraphOptions)
        Enhanced:_MoveElementToCard(paragraph, card)
        table.insert(card.Elements, paragraph)
        return paragraph
    end
    
    card.Input = function(self, inputOptions)
        local input = tab:Input(inputOptions)
        Enhanced:_MoveElementToCard(input, card)
        table.insert(card.Elements, input)
        return input
    end
    
    card.Keybind = function(self, keybindOptions)
        local keybind = tab:Keybind(keybindOptions)
        Enhanced:_MoveElementToCard(keybind, card)
        table.insert(card.Elements, keybind)
        return keybind
    end
    
    card.Colorpicker = function(self, colorpickerOptions)
        local colorpicker = tab:Colorpicker(colorpickerOptions)
        Enhanced:_MoveElementToCard(colorpicker, card)
        table.insert(card.Elements, colorpicker)
        return colorpicker
    end
    
    -- Store card
    table.insert(tab._Cards, card)
    
    print("[WindUI Enhanced] Card created: " .. card.Title)
    return card
end

-- ============================================================
-- CARD UI RENDERING
-- ============================================================

function Enhanced:_CreateCardUI(card, tab)
    -- Try to access tab's content frame
    local container = Instance.new("Frame")
    container.Name = "Card_" .. card.Title
    container.Size = UDim2.new(1, -20, 0, 0)  -- Auto-size based on content
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    
    -- Create card background with glassmorphism
    if card.Glass then
        local cardBg = Instance.new("Frame")
       cardBg.Name = "CardBackground"
        cardBg.Size = UDim2.new(1, 0, 1, 0)
        cardBg.BackgroundColor3 = self.GlassTheme.CardBackground
        cardBg.BackgroundTransparency = self.GlassTheme.CardBackgroundTransparency
        cardBg.Parent = container
        
        -- Rounded corners
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = cardBg
        
        -- Border
        local stroke = Instance.new("UIStroke")
        stroke.Color = self.GlassTheme.CardBorder
        stroke.Transparency = self.GlassTheme.CardBorderTransparency
        stroke.Thickness = 1
        stroke.Parent = cardBg
    end
    
    -- Card header (title)
    local header = Instance.new("TextLabel")
    header.Name = "CardHeader"
    header.Size = UDim2.new(1, -24, 0, 30)
    header.Position = UDim2.new(0, 12, 0, 8)
    header.BackgroundTransparency = 1
    header.Text = card.Title
    header.TextColor3 = self.GlassTheme.TitleText
    header.TextSize = 14
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = container
    
    -- Description (if provided)
    if card.Description then
        local desc = Instance.new("TextLabel")
        desc.Name = "CardDescription"
        desc.Size = UDim2.new(1, -24, 0, 20)
        desc.Position = UDim2.new(0, 12, 0, 35)
        desc.BackgroundTransparency = 1
        desc.Text = card.Description
        desc.TextColor3 = self.GlassTheme.DescText
        desc.TextSize = 12
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = container
    end
    
    -- Content container for elements
    local content = Instance.new("Frame")
    content.Name = "CardContent"
    content.Size = UDim2.new(1, -24, 0, 0)
    content.Position = UDim2.new(0, 12, 0, card.Description and 60 or 38)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.Parent = container
    
    -- Layout for content
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = content
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = container
    
    -- Try to parent to tab's content area
    pcall(function()
        if tab.Frame and tab.Frame:FindFirstChild("Content") then
            container.Parent = tab.Frame.Content
        elseif tab.Frame then
            container.Parent = tab.Frame
        end
    end)
    
    return container
end

-- ============================================================
-- HELPER: Move Element to Card
-- ============================================================

function Enhanced:_MoveElementToCard(element, card)
    pcall(function()
        if element.Frame and card.Container then
            local content = card.Container:FindFirstChild("CardContent")
            if content then
                element.Frame.Parent = content
            end
        end
    end)
end

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

function Enhanced:GetVersion()
    return self.Version
end

function Enhanced:IsInitialized()
    return self.WindUI ~= nil
end

-- ============================================================
-- RETURN MODULE
-- ============================================================

print("[WindUI Enhanced] Module loaded")
return Enhanced
