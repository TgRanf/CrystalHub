-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--            Includes: Instant Role Detect, Silent Aim,
--            AutoFarm, Hitbox Expander, Fling, ESP & More
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

-- Вкладки
local CombatTab   = Window:CreateTab("Бой", 4483362458)
local SilentTab   = Window:CreateTab("Silent Aim", 4483362458)
local FarmTab     = Window:CreateTab("Автофарм", 4483362458)
local TeleportTab = Window:CreateTab("Телепорты", 4483362458)
local VisualsTab  = Window:CreateTab("Визуалы", 4483362458)
local PlayerTab   = Window:CreateTab("Игрок", 4483362458)

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UIS = game:GetService("UserInputService")

-- ================= ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ =================

-- Silent Aim
getgenv().SilentAimEnabled = false
getgenv().SilentAimTargetMode = "Убийца"
getgenv().SilentAimHitChance = 100
getgenv().SilentAimPrediction = true
getgenv().SilentAimPredictionAmount = 0.165

-- Камера Аимбот
getgenv().AimbotEnabled = false
getgenv().VisibleCheckEnabled = true
getgenv().AimbotFOV = 130
getgenv().AimbotSmoothness = 4
getgenv().AimbotTargetMode = "Все"

-- Хитбоксы & Бой
getgenv().HitboxEnabled = false
getgenv().HitboxSize = 5
getgenv().AutoGrabGunEnabled = false
getgenv().AutoPickupGun = false
getgenv().GunDropNotifications = false

-- Автофарм
getgenv().AutoFarmEnabled = false
getgenv().FarmSpeed = 30
getgenv().SmartFarm = true
getgenv().currentTween = nil

-- Визуалы & Персонаж
getgenv().ESPEnabled = false
getgenv().ESPHighlightEnabled = false
getgenv().GunESPEnabled = false
getgenv().GunESPHighlightEnabled = false
getgenv().NoclipEnabled = false
getgenv().CustomSpeed = 16
getgenv().CustomJump = 50
getgenv().XRayEnabled = false

-- X-Ray переменные (из MM2 Utilities)
local xrayEnabled = false
local object = workspace

-- ================= ПРОВЕРКА СТАТУСА РАУНДА =================
getgenv().isInRound = function()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:FindFirstChild("CoinContainer") or obj:FindFirstChild("Spawns") or obj.Name == "Map" then
            return true
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("монет")) then
            return true
        end
    end
    return false
end

-- ================= МГНОВЕННОЕ ОПРЕДЕЛЕНИЕ РОЛЕЙ (0 ms) =================
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
            return p
        end
    end
    return nil
end
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 2/4
-- =================================================================

-- ================= SILENT AIM ДВИЖОК (__index & __namecall) =================
local function getSilentAimTarget()
    if not getgenv().SilentAimEnabled then return nil end
    
    if math.random(1, 100) > getgenv().SilentAimHitChance then
        return nil
    end

    local targetPlayer = nil
    
    if getgenv().SilentAimTargetMode == "Убийца" then
        targetPlayer = getgenv().getPlayerByRole(getgenv().COLOR_MURDERER)
    elseif getgenv().SilentAimTargetMode == "Шериф" then
        targetPlayer = getgenv().getPlayerByRole(getgenv().COLOR_SHERIFF)
    else
        local shortestDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        targetPlayer = p
                    end
                end
            end
        end
    end

    if targetPlayer and targetPlayer.Character then
        return targetPlayer.Character:FindFirstChild("Head") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    end

    return nil
end

-- 1. Перехват Mouse.Hit / Target
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, index)
    if self == Mouse and not checkcaller() and getgenv().SilentAimEnabled then
        local targetPart = getSilentAimTarget()
        if targetPart then
            if index == "Hit" or index == "hit" then
                if getgenv().SilentAimPrediction and targetPart:IsA("BasePart") then
                    return targetPart.CFrame + (targetPart.Velocity * getgenv().SilentAimPredictionAmount)
                end
                return targetPart.CFrame
            elseif index == "Target" or index == "target" then
                return targetPart
            end
        end
    end
    return oldIndex(self, index)
end))

-- 2. Перехват Raycast выстрела
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and getgenv().SilentAimEnabled and self == workspace then
        if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
            local targetPart = getSilentAimTarget()
            if targetPart then
                if method == "Raycast" then
                    local origin = args[1]
                    local targetPos = targetPart.Position
                    if getgenv().SilentAimPrediction then
                        targetPos = targetPos + (targetPart.Velocity * getgenv().SilentAimPredictionAmount)
                    end
                    args[2] = (targetPos - origin).Unit * 1000
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end

    return oldNamecall(self, ...)
end))

-- ================= СИСТЕМА ФЛИГА (FLING) =================
getgenv().flingTarget = function(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Цель не найдена!", Duration = 3 })
        return
    end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    local hrp = myChar.HumanoidRootPart
    local targetHrp = targetPlayer.Character.HumanoidRootPart
    local oldCFrame = hrp.CFrame
    local humanoid = myChar:FindFirstChildOfClass("Humanoid")

    for _, part in ipairs(myChar:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    if humanoid then humanoid.PlatformStand = true end

    local angle = 0
    local startTime = tick()
    local flingConn

    flingConn = RunService.Heartbeat:Connect(function()
        if tick() - startTime > 1.5 or not targetHrp or not targetHrp.Parent then
            if flingConn then flingConn:Disconnect() end
            return
        end

        hrp.CFrame = targetHrp.CFrame * CFrame.Angles(0, math.rad(angle), 0)
        hrp.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 99999, 0)
        angle = angle + 45
    end)

    task.wait(1.5)
    if flingConn then flingConn:Disconnect() end

    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    hrp.CFrame = oldCFrame
    if humanoid then humanoid.PlatformStand = false end

    for _, part in ipairs(myChar:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end

    Rayfield:Notify({ Title = "CrystalHub", Content = "Флинг завершён!", Duration = 3 })
end

-- ================= АВТО-ПОДБОР ПИСТОЛЕТА (ИЗ CRYSTALHUB) =================
task.spawn(function()
    local isGrabbing = false
    while task.wait(0.1) do
        if getgenv().AutoGrabGunEnabled and getgenv().isInRound() and not isGrabbing then
            local gunDrop = nil
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                    gunDrop = obj
                    break
                end
            end

            if gunDrop then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    isGrabbing = true
                    local oldCFrame = hrp.CFrame
                    hrp.CFrame = gunDrop.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.25)
                    hrp.CFrame = oldCFrame
                    Rayfield:Notify({ Title = "CrystalHub", Content = "Пистолет подхвачен!", Duration = 2 })
                    task.wait(1)
                    isGrabbing = false
                end
            end
        end
    end
end)

-- ================= КНОПКА ВЫСТРЕЛА (🎯) =================
local ShotGui = nil
getgenv().toggleShotButton = function(state)
    if state then
        if not ShotGui then
            ShotGui = Instance.new("ScreenGui")
            ShotGui.Name = "CrystalHubShotGui"
            ShotGui.Parent = CoreGui

            local btn = Instance.new("TextButton")
            btn.Name = "ShotBtn"
            btn.Parent = ShotGui
            btn.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
            btn.Position = UDim2.new(0.82, 0, 0.45, 0)
            btn.Size = UDim2.new(0, 55, 0, 55)
            btn.Font = Enum.Font.SourceSansBold
            btn.Text = "🎯"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 24
            btn.Draggable = true
            btn.Active = true

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = btn

            local stroke = Instance.new("UIStroke")
            stroke.Parent = btn
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Thickness = 2

            btn.MouseButton1Click:Connect(function()
                if not getgenv().isInRound() then
                    Rayfield:Notify({ Title = "CrystalHub", Content = "В лобби недоступно!", Duration = 3 })
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
                        Rayfield:Notify({ Title = "CrystalHub", Content = "Выстрел!", Duration = 2 })
                    end
                else
                    Rayfield:Notify({ Title = "CrystalHub", Content = "Убийца не найден!", Duration = 2 })
                end
            end)
        end
        ShotGui.Enabled = true
    else
        if ShotGui then ShotGui.Enabled = false end
    end
end
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 3/4
-- =================================================================

-- ================= ИНТЕРФЕЙС ЭЛЕМЕНТЫ =================

-- Вкладка: Бой
CombatTab:CreateToggle({
   Name = "Авто-подбор Пистолета (Auto-Grab Gun)",
   CurrentValue = false,
   Flag = "AutoGrabToggle",
   Callback = function(Value) getgenv().AutoGrabGunEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "Auto Pickup Gun (MM2 Utilities)",
   CurrentValue = false,
   Flag = "AutoPickupToggle",
   Callback = function(Value) getgenv().AutoPickupGun = Value end,
})

CombatTab:CreateButton({
   Name = "Флинг Убийцы (Fling Murderer)",
   Callback = function()
       local m = getgenv().getPlayerByRole(getgenv().COLOR_MURDERER)
       getgenv().flingTarget(m)
   end,
})

CombatTab:CreateButton({
   Name = "Флинг Шерифа (Fling Sheriff)",
   Callback = function()
       local s = getgenv().getPlayerByRole(getgenv().COLOR_SHERIFF)
       getgenv().flingTarget(s)
   end,
})

CombatTab:CreateToggle({
   Name = "Увеличение Хитбоксов (Hitbox Expander)",
   CurrentValue = false,
   Flag = "HitboxToggle",
   Callback = function(Value)
       getgenv().HitboxEnabled = Value
       if not Value then
           for _, p in ipairs(Players:GetPlayers()) do
               if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                   p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                   p.Character.HumanoidRootPart.Transparency = 1
               end
           end
       end
   end,
})

CombatTab:CreateSlider({
   Name = "Размер Хитбокса",
   Range = {2, 15},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 5,
   Flag = "HitboxSizeSlider",
   Callback = function(Value) getgenv().HitboxSize = Value end,
})

CombatTab:CreateToggle({
   Name = "Отображать кнопку Выстрела (🎯)",
   CurrentValue = false,
   Flag = "AutoShotToggle",
   Callback = function(Value) getgenv().toggleShotButton(Value) end,
})

-- Вкладка: Silent Aim
SilentTab:CreateToggle({
   Name = "🎯 Включить Silent Aim (Тихий Аим)",
   CurrentValue = false,
   Flag = "SilentAimToggle",
   Callback = function(Value) getgenv().SilentAimEnabled = Value end,
})

SilentTab:CreateDropdown({
   Name = "Цель Silent Aim",
   Options = {"Убийца", "Шериф", "Все"},
   CurrentOption = {"Убийца"},
   MultipleOptions = false,
   Flag = "SilentAimTargetDropdown",
   Callback = function(Option)
       getgenv().SilentAimTargetMode = type(Option) == "table" and Option[1] or Option
   end,
})

SilentTab:CreateToggle({
   Name = "Предикшн Движения (Prediction)",
   CurrentValue = true,
   Flag = "PredictionToggle",
   Callback = function(Value) getgenv().SilentAimPrediction = Value end,
})

SilentTab:CreateSlider({
   Name = "Коэффициент Предикшена",
   Range = {0, 0.5},
   Increment = 0.01,
   Suffix = " sec",
   CurrentValue = 0.165,
   Flag = "PredictionSlider",
   Callback = function(Value) getgenv().SilentAimPredictionAmount = Value end,
})

SilentTab:CreateSlider({
   Name = "Шанс Попадания (Hit Chance)",
   Range = {10, 100},
   Increment = 5,
   Suffix = "%",
   CurrentValue = 100,
   Flag = "HitChanceSlider",
   Callback = function(Value) getgenv().SilentAimHitChance = Value end,
})

-- Вкладка: Автофарм
FarmTab:CreateToggle({
   Name = "Включить Умный Автофарм Монет",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       getgenv().AutoFarmEnabled = Value
       if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
           LocalPlayer.Character.Humanoid.PlatformStand = false
           if getgenv().currentTween then getgenv().currentTween:Cancel() end
       end
   end,
})

FarmTab:CreateToggle({
   Name = "Безопасный режим (Обходить Убийцу)",
   CurrentValue = true,
   Flag = "SmartFarmToggle",
   Callback = function(Value) getgenv().SmartFarm = Value end,
})

FarmTab:CreateSlider({
   Name = "Скорость фарма",
   Range = {15, 50},
   Increment = 1,
   Suffix = " speed",
   CurrentValue = 30,
   Flag = "FarmSpeedSlider",
   Callback = function(Value) getgenv().FarmSpeed = Value end,
})

-- Вкладка: Телепорты
TeleportTab:CreateButton({
   Name = "Телепорт в Лобби",
   Callback = function()
       local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("LobbyMap")
       if lobby and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
           LocalPlayer.Character.HumanoidRootPart.CFrame = lobby:GetModelCFrame() + Vector3.new(0, 5, 0)
       else
           Rayfield:Notify({ Title = "CrystalHub", Content = "Лобби не найдено!", Duration = 2 })
       end
   end,
})

TeleportTab:CreateButton({
   Name = "Телепорт к Убийце 🔪",
   Callback = function()
       local m = getgenv().getPlayerByRole(getgenv().COLOR_MURDERER)
       if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
           LocalPlayer.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 3)
       else
           Rayfield:Notify({ Title = "CrystalHub", Content = "Убийца не найден!", Duration = 2 })
       end
   end,
})

TeleportTab:CreateButton({
   Name = "Телепорт к Шерифу 🔫",
   Callback = function()
       local s = getgenv().getPlayerByRole(getgenv().COLOR_SHERIFF)
       if s and s.Character and s.Character:FindFirstChild("HumanoidRootPart") then
           LocalPlayer.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 3)
       else
           Rayfield:Notify({ Title = "CrystalHub", Content = "Шериф не найден!", Duration = 2 })
       end
   end,
})

-- ================= НОВЫЕ ФУНКЦИИ ИЗ MM2 UTILITIES =================

-- Gun Drop Status + Уведомления (из MM2 Utilities)
local gunDropStatus = false
local gunDropNotified = false

local function checkGunDrop()
    local gunDrop = workspace:FindFirstChild("GunDrop", true)
    if gunDrop then
        gunDropStatus = true
        if getgenv().GunDropNotifications and not gunDropNotified then
            Rayfield:Notify({ Title = "CrystalHub", Content = "🔫 Пистолет упал!", Duration = 3 })
            gunDropNotified = true
        end
    else
        gunDropStatus = false
        gunDropNotified = false
    end
    return gunDropStatus
end

-- Вкладка: Визуалы
VisualsTab:CreateToggle({
   Name = "Gun Drop Notifications",
   CurrentValue = false,
   Flag = "GunDropNotifToggle",
   Callback = function(Value)
       getgenv().GunDropNotifications = Value
       if Value then
           Rayfield:Notify({ Title = "CrystalHub", Content = "Уведомления о пистолете включены", Duration = 2 })
       end
   end,
})

VisualsTab:CreateLabel({
   Name = "Gun Drop Status: Waiting...",
   Flag = "GunDropStatusLabel",
})

-- Обновление статуса
task.spawn(function()
    while true do
        task.wait(0.5)
        local status = checkGunDrop()
        local label = Window:GetFlag("GunDropStatusLabel")
        if label then
            if status then
                label:SetText("🔫 Gun Drop Status: DROPPED")
            else
                label:SetText("🔫 Gun Drop Status: NOT DROPPED")
            end
        end
    end
end)

-- X-Ray (из MM2 Utilities)
local xrayEnabled = false
local object = workspace

local function XrayOn(obj)
    for _, v in pairs(obj:GetChildren()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.LocalTransparencyModifier = 0.5
        end
        XrayOn(v)
    end
end

local function XrayOff(obj)
    for _, v in pairs(obj:GetChildren()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.LocalTransparencyModifier = 0
        end
        XrayOff(v)
    end
end

VisualsTab:CreateToggle({
   Name = "X-Ray (See Through Walls)",
   CurrentValue = false,
   Flag = "XRayToggle",
   Callback = function(Value)
       xrayEnabled = Value
       if Value then
           XrayOn(object)
           Rayfield:Notify({ Title = "CrystalHub", Content = "X-Ray включён", Duration = 2 })
       else
           XrayOff(object)
           Rayfield:Notify({ Title = "CrystalHub", Content = "X-Ray выключен", Duration = 2 })
       end
   end,
})

-- ================= ESP (ИЗ SIMPLE HUB V9.5.8) =================
local ESP_Active = false

local function GetPlayerRole(player)
    if not player then return "Innocent" end
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    
    if (backpack and backpack:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then
        return "Sheriff"
    elseif (backpack and backpack:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
        return "Murderer"
    end
    return "Innocent"
end

local function ManagementESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local existingHighlight = char:FindFirstChild("CrystalHubESP")
            
            if ESP_Active then
                if not existingHighlight then
                    existingHighlight = Instance.new("Highlight")
                    existingHighlight.Name = "CrystalHubESP"
                    existingHighlight.FillTransparency = 1
                    existingHighlight.OutlineTransparency = 0
                    existingHighlight.Parent = char
                end
                
                local role = GetPlayerRole(player)
                if role == "Murderer" then
                    existingHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                elseif role == "Sheriff" then
                    existingHighlight.OutlineColor = Color3.fromRGB(0, 100, 255)
                else
                    existingHighlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                end
            else
                if existingHighlight then existingHighlight:Destroy() end
            end
        end
    end
end

VisualsTab:CreateToggle({
   Name = "ESP Roles (Highlight)",
   CurrentValue = false,
   Flag = "ESPHighlightToggle",
   Callback = function(Value)
       ESP_Active = Value
       if not Value then
           for _, p in ipairs(Players:GetPlayers()) do
               if p.Character then
                   local hl = p.Character:FindFirstChild("CrystalHubESP")
                   if hl then hl:Destroy() end
               end
           end
       end
   end,
})

task.spawn(function()
    while task.wait(0.3) do
        ManagementESP()
    end
end)

-- ================= GUN ESP (ИЗ SIMPLE HUB V9.5.8) =================
local GunESP_Active = false

local function GetRealDroppedGun()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if (obj.Name == "GunDrop" or obj.Name == "Drop" or obj.Name == "Gun") and obj:IsA("Model") then
            if not Players:GetPlayerFromCharacter(obj) then return obj end
        end
    end
    local normalDrop = Workspace:FindFirstChild("GunDrop", true)
    if normalDrop and not normalDrop:IsDescendantOf(LocalPlayer.Character) then
        return normalDrop
    end
    return nil
end

local function UpdateGunESP()
    local droppedGun = GetRealDroppedGun()
    if droppedGun then
        local gunHighlight = droppedGun:FindFirstChild("GunESP_Outline")
        if GunESP_Active then
            if not gunHighlight then
                gunHighlight = Instance.new("Highlight")
                gunHighlight.Name = "GunESP_Outline"
                gunHighlight.FillTransparency = 0.5
                gunHighlight.FillColor = Color3.fromRGB(255, 130, 0)
                gunHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                gunHighlight.OutlineTransparency = 0
                gunHighlight.Parent = droppedGun
            end
        else
            if gunHighlight then gunHighlight:Destroy() end
        end
    end
end

VisualsTab:CreateToggle({
   Name = "Gun ESP (Highlight)",
   CurrentValue = false,
   Flag = "GunESPHighlightToggle",
   Callback = function(Value)
       GunESP_Active = Value
       if not Value then
           local gun = GetRealDroppedGun()
           if gun then
               local hl = gun:FindFirstChild("GunESP_Outline")
               if hl then hl:Destroy() end
           end
       end
   end,
})

task.spawn(function()
    while task.wait(0.5) do
        UpdateGunESP()
    end
end)

-- ================= СПЕКТИРОВАНИЕ (ИЗ MM2 UTILITIES) =================
local Spectating = Instance.new("TextLabel")
Spectating.Parent = CoreGui
Spectating.Position = UDim2.new(0.5, 0, 0.8, 0)
Spectating.Size = UDim2.new(0, 200, 0, 30)
Spectating.AnchorPoint = Vector2.new(0.5, 0.5)
Spectating.BackgroundTransparency = 1
Spectating.Text = "Spectating: None"
Spectating.TextColor3 = Color3.fromRGB(255, 255, 255)
Spectating.TextSize = 24
Spectating.Font = Enum.Font.GothamBold
Spectating.Visible = false

local mbtn = false
local sbtn = false

-- Используем кнопки из интерфейса для спектирования
-- Эти функции будут вызваны из кнопок "Телепорт к Убийце" и "Телепорт к Шерифу"
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 4/4
-- =================================================================

-- ================= ВКЛАДКА: ИГРОК =================
PlayerTab:CreateToggle({
   Name = "Noclip (Сквозь стены)",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value) getgenv().NoclipEnabled = Value end,
})

PlayerTab:CreateSlider({
   Name = "Скорость Бега",
   Range = {16, 120},
   Increment = 1,
   Suffix = " speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value) getgenv().CustomSpeed = Value end,
})

PlayerTab:CreateSlider({
   Name = "Высота Прыжка",
   Range = {50, 200},
   Increment = 1,
   Suffix = " power",
   CurrentValue = 50,
   Flag = "JumpSlider",
   Callback = function(Value) getgenv().CustomJump = Value end,
})

-- ================= РЕНДЕР И ОБНОВЛЕНИЯ =================

RunService.RenderStepped:Connect(function()
    -- Hitbox Expander
    if getgenv().HitboxEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                hrp.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                hrp.Transparency = 0.7
                hrp.Color = Color3.fromRGB(255, 0, 0)
                hrp.CanCollide = false
            end
        end
    end
end)

-- Управление физикой игрока
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = getgenv().CustomSpeed or 16
            humanoid.JumpPower = getgenv().CustomJump or 50
        end
        if getgenv().NoclipEnabled then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- ================= АВТО-ПОДБОР ПИСТОЛЕТА (ИЗ MM2 UTILITIES) =================
task.spawn(function()
    while task.wait(0.3) do
        if getgenv().AutoPickupGun and getgenv().isInRound() and getgenv().isAlive() then
            local gunDrop = workspace:FindFirstChild("GunDrop", true)
            if gunDrop then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local oldCF = hrp.CFrame
                    hrp.CFrame = gunDrop.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.2)
                    hrp.CFrame = oldCF
                    Rayfield:Notify({ Title = "CrystalHub", Content = "🔫 Пистолет подобран!", Duration = 2 })
                    task.wait(1)
                end
            end
        end
    end
end)

-- ================= X-RAY HOTKEY (T) (ИЗ MM2 UTILITIES) =================
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.T then
        xrayEnabled = not xrayEnabled
        if xrayEnabled then
            XrayOn(object)
            Rayfield:Notify({ Title = "CrystalHub", Content = "X-Ray включён (T)", Duration = 2 })
        else
            XrayOff(object)
            Rayfield:Notify({ Title = "CrystalHub", Content = "X-Ray выключен (T)", Duration = 2 })
        end
    end
end)

-- ================= CTRL + CLICK TELEPORT (ИЗ MM2 UTILITIES) =================
local ctrlpressed = false

mouse.Button1Down:Connect(function()
    if ctrlpressed then
        LocalPlayer.Character:MoveTo(mouse.Hit.p)
        Rayfield:Notify({ Title = "CrystalHub", Content = "Телепорт по клику!", Duration = 2 })
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        ctrlpressed = true
    end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        ctrlpressed = false
    end
end)

-- ================= ЛОГИКА АВТОФАРМА =================
task.spawn(function()
    while true do
        task.wait(0.1)
        if getgenv().AutoFarmEnabled then
            if not getgenv().isInRound() then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.PlatformStand = false
                end
                if getgenv().currentTween then getgenv().currentTween:Cancel() end
                continue
            end

            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hrp = char.HumanoidRootPart
                local murderer = getgenv().getPlayerByRole(getgenv().COLOR_MURDERER)
                local murdPos = (murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")) and murderer.Character.HumanoidRootPart.Position

                local closestCoin = nil
                local shortestDist = math.huge

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("монет")) then
                        local isSafe = true
                        if getgenv().SmartFarm and murdPos then
                            if (obj.Position - murdPos).Magnitude < 25 then
                                isSafe = false
                            end
                        end

                        if isSafe then
                            local dist = (hrp.Position - obj.Position).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                closestCoin = obj
                            end
                        end
                    end
                end

                if closestCoin then
                    char.Humanoid.PlatformStand = true
                    local dist = (closestCoin.Position - hrp.Position).Magnitude
                    local time = dist / (getgenv().FarmSpeed or 30)

                    if time > 0.05 then
                        if getgenv().currentTween then getgenv().currentTween:Cancel() end
                        getgenv().currentTween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(closestCoin.Position)})
                        getgenv().currentTween:Play()

                        local elapsed = 0
                        while elapsed < time and getgenv().AutoFarmEnabled and closestCoin and closestCoin.Parent and getgenv().isInRound() do
                            task.wait(0.05)
                            elapsed = elapsed + 0.05
                        end
                    end
                else
                    char.Humanoid.PlatformStand = false
                    if getgenv().currentTween then getgenv().currentTween:Cancel() end
                end
            end
        end
    end
end)

print("CrystalHub MM2 Ultimate - Loaded!")
