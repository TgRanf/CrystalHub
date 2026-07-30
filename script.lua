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
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ================= ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ =================

-- Silent Aim
getgenv().SilentAimEnabled = false

-- Хитбоксы & Бой
getgenv().HitboxEnabled = false
getgenv().HitboxSize = 5
getgenv().AutoGrabGunEnabled = false
getgenv().KillAllEnabled = false

-- Автофарм
getgenv().AutoFarmEnabled = false
getgenv().FarmSpeed = 30
getgenv().SmartFarm = true
getgenv().currentTween = nil

-- Визуалы & Персонаж
getgenv().ESPEnabled = false
getgenv().GunESPEnabled = false
getgenv().NoclipEnabled = false
getgenv().CustomSpeed = 16
getgenv().CustomJump = 50
getgenv().FlyEnabled = false
getgenv().FullBrightEnabled = false

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

-- ================= МГНОВЕННОЕ ОПРЕДЕЛЕНИЕ РОЛЕЙ =================
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

-- ================= SILENT AIM (ИЗ НОВОГО СКРИПТА) =================
local function getClosestTarget()
    if not getgenv().SilentAimEnabled then return nil end
    
    local targetPlayer = nil
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
    
    if targetPlayer and targetPlayer.Character then
        return targetPlayer.Character:FindFirstChild("Head")
    end
    return nil
end

local oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, index)
    if self == Mouse and not checkcaller() and getgenv().SilentAimEnabled then
        local targetPart = getClosestTarget()
        if targetPart then
            if index == "Hit" then
                return targetPart.CFrame
            elseif index == "Target" then
                return targetPart
            end
        end
    end
    return oldIndex(self, index)
end))
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 2/4
-- =================================================================

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

-- ================= KILL ALL (ИЗ НОВОГО СКРИПТА) =================
task.spawn(function()
    while true do
        task.wait(0.1)
        if getgenv().KillAllEnabled and getgenv().isInRound() then
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            
            local hrp = char.HumanoidRootPart
            
            for _, victim in ipairs(Players:GetPlayers()) do
                if victim == LocalPlayer then continue end
                if not victim.Character or not victim.Character:FindFirstChild("HumanoidRootPart") then continue end
                if victim.Character:FindFirstChild("Humanoid") and victim.Character.Humanoid.Health <= 0 then continue end
                
                repeat
                    hrp.CFrame = victim.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                    task.wait(0.1)
                until not victim.Character or not victim.Character:FindFirstChild("Humanoid") or victim.Character.Humanoid.Health <= 0
            end
        end
    end
end)

-- ================= АВТО-ПОДБОР ПИСТОЛЕТА =================
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

-- ================= КНОПКА ВЫСТРЕЛА =================
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

CombatTab:CreateToggle({
   Name = "Kill All Players",
   CurrentValue = false,
   Flag = "KillAllToggle",
   Callback = function(Value) getgenv().KillAllEnabled = Value end,
})

-- Вкладка: Silent Aim
SilentTab:CreateToggle({
   Name = "🎯 Включить Silent Aim (Тихий Аим)",
   CurrentValue = false,
   Flag = "SilentAimToggle",
   Callback = function(Value) getgenv().SilentAimEnabled = Value end,
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

-- Вкладка: Визуалы
VisualsTab:CreateToggle({
   Name = "Включить ESP Ролей (Игроки)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       getgenv().ESPEnabled = Value
       if not Value then
           for _, p in ipairs(Players:GetPlayers()) do
               if p.Character then
                   if p.Character:FindFirstChild("RoleESP") then p.Character.RoleESP:Destroy() end
                   if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("RoleTag") then
                       p.Character.Head.RoleTag:Destroy()
                   end
               end
           end
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "ESP Выпавшего Пистолета (Gun Drop ESP)",
   CurrentValue = false,
   Flag = "GunESPToggle",
   Callback = function(Value)
       getgenv().GunESPEnabled = Value
       if not Value then
           for _, obj in ipairs(Workspace:GetDescendants()) do
               if obj.Name == "GunDrop" then
                   if obj:FindFirstChild("GunESP") then obj.GunESP:Destroy() end
                   if obj:FindFirstChild("GunTag") then obj.GunTag:Destroy() end
               end
           end
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "FullBright (Яркий мир)",
   CurrentValue = false,
   Flag = "FullBrightToggle",
   Callback = function(Value)
       getgenv().FullBrightEnabled = Value
       if Value then
           Lighting.Brightness = 2
           Lighting.ClockTime = 14
           Lighting.FogEnd = 100000
           Lighting.GlobalShadows = false
           Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
           Rayfield:Notify({ Title = "CrystalHub", Content = "FullBright включён", Duration = 2 })
       else
           Lighting.Brightness = 1
           Lighting.ClockTime = 14
           Lighting.FogEnd = 1000
           Lighting.GlobalShadows = true
           Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
           Rayfield:Notify({ Title = "CrystalHub", Content = "FullBright выключен", Duration = 2 })
       end
   end,
})

-- Вкладка: Игрок
PlayerTab:CreateToggle({
   Name = "Noclip (Сквозь стены)",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value) getgenv().NoclipEnabled = Value end,
})

PlayerTab:CreateToggle({
   Name = "Fly (Полёт)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value) getgenv().FlyEnabled = Value end,
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
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 4/4
-- =================================================================

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

    -- ESP Игроков
    if getgenv().ESPEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local color = getgenv().playerRoles[p] or getgenv().COLOR_INNOCENT
                
                local hl = p.Character:FindFirstChild("RoleESP")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "RoleESP"
                    hl.Adornee = p.Character
                    hl.Parent = p.Character
                    hl.FillTransparency = 0.4
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                hl.FillColor = color
                hl.OutlineColor = color

                local tag = p.Character.Head:FindFirstChild("RoleTag")
                if not tag then
                    tag = Instance.new("BillboardGui")
                    tag.Name = "RoleTag"
                    tag.Size = UDim2.new(0, 120, 0, 30)
                    tag.StudsOffset = Vector3.new(0, 2.5, 0)
                    tag.AlwaysOnTop = true
                    tag.Parent = p.Character.Head

                    local label = Instance.new("TextLabel")
                    label.Name = "Text"
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.TextScaled = true
                    label.Font = Enum.Font.SourceSansBold
                    label.Parent = tag
                end

                local roleName = "НЕВИННЫЙ"
                if color == getgenv().COLOR_MURDERER then roleName = "УБИЙЦА 🔪" end
                if color == getgenv().COLOR_SHERIFF then roleName = "ШЕРИФ 🔫" end

                tag.Text.Text = p.Name .. " [" .. roleName .. "]"
                tag.Text.TextColor3 = color
            end
        end
    end

    -- ESP Пистолета
    if getgenv().GunESPEnabled then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                if not obj:FindFirstChild("GunESP") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "GunESP"
                    hl.Adornee = obj
                    hl.Parent = obj
                    hl.FillColor = Color3.fromRGB(255, 255, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.2
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                    local tag = Instance.new("BillboardGui")
                    tag.Name = "GunTag"
                    tag.Size = UDim2.new(0, 120, 0, 30)
                    tag.StudsOffset = Vector3.new(0, 2, 0)
                    tag.AlwaysOnTop = true
                    tag.Parent = obj

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = "🔫 ПИСТОЛЕТ"
                    label.TextColor3 = Color3.fromRGB(255, 255, 0)
                    label.TextScaled = true
                    label.Font = Enum.Font.SourceSansBold
                    label.Parent = tag
                end
            end
        end
    end
end)

-- ================= УПРАВЛЕНИЕ ФИЗИКОЙ =================
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

-- ================= FLY (ИЗ НОВОГО СКРИПТА) =================
local flyConnection = nil
local flyBodyGyro = nil
local flyBodyVelocity = nil
local flySpeed = 0
local flyMaxSpeed = 50

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    humanoid.PlatformStand = true
    
    flyBodyGyro = Instance.new("BodyGyro", torso)
    flyBodyGyro.P = 9e4
    flyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.cframe = torso.CFrame
    
    flyBodyVelocity = Instance.new("BodyVelocity", torso)
    flyBodyVelocity.velocity = Vector3.new(0, 0.1, 0)
    flyBodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    if flyConnection then flyConnection:Disconnect() end
    
    local controls = {f = 0, b = 0, l = 0, r = 0}
    local lastControls = {f = 0, b = 0, l = 0, r = 0}
    local speed = 0
    local maxSpeed = 50
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().FlyEnabled or not char or not char.Parent then
            if flyConnection then flyConnection:Disconnect() end
            return
        end
        
        local cam = Workspace.CurrentCamera
        if not cam then return end
        
        -- Управление WASD
        local moveDir = UserInputService:GetMoveDirection()
        
        if moveDir and moveDir.Magnitude > 0 then
            speed = math.min(maxSpeed, moveDir.Magnitude * maxSpeed)
            
            local lookVector = cam.CFrame.LookVector
            local rightVector = cam.CFrame.RightVector
            
            local moveVector = (lookVector * -moveDir.Z) + (rightVector * moveDir.X)
            flyBodyVelocity.velocity = moveVector * speed
            flyBodyGyro.cframe = cam.CFrame
        else
            speed = math.max(0, speed - 2)
            flyBodyVelocity.velocity = flyBodyVelocity.velocity * 0.9
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if getgenv().FlyEnabled then
            if not flyBodyVelocity then
                startFly()
            end
        else
            if flyConnection then flyConnection:Disconnect() end
            if flyBodyGyro then flyBodyGyro:Destroy() end
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
            
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = false
                end
            end
            
            flyBodyGyro = nil
            flyBodyVelocity = nil
            flyConnection = nil
        end
    end
end)

-- ================= ЛОГИКА АВТОФАРМА (ИЗ НОВОГО СКРИПТА) =================
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
