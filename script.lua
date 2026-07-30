-- ====================================================================
-- CrystalHub | MM2 Thank you for choosing us
-- ====================================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/Fluent.lua"))()

local Window = Fluent:CreateWindow({
    Title = "CrystalHub | MM2 Ultimate",
    SubTitle = "Mobile & PC Edition",
    TabWidth = 150,
    Size = UDim2.fromOffset(550, 380),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Создаем вкладки
local Tabs = {
    Combat = Window:AddTab({ Title = "Бой", Icon = "swords" }),
    Farm = Window:AddTab({ Title = "Автофарм", Icon = "coins" }),
    Visuals = Window:AddTab({ Title = "Визуалы", Icon = "eye" }),
    Player = Window:AddTab({ Title = "Игрок", Icon = "user" })
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Состояние и настройки
local AimbotEnabled = false
local VisibleCheckEnabled = true
local AimbotFOV = 130
local AimbotSmoothness = 4
local AimbotTargetMode = "Все" -- "Все", "Только Убийца", "Только Шериф"

local AutoFarmEnabled = false
local FarmSpeed = 30
local currentTween = nil

local ESPEnabled = false
local NoclipEnabled = false
local CustomSpeed = 16
local CustomJump = 50

-- 🛡️ 1. ПРОВЕРКА НА ЛОББИ (LOBBY CHECK)
local function isInRound()
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

-- ⚡ 2. МГНОВЕННЫЙ ПЕРЕХВАТ РОЛЕЙ (0-я СЕКУНДА РАУНДА)
local playerRoles = {}
local COLOR_INNOCENT = Color3.fromRGB(0, 255, 0)
local COLOR_SHERIFF  = Color3.fromRGB(0, 150, 255)
local COLOR_MURDERER = Color3.fromRGB(255, 0, 0)

local function detectToolRole(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local name = tool.Name:lower()
    if name:find("knife") or name:find("нож") or name:find("blade") then
        return COLOR_MURDERER
    elseif name:find("gun") or name:find("revolver") or name:find("pistol") or name:find("пест") then
        return COLOR_SHERIFF
    end
    return nil
end

local function hookPlayerInventory(player)
    playerRoles[player] = COLOR_INNOCENT

    local function bindContainer(container)
        if not container then return end
        container.ChildAdded:Connect(function(child)
            local roleColor = detectToolRole(child)
            if roleColor then
                playerRoles[player] = roleColor
            end
        end)
        for _, child in ipairs(container:GetChildren()) do
            local roleColor = detectToolRole(child)
            if roleColor then
                playerRoles[player] = roleColor
            end
        end
    end

    if player.Character then bindContainer(player.Character) end
    local bp = player:FindFirstChild("Backpack")
    if bp then bindContainer(bp) end

    player.CharacterAdded:Connect(function(char)
        playerRoles[player] = COLOR_INNOCENT
        bindContainer(char)
        task.spawn(function()
            local newBp = player:WaitForChild("Backpack", 5)
            if newBp then bindContainer(newBp) end
        end)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do hookPlayerInventory(p) end
Players.PlayerAdded:Connect(hookPlayerInventory)

local function getPlayerByRole(roleColor)
    for p, color in pairs(playerRoles) do
        if p ~= LocalPlayer and color == roleColor and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            return p
        end
    end
    return nil
end

-- 🎯 3. КНОПКА AUTO-SHOT
local ShotGui = nil

local function toggleShotButton(state)
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
                if not isInRound() then
                    Fluent:Notify({ Title = "CrystalHub", Content = "Функция недоступна в лобби!", Duration = 3 })
                    return
                end

                local murderer = getPlayerByRole(COLOR_MURDERER)
                if murderer and murderer.Character and murderer.Character:FindFirstChild("Head") then
                    local targetHead = murderer.Character.Head
                    
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    if bp then
                        local gun = bp:FindFirstChildOfClass("Tool")
                        if gun and detectToolRole(gun) == COLOR_SHERIFF then
                            LocalPlayer.Character.Humanoid:EquipTool(gun)
                            task.wait(0.05)
                        end
                    end
                    
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
                        tool:Activate()
                        Fluent:Notify({ Title = "CrystalHub", Content = "Пуля выпущена в Убийцу!", Duration = 2 })
                    end
                else
                    Fluent:Notify({ Title = "CrystalHub", Content = "Убийца не найден!", Duration = 2 })
                end
            end)
        end
        ShotGui.Enabled = true
    else
        if ShotGui then ShotGui.Enabled = false end
    end
end

-- 🌀 4. ФЛИНГ И AUTO-GRAB GUN
local function flingTarget(targetPlayer)
    if not isInRound() then
        Fluent:Notify({ Title = "CrystalHub", Content = "Нельзя использовать в Лобби!", Duration = 3 })
        return
    end

    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Fluent:Notify({ Title = "CrystalHub", Content = "Цель не найдена!", Duration = 3 })
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

    Fluent:Notify({ Title = "CrystalHub", Content = "Цель успешно выброшена!", Duration = 3 })
end

local function autoGrabGun()
    if not isInRound() then
        Fluent:Notify({ Title = "CrystalHub", Content = "Вы находитесь в лобби!", Duration = 3 })
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
        Fluent:Notify({ Title = "CrystalHub", Content = "Выпавший пистолет не найден!", Duration = 3 })
        return
    end

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local oldCFrame = hrp.CFrame
        hrp.CFrame = gunDrop.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.2)
        hrp.CFrame = oldCFrame
        Fluent:Notify({ Title = "CrystalHub", Content = "Пистолет подобран!", Duration = 3 })
    end
end

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

local function getClosestInFOV()
    local closestTarget = nil
    local shortestDist = AimbotFOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if humanoid and humanoid.Health > 0 and head then
                local roleColor = playerRoles[player]
                local validRole = true
                
                if AimbotTargetMode == "Только Убийца" then
                    validRole = (roleColor == COLOR_MURDERER)
                elseif AimbotTargetMode == "Только Шериф" then
                    validRole = (roleColor == COLOR_SHERIFF)
                end
                
                if validRole then
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
    end
    return closestTarget
end
