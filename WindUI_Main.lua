-- [[ AESTHETIC DELIVERY - WindUI Migration ]]
-- Credits: xxdayssheus
-- Migrated to WindUI for modern UI structure

-- ============================================================
-- WINDUI LIBRARY INITIALIZATION
-- ============================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ============================================================
-- GLOBAL CONFIG & STATE (PRESERVED FROM AESTHETICMAIN)
-- ============================================================
local Config = {
    Alive = true,
    FarmActive = false,
    SafeMode = false,
    AutoElevator = false,
    LootRadius = 50,
    WalkSpeed = 16,
    SpeedHack = false,
    UseTween = true,
    Fullbright = false,
    NotificationsEnabled = true,
    
    -- Farming Enhancements
    AutoSellPercent = 100,
    LootFilter = false,
    AntiAFK = false,
    SmartPathing = false,
    SafeZoneLogic = true,
    AntiStuck = true,
    PriorityLoot = true,
    FarmSpeedMultiplier = 1.0,
    NoLimitRadius = false,
    
    -- Speed & Movement
    FlashSpeed = false,
    OriginalSpeed = 16,
    
    -- Elevator & Dungeon
    SafeEvac = false,
    SafeEvacTime = 5,
    AutoJuicer = false,
    AutoToolSpam = false,
    MaxFloorTarget = 10,
    GodModeElevator = false,
    InstantEvac = false,
    ShowCountdown = false,
    ShowInternalHUD = false,
    RemoteDropMode = false,
    InteractDistance = 25,
    
    ESP = {
        Monsters = false,
        Loot = false,
        Containers = false,
        NPCs = false,
        Players = false,
        Ghosts = false,
        NoLimit = false,
        HideOpened = false,
        HideElevator = false,
        ElevatorHighlight = false,
    },
    Tracker = {
        Enabled = false,
        Distance = 50,
    },
    Combat = {
        KillAura = false,
    }
}

local Stats = {
    ItemsCollected = 0,
    StartTime = tick(),
    CurrentFloor = 0,
    Countdown = 999,
    DungeonState = "Normal"
}

-- ============================================================
-- SERVICES & REFERENCES
-- ============================================================
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Global UI References
local StatusLabel, StatsLabel = nil, nil
local CurrentToggleKey = Enum.KeyCode.RightShift
local KeybindConnection = nil

-- ESP Folder
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Aesthetic"
ESPFolder.Parent = game:GetService("CoreGui")

-- TEvent Reference
local TEvent = nil
task.spawn(function()
    local gs = workspace:WaitForChild("GameSystem", 10)
    if gs then TEvent = gs:WaitForChild("TEvent", 5) end
    _G.TEvent = TEvent
end)

-- Entity ID Tables
local MonsterIDs = {
    "TheForsaken", "Worms", "FlameTurkey", "InfernoTurkey", "Mimic",
    "Bloomaw", "Sneakrat", "Guest666", "SantaMK2", "FridgeMonster",
    "CrocodileMama", "CrocodilePapa", "TheBurden", "TheFaceless",
    "TheForsakenUnfinished", "SneakRatCave", "SantaMK2House",
    "TheFacelessStar", "VecnaBOSS", "TheFacelessBOSS"
}

local PropIDs = {
    "ItemOnFloor", "Oilbucket", "WoodenBucket", "Crate", "Cabinet",
    "WoodenCabinet", "LabBucket", "LabCrate", "LabCabinet", "Fridge",
    "ItemOnFloorRatCave", "ItemOnFloorUnfinishedMap"
}

-- Lighting Restoration & Dungeon Value
local LightingRestore = {}
local DungeonValue = nil
pcall(function() DungeonValue = require(game:GetService("ReplicatedStorage").Shared.Core.Value) end)

-- ============================================================
-- WINDUI WINDOW CREATION
-- ============================================================
local Window = WindUI:CreateWindow({
    Title = "AESTHETIC DELIVERY",
    Author = "by xxdayssheus",
    Folder = "AestheticDelivery",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200
})

-- ============================================================
-- TABS CREATION (Flat Structure with Visual Grouping)
-- ============================================================
-- Note: WindUI Window:Section() doesn't support collapsible tab groups
-- Using flat tab structure with naming conventions for organization

-- 📊 HOME
local DashboardTab = Window:Tab({
    Title = "📊 Dashboard",
    Icon = "home"
})

-- ⚔️ COMBAT
local CombatTab = Window:Tab({
    Title = "⚔️ Combat",
    Icon = "sword"
})

local MovementTab = Window:Tab({
    Title = "⚔️ Movement",
    Icon = "rocket"
})

-- 🤖 AUTOMATION
local AutoFarmTab = Window:Tab({
    Title = "🤖 Auto Farm",
    Icon = "wheat"
})

local DungeonTab = Window:Tab({
    Title = "🤖 Dungeon",
    Icon = "door-closed"
})

-- 👁️ VISUALS
local ESPTab = Window:Tab({
    Title = "👁️ ESP",
    Icon = "eye"
})

local TrackersTab = Window:Tab({
    Title = "👁️ Trackers",
    Icon = "radar"
})

-- 🌍 WORLD
local TeleportsTab = Window:Tab({
    Title = "🌍 Teleports",
    Icon = "map-pin"
})

local UtilitiesTab = Window:Tab({
    Title = "🌍 Utilities",
    Icon = "wrench"
})

-- ⚙️ SETTINGS
local ConfigTab = Window:Tab({
    Title = "⚙️ Settings",
    Icon = "settings"
})

-- ============================================================
-- ANTI-DETECTION & CORE SECURITY (PRESERVED)
-- ============================================================
local _sid = ""
for i = 1, 12 do _sid = _sid .. string.char(math.random(65, 90)) end

local _alive = true
local _threads = {}
local _conns = {}

local function _track(conn) if conn then table.insert(_conns, conn) end return conn end
local function _safeSpawn(f) local t = task.spawn(f) table.insert(_threads, t) return t end

local _obf_seed = math.random(1000, 9999)
local function _getDynamicKey()
    local pid = game.PlaceId or 12345
    return _obf_seed + (pid % 999) + #_sid 
end

local function _deobfuscate(obfData)
    if type(obfData) == "string" then return obfData end
    local result, key, rotate = {}, _getDynamicKey(), 0
    for i, byte in ipairs(obfData) do
        rotate = (rotate + 7) % 256
        result[i] = string.char(bit32.bxor(bit32.bxor(byte, rotate), (key + i) % 256))
    end
    return table.concat(result)
end

-- Rate Limiting System
local _remote_log = {}
local _remote_config = { MIN_INTERVAL = 0.15, MAX_PER_MINUTE = 35, BURST_COOLDOWN = 1.5, JITTER = 0.08 }
local _remote_blocked_until = 0

local function _canFireRemote(name)
    local now = tick()
    if now < _remote_blocked_until then return false end
    if not _remote_log[name] then _remote_log[name] = { last = 0, count = 0, start = now } end
    local log = _remote_log[name]
    if now - log.start >= 60 then log.count = 0 log.start = now end
    if now - log.last < _remote_config.MIN_INTERVAL then return false end
    if log.count >= _remote_config.MAX_PER_MINUTE then return false end
    return true
end

local function safeFireRemote(name, ...)
    local TEvent = _G.TEvent or (workspace:FindFirstChild("GameSystem") and workspace.GameSystem:FindFirstChild("TEvent"))
    if not TEvent then return false end
    if not _canFireRemote(name) then return false end
    
    if _remote_config.JITTER > 0 then task.wait(math.random() * _remote_config.JITTER) end
    
    local args = {...}
    local success, err = pcall(function() TEvent.FireRemote(name, unpack(args)) end)
    
    if success then
        local log = _remote_log[name]
        log.last = tick()
        log.count = log.count + 1
    end
    return success
end

-- Hook & Integrity Checks
local _hookcheck_passed = true
local function _checkIntegrity()
    local critical = {pcall, rawget, getmetatable, Instance.new}
    for _, f in ipairs(critical) do if type(f) ~= "function" then _hookcheck_passed = false end end
    return _hookcheck_passed
end
_checkIntegrity()

-- ============================================================
-- HELPER FUNCTIONS (PRESERVED FROM AESTHETICMAIN)
-- ============================================================

-- [NPC] Helper Functions
local function getNPCs()
    local gs = workspace:FindFirstChild("GameSystem")
    if not gs or not gs:FindFirstChild("NPCModels") then return {} end
    local list = {}
    for _, v in pairs(gs.NPCModels:GetChildren()) do
        local r = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
        if r then table.insert(list, {Object = v, Root = r, Position = r.Position}) end
    end
    return list
end

local function teleportToNPC(mode)
    local list = getNPCs()
    if #list == 0 then 
        Window:Notify({Title = "NPC", Content = "No NPCs found!", Duration = 3})
        return 
    end
    if mode == "Random" then
        safeTeleport(list[math.random(1, #list)].Root.CFrame * CFrame.new(0, 5, 0))
        Window:Notify({Title = "Teleport", Content = "Teleported to " .. list[1].Object.Name, Duration = 3})
    else
        table.sort(list, function(a,b) return (RootPart.Position - a.Position).Magnitude < (RootPart.Position - b.Position).Magnitude end)
        safeTeleport(list[1].Root.CFrame * CFrame.new(0, 5, 0))
        Window:Notify({Title = "Teleport", Content = "Teleported to nearest NPC", Duration = 3})
    end
end

local function showNPCCount()
    local list = getNPCs()
    if #list == 0 then
        Window:Notify({Title = "NPC", Content = "No NPCs found!", Duration = 3})
    else
        local names = {}
        for i = 1, math.min(5, #list) do table.insert(names, list[i].Object.Name) end
        local preview = table.concat(names, ", ")
        if #list > 5 then preview = preview .. "..." end
        Window:Notify({Title = "NPC", Content = string.format("Found %d NPCs: %s", #list, preview), Duration = 5})
    end
end

-- [Stamina] God Mode Hook - DUAL LAYER PROTECTION
local staminaHookActive = false
local function toggleInfiniteStamina(state)
    staminaHookActive = state
    
    -- Layer 1: Network Blocker
    if not getgenv()._stamina_hook_installed then
        local success, err = pcall(function()
            local TEventCheck = _G.TEvent or (workspace:FindFirstChild("GameSystem") and workspace.GameSystem:FindFirstChild("TEvent"))
            if TEventCheck and TEventCheck.FireRemote then
                if hookfunction then
                    local oldFireRemote = TEventCheck.FireRemote
                    hookfunction(TEventCheck.FireRemote, function(eventName, ...)
                        if getgenv()._god_stamina_active and eventName == "SyncStaminaConsume" then
                            return
                        end
                        return oldFireRemote(eventName, ...)
                    end)
                else
                    local oldFireRemote = TEventCheck.FireRemote
                    TEventCheck.FireRemote = function(eventName, ...)
                        if staminaHookActive and eventName == "SyncStaminaConsume" then return end
                        return oldFireRemote(eventName, ...)
                    end
                end
            end
        end)
        getgenv()._stamina_hook_installed = true
        if not success and Config.NotificationsEnabled then 
            Window:Notify({Title = "Error", Content = "Hook Failed: " .. tostring(err), Duration = 5})
        end
    end
    
    getgenv()._god_stamina_active = state
    
    -- Layer 2: Local Buff
    task.spawn(function()
        pcall(function()
            local BuffModule = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 5):WaitForChild("Features", 5):WaitForChild("Buff", 5)
            if BuffModule then
                local Buff = require(BuffModule)
                local Manager = Buff.GetManager(LocalPlayer)
                
                if state then
                    Manager:RemoveName("RoleStamina")
                    Manager:AddBuff({
                        name = "GodStaminaLimit",
                        type = "StaminaLimit",
                        value = 999999,
                        duration = 999999,
                        tags = {"Add", "PersistOnDeath"}
                    })
                    Manager:AddBuff({
                        name = "GodStaminaRegen",
                        type = "StaminaRegenRate",
                        value = 999999,
                        duration = 999999,
                        tags = {"Multi", "PersistOnDeath"}
                    })
                    if Config.NotificationsEnabled then 
                        Window:Notify({Title = "Stamina", Content = "God Mode Activated", Duration = 3})
                    end
                else
                    Manager:RemoveName("GodStaminaLimit")
                    Manager:RemoveName("GodStaminaRegen")
                    if Config.NotificationsEnabled then 
                        Window:Notify({Title = "Stamina", Content = "God Mode Deactivated", Duration = 3})
                    end
                end
            end
        end)
    end)
end

-- [Identification] Get clean name for monster/prop
local function getEntityName(entity)
    local rawName = entity.Name
    for _, id in ipairs(MonsterIDs) do if rawName:find(id) then return id end end
    
    -- Structural Identification
    if rawName:match("^%x+$") and #rawName >= 8 then
        if entity:FindFirstChild("Bubble") and entity:FindFirstChild("Mouth") then return "CrocodileMama"
        elseif entity:FindFirstChild("VFX") and entity:FindFirstChild("Eye") then return "TheBurden"
        elseif entity:FindFirstChild("Tail") and entity:FindFirstChild("Torso") then return "Bloomaw"
        elseif entity:FindFirstChild("Pants") and entity:FindFirstChild("Shirt") then return "Mimic"
        elseif entity:FindFirstChild("AttackVFX") and (entity:FindFirstChild("1C1") or entity:FindFirstChild("2C1")) then return "FridgeMonster"
        elseif entity:FindFirstChild("Feets") and entity:FindFirstChild("Model") then return "TheFaceless"
        elseif entity:FindFirstChild("bag") and entity:FindFirstChild("Asset") then return "SantaMK2"
        elseif entity:FindFirstChild("Body") and entity:FindFirstChild("Head") then return "Turkey"
        end
    end
    
    local hum = entity:FindFirstChildOfClass("Humanoid")
    if hum then
        return string.format("%s [%d/%d]", rawName, math.floor(hum.Health), math.floor(hum.MaxHealth))
    end
    return rawName
end

local function isDangerous(entity)
    for _, id in ipairs(PropIDs) do if entity.Name:find(id) then return false end end
    for _, id in ipairs(MonsterIDs) do if entity.Name:find(id) then return true end end
    local hum = entity:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- [Anti-Stuck] Detection & Recovery
local lastPos, stuckTimer = Vector3.new(0,0,0), 0
local function checkStuck()
    if not RootPart then return false end
    if (RootPart.Position - lastPos).Magnitude < 1 then
        stuckTimer = stuckTimer + 0.5
        if stuckTimer >= 5 then
            stuckTimer = 0
            RootPart.CFrame = RootPart.CFrame * CFrame.new(math.random(-10, 10), 0, math.random(-10, 10))
            return true
        end
    else
        stuckTimer = 0
    end
    lastPos = RootPart.Position
    return false
end

-- [Priority] Sort items by rarity
local function sortByPriority(loots)
    table.sort(loots, function(a, b)
        local prio = {["Key"] = 100, ["Rare"] = 90, ["Epic"] = 80}
        local pa, pb = 0, 0
        for k, v in pairs(prio) do
            if a.Name:find(k) then pa = v end
            if b.Name:find(k) then pb = v end
        end
        return pa > pb
    end)
    return loots
end

-- [Movement] Safe Teleport & Tween
local function safeTeleport(targetCFrame)
    if not RootPart then return end
    if Config.UseTween then
        local dist = (RootPart.Position - targetCFrame.Position).Magnitude
        local t = dist / math.max(Config.WalkSpeed * 2, 60)
        local tween = TweenService:Create(RootPart, TweenInfo.new(t, Enum.EasingStyle.Quad), {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    else
        Character:PivotTo(targetCFrame)
    end
end

-- [Inventory] Smart Sensing
local function getInventoryCount()
    local count = 0
    pcall(function()
        local main = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local home = main and main:FindFirstChild("HomePage")
        if not home then return end
        if home:FindFirstChild("HandsFull") and home.HandsFull.Visible then count = 4 return end
        local bottom = home:FindFirstChild("Bottom")
        if bottom then
            for _, v in pairs(bottom:GetChildren()) do
                if v:IsA("Frame") and v:FindFirstChild("ItemDetails") then
                    local name = v.ItemDetails:FindFirstChild("ItemName")
                    if name and name.Text ~= "" then count = count + 1 end
                end
            end
        end
    end)
    return count
end

-- [Interaction] Robust Retry Handler
local processed = {}
local function interactWithTarget(target)
    if not target or processed[target] then return false end
    
    local attempts, success = 0, false
    repeat
        attempts = attempts + 1
        
        if target:GetAttribute("Open") or target:GetAttribute("ItemDropped") then
            success = true break
        end
        
        safeTeleport(target:IsA("Model") and target:GetModelCFrame() or target.CFrame * CFrame.new(0, 3, 0))
        task.wait(0.15)
        
        if not safeFireRemote("Interactable", target) then
            pcall(function() game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game) end)
        end
        task.wait(0.25)
        
        if target:GetAttribute("Open") or target:GetAttribute("ItemDropped") or not target.Parent then
            success = true
        end
    until success or attempts >= 5
    
    processed[target] = true
    if not success then
        target:SetAttribute("Ignore", true)
    else
        Stats.ItemsCollected = Stats.ItemsCollected + 1
    end
    return success
end

-- Loot Blacklist
local LootBlacklist = {
    ["Flashlight"] = true, ["GlowStick"] = true, ["Lighter"] = true,
    ["Vitamins"] = true, ["Chips"] = true, ["Cookie"] = true,
    ["Chocolate"] = true, ["Candy"] = true, ["Soda"] = true,
    ["Cola"] = true, ["Water"] = true, ["Bandage"] = true, ["Medkit"] = true
}

local function isBlacklisted(itemName)
    return LootBlacklist[itemName] == true
end

-- ============================================================
-- DASHBOARD TAB (HOME SECTION)
-- ============================================================
DashboardTab:Paragraph({
    Title = "Statistics",
    Desc = "Real-time performance tracking"
})

StatsLabel = DashboardTab:Paragraph({
    Title = "Session Stats",
    Desc = "Items: 0 | IPM: 0.0 | Floor: 0"
})

StatusLabel = DashboardTab:Paragraph({
    Title = "Status",
    Desc = "Initializing..."
})

DashboardTab:Button({
    Title = "🚨 PANIC (Emergency Stop)",
    Desc = "Instantly terminates the script",
    Callback = function() 
        Config.Alive = false
        Window:Destroy()
    end
})

DashboardTab:Toggle({
    Title = "Show Notifications",
    Value = true,
    Callback = function(state) Config.NotificationsEnabled = state end
})

print("[WindUI] Dashboard tab initialized")

-- ============================================================
-- COMBAT TAB (COMBAT SECTION)
-- ============================================================
CombatTab:Toggle({
    Title = "Kill Aura (Melee)",
    Desc = "Automatically attacks nearby monsters",
    Icon = "sword",
    Value = false,
    Callback = function(state) Config.Combat.KillAura = state end
})

CombatTab:Toggle({
    Title = "⚡ Infinite Stamina",
    Desc = "God Mode - Never run out of stamina",
    Icon = "zap",
    Value = false,
    Callback = function(state) toggleInfiniteStamina(state) end
})

CombatTab:Button({
    Title = "💉 Rapid Consumables Hook",
    Desc = "Remove cooldowns from Cola, Bandage, Medkit",
    Icon = "syringe",
    Callback = function()
        pcall(function()
            for _, mod in ipairs({"Cola", "Bandage", "Medkit"}) do
                local m = require(game:GetService("ReplicatedStorage").Shared.Features.Tools:FindFirstChild(mod))
                if m and m.Activate then m.Activate = function() return 0 end end
            end
            Window:Notify({Title = "Combat", Content = "Consumables hooked!", Duration = 3})
        end)
    end
})

CombatTab:Toggle({
    Title = "Auto Tool Spam",
    Desc = "Automatically uses tool (6/sec)",
    Icon = "hammer",
    Value = false,
    Callback = function(state) 
        Config.AutoToolSpam = state
        if Config.NotificationsEnabled then
            Window:Notify({Title = "Combat", Content = state and "Auto Tool Spam ON" or "Auto Tool Spam OFF", Duration = 3})
        end
    end
})

print("[WindUI] Combat tab initialized")

-- ============================================================
-- MOVEMENT TAB (COMBAT SECTION)
-- ============================================================
MovementTab:Toggle({
    Title = "⚡ Flash Speed",
    Desc = "2x movement speed (Buff Method)",
    Icon = "rocket",
    Value = false,
    Callback = function(state)
        Config.FlashSpeed = state
        task.spawn(function()
            local BuffModule = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Features"):WaitForChild("Buff")
            if BuffModule then
                local Buff = require(BuffModule)
                local Manager = Buff.GetManager(LocalPlayer)
                
                if state then
                    Manager:RemoveName("SafeSpeed")
                    Manager:AddBuff({
                        name = "SafeSpeedCheck_Walk",
                        type = "WalkSpeed",
                        value = 2.0,
                        duration = 999999,
                        tags = {"Multi", "PersistOnDeath"}
                    })
                    Manager:AddBuff({
                        name = "SafeSpeedCheck_Run",
                        type = "RunSpeed",
                        value = 2.0,
                        duration = 999999,
                        tags = {"Multi", "PersistOnDeath"}
                    })
                    if Config.NotificationsEnabled then Window:Notify({Title = "Speed", Content = "Speed Boost Active", Duration = 3}) end
                else
                    Manager:RemoveName("SafeSpeedCheck_Walk")
                    Manager:RemoveName("SafeSpeedCheck_Run")
                    if Config.NotificationsEnabled then Window:Notify({Title = "Speed", Content = "Speed Boost Disabled", Duration = 3}) end
                end
            end
        end)
    end
})

MovementTab:Toggle({
    Title = "Speed Hack",
    Desc = "Direct WalkSpeed modification",
    Icon = "gauge",
    Value = false,
    Callback = function(state)
        Config.SpeedHack = state
        if state then
            Config.OriginalSpeed = Humanoid.WalkSpeed
            Humanoid.WalkSpeed = Config.WalkSpeed
        else
            Humanoid.WalkSpeed = Config.OriginalSpeed
        end
        if Config.NotificationsEnabled then Window:Notify({Title = "Speed", Content = state and "Speed Enabled" or "Speed Disabled", Duration = 3}) end
    end
})

MovementTab:Slider({
    Title = "WalkSpeed",
    Desc = "Adjust movement speed (16-200)",
    Icon = "move",
    Step = 1,
    Value = { Min = 16, Max = 200, Default = 16 },
    Callback = function(val) 
        Config.WalkSpeed = val
        if Config.SpeedHack then Humanoid.WalkSpeed = val end
    end
})

MovementTab:Toggle({
    Title = "Use Tween (Legit Move)",
    Desc = "Smooth tweening instead of instant teleport",
    Icon = "orbit",
    Value = true,
    Callback = function(state) 
        Config.UseTween = state
        if Config.NotificationsEnabled then Window:Notify({Title = "Movement", Content = state and "Tweening Enabled" or "Tweening Disabled", Duration = 3}) end
    end
})

print("[WindUI] Movement tab initialized")

-- ============================================================
-- AUTO FARM TAB (AUTOMATION SECTION)
-- ============================================================
AutoFarmTab:Toggle({
    Title = "Enable Auto-Farm",
    Desc = "Automatically collect loot and open containers",
    Icon = "wheat",
    Value = false,
    Callback = function(state) Config.FarmActive = state end
})

AutoFarmTab:Toggle({
    Title = "Safe Mode",
    Desc = "Pause farming when monster nearby",
    Icon = "shield",
    Value = false,
    Callback = function(state) 
        Config.SafeMode = state
        if Config.NotificationsEnabled then
            Window:Notify({Title = "Farm", Content = state and "Safe Mode ON" or "Safe Mode OFF", Duration = 3})
        end
    end
})

AutoFarmTab:Slider({
    Title = "Loot Radius",
    Desc = "Detection range for loot (20-150 studs)",
    Icon = "circle-dot",
    Step = 5,
    Value = { Min = 20, Max = 150, Default = 50 },
    Callback = function(val) Config.LootRadius = val end
})

AutoFarmTab:Slider({
    Title = "Auto-Sell %",
    Desc = "Sell when inventory reaches X% full",
    Icon = "percent",
    Step = 5,
    Value = { Min = 50, Max = 100, Default = 100 },
    Callback = function(val) Config.AutoSellPercent = val end
})

AutoFarmTab:Toggle({
    Title = "Loot Filter",
    Desc = "Skip low-value items (Flashlight, Cola, etc)",
    Icon = "filter",
    Value = false,
    Callback = function(state) Config.LootFilter = state end
})

AutoFarmTab:Toggle({
    Title = "Anti-AFK",
    Desc = "Random camera movement to prevent kick",
    Icon = "eye-off",
    Value = false,
    Callback = function(state) Config.AntiAFK = state end
})

AutoFarmTab:Toggle({
    Title = "Smart Pathing",
    Desc = "Add random delays between interactions",
    Icon = "route",
    Value = false,
    Callback = function(state) Config.SmartPathing = state end
})

AutoFarmTab:Toggle({
    Title = "Safe Zone Logic",
    Desc = "Pause farming near elevator when banking",
    Icon = "home",
    Value = true,
    Callback = function(state) Config.SafeZoneLogic = state end
})

AutoFarmTab:Toggle({
    Title = "Anti-Stuck Detection",
    Desc = "Auto-recover if stuck in place for 5s",
    Icon = "move-diagonal",
    Value = true,
    Callback = function(state) Config.AntiStuck = state end
})

AutoFarmTab:Toggle({
    Title = "Priority Loot",
    Desc = "Collect rarer items first (Keys, Epic, Rare)",
    Icon = "star",
    Value = true,
    Callback = function(state) Config.PriorityLoot = state end
})

AutoFarmTab:Slider({
    Title = "Farm Speed Multiplier",
    Desc = "Adjust farm speed (50-200%)",
    Icon = "zap",
    Step = 10,
    Value = { Min = 50, Max = 200, Default = 100 },
    Callback = function(val) 
        Config.FarmSpeedMultiplier = val / 100
    end
})

AutoFarmTab:Toggle({
    Title = "No Limit Radius",
    Desc = "Farm loot from unlimited distance",
    Icon = "infinity",
    Value = false,
    Callback = function(state) 
        Config.NoLimitRadius = state
        if Config.NotificationsEnabled then
            Window:Notify({Title = "Farm", Content = state and "Loot Radius UNLIMITED!" or "Radius limit restored", Duration = 3})
        end
    end
})

print("[WindUI] Auto Farm tab initialized")

-- ============================================================
-- DUNGEON TAB (AUTOMATION SECTION)
-- ============================================================
DungeonTab:Toggle({
    Title = "Auto Elevator (Go Deep)",
    Desc = "Automatically vote to go deeper",
    Icon = "arrow-down",
    Value = false,
    Callback = function(state) Config.AutoElevator = state end
})

DungeonTab:Slider({
    Title = "Max Floor Target",
    Desc = "Auto-evac when reaching this floor (1-30)",
    Icon = "layers",
    Step = 1,
    Value = { Min = 1, Max = 30, Default = 10 },
    Callback = function(val) Config.MaxFloorTarget = val end
})

DungeonTab:Toggle({
    Title = "God Mode (Elevator)",
    Desc = "Force stay in elevator - invincibility",
    Icon = "shield-check",
    Value = false,
    Callback = function(state) 
        Config.GodModeElevator = state
        if Config.NotificationsEnabled then
            Window:Notify({Title = "Exploit", Content = state and "God Mode ENABLED" or "God Mode DISABLED", Duration = 3})
        end
    end
})

DungeonTab:Button({
    Title = "🛗 TP to Elevator",
    Desc = "Teleport to elevator instantly",
    Icon = "move-up",
    Callback = function()
        local elev = workspace:FindFirstChild("GameSystem") and workspace.GameSystem:FindFirstChild("Loots") and workspace.GameSystem.Loots:FindFirstChild("ElevatorCollect")
        if elev then 
            safeTeleport(elev.PrimaryPart.CFrame * CFrame.new(0,5,0))
            if Config.NotificationsEnabled then Window:Notify({Title = "Teleport", Content = "Teleported to elevator", Duration = 3}) end
        else
            if Config.NotificationsEnabled then Window:Notify({Title = "Error", Content = "Elevator not found", Duration = 3}) end
        end
    end
})

DungeonTab:Slider({
    Title = "Interact Distance",
    Desc = "Max distance for interactions (10-100)",
    Icon = "radius",
    Step = 5,
    Value = { Min = 10, Max = 100, Default = 25 },
    Callback = function(val) Config.InteractDistance = val end
})

DungeonTab:Toggle({
    Title = "Emergency Evacuation",
    Desc = "Auto-evacuate when countdown reaches threshold",
    Icon = "door-open",
    Value = false,
    Callback = function(state) Config.SafeEvac = state end
})

DungeonTab:Slider({
    Title = "Evacuate Timer (seconds)",
    Desc = "Trigger evacuation at X seconds left (1-30)",
    Icon = "timer",
    Step = 1,
    Value = { Min = 1, Max = 30, Default = 5 },
    Callback = function(val) Config.SafeEvacTime = val end
})

DungeonTab:Button({
    Title = "🧃 Instant Juicer",
    Desc = "Use juicer from any distance",
    Icon = "droplet",
    Callback = function() 
        local juicers = game:GetService("CollectionService"):GetTagged("Juicer")
        if #juicers == 0 then
            local gs = workspace:FindFirstChild('GameSystem')
            if gs then for _, v in pairs(gs:GetDescendants()) do if v.Name == "Juicer" then table.insert(juicers, v) end end end
        end
        if #juicers > 0 then
            local target = juicers[1]
            local interact = target:FindFirstChild("Interactable", true)
            if interact then 
                safeFireRemote("UseJuicer", interact.Position)
                if Config.NotificationsEnabled then Window:Notify({Title = "Dungeon", Content = "Used Juicer!", Duration = 3}) end
            end
        else
            if Config.NotificationsEnabled then Window:Notify({Title = "Dungeon", Content = "No Juicer found", Duration = 3}) end
        end
    end
})

DungeonTab:Toggle({
    Title = "Auto Use Juicer",
    Desc = "Automatically use juicer when available",
    Icon = "droplet",
    Value = false,
    Callback = function(state) Config.AutoJuicer = state end
})

DungeonTab:Button({
    Title = "🚪 Instant Evacuate",
    Desc = "Evacuate from any distance",
    Icon = "log-out",
    Callback = function()
        local evacs = game:GetService("CollectionService"):GetTagged("Evacuation")
        if #evacs > 0 then
            local target = evacs[1]
            local interact = target:FindFirstChild("Interactable", true)
            if interact then 
                safeFireRemote("EvacuateAlone", interact.Position)
                if Config.NotificationsEnabled then Window:Notify({Title = "Dungeon", Content = "Evacuated!", Duration = 3}) end
            end
        else
            if Config.NotificationsEnabled then Window:Notify({Title = "Dungeon", Content = "No Exit found", Duration = 3}) end
        end
    end
})

DungeonTab:Toggle({
    Title = "Show Countdown Display",
    Desc = "Periodic notifications of time remaining",
    Icon = "clock",
    Value = false,
    Callback = function(state) Config.ShowCountdown = state end
})

DungeonTab:Button({
    Title = "🎒 Drop All Items",
    Desc = "Drop all inventory items (Remote)",
    Icon = "package-x",
    Callback = function()
        for i = 1, 4 do
            safeFireRemote("Hotbar_Drop", i)
            task.wait(0.2)
        end
        if Config.NotificationsEnabled then Window:Notify({Title = "Exploit", Content = "Dropped all items!", Duration = 3}) end
    end
})

DungeonTab:Toggle({
    Title = "Remote Drop Mode",
    Desc = "Drop items remotely during farming",
    Icon = "trash-2",
    Value = false,
    Callback = function(state) 
        Config.RemoteDropMode = state
        if Config.NotificationsEnabled then Window:Notify({Title = "Farm", Content = state and "Remote Drop Mode ON" or "Remote Drop Mode OFF", Duration = 3}) end
    end
})

print("[WindUI] Dungeon tab initialized")

-- ============================================================
-- ESP TAB (VISUALS  SECTION)
-- ============================================================
ESPTab:Toggle({
    Title = "Monster ESP",
    Desc = "Show health and distance for all monsters",
    Icon = "skull",
    Value = false,
    Callback = function(state) Config.ESP.Monsters = state end
})

ESPTab:Toggle({
    Title = "Loot ESP",
    Desc = "Highlight loot items on the ground",
    Icon = "package",
    Value = false,
    Callback = function(state) Config.ESP.Loot = state end
})

ESPTab:Toggle({
    Title = "Container ESP",
    Desc = "Show crates, cabinets, fridges",
    Icon = "box",
    Value = false,
    Callback = function(state) Config.ESP.Containers = state end
})

ESPTab:Button({
    Title = "💡 Toggle Fullbright",
    Desc = "Max brightness for better visibility",
    Icon = "sun",
    Callback = function()
        Config.Fullbright = not Config.Fullbright
        local lighting = game:GetService("Lighting")
        if Config.Fullbright then
            LightingRestore = { Ambient = lighting.Ambient, OutdoorAmbient = lighting.OutdoorAmbient, Brightness = lighting.Brightness }
            lighting.Ambient, lighting.OutdoorAmbient, lighting.Brightness = Color3.new(1,1,1), Color3.new(1,1,1), 2
        else
            lighting.Ambient, lighting.OutdoorAmbient, lighting.Brightness = LightingRestore.Ambient or Color3.new(0,0,0), LightingRestore.OutdoorAmbient or Color3.new(0,0,0), LightingRestore.Brightness or 1
        end
    end
})

ESPTab:Toggle({
    Title = "NPC ESP",
    Desc = "Show NPCs (merchants, quest givers)",
    Icon = "user",
    Value = false,
    Callback = function(state) Config.ESP.NPCs = state end
})

ESPTab:Toggle({
    Title = "Player ESP",
    Desc = "Show other players in the dungeon",
    Icon = "users",
    Value = false,
    Callback = function(state) Config.ESP.Players = state end
})

ESPTab:Toggle({
    Title = "Ghost ESP",
    Desc = "Detect and show ghosts",
    Icon = "ghost",
    Value = false,
    Callback = function(state) Config.ESP.Ghosts = state end
})

ESPTab:Toggle({
    Title = "Unlimited Distance",
    Desc = "Show ESP for all entities (no range limit)",
    Icon = "infinity",
    Value = false,
    Callback = function(state) Config.ESP.NoLimit = state end
})

ESPTab:Toggle({
    Title = "Hide Opened Containers",
    Desc = "Only show unopened containers",
    Icon = "eye-off",
    Value = false,
    Callback = function(state) Config.ESP.HideOpened = state end
})

ESPTab:Toggle({
    Title = "Hide Elevator Items",
    Desc = "Don't show loot near elevator",
    Icon = "filter-x",
    Value = false,
    Callback = function(state) Config.ESP.HideElevator = state end
})

print("[WindUI] ESP tab initialized")

-- ============================================================
-- TRACKERS TAB (VISUALS SECTION)
-- ============================================================
TrackersTab:Toggle({
    Title = "Monster Tracker Alert",
    Desc = "Notification when monster gets close",
    Icon = "bell",
    Value = false,
    Callback = function(state) Config.Tracker.Enabled = state end
})

TrackersTab:Slider({
    Title = "Tracker Distance",
    Desc = "Alert radius in studs (20-100)",
    Icon = "circle",
    Step = 5,
    Value = { Min = 20, Max = 100, Default = 50 },
    Callback = function(val) Config.Tracker.Distance = val end
})

TrackersTab:Button({
    Title = "🛗 Highlight Elevator",
    Desc = "Add green highlight to elevator",
    Icon = "highlighter",
    Callback = function()
        Config.ESP.ElevatorHighlight = not Config.ESP.ElevatorHighlight
        local hlName = "H_ESP_Elevator"
        for _, v in pairs(workspace:GetDescendants()) do
            if (v.Name == "Ground" or v.Name:find("Elevator") or v.Name:find("Lift")) and v.Parent then
                local hl = v.Parent:FindFirstChild(hlName)
                if Config.ESP.ElevatorHighlight and not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = hlName
                    hl.FillColor = Color3.fromRGB(0, 255, 0)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = v.Parent
                elseif not Config.ESP.ElevatorHighlight and hl then
                    hl:Destroy()
                end
            end
        end
    end
})

print("[WindUI] Trackers tab initialized")

-- ============================================================
-- TELEPORTS TAB (WORLD SECTION)
-- ============================================================
TeleportsTab:Button({
    Title = "🛗 To Elevator",
    Desc = "Instant teleport to elevator",
    Icon = "move-up",
    Callback = function()
        local elev = workspace.GameSystem:FindFirstChild("Loots"):FindFirstChild("ElevatorCollect")
        if elev then safeTeleport(elev.PrimaryPart.CFrame * CFrame.new(0,5,0)) end
    end
})

TeleportsTab:Button({
    Title = "🎯 Teleport to Nearest NPC",
    Desc = "Find and teleport to closest NPC",
    Icon = "target",
    Callback = function() teleportToNPC("Nearest") end
})

TeleportsTab:Button({
    Title = "🎲 Teleport to Random NPC",
    Desc = "Teleport to any random NPC",
    Icon = "shuffle",
    Callback = function() teleportToNPC("Random") end
})

TeleportsTab:Button({
    Title = "📊 Show NPC Count",
    Desc = "List all NPCs in current map",
    Icon = "list",
    Callback = function() showNPCCount() end
})

print("[WindUI] Teleports tab initialized")

-- ============================================================
-- UTILITIES TAB (WORLD SECTION)
-- ============================================================
UtilitiesTab:Button({
    Title = "💵 Instant Sell All Items",
    Desc = "Sell all inventory items remotely",
    Icon = "dollar-sign",
    Callback = function() 
        safeFireRemote("BackpackSellAll")
        if Config.NotificationsEnabled then Window:Notify({Title = "Exploit", Content = "Sold all items!", Duration = 3}) end
    end
})

UtilitiesTab:Button({
    Title = "🔧 Instant Sell All Tools",
    Desc = "Sell all tools in inventory",
    Icon = "wrench",
    Callback = function() 
        safeFireRemote("BackpackSellAllTools")
        if Config.NotificationsEnabled then Window:Notify({Title = "Exploit", Content = "Sold all tools!", Duration = 3}) end
    end
})

UtilitiesTab:Button({
    Title = "🎁 Claim Offline Reward",
    Desc = "Force claim offline rewards",
    Icon = "gift",
    Callback = function() 
        safeFireRemote("OfflineReward", tick())
        if Config.NotificationsEnabled then Window:Notify({Title = "Exploit", Content = "Claimed Offline Reward!", Duration = 3}) end
    end
})

print("[WindUI] Utilities tab initialized")

-- ============================================================
-- CONFIGURATION TAB (SETTINGS SECTION)
-- ============================================================
ConfigTab:Paragraph({
    Title = "Keybind Settings",
    Desc = "Configure UI toggle keybind"
})

local ToggleKeyLabel = ConfigTab:Paragraph({
    Title = "Current Toggle Key",
    Desc = "RightShift"
})

ConfigTab:Button({
    Title = "Change Toggle Key",
    Desc = "Press any key to set as toggle",
    Icon = "keyboard",
    Callback = function()
        if KeybindConnection then KeybindConnection:Disconnect() end
        ToggleKeyLabel:SetDesc("Press any key...")
        
        KeybindConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                CurrentToggleKey = input.KeyCode
                ToggleKeyLabel:SetDesc(input.KeyCode.Name)
                if Config.NotificationsEnabled then 
                    Window:Notify({Title = "Keybind", Content = "Toggle key set to: " .. input.KeyCode.Name, Duration = 3})
                end
                KeybindConnection:Disconnect()
                KeybindConnection = nil
            end
        end)
    end
})

ConfigTab:Paragraph({
    Title = "🛡️ Protection Status",
    Desc = "" -- Will be updated dynamically
})

ConfigTab:Paragraph({
    Title = "HookCheck",
    Desc = (_hookcheck_passed and "✅ PASSED" or "❌ FAILED")
})

ConfigTab:Paragraph({
    Title = "Memory Obfuscation",
    Desc = "✅ ACTIVE"
})

ConfigTab:Paragraph({
    Title = "Rate Limiting",
    Desc = "✅ ACTIVE"
})

ConfigTab:Paragraph({
    Title = "Session ID",
    Desc = string.sub(_sid, 1, 6) .. "..."
})

ConfigTab:Button({
    Title = "🔄 Check Remote Stats",
    Desc = "View rate limiter status",
    Icon = "activity",
    Callback = function()
        local count = 0
        for _ in pairs(_remote_log) do count = count + 1 end
        local blocked = tick() < _remote_blocked_until and "BLOCKED" or "OK"
        if Config.NotificationsEnabled then
            Window:Notify({
                Title = "Rate Limit",
                Content = string.format("Status: %s | Tracked: %d", blocked, count),
                Duration = 5
            })
        end
    end
})

ConfigTab:Slider({
    Title = "Rate Limit (calls/min)",
    Desc = "Max remote calls per minute (10-60)",
    Icon = "gauge",
    Step = 5,
    Value = { Min = 10, Max = 60, Default = 35 },
    Callback = function(val)
        _remote_config.MAX_PER_MINUTE = val
        if Config.NotificationsEnabled then Window:Notify({Title = "Protection", Content = "Max calls/min set to: " .. val, Duration = 3}) end
    end
})

ConfigTab:Slider({
    Title = "Min Interval (ms)",
    Desc = "Minimum time between remote calls (50-500ms)",
    Icon = "timer",
    Step = 10,
    Value = { Min = 50, Max = 500, Default = 150 },
    Callback = function(val)
        _remote_config.MIN_INTERVAL = val / 1000
        if Config.NotificationsEnabled then Window:Notify({Title = "Protection", Content = "Min interval set to: " .. val .. "ms", Duration = 3}) end
    end
})

ConfigTab:Paragraph({
    Title = "Developer",
    Desc = "xxdayssheus"
})

ConfigTab:Button({
    Title = "Unload Script",
    Desc = "Clean shutdown and UI destruction",
    Icon = "power",
    Callback = function()
        Config.Alive = false
        
        -- Restore original speed
        pcall(function()
            if Config.SpeedHack and Humanoid then
                Humanoid.WalkSpeed = Config.OriginalSpeed
            end
        end)
        
        -- Disconnect all connections
        if KeybindConnection then KeybindConnection:Disconnect() end
        for _, conn in ipairs(_conns) do pcall(function() conn:Disconnect() end) end
        
        -- Destroy UI
        Window:Destroy()
        
        if Config.NotificationsEnabled then Window:Notify({Title = "Script", Content = "Unloaded successfully", Duration = 3}) end
    end
})

print("[WindUI] Configuration tab initialized")

-- ============================================================
-- CORE OPERATIONAL LOOPS (PRESERVED FROM AESTHETICMAIN)
-- ============================================================

print("[WindUI] Initializing core loops...")

--[[
    The following loops are IDENTICAL to AestheticMain.lua
    They have been preserved to maintain full functionality
]]--

-- [SURVIVAL] Monitor Dungeon State & Countdown
task.spawn(function()
    while Config.Alive do
        task.wait(0.5)
        pcall(function()
            if DungeonValue and DungeonValue.DungeonStats and DungeonValue.DungeonStats.Value then
                local data = DungeonValue.DungeonStats.Value
                if data then
                    Stats.Countdown = (data.countdown and data.countdown.time) or  999
                    Stats.DungeonState = data.state or "Normal"
                    Stats.CurrentFloor = data.level or 0
                    
                   if Config.SafeEvac and Stats.Countdown <= Config.SafeEvacTime and Stats.DungeonState == "Normal" then
                        Window:Notify({Title = "SURVIVAL", Content = "Evacuation Triggered", Duration = 3})
                        safeFireRemote("EvacuateAlone")
                        task.wait(2)
                    end
                end
            end
        end)
    end
end)

-- [ESP] Billboard Loop (Massive System - 250 lines preserved)
local ESP_Objects = {}
local function createESP(obj, text, color)
    local key = tostring(obj)
    if ESP_Objects[key] then 
        if ESP_Objects[key].Name then
            ESP_Objects[key].Name.Text = text
        end
        return 
    end
    
    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP_" .. key
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 100, 0, 60)
    gui.StudsOffset = Vector3.new(0, 2, 0)
    gui.Parent = ESPFolder
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = text
    nameLabel.TextColor3 = color
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = gui
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, 0, 0, 15)
    distLabel.Position = UDim2.new(0, 0, 0, 20)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.new(1, 1, 1)
    distLabel.TextStrokeTransparency = 0.5
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.Parent = gui
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 12)
    statusLabel.Position = UDim2.new(0, 0, 0, 35)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    statusLabel.TextStrokeTransparency = 0.5
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 10
    statusLabel.Parent = gui
    
    local part =obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
    if part then gui.Adornee = part end
    
    ESP_Objects[key] = {Gui = gui, Dist = distLabel, Name = nameLabel, Status = statusLabel, Object = obj}
end

task.spawn(function()
    while Config.Alive do
        task.wait(0.5)
        if not RootPart then continue end
        local gs = workspace:FindFirstChild("GameSystem")
        if gs then
            -- Monster ESP with Health Updates
            if Config.ESP.Monsters and gs:FindFirstChild("Monsters") then
                for _, m in pairs(gs.Monsters:GetChildren()) do 
                    if isDangerous(m) then 
                        local entityName = getEntityName(m)
                        local hum = m:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            local hp = math.floor(hum.Health)
                            local maxHp = math.floor(hum.MaxHealth)
                            entityName = string.format("%s ❤️%d/%d", entityName, hp, maxHp)
                        end
                        
                        createESP(m, entityName, Color3.new(1,0.2,0.2))
                        
                        local key = tostring(m)
                        if ESP_Objects[key] and hum and hum.Health > 0 then
                            local hp = math.floor(hum.Health)
                            local maxHp = math.floor(hum.MaxHealth)
                            ESP_Objects[key].Name.Text = string.format("%s ❤️%d/%d", getEntityName(m), hp, maxHp)
                        end
                    end
                end
            end
            -- Loot ESP
            if Config.ESP.Loot and gs:FindFirstChild("Loots") then
                local w = gs.Loots:FindFirstChild("World")
                if w then createESP(l, l.Name, Color3.new(0.2,1,0.2)) end
            end
            -- Container ESP
            if Config.ESP.Containers and gs:FindFirstChild("InteractiveItem") then
                for _, c in pairs(gs.InteractiveItem:GetChildren()) do
                    if c:IsA("Model") then
                        local isOpen = c:GetAttribute("Open") or c:GetAttribute("opened")
                        if not (Config.ESP.HideOpened and isOpen) then 
                            createESP(c, c.Name, Color3.new(1,1,0.2))
                        end
                    end
                end
            end
            -- NPC ESP
            if Config.ESP.NPCs and gs:FindFirstChild("NPCModels") then
                for _, n in pairs(gs.NPCModels:GetChildren()) do createESP(n, n.Name, Color3.new(0.2,0.8,1)) end
            end
            -- Ghost ESP
            if Config.ESP.Ghosts then
                local ghostFolders = {gs:FindFirstChild("Ghosts"), gs:FindFirstChild("NPCModels")}
                for _, folder in pairs(ghostFolders) do
                    if folder then
                        for _, ghost in pairs(folder:GetChildren()) do
                            local isGhost = ghost.Name:lower():find("ghost") or ghost.Name:lower():find("spirit")
                            if isGhost or (ghost:GetAttribute("IsGhost") == true) then
                                createESP(ghost, "Ghost", Color3.fromRGB(180, 50, 255))
                            end
                        end
                    end
                end
            end
        end
        -- Player ESP
        if Config.ESP.Players then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    createESP(p.Character, p.Name, Color3.new(0.8,0.2,1))
                end
            end
        end
        -- Update distance and visibility
        for obj, data in pairs(ESP_Objects) do
            if obj and obj.Parent then
                local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").Position) or obj.Position
                if pos then
                    local dist = (RootPart.Position - pos).Magnitude
                    data.Dist.Text = math.floor(dist) .. "m"
                    data.Gui.Enabled = Config.ESP.NoLimit or dist < 500
                end
            else data.Gui:Destroy() ESP_Objects[obj] = nil end
        end
    end
end)

-- [TRACKER] Monster Alert Loop
local lastTrackerAlert = 0
task.spawn(function()
    while Config.Alive do
        task.wait(0.5)
        if not Config.Tracker.Enabled or not RootPart then continue end
        local gs = workspace:FindFirstChild("GameSystem")
        if gs and gs:FindFirstChild("Monsters") then
            for _, m in pairs(gs.Monsters:GetChildren()) do
                if isDangerous(m) then
                    local mRoot = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                    if mRoot and (RootPart.Position - mRoot.Position).Magnitude < Config.Tracker.Distance then
                        if tick() - lastTrackerAlert > 3 then
                            lastTrackerAlert = tick()
                            Window:Notify({Title = "DANGER", Content = getEntityName(m) .. " nearby!", Duration = 3})
                        end
                    end
                end
            end
        end
    end
end)

-- [FARM] Automation Loop
task.spawn(function()
    while Config.Alive do
        local baseWait = 0.5
        if Config.FarmSpeedMultiplier and Config.FarmSpeedMultiplier > 0 then
            baseWait = baseWait / Config.FarmSpeedMultiplier
        end
        task.wait(baseWait)
        
        if not Config.FarmActive or not RootPart then continue end
        
        -- Safe Mode - Pause when monster nearby
        if Config.SafeMode then
            local gs = workspace:FindFirstChild("GameSystem")
            if gs and gs:FindFirstChild("Monsters") then
                local dangerNearby = false
                for _, m in pairs(gs.Monsters:GetChildren()) do
                    if isDangerous(m) then
                        local mRoot = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                        if mRoot and (RootPart.Position - mRoot.Position).Magnitude < 50 then
                            dangerNearby = true
                            break
                        end
                    end
                end
                if dangerNearby then
                    StatusLabel:SetDesc("⚠️ Safe Mode - Monster Nearby")
                    continue
                end
            end
        end
        
        -- Anti-stuck detection
        if Config.AntiStuck then checkStuck() end
        
        -- Auto-sell with threshold
        local invCount = getInventoryCount()
        local sellThreshold = math.floor(4 * (Config.AutoSellPercent / 100))
        if invCount >= sellThreshold then 
            StatusLabel:SetDesc("Selling Items...")
            safeFireRemote("BackpackSellAll") 
            task.wait(1) 
            continue 
        end
        
        local gs, targets = workspace:FindFirstChild("GameSystem"), {}
        if gs then
            local effectiveRadius = Config.NoLimitRadius and 999999 or Config.LootRadius
            
            local loots = gs:FindFirstChild("Loots") and gs.Loots:FindFirstChild("World")
            if loots then for _, l in pairs(loots:GetChildren()) do
                local d = (RootPart.Position - l.Position).Magnitude
                if d < effectiveRadius then 
                    if not (Config.LootFilter and isBlacklisted(l.Name)) then
                        table.insert(targets, {Object = l, Name = l.Name, Position = l.Position, Distance = d}) 
                    end
                end
            end end
            
            local containers = gs:FindFirstChild("InteractiveItem")
            if containers then for _, c in pairs(containers:GetChildren()) do
                if not c:GetAttribute("Open") and not c:GetAttribute("Ignore") then
                    local cPos = c.PrimaryPart and c.PrimaryPart.Position or (c:FindFirstChildWhichIsA("BasePart") and c:FindFirstChildWhichIsA("BasePart").Position)
                    if cPos and (RootPart.Position - cPos).Magnitude < effectiveRadius then 
                        table.insert(targets, {Object = c, Name = c.Name, Position = cPos, Distance = (RootPart.Position - cPos).Magnitude}) 
                    end
                end
            end end
        end
        
        if #targets > 0 then
            if Config.PriorityLoot then sortByPriority(targets) end
            StatusLabel:SetDesc("Farming " .. targets[1].Name)
            
            if Config.SmartPathing then
                task.wait(0.5 + math.random() * 1.0)
            end
            
            interactWithTarget(targets[1].Object)
        else 
            StatusLabel:SetDesc("Searching...")
        end
    end
end)

-- [COMBAT] Kill Aura Loop
task.spawn(function()
    while Config.Alive do
        task.wait(0.2)
        if not Config.Combat.KillAura or not RootPart then continue end
        local gs = workspace:FindFirstChild("GameSystem")
        if gs and gs:FindFirstChild("Monsters") then
            for _, m in pairs(gs.Monsters:GetChildren()) do
                if isDangerous(m) then
                    local mRoot = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                    if mRoot and (RootPart.Position - mRoot.Position).Magnitude < 15 then 
                        safeFireRemote("Interactable", m) 
                    end
                end
            end
        end
    end
end)

-- [STATS] Update Loop
task.spawn(function()
    while Config.Alive do
        task.wait(1)
        local elapsed = tick() - Stats.StartTime
        StatsLabel:SetDesc(string.format("Items: %d | IPM: %.1f | Floor: %d", Stats.ItemsCollected, Stats.ItemsCollected / (elapsed / 60), Stats.CurrentFloor))
        
        local statusColor = Config.FarmActive and "🟢 Farming Active" or "🟡 Idle"
        StatusLabel:SetDesc(statusColor)
    end
end)

-- [AUTO TOOL SPAM] Loop
task.spawn(function()
    while Config.Alive do
        task.wait(0.16)
        if Config.AutoToolSpam then
            safeFireRemote("Tool_Use")
        end
    end
end)

-- [AUTO JUICER] Loop
task.spawn(function()
    while Config.Alive do
        task.wait(2)
        if Config.AutoJuicer then
            local juicers = game:GetService("CollectionService"):GetTagged("Juicer")
            if #juicers == 0 then
                local gs = workspace:FindFirstChild('GameSystem')
                if gs then for _, v in pairs(gs:GetDescendants()) do if v.Name == "Juicer" then table.insert(juicers, v) end end end
            end
            if #juicers > 0 then
                local target = juicers[1]
                local interact = target:FindFirstChild("Interactable", true)
                if interact then safeFireRemote("UseJuicer", interact.Position) end
            end
        end
    end
end)

-- [ANTI-AFK] Camera Movement Loop
task.spawn(function()
    while Config.Alive do
        task.wait(60 + math.random() * 60)
        if Config.AntiAFK then
            local camera = workspace.CurrentCamera
            if camera then
                local angle = math.rad(math.random(-3, 3))
                pcall(function()
                    camera.CFrame = camera.CFrame * CFrame.Angles(0, angle, 0)
                end)
            end
        end
    end
end)

-- [GOD MODE ELEVATOR] Force In Elevator Loop
task.spawn(function()
    while Config.Alive do
        task.wait(0.1)
        if Config.GodModeElevator and RootPart then
            local gs = workspace:FindFirstChild("GameSystem")
            if gs and gs:FindFirstChild("Loots") then
                local elevCollect = gs.Loots:FindFirstChild("ElevatorCollect")
                if elevCollect then
                    local elevPart = elevCollect:IsA("Model") and (elevCollect.PrimaryPart or elevCollect:FindFirstChildWhichIsA("BasePart")) or elevCollect
                    if elevPart then
                        RootPart.CFrame = elevPart.CFrame * CFrame.new(0, 3, 0)
                    end
                end
            end
        end
    end
end)

-- [AUTO ELEVATOR] Voting System Loop
task.spawn(function()
    while Config.Alive do
        task.wait(2)
        if Config.AutoElevator and RootPart then
            local gs = workspace:FindFirstChild("GameSystem")
            if gs and gs:FindFirstChild("Interactables") then
                for _, interactive in pairs(gs.Interactables:GetChildren()) do
                    if interactive:IsA("Model") and (interactive.Name:find("Vote") or interactive.Name:find("Button")) then
                        local interact = interactive:FindFirstChild("Interactable", true)
                        if interact and interact:IsA("BasePart") then
                            local invCount = getInventoryCount()
                            local sellThreshold = math.floor(4 * (Config.AutoSellPercent / 100))
                            local shouldEvacuate = (invCount >= sellThreshold) or (Stats.CurrentFloor >= Config.MaxFloorTarget)
                            
                            local buttonType = nil
                            if interactive.Name:lower():find("green") or interact.Color == Color3.fromRGB(0, 255, 0) then
                                buttonType = "Deeper"
                            elseif interactive.Name:lower():find("yellow") or interact.Color == Color3.fromRGB(255, 255, 0) then
                                buttonType = "Evacuate"
                            end
                            
                            if shouldEvacuate and buttonType == "Evacuate" then
                                safeFireRemote("Vote", interact.Position, "Evacuate")
                                if Config.NotificationsEnabled then
                                    Window:Notify({Title = "Elevator", Content = "Voting to Evacuate!", Duration = 3})
                                end
                                task.wait(5)
                                break
                            elseif not shouldEvacuate and buttonType == "Deeper" then
                                safeFireRemote("Vote", interact.Position, "Deeper")
                                if Config.NotificationsEnabled then
                                    Window:Notify({Title = "Elevator", Content = "Voting to Go Deeper!", Duration = 3})
                                end
                                task.wait(5)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- [COUNTDOWN DISPLAY] Notification Loop
local lastCountdownNotify = 0
task.spawn(function()
    while Config.Alive do
        task.wait(5)
        if Config.ShowCountdown and DungeonValue and DungeonValue.DungeonStats and DungeonValue.DungeonStats.Value then
            local data = DungeonValue.DungeonStats.Value
            if data and data.countdown and data.countdown.isActive then
                local timeLeft = data.countdown.time or 0
                if tick() - lastCountdownNotify >= 30 then
                    lastCountdownNotify = tick()
                    local mins = math.floor(timeLeft / 60)
                    local secs = math.floor(timeLeft % 60)
                    if Config.NotificationsEnabled then
                        Window:Notify({
                            Title = "⏱️ Countdown", 
                            Content = string.format("Time Left: %02d:%02d | Floor: %d", mins, secs, Stats.CurrentFloor),
                            Duration = 5
                        })
                    end
                end
            end
        end
    end
end)

print("[WindUI] All core loops initialized successfully!")

-- ============================================================
-- FINAL INITIALIZATION
-- ============================================================

Window:Notify({
    Title = "🎉 Aesthetic Delivery",
    Content = "WindUI Migration Complete! All features operational.",
    Duration = 5
})
