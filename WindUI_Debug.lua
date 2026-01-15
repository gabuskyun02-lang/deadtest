-- Debug script to explore WindUI's internal structure
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Debug",
    Size = UDim2.fromOffset(580, 460)
})

-- Try to find window's internal structure
print("=== WindUI Window Structure Debug ===")

-- Print all properties
for k, v in pairs(Window) do
    print(string.format("[Window.%s] = %s", tostring(k), tostring(typeof(v))))
end

-- Try to find UI elements
if Window.UIElements then
    print("\n=== Window.UIElements ===")
    for k, v in pairs(Window.UIElements) do
        print(string.format("[UIElements.%s] = %s", tostring(k), tostring(v)))
    end
end

-- Create a tab to see tab structure
local Tab = Window:Tab({ Title = "Test" })

print("\n=== Tab Structure ===")
for k, v in pairs(Tab) do
    print(string.format("[Tab.%s] = %s", tostring(k), tostring(typeof(v))))
end

-- Try to find sidebar
local function findFramesByName(parent, name, results)
    results = results or {}
    for _, child in ipairs(parent:GetChildren()) do
        if child.Name:lower():find(name:lower()) then
            table.insert(results, child)
            print(string.format("Found: %s (%s)", child:GetFullName(), child.ClassName))
        end
        if child:IsA("GuiObject") then
            findFramesByName(child, name, results)
        end
    end
    return results
end

print("\n=== Searching for SideBar/Tabs ===")
local gui = game:GetService("CoreGui"):FindFirstChild("WindUI")
if gui then
    findFramesByName(gui, "tab")
    findFramesByName(gui, "side")
    findFramesByName(gui, "content")
end
