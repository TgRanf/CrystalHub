-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--            Includes: Instant Role Detect, Silent Aim,
--            AutoFarm, Hitbox Expander, Fling, ESP & More
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

-- Автофарм
getgenv().AutoFarmEnabled = false
getgenv().FarmSpeed = 30
getgenv().SmartFarm = true
getgenv().currentTween = nil
getgenv().isFarming = false

-- Визуалы & Персонаж
getgenv().ESPEnabled = false
getgenv().GunESPEnabled = false
getgenv().NoclipEnabled = false
getgenv().CustomSpeed = 16
getgenv().CustomJump = 50

-- ================= ПРОВЕРКА СТАТУСА =================
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
            Rayfield:Notify({ Title = "CrystalHub", Content = "Убийца найден: " .. player.Name, Duration = 3 })
        end
    elseif name:find("gun") or name:find("revolver") or name:find("pistol") or name:find("пест") or name:find("luger") then
        if getgenv().playerRoles[player] ~= getgenv().COLOR_SHERIFF then
            getgenv().playerRoles[player] = getgenv().COLOR_SHERIFF
            Rayfield:Notify({ Title = "CrystalHub", Content = "Шериф найден: " .. player.Name, Duration = 3 })
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
    
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
            getgenv().playerRoles[player] = nil
        end
    end)
end

task.spawn(function()
    while task.wait(1) do
        if not getgenv().isInRound() then
            table.clear(getgenv().playerRoles)
        end
        for p, _ in pairs(getgenv().playerRoles) do
            if not p.Character or not p.Character:FindFirstChild("Humanoid") or p.Character.Humanoid.Health <= 0 then
                getgenv().playerRoles[p] = nil
            end
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
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 2/4
-- =================================================================

-- ================= SILENT AIM =================
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

-- ================= СИСТЕМА ФЛИГА =================
getgenv().flingTarget = function(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Цель не найдена!", Duration = 3 })
        return
    end

    local char = LocalPlayer.Character
    if not char then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Персонаж не найден!", Duration = 3 })
        return
    end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            tool = bp:FindFirstChildOfClass("Tool")
            if tool then
                char.Humanoid:EquipTool(tool)
                task.wait(0.1)
                tool = char:FindFirstChildOfClass("Tool")
            end
        end
    end

    if not tool then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Нет инструмента!", Duration = 3 })
        return
    end

    local handle = tool:FindFirstChild("Handle")
    if not handle then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Нет Handle!", Duration = 3 })
        return
    end

    local originalCF = handle.CFrame
    local targetParts = {}
    for _, part in ipairs(targetPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(targetParts, part)
        end
    end

    if #targetParts == 0 then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Нет частей у цели!", Duration = 3 })
        return
    end

    for i = 1, 15 do
        for _, part in ipairs(targetParts) do
            if part and part.Parent then
                handle.CFrame = part.CFrame * CFrame.new(0, 0, 0.5)
                task.wait(0.01)
            end
        end
        task.wait(0.02)
    end

    handle.CFrame = originalCF
    Rayfield:Notify({ Title = "CrystalHub", Content = "Флинг выполнен!", Duration = 3 })
end

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
            btn.Text = "SHOT"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 18
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
                if not getgenv().isInRound() or not getgenv().isAlive() then
                    Rayfield:Notify({ Title = "CrystalHub", Content = "Недоступно!", Duration = 3 })
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

CombatTab:CreateToggle({
   Name = "Авто-подбор Пистолета",
   CurrentValue = false,
   Flag = "AutoGrabToggle",
   Callback = function(Value) getgenv().AutoGrabGunEnabled = Value end,
})

CombatTab:CreateButton({
   Name = "Флинг Убийцы",
   Callback = function()
       local m = getgenv().getPlayerByRole(getgenv().COLOR_MURDERER)
       getgenv().flingTarget(m)
   end,
})

CombatTab:CreateButton({
   Name = "Флинг Шерифа",
   Callback = function()
       local s = getgenv().getPlayerByRole(getgenv().COLOR_SHERIFF)
       getgenv().flingTarget(s)
   end,
})

CombatTab:CreateToggle({
   Name = "Увеличение Хитбоксов",
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
   Name = "Кнопка Выстрела",
   CurrentValue = false,
   Flag = "AutoShotToggle",
   Callback = function(Value) getgenv().toggleShotButton(Value) end,
})

SilentTab:CreateToggle({
   Name = "Silent Aim",
   CurrentValue = false,
   Flag = "SilentAimToggle",
   Callback = function(Value) getgenv().SilentAimEnabled = Value end,
})

SilentTab:CreateDropdown({
   Name = "Цель",
   Options = {"Убийца", "Шериф", "Все"},
   CurrentOption = {"Убийца"},
   MultipleOptions = false,
   Flag = "SilentAimTargetDropdown",
   Callback = function(Option)
       getgenv().SilentAimTargetMode = type(Option) == "table" and Option[1] or Option
   end,
})

SilentTab:CreateToggle({
   Name = "Предикшн",
   CurrentValue = true,
   Flag = "PredictionToggle",
   Callback = function(Value) getgenv().SilentAimPrediction = Value end,
})

SilentTab:CreateSlider({
   Name = "Коэффициент",
   Range = {0, 0.5},
   Increment = 0.01,
   Suffix = " sec",
   CurrentValue = 0.165,
   Flag = "PredictionSlider",
   Callback = function(Value) getgenv().SilentAimPredictionAmount = Value end,
})

SilentTab:CreateSlider({
   Name = "Шанс попадания",
   Range = {10, 100},
   Increment = 5,
   Suffix = "%",
   CurrentValue = 100,
   Flag = "HitChanceSlider",
   Callback = function(Value) getgenv().SilentAimHitChance = Value end,
})

FarmTab:CreateToggle({
   Name = "Автофарм монет",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       getgenv().AutoFarmEnabled = Value
       if not Value then
           if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
               LocalPlayer.Character.Humanoid.PlatformStand = false
           end
           if getgenv().currentTween then getgenv().currentTween:Cancel() end
           getgenv().isFarming = false
           stopFlying()
       end
   end,
})

FarmTab:CreateToggle({
   Name = "Обходить убийцу",
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

-- ================= ТЕЛЕПОРТЫ (БЕЗ ЭМОДЗИ) =================
TeleportTab:CreateButton({
   Name = "Teleport to Lobby",
   Callback = function()
       local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("LobbyMap")
       if lobby and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
           LocalPlayer.Character.HumanoidRootPart.CFrame = lobby:GetModelCFrame() + Vector3.new(0, 5, 0)
       else
           LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-108.5, 145, 0.6)
           Rayfield:Notify({ Title = "CrystalHub", Content = "Teleported to Lobby", Duration = 2 })
       end
   end,
})

TeleportTab:CreateButton({
   Name = "Teleport to Map Spawn",
   Callback = function()
       local success = false
       for _, child in ipairs(Workspace:GetDescendants()) do
           if child.Name == "Spawns" and child:FindFirstChild("Spawn") then
               LocalPlayer.Character.HumanoidRootPart.CFrame = child.Spawn.CFrame
               success = true
               Rayfield:Notify({ Title = "CrystalHub", Content = "Teleported to Map", Duration = 2 })
               break
           end
       end
       if not success then
           Rayfield:Notify({ Title = "CrystalHub", Content = "Spawn not found!", Duration = 2 })
       end
   end,
})

TeleportTab:CreateButton({
   Name = "Teleport to Murderer",
   Callback = function()
       local m = getgenv().getPlayerByRole(getgenv().COLOR_MURDERER)
       if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
           LocalPlayer.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 3)
       else
           Rayfield:Notify({ Title = "CrystalHub", Content = "Murderer not found!", Duration = 2 })
       end
   end,
})

TeleportTab:CreateButton({
   Name = "Teleport to Sheriff",
   Callback = function()
       local s = getgenv().getPlayerByRole(getgenv().COLOR_SHERIFF)
       if s and s.Character and s.Character:FindFirstChild("HumanoidRootPart") then
           LocalPlayer.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 3)
       else
           Rayfield:Notify({ Title = "CrystalHub", Content = "Sheriff not found!", Duration = 2 })
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "ESP Ролей",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       getgenv().ESPEnabled = Value
       if not Value then
           for _, p in ipairs(Players:GetPlayers()) do
               if p.Character then
                   if p.Character:FindFirstChild("G_H") then p.Character.G_H:Destroy() end
                   if p.Character:FindFirstChild("RoleESP") then p.Character.RoleESP:Destroy() end
                   if p.Character.Head and p.Character.Head:FindFirstChild("RoleTag") then
                       p.Character.Head.RoleTag:Destroy()
                   end
               end
           end
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "ESP Пистолета",
   CurrentValue = false,
   Flag = "GunESPToggle",
   Callback = function(Value)
       getgenv().GunESPEnabled = Value
       if not Value then
           for _, obj in ipairs(Workspace:GetDescendants()) do
               if obj.Name == "GunDrop" or obj.Name == "DroppedGun" then
                   if obj:FindFirstChild("GunESP") then obj.GunESP:Destroy() end
                   if obj:FindFirstChild("GunTag") then obj.GunTag:Destroy() end
               end
           end
       end
   end,
})

PlayerTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value) getgenv().NoclipEnabled = Value end,
})

PlayerTab:CreateSlider({
   Name = "Speed",
   Range = {16, 120},
   Increment = 1,
   Suffix = " speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value) getgenv().CustomSpeed = Value end,
})
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 4/4
-- =================================================================

-- ================= ESP ИГРОКОВ (ОПТИМИЗИРОВАННЫЙ) =================
local function updateESP()
    if not getgenv().ESPEnabled or not getgenv().isInRound() then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                if p.Character:FindFirstChild("G_H") then p.Character.G_H:Destroy() end
                if p.Character:FindFirstChild("RoleESP") then p.Character.RoleESP:Destroy() end
                if p.Character.Head and p.Character.Head:FindFirstChild("RoleTag") then
                    p.Character.Head.RoleTag:Destroy()
                end
            end
        end
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not p.Character then continue end
        
        local hum = p.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then
            if p.Character:FindFirstChild("G_H") then p.Character.G_H:Destroy() end
            if p.Character:FindFirstChild("RoleESP") then p.Character.RoleESP:Destroy() end
            if p.Character.Head and p.Character.Head:FindFirstChild("RoleTag") then
                p.Character.Head.RoleTag:Destroy()
            end
            continue
        end

        local color = getgenv().playerRoles[p] or getgenv().COLOR_INNOCENT
        
        local hl = p.Character:FindFirstChild("G_H")
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "G_H"
            hl.Adornee = p.Character
            hl.Parent = p.Character
            hl.FillTransparency = 0.3
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
        hl.FillColor = color
        hl.OutlineColor = color

        local tag = p.Character.Head:FindFirstChild("RoleTag")
        if not tag then
            tag = Instance.new("BillboardGui")
            tag.Name = "RoleTag"
            tag.Size = UDim2.new(0, 80, 0, 20)
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

        local roleName = "INNOCENT"
        if color == getgenv().COLOR_MURDERER then roleName = "MURDERER" end
        if color == getgenv().COLOR_SHERIFF then roleName = "SHERIFF" end
        tag.Text.Text = roleName
        tag.Text.TextColor3 = color
    end
end

task.spawn(function()
    while task.wait(0.3) do
        updateESP()
    end
end)

-- ================= ESP ПИСТОЛЕТА =================
local function updateGunESP()
    if not getgenv().GunESPEnabled or not getgenv().isInRound() then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "GunDrop" or obj.Name == "DroppedGun" then
                if obj:FindFirstChild("GunESP") then obj.GunESP:Destroy() end
                if obj:FindFirstChild("GunTag") then obj.GunTag:Destroy() end
            end
        end
        return
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj.Name == "GunDrop" or obj.Name == "DroppedGun") and obj:IsA("BasePart") then
            if not obj:FindFirstChild("GunESP") then
                local hl = Instance.new("Highlight")
                hl.Name = "GunESP"
                hl.Adornee = obj
                hl.Parent = obj
                hl.FillColor = Color3.fromRGB(255, 255, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.1
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                local tag = Instance.new("BillboardGui")
                tag.Name = "GunTag"
                tag.Size = UDim2.new(0, 40, 0, 15)
                tag.StudsOffset = Vector3.new(0, 1.5, 0)
                tag.AlwaysOnTop = true
                tag.Parent = obj
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = "GUN"
                label.TextColor3 = Color3.fromRGB(255, 255, 0)
                label.TextScaled = true
                label.Font = Enum.Font.SourceSansBold
                label.Parent = tag
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        updateGunESP()
    end
end)

-- ================= АВТО-ПОДБОР ПИСТОЛЕТА =================
task.spawn(function()
    while task.wait(0.15) do
        if not getgenv().AutoGrabGunEnabled then continue end
        if not getgenv().isInRound() or not getgenv().isAlive() then continue end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        
        local gunDrop = nil
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj.Name == "GunDrop" or obj.Name == "DroppedGun") and obj:IsA("BasePart") then
                gunDrop = obj
                break
            end
        end
        
        if gunDrop then
            local hrp = char.HumanoidRootPart
            local oldCF = hrp.CFrame
            hrp.CFrame = gunDrop.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.15)
            hrp.CFrame = oldCF
            Rayfield:Notify({ Title = "CrystalHub", Content = "Gun picked up!", Duration = 2 })
            task.wait(0.5)
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

-- ================= АВТОФАРМ (ПЛАВНЫЙ ПОЛЁТ) =================
local flyToggle = false
local flyBodyVelocity = nil
local flyBodyGyro = nil

local function stopFlying()
    flyToggle = false
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    flyBodyVelocity = nil
    flyBodyGyro = nil
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

local function startFlying(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    
    flyToggle = true
    humanoid.PlatformStand = true
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVelocity.P = 9e4
    flyBodyVelocity.Parent = hrp
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.P = 9e4
    flyBodyGyro.Parent = hrp
    
    local startPos = hrp.Position
    local distance = (targetPos - startPos).Magnitude
    local speed = math.min(distance / 0.3, 80)
    
    while flyToggle and hrp and hrp.Parent do
        local currentPos = hrp.Position
        local direction = (targetPos - currentPos).Unit
        local distToTarget = (targetPos - currentPos).Magnitude
        
        if distToTarget < 2 then
            break
        end
        
        local speedMultiplier = math.min(distToTarget / 10, 1)
        local currentSpeed = speed * (0.5 + speedMultiplier * 0.5)
        
        flyBodyVelocity.Velocity = direction * currentSpeed
        flyBodyGyro.CFrame = CFrame.lookAt(hrp.Position, targetPos)
        
        task.wait()
    end
    
    stopFlying()
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if getgenv().AutoFarmEnabled and getgenv().isInRound() and getgenv().isAlive() then
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
                task.wait(0.5)
                continue
            end
            
            local hrp = char.HumanoidRootPart
            
            local murderer = getgenv().getPlayerByRole(getgenv().COLOR_MURDERER)
            local murdPos = nil
            if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                murdPos = murderer.Character.HumanoidRootPart.Position
            end

            local bestCoin = nil
            local bestDist = math.huge
            
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("монет")) then
                    if getgenv().SmartFarm and murdPos then
                        if (obj.Position - murdPos).Magnitude < 30 then
                            continue
                        end
                    end
                    
                    local dist = (hrp.Position - obj.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestCoin = obj
                    end
                end
            end

            if bestCoin then
                startFlying(bestCoin.Position)
                task.wait(0.05)
                
                local flyDirection = (hrp.Position - (murdPos or Vector3.new(0, 0, 0))).Unit
                if flyDirection.Magnitude < 0.1 then
                    flyDirection = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit
                end
                
                hrp.CFrame = hrp.CFrame + (flyDirection * 15)
                stopFlying()
                
                task.wait(0.05)
            else
                stopFlying()
                task.wait(0.5)
            end
        else
            stopFlying()
            task.wait(0.5)
        end
    end
end)

-- ================= ХИТБОКСЫ =================
RunService.RenderStepped:Connect(function()
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

print("CrystalHub MM2 Ultimate - Fully Loaded!")
PlayerTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 200},
   Increment = 1,
   Suffix = " power",
   CurrentValue = 50,
   Flag = "JumpSlider",
   Callback = function(Value) getgenv().CustomJump = Value end,
})
