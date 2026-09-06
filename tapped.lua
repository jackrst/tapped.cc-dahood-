local function safeStart()
    local ok, err = pcall(function()
        local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
        local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
        local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
        local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
        if not Library then warn("[tapped.cc] Failed to load UI library") return end

        Library.ShowToggleFrameInKeybinds = true
        Library.ShowCustomCursor = true
        Library.NotifySide = "Left"

        local Window = Library:CreateWindow({
            Title = "tapped.cc – Da Hood",
            Center = true,
            AutoShow = true,
            Resizable = true,
            ShowCustomCursor = true,
            UnlockMouseWhileOpen = true,
            NotifySide = "Left",
            TabPadding = 8,
            MenuFadeTime = 0.2
        })

        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local GuiService = game:GetService("GuiService")
        local LocalPlayer = Players.LocalPlayer
        local TweenService = game:GetService("TweenService")
        local Lighting = game:GetService("Lighting")
        local Debris = game:GetService("Debris")
        local TeleportService = game:GetService("TeleportService")
        local function getCamera() return workspace.CurrentCamera end

        local Capabilities = {
            Drawing = false,
            fireclickdetector = type(fireclickdetector) == "function",
            getconnections = type(getconnections) == "function",
            setfpscap = type(setfpscap) == "function",
            sethiddenproperty = type(sethiddenproperty) == "function",
        }
        pcall(function()
            if Drawing ~= nil and type(Drawing) == "table" and type(Drawing.new) == "function" then
                local ok, circ = pcall(function() return Drawing.new("Circle") end)
                if ok and circ then
                    local ok2, line = pcall(function() return Drawing.new("Line") end)
                    if ok2 and line then
                        Capabilities.Drawing = true
                        pcall(function() circ:Remove(); line:Remove() end)
                    end
                end
            end
        end)

        local MainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
        Capabilities.MainEvent = MainEvent ~= nil

        local function clampNumber(value, minimum, maximum, fallback)
            local num = tonumber(value)
            if not num then return fallback end
            if num < minimum then return minimum end
            if num > maximum then return maximum end
            return num
        end

        local Settings = {
            Ragebot = {
                SilentAim = false,
                Hitchance = 100,
                AimPart = "HumanoidRootPart",
                TeamCheck = false,
                PriorityMode = "FOV",
                VisibilityCheck = false,
                FOVRadius = 200,
                FOVColor = Color3.fromRGB(255,0,0),
                FOVThickness = 1.5,
                FOVTransparency = 0.8,
                ShowFOV = true,
                LockKey = "Q",
                Spectate = false,
                TargetStrafe = { Enabled = false, Speed = 1.5, Distance = 8, Height = 4, Keybind = "X" },
                Unhittable = false,
                AutoShoot = false,
                AutoShootVisibilityCheck = false,
                RapidFire = false,
                RapidFireDelay = 0.08,
                NoRecoil = false,
                AutoReload = false,
                StopAutoShootBelowHealth = 20,
                LockTracer = true,
                Prediction = false,
                Resolver = true,
                KnockedCheck = true,
                GrabbedCheck = true,
                NoGroundShots = true,
                SilentReload = false,
                AutoSelect = false,
                AutoStomp = false,
                HitDetection = {
                    Enabled = false,
                    Sound = true,
                    Notify = true,
                    HitSound = "Neverlose",
                },
                HitboxExpander = {
                    Enabled = false,
                    Size = Vector3.new(16,16,16),
                    Color = Color3.fromRGB(0,0,0),
                    Transparency = 0.8,
                    OutlineColor = Color3.fromRGB(108,59,170),
                    OutlineTransparency = 0,
                },
                AntiAim = {
                    VoidHide = false,
                },
            },
            Player = {
                WalkSpeedEnabled = false,
                WalkSpeed = 300,
                WalkSpeedToggleKey = "T",
                NoClipEnabled = false,
                Fly = { Enabled = false, Keybind = Enum.KeyCode.F, Speed = 25 },
                NoSlow = false,
                NoJumpCooldown = false,
                NetworkAnti = { Enabled = false, Keybind = Enum.KeyCode.K },
                AutoRespawn = false,
                AutoRespawnDelay = 3,
                AntiVoid = true,
            },
            Visuals = {
                BulletTracers = {
                    Enabled = false,
                    Color = Color3.fromRGB(255,102,204),
                    Width = 0.5,
                    Brightness = 5,
                    Segments = 10,
                    LightEmission = 5,
                    Speed = 3,
                    Texture = "Normal",
                    RayTracing = false,
                    GlowIntensity = 5,
                },
                HitSound = {
                    Enabled = false,
                    SelectedSound = "Neverlose",
                    Volume = 1,
                    SoundId = "rbxassetid://139452805868562",
                },
                ESP = { Enabled = false, TeamCheck = false, HighlightColor = Color3.fromRGB(255,0,0), HighlightTransparency = 0.5 },
                SelfChams = {
                    Enabled = false,
                    Color = Color3.fromRGB(255,0,0),
                    Transparency = 0.5,
                    OutlineColor = Color3.fromRGB(255,255,255),
                    OutlineTransparency = 0,
                    Material = "ForceField",
                },
                CameraFOV = 70,
                Watermark = {
                    Enabled = true,
                    Color = Color3.fromRGB(226,226,226),
                    Size = 14,
                    StatusSize = 11,
                },
                NoFlash = { Enabled = false },
            },
            Graphics = {
                Ambience = { Enabled = false, Ambient = Color3.fromRGB(178,178,178), OutdoorAmbient = Color3.fromRGB(178,178,178), Brightness = 2, ColorShiftBottom = Color3.fromRGB(0,0,0), ColorShiftTop = Color3.fromRGB(0,0,0), FogColor = Color3.fromRGB(0,0,0), FogStart = 0, FogEnd = 500, TimeOfDay = "18:00:00", SkyboxID = "rbxassetid://1294489738", ClockTimeOverride = 18 },
                LowGraphics = false,
            },
            Misc = {
                AutoBuy = { SelectedGun = nil },
                SelectedLocation = "Admin Base",
            },
        }

        Settings.Player.WalkSpeed = clampNumber(Settings.Player.WalkSpeed, 0, 500, 300)
        Settings.Ragebot.FOVRadius = clampNumber(Settings.Ragebot.FOVRadius, 1, 2000, 200)
        Settings.Ragebot.Hitchance = clampNumber(Settings.Ragebot.Hitchance, 0, 100, 100)
        Settings.Ragebot.StopAutoShootBelowHealth = clampNumber(Settings.Ragebot.StopAutoShootBelowHealth, 0, 100, 20)
        Settings.Ragebot.RapidFireDelay = clampNumber(Settings.Ragebot.RapidFireDelay, 0.02, 0.5, 0.08)
        Settings.Player.AutoRespawnDelay = clampNumber(Settings.Player.AutoRespawnDelay, 0.5, 10, 3)
        Settings.Visuals.CameraFOV = clampNumber(Settings.Visuals.CameraFOV, 1, 120, 70)

        local CharacterState = {
            character = nil,
            humanoid = nil,
            rootPart = nil,
            walkSpeed = nil,
            jumpPower = nil,
        }
        local function isValidPart(part) return part and part.Parent and part:IsA("BasePart") end
        local function isValidCharacter(model)
            if not model or not model.Parent then return false end
            local hum = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            return hum and hum.Health > 0 and root ~= nil
        end
        local function refreshCharacter(character)
            CharacterState.character = character
            task.spawn(function()
                local hum = character:WaitForChild("Humanoid", 10)
                local root = character:WaitForChild("HumanoidRootPart", 10)
                CharacterState.humanoid = hum
                CharacterState.rootPart = root
                if hum then
                    CharacterState.walkSpeed = hum.WalkSpeed
                    CharacterState.jumpPower = hum.JumpPower
                end
            end)
        end
        if LocalPlayer.Character then refreshCharacter(LocalPlayer.Character) end
        LocalPlayer.CharacterAdded:Connect(refreshCharacter)

        local ConnectionManager = { _connections = {} }
        function ConnectionManager:Add(feature, connection)
            if not connection or typeof(connection.Disconnect) ~= "function" then return nil end
            local entry = { connection = connection, feature = feature, active = true }
            table.insert(self._connections, entry)
            return entry
        end
        function ConnectionManager:Remove(entry)
            if not entry or not entry.active then return end
            entry.active = false
            pcall(function() entry.connection:Disconnect() end)
        end
        function ConnectionManager:RemoveAll()
            for _, entry in ipairs(self._connections) do
                if entry.active then
                    entry.active = false
                    pcall(function() entry.connection:Disconnect() end)
                end
            end
            self._connections = {}
        end

        local Cleanup = { callbacks = {} }
        function Cleanup:Add(callback) table.insert(self.callbacks, callback) end
        function Cleanup:Run()
            for i = #self.callbacks, 1, -1 do
                pcall(self.callbacks[i])
                self.callbacks[i] = nil
            end
        end

        local fovCircle, lockTracerLine, watermarkText, watermarkStatus, targetCircle, selfHighlight = nil, nil, nil, nil, nil, nil
        local OriginalHitboxState = {}
        local outlinePool = {}
        local espObjects = {}
        local targetVelocity = {}
        local velocityHistory = {}

        Cleanup:Add(function()
            ConnectionManager:RemoveAll()
            if CharacterState.humanoid and CharacterState.humanoid.Parent then
                if CharacterState.walkSpeed then CharacterState.humanoid.WalkSpeed = CharacterState.walkSpeed end
                if CharacterState.jumpPower then CharacterState.humanoid.JumpPower = CharacterState.jumpPower end
            end
        end)
        Cleanup:Add(function()
            if fovCircle then pcall(function() fovCircle:Remove() end); fovCircle = nil end
            if lockTracerLine then pcall(function() lockTracerLine:Remove() end); lockTracerLine = nil end
            if watermarkText then pcall(function() watermarkText:Remove() end); watermarkText = nil end
            if watermarkStatus then pcall(function() watermarkStatus:Remove() end); watermarkStatus = nil end
            if targetCircle then pcall(function() targetCircle:Destroy() end); targetCircle = nil end
            if selfHighlight then pcall(function() selfHighlight:Destroy() end); selfHighlight = nil end
            for _, obj in pairs(espObjects) do pcall(function() if obj.highlight then obj.highlight:Destroy() end; if obj.billboard then obj.billboard:Destroy() end end) end
            espObjects = {}
            for char, data in pairs(OriginalHitboxState) do
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if isValidPart(root) then
                    root.Size = data.Size
                    root.Transparency = data.Transparency
                    root.BrickColor = data.BrickColor
                    root.Material = data.Material
                    root.CanCollide = data.CanCollide
                    root.CanTouch = data.CanTouch
                    root.CanQuery = data.CanQuery
                    root.Massless = data.Massless
                    local out = root:FindFirstChild("Outline")
                    if out then pcall(function() out:Destroy() end) end
                end
            end
            OriginalHitboxState = {}
        end)

        local function getScreenPosition(worldPos)
            local cam = getCamera()
            if not cam then return Vector2.new(0,0) end
            local pos = cam:WorldToScreenPoint(worldPos)
            local inset = GuiService:GetGuiInset()
            return Vector2.new(pos.X, pos.Y + inset.Y)
        end
        local function getPlayerFromCharacter(char)
            if not char then return nil end
            return Players:GetPlayerFromCharacter(char)
        end
        local function resolveAimPart(character)
            if not character then return nil end
            local part = character:FindFirstChild(Settings.Ragebot.AimPart)
            if isValidPart(part) then return part end
            part = character:FindFirstChild("HumanoidRootPart")
            if isValidPart(part) then return part end
            part = character:FindFirstChild("Head")
            if isValidPart(part) then return part end
            return nil
        end
        local function isPartVisible(part)
            if not isValidPart(part) then return false end
            local cam = getCamera()
            if not cam then return false end
            local camPos = cam.CFrame.Position
            local dir = (part.Position - camPos).Unit
            local dist = (part.Position - camPos).Magnitude
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {LocalPlayer.Character}
            local result = workspace:Raycast(camPos, dir * dist, params)
            if result then return result.Instance == part or result.Instance:IsDescendantOf(part.Parent) end
            return true
        end
        local function getFOVCenter() return UserInputService:GetMouseLocation() end
        local function isValidLockedTarget(character)
            return isValidCharacter(character) and (not Settings.Ragebot.KnockedCheck or not (character:FindFirstChild("BodyEffects") and character.BodyEffects:FindFirstChild("K.O") and character.BodyEffects["K.O"].Value)) and (not Settings.Ragebot.GrabbedCheck or not character:FindFirstChild("GRABBING_CONSTRAINT")) and (not Settings.Ragebot.NoGroundShots or (character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position.Y >= -20))
        end
        local function hasProtection(character)
            if character:FindFirstChildOfClass("ForceField") then return true end
            local prot = character:FindFirstChild("Protection")
            if prot and prot:IsA("BoolValue") and prot.Value == true then return true end
            return false
        end
        local function getAllEnemies(teamCheck)
            local chars = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                local char = player.Character
                if not char then continue end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                if teamCheck and player.Team == LocalPlayer.Team then continue end
                table.insert(chars, char)
            end
            return chars
        end
        local function findBestTarget()
            local chars = getAllEnemies(Settings.Ragebot.TeamCheck)
            if #chars == 0 then return nil end
            local center = getFOVCenter()
            local cam = getCamera()
            if not cam then return nil end
            local best, bestScore = nil, math.huge
            for _, char in ipairs(chars) do
                if not isValidCharacter(char) then continue end
                local part = resolveAimPart(char)
                if not part then continue end
                local screenPos = getScreenPosition(part.Position)
                local pos3D = cam:WorldToScreenPoint(part.Position)
                if pos3D.Z <= 0 then continue end
                local dist = (screenPos - center).Magnitude
                if dist > Settings.Ragebot.FOVRadius then continue end
                if not Settings.Ragebot.HitboxExpander.Enabled and Settings.Ragebot.VisibilityCheck and not isPartVisible(part) then continue end
                local score = dist
                if Settings.Ragebot.PriorityMode == "Distance" then
                    score = (part.Position - cam.CFrame.Position).Magnitude
                elseif Settings.Ragebot.PriorityMode == "Health" then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    score = hum and hum.Health or 100
                end
                if score < bestScore then
                    bestScore = score
                    best = char
                end
            end
            return best
        end

        local TargetState = { Locked = false, Character = nil, Player = nil }

        local showNotification
        local function lockTarget(character)
            local player = getPlayerFromCharacter(character)
            if not player or not character or not isValidLockedTarget(character) then return false end
            TargetState.Locked = true
            TargetState.Character = character
            TargetState.Player = player
            if Settings.Ragebot.Spectate then
                local hum = character:FindFirstChildOfClass("Humanoid")
                if hum then
                    local cam = getCamera()
                    if cam then
                        cam.CameraSubject = hum
                        cam.CameraType = Enum.CameraType.Custom
                    end
                end
            end
            if player and showNotification then
                showNotification("Locked onto " .. player.Name, "info")
            end
            return true
        end
        local function unlockTarget()
            local oldPlayer = TargetState.Player
            TargetState.Locked = false
            TargetState.Character = nil
            TargetState.Player = nil
            -- Revert camera to self
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local cam = getCamera()
                    if cam then
                        cam.CameraSubject = hum
                        cam.CameraType = Enum.CameraType.Custom
                    end
                end
            end
            if oldPlayer and showNotification then
                showNotification("Unlocked " .. oldPlayer.Name, "info")
            end
        end
        local function handleLockToggle()
            if TargetState.Locked then unlockTarget() else
                local best = findBestTarget()
                if best then lockTarget(best) end
            end
        end

        -- Spectate toggle callback: apply immediately if target locked
        local function applySpectateSetting()
            if Settings.Ragebot.Spectate then
                if TargetState.Locked and TargetState.Character then
                    local hum = TargetState.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local cam = getCamera()
                        if cam then
                            cam.CameraSubject = hum
                            cam.CameraType = Enum.CameraType.Custom
                        end
                    end
                end
            else
                -- revert to self
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local cam = getCamera()
                        if cam then
                            cam.CameraSubject = hum
                            cam.CameraType = Enum.CameraType.Custom
                        end
                    end
                end
            end
        end

        local resolverIndex = 0
        local resolverParts = {"Head", "HumanoidRootPart", "Torso"}
        local GunHandler = nil
        pcall(function()
            local modules = ReplicatedStorage:FindFirstChild("Modules")
            if modules then
                local gunModule = modules:FindFirstChild("GunHandler")
                if gunModule then
                    GunHandler = require(gunModule)
                end
            end
        end)

        if GunHandler then
            local origAim = GunHandler.getAim
            local origCanShoot = GunHandler.getCanShoot

            GunHandler.getAim = function(origin, ...)
                if not Settings.Ragebot.SilentAim then
                    return origAim(origin, ...)
                end

                if TargetState.Locked and TargetState.Character and isValidLockedTarget(TargetState.Character) then
                    if math.random(1,100) <= Settings.Ragebot.Hitchance then
                        local aimPartName = Settings.Ragebot.AimPart
                        if Settings.Ragebot.Resolver then
                            resolverIndex = (resolverIndex % #resolverParts) + 1
                            aimPartName = resolverParts[resolverIndex]
                            local target = TargetState.Character
                            local head = target:FindFirstChild("Head")
                            if head and isValidPart(head) then
                                if not isPartVisible(head) then
                                    aimPartName = "HumanoidRootPart"
                                end
                            end
                        end

                        local part = TargetState.Character:FindFirstChild(aimPartName)
                        if not isValidPart(part) then
                            part = resolveAimPart(TargetState.Character)
                        end

                        if part then
                            local pos = part.Position
                            if Settings.Ragebot.Prediction then
                                local vd = targetVelocity[TargetState.Character]
                                if vd and vd.velocity then
                                    local velMag = vd.velocity.Magnitude
                                    if velMag > 2 then
                                        local ping = LocalPlayer:GetNetworkPing()
                                        local dist = (pos - origin).Magnitude
                                        local bulletSpeed = 300
                                        local travelTime = dist / bulletSpeed
                                        local leadTime = (ping / 1000) + travelTime
                                        local hist = velocityHistory[TargetState.Character]
                                        if not hist then hist = {}; velocityHistory[TargetState.Character] = hist end
                                        table.insert(hist, vd.velocity)
                                        if #hist > 3 then table.remove(hist, 1) end
                                        local avgVel = Vector3.new(0,0,0)
                                        for _, v in ipairs(hist) do avgVel = avgVel + v end
                                        avgVel = avgVel / #hist
                                        pos = pos + avgVel * leadTime
                                    end
                                end
                            end
                            local dir = (pos - origin).Unit
                            local dist = (pos - origin).Magnitude
                            -- FIX: if origin is inside the target (distance very small), use a small offset to avoid zero direction
                            if dist < 0.5 then
                                -- Use the part's CFrame up vector or just a fixed offset
                                local offset = Vector3.new(0, 1, 0) -- aim slightly above center
                                dir = (pos + offset - origin).Unit
                            end
                            return dir, dist
                        end
                    end
                end
                return origAim(origin, ...)
            end

            GunHandler.getCanShoot = function(char)
                if Settings.Ragebot.RapidFire then
                    return true
                end
                return origCanShoot(char)
            end
        end

        local rapidFireHooks = {}
        local rapidFireChildConns = {}
        local rapidFireLoopRunning = false
        local rapidFireLoopThread = nil
        local lastFireTime = {}

        local function hookToolForRapidFire(tool)
            if not tool:IsA("Tool") then return end
            if not Capabilities.getconnections then return end
            for _, conn in ipairs(getconnections(tool.Activated)) do
                pcall(function()
                    local info = debug.getinfo(conn.Function, "u")
                    if info then
                        for i = 1, info.nups do
                            local v = debug.getupvalue(conn.Function, i)
                            if type(v) == "number" then
                                table.insert(rapidFireHooks, {conn = conn, index = i, original = v})
                                debug.setupvalue(conn.Function, i, 0)
                            end
                        end
                    end
                end)
            end
        end

        local function startRapidFireLoop()
            if rapidFireLoopRunning then return end
            rapidFireLoopRunning = true
            rapidFireLoopThread = task.spawn(function()
                while rapidFireLoopRunning do
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        local char = LocalPlayer.Character
                        if char then
                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool then
                                local ammo = tool:FindFirstChild("Ammo")
                                if not ammo or ammo.Value > 0 then
                                    local canFire = true
                                    local cd = tool:FindFirstChild("Cooldown") or tool:FindFirstChild("FireRate")
                                    if cd and cd:IsA("NumberValue") then
                                        local last = lastFireTime[tool] or 0
                                        if tick() - last < cd.Value then
                                            canFire = false
                                        else
                                            lastFireTime[tool] = tick()
                                        end
                                    end
                                    if canFire then
                                        tool:Activate()
                                    end
                                end
                            end
                        end
                    end
                    task.wait(Settings.Ragebot.RapidFireDelay)
                end
            end)
        end

        local function stopRapidFireLoop()
            rapidFireLoopRunning = false
            if rapidFireLoopThread then task.cancel(rapidFireLoopThread); rapidFireLoopThread = nil end
        end

        function applyRapidFire()
            for _, hook in ipairs(rapidFireHooks) do
                pcall(function() debug.setupvalue(hook.conn.Function, hook.index, hook.original) end)
            end
            rapidFireHooks = {}
            for _, conn in ipairs(rapidFireChildConns) do
                if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
            end
            rapidFireChildConns = {}
            stopRapidFireLoop()

            if not Settings.Ragebot.RapidFire then return end
            if not Capabilities.getconnections then return end

            local char = LocalPlayer.Character
            local backpack = LocalPlayer:FindFirstChild("Backpack")

            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    hookToolForRapidFire(tool)
                end
                local conn = char.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") then
                        task.wait(0.1)
                        hookToolForRapidFire(child)
                    end
                end)
                table.insert(rapidFireChildConns, conn)
            end

            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    hookToolForRapidFire(tool)
                end
                local conn = backpack.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") then
                        task.wait(0.1)
                        hookToolForRapidFire(child)
                    end
                end)
                table.insert(rapidFireChildConns, conn)
            end

            startRapidFireLoop()
        end

        local flyCore, flyWeld, flyPos, flyGyro = nil, nil, nil, nil
        local flyRunning = false
        local flyKeys = {w=false,a=false,s=false,d=false}

        function startFly()
            if flyRunning then return end
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not isValidPart(root) then return end
            flyCore = Instance.new("Part")
            flyCore.Name = "IgnoredVelocity"
            flyCore.Size = Vector3.new(0.05,0.05,0.05)
            flyCore.Anchored = false; flyCore.CanCollide = false
            flyCore.Parent = workspace
            flyWeld = Instance.new("Weld", flyCore)
            flyWeld.Part0 = flyCore; flyWeld.Part1 = root; flyWeld.C0 = CFrame.new(0,0,0)
            flyPos = Instance.new("BodyPosition", flyCore)
            flyPos.Name = "IgnoredVelocity"
            flyPos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyPos.position = flyCore.Position
            flyGyro = Instance.new("BodyGyro", flyCore)
            flyGyro.maxTorque = Vector3.new(9e9,9e9,9e9)
            flyGyro.cframe = flyCore.CFrame
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = true
                hum.AutoJumpEnabled = false
            end
            flyRunning = true
        end

        function stopFly()
            if not flyRunning then return end
            flyRunning = false
            if flyCore then flyCore:Destroy(); flyCore=nil end
            if flyWeld then flyWeld:Destroy(); flyWeld=nil end
            if flyPos then flyPos:Destroy(); flyPos=nil end
            if flyGyro then flyGyro:Destroy(); flyGyro=nil end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.PlatformStand = false
                    hum.AutoJumpEnabled = true
                    hum.WalkSpeed = CharacterState.walkSpeed or 16
                    hum.JumpPower = CharacterState.jumpPower or 50
                end
                for _, constraint in pairs(char:GetDescendants()) do
                    if constraint:IsA("BodyPosition") or constraint:IsA("BodyGyro") or constraint:IsA("Weld") then
                        if constraint.Name == "IgnoredVelocity" or constraint.Name == "FlyCore" then
                            constraint:Destroy()
                        end
                    end
                end
            end
        end

        function setFlyEnabled(enabled)
            if enabled then startFly() else stopFly() end
            Settings.Player.Fly.Enabled = enabled
        end

        local flyMovementEntry
        function startFlyMovementLoop()
            if flyMovementEntry then return end
            local conn = RunService.RenderStepped:Connect(function(dt)
                if not flyRunning or not flyPos or not flyGyro then return end
                local cam = getCamera()
                if not cam then return end
                local speed = Settings.Player.Fly.Speed * dt
                local newPos = flyGyro.cframe - flyGyro.cframe.p + flyPos.position
                if flyKeys.w then newPos = newPos + cam.CoordinateFrame.lookVector * speed end
                if flyKeys.s then newPos = newPos - cam.CoordinateFrame.lookVector * speed end
                if flyKeys.d then newPos = newPos * CFrame.new(speed,0,0) end
                if flyKeys.a then newPos = newPos * CFrame.new(-speed,0,0) end
                flyPos.position = newPos.p
                flyGyro.cframe = cam.CoordinateFrame
            end)
            flyMovementEntry = ConnectionManager:Add("Fly", conn)
        end

        local silentReloadEntry = nil
        function setSilentReloadEnabled(enabled)
            Settings.Ragebot.SilentReload = enabled
            if silentReloadEntry then ConnectionManager:Remove(silentReloadEntry); silentReloadEntry = nil end
            if enabled then
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local targetAnim = "rbxassetid://2877910736"
                        local conn = RunService.Heartbeat:Connect(function()
                            if not hum or not hum.Parent then return end
                            for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                                local anim = track.Animation
                                if anim and anim.AnimationId == targetAnim then track:Stop() end
                            end
                        end)
                        silentReloadEntry = ConnectionManager:Add("SilentReload", conn)
                    end
                end
            end
        end

        local hitboxEntry = nil
        local lastHitboxTarget = nil

        function getOutline(part)
            if not isValidPart(part) then return nil end
            local out = part:FindFirstChild("Outline")
            if not out then
                out = #outlinePool > 0 and table.remove(outlinePool) or Instance.new("SelectionBox")
                out.LineThickness = 0.05
                out.Color3 = Settings.Ragebot.HitboxExpander.OutlineColor
                out.Name = "Outline"
            end
            out.Adornee = part
            out.Parent = part
            out.Transparency = Settings.Ragebot.HitboxExpander.OutlineTransparency
            return out
        end

        function releaseOutline(out)
            if out then
                out.Adornee = nil
                out.Parent = nil
                table.insert(outlinePool, out)
            end
        end

        function saveOriginalHitboxState(char)
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not isValidPart(root) then return end
            if OriginalHitboxState[char] then return end
            OriginalHitboxState[char] = {
                Size = root.Size,
                Transparency = root.Transparency,
                BrickColor = root.BrickColor,
                Material = root.Material,
                CanCollide = root.CanCollide,
                CanTouch = root.CanTouch,
                CanQuery = root.CanQuery,
                Massless = root.Massless,
            }
        end

        function restoreHitboxState(char)
            if not char then return end
            local data = OriginalHitboxState[char]
            if not data then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if isValidPart(root) then
                root.Size = data.Size
                root.Transparency = data.Transparency
                root.BrickColor = data.BrickColor
                root.Material = data.Material
                root.CanCollide = data.CanCollide
                root.CanTouch = data.CanTouch
                root.CanQuery = data.CanQuery
                root.Massless = data.Massless
                local out = root:FindFirstChild("Outline")
                if out then releaseOutline(out) end
            end
            OriginalHitboxState[char] = nil
        end

        function restoreAllHitboxes()
            for char, _ in pairs(OriginalHitboxState) do
                restoreHitboxState(char)
            end
            OriginalHitboxState = {}
            lastHitboxTarget = nil
        end

        function updateHitboxes()
            if not Settings.Ragebot.HitboxExpander.Enabled then return end
            local target = TargetState.Locked and TargetState.Character or nil
            if target and not isValidCharacter(target) then target = nil end

            if lastHitboxTarget and lastHitboxTarget ~= target then
                restoreHitboxState(lastHitboxTarget)
            end

            if target then
                local root = target:FindFirstChild("HumanoidRootPart")
                if isValidPart(root) then
                    saveOriginalHitboxState(target)
                    lastHitboxTarget = target

                    local be = target:FindFirstChild("BodyEffects")
                    local KO = be and be:FindFirstChild("K.O") and be["K.O"].Value
                    local grabbed = target:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
                    if KO or grabbed then
                        root.Size = Vector3.new(0,0,0)
                        root.Transparency = 1
                        local out = root:FindFirstChild("Outline")
                        if out then releaseOutline(out) end
                    else
                        local sz = Settings.Ragebot.HitboxExpander.Size
                        if root.Size ~= sz then
                            root.Size = sz
                            root.Transparency = Settings.Ragebot.HitboxExpander.Transparency
                            root.BrickColor = BrickColor.new(Settings.Ragebot.HitboxExpander.Color)
                            root.Material = Enum.Material.Neon
                            root.CanCollide = false
                            getOutline(root)
                        else
                            root.BrickColor = BrickColor.new(Settings.Ragebot.HitboxExpander.Color)
                            root.Transparency = Settings.Ragebot.HitboxExpander.Transparency
                        end
                        local out = root:FindFirstChild("Outline")
                        if out then
                            out.Color3 = Settings.Ragebot.HitboxExpander.OutlineColor
                            out.Transparency = Settings.Ragebot.HitboxExpander.OutlineTransparency
                        end
                    end
                end
            else
                if lastHitboxTarget then
                    restoreHitboxState(lastHitboxTarget)
                    lastHitboxTarget = nil
                end
            end
        end

        function setHitboxExpanderEnabled(enabled)
            Settings.Ragebot.HitboxExpander.Enabled = enabled
            if enabled then
                if not hitboxEntry then
                    local conn = RunService.Heartbeat:Connect(updateHitboxes)
                    hitboxEntry = ConnectionManager:Add("Hitbox", conn)
                end
            else
                if hitboxEntry then ConnectionManager:Remove(hitboxEntry); hitboxEntry = nil end
                restoreAllHitboxes()
            end
        end

        local soundOptions = {
            Neverlose = "rbxassetid://139452805868562",
            Sparkle = "rbxassetid://110241936966089",
            Minecraft = "rbxassetid://131197435969853",
            TF2 = "rbxassetid://118731928809041",
        }
        local hitEffectCooldowns = {}

        function playHitSoundGlobal()
            if not Settings.Ragebot.HitDetection.Sound then return end
            local s = Instance.new("Sound")
            s.SoundId = Settings.Visuals.HitSound.SoundId
            s.Volume = Settings.Visuals.HitSound.Volume
            s.Parent = workspace
            s:Play()
            Debris:AddItem(s, 1)
        end

        local notifyGui, notifyContainer
        local activeNotifies = {}
        local NOTIFY_WIDTH = 320
        local NOTIFY_HEIGHT = 32
        local NOTIFY_GAP = 6
        local NOTIFY_DURATION = 1.8
        local NOTIFY_FADE_TIME = 0.3
        local NOTIFY_BG_TRANSPARENCY = 0.25
        local NOTIFY_TEXT_SIZE = 14
        local NOTIFY_FONT = Enum.Font.SourceSansSemibold
        local MAX_NOTIFICATIONS = 5
        local ICON_COLORS = {
            hit = Color3.fromRGB(46, 204, 113),
            info = Color3.fromRGB(255, 255, 255),
            warn = Color3.fromRGB(241, 196, 15),
        }

        local function createNotifyGui()
            if notifyGui and notifyGui.Parent then return end
            notifyGui = Instance.new("ScreenGui")
            notifyGui.Name = "_NotificationGui"
            notifyGui.ResetOnSpawn = false
            notifyGui.IgnoreGuiInset = true
            notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            pcall(function()
                notifyGui.Parent = game:GetService("CoreGui")
            end)
            if not notifyGui.Parent then
                notifyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            end
            notifyContainer = Instance.new("Frame")
            notifyContainer.Name = "Container"
            notifyContainer.Parent = notifyGui
            notifyContainer.BackgroundTransparency = 1
            notifyContainer.BorderSizePixel = 0
            notifyContainer.Size = UDim2.new(0, NOTIFY_WIDTH, 0, 220)
            notifyContainer.AnchorPoint = Vector2.new(0.5, 1)
            notifyContainer.Position = UDim2.new(0.5, 0, 0.78, 0)
        end

        local function updateNotificationPositions(animated)
            for index, notif in ipairs(activeNotifies) do
                if notif.frame and notif.frame.Parent then
                    local targetY = -(index * NOTIFY_HEIGHT) - ((index - 1) * NOTIFY_GAP)
                    notif.currentY = targetY
                    local target = UDim2.new(0, 0, 1, targetY)
                    if animated then
                        local tween = TweenService:Create(
                            notif.frame,
                            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                            {Position = target}
                        )
                        tween:Play()
                    else
                        notif.frame.Position = target
                    end
                end
            end
        end

        local function fadeOutAndRemove(notif)
            if not notif or notif.removing then return end
            notif.removing = true
            local frame = notif.frame
            local label = notif.label
            local icon = notif.icon
            if frame and frame.Parent then
                local targetPos = UDim2.new(0, 40, 1, notif.currentY)
                local frameTween = TweenService:Create(
                    frame,
                    TweenInfo.new(NOTIFY_FADE_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                    {Position = targetPos, BackgroundTransparency = 1}
                )
                local labelTween = TweenService:Create(
                    label,
                    TweenInfo.new(NOTIFY_FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {TextTransparency = 1}
                )
                frameTween:Play()
                labelTween:Play()
                if icon then
                    TweenService:Create(
                        icon,
                        TweenInfo.new(NOTIFY_FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                        {TextTransparency = 1}
                    ):Play()
                end
                frameTween.Completed:Once(function()
                    if frame and frame.Parent then frame:Destroy() end
                end)
            end
            for i, existing in ipairs(activeNotifies) do
                if existing == notif then
                    table.remove(activeNotifies, i)
                    break
                end
            end
            updateNotificationPositions(true)
        end

        function showNotification(text, iconType)
            iconType = iconType or "info"
            createNotifyGui()
            while #activeNotifies >= MAX_NOTIFICATIONS do
                local oldest = activeNotifies[1]
                if oldest then fadeOutAndRemove(oldest) else break end
            end
            local frame = Instance.new("Frame")
            frame.Name = "PillNotification"
            frame.Parent = notifyContainer
            frame.Size = UDim2.new(1, 0, 0, NOTIFY_HEIGHT)
            frame.Position = UDim2.new(0, 60, 1, -NOTIFY_HEIGHT)
            frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            frame.BackgroundTransparency = 1
            frame.BorderSizePixel = 0
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 16)
            corner.Parent = frame
            local icon = Instance.new("TextLabel")
            icon.Name = "Icon"
            icon.Parent = frame
            icon.Size = UDim2.new(0, 24, 0, 24)
            icon.Position = UDim2.new(0, 8, 0.5, -12)
            icon.BackgroundTransparency = 1
            icon.Font = Enum.Font.SourceSansBold
            icon.TextSize = 18
            icon.TextColor3 = ICON_COLORS[iconType] or ICON_COLORS.info
            icon.Text = "✓"
            icon.TextTransparency = 1
            local label = Instance.new("TextLabel")
            label.Name = "Text"
            label.Parent = frame
            label.Size = UDim2.new(1, -44, 1, 0)
            label.Position = UDim2.new(0, 36, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = NOTIFY_FONT
            label.TextSize = NOTIFY_TEXT_SIZE
            label.TextColor3 = Color3.fromRGB(245, 245, 245)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.Text = text
            label.TextTransparency = 1
            local notif = { frame = frame, label = label, icon = icon, currentY = -NOTIFY_HEIGHT, removing = false }
            table.insert(activeNotifies, notif)
            updateNotificationPositions(false)
            local finalPos = UDim2.new(0, 0, 1, notif.currentY)
            local slideIn = TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = finalPos, BackgroundTransparency = NOTIFY_BG_TRANSPARENCY})
            local textIn = TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
            local iconIn = TweenService:Create(icon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
            slideIn:Play()
            textIn:Play()
            iconIn:Play()
            task.delay(NOTIFY_DURATION, function()
                if notif and not notif.removing then fadeOutAndRemove(notif) end
            end)
        end

        function showHitNotification(text)
            if not Settings.Ragebot.HitDetection.Notify then return end
            showNotification(text, "hit")
        end

        local bodyPartNames = {
            Head = "Head", UpperTorso = "Torso", LowerTorso = "Torso",
            LeftUpperArm = "Left Arm", LeftLowerArm = "Left Arm", LeftHand = "Left Hand",
            RightUpperArm = "Right Arm", RightLowerArm = "Right Arm", RightHand = "Right Hand",
            LeftUpperLeg = "Left Leg", LeftLowerLeg = "Left Leg", LeftFoot = "Left Foot",
            RightUpperLeg = "Right Leg", RightLowerLeg = "Right Leg", RightFoot = "Right Foot",
            HumanoidRootPart = "Body",
        }

        local function getBodyPartName(character, hitPos)
            if not character or not hitPos then return "Body" end
            local closestPart = nil
            local closestDist = math.huge
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local dist = (part.Position - hitPos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPart = part
                    end
                end
            end
            if closestPart then
                return bodyPartNames[closestPart.Name] or closestPart.Name
            end
            return "Body"
        end

        local function onHitDetected(targetChar, hitPos)
            if not targetChar or not isValidCharacter(targetChar) then return end
            local now = tick()
            local lastTime = hitEffectCooldowns[targetChar]
            if lastTime and (now - lastTime) < 0.01 then return end
            hitEffectCooldowns[targetChar] = now
            local player = getPlayerFromCharacter(targetChar)
            if not player then return end
            local hum = targetChar:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local beforeHealth = hum.Health
            local bodyPart = getBodyPartName(targetChar, hitPos)
            task.delay(0.02, function()
                if not targetChar.Parent then return end
                local newHum = targetChar:FindFirstChildOfClass("Humanoid")
                if not newHum then return end
                local damage = beforeHealth - newHum.Health
                if damage > 0 then
                    playHitSoundGlobal()
                    showHitNotification(string.format("Hit %s's %s for -%d HP", player.Name, bodyPart, math.floor(damage)))
                end
            end)
        end

        local bulletRayEntry = nil
        function setupBulletRay()
            if bulletRayEntry then return end
            local conn = workspace.DescendantAdded:Connect(function(desc)
                if desc.Name ~= "BULLET_RAYS" then return end
                if desc:GetAttribute("OwnerCharacter") ~= LocalPlayer.Name then return end
                task.wait(0.01)
                if Settings.Ragebot.HitDetection.Enabled then
                    local gunBeam = desc:FindFirstChild("GunBeam") or desc:FindFirstChild("NewGunBeam")
                    if gunBeam then
                        local att1 = gunBeam.Attachment1
                        if att1 then
                            local hitPos = att1.WorldPosition
                            local targetChar = nil
                            local closestDist = 20
                            for _, player in ipairs(Players:GetPlayers()) do
                                if player == LocalPlayer then continue end
                                local char = player.Character
                                if not char then continue end
                                local root = char:FindFirstChild("HumanoidRootPart")
                                if not isValidPart(root) then continue end
                                for _, part in pairs(char:GetDescendants()) do
                                    if part:IsA("BasePart") and (part.Position - hitPos).Magnitude < closestDist then
                                        closestDist = (part.Position - hitPos).Magnitude
                                        targetChar = char
                                    end
                                end
                            end
                            if targetChar then
                                onHitDetected(targetChar, hitPos)
                            end
                        end
                    end
                end
                if Settings.Visuals.BulletTracers.Enabled then
                    local gunBeam = desc:FindFirstChild("GunBeam") or desc:FindFirstChild("NewGunBeam")
                    if gunBeam then
                        gunBeam.Texture = Settings.Visuals.BulletTracers.Texture == "Normal" and "rbxassetid://7151778302" or "rbxassetid://9150635648"
                        gunBeam.LightEmission = Settings.Visuals.BulletTracers.GlowIntensity or Settings.Visuals.BulletTracers.LightEmission
                        gunBeam.Segments = Settings.Visuals.BulletTracers.Segments
                        gunBeam.LightInfluence = 0
                        gunBeam.TextureSpeed = Settings.Visuals.BulletTracers.Speed
                        gunBeam.Brightness = Settings.Visuals.BulletTracers.Brightness
                        gunBeam.Color = ColorSequence.new(Settings.Visuals.BulletTracers.Color)
                        gunBeam.Width0 = Settings.Visuals.BulletTracers.Width
                        gunBeam.Width1 = Settings.Visuals.BulletTracers.Width
                        gunBeam.Transparency = NumberSequence.new(0)
                        local originalWidth = Settings.Visuals.BulletTracers.Width
                        local pulse = TweenService:Create(gunBeam, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Width0 = originalWidth * 2, Width1 = originalWidth * 2})
                        pulse:Play()
                        local revert = TweenService:Create(gunBeam, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Width0 = originalWidth, Width1 = originalWidth})
                        pulse.Completed:Connect(function() revert:Play() end)
                        if Settings.Visuals.BulletTracers.RayTracing then
                            local start = desc.Position
                            local endp = start
                            local att1 = desc:FindFirstChild("Attachment1")
                            if att1 then endp = desc.CFrame:PointToWorldSpace(att1.Position) end
                            local tracer = Instance.new("Part")
                            tracer.Shape = Enum.PartType.Cylinder
                            tracer.Size = Vector3.new(0.05, 0.05, (endp - start).Magnitude)
                            tracer.Anchored = true; tracer.CanCollide = false
                            tracer.Material = Enum.Material.Neon
                            tracer.Color = Settings.Visuals.BulletTracers.Color
                            tracer.LightEmission = Settings.Visuals.BulletTracers.GlowIntensity or 5
                            tracer.CFrame = CFrame.lookAt(start, endp) * CFrame.new(0,0,-(endp-start).Magnitude/2)
                            tracer.Parent = workspace
                            Debris:AddItem(tracer, 0.5)
                            local fadeTween = TweenService:Create(tracer, TweenInfo.new(0.5), {Transparency = 1})
                            fadeTween:Play()
                            fadeTween.Completed:Connect(function() tracer:Destroy() end)
                        end
                    end
                end
            end)
            bulletRayEntry = ConnectionManager:Add("BulletRay", conn)
        end

        function updateESP()
            if not Settings.Visuals.ESP.Enabled then
                for _, obj in pairs(espObjects) do
                    pcall(function() if obj.highlight then obj.highlight:Destroy() end; if obj.billboard then obj.billboard:Destroy() end end)
                end
                espObjects = {}
                return
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                local char = player.Character
                if not isValidCharacter(char) then
                    if espObjects[player] then
                        pcall(function() if espObjects[player].highlight then espObjects[player].highlight:Destroy() end; if espObjects[player].billboard then espObjects[player].billboard:Destroy() end end)
                        espObjects[player] = nil
                    end
                    continue
                end
                local show = true
                if Settings.Visuals.ESP.TeamCheck and player.Team == LocalPlayer.Team then show = false end
                if show then
                    local obj = espObjects[player]
                    if not obj then
                        obj = {}
                        local h = Instance.new("Highlight")
                        h.Name = "ESP_Highlight"
                        h.Parent = char
                        h.Adornee = char
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.OutlineTransparency = 0
                        h.OutlineColor = Settings.Visuals.ESP.HighlightColor
                        local bill = Instance.new("BillboardGui")
                        bill.Name = "ESP_Billboard"
                        bill.Parent = char
                        bill.AlwaysOnTop = true
                        bill.Size = UDim2.new(0,200,0,30)
                        bill.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                        bill.StudsOffset = Vector3.new(0,2.5,0)
                        local label = Instance.new("TextLabel")
                        label.Name = "ESP_Label"
                        label.Parent = bill
                        label.BackgroundTransparency = 1
                        label.Size = UDim2.new(1,0,1,0)
                        label.Font = Enum.Font.SourceSans
                        label.TextSize = 14
                        label.TextColor3 = Settings.Visuals.ESP.HighlightColor
                        label.TextStrokeTransparency = 0.5
                        label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
                        obj.highlight = h; obj.billboard = bill; obj.label = label
                        espObjects[player] = obj
                    end
                    obj.highlight.FillColor = Settings.Visuals.ESP.HighlightColor
                    obj.highlight.FillTransparency = Settings.Visuals.ESP.HighlightTransparency
                    obj.highlight.OutlineColor = Settings.Visuals.ESP.HighlightColor
                    obj.highlight.Enabled = true
                    obj.label.Text = player.DisplayName
                    obj.label.TextColor3 = Settings.Visuals.ESP.HighlightColor
                    obj.billboard.Enabled = true
                else
                    if espObjects[player] then
                        pcall(function() if espObjects[player].highlight then espObjects[player].highlight:Destroy() end; if espObjects[player].billboard then espObjects[player].billboard:Destroy() end end)
                        espObjects[player] = nil
                    end
                end
            end
        end

        function updateSelfChams()
            if not Settings.Visuals.SelfChams.Enabled then
                if selfHighlight then selfHighlight:Destroy(); selfHighlight = nil end
                return
            end
            local char = LocalPlayer.Character
            if not char then return end
            local material = Enum.Material[Settings.Visuals.SelfChams.Material] or Enum.Material.ForceField
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Material = material
                    part.Color = Settings.Visuals.SelfChams.Color
                    part.Transparency = Settings.Visuals.SelfChams.Transparency
                end
            end
            if not selfHighlight then
                selfHighlight = Instance.new("Highlight")
                selfHighlight.Name = "SelfHighlight"
                selfHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
            selfHighlight.Parent = char
            selfHighlight.Adornee = char
            selfHighlight.FillTransparency = 1
            selfHighlight.OutlineColor = Settings.Visuals.SelfChams.OutlineColor
            selfHighlight.OutlineTransparency = Settings.Visuals.SelfChams.OutlineTransparency
            selfHighlight.Enabled = true
        end

        function updateTargetCircle()
            if not targetCircle then
                targetCircle = Instance.new("Part")
                targetCircle.Shape = Enum.PartType.Cylinder
                targetCircle.Anchored = true
                targetCircle.CanCollide = false
                targetCircle.Material = Enum.Material.Neon
                targetCircle.Transparency = 1
                targetCircle.Parent = workspace
                targetCircle.Name = "TargetCircle"
            end
            if TargetState.Locked and TargetState.Character then
                local root = TargetState.Character:FindFirstChild("HumanoidRootPart")
                if isValidPart(root) then
                    targetCircle.Transparency = 0
                    targetCircle.CFrame = root.CFrame
                    targetCircle.Size = Vector3.new(2, 0.1, 2)
                else
                    targetCircle.Transparency = 1
                end
            else
                targetCircle.Transparency = 1
            end
        end

        if Capabilities.Drawing then
            pcall(function()
                local ok1, circle = pcall(function() return Drawing.new("Circle") end)
                if ok1 and circle then
                    fovCircle = circle
                    fovCircle.Thickness = Settings.Ragebot.FOVThickness
                    fovCircle.Filled = false
                    fovCircle.Transparency = Settings.Ragebot.FOVTransparency
                    fovCircle.Visible = false
                    fovCircle.Color = Settings.Ragebot.FOVColor
                    fovCircle.Radius = Settings.Ragebot.FOVRadius
                end
                local ok2, line = pcall(function() return Drawing.new("Line") end)
                if ok2 and line then
                    lockTracerLine = line
                    lockTracerLine.Thickness = 1.5
                    lockTracerLine.Transparency = 0.5
                    lockTracerLine.Visible = false
                    lockTracerLine.Color = Settings.Ragebot.FOVColor
                end
            end)
        end

        function updateFOVCircle()
            if not Capabilities.Drawing or not fovCircle then return end
            if Settings.Ragebot.ShowFOV then
                local center = getFOVCenter()
                fovCircle.Position = center
                fovCircle.Radius = Settings.Ragebot.FOVRadius
                fovCircle.Color = Settings.Ragebot.FOVColor
                fovCircle.Thickness = Settings.Ragebot.FOVThickness
                fovCircle.Transparency = Settings.Ragebot.FOVTransparency
                fovCircle.Visible = true
            else
                fovCircle.Visible = false
            end
        end

        function updateLockTracer()
            if not Capabilities.Drawing or not lockTracerLine then return end
            if TargetState.Locked and TargetState.Character and Settings.Ragebot.LockTracer then
                local part = resolveAimPart(TargetState.Character)
                if isValidPart(part) then
                    local screen = getScreenPosition(part.Position)
                    local cam = getCamera()
                    if cam then
                        local pos3D = cam:WorldToScreenPoint(part.Position)
                        if pos3D.Z > 0 then
                            local mp = UserInputService:GetMouseLocation()
                            lockTracerLine.From = Vector2.new(mp.X, mp.Y)
                            lockTracerLine.To = screen
                            lockTracerLine.Color = Settings.Ragebot.FOVColor
                            lockTracerLine.Visible = true
                        else
                            lockTracerLine.Visible = false
                        end
                    else
                        lockTracerLine.Visible = false
                    end
                else
                    lockTracerLine.Visible = false
                end
            else
                lockTracerLine.Visible = false
            end
        end

        local RuntimeState = { ambienceToggled = false, originalLighting = nil, normalLighting = nil }

        function toggleAmbience()
            if Settings.Graphics.Ambience.Enabled then
                local a = Settings.Graphics.Ambience
                Lighting.Ambient = a.Ambient
                Lighting.OutdoorAmbient = a.OutdoorAmbient
                Lighting.Brightness = a.Brightness
                Lighting.ColorShift_Bottom = a.ColorShiftBottom
                Lighting.ColorShift_Top = a.ColorShiftTop
                Lighting.FogColor = a.FogColor
                Lighting.FogStart = a.FogStart
                Lighting.FogEnd = a.FogEnd
                Lighting.TimeOfDay = a.TimeOfDay
                local sky = Lighting:FindFirstChildOfClass("Sky")
                if not sky then sky = Instance.new("Sky"); sky.Parent = Lighting end
                local id = a.SkyboxID
                sky.SkyboxBk = id; sky.SkyboxDn = id; sky.SkyboxFt = id
                sky.SkyboxLf = id; sky.SkyboxRt = id; sky.SkyboxUp = id
                RuntimeState.ambienceToggled = true
            else
                if RuntimeState.originalLighting then
                    Lighting.Ambient = RuntimeState.originalLighting.Ambient
                    Lighting.OutdoorAmbient = RuntimeState.originalLighting.OutdoorAmbient
                    Lighting.Brightness = RuntimeState.originalLighting.Brightness
                    Lighting.ColorShift_Bottom = RuntimeState.originalLighting.ColorShiftBottom
                    Lighting.ColorShift_Top = RuntimeState.originalLighting.ColorShiftTop
                    Lighting.FogColor = RuntimeState.originalLighting.FogColor
                    Lighting.FogStart = RuntimeState.originalLighting.FogStart
                    Lighting.FogEnd = RuntimeState.originalLighting.FogEnd
                    Lighting.TimeOfDay = RuntimeState.originalLighting.TimeOfDay
                end
                RuntimeState.ambienceToggled = false
            end
        end

        local ambienceClockEntry = nil
        function startAmbienceClockLock()
            if ambienceClockEntry then return end
            local conn = RunService.Heartbeat:Connect(function()
                if RuntimeState.ambienceToggled and Settings.Graphics.Ambience.ClockTimeOverride then
                    Lighting.ClockTime = Settings.Graphics.Ambience.ClockTimeOverride
                end
            end)
            ambienceClockEntry = ConnectionManager:Add("AmbienceClock", conn)
        end

        local noRecoilActive = false
        function applyNoRecoil()
            if Settings.Ragebot.NoRecoil then
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        local recoil = tool:FindFirstChild("Recoil")
                        if recoil and recoil:IsA("NumberValue") then
                            recoil.Value = 0
                        end
                    end
                end
            end
        end

        local function getCurrentWeaponRange()
            local char = LocalPlayer.Character
            if not char then return 200 end
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return 200 end
            local range = tool:FindFirstChild("Range")
            if range and range:IsA("NumberValue") then
                return range.Value
            end
            return 200
        end

        local KNOWN_GUNS = {
            "[AK47] - $2532", "[AR] - $1126", "[AUG] - $2195", "[Deagle] - $11255",
            "[Double-Barrel SG] - $1519", "[Drum-Shotgun] - $1238", "[DrumGun] - $3377",
            "[Flamethrower] - $10130", "[Flintlock] - $1463", "[Glock] - $338",
            "[GrenadeLauncher] - $11255", "[LMG] - $4221", "[P90] - $1126",
            "[RPG] - $22510", "[Revolver] - $1463", "[Rifle] - $1745",
            "[SMG] - $844", "[Shotgun] - $1407", "[SilencerAR] - $1407",
            "[TacticalShotgun] - $1970", "[Taser] - $1126",
        }

        local function getRealGuns()
            local shop = workspace.Ignored and workspace.Ignored.Shop
            if not shop then return {} end
            local found = {}
            for _, m in ipairs(shop:GetChildren()) do
                if m:IsA("Model") and KNOWN_GUNS[m.Name] and m:FindFirstChild("ClickDetector") then
                    table.insert(found, m.Name)
                end
            end
            table.sort(found)
            return found
        end

        local function buyItem(itemName)
            if not itemName or itemName == "" then return false end
            local shop = workspace.Ignored and workspace.Ignored.Shop
            if not shop then return false end
            local model = shop:FindFirstChild(itemName)
            if not model then return false end
            local cd = model:FindFirstChildOfClass("ClickDetector")
            if not cd then return false end
            local char = LocalPlayer.Character
            if not char then return false end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not isValidPart(root) then return false end
            local oldPos = root.CFrame
            local targetPos = model:FindFirstChild("Head") and model.Head.Position or model:GetBoundingBox().Position
            root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
            task.wait(0.2)
            if Capabilities.fireclickdetector then
                fireclickdetector(cd)
            else
                cd:Click()
            end
            task.wait(0.1)
            root.CFrame = oldPos
            return true
        end

        local teleportLocations = {
            ["Admin Base"] = CFrame.new(-874.9,-32.6,-525.2),
            ["High Medium Armor"] = CFrame.new(-934.7,-28.5,566.0),
            ["Food"] = CFrame.new(-788.4,-39.6,-935.3),
            ["Gas Station"] = CFrame.new(608.6,65.3,-267.6),
            ["School"] = CFrame.new(-581.8,68.5,331.0),
            ["Military"] = CFrame.new(92.6,122.7,-860.1),
            ["Ufo"] = CFrame.new(65.2,139.0,-691.8),
            ["Bank"] = CFrame.new(-374.5,102.1,-440.2),
            ["Gym Top"] = CFrame.new(-76.2,56.7,-629.9),
            ["Casino"] = CFrame.new(-1049.0,110.3,-154.6),
            ["Uphill"] = CFrame.new(485.7,112.5,-644.3),
            ["Revolver"] = CFrame.new(-659.1,110.7,-158.2),
            ["Flank"] = CFrame.new(376.7,130.7,-245.6),
            ["PlayGround"] = CFrame.new(-260.8,126.4,-877.8),
        }

        function teleportToLocation(locName)
            local cf = teleportLocations[locName]
            if cf and LocalPlayer.Character then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if isValidPart(root) then root.CFrame = cf end
            end
        end

        function forceReset()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = 0 end
            end
        end

        function rejoinServer()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end

        local voidHideCFrame = nil
        local noClipOriginalStates = {}

        function applyPlayerMods()
            if not CharacterState.humanoid or not CharacterState.humanoid.Parent then return end
            local hum = CharacterState.humanoid

            if Settings.Player.WalkSpeedEnabled then
                hum.WalkSpeed = Settings.Player.WalkSpeed
            else
                hum.WalkSpeed = CharacterState.walkSpeed or 16
            end

            local char = LocalPlayer.Character
            if char then
                if Settings.Player.NoClipEnabled then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if not noClipOriginalStates[part] then
                                noClipOriginalStates[part] = part.CanCollide
                            end
                            part.CanCollide = false
                        end
                    end
                else
                    for part, orig in pairs(noClipOriginalStates) do
                        if part and part.Parent then
                            part.CanCollide = orig
                        end
                    end
                    noClipOriginalStates = {}
                end
            end

            if Settings.Ragebot.AntiAim.VoidHide then
                if not voidHideCFrame and CharacterState.rootPart then
                    voidHideCFrame = CharacterState.rootPart.CFrame
                    CharacterState.rootPart.CFrame = CFrame.new(0, -1000, 0)
                end
            else
                if voidHideCFrame and CharacterState.rootPart then
                    CharacterState.rootPart.CFrame = voidHideCFrame
                    voidHideCFrame = nil
                end
            end

            if Settings.Player.AntiVoid and CharacterState.rootPart then
                if CharacterState.rootPart.Position.Y < -50 then
                    CharacterState.rootPart.CFrame = CFrame.new(0, 50, 0)
                end
            end

            if Settings.Visuals.NoFlash and Settings.Visuals.NoFlash.Enabled then
                local cam = getCamera()
                if cam then
                    local flash = cam:FindFirstChild("FlashEffect")
                    if flash then flash.Enabled = false end
                    local damage = cam:FindFirstChild("DamageEffect")
                    if damage then damage.Enabled = false end
                end
            end

            if Settings.Ragebot.NoRecoil then
                applyNoRecoil()
            end
        end

        function checkAutoReload()
            if not Settings.Ragebot.AutoReload then return end
            local char = LocalPlayer.Character
            if not char then return end
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
            local ammo = tool:FindFirstChild("Ammo")
            if ammo and ammo.Value <= 0 and MainEvent then
                task.wait(math.random(50, 300) / 1000)
                MainEvent:FireServer("Reload", tool)
            end
        end

        function antiStompCheck()
            if not Settings.Ragebot.AntiStomp then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local be = char:FindFirstChild("BodyEffects")
            local KO = be and be:FindFirstChild("K.O") and be["K.O"].Value
            local grabbed = char:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
            if KO or grabbed then
                hum.PlatformStand = true
                hum.WalkSpeed = 0
                hum.JumpHeight = 0
                hum.Health = 0
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum.MaxHealth = hum.Health
                if be then be:ClearAllChildren() end
                if MainEvent then MainEvent:FireServer("Respawn") end
            end
        end

        local lastNetworkAntiAction = 0
        function networkAntiCheck()
            if not Settings.Player.NetworkAnti.Enabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            local be = char:FindFirstChild("BodyEffects")
            local KO = be and be:FindFirstChild("K.O") and be["K.O"].Value
            local grabbed = char:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
            local beingStomped = false
            if be and be:FindFirstChild("Stomp") then
                beingStomped = be.Stomp.Value
            end

            if (KO or grabbed or beingStomped) and (tick() - lastNetworkAntiAction > 2) then
                lastNetworkAntiAction = tick()
                if Library and Library.Notify then
                    Library:Notify("Network Anti triggered!", 3)
                end
                if hum.Health > 0 then
                    hum.Health = 0
                end
                local root = char:FindFirstChild("HumanoidRootPart")
                if isValidPart(root) then
                    root.CFrame = CFrame.new(0, 100, 0)
                end
                task.wait(0.5)
                if MainEvent then MainEvent:FireServer("Respawn") end
            end
        end

        local statusText = "Safe"
        local function setWatermarkStatus(newStatus)
            if newStatus ~= statusText then
                statusText = newStatus
            end
        end

        local isShooting = false
        local isReloading = false
        local shootTimer = 0
        local reloadTimer = 0

        function updateWatermark()
            if not Settings.Visuals.Watermark.Enabled then
                if watermarkText then watermarkText:Remove(); watermarkText = nil end
                if watermarkStatus then watermarkStatus:Remove(); watermarkStatus = nil end
                return
            end
            if not Capabilities.Drawing then return end

            if not watermarkText then
                watermarkText = Drawing.new("Text")
                watermarkText.Text = "tapped.cc"
                watermarkText.Font = 3
                watermarkText.Outline = true
                watermarkText.OutlineColor = Color3.fromRGB(0,0,0)
                watermarkText.Visible = true
            end
            if not watermarkStatus then
                watermarkStatus = Drawing.new("Text")
                watermarkStatus.Text = statusText
                watermarkStatus.Font = 2
                watermarkStatus.Outline = true
                watermarkStatus.OutlineColor = Color3.fromRGB(0,0,0)
                watermarkStatus.Visible = true
            end

            local cursor = UserInputService:GetMouseLocation()
            local mainSize = Settings.Visuals.Watermark.Size
            local statusSize = Settings.Visuals.Watermark.StatusSize or mainSize * 0.8
            local offsetX = 16
            local offsetY = 8

            watermarkText.Color = Settings.Visuals.Watermark.Color
            watermarkText.Size = mainSize
            local mainBounds = watermarkText.TextBounds
            watermarkText.Position = Vector2.new(cursor.X + offsetX, cursor.Y + offsetY)

            watermarkStatus.Color = Settings.Visuals.Watermark.Color
            watermarkStatus.Size = statusSize
            local statusBounds = watermarkStatus.TextBounds
            local statusX = cursor.X + offsetX + (mainBounds.X - statusBounds.X) / 2
            local statusY = cursor.Y + offsetY + mainBounds.Y + 2
            watermarkStatus.Position = Vector2.new(statusX, statusY)

            if watermarkStatus.Text ~= statusText then
                watermarkStatus.Text = statusText
            end
        end

        local function checkShootingStatus()
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        local ammo = tool:FindFirstChild("Ammo")
                        if not ammo or ammo.Value > 0 then
                            isShooting = true
                            shootTimer = tick()
                            setWatermarkStatus("Shooting")
                        end
                    end
                end
            end
            if isShooting and (tick() - shootTimer > 0.5) then
                isShooting = false
                if not isReloading then
                    setWatermarkStatus("Safe")
                end
            end
        end

        local function checkReloadingStatus()
            if UserInputService:IsKeyDown(Enum.KeyCode.R) and not isReloading then
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        local ammo = tool:FindFirstChild("Ammo")
                        if ammo and ammo:IsA("IntValue") then
                            local maxAmmo = ammo:GetAttribute("MaxAmmo") or ammo.Parent:FindFirstChild("MaxAmmo") or ammo:FindFirstChild("MaxAmmo")
                            if maxAmmo and maxAmmo:IsA("NumberValue") then
                                if ammo.Value > 0 and ammo.Value < maxAmmo.Value then
                                    isReloading = true
                                    reloadTimer = tick()
                                    setWatermarkStatus("Reloading")
                                end
                            end
                        end
                    end
                end
            end
            if isReloading and (tick() - reloadTimer > 2.5) then
                isReloading = false
                if not isShooting then
                    setWatermarkStatus("Safe")
                end
            end
        end

        local orbitAngle = 0
        local lastAutoSelectTime = 0

        function safeCall(feature, func)
            local ok, err = pcall(func)
            if not ok then
                warn("[tapped.cc][MainLoop] " .. feature .. " ERROR: " .. tostring(err))
            end
        end

        local function cleanVelocityCache()
            for char, _ in pairs(targetVelocity) do
                if not char or not char.Parent or not isValidCharacter(char) then
                    targetVelocity[char] = nil
                    velocityHistory[char] = nil
                end
            end
        end

        function mainLoop(dt)
            safeCall("PlayerMods", applyPlayerMods)
            safeCall("AutoReload", checkAutoReload)
            safeCall("SelfChams", updateSelfChams)
            safeCall("ESP", updateESP)
            safeCall("TargetCircle", updateTargetCircle)
            safeCall("AntiStomp", antiStompCheck)
            safeCall("NetworkAnti", networkAntiCheck)
            safeCall("FOV", updateFOVCircle)
            safeCall("LockTracer", updateLockTracer)
            safeCall("CameraFOV", function()
                if getCamera() then getCamera().FieldOfView = Settings.Visuals.CameraFOV end
            end)
            safeCall("LowGraphics", function()
                if Settings.Graphics.LowGraphics then Lighting.GlobalShadows = false else Lighting.GlobalShadows = true end
            end)
            safeCall("AutoRespawn", function()
                if Settings.Player.AutoRespawn and CharacterState.humanoid and CharacterState.humanoid.Health <= 0 then
                    task.wait(Settings.Player.AutoRespawnDelay)
                    if CharacterState.humanoid and CharacterState.humanoid.Health <= 0 then
                        if MainEvent then MainEvent:FireServer("Respawn") end
                    end
                end
            end)
            safeCall("Watermark", updateWatermark)
            safeCall("ShootingStatus", checkShootingStatus)
            safeCall("ReloadingStatus", checkReloadingStatus)

            safeCall("VelocityTracking", function()
                cleanVelocityCache()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player == LocalPlayer then continue end
                    local char = player.Character
                    if char and isValidCharacter(char) then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if isValidPart(root) then
                            local vel = root.AssemblyLinearVelocity
                            if not targetVelocity[char] then targetVelocity[char] = {} end
                            targetVelocity[char].velocity = vel
                            targetVelocity[char].lastUpdate = tick()
                        end
                    end
                end
            end)

            safeCall("TargetPersistence", function()
                if TargetState.Locked and TargetState.Player then
                    local player = TargetState.Player
                    local char = player.Character
                    if char and isValidCharacter(char) and char ~= TargetState.Character then
                        TargetState.Character = char
                        if Settings.Ragebot.Spectate then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then
                                local cam = getCamera()
                                if cam then
                                    cam.CameraSubject = hum
                                    cam.CameraType = Enum.CameraType.Custom
                                end
                            end
                        end
                    end
                end
            end)

            safeCall("Targeting", function()
                local char = LocalPlayer.Character

                if Settings.Ragebot.AutoSelect and (tick() - lastAutoSelectTime > 0.1) then
                    lastAutoSelectTime = tick()
                    local best = findBestTarget()
                    if best then
                        if not TargetState.Locked or TargetState.Character ~= best then
                            lockTarget(best)
                        end
                    end
                end

                if TargetState.Locked and TargetState.Player then
                    local player = TargetState.Player
                    local target = player.Character
                    if not target or not isValidCharacter(target) then
                        return
                    end
                    TargetState.Character = target

                    if hasProtection(target) then
                        -- do nothing, won't shoot
                    else
                        if Settings.Ragebot.TargetStrafe.Enabled and char then
                            local root = char:FindFirstChild("HumanoidRootPart")
                            local tRoot = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                            if isValidPart(root) and isValidPart(tRoot) then
                                orbitAngle = orbitAngle + dt * Settings.Ragebot.TargetStrafe.Speed * 2 * math.pi
                                local radius = Settings.Ragebot.TargetStrafe.Distance
                                local height = Settings.Ragebot.TargetStrafe.Height
                                if Settings.Ragebot.Unhittable then
                                    radius = radius + math.random(-3, 3)
                                    height = height + math.random(-2, 2)
                                    orbitAngle = orbitAngle + math.random(-0.5, 0.5) * dt
                                end
                                local desired = tRoot.Position + Vector3.new(math.sin(orbitAngle)*radius, height, math.cos(orbitAngle)*radius)
                                local cf = CFrame.new(desired, tRoot.Position)
                                root.CFrame = cf
                            end
                        end

                        if Settings.Ragebot.AutoShoot and isValidLockedTarget(target) then
                            local tHum = target:FindFirstChildOfClass("Humanoid")
                            if tHum and tHum.Health > Settings.Ragebot.StopAutoShootBelowHealth then
                                local part = resolveAimPart(target)
                                if isValidPart(part) then
                                    local can = true
                                    if Settings.Ragebot.AutoShootVisibilityCheck then can = isPartVisible(part) end
                                    if can then
                                        local weaponRange = getCurrentWeaponRange()
                                        if weaponRange and char and char:FindFirstChild("HumanoidRootPart") and (part.Position - char.HumanoidRootPart.Position).Magnitude > weaponRange then
                                            can = false
                                        end
                                    end
                                    if can and not hasProtection(target) then
                                        local tool = char:FindFirstChildOfClass("Tool")
                                        if tool then
                                            local ammo = tool:FindFirstChild("Ammo")
                                            if not ammo or ammo.Value > 0 then
                                                tool:Activate()
                                                isShooting = true
                                                shootTimer = tick()
                                                setWatermarkStatus("Shooting")
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if Settings.Ragebot.AutoStomp then
                        local tHum = target:FindFirstChildOfClass("Humanoid")
                        local be = target:FindFirstChild("BodyEffects")
                        local KO = be and be:FindFirstChild("K.O") and be["K.O"].Value
                        local targetHealth = tHum and tHum.Health or 0
                        if (targetHealth <= 10) or KO then
                            local targetRoot = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso") or target:FindFirstChild("Head")
                            if isValidPart(targetRoot) and char and char:FindFirstChild("HumanoidRootPart") then
                                local localRoot = char:FindFirstChild("HumanoidRootPart")
                                localRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 2, 0)
                                if MainEvent then
                                    MainEvent:FireServer("Stomp")
                                end
                            end
                        end
                    end
                end
            end)
        end

        local charAddedEntry = nil
        function setupCharacterLifecycle()
            if charAddedEntry then ConnectionManager:Remove(charAddedEntry); charAddedEntry = nil end
            local conn = LocalPlayer.CharacterAdded:Connect(function(newChar)
                refreshCharacter(newChar)
                if Settings.Player.Fly.Enabled then startFly() end
                if Settings.Ragebot.SilentReload then setSilentReloadEnabled(true) end
                if Settings.Ragebot.HitboxExpander.Enabled then setHitboxExpanderEnabled(true) end
                if Settings.Ragebot.RapidFire then applyRapidFire() end
                if TargetState.Locked and TargetState.Player then
                    local newTargetChar = TargetState.Player.Character
                    if newTargetChar and isValidCharacter(newTargetChar) then
                        TargetState.Character = newTargetChar
                        if Settings.Ragebot.Spectate then
                            local hum = newTargetChar:FindFirstChildOfClass("Humanoid")
                            if hum then
                                local cam = getCamera()
                                if cam then
                                    cam.CameraSubject = hum
                                    cam.CameraType = Enum.CameraType.Custom
                                end
                            end
                        end
                    end
                else
                    local hum = newChar:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local cam = getCamera()
                        if cam then
                            cam.CameraSubject = hum
                            cam.CameraType = Enum.CameraType.Custom
                        end
                    end
                end
            end)
            charAddedEntry = ConnectionManager:Add("CharacterLifecycle", conn)
        end

        local Tabs = {
            Combat = Window:AddTab("Combat"),
            Visuals = Window:AddTab("Visuals"),
            Player = Window:AddTab("Player"),
            Graphics = Window:AddTab("Graphics"),
            Misc = Window:AddTab("Misc"),
            Settings = Window:AddTab("Settings"),
        }

        local function createGroupbox(tab, title, side)
            if side == "right" then
                return tab:AddRightGroupbox(title)
            else
                return tab:AddLeftGroupbox(title)
            end
        end

        local function createToggle(group, id, config, callback)
            if not group then return end
            return group:AddToggle(id, {
                Text = config.Text,
                Default = config.Default,
                Tooltip = config.Tooltip,
                Callback = function(v)
                    callback(v)
                end
            })
        end

        local function createSlider(group, id, config, callback)
            if not group then return end
            group:AddSlider(id, {
                Text = config.Text,
                Default = config.Default,
                Min = config.Min,
                Max = config.Max,
                Rounding = config.Rounding or 0,
                Suffix = config.Suffix or "",
                Callback = function(v)
                    callback(v)
                end
            })
        end

        local function createDropdown(group, id, config, callback)
            if not group then return end
            local default = config.Default
            if type(default) == "string" then
                local idx = 1
                for i, v in ipairs(config.Values) do
                    if v == default then idx = i break end
                end
                default = idx
            end
            group:AddDropdown(id, {
                Values = config.Values,
                Default = default or 1,
                Multi = false,
                Text = config.Text,
                Tooltip = config.Tooltip,
                Callback = function(v)
                    callback(v)
                end
            })
        end

        local function createColorpicker(group, id, config, callback)
            if not group then return end
            group:AddLabel(config.Text or id):AddColorPicker(id, {
                Default = config.Default,
                Title = config.Text,
                Transparency = 0,
                Callback = function(v)
                    callback(v)
                end
            })
        end

        local function createButton(group, id, config)
            if not group then return end
            group:AddButton({
                Text = config.Text,
                Func = config.Callback,
                Tooltip = config.Tooltip
            })
        end

        local c = Tabs.Combat
        local aimGroup = createGroupbox(c, "Aim", "left")
        createToggle(aimGroup, "SilentAim", { Text = "Silent Aim", Default = false }, function(v) Settings.Ragebot.SilentAim = v end)
        createSlider(aimGroup, "Hitchance", { Text = "Hit Chance", Default = 100, Min = 0, Max = 100, Rounding = 1 }, function(v) Settings.Ragebot.Hitchance = v end)
        createDropdown(aimGroup, "AimPart", { Text = "Aim Part", Values = {"Head","HumanoidRootPart","Torso"}, Default = "HumanoidRootPart" }, function(v) Settings.Ragebot.AimPart = v end)
        createToggle(aimGroup, "TeamCheck", { Text = "Team Check", Default = false }, function(v) Settings.Ragebot.TeamCheck = v end)
        createDropdown(aimGroup, "PriorityMode", { Text = "Priority Mode", Values = {"FOV","Distance","Health"}, Default = "FOV" }, function(v) Settings.Ragebot.PriorityMode = v end)
        createToggle(aimGroup, "VisCheck", { Text = "Visibility Check", Default = false }, function(v) Settings.Ragebot.VisibilityCheck = v end)
        createToggle(aimGroup, "AutoSelect", { Text = "Auto Select", Default = false }, function(v) Settings.Ragebot.AutoSelect = v end)
        createToggle(aimGroup, "Resolver", { Text = "Resolver", Default = true }, function(v) Settings.Ragebot.Resolver = v end)
        createToggle(aimGroup, "Prediction", { Text = "Prediction", Default = false }, function(v) Settings.Ragebot.Prediction = v end)

        local fovGroup = createGroupbox(c, "FOV Circle", "right")
        createToggle(fovGroup, "ShowFOV", { Text = "Show FOV", Default = true }, function(v) Settings.Ragebot.ShowFOV = v end)
        createSlider(fovGroup, "FOVRadius", { Text = "Radius", Default = 200, Min = 50, Max = 500, Rounding = 1 }, function(v) Settings.Ragebot.FOVRadius = v end)
        createColorpicker(fovGroup, "FOVColor", { Text = "Color", Default = Color3.fromRGB(255,0,0) }, function(v) Settings.Ragebot.FOVColor = v end)
        createSlider(fovGroup, "FOVThickness", { Text = "Thickness", Default = 1.5, Min = 0.5, Max = 5, Rounding = 1 }, function(v) Settings.Ragebot.FOVThickness = v end)
        createSlider(fovGroup, "FOVTransparency", { Text = "Transparency", Default = 0.8, Min = 0, Max = 1, Rounding = 2 }, function(v) Settings.Ragebot.FOVTransparency = v end)

        local antiAimGroup = createGroupbox(c, "Anti-Aim", "right")
        createToggle(antiAimGroup, "VoidHide", { Text = "Void Hide", Default = false }, function(v) Settings.Ragebot.AntiAim.VoidHide = v end)

        local lockGroup = createGroupbox(c, "Lock & Spectate", "left")
        createDropdown(lockGroup, "LockKey", { Text = "Lock Key", Values = {"Q","E","R","F","LeftControl","LeftShift","None"}, Default = "Q" }, function(v) Settings.Ragebot.LockKey = v end)
        local spectateToggle = createToggle(lockGroup, "Spectate", { Text = "Spectate Target", Default = false }, function(v)
            Settings.Ragebot.Spectate = v
            applySpectateSetting()
        end)

        local targetStrafeGroup = createGroupbox(c, "Target Strafe", "right")
        local strafeToggle = createToggle(targetStrafeGroup, "TargetStrafe", { Text = "Enabled", Default = false }, function(v) Settings.Ragebot.TargetStrafe.Enabled = v end)
        strafeToggle:AddKeyPicker("TargetStrafeKey", { Default = "X", Mode = "Toggle", Text = "Target Strafe", SyncToggleState = true })
        createSlider(targetStrafeGroup, "StrafeSpeed", { Text = "Speed", Default = 1.5, Min = 0.1, Max = 20, Rounding = 1, Suffix = "x" }, function(v) Settings.Ragebot.TargetStrafe.Speed = v end)
        createSlider(targetStrafeGroup, "StrafeDist", { Text = "Distance", Default = 8, Min = 1, Max = 50, Rounding = 0, Suffix = " studs" }, function(v) Settings.Ragebot.TargetStrafe.Distance = v end)
        createSlider(targetStrafeGroup, "StrafeHeight", { Text = "Height", Default = 4, Min = 0, Max = 20, Rounding = 0, Suffix = " studs" }, function(v) Settings.Ragebot.TargetStrafe.Height = v end)
        createToggle(targetStrafeGroup, "Unhittable", { Text = "Unhittable", Default = false }, function(v) Settings.Ragebot.Unhittable = v end)

        local shootGroup = createGroupbox(c, "Shooting", "left")
        local autoShootToggle = createToggle(shootGroup, "AutoShoot", { Text = "Auto Shoot", Default = false }, function(v) Settings.Ragebot.AutoShoot = v end)
        autoShootToggle:AddKeyPicker("AutoShootKey", { Default = "None", Mode = "Toggle", Text = "Auto Shoot", SyncToggleState = true })
        createToggle(shootGroup, "AutoShootVisibilityCheck", { Text = "Auto Shoot Visibility", Default = false }, function(v) Settings.Ragebot.AutoShootVisibilityCheck = v end)
        createSlider(shootGroup, "StopHealth", { Text = "Stop Below Health", Default = 20, Min = 0, Max = 100, Rounding = 1 }, function(v) Settings.Ragebot.StopAutoShootBelowHealth = v end)
        local rapidFireToggle = createToggle(shootGroup, "RapidFire", { Text = "Rapid Fire", Default = false }, function(v) Settings.Ragebot.RapidFire = v; applyRapidFire() end)
        rapidFireToggle:AddKeyPicker("RapidFireKey", { Default = "None", Mode = "Toggle", Text = "Rapid Fire", SyncToggleState = true })
        createSlider(shootGroup, "RapidFireDelay", { Text = "Rapid Fire Delay", Default = 0.08, Min = 0.02, Max = 0.5, Rounding = 2 }, function(v) Settings.Ragebot.RapidFireDelay = v end)
        createToggle(shootGroup, "NoRecoil", { Text = "No Recoil", Default = false }, function(v) Settings.Ragebot.NoRecoil = v end)
        createToggle(shootGroup, "AutoReload", { Text = "Auto Reload", Default = false }, function(v) Settings.Ragebot.AutoReload = v end)
        createToggle(shootGroup, "SilentReload", { Text = "Silent Reload", Default = false }, function(v) setSilentReloadEnabled(v) end)

        local extraGroup = createGroupbox(c, "Extra Combat", "right")
        createToggle(extraGroup, "LockTracer", { Text = "Lock Tracer", Default = true }, function(v) Settings.Ragebot.LockTracer = v end)
        createToggle(extraGroup, "KnockedCheck", { Text = "Knocked Check", Default = true }, function(v) Settings.Ragebot.KnockedCheck = v end)
        createToggle(extraGroup, "GrabbedCheck", { Text = "Grabbed Check", Default = true }, function(v) Settings.Ragebot.GrabbedCheck = v end)
        createToggle(extraGroup, "NoGroundShots", { Text = "No Ground Shots", Default = true }, function(v) Settings.Ragebot.NoGroundShots = v end)

        local hitDetectGroup = createGroupbox(c, "Hit Detection", "right")
        createToggle(hitDetectGroup, "HitDetect", { Text = "Enabled", Default = false }, function(v) Settings.Ragebot.HitDetection.Enabled = v end)
        createToggle(hitDetectGroup, "HitDetectSound", { Text = "Sound", Default = true }, function(v) Settings.Ragebot.HitDetection.Sound = v end)
        createToggle(hitDetectGroup, "HitDetectNotify", { Text = "Notify", Default = true }, function(v) Settings.Ragebot.HitDetection.Notify = v end)

        local hitboxGroup = createGroupbox(c, "Hitbox Expander", "left")
        createToggle(hitboxGroup, "Hitbox", { Text = "Enabled", Default = false }, function(v) setHitboxExpanderEnabled(v) end)
        createSlider(hitboxGroup, "HitboxSize", { Text = "Size", Default = 16, Min = 2, Max = 30, Rounding = 1 }, function(v) Settings.Ragebot.HitboxExpander.Size = Vector3.new(v,v,v) end)
        createColorpicker(hitboxGroup, "HitboxColor", { Text = "Color", Default = Color3.fromRGB(0,0,0) }, function(v) Settings.Ragebot.HitboxExpander.Color = v end)
        createSlider(hitboxGroup, "HitboxTrans", { Text = "Transparency", Default = 0.8, Min = 0, Max = 1, Rounding = 2 }, function(v) Settings.Ragebot.HitboxExpander.Transparency = v end)
        createColorpicker(hitboxGroup, "HitboxOutlineColor", { Text = "Outline Color", Default = Color3.fromRGB(108,59,170) }, function(v) Settings.Ragebot.HitboxExpander.OutlineColor = v end)
        createSlider(hitboxGroup, "HitboxOutlineTrans", { Text = "Outline Trans.", Default = 0, Min = 0, Max = 1, Rounding = 2 }, function(v) Settings.Ragebot.HitboxExpander.OutlineTransparency = v end)

        local autoStompGroup = createGroupbox(c, "Auto Stomp", "right")
        local autoStompToggle = createToggle(autoStompGroup, "AutoStomp", { Text = "Auto Stomp", Default = false }, function(v) Settings.Ragebot.AutoStomp = v end)
        autoStompToggle:AddKeyPicker("AutoStompKey", { Default = "None", Mode = "Toggle", Text = "Auto Stomp", SyncToggleState = true })

        local vis = Tabs.Visuals
        local hitSoundGroup = createGroupbox(vis, "Hit Sound", "left")
        createToggle(hitSoundGroup, "HitSound", { Text = "Enabled", Default = false }, function(v) Settings.Visuals.HitSound.Enabled = v end)
        createDropdown(hitSoundGroup, "HitSoundSelect", {
            Text = "Sound",
            Values = {"Neverlose","Sparkle","Minecraft","TF2"},
            Default = "Neverlose"
        }, function(v)
            Settings.Visuals.HitSound.SelectedSound = v
            Settings.Visuals.HitSound.SoundId = soundOptions[v] or "rbxassetid://139452805868562"
        end)
        createSlider(hitSoundGroup, "HitSoundVolume", { Text = "Volume", Default = 1, Min = 0, Max = 1, Rounding = 2 }, function(v) Settings.Visuals.HitSound.Volume = v end)

        local tracerGroup = createGroupbox(vis, "Bullet Tracers", "right")
        createToggle(tracerGroup, "TracerEnabled", { Text = "Enabled", Default = false }, function(v) Settings.Visuals.BulletTracers.Enabled = v end)
        createColorpicker(tracerGroup, "TracerColor", { Text = "Color", Default = Color3.fromRGB(255,102,204) }, function(v) Settings.Visuals.BulletTracers.Color = v end)
        createSlider(tracerGroup, "TracerWidth", { Text = "Width", Default = 0.5, Min = 0.1, Max = 3, Rounding = 1 }, function(v) Settings.Visuals.BulletTracers.Width = v end)
        createSlider(tracerGroup, "TracerBrightness", { Text = "Brightness", Default = 5, Min = 1, Max = 10, Rounding = 1 }, function(v) Settings.Visuals.BulletTracers.Brightness = v end)
        createSlider(tracerGroup, "TracerSegments", { Text = "Segments", Default = 10, Min = 2, Max = 20, Rounding = 1 }, function(v) Settings.Visuals.BulletTracers.Segments = v end)
        createSlider(tracerGroup, "TracerSpeed", { Text = "Speed", Default = 3, Min = 1, Max = 10, Rounding = 1 }, function(v) Settings.Visuals.BulletTracers.Speed = v end)
        createDropdown(tracerGroup, "TracerTexture", { Text = "Texture", Values = {"Normal","Glow"}, Default = "Normal" }, function(v) Settings.Visuals.BulletTracers.Texture = v end)
        createToggle(tracerGroup, "TracerRayTrace", { Text = "Ray Tracing", Default = false }, function(v) Settings.Visuals.BulletTracers.RayTracing = v end)
        createSlider(tracerGroup, "TracerGlowIntensity", { Text = "Glow Intensity", Default = 5, Min = 1, Max = 20, Rounding = 1 }, function(v) Settings.Visuals.BulletTracers.GlowIntensity = v end)

        local espGroup = createGroupbox(vis, "ESP", "left")
        createToggle(espGroup, "ESP", { Text = "Enabled", Default = false }, function(v) Settings.Visuals.ESP.Enabled = v end)
        createToggle(espGroup, "ESPTeamCheck", { Text = "Team Check", Default = false }, function(v) Settings.Visuals.ESP.TeamCheck = v end)
        createColorpicker(espGroup, "ESPColor", { Text = "Color", Default = Color3.fromRGB(255,0,0) }, function(v) Settings.Visuals.ESP.HighlightColor = v end)
        createSlider(espGroup, "ESPTrans", { Text = "Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 2 }, function(v) Settings.Visuals.ESP.HighlightTransparency = v end)

        local selfChamsGroup = createGroupbox(vis, "Self Chams", "right")
        createToggle(selfChamsGroup, "SelfChams", { Text = "Enabled", Default = false }, function(v) Settings.Visuals.SelfChams.Enabled = v end)
        createColorpicker(selfChamsGroup, "SelfChamsColor", { Text = "Color", Default = Color3.fromRGB(255,0,0) }, function(v) Settings.Visuals.SelfChams.Color = v end)
        createSlider(selfChamsGroup, "SelfChamsTrans", { Text = "Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 2 }, function(v) Settings.Visuals.SelfChams.Transparency = v end)
        createColorpicker(selfChamsGroup, "SelfChamsOutline", { Text = "Outline Color", Default = Color3.fromRGB(255,255,255) }, function(v) Settings.Visuals.SelfChams.OutlineColor = v end)
        createSlider(selfChamsGroup, "SelfChamsOutlineTrans", { Text = "Outline Transparency", Default = 0, Min = 0, Max = 1, Rounding = 2 }, function(v) Settings.Visuals.SelfChams.OutlineTransparency = v end)
        createDropdown(selfChamsGroup, "SelfChamsMaterial", {
            Text = "Material (ForceField best)",
            Values = {"ForceField","Neon","Glass","SmoothPlastic","Plastic"},
            Default = "ForceField"
        }, function(v)
            Settings.Visuals.SelfChams.Material = v
        end)

        local cameraGroup = createGroupbox(vis, "Camera", "left")
        createSlider(cameraGroup, "CameraFOV", { Text = "Field of View", Default = 70, Min = 1, Max = 120, Rounding = 0 }, function(v) Settings.Visuals.CameraFOV = v end)

        local watermarkGroup = createGroupbox(vis, "Watermark", "right")
        createToggle(watermarkGroup, "WatermarkToggle", { Text = "Enabled", Default = true }, function(v) Settings.Visuals.Watermark.Enabled = v end)
        createColorpicker(watermarkGroup, "WatermarkColor", { Text = "Color", Default = Color3.fromRGB(226,226,226) }, function(v) Settings.Visuals.Watermark.Color = v end)
        createSlider(watermarkGroup, "WatermarkSize", { Text = "Size", Default = 14, Min = 8, Max = 24, Rounding = 1 }, function(v) Settings.Visuals.Watermark.Size = v end)
        createSlider(watermarkGroup, "WatermarkStatusSize", { Text = "Status Size", Default = 11, Min = 8, Max = 18, Rounding = 1 }, function(v) Settings.Visuals.Watermark.StatusSize = v end)

        local noFlashGroup = createGroupbox(vis, "Screen Effects", "right")
        createToggle(noFlashGroup, "NoFlash", { Text = "No Flash/Damage Effects", Default = false }, function(v) Settings.Visuals.NoFlash.Enabled = v end)

        local pl = Tabs.Player
        local moveGroup = createGroupbox(pl, "Movement", "left")
        local walkSpeedToggle = createToggle(moveGroup, "WalkSpeed", { Text = "WalkSpeed", Default = false }, function(v) Settings.Player.WalkSpeedEnabled = v end)
        walkSpeedToggle:AddKeyPicker("WalkSpeedKey", { Default = "T", Mode = "Toggle", Text = "WalkSpeed", SyncToggleState = true })
        createSlider(moveGroup, "WalkSpeedVal", { Text = "Speed", Default = 300, Min = 50, Max = 500, Rounding = 1 }, function(v) Settings.Player.WalkSpeed = v end)
        createToggle(moveGroup, "NoClip", { Text = "NoClip", Default = false }, function(v) Settings.Player.NoClipEnabled = v end)
        createToggle(moveGroup, "NoSlow", { Text = "No Slow", Default = false }, function(v) Settings.Player.NoSlow = v end)
        createToggle(moveGroup, "NoJumpCooldown", { Text = "No Jump Cooldown", Default = false }, function(v) Settings.Player.NoJumpCooldown = v end)

        local flyGroup = createGroupbox(pl, "Fly", "right")
        local flyToggle = createToggle(flyGroup, "Fly", { Text = "Enabled", Default = false }, function(v) setFlyEnabled(v) end)
        flyToggle:AddKeyPicker("FlyKey", { Default = "F", Mode = "Toggle", Text = "Fly", SyncToggleState = true })
        createSlider(flyGroup, "FlySpeed", { Text = "Speed", Default = 25, Min = 5, Max = 150, Rounding = 1 }, function(v) Settings.Player.Fly.Speed = v end)

        local networkGroup = createGroupbox(pl, "Network Anti", "left")
        local networkAntiToggle = createToggle(networkGroup, "NetworkAnti", { Text = "Enabled", Default = false }, function(v) Settings.Player.NetworkAnti.Enabled = v end)
        networkAntiToggle:AddKeyPicker("NetworkAntiKey", { Default = "K", Mode = "Toggle", Text = "Network Anti", SyncToggleState = true })

        local miscGroup = createGroupbox(pl, "Misc", "right")
        createToggle(miscGroup, "AutoRespawn", { Text = "Auto Respawn", Default = false }, function(v) Settings.Player.AutoRespawn = v end)
        createSlider(miscGroup, "AutoRespawnDelay", { Text = "Respawn Delay", Default = 3, Min = 0.5, Max = 10, Rounding = 1 }, function(v) Settings.Player.AutoRespawnDelay = v end)
        createToggle(miscGroup, "AntiVoid", { Text = "Anti Void", Default = true }, function(v) Settings.Player.AntiVoid = v end)

        local gr = Tabs.Graphics
        local ambienceGroup = createGroupbox(gr, "Ambience", "left")
        createToggle(ambienceGroup, "Ambience", { Text = "Enabled", Default = false }, function(v) Settings.Graphics.Ambience.Enabled = v; toggleAmbience(); if v then startAmbienceClockLock() end end)
        createColorpicker(ambienceGroup, "AmbienceAmbient", { Text = "Ambient", Default = Color3.fromRGB(178,178,178) }, function(v) Settings.Graphics.Ambience.Ambient = v; toggleAmbience() end)
        createColorpicker(ambienceGroup, "AmbienceOutdoor", { Text = "Outdoor", Default = Color3.fromRGB(178,178,178) }, function(v) Settings.Graphics.Ambience.OutdoorAmbient = v; toggleAmbience() end)
        createSlider(ambienceGroup, "AmbienceBrightness", { Text = "Brightness", Default = 2, Min = 0, Max = 4, Rounding = 1 }, function(v) Settings.Graphics.Ambience.Brightness = v; toggleAmbience() end)
        createColorpicker(ambienceGroup, "AmbienceFogColor", { Text = "Fog Color", Default = Color3.fromRGB(0,0,0) }, function(v) Settings.Graphics.Ambience.FogColor = v; toggleAmbience() end)
        createSlider(ambienceGroup, "AmbienceFogStart", { Text = "Fog Start", Default = 0, Min = 0, Max = 1000, Rounding = 1 }, function(v) Settings.Graphics.Ambience.FogStart = v; toggleAmbience() end)
        createSlider(ambienceGroup, "AmbienceFogEnd", { Text = "Fog End", Default = 500, Min = 0, Max = 2000, Rounding = 1 }, function(v) Settings.Graphics.Ambience.FogEnd = v; toggleAmbience() end)
        createSlider(ambienceGroup, "AmbienceTime", { Text = "Time of Day", Default = 18, Min = 0, Max = 24, Rounding = 1 }, function(v)
            Settings.Graphics.Ambience.TimeOfDay = tostring(v)..":00:00"
            Settings.Graphics.Ambience.ClockTimeOverride = v
            toggleAmbience()
        end)
        createDropdown(ambienceGroup, "AmbienceSkybox", { Text = "Skybox ID", Values = {"1294489738","1854733196","2561986864"}, Default = "1294489738" }, function(v) Settings.Graphics.Ambience.SkyboxID = "rbxassetid://"..v; toggleAmbience() end)

        local graphicsExtra = createGroupbox(gr, "Extra", "right")
        createToggle(graphicsExtra, "LowGraphics", { Text = "Low Graphics", Default = false }, function(v) Settings.Graphics.LowGraphics = v end)

        local mi = Tabs.Misc
        local autoBuyGroup = createGroupbox(mi, "Auto Buy", "left")
        local guns = getRealGuns()
        if #guns == 0 then
            guns = {}
            for _, gun in ipairs(KNOWN_GUNS) do table.insert(guns, gun) end
            table.sort(guns)
        end
        local defaultGun = guns[1] or ""
        createDropdown(autoBuyGroup, "SelectedGun", { Text = "Select Gun", Values = guns, Default = defaultGun }, function(v) Settings.Misc.AutoBuy.SelectedGun = v end)
        Settings.Misc.AutoBuy.SelectedGun = defaultGun
        createButton(autoBuyGroup, "BuyGun", { Text = "Buy Gun", Callback = function()
            local gun = Settings.Misc.AutoBuy.SelectedGun
            if not gun or gun == "" then
                if Library and Library.Notify then Library:Notify("No gun selected", 3) end
                return
            end
            if buyItem(gun) then
                if Library and Library.Notify then Library:Notify("Purchased: "..gun, 3) end
            else
                if Library and Library.Notify then Library:Notify("Failed to buy "..gun, 3) end
            end
        end})
        createButton(autoBuyGroup, "BuyAmmo", { Text = "Buy Ammo", Callback = function()
            local gun = Settings.Misc.AutoBuy.SelectedGun
            if not gun or gun == "" then
                if Library and Library.Notify then Library:Notify("No gun selected", 3) end
                return
            end
            local wtype = string.match(gun, "%[(.-)%]") or gun:gsub("%[", ""):gsub("%].*", "")
            local shop = workspace.Ignored and workspace.Ignored.Shop
            if not shop then
                if Library and Library.Notify then Library:Notify("Shop not found", 3) end
                return
            end
            local ammo = nil
            for _, child in ipairs(shop:GetChildren()) do
                if child:IsA("Model") and string.find(child.Name, wtype.." Ammo") then
                    ammo = child.Name
                    break
                end
            end
            if not ammo then
                if Library and Library.Notify then Library:Notify("No ammo found for "..wtype, 3) end
                return
            end
            if buyItem(ammo) then
                if Library and Library.Notify then Library:Notify("Purchased ammo: "..ammo, 3) end
            else
                if Library and Library.Notify then Library:Notify("Failed to buy ammo", 3) end
            end
        end})

        local teleportGroup = createGroupbox(mi, "Teleport", "right")
        createDropdown(teleportGroup, "TeleportLoc", { Text = "Location", Values = {"Admin Base","High Medium Armor","Food","Gas Station","School","Military","Ufo","Bank","Gym Top","Casino","Uphill","Revolver","Flank","PlayGround"}, Default = "Admin Base" }, function(v) Settings.Misc.SelectedLocation = v end)
        createButton(teleportGroup, "Teleport", { Text = "Teleport", Callback = function()
            if Settings.Misc.SelectedLocation then teleportToLocation(Settings.Misc.SelectedLocation) end
        end})

        local utilsGroup = createGroupbox(mi, "Utilities", "left")
        createButton(utilsGroup, "ForceReset", { Text = "Force Reset", Callback = forceReset })
        createButton(utilsGroup, "Rejoin", { Text = "Rejoin", Callback = rejoinServer })

        local settingsTab = Tabs.Settings
        local menuGroup = createGroupbox(settingsTab, "Menu", "left")
        menuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        menuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end})
        menuGroup:AddButton({ Text = "Unload", Func = function() Library:Unload() end })

        if ThemeManager then
            ThemeManager:SetLibrary(Library)
            ThemeManager:SetFolder("tapped.cc")
            ThemeManager:ApplyToTab(settingsTab)
        end

        if SaveManager then
            SaveManager:SetLibrary(Library)
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
            SaveManager:SetFolder("tapped.cc")
            SaveManager:SetSubFolder(game.PlaceId)
            SaveManager:BuildConfigSection(settingsTab)
            SaveManager:LoadAutoloadConfig()
        end

        Library.ToggleKeybind = Library.Options.MenuKeybind

        local function startup()
            RuntimeState.normalLighting = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
            }
            RuntimeState.originalLighting = {
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                Brightness = Lighting.Brightness,
                ColorShiftBottom = Lighting.ColorShift_Bottom,
                ColorShiftTop = Lighting.ColorShift_Top,
                FogColor = Lighting.FogColor,
                FogStart = Lighting.FogStart,
                FogEnd = Lighting.FogEnd,
                TimeOfDay = Lighting.TimeOfDay,
                ClockTime = Lighting.ClockTime,
            }

            ConnectionManager:Add("MainLoop", RunService.RenderStepped:Connect(mainLoop))

            setupCharacterLifecycle()
            startFlyMovementLoop()
            setupBulletRay()

            local kbConn = UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                local key = input.KeyCode
                if Settings.Ragebot.LockKey ~= "None" and key == Enum.KeyCode[Settings.Ragebot.LockKey] then
                    handleLockToggle()
                end
            end)
            ConnectionManager:Add("Keybinds", kbConn)

            local flyKeysConn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard and Settings.Player.Fly.Enabled then
                    local k = input.KeyCode
                    if k == Enum.KeyCode.W then flyKeys.w = true
                    elseif k == Enum.KeyCode.S then flyKeys.s = true
                    elseif k == Enum.KeyCode.A then flyKeys.a = true
                    elseif k == Enum.KeyCode.D then flyKeys.d = true end
                end
            end)
            ConnectionManager:Add("FlyKeys", flyKeysConn)

            local flyKeysEnd = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard and Settings.Player.Fly.Enabled then
                    local k = input.KeyCode
                    if k == Enum.KeyCode.W then flyKeys.w = false
                    elseif k == Enum.KeyCode.S then flyKeys.s = false
                    elseif k == Enum.KeyCode.A then flyKeys.a = false
                    elseif k == Enum.KeyCode.D then flyKeys.d = false end
                end
            end)
            ConnectionManager:Add("FlyKeysEnd", flyKeysEnd)

            if Settings.Ragebot.HitboxExpander.Enabled then setHitboxExpanderEnabled(true) end
            if Settings.Player.Fly.Enabled then startFly() end
            if Settings.Ragebot.SilentReload then setSilentReloadEnabled(true) end
            if Settings.Graphics.Ambience.Enabled then
                toggleAmbience()
                startAmbienceClockLock()
            end

            print("[tapped.cc] Loaded successfully (all features off).")
        end

        pcall(startup)

        function Unload()
            Cleanup:Run()
            print("[tapped.cc] Unloaded")
        end

    end)
    if not ok then
        warn("[tapped.cc] Startup error: " .. tostring(err))
    end
end

local success, err = pcall(safeStart)
if not success then
    warn("[tapped.cc] FATAL ERROR: " .. tostring(err))
end
