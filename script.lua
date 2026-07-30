-- ====================================================================
-- Crystal Pro Mobile | FOV Aimbot + Auto-Shot Btn + Coin Farm + ESP
-- ====================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Crystal Pro Mobile Hub",
   LoadingTitle = "Загрузка мобильного софта...",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
   Theme = "Amethyst"
})

-- Вкладки
local CombatTab = Window:CreateTab("Бой & Аим", 4483362458)
local FarmTab = Window:CreateTab("Автофарм", 4483362458)
local VisualsTab = Window:CreateTab("Визуалы (ESP)", 4483362458)
local PlayerTab = Window:CreateTab("Игрок", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Настройки
local AimbotEnabled = false
local VisibleCheckEnabled = true
local AimbotSmoothness = 4
local AimbotFOV = 130

local AutoFarmEnabled = false
local FarmSpeed = 30
local currentTween = nil

local ESPEnabled = false
local NoclipEnabled = false
local CustomSpeed = 16
local CustomJump = 50

-- ====================================================================
-- 📱 1. КОМПАКТНЫЕ ПЛАВАЮЩИЕ КНОПКИ НА ЭКРАНЕ (MENU & SHOT)
-- ====================================================================

if CoreGui:FindFirstChild("CrystalMobileUI") then
    CoreGui.CrystalMobileUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CrystalMobileUI"
ScreenGui.Parent = CoreGui

-- Кнопка открытия Меню
local MenuBtn = Instance.new("TextButton")
MenuBtn.Name = "MenuButton"
MenuBtn.Parent = ScreenGui
MenuBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
MenuBtn.Position = UDim2.new(0.02, 0, 0.12, 0)
MenuBtn.Size = UDim2.new(0, 45, 0, 45)
MenuBtn.Font = Enum.Font.SourceSansBold
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.TextSize = 11
MenuBtn.Draggable = true
MenuBtn.Active = true

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = MenuBtn

MenuBtn.MouseButton1Click:Connect(function()
    Rayfield:ToggleUI()
end)

-- Круглая Кнопка Авто-Шота (Выстрел в Убийцу)
local ShotBtn = Instance.new("TextButton")
ShotBtn.Name = "AutoShotButton"
ShotBtn.Parent = ScreenGui
ShotBtn.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
ShotBtn.Position = UDim2.new(0.82, 0, 0.5, 0)
ShotBtn.Size = UDim2.new(0, 55, 0, 55)
ShotBtn.Font = Enum.Font.SourceSansBold
ShotBtn.Text = "🎯"
ShotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShotBtn.TextSize = 24
ShotBtn.Draggable = true
ShotBtn.Active = true

local ShotCorner = Instance.new("UICorner")
ShotCorner.CornerRadius = UDim.new(1, 0) -- Делаем полностью круглой
ShotCorner.Parent = ShotBtn

local ShotStroke = Instance.new("UIStroke")
ShotStroke.Parent = ShotBtn
ShotStroke.Color = Color3.fromRGB(255, 255, 255)
ShotStroke.Thickness = 2

-- ====================================================================
-- 🎯 2. ЛОГИКА АИМБОТА И АВТО-ШОТА
-- ====================================================================

-- Круг FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(138, 43, 226)
FOVCircle.Thickness = 2
FOVCircle.Transparency = 0.8
FOVCircle.Radius = AimbotFOV

local function isVisible(targetPart)
    if not VisibleCheckEnabled then return true end
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

-- Поиск Убийцы (Murderer)
local function getMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local bp = p:FindFirstChild("Backpack")
            
            local hasKnife = (char and (char:FindFirstChild("Knife") or char:FindFirstChild("Blade"))) or
                             (bp and (bp:FindFirstChild("Knife") or bp:FindFirstChild("Blade")))
            if hasKnife then
                return p
            end
        end
    end
    return nil
end

local function getClosestInFOV()
    local closestTarget = nil
    local shortestDist = AimbotFOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if humanoid and humanoid.Health > 0 and head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < shortestDist and isVisible(head) then
                        shortestDist = dist
                        closestTarget = head
                    end
                end
            end
        end
    end
    return closestTarget
end

-- Обработка клика по кнопке 🎯 AUTO-SHOT
ShotBtn.MouseButton1Click:Connect(function()
    local murderer = getMurderer()
    if murderer and murderer.Character and murderer.Character:FindFirstChild("Head") then
        local targetHead = murderer.Character.Head
        
        -- Достаем пест из инвентаря если он там
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            local gun = bp:FindFirstChildOfClass("Tool")
            if gun and (gun.Name:lower():find("gun") or gun.Name:lower():find("revolver") or gun.Name:lower():find("pistol")) then
                LocalPlayer.Character.Humanoid:EquipTool(gun)
                task.wait(0.05)
            end
        end
        
        -- Мгновенное наведение и выстрел
        local equippedTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if equippedTool then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
            equippedTool:Activate()
            
            Rayfield:Notify({
                Title = "Выстрел!",
                Content = "Пуля отправлена в Убийцу: " .. murderer.Name,
                Duration = 2
            })
        end
    else
        Rayfield:Notify({
            Title = "Ошибка",
            Content = "Убийца не найден или мертв!",
            Duration = 2
        })
    end
end)

-- Цикл обновления Аима
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = AimbotFOV
    FOVCircle.Visible = AimbotEnabled

    if AimbotEnabled then
        local target = getClosestInFOV()
        if target then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / AimbotSmoothness)
        end
    end
end)

-- ====================================================================
-- 💰 3. СТАБИЛЬНЫЙ АВТОФАРМ МОНЕТ
-- ====================================================================

local function getClosestSafeCoin()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local murderer = getMurderer()
    local murdererPos = (murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")) and murderer.Character.HumanoidRootPart.Position

    local closestCoin = nil
    local shortestDist = math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("монет")) then
            -- Проверка безопасности (подальше от убийцы)
            if not (murdererPos and (obj.Position - murdererPos).Magnitude < 20) then
                local dist = (hrp.Position - obj.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestCoin = obj
                end
            end
        end
    end
    return closestCoin
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoFarmEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hrp = char.HumanoidRootPart
                local coin = getClosestSafeCoin()
                
                if coin then
                    char.Humanoid.PlatformStand = true
                    local dist = (coin.Position - hrp.Position).Magnitude
                    local time = dist / FarmSpeed
                    
                    if time > 0.05 then
                        if currentTween then currentTween:Cancel() end
                        currentTween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(coin.Position)})
                        currentTween:Play()
                        
                        local elapsed = 0
                        while elapsed < time and AutoFarmEnabled and coin and coin.Parent do
                            task.wait(0.05)
                            elapsed = elapsed + 0.05
                        end
                    end
                else
                    char.Humanoid.PlatformStand = false
                    if currentTween then currentTween:Cancel() end
                end
            end
        end
    end
end)

-- ====================================================================
-- 👁️ 4. ESP ПОДСВЕТКА
-- ====================================================================

local function applyESP(player)
    if player == LocalPlayer then return end
    local function setupChar(char)
        if not char then return end
        if char:FindFirstChild("MobileESP") then char.MobileESP:Destroy() end
        if not ESPEnabled then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "MobileESP"
        highlight.Adornee = char
        highlight.Parent = char
        highlight.FillColor = Color3.fromRGB(0, 255, 138)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    if player.Character then setupChar(player.Character) end
    player.CharacterAdded:Connect(setupChar)
end

-- ====================================================================
-- 📱 5. ИНТЕРФЕЙС И ЭЛЕМЕНТЫ УПРАВЛЕНИЯ
-- ====================================================================

CombatTab:CreateToggle({
   Name = "Аимбот (Вкл/Выкл)",
   CurrentValue = false,
   Callback = function(Value) AimbotEnabled = Value end,
})

CombatTab:CreateToggle({
   Name = "Проверка стен (Visible Check)",
   CurrentValue = true,
   Callback = function(Value) VisibleCheckEnabled = Value end,
})

CombatTab:CreateSlider({
   Name = "Радиус захвата (FOV)",
   Range = {50, 300},
   Increment = 10,
   CurrentValue = 130,
   Callback = function(Value) AimbotFOV = Value end,
})

CombatTab:CreateSlider({
   Name = "Плавность Аима",
   Range = {1, 10},
   Increment = 1,
   CurrentValue = 4,
   Callback = function(Value) AimbotSmoothness = Value end,
})

-- Автофарм
FarmTab:CreateToggle({
   Name = "Включить Автофарм Монет",
   CurrentValue = false,
   Callback = function(Value) 
      AutoFarmEnabled = Value 
      if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
          LocalPlayer.Character.Humanoid.PlatformStand = false
          if currentTween then currentTween:Cancel() end
      end
   end,
})

FarmTab:CreateSlider({
   Name = "Скорость Полета Фарма",
   Range = {15, 50},
   Increment = 5,
   CurrentValue = 30,
   Callback = function(Value) FarmSpeed = Value end,
})

-- Визуалы
VisualsTab:CreateToggle({
   Name = "ESP Игроков",
   CurrentValue = false,
   Callback = function(Value)
      ESPEnabled = Value
      for _, p in ipairs(Players:GetPlayers()) do
          if Value then applyESP(p) else
              if p.Character and p.Character:FindFirstChild("MobileESP") then p.Character.MobileESP:Destroy() end
          end
      end
   end,
})

-- Игрок
PlayerTab:CreateToggle({
   Name = "Noclip (Сквозь стены)",
   CurrentValue = false,
   Callback = function(Value) NoclipEnabled = Value end,
})

PlayerTab:CreateSlider({
   Name = "Скорость Бега",
   Range = {16, 120},
   Increment = 4,
   CurrentValue = 16,
   Callback = function(Value) CustomSpeed = Value end,
})

PlayerTab:CreateSlider({
   Name = "Высота Прыжка",
   Range = {50, 200},
   Increment = 10,
   CurrentValue = 50,
   Callback = function(Value) CustomJump = Value end,
})

-- Физика Игрока
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = CustomSpeed
            humanoid.JumpPower = CustomJump
        end
        if NoclipEnabled then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    if ESPEnabled then applyESP(p) end
end)

Rayfield:Notify({
   Title = "Crystal Pro Mobile",
   Content = "Скрипт готов! Нажмите 🎯 для Авто-выстрела или MENU для настроек.",
   Duration = 5
})
