local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "CrystalHub | MM2 Ultimate",
   Icon = 0,
   LoadingTitle = "CrystalHub MM2",
   LoadingSubtitle = "Mobile & PC Edition",
   Theme = "Default",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = false,
      FolderName = "CrystalHub",
      FileName = "MM2Config"
   },

   KeySystem = false
})

-- Вкладки
local CombatTab = Window:CreateTab("Бой", 4483362458)
local FarmTab = Window:CreateTab("Автофарм", 4483362458)
local VisualsTab = Window:CreateTab("Визуалы", 4483362458)
local PlayerTab = Window:CreateTab("Игрок", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Глобальные настройки
getgenv().AimbotEnabled = false
getgenv().VisibleCheckEnabled = true
getgenv().AimbotFOV = 130
getgenv().AimbotSmoothness = 4
getgenv().AimbotTargetMode = "Все"

getgenv().AutoFarmEnabled = false
getgenv().FarmSpeed = 30
getgenv().currentTween = nil

getgenv().ESPEnabled = false
getgenv().NoclipEnabled = false
getgenv().CustomSpeed = 16
getgenv().CustomJump = 50

-- Логика игры
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

getgenv().playerRoles = {}
getgenv().COLOR_INNOCENT = Color3.fromRGB(0, 255, 0)
getgenv().COLOR_SHERIFF  = Color3.fromRGB(0, 150, 255)
getgenv().COLOR_MURDERER = Color3.fromRGB(255, 0, 0)

local function detectToolRole(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local name = tool.Name:lower()
    if name:find("knife") or name:find("нож") or name:find("blade") then
        return getgenv().COLOR_MURDERER
    elseif name:find("gun") or name:find("revolver") or name:find("pistol") or name:find("пест") then
        return getgenv().COLOR_SHERIFF
    end
    return nil
end

local function hookPlayerInventory(player)
    getgenv().playerRoles[player] = getgenv().COLOR_INNOCENT

    local function bindContainer(container)
        if not container then return end
        container.ChildAdded:Connect(function(child)
            local roleColor = detectToolRole(child)
            if roleColor then
                getgenv().playerRoles[player] = roleColor
            end
        end)
        for _, child in ipairs(container:GetChildren()) do
            local roleColor = detectToolRole(child)
            if roleColor then
                getgenv().playerRoles[player] = roleColor
            end
        end
    end

    if player.Character then bindContainer(player.Character) end
    local bp = player:FindFirstChild("Backpack")
    if bp then bindContainer(bp) end

    player.CharacterAdded:Connect(function(char)
        getgenv().playerRoles[player] = getgenv().COLOR_INNOCENT
        bindContainer(char)
        task.spawn(function()
            local newBp = player:WaitForChild("Backpack", 5)
            if newBp then bindContainer(newBp) end
        end)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do hookPlayerInventory(p) end
Players.PlayerAdded:Connect(hookPlayerInventory)

getgenv().getPlayerByRole = function(roleColor)
    for p, color in pairs(getgenv().playerRoles) do
        if p ~= LocalPlayer and color == roleColor and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            return p
        end
    end
    return nil
end

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
                    Rayfield:Notify({ Title = "CrystalHub", Content = "Функция недоступна в лобби!", Duration = 3 })
                    return
                end

                local murderer = getgenv().getPlayerByRole(getgenv().COLOR_MURDERER)
                if murderer and murderer.Character and murderer.Character:FindFirstChild("Head") then
                    local targetHead = murderer.Character.Head
                    
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    if bp then
                        local gun = bp:FindFirstChildOfClass("Tool")
                        if gun and detectToolRole(gun) == getgenv().COLOR_SHERIFF then
                            LocalPlayer.Character.Humanoid:EquipTool(gun)
                            task.wait(0.05)
                        end
                    end
                    
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
                        tool:Activate()
                        Rayfield:Notify({ Title = "CrystalHub", Content = "Пуля выпущена в Убийцу!", Duration = 2 })
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

getgenv().flingTarget = function(targetPlayer)
    if not getgenv().isInRound() then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Нельзя использовать в Лобби!", Duration = 3 })
        return
    end

    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Цель не найдена!", Duration = 3 })
        return
    end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    local hrp = myChar.HumanoidRootPart
    local targetHrp = targetPlayer.Character.HumanoidRootPart
    local oldPos = hrp.CFrame

    for _, part in ipairs(myChar:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    myChar.Humanoid.PlatformStand = true

    local flingConn = RunService.Heartbeat:Connect(function()
        if not targetHrp or not targetHrp.Parent then return end
        hrp.CFrame = targetHrp.CFrame
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 99999, 0)
    end)

    task.wait(1.5)
    flingConn:Disconnect()

    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    hrp.CFrame = oldPos
    myChar.Humanoid.PlatformStand = false

    for _, part in ipairs(myChar:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end

    Rayfield:Notify({ Title = "CrystalHub", Content = "Цель успешно выброшена!", Duration = 3 })
end

getgenv().autoGrabGun = function()
    if not getgenv().isInRound() then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Вы находитесь в лобби!", Duration = 3 })
        return
    end

    local gunDrop = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "GunDrop" and obj:IsA("BasePart") then
            gunDrop = obj
            break
        end
    end

    if not gunDrop then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Выпавший пистолет не найден!", Duration = 3 })
        return
    end

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local oldCFrame = hrp.CFrame
        hrp.CFrame = gunDrop.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.2)
        hrp.CFrame = oldCFrame
        Rayfield:Notify({ Title = "CrystalHub", Content = "Пистолет подобран!", Duration = 3 })
    end
end

getgenv().isVisible = function(targetPart)
    if not getgenv().VisibleCheckEnabled then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    if result and result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return not result
end

getgenv().getClosestInFOV = function()
    local closestTarget = nil
    local shortestDist = getgenv().AimbotFOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if humanoid and humanoid.Health > 0 and head then
                local roleColor = getgenv().playerRoles[player]
                local validRole = true
                
                if getgenv().AimbotTargetMode == "Только Убийца" then
                    validRole = (roleColor == getgenv().COLOR_MURDERER)
                elseif getgenv().AimbotTargetMode == "Только Шериф" then
                    validRole = (roleColor == getgenv().COLOR_SHERIFF)
                end
                
                if validRole then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist < shortestDist and getgenv().isVisible(head) then
                            shortestDist = dist
                            closestTarget = head
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

-- ================= ИНТЕРФЕЙС RAYFIELD =================

-- Вкладка: Бой
CombatTab:CreateToggle({
   Name = "Отображать кнопку Auto-Shot (🎯)",
   CurrentValue = false,
   Flag = "AutoShotToggle",
   Callback = function(Value)
       getgenv().toggleShotButton(Value)
   end,
})

CombatTab:CreateButton({
   Name = "Авто-подбор Пистолета (Auto-Grab Gun)",
   Callback = function()
       getgenv().autoGrabGun()
   end,
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
   Name = "Включить Аимбот",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
       getgenv().AimbotEnabled = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Проверка стен (Visible Check)",
   CurrentValue = true,
   Flag = "VisibleCheckToggle",
   Callback = function(Value)
       getgenv().VisibleCheckEnabled = Value
   end,
})

CombatTab:CreateDropdown({
   Name = "Цель аимбота (Кого атаковать)",
   Options = {"Все", "Только Убийца", "Только Шериф"},
   CurrentOption = {"Все"},
   MultipleOptions = false,
   Flag = "AimbotTargetDropdown",
   Callback = function(Option)
       local selected = type(Option) == "table" and Option[1] or Option
       getgenv().AimbotTargetMode = selected
   end,
})

CombatTab:CreateSlider({
   Name = "Радиус захвата FOV",
   Range = {50, 300},
   Increment = 5,
   Suffix = " px",
   CurrentValue = 130,
   Flag = "AimbotFOVSlider",
   Callback = function(Value)
       getgenv().AimbotFOV = Value
   end,
})

-- Вкладка: Автофарм
FarmTab:CreateToggle({
   Name = "Включить Автофарм Монет",
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

FarmTab:CreateSlider({
   Name = "Скорость фарма",
   Range = {15, 50},
   Increment = 1,
   Suffix = " speed",
   CurrentValue = 30,
   Flag = "FarmSpeedSlider",
   Callback = function(Value)
       getgenv().FarmSpeed = Value
   end,
})

-- Вкладка: Визуалы
VisualsTab:CreateToggle({
   Name = "Включить ESP (Мгновенные Роли)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       getgenv().ESPEnabled = Value
       for _, p in ipairs(Players:GetPlayers()) do
           if p ~= LocalPlayer and p.Character then
               if Value then
                   if not p.Character:FindFirstChild("RoleESP") then
                       local hl = Instance.new("Highlight")
                       hl.Name = "RoleESP"
                       hl.Adornee = p.Character
                       hl.Parent = p.Character
                       hl.FillTransparency = 0.5
                       hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                   end
               else
                   if p.Character:FindFirstChild("RoleESP") then p.Character.RoleESP:Destroy() end
               end
           end
       end
   end,
})

-- Вкладка: Игрок
PlayerTab:CreateToggle({
   Name = "Noclip (Сквозь стены)",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
       getgenv().NoclipEnabled = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "Скорость Бега",
   Range = {16, 120},
   Increment = 1,
   Suffix = " speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
       getgenv().CustomSpeed = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "Высота Прыжка",
   Range = {50, 200},
   Increment = 1,
   Suffix = " power",
   CurrentValue = 50,
   Flag = "JumpSlider",
   Callback = function(Value)
       getgenv().CustomJump = Value
   end,
})

-- Циклы и фоновые процессы
RunService.RenderStepped:Connect(function()
    if getgenv().AimbotEnabled then
        local target = getgenv().getClosestInFOV()
        if target then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / (getgenv().AimbotSmoothness or 4))
        end
    end

    if getgenv().ESPEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("RoleESP") then
                local color = getgenv().playerRoles[p] or getgenv().COLOR_INNOCENT
                p.Character.RoleESP.FillColor = color
                p.Character.RoleESP.OutlineColor = color
            end
        end
    end
end)

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
                        if not (murdPos and (obj.Position - murdPos).Magnitude < 20) then
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
