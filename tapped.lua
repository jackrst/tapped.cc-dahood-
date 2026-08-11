--[[
   tapped.cc v3.3.1 – Da Hood HvH Script
   All forward references fixed; Starlight UI corrected.
--]]

-- ═══════════════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════
-- LIBRARIES
-- ═══════════════════════════════════════════════════════════════════════

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

-- ═══════════════════════════════════════════════════════════════════════
-- CHARACTER MANAGER
-- ═══════════════════════════════════════════════════════════════════════

local Character = nil
local Humanoid = nil
local originalWalkSpeed = 16

local function refreshCharacter(newChar)
    if not newChar then return end
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    originalWalkSpeed = Humanoid.WalkSpeed
end

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

refreshCharacter(getCharacter())

-- ═══════════════════════════════════════════════════════════════════════
-- GUN HANDLER
-- ═══════════════════════════════════════════════════════════════════════

local GunHandler = nil
local gunHandlerAvailable = pcall(function()
    GunHandler = require(ReplicatedStorage.Modules.GunHandler)
end)

-- ═══════════════════════════════════════════════════════════════════════
-- WEAPON DETECTION
-- ═══════════════════════════════════════════════════════════════════════

local GunNames = {
    ["[Glock]"] = true, ["[Silencer]"] = true, ["[Shotgun]"] = true,
    ["[Rifle]"] = true, ["[SMG]"] = true, ["[AR]"] = true,
    ["[RPG]"] = true, ["[Admin-RPG]"] = true, ["[GrenadeLauncher]"] = true,
    ["[P90]"] = true, ["[SilencerAR]"] = true, ["[Revolver]"] = true,
    ["[AK47]"] = true, ["[TacticalShotgun]"] = true, ["[DrumGun]"] = true,
    ["[Flamethrower]"] = true, ["[AUG]"] = true, ["[LMG]"] = true,
    ["[Double-Barrel SG]"] = true, ["[Drum-Shotgun]"] = true,
    ["[Flintlock]"] = true, ["[Deagle]"] = true
}

local function isGun(tool) return tool:IsA("Tool") and GunNames[tool.Name] == true end

local function getCurrentGunName()
    if not Character then return "None" end
    for _, tool in ipairs(Character:GetChildren()) do
        if isGun(tool) then return tool.Name end
    end
    return "None"
end

local function getCurrentWeapon()
    if not Character then return nil end
    for _, child in ipairs(Character:GetChildren()) do
        if child:IsA("Tool") and child:FindFirstChild("Handle") then
            return child
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════
-- SETTINGS
-- ═══════════════════════════════════════════════════════════════════════

local Settings = {
    -- Ragebot
    SilentAim = true,
    SilentAimMode = "Rage",
    LegitSmoothness = 0.3,
    FOVFull = true,
    FOVRadius = 200,
    AimPart = "Head",
    TeamCheck = false,
    VisibleCheck = false,
    OnRightClickOnly = false,
    AutoShoot = true,
    Prediction = true,
    PredictionValue = 0.121,
    HitboxExpander = true,
    HitboxExpanderSize = 25,
    AutoWeapon = true,
    Triggerbot = true,
    KillAura = true,
    KillAuraRange = 300,
    FOVColor = Color3.fromRGB(255,0,0),
    NoSpread = true,
    AutoReload = true,
    MuteShootSounds = false,
    ForceAimAnimation = false,
    CombatToggle = false,
    BulletTP = false,
    ShotDelay = 0,
    TargetSwitchKey = Enum.KeyCode.Tab,
    FaceTarget = true,
    TargetHUD = true,
    CrosshairFollow = true,
    Tracer = true,
    OrbitingOrbs = true,
    -- HvH
    WalkableDesync = false,
    DesyncAmount = 120,
    VelocityDesync = false,
    NetworkFakeLag = false,
    NetworkFakeLagFactor = 15,
    AirshotResolver = true,
    AntiStomp = true,
    Resolver = true,
    ResolverMode = "Velocity",
    SpinBot = false,
    SpinBotSpeed = 5,
    CFrameSpeed = false,
    CFrameSpeedAmount = 5,
    Fly = false,
    Noclip = false,
    Speed = 16,
    VoidHide = false,
    VoidHideKey = Enum.KeyCode.V,
    VoidPosition = Vector3.new(0,-1000,0),
    ToolOrbit = false,
    ToolOrbitSpeed = 2,
    -- Visuals
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
    ESPEnemyColor = Color3.fromRGB(255,60,60),
    ESPTeamColor = Color3.fromRGB(60,160,255),
    ESPVisibleColor = Color3.fromRGB(0,255,100),
    TracerColor = Color3.fromRGB(255,255,255),
    ChamsEnabled = true,
    ChamsPlayer = true,
    ChamsColor = Color3.fromRGB(0,255,255),
    ChamsTransparency = 0.4,
    SelfChams = false,
    SelfChamsColor = Color3.fromRGB(255,0,255),
    SelfChamsTransparency = 0.5,
    GlowTracers = true,
    TracerGlowColor = Color3.fromRGB(255,50,50),
    TracerLifeTime = 0.6,
    TracerThickness = 0.5,
    Crosshair = true,
    CrosshairSize = 10,
    CrosshairThickness = 2,
    CrosshairColor = Color3.fromRGB(0,255,0),
    FOVCircleVisible = true,
    FOVCircleColor = Color3.fromRGB(255,0,0),
    HitboxVisual = true,
    WorldBrightness = 1.5,
    WorldAmbient = Color3.fromRGB(200,200,200),
    WorldFogEnabled = false,
    WorldFogColor = Color3.fromRGB(0,0,0),
    WorldFogEnd = 1000,
    -- Misc
    AutoStomp = true,
    StompKeybind = Enum.KeyCode.E,
    RagebotKeybind = Enum.KeyCode.X,
    NoSlowDown = true,
    DebugConsole = true
}

-- ═══════════════════════════════════════════════════════════════════════
-- CONFIGURATION (FIXED)
-- ═══════════════════════════════════════════════════════════════════════

local CONFIG_FILE = "tapped_dahood_config.json"

local function isColor3(v)
    return type(v) == "table" and v.R ~= nil and v.G ~= nil and v.B ~= nil
end

local function isVector3(v)
    return type(v) == "table" and v.X ~= nil and v.Y ~= nil and v.Z ~= nil
end

local function serializeColor3(c) return {R=c.R,G=c.G,B=c.B} end
local function deserializeColor3(t) return Color3.new(t.R or 0, t.G or 0, t.B or 0) end

local function serializeKeycode(k) return k and tostring(k) or "None" end
local function deserializeKeycode(s)
    if s == "None" or not s then return Enum.KeyCode.None end
    for _, enum in pairs(Enum.KeyCode:GetEnumItems()) do
        if tostring(enum) == s then return enum end
    end
    return Enum.KeyCode.None
end

local function serializeVector3(v) return {X=v.X,Y=v.Y,Z=v.Z} end
local function deserializeVector3(t) return Vector3.new(t.X or 0, t.Y or 0, t.Z or 0) end

local function saveConfig()
    local data = {}
    for k, v in pairs(Settings) do
        if type(v) == "Color3" then
            data[k] = serializeColor3(v)
        elseif type(v) == "EnumItem" then
            data[k] = serializeKeycode(v)
        elseif type(v) == "Vector3" then
            data[k] = serializeVector3(v)
        else
            data[k] = v
        end
    end
    local success, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if success then
        pcall(function() writefile(CONFIG_FILE, encoded) end)
        Log("Configuration saved.")
    else
        Log("Failed to save config: " .. tostring(encoded))
    end
end

local function loadConfig()
    local content
    local success, result = pcall(function() return readfile(CONFIG_FILE) end)
    if not success then return end
    content = result
    local success, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if not success then return end
    for k, v in pairs(decoded) do
        if Settings[k] ~= nil then
            local expected = Settings[k]
            if type(expected) == "Color3" and isColor3(v) then
                Settings[k] = deserializeColor3(v)
            elseif type(expected) == "EnumItem" and type(v) == "string" then
                Settings[k] = deserializeKeycode(v)
            elseif type(expected) == "Vector3" and isVector3(v) then
                Settings[k] = deserializeVector3(v)
            elseif type(v) == type(expected) then
                Settings[k] = v
            end
        end
    end
    Log("Configuration loaded.")
end
loadConfig()

-- ═══════════════════════════════════════════════════════════════════════
-- LOGGING
-- ═══════════════════════════════════════════════════════════════════════

local DebugLogs = {}
local function Log(msg)
    if not Settings.DebugConsole then return end
    local timestamp = os.date("%H:%M:%S")
    local formatted = string.format("[%s] %s", timestamp, tostring(msg))
    table.insert(DebugLogs, formatted)
    if #DebugLogs > 30 then table.remove(DebugLogs, 1) end
    print(formatted)
end

local function LogError(func, err)
    Log(string.format("ERROR in %s: %s", func, tostring(err)))
end

-- ═══════════════════════════════════════════════════════════════════════
-- GLOBAL TOGGLES
-- ═══════════════════════════════════════════════════════════════════════

local function applyCombatToggle() _G.GUN_COMBAT_TOGGLE = Settings.CombatToggle end
local function applyMuteShootSounds() _G.MuteShootSounds = Settings.MuteShootSounds end
local function applyForceAimAnimation() _G.Aimed = Settings.ForceAimAnimation end
local function applyNoSpread() shared.SpreadMode = Settings.NoSpread and "DH" or nil end
applyCombatToggle(); applyMuteShootSounds(); applyForceAimAnimation(); applyNoSpread()

-- ═══════════════════════════════════════════════════════════════════════
-- CONNECTION MANAGER
-- ═══════════════════════════════════════════════════════════════════════

local Connections = {}
local function trackConnection(conn)
    if conn and not table.find(Connections, conn) then
        table.insert(Connections, conn)
    end
    return conn
end

local function disconnectAll()
    for _, conn in ipairs(Connections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    table.clear(Connections)
end

-- ═══════════════════════════════════════════════════════════════════════
-- PLAYER CACHE
-- ═══════════════════════════════════════════════════════════════════════

local cachedPlayers = {}
local function updatePlayerCache()
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
    cachedPlayers = chars
end

local function rebuildPlayerCache()
    updatePlayerCache()
end

-- ═══════════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════════════════════════════
-- TARGET VALIDATION
-- ═══════════════════════════════════════════════════════════════════════

local targetRaycastParams = RaycastParams.new()
targetRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
targetRaycastParams.FilterDescendantsInstances = {}

local function updateTargetRaycastFilter()
    local filter = {}
    if Character then table.insert(filter, Character) end
    table.insert(filter, Camera)
    targetRaycastParams.FilterDescendantsInstances = filter
end

local function isValidTarget(char)
    if not char or char == Character then return false end
    if not char.Parent then return false end
    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if Settings.TeamCheck then
        local player = Players:GetPlayerFromCharacter(char)
        if player and player.Team == LocalPlayer.Team then return false end
    end
    local part = getTargetPart(char)
    if not part then return false end
    if Settings.VisibleCheck then
        updateTargetRaycastFilter()
        local origin = Camera.CFrame.Position
        local direction = (part.Position - origin).Unit * 1000
        local result = workspace:Raycast(origin, direction, targetRaycastParams)
        if result and result.Instance and not result.Instance:IsDescendantOf(char) then
            return false
        end
    end
    if not Settings.FOVFull then
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then return false end
        local mousePos = UserInputService:GetMouseLocation()
        local center = Vector2.new(mousePos.X, mousePos.Y + 36)
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist > Settings.FOVRadius then return false end
    end
    return true
end

local function getValidTargets()
    local valid = {}
    for _, char in ipairs(cachedPlayers) do
        if isValidTarget(char) then
            table.insert(valid, char)
        end
    end
    return valid
end

-- ═══════════════════════════════════════════════════════════════════════
-- GET CLOSEST TARGET
-- ═══════════════════════════════════════════════════════════════════════

local function GetClosestTarget()
    local closest = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local center = Vector2.new(mousePos.X, mousePos.Y + 36)
    for _, char in ipairs(getValidTargets()) do
        local part = getTargetPart(char)
        if not part then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist < shortestDist then
            shortestDist = dist
            closest = char
        end
    end
    return closest
end

-- ═══════════════════════════════════════════════════════════════════════
-- AIM CACHE
-- ═══════════════════════════════════════════════════════════════════════

local AimCache = {
    Target = nil,
    TargetPart = nil,
    TargetPos = nil,
    Frame = 0,
    Locked = false,
}
local orbitingObjects = {}
local orbitConnection = nil

local function clearCache()
    AimCache.Target = nil; AimCache.TargetPart = nil; AimCache.TargetPos = nil
    AimCache.Frame = 0; AimCache.Locked = false
    for _, obj in pairs(orbitingObjects) do if obj then obj:Destroy() end end
    table.clear(orbitingObjects)
    if orbitConnection then orbitConnection:Disconnect(); orbitConnection = nil end
end

local function updateCache()
    if not Settings.SilentAim then clearCache(); return end
    if Settings.OnRightClickOnly and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        clearCache(); return
    end

    local currentTarget = AimCache.Target
    if currentTarget and isValidTarget(currentTarget) then
        local part = getTargetPart(currentTarget)
        if part then
            AimCache.TargetPos = part.Position
            AimCache.TargetPart = part
            return
        else
            clearCache()
        end
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

-- ═══════════════════════════════════════════════════════════════════════
-- DRAWING HELPERS
-- ═══════════════════════════════════════════════════════════════════════

local weaponDisplay = Drawing.new("Text")
weaponDisplay.Size = 14; weaponDisplay.Center = true; weaponDisplay.Outline = true
weaponDisplay.OutlineColor = Color3.fromRGB(0,0,0); weaponDisplay.Color = Color3.fromRGB(255,255,255)
weaponDisplay.Transparency = 0.8; weaponDisplay.Visible = false

local function updateWeaponDisplay()
    weaponDisplay.Text = "Weapon: " .. getCurrentGunName()
    weaponDisplay.Visible = Settings.ESPEnabled
end

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5; fovCircle.Filled = false; fovCircle.Transparency = 0.8
fovCircle.Color = Settings.FOVColor

local function updateFOVCircle()
    local mousePos = UserInputService:GetMouseLocation()
    fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y + 36)
    if Settings.FOVFull then
        fovCircle.Radius = 9999
    else
        fovCircle.Radius = Settings.FOVRadius
    end
    fovCircle.Visible = Settings.FOVCircleVisible
    fovCircle.Color = Settings.FOVColor
end

local crosshairLines = {}
local function createCrosshair()
    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Thickness = 2; line.Color = Color3.fromRGB(0,255,0); line.Transparency = 0.8
        line.Visible = false
        table.insert(crosshairLines, line)
    end
end
createCrosshair()

local function updateCrosshair()
    local visible = Settings.Crosshair
    local size = Settings.CrosshairSize or 10
    local thickness = Settings.CrosshairThickness or 2
    local color = Settings.CrosshairColor
    local center = Camera.ViewportSize / 2
    local targetScreenPos = nil
    if Settings.CrosshairFollow and AimCache.Target and isValidTarget(AimCache.Target) then
        local part = getTargetPart(AimCache.Target)
        if part then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then targetScreenPos = Vector2.new(pos.X, pos.Y) end
        end
    end
    local centerPos = targetScreenPos or center
    local offsets = {
        {-size,0,-4,0}, {4,0,size,0}, {0,-size,0,-4}, {0,4,0,size}
    }
    for i, line in ipairs(crosshairLines) do
        local off = offsets[i]
        line.From = Vector2.new(centerPos.X + off[1], centerPos.Y + off[2])
        line.To = Vector2.new(centerPos.X + off[3], centerPos.Y + off[4])
        line.Thickness = thickness; line.Color = color; line.Visible = visible
    end
end

local tracerLine = Drawing.new("Line")
tracerLine.Thickness = 1.5; tracerLine.Transparency = 0.7; tracerLine.Visible = false

local function updateTracer()
    if not Settings.Tracer then tracerLine.Visible = false; return end
    if not AimCache.Target or not isValidTarget(AimCache.Target) then
        tracerLine.Visible = false; return
    end
    local part = getTargetPart(AimCache.Target)
    if not part then tracerLine.Visible = false; return end
    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then tracerLine.Visible = false; return end
    local center = Camera.ViewportSize / 2
    tracerLine.From = Vector2.new(center.X, center.Y)
    tracerLine.To = Vector2.new(pos.X, pos.Y)
    tracerLine.Color = Settings.FOVColor or Color3.fromRGB(255,0,0)
    tracerLine.Visible = true
end

-- ═══════════════════════════════════════════════════════════════════════
-- ROTATION PRIORITY
-- ═══════════════════════════════════════════════════════════════════════

local RotationPriority = {
    FaceTarget = 0,
    SpinBot = 1,
    WalkableDesync = 2,
}
local activeRotation = nil

-- ═══════════════════════════════════════════════════════════════════════
-- NO SLOWDOWN
-- ═══════════════════════════════════════════════════════════════════════

local function fixSlowdown()
    if not Settings.NoSlowDown then return end
    shared.CenterOfMass = "NONE"; shared.MacroSpeed = 0
end
fixSlowdown()

local function cancelSlowdown()
    if not Settings.NoSlowDown or not Character then return end
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
        if child:IsA("Tool") then
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

-- ═══════════════════════════════════════════════════════════════════════
-- AUTO RELOAD
-- ═══════════════════════════════════════════════════════════════════════

local reloading = false
local function autoReload()
    if not Settings.AutoReload or not Character then return end
    local tool = Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local ammo = tool:FindFirstChild("Ammo")
    if ammo and ammo.Value <= 0 and not reloading then
        reloading = true
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        task.delay(0.5, function() reloading = false end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- SILENT AIM HOOK
-- ═══════════════════════════════════════════════════════════════════════

if gunHandlerAvailable and GunHandler then
    local originalGetAim = GunHandler.getAim

    local function getResolvedPosition(target, origin)
        if not Settings.AirshotResolver then return target.Position end
        local root = target
        local currentPos = root.Position
        local velocity = root.AssemblyLinearVelocity or Vector3.new(0,0,0)
        if velocity.Magnitude > 200 then
            local hum = target.Parent:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 then
                velocity = hum.MoveDirection * hum.WalkSpeed
            else
                velocity = Vector3.new(0,0,0)
            end
        end
        return currentPos + (velocity * Settings.PredictionValue)
    end

    GunHandler.getAim = function(origin)
        updateCache()
        if Settings.Resolver and AimCache.Target and isValidTarget(AimCache.Target) then
            local targetPart = getTargetPart(AimCache.Target)
            if targetPart then
                if Settings.ResolverMode == "Velocity" then
                    local vel = targetPart.AssemblyLinearVelocity or Vector3.new(0,0,0)
                    AimCache.TargetPos = targetPart.Position + (vel * 0.1)
                elseif Settings.ResolverMode == "Jitter" then
                    AimCache.TargetPos = targetPart.Position + Vector3.new(
                        (math.random()-0.5)*0.5, (math.random()-0.5)*0.5, (math.random()-0.5)*0.5
                    )
                elseif Settings.ResolverMode == "LookVector" then
                    local look = targetPart.CFrame.LookVector
                    AimCache.TargetPos = targetPart.Position + (look * 2)
                end
            end
        end
        if AimCache.Target and AimCache.TargetPos and isValidTarget(AimCache.Target) then
            if AimCache.TargetPart and AimCache.TargetPart.Parent then
                if Settings.Prediction then
                    AimCache.TargetPos = getResolvedPosition(AimCache.TargetPart, origin)
                else
                    AimCache.TargetPos = AimCache.TargetPart.Position
                end
            end
            local dir = (AimCache.TargetPos - origin).Unit
            local dist = (AimCache.TargetPos - origin).Magnitude
            if Settings.SilentAimMode == "Legit" and Settings.LegitSmoothness > 0 then
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
        if Settings.GlowTracers and result and result.Position then
            local origin = args.ForcedOrigin or args.Handle and args.Handle.Position or Camera.CFrame.Position
            local endPos = result.Position
            local distance = (endPos - origin).Magnitude
            if distance > 5 then
                local beam = Instance.new("Part")
                beam.Size = Vector3.new(Settings.TracerThickness or 0.5, Settings.TracerThickness or 0.5, distance)
                beam.CFrame = CFrame.lookAt(origin, endPos) * CFrame.new(0,0,-distance/2)
                beam.Material = Enum.Material.Neon; beam.Color = Settings.TracerGlowColor
                beam.Anchored = true; beam.CanCollide = false; beam.Transparency = 0.15
                beam.Parent = workspace
                local trail = Instance.new("Trail")
                local att0 = Instance.new("Attachment", beam); local att1 = Instance.new("Attachment", beam)
                att0.Position = Vector3.new(0,0,-distance/2); att1.Position = Vector3.new(0,0,distance/2)
                trail.Attachment0 = att0; trail.Attachment1 = att1
                trail.Color = ColorSequence.new(Settings.TracerGlowColor)
                trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.1), NumberSequenceKeypoint.new(0.5,0.3), NumberSequenceKeypoint.new(1,0.9)})
                trail.Lifetime = Settings.TracerLifeTime; trail.Parent = beam
                local particles = Instance.new("ParticleEmitter")
                particles.Texture = "rbxassetid://2784981116"
                particles.Rate = 200; particles.Lifetime = NumberRange.new(0.05,0.2)
                particles.SpreadAngle = Vector2.new(360,360); particles.VelocityInheritance = 0
                particles.Speed = NumberRange.new(3,10); particles.Color = ColorSequence.new(Settings.TracerGlowColor)
                particles.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.2), NumberSequenceKeypoint.new(1,1)})
                particles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.3), NumberSequenceKeypoint.new(1,0)})
                particles.Parent = beam
                game:GetService("Debris"):AddItem(beam, Settings.TracerLifeTime + 0.3)
            end
        end
        task.spawn(cancelSlowdown)
        return result, newArgs, hitPos
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- KILL AURA BUBBLE
-- ═══════════════════════════════════════════════════════════════════════

local killAuraBubble = nil; local killAuraRing = nil; local bubbleSpinConnection = nil

local function createKillAuraBubble()
    if killAuraBubble then killAuraBubble:Destroy() end
    if killAuraRing then killAuraRing:Destroy() end
    if bubbleSpinConnection then bubbleSpinConnection:Disconnect() end
    killAuraBubble = nil; killAuraRing = nil; bubbleSpinConnection = nil
    if not Settings.KillAura or not Character then return end
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bubble = Instance.new("Part")
    bubble.Name = "KillAuraBubble"
    bubble.Size = Vector3.new(Settings.KillAuraRange*2, Settings.KillAuraRange*2, Settings.KillAuraRange*2)
    bubble.Shape = Enum.PartType.Ball; bubble.Material = Enum.Material.Neon
    bubble.Color = Color3.fromRGB(0,150,255); bubble.Transparency = 0.7
    bubble.Anchored = false; bubble.CanCollide = false; bubble.CastShadow = false
    bubble.Parent = hrp
    local weld = Instance.new("Weld"); weld.Part0 = hrp; weld.Part1 = bubble; weld.C0 = CFrame.new(0,0,0); weld.Parent = bubble
    local ring = Instance.new("Part")
    ring.Name = "KillAuraRing"
    ring.Size = Vector3.new(Settings.KillAuraRange*2.1, 0.2, Settings.KillAuraRange*2.1)
    ring.Shape = Enum.PartType.Cylinder; ring.Material = Enum.Material.Neon
    ring.Color = Color3.fromRGB(0,200,255); ring.Transparency = 0.4
    ring.Anchored = false; ring.CanCollide = false; ring.CastShadow = false
    ring.Parent = hrp
    local ringWeld = Instance.new("Weld"); ringWeld.Part0 = hrp; ringWeld.Part1 = ring; ringWeld.C0 = CFrame.new(0,0,0); ringWeld.Parent = ring
    bubbleSpinConnection = RunService.Heartbeat:Connect(function()
        if not ring.Parent then bubbleSpinConnection:Disconnect(); return end
        ring.CFrame = ring.CFrame * CFrame.Angles(0, math.rad(2), 0)
    end)
    trackConnection(bubbleSpinConnection)
    killAuraBubble = bubble; killAuraRing = ring
end

local function updateKillAuraBubble()
    if not Settings.KillAura then
        if killAuraBubble then killAuraBubble:Destroy() end
        if killAuraRing then killAuraRing:Destroy() end
        if bubbleSpinConnection then bubbleSpinConnection:Disconnect() end
        killAuraBubble = nil; killAuraRing = nil; bubbleSpinConnection = nil
        return
    end
    if not killAuraBubble or not killAuraBubble.Parent then createKillAuraBubble() end
    if killAuraBubble then
        local newSize = Settings.KillAuraRange * 2
        killAuraBubble.Size = Vector3.new(newSize, newSize, newSize)
        if killAuraRing then
            killAuraRing.Size = Vector3.new(newSize * 1.05, 0.2, newSize * 1.05)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- COMBAT LOOP
-- ═══════════════════════════════════════════════════════════════════════

local function performCombat()
    if not (Settings.AutoShoot or Settings.KillAura or Settings.Triggerbot) then return end
    local target = GetClosestTarget()
    if not target then return end
    if Settings.AutoWeapon then
        local weapon = getCurrentWeapon()
        if not weapon then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                        tool.Parent = Character
                        break
                    end
                end
            end
        end
    end
    local weapon = getCurrentWeapon()
    if weapon and weapon:IsA("Tool") then
        weapon:Activate()
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- MOVEMENT FEATURES
-- ═══════════════════════════════════════════════════════════════════════

local walkableDesyncConnection = nil
local function toggleWalkableDesync(enabled)
    if walkableDesyncConnection then walkableDesyncConnection:Disconnect() end
    if enabled then
        walkableDesyncConnection = RunService.Heartbeat:Connect(function()
            if not Settings.WalkableDesync or not Character then return end
            local hrp = Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            activeRotation = {priority = RotationPriority.WalkableDesync, func = function()
                local angle = math.rad(Settings.DesyncAmount)
                return CFrame.new(hrp.Position) * CFrame.Angles(0, angle, 0)
            end}
        end)
        trackConnection(walkableDesyncConnection)
    else
        if walkableDesyncConnection then walkableDesyncConnection:Disconnect(); walkableDesyncConnection = nil end
    end
end

local velocityDesyncConnection = nil
local function toggleVelocityDesync(enabled)
    if velocityDesyncConnection then velocityDesyncConnection:Disconnect() end
    if enabled then
        velocityDesyncConnection = RunService.Heartbeat:Connect(function()
            if not Settings.VelocityDesync or not Character then return end
            local root = Character:FindFirstChild("HumanoidRootPart")
            if root then root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + Vector3.new(0,0.5,0) end
        end)
        trackConnection(velocityDesyncConnection)
    end
end

local networkFakeLagConnection = nil; local frameCounter = 0
local function toggleNetworkFakeLag(enabled)
    if networkFakeLagConnection then networkFakeLagConnection:Disconnect() end
    if enabled then
        networkFakeLagConnection = RunService.Heartbeat:Connect(function()
            if not Settings.NetworkFakeLag or not Character then return end
            local root = Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            frameCounter = frameCounter + 1
            if frameCounter <= Settings.NetworkFakeLagFactor then
                root.AssemblyLinearVelocity = Vector3.new(0,0,0)
            else
                frameCounter = 0
            end
        end)
        trackConnection(networkFakeLagConnection)
    end
end

local antiStompConnection = nil
local function toggleAntiStomp(enabled)
    if antiStompConnection then antiStompConnection:Disconnect() end
    if enabled then
        antiStompConnection = RunService.Heartbeat:Connect(function()
            if not Settings.AntiStomp or not Character then return end
            local hum = Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 15 then
                for _, part in ipairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then part.AssemblyLinearVelocity = Vector3.new(0,-500,0) end
                end
            end
        end)
        trackConnection(antiStompConnection)
    end
end

local spinBotConnection = nil
local function toggleSpinBot(enabled)
    if spinBotConnection then spinBotConnection:Disconnect() end
    if enabled then
        spinBotConnection = RunService.Heartbeat:Connect(function()
            if not Settings.SpinBot or not Character then return end
            local hrp = Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            activeRotation = {priority = RotationPriority.SpinBot, func = function()
                local angle = tick() * math.rad(Settings.SpinBotSpeed * 10)
                return CFrame.new(hrp.Position) * CFrame.Angles(0, angle, 0)
            end}
        end)
        trackConnection(spinBotConnection)
    end
end

local cframeSpeedConnection = nil
local function toggleCFrameSpeed(enabled)
    if cframeSpeedConnection then cframeSpeedConnection:Disconnect() end
    if enabled then
        cframeSpeedConnection = RunService.Heartbeat:Connect(function()
            if not Settings.CFrameSpeed or not Character then return end
            local hrp = Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0,0,-(Settings.CFrameSpeedAmount or 5)*0.1) end
        end)
        trackConnection(cframeSpeedConnection)
    end
end

local flyVelocity = nil; local flyConnection = nil
local function toggleFly(enabled)
    if flyConnection then flyConnection:Disconnect() end
    if flyVelocity then flyVelocity:Destroy() end; flyVelocity = nil
    if enabled and Character then
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        local hum = Character:FindFirstChild("Humanoid")
        if hrp and hum then
            hum.PlatformStand = true
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5); flyVelocity.Velocity = Vector3.new(0,0,0)
            flyVelocity.Parent = hrp
            flyConnection = RunService.Heartbeat:Connect(function()
                if not Settings.Fly or not Character then return end
                local hrp = Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local cam = workspace.CurrentCamera
                local forward = cam.CFrame.LookVector; local right = cam.CFrame.RightVector; local up = cam.CFrame.UpVector
                local move = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + forward end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - forward end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - right end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + right end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + up end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - up end
                if move.Magnitude > 0 then move = move.Unit * 50 end
                flyVelocity.Velocity = move
            end)
            trackConnection(flyConnection)
        end
    else
        if Character then
            local hum = Character:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end

local noclipOriginalState = {}
local noclipConnection = nil
local function toggleNoclip(enabled)
    if noclipConnection then noclipConnection:Disconnect() end
    if enabled then
        noclipConnection = RunService.Heartbeat:Connect(function()
            if not Settings.Noclip or not Character then return end
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if noclipOriginalState[part] == nil then
                        noclipOriginalState[part] = part.CanCollide
                    end
                    part.CanCollide = false
                end
            end
        end)
        trackConnection(noclipConnection)
    else
        if Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local orig = noclipOriginalState[part]
                    if orig ~= nil then
                        part.CanCollide = orig
                    else
                        part.CanCollide = true
                    end
                end
            end
        end
        table.clear(noclipOriginalState)
    end
end

local function applySpeed()
    if Character and Humanoid then Humanoid.WalkSpeed = Settings.Speed end
end

-- ═══════════════════════════════════════════════════════════════════════
-- FACE TARGET
-- ═══════════════════════════════════════════════════════════════════════

local function faceTarget()
    if not Settings.FaceTarget or not Character then return end
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not AimCache.Target or not isValidTarget(AimCache.Target) then return end
    local targetPart = getTargetPart(AimCache.Target)
    if not targetPart then return end
    activeRotation = {priority = RotationPriority.FaceTarget, func = function()
        local lookAt = CFrame.lookAt(hrp.Position, targetPart.Position)
        return CFrame.new(hrp.Position, lookAt.Position + lookAt.LookVector)
    end}
end

-- ═══════════════════════════════════════════════════════════════════════
-- ORBITING ORBS
-- ═══════════════════════════════════════════════════════════════════════

local function createOrbitingEffect()
    if not Settings.OrbitingOrbs or not AimCache.Target or not isValidTarget(AimCache.Target) then return end
    for _, obj in pairs(orbitingObjects) do if obj then obj:Destroy() end end
    table.clear(orbitingObjects)
    if orbitConnection then orbitConnection:Disconnect(); orbitConnection = nil end
    for i = 1, 10 do
        local orb = Instance.new("Part")
        orb.Size = Vector3.new(0.5,0.5,0.5); orb.Shape = Enum.PartType.Ball
        orb.Material = Enum.Material.Neon; orb.Color = Color3.fromRGB(255,100,100)
        orb.Anchored = true; orb.CanCollide = false; orb.Transparency = 0.3
        orb.Parent = workspace
        orbitingObjects[i] = orb
    end
    orbitConnection = RunService.Heartbeat:Connect(function()
        if not Settings.OrbitingOrbs or not AimCache.Target or not isValidTarget(AimCache.Target) then
            for _, obj in pairs(orbitingObjects) do if obj then obj:Destroy() end end
            table.clear(orbitingObjects); orbitConnection:Disconnect(); orbitConnection = nil; return
        end
        local targetPos = AimCache.TargetPos or (AimCache.TargetPart and AimCache.TargetPart.Position)
        if not targetPos then return end
        local time = tick()
        for i, orb in ipairs(orbitingObjects) do
            if not orb then continue end
            local angle = (i / 10) * 2 * math.pi + time * 0.5
            local radius = 3
            local x = math.cos(angle) * radius; local z = math.sin(angle) * radius
            local y = math.sin(angle * 1.5) * 1.5
            orb.CFrame = CFrame.new(targetPos + Vector3.new(x, y, z))
        end
    end)
    trackConnection(orbitConnection)
end

-- ═══════════════════════════════════════════════════════════════════════
-- TARGET HUD
-- ═══════════════════════════════════════════════════════════════════════

local targetGui = Instance.new("ScreenGui")
targetGui.Name = "TargetIndicator"; targetGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
targetGui.ResetOnSpawn = false
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,240,0,60); frame.Position = UDim2.new(0.5,-120,0.5,-30)
frame.BackgroundColor3 = Color3.fromRGB(15,15,25); frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 1; frame.BorderColor3 = Color3.fromRGB(255,255,255)
frame.Active = true; frame.Draggable = true; frame.Visible = false; frame.Parent = targetGui
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1,-10,1,0); label.Position = UDim2.new(0,5,0,0)
label.BackgroundTransparency = 1; label.Text = "No Target"; label.TextColor3 = Color3.fromRGB(255,255,255)
label.TextSize = 14; label.Font = Enum.Font.GothamSemibold
label.TextXAlignment = Enum.TextXAlignment.Left; label.TextYAlignment = Enum.TextYAlignment.Center
label.Parent = frame
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,20,0,20); closeBtn.Position = UDim2.new(1,-22,0,2)
closeBtn.BackgroundTransparency = 1; closeBtn.Text = "✕"; closeBtn.TextColor3 = Color3.fromRGB(200,50,50)
closeBtn.TextSize = 14; closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function() Settings.TargetHUD = false; frame.Visible = false end)

local function updateTargetHUD()
    if not Settings.TargetHUD then frame.Visible = false; return end
    if AimCache.Target and isValidTarget(AimCache.Target) then
        local player = Players:GetPlayerFromCharacter(AimCache.Target)
        local name = player and player.Name or "Unknown"
        local hum = AimCache.Target:FindFirstChild("Humanoid")
        local health = hum and math.floor(hum.Health) or 0
        local dist = AimCache.TargetPos and math.floor((AimCache.TargetPos - Camera.CFrame.Position).Magnitude) or 0
        label.Text = string.format("%s\n❤️ %d HP  |  📏 %dm", name, health, dist)
        label.TextColor3 = (health > 50) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
        frame.Visible = true
    else
        frame.Visible = false
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- KEYBINDS & TARGET SWITCHING
-- ═══════════════════════════════════════════════════════════════════════

local ragebotActive = false
local targetIndex = 0; local targetList = {}
local function switchTarget()
    targetList = getValidTargets()
    if #targetList == 0 then clearCache(); return end
    targetIndex = (targetIndex % #targetList) + 1
    local newTarget = targetList[targetIndex]
    if newTarget and isValidTarget(newTarget) then
        AimCache.Target = newTarget
        AimCache.TargetPart = getTargetPart(newTarget)
        AimCache.TargetPos = AimCache.TargetPart and AimCache.TargetPart.Position or nil
    else
        clearCache()
    end
end

local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.RagebotKeybind then
        ragebotActive = not ragebotActive
        Settings.AutoShoot = ragebotActive; Settings.KillAura = ragebotActive
    end
    if input.KeyCode == Settings.StompKeybind and ragebotActive then
        if AimCache.Target and isValidTarget(AimCache.Target) then
            local targetPos = AimCache.TargetPos
            if targetPos then
                local hrp = Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0,3,0))
                    task.wait(0.1)
                end
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end
    end
    if input.KeyCode == Settings.TargetSwitchKey then
        switchTarget()
    end
    if input.KeyCode == Settings.VoidHideKey then
        if Settings.VoidHide and Character then
            local hrp = Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(Settings.VoidPosition) end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- HITBOX EXPANDER
-- ═══════════════════════════════════════════════════════════════════════

local hitboxOriginalData = {}
local hitboxVisuals = {}

local function updateHitboxVisual()
    if not Settings.HitboxExpander or not Settings.HitboxVisual then
        for _, v in pairs(hitboxVisuals) do if v then v:Destroy() end end
        table.clear(hitboxVisuals)
        return
    end

    local size = Settings.HitboxExpanderSize or 25
    local idx = 1
    for _, char in ipairs(cachedPlayers) do
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp ~= Character:FindFirstChild("HumanoidRootPart") then
            local visual = hitboxVisuals[idx]
            if not visual then
                visual = Instance.new("Part")
                visual.Size = Vector3.new(size,size,size)
                visual.Material = Enum.Material.Neon
                visual.Color = Color3.fromRGB(255,50,50)
                visual.Transparency = 0.5
                visual.Anchored = true
                visual.CanCollide = false
                visual.Parent = workspace
                local weld = Instance.new("Weld")
                weld.Part0 = hrp
                weld.Part1 = visual
                weld.C0 = CFrame.new(0,0,0)
                weld.Parent = visual
                hitboxVisuals[idx] = visual
            end
            visual.Size = Vector3.new(size,size,size)
            visual.CFrame = hrp.CFrame
            idx = idx + 1
        end
    end
    while #hitboxVisuals > idx do
        local extra = hitboxVisuals[#hitboxVisuals]
        if extra then extra:Destroy() end
        table.remove(hitboxVisuals)
    end
end

local function applyHitboxExpander()
    if not Settings.HitboxExpander then
        for char, data in pairs(hitboxOriginalData) do
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = data.Size; hrp.Transparency = data.Transparency; hrp.CanCollide = data.CanCollide
            end
        end
        table.clear(hitboxOriginalData)
        for _, v in pairs(hitboxVisuals) do if v then v:Destroy() end end
        table.clear(hitboxVisuals)
        return
    end
    local size = Settings.HitboxExpanderSize or 25
    for _, char in ipairs(cachedPlayers) do
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp ~= Character:FindFirstChild("HumanoidRootPart") then
            if not hitboxOriginalData[char] then
                hitboxOriginalData[char] = {Size = hrp.Size, Transparency = hrp.Transparency, CanCollide = hrp.CanCollide}
            end
            hrp.Size = Vector3.new(size,size,size); hrp.CanCollide = false; hrp.Transparency = 0.5
        end
    end
    if Settings.HitboxVisual then updateHitboxVisual() end
end

-- ═══════════════════════════════════════════════════════════════════════
-- SELF CHAMS
-- ═══════════════════════════════════════════════════════════════════════

local selfHighlight = nil
local function updateSelfChams()
    if selfHighlight then selfHighlight:Destroy() end; selfHighlight = nil
    if not Settings.SelfChams or not Character then return end
    selfHighlight = Instance.new("Highlight")
    selfHighlight.FillColor = Settings.SelfChamsColor; selfHighlight.FillTransparency = Settings.SelfChamsTransparency
    selfHighlight.OutlineColor = Color3.fromRGB(255,255,255); selfHighlight.OutlineTransparency = 0.3
    selfHighlight.Parent = Character
end

-- ═══════════════════════════════════════════════════════════════════════
-- ENEMY CHAMS
-- ═══════════════════════════════════════════════════════════════════════

local chamsObjects = {}
local function applyChams()
    for _, obj in pairs(chamsObjects) do if obj:IsA("Highlight") then obj:Destroy() end end
    table.clear(chamsObjects)
    if not Settings.ChamsEnabled then return end
    if Settings.ChamsPlayer then
        for _, char in ipairs(cachedPlayers) do
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Settings.ChamsColor; highlight.FillTransparency = Settings.ChamsTransparency
                highlight.OutlineColor = Color3.fromRGB(255,255,255); highlight.OutlineTransparency = 0.3
                highlight.Parent = char
                table.insert(chamsObjects, highlight)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- TOOL ORBIT
-- ═══════════════════════════════════════════════════════════════════════

local toolOrbitParts = {}; local orbitUpdateConnection = nil
local function updateToolOrbit()
    for _, part in pairs(toolOrbitParts) do if part then part:Destroy() end end
    table.clear(toolOrbitParts)
    if orbitUpdateConnection then orbitUpdateConnection:Disconnect(); orbitUpdateConnection = nil end
    if not Settings.ToolOrbit or not Character then return end
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local weapons = {}
    for _, child in ipairs(Character:GetChildren()) do
        if child:IsA("Tool") and child:FindFirstChild("Handle") then table.insert(weapons, child) end
    end
    for i, tool in ipairs(weapons) do
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.5,0.5,0.5); part.Shape = Enum.PartType.Ball
        part.Material = Enum.Material.Neon; part.Color = Color3.fromRGB(255,200,50)
        part.Anchored = true; part.CanCollide = false; part.Transparency = 0.3
        part.Parent = workspace
        part:SetAttribute("ToolIndex", i)
        table.insert(toolOrbitParts, part)
    end
    if #toolOrbitParts > 0 then
        orbitUpdateConnection = RunService.Heartbeat:Connect(function()
            if not Settings.ToolOrbit or not Character then return end
            local hrp = Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local center = hrp.Position; local time = tick(); local speed = Settings.ToolOrbitSpeed or 2
            for i, part in ipairs(toolOrbitParts) do
                if not part then continue end
                local index = part:GetAttribute("ToolIndex") or i
                local angle = (index / #toolOrbitParts) * 2 * math.pi + time * speed
                local radius = 3
                local x = math.cos(angle) * radius; local z = math.sin(angle) * radius
                local y = math.sin(angle * 1.5) * 1.5
                part.CFrame = CFrame.new(center + Vector3.new(x, y, z))
            end
        end)
        trackConnection(orbitUpdateConnection)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- ESP
-- ═══════════════════════════════════════════════════════════════════════

local ESPObjects = {}

local function getESPColor(player, char, isVisible)
    if not player then return Settings.ESPEnemyColor end
    local isEnemy = (not Settings.TeamCheck) or (player.Team ~= LocalPlayer.Team)
    local base = isEnemy and Settings.ESPEnemyColor or Settings.ESPTeamColor
    return isVisible and Settings.ESPVisibleColor or base
end

local function createESPForCharacter(char)
    if ESPObjects[char] then return end
    local player = Players:GetPlayerFromCharacter(char)
    if not player then return end
    local esp = {}
    if Settings.ESPBoxes then
        esp.Box = Drawing.new("Square")
        esp.Box.Thickness = 2; esp.Box.Filled = false; esp.Box.Transparency = 0.5
    end
    if Settings.ESPNames then
        esp.Name = Drawing.new("Text")
        esp.Name.Size = 14; esp.Name.Center = true; esp.Name.Outline = true
        esp.Name.OutlineColor = Color3.fromRGB(0,0,0); esp.Name.Transparency = 0.8
    end
    if Settings.ESPHealth then
        esp.Health = Drawing.new("Text")
        esp.Health.Size = 12; esp.Health.Center = true; esp.Health.Outline = true
        esp.Health.OutlineColor = Color3.fromRGB(0,0,0); esp.Health.Transparency = 0.8
    end
    if Settings.ESPDistance then
        esp.Distance = Drawing.new("Text")
        esp.Distance.Size = 11; esp.Distance.Center = true; esp.Distance.Outline = true
        esp.Distance.OutlineColor = Color3.fromRGB(0,0,0); esp.Distance.Transparency = 0.6
    end
    if Settings.ESPSnaplines then
        esp.Snapline = Drawing.new("Line"); esp.Snapline.Thickness = 1; esp.Snapline.Transparency = 0.5
    end
    if Settings.ESPTracers then
        esp.Tracer = Drawing.new("Line"); esp.Tracer.Thickness = 1; esp.Tracer.Transparency = 0.7
    end
    if Settings.ESPHeadDot then
        esp.HeadDot = Drawing.new("Circle"); esp.HeadDot.Radius = 3; esp.HeadDot.Filled = true
        esp.HeadDot.Transparency = 0.8
    end
    if Settings.ESPSkeleton then
        esp.Skeleton = {}
        for i = 1, 6 do
            local line = Drawing.new("Line")
            line.Thickness = 1; line.Transparency = 0.5
            table.insert(esp.Skeleton, line)
        end
    end
    if Settings.ESPWeapon then
        esp.Weapon = Drawing.new("Text")
        esp.Weapon.Size = 11; esp.Weapon.Center = true; esp.Weapon.Outline = true
        esp.Weapon.OutlineColor = Color3.fromRGB(0,0,0); esp.Weapon.Transparency = 0.7
    end
    ESPObjects[char] = esp
end

local function updateESPObject(char, esp)
    if not char or not char.Parent then
        for _, obj in pairs(esp) do if obj and obj.Visible ~= nil then obj.Visible = false end end
        return
    end
    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then
        for _, obj in pairs(esp) do if obj and obj.Visible ~= nil then obj.Visible = false end end
        return
    end

    local parts = {}
    local r15 = char:FindFirstChild("UpperTorso") and char:FindFirstChild("LowerTorso")
    if r15 then
        parts = {
            Head = char:FindFirstChild("Head"),
            UpperTorso = char:FindFirstChild("UpperTorso"),
            LowerTorso = char:FindFirstChild("LowerTorso"),
            LeftUpperArm = char:FindFirstChild("LeftUpperArm"),
            LeftLowerArm = char:FindFirstChild("LeftLowerArm"),
            RightUpperArm = char:FindFirstChild("RightUpperArm"),
            RightLowerArm = char:FindFirstChild("RightLowerArm"),
            LeftUpperLeg = char:FindFirstChild("LeftUpperLeg"),
            LeftLowerLeg = char:FindFirstChild("LeftLowerLeg"),
            RightUpperLeg = char:FindFirstChild("RightUpperLeg"),
            RightLowerLeg = char:FindFirstChild("RightLowerLeg"),
            HumanoidRootPart = char:FindFirstChild("HumanoidRootPart"),
        }
    else
        parts = {
            Head = char:FindFirstChild("Head"),
            Torso = char:FindFirstChild("Torso"),
            LeftArm = char:FindFirstChild("Left Arm"),
            RightArm = char:FindFirstChild("Right Arm"),
            LeftLeg = char:FindFirstChild("Left Leg"),
            RightLeg = char:FindFirstChild("Right Leg"),
            HumanoidRootPart = char:FindFirstChild("HumanoidRootPart"),
        }
    end

    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge
    local rootScreen = nil
    for _, part in pairs(parts) do
        if part and part:IsA("BasePart") then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                if pos.X < minX then minX = pos.X end
                if pos.X > maxX then maxX = pos.X end
                if pos.Y < minY then minY = pos.Y end
                if pos.Y > maxY then maxY = pos.Y end
                if part == parts.HumanoidRootPart or part == parts.Torso or part == parts.UpperTorso then
                    rootScreen = Vector2.new(pos.X, pos.Y)
                end
            end
        end
    end

    if not rootScreen or minX == math.huge then
        for _, obj in pairs(esp) do if obj and obj.Visible ~= nil then obj.Visible = false end end
        return
    end

    local isVisible = false
    if Settings.VisibleCheck then
        local origin = Camera.CFrame.Position
        local targetPart = parts.Head or parts.Torso or parts.UpperTorso or parts.HumanoidRootPart
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
    local color = getESPColor(player, char, isVisible)

    if esp.Box then
        local sizeX = maxX - minX
        local sizeY = maxY - minY
        if sizeX > 1 and sizeY > 1 then
            esp.Box.Visible = true
            esp.Box.Position = Vector2.new(minX, minY)
            esp.Box.Size = Vector2.new(sizeX, sizeY)
            esp.Box.Color = color
        else
            esp.Box.Visible = false
        end
    end

    if esp.Name then
        esp.Name.Visible = true
        esp.Name.Position = Vector2.new(rootScreen.X, minY - 20)
        esp.Name.Text = player and player.Name or "Unknown"
        esp.Name.Color = color
    end

    if esp.Health then
        esp.Health.Visible = true
        esp.Health.Position = Vector2.new(rootScreen.X, maxY + 10)
        local health = hum.Health
        esp.Health.Text = math.floor(health) .. " HP"
        local pct = health / hum.MaxHealth
        esp.Health.Color = Color3.fromRGB(255 - 255*pct, 255*pct, 0)
    end

    if esp.Distance then
        esp.Distance.Visible = true
        esp.Distance.Position = Vector2.new(rootScreen.X, maxY + 30)
        local dist = (parts.HumanoidRootPart and parts.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
        esp.Distance.Text = math.floor(dist) .. "m"
        esp.Distance.Color = Color3.fromRGB(255,255,255)
    end

    if esp.Snapline then
        esp.Snapline.Visible = true
        esp.Snapline.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        esp.Snapline.To = rootScreen
        esp.Snapline.Color = color
    end

    if esp.Tracer then
        esp.Tracer.Visible = true
        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        esp.Tracer.To = rootScreen
        esp.Tracer.Color = Settings.TracerColor
    end

    if esp.HeadDot then
        local headPart = parts.Head or parts.Torso or parts.UpperTorso
        if headPart then
            local headPos, onScreen = Camera:WorldToViewportPoint(headPart.Position)
            if onScreen then
                esp.HeadDot.Visible = true
                esp.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                esp.HeadDot.Color = color
            else
                esp.HeadDot.Visible = false
            end
        else
            esp.HeadDot.Visible = false
        end
    end

    if esp.Skeleton then
        local skeletonLines = {}
        if r15 then
            skeletonLines = {
                {parts.Head, parts.UpperTorso},
                {parts.UpperTorso, parts.LowerTorso},
                {parts.LeftUpperArm, parts.LeftLowerArm},
                {parts.RightUpperArm, parts.RightLowerArm},
                {parts.LeftUpperLeg, parts.LeftLowerLeg},
                {parts.RightUpperLeg, parts.RightLowerLeg},
            }
        else
            skeletonLines = {
                {parts.Head, parts.Torso},
                {parts.LeftArm, parts.Torso},
                {parts.RightArm, parts.Torso},
                {parts.LeftLeg, parts.Torso},
                {parts.RightLeg, parts.Torso},
            }
        end
        for i, pair in ipairs(skeletonLines) do
            local p1, p2 = pair[1], pair[2]
            local line = esp.Skeleton[i]
            if p1 and p2 and line then
                local p1Pos, on1 = Camera:WorldToViewportPoint(p1.Position)
                local p2Pos, on2 = Camera:WorldToViewportPoint(p2.Position)
                if on1 and on2 then
                    line.Visible = true
                    line.From = Vector2.new(p1Pos.X, p1Pos.Y)
                    line.To = Vector2.new(p2Pos.X, p2Pos.Y)
                    line.Color = color
                else
                    line.Visible = false
                end
            elseif line then
                line.Visible = false
            end
        end
        for i = #skeletonLines + 1, #esp.Skeleton do
            if esp.Skeleton[i] then esp.Skeleton[i].Visible = false end
        end
    end

    if esp.Weapon then
        esp.Weapon.Visible = true
        esp.Weapon.Position = Vector2.new(rootScreen.X, maxY + 50)
        local tool = char:FindFirstChildOfClass("Tool")
        esp.Weapon.Text = tool and tool.Name or ""
        esp.Weapon.Color = Color3.fromRGB(255,255,255)
    end
end

local function rebuildESP()
    for char, esp in pairs(ESPObjects) do
        for _, obj in pairs(esp) do
            if obj and obj.Remove then
                obj:Remove()
            end
        end
    end

    table.clear(ESPObjects)

    if not Settings.ESPEnabled then
        return
    end

    for _, char in ipairs(cachedPlayers) do
        createESPForCharacter(char)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- WORLD MODS
-- ═══════════════════════════════════════════════════════════════════════

local originalLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    FogEnd = Lighting.FogEnd,
    FogColor = Lighting.FogColor,
    FogStart = Lighting.FogStart
}
local function applyWorldMods()
    if Settings.WorldFogEnabled then
        Lighting.Brightness = Settings.WorldBrightness
        Lighting.Ambient = Settings.WorldAmbient
        Lighting.FogColor = Settings.WorldFogColor
        Lighting.FogEnd = Settings.WorldFogEnd
        Lighting.FogStart = 0
    else
        for prop, val in pairs(originalLighting) do
            Lighting[prop] = val
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- REAPPLY ALL FEATURES (MUST be defined before it's called)
-- ═══════════════════════════════════════════════════════════════════════

local function reapplyAllFeatures()
    disconnectAll()
    clearCache()
    toggleWalkableDesync(Settings.WalkableDesync)
    toggleVelocityDesync(Settings.VelocityDesync)
    toggleNetworkFakeLag(Settings.NetworkFakeLag)
    toggleAntiStomp(Settings.AntiStomp)
    toggleSpinBot(Settings.SpinBot)
    toggleCFrameSpeed(Settings.CFrameSpeed)
    toggleFly(Settings.Fly)
    toggleNoclip(Settings.Noclip)
    applySpeed()
    applyChams()
    applyHitboxExpander()
    hookWeaponSlowdown()
    createKillAuraBubble()
    updateSelfChams()
    updateToolOrbit()
    updateWeaponDisplay()
    applyNoSpread()
    applyWorldMods()
    rebuildESP()
    -- Recreate main loops
    trackConnection(RunService.RenderStepped:Connect(renderLoop))
    trackConnection(RunService.Heartbeat:Connect(heartbeatLoop))
    trackConnection(UserInputService.InputBegan:Connect(onInputBegan))
end

-- ═══════════════════════════════════════════════════════════════════════
-- RENDER LOOP (uses reapplyAllFeatures, must be defined after)
-- ═══════════════════════════════════════════════════════════════════════

local function renderLoop()
    updateFOVCircle()
    updateCrosshair()
    updateTracer()
    updateTargetHUD()
    updateWeaponDisplay()

    if Settings.ESPEnabled then
        for char, esp in pairs(ESPObjects) do
            if char and char.Parent and isValidTarget(char) then
                updateESPObject(char, esp)
            else
                for _, obj in pairs(esp) do
                    if obj and obj.Visible ~= nil then obj.Visible = false end
                end
            end
        end
    else
        for char, esp in pairs(ESPObjects) do
            for _, obj in pairs(esp) do
                if obj and obj.Visible ~= nil then obj.Visible = false end
            end
        end
    end

    faceTarget()

    if activeRotation and Character then
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local best = nil
            local bestPriority = -1
            for _, entry in pairs({activeRotation}) do
                if entry and entry.priority > bestPriority then
                    best = entry; bestPriority = entry.priority
                end
            end
            if best then
                hrp.CFrame = best.func()
            end
        end
        activeRotation = nil
    end

    if Settings.OrbitingOrbs and AimCache.Target and isValidTarget(AimCache.Target) then
        if #orbitingObjects == 0 then createOrbitingEffect() end
    else
        if #orbitingObjects > 0 then
            for _, obj in pairs(orbitingObjects) do if obj then obj:Destroy() end end
            table.clear(orbitingObjects)
            if orbitConnection then orbitConnection:Disconnect(); orbitConnection = nil end
        end
    end
end

local function heartbeatLoop()
    autoReload()
    performCombat()
end

-- ═══════════════════════════════════════════════════════════════════════
-- PERMANENT CONNECTIONS (must be defined after everything they use)
-- ═══════════════════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function(newChar)
    refreshCharacter(newChar)
    task.wait(0.5)
    if Settings.NoSlowDown then Humanoid.WalkSpeed = originalWalkSpeed end
    rebuildPlayerCache()
    reapplyAllFeatures()
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        rebuildPlayerCache()
        if Settings.ESPEnabled then
            createESPForCharacter(char)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    local char = player.Character
    if char and ESPObjects[char] then
        for _, obj in pairs(ESPObjects[char]) do
            if obj and obj.Remove then obj:Remove() end
        end
        ESPObjects[char] = nil
    end
    rebuildPlayerCache()
end)

-- ═══════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════

task.wait(1)
rebuildPlayerCache()
reapplyAllFeatures()

-- ═══════════════════════════════════════════════════════════════════════
-- UI (Starlight) – corrected syntax
-- ═══════════════════════════════════════════════════════════════════════

local success, err = pcall(function()
    if not Starlight then
        error("Starlight library failed to load!")
    end

    local MainWindow = Starlight:CreateWindow({
        Name = "tapped.cc | Da Hood",
        Icon = NebulaIcons:GetIcon("zap", "Material"),
        DefaultTab = "Ragebot"
    })

    if not MainWindow then
        error("MainWindow failed to create!")
    end

    local RageTab = MainWindow:CreateTab({ 
        Name = "Ragebot", 
        Icon = NebulaIcons:GetIcon("crosshair", "Material")
    })
    local LocalTab = MainWindow:CreateTab({ 
        Name = "Local / HvH", 
        Icon = NebulaIcons:GetIcon("shield", "Material")
    })
    local VisTab = MainWindow:CreateTab({ 
        Name = "Visuals", 
        Icon = NebulaIcons:GetIcon("eye", "Material")
    })
    local MiscTab = MainWindow:CreateTab({ 
        Name = "Misc", 
        Icon = NebulaIcons:GetIcon("settings", "Material")
    })
    local ConfigTab = MainWindow:CreateTab({ 
        Name = "Config", 
        Icon = NebulaIcons:GetIcon("save", "Material")
    })
    local DebugTab = MainWindow:CreateTab({ 
        Name = "Debug", 
        Icon = NebulaIcons:GetIcon("terminal", "Material")
    })

    -- Ragebot Section
    local MainRageSec = RageTab:CreateSection({ Name = "Silent Aim & Combat" })
    MainRageSec:CreateToggle({ Name = "Silent Aim", Default = Settings.SilentAim, Callback = function(v) Settings.SilentAim = v end })
    MainRageSec:CreateToggle({ Name = "Auto Shoot", Default = Settings.AutoShoot, Callback = function(v) Settings.AutoShoot = v end })
    MainRageSec:CreateToggle({ Name = "Triggerbot", Default = Settings.Triggerbot, Callback = function(v) Settings.Triggerbot = v end })
    MainRageSec:CreateToggle({ Name = "Kill Aura", Default = Settings.KillAura, Callback = function(v) Settings.KillAura = v; updateKillAuraBubble() end })
    MainRageSec:CreateSlider({ Name = "Kill Aura Range", Min = 50, Max = 500, Default = Settings.KillAuraRange, Callback = function(v) Settings.KillAuraRange = v; updateKillAuraBubble() end })
    MainRageSec:CreateToggle({ Name = "Prediction", Default = Settings.Prediction, Callback = function(v) Settings.Prediction = v end })
    MainRageSec:CreateSlider({ Name = "Prediction Value", Min = 0, Max = 0.5, Default = Settings.PredictionValue, Increment = 0.001, Callback = function(v) Settings.PredictionValue = v end })
    MainRageSec:CreateToggle({ Name = "No Spread", Default = Settings.NoSpread, Callback = function(v) Settings.NoSpread = v; applyNoSpread() end })
    MainRageSec:CreateToggle({ Name = "Auto Reload", Default = Settings.AutoReload, Callback = function(v) Settings.AutoReload = v end })
    MainRageSec:CreateToggle({ Name = "Bullet TP (Experimental)", Default = Settings.BulletTP, Callback = function(v) Settings.BulletTP = v end })

    local TargetHitboxSec = RageTab:CreateSection({ Name = "Target Hitbox" })
    TargetHitboxSec:CreateDropdown({ Name = "Aim Part", List = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}, Default = Settings.AimPart, Callback = function(v) Settings.AimPart = v end })
    TargetHitboxSec:CreateSlider({ Name = "Shot Delay (Coming soon)", Min = 0, Max = 500, Default = Settings.ShotDelay, Callback = function(v) Settings.ShotDelay = v end, Enabled = false })

    local RageVisualsSec = RageTab:CreateSection({ Name = "Visuals (Ragebot)" })
    RageVisualsSec:CreateToggle({ Name = "FOV Full", Default = Settings.FOVFull, Callback = function(v) Settings.FOVFull = v end })
    RageVisualsSec:CreateSlider({ Name = "FOV Radius", Min = 50, Max = 2000, Default = Settings.FOVRadius, Callback = function(v) Settings.FOVRadius = v end })
    RageVisualsSec:CreateColorPicker({ Name = "FOV Color", Default = Settings.FOVColor, Callback = function(c) Settings.FOVColor = c end })
    RageVisualsSec:CreateToggle({ Name = "Face Target", Default = Settings.FaceTarget, Callback = function(v) Settings.FaceTarget = v end })
    RageVisualsSec:CreateToggle({ Name = "View Target (HUD)", Default = Settings.TargetHUD, Callback = function(v) Settings.TargetHUD = v end })
    RageVisualsSec:CreateToggle({ Name = "Crosshair Follow", Default = Settings.CrosshairFollow, Callback = function(v) Settings.CrosshairFollow = v end })
    RageVisualsSec:CreateToggle({ Name = "Tracer", Default = Settings.Tracer, Callback = function(v) Settings.Tracer = v end })
    RageVisualsSec:CreateToggle({ Name = "Orbiting Orbs", Default = Settings.OrbitingOrbs, Callback = function(v) Settings.OrbitingOrbs = v; createOrbitingEffect() end })
    RageVisualsSec:CreateToggle({ Name = "Weapon Display", Default = Settings.ESPEnabled, Callback = function(v) Settings.ESPEnabled = v end })

    local TargetSelectSec = RageTab:CreateSection({ Name = "Target Selection" })
    TargetSelectSec:CreateKeybind({ Name = "Switch Target Key", Default = Settings.TargetSwitchKey, Callback = function(key) Settings.TargetSwitchKey = key end })
    TargetSelectSec:CreateToggle({ Name = "Auto Weapon Select", Default = Settings.AutoWeapon, Callback = function(v) Settings.AutoWeapon = v end })
    TargetSelectSec:CreateToggle({ Name = "Hitbox Expander", Default = Settings.HitboxExpander, Callback = function(v) Settings.HitboxExpander = v; applyHitboxExpander() end })
    TargetSelectSec:CreateSlider({ Name = "Hitbox Size", Min = 5, Max = 50, Default = Settings.HitboxExpanderSize, Callback = function(v) Settings.HitboxExpanderSize = v; applyHitboxExpander() end })
    TargetSelectSec:CreateToggle({ Name = "Team Check", Default = Settings.TeamCheck, Callback = function(v) Settings.TeamCheck = v end })
    TargetSelectSec:CreateToggle({ Name = "Visibility Check", Default = Settings.VisibleCheck, Callback = function(v) Settings.VisibleCheck = v end })
    TargetSelectSec:CreateToggle({ Name = "Right Click Only", Default = Settings.OnRightClickOnly, Callback = function(v) Settings.OnRightClickOnly = v end })

    -- Local/HvH Section
    local HvHSec = LocalTab:CreateSection({ Name = "HvH & Resolver" })
    HvHSec:CreateToggle({ Name = "Resolver", Default = Settings.Resolver, Callback = function(v) Settings.Resolver = v end })
    HvHSec:CreateDropdown({ Name = "Resolver Mode", List = {"Velocity", "Jitter", "LookVector"}, Default = Settings.ResolverMode, Callback = function(v) Settings.ResolverMode = v end })
    HvHSec:CreateToggle({ Name = "Walkable Desync", Default = Settings.WalkableDesync, Callback = function(v) Settings.WalkableDesync = v; toggleWalkableDesync(v) end })
    HvHSec:CreateSlider({ Name = "Desync Amount", Min = 30, Max = 180, Default = Settings.DesyncAmount, Callback = function(v) Settings.DesyncAmount = v end })
    HvHSec:CreateToggle({ Name = "Velocity Desync", Default = Settings.VelocityDesync, Callback = function(v) Settings.VelocityDesync = v; toggleVelocityDesync(v) end })
    HvHSec:CreateToggle({ Name = "Network Fake Lag", Default = Settings.NetworkFakeLag, Callback = function(v) Settings.NetworkFakeLag = v; toggleNetworkFakeLag(v) end })
    HvHSec:CreateToggle({ Name = "Anti-Stomp", Default = Settings.AntiStomp, Callback = function(v) Settings.AntiStomp = v; toggleAntiStomp(v) end })
    HvHSec:CreateKeybind({ Name = "Void Hide Key", Default = Settings.VoidHideKey, Callback = function(key) Settings.VoidHideKey = key end })
    HvHSec:CreateToggle({ Name = "Void Hide", Default = Settings.VoidHide, Callback = function(v) Settings.VoidHide = v end })

    local SpinSec = LocalTab:CreateSection({ Name = "Spinbot & Movement" })
    SpinSec:CreateToggle({ Name = "Spin Bot", Default = Settings.SpinBot, Callback = function(v) Settings.SpinBot = v; toggleSpinBot(v) end })
    SpinSec:CreateSlider({ Name = "Spin Speed", Min = 1, Max = 20, Default = Settings.SpinBotSpeed, Callback = function(v) Settings.SpinBotSpeed = v end })
    SpinSec:CreateToggle({ Name = "CFrame Speed", Default = Settings.CFrameSpeed, Callback = function(v) Settings.CFrameSpeed = v; toggleCFrameSpeed(v) end })
    SpinSec:CreateSlider({ Name = "CFrame Amount", Min = 1, Max = 20, Default = Settings.CFrameSpeedAmount, Callback = function(v) Settings.CFrameSpeedAmount = v end })
    SpinSec:CreateToggle({ Name = "Fly", Default = Settings.Fly, Callback = function(v) Settings.Fly = v; toggleFly(v) end })
    SpinSec:CreateToggle({ Name = "Noclip", Default = Settings.Noclip, Callback = function(v) Settings.Noclip = v; toggleNoclip(v) end })

    -- Visuals Section
    local ESPSec = VisTab:CreateSection({ Name = "ESP" })
    ESPSec:CreateToggle({ Name = "Enable ESP", Default = Settings.ESPEnabled, Callback = function(v) Settings.ESPEnabled = v; rebuildESP() end })
    ESPSec:CreateToggle({ Name = "Boxes", Default = Settings.ESPBoxes, Callback = function(v) Settings.ESPBoxes = v; rebuildESP() end })
    ESPSec:CreateToggle({ Name = "Names", Default = Settings.ESPNames, Callback = function(v) Settings.ESPNames = v; rebuildESP() end })
    ESPSec:CreateToggle({ Name = "Health", Default = Settings.ESPHealth, Callback = function(v) Settings.ESPHealth = v; rebuildESP() end })
    ESPSec:CreateToggle({ Name = "Distance", Default = Settings.ESPDistance, Callback = function(v) Settings.ESPDistance = v; rebuildESP() end })
    ESPSec:CreateToggle({ Name = "Snaplines", Default = Settings.ESPSnaplines, Callback = function(v) Settings.ESPSnaplines = v; rebuildESP() end })
    ESPSec:CreateToggle({ Name = "Tracers", Default = Settings.ESPTracers, Callback = function(v) Settings.ESPTracers = v; rebuildESP() end })
    ESPSec:CreateToggle({ Name = "Head Dot", Default = Settings.ESPHeadDot, Callback = function(v) Settings.ESPHeadDot = v; rebuildESP() end })
    ESPSec:CreateToggle({ Name = "Skeleton", Default = Settings.ESPSkeleton, Callback = function(v) Settings.ESPSkeleton = v; rebuildESP() end })
    ESPSec:CreateToggle({ Name = "Weapon Name", Default = Settings.ESPWeapon, Callback = function(v) Settings.ESPWeapon = v; rebuildESP() end })
    ESPSec:CreateColorPicker({ Name = "Enemy Color", Default = Settings.ESPEnemyColor, Callback = function(c) Settings.ESPEnemyColor = c end })
    ESPSec:CreateColorPicker({ Name = "Team Color", Default = Settings.ESPTeamColor, Callback = function(c) Settings.ESPTeamColor = c end })
    ESPSec:CreateColorPicker({ Name = "Visible Color", Default = Settings.ESPVisibleColor, Callback = function(c) Settings.ESPVisibleColor = c end })
    ESPSec:CreateColorPicker({ Name = "Tracer Color", Default = Settings.TracerColor, Callback = function(c) Settings.TracerColor = c end })

    local ChamsSec = VisTab:CreateSection({ Name = "Chams" })
    ChamsSec:CreateToggle({ Name = "Enable Chams", Default = Settings.ChamsEnabled, Callback = function(v) Settings.ChamsEnabled = v; applyChams() end })
    ChamsSec:CreateToggle({ Name = "Player Chams", Default = Settings.ChamsPlayer, Callback = function(v) Settings.ChamsPlayer = v; applyChams() end })
    ChamsSec:CreateColorPicker({ Name = "Chams Color", Default = Settings.ChamsColor, Callback = function(c) Settings.ChamsColor = c; applyChams() end })
    ChamsSec:CreateSlider({ Name = "Chams Transparency", Min = 0, Max = 1, Default = Settings.ChamsTransparency, Increment = 0.05, Callback = function(v) Settings.ChamsTransparency = v; applyChams() end })

    local LocalVisSec = VisTab:CreateSection({ Name = "Local Visuals" })
    LocalVisSec:CreateToggle({ Name = "Self Chams", Default = Settings.SelfChams, Callback = function(v) Settings.SelfChams = v; updateSelfChams() end })
    LocalVisSec:CreateColorPicker({ Name = "Self Chams Color", Default = Settings.SelfChamsColor, Callback = function(c) Settings.SelfChamsColor = c; updateSelfChams() end })
    LocalVisSec:CreateSlider({ Name = "Self Chams Transparency", Min = 0, Max = 1, Default = Settings.SelfChamsTransparency, Increment = 0.05, Callback = function(v) Settings.SelfChamsTransparency = v; updateSelfChams() end })
    LocalVisSec:CreateToggle({ Name = "Tool Orbit", Default = Settings.ToolOrbit, Callback = function(v) Settings.ToolOrbit = v; updateToolOrbit() end })
    LocalVisSec:CreateSlider({ Name = "Tool Orbit Speed", Min = 1, Max = 10, Default = Settings.ToolOrbitSpeed, Callback = function(v) Settings.ToolOrbitSpeed = v end })

    local WorldSec = VisTab:CreateSection({ Name = "World" })
    WorldSec:CreateSlider({ Name = "Brightness", Min = 0, Max = 5, Default = Settings.WorldBrightness, Callback = function(v) Settings.WorldBrightness = v; applyWorldMods() end })
    WorldSec:CreateToggle({ Name = "Fog", Default = Settings.WorldFogEnabled, Callback = function(v) Settings.WorldFogEnabled = v; applyWorldMods() end })
    WorldSec:CreateSlider({ Name = "Fog End", Min = 100, Max = 5000, Default = Settings.WorldFogEnd, Callback = function(v) Settings.WorldFogEnd = v; applyWorldMods() end })

    -- Misc Section
    local MoveSec = MiscTab:CreateSection({ Name = "Movement" })
    MoveSec:CreateSlider({ Name = "Speed", Min = 1, Max = 100, Default = Settings.Speed, Callback = function(v) Settings.Speed = v; applySpeed() end })

    local AutoSec = MiscTab:CreateSection({ Name = "Automation" })
    AutoSec:CreateToggle({ Name = "Auto-Stomp", Default = Settings.AutoStomp, Callback = function(v) Settings.AutoStomp = v end })
    AutoSec:CreateKeybind({ Name = "Stomp Key", Default = Settings.StompKeybind, Callback = function(key) Settings.StompKeybind = key end })
    AutoSec:CreateKeybind({ Name = "Ragebot Toggle Key", Default = Settings.RagebotKeybind, Callback = function(key) Settings.RagebotKeybind = key end })
    AutoSec:CreateToggle({ Name = "No Slowdown", Default = Settings.NoSlowDown, Callback = function(v) Settings.NoSlowDown = v; if v then fixSlowdown() end end })

    -- Config Section
    local ConfigSec = ConfigTab:CreateSection({ Name = "Configuration" })
    ConfigSec:CreateButton({ Name = "Save Config", Callback = function() saveConfig() end })
    ConfigSec:CreateButton({ Name = "Load Config", Callback = function() loadConfig() end })

    -- Debug Section
    local DebugSec = DebugTab:CreateSection({ Name = "Console Logs" })
    DebugSec:CreateButton({ Name = "Clear Logs", Callback = function() DebugLogs = {}; Log("Logs Cleared") end })
end)

if not success then
    warn("[tapped.cc UI ERROR]", err)
    Log("[UI ERROR] " .. tostring(err))
end

-- ═══════════════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════════════

local function cleanup()
    disconnectAll()
    if weaponDisplay then weaponDisplay:Remove() end
    if fovCircle then fovCircle:Remove() end
    if tracerLine then tracerLine:Remove() end
    for _, line in pairs(crosshairLines) do if line then line:Remove() end end
    if targetGui then targetGui:Destroy() end
    if killAuraBubble then killAuraBubble:Destroy() end
    if killAuraRing then killAuraRing:Destroy() end
    if selfHighlight then selfHighlight:Destroy() end
    for _, obj in pairs(chamsObjects) do if obj:IsA("Highlight") then obj:Destroy() end end
    for _, v in pairs(hitboxVisuals) do if v then v:Destroy() end end
    table.clear(hitboxVisuals)
    for _, obj in pairs(toolOrbitParts) do if obj then obj:Destroy() end end
    for _, obj in pairs(orbitingObjects) do if obj then obj:Destroy() end end
    for _, esp in pairs(ESPObjects) do
        for _, obj in pairs(esp) do
            if obj and obj.Remove then obj:Remove() end
        end
    end
    for char, data in pairs(hitboxOriginalData) do
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = data.Size; hrp.Transparency = data.Transparency; hrp.CanCollide = data.CanCollide
        end
    end
    for prop, val in pairs(originalLighting) do Lighting[prop] = val end
    for part, orig in pairs(noclipOriginalState) do
        if part and part.Parent then
            part.CanCollide = orig
        end
    end
    table.clear(noclipOriginalState)
    if Character and Humanoid then
        Humanoid.WalkSpeed = originalWalkSpeed
    end
    clearCache()
    Log("Cleanup complete.")
end

_G.cleanup = cleanup

Log("tapped.cc v3.3.1 loaded successfully.")
Log("All systems operational.")
