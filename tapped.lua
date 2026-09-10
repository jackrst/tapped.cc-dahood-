local function safeStart()
    local ok, err = pcall(function()
        -- ============================================================
        -- CORE
        -- ============================================================
        local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
        local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
        local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
        local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
        if not Library then warn("[tapped.cc] Failed to load UI library") return end

        Library.ShowToggleFrameInKeybinds = true
        Library.ShowCustomCursor = true
        Library.NotifySide = "Left"

        local Window = Library:CreateWindow({
            Title = "tapped.cc – Da Hood", Center = true, AutoShow = true,
            Resizable = true, ShowCustomCursor = true, UnlockMouseWhileOpen = true,
            NotifySide = "Left", TabPadding = 8, MenuFadeTime = 0.2
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

        local Cap = {
            Drawing = false,
            fireclickdetector = type(fireclickdetector) == "function",
            getconnections = type(getconnections) == "function",
            setfflag = type(setfflag) == "function",
            sethiddenproperty = type(sethiddenproperty) == "function",
            hookmetamethod = type(hookmetamethod) == "function",
            getrawmetatable = type(getrawmetatable) == "function",
            checkcaller = type(checkcaller) == "function",
            newcclosure = type(newcclosure) == "function",
        }
        pcall(function()
            if Drawing ~= nil and type(Drawing) == "table" and type(Drawing.new) == "function" then
                local ok, circ = pcall(function() return Drawing.new("Circle") end)
                if ok and circ then
                    local ok2, line = pcall(function() return Drawing.new("Line") end)
                    if ok2 and line then
                        Cap.Drawing = true
                        pcall(function() circ:Remove(); line:Remove() end)
                    end
                end
            end
        end)

        local MainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
        Cap.MainEvent = MainEvent ~= nil

        local function clampNumber(value, minimum, maximum, fallback)
            local num = tonumber(value)
            if not num then return fallback end
            if num < minimum then return minimum end
            if num > maximum then return maximum end
            return num
        end

        local Settings = {
            Ragebot = {
                SilentAim = false, Hitchance = 100, AimPart = "HumanoidRootPart", TeamCheck = false,
                PriorityMode = "FOV", VisibilityCheck = false, FOVRadius = 200, FOVColor = Color3.fromRGB(255,0,0),
                FOVThickness = 1.5, FOVTransparency = 0.8, ShowFOV = true, LockKey = "Q", Spectate = false,
                TargetStrafe = { Enabled = false, Speed = 1.5, Distance = 8, Height = 4 },
                Unhittable = false, AutoShoot = false, AutoShootVisibilityCheck = false,
                RapidFire = false, RapidFireDelay = 0.08, NoRecoil = false, NoSpread = false, AutoReload = false,
                StopAutoShootBelowHealth = 20, LockTracer = true, Prediction = false,
                Resolver = true, KnockedCheck = true, GrabbedCheck = true, NoGroundShots = true,
                SilentReload = false, AutoSelect = false, AutoStomp = false, MultiGun = false,
                VoidSpamRage = false, AntiStomp = false, FaceTarget = false,
                AccuracyLimiter = { Enabled = true, MaxAccuracy = 95, Window = 20 },
                HitDetection = { Enabled = true, Sound = true, Notify = true, MissNotify = true, HitSound = "Neverlose",
                                 EffectClone = false, EffectPulse = false },
                HitboxExpander = { Enabled = false, Size = Vector3.new(16,16,16), Color = Color3.fromRGB(0,0,0),
                                   Transparency = 0.8, OutlineColor = Color3.fromRGB(108,59,170), OutlineTransparency = 0 },
            },
            Player = {
                WalkSpeedEnabled = false, WalkSpeed = 300, WalkSpeedMode = "Humanoid", NoClipEnabled = false,
                Fly = { Enabled = false, Keybind = Enum.KeyCode.F, Speed = 25 }, NoSlow = false, NoJumpCooldown = false,
                NetworkAnti = { Enabled = false }, AutoRespawn = false, AutoRespawnDelay = 3, AntiVoid = true,
            },
            Visuals = {
                BulletTracers = { Enabled = false, Color = Color3.fromRGB(255,102,204), Width = 0.5, Brightness = 5,
                                  Segments = 10, LightEmission = 5, Speed = 3, Texture = "Normal", RayTracing = false, GlowIntensity = 5 },
                HitSound = { Enabled = false, SelectedSound = "Neverlose", Volume = 1, SoundId = "rbxassetid://139452805868562" },
                ESP = { Enabled = false, TeamCheck = false, HighlightColor = Color3.fromRGB(255,0,0), HighlightTransparency = 0.5 },
                ClientChams = {
                    CharEnabled = false, CharMaterial = "ForceField", CharColor = Color3.fromRGB(255,0,0),
                    WeaponEnabled = false, WeaponMaterial = "SmoothPlastic", WeaponColor = Color3.fromRGB(255,0,0),
                    TrailEnabled = false, TrailColor = Color3.fromRGB(255,0,0), TrailLifetime = 3,
                },
                Crosshair = { Enabled = false, Color = Color3.fromRGB(255,102,204), Mode = "mouse",
                              Thickness = 2, Length = 10, Radius = 11,
                              Spin = false, SpinSpeed = 150,
                              Resize = false, ResizeSpeed = 5,
                              FollowTarget = false },
                CameraFOV = 70,
                Watermark = { Enabled = true, Color = Color3.fromRGB(226,226,226), Size = 14, StatusSize = 11 },
                NoFlash = { Enabled = false }, RemoveBulletTracer = false, RemoveGunSound = false,
            },
            Graphics = {
                Ambience = { Enabled = false, Ambient = Color3.fromRGB(178,178,178), OutdoorAmbient = Color3.fromRGB(178,178,178),
                             Brightness = 2, ColorShiftBottom = Color3.fromRGB(0,0,0), ColorShiftTop = Color3.fromRGB(0,0,0),
                             FogColor = Color3.fromRGB(0,0,0), FogStart = 0, FogEnd = 500, TimeOfDay = "18:00:00",
                             SkyboxID = "rbxassetid://1294489738", ClockTimeOverride = 18 },
                LowGraphics = false,
            },
            Exploits = {
                InvisibleDesync = { Enabled = false, XMin = -16000, XMax = 16000, YMin = -16000, YMax = 16000, ZMin = -16000, ZMax = 16000 },
                CFrameDesync = { Enabled = false },
            },
            Misc = { AutoBuy = { SelectedGun = nil }, SelectedLocation = "Admin Base" },
        }

        Settings.Player.WalkSpeed = clampNumber(Settings.Player.WalkSpeed, 0, 500, 300)
        Settings.Ragebot.FOVRadius = clampNumber(Settings.Ragebot.FOVRadius, 1, 2000, 200)
        Settings.Ragebot.Hitchance = clampNumber(Settings.Ragebot.Hitchance, 0, 100, 100)
        Settings.Ragebot.StopAutoShootBelowHealth = clampNumber(Settings.Ragebot.StopAutoShootBelowHealth, 0, 100, 20)
        Settings.Ragebot.RapidFireDelay = clampNumber(Settings.Ragebot.RapidFireDelay, 0.02, 0.5, 0.08)
        Settings.Ragebot.AccuracyLimiter.MaxAccuracy = clampNumber(Settings.Ragebot.AccuracyLimiter.MaxAccuracy, 50, 99, 95)
        Settings.Ragebot.AccuracyLimiter.Window = clampNumber(Settings.Ragebot.AccuracyLimiter.Window, 5, 50, 20)
        Settings.Player.AutoRespawnDelay = clampNumber(Settings.Player.AutoRespawnDelay, 0.5, 10, 3)
        Settings.Visuals.CameraFOV = clampNumber(Settings.Visuals.CameraFOV, 1, 120, 70)

        -- ============================================================
        -- STATE
        -- ============================================================
        local State = {
            Character = { character = nil, humanoid = nil, rootPart = nil, walkSpeed = nil, jumpPower = nil },
            Target = { Locked = false, Character = nil, Player = nil },
            Void = { inVoid = false, reloading = false, orbitPos = nil, lastVoidTime = 0, lastOrbitTime = 0 },
            Face = { savedAutoRotate = nil },
            Accuracy = { history = {}, forceNextMiss = false, _lastShotForced = false },
            Shots = {},
            HPSnapshot = {},
            originalPosition = nil,
            targetVelocity = {},
            velocityHistory = {},
            multiGunClones = {},
            lastFireTime = {},
            rapidFireHooks = {},
            rapidFireChildConns = {},
            espObjects = {},
            OriginalHitboxState = {},
            outlinePool = {},
            noClipOriginalStates = {},
            origCharChamsProps = {},
            origWeapChamsProps = {},
            RuntimeLighting = nil,
            AmbienceToggled = false,
            lastAmmoCount = {},
            lastShotRegTime = 0,
            InvisibleDesync = { running = false, conn = nil, shouldSleep = false, origVel = {}, origAssemblyVel = {} },
            CFrameDesync = { running = false, loopThread = nil, fakeCFrame = nil, clientLocation = nil },
        }

        local Draw = {
            fovCircle = nil, lockTracerLine = nil, watermarkText = nil, watermarkStatus = nil,
            targetCircle = nil,
            crosshairLines = {},
        }
        local Refs = {
            GunHandler = nil, originalGunHandlerMethods = nil, charAddedEntry = nil,
            voidCoroutine = nil, rapidFireLoopRunning = false, rapidFireLoopThread = nil,
            flyMovementEntry = nil, silentReloadEntry = nil, hitboxEntry = nil, lastHitboxTarget = nil,
            autoRespawnTask = nil, bulletRayEntry = nil, ambienceClockEntry = nil,
            lastNetworkAntiAction = 0, orbitAngle = 0, lastAutoSelectTime = 0,
            flyCore = nil, flyWeld = nil, flyPos = nil, flyGyro = nil, flyRunning = false,
            flyKeys = { w=false, a=false, s=false, d=false },
            resolverIndex = 0, resolverParts = { "Head", "HumanoidRootPart", "Torso" },
            watchedPlayers = {},
            crosshairSpin = 0, crosshairResizeT = 0,
            networkAntiLoop = nil,
        }
        local Status = { text = "Safe", isShooting = false, isReloading = false, shootTimer = 0, reloadTimer = 0 }

        local function isValidPart(part) return part and part.Parent and part:IsA("BasePart") end
        local function isValidCharacter(model)
            if not model or not model.Parent then return false end
            local hum = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            return hum and hum.Health > 0 and root ~= nil
        end
        local function refreshCharacter(character)
            State.Character.character = character
            task.spawn(function()
                local hum = character:WaitForChild("Humanoid", 10)
                local root = character:WaitForChild("HumanoidRootPart", 10)
                State.Character.humanoid = hum
                State.Character.rootPart = root
                if hum then State.Character.walkSpeed = hum.WalkSpeed; State.Character.jumpPower = hum.JumpPower end
            end)
        end

        local Connections = { _c = {} }
        function Connections:Add(feature, conn)
            if not conn or typeof(conn.Disconnect) ~= "function" then return nil end
            local e = { connection = conn, feature = feature, active = true }
            table.insert(self._c, e); return e
        end
        function Connections:Remove(e)
            if not e or not e.active then return end
            e.active = false; pcall(function() e.connection:Disconnect() end)
        end
        function Connections:RemoveAll()
            for _, e in ipairs(self._c) do
                if e.active then e.active = false; pcall(function() e.connection:Disconnect() end) end
            end
            self._c = {}
        end

        local Cleanup = { cb = {} }
        function Cleanup:Add(f) table.insert(self.cb, f) end
        function Cleanup:Run()
            for i = #self.cb, 1, -1 do pcall(self.cb[i]); self.cb[i] = nil end
        end

        -- ============================================================
        -- NOTIFICATIONS
        -- ============================================================
        local Notify = (function()
            local gui, container, active = nil, nil, {}
            local W, H, GAP, DUR, FADE, BG, TS, MAX = 340, 32, 6, 2.2, 0.3, 0.25, 14, 6
            local FONT = Enum.Font.SourceSansSemibold
            local COLORS = { hit = Color3.fromRGB(46,204,113), info = Color3.fromRGB(255,255,255), warn = Color3.fromRGB(241,196,15), miss = Color3.fromRGB(231,76,60) }
            local GLYPHS = { hit = "✓", info = "•", warn = "!", miss = "✗" }

            local function createGui()
                if gui and gui.Parent then return end
                gui = Instance.new("ScreenGui")
                gui.Name = "_NotificationGui"; gui.ResetOnSpawn = false
                gui.IgnoreGuiInset = true; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                pcall(function() gui.Parent = game:GetService("CoreGui") end)
                if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
                container = Instance.new("Frame")
                container.Name = "Container"; container.Parent = gui
                container.BackgroundTransparency = 1; container.BorderSizePixel = 0
                container.Size = UDim2.new(0, W, 0, 240)
                container.AnchorPoint = Vector2.new(0.5, 1)
                container.Position = UDim2.new(0.5, 0, 0.78, 0)
            end

            local function updatePositions(animated)
                for i, n in ipairs(active) do
                    if n.frame and n.frame.Parent then
                        local targetY = -(i * H) - ((i - 1) * GAP)
                        n.currentY = targetY
                        local target = UDim2.new(0, 0, 1, targetY)
                        if animated then
                            TweenService:Create(n.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = target}):Play()
                        else n.frame.Position = target end
                    end
                end
            end

            local function fadeOut(n)
                if not n or n.removing then return end
                n.removing = true
                local frame, label, icon = n.frame, n.label, n.icon
                if frame and frame.Parent then
                    TweenService:Create(frame, TweenInfo.new(FADE, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0, 40, 1, n.currentY), BackgroundTransparency = 1}):Play()
                    TweenService:Create(label, TweenInfo.new(FADE, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
                    if icon then TweenService:Create(icon, TweenInfo.new(FADE, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play() end
                    task.delay(FADE + 0.05, function() if frame and frame.Parent then frame:Destroy() end end)
                end
                for i, x in ipairs(active) do if x == n then table.remove(active, i); break end end
                updatePositions(true)
            end

            local function show(text, iconType)
                iconType = iconType or "info"
                createGui()
                while #active >= MAX do
                    local o = active[1]; if o then fadeOut(o) else break end
                end
                local frame = Instance.new("Frame")
                frame.Name = "PillNotification"; frame.Parent = container
                frame.Size = UDim2.new(1, 0, 0, H)
                frame.Position = UDim2.new(0, 60, 1, -H)
                frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                frame.BackgroundTransparency = 1; frame.BorderSizePixel = 0
                Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
                local icon = Instance.new("TextLabel")
                icon.Parent = frame; icon.Size = UDim2.new(0, 24, 0, 24)
                icon.Position = UDim2.new(0, 8, 0.5, -12); icon.BackgroundTransparency = 1
                icon.Font = Enum.Font.SourceSansBold; icon.TextSize = 18
                icon.TextColor3 = COLORS[iconType] or COLORS.info
                icon.Text = GLYPHS[iconType] or "•"; icon.TextTransparency = 1
                local label = Instance.new("TextLabel")
                label.Parent = frame; label.Size = UDim2.new(1, -44, 1, 0)
                label.Position = UDim2.new(0, 36, 0, 0); label.BackgroundTransparency = 1
                label.Font = FONT; label.TextSize = TS
                label.TextColor3 = Color3.fromRGB(245, 245, 245)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextYAlignment = Enum.TextYAlignment.Center
                label.Text = text; label.TextTransparency = 1
                local n = { frame = frame, label = label, icon = icon, currentY = -H, removing = false }
                table.insert(active, n)
                updatePositions(false)
                local finalPos = UDim2.new(0, 0, 1, n.currentY)
                TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = finalPos, BackgroundTransparency = BG}):Play()
                TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
                TweenService:Create(icon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
                task.delay(DUR, function() if n and not n.removing then fadeOut(n) end end)
            end

            return { show = show, hit = function(t) if Settings.Ragebot.HitDetection.Notify then show(t, "hit") end end }
        end)()

        local showNotification = Notify.show
        local showHitNotification = Notify.hit
        local playHitSoundGlobal

        -- ============================================================
        -- TARGETING HELPERS
        -- ============================================================
        local function getScreenPosition(worldPos)
            local cam = getCamera(); if not cam then return Vector2.new(0,0) end
            local p = cam:WorldToScreenPoint(worldPos)
            local inset = GuiService:GetGuiInset()
            return Vector2.new(p.X, p.Y + inset.Y)
        end
        local function getPlayerFromCharacter(c) if not c then return nil end; return Players:GetPlayerFromCharacter(c) end
        local function resolveAimPart(c)
            if not c then return nil end
            local p = c:FindFirstChild(Settings.Ragebot.AimPart); if isValidPart(p) then return p end
            p = c:FindFirstChild("HumanoidRootPart"); if isValidPart(p) then return p end
            p = c:FindFirstChild("Head"); if isValidPart(p) then return p end
            return nil
        end
        local function isPartVisible(part)
            if not isValidPart(part) then return false end
            local cam = getCamera(); if not cam then return false end
            local camPos = cam.CFrame.Position
            local dir = (part.Position - camPos).Unit
            local dist = (part.Position - camPos).Magnitude
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = { LocalPlayer.Character }
            local result = workspace:Raycast(camPos, dir * dist, rp)
            if result then return result.Instance == part or result.Instance:IsDescendantOf(part.Parent) end
            return true
        end
        local function getFOVCenter() return UserInputService:GetMouseLocation() end
        local function isValidLockedTarget(c)
            return isValidCharacter(c)
                and (not Settings.Ragebot.KnockedCheck or not (c:FindFirstChild("BodyEffects") and c.BodyEffects:FindFirstChild("K.O") and c.BodyEffects["K.O"].Value))
                and (not Settings.Ragebot.GrabbedCheck or not c:FindFirstChild("GRABBING_CONSTRAINT"))
                and (not Settings.Ragebot.NoGroundShots or (c:FindFirstChild("HumanoidRootPart") and c.HumanoidRootPart.Position.Y >= -20))
        end
        local function hasProtection(c)
            if c:FindFirstChildOfClass("ForceField") then return true end
            local p = c:FindFirstChild("Protection")
            if p and p:IsA("BoolValue") and p.Value then return true end
            return false
        end
        local function getAllEnemies(teamCheck)
            local chars = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == LocalPlayer then continue end
                local c = plr.Character; if not c then continue end
                local h = c:FindFirstChildOfClass("Humanoid")
                if not h or h.Health <= 0 then continue end
                if teamCheck and plr.Team == LocalPlayer.Team then continue end
                table.insert(chars, c)
            end
            return chars
        end
        local function findBestTarget()
            local chars = getAllEnemies(Settings.Ragebot.TeamCheck)
            if #chars == 0 then return nil end
            local center = getFOVCenter()
            local cam = getCamera(); if not cam then return nil end
            local best, bestScore = nil, math.huge
            for _, c in ipairs(chars) do
                if not isValidCharacter(c) then continue end
                local part = resolveAimPart(c); if not part then continue end
                local screenPos = getScreenPosition(part.Position)
                local pos3D = cam:WorldToScreenPoint(part.Position)
                if pos3D.Z <= 0 then continue end
                local d = (screenPos - center).Magnitude
                if d > Settings.Ragebot.FOVRadius then continue end
                if not Settings.Ragebot.HitboxExpander.Enabled and Settings.Ragebot.VisibilityCheck and not isPartVisible(part) then continue end
                local score = d
                if Settings.Ragebot.PriorityMode == "Distance" then score = (part.Position - cam.CFrame.Position).Magnitude
                elseif Settings.Ragebot.PriorityMode == "Health" then
                    local h = c:FindFirstChildOfClass("Humanoid"); score = h and h.Health or 100
                end
                if score < bestScore then bestScore = score; best = c end
            end
            return best
        end

        local function lockTarget(character)
            local player = getPlayerFromCharacter(character)
            if not player or not character or not isValidLockedTarget(character) then return false end
            State.Target.Locked = true; State.Target.Character = character; State.Target.Player = player
            if Settings.Ragebot.Spectate then
                local h = character:FindFirstChildOfClass("Humanoid")
                if h then local cam = getCamera(); if cam then cam.CameraSubject = h; cam.CameraType = Enum.CameraType.Custom end end
            end
            if player then showNotification("Locked onto " .. player.Name, "info") end
            return true
        end
        local function unlockTarget()
            local old = State.Target.Player
            State.Target.Locked = false; State.Target.Character = nil; State.Target.Player = nil
            local c = LocalPlayer.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then local cam = getCamera(); if cam then cam.CameraSubject = h; cam.CameraType = Enum.CameraType.Custom end end
            end
            if old then showNotification("Unlocked " .. old.Name, "info") end
        end
        local function handleLockToggle()
            if State.Target.Locked then unlockTarget(); return end
            local b = findBestTarget(); if b then lockTarget(b) end
        end
        local function applySpectateSetting()
            if Settings.Ragebot.Spectate then
                if State.Target.Locked and State.Target.Character then
                    local h = State.Target.Character:FindFirstChildOfClass("Humanoid")
                    if h then local cam = getCamera(); if cam then cam.CameraSubject = h; cam.CameraType = Enum.CameraType.Custom end end
                end
            else
                local c = LocalPlayer.Character
                if c then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h then local cam = getCamera(); if cam then cam.CameraSubject = h; cam.CameraType = Enum.CameraType.Custom end end
                end
            end
        end

        -- ============================================================
        -- ACCURACY TRACKER
        -- ============================================================
        local function calcRollingAccuracy()
            local total, hits = 0, 0
            for _, s in ipairs(State.Accuracy.history) do total = total + 1; if s.hit then hits = hits + 1 end end
            if total == 0 then return 100 end
            return (hits / total) * 100
        end
        local function recordAccuracyShot(forced)
            table.insert(State.Accuracy.history, { hit = false, resolved = false, forced = forced })
            local win = Settings.Ragebot.AccuracyLimiter.Window
            while #State.Accuracy.history > win do table.remove(State.Accuracy.history, 1) end
            if Settings.Ragebot.AccuracyLimiter.Enabled and #State.Accuracy.history >= math.min(5, win) then
                if calcRollingAccuracy() >= Settings.Ragebot.AccuracyLimiter.MaxAccuracy then
                    State.Accuracy.forceNextMiss = true
                end
            end
        end
        local function recordAccuracyHit()
            for i = #State.Accuracy.history, 1, -1 do
                local s = State.Accuracy.history[i]
                if not s.resolved then s.hit = true; s.resolved = true; break end
            end
        end
        local function recordAccuracyMiss()
            for i = #State.Accuracy.history, 1, -1 do
                local s = State.Accuracy.history[i]
                if not s.resolved then s.hit = false; s.resolved = true; break end
            end
        end

        -- ============================================================
        -- HIT EFFECTS
        -- ============================================================
        local function spawnHitEffectClone(targetChar)
            if not Settings.Ragebot.HitDetection.EffectClone then return end
            if not targetChar or not targetChar.PrimaryPart then return end
            task.spawn(function()
                pcall(function()
                    targetChar.Archivable = true
                    local clone = targetChar:Clone()
                    clone.Name = "tcc_HitClone"
                    for _, v in ipairs(clone:GetDescendants()) do
                        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Humanoid") or v:IsA("Accessory") or v:IsA("Tool") then
                            v:Destroy()
                        elseif v:IsA("BasePart") or v:IsA("MeshPart") then
                            v.Material = Enum.Material.ForceField
                            v.Color = Settings.Ragebot.FOVColor
                            v.CanCollide = false
                            v.Anchored = true
                            v.CanQuery = false
                            v.CanTouch = false
                        end
                    end
                    local head = clone:FindFirstChild("Head")
                    if head and head:FindFirstChild("face") then head.face:Destroy() end
                    clone.Parent = workspace
                    Debris:AddItem(clone, 2)
                end)
            end)
        end

        local function spawnHitEffectPulse(targetChar)
            if not Settings.Ragebot.HitDetection.EffectPulse then return end
            if not targetChar then return end
            local root = targetChar:FindFirstChild("HumanoidRootPart")
            if not root then return end
            pcall(function()
                local attachment = Instance.new("Attachment", root)
                local p1 = Instance.new("ParticleEmitter", attachment)
                p1.LightEmission = 3
                p1.Transparency = NumberSequence.new(0)
                p1.Color = ColorSequence.new(Settings.Ragebot.FOVColor)
                p1.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 6, 1.2)}
                p1.Enabled = false
                p1.Rate = 2
                p1.Lifetime = NumberRange.new(0.25)
                p1.Speed = NumberRange.new(0.1)
                p1.Squash = NumberSequence.new(0)
                p1.ZOffset = 1
                p1.Texture = "rbxassetid://2916153928"
                p1.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
                p1.Shape = Enum.ParticleEmitterShape.Box
                p1.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
                p1.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
                local p2 = p1:Clone()
                p2.Orientation = Enum.ParticleOrientation.FacingCamera
                p2.Parent = attachment
                p1:Emit(1); p2:Emit(1)
                Debris:AddItem(attachment, 1)
            end)
        end

        -- ============================================================
        -- SHOT TRACKING
        -- ============================================================
        local function resolveShotHit(idx, damage)
            local shot = State.Shots[idx]
            if not shot or shot.resolved then return end
            shot.resolved = true
            recordAccuracyHit()
            if playHitSoundGlobal then playHitSoundGlobal() end
            if shot.player and Settings.Ragebot.HitDetection.Notify then
                showHitNotification(string.format("Hit %s's %s for -%d HP", shot.player.Name, shot.aimPartName, math.max(1, math.floor(damage or 0))))
            end
            local char = shot.player and shot.player.Character
            if char then
                spawnHitEffectClone(char)
                spawnHitEffectPulse(char)
            end
            table.remove(State.Shots, idx)
        end
        local function resolveShotMiss(idx, reason)
            local shot = State.Shots[idx]
            if not shot or shot.resolved then return end
            shot.resolved = true
            recordAccuracyMiss()
            if Settings.Ragebot.HitDetection.Notify and Settings.Ragebot.HitDetection.MissNotify then
                local name = shot.player and shot.player.Name or "target"
                showNotification(string.format("Missed %s – %s", name, reason), "miss")
            end
            table.remove(State.Shots, idx)
        end

        local function beginShotTracking(targetChar, aimPartName, forced)
            if not targetChar or not targetChar.Parent then return end
            local targetPlayer = getPlayerFromCharacter(targetChar)
            if not targetPlayer or targetPlayer == LocalPlayer then return end
            local h = targetChar:FindFirstChildOfClass("Humanoid")
            if not h then return end
            table.insert(State.Shots, {
                player = targetPlayer,
                charAtFire = targetChar,
                startHP = h.Health,
                fireTime = tick(),
                aimPartName = aimPartName or "Body",
                forced = forced or false,
                pingAtFire = (LocalPlayer:GetNetworkPing() or 0) * 1000,
                lastAimPos = (function()
                    local ap = resolveAimPart(targetChar)
                    return ap and ap.Position or nil
                end)(),
                resolved = false,
            })
        end

        local function onPlayerHealthDrop(player, damage)
            for i = #State.Shots, 1, -1 do
                local shot = State.Shots[i]
                if shot.player == player and not shot.resolved then
                    if tick() - shot.fireTime < 3.0 then
                        resolveShotHit(i, damage)
                        return
                    end
                end
            end
        end

        local function watchPlayer(player)
            if player == LocalPlayer or Refs.watchedPlayers[player] then return end
            Refs.watchedPlayers[player] = true
            local function onChar(char)
                local hum = char:WaitForChild("Humanoid", 8)
                if not hum then return end
                State.HPSnapshot[player] = { char = char, hp = hum.Health }
                hum.HealthChanged:Connect(function(newHealth)
                    local prev = State.HPSnapshot[player]
                    if prev and prev.char == char and newHealth < prev.hp - 0.05 then
                        onPlayerHealthDrop(player, prev.hp - newHealth)
                    end
                    State.HPSnapshot[player] = { char = char, hp = newHealth }
                end)
            end
            if player.Character then onChar(player.Character) end
            player.CharacterAdded:Connect(onChar)
            player.CharacterRemoving:Connect(function()
                local prev = State.HPSnapshot[player]
                if prev and prev.hp > 0.5 then onPlayerHealthDrop(player, prev.hp) end
                State.HPSnapshot[player] = nil
            end)
        end

        local function pollHealthSnapshots()
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hum then
                    local prev = State.HPSnapshot[player]
                    if prev and prev.hp > 0.5 and prev.char == char then onPlayerHealthDrop(player, prev.hp) end
                    continue
                end
                local prev = State.HPSnapshot[player]
                if prev and prev.char == char and hum.Health < prev.hp - 0.05 then
                    onPlayerHealthDrop(player, prev.hp - hum.Health)
                    State.HPSnapshot[player] = { char = char, hp = hum.Health }
                end
            end
        end

        local function updateShotTimeouts()
            local now = tick()
            for i = #State.Shots, 1, -1 do
                local shot = State.Shots[i]
                if not shot.resolved then
                    local window = 0.6 + (shot.pingAtFire / 1000) * 1.6
                    if now - shot.fireTime > window then
                        local reason
                        if shot.forced then reason = "accuracy limiter"
                        else
                            local c = shot.player and shot.player.Character
                            if c and hasProtection(c) then reason = "target protected"
                            elseif shot.pingAtFire > 150 then reason = string.format("ping (%dms)", math.floor(shot.pingAtFire))
                            else
                                if c ~= shot.charAtFire then reason = "target lost"
                                else
                                    local root = c and c:FindFirstChild("HumanoidRootPart")
                                    if root and shot.lastAimPos and (root.Position - shot.lastAimPos).Magnitude > 15 then reason = "target moved"
                                    elseif Settings.Ragebot.AutoShoot and Settings.Ragebot.AutoShootVisibilityCheck then reason = "no LOS"
                                    else reason = "unknown" end
                                end
                            end
                        end
                        resolveShotMiss(i, reason)
                    end
                end
            end
        end

        local function registerShot()
            if not (State.Target.Locked and State.Target.Character) then return end
            local now = tick()
            if now - State.lastShotRegTime < 0.03 then return end
            State.lastShotRegTime = now
            recordAccuracyShot(State.Accuracy._lastShotForced)
            beginShotTracking(State.Target.Character, Settings.Ragebot.AimPart, State.Accuracy._lastShotForced)
            State.Accuracy._lastShotForced = false
        end

        local function checkAmmoShot()
            local c = LocalPlayer.Character
            if not c then return end
            local t = c:FindFirstChildOfClass("Tool")
            if not t then State.lastAmmoCount = {}; return end
            local ammo = t:FindFirstChild("Ammo")
            if not ammo then return end
            local last = State.lastAmmoCount[t]
            local cur = ammo.Value
            State.lastAmmoCount[t] = cur
            if last and cur < last then
                local count = math.min(last - cur, 5)
                for _ = 1, count do registerShot() end
            end
        end

        -- ============================================================
        -- HIT SOUNDS
        -- ============================================================
        local soundOptions = {
            Neverlose     = "rbxassetid://139452805868562",
            Sparkle       = "rbxassetid://110241936966089",
            Minecraft     = "rbxassetid://131197435969853",
            TF2           = "rbxassetid://118731928809041",
            OSU           = "rbxassetid://7147454322",
            Bameware      = "rbxassetid://3124331820",
            Hitmarker     = "rbxassetid://160432334",
            skeet         = "rbxassetid://4817809188",
            Rust          = "rbxassetid://5043539486",
            ["Lazer Beam"]= "rbxassetid://130791043",
            ["Bow Hit"]   = "rbxassetid://1053296915",
            Bow           = "rbxassetid://3442683707",
            ["TF2 Hitsound"] = "rbxassetid://3455144981",
            ["TF2 Critical"] = "rbxassetid://296102734",
        }
        playHitSoundGlobal = function()
            if not Settings.Ragebot.HitDetection.Sound then return end
            local s = Instance.new("Sound")
            s.SoundId = Settings.Visuals.HitSound.SoundId
            s.Volume = Settings.Visuals.HitSound.Volume
            s.Parent = workspace; s:Play()
            Debris:AddItem(s, 1)
        end

        -- ============================================================
        -- GUNHANDLER HOOKS
        -- ============================================================
        pcall(function()
            local modules = ReplicatedStorage:FindFirstChild("Modules")
            if modules then
                local gm = modules:FindFirstChild("GunHandler")
                if gm then
                    Refs.GunHandler = require(gm)
                    Refs.originalGunHandlerMethods = { getAim = Refs.GunHandler.getAim, getCanShoot = Refs.GunHandler.getCanShoot, shoot = Refs.GunHandler.shoot }
                end
            end
        end)

        local VOID_Y_MIN, VOID_Y_MAX, VOID_XZ_RANGE = 600, 1500, 300
        local function getRandomVoidPosition()
            return Vector3.new(
                (math.random() - 0.5) * 2 * VOID_XZ_RANGE,
                VOID_Y_MIN + math.random() * (VOID_Y_MAX - VOID_Y_MIN),
                (math.random() - 0.5) * 2 * VOID_XZ_RANGE
            )
        end
        local function setRootCFrameSafely(root, cf, velHint)
            if not root or not root.Parent then return end
            pcall(function()
                if velHint then root.AssemblyLinearVelocity = velHint end
                root.CFrame = cf
            end)
        end
        local function jitteredWait(base) task.wait(base + math.random() * 0.03) end

        if Refs.GunHandler then
            local origAim = Refs.GunHandler.getAim
            local origCanShoot = Refs.GunHandler.getCanShoot
            local origShoot = Refs.GunHandler.shoot

            if type(origAim) == "function" then
                Refs.GunHandler.getAim = function(origin, ...)
                    if State.Accuracy.forceNextMiss and Settings.Ragebot.SilentAim then
                        State.Accuracy.forceNextMiss = false
                        State.Accuracy._lastShotForced = true
                        return Vector3.new(0, 1, 0), 1000
                    end
                    State.Accuracy._lastShotForced = false
                    if not Settings.Ragebot.SilentAim then return origAim(origin, ...) end
                    if State.Target.Locked and State.Target.Character and isValidLockedTarget(State.Target.Character) then
                        if math.random(1,100) <= Settings.Ragebot.Hitchance then
                            local aimPartName = Settings.Ragebot.AimPart
                            if Settings.Ragebot.Resolver then
                                Refs.resolverIndex = (Refs.resolverIndex % #Refs.resolverParts) + 1
                                aimPartName = Refs.resolverParts[Refs.resolverIndex]
                                local head = State.Target.Character:FindFirstChild("Head")
                                if head and isValidPart(head) and not isPartVisible(head) then aimPartName = "HumanoidRootPart" end
                            end
                            local part = State.Target.Character:FindFirstChild(aimPartName)
                            if not isValidPart(part) then part = resolveAimPart(State.Target.Character) end
                            if part then
                                local pos = part.Position
                                if Settings.Ragebot.Prediction then
                                    local vd = State.targetVelocity[State.Target.Character]
                                    if vd and vd.velocity and vd.velocity.Magnitude > 2 then
                                        local ping = LocalPlayer:GetNetworkPing()
                                        local d = (pos - origin).Magnitude
                                        local lt = ping + (d / 300)
                                        local hist = State.velocityHistory[State.Target.Character]
                                        if not hist then hist = {}; State.velocityHistory[State.Target.Character] = hist end
                                        table.insert(hist, vd.velocity)
                                        if #hist > 3 then table.remove(hist, 1) end
                                        local avg = Vector3.new(0,0,0)
                                        for _, v in ipairs(hist) do avg = avg + v end
                                        avg = avg / #hist
                                        pos = pos + avg * lt
                                    end
                                end
                                local dir = (pos - origin).Unit
                                local d = (pos - origin).Magnitude
                                if d < 0.5 then dir = (pos + Vector3.new(0,1,0) - origin).Unit end
                                return dir, d
                            end
                        end
                    end
                    return origAim(origin, ...)
                end
            end

            if type(origCanShoot) == "function" then
                Refs.GunHandler.getCanShoot = function(c)
                    if Settings.Ragebot.RapidFire then return true end
                    return origCanShoot(c)
                end
            end

            if type(origShoot) == "function" then
                Refs.GunHandler.shoot = function(self, data)
                    if not data then return origShoot(self, data) end
                    if data.Shooter == LocalPlayer.Character then
                        registerShot()
                    end
                    if Settings.Ragebot.NoSpread and State.Target.Locked and State.Target.Character then
                        local head = State.Target.Character:FindFirstChild("Head")
                        if head and isValidPart(head) then data.AimPosition = head.Position end
                    end
                    local shouldVoid = Settings.Ragebot.VoidSpamRage and Settings.Ragebot.TargetStrafe.Enabled and State.Target.Locked and LocalPlayer.Character
                    local hasTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if shouldVoid and State.Void.inVoid and hasTool then
                        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local tR = State.Target.Character and State.Target.Character:FindFirstChild("HumanoidRootPart")
                        if root and tR then
                            local op = State.Void.orbitPos or tR.Position
                            setRootCFrameSafely(root, CFrame.new(op, tR.Position), Vector3.new(0,0,0))
                        end
                    end
                    local result = origShoot(self, data)
                    if Settings.Ragebot.MultiGun then
                        for _, clone in ipairs(State.multiGunClones) do
                            if clone and clone.Parent then
                                local cd = table.clone(data)
                                cd.Handle = clone:FindFirstChild("Handle")
                                if cd.Handle then pcall(function() origShoot(self, cd) end) end
                            end
                        end
                    end
                    if shouldVoid and State.Void.inVoid and hasTool then
                        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then setRootCFrameSafely(root, CFrame.new(getRandomVoidPosition()), Vector3.new(0, -250 + math.random(-40, 40), 0)) end
                    end
                    return result
                end
            end
        end

        -- ============================================================
        -- VOID SPAM
        -- ============================================================
        local function voidSpamLoop()
            task.wait(0.2 + math.random() * 0.2)
            while Settings.Ragebot.VoidSpamRage and Settings.Ragebot.TargetStrafe.Enabled and State.Target.Locked do
                local char = LocalPlayer.Character; if not char then break end
                local root = char:FindFirstChild("HumanoidRootPart"); if not root then break end
                local target = State.Target.Character
                if not target or not isValidCharacter(target) then
                    if not State.Void.inVoid then
                        setRootCFrameSafely(root, CFrame.new(getRandomVoidPosition()), Vector3.new(0, -250 + math.random(-40, 40), 0))
                        State.Void.inVoid = true
                    end
                    jitteredWait(0.1); continue
                end
                local hasTool = char:FindFirstChildOfClass("Tool") ~= nil
                local be = char:FindFirstChild("BodyEffects")
                local isReloading = be and be:FindFirstChild("Reload") and be.Reload.Value == true
                local tR = target:FindFirstChild("HumanoidRootPart")
                if not tR then jitteredWait(0.1); continue end
                local radius = Settings.Ragebot.TargetStrafe.Distance
                local height = Settings.Ragebot.TargetStrafe.Height
                local angle = (tick() * Settings.Ragebot.TargetStrafe.Speed) % (2 * math.pi)
                local orbitPos = tR.Position + Vector3.new(math.sin(angle)*radius, height, math.cos(angle)*radius)
                State.Void.orbitPos = orbitPos
                if hasTool and not isReloading then
                    if State.Void.inVoid or (tick() - State.Void.lastOrbitTime) > 0.15 then
                        setRootCFrameSafely(root, CFrame.new(orbitPos, tR.Position), Vector3.new(0,0,0))
                        State.Void.inVoid = false
                        State.Void.lastOrbitTime = tick()
                    end
                else
                    if not State.Void.inVoid then
                        setRootCFrameSafely(root, CFrame.new(getRandomVoidPosition()), Vector3.new(0, -250 + math.random(-40, 40), 0))
                        State.Void.inVoid = true
                    end
                end
                jitteredWait(0.05)
            end
            if State.originalPosition and LocalPlayer.Character then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then setRootCFrameSafely(root, State.originalPosition, Vector3.new(0,0,0)) end
                State.originalPosition = nil
            end
            State.Void.inVoid = false; State.Void.reloading = false
        end

        local function startVoidSpam()
            if Refs.voidCoroutine then task.cancel(Refs.voidCoroutine); Refs.voidCoroutine = nil end
            if Settings.Ragebot.VoidSpamRage and Settings.Ragebot.TargetStrafe.Enabled then
                if not State.originalPosition then
                    local c = LocalPlayer.Character
                    if c then
                        local r = c:FindFirstChild("HumanoidRootPart")
                        if r then State.originalPosition = r.CFrame end
                    end
                end
                Refs.voidCoroutine = task.spawn(voidSpamLoop)
            else
                if State.originalPosition and LocalPlayer.Character then
                    local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if r then setRootCFrameSafely(r, State.originalPosition, Vector3.new(0,0,0)) end
                    State.originalPosition = nil
                end
                State.Void.inVoid = false
            end
        end
        local _oldApplySpectate = applySpectateSetting
        applySpectateSetting = function() _oldApplySpectate(); startVoidSpam() end

        -- ============================================================
        -- INVISIBLE DESYNC
        -- ============================================================
        local function stopInvisibleDesync()
            State.InvisibleDesync.running = false
            if State.InvisibleDesync.conn then
                State.InvisibleDesync.conn:Disconnect()
                State.InvisibleDesync.conn = nil
            end
            if Cap.setfflag then
                pcall(function()
                    setfflag("S2PhysicsSenderRate", "15")
                    setfflag("PhysicsSenderMaxBandwidthBps", "38760")
                end)
            end
            if Cap.sethiddenproperty then
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then pcall(function() sethiddenproperty(root, "NetworkIsSleeping", false) end) end
            end
        end

        local function startInvisibleDesync()
            if State.InvisibleDesync.running then return end
            if not Cap.setfflag or not Cap.sethiddenproperty then
                showNotification("Invisible Desync needs setfflag + sethiddenproperty", "warn")
                return
            end
            State.InvisibleDesync.running = true
            State.InvisibleDesync.conn = RunService.Heartbeat:Connect(function()
                if not State.InvisibleDesync.running then return end
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                State.InvisibleDesync.shouldSleep = not State.InvisibleDesync.shouldSleep
                pcall(function()
                    setfflag("S2PhysicsSenderRate", "2")
                    setfflag("PhysicsSenderMaxBandwidthBps", tostring(math.pi/3))
                    sethiddenproperty(root, "NetworkIsSleeping", State.InvisibleDesync.shouldSleep)
                    State.InvisibleDesync.origVel[1] = root.Velocity
                    State.InvisibleDesync.origVel[2] = root.AssemblyLinearVelocity
                    local jX = math.random(Settings.Exploits.InvisibleDesync.XMin, Settings.Exploits.InvisibleDesync.XMax)
                    local jY = math.random(Settings.Exploits.InvisibleDesync.YMin, Settings.Exploits.InvisibleDesync.YMax)
                    local jZ = math.random(Settings.Exploits.InvisibleDesync.ZMin, Settings.Exploits.InvisibleDesync.ZMax)
                    root.Velocity = root.Velocity + Vector3.new(jX, jY, jZ)
                    root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + Vector3.new(jX, jY, jZ)
                end)
                RunService.RenderStepped:Wait()
                pcall(function()
                    root.Velocity = State.InvisibleDesync.origVel[1]
                    root.AssemblyLinearVelocity = State.InvisibleDesync.origVel[2]
                    setfflag("S2PhysicsSenderRate", "1")
                end)
                State.InvisibleDesync.shouldSleep = not State.InvisibleDesync.shouldSleep
            end)
        end

        -- ============================================================
        -- CFRAME DESYNC
        -- ============================================================
        local function stopCFrameDesync()
            State.CFrameDesync.running = false
            if State.CFrameDesync.loopThread then
                task.cancel(State.CFrameDesync.loopThread)
                State.CFrameDesync.loopThread = nil
            end
            State.CFrameDesync.fakeCFrame = nil
            State.CFrameDesync.clientLocation = nil
        end

        local function startCFrameDesync()
            if State.CFrameDesync.running then return end
            State.CFrameDesync.running = true
            State.CFrameDesync.loopThread = task.spawn(function()
                while State.CFrameDesync.running do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then task.wait(0.5); continue end
                    local saved = root.CFrame
                    State.CFrameDesync.fakeCFrame = saved * CFrame.new(9e9, 0/0, 9e9)
                    task.wait(1)
                    if not State.CFrameDesync.running then break end
                    State.CFrameDesync.fakeCFrame = saved
                    task.wait()
                    State.CFrameDesync.fakeCFrame = nil
                    task.wait(1)
                end
                State.CFrameDesync.fakeCFrame = nil
            end)
        end

        local _postSimConn = RunService.PostSimulation:Connect(function()
            if not State.CFrameDesync.running then return end
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            State.CFrameDesync.clientLocation = root.CFrame
            if State.CFrameDesync.fakeCFrame then
                pcall(function() root.CFrame = State.CFrameDesync.fakeCFrame end)
            end
            RunService.PreRender:Wait()
            if State.CFrameDesync.clientLocation then
                pcall(function() root.CFrame = State.CFrameDesync.clientLocation end)
            end
            State.CFrameDesync.clientLocation = nil
        end)
        Connections:Add("CFrameDesyncPostSim", _postSimConn)

        do
            if Cap.getrawmetatable and Cap.hookmetamethod and Cap.checkcaller and Cap.newcclosure then
                pcall(function()
                    local origIndex
                    origIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
                        if key == "CFrame" and State.CFrameDesync.running and State.CFrameDesync.clientLocation then
                            local ok, name = pcall(function() return self.Name end)
                            local ok2, parent = pcall(function() return self.Parent end)
                            if ok and ok2 and name == "HumanoidRootPart" and parent == LocalPlayer.Character then
                                return State.CFrameDesync.clientLocation
                            end
                        end
                        return origIndex(self, key)
                    end))
                end)
            end
        end

        -- ============================================================
        -- NETWORK ANTI
        -- ============================================================
        local function startNetworkAnti()
            if Refs.networkAntiLoop then return end
            if not Cap.sethiddenproperty then
                showNotification("Network Anti needs sethiddenproperty", "warn")
                return
            end
            Refs.networkAntiLoop = task.spawn(function()
                while Settings.Player.NetworkAnti.Enabled do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        pcall(function()
                            sethiddenproperty(root, "NetworkIsSleeping", true)
                            task.wait()
                            sethiddenproperty(root, "NetworkIsSleeping", false)
                        end)
                    end
                    task.wait(0.1)
                end
                Refs.networkAntiLoop = nil
            end)
        end
        local function stopNetworkAnti()
            Settings.Player.NetworkAnti.Enabled = false
        end

        -- ============================================================
        -- FACE TARGET
        -- ============================================================
        local function updateFaceTarget()
            local c = LocalPlayer.Character
            if not c then State.Face.savedAutoRotate = nil; return end
            local h = c:FindFirstChildOfClass("Humanoid")
            local root = c:FindFirstChild("HumanoidRootPart")
            if not h or not isValidPart(root) then return end
            local should = Settings.Ragebot.FaceTarget and State.Target.Locked and State.Target.Character and isValidCharacter(State.Target.Character)
            if should then
                if State.Face.savedAutoRotate == nil then State.Face.savedAutoRotate = h.AutoRotate end
                h.AutoRotate = false
                local tR = State.Target.Character:FindFirstChild("HumanoidRootPart") or State.Target.Character:FindFirstChild("Head")
                if isValidPart(tR) then
                    local cur = root.Position
                    local lookAt = Vector3.new(tR.Position.X, cur.Y, tR.Position.Z)
                    if (lookAt - cur).Magnitude > 0.05 then pcall(function() root.CFrame = CFrame.lookAt(cur, lookAt) end) end
                end
            else
                if State.Face.savedAutoRotate ~= nil then
                    pcall(function() h.AutoRotate = State.Face.savedAutoRotate end)
                    State.Face.savedAutoRotate = nil
                end
            end
        end

        -- ============================================================
        -- CROSSHAIR
        -- ============================================================
        local function initCrosshair()
            if not Cap.Drawing then return end
            for i = 1, 4 do
                Draw.crosshairLines[i] = Drawing.new("Line")
                Draw.crosshairLines[i].Thickness = Settings.Visuals.Crosshair.Thickness
                Draw.crosshairLines[i].Color = Settings.Visuals.Crosshair.Color
                Draw.crosshairLines[i].Transparency = 1
                Draw.crosshairLines[i].Visible = false
            end
        end
        initCrosshair()

        local function updateCrosshair(dt)
            if not Cap.Drawing then return end
            local cx = Settings.Visuals.Crosshair
            local lines = Draw.crosshairLines
            if not cx.Enabled then
                for i = 1, 4 do if lines[i] then lines[i].Visible = false end end
                return
            end

            local center = nil

            if cx.FollowTarget and State.Target.Locked and State.Target.Character then
                local aimPart = resolveAimPart(State.Target.Character)
                if isValidPart(aimPart) then
                    local cam = getCamera()
                    if cam then
                        local p3 = cam:WorldToScreenPoint(aimPart.Position)
                        if p3.Z > 0 then
                            local inset = GuiService:GetGuiInset()
                            center = Vector2.new(p3.X, p3.Y + inset.Y)
                        end
                    end
                end
            end

            if not center then
                if cx.Mode == "center" then
                    local cam = getCamera()
                    if cam then
                        local vp = cam.ViewportSize
                        center = Vector2.new(vp.X / 2, vp.Y / 2)
                    end
                else
                    center = UserInputService:GetMouseLocation()
                end
            end

            if not center then return end

            if cx.Spin then
                Refs.crosshairSpin = (Refs.crosshairSpin + dt * cx.SpinSpeed) % 360
            end
            if cx.Resize then
                Refs.crosshairResizeT = Refs.crosshairResizeT + dt * cx.ResizeSpeed
            end

            local len = cx.Length
            local gap = cx.Radius
            if cx.Resize then
                local r = math.sin(Refs.crosshairResizeT) * 0.5 + 0.5
                len = len * (0.6 + r * 0.8)
                gap = gap + r * 4
            end

            local baseAngle = math.rad(Refs.crosshairSpin)
            for i = 1, 4 do
                local line = lines[i]
                if not line then continue end
                local a = baseAngle + (i - 1) * (math.pi / 2)
                local dx = math.cos(a)
                local dy = math.sin(a)
                local fromP = Vector2.new(center.X + dx * gap, center.Y + dy * gap)
                local toP = Vector2.new(center.X + dx * (gap + len), center.Y + dy * (gap + len))
                line.From = fromP
                line.To = toP
                line.Color = cx.Color
                line.Thickness = cx.Thickness
                line.Visible = true
            end
        end

        -- ============================================================
        -- CLIENT CHAMS
        -- ============================================================
        local function isInsideTool(part, char)
            local p = part.Parent
            while p and p ~= char do
                if p:IsA("Tool") then return true end
                p = p.Parent
            end
            return false
        end

        local function applyCharChams(char)
            local cc = Settings.Visuals.ClientChams
            local mat = Enum.Material[cc.CharMaterial] or Enum.Material.ForceField
            for _, v in ipairs(char:GetDescendants()) do
                if not (v:IsA("BasePart") or v:IsA("MeshPart")) then continue end
                if isInsideTool(v, char) then continue end
                if not State.origCharChamsProps[v] then
                    State.origCharChamsProps[v] = {
                        Material = v.Material,
                        Color = v.Color,
                        TextureID = v:IsA("MeshPart") and v.TextureID or nil,
                    }
                end
                v.Material = mat
                v.Color = cc.CharColor
                if v:IsA("MeshPart") then v.TextureID = "" end
            end
        end

        local function restoreCharChams()
            for part, props in pairs(State.origCharChamsProps) do
                if part and part.Parent then
                    pcall(function()
                        part.Material = props.Material
                        part.Color = props.Color
                        if props.TextureID ~= nil and part:IsA("MeshPart") then
                            part.TextureID = props.TextureID
                        end
                    end)
                end
            end
            State.origCharChamsProps = {}
        end

        local function applyWeaponChams(char)
            local cc = Settings.Visuals.ClientChams
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end
            local mat = Enum.Material[cc.WeaponMaterial] or Enum.Material.SmoothPlastic
            for _, v in ipairs(tool:GetDescendants()) do
                if not (v:IsA("BasePart") or v:IsA("MeshPart")) then continue end
                if not State.origWeapChamsProps[v] then
                    State.origWeapChamsProps[v] = {
                        Material = v.Material,
                        Color = v.Color,
                        TextureID = v:IsA("MeshPart") and v.TextureID or nil,
                    }
                end
                v.Material = mat
                v.Color = cc.WeaponColor
                if v:IsA("MeshPart") then v.TextureID = "" end
            end
        end

        local function restoreWeaponChams()
            for part, props in pairs(State.origWeapChamsProps) do
                if part and part.Parent then
                    pcall(function()
                        part.Material = props.Material
                        part.Color = props.Color
                        if props.TextureID ~= nil and part:IsA("MeshPart") then
                            part.TextureID = props.TextureID
                        end
                    end)
                end
            end
            State.origWeapChamsProps = {}
        end

        local function applyTrail()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            if root:FindFirstChild("tcc_Trail") then return end

            local a0 = Instance.new("Attachment", root)
            a0.Name = "tcc_TrailA0"
            a0.Position = Vector3.new(0, 1.5, 0)
            local a1 = Instance.new("Attachment", root)
            a1.Name = "tcc_TrailA1"
            a1.Position = Vector3.new(0, -1.5, 0)

            local t = Instance.new("Trail")
            t.Name = "tcc_Trail"
            t.Texture = "rbxassetid://1390780157"
            t.Color = ColorSequence.new(Settings.Visuals.ClientChams.TrailColor)
            t.Lifetime = Settings.Visuals.ClientChams.TrailLifetime
            t.Attachment0 = a0
            t.Attachment1 = a1
            t.Parent = root
        end

        local function removeTrail()
            local char = LocalPlayer.Character
            if not char then return end
            for _, v in ipairs(char:GetDescendants()) do
                if v.Name == "tcc_Trail" or v.Name == "tcc_TrailA0" or v.Name == "tcc_TrailA1" then
                    pcall(function() v:Destroy() end)
                end
            end
        end

        local function updateClientChams()
            local cc = Settings.Visuals.ClientChams
            local char = LocalPlayer.Character
            if not char then
                State.origCharChamsProps = {}
                State.origWeapChamsProps = {}
                return
            end

            if cc.CharEnabled then
                applyCharChams(char)
            elseif next(State.origCharChamsProps) ~= nil then
                restoreCharChams()
            end

            if cc.WeaponEnabled then
                applyWeaponChams(char)
            elseif next(State.origWeapChamsProps) ~= nil then
                restoreWeaponChams()
            end

            if cc.TrailEnabled then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local trail = root:FindFirstChild("tcc_Trail")
                    if trail then
                        pcall(function()
                            trail.Color = ColorSequence.new(cc.TrailColor)
                            trail.Lifetime = cc.TrailLifetime
                        end)
                    else
                        applyTrail()
                    end
                end
            else
                removeTrail()
            end
        end

        local function clearAllClientChams()
            restoreCharChams()
            restoreWeaponChams()
            removeTrail()
        end

        -- ============================================================
        -- BULLET RAY / TRACER / GUN SOUND MUTE
        -- ============================================================
        local MUTE_ATTR = "_tcc_muted"
        local function applyRemoveBulletTracer(desc)
            for _, d in ipairs(desc:GetDescendants()) do
                if d:IsA("Beam") then d.Enabled = false; d.Transparency = NumberSequence.new(1) end
            end
        end
        local function applyGunSoundMute()
            local c = LocalPlayer.Character
            local t = c and c:FindFirstChildOfClass("Tool")
            if Settings.Visuals.RemoveGunSound then
                if t then
                    for _, d in ipairs(t:GetDescendants()) do
                        if d:IsA("Sound") then
                            if d:GetAttribute(MUTE_ATTR) == nil then d:SetAttribute(MUTE_ATTR, d.Volume) end
                            if d.Volume ~= 0 then d.Volume = 0 end
                        end
                    end
                end
            else
                local function restoreContainer(container)
                    if not container then return end
                    for _, d in ipairs(container:GetDescendants()) do
                        if d:IsA("Sound") then
                            local orig = d:GetAttribute(MUTE_ATTR)
                            if orig ~= nil then
                                pcall(function() d.Volume = orig end)
                                d:SetAttribute(MUTE_ATTR, nil)
                            end
                        end
                    end
                end
                if t then restoreContainer(t) end
                if c then restoreContainer(c) end
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then restoreContainer(bp) end
            end
        end
        local function setupBulletRay()
            if Refs.bulletRayEntry then return end
            local conn = workspace.DescendantAdded:Connect(function(desc)
                if desc.Name ~= "BULLET_RAYS" then return end
                if desc:GetAttribute("OwnerCharacter") ~= LocalPlayer.Name then return end
                task.wait(0.01)
                if Settings.Visuals.RemoveBulletTracer then applyRemoveBulletTracer(desc) end
                if Settings.Visuals.BulletTracers.Enabled then
                    local gb = desc:FindFirstChild("GunBeam") or desc:FindFirstChild("NewGunBeam")
                    if gb then
                        gb.Texture = Settings.Visuals.BulletTracers.Texture == "Normal" and "rbxassetid://7151778302" or "rbxassetid://9150635648"
                        gb.LightEmission = Settings.Visuals.BulletTracers.GlowIntensity
                        gb.Segments = Settings.Visuals.BulletTracers.Segments
                        gb.LightInfluence = 0
                        gb.TextureSpeed = Settings.Visuals.BulletTracers.Speed
                        gb.Brightness = Settings.Visuals.BulletTracers.Brightness
                        gb.Color = ColorSequence.new(Settings.Visuals.BulletTracers.Color)
                        gb.Width0 = Settings.Visuals.BulletTracers.Width
                        gb.Width1 = Settings.Visuals.BulletTracers.Width
                        gb.Transparency = NumberSequence.new(0)
                        if Settings.Visuals.BulletTracers.RayTracing then
                            local start = desc.Position
                            local endp = start
                            local att1 = desc:FindFirstChild("Attachment1")
                            if att1 then endp = desc.CFrame:PointToWorldSpace(att1.Position) end
                            local tr = Instance.new("Part")
                            tr.Shape = Enum.PartType.Cylinder
                            tr.Size = Vector3.new(0.05, 0.05, (endp - start).Magnitude)
                            tr.Anchored = true; tr.CanCollide = false
                            tr.Material = Enum.Material.Neon
                            tr.Color = Settings.Visuals.BulletTracers.Color
                            tr.LightEmission = Settings.Visuals.BulletTracers.GlowIntensity
                            tr.CFrame = CFrame.lookAt(start, endp) * CFrame.new(0,0,-(endp-start).Magnitude/2)
                            tr.Parent = workspace
                            Debris:AddItem(tr, 0.5)
                            TweenService:Create(tr, TweenInfo.new(0.5), {Transparency = 1}):Play()
                        end
                    end
                end
            end)
            Refs.bulletRayEntry = Connections:Add("BulletRay", conn)
        end

        -- ============================================================
        -- ESP
        -- ============================================================
        local function updateESP()
            if not Settings.Visuals.ESP.Enabled then
                if next(State.espObjects) == nil then return end
                for _, o in pairs(State.espObjects) do
                    pcall(function() if o.highlight then o.highlight:Destroy() end; if o.billboard then o.billboard:Destroy() end end)
                end
                State.espObjects = {}; return
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == LocalPlayer then continue end
                local c = plr.Character
                if not isValidCharacter(c) then
                    if State.espObjects[plr] then
                        pcall(function() if State.espObjects[plr].highlight then State.espObjects[plr].highlight:Destroy() end; if State.espObjects[plr].billboard then State.espObjects[plr].billboard:Destroy() end end)
                        State.espObjects[plr] = nil
                    end
                    continue
                end
                local show = not (Settings.Visuals.ESP.TeamCheck and plr.Team == LocalPlayer.Team)
                if show then
                    local o = State.espObjects[plr]
                    if not o then
                        o = {}
                        local hl = Instance.new("Highlight")
                        hl.Name = "ESP_Highlight"; hl.Parent = c; hl.Adornee = c
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.OutlineTransparency = 0
                        hl.OutlineColor = Settings.Visuals.ESP.HighlightColor
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "ESP_Billboard"; bb.Parent = c
                        bb.AlwaysOnTop = true
                        bb.Size = UDim2.new(0,200,0,30)
                        bb.Adornee = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
                        bb.StudsOffset = Vector3.new(0,2.5,0)
                        local lbl = Instance.new("TextLabel")
                        lbl.Parent = bb; lbl.BackgroundTransparency = 1
                        lbl.Size = UDim2.new(1,0,1,0)
                        lbl.Font = Enum.Font.SourceSans; lbl.TextSize = 14
                        lbl.TextColor3 = Settings.Visuals.ESP.HighlightColor
                        lbl.TextStrokeTransparency = 0.5
                        lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
                        o.highlight = hl; o.billboard = bb; o.label = lbl
                        State.espObjects[plr] = o
                    end
                    o.highlight.FillColor = Settings.Visuals.ESP.HighlightColor
                    o.highlight.FillTransparency = Settings.Visuals.ESP.HighlightTransparency
                    o.highlight.OutlineColor = Settings.Visuals.ESP.HighlightColor
                    o.highlight.Enabled = true
                    o.label.Text = plr.DisplayName
                    o.label.TextColor3 = Settings.Visuals.ESP.HighlightColor
                    o.billboard.Enabled = true
                else
                    if State.espObjects[plr] then
                        pcall(function() if State.espObjects[plr].highlight then State.espObjects[plr].highlight:Destroy() end; if State.espObjects[plr].billboard then State.espObjects[plr].billboard:Destroy() end end)
                        State.espObjects[plr] = nil
                    end
                end
            end
        end

        -- ============================================================
        -- TARGET CIRCLE / FOV / LOCK TRACER
        -- ============================================================
        local function updateTargetCircle()
            if not Draw.targetCircle then
                Draw.targetCircle = Instance.new("Part")
                Draw.targetCircle.Shape = Enum.PartType.Cylinder
                Draw.targetCircle.Anchored = true
                Draw.targetCircle.CanCollide = false
                Draw.targetCircle.Material = Enum.Material.Neon
                Draw.targetCircle.Transparency = 1
                Draw.targetCircle.Parent = workspace
                Draw.targetCircle.Name = "tcc_TargetCircle"
            end
            if State.Target.Locked and State.Target.Character then
                local root = State.Target.Character:FindFirstChild("HumanoidRootPart")
                if isValidPart(root) then
                    Draw.targetCircle.Transparency = 0
                    Draw.targetCircle.CFrame = root.CFrame
                    Draw.targetCircle.Size = Vector3.new(2, 0.1, 2)
                else Draw.targetCircle.Transparency = 1 end
            else Draw.targetCircle.Transparency = 1 end
        end

        if Cap.Drawing then
            pcall(function()
                local ok1, circ = pcall(function() return Drawing.new("Circle") end)
                if ok1 and circ then
                    Draw.fovCircle = circ
                    Draw.fovCircle.Thickness = Settings.Ragebot.FOVThickness
                    Draw.fovCircle.Filled = false
                    Draw.fovCircle.Transparency = Settings.Ragebot.FOVTransparency
                    Draw.fovCircle.Visible = false
                    Draw.fovCircle.Color = Settings.Ragebot.FOVColor
                    Draw.fovCircle.Radius = Settings.Ragebot.FOVRadius
                end
                local ok2, line = pcall(function() return Drawing.new("Line") end)
                if ok2 and line then
                    Draw.lockTracerLine = line
                    Draw.lockTracerLine.Thickness = 1.5
                    Draw.lockTracerLine.Transparency = 0.5
                    Draw.lockTracerLine.Visible = false
                    Draw.lockTracerLine.Color = Settings.Ragebot.FOVColor
                end
            end)
        end

        local function updateFOVCircle()
            if not Cap.Drawing or not Draw.fovCircle then return end
            if Settings.Ragebot.ShowFOV then
                local center = getFOVCenter()
                Draw.fovCircle.Position = center
                Draw.fovCircle.Radius = Settings.Ragebot.FOVRadius
                Draw.fovCircle.Color = Settings.Ragebot.FOVColor
                Draw.fovCircle.Thickness = Settings.Ragebot.FOVThickness
                Draw.fovCircle.Transparency = Settings.Ragebot.FOVTransparency
                Draw.fovCircle.Visible = true
            else Draw.fovCircle.Visible = false end
        end

        local function updateLockTracer()
            if not Cap.Drawing or not Draw.lockTracerLine then return end
            if State.Target.Locked and State.Target.Character and Settings.Ragebot.LockTracer then
                local part = resolveAimPart(State.Target.Character)
                if isValidPart(part) then
                    local screen = getScreenPosition(part.Position)
                    local cam = getCamera()
                    if cam then
                        local p3 = cam:WorldToScreenPoint(part.Position)
                        if p3.Z > 0 then
                            local mp = UserInputService:GetMouseLocation()
                            Draw.lockTracerLine.From = Vector2.new(mp.X, mp.Y)
                            Draw.lockTracerLine.To = screen
                            Draw.lockTracerLine.Color = Settings.Ragebot.FOVColor
                            Draw.lockTracerLine.Visible = true
                        else Draw.lockTracerLine.Visible = false end
                    else Draw.lockTracerLine.Visible = false end
                else Draw.lockTracerLine.Visible = false end
            else Draw.lockTracerLine.Visible = false end
        end

        -- ============================================================
        -- WORLD MOD
        -- ============================================================
        local function toggleAmbience()
            local a = Settings.Graphics.Ambience
            if a.Enabled then
                if not State.RuntimeLighting then
                    State.RuntimeLighting = {
                        Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
                        Brightness = Lighting.Brightness,
                        ColorShiftBottom = Lighting.ColorShift_Bottom, ColorShiftTop = Lighting.ColorShift_Top,
                        FogColor = Lighting.FogColor, FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd,
                        TimeOfDay = Lighting.TimeOfDay, ClockTime = Lighting.ClockTime,
                    }
                end
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
                State.AmbienceToggled = true
            else
                if State.RuntimeLighting then
                    Lighting.Ambient = State.RuntimeLighting.Ambient
                    Lighting.OutdoorAmbient = State.RuntimeLighting.OutdoorAmbient
                    Lighting.Brightness = State.RuntimeLighting.Brightness
                    Lighting.ColorShift_Bottom = State.RuntimeLighting.ColorShiftBottom
                    Lighting.ColorShift_Top = State.RuntimeLighting.ColorShiftTop
                    Lighting.FogColor = State.RuntimeLighting.FogColor
                    Lighting.FogStart = State.RuntimeLighting.FogStart
                    Lighting.FogEnd = State.RuntimeLighting.FogEnd
                    Lighting.TimeOfDay = State.RuntimeLighting.TimeOfDay
                end
                State.AmbienceToggled = false
            end
        end
        local function startAmbienceClockLock()
            if Refs.ambienceClockEntry then return end
            local conn = RunService.Heartbeat:Connect(function()
                if State.AmbienceToggled and Settings.Graphics.Ambience.ClockTimeOverride then
                    Lighting.ClockTime = Settings.Graphics.Ambience.ClockTimeOverride
                end
            end)
            Refs.ambienceClockEntry = Connections:Add("AmbienceClock", conn)
        end
        local function applyNoRecoil()
            if not Settings.Ragebot.NoRecoil then return end
            local c = LocalPlayer.Character; if not c then return end
            local t = c:FindFirstChildOfClass("Tool"); if not t then return end
            local r = t:FindFirstChild("Recoil")
            if r and r:IsA("NumberValue") then r.Value = 0 end
        end
        local function getCurrentWeaponRange()
            local c = LocalPlayer.Character; if not c then return 200 end
            local t = c:FindFirstChildOfClass("Tool"); if not t then return 200 end
            local r = t:FindFirstChild("Range")
            if r and r:IsA("NumberValue") then return r.Value end
            return 200
        end

        -- ============================================================
        -- MISC UTILITY
        -- ============================================================
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
        local function teleportToLocation(n)
            local cf = teleportLocations[n]
            if cf and LocalPlayer.Character then
                local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if isValidPart(r) then r.CFrame = cf end
            end
        end
        local function forceReset()
            local c = LocalPlayer.Character
            if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.Health = 0 end end
        end
        local function rejoinServer() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end
        local function getAllShopItems()
            local shop = workspace.Ignored and workspace.Ignored.Shop
            if not shop then return {} end
            local items = {}
            for _, child in ipairs(shop:GetChildren()) do
                if child:IsA("Model") and child:FindFirstChildOfClass("ClickDetector") then
                    if string.match(child.Name, "^%[.*%]$") and not string.find(child.Name, " Ammo") then
                        table.insert(items, child.Name)
                    end
                end
            end
            table.sort(items); return items
        end
        local function getRealGuns()
            local items = getAllShopItems()
            if #items == 0 then
                return { "[AK47] - $2532","[AR] - $1126","[AUG] - $2195","[Deagle] - $11255","[Double-Barrel SG] - $1519","[Drum-Shotgun] - $1238","[DrumGun] - $3377","[Flamethrower] - $10130","[Flintlock] - $1463","[Glock] - $338","[GrenadeLauncher] - $11255","[LMG] - $4221","[P90] - $1126","[RPG] - $22510","[Revolver] - $1463","[Rifle] - $1745","[SMG] - $844","[Shotgun] - $1407","[SilencerAR] - $1407","[TacticalShotgun] - $1970","[Taser] - $1126" }
            end
            return items
        end
        local function buyItem(itemName)
            if not itemName or itemName == "" then return false end
            if type(fireclickdetector) ~= "function" then return false end
            local shop = workspace.Ignored and workspace.Ignored.Shop; if not shop then return false end
            local model = shop:FindFirstChild(itemName); if not model then return false end
            local cd = model:FindFirstChildOfClass("ClickDetector"); if not cd then return false end
            local c = LocalPlayer.Character; if not c then return false end
            local root = c:FindFirstChild("HumanoidRootPart"); if not isValidPart(root) then return false end
            local old = root.CFrame
            local tPos = model:FindFirstChild("Head") and model.Head.Position or model:GetBoundingBox().Position
            root.CFrame = CFrame.new(tPos + Vector3.new(0, 3, 0))
            task.wait(0.2); fireclickdetector(cd); task.wait(0.1)
            root.CFrame = old
            return true
        end

        -- ============================================================
        -- PLAYER MODS
        -- ============================================================
        local CFrameWalkSpeed_BASE = 16
        local function applyCFrameWalkSpeed(dt)
            if not Settings.Player.WalkSpeedEnabled then return end
            if Settings.Player.WalkSpeedMode ~= "CFrame" then return end
            local c = LocalPlayer.Character; if not c then return end
            local root = c:FindFirstChild("HumanoidRootPart"); if not isValidPart(root) then return end
            local h = c:FindFirstChildOfClass("Humanoid"); if not h then return end
            h.WalkSpeed = CFrameWalkSpeed_BASE
            local md = h.MoveDirection
            if md.Magnitude < 0.01 then return end
            local extra = Settings.Player.WalkSpeed - CFrameWalkSpeed_BASE
            if extra <= 0 then return end
            pcall(function() root.CFrame = root.CFrame + md * extra * dt end)
        end
        local function applyPlayerMods(dt)
            if not State.Character.humanoid or not State.Character.humanoid.Parent then return end
            local h = State.Character.humanoid
            if Settings.Player.WalkSpeedEnabled then
                if Settings.Player.WalkSpeedMode == "Humanoid" then h.WalkSpeed = Settings.Player.WalkSpeed end
            else
                h.WalkSpeed = State.Character.walkSpeed or 16
            end
            local c = LocalPlayer.Character
            if c then
                if Settings.Player.NoClipEnabled then
                    for _, part in pairs(c:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if not State.noClipOriginalStates[part] then State.noClipOriginalStates[part] = part.CanCollide end
                            part.CanCollide = false
                        end
                    end
                else
                    for part, orig in pairs(State.noClipOriginalStates) do
                        if part and part.Parent then part.CanCollide = orig end
                    end
                    State.noClipOriginalStates = {}
                end
            end
            if Settings.Player.AntiVoid and State.Character.rootPart then
                if State.Character.rootPart.Position.Y < -50 then State.Character.rootPart.CFrame = CFrame.new(0, 50, 0) end
            end
            if Settings.Visuals.NoFlash and Settings.Visuals.NoFlash.Enabled then
                local cam = getCamera()
                if cam then
                    local f = cam:FindFirstChild("FlashEffect"); if f then f.Enabled = false end
                    local d = cam:FindFirstChild("DamageEffect"); if d then d.Enabled = false end
                end
            end
            applyNoRecoil()
        end

        local function checkAutoReload()
            if not Settings.Ragebot.AutoReload then return end
            local c = LocalPlayer.Character; if not c then return end
            local t = c:FindFirstChildOfClass("Tool"); if not t then return end
            local a = t:FindFirstChild("Ammo")
            if a and a.Value <= 0 and MainEvent then
                task.wait(math.random(50, 300) / 1000)
                MainEvent:FireServer("Reload", t)
            end
        end
        local function antiStompCheck()
            if not Settings.Ragebot.AntiStomp then return end
            local c = LocalPlayer.Character; if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid"); if not h then return end
            local be = c:FindFirstChild("BodyEffects")
            local KO = be and be:FindFirstChild("K.O") and be["K.O"].Value
            local grabbed = c:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
            if KO or grabbed then
                h.PlatformStand = true; h.WalkSpeed = 0; h.JumpHeight = 0; h.Health = 0
                for _, p in pairs(c:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end
                if be then be:ClearAllChildren() end
                if MainEvent then MainEvent:FireServer("Respawn") end
            end
        end

        local function updateWatermark()
            if not Settings.Visuals.Watermark.Enabled then
                if Draw.watermarkText then Draw.watermarkText:Remove(); Draw.watermarkText = nil end
                if Draw.watermarkStatus then Draw.watermarkStatus:Remove(); Draw.watermarkStatus = nil end
                return
            end
            if not Cap.Drawing then return end
            if not Draw.watermarkText then
                Draw.watermarkText = Drawing.new("Text")
                Draw.watermarkText.Text = "tapped.cc"; Draw.watermarkText.Font = 3
                Draw.watermarkText.Outline = true; Draw.watermarkText.OutlineColor = Color3.fromRGB(0,0,0)
                Draw.watermarkText.Visible = true
            end
            if not Draw.watermarkStatus then
                Draw.watermarkStatus = Drawing.new("Text")
                Draw.watermarkStatus.Text = Status.text; Draw.watermarkStatus.Font = 2
                Draw.watermarkStatus.Outline = true; Draw.watermarkStatus.OutlineColor = Color3.fromRGB(0,0,0)
                Draw.watermarkStatus.Visible = true
            end
            local cursor = UserInputService:GetMouseLocation()
            local mainSize = Settings.Visuals.Watermark.Size
            local statusSize = Settings.Visuals.Watermark.StatusSize or mainSize * 0.8
            Draw.watermarkText.Color = Settings.Visuals.Watermark.Color
            Draw.watermarkText.Size = mainSize
            local mainB = Draw.watermarkText.TextBounds
            Draw.watermarkText.Position = Vector2.new(cursor.X + 16, cursor.Y + 8)
            Draw.watermarkStatus.Color = Settings.Visuals.Watermark.Color
            Draw.watermarkStatus.Size = statusSize
            local statusB = Draw.watermarkStatus.TextBounds
            Draw.watermarkStatus.Position = Vector2.new(cursor.X + 16 + (mainB.X - statusB.X) / 2, cursor.Y + 8 + mainB.Y + 2)
            if Draw.watermarkStatus.Text ~= Status.text then Draw.watermarkStatus.Text = Status.text end
        end
        local function checkShootingStatus()
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local c = LocalPlayer.Character
                if c then
                    local t = c:FindFirstChildOfClass("Tool")
                    if t then
                        local a = t:FindFirstChild("Ammo")
                        if not a or a.Value > 0 then Status.isShooting = true; Status.shootTimer = tick(); Status.text = "Shooting" end
                    end
                end
            end
            if Status.isShooting and (tick() - Status.shootTimer > 0.5) then
                Status.isShooting = false
                if not Status.isReloading then Status.text = "Safe" end
            end
        end
        local function checkReloadingStatus()
            if UserInputService:IsKeyDown(Enum.KeyCode.R) and not Status.isReloading then
                local c = LocalPlayer.Character
                if c then
                    local t = c:FindFirstChildOfClass("Tool")
                    if t then
                        local a = t:FindFirstChild("Ammo")
                        if a and a:IsA("IntValue") then
                            local ma = t:FindFirstChild("MaxAmmo") or a:FindFirstChild("MaxAmmo")
                            if ma and (ma:IsA("NumberValue") or ma:IsA("IntValue")) and a.Value > 0 and a.Value < ma.Value then
                                Status.isReloading = true; Status.reloadTimer = tick(); Status.text = "Reloading"
                            end
                        end
                    end
                end
            end
            if Status.isReloading and (tick() - Status.reloadTimer > 2.5) then
                Status.isReloading = false
                if not Status.isShooting then Status.text = "Safe" end
            end
        end

        -- ============================================================
        -- FLY
        -- ============================================================
        local function startFly()
            if Refs.flyRunning then return end
            local c = LocalPlayer.Character; if not c then return end
            local root = c:FindFirstChild("HumanoidRootPart"); if not isValidPart(root) then return end
            Refs.flyCore = Instance.new("Part")
            Refs.flyCore.Name = "IgnoredVelocity"
            Refs.flyCore.Size = Vector3.new(0.05,0.05,0.05)
            Refs.flyCore.Anchored = false; Refs.flyCore.CanCollide = false
            Refs.flyCore.Parent = workspace
            Refs.flyWeld = Instance.new("Weld", Refs.flyCore)
            Refs.flyWeld.Part0 = Refs.flyCore; Refs.flyWeld.Part1 = root; Refs.flyWeld.C0 = CFrame.new(0,0,0)
            Refs.flyPos = Instance.new("BodyPosition", Refs.flyCore)
            Refs.flyPos.Name = "IgnoredVelocity"
            Refs.flyPos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
            Refs.flyPos.position = Refs.flyCore.Position
            Refs.flyGyro = Instance.new("BodyGyro", Refs.flyCore)
            Refs.flyGyro.maxTorque = Vector3.new(9e9,9e9,9e9)
            Refs.flyGyro.cframe = Refs.flyCore.CFrame
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h.PlatformStand = true; h.AutoJumpEnabled = false end
            Refs.flyRunning = true
        end
        local function stopFly()
            if not Refs.flyRunning then return end
            Refs.flyRunning = false
            if Refs.flyCore then Refs.flyCore:Destroy(); Refs.flyCore=nil end
            if Refs.flyWeld then Refs.flyWeld:Destroy(); Refs.flyWeld=nil end
            if Refs.flyPos then Refs.flyPos:Destroy(); Refs.flyPos=nil end
            if Refs.flyGyro then Refs.flyGyro:Destroy(); Refs.flyGyro=nil end
            local c = LocalPlayer.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then
                    h.PlatformStand = false; h.AutoJumpEnabled = true
                    h.WalkSpeed = State.Character.walkSpeed or 16
                    h.JumpPower = State.Character.jumpPower or 50
                end
            end
        end
        local function setFlyEnabled(enabled) if enabled then startFly() else stopFly() end; Settings.Player.Fly.Enabled = enabled end
        local function startFlyMovementLoop()
            if Refs.flyMovementEntry then return end
            local conn = RunService.RenderStepped:Connect(function(dt)
                if not Refs.flyRunning or not Refs.flyPos or not Refs.flyGyro then return end
                local cam = getCamera(); if not cam then return end
                local speed = Settings.Player.Fly.Speed * dt
                local newPos = Refs.flyGyro.cframe - Refs.flyGyro.cframe.p + Refs.flyPos.position
                if Refs.flyKeys.w then newPos = newPos + cam.CoordinateFrame.lookVector * speed end
                if Refs.flyKeys.s then newPos = newPos - cam.CoordinateFrame.lookVector * speed end
                if Refs.flyKeys.d then newPos = newPos * CFrame.new(speed,0,0) end
                if Refs.flyKeys.a then newPos = newPos * CFrame.new(-speed,0,0) end
                Refs.flyPos.position = newPos.p
                Refs.flyGyro.cframe = cam.CoordinateFrame
            end)
            Refs.flyMovementEntry = Connections:Add("Fly", conn)
        end

        local function setSilentReloadEnabled(enabled)
            Settings.Ragebot.SilentReload = enabled
            if Refs.silentReloadEntry then Connections:Remove(Refs.silentReloadEntry); Refs.silentReloadEntry = nil end
            if enabled then
                local c = LocalPlayer.Character
                if c then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h then
                        local targetAnim = "rbxassetid://2877910736"
                        local conn = RunService.Heartbeat:Connect(function()
                            if not h or not h.Parent then return end
                            for _, track in pairs(h:GetPlayingAnimationTracks()) do
                                local a = track.Animation
                                if a and a.AnimationId == targetAnim then track:Stop() end
                            end
                        end)
                        Refs.silentReloadEntry = Connections:Add("SilentReload", conn)
                    end
                end
            end
        end

        -- ============================================================
        -- HITBOX EXPANDER
        -- ============================================================
        local function getOutline(part)
            if not isValidPart(part) then return nil end
            local out = part:FindFirstChild("Outline")
            if not out then
                out = #State.outlinePool > 0 and table.remove(State.outlinePool) or Instance.new("SelectionBox")
                out.LineThickness = 0.05
                out.Color3 = Settings.Ragebot.HitboxExpander.OutlineColor
                out.Name = "Outline"
            end
            out.Adornee = part; out.Parent = part
            out.Transparency = Settings.Ragebot.HitboxExpander.OutlineTransparency
            return out
        end
        local function releaseOutline(out)
            if out then out.Adornee = nil; out.Parent = nil; table.insert(State.outlinePool, out) end
        end
        local function saveOriginalHitboxState(char)
            if not char then return end
            local r = char:FindFirstChild("HumanoidRootPart"); if not isValidPart(r) then return end
            if State.OriginalHitboxState[char] then return end
            State.OriginalHitboxState[char] = { Size = r.Size, Transparency = r.Transparency, BrickColor = r.BrickColor, Material = r.Material, CanCollide = r.CanCollide, CanTouch = r.CanTouch, CanQuery = r.CanQuery, Massless = r.Massless }
        end
        local function restoreHitboxState(char)
            if not char then return end
            local d = State.OriginalHitboxState[char]; if not d then return end
            local r = char:FindFirstChild("HumanoidRootPart")
            if isValidPart(r) then
                r.Size = d.Size; r.Transparency = d.Transparency; r.BrickColor = d.BrickColor
                r.Material = d.Material; r.CanCollide = d.CanCollide; r.CanTouch = d.CanTouch
                r.CanQuery = d.CanQuery; r.Massless = d.Massless
                local o = r:FindFirstChild("Outline"); if o then releaseOutline(o) end
            end
            State.OriginalHitboxState[char] = nil
        end
        local function restoreAllHitboxes()
            for char, _ in pairs(State.OriginalHitboxState) do restoreHitboxState(char) end
            State.OriginalHitboxState = {}; Refs.lastHitboxTarget = nil
        end
        local function updateHitboxes()
            if not Settings.Ragebot.HitboxExpander.Enabled then return end
            local target = State.Target.Locked and State.Target.Character or nil
            if target and not isValidCharacter(target) then target = nil end
            if Refs.lastHitboxTarget and Refs.lastHitboxTarget ~= target then restoreHitboxState(Refs.lastHitboxTarget) end
            if target then
                local root = target:FindFirstChild("HumanoidRootPart")
                if isValidPart(root) then
                    saveOriginalHitboxState(target); Refs.lastHitboxTarget = target
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
                    local o = root:FindFirstChild("Outline")
                    if o then o.Color3 = Settings.Ragebot.HitboxExpander.OutlineColor; o.Transparency = Settings.Ragebot.HitboxExpander.OutlineTransparency end
                end
            else
                if Refs.lastHitboxTarget then restoreHitboxState(Refs.lastHitboxTarget); Refs.lastHitboxTarget = nil end
            end
        end
        local function setHitboxExpanderEnabled(enabled)
            Settings.Ragebot.HitboxExpander.Enabled = enabled
            if enabled then
                if not Refs.hitboxEntry then
                    Refs.hitboxEntry = Connections:Add("Hitbox", RunService.Heartbeat:Connect(updateHitboxes))
                end
            else
                if Refs.hitboxEntry then Connections:Remove(Refs.hitboxEntry); Refs.hitboxEntry = nil end
                restoreAllHitboxes()
            end
        end

        -- ============================================================
        -- RAPID FIRE
        -- ============================================================
        local function hookToolForRapidFire(tool)
            if not tool:IsA("Tool") then return end
            if not Cap.getconnections then return end
            if type(debug.getinfo) ~= "function" or type(debug.getupvalue) ~= "function" or type(debug.setupvalue) ~= "function" then return end
            for _, conn in ipairs(getconnections(tool.Activated)) do
                pcall(function()
                    local info = debug.getinfo(conn.Function, "u")
                    if info then
                        for i = 1, info.nups do
                            local v = debug.getupvalue(conn.Function, i)
                            if type(v) == "number" then
                                table.insert(State.rapidFireHooks, {conn = conn, index = i, original = v})
                                debug.setupvalue(conn.Function, i, 0)
                            end
                        end
                    end
                end)
            end
        end
        local function startRapidFireLoop()
            if Refs.rapidFireLoopRunning then return end
            Refs.rapidFireLoopRunning = true
            Refs.rapidFireLoopThread = task.spawn(function()
                while Refs.rapidFireLoopRunning do
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        local c = LocalPlayer.Character
                        if c then
                            local t = c:FindFirstChildOfClass("Tool")
                            if t then
                                local a = t:FindFirstChild("Ammo")
                                if not a or a.Value > 0 then
                                    local canFire = true
                                    local cd = t:FindFirstChild("Cooldown") or t:FindFirstChild("FireRate")
                                    if cd and cd:IsA("NumberValue") then
                                        local last = State.lastFireTime[t] or 0
                                        if tick() - last < cd.Value then canFire = false else State.lastFireTime[t] = tick() end
                                    end
                                    if canFire then t:Activate() end
                                end
                            end
                        end
                    end
                    task.wait(Settings.Ragebot.RapidFireDelay)
                end
            end)
        end
        local function stopRapidFireLoop()
            Refs.rapidFireLoopRunning = false
            if Refs.rapidFireLoopThread then task.cancel(Refs.rapidFireLoopThread); Refs.rapidFireLoopThread = nil end
        end
        local function applyRapidFire()
            for _, hook in ipairs(State.rapidFireHooks) do
                pcall(function() debug.setupvalue(hook.conn.Function, hook.index, hook.original) end)
            end
            State.rapidFireHooks = {}
            for _, conn in ipairs(State.rapidFireChildConns) do
                if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
            end
            State.rapidFireChildConns = {}
            stopRapidFireLoop()
            if not Settings.Ragebot.RapidFire then return end
            if not Cap.getconnections then return end
            local c = LocalPlayer.Character
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if c then
                for _, t in ipairs(c:GetChildren()) do hookToolForRapidFire(t) end
                local conn = c.ChildAdded:Connect(function(child) if child:IsA("Tool") then task.wait(0.1); hookToolForRapidFire(child) end end)
                table.insert(State.rapidFireChildConns, conn)
            end
            if bp then
                for _, t in ipairs(bp:GetChildren()) do hookToolForRapidFire(t) end
                local conn = bp.ChildAdded:Connect(function(child) if child:IsA("Tool") then task.wait(0.1); hookToolForRapidFire(child) end end)
                table.insert(State.rapidFireChildConns, conn)
            end
            startRapidFireLoop()
        end

        -- ============================================================
        -- MULTI GUN
        -- ============================================================
        local function createMultiGunClone(tool)
            if not tool or not tool:IsA("Tool") then return nil end
            local clone = tool:Clone()
            clone.Name = tool.Name .. "_Multi"
            clone.Parent = LocalPlayer.Character
            local handle = clone:FindFirstChild("Handle")
            if not handle then
                handle = Instance.new("Part")
                handle.Name = "Handle"; handle.Size = Vector3.new(1,1,1)
                handle.Transparency = 1; handle.CanCollide = false; handle.Parent = clone
            end
            local rh = LocalPlayer.Character:FindFirstChild("RightHand")
            if rh then
                local w = Instance.new("Weld")
                w.Part0 = rh; w.Part1 = handle
                w.C0 = CFrame.new(0, -1, 0); w.Parent = handle
            end
            return clone
        end
        local function updateMultiGun()
            for _, clone in pairs(State.multiGunClones) do pcall(function() clone:Destroy() end) end
            State.multiGunClones = {}
            if not Settings.Ragebot.MultiGun then return end
            local c = LocalPlayer.Character; if not c then return end
            local t = c:FindFirstChildOfClass("Tool"); if not t then return end
            for i = 1, 2 do
                local clone = createMultiGunClone(t)
                if clone then table.insert(State.multiGunClones, clone) end
            end
        end

        -- ============================================================
        -- CHARACTER LIFECYCLE
        -- ============================================================
        local function setupCharacterLifecycle()
            if Refs.charAddedEntry then Connections:Remove(Refs.charAddedEntry); Refs.charAddedEntry = nil end
            local conn = LocalPlayer.CharacterAdded:Connect(function(newChar)
                State.origCharChamsProps = {}
                State.origWeapChamsProps = {}
                refreshCharacter(newChar)
                if Settings.Player.Fly.Enabled then startFly() end
                if Settings.Ragebot.SilentReload then setSilentReloadEnabled(true) end
                if Settings.Ragebot.HitboxExpander.Enabled then setHitboxExpanderEnabled(true) end
                if Settings.Ragebot.RapidFire then applyRapidFire() end
                updateMultiGun()
                if State.Target.Locked and State.Target.Player then
                    local ntc = State.Target.Player.Character
                    if ntc and isValidCharacter(ntc) then
                        State.Target.Character = ntc
                        if Settings.Ragebot.Spectate then
                            local h = ntc:FindFirstChildOfClass("Humanoid")
                            if h then local cam = getCamera(); if cam then cam.CameraSubject = h; cam.CameraType = Enum.CameraType.Custom end end
                        end
                    end
                else
                    local h = newChar:FindFirstChildOfClass("Humanoid")
                    if h then local cam = getCamera(); if cam then cam.CameraSubject = h; cam.CameraType = Enum.CameraType.Custom end end
                end
                startVoidSpam()
            end)
            Refs.charAddedEntry = Connections:Add("CharacterLifecycle", conn)
        end

        -- ============================================================
        -- CLEANUP
        -- ============================================================
        Cleanup:Add(function()
            Connections:RemoveAll()
            stopInvisibleDesync()
            stopCFrameDesync()
            if State.Character.humanoid and State.Character.humanoid.Parent then
                if State.Character.walkSpeed then State.Character.humanoid.WalkSpeed = State.Character.walkSpeed end
                if State.Character.jumpPower then State.Character.humanoid.JumpPower = State.Character.jumpPower end
                if State.Face.savedAutoRotate ~= nil then
                    pcall(function() State.Character.humanoid.AutoRotate = State.Face.savedAutoRotate end)
                end
            end
            for _, c in pairs(State.multiGunClones) do pcall(function() c:Destroy() end) end
            State.multiGunClones = {}
            clearAllClientChams()
            for _, o in pairs(State.espObjects) do pcall(function() if o.highlight then o.highlight:Destroy() end; if o.billboard then o.billboard:Destroy() end end) end
            State.espObjects = {}
            if Draw.fovCircle then pcall(function() Draw.fovCircle:Remove() end) end
            if Draw.lockTracerLine then pcall(function() Draw.lockTracerLine:Remove() end) end
            if Draw.watermarkText then pcall(function() Draw.watermarkText:Remove() end) end
            if Draw.watermarkStatus then pcall(function() Draw.watermarkStatus:Remove() end) end
            if Draw.targetCircle then pcall(function() Draw.targetCircle:Destroy() end) end
            for _, l in ipairs(Draw.crosshairLines) do pcall(function() l:Remove() end) end
            for char, d in pairs(State.OriginalHitboxState) do
                local r = char and char:FindFirstChild("HumanoidRootPart")
                if isValidPart(r) then
                    r.Size = d.Size; r.Transparency = d.Transparency; r.BrickColor = d.BrickColor
                    r.Material = d.Material; r.CanCollide = d.CanCollide; r.CanTouch = d.CanTouch
                    r.CanQuery = d.CanQuery; r.Massless = d.Massless
                end
            end
            State.OriginalHitboxState = {}
            if Refs.voidCoroutine then task.cancel(Refs.voidCoroutine); Refs.voidCoroutine = nil end
            stopRapidFireLoop()
            for _, conn in ipairs(State.rapidFireChildConns) do
                if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
            end
            if Refs.originalGunHandlerMethods and Refs.GunHandler then
                local gh = Refs.GunHandler
                if type(Refs.originalGunHandlerMethods.getAim) == "function" then gh.getAim = Refs.originalGunHandlerMethods.getAim end
                if type(Refs.originalGunHandlerMethods.getCanShoot) == "function" then gh.getCanShoot = Refs.originalGunHandlerMethods.getCanShoot end
                if type(Refs.originalGunHandlerMethods.shoot) == "function" then gh.shoot = Refs.originalGunHandlerMethods.shoot end
            end
            State.Target.Locked = false; State.Target.Character = nil; State.Target.Player = nil
            State.Void.inVoid = false; State.Void.reloading = false
            State.originalPosition = nil
            State.Shots = {}
            State.HPSnapshot = {}
        end)

        -- ============================================================
        -- MAIN LOOP
        -- ============================================================
        local function safeCall(feature, func)
            local ok, err = pcall(func)
            if not ok then warn("[tapped.cc][MainLoop] " .. feature .. " ERROR: " .. tostring(err)) end
        end
        local function cleanVelocityCache()
            for char, _ in pairs(State.targetVelocity) do
                if not char or not char.Parent or not isValidCharacter(char) then
                    State.targetVelocity[char] = nil; State.velocityHistory[char] = nil
                end
            end
        end
        local function checkAutoRespawn()
            if not Settings.Player.AutoRespawn then return end
            if State.Character.humanoid and State.Character.humanoid.Health <= 0 then
                if Refs.autoRespawnTask then return end
                Refs.autoRespawnTask = task.spawn(function()
                    task.wait(Settings.Player.AutoRespawnDelay)
                    if State.Character.humanoid and State.Character.humanoid.Health <= 0 then
                        if MainEvent then MainEvent:FireServer("Respawn") end
                    end
                    Refs.autoRespawnTask = nil
                end)
            end
        end

        local function mainLoop(dt)
            safeCall("PlayerMods", function() applyPlayerMods(dt) end)
            safeCall("CFrameWalkSpeed", function() applyCFrameWalkSpeed(dt) end)
            safeCall("AutoReload", checkAutoReload)
            safeCall("ClientChams", updateClientChams)
            safeCall("ESP", updateESP)
            safeCall("TargetCircle", updateTargetCircle)
            safeCall("AntiStomp", antiStompCheck)
            safeCall("FOV", updateFOVCircle)
            safeCall("LockTracer", updateLockTracer)
            safeCall("Crosshair", function() updateCrosshair(dt) end)
            safeCall("CameraFOV", function() if getCamera() then getCamera().FieldOfView = Settings.Visuals.CameraFOV end end)
            safeCall("LowGraphics", function()
                if Settings.Graphics.LowGraphics then Lighting.GlobalShadows = false else Lighting.GlobalShadows = true end
            end)
            safeCall("AutoRespawn", checkAutoRespawn)
            safeCall("Watermark", updateWatermark)
            safeCall("ShootingStatus", checkShootingStatus)
            safeCall("ReloadingStatus", checkReloadingStatus)
            safeCall("FaceTarget", updateFaceTarget)
            safeCall("HealthSnapshots", pollHealthSnapshots)
            safeCall("AmmoShot", checkAmmoShot)
            safeCall("ShotTimeouts", updateShotTimeouts)
            safeCall("GunSoundMute", applyGunSoundMute)
            safeCall("VelocityTracking", function()
                cleanVelocityCache()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr == LocalPlayer then continue end
                    local c = plr.Character
                    if c and isValidCharacter(c) then
                        local r = c:FindFirstChild("HumanoidRootPart")
                        if isValidPart(r) then
                            if not State.targetVelocity[c] then State.targetVelocity[c] = {} end
                            State.targetVelocity[c].velocity = r.AssemblyLinearVelocity
                            State.targetVelocity[c].lastUpdate = tick()
                        end
                    end
                end
            end)
            safeCall("TargetPersistence", function()
                if State.Target.Locked and State.Target.Player then
                    local plr = State.Target.Player
                    local c = plr.Character
                    if c and isValidCharacter(c) and c ~= State.Target.Character then
                        State.Target.Character = c
                        if Settings.Ragebot.Spectate then
                            local h = c:FindFirstChildOfClass("Humanoid")
                            if h then local cam = getCamera(); if cam then cam.CameraSubject = h; cam.CameraType = Enum.CameraType.Custom end end
                        end
                    end
                end
            end)
            safeCall("Targeting", function()
                local c = LocalPlayer.Character
                if Settings.Ragebot.AutoSelect and (tick() - Refs.lastAutoSelectTime > 0.1) then
                    Refs.lastAutoSelectTime = tick()
                    local best = findBestTarget()
                    if best and (not State.Target.Locked or State.Target.Character ~= best) then lockTarget(best) end
                end
                if State.Target.Locked and State.Target.Player then
                    local plr = State.Target.Player
                    local target = plr.Character
                    if not target or not isValidCharacter(target) then return end
                    State.Target.Character = target
                    if not hasProtection(target) then
                        if Settings.Ragebot.TargetStrafe.Enabled and c and not Settings.Ragebot.VoidSpamRage then
                            local root = c:FindFirstChild("HumanoidRootPart")
                            local tR = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
                            if isValidPart(root) and isValidPart(tR) then
                                Refs.orbitAngle = Refs.orbitAngle + dt * Settings.Ragebot.TargetStrafe.Speed * 2 * math.pi
                                local rad = Settings.Ragebot.TargetStrafe.Distance
                                local hgt = Settings.Ragebot.TargetStrafe.Height
                                if Settings.Ragebot.Unhittable then
                                    rad = rad + math.random(-3, 3)
                                    hgt = hgt + math.random(-2, 2)
                                    Refs.orbitAngle = Refs.orbitAngle + math.random(-0.5, 0.5) * dt
                                end
                                local want = tR.Position + Vector3.new(math.sin(Refs.orbitAngle)*rad, hgt, math.cos(Refs.orbitAngle)*rad)
                                root.CFrame = CFrame.new(want, tR.Position)
                            end
                        end
                        if Settings.Ragebot.AutoShoot and isValidLockedTarget(target) then
                            local tH = target:FindFirstChildOfClass("Humanoid")
                            if tH and tH.Health > Settings.Ragebot.StopAutoShootBelowHealth then
                                local part = resolveAimPart(target)
                                if isValidPart(part) then
                                    local can = true
                                    if Settings.Ragebot.AutoShootVisibilityCheck then can = isPartVisible(part) end
                                    if can then
                                        local range = getCurrentWeaponRange()
                                        if range and c and c:FindFirstChild("HumanoidRootPart")
                                           and (part.Position - c.HumanoidRootPart.Position).Magnitude > range then can = false end
                                    end
                                    if can then
                                        local t = c:FindFirstChildOfClass("Tool")
                                        if t then
                                            local a = t:FindFirstChild("Ammo")
                                            if not a or a.Value > 0 then
                                                t:Activate(); Status.isShooting = true; Status.shootTimer = tick(); Status.text = "Shooting"
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if Settings.Ragebot.AutoStomp then
                        local tH = target:FindFirstChildOfClass("Humanoid")
                        local be = target:FindFirstChild("BodyEffects")
                        local KO = be and be:FindFirstChild("K.O") and be["K.O"].Value
                        local hp = tH and tH.Health or 0
                        if (hp <= 10) or KO then
                            local c2 = LocalPlayer.Character
                            if c2 then
                                local lr = c2:FindFirstChild("HumanoidRootPart")
                                local tr = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso") or target:FindFirstChild("Head")
                                if isValidPart(lr) and isValidPart(tr) then
                                    lr.CFrame = tr.CFrame + Vector3.new(0, 2, 0)
                                    if MainEvent then MainEvent:FireServer("Stomp") end
                                end
                            end
                        end
                    end
                end
            end)
        end

        -- ============================================================
        -- UI
        -- ============================================================
        local function buildUI()
            local Tabs = {
                Ragebot  = Window:AddTab("Ragebot"),
                Exploits = Window:AddTab("Exploits"),
                Visuals  = Window:AddTab("Visuals"),
                Player   = Window:AddTab("Player"),
                Misc     = Window:AddTab("Misc"),
                Config   = Window:AddTab("Config"),
            }
            local function gb(tab, title, side)
                if side == "right" then return tab:AddRightGroupbox(title) end
                return tab:AddLeftGroupbox(title)
            end
            local function tgl(g, id, cfg, cb)
                if not g then return end
                return g:AddToggle(id, { Text = cfg.Text, Default = cfg.Default, Tooltip = cfg.Tooltip,
                    Callback = function(v) if type(cb) == "function" then cb(v) end end })
            end
            local function sld(g, id, cfg, cb)
                if not g then return end
                g:AddSlider(id, { Text = cfg.Text, Default = cfg.Default, Min = cfg.Min, Max = cfg.Max,
                    Rounding = cfg.Rounding or 0, Suffix = cfg.Suffix or "",
                    Callback = function(v) if type(cb) == "function" then cb(v) end end })
            end
            local function drp(g, id, cfg, cb)
                if not g then return end
                local d = cfg.Default
                if type(d) == "string" then
                    local i = 1; for k, v in ipairs(cfg.Values) do if v == d then i = k; break end end; d = i
                end
                g:AddDropdown(id, { Values = cfg.Values, Default = d or 1, Multi = false, Text = cfg.Text, Tooltip = cfg.Tooltip,
                    Callback = function(v) if type(cb) == "function" then cb(v) end end })
            end
            local function cpk(g, id, cfg, cb)
                if not g then return end
                g:AddLabel(cfg.Text or id):AddColorPicker(id, { Default = cfg.Default, Title = cfg.Text, Transparency = 0,
                    Callback = function(v) if type(cb) == "function" then cb(v) end end })
            end
            local function btn(g, id, cfg)
                if not g then return end
                g:AddButton({ Text = cfg.Text, Func = cfg.Callback, Tooltip = cfg.Tooltip })
            end

            -- ============ RAGEBOT ============
            local function buildRagebot()
                local tab = Tabs.Ragebot
                local aim = gb(tab, "Aim", "left")
                tgl(aim, "SilentAim", { Text = "Silent Aim", Default = false }, function(v) Settings.Ragebot.SilentAim = v end)
                sld(aim, "Hitchance", { Text = "Hit Chance", Default = 100, Min = 0, Max = 100, Rounding = 1 }, function(v) Settings.Ragebot.Hitchance = v end)
                drp(aim, "AimPart", { Text = "Aim Part", Values = {"Head","HumanoidRootPart","Torso"}, Default = "HumanoidRootPart" }, function(v) Settings.Ragebot.AimPart = v end)
                tgl(aim, "TeamCheck", { Text = "Team Check", Default = false }, function(v) Settings.Ragebot.TeamCheck = v end)
                drp(aim, "PriorityMode", { Text = "Priority Mode", Values = {"FOV","Distance","Health"}, Default = "FOV" }, function(v) Settings.Ragebot.PriorityMode = v end)
                tgl(aim, "VisCheck", { Text = "Visibility Check", Default = false }, function(v) Settings.Ragebot.VisibilityCheck = v end)
                tgl(aim, "AutoSelect", { Text = "Auto Select", Default = false }, function(v) Settings.Ragebot.AutoSelect = v end)
                tgl(aim, "Resolver", { Text = "Resolver", Default = true }, function(v) Settings.Ragebot.Resolver = v end)
                tgl(aim, "Prediction", { Text = "Prediction", Default = false }, function(v) Settings.Ragebot.Prediction = v end)
                tgl(aim, "FaceTarget", { Text = "Face Target", Default = false }, function(v) Settings.Ragebot.FaceTarget = v end)

                local lock = gb(tab, "Lock & Spectate", "left")
                drp(lock, "LockKey", { Text = "Lock Key", Values = {"Q","E","R","F","LeftControl","LeftShift","None"}, Default = "Q" }, function(v) Settings.Ragebot.LockKey = v end)
                local sp = tgl(lock, "Spectate", { Text = "Spectate Target", Default = false }, function(v)
                    Settings.Ragebot.Spectate = v; applySpectateSetting()
                end)
                sp:AddKeyPicker("SpectateKey", { Default = "None", Mode = "Toggle", Text = "Spectate", SyncToggleState = true })
                tgl(lock, "LockTracer", { Text = "Lock Tracer", Default = true }, function(v) Settings.Ragebot.LockTracer = v end)

                local filt = gb(tab, "Target Filters", "left")
                tgl(filt, "KnockedCheck", { Text = "Knocked Check", Default = true }, function(v) Settings.Ragebot.KnockedCheck = v end)
                tgl(filt, "GrabbedCheck", { Text = "Grabbed Check", Default = true }, function(v) Settings.Ragebot.GrabbedCheck = v end)
                tgl(filt, "NoGroundShots", { Text = "No Ground Shots", Default = true }, function(v) Settings.Ragebot.NoGroundShots = v end)

                local acc = gb(tab, "Accuracy Limiter", "left")
                tgl(acc, "AccLimEnabled", { Text = "Enabled", Default = true }, function(v) Settings.Ragebot.AccuracyLimiter.Enabled = v end)
                sld(acc, "AccLimMax", { Text = "Max Accuracy %", Default = 95, Min = 50, Max = 99, Rounding = 1 }, function(v) Settings.Ragebot.AccuracyLimiter.MaxAccuracy = v end)
                sld(acc, "AccLimWin", { Text = "Window (shots)", Default = 20, Min = 5, Max = 50, Rounding = 0 }, function(v) Settings.Ragebot.AccuracyLimiter.Window = v end)

                local fov = gb(tab, "FOV Circle", "right")
                tgl(fov, "ShowFOV", { Text = "Show FOV", Default = true }, function(v) Settings.Ragebot.ShowFOV = v end)
                sld(fov, "FOVRadius", { Text = "Radius", Default = 200, Min = 50, Max = 500, Rounding = 1 }, function(v) Settings.Ragebot.FOVRadius = v end)
                cpk(fov, "FOVColor", { Text = "Color", Default = Color3.fromRGB(255,0,0) }, function(v) Settings.Ragebot.FOVColor = v end)
                sld(fov, "FOVThickness", { Text = "Thickness", Default = 1.5, Min = 0.5, Max = 5, Rounding = 1 }, function(v) Settings.Ragebot.FOVThickness = v end)
                sld(fov, "FOVTransparency", { Text = "Transparency", Default = 0.8, Min = 0, Max = 1, Rounding = 2 }, function(v) Settings.Ragebot.FOVTransparency = v end)

                local sh = gb(tab, "Auto Shoot", "right")
                local ast = tgl(sh, "AutoShoot", { Text = "Auto Shoot", Default = false }, function(v) Settings.Ragebot.AutoShoot = v end)
                ast:AddKeyPicker("AutoShootKey", { Default = "None", Mode = "Toggle", Text = "Auto Shoot", SyncToggleState = true })
                tgl(sh, "AutoShootVis", { Text = "Auto Shoot Visibility", Default = false }, function(v) Settings.Ragebot.AutoShootVisibilityCheck = v end)
                sld(sh, "StopHealth", { Text = "Stop Below Health", Default = 20, Min = 0, Max = 100, Rounding = 1 }, function(v) Settings.Ragebot.StopAutoShootBelowHealth = v end)
                local astomp = tgl(sh, "AutoStomp", { Text = "Auto Stomp", Default = false }, function(v) Settings.Ragebot.AutoStomp = v end)
                astomp:AddKeyPicker("AutoStompKey", { Default = "None", Mode = "Toggle", Text = "Auto Stomp", SyncToggleState = true })

                local st = gb(tab, "Target Strafe", "right")
                local stog = tgl(st, "TargetStrafe", { Text = "Enabled", Default = false }, function(v)
                    Settings.Ragebot.TargetStrafe.Enabled = v; startVoidSpam()
                end)
                stog:AddKeyPicker("TargetStrafeKey", { Default = "X", Mode = "Toggle", Text = "Target Strafe", SyncToggleState = true })
                sld(st, "StrafeSpeed", { Text = "Speed", Default = 1.5, Min = 0.1, Max = 20, Rounding = 1, Suffix = "x" }, function(v) Settings.Ragebot.TargetStrafe.Speed = v end)
                sld(st, "StrafeDist", { Text = "Distance", Default = 8, Min = 1, Max = 50, Rounding = 0, Suffix = " studs" }, function(v) Settings.Ragebot.TargetStrafe.Distance = v end)
                sld(st, "StrafeHeight", { Text = "Height", Default = 4, Min = 0, Max = 20, Rounding = 0, Suffix = " studs" }, function(v) Settings.Ragebot.TargetStrafe.Height = v end)
                tgl(st, "Unhittable", { Text = "Unhittable", Default = false }, function(v) Settings.Ragebot.Unhittable = v end)
                tgl(st, "VoidSpamRage", { Text = "Void Spam Rage", Default = false }, function(v)
                    Settings.Ragebot.VoidSpamRage = v; startVoidSpam()
                end)

                local hd = gb(tab, "Hit Detection", "left")
                tgl(hd, "HitDetect", { Text = "Enabled", Default = true }, function(v) Settings.Ragebot.HitDetection.Enabled = v end)
                tgl(hd, "HitDetectSound", { Text = "Sound", Default = true }, function(v) Settings.Ragebot.HitDetection.Sound = v end)
                tgl(hd, "HitDetectNotify", { Text = "Notify", Default = true }, function(v) Settings.Ragebot.HitDetection.Notify = v end)
                tgl(hd, "HitDetectMissNotify", { Text = "Miss Notify (with reason)", Default = true }, function(v) Settings.Ragebot.HitDetection.MissNotify = v end)

                local he = gb(tab, "Hit Effects", "left")
                tgl(he, "HitClone", { Text = "Effect: Clone", Default = false }, function(v) Settings.Ragebot.HitDetection.EffectClone = v end)
                tgl(he, "HitPulse", { Text = "Effect: Pulse", Default = false }, function(v) Settings.Ragebot.HitDetection.EffectPulse = v end)

                local hs = gb(tab, "Hit Sound", "right")
                tgl(hs, "HitSound", { Text = "Enabled", Default = false }, function(v) Settings.Visuals.HitSound.Enabled = v end)
                drp(hs, "HitSoundSelect", { Text = "Sound", Values = {"Neverlose","Sparkle","Minecraft","TF2","OSU","Bameware","Hitmarker","skeet","Rust","Lazer Beam","Bow Hit","Bow","TF2 Hitsound","TF2 Critical"}, Default = "Neverlose" }, function(v)
                    Settings.Visuals.HitSound.SelectedSound = v
                    Settings.Visuals.HitSound.SoundId = soundOptions[v] or "rbxassetid://139452805868562"
                end)
                sld(hs, "HitSoundVol", { Text = "Volume", Default = 1, Min = 0, Max = 1, Rounding = 2 }, function(v) Settings.Visuals.HitSound.Volume = v end)
            end

            -- ============ EXPLOITS ============
            local function buildExploits()
                local tab = Tabs.Exploits
                local rf = gb(tab, "Rapid Fire", "left")
                local rt = tgl(rf, "RapidFire", { Text = "Rapid Fire", Default = false }, function(v) Settings.Ragebot.RapidFire = v; applyRapidFire() end)
                rt:AddKeyPicker("RapidFireKey", { Default = "None", Mode = "Toggle", Text = "Rapid Fire", SyncToggleState = true })
                sld(rf, "RapidFireDelay", { Text = "Rapid Fire Delay", Default = 0.08, Min = 0.02, Max = 0.5, Rounding = 2 }, function(v) Settings.Ragebot.RapidFireDelay = v end)
                tgl(rf, "MultiGun", { Text = "Multi‑Gun (clones)", Default = false }, function(v) Settings.Ragebot.MultiGun = v; updateMultiGun() end)
                tgl(rf, "AutoReload", { Text = "Auto Reload", Default = false }, function(v) Settings.Ragebot.AutoReload = v end)
                tgl(rf, "SilentReload", { Text = "Silent Reload", Default = false }, function(v) setSilentReloadEnabled(v) end)

                local gm = gb(tab, "Gun Mods", "left")
                tgl(gm, "NoRecoil", { Text = "No Recoil", Default = false }, function(v) Settings.Ragebot.NoRecoil = v end)
                tgl(gm, "NoSpread", { Text = "No Spread (Head Only)", Default = false }, function(v) Settings.Ragebot.NoSpread = v end)

                local dsn = gb(tab, "Desync", "left")
                local invT = tgl(dsn, "InvisibleDesync", { Text = "Invisible Desync", Default = false }, function(v)
                    if v then startInvisibleDesync() else stopInvisibleDesync() end
                end)
                invT:AddKeyPicker("InvDesyncKey", { Default = "None", Mode = "Toggle", Text = "Invisible Desync", SyncToggleState = true })
                local cfdT = tgl(dsn, "CFrameDesync", { Text = "CFrame Desync", Default = false }, function(v)
                    if v then startCFrameDesync() else stopCFrameDesync() end
                end)
                cfdT:AddKeyPicker("CFDesyncKey", { Default = "None", Mode = "Toggle", Text = "CFrame Desync", SyncToggleState = true })

                local na = gb(tab, "Defense", "right")
                tgl(na, "AntiStomp", { Text = "Anti Stomp", Default = false }, function(v) Settings.Ragebot.AntiStomp = v end)
                local netT = tgl(na, "NetworkAnti", { Text = "Network Anti", Default = false }, function(v)
                    Settings.Player.NetworkAnti.Enabled = v
                    if v then startNetworkAnti() else stopNetworkAnti() end
                end)
                netT:AddKeyPicker("NetworkAntiKey", { Default = "K", Mode = "Toggle", Text = "Network Anti", SyncToggleState = true })

                local hb = gb(tab, "Hitbox Expander", "right")
                tgl(hb, "Hitbox", { Text = "Enabled", Default = false }, function(v) setHitboxExpanderEnabled(v) end)
                sld(hb, "HitboxSize", { Text = "Size", Default = 16, Min = 2, Max = 30, Rounding = 1 }, function(v) Settings.Ragebot.HitboxExpander.Size = Vector3.new(v,v,v) end)
                cpk(hb, "HitboxColor", { Text = "Color", Default = Color3.fromRGB(0,0,0) }, function(v) Settings.Ragebot.HitboxExpander.Color = v end)
                sld(hb, "HitboxTrans", { Text = "Transparency", Default = 0.8, Min = 0, Max = 1, Rounding = 2 }, function(v) Settings.Ragebot.HitboxExpander.Transparency = v end)
                cpk(hb, "HitboxOutCol", { Text = "Outline Color", Default = Color3.fromRGB(108,59,170) }, function(v) Settings.Ragebot.HitboxExpander.OutlineColor = v end)
                sld(hb, "HitboxOutTrans", { Text = "Outline Trans.", Default = 0, Min = 0, Max = 1, Rounding = 2 }, function(v) Settings.Ragebot.HitboxExpander.OutlineTransparency = v end)
            end

            -- ============ VISUALS ============
            local function buildVisuals()
                local tab = Tabs.Visuals
                local esp = gb(tab, "ESP", "left")
                tgl(esp, "ESP", { Text = "Enabled", Default = false }, function(v) Settings.Visuals.ESP.Enabled = v end)
                tgl(esp, "ESPTeam", { Text = "Team Check", Default = false }, function(v) Settings.Visuals.ESP.TeamCheck = v end)
                cpk(esp, "ESPColor", { Text = "Color", Default = Color3.fromRGB(255,0,0) }, function(v) Settings.Visuals.ESP.HighlightColor = v end)
                sld(esp, "ESPTrans", { Text = "Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 2 }, function(v) Settings.Visuals.ESP.HighlightTransparency = v end)

                local cc = gb(tab, "Client Chams", "left")
                tgl(cc, "CCChar", { Text = "Character Chams", Default = false }, function(v) Settings.Visuals.ClientChams.CharEnabled = v end)
                cpk(cc, "CCCharCol", { Text = "Character Color", Default = Color3.fromRGB(255,0,0) }, function(v) Settings.Visuals.ClientChams.CharColor = v end)
                drp(cc, "CCCharMat", { Text = "Character Material", Values = {"ForceField","Neon","Glass","Plastic","SmoothPlastic"}, Default = "ForceField" }, function(v) Settings.Visuals.ClientChams.CharMaterial = v end)
                tgl(cc, "CCWeap", { Text = "Weapon Chams", Default = false }, function(v) Settings.Visuals.ClientChams.WeaponEnabled = v end)
                cpk(cc, "CCWeapCol", { Text = "Weapon Color", Default = Color3.fromRGB(255,0,0) }, function(v) Settings.Visuals.ClientChams.WeaponColor = v end)
                drp(cc, "CCWeapMat", { Text = "Weapon Material", Values = {"ForceField","Neon","Glass","Plastic","SmoothPlastic"}, Default = "SmoothPlastic" }, function(v) Settings.Visuals.ClientChams.WeaponMaterial = v end)
                tgl(cc, "CCTrail", { Text = "Trail", Default = false }, function(v) Settings.Visuals.ClientChams.TrailEnabled = v end)
                cpk(cc, "CCTrailCol", { Text = "Trail Color", Default = Color3.fromRGB(255,0,0) }, function(v) Settings.Visuals.ClientChams.TrailColor = v end)
                sld(cc, "CCTrailLife", { Text = "Trail Lifetime", Default = 3, Min = 1, Max = 10, Rounding = 0 }, function(v) Settings.Visuals.ClientChams.TrailLifetime = v end)

                local ch = gb(tab, "Crosshair", "left")
                tgl(ch, "CHEnabled", { Text = "Enabled", Default = false }, function(v) Settings.Visuals.Crosshair.Enabled = v end)
                tgl(ch, "CHFollow", { Text = "Follow Target", Default = false }, function(v) Settings.Visuals.Crosshair.FollowTarget = v end)
                cpk(ch, "CHColor", { Text = "Color", Default = Color3.fromRGB(255,102,204) }, function(v) Settings.Visuals.Crosshair.Color = v end)
                drp(ch, "CHMode", { Text = "Mode", Values = {"mouse","center"}, Default = "mouse" }, function(v) Settings.Visuals.Crosshair.Mode = v end)
                sld(ch, "CHThick", { Text = "Thickness", Default = 2, Min = 1, Max = 5, Rounding = 1 }, function(v) Settings.Visuals.Crosshair.Thickness = v end)
                sld(ch, "CHLen", { Text = "Length", Default = 10, Min = 1, Max = 50, Rounding = 0 }, function(v) Settings.Visuals.Crosshair.Length = v end)
                sld(ch, "CHGap", { Text = "Gap Radius", Default = 11, Min = 0, Max = 20, Rounding = 0 }, function(v) Settings.Visuals.Crosshair.Radius = v end)
                tgl(ch, "CHSpin", { Text = "Spin", Default = false }, function(v) Settings.Visuals.Crosshair.Spin = v end)
                sld(ch, "CHSpinSpeed", { Text = "Spin Speed", Default = 150, Min = 1, Max = 340, Rounding = 0 }, function(v) Settings.Visuals.Crosshair.SpinSpeed = v end)
                tgl(ch, "CHResize", { Text = "Resize", Default = false }, function(v) Settings.Visuals.Crosshair.Resize = v end)
                sld(ch, "CHResizeSpeed", { Text = "Resize Speed", Default = 5, Min = 1, Max = 22, Rounding = 0 }, function(v) Settings.Visuals.Crosshair.ResizeSpeed = v end)

                local tr = gb(tab, "Bullet Tracers", "right")
                tgl(tr, "TracerEnabled", { Text = "Enabled", Default = false }, function(v) Settings.Visuals.BulletTracers.Enabled = v end)
                tgl(tr, "RemoveBulletTracer", { Text = "Remove Bullet Tracer (hide own)", Default = false }, function(v) Settings.Visuals.RemoveBulletTracer = v end)
                tgl(tr, "RemoveGunSound", { Text = "Remove Gun Sound", Default = false }, function(v) Settings.Visuals.RemoveGunSound = v end)
                cpk(tr, "TracerColor", { Text = "Color", Default = Color3.fromRGB(255,102,204) }, function(v) Settings.Visuals.BulletTracers.Color = v end)
                sld(tr, "TracerWidth", { Text = "Width", Default = 0.5, Min = 0.1, Max = 3, Rounding = 1 }, function(v) Settings.Visuals.BulletTracers.Width = v end)
                sld(tr, "TracerBrightness", { Text = "Brightness", Default = 5, Min = 1, Max = 10, Rounding = 1 }, function(v) Settings.Visuals.BulletTracers.Brightness = v end)
                sld(tr, "TracerSegments", { Text = "Segments", Default = 10, Min = 2, Max = 20, Rounding = 1 }, function(v) Settings.Visuals.BulletTracers.Segments = v end)
                sld(tr, "TracerSpeed", { Text = "Speed", Default = 3, Min = 1, Max = 10, Rounding = 1 }, function(v) Settings.Visuals.BulletTracers.Speed = v end)
                drp(tr, "TracerTexture", { Text = "Texture", Values = {"Normal","Glow"}, Default = "Normal" }, function(v) Settings.Visuals.BulletTracers.Texture = v end)
                tgl(tr, "TracerRayTrace", { Text = "Ray Tracing", Default = false }, function(v) Settings.Visuals.BulletTracers.RayTracing = v end)
                sld(tr, "TracerGlow", { Text = "Glow Intensity", Default = 5, Min = 1, Max = 20, Rounding = 1 }, function(v) Settings.Visuals.BulletTracers.GlowIntensity = v end)

                local wm = gb(tab, "Watermark", "right")
                tgl(wm, "WatermarkToggle", { Text = "Enabled", Default = true }, function(v) Settings.Visuals.Watermark.Enabled = v end)
                cpk(wm, "WatermarkColor", { Text = "Color", Default = Color3.fromRGB(226,226,226) }, function(v) Settings.Visuals.Watermark.Color = v end)
                sld(wm, "WatermarkSize", { Text = "Size", Default = 14, Min = 8, Max = 24, Rounding = 1 }, function(v) Settings.Visuals.Watermark.Size = v end)

                local amb = gb(tab, "World Modulation", "right")
                tgl(amb, "Ambience", { Text = "Enabled", Default = false }, function(v) Settings.Graphics.Ambience.Enabled = v; toggleAmbience(); if v then startAmbienceClockLock() end end)
                cpk(amb, "AmbAmbient", { Text = "Ambient", Default = Color3.fromRGB(178,178,178) }, function(v) Settings.Graphics.Ambience.Ambient = v; toggleAmbience() end)
                cpk(amb, "AmbOutdoor", { Text = "Outdoor", Default = Color3.fromRGB(178,178,178) }, function(v) Settings.Graphics.Ambience.OutdoorAmbient = v; toggleAmbience() end)
                sld(amb, "AmbBrightness", { Text = "Brightness", Default = 2, Min = 0, Max = 4, Rounding = 1 }, function(v) Settings.Graphics.Ambience.Brightness = v; toggleAmbience() end)
                cpk(amb, "AmbFogColor", { Text = "Fog Color", Default = Color3.fromRGB(0,0,0) }, function(v) Settings.Graphics.Ambience.FogColor = v; toggleAmbience() end)
                sld(amb, "AmbFogStart", { Text = "Fog Start", Default = 0, Min = 0, Max = 1000, Rounding = 1 }, function(v) Settings.Graphics.Ambience.FogStart = v; toggleAmbience() end)
                sld(amb, "AmbFogEnd", { Text = "Fog End", Default = 500, Min = 0, Max = 2000, Rounding = 1 }, function(v) Settings.Graphics.Ambience.FogEnd = v; toggleAmbience() end)
                sld(amb, "AmbTime", { Text = "Time of Day", Default = 18, Min = 0, Max = 24, Rounding = 1 }, function(v)
                    Settings.Graphics.Ambience.TimeOfDay = tostring(v)..":00:00"
                    Settings.Graphics.Ambience.ClockTimeOverride = v; toggleAmbience()
                end)
                drp(amb, "AmbSkybox", { Text = "Skybox ID", Values = {"1294489738","1854733196","2561986864"}, Default = "1294489738" }, function(v) Settings.Graphics.Ambience.SkyboxID = "rbxassetid://"..v; toggleAmbience() end)

                local fx = gb(tab, "Screen Effects", "right")
                tgl(fx, "NoFlash", { Text = "No Flash/Damage Effects", Default = false }, function(v) Settings.Visuals.NoFlash.Enabled = v end)
                tgl(fx, "LowGraphics", { Text = "Low Graphics (no shadows)", Default = false }, function(v) Settings.Graphics.LowGraphics = v end)
            end

            -- ============ PLAYER ============
            local function buildPlayer()
                local tab = Tabs.Player
                local mv = gb(tab, "Movement", "left")
                local ws = tgl(mv, "WalkSpeed", { Text = "WalkSpeed", Default = false }, function(v) Settings.Player.WalkSpeedEnabled = v end)
                ws:AddKeyPicker("WalkSpeedKey", { Default = "T", Mode = "Toggle", Text = "WalkSpeed", SyncToggleState = true })
                sld(mv, "WalkSpeedVal", { Text = "Speed", Default = 300, Min = 50, Max = 500, Rounding = 1 }, function(v) Settings.Player.WalkSpeed = v end)
                drp(mv, "WalkSpeedMode", { Text = "WalkSpeed Mode", Values = {"Humanoid", "CFrame"}, Default = "Humanoid" }, function(v) Settings.Player.WalkSpeedMode = v end)
                tgl(mv, "NoClip", { Text = "NoClip", Default = false }, function(v) Settings.Player.NoClipEnabled = v end)
                tgl(mv, "NoSlow", { Text = "No Slow", Default = false }, function(v) Settings.Player.NoSlow = v end)
                tgl(mv, "NoJumpCooldown", { Text = "No Jump Cooldown", Default = false }, function(v) Settings.Player.NoJumpCooldown = v end)

                local fl = gb(tab, "Fly", "right")
                local ft = tgl(fl, "Fly", { Text = "Enabled", Default = false }, function(v) setFlyEnabled(v) end)
                ft:AddKeyPicker("FlyKey", { Default = "F", Mode = "Toggle", Text = "Fly", SyncToggleState = true })
                sld(fl, "FlySpeed", { Text = "Speed", Default = 25, Min = 5, Max = 150, Rounding = 1 }, function(v) Settings.Player.Fly.Speed = v end)

                local sv = gb(tab, "Survival", "left")
                tgl(sv, "AutoRespawn", { Text = "Auto Respawn", Default = false }, function(v) Settings.Player.AutoRespawn = v end)
                sld(sv, "AutoRespawnDelay", { Text = "Respawn Delay", Default = 3, Min = 0.5, Max = 10, Rounding = 1 }, function(v) Settings.Player.AutoRespawnDelay = v end)
                tgl(sv, "AntiVoid", { Text = "Anti Void", Default = true }, function(v) Settings.Player.AntiVoid = v end)
            end

            -- ============ MISC ============
            local function buildMisc()
                local tab = Tabs.Misc
                local ab = gb(tab, "Auto Buy", "left")
                local guns = getRealGuns()
                local dg = guns[1] or ""
                drp(ab, "SelectedGun", { Text = "Select Gun", Values = guns, Default = dg }, function(v) Settings.Misc.AutoBuy.SelectedGun = v end)
                Settings.Misc.AutoBuy.SelectedGun = dg
                btn(ab, "BuyGun", { Text = "Buy Gun", Callback = function()
                    local g = Settings.Misc.AutoBuy.SelectedGun
                    if not g or g == "" then if Library and Library.Notify then Library:Notify("No gun selected", 3) end; return end
                    if buyItem(g) then if Library and Library.Notify then Library:Notify("Purchased: "..g, 3) end
                    else if Library and Library.Notify then Library:Notify("Failed to buy "..g, 3) end end
                end})
                btn(ab, "BuyAmmo", { Text = "Buy Ammo", Callback = function()
                    local g = Settings.Misc.AutoBuy.SelectedGun
                    if not g or g == "" then if Library and Library.Notify then Library:Notify("No gun selected", 3) end; return end
                    local wt = string.match(g, "%[(.-)%]") or g:gsub("%[", ""):gsub("%].*", "")
                    local shop = workspace.Ignored and workspace.Ignored.Shop
                    if not shop then return end
                    local am = nil
                    for _, ch in ipairs(shop:GetChildren()) do
                        if ch:IsA("Model") and string.find(ch.Name, wt.." Ammo") then am = ch.Name; break end
                    end
                    if not am then if Library and Library.Notify then Library:Notify("No ammo found", 3) end; return end
                    if buyItem(am) then if Library and Library.Notify then Library:Notify("Purchased ammo: "..am, 3) end
                    else if Library and Library.Notify then Library:Notify("Failed", 3) end end
                end})

                local tp = gb(tab, "Teleport", "right")
                drp(tp, "TeleportLoc", { Text = "Location", Values = {"Admin Base","High Medium Armor","Food","Gas Station","School","Military","Ufo","Bank","Gym Top","Casino","Uphill","Revolver","Flank","PlayGround"}, Default = "Admin Base" }, function(v) Settings.Misc.SelectedLocation = v end)
                btn(tp, "Teleport", { Text = "Teleport", Callback = function()
                    if Settings.Misc.SelectedLocation then teleportToLocation(Settings.Misc.SelectedLocation) end
                end})

                local ut = gb(tab, "Utilities", "left")
                btn(ut, "ForceReset", { Text = "Force Reset", Callback = forceReset })
                btn(ut, "Rejoin", { Text = "Rejoin", Callback = rejoinServer })
            end

            -- ============ CONFIG ============
            local function buildConfig()
                local tab = Tabs.Config
                local mn = gb(tab, "Menu", "left")
                mn:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
                mn:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu", Callback = function(v) Library.KeybindFrame.Visible = v end })
                if ThemeManager then
                    ThemeManager:SetLibrary(Library); ThemeManager:SetFolder("tapped.cc"); ThemeManager:ApplyToTab(tab)
                end
                if SaveManager then
                    SaveManager:SetLibrary(Library)
                    SaveManager:IgnoreThemeSettings()
                    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
                    SaveManager:SetFolder("tapped.cc")
                    SaveManager:SetSubFolder(game.PlaceId)
                    SaveManager:BuildConfigSection(tab)
                    SaveManager:LoadAutoloadConfig()
                end
                mn:AddButton({ Text = "Unload", Func = function() Cleanup:Run(); Library:Unload(); print("[tapped.cc] Unloaded") end })
            end

            buildRagebot()
            buildExploits()
            buildVisuals()
            buildPlayer()
            buildMisc()
            buildConfig()
        end

        buildUI()
        Library.ToggleKeybind = Library.Options.MenuKeybind

        -- ============================================================
        -- STARTUP
        -- ============================================================
        local function startup()
            if LocalPlayer.Character then refreshCharacter(LocalPlayer.Character) end
            LocalPlayer.CharacterAdded:Connect(refreshCharacter)
            Connections:Add("MainLoop", RunService.RenderStepped:Connect(mainLoop))
            setupCharacterLifecycle()
            startFlyMovementLoop()
            setupBulletRay()

            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then watchPlayer(plr) end
            end
            Players.PlayerAdded:Connect(watchPlayer)
            Players.PlayerRemoving:Connect(function(plr)
                Refs.watchedPlayers[plr] = nil
                State.HPSnapshot[plr] = nil
            end)

            local kbConn = UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                local keyName = Settings.Ragebot.LockKey
                local keyCode = keyName ~= "None" and Enum.KeyCode[keyName] or nil
                if keyCode and input.KeyCode == keyCode then handleLockToggle() end
            end)
            Connections:Add("Keybinds", kbConn)

            local fk1 = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard and Settings.Player.Fly.Enabled then
                    local k = input.KeyCode
                    if k == Enum.KeyCode.W then Refs.flyKeys.w = true
                    elseif k == Enum.KeyCode.S then Refs.flyKeys.s = true
                    elseif k == Enum.KeyCode.A then Refs.flyKeys.a = true
                    elseif k == Enum.KeyCode.D then Refs.flyKeys.d = true end
                end
            end)
            Connections:Add("FlyKeys", fk1)

            local fk2 = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard and Settings.Player.Fly.Enabled then
                    local k = input.KeyCode
                    if k == Enum.KeyCode.W then Refs.flyKeys.w = false
                    elseif k == Enum.KeyCode.S then Refs.flyKeys.s = false
                    elseif k == Enum.KeyCode.A then Refs.flyKeys.a = false
                    elseif k == Enum.KeyCode.D then Refs.flyKeys.d = false end
                end
            end)
            Connections:Add("FlyKeysEnd", fk2)

            if Settings.Ragebot.HitboxExpander.Enabled then setHitboxExpanderEnabled(true) end
            if Settings.Player.Fly.Enabled then startFly() end
            if Settings.Ragebot.SilentReload then setSilentReloadEnabled(true) end
            if Settings.Graphics.Ambience.Enabled then toggleAmbience(); startAmbienceClockLock() end

            print("[tapped.cc] Loaded successfully.")
        end

        local sok, serr = pcall(startup)
        if not sok then
            warn("[tapped.cc] Startup error: " .. tostring(serr))
            Cleanup:Run()
            return
        end
    end)
    if not ok then warn("[tapped.cc] Startup error: " .. tostring(err)) end
end

local success, err = pcall(safeStart)
if not success then warn("[tapped.cc] FATAL ERROR: " .. tostring(err)) end
