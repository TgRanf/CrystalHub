-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION (OPTIMIZED)
--                           PART 1/4
-- =================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "CrystalHub | MM2",
   Icon = 0,
   LoadingTitle = "CrystalHub MM2",
   LoadingSubtitle = "Optimized",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local CombatTab   = Window:CreateTab("Бой", 4483362458)
local SilentTab   = Window:CreateTab("Silent Aim", 4483362458)
local FarmTab     = Window:CreateTab("Автофарм", 4483362458)
local TeleportTab = Window:CreateTab("Телепорты", 4483362458)
local VisualsTab  = Window:CreateTab("Визуалы", 4483362458)
local PlayerTab   = Window:CreateTab("Игрок", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ================= ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ =================
getgenv().SilentAimEnabled = false
getgenv().SilentAimTargetMode = "Убийца"
getgenv().SilentAimHitChance = 100
getgenv().SilentAimPrediction = true
getgenv().SilentAimPredictionAmount = 0.165

getgenv().HitboxEnabled = false
getgenv().HitboxSize = 5
getgenv().AutoGrabGunEnabled = false

getgenv().AutoFarmEnabled = false
getgenv().FarmSpeed = 30
getgenv().SmartFarm = true
getgenv().currentTween = nil

getgenv().ESPEnabled = false
getgenv().GunESPEnabled = false
getgenv().NoclipEnabled = false
getgenv().CustomSpeed = 16
getgenv().CustomJump = 50

-- ================= ПРОВЕРКА РАУНДА (кешированная) =================
local roundCache = false
local roundCheckTime = 0
getgenv().isInRound = function()
    if tick() - roundCheckTime < 0.5 then return roundCache end
    roundCheckTime = tick()
    roundCache = #Workspace:GetDescendants() > 50
    return roundCache
end

-- ================= МГНОВЕННОЕ ОПРЕДЕЛЕНИЕ РОЛЕЙ =================
local playerRoles = {}
local COLOR_INNOCENT = Color3.fromRGB(0, 255, 0)
local COLOR_SHERIFF  = Color3.fromRGB(0, 150, 255)
local COLOR_MURDERER = Color3.fromRGB(255, 0, 0)

local function assignRole(player, toolName)
    if player == LocalPlayer then return end
    local name = toolName:lower()
    if name:find("knife") or name:find("нож") or name:find("blade") then
        if playerRoles[player] ~= COLOR_MURDERER then
            playerRoles[player] = COLOR_MURDERER
            Rayfield:Notify({ Title = "CrystalHub", Content = "Убийца: " .. player.Name, Duration = 2 })
        end
    elseif name:find("gun") or name:find("revolver") or name:find("pistol") or name:find("luger") then
        if playerRoles[player] ~= COLOR_SHERIFF then
            playerRoles[player] = COLOR_SHERIFF
            Rayfield:Notify({ Title = "CrystalHub", Content = "Шериф: " .. player.Name, Duration = 2 })
        end
    end
end

local function trackPlayer(player)
    if player == LocalPlayer then return end
    local function onTool(child)
        if child:IsA("Tool") then assignRole(player, child.Name) end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        bp.ChildAdded:Connect(onTool)
        for _, c in ipairs(bp:GetChildren()) do onTool(c) end
    end
    player.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(onTool)
        for _, c in ipairs(char:GetChildren()) do onTool(c) end
    end)
    if player.Character then
        for _, c in ipairs(player.Character:GetChildren()) do onTool(c) end
        player.Character.ChildAdded:Connect(onTool)
    end
end

for _, p in ipairs(Players:GetPlayers()) do trackPlayer(p) end
Players.PlayerAdded:Connect(trackPlayer)

getgenv().getPlayerByRole = function(roleColor)
    for p, color in pairs(playerRoles) do
        if p ~= LocalPlayer and color == roleColor and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            return p
        end
    end
    return nil
end
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION (OPTIMIZED)
--                           PART 2/4
-- =================================================================

-- ================= SILENT AIM (оптимизирован) =================
local function getSilentTarget()
    if not getgenv().SilentAimEnabled or math.random(1, 100) > getgenv().SilentAimHitChance then return nil end
    local target
    local mode = getgenv().SilentAimTargetMode
    if mode == "Убийца" then
        target = getgenv().getPlayerByRole(COLOR_MURDERER)
    elseif mode == "Шериф" then
        target = getgenv().getPlayerByRole(COLOR_SHERIFF)
    else
        local bestDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, on = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if on then
                    local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if d < bestDist then bestDist = d; target = p end
                end
            end
        end
    end
    if target and target.Character then
        return target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, idx)
    if self == Mouse and not checkcaller() and getgenv().SilentAimEnabled then
        local part = getSilentTarget()
        if part then
            if idx == "Hit" or idx == "hit" then
                if getgenv().SilentAimPrediction and part:IsA("BasePart") then
                    return part.CFrame + (part.Velocity * getgenv().SilentAimPredictionAmount)
                end
                return part.CFrame
            elseif idx == "Target" then return part end
        end
    end
    return oldIndex(self, idx)
end))

local oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if not checkcaller() and getgenv().SilentAimEnabled and self == workspace then
        local method = getnamecallmethod()
        if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
            local part = getSilentTarget()
            if part then
                local args = {...}
                if method == "Raycast" then
                    local origin = args[1]
                    local targetPos = part.Position
                    if getgenv().SilentAimPrediction then targetPos = targetPos + (part.Velocity * getgenv().SilentAimPredictionAmount) end
                    args[2] = (targetPos - origin).Unit * 1000
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    return oldNamecall(self, ...)
end))

-- ================= СИСТЕМА ФЛИГА (TELEPORT-HANDLE FLING) =================
getgenv().flingTarget = function(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Цель не найдена!", Duration = 2 })
        return
    end

    local char = LocalPlayer.Character
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Возьмите любой инструмент!", Duration = 2 })
        return
    end

    local handle = tool:FindFirstChild("Handle")
    if not handle then
        Rayfield:Notify({ Title = "CrystalHub", Content = "У инструмента нет Handle!", Duration = 2 })
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
        Rayfield:Notify({ Title = "CrystalHub", Content = "Нет частей у цели!", Duration = 2 })
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
    Rayfield:Notify({ Title = "CrystalHub", Content = "Флинг выполнен!", Duration = 2 })
end

-- ================= АВТО-ПОДБОР ПИСТОЛЕТА =================
task.spawn(function()
    while task.wait(0.15) do
        if getgenv().AutoGrabGunEnabled and getgenv().isInRound() then
            local gunDrop
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "GunDrop" and obj:IsA("BasePart") then
                    gunDrop = obj; break
                end
            end
            if gunDrop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local old = hrp.CFrame
                hrp.CFrame = gunDrop.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.2)
                hrp.CFrame = old
                Rayfield:Notify({ Title = "CrystalHub", Content = "Gun picked up!", Duration = 1.5 })
            end
        end
    end
end)

-- ================= КНОПКА ВЫСТРЕЛА (без эмодзи) =================
local ShotGui
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
                if not getgenv().isInRound() then
                    Rayfield:Notify({ Title = "CrystalHub", Content = "Not in round!", Duration = 2 })
                    return
                end
                local murderer = getgenv().getPlayerByRole(COLOR_MURDERER)
                if murderer and murderer.Character and murderer.Character:FindFirstChild("Head") then
                    local head = murderer.Character.Head
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    if bp then
                        local gun = bp:FindFirstChildOfClass("Tool")
                        if gun then LocalPlayer.Character.Humanoid:EquipTool(gun); task.wait(0.05) end
                    end
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                        tool:Activate()
                        Rayfield:Notify({ Title = "CrystalHub", Content = "Shot fired!", Duration = 1.5 })
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
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION (OPTIMIZED)
--                           PART 3/4
-- =================================================================

-- ================= ИНТЕРФЕЙС (без ников в ESP) =================
CombatTab:CreateToggle({ Name = "Auto-Grab Gun", CurrentValue = false, Flag = "AutoGrabToggle", Callback = function(v) getgenv().AutoGrabGunEnabled = v end })
CombatTab:CreateButton({ Name = "Fling Murderer", Callback = function() getgenv().flingTarget(getgenv().getPlayerByRole(COLOR_MURDERER)) end })
CombatTab:CreateButton({ Name = "Fling Sheriff", Callback = function() getgenv().flingTarget(getgenv().getPlayerByRole(COLOR_SHERIFF)) end })
CombatTab:CreateToggle({ Name = "Hitbox Expander", CurrentValue = false, Flag = "HitboxToggle", Callback = function(v)
    getgenv().HitboxEnabled = v
    if not v then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            end
        end
    end
end })
CombatTab:CreateSlider({ Name = "Hitbox Size", Range = {2, 15}, Increment = 1, Suffix = " studs", CurrentValue = 5, Flag = "HitboxSizeSlider", Callback = function(v) getgenv().HitboxSize = v end })
CombatTab:CreateToggle({ Name = "Show SHOT Button", CurrentValue = false, Flag = "AutoShotToggle", Callback = function(v) getgenv().toggleShotButton(v) end })

SilentTab:CreateToggle({ Name = "Silent Aim", CurrentValue = false, Flag = "SilentAimToggle", Callback = function(v) getgenv().SilentAimEnabled = v end })
SilentTab:CreateDropdown({ Name = "Target", Options = {"Убийца", "Шериф", "Все"}, CurrentOption = {"Убийца"}, MultipleOptions = false, Flag = "SilentAimTargetDropdown", Callback = function(o) getgenv().SilentAimTargetMode = type(o)=="table" and o[1] or o end })
SilentTab:CreateToggle({ Name = "Prediction", CurrentValue = true, Flag = "PredictionToggle", Callback = function(v) getgenv().SilentAimPrediction = v end })
SilentTab:CreateSlider({ Name = "Prediction Amount", Range = {0, 0.5}, Increment = 0.01, Suffix = " sec", CurrentValue = 0.165, Flag = "PredictionSlider", Callback = function(v) getgenv().SilentAimPredictionAmount = v end })
SilentTab:CreateSlider({ Name = "Hit Chance", Range = {10, 100}, Increment = 5, Suffix = "%", CurrentValue = 100, Flag = "HitChanceSlider", Callback = function(v) getgenv().SilentAimHitChance = v end })

FarmTab:CreateToggle({ Name = "AutoFarm", CurrentValue = false, Flag = "AutoFarmToggle", Callback = function(v)
    getgenv().AutoFarmEnabled = v
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
        if getgenv().currentTween then getgenv().currentTween:Cancel() end
    end
end })
FarmTab:CreateToggle({ Name = "Safe Mode (avoid murderer)", CurrentValue = true, Flag = "SmartFarmToggle", Callback = function(v) getgenv().SmartFarm = v end })
FarmTab:CreateSlider({ Name = "Farm Speed", Range = {15, 50}, Increment = 1, Suffix = " speed", CurrentValue = 30, Flag = "FarmSpeedSlider", Callback = function(v) getgenv().FarmSpeed = v end })

TeleportTab:CreateButton({ Name = "Teleport to Lobby", Callback = function()
    local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("LobbyMap")
    if lobby and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = lobby:GetModelCFrame() + Vector3.new(0, 5, 0)
    end
end })
TeleportTab:CreateButton({ Name = "Teleport to Murderer", Callback = function()
    local m = getgenv().getPlayerByRole(COLOR_MURDERER)
    if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 3)
    end
end })
TeleportTab:CreateButton({ Name = "Teleport to Sheriff", Callback = function()
    local s = getgenv().getPlayerByRole(COLOR_SHERIFF)
    if s and s.Character and s.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 3)
    end
end })

VisualsTab:CreateToggle({ Name = "ESP Roles (no names)", CurrentValue = false, Flag = "ESPToggle", Callback = function(v)
    getgenv().ESPEnabled = v
    if not v then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                if p.Character:FindFirstChild("RoleESP") then p.Character.RoleESP:Destroy() end
                if p.Character.Head and p.Character.Head:FindFirstChild("RoleTag") then p.Character.Head.RoleTag:Destroy() end
            end
        end
    end
end })
VisualsTab:CreateToggle({ Name = "Gun Drop ESP (yellow label)", CurrentValue = false, Flag = "GunESPToggle", Callback = function(v)
    getgenv().GunESPEnabled = v
    if not v then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "GunDrop" then
                if obj:FindFirstChild("GunESP") then obj.GunESP:Destroy() end
                if obj:FindFirstChild("GunTag") then obj.GunTag:Destroy() end
            end
        end
    end
end })

PlayerTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Flag = "NoclipToggle", Callback = function(v) getgenv().NoclipEnabled = v end })
PlayerTab:CreateSlider({ Name = "Speed", Range = {16, 120}, Increment = 1, Suffix = " speed", CurrentValue = 16, Flag = "SpeedSlider", Callback = function(v) getgenv().CustomSpeed = v end })
PlayerTab:CreateSlider({ Name = "Jump Power", Range = {50, 200}, Increment = 1, Suffix = " power", CurrentValue = 50, Flag = "JumpSlider", Callback = function(v) getgenv().CustomJump = v end })
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION (OPTIMIZED)
--                           PART 4/4
-- =================================================================

-- ================= RENDER LOOP (оптимизированный) =================
RunService.RenderStepped:Connect(function()
    if getgenv().HitboxEnabled then
        local size = getgenv().HitboxSize
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                hrp.Size = Vector3.new(size, size, size)
                hrp.Transparency = 0.7
                hrp.Color = Color3.fromRGB(255, 0, 0)
            end
        end
    end

    if getgenv().ESPEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local color = playerRoles[p] or COLOR_INNOCENT
                local hl = p.Character:FindFirstChild("RoleESP") or Instance.new("Highlight")
                if not hl.Parent then
                    hl.Name = "RoleESP"
                    hl.Adornee = p.Character
                    hl.Parent = p.Character
                    hl.FillTransparency = 0.4
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                hl.FillColor = color
                hl.OutlineColor = color

                local tag = p.Character.Head:FindFirstChild("RoleTag") or Instance.new("BillboardGui")
                if not tag.Parent then
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
                local roleName = (color == COLOR_MURDERER and "MURDERER") or (color == COLOR_SHERIFF and "SHERIFF") or "INNOCENT"
                tag.Text.Text = roleName
                tag.Text.TextColor3 = color
            end
        end
    end

    if getgenv().GunESPEnabled then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "GunDrop" and obj:IsA("BasePart") and not obj:FindFirstChild("GunESP") then
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
end)

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = getgenv().CustomSpeed
            hum.JumpPower = getgenv().CustomJump
        end
        if getgenv().NoclipEnabled then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- ================= АВТОФАРМ (оптимизирован) =================
task.spawn(function()
    while task.wait(0.15) do
        if not getgenv().AutoFarmEnabled then continue end
        if not getgenv().isInRound() then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.PlatformStand = false
            end
            if getgenv().currentTween then getgenv().currentTween:Cancel() end
            continue
        end
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart
        local murderer = getgenv().getPlayerByRole(COLOR_MURDERER)
        local murdPos = murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") and murderer.Character.HumanoidRootPart.Position

        local bestCoin, bestDist
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("монет")) then
                if getgenv().SmartFarm and murdPos and (obj.Position - murdPos).Magnitude < 25 then continue end
                local d = (hrp.Position - obj.Position).Magnitude
                if not bestDist or d < bestDist then bestDist = d; bestCoin = obj end
            end
        end
        if bestCoin then
            char.Humanoid.PlatformStand = true
            local time = bestDist / (getgenv().FarmSpeed or 30)
            if time > 0.05 then
                if getgenv().currentTween then getgenv().currentTween:Cancel() end
                getgenv().currentTween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(bestCoin.Position)})
                getgenv().currentTween:Play()
                task.wait(time)
            end
        else
            char.Humanoid.PlatformStand = false
            if getgenv().currentTween then getgenv().currentTween:Cancel() end
        end
    end
end)

print("CrystalHub MM2 Optimized - Fully Loaded!")
