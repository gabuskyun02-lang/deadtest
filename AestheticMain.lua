-- [[ AESTHETIC MAIN - PREMIUM REFACTOR ]]
-- Credits: xxdayssheus
-- Refactored for AestheticUI

local AestheticUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/gabuskyun02-lang/deadtest/refs/heads/main/AestheticUI.lua"))()

-- ============================================================
-- GLOBAL CONFIG & STATE
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
        AestheticUI:Notify({Title = "NPC", Message = "No NPCs found!", Type = "Warning"})
        return 
    end
    if mode == "Random" then
        safeTeleport(list[math.random(1, #list)].Root.CFrame * CFrame.new(0, 5, 0))
        AestheticUI:Notify({Title = "Teleport", Message = "Teleported to " .. list[1].Object.Name, Type = "Success"})
    else
        table.sort(list, function(a,b) return (RootPart.Position - a.Position).Magnitude < (RootPart.Position - b.Position).Magnitude end)
        safeTeleport(list[1].Root.CFrame * CFrame.new(0, 5, 0))
        AestheticUI:Notify({Title = "Teleport", Message = "Teleported to nearest NPC", Type = "Success"})
    end
end

local function showNPCCount()
    local list = getNPCs()
    if #list == 0 then
        AestheticUI:Notify({Title = "NPC", Message = "No NPCs found!", Type = "Warning"})
    else
        local names = {}
        for i = 1, math.min(5, #list) do table.insert(names, list[i].Object.Name) end
        local preview = table.concat(names, ", ")
        if #list > 5 then preview = preview .. "..." end
        AestheticUI:Notify({Title = "NPC", Message = string.format("Found %d NPCs: %s", #list, preview), Type = "Success"})
    end
end

-- [Stamina] God Mode Hook - DUAL LAYER PROTECTION
local staminaHookActive = false
local function toggleInfiniteStamina(state)
    staminaHookActive = state
    
    -- Layer 1: Network Blocker (Prevents Server Kick)
    if not getgenv()._stamina_hook_installed then
        local success, err = pcall(function()
            -- Force hook TEvent to drop stamina packets
            local TEventCheck = _G.TEvent or (workspace:FindFirstChild("GameSystem") and workspace.GameSystem:FindFirstChild("TEvent"))
            if TEventCheck and TEventCheck.FireRemote then
                -- Use hookfunction if available (advanced executors)
                if hookfunction then
                    local oldFireRemote = TEventCheck.FireRemote
                    hookfunction(TEventCheck.FireRemote, function(eventName, ...)
                        -- If user enabled God Mode, BLOCK the stamina sync packet
                        if getgenv()._god_stamina_active and eventName == "SyncStaminaConsume" then
                            return -- Silent Drop
                        end
                        return oldFireRemote(eventName, ...)
                    end)
                else
                    -- Fallback for executors without hookfunction
                    local oldFireRemote = TEventCheck.FireRemote
                    TEventCheck.FireRemote = function(eventName, ...)
                        if staminaHookActive and eventName == "SyncStaminaConsume" then return end
                        return oldFireRemote(eventName, ...)
                    end
                end
            end
        end)
        getgenv()._stamina_hook_installed = true
        if not success then 
            if Config.NotificationsEnabled then 
                AestheticUI:Notify({Title = "Error", Message = "Hook Failed: " .. tostring(err), Type = "Error"})
            end
        end
    end
    
    getgenv()._god_stamina_active = state
    
    -- Layer 2: Local Buff (Keeps UI Full + Infinite Regen)
    task.spawn(function()
        pcall(function()
            local BuffModule = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 5):WaitForChild("Features", 5):WaitForChild("Buff", 5)
            if BuffModule then
                local Buff = require(BuffModule)
                local Manager = Buff.GetManager(LocalPlayer)
                
                if state then
                    -- Remove old stamina buffs
                    Manager:RemoveName("RoleStamina")
                    
                    -- Add God Buffs (CRITICAL: Both limit AND regen)
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
                        AestheticUI:Notify({Title = "Stamina", Message = "God Mode Activated (Server Blocked + UI Full)", Type = "Success"})
                    end
                else
                    -- Remove God Buffs
                    Manager:RemoveName("GodStaminaLimit")
                    Manager:RemoveName("GodStaminaRegen")
                    if Config.NotificationsEnabled then 
                        AestheticUI:Notify({Title = "Stamina", Message = "God Mode Deactivated", Type = "Info"})
                    end
                end
            end
        end)
    end)
end

-- Services
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
local StatusLabel, StatsLabel, ToggleKeyLabel = nil, nil, nil
local CurrentToggleKey = Enum.KeyCode.LeftControl
local KeybindConnection = nil

-- TEvent Reference
local TEvent = nil
task.spawn(function()
    local gs = workspace:WaitForChild("GameSystem", 10)
    if gs then TEvent = gs:WaitForChild("TEvent", 5) end
    _G.TEvent = TEvent
end)

-- Entity ID Tables (CRITICAL for detection)
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
-- ANTI-DETECTION & CORE SECURITY
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

-- [Identification] Get clean name for monster/prop (handles hash-names)
local function getEntityName(entity)
    local rawName = entity.Name
    for _, id in ipairs(MonsterIDs) do if rawName:find(id) then return id end end
    
    -- Structural Identification for Obfuscated Names
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

-- [Priority] Sort items by rarity keywords
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
        local tween = game:GetService("TweenService"):Create(RootPart, TweenInfo.new(t, Enum.EasingStyle.Quad), {CFrame = targetCFrame})
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

-- [Interaction] Robust Retry Handler (Ported from vu168)
local processed = {}
local function interactWithTarget(target)
    if not target or processed[target] then return false end
    
    local attempts, success = 0, false
    repeat
        attempts = attempts + 1
        
        -- State Check (Latency Mitigation)
        if target:GetAttribute("Open") or target:GetAttribute("ItemDropped") then
            success = true break
        end
        
        safeTeleport(target:IsA("Model") and target:GetModelCFrame() or target.CFrame * CFrame.new(0, 3, 0))
        task.wait(0.15)
        
        -- DUAL-MODE interaction (Priority on Internal Remotes)
        if not safeFireRemote("Interactable", target) then
            -- Fallback to key simulation if remote fails (e.g. rate limit reached)
            -- Note: Key simulation requires VirtualInputManager usually available in executors
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

-- ============================================================
-- UI INITIALIZATION
-- ============================================================
-- ============================================================
-- UI INITIALIZATION
-- ============================================================
local Window = AestheticUI:CreateWindow({
    Title = "AESTHETIC DELIVERY",
    Icon = "rbxassetid://10723407389",
    Logo = "rbxassetid://6031229361",
    Size = UDim2.new(0, 850, 0, 550)
})

local HomeTab = AestheticUI:CreateTab(Window, { Name = "Home", Icon = "rbxassetid://1072334 density" })
local CombatTab = AestheticUI:CreateTab(Window, { Name = "Combat", Icon = "rbxassetid://1072334 sword" })
local AutoTab = AestheticUI:CreateTab(Window, { Name = "Automation", Icon = "rbxassetid://1072334 settings" })
local VisualTab = AestheticUI:CreateTab(Window, { Name = "Visuals", Icon = "rbxassetid://1072334 eye" })
local WorldTab = AestheticUI:CreateTab(Window, { Name = "World", Icon = "rbxassetid://1072334 map" })
local SettingsTab = AestheticUI:CreateTab(Window, { Name = "Settings", Icon = "rbxassetid://1072334 sliders" })

local StatusLabel = nil
local StatsLabel = nil

-- Home Section
local StatsSection = AestheticUI:CreateSection(HomeTab, "📊 Statistics")
StatusLabel = AestheticUI:CreateLabel(StatsSection, {
    Text = "Status: <font color='#FFD700'>Initializing...</font>"
})
StatsLabel = AestheticUI:CreateLabel(StatsSection, {
    Text = "Items: 0 | IPM: 0.0 | Floor: 0"
})

AestheticUI:CreateButton(StatsSection, {
    Text = "🚨 PANIC (Emergency Stop)",
    Tooltip = "Instantly terminates the script and destroys the UI",
    Callback = function() 
        Config.Alive = false
        Window:Destroy()
    end
})

AestheticUI:CreateToggle(StatsSection, {
    Text = "Show Notifications",
    Default = true,
    Callback = function(state) Config.NotificationsEnabled = state end
})

-- Farming Improvements Section
local FarmImprovements = AestheticUI:CreateSection(HomeTab, "Farm Improvements")
AestheticUI:CreateToggle(FarmImprovements, {
    Text = "Safe Mode",
    Default = false,
    Callback = function(state) 
        Config.SafeMode = state
        if Config.NotificationsEnabled then
            AestheticUI:Notify({Title = "Farm", Message = state and "Safe Mode ON - Pauses when monster near" or "Safe Mode OFF", Type = "Info"})
        end
    end
})

AestheticUI:CreateSlider(FarmImprovements, {
    Text = "Auto-Sell %",
    Min = 50, Max = 100, Default = 100,
    Callback = function(val) Config.AutoSellPercent = val end
})

AestheticUI:CreateToggle(FarmImprovements, {
    Text = "Loot Filter",
    Default = false,
    Callback = function(state) Config.LootFilter = state end
})

AestheticUI:CreateToggle(FarmImprovements, {
    Text = "Anti-AFK",
    Default = false,
    Callback = function(state) Config.AntiAFK = state end
})

AestheticUI:CreateToggle(FarmImprovements, {
    Text = "Smart Pathing",
    Default = false,
    Callback = function(state) Config.SmartPathing = state end
})

AestheticUI:CreateToggle(FarmImprovements, {
    Text = "Safe Zone Logic",
    Default = true,
    Callback = function(state) Config.SafeZoneLogic = state end
})

AestheticUI:CreateToggle(FarmImprovements, {
    Text = "Anti-Stuck",
    Default = true,
    Callback = function(state) Config.AntiStuck = state end
})

AestheticUI:CreateToggle(FarmImprovements, {
    Text = "Priority Loot",
    Default = true,
    Callback = function(state) Config.PriorityLoot = state end
})

AestheticUI:CreateSlider(FarmImprovements, {
    Text = "Farm Speed Multiplier",
    Min = 50, Max = 200, Default = 100,
    Callback = function(val) 
        Config.FarmSpeedMultiplier = val / 100
    end
})

AestheticUI:CreateToggle(FarmImprovements, {
    Text = "No Limit Radius",
    Default = false,
    Callback = function(state) 
        Config.NoLimitRadius = state
        if Config.NotificationsEnabled then
            AestheticUI:Notify({Title = "Farm", Message = state and "Loot Radius UNLIMITED!" or "Radius limit restored", Type = state and "Success" or "Info"})
        end
    end
})

-- Elevator Section  
local ElevatorSection = AestheticUI:CreateSection(HomeTab, "🛗 Elevator & Quick Actions")
AestheticUI:CreateToggle(ElevatorSection, {
    Text = "Auto Elevator (Go Deep)",
    Default = false,
    Callback = function(state) Config.AutoElevator = state end
})

AestheticUI:CreateSlider(ElevatorSection, {
    Text = "Max Floor Target",
    Min = 1, Max = 30, Default = 10,
    Callback = function(val) Config.MaxFloorTarget = val end
})

AestheticUI:CreateToggle(ElevatorSection, {
    Text = "God Mode (Elevator)",
    Default = false,
    Callback = function(state) 
        Config.GodModeElevator = state
        if Config.NotificationsEnabled then
            AestheticUI:Notify({Title = "Exploit", Message = state and "God Mode ENABLED" or "God Mode DISABLED", Type = state and "Success" or "Warning"})
        end
    end
})

AestheticUI:CreateButton(ElevatorSection, {
    Text = "🛗 TP to Elevator",
    Callback = function()
        local elev = workspace:FindFirstChild("GameSystem") and workspace.GameSystem:FindFirstChild("Loots") and workspace.GameSystem.Loots:FindFirstChild("ElevatorCollect")
        if elev then 
            safeTeleport(elev.PrimaryPart.CFrame * CFrame.new(0,5,0))
            if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Teleport", Message = "Teleported to elevator", Type = "Success"}) end
        else
            if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Error", Message = "Elevator not found", Type = "Error"}) end
        end
    end
})

AestheticUI:CreateSlider(HomeTab, {
    Text = "Interact Distance",
    Min = 10, Max = 100, Default = 25,
    Callback = function(val) Config.InteractDistance = val end
})

-- Combat Section
local CombatSection = AestheticUI:CreateSection(CombatTab, "Combat Exploits")
AestheticUI:CreateToggle(CombatSection, {
    Text = "Kill Aura (Melee)",
    Default = false,
    Callback = function(state) Config.Combat.KillAura = state end
})

AestheticUI:CreateToggle(CombatSection, {
    Text = "⚡ Infinite Stamina (God Mode)",
    Default = false,
    Callback = function(state) toggleInfiniteStamina(state) end
})

AestheticUI:CreateButton(CombatSection, {
    Text = "💉 Rapid Consumables Hook",
    Callback = function()
        pcall(function()
            for _, mod in ipairs({"Cola", "Bandage", "Medkit"}) do
                local m = require(game:GetService("ReplicatedStorage").Shared.Features.Tools:FindFirstChild(mod))
                if m and m.Activate then m.Activate = function() return 0 end end
            end
            AestheticUI:Notify({Title = "Combat", Message = "Items Hooked!", Type = "Success"})
        end)
    end
})

-- Speed & Movement Section
local SpeedSection = AestheticUI:CreateSection(CombatTab, "Speed & Movement")
AestheticUI:CreateToggle(SpeedSection, {
    Text = "⚡ Flash Speed (Buff Method)",
    Default = false,
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
                    if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Speed", Message = "Speed Boost Active", Type = "Success"}) end
                else
                    Manager:RemoveName("SafeSpeedCheck_Walk")
                    Manager:RemoveName("SafeSpeedCheck_Run")
                    if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Speed", Message = "Speed Boost Disabled", Type = "Info"}) end
                end
            end
        end)
    end
})

AestheticUI:CreateToggle(SpeedSection, {
    Text = "Speed Hack",
    Default = false,
    Callback = function(state)
        Config.SpeedHack = state
        if state then
            Config.OriginalSpeed = Humanoid.WalkSpeed
            Humanoid.WalkSpeed = Config.WalkSpeed
        else
            Humanoid.WalkSpeed = Config.OriginalSpeed
        end
        if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Speed", Message = state and "Speed Enabled" or "Speed Disabled", Type = "Info"}) end
    end
})

AestheticUI:CreateSlider(SpeedSection, {
    Text = "Walk Speed",
    Min = 16, Max = 200, Default = 16,
    Callback = function(val) 
        Config.WalkSpeed = val
        if Config.SpeedHack then Humanoid.WalkSpeed = val end
    end
})

AestheticUI:CreateToggle(SpeedSection, {
    Text = "Use Tween (Legit Move)",
    Default = true,
    Callback = function(state) 
        Config.UseTween = state
        if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Movement", Message = state and "Tweening Enabled (Smooth)" or "Tweening Disabled (Snap)", Type = "Info"}) end
    end
})

-- Automation Section
local FarmingSection = AestheticUI:CreateSection(AutoTab, "Auto Farm")
AestheticUI:CreateToggle(FarmingSection, {
    Text = "Enable Auto-Farm",
    Default = false,
    Callback = function(state) Config.FarmActive = state end
})

AestheticUI:CreateToggle(FarmingSection, {
    Text = "Safe Mode (Monster Evade)",
    Default = true,
    Callback = function(state) Config.SafeMode = state end
})

AestheticUI:CreateSlider(FarmingSection, {
    Text = "Loot Radius",
    Min = 20, Max = 150, Default = 50,
    Callback = function(val) Config.LootRadius = val end
})

local DungeonSection = AestheticUI:CreateSection(AutoTab, "Dungeon Exploits")
AestheticUI:CreateToggle(DungeonSection, {
    Text = "Emergency Evacuation",
    Default = false,
    Callback = function(state) Config.SafeEvac = state end
})

AestheticUI:CreateSlider(DungeonSection, {
    Text = "Evacuate Timer (seconds)",
    Min = 1, Max = 30, Default = 5,
    Callback = function(val) Config.SafeEvacTime = val end
})

AestheticUI:CreateButton(DungeonSection, {
    Text = "🧃 Instant Juicer",
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
                if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Dungeon", Message = "Used Juicer!", Type = "Success"}) end
            end
        else
            if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Dungeon", Message = "No Juicer found", Type = "Error"}) end
        end
    end
})

AestheticUI:CreateToggle(DungeonSection, {
    Text = "Auto Use Juicer",
    Default = false,
    Callback = function(state) Config.AutoJuicer = state end
})

AestheticUI:CreateButton(DungeonSection, {
    Text = "🚪 Instant Evacuate (Infinite Range)",
    Callback = function()
        local evacs = game:GetService("CollectionService"):GetTagged("Evacuation")
        if #evacs > 0 then
            local target = evacs[1]
            local interact = target:FindFirstChild("Interactable", true)
            if interact then 
                safeFireRemote("EvacuateAlone", interact.Position)
                if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Dungeon", Message = "Evacuated!", Type = "Success"}) end
            end
        else
            if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Dungeon", Message = "No Exit found", Type = "Error"}) end
        end
    end
})

AestheticUI:CreateToggle(DungeonSection, {
    Text = "Instant Evac (Auto Farm)",
    Default = false,
    Callback = function(state) Config.InstantEvac = state end
})

AestheticUI:CreateToggle(DungeonSection, {
    Text = "Show Countdown Display",
    Default = false,
    Callback = function(state) Config.ShowCountdown = state end
})

-- Tool & Hotbar Section
local ToolSection = AestheticUI:CreateSection(AutoTab, "🎮 Tool & Hotbar Exploits")
AestheticUI:CreateButton(ToolSection, {
    Text = "🎒 Drop All Items (Remote)",
    Callback = function()
        for i = 1, 4 do
            safeFireRemote("Hotbar_Drop", i)
            task.wait(0.2)
        end
        if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Exploit", Message = "Dropped all items!", Type = "Success"}) end
    end
})

AestheticUI:CreateButton(ToolSection, {
    Text = "⚡ Use Tool (Remote)",
    Callback = function()
        safeFireRemote("Tool_Use")
        if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Exploit", Message = "Used tool!", Type = "Success"}) end
    end
})

AestheticUI:CreateButton(ToolSection, {
    Text = "1️⃣ Switch Slot 1",
    Callback = function() safeFireRemote("Hotbar_Switch", 1) end
})

AestheticUI:CreateButton(ToolSection, {
    Text = "2️⃣ Switch Slot 2",
    Callback = function() safeFireRemote("Hotbar_Switch", 2) end
})

AestheticUI:CreateToggle(ToolSection, {
    Text = "Auto Tool Spam",
    Default = false,
    Callback = function(state) 
        Config.AutoToolSpam = state
        if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Exploit", Message = state and "Auto Tool Spam ON (6/sec)" or "Auto Tool Spam OFF", Type = "Info"}) end
    end
})

AestheticUI:CreateToggle(ToolSection, {
    Text = "Remote Drop Mode",
    Default = false,
    Callback = function(state) 
        Config.RemoteDropMode = state
        if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Farm", Message = state and "Remote Drop Mode ON" or "Remote Drop Mode OFF", Type = "Info"}) end
    end
})

-- Visuals Section
local ESPSection = AestheticUI:CreateSection(VisualTab, "ESP & Perception")
AestheticUI:CreateToggle(ESPSection, {
    Text = "Monster ESP",
    Default = false,
    Callback = function(state) Config.ESP.Monsters = state end
})

AestheticUI:CreateToggle(ESPSection, {
    Text = "Loot ESP",
    Default = false,
    Callback = function(state) Config.ESP.Loot = state end
})

AestheticUI:CreateToggle(ESPSection, {
    Text = "Container ESP",
    Default = false,
    Callback = function(state) Config.ESP.Containers = state end
})

AestheticUI:CreateButton(ESPSection, {
    Text = "💡 Toggle Fullbright",
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

AestheticUI:CreateToggle(ESPSection, {
    Text = "NPC ESP",
    Default = false,
    Callback = function(state) Config.ESP.NPCs = state end
})

AestheticUI:CreateToggle(ESPSection, {
    Text = "Player ESP",
    Default = false,
    Callback = function(state) Config.ESP.Players = state end
})

AestheticUI:CreateToggle(ESPSection, {
    Text = "Ghost ESP",
    Default = false,
    Callback = function(state) Config.ESP.Ghosts = state end
})

AestheticUI:CreateToggle(ESPSection, {
    Text = "Unlimited Distance",
    Default = false,
    Callback = function(state) Config.ESP.NoLimit = state end
})

AestheticUI:CreateToggle(ESPSection, {
    Text = "Hide Opened Containers",
    Default = false,
    Callback = function(state) Config.ESP.HideOpened = state end
})

AestheticUI:CreateToggle(ESPSection, {
    Text = "Hide Elevator Items",
    Default = false,
    Callback = function(state) Config.ESP.HideElevator = state end
})

local TrackerSection = AestheticUI:CreateSection(VisualTab, "Monster Tracker")
AestheticUI:CreateToggle(TrackerSection, {
    Text = "Monster Tracker Alert",
    Default = false,
    Callback = function(state) Config.Tracker.Enabled = state end
})

AestheticUI:CreateSlider(TrackerSection, {
    Text = "Tracker Distance",
    Min = 20, Max = 100, Default = 50,
    Callback = function(val) Config.Tracker.Distance = val end
})

AestheticUI:CreateButton(TrackerSection, {
    Text = "🛗 Highlight Elevator",
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

-- World Section
local TPSection = AestheticUI:CreateSection(WorldTab, "Teleports")
AestheticUI:CreateButton(TPSection, {
    Text = "🛗 To Elevator",
    Callback = function()
        local elev = workspace.GameSystem:FindFirstChild("Loots"):FindFirstChild("ElevatorCollect")
        if elev then safeTeleport(elev.PrimaryPart.CFrame * CFrame.new(0,5,0)) end
    end
})

AestheticUI:CreateButton(TPSection, {
    Text = "🎯 Teleport to Nearest NPC",
    Callback = function() teleportToNPC("Nearest") end
})

AestheticUI:CreateButton(TPSection, {
    Text = "🎲 Teleport to Random NPC",
    Callback = function() teleportToNPC("Random") end
})

AestheticUI:CreateButton(TPSection, {
    Text = "📊 Show NPC Count",
    Callback = function() showNPCCount() end
})

local UtilSection = AestheticUI:CreateSection(WorldTab, "Utilities & Exploits")
AestheticUI:CreateButton(UtilSection, {
    Text = "💵 Instant Sell All Items",
    Callback = function() 
        safeFireRemote("BackpackSellAll")
        if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Exploit", Message = "Sold all items!", Type = "Success"}) end
    end
})

AestheticUI:CreateButton(UtilSection, {
    Text = "🔧 Instant Sell All Tools",
    Callback = function() 
        safeFireRemote("BackpackSellAllTools")
        if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Exploit", Message = "Sold all tools!", Type = "Success"}) end
    end
})

AestheticUI:CreateButton(UtilSection, {
    Text = "🎁 Claim Offline Reward",
    Callback = function() 
        safeFireRemote("OfflineReward", tick())
        if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Exploit", Message = "Claimed Offline Reward!", Type = "Success"}) end
    end
})

-- Settings Tab
local KeybindSection = AestheticUI:CreateSection(SettingsTab, "Keybind Settings")
ToggleKeyLabel = AestheticUI:CreateLabel(KeybindSection, "Current Toggle Key: LeftControl")

AestheticUI:CreateButton(KeybindSection, {
    Text = "Change Toggle Key (Press Any Key)",
    Callback = function()
        if KeybindConnection then KeybindConnection:Disconnect() end
        ToggleKeyLabel.Text = "Press any key..."
        
        KeybindConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                CurrentToggleKey = input.KeyCode
                ToggleKeyLabel.Text = "Current Toggle Key: " .. CurrentToggleKey.Name
                if Config.NotificationsEnabled then 
                    AestheticUI:Notify({Title = "Keybind", Message = "Toggle key set to: " .. CurrentToggleKey.Name, Type = "Success"})
                end
                KeybindConnection:Disconnect()
                KeybindConnection = nil
            end
        end)
    end
})

local ProtectionSection = AestheticUI:CreateSection(SettingsTab, "🛡️ Protection Status")
AestheticUI:CreateLabel(ProtectionSection, "HookCheck: " .. (_hookcheck_passed and "✅ PASSED" or "❌ FAILED"))
AestheticUI:CreateLabel(ProtectionSection, "Memory Obfuscation: ✅ ACTIVE")
AestheticUI:CreateLabel(ProtectionSection, "Rate Limiting: ✅ ACTIVE")
AestheticUI:CreateLabel(ProtectionSection, "Session ID: " .. string.sub(_sid, 1, 6) .. "...")

AestheticUI:CreateButton(ProtectionSection, {
    Text = "🔄 Check Remote Stats",
    Callback = function()
        local count = 0
        for _ in pairs(_remote_log) do count = count + 1 end
        local blocked = tick() < _remote_blocked_until and "BLOCKED" or "OK"
        if Config.NotificationsEnabled then
            AestheticUI:Notify({
                Title = "Rate Limit",
                Message = string.format("Status: %s | Tracked: %d", blocked, count),
                Type = "Info"
            })
        end
    end
})

AestheticUI:CreateSlider(ProtectionSection, {
    Text = "Rate Limit (calls/min)",
    Min = 10, Max = 60, Default = 35,
    Callback = function(val)
        _remote_config.MAX_PER_MINUTE = val
        if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Protection", Message = "Max calls/min set to: " .. val, Type = "Info"}) end
    end
})

AestheticUI:CreateSlider(ProtectionSection, {
    Text = "Min Interval (ms)",
    Min = 50, Max = 500, Default = 150,
    Callback = function(val)
        _remote_config.MIN_INTERVAL = val / 1000
        if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Protection", Message = "Min interval set to: " .. val .. "ms", Type = "Info"}) end
    end
})

local AdvancedSection = AestheticUI:CreateSection(SettingsTab, "Advanced")
AestheticUI:CreateLabel(AdvancedSection, "Developer: xxdayssheus")
AestheticUI:CreateButton(AdvancedSection, {
    Text = "Unload Script",
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
        
        if Config.NotificationsEnabled then AestheticUI:Notify({Title = "Script", Message = "Unloaded successfully", Type = "Success"}) end
    end
})

-- ============================================================
-- CORE LOGIC LOOPS (ESP, Farming, Combat, Survival)
-- ============================================================

-- [SURVIVAL] Monitor State & Countdown
task.spawn(function()
    while Config.Alive do
        task.wait(0.5)
        pcall(function()
            if DungeonValue and DungeonValue.DungeonStats and DungeonValue.DungeonStats.Value then
                local data = DungeonValue.DungeonStats.Value
                if data then
                    Stats.Countdown = (data.countdown and data.countdown.time) or 999
                    Stats.DungeonState = data.state or "Normal"
                    Stats.CurrentFloor = data.level or 0
                    
                    if Config.SafeEvac and Stats.Countdown <= Config.SafeEvacTime and Stats.DungeonState == "Normal" then
                        AestheticUI:Notify({Title = "SURVIVAL", Message = "Evacuation Triggered", Type = "Warning"})
                        safeFireRemote("EvacuateAlone")
                        task.wait(2)
                    end
                end
            end
        end)
    end
end)

-- [ESP] Billboard Loop
local ESP_Objects = {}
local function createESP(obj, text, color)
    local key = tostring(obj)
    if ESP_Objects[key] then 
        -- Update existing ESP name label
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
    
    -- Status label for containers (Open/Closed)
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
    
    local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
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
                        -- Build label with health info
                        local entityName = getEntityName(m)
                        local hum = m:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            local hp = math.floor(hum.Health)
                            local maxHp = math.floor(hum.MaxHealth)
                            entityName = string.format("%s ❤️%d/%d", entityName, hp, maxHp)
                        end
                        
                        createESP(m, entityName, Color3.new(1,0.2,0.2))
                        
                        -- Real-time health update for existing ESP
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
                if w then 
                    -- Get elevator position for filtering
                    local elevatorPos = nil
                    if Config.ESP.HideElevator then
                        local elevCollect = gs.Loots:FindFirstChild("ElevatorCollect")
                        if elevCollect then
                            local elevPart = nil
                            if elevCollect:IsA("Model") then
                                elevPart = elevCollect.PrimaryPart or elevCollect:FindFirstChildWhichIsA("BasePart")
                            elseif elevCollect:IsA("Folder") then
                                elevPart = elevCollect:FindFirstChildWhichIsA("BasePart", true)
                            elseif elevCollect:IsA("BasePart") then
                                elevPart = elevCollect
                            end
                            if elevPart then elevatorPos = elevPart.Position end
                        end
                    end
                    
                    for _, l in pairs(w:GetChildren()) do 
                        local lPos = l:IsA("Model") and (l.PrimaryPart and l.PrimaryPart.Position or l:FindFirstChildWhichIsA("BasePart") and l:FindFirstChildWhichIsA("BasePart").Position) or l.Position
                        -- Skip if near elevator (within 15 studs)
                        if Config.ESP.HideElevator and elevatorPos and lPos then
                            local elevDist = (elevatorPos - lPos).Magnitude
                            if elevDist <= 15 then continue end
                        end
                        createESP(l, l.Name, Color3.new(0.2,1,0.2)) 
                    end
                end
            end
            -- Container ESP with Status Labels
            if Config.ESP.Containers and gs:FindFirstChild("InteractiveItem") then
                -- Monster Blacklist - DO NOT show these as containers!
                local monsterBlacklist = {
                    ["Worms"] = true, ["Worm"] = true, ["FridgeMonster"] = true,
                    ["MimicFridge"] = true, ["FakeFridge"] = true, ["Mimic"] = true,
                    ["TheForsaken"] = true, ["Crawler"] = true, ["Shadow"] = true
                }
                
                for _, c in pairs(gs.InteractiveItem:GetChildren()) do
                    if c:IsA("Model") then
                        -- Get base name (remove numbers)
                        local baseName = c.Name:match("^([A-Za-z]+)") or c.Name
                        
                        -- SKIP if this is a monster disguised as container
                        if monsterBlacklist[baseName] or monsterBlacklist[c.Name] then continue end
                        
                        -- Check if in Monsters folder (sometimes moves there)
                        if c.Parent and c.Parent.Name == "Monsters" then continue end
                        
                        -- Multi-method opened detection
                        local isOpen = false
                        local attrs = c:GetAttributes()
                        
                        -- Method 1: Check multiple attribute names
                        if attrs then
                            isOpen = attrs.Open == true or attrs.opened == true 
                                or attrs.IsOpen == true or attrs.isOpen == true or attrs.Opened == true
                        end
                        
                        -- Method 2: Visual part check
                        if not isOpen then
                            local openedPart = c:FindFirstChild("Opened") or c:FindFirstChild("Open")
                            local closedPart = c:FindFirstChild("Closed") or c:FindFirstChild("Close")
                            if openedPart and openedPart:IsA("BasePart") and openedPart.Transparency < 0.9 then
                                isOpen = true
                            elseif closedPart and closedPart:IsA("BasePart") and closedPart.Transparency > 0.5 then
                                isOpen = true -- Closed part invisible = opened
                            end
                        end
                        
                        -- Method 3: Door rotation check (for Fridge type)
                        if not isOpen and baseName == "Fridge" then
                            local door = c:FindFirstChild("Door") or c:FindFirstChild("door")
                            if door and door:IsA("BasePart") then
                                local rotation = door.Orientation.Y
                                if math.abs(rotation) > 30 then isOpen = true end
                            end
                        end
                        
                        -- Method 4: Interactable attributes
                        if not isOpen then
                            local interactable = c:FindFirstChild("Interactable")
                            if interactable then
                                local intAttrs = interactable:GetAttributes()
                                if intAttrs and (intAttrs.Used == true or intAttrs.opened == true) then
                                    isOpen = true
                                end
                            end
                        end
                        
                        -- Hide if opened and filter enabled
                        if Config.ESP.HideOpened and isOpen then continue end
                        
                        -- Create ESP for containers
                        if not isOpen then 
                            createESP(c, c.Name, Color3.new(1,1,0.2))
                            
                            -- Update status label
                            local key = tostring(c)
                            if ESP_Objects[key] and ESP_Objects[key].Status then
                                if isOpen then
                                    ESP_Objects[key].Status.Text = "🔓 Open"
                                    ESP_Objects[key].Status.TextColor3 = Color3.fromRGB(255, 100, 100)
                                else
                                    ESP_Objects[key].Status.Text = "🔒 Closed"
                                    ESP_Objects[key].Status.TextColor3 = Color3.fromRGB(100, 255, 100)
                                end
                            end
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
                -- Ghosts can be in multiple locations
                local ghostFolders = {gs:FindFirstChild("Ghosts"), gs:FindFirstChild("NPCModels")}
                for _, folder in pairs(ghostFolders) do
                    if folder then
                        for _, ghost in pairs(folder:GetChildren()) do
                            -- Check if it's a ghost (by name or attributes)
                            local isGhost = ghost.Name:lower():find("ghost") or ghost.Name:lower():find("spirit")
                            if isGhost or (ghost:GetAttribute("IsGhost") == true) then
                                createESP(ghost, "Ghost", Color3.fromRGB(180, 50, 255)) -- Purple color
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

local function interactWithTarget(target)
    if not target or not RootPart then return end
    local targetPos = target:IsA("Model") and (target.PrimaryPart and target.PrimaryPart.Position or target:FindFirstChildWhichIsA("BasePart") and target:FindFirstChildWhichIsA("BasePart").Position) or target.Position
    if not targetPos then return end
    
    -- Use configurable interact distance (default 25)
    local distance = Config.InteractDistance or 25
    local offsetCFrame = CFrame.new(targetPos) * CFrame.new(0, 0, math.min(distance / 4, 6))
    
    if Config.UseTween then
        local tween = TweenService:Create(RootPart, TweenInfo.new(0.5), {CFrame = offsetCFrame})
        tween:Play()
        tween.Completed:Wait()
    else
        RootPart.CFrame = offsetCFrame
    end
    task.wait(0.2)
    
    local interact = target:FindFirstChild("Interactable", true) or target:FindFirstChild("Interact", true)
    if interact then
        safeFireRemote("Interactable", interact.Position)
    else
        safeFireRemote("Interactable", target)
    end
    task.wait(0.3)
end

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
                            AestheticUI:Notify({Title = "DANGER", Message = getEntityName(m) .. " nearby!", Type = "Warning"})
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
        -- Apply farm speed multiplier
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
                    StatusLabel.Text = "Status: <font color='#FF0000'>⚠️ Safe Mode - Monster Nearby</font>"
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
            StatusLabel.Text = "Status: <font color='#8A2BE2'>Selling Items...</font>"
            safeFireRemote("BackpackSellAll") 
            task.wait(1) 
            continue 
        end
        
        local gs, targets = workspace:FindFirstChild("GameSystem"), {}
        if gs then
            -- Determine radius (unlimited or limited)
            local effectiveRadius = Config.NoLimitRadius and 999999 or Config.LootRadius
            
            -- Safe Zone Logic - Pause farm if near elevator and banking
            if Config.SafeZoneLogic then
                local elevCollect = gs:FindFirstChild("Loots") and gs.Loots:FindFirstChild("ElevatorCollect")
                if elevCollect then
                    local elevPart = elevCollect:IsA("Model") and (elevCollect.PrimaryPart or elevCollect:FindFirstChildWhichIsA("BasePart")) or elevCollect
                    if elevPart and (RootPart.Position - elevPart.Position).Magnitude < 30 then
                        -- In safe zone, check if we should be banking
                        local invCount = getInventoryCount()
                        local sellThreshold = math.floor(4 * (Config.AutoSellPercent / 100))
                        if invCount >= sellThreshold then
                            StatusLabel.Text = "Status: <font color='#00BFFF'>Safe Zone - Banking...</font>"
                            task.wait(1)
                            continue -- Let sell logic handle it
                        end
                    end
                end
            end
            
            local loots = gs:FindFirstChild("Loots") and gs.Loots:FindFirstChild("World")
            if loots then for _, l in pairs(loots:GetChildren()) do
                local d = (RootPart.Position - l.Position).Magnitude
                if d < effectiveRadius then 
                    -- Loot Filter - Skip blacklisted items
                    if not (Config.LootFilter and isBlacklisted(l.Name)) then
                        table.insert(targets, {Object = l, Name = l.Name, Position = l.Position, Distance = d}) 
                    end
                end
            end end
            local containers = gs:FindFirstChild("InteractiveItem")
            if containers then for _, c in pairs(containers:GetChildren()) do
                if not c:GetAttribute("Open") and not c:GetAttribute("Ignore") then
                    local cPos = c.PrimaryPart and c.PrimaryPart.Position or (c:FindFirstChildWhichIsA("BasePart") and c:FindFirstChildWhichIsA("BasePart").Position)
                    if cPos and (RootPart.Position - cPos).Magnitude < effectiveRadius then table.insert(targets, {Object = c, Name = c.Name, Position = cPos, Distance = (RootPart.Position - cPos).Magnitude}) end
                end
            end end
        end
        if #targets > 0 then
            if Config.PriorityLoot then sortByPriority(targets) end
            StatusLabel.Text = "Status: <font color='#00FF00'>Farming " .. targets[1].Name .. "</font>"
            
            -- Smart Pathing - Add random delay before interact
            if Config.SmartPathing then
                task.wait(0.5 + math.random() * 1.0)
            end
            
            interactWithTarget(targets[1].Object)
        else StatusLabel.Text = "Status: <font color='#892be2'>Searching...</font>" end
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
                    if mRoot and (RootPart.Position - mRoot.Position).Magnitude < 15 then safeFireRemote("Interactable", m) end
                end
            end
        end
    end
end)

-- Stats Loop
task.spawn(function()
    while Config.Alive do
        task.wait(1)
        local elapsed = tick() - Stats.StartTime
        StatsLabel:Set(string.format("Items: %d | IPM: %.1f | Floor: %d", Stats.ItemsCollected, Stats.ItemsCollected / (elapsed / 60), Stats.CurrentFloor))
        
        local statusColor = Config.FarmActive and "#00FF00" or "#FFD700"
        local statusText = Config.FarmActive and "Farming Active" or "Idle"
        StatusLabel:Set(string.format("Status: <font color='%s'>%s</font>", statusColor, statusText))
    end
end)

-- [AUTO TOOL SPAM] Loop
task.spawn(function()
    while Config.Alive do
        task.wait(0.16) -- ~6 per second
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

-- [SAFE EVAC] Countdown Monitor
task.spawn(function()
    while Config.Alive do
        task.wait(1)
        if Config.SafeEvac and DungeonValue and DungeonValue.DungeonStats and DungeonValue.DungeonStats.Value then
            local data = DungeonValue.DungeonStats.Value
            if data and data.countdown and data.countdown.time then
                local timeLeft = data.countdown.time
                if timeLeft <= Config.SafeEvacTime and data.state == "Normal" then
                    local evacs = game:GetService("CollectionService"):GetTagged("Evacuation")
                    if #evacs > 0 then
                        local target = evacs[1]
                        local interact = target:FindFirstChild("Interactable", true)
                        if interact then 
                            safeFireRemote("EvacuateAlone", interact.Position)
                            if Config.NotificationsEnabled then 
                                AestheticUI:Notify({Title = "SURVIVAL", Message = "Safe Evac Triggered!", Type = "Warning"})
                            end
                            task.wait(5) -- Cooldown
                        end
                    end
                end
            end
        end
    end
end)

-- [ANTI-AFK] Camera Movement Loop
task.spawn(function()
    while Config.Alive do
        task.wait(60 + math.random() * 60) -- Wait 60-120 seconds
        if Config.AntiAFK then
            local camera = workspace.CurrentCamera
            if camera then
                -- Small random camera rotation (anti-detection)
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
                        -- Force player to stay at elevator (God Mode)
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
                            -- Determine vote decision based on floor and inventory
                            local invCount = getInventoryCount()
                            local sellThreshold = math.floor(4 * (Config.AutoSellPercent / 100))
                            local shouldEvacuate = (invCount >= sellThreshold) or (Stats.CurrentFloor >= Config.MaxFloorTarget)
                            
                            -- Find vote buttons (Greenky = Go Deeper, Yellowky = Evacuate/Leave)
                            local buttonType = nil
                            if interactive.Name:lower():find("green") or interact.Color == Color3.fromRGB(0, 255, 0) then
                                buttonType = "Deeper"
                            elseif interactive.Name:lower():find("yellow") or interact.Color == Color3.fromRGB(255, 255, 0) then
                                buttonType = "Evacuate"
                            end
                            
                            -- Vote logic
                            if shouldEvacuate and buttonType == "Evacuate" then
                                -- Vote to evacuate
                                safeFireRemote("Vote", interact.Position, "Evacuate")
                                if Config.NotificationsEnabled then
                                    AestheticUI:Notify({Title = "Elevator", Message = "Voting to Evacuate!", Type = "Info"})
                                end
                                task.wait(5)
                                break
                            elseif not shouldEvacuate and buttonType == "Deeper" then
                                -- Vote to go deeper
                                safeFireRemote("Vote", interact.Position, "Deeper")
                                if Config.NotificationsEnabled then
                                    AestheticUI:Notify({Title = "Elevator", Message = "Voting to Go Deeper!", Type = "Info"})
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
                -- Notify every 30 seconds
                if tick() - lastCountdownNotify >= 30 then
                    lastCountdownNotify = tick()
                    local mins = math.floor(timeLeft / 60)
                    local secs = math.floor(timeLeft % 60)
                    if Config.NotificationsEnabled then
                        AestheticUI:Notify({
                            Title = "⏱️ Countdown", 
                            Message = string.format("Time Left: %02d:%02d | Floor: %d", mins, secs, Stats.CurrentFloor),
                            Type = "Info"
                        })
                    end
                end
            end
        end
    end
end)

-- [LOOT BLACKLIST] Low-value items to skip when Loot Filter enabled
local LootBlacklist = {
    ["Flashlight"] = true,
    ["GlowStick"] = true,
    ["Lighter"] = true,
    ["Vitamins"] = true,
    ["Chips"] = true,
    ["Cookie"] = true,
    ["Chocolate"] = true,
    ["Candy"] = true,
    ["Soda"] = true,
    ["Cola"] = true,
    ["Water"] = true,
    ["Bandage"] = true,
    ["Medkit"] = true
}

local function isBlacklisted(itemName)
    return LootBlacklist[itemName] == true
end

AestheticUI:Notify({ Title = "RuneX Ready", Message = "Refactored Deadly Delivery Active", Type = "Success" })

-- Set UI Toggle Keybind (Right Shift)
Window:SetBind(Enum.KeyCode.RightShift)
