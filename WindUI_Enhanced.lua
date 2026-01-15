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
-- SECTION SYSTEM (Using WindUI's Native Window:Section)
-- ============================================================

function Enhanced:_CreateSection(window, options)
    options = options or {}
    
    -- Use WindUI's NATIVE Window:Section() method!
    -- This actually creates the sidebar section headers
    local nativeSection = window:Section({
        Title = options.Title or "Section",
        Icon = options.Icon,
        Opened = options.Opened ~= false
    })
    
    -- Wrap the native section with enhanced functionality
    local section = {
        _Native = nativeSection,
        Title = options.Title or "Section",
        Icon = options.Icon,
        Collapsible = options.Collapsible ~= false,
        Opened = options.Opened ~= false,
        Tabs = {},
        Window = window,
        Index = window._SectionIndex
    }
    
    window._SectionIndex = window._SectionIndex + 1
    
    -- Override AddTab to work with the native section
    section.AddTab = function(self, tabOptions)
        tabOptions = tabOptions or {}
        
        -- Create tab using original WindUI under this section
        local tab = window:Tab(tabOptions)
        
        -- Store reference
        table.insert(section.Tabs, tab)
        
        -- Add enhanced features to tab
        Enhanced:_EnhanceTab(tab, window)
        
        return tab
    end
    
    -- Toggle collapse/expand
    section.Toggle = function(self)
        section.Opened = not section.Opened
        -- Note: WindUI's native Section handles collapse automatically
    end
    
    -- Store section
    table.insert(window._Sections, section)
    
    print("[WindUI Enhanced] Section created: " .. section.Title .. " (using native Window:Section)")
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
-- CARD CONTAINER SYSTEM (Using Tab:Section for Visual Boxes)
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
    
    -- Use WindUI's native Section for visual container!
    -- Tab:Section creates a collapsible box - perfect for cards
    card.Container = tab:Section({
        Title = card.Title,
        Box = true,  -- Enable box styling
        Opened = true,  -- Always opened by default
        FontWeight = "Bold",
       TextSize = 15
    })
    
    -- If description provided, add it as paragraph
    if card.Description then
        card.Container:Paragraph({
            Title = "",
            Desc = card.Description
        })
    end
    
    -- Wrap element creation methods to use the Section container
    card.Toggle = function(self, toggleOptions)
        return card.Container:Toggle(toggleOptions)
    end
    
    card.Slider = function(self, sliderOptions)
        return card.Container:Slider(sliderOptions)
    end
    
    card.Dropdown = function(self, dropdownOptions)
        return card.Container:Dropdown(dropdownOptions)
    end
    
    card.Button = function(self, buttonOptions)
        return card.Container:Button(buttonOptions)
    end
    
    card.Paragraph = function(self, paragraphOptions)
        return card.Container:Paragraph(paragraphOptions)
    end
    
    card.Input = function(self, inputOptions)
        return card.Container:Input(inputOptions)
    end
    
    card.Keybind = function(self, keybindOptions)
        return card.Container:Keybind(keybindOptions)
    end
    
    card.Colorpicker = function(self, colorpickerOptions)
        return card.Container:Colorpicker(colorpickerOptions)
    end
    
    card.Code = function(self, codeOptions)
        return card.Container:Code(codeOptions)
    end
    
    -- Store card
    table.insert(tab._Cards, card)
    
    print("[WindUI Enhanced] Card created: " .. card.Title .. " (using Tab:Section)")
    return card
end

-- ============================================================
-- HELPER: Move Element to Card (NOT NEEDED - using Tab:Section)
-- ============================================================

function Enhanced:_MoveElementToCard(element, card)
    -- Not needed anymore - Tab:Section handles parenting
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
