-- [[ AESTHETIC MAIN - PREMIUM REFACTOR ]]
-- Credits: xxdayssheus
-- Refactored for AestheticUI

local AestheticUI = loadstring(game:HttpGet("file:///d:/roblox%20lua%20deadly%202/AestheticUI.lua"))()

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
    
    -- Survival & Dungeon
    SafeEvac = false,
    SafeEvacTime = 5,
    AutoJuicer = false,
    AutoToolSpam = false,
    
    ESP = {
        Monsters = false,
        Loot = false,
        Containers = false,
        NoLimit = false,
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
    if #list == 0 then return end
    if mode == "Random" then
        safeTeleport(list[math.random(1, #list)].Root.CFrame * CFrame.new(0, 5, 0))
    else
        table.sort(list, function(a,b) return (RootPart.Position - a.Position).Magnitude < (RootPart.Position - b.Position).Magnitude end)
        safeTeleport(list[1].Root.CFrame * CFrame.new(0, 5, 0))
    end
end

-- [Stamina] God Mode Hook
local staminaHookActive = false
local function toggleInfiniteStamina(state)
    staminaHookActive = state
    if state and not getgenv()._stamina_hooked then
        getgenv()._stamina_hooked = true
        pcall(function()
            local TEvent = _G.TEvent or (workspace:FindFirstChild("GameSystem") and workspace.GameSystem:FindFirstChild("TEvent"))
            if TEvent and TEvent.FireRemote then
                local old = TEvent.FireRemote
                TEvent.FireRemote = function(name, ...)
                    if staminaHookActive and name == "SyncStaminaConsume" then return end
                    return old(name, ...)
                end
            end
        end)
    end
end

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

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
    Title = "AESTHETIC <font color='#8A2BE2'>DELIVERY</font>",
    Subtitle = "Premium Dungeon Automation",
    Logo = "rbxassetid://6031229361"
})

local HomeTab = AestheticUI:CreateTab(Window, { Name = "Home", Icon = "rbxassetid://1072334 density" })
local CombatTab = AestheticUI:CreateTab(Window, { Name = "Combat", Icon = "rbxassetid://1072334 sword" })
local AutoTab = AestheticUI:CreateTab(Window, { Name = "Automation", Icon = "rbxassetid://1072334 settings" })
local VisualTab = AestheticUI:CreateTab(Window, { Name = "Visuals", Icon = "rbxassetid://1072334 eye" })
local WorldTab = AestheticUI:CreateTab(Window, { Name = "World", Icon = "rbxassetid://1072334 map" })
local SettingsTab = AestheticUI:CreateTab(Window, { Name = "Settings", Icon = "rbxassetid://1072334 sliders" })

-- Home Section
local StatsSection = AestheticUI:CreateSection(HomeTab, "Statistics")
StatusLabel = AestheticUI:CreateLabel(StatsSection, "Status: <font color='#00FF00'>Ready</font>")
StatsLabel = AestheticUI:CreateLabel(StatsSection, "Items: 0 | IPM: 0.0 | Floors: 0")

AestheticUI:CreateButton(StatsSection, {
    Text = "🚨 PANIC (Emergency Stop)",
    Tooltip = "Instantly terminates the script and destroys the UI",
    Callback = function() 
        Config.Alive = false
        Window:Destroy()
    end
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

AestheticUI:CreateButton(DungeonSection, {
    Text = "🧃 Instant Juicer",
    Callback = function() safeFireRemote("UseJuicer") end
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

local UtilSection = AestheticUI:CreateSection(WorldTab, "Utilities & Exploits")
AestheticUI:CreateButton(UtilSection, {
    Text = "💵 Instant Sell All Items",
    Callback = function() safeFireRemote("BackpackSellAll") end
})

AestheticUI:CreateButton(UtilSection, {
    Text = "🔧 Instant Sell All Tools",
    Callback = function() safeFireRemote("BackpackSellAllTools") end
})

AestheticUI:CreateButton(UtilSection, {
    Text = "🎁 Claim Offline Reward",
    Callback = function() safeFireRemote("OfflineReward", tick()) end
})

Window:SetBind(Enum.KeyCode.LeftControl)

-- ============================================================
-- CORE LOGIC LOOPS (ESP, Farming, Combat, Survival)
-- ============================================================

-- [SURVIVAL] Monitor State & Countdown
task.spawn(function()
    while Config.Alive do
        task.wait(0.5)
        if DungeonValue and DungeonValue.DungeonStats then
            local data = DungeonValue.DungeonStats.Value
            Stats.Countdown, Stats.DungeonState, Stats.CurrentFloor = data.countdown and data.countdown.time or 999, data.state or "Normal", data.level or 0
            if Config.SafeEvac and Stats.Countdown <= Config.SafeEvacTime and Stats.DungeonState == "Normal" then
                AestheticUI:Notify({Title = "⚠️ SURVIVAL", Content = "Evacuation Triggered", Type = "Warning"})
                safeFireRemote("EvacuateAlone")
                task.wait(2)
            end
        end
    end
end)

-- [ESP] Billboard Loop
local ESP_Objects = {}
local function createESP(instance, name, color)
    if ESP_Objects[instance] then return end
    local esp = Instance.new("BillboardGui", game:GetService("CoreGui"))
    esp.Name, esp.Adornee, esp.AlwaysOnTop, esp.Size = "A_ESP", instance, true, UDim2.new(0, 80, 0, 40)
    esp.StudsOffset = Vector3.new(0, 2, 0)
    local lbl = Instance.new("TextLabel", esp) lbl.Size, lbl.BackgroundTransparency, lbl.Text, lbl.TextColor3, lbl.Font, lbl.TextSize = UDim2.new(1,0,0.5,0), 1, name, color, Enum.Font.GothamBold, 12
    local dlbl = Instance.new("TextLabel", esp) dlbl.Size, dlbl.Position, dlbl.BackgroundTransparency, dlbl.Text, dlbl.TextColor3, dlbl.TextSize = UDim2.new(1,0,0.5,0), UDim2.new(0,0,0.5,0), 1, "0m", Color3.new(1,1,1), 10
    ESP_Objects[instance] = { Gui = esp, Dist = dlbl }
end

task.spawn(function()
    while Config.Alive do
        task.wait(0.5)
        if not RootPart then continue end
        local gs = workspace:FindFirstChild("GameSystem")
        if gs then
            if Config.ESP.Monsters and gs:FindFirstChild("Monsters") then
                for _, m in pairs(gs.Monsters:GetChildren()) do if isDangerous(m) then createESP(m, getEntityName(m), Color3.new(1,0.2,0.2)) end end
            end
            if Config.ESP.Loot and gs:FindFirstChild("Loots") then
                local w = gs.Loots:FindFirstChild("World")
                if w then for _, l in pairs(w:GetChildren()) do createESP(l, l.Name, Color3.new(0.2,1,0.2)) end end
            end
            if Config.ESP.Containers and gs:FindFirstChild("InteractiveItem") then
                for _, c in pairs(gs.InteractiveItem:GetChildren()) do
                    if not c:GetAttribute("Open") then createESP(c, c.Name, Color3.new(1,1,0.2)) end
                end
            end
        end
        for obj, data in pairs(ESP_Objects) do
            if obj and obj.Parent then
                local dist = (RootPart.Position - (obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:FindFirstChildWhichIsA("BasePart").Position) or obj.Position)).Magnitude
                data.Dist.Text = math.floor(dist) .. "m"
                data.Gui.Enabled = Config.ESP.NoLimit or dist < 500
            else data.Gui:Destroy() ESP_Objects[obj] = nil end
        end
    end
end)

-- [FARM] Automation Loop
task.spawn(function()
    while Config.Alive do
        task.wait(0.5)
        if not Config.FarmActive or not RootPart then continue end
        checkStuck()
        if getInventoryCount() >= 4 then 
            StatusLabel.Text = "Status: <font color='#8A2BE2'>Selling Items...</font>"
            safeFireRemote("BackpackSellAll") 
            task.wait(1) 
            continue 
        end
        local gs, targets = workspace:FindFirstChild("GameSystem"), {}
        if gs then
            local loots = gs:FindFirstChild("Loots") and gs.Loots:FindFirstChild("World")
            if loots then for _, l in pairs(loots:GetChildren()) do
                local d = (RootPart.Position - l.Position).Magnitude
                if d < Config.LootRadius then table.insert(targets, {Object = l, Name = l.Name, Position = l.Position, Distance = d}) end
            end end
            local containers = gs:FindFirstChild("InteractiveItem")
            if containers then for _, c in pairs(containers:GetChildren()) do
                if not c:GetAttribute("Open") and not c:GetAttribute("Ignore") then
                    local cPos = c.PrimaryPart and c.PrimaryPart.Position or (c:FindFirstChildWhichIsA("BasePart") and c:FindFirstChildWhichIsA("BasePart").Position)
                    if cPos and (RootPart.Position - cPos).Magnitude < Config.LootRadius then table.insert(targets, {Object = c, Name = c.Name, Position = cPos, Distance = (RootPart.Position - cPos).Magnitude}) end
                end
            end end
        end
        if #targets > 0 then
            sortByPriority(targets)
            StatusLabel.Text = "Status: <font color='#00FF00'>Farming " .. targets[1].Name .. "</font>"
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
        StatsLabel.Text = string.format("Items: %d | IPM: %.1f | Floor: %d", Stats.ItemsCollected, Stats.ItemsCollected / (elapsed / 60), Stats.CurrentFloor)
    end
end)

AestheticUI:Notify({ Title = "RuneX Ready", Message = "Refactored Deadly Delivery Active", Type = "Success" })
