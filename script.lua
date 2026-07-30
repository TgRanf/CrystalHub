-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                ЧИСТЫЙ ОРИГИНАЛ ИЗ ВАШИХ ИСХОДНИКОВ
--                           PART 1/4
-- =================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "CrystalHub | MM2 Ultimate Admin",
   Icon = 0,
   LoadingTitle = "CrystalHub MM2",
   LoadingSubtitle = "Delta & Mobile Edition",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Вкладки (из MarsInsanity)
local CombatTab   = Window:CreateTab("Combat", 4483362458)
local SilentTab   = Window:CreateTab("Silent Aim", 4483362458)
local FarmTab     = Window:CreateTab("Auto Farm", 4483362458)
local TeleportTab = Window:CreateTab("Teleports", 4483362458)
local VisualsTab  = Window:CreateTab("Visuals", 4483362458)
local PlayerTab   = Window:CreateTab("Player", 4483362458)
local MiscTab     = Window:CreateTab("Misc", 4483362458)

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ================= ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ (ОРИГИНАЛ ИЗ ВАШЕГО КОДА) =================

-- Silent Aim (из Stefanuk12)
getgenv().SilentAimEnabled = false
getgenv().SilentAimTargetMode = "Убийца"
getgenv().SilentAimHitChance = 100
getgenv().SilentAimPrediction = true
getgenv().SilentAimPredictionAmount = 0.165

-- Хитбоксы & Бой (из вашего кода)
getgenv().HitboxEnabled = false
getgenv().HitboxSize = 5
getgenv().AutoGrabGunEnabled = false

-- Автофарм (из MarsInsanity)
getgenv().AutoFarmEnabled = false
getgenv().FarmSpeed = 30
getgenv().SmartFarm = true
getgenv().currentTween = nil
getgenv().isFarming = false

-- Визуалы & Персонаж (из MarsInsanity + ваш код)
getgenv().ESPEnabled = false
getgenv().GunESPEnabled = false
getgenv().NoclipEnabled = false
getgenv().CustomSpeed = 16
getgenv().CustomJump = 50
getgenv().FlyEnabled = false
getgenv().InfiniteJumpEnabled = false
getgenv().XRayEnabled = false

-- ================= ПРОВЕРКА СТАТУСА (ИЗ ВАШЕГО КОДА) =================
local roundCache = false
local roundCheckTime = 0
getgenv().isInRound = function()
    if tick() - roundCheckTime < 0.5 then return roundCache end
    roundCheckTime = tick()
    roundCache = #Workspace:GetDescendants() > 50
    return roundCache
end

getgenv().isAlive = function()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

-- ================= ОПРЕДЕЛЕНИЕ РОЛЕЙ (ИЗ ВАШЕГО ОРИГИНАЛЬНОГО КОДА) =================
getgenv().playerRoles = {}
getgenv().COLOR_INNOCENT = Color3.fromRGB(0, 255, 0)
getgenv().COLOR_SHERIFF  = Color3.fromRGB(0, 150, 255)
getgenv().COLOR_MURDERER = Color3.fromRGB(255, 0, 0)

local function assignRole(player, toolName)
    if player == LocalPlayer then return end
    local name = toolName:lower()
    
    if name:find("knife") or name:find("нож") or name:find("blade") or name:find("dagger") then
        if getgenv().playerRoles[player] ~= getgenv().COLOR_MURDERER then
            getgenv().playerRoles[player] = getgenv().COLOR_MURDERER
            Rayfield:Notify({ Title = "CrystalHub", Content = "🔪 Убийца найден: " .. player.Name, Duration = 3 })
        end
    elseif name:find("gun") or name:find("revolver") or name:find("pistol") or name:find("пест") or name:find("luger") then
        if getgenv().playerRoles[player] ~= getgenv().COLOR_SHERIFF then
            getgenv().playerRoles[player] = getgenv().COLOR_SHERIFF
            Rayfield:Notify({ Title = "CrystalHub", Content = "🔫 Шериф найден: " .. player.Name, Duration = 3 })
        end
    end
end

local function trackPlayerRoles(player)
    if player == LocalPlayer then return end

    local function setupContainerListener(container)
        if not container then return end
        container.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then assignRole(player, child.Name) end
        end)
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Tool") then assignRole(player, child.Name) end
        end
    end

    task.spawn(function()
        local bp = player:WaitForChild("Backpack", 10)
        setupContainerListener(bp)
    end)

    player.CharacterAdded:Connect(function(char)
        setupContainerListener(char)
        getgenv().playerRoles[player] = nil
    end)
    if player.Character then setupContainerListener(player.Character) end
end

task.spawn(function()
    while task.wait(1) do
        if not getgenv().isInRound() then
            table.clear(getgenv().playerRoles)
        end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do trackPlayerRoles(p) end
Players.PlayerAdded:Connect(trackPlayerRoles)

getgenv().getPlayerByRole = function(roleColor)
    for p, color in pairs(getgenv().playerRoles) do
        if p ~= LocalPlayer and color == roleColor and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                return p
            end
        end
    end
    return nil
end

-- ================= ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (ИЗ MARSINSANITY) =================
local function antiLag()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        end
    end
    Lighting.GlobalShadows = false
    Rayfield:Notify({ Title = "CrystalHub", Content = "Anti-Lag applied!", Duration = 2 })
end

local function fullBright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Rayfield:Notify({ Title = "CrystalHub", Content = "FullBright enabled!", Duration = 2 })
end

local function removeShadows()
    Lighting.GlobalShadows = false
    Rayfield:Notify({ Title = "CrystalHub", Content = "Shadows removed!", Duration = 2 })
end
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                ЧИСТЫЙ ОРИГИНАЛ ИЗ ВАШИХ ИСХОДНИКОВ
--                           PART 2/4 (ПОЛНАЯ ВЕРСИЯ)
-- =================================================================

-- ================= SILENT AIM (ОРИГИНАЛ ИЗ STEFANUK12) =================
local ValiantAimHacks = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Stefanuk12/ROBLOX/master/Universal/Experimental%20Silent%20Aim%20Module.lua"))()

ValiantAimHacks.SilentAimEnabled = false
ValiantAimHacks.ShowFOV = false
ValiantAimHacks.FOV = 60
ValiantAimHacks.HitChance = 100
ValiantAimHacks.VisibleCheck = true
ValiantAimHacks.TeamCheck = false
ValiantAimHacks.TargetPart = {"Head", "HumanoidRootPart"}

-- Перехват для Silent Aim (оригинал из Stefanuk12)
local mt = getrawmetatable(game)
local backupIndex = mt.__index
local backupNamecall = mt.__namecall
setreadonly(mt, false)

mt.__index = newcclosure(function(self, key)
    if self == Mouse and not checkcaller() then
        if ValiantAimHacks.checkSilentAim() then
            local targetPart = ValiantAimHacks.SelectedPart
            if targetPart then
                if key == "Hit" then
                    return targetPart.CFrame
                elseif key == "Target" then
                    return targetPart
                end
            end
        end
    end
    return backupIndex(self, key)
end)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "FireServer" then
        if tostring(self):find("Shoot") or tostring(self):find("Gun") then
            if ValiantAimHacks.checkSilentAim() then
                local targetPart = ValiantAimHacks.SelectedPart
                if targetPart then
                    args[1] = targetPart.Position
                    return backupNamecall(self, unpack(args))
                end
            end
        end
        if tostring(self):find("Knife") or tostring(self):find("Swing") then
            if ValiantAimHacks.checkSilentAim() then
                local targetPart = ValiantAimHacks.SelectedPart
                if targetPart then
                    args[1] = targetPart.Position
                    return backupNamecall(self, unpack(args))
                end
            end
        end
    end
    
    return backupNamecall(self, ...)
end)

setreadonly(mt, true)

task.spawn(function()
    while task.wait(1) do
        if not ValiantAimHacks.SilentAimEnabled then
            ValiantAimHacks.Selected = LocalPlayer
            ValiantAimHacks.SelectedPart = nil
        end
    end
end)

-- ================= FLING (ОРИГИНАЛ ИЗ JOSHCLARK756) =================
local teleportEnabled = false
local velocityEnabled = false

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function velocityBypasser()
    while true do
        if velocityEnabled then
            RunService.Heartbeat:Wait()
            local character = LocalPlayer.Character
            local root = getRoot(character)
            local vel, movel = nil, 0.1

            while velocityEnabled and not (character and character.Parent and root and root.Parent) do
                RunService.Heartbeat:Wait()
                character = LocalPlayer.Character
                root = getRoot(character)
            end

            if not velocityEnabled then return end

            vel = root.Velocity
            root.Velocity = vel * 1000000 + Vector3.new(0, 1000000, 0)

            RunService.RenderStepped:Wait()
            if velocityEnabled and character and character.Parent and root and root.Parent then
                root.Velocity = vel
            end

            RunService.Stepped:Wait()
            if velocityEnabled and character and character.Parent and root and root.Parent then
                root.Velocity = vel + Vector3.new(0, movel, 0)
                movel = movel * -1
            end
        else
            task.wait(0.1)
        end
    end
end

local function teleportHandleToPart(part)
    local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not Tool then
        print("No tool equipped. Please equip a tool and try again.")
        return
    end
    
    local Handle = Tool:FindFirstChild("Handle")
    if not Handle then
        print("Tool has no Handle. This script may not work as intended.")
        return
    end
    
    local originalCFrame = Handle.CFrame
    Handle.CFrame = part.CFrame
    task.wait(0.05)
    Handle.CFrame = originalCFrame
end

local function teleportHandleToPlayer(player)
    if player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                teleportHandleToPart(part)
            end
        end
    end
end

local function getPlayerHRP(player)
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function isPlayerAlive(player)
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function getHRPVelocity(hrp)
    return hrp and hrp.Velocity.Magnitude or 0
end

local function isPlayerSitting(player)
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Sit
end

local velocityThreshold = 50

local function runTeleportation()
    while true do
        if teleportEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not isPlayerSitting(player) then
                    local hrp = getPlayerHRP(player)
                    local initialVelocity = getHRPVelocity(hrp)
                    
                    while teleportEnabled and player and player.Parent and isPlayerAlive(player) and getHRPVelocity(hrp) - initialVelocity < velocityThreshold do
                        teleportHandleToPlayer(player)
                        task.wait(0.1)
                        hrp = getPlayerHRP(player)
                        
                        if isPlayerSitting(player) then
                            break
                        end
                    end
                    
                    task.wait(0.5)
                end
            end
        else
            task.wait(0.1)
        end
    end
end

coroutine.wrap(velocityBypasser)()
coroutine.wrap(runTeleportation)()

-- ================= SHOT BUTTON (ОРИГИНАЛ ИЗ MARSINSANITY) =================
local ShotGui = nil
getgenv().toggleShotButton = function(state)
    if state then
        if not ShotGui then
            ShotGui = Instance.new("ScreenGui")
            ShotGui.Name = "CrystalHubShotGui"
            ShotGui.Parent = CoreGui
            ShotGui.ResetOnSpawn = false

            local btn = Instance.new("TextButton")
            btn.Name = "ShotBtn"
            btn.Parent = ShotGui
            btn.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
            btn.Position = UDim2.new(0.82, 0, 0.45, 0)
            btn.Size = UDim2.new(0, 55, 0, 55)
            btn.Font = Enum.Font.SourceSansBold
            btn.Text = "SHOT"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 18
            btn.Draggable = true
            btn.Active = true

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                if not getgenv().isInRound() or not getgenv().isAlive() then
                    Rayfield:Notify({ Title = "CrystalHub", Content = "Not available!", Duration = 2 })
                    return
                end

                local murderer = getgenv().getPlayerByRole(getgenv().COLOR_MURDERER)
                if murderer and murderer.Character and murderer.Character:FindFirstChild("Head") then
                    local targetHead = murderer.Character.Head
                    
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    if bp then
                        local gun = bp:FindFirstChildOfClass("Tool")
                        if gun then
                            LocalPlayer.Character.Humanoid:EquipTool(gun)
                            task.wait(0.05)
                        end
                    end
                    
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
                        tool:Activate()
                        Rayfield:Notify({ Title = "CrystalHub", Content = "Shot fired!", Duration = 2 })
                    end
                else
                    Rayfield:Notify({ Title = "CrystalHub", Content = "Murderer not found!", Duration = 2 })
                end
            end)
        end
        ShotGui.Enabled = true
    else
        if ShotGui then ShotGui.Enabled = false end
    end
end

-- ================= KILL ALL (ОРИГИНАЛ ИЗ MARSINSANITY) =================
local function KillAll()
    local Players = game:GetService("Players")
    for i, Victim in pairs(Players:GetPlayers()) do
        if Victim.Name ~= game.Players.LocalPlayer.Name then
            repeat
                wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Victim.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
            until Victim.Character.Humanoid.Health == 0
        end
    end
end

-- ================= GUN GRABBER (ОРИГИНАЛ ИЗ MARSINSANITY) =================
local function GunGrabber()
    local currentX = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.X
    local currentY = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Y
    local currentZ = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Z

    if workspace:FindFirstChild("GunDrop") ~= nil then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace:FindFirstChild("GunDrop").CFrame
        wait(0.25)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(currentX, currentY, currentZ)
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "CrystalHub",
            Text = "Wait for the Sheriff's death to grab the gun",
            Icon = "",
            Duration = 2,
        })
    end
end

-- ================= X-RAY (ОРИГИНАЛ ИЗ MARSINSANITY) =================
local obj = game.Workspace
local function XrayOn(obj)
    for _, v in pairs(obj:GetChildren()) do
        if (v:IsA("BasePart")) and not v.Parent:FindFirstChild("Humanoid") then
            v.LocalTransparencyModifier = 0.75
        end
        XrayOn(v)
    end
end

local function XrayOff(obj)
    for _, v in pairs(obj:GetChildren()) do
        if (v:IsA("BasePart")) and not v.Parent:FindFirstChild("Humanoid") then
            v.LocalTransparencyModifier = 0
        end
        XrayOff(v)
    end
end
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                ЧИСТЫЙ ОРИГИНАЛ ИЗ ВАШИХ ИСХОДНИКОВ
--                           PART 3/4
-- =================================================================

-- ================= TELEPORTS (ОРИГИНАЛ ИЗ MARSINSANITY) =================
-- TP to Lobby
local function TPLobby()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-108.5, 145, 0.6)
end

-- TP to Map Spawn
local function TPMap()
    local Workplace = workspace:GetChildren()
    for i, Thing in pairs(Workplace) do
        local ThingChildren = Thing:GetChildren()
        for i, Child in pairs(ThingChildren) do
            if Child.Name == "Spawns" then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Child.Spawn.CFrame
            end
        end
    end
end

-- TP to Murderer
local function TPMurderer()
    local Players = game:GetService("Players")
    for i, player in pairs(Players:GetPlayers()) do
        local bp = player.Backpack:GetChildren()
        for i, tool in pairs(bp) do
            if tool.Name == "Knife" then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[tool.Parent.Parent.Name].Character.HumanoidRootPart.CFrame
            end
        end
    end
end

-- TP to Sheriff
local function TPSheriff()
    local Players = game:GetService("Players")
    for i, player in pairs(Players:GetPlayers()) do
        local bp = player.Backpack:GetChildren()
        for i, tool in pairs(bp) do
            if tool.Name == "Gun" then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[tool.Parent.Parent.Name].Character.HumanoidRootPart.CFrame
            end
        end
    end
end

-- TP to Player (по имени)
local function TPPlayer(name)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[name].Character.HumanoidRootPart.CFrame
end

-- ================= COIN FARM (ОРИГИНАЛ ИЗ MARSINSANITY) =================
local function CoinFarm()
    while getgenv().AutoFarmEnabled do
        wait(0.25)
        local place = workspace:GetChildren()
        local currentX = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.X
        local currentY = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Y
        local currentZ = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Z

        for i, v in pairs(place) do
            local vChildren = v:GetChildren()
            for i, child in pairs(vChildren) do
                if child.Name == "CoinContainer" then
                    if child.Coin_Server:FindFirstChild("Coin") ~= nil then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = child.Coin_Server.Coin.CFrame
                    else
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(currentX, currentY, currentZ)
                        getgenv().AutoFarmEnabled = false
                    end
                end
            end
        end
    end
end

-- ================= FLY (ОРИГИНАЛ ИЗ MARSINSANITY) =================
local flyEnabled = false
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyControls = {F = 0, B = 0, L = 0, R = 0}

local function startFly()
    flyEnabled = true
    local player = game.Players.LocalPlayer
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
    end
end

local function stopFly()
    flyEnabled = false
    local player = game.Players.LocalPlayer
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    if flyBodyGyro then
        flyBodyGyro:Destroy()
        flyBodyGyro = nil
    end
end

-- Fly update loop
task.spawn(function()
    while true do
        wait()
        if flyEnabled and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            if not flyBodyVelocity then
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                flyBodyVelocity.P = 9e4
                flyBodyVelocity.Parent = hrp
                
                flyBodyGyro = Instance.new("BodyGyro")
                flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                flyBodyGyro.P = 9e4
                flyBodyGyro.Parent = hrp
            end
            
            local speed = 50
            local lookVector = Camera.CFrame.LookVector
            local rightVector = Camera.CFrame.RightVector
            
            local moveVector = Vector3.new(
                (flyControls.R - flyControls.L),
                0,
                (flyControls.F - flyControls.B)
            )
            
            flyBodyVelocity.Velocity = (lookVector * moveVector.Z + rightVector * moveVector.X) * speed
            flyBodyGyro.CFrame = Camera.CFrame
        else
            if flyBodyVelocity then
                flyBodyVelocity:Destroy()
                flyBodyVelocity = nil
            end
            if flyBodyGyro then
                flyBodyGyro:Destroy()
                flyBodyGyro = nil
            end
        end
    end
end)

-- Fly controls
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then flyControls.F = 1
    elseif key == Enum.KeyCode.S then flyControls.B = 1
    elseif key == Enum.KeyCode.A then flyControls.L = 1
    elseif key == Enum.KeyCode.D then flyControls.R = 1 end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then flyControls.F = 0
    elseif key == Enum.KeyCode.S then flyControls.B = 0
    elseif key == Enum.KeyCode.A then flyControls.L = 0
    elseif key == Enum.KeyCode.D then flyControls.R = 0 end
end)

-- ================= INFINITE JUMP (ОРИГИНАЛ ИЗ MARSINSANITY) =================
local infiniteJumpEnabled = false

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ================= NOCLIP (ОРИГИНАЛ ИЗ MARSINSANITY) =================
local noclipEnabled = false

game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:ChangeState(11) -- Enum.HumanoidStateType.Climbing
            end
        end
    end
end)
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                ЧИСТЫЙ ОРИГИНАЛ ИЗ ВАШИХ ИСХОДНИКОВ
--                           PART 4/4 (ESP)
-- =================================================================

-- ================= ESP (ОРИГИНАЛ ИЗ MURDER_MYSTERY_2-SIMPLE_ESP) =================
local faces = {"Back", "Bottom", "Front", "Left", "Right", "Top"}
local ESPToggle = false

local function MakeESP()
    for _, v in pairs(game.Players:GetChildren()) do
        if v.Name ~= game.Players.LocalPlayer.Name then
            -- BillboardGui с именем
            local bgui = Instance.new("BillboardGui", v.Character.Head)
            bgui.Name = ("EGUI")
            bgui.AlwaysOnTop = true
            bgui.ExtentsOffset = Vector3.new(0, 2, 0)
            bgui.Size = UDim2.new(0, 200, 0, 50)
            local nam = Instance.new("TextLabel", bgui)
            nam.Text = v.Name
            nam.BackgroundTransparency = 1
            nam.TextSize = 15
            nam.Font = ("GothamBold")
            nam.TextColor3 = Color3.new(255, 255, 255)
            nam.Size = UDim2.new(0, 200, 0, 50)
            
            -- Определяем цвет по роли
            local roleColor = getgenv().playerRoles[v]
            if roleColor == getgenv().COLOR_MURDERER then
                -- Убийца — красный
                for _, p in pairs(v.Character:GetChildren()) do
                    if p.Name == ("Head") or p.Name == ("Torso") or p.Name == ("Right Arm") or p.Name == ("Right Leg") or p.Name == ("Left Arm") or p.Name == ("Left Leg") then 
                        for _, f in pairs(faces) do
                            local m = Instance.new("SurfaceGui", p)
                            m.Name = ("EGUI")
                            m.Face = f
                            m.AlwaysOnTop = true
                            local mf = Instance.new("Frame", m)
                            mf.Size = UDim2.new(1, 0, 1, 0)
                            mf.BorderSizePixel = 0
                            mf.BackgroundTransparency = 0.5
                            mf.BackgroundColor3 = Color3.new(255, 0, 0)
                        end
                    end
                end
            elseif roleColor == getgenv().COLOR_SHERIFF then
                -- Шериф — синий
                for _, p in pairs(v.Character:GetChildren()) do
                    if p.Name == ("Head") or p.Name == ("Torso") or p.Name == ("Right Arm") or p.Name == ("Right Leg") or p.Name == ("Left Arm") or p.Name == ("Left Leg") then 
                        for _, f in pairs(faces) do
                            local m = Instance.new("SurfaceGui", p)
                            m.Name = ("EGUI")
                            m.Face = f
                            m.AlwaysOnTop = true
                            local mf = Instance.new("Frame", m)
                            mf.Size = UDim2.new(1, 0, 1, 0)
                            mf.BorderSizePixel = 0
                            mf.BackgroundTransparency = 0.5
                            mf.BackgroundColor3 = Color3.new(0, 0, 255)
                        end
                    end
                end
            else
                -- Невинный — зелёный
                for _, p in pairs(v.Character:GetChildren()) do
                    if p.Name == ("Head") or p.Name == ("Torso") or p.Name == ("Right Arm") or p.Name == ("Right Leg") or p.Name == ("Left Arm") or p.Name == ("Left Leg") then 
                        for _, f in pairs(faces) do
                            local m = Instance.new("SurfaceGui", p)
                            m.Name = ("EGUI")
                            m.Face = f
                            m.AlwaysOnTop = true
                            local mf = Instance.new("Frame", m)
                            mf.Size = UDim2.new(1, 0, 1, 0)
                            mf.BorderSizePixel = 0
                            mf.BackgroundTransparency = 0.5
                            mf.BackgroundColor3 = Color3.new(0, 255, 0)
                        end
                    end
                end
            end
        end
    end
end

local function ClearESP()
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v.Name == ("EGUI") then
            v:Destroy()
        end
    end
end

-- Включаем/выключаем ESP
task.spawn(function()
    while true do
        wait(0.5)
        if getgenv().ESPEnabled then
            if not ESPToggle then
                ESPToggle = true
                ClearESP()
                MakeESP()
            end
        else
            if ESPToggle then
                ESPToggle = false
                ClearESP()
            end
        end
    end
end)

-- Обновляем ESP при добавлении/удалении игроков
game:GetService("Players").PlayerAdded:Connect(function()
    if ESPToggle then
        wait(1)
        ClearESP()
        MakeESP()
    end
end)

game:GetService("Players").PlayerRemoving:Connect(function()
    if ESPToggle then
        wait(1)
        ClearESP()
        MakeESP()
    end
end)

-- Периодическое обновление ESP (каждые 60 секунд)
task.spawn(function()
    while true do
        wait(60)
        if ESPToggle then
            ClearESP()
            MakeESP()
        end
    end
end)
