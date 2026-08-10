--[[
   ═══════════════════════════════════════════════════════════════════════════════
   ████████╗ █████╗ ██████╗ ██████╗ ███████╗██████╗  ██████╗ ██████╗ 
   ╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝ 
      ██║   ███████║██████╔╝██████╔╝█████╗  ██████╔╝██║     ██║     
      ██║   ██╔══██║██╔═══╝ ██╔═══╝ ██╔══╝  ██╔══██╗██║     ██║     
      ██║   ██║  ██║██║     ██║     ███████╗██║  ██║╚██████╗╚██████╗
      ╚═╝   ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝
   ═══════════════════════════════════════════════════════════════════════════════
   tapped.cc - Ultimate Da Hood HvH Script
   GitHub: https://github.com/jackrst/yapped.cc-dahood-
   Version: 2.0.1
   Last Updated: 2024
   ═══════════════════════════════════════════════════════════════════════════════

   ── TABLE OF CONTENTS ──
   1.  Load Libraries
   2.  Services
   3.  Character / GunHandler
   4.  AimCache System
   5.  Settings (FULLY CUSTOMIZABLE)
   6.  Core Functions
   7.  No Slowdown Fix
   8.  Orbiting Objects Declaration (FIXED)
   9.  Target Indicator UI (Draggable)
   10. Kill Aura Bubble (Holographic)
   11. Hitbox Expander + Visual
   12. Smart Weapon Selection
   13. Auto Stomp
   14. Ragebot Keybind
   15. FOV Circle
   16. Helper Functions
   17. Cache System (Validate/Update)
   18. GunHandler Hooks (Silent Aim + Bullet TP + Glow Tracers)
   19. Velocity Desync
   20. Network Fake Lag
   21. Anti-Stomp (Defov)
   22. Walkable Desync (Replaces Anti-Aim)
   23. SpinBot
   24. Desync Visual (Fake Character)
   25. Orbiting Target Effect
   26. Fly / Noclip / Speed
   27. Bunny Hop / Auto Strafing / Auto Crouch
   28. ESP (Fully Customizable)
   29. Chams (Fully Customizable)
   30. World Mods (Fully Customizable)
   31. Respawn Handler
   32. Initialization
   33. Update Loops
   34. Starlight UI (Every Feature Toggleable)
   ═══════════════════════════════════════════════════════════════════════════════
--]]

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. LOAD LIBRARIES (FIXED: Single Load)
-- ═══════════════════════════════════════════════════════════════════════════

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. SERVICES
-- ═══════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. CHARACTER / GUNHANDLER
-- ═══════════════════════════════════════════════════════════════════════════

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local Character = getCharacter()
local Humanoid = Character:WaitForChild("Humanoid")
local originalWalkSpeed = 16

local GunHandler = nil
local gunHandlerAvailable = pcall(function()
    GunHandler = require(ReplicatedStorage.Modules.GunHandler)
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. AIM CACHE SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

local AimCache = {
    Target = nil,
    TargetPart = nil,
    TargetPos = nil,
    Frame = 0,
    Locked = false,
}

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. SETTINGS (FULLY CUSTOMIZABLE - EVERY FEATURE TOGGLEABLE)
-- ═══════════════════════════════════════════════════════════════════════════

local Settings = {
    -- ── Ragebot ──
    SilentAim = true,
    SilentAimMode = "Rage",          -- Rage / Legit
    LegitSmoothness = 0.3,           -- ⬅️ ADDED: 0.01-1.0
    FOVRadius = 9999,                -- 50-9999
    AimPart = "Head",                -- Head / Torso / HumanoidRootPart / UpperTorso / Left Arm / Right Arm / Left Leg / Right Leg
    TeamCheck = false,
    VisibleCheck = false,
    OnRightClickOnly = false,
    NoRecoil = true,
    AutoShoot = true,
    KillAura = true,
    KillAuraRange = 300,             -- 50-500
    Triggerbot = true,
    HitboxExpander = true,
    HitboxExpanderSize = 25,         -- 5-50
    BulletTP = true,
    Prediction = true,
    PredictionValue = 0.121,         -- 0.01-0.3
    NoSlowDown = true,
    
    -- ── Smart Features ──
    AutoWeapon = true,
    RagebotKeybind = Enum.KeyCode.X,
    AutoStomp = true,
    StompKeybind = Enum.KeyCode.E,
    TargetIndicator = true,
    FakeMacro = false,
    
    -- ── HvH Features ──
    WalkableDesync = false,          -- Replaces Anti-Aim
    DesyncAmount = 120,              -- 30-180
    VelocityDesync = false,
    NetworkFakeLag = false,
    NetworkFakeLagFactor = 15,       -- 1-20
    AirshotResolver = true,
    AntiStomp = true,
    
    -- ── Visual Effects ──
    DesyncVisual = false,            -- Fake character
    OrbitingTargets = true,          -- 10 orbs around target
    HitboxVisual = true,             -- Shows expanded hitbox
    
    -- ── Spin Bot ──
    SpinBot = false,
    SpinBotSpeed = 5,                -- 1-20
    
    -- ── FOV ──
    FOVCircleVisible = true,
    FOVCircleColor = Color3.fromRGB(255, 0, 0),
    
    -- ── ESP ──
    ESPEnabled = true,
    ESPBoxes = true,
    ESPNames = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPSnaplines = false,
    ESPTracers = false,
    ESPHeadDot = true,
    ESPSkeleton = false,
    ESPWeapon = false,
    ESPEnemyColor = Color3.fromRGB(255, 0, 0),
    ESPTeamColor = Color3.fromRGB(0, 255, 0),
    ESPVisibleColor = Color3.fromRGB(255, 255, 0),
    TracerColor = Color3.fromRGB(255, 255, 0),
    
    -- ── Chams ──
    ChamsEnabled = true,
    ChamsPlayer = true,
    ChamsColor = Color3.fromRGB(0, 255, 255),
    ChamsTransparency = 0.4,
    
    -- ── Glow Tracers ──
    GlowTracers = true,
    TracerGlowColor = Color3.fromRGB(255, 50, 50),
    TracerLifeTime = 0.6,
    TracerThickness = 0.5,
    
    -- ── World Mods ──
    WorldBrightness = 1.5,
    WorldAmbient = Color3.fromRGB(200, 200, 200),
    WorldFogEnabled = false,
    WorldFogColor = Color3.fromRGB(0, 0, 0),
    WorldFogEnd = 1000,
    WorldSkyColor = Color3.fromRGB(0, 0, 0),
    WorldBottomColor = Color3.fromRGB(0, 0, 0),
    
    -- ── Movement ──
    Fly = false,
    Noclip = false,
    Speed = 16,                      -- 1-100
    BunnyHop = false,
    AutoStrafing = false,
    AutoCrouch = false,
}

-- ═══════════════════════════════════════════════════════════════════════════
-- 6. CORE FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

local function fixSlowdown()
    if not Settings.NoSlowDown then return end
    shared.CenterOfMass = "NONE"
    shared.MacroSpeed = 0
end
fixSlowdown()

-- ═══════════════════════════════════════════════════════════════════════════
-- 7. NO SLOWDOWN FIX (Force Forward Velocity)
-- ═══════════════════════════════════════════════════════════════════════════

local function cancelSlowdown()
    if not Settings.NoSlowDown then return end
    if not Character then return end
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local vel = hrp.AssemblyLinearVelocity
    local forward = hrp.CFrame.LookVector
    local speed = math.max(originalWalkSpeed, vel.Magnitude)
    hrp.AssemblyLinearVelocity = forward * speed
end

local function hookWeaponSlowdown()
    if not Character then return end
    for _, child in ipairs(Character:GetChildren()) do
        if child:IsA("Tool") and child:FindFirstChild("Activated") then
            child.Activated:Connect(function()
                task.wait(0.02)
                cancelSlowdown()
            end)
        end
    end
end
hookWeaponSlowdown()

if gunHandlerAvailable and GunHandler then
    local origShoot = GunHandler.shoot
    GunHandler.shoot = function(args)
        local result = origShoot(args)
        task.spawn(cancelSlowdown)
        return result
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 8. ORBITING OBJECTS DECLARATION (FIXED: Moved Before clearCache)
-- ═══════════════════════════════════════════════════════════════════════════

local orbitingObjects = {}
local orbitConnection = nil

-- ═══════════════════════════════════════════════════════════════════════════
-- 9. TARGET INDICATOR UI (Draggable Box)
-- ═══════════════════════════════════════════════════════════════════════════

local targetGui = Instance.new("ScreenGui")
targetGui.Name = "TargetIndicator"
targetGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
targetGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 60)
frame.Position = UDim2.new(0.5, -120, 0.5, -30)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Active = true
frame.Draggable = true
frame.Visible = false
frame.Parent = targetGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -10, 1, 0)
label.Position = UDim2.new(0, 5, 0, 0)
label.BackgroundTransparency = 1
label.Text = "No Target"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 14
label.Font = Enum.Font.GothamSemibold
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Center
label.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -22, 0, 2)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    Settings.TargetIndicator = false
    frame.Visible = false
end)

local function updateTargetIndicator()
    if not Settings.TargetIndicator then
        if frame then frame.Visible = false end
        return
    end
    if AimCache.Target and isTargetValid(AimCache.Target) then
        local player = Players:GetPlayerFromCharacter(AimCache.Target)
        local name = player and player.Name or "Unknown"
        local hum = AimCache.Target:FindFirstChild("Humanoid")
        local health = hum and math.floor(hum.Health) or 0
        local dist = AimCache.TargetPos and math.floor((AimCache.TargetPos - Camera.CFrame.Position).Magnitude) or 0
        label.Text = string.format("%s\n❤️ %d HP  |  📏 %dm", name, health, dist)
        label.TextColor3 = (health > 50) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        frame.Visible = true
    else
        frame.Visible = false
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 10. KILL AURA BUBBLE (Holographic Range Indicator)
-- ═══════════════════════════════════════════════════════════════════════════

local killAuraBubble = nil
local killAuraRing = nil
local bubbleSpinConnection = nil

local function createKillAuraBubble()
    if killAuraBubble then killAuraBubble:Destroy() end
    if killAuraRing then killAuraRing:Destroy() end
    if bubbleSpinConnection then bubbleSpinConnection:Disconnect() end
    killAuraBubble = nil
    killAuraRing = nil
    bubbleSpinConnection = nil
    if not Settings.KillAura then return end
    if not Character then return end
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bubble = Instance.new("Part")
    bubble.Name = "KillAuraBubble"
    bubble.Size = Vector3.new(Settings.KillAuraRange * 2, Settings.KillAuraRange * 2, Settings.KillAuraRange * 2)
    bubble.Shape = Enum.PartType.Ball
    bubble.Material = Enum.Material.Neon
    bubble.Color = Color3.fromRGB(0, 150, 255)
    bubble.Transparency = 0.7
    bubble.Anchored = false
    bubble.CanCollide = false
    bubble.CastShadow = false
    bubble.Parent = hrp
    local weld = Instance.new("Weld")
    weld.Part0 = hrp
    weld.Part1 = bubble
    weld.C0 = CFrame.new(0, 0, 0)
    weld.Parent = bubble
    local ring = Instance.new("Part")
    ring.Name = "KillAuraRing"
    ring.Size = Vector3.new(Settings.KillAuraRange * 2.1, 0.2, Settings.KillAuraRange * 2.1)
    ring.Shape = Enum.PartType.Cylinder
    ring.Material = Enum.Material.Neon
    ring.Color = Color3.fromRGB(0, 200, 255)
    ring.Transparency = 0.4
    ring.Anchored = false
    ring.CanCollide = false
    ring.CastShadow = false
    ring.Parent = hrp
    local ringWeld = Instance.new("Weld")
    ringWeld.Part0 = hrp
    ringWeld.Part1 = ring
    ringWeld.C0 = CFrame.new(0, 0, 0)
    ringWeld.Parent = ring
    bubbleSpinConnection = RunService.Heartbeat:Connect(function()
        if not ring.Parent then
            bubbleSpinConnection:Disconnect()
            return
        end
        ring.CFrame = ring.CFrame * CFrame.Angles(0, math.rad(2), 0)
    end)
    killAuraBubble = bubble
    killAuraRing = ring
end

local function updateKillAuraBubble()
    if not Settings.KillAura then
        if killAuraBubble then killAuraBubble:Destroy() end
        if killAuraRing then killAuraRing:Destroy() end
        if bubbleSpinConnection then bubbleSpinConnection:Disconnect() end
        killAuraBubble = nil
        killAuraRing = nil
        bubbleSpinConnection = nil
        return
    end
    if not killAuraBubble or not killAuraBubble.Parent then
        createKillAuraBubble()
        return
    end
    local newSize = Settings.KillAuraRange * 2
    killAuraBubble.Size = Vector3.new(newSize, newSize, newSize)
    if killAuraRing then
        killAuraRing.Size = Vector3.new(newSize * 1.05, 0.2, newSize * 1.05)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 11. HITBOX EXPANDER + VISUAL (Shows expanded hitbox)
-- ═══════════════════════════════════════════════════════════════════════════

local hitboxVisuals = {}

local function updateHitboxVisual()
    for _, v in pairs(hitboxVisuals) do
        if v then v:Destroy() end
    end
    hitboxVisuals = {}
    
    if not Settings.HitboxExpander or not Settings.HitboxVisual then return end
    
    for _, char in ipairs(getCharacters()) do
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp ~= Character:FindFirstChild("HumanoidRootPart") then
            local visual = Instance.new("Part")
            visual.Size = Vector3.new(Settings.HitboxExpanderSize, Settings.HitboxExpanderSize, Settings.HitboxExpanderSize)
            visual.CFrame = hrp.CFrame
            visual.Material = Enum.Material.Neon
            visual.Color = Color3.fromRGB(255, 50, 50)
            visual.Transparency = 0.5
            visual.Anchored = true
            visual.CanCollide = false
            visual.Parent = workspace
            local weld = Instance.new("Weld")
            weld.Part0 = hrp
            weld.Part1 = visual
            weld.C0 = CFrame.new(0, 0, 0)
            weld.Parent = visual
            table.insert(hitboxVisuals, visual)
        end
    end
end

local function applyHitboxExpander()
    if not Settings.HitboxExpander then return end
    local size = Settings.HitboxExpanderSize or 25
    for _, char in ipairs(getCharacters()) do
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp ~= Character:FindFirstChild("HumanoidRootPart") then
            hrp.Size = Vector3.new(size, size, size)
            hrp.CanCollide = false
            hrp.Transparency = 0.5
        end
    end
    if Settings.HitboxVisual then
        updateHitboxVisual()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 12. SMART WEAPON SELECTION
-- ═══════════════════════════════════════════════════════════════════════════

local function isGun(tool)
    if not tool:IsA("Tool") then return false end
    if tool:FindFirstChild("GunScript") then return true end
    if tool:FindFirstChild("GunClientShotgun") then return true end
    if tool:FindFirstChild("RemoteEvent") then return true end
    if tool:FindFirstChild("Handle") and tool:FindFirstChild("Ammo") then return true end
    return false
end

local function getBestGun()
    if not Character then return nil end
    local bestGun = nil
    local bestScore = -1
    local equipped = Character:FindFirstChildOfClass("Tool")
    if equipped and isGun(equipped) then
        return equipped
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if isGun(tool) then
                local range = tool:FindFirstChild("Range")
                local damage = tool:FindFirstChild("Damage")
                local score = 0
                if range then score = score + range.Value end
                if damage then score = score + damage.Value * 10 end
                if score > bestScore then
                    bestScore = score
                    bestGun = tool
                end
            end
        end
    end
    if not bestGun then
        for _, tool in ipairs(Character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                bestGun = tool
                break
            end
        end
    end
    return bestGun
end

local function equipBestGun()
    if not Settings.AutoWeapon then return end
    if not AimCache.Target then return end
    local current = getCurrentWeapon()
    if current then return end
    local gun = getBestGun()
    if gun and gun.Parent ~= Character then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack and gun.Parent == backpack then
            gun.Parent = Character
            task.wait(0.1)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 13. AUTO STOMP
-- ═══════════════════════════════════════════════════════════════════════════

local function stompTarget()
    if not Settings.AutoStomp then return end
    if not AimCache.Target or not isTargetValid(AimCache.Target) then return end
    local targetPos = AimCache.TargetPos
    if not targetPos then return end
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        task.wait(0.1)
    end
    local key = Enum.KeyCode.E
    UserInputService:SetKeyDown(key)
    task.wait(0.05)
    UserInputService:SetKeyUp(key)
    clearCache()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 14. RAGEBOT KEYBIND
-- ═══════════════════════════════════════════════════════════════════════════

local ragebotActive = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.RagebotKeybind then
        ragebotActive = not ragebotActive
        if ragebotActive then
            equipBestGun()
            updateCache()
        else
            clearCache()
        end
    end
    if input.KeyCode == Settings.StompKeybind and ragebotActive then
        stompTarget()
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 15. FOV CIRCLE
-- ═══════════════════════════════════════════════════════════════════════════

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Filled = false
fovCircle.Transparency = 0.8
fovCircle.Visible = Settings.FOVCircleVisible
fovCircle.Color = Settings.FOVCircleColor
fovCircle.Radius = Settings.FOVRadius

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y + 36)
    fovCircle.Radius = Settings.FOVRadius
    fovCircle.Visible = Settings.FOVCircleVisible
    fovCircle.Color = Settings.FOVCircleColor
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 16. HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

local function getCharacters()
    local chars = {}
    local playersFolder = workspace:FindFirstChild("Players")
    if playersFolder then
        for _, child in ipairs(playersFolder:GetChildren()) do
            if child:IsA("Model") and child ~= Character then
                local hum = child:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    table.insert(chars, child)
                end
            end
        end
    end
    return chars
end

local function getTargetPart(character)
    local partName = Settings.AimPart
    if type(partName) == "table" then partName = partName[1] or "Head" end
    local part = character:FindFirstChild(partName)
    if part then return part end
    part = character:FindFirstChild("HumanoidRootPart")
    if part then return part end
    part = character:FindFirstChild("UpperTorso")
    if part then return part end
    part = character:FindFirstChild("Torso")
    if part then return part end
    return nil
end

local function isTargetValid(character)
    if not character then return false end
    if not character.Parent then return false end
    local hum = character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true
end

local function clearCache()
    AimCache.Target = nil
    AimCache.TargetPart = nil
    AimCache.TargetPos = nil
    AimCache.Frame = 0
    AimCache.Locked = false
    -- Clear orbiting objects (FIXED)
    for _, obj in pairs(orbitingObjects) do
        if obj then obj:Destroy() end
    end
    orbitingObjects = {}
    if orbitConnection then orbitConnection:Disconnect() end
    orbitConnection = nil
end

local function GetClosestTarget()
    local closest = nil
    local shortestDist = Settings.FOVRadius
    local mousePos = UserInputService:GetMouseLocation()
    local mousePos2 = Vector2.new(mousePos.X, mousePos.Y + 36)
    local origin = Camera.CFrame.Position
    local chars = getCharacters()
    for _, char in ipairs(chars) do
        if char == Character then continue end
        if not char.Parent then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if Settings.TeamCheck then
            local player = Players:GetPlayerFromCharacter(char)
            if player and player.Team == LocalPlayer.Team then continue end
        end
        local targetPart = getTargetPart(char)
        if not targetPart then continue end
        if Settings.VisibleCheck then
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {Character, Camera}
            params.FilterType = Enum.RaycastFilterType.Blacklist
            local dir = (targetPart.Position - origin).Unit * 1000
            local result = workspace:Raycast(origin, dir, params)
            if result and result.Instance and not result.Instance:IsDescendantOf(char) then
                continue
            end
        end
        local targetPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        local screenPos = Vector2.new(targetPos.X, targetPos.Y)
        local dist = (screenPos - mousePos2).Magnitude
        local dirToTarget = (targetPart.Position - origin).Unit
        local dot = Camera.CFrame.LookVector:Dot(dirToTarget)
        if dist < shortestDist and dot > 0.3 then
            closest = char
            shortestDist = dist
        end
    end
    return closest
end

local function getCurrentWeapon()
    if Character then
        for _, child in ipairs(Character:GetChildren()) do
            if child:IsA("Tool") and child:FindFirstChild("Handle") then
                return child
            end
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 17. CACHE SYSTEM (Validate / Update)
-- ═══════════════════════════════════════════════════════════════════════════

local function validateCache()
    if not AimCache.Target then return false end
    if not isTargetValid(AimCache.Target) then return false end
    local part = getTargetPart(AimCache.Target)
    if not part then return false end
    local targetPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return false end
    local mousePos = UserInputService:GetMouseLocation()
    local mousePos2 = Vector2.new(mousePos.X, mousePos.Y + 36)
    local dist = (Vector2.new(targetPos.X, targetPos.Y) - mousePos2).Magnitude
    if dist > Settings.FOVRadius then return false end
    if Settings.TeamCheck then
        local player = Players:GetPlayerFromCharacter(AimCache.Target)
        if player and player.Team == LocalPlayer.Team then return false end
    end
    if Settings.VisibleCheck then
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {Character, Camera}
        params.FilterType = Enum.RaycastFilterType.Blacklist
        local dir = (part.Position - Camera.CFrame.Position).Unit * 1000
        local result = workspace:Raycast(Camera.CFrame.Position, dir, params)
        if result and result.Instance and not result.Instance:IsDescendantOf(AimCache.Target) then
            return false
        end
    end
    AimCache.TargetPos = part.Position
    AimCache.TargetPart = part
    return true
end

local function updateCache()
    if not Settings.SilentAim then
        clearCache()
        return
    end
    if Settings.OnRightClickOnly and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        clearCache()
        return
    end
    if validateCache() then
        return
    end
    local targetChar = GetClosestTarget()
    if targetChar then
        local targetPart = getTargetPart(targetChar)
        if targetPart then
            AimCache.Target = targetChar
            AimCache.TargetPart = targetPart
            AimCache.TargetPos = targetPart.Position
            AimCache.Frame = tick()
            AimCache.Locked = true
        end
    else
        clearCache()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 18. GUNHANDLER HOOKS (Silent Aim + Bullet TP + Glow Tracers)
-- ═══════════════════════════════════════════════════════════════════════════

if gunHandlerAvailable and GunHandler then
    local originalGetAim = GunHandler.getAim
    
    local function getResolvedPosition(target, origin)
        if not Settings.AirshotResolver then
            return target.Position
        end
        local root = target
        local currentPos = root.Position
        local velocity = root.Velocity
        if velocity.Magnitude > 200 then
            local hum = target.Parent:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 then
                velocity = hum.MoveDirection * hum.WalkSpeed
            else
                velocity = Vector3.new(0, 0, 0)
            end
        end
        return currentPos + (velocity * Settings.PredictionValue)
    end
    
    GunHandler.getAim = function(origin)
        updateCache()
        if AimCache.Target and AimCache.TargetPos and isTargetValid(AimCache.Target) then
            if AimCache.TargetPart and AimCache.TargetPart.Parent then
                if Settings.Prediction then
                    AimCache.TargetPos = getResolvedPosition(AimCache.TargetPart, origin)
                else
                    AimCache.TargetPos = AimCache.TargetPart.Position
                end
            end
            local dir = (AimCache.TargetPos - origin).Unit
            local dist = (AimCache.TargetPos - origin).Magnitude
            if Settings.SilentAimMode == "Legit" and Settings.LegitSmoothness and Settings.LegitSmoothness > 0 then
                local original = originalGetAim(origin)
                local targetDir = (AimCache.TargetPos - origin).Unit
                local lerped = original:Lerp(targetDir, Settings.LegitSmoothness * 0.5)
                return lerped, dist
            end
            return dir, dist
        end
        return originalGetAim(origin)
    end
    
    local originalShoot = GunHandler.shoot
    GunHandler.shoot = function(args)
        if Settings.BulletTP and AimCache.TargetPos then
            args.AimPosition = AimCache.TargetPos
        end
        local result, newArgs, hitPos = originalShoot(args)
        
        -- Glow Tracers
        if Settings.GlowTracers and result and result.Position then
            local origin = args.ForcedOrigin or args.Handle and args.Handle.Position or Camera.CFrame.Position
            local endPos = result.Position
            local distance = (endPos - origin).Magnitude
            if distance > 5 then
                local beam = Instance.new("Part")
                local thickness = Settings.TracerThickness or 0.5
                beam.Size = Vector3.new(thickness, thickness, distance)
                beam.CFrame = CFrame.lookAt(origin, endPos) * CFrame.new(0, 0, -distance/2)
                beam.Material = Enum.Material.Neon
                beam.Color = Settings.TracerGlowColor
                beam.Anchored = true
                beam.CanCollide = false
                beam.Transparency = 0.15
                beam.Parent = workspace
                
                local trail = Instance.new("Trail")
                local att0 = Instance.new("Attachment", beam)
                local att1 = Instance.new("Attachment", beam)
                att0.Position = Vector3.new(0, 0, -distance/2)
                att1.Position = Vector3.new(0, 0, distance/2)
                trail.Attachment0 = att0
                trail.Attachment1 = att1
                trail.Color = ColorSequence.new(Settings.TracerGlowColor)
                trail.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.1),
                    NumberSequenceKeypoint.new(0.5, 0.3),
                    NumberSequenceKeypoint.new(1, 0.9)
                })
                trail.Lifetime = Settings.TracerLifeTime
                trail.Parent = beam
                
                local particles = Instance.new("ParticleEmitter")
                particles.Texture = "rbxassetid://2784981116"
                particles.Rate = 200
                particles.Lifetime = NumberRange.new(0.05, 0.2)
                particles.SpreadAngle = Vector2.new(360, 360)
                particles.VelocityInheritance = 0
                particles.Speed = NumberRange.new(3, 10)
                particles.Color = ColorSequence.new(Settings.TracerGlowColor)
                particles.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.2),
                    NumberSequenceKeypoint.new(1, 1)
                })
                particles.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.3),
                    NumberSequenceKeypoint.new(1, 0)
                })
                particles.Parent = beam
                
                game:GetService("Debris"):AddItem(beam, Settings.TracerLifeTime + 0.3)
            end
        end
        
        task.spawn(cancelSlowdown)
        return result, newArgs, hitPos
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 19. VELOCITY DESYNC
-- ═══════════════════════════════════════════════════════════════════════════

local velocityDesyncConnection = nil
local desyncVelocity = Vector3.new(9999, 9999, 9999)

local function toggleVelocityDesync(enabled)
    if velocityDesyncConnection then velocityDesyncConnection:Disconnect() end
    if enabled then
        velocityDesyncConnection = RunService.Heartbeat:Connect(function()
            if not Settings.VelocityDesync then return end
            if not Character then return end
            local root = Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local realVel = root.Velocity
            root.Velocity = desyncVelocity
            RunService.RenderStepped:Wait()
            root.Velocity = realVel
        end)
    end
end
toggleVelocityDesync(Settings.VelocityDesync)

-- ═══════════════════════════════════════════════════════════════════════════
-- 20. NETWORK FAKE LAG
-- ═══════════════════════════════════════════════════════════════════════════

local networkFakeLagConnection = nil
local frameCounter = 0

local function toggleNetworkFakeLag(enabled)
    if networkFakeLagConnection then networkFakeLagConnection:Disconnect() end
    if enabled then
        networkFakeLagConnection = RunService.Heartbeat:Connect(function()
            if not Settings.NetworkFakeLag then return end
            if Character then
                local root = Character:FindFirstChild("HumanoidRootPart")
                if root then
                    frameCounter = frameCounter + 1
                    if frameCounter <= Settings.NetworkFakeLagFactor then
                        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    else
                        frameCounter = 0
                    end
                end
            end
        end)
    end
end
toggleNetworkFakeLag(Settings.NetworkFakeLag)

-- ═══════════════════════════════════════════════════════════════════════════
-- 21. ANTI-STOMP (Defov)
-- ═══════════════════════════════════════════════════════════════════════════

local antiStompConnection = nil

local function toggleAntiStomp(enabled)
    if antiStompConnection then antiStompConnection:Disconnect() end
    if enabled then
        antiStompConnection = RunService.Heartbeat:Connect(function()
            if not Settings.AntiStomp then return end
            if not Character then return end
            local hum = Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 15 then
                for _, part in ipairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.new(0, -500, 0)
                    end
                end
            end
        end)
    end
end
toggleAntiStomp(Settings.AntiStomp)

-- ═══════════════════════════════════════════════════════════════════════════
-- 22. WALKABLE DESYNC (Replaces Anti-Aim)
-- ═══════════════════════════════════════════════════════════════════════════

local walkableDesyncConnection = nil

local function toggleWalkableDesync(enabled)
    if walkableDesyncConnection then walkableDesyncConnection:Disconnect() end
    if enabled then
        walkableDesyncConnection = RunService.Heartbeat:Connect(function()
            if not Settings.WalkableDesync then return end
            if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = Character.HumanoidRootPart
            local current = hrp.CFrame
            local angle = math.rad(Settings.DesyncAmount)
            hrp.CFrame = CFrame.new(current.Position) * CFrame.Angles(0, angle, 0)
        end)
    end
end
toggleWalkableDesync(Settings.WalkableDesync)

-- ═══════════════════════════════════════════════════════════════════════════
-- 23. SPINBOT
-- ═══════════════════════════════════════════════════════════════════════════

local spinBotConnection = nil

local function toggleSpinBot(enabled)
    if spinBotConnection then spinBotConnection:Disconnect() end
    if enabled then
        spinBotConnection = RunService.Heartbeat:Connect(function()
            if not Settings.SpinBot then return end
            if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = Character.HumanoidRootPart
            local current = hrp.CFrame
            local angle = tick() * math.rad(Settings.SpinBotSpeed * 10)
            hrp.CFrame = CFrame.new(current.Position) * CFrame.Angles(0, angle, 0)
        end)
    end
end
toggleSpinBot(Settings.SpinBot)

-- ═══════════════════════════════════════════════════════════════════════════
-- 24. DESYNC VISUAL (Fake Character)
-- ═══════════════════════════════════════════════════════════════════════════

local fakeCharacter = nil
local fakeConnection = nil

local function updateDesyncVisual()
    if Settings.DesyncVisual and Character then
        if not fakeCharacter or not fakeCharacter.Parent then
            fakeCharacter = Character:Clone()
            fakeCharacter.Name = "DesyncFake"
            for _, child in ipairs(fakeCharacter:GetChildren()) do
                if child:IsA("BasePart") then
                    child.Transparency = 0.7
                    child.Material = Enum.Material.Neon
                    child.Color = Color3.fromRGB(0, 200, 255)
                end
            end
            fakeCharacter.Parent = workspace
            if fakeCharacter:FindFirstChild("Humanoid") then
                fakeCharacter.Humanoid:Destroy()
            end
        end
        if fakeConnection then fakeConnection:Disconnect() end
        fakeConnection = RunService.Heartbeat:Connect(function()
            if not Settings.DesyncVisual or not Character then
                if fakeCharacter then fakeCharacter:Destroy() end
                fakeCharacter = nil
                fakeConnection:Disconnect()
                return
            end
            local hrp = Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local fakeHrp = fakeCharacter:FindFirstChild("HumanoidRootPart")
            if not fakeHrp then return end
            fakeHrp.CFrame = hrp.CFrame * CFrame.new(1.5, 0, 0)
        end)
    else
        if fakeCharacter then fakeCharacter:Destroy() end
        fakeCharacter = nil
        if fakeConnection then fakeConnection:Disconnect() end
        fakeConnection = nil
    end
end
updateDesyncVisual()

-- ═══════════════════════════════════════════════════════════════════════════
-- 25. ORBITING TARGET EFFECT
-- ═══════════════════════════════════════════════════════════════════════════

local function createOrbitingEffect()
    if not Settings.OrbitingTargets then return end
    if not AimCache.Target or not isTargetValid(AimCache.Target) then return end
    
    -- Clear old orbs
    for _, obj in pairs(orbitingObjects) do
        if obj then obj:Destroy() end
    end
    orbitingObjects = {}
    if orbitConnection then orbitConnection:Disconnect() end
    
    -- Create 10 orbs
    for i = 1, 10 do
        local orb = Instance.new("Part")
        orb.Size = Vector3.new(0.5, 0.5, 0.5)
        orb.Shape = Enum.PartType.Ball
        orb.Material = Enum.Material.Neon
        orb.Color = Color3.fromRGB(255, 100, 100)
        orb.Anchored = true
        orb.CanCollide = false
        orb.Transparency = 0.3
        orb.Parent = workspace
        orbitingObjects[i] = orb
    end
    
    orbitConnection = RunService.Heartbeat:Connect(function()
        if not Settings.OrbitingTargets or not AimCache.Target or not isTargetValid(AimCache.Target) then
            for _, obj in pairs(orbitingObjects) do
                if obj then obj:Destroy() end
            end
            orbitingObjects = {}
            orbitConnection:Disconnect()
            return
        end
        local targetPos = AimCache.TargetPos or AimCache.TargetPart and AimCache.TargetPart.Position
        if not targetPos then return end
        local time = tick()
        for i, orb in ipairs(orbitingObjects) do
            if not orb then continue end
            local angle = (i / 10) * 2 * math.pi + time * 0.5
            local radius = 3
            local x = math.cos(angle) * radius
            local z = math.sin(angle) * radius
            local y = math.sin(angle * 1.5) * 1.5
            orb.CFrame = CFrame.new(targetPos + Vector3.new(x, y, z))
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 26. FLY / NOCLIP / SPEED
-- ═══════════════════════════════════════════════════════════════════════════

local flyVelocity = nil
local flyConnection = nil

local function toggleFly(enabled)
    if flyConnection then flyConnection:Disconnect() end
    if flyVelocity then flyVelocity:Destroy() end
    flyVelocity = nil
    if enabled and Character then
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        local hum = Character:FindFirstChild("Humanoid")
        if hrp and hum then
            hum.PlatformStand = true
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyVelocity.Parent = hrp
            flyConnection = RunService.Heartbeat:Connect(function()
                if not Settings.Fly or not Character or not Character.Parent then return end
                local hrp = Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local cam = workspace.CurrentCamera
                local forward = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                local up = cam.CFrame.UpVector
                local move = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + forward end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - forward end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - right end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + right end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + up end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - up end
                local speed = 50
                if move.Magnitude > 0 then move = move.Unit * speed end
                flyVelocity.Velocity = move
            end)
        end
    else
        if Character then
            local hum = Character:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end
toggleFly(Settings.Fly)

local noclipConnection = nil
local function toggleNoclip(enabled)
    if noclipConnection then noclipConnection:Disconnect() end
    if enabled then
        noclipConnection = RunService.Heartbeat:Connect(function()
            if not Settings.Noclip then return end
            if not Character or not Character.Parent then return end
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end
toggleNoclip(Settings.Noclip)

local function applySpeed()
    if Character and Humanoid then
        Humanoid.WalkSpeed = Settings.Speed
    end
end
applySpeed()

-- ═══════════════════════════════════════════════════════════════════════════
-- 27. BUNNY HOP / AUTO STRAFING / AUTO CROUCH
-- ═══════════════════════════════════════════════════════════════════════════

local connections = {}

local function startConnection(name, func, enabled)
    if connections[name] then connections[name]:Disconnect() end
    if enabled then
        connections[name] = RunService.Heartbeat:Connect(func)
    end
end

startConnection("BunnyHop", function()
    if Settings.BunnyHop and Humanoid and Humanoid:GetState() == Enum.HumanoidStateType.Jumping then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end, Settings.BunnyHop)

startConnection("AutoStrafing", function()
    if Settings.AutoStrafing and Character and Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Character.HumanoidRootPart
        local vel = hrp.AssemblyLinearVelocity
        if vel.Magnitude > 10 then
            local right = hrp.CFrame.RightVector
            local dot = right:Dot(vel)
            if dot > 0 then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(2), 0)
            else
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(-2), 0)
            end
        end
    end
end, Settings.AutoStrafing)

startConnection("AutoCrouch", function()
    if Settings.AutoCrouch and Humanoid then
        Humanoid.Crouch = true
    end
end, Settings.AutoCrouch)

-- ═══════════════════════════════════════════════════════════════════════════
-- 28. ESP
-- ═══════════════════════════════════════════════════════════════════════════

local ESPObjects = {}

local function createESP()
    for _, obj in pairs(ESPObjects) do
        if obj.Box then obj.Box:Remove() end
        if obj.Name then obj.Name:Remove() end
        if obj.Health then obj.Health:Remove() end
        if obj.Distance then obj.Distance:Remove() end
        if obj.Snapline then obj.Snapline:Remove() end
        if obj.Tracer then obj.Tracer:Remove() end
        if obj.HeadDot then obj.HeadDot:Remove() end
        if obj.Skeleton then
            for _, line in pairs(obj.Skeleton) do
                if line then line:Remove() end
            end
        end
        if obj.Weapon then obj.Weapon:Remove() end
    end
    ESPObjects = {}
    if not Settings.ESPEnabled then return end
    
    for _, char in ipairs(getCharacters()) do
        local player = Players:GetPlayerFromCharacter(char)
        if player then
            local hum = char:FindFirstChild("Humanoid")
            if not hum then continue end
            
            local isVisible = false
            local targetPart = getTargetPart(char)
            if targetPart then
                local origin = Camera.CFrame.Position
                local dir = (targetPart.Position - origin).Unit * 1000
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {Character, Camera}
                params.FilterType = Enum.RaycastFilterType.Blacklist
                local result = workspace:Raycast(origin, dir, params)
                if result and result.Instance and result.Instance:IsDescendantOf(char) then
                    isVisible = true
                end
            end
            if not Settings.VisibleCheck then isVisible = true end
            
            local isEnemy = (not Settings.TeamCheck) or (player.Team ~= LocalPlayer.Team)
            local color = isEnemy and Settings.ESPEnemyColor or Settings.ESPTeamColor
            if isVisible then color = Settings.ESPVisibleColor end
            
            local esp = {}
            
            if Settings.ESPBoxes then
                local box = Drawing.new("Square")
                box.Thickness = 2
                box.Filled = false
                box.Color = color
                box.Transparency = 0.5
                esp.Box = box
            end
            
            if Settings.ESPNames then
                local nameText = Drawing.new("Text")
                nameText.Text = player.Name
                nameText.Size = 14
                nameText.Center = true
                nameText.Color = color
                nameText.Transparency = 0.8
                nameText.Outline = true
                nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
                esp.Name = nameText
            end
            
            if Settings.ESPHealth then
                local healthText = Drawing.new("Text")
                healthText.Text = math.floor(hum.Health) .. " HP"
                healthText.Size = 12
                healthText.Center = true
                healthText.Color = Color3.fromRGB(255, 255, 255)
                healthText.Transparency = 0.8
                healthText.Outline = true
                healthText.OutlineColor = Color3.fromRGB(0, 0, 0)
                esp.Health = healthText
            end
            
            if Settings.ESPDistance then
                local distText = Drawing.new("Text")
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                if root then
                    local dist = (root.Position - Camera.CFrame.Position).Magnitude
                    distText.Text = math.floor(dist) .. "m"
                    distText.Size = 11
                    distText.Center = true
                    distText.Color = Color3.fromRGB(255, 255, 255)
                    distText.Transparency = 0.6
                    distText.Outline = true
                    distText.OutlineColor = Color3.fromRGB(0, 0, 0)
                    esp.Distance = distText
                end
            end
            
            if Settings.ESPSnaplines then
                local line = Drawing.new("Line")
                line.Thickness = 1
                line.Color = color
                line.Transparency = 0.5
                esp.Snapline = line
            end
            
            if Settings.ESPTracers then
                local tracer = Drawing.new("Line")
                tracer.Thickness = 1
                tracer.Color = Settings.TracerColor
                tracer.Transparency = 0.7
                esp.Tracer = tracer
            end
            
            if Settings.ESPHeadDot then
                local headDot = Drawing.new("Circle")
                headDot.Radius = 3
                headDot.Filled = true
                headDot.Color = color
                headDot.Transparency = 0.8
                esp.HeadDot = headDot
            end
            
            if Settings.ESPSkeleton then
                esp.Skeleton = {}
                local joints = {
                    {"Head", "UpperTorso"},
                    {"UpperTorso", "HumanoidRootPart"},
                    {"LeftUpperArm", "LeftLowerArm"},
                    {"RightUpperArm", "RightLowerArm"},
                    {"LeftUpperLeg", "LeftLowerLeg"},
                    {"RightUpperLeg", "RightLowerLeg"}
                }
                for _, joint in ipairs(joints) do
                    local p1 = char:FindFirstChild(joint[1])
                    local p2 = char:FindFirstChild(joint[2])
                    if p1 and p2 then
                        local line = Drawing.new("Line")
                        line.Thickness = 1
                        line.Color = color
                        line.Transparency = 0.5
                        table.insert(esp.Skeleton, line)
                    end
                end
            end
            
            if Settings.ESPWeapon then
                local weaponText = Drawing.new("Text")
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    weaponText.Text = tool.Name
                    weaponText.Size = 11
                    weaponText.Center = true
                    weaponText.Color = Color3.fromRGB(255, 255, 255)
                    weaponText.Transparency = 0.7
                    weaponText.Outline = true
                    weaponText.OutlineColor = Color3.fromRGB(0, 0, 0)
                    esp.Weapon = weaponText
                end
            end
            
            ESPObjects[char] = esp
        end
    end
end

local function updateESP()
    for char, esp in pairs(ESPObjects) do
        if not char or not char.Parent then
            for _, obj in pairs(esp) do if obj and obj.Remove then obj:Remove() end end
            ESPObjects[char] = nil
            continue
        end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then
            for _, obj in pairs(esp) do if obj and obj.Remove then obj:Remove() end end
            ESPObjects[char] = nil
            continue
        end
        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
        if not root then continue end
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            if esp.Box then esp.Box.Visible = false end
            if esp.Name then esp.Name.Visible = false end
            if esp.Health then esp.Health.Visible = false end
            if esp.Distance then esp.Distance.Visible = false end
            if esp.Snapline then esp.Snapline.Visible = false end
            if esp.Tracer then esp.Tracer.Visible = false end
            if esp.HeadDot then esp.HeadDot.Visible = false end
            if esp.Skeleton then for _, line in pairs(esp.Skeleton) do if line then line.Visible = false end end end
            if esp.Weapon then esp.Weapon.Visible = false end
            continue
        end
        local size = 40
        local screenY = pos.Y
        local screenX = pos.X
        local isVisible = false
        if Settings.VisibleCheck then
            local origin = Camera.CFrame.Position
            local targetPart = char:FindFirstChild("Head") or root
            if targetPart then
                local dir = (targetPart.Position - origin).Unit * 1000
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {Character, Camera}
                params.FilterType = Enum.RaycastFilterType.Blacklist
                local result = workspace:Raycast(origin, dir, params)
                if result and result.Instance and result.Instance:IsDescendantOf(char) then
                    isVisible = true
                end
            end
        else
            isVisible = true
        end
        local player = Players:GetPlayerFromCharacter(char)
        local isEnemy = (not Settings.TeamCheck) or (player and player.Team ~= LocalPlayer.Team)
        local color = isEnemy and Settings.ESPEnemyColor or Settings.ESPTeamColor
        if isVisible then color = Settings.ESPVisibleColor end
        
        if esp.Box then
            esp.Box.Visible = true
            esp.Box.Size = Vector2.new(size, size)
            esp.Box.Position = Vector2.new(screenX - size/2, screenY - size/2)
            esp.Box.Color = color
        end
        if esp.Name then
            esp.Name.Visible = true
            esp.Name.Position = Vector2.new(screenX, screenY - size/2 - 20)
            esp.Name.Color = color
        end
        if esp.Health then
            esp.Health.Visible = true
            esp.Health.Position = Vector2.new(screenX, screenY + 10)
            esp.Health.Text = math.floor(hum.Health) .. " HP"
            local healthPercent = hum.Health / hum.MaxHealth
            esp.Health.Color = Color3.fromRGB(255 - 255 * healthPercent, 255 * healthPercent, 0)
        end
        if esp.Distance then
            esp.Distance.Visible = true
            esp.Distance.Position = Vector2.new(screenX, screenY + size/2 + 20)
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            esp.Distance.Text = math.floor(dist) .. "m"
        end
        if esp.Snapline then
            esp.Snapline.Visible = true
            esp.Snapline.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            esp.Snapline.To = Vector2.new(screenX, screenY)
            esp.Snapline.Color = color
        end
        if esp.Tracer then
            esp.Tracer.Visible = true
            esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(screenX, screenY)
            esp.Tracer.Color = Settings.TracerColor
        end
        if esp.HeadDot then
            esp.HeadDot.Visible = true
            local headPart = char:FindFirstChild("Head")
            if headPart then
                local headPos, _ = Camera:WorldToViewportPoint(headPart.Position)
                esp.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                esp.HeadDot.Color = color
            end
        end
        if esp.Skeleton then
            for i, joint in ipairs({
                {"Head", "UpperTorso"},
                {"UpperTorso", "HumanoidRootPart"},
                {"LeftUpperArm", "LeftLowerArm"},
                {"RightUpperArm", "RightLowerArm"},
                {"LeftUpperLeg", "LeftLowerLeg"},
                {"RightUpperLeg", "RightLowerLeg"}
            }) do
                local p1 = char:FindFirstChild(joint[1])
                local p2 = char:FindFirstChild(joint[2])
                if p1 and p2 and esp.Skeleton[i] then
                    local p1Pos, _ = Camera:WorldToViewportPoint(p1.Position)
                    local p2Pos, _ = Camera:WorldToViewportPoint(p2.Position)
                    esp.Skeleton[i].Visible = true
                    esp.Skeleton[i].From = Vector2.new(p1Pos.X, p1Pos.Y)
                    esp.Skeleton[i].To = Vector2.new(p2Pos.X, p2Pos.Y)
                    esp.Skeleton[i].Color = color
                elseif esp.Skeleton[i] then
                    esp.Skeleton[i].Visible = false
                end
            end
        end
        if esp.Weapon then
            esp.Weapon.Visible = true
            esp.Weapon.Position = Vector2.new(screenX, screenY + size/2 + 35)
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                esp.Weapon.Text = tool.Name
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 29. CHAMS
-- ═══════════════════════════════════════════════════════════════════════════

local chamsObjects = {}

local function applyChams()
    for _, obj in pairs(chamsObjects) do if obj:IsA("Highlight") then obj:Destroy() end end
    chamsObjects = {}
    if not Settings.ChamsEnabled then return end
    if Settings.ChamsPlayer then
        for _, char in ipairs(getCharacters()) do
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Settings.ChamsColor
                highlight.FillTransparency = Settings.ChamsTransparency
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0.3
                highlight.Parent = char
                table.insert(chamsObjects, highlight)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 30. WORLD MODS
-- ═══════════════════════════════════════════════════════════════════════════

local function applyWorldMods()
    Lighting.Brightness = Settings.WorldBrightness
    Lighting.Ambient = Settings.WorldAmbient
    Lighting.ColorShift_Top = Settings.WorldSkyColor
    Lighting.ColorShift_Bottom = Settings.WorldBottomColor
    if Settings.WorldFogEnabled then
        Lighting.FogColor = Settings.WorldFogColor
        Lighting.FogEnd = Settings.WorldFogEnd
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = 100000
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 31. RESPAWN HANDLER (FIXED: Added createOrbitingEffect)
-- ═══════════════════════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    clearCache()
    task.wait(0.5)
    if Settings.NoSlowDown then
        Humanoid.WalkSpeed = originalWalkSpeed
    end
    toggleFly(Settings.Fly)
    toggleNoclip(Settings.Noclip)
    applySpeed()
    if Settings.KillAura then
        task.wait(0.3)
        createKillAuraBubble()
    end
    toggleVelocityDesync(Settings.VelocityDesync)
    toggleNetworkFakeLag(Settings.NetworkFakeLag)
    toggleAntiStomp(Settings.AntiStomp)
    toggleWalkableDesync(Settings.WalkableDesync)
    toggleSpinBot(Settings.SpinBot)
    updateDesyncVisual()
    task.wait(0.2)
    createESP()
    applyChams()
    applyHitboxExpander()
    hookWeaponSlowdown()
    createOrbitingEffect()  -- ⬅️ ADDED
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 32. INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

task.wait(1)
createESP()
applyChams()
applyWorldMods()
applyHitboxExpander()
if Settings.KillAura then
    task.wait(0.5)
    createKillAuraBubble()
end
hookWeaponSlowdown()
updateDesyncVisual()
createOrbitingEffect()

-- ═══════════════════════════════════════════════════════════════════════════
-- 33. UPDATE LOOPS
-- ═══════════════════════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
    if Settings.ESPEnabled then updateESP() end
    if Settings.ChamsEnabled then applyChams() end
    if Settings.TargetIndicator then updateTargetIndicator() end
    if Settings.HitboxExpander then 
        applyHitboxExpander()
        if Settings.HitboxVisual then updateHitboxVisual() end
    end
    if Settings.OrbitingTargets and AimCache.Target and isTargetValid(AimCache.Target) then
        if #orbitingObjects == 0 then
            createOrbitingEffect()
        end
    else
        if #orbitingObjects > 0 then
            for _, obj in pairs(orbitingObjects) do
                if obj then obj:Destroy() end
            end
            orbitingObjects = {}
            if orbitConnection then orbitConnection:Disconnect() end
            orbitConnection = nil
        end
    end
end)

Players.PlayerAdded:Connect(function() 
    task.wait(1) 
    createESP() 
    applyChams()
    applyHitboxExpander()
end)

Players.PlayerRemoving:Connect(function() 
    createESP() 
    applyChams() 
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- 34. STARLIGHT UI (Every Feature Toggleable with Dropdowns/Sliders)
-- ═══════════════════════════════════════════════════════════════════════════

-- Wrap UI creation in pcall to prevent crashes from beta Starlight
pcall(function()
    local MainWindow = Starlight:CreateWindow({
        Title = "tapped.cc",
        Subtitle = "Da Hood HvH",
        Keybind = Enum.KeyCode.K,
    })

    -- ── Ragebot Tab ──
    local RageTab = MainWindow:CreateTab({ Name = "Ragebot", Icon = NebulaIcons.Target })

    local SilentAimSection = RageTab:CreateSection({ Name = "Silent Aim" })
    SilentAimSection:CreateToggle({ 
        Name = "Enable Silent Aim", 
        Default = true, 
        Callback = function(v) Settings.SilentAim = v; if not v then clearCache() end end 
    })
    SilentAimSection:CreateDropdown({ 
        Name = "Aim Mode", 
        Options = {"Rage", "Legit"}, 
        Default = "Rage", 
        Callback = function(v) Settings.SilentAimMode = v; clearCache() end 
    })
    SilentAimSection:CreateSlider({ 
        Name = "FOV Radius", 
        Min = 50, 
        Max = 9999, 
        Default = 9999, 
        Suffix = "px", 
        Callback = function(v) Settings.FOVRadius = v; clearCache() end 
    })
    SilentAimSection:CreateDropdown({ 
        Name = "Aim Part", 
        Options = {"Head", "Torso", "HumanoidRootPart", "UpperTorso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, 
        Default = "Head", 
        Callback = function(v) Settings.AimPart = v; clearCache() end 
    })
    SilentAimSection:CreateToggle({ 
        Name = "Team Check", 
        Default = false, 
        Callback = function(v) Settings.TeamCheck = v; clearCache() end 
    })
    SilentAimSection:CreateToggle({ 
        Name = "Visibility Check", 
        Default = false, 
        Callback = function(v) Settings.VisibleCheck = v; clearCache() end 
    })
    SilentAimSection:CreateToggle({ 
        Name = "Right Click Only", 
        Default = false, 
        Callback = function(v) Settings.OnRightClickOnly = v; clearCache() end 
    })

    local RageFeatures = RageTab:CreateSection({ Name = "Rage Features" })
    RageFeatures:CreateToggle({ 
        Name = "No Recoil", 
        Default = true, 
        Callback = function(v) Settings.NoRecoil = v end 
    })
    RageFeatures:CreateToggle({ 
        Name = "Auto Shoot", 
        Default = true, 
        Callback = function(v) Settings.AutoShoot = v end 
    })
    RageFeatures:CreateToggle({ 
        Name = "Kill Aura", 
        Default = true, 
        Callback = function(v) 
            Settings.KillAura = v
            if v then 
                updateKillAuraBubble() 
            else 
                if killAuraBubble then killAuraBubble:Destroy() end
                if killAuraRing then killAuraRing:Destroy() end
                if bubbleSpinConnection then bubbleSpinConnection:Disconnect() end
                killAuraBubble = nil
                killAuraRing = nil
                bubbleSpinConnection = nil
            end
        end 
    })
    RageFeatures:CreateSlider({ 
        Name = "Kill Aura Range", 
        Min = 50, 
        Max = 500, 
        Default = 300, 
        Suffix = "studs", 
        Callback = function(v) 
            Settings.KillAuraRange = v
            if Settings.KillAura then updateKillAuraBubble() end
        end 
    })
    RageFeatures:CreateToggle({ 
        Name = "Triggerbot", 
        Default = true, 
        Callback = function(v) Settings.Triggerbot = v end 
    })
    RageFeatures:CreateToggle({ 
        Name = "Hitbox Expander", 
        Default = true, 
        Callback = function(v) Settings.HitboxExpander = v; applyHitboxExpander() end 
    })
    RageFeatures:CreateSlider({ 
        Name = "Hitbox Size", 
        Min = 5, 
        Max = 50, 
        Default = 25, 
        Suffix = "studs", 
        Callback = function(v) Settings.HitboxExpanderSize = v; applyHitboxExpander() end 
    })
    RageFeatures:CreateToggle({ 
        Name = "Hitbox Visual", 
        Default = true, 
        Callback = function(v) Settings.HitboxVisual = v; applyHitboxExpander() end 
    })
    RageFeatures:CreateToggle({ 
        Name = "Bullet TP", 
        Default = true, 
        Callback = function(v) Settings.BulletTP = v end 
    })
    RageFeatures:CreateToggle({ 
        Name = "Prediction", 
        Default = true, 
        Callback = function(v) Settings.Prediction = v end 
    })
    RageFeatures:CreateSlider({ 
        Name = "Prediction Value", 
        Min = 0.01, 
        Max = 0.3, 
        Default = 0.121, 
        Suffix = "s", 
        Callback = function(v) Settings.PredictionValue = v end 
    })
    RageFeatures:CreateToggle({ 
        Name = "Airshot Resolver", 
        Default = true, 
        Callback = function(v) Settings.AirshotResolver = v end 
    })

    local SmartFeatures = RageTab:CreateSection({ Name = "Smart Features" })
    SmartFeatures:CreateToggle({ 
        Name = "Auto Weapon Select", 
        Default = true, 
        Callback = function(v) Settings.AutoWeapon = v end 
    })
    SmartFeatures:CreateToggle({ 
        Name = "Auto Stomp", 
        Default = true, 
        Callback = function(v) Settings.AutoStomp = v end 
    })
    SmartFeatures:CreateToggle({ 
        Name = "Target Indicator", 
        Default = true, 
        Callback = function(v) 
            Settings.TargetIndicator = v
            if not v and frame then frame.Visible = false end
        end 
    })
    SmartFeatures:CreateToggle({ 
        Name = "Fake Macro (90+ FPS)", 
        Default = false, 
        Callback = function(v) Settings.FakeMacro = v end 
    })
    SmartFeatures:CreateKeybind({ 
        Name = "Ragebot Toggle Key", 
        Default = Enum.KeyCode.X, 
        Callback = function(key) Settings.RagebotKeybind = key end 
    })
    SmartFeatures:CreateKeybind({ 
        Name = "Stomp Key", 
        Default = Enum.KeyCode.E, 
        Callback = function(key) Settings.StompKeybind = key end 
    })

    -- ── Visuals Tab ──
    local VisTab = MainWindow:CreateTab({ Name = "Visuals", Icon = NebulaIcons.Eye })

    local ESPSection = VisTab:CreateSection({ Name = "ESP" })
    ESPSection:CreateToggle({ 
        Name = "Enable ESP", 
        Default = true, 
        Callback = function(v) 
            Settings.ESPEnabled = v
            if v then createESP() else 
                for _, obj in pairs(ESPObjects) do
                    if obj.Box then obj.Box:Remove() end
                    if obj.Name then obj.Name:Remove() end
                    if obj.Health then obj.Health:Remove() end
                    if obj.Distance then obj.Distance:Remove() end
                    if obj.Snapline then obj.Snapline:Remove() end
                    if obj.Tracer then obj.Tracer:Remove() end
                    if obj.HeadDot then obj.HeadDot:Remove() end
                    if obj.Skeleton then for _, line in pairs(obj.Skeleton) do if line then line:Remove() end end end
                    if obj.Weapon then obj.Weapon:Remove() end
                end
                ESPObjects = {}
            end
        end 
    })
    ESPSection:CreateToggle({ Name = "Boxes", Default = true, Callback = function(v) Settings.ESPBoxes = v; createESP() end })
    ESPSection:CreateToggle({ Name = "Names", Default = true, Callback = function(v) Settings.ESPNames = v; createESP() end })
    ESPSection:CreateToggle({ Name = "Health", Default = true, Callback = function(v) Settings.ESPHealth = v; createESP() end })
    ESPSection:CreateToggle({ Name = "Distance", Default = true, Callback = function(v) Settings.ESPDistance = v; createESP() end })
    ESPSection:CreateToggle({ Name = "Snaplines", Default = false, Callback = function(v) Settings.ESPSnaplines = v; createESP() end })
    ESPSection:CreateToggle({ Name = "Tracers", Default = false, Callback = function(v) Settings.ESPTracers = v; createESP() end })
    ESPSection:CreateToggle({ Name = "Head Dot", Default = true, Callback = function(v) Settings.ESPHeadDot = v; createESP() end })
    ESPSection:CreateToggle({ Name = "Skeleton", Default = false, Callback = function(v) Settings.ESPSkeleton = v; createESP() end })
    ESPSection:CreateToggle({ Name = "Weapon Name", Default = false, Callback = function(v) Settings.ESPWeapon = v; createESP() end })
    ESPSection:CreateColorPicker({ Name = "Enemy Color", Default = Color3.fromRGB(255, 0, 0), Callback = function(c) Settings.ESPEnemyColor = c; createESP() end })
    ESPSection:CreateColorPicker({ Name = "Team Color", Default = Color3.fromRGB(0, 255, 0), Callback = function(c) Settings.ESPTeamColor = c; createESP() end })
    ESPSection:CreateColorPicker({ Name = "Visible Color", Default = Color3.fromRGB(255, 255, 0), Callback = function(c) Settings.ESPVisibleColor = c; createESP() end })

    local ChamsSection = VisTab:CreateSection({ Name = "Chams" })
    ChamsSection:CreateToggle({ Name = "Enable Chams", Default = true, Callback = function(v) Settings.ChamsEnabled = v; applyChams() end })
    ChamsSection:CreateToggle({ Name = "Player Chams", Default = true, Callback = function(v) Settings.ChamsPlayer = v; applyChams() end })
    ChamsSection:CreateColorPicker({ Name = "Chams Color", Default = Color3.fromRGB(0, 255, 255), Callback = function(c) Settings.ChamsColor = c; applyChams() end })
    ChamsSection:CreateSlider({ Name = "Chams Transparency", Min = 0, Max = 1, Default = 0.4, Increment = 0.05, Callback = function(v) Settings.ChamsTransparency = v; applyChams() end })

    local TracerSection = VisTab:CreateSection({ Name = "Glow Tracers" })
    TracerSection:CreateToggle({ Name = "Enable Glow Tracers", Default = true, Callback = function(v) Settings.GlowTracers = v end })
    TracerSection:CreateColorPicker({ Name = "Tracer Glow Color", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) Settings.TracerGlowColor = c end })
    TracerSection:CreateSlider({ Name = "Tracer Lifetime", Min = 0.1, Max = 1.5, Default = 0.6, Suffix = "s", Callback = function(v) Settings.TracerLifeTime = v end })
    TracerSection:CreateSlider({ Name = "Tracer Thickness", Min = 0.1, Max = 1.5, Default = 0.5, Callback = function(v) Settings.TracerThickness = v end })

    local WorldSection = VisTab:CreateSection({ Name = "World Mods" })
    WorldSection:CreateSlider({ Name = "Brightness", Min = 0, Max = 5, Default = 1.5, Callback = function(v) Settings.WorldBrightness = v; applyWorldMods() end })
    WorldSection:CreateColorPicker({ Name = "Ambient Color", Default = Color3.fromRGB(200, 200, 200), Callback = function(c) Settings.WorldAmbient = c; applyWorldMods() end })
    WorldSection:CreateColorPicker({ Name = "Sky Color", Default = Color3.fromRGB(0, 0, 0), Callback = function(c) Settings.WorldSkyColor = c; applyWorldMods() end })
    WorldSection:CreateColorPicker({ Name = "Bottom Color", Default = Color3.fromRGB(0, 0, 0), Callback = function(c) Settings.WorldBottomColor = c; applyWorldMods() end })
    WorldSection:CreateToggle({ Name = "Fog", Default = false, Callback = function(v) Settings.WorldFogEnabled = v; applyWorldMods() end })
    WorldSection:CreateColorPicker({ Name = "Fog Color", Default = Color3.fromRGB(0, 0, 0), Callback = function(c) Settings.WorldFogColor = c; applyWorldMods() end })
    WorldSection:CreateSlider({ Name = "Fog End", Min = 100, Max = 5000, Default = 1000, Suffix = "studs", Callback = function(v) Settings.WorldFogEnd = v; applyWorldMods() end })

    local FOVSection = VisTab:CreateSection({ Name = "FOV" })
    FOVSection:CreateToggle({ Name = "FOV Circle", Default = true, Callback = function(v) Settings.FOVCircleVisible = v end })
    FOVSection:CreateColorPicker({ Name = "FOV Color", Default = Color3.fromRGB(255, 0, 0), Callback = function(c) Settings.FOVCircleColor = c end })

    -- ── HvH Tab ──
    local HvHTab = MainWindow:CreateTab({ Name = "HvH", Icon = NebulaIcons.Shield })

    local HvHSection = HvHTab:CreateSection({ Name = "HvH Features" })
    HvHSection:CreateToggle({ 
        Name = "Walkable Desync (Replaces Anti-Aim)", 
        Default = false, 
        Callback = function(v) Settings.WalkableDesync = v; toggleWalkableDesync(v) end 
    })
    HvHSection:CreateSlider({ 
        Name = "Desync Amount", 
        Min = 30, 
        Max = 180, 
        Default = 120, 
        Suffix = "°", 
        Callback = function(v) Settings.DesyncAmount = v end 
    })
    HvHSection:CreateToggle({ 
        Name = "Velocity Desync", 
        Default = false, 
        Callback = function(v) Settings.VelocityDesync = v; toggleVelocityDesync(v) end 
    })
    HvHSection:CreateToggle({ 
        Name = "Network Fake Lag", 
        Default = false, 
        Callback = function(v) Settings.NetworkFakeLag = v; toggleNetworkFakeLag(v) end 
    })
    HvHSection:CreateSlider({ 
        Name = "Fake Lag Factor", 
        Min = 1, 
        Max = 20, 
        Default = 15, 
        Callback = function(v) Settings.NetworkFakeLagFactor = v end 
    })
    HvHSection:CreateToggle({ 
        Name = "Anti-Stomp (Defov)", 
        Default = true, 
        Callback = function(v) Settings.AntiStomp = v; toggleAntiStomp(v) end 
    })
    HvHSection:CreateToggle({ 
        Name = "Desync Visual (Fake Character)", 
        Default = false, 
        Callback = function(v) Settings.DesyncVisual = v; updateDesyncVisual() end 
    })
    HvHSection:CreateToggle({ 
        Name = "Orbiting Target Effect", 
        Default = true, 
        Callback = function(v) 
            Settings.OrbitingTargets = v
            if not v then
                for _, obj in pairs(orbitingObjects) do if obj then obj:Destroy() end end
                orbitingObjects = {}
                if orbitConnection then orbitConnection:Disconnect() end
                orbitConnection = nil
            else
                createOrbitingEffect()
            end
        end 
    })

    local SpinSection = HvHTab:CreateSection({ Name = "Spin Bot" })
    SpinSection:CreateToggle({ Name = "Spin Bot", Default = false, Callback = function(v) Settings.SpinBot = v; toggleSpinBot(v) end })
    SpinSection:CreateSlider({ Name = "Spin Speed", Min = 1, Max = 20, Default = 5, Callback = function(v) Settings.SpinBotSpeed = v end })

    -- ── Misc Tab ──
    local MiscTab = MainWindow:CreateTab({ Name = "Misc", Icon = NebulaIcons.Settings })

    local MovementSection = MiscTab:CreateSection({ Name = "Movement" })
    MovementSection:CreateToggle({ Name = "Bunny Hop", Default = false, Callback = function(v) Settings.BunnyHop = v end })
    MovementSection:CreateToggle({ Name = "Auto Strafing", Default = false, Callback = function(v) Settings.AutoStrafing = v end })
    MovementSection:CreateToggle({ Name = "Auto Crouch", Default = false, Callback = function(v) Settings.AutoCrouch = v end })

    local FlightSection = MiscTab:CreateSection({ Name = "Flight & Noclip" })
    FlightSection:CreateToggle({ Name = "Fly", Default = false, Callback = function(v) Settings.Fly = v; toggleFly(v) end })
    FlightSection:CreateToggle({ Name = "Noclip", Default = false, Callback = function(v) Settings.Noclip = v; toggleNoclip(v) end })
    FlightSection:CreateSlider({ Name = "Speed", Min = 1, Max = 100, Default = 16, Suffix = "studs/s", Callback = function(v) Settings.Speed = v; applySpeed() end })

    local PerfSection = MiscTab:CreateSection({ Name = "Performance" })
    PerfSection:CreateToggle({ 
        Name = "No Slowdown (Force Forward)", 
        Default = true, 
        Callback = function(v) 
            Settings.NoSlowDown = v
            if v then fixSlowdown() end
        end 
    })
end) -- pcall end

print("═" .. string.rep("═", 70))
print("tapped.cc v2.0.1 loaded successfully!")
print("Press K to open the menu")
print("═" .. string.rep("═", 70))
