-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                ВСЕ ФУНКЦИИ ИЗ XHUB
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
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

-- ================= ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ (XHUB) =================
local ESPEnabled = {
    Murderer = false,
    Sheriff = false,
    DroppedGun = false,
}

local FarmCoinsEnabled = false
local farmCooldown = 0.1
local loopMovementAttributes = false
local killAllEnabled = false
local noclipEnabled = false
local silentAimEnabled = false

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

-- ================= ОПРЕДЕЛЕНИЕ РОЛЕЙ (XHUB) =================
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

local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and GetPlayerRole(p) == "Murderer" then
            return p
        end
    end
    return nil
end

local function GetSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and GetPlayerRole(p) == "Sheriff" then
            return p
        end
    end
    return nil
end
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 2/4
-- =================================================================

-- ================= ESP (XHUB) =================
local function addHighlight(part, color, text)
    if not part then return end

    local highlight = Instance.new("Highlight", part)
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    if part:IsA("Model") and part:FindFirstChild("Head") then
        local billboard = Instance.new("BillboardGui", part)
        billboard.Adornee = part.Head
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = color
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold
    end
end

local function removeESP(part)
    if part then
        for _, obj in pairs(part:GetChildren()) do
            if obj:IsA("Highlight") or obj:IsA("BillboardGui") then
                obj:Destroy()
            end
        end
    end
end

local function checkForMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Backpack:FindFirstChild("Knife") then
            removeESP(player.Character)
            addHighlight(player.Character, Color3.new(1, 0, 0), "Murderer - " .. player.Name)
        end
    end
end

local function checkForSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Backpack:FindFirstChild("Gun") then
            removeESP(player.Character)
            addHighlight(player.Character, Color3.new(0, 0, 1), "Sheriff - " .. player.Name)
        end
    end
end

local function checkForDroppedGun()
    local gunDrop = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("GunDrop")
    if gunDrop then
        removeESP(gunDrop)
        addHighlight(gunDrop, Color3.new(0, 1, 0), "Dropped Gun")
    end
end

-- ================= ФАРМ (XHUB) =================
local function farmCoinsAndBeachballs()
    local CoinContainer = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("CoinContainer")
    if CoinContainer then
        for _, coin in pairs(CoinContainer:GetChildren()) do
            LocalPlayer.Character:SetPrimaryPartCFrame(coin.CFrame)
            task.wait(farmCooldown)
        end
    end
end

-- ================= KILL ALL (XHUB) =================
local function killAllPlayers()
    while killAllEnabled do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                LocalPlayer.Character:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
                task.wait(1)
            end
        end
        task.wait(1)
    end
end

-- ================= AIM MURDERER (XHUB) =================
local function aimAtMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Backpack:FindFirstChild("Knife") and player.Character and LocalPlayer.Backpack:FindFirstChild("Gun") then
            local murdererHead = player.Character:FindFirstChild("Head")
            if murdererHead then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, murdererHead.Position)
            end
        end
    end
end

-- ================= SILENT AIM (XHUB) =================
local oldIndex

local function getClosestTarget()
    if not silentAimEnabled then return nil end
    
    local targetPlayer = nil
    local shortestDist = math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not p.Character or not p.Character:FindFirstChild("Head") then continue end
        
        local head = p.Character.Head
        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen then
            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                targetPlayer = p
            end
        end
    end
    
    if targetPlayer and targetPlayer.Character then
        return targetPlayer.Character:FindFirstChild("Head")
    end
    return nil
end

oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if self == Mouse and not checkcaller() and silentAimEnabled then
        local targetPart = getClosestTarget()
        if targetPart then
            if key == "Hit" then
                return targetPart.CFrame
            elseif key == "Target" then
                return targetPart
            end
        end
    end
    return oldIndex(self, key)
end))

-- ================= ФЛИНГ =================
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
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 3/4
-- =================================================================

-- ================= ИНТЕРФЕЙС ЭЛЕМЕНТЫ =================

-- Вкладка: Бой
CombatTab:CreateToggle({
   Name = "Авто-подбор Пистолета",
   CurrentValue = false,
   Flag = "AutoGrabToggle",
   Callback = function(Value) getgenv().AutoGrabGunEnabled = Value end,
})

CombatTab:CreateButton({
   Name = "Флинг Убийцы",
   Callback = function()
       local m = GetMurderer()
       getgenv().flingTarget(m)
   end,
})

CombatTab:CreateButton({
   Name = "Флинг Шерифа",
   Callback = function()
       local s = GetSheriff()
       getgenv().flingTarget(s)
   end,
})

CombatTab:CreateToggle({
   Name = "Kill All Players (XHub)",
   CurrentValue = false,
   Flag = "KillAllToggle",
   Callback = function(Value)
       killAllEnabled = Value
       if Value then
           task.spawn(killAllPlayers)
       end
   end,
})

-- Вкладка: Silent Aim
SilentTab:CreateToggle({
   Name = "Silent Aim (XHub)",
   CurrentValue = false,
   Flag = "SilentAimToggle",
   Callback = function(Value)
       silentAimEnabled = Value
   end,
})

SilentTab:CreateToggle({
   Name = "Aim Murderer (If Sheriff)",
   CurrentValue = false,
   Flag = "AimMurdererToggle",
   Callback = function(Value)
       if Value then
           RunService.RenderStepped:Connect(aimAtMurderer)
       else
           RunService.RenderStepped:Disconnect(aimAtMurderer)
       end
   end,
})

-- Вкладка: Визуалы
VisualsTab:CreateToggle({
   Name = "ESP Murderer (XHub)",
   CurrentValue = false,
   Flag = "ESPMurdererToggle",
   Callback = function(Value)
       ESPEnabled.Murderer = Value
       if not Value then
           for _, player in pairs(Players:GetPlayers()) do
               removeESP(player.Character)
           end
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "ESP Sheriff (XHub)",
   CurrentValue = false,
   Flag = "ESPSheriffToggle",
   Callback = function(Value)
       ESPEnabled.Sheriff = Value
       if not Value then
           for _, player in pairs(Players:GetPlayers()) do
               removeESP(player.Character)
           end
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "ESP Dropped Gun (XHub)",
   CurrentValue = false,
   Flag = "ESPGunToggle",
   Callback = function(Value)
       ESPEnabled.DroppedGun = Value
       if not Value then
           local gunDrop = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("GunDrop")
           removeESP(gunDrop)
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "FullBright",
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

-- Вкладка: Автофарм
FarmTab:CreateToggle({
   Name = "Farm Coins & Beachballs (XHub)",
   CurrentValue = false,
   Flag = "FarmCoinsToggle",
   Callback = function(Value)
       FarmCoinsEnabled = Value
   end,
})

FarmTab:CreateInput({
   Name = "Farm Cooldown (sec)",
   PlaceholderText = "0.1",
   CurrentValue = "0.1",
   Flag = "FarmCooldownInput",
   Callback = function(Value)
       farmCooldown = tonumber(Value) or 0.1
   end,
})

-- Вкладка: Телепорты
TeleportTab:CreateButton({
   Name = "TP to Murderer (XHub)",
   Callback = function()
       local m = GetMurderer()
       if m and m.Character then
           LocalPlayer.Character:SetPrimaryPartCFrame(m.Character.PrimaryPart.CFrame)
           Rayfield:Notify({ Title = "CrystalHub", Content = "Teleported to Murderer", Duration = 2 })
       end
   end,
})

TeleportTab:CreateButton({
   Name = "TP to Sheriff (XHub)",
   Callback = function()
       local s = GetSheriff()
       if s and s.Character then
           LocalPlayer.Character:SetPrimaryPartCFrame(s.Character.PrimaryPart.CFrame)
           Rayfield:Notify({ Title = "CrystalHub", Content = "Teleported to Sheriff", Duration = 2 })
       end
   end,
})

TeleportTab:CreateButton({
   Name = "TP to Gun (XHub)",
   Callback = function()
       local gunDrop = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("GunDrop")
       if gunDrop then
           LocalPlayer.Character:SetPrimaryPartCFrame(gunDrop.CFrame)
           Rayfield:Notify({ Title = "CrystalHub", Content = "Teleported to Gun", Duration = 2 })
       else
           Rayfield:Notify({ Title = "CrystalHub", Content = "Gun not found!", Duration = 2 })
       end
   end,
})

-- Вкладка: Игрок
PlayerTab:CreateToggle({
   Name = "Noclip (XHub)",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
       noclipEnabled = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value) getgenv().FlyEnabled = Value end,
})

PlayerTab:CreateSlider({
   Name = "Walkspeed (XHub)",
   Range = {16, 200},
   Increment = 1,
   Suffix = " speed",
   CurrentValue = 16,
   Flag = "WalkspeedSlider",
   Callback = function(Value)
       local char = LocalPlayer.Character
       if char then
           local humanoid = char:FindFirstChild("Humanoid")
           if humanoid then
               humanoid.WalkSpeed = Value
           end
       end
   end,
})

PlayerTab:CreateSlider({
   Name = "Jump Power (XHub)",
   Range = {50, 890},
   Increment = 1,
   Suffix = " power",
   CurrentValue = 50,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
       local char = LocalPlayer.Character
       if char then
           local humanoid = char:FindFirstChild("Humanoid")
           if humanoid then
               humanoid.JumpPower = Value
           end
       end
   end,
})

PlayerTab:CreateInput({
   Name = "Change Gravity (XHub)",
   PlaceholderText = "Enter gravity",
   CurrentValue = tostring(Workspace.Gravity),
   Flag = "GravityInput",
   Callback = function(Value)
       Workspace.Gravity = tonumber(Value) or 196.2
       Rayfield:Notify({ Title = "CrystalHub", Content = "Gravity set to " .. Value, Duration = 2 })
   end,
})

PlayerTab:CreateToggle({
   Name = "Loop Walkspeed/JumpPower (XHub)",
   CurrentValue = false,
   Flag = "LoopAttributesToggle",
   Callback = function(Value)
       loopMovementAttributes = Value
   end,
})
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 4/4
-- =================================================================

-- ================= ОБНОВЛЕНИЕ ESP (XHUB) =================
RunService.RenderStepped:Connect(function()
    if ESPEnabled.Murderer then
        checkForMurderer()
    end
    if ESPEnabled.Sheriff then
        checkForSheriff()
    end
    if ESPEnabled.DroppedGun then
        checkForDroppedGun()
    end
end)

-- ================= LOOP ATTRIBUTES (XHUB) =================
RunService.RenderStepped:Connect(function()
    if loopMovementAttributes then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                local speed = Window:GetFlag("WalkspeedSlider")
                local jump = Window:GetFlag("JumpPowerSlider")
                if speed then humanoid.WalkSpeed = speed.CurrentValue or 16 end
                if jump then humanoid.JumpPower = jump.CurrentValue or 50 end
            end
        end
    end
end)

-- ================= NOCLIP (XHUB) =================
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- ================= ФАРМ (XHUB) =================
RunService.Heartbeat:Connect(function()
    if FarmCoinsEnabled then
        farmCoinsAndBeachballs()
    end
end)

-- ================= KILL ALL (XHUB) =================
RunService.Heartbeat:Connect(function()
    if killAllEnabled then
        killAllPlayers()
    end
end)

-- ================= FLY =================
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
    
    if not getgenv().FlyEnabled then
        humanoid.PlatformStand = false
        return
    end
    
    humanoid.PlatformStand = true
    
    flyBodyGyro = Instance.new("BodyGyro", torso)
    flyBodyGyro.P = 9e4
    flyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.cframe = torso.CFrame
    
    flyBodyVelocity = Instance.new("BodyVelocity", torso)
    flyBodyVelocity.velocity = Vector3.new(0, 0.1, 0)
    flyBodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    if flyConnection then flyConnection:Disconnect() end
    
    local speed = 0
    local maxSpeed = 50
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().FlyEnabled or not char or not char.Parent then
            if flyConnection then flyConnection:Disconnect() end
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = false
                end
            end
            return
        end
        
        local cam = Workspace.CurrentCamera
        if not cam then return end
        
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

-- ================= ШОТ БАТТОН =================
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

                local murderer = GetMurderer()
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

CombatTab:CreateToggle({
   Name = "Отображать кнопку Выстрела",
   CurrentValue = false,
   Flag = "AutoShotToggle",
   Callback = function(Value) getgenv().toggleShotButton(Value) end,
})

print("CrystalHub MM2 Ultimate - Loaded!")
