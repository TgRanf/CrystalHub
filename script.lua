-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--            Based on your original sources + Zyn-ic Octree Farm
--                           PART 1/4
-- =================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "CrystalHub | MM2 Ultimate",
   Icon = 0,
   LoadingTitle = "CrystalHub MM2",
   LoadingSubtitle = "Powered by Zyn-ic Octree",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Вкладки
local CombatTab   = Window:CreateTab("Combat", 4483362458)
local SilentTab   = Window:CreateTab("Silent Aim", 4483362458)
local FarmTab     = Window:CreateTab("Auto Farm", 4483362458)
local TeleportTab = Window:CreateTab("Teleports", 4483362458)
local VisualsTab  = Window:CreateTab("Visuals", 4483362458)
local PlayerTab   = Window:CreateTab("Player", 4483362458)

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

-- Автофарм (Zyn-ic)
getgenv().AutoFarmEnabled = false
getgenv().FarmSpeed = 30
getgenv().SmartFarm = true
getgenv().isFarming = false
getgenv().farmRadius = 200

-- Визуалы & Персонаж
getgenv().ESPEnabled = false
getgenv().GunESPEnabled = false
getgenv().NoclipEnabled = false
getgenv().CustomSpeed = 16
getgenv().CustomJump = 50

-- Авто-подбор
getgenv().AutoGrabGunEnabled = false

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
            Rayfield:Notify({ Title = "CrystalHub", Content = "Murderer found: " .. player.Name, Duration = 3 })
        end
    elseif name:find("gun") or name:find("revolver") or name:find("pistol") or name:find("пест") or name:find("luger") then
        if getgenv().playerRoles[player] ~= getgenv().COLOR_SHERIFF then
            getgenv().playerRoles[player] = getgenv().COLOR_SHERIFF
            Rayfield:Notify({ Title = "CrystalHub", Content = "Sheriff found: " .. player.Name, Duration = 3 })
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

-- ================= SILENT AIM (ИЗ STEFANUK12) =================
local ValiantAimHacks = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Stefanuk12/ROBLOX/master/Universal/Experimental%20Silent%20Aim%20Module.lua"))()

ValiantAimHacks.SilentAimEnabled = false
ValiantAimHacks.ShowFOV = true
ValiantAimHacks.FOV = 60
ValiantAimHacks.HitChance = 100
ValiantAimHacks.VisibleCheck = true
ValiantAimHacks.TeamCheck = false
ValiantAimHacks.TargetPart = {"Head", "HumanoidRootPart"}

SilentTab:CreateToggle({
   Name = "Silent Aim (Knife/Gun)",
   CurrentValue = false,
   Flag = "SilentAimToggle",
   Callback = function(Value)
       ValiantAimHacks.SilentAimEnabled = Value
       if not Value then
           ValiantAimHacks.Selected = LocalPlayer
           ValiantAimHacks.SelectedPart = nil
       end
   end,
})

SilentTab:CreateSlider({
   Name = "FOV Radius",
   Range = {30, 120},
   Increment = 5,
   Suffix = " degrees",
   CurrentValue = 60,
   Flag = "FOVSlider",
   Callback = function(Value)
       ValiantAimHacks.FOV = Value
   end,
})

SilentTab:CreateSlider({
   Name = "Hit Chance",
   Range = {10, 100},
   Increment = 5,
   Suffix = "%",
   CurrentValue = 100,
   Flag = "HitChanceSlider",
   Callback = function(Value)
       ValiantAimHacks.HitChance = Value
   end,
})

SilentTab:CreateToggle({
   Name = "Show FOV Circle",
   CurrentValue = true,
   Flag = "ShowFOVToggle",
   Callback = function(Value)
       ValiantAimHacks.ShowFOV = Value
   end,
})

SilentTab:CreateToggle({
   Name = "Visible Check",
   CurrentValue = true,
   Flag = "VisibleCheckToggle",
   Callback = function(Value)
       ValiantAimHacks.VisibleCheck = Value
   end,
})

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

-- ================= SHOT BUTTON =================
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

-- ================= KILL MURDERER =================
local function GetMurderer()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            if v.Character and v.Character:FindFirstChild("Knife") then
                return v
            end
            if v.Backpack and v.Backpack:FindFirstChild("Knife") then
                return v
            end
        end
    end
    return nil
end
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 3/4
-- =================================================================

-- ================= ИНТЕРФЕЙС ЭЛЕМЕНТЫ =================

CombatTab:CreateToggle({
   Name = "Auto Grab Gun",
   CurrentValue = false,
   Flag = "AutoGrabToggle",
   Callback = function(Value) getgenv().AutoGrabGunEnabled = Value end,
})

CombatTab:CreateButton({
   Name = "Kill Murderer",
   Callback = function()
       local murderer = GetMurderer()
       if not murderer then
           Rayfield:Notify({ Title = "CrystalHub", Content = "Murderer not found!", Duration = 3 })
           return
       end
       
       if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
           return
       end
       
       local hrp = LocalPlayer.Character.HumanoidRootPart
       repeat
           if murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
               hrp.CFrame = murderer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
               task.wait(0.1)
           end
       until not murderer.Character or not murderer.Character:FindFirstChild("Humanoid") or murderer.Character.Humanoid.Health <= 0
       
       Rayfield:Notify({ Title = "CrystalHub", Content = "Murderer killed!", Duration = 3 })
   end,
})

CombatTab:CreateButton({
   Name = "Kill All Players",
   Callback = function()
       if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
           return
       end
       
       local hrp = LocalPlayer.Character.HumanoidRootPart
       
       for _, victim in pairs(Players:GetPlayers()) do
           if victim == LocalPlayer then continue end
           if not victim.Character or not victim.Character:FindFirstChild("HumanoidRootPart") then
               continue
           end
           
           if victim.Character:FindFirstChild("Humanoid") and victim.Character.Humanoid.Health <= 0 then
               continue
           end
           
           repeat
               hrp.CFrame = victim.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
               task.wait(0.1)
           until not victim.Character or not victim.Character:FindFirstChild("Humanoid") or victim.Character.Humanoid.Health <= 0
       end
       
       Rayfield:Notify({ Title = "CrystalHub", Content = "All players killed!", Duration = 3 })
   end,
})

CombatTab:CreateButton({
   Name = "Show Shot Button",
   CurrentValue = false,
   Flag = "AutoShotToggle",
   Callback = function(Value) getgenv().toggleShotButton(Value) end,
})

-- Вкладка: Auto Farm
FarmTab:CreateToggle({
   Name = "Auto Farm (Zyn-ic Octree)",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       getgenv().AutoFarmEnabled = Value
       if not Value then
           if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
               LocalPlayer.Character.Humanoid.PlatformStand = false
           end
           getgenv().isFarming = false
       end
   end,
})

FarmTab:CreateToggle({
   Name = "Avoid Murderer",
   CurrentValue = true,
   Flag = "SmartFarmToggle",
   Callback = function(Value) getgenv().SmartFarm = Value end,
})

FarmTab:CreateSlider({
   Name = "Farm Speed",
   Range = {15, 50},
   Increment = 1,
   Suffix = " speed",
   CurrentValue = 30,
   Flag = "FarmSpeedSlider",
   Callback = function(Value) getgenv().FarmSpeed = Value end,
})

FarmTab:CreateSlider({
   Name = "Search Radius",
   Range = {100, 300},
   Increment = 10,
   Suffix = " studs",
   CurrentValue = 200,
   Flag = "FarmRadiusSlider",
   Callback = function(Value) getgenv().farmRadius = Value end,
})

-- ================= ТЕЛЕПОРТЫ =================
TeleportTab:CreateButton({
   Name = "TP to Lobby",
   Callback = function()
       LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-108.5, 145, 0.6)
       Rayfield:Notify({ Title = "CrystalHub", Content = "Teleported to Lobby", Duration = 2 })
   end,
})

TeleportTab:CreateButton({
   Name = "TP to Map Spawn",
   Callback = function()
       for _, child in ipairs(Workspace:GetDescendants()) do
           if child.Name == "Spawns" and child:FindFirstChild("Spawn") then
               LocalPlayer.Character.HumanoidRootPart.CFrame = child.Spawn.CFrame
               Rayfield:Notify({ Title = "CrystalHub", Content = "Teleported to Map", Duration = 2 })
               return
           end
       end
       Rayfield:Notify({ Title = "CrystalHub", Content = "Spawn not found!", Duration = 2 })
   end,
})

TeleportTab:CreateButton({
   Name = "TP to Murderer",
   Callback = function()
       local m = getgenv().getPlayerByRole(getgenv().COLOR_MURDERER)
       if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
           LocalPlayer.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame
           Rayfield:Notify({ Title = "CrystalHub", Content = "Teleported to Murderer", Duration = 2 })
       else
           Rayfield:Notify({ Title = "CrystalHub", Content = "Murderer not found!", Duration = 2 })
       end
   end,
})

TeleportTab:CreateButton({
   Name = "TP to Sheriff",
   Callback = function()
       local s = getgenv().getPlayerByRole(getgenv().COLOR_SHERIFF)
       if s and s.Character and s.Character:FindFirstChild("HumanoidRootPart") then
           LocalPlayer.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame
           Rayfield:Notify({ Title = "CrystalHub", Content = "Teleported to Sheriff", Duration = 2 })
       else
           Rayfield:Notify({ Title = "CrystalHub", Content = "Sheriff not found!", Duration = 2 })
       end
   end,
})

TeleportTab:CreateTextBox({
   Name = "TP to Player",
   PlaceholderText = "Enter player name",
   CurrentValue = "",
   Flag = "TPPlayerName",
   Callback = function(Value)
       for _, v in pairs(Players:GetPlayers()) do
           if string.lower(string.sub(v.Name, 1, string.len(Value))) == string.lower(Value) then
               if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                   LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
                   Rayfield:Notify({ Title = "CrystalHub", Content = "Teleported to " .. v.Name, Duration = 2 })
               end
               return
           end
       end
       Rayfield:Notify({ Title = "CrystalHub", Content = "Player not found!", Duration = 2 })
   end,
})

-- ================= ВИЗУАЛЫ =================
VisualsTab:CreateToggle({
   Name = "ESP Roles (Box)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       getgenv().ESPEnabled = Value
       if not Value then
           for _, p in ipairs(Players:GetPlayers()) do
               if p.Character and p.Character:FindFirstChild("Head") then
                   for _, child in ipairs(p.Character.Head:GetChildren()) do
                       if child:IsA("BoxHandleAdornment") then
                           child:Destroy()
                       end
                   end
               end
           end
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "ESP Gun Drop",
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

-- ================= ИГРОК =================
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

PlayerTab:CreateSlider({
   Name = "Jump Power",
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

-- ================= ESP =================
local function createESP(player)
    if player == LocalPlayer then return end
    if not player.Character or not player.Character:FindFirstChild("Head") then return end
    
    for _, child in ipairs(player.Character.Head:GetChildren()) do
        if child:IsA("BoxHandleAdornment") then
            child:Destroy()
        end
    end
    
    local esp = Instance.new("BoxHandleAdornment")
    esp.Parent = player.Character.Head
    esp.Size = Vector3.new(1, 1, 1)
    esp.AlwaysOnTop = true
    esp.Adornee = player.Character.Head
    esp.Visible = true
    esp.ZIndex = 2
    
    local color = getgenv().playerRoles[player]
    if color == getgenv().COLOR_MURDERER then
        esp.Color3 = Color3.new(1, 0, 0)
    elseif color == getgenv().COLOR_SHERIFF then
        esp.Color3 = Color3.new(0, 0, 1)
    else
        esp.Color3 = Color3.new(0, 1, 0)
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().ESPEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") then
                    for _, child in ipairs(p.Character.Head:GetChildren()) do
                        if child:IsA("BoxHandleAdornment") then
                            child:Destroy()
                        end
                    end
                end
            end
            continue
        end
        
        for _, p in ipairs(Players:GetPlayers()) do
            createESP(p)
        end
    end
end)

-- ================= ESP GUN DROP =================
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

-- ================= АВТОФАРМ (ZYN-IC OCTREE) =================
local farmThread = nil
local farmRunning = false

local function getCoinContainer()
    for _, v in Workspace:GetDescendants() do
        if v:IsA("Model") and v.Name == "Base" then
            return v.Parent:FindFirstChild("CoinContainer")
        end
    end
    return nil
end

local function moveToPositionSmooth(targetPos, duration)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local startPos = hrp.Position
    local startTime = tick()
    
    while tick() - startTime < duration do
        local alpha = (tick() - startTime) / duration
        local currentPos = startPos:Lerp(targetPos, alpha)
        hrp.CFrame = CFrame.new(currentPos)
        task.wait()
    end
    
    hrp.CFrame = CFrame.new(targetPos)
end

local function startZynicFarm()
    if farmRunning then return end
    farmRunning = true
    
    local coinContainer = getCoinContainer()
    if not coinContainer then
        Rayfield:Notify({ Title = "CrystalHub", Content = "CoinContainer not found!", Duration = 3 })
        farmRunning = false
        return
    end
    
    -- Загружаем Octree
    local Octree = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sleitnick/rbxts-octo-tree/main/src/init.lua", true))()
    local octree = Octree.new()
    local touchedCoins = {}
    local connections = {}
    
    local function markCoinTouched(coin)
        touchedCoins[coin] = true
        local node = octree:FindFirstNode(coin)
        if node then
            octree:RemoveNode(node)
        end
    end
    
    local function setupTracking(coin)
        if touchedCoins[coin] then return end
        
        local touchInterest = coin:FindFirstChildWhichIsA("TouchTransmitter")
        if touchInterest then
            local conn = touchInterest.AncestryChanged:Connect(function(_, parent)
                if parent == nil then
                    markCoinTouched(coin)
                end
            end)
            table.insert(connections, conn)
        end
        
        local posConn = coin:GetPropertyChangedSignal("Position"):Connect(function()
            if coin.Position.Y ~= coin:GetAttribute("LastY") then
                markCoinTouched(coin)
                coin:Destroy()
            end
        end)
        coin:SetAttribute("LastY", coin.Position.Y)
        table.insert(connections, posConn)
    end
    
    local function populateOctree()
        octree:ClearAllNodes()
        for _, descendant in pairs(coinContainer:GetDescendants()) do
            if descendant:IsA("TouchTransmitter") then
                local coin = descendant.Parent
                if not touchedCoins[coin] then
                    octree:CreateNode(coin.Position, coin)
                    setupTracking(coin)
                end
            end
        end
    end
    
    populateOctree()
    
    local waypoint = LocalPlayer.Character:GetPivot()
    
    while getgenv().AutoFarmEnabled and getgenv().isAlive() and getgenv().isInRound() do
        local char = LocalPlayer.Character
        if not char then break end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then break end
        
        local radius = getgenv().farmRadius or 200
        local nearestNode = octree:GetNearest(hrp.Position, radius, 1)[1]
        
        if nearestNode then
            local coin = nearestNode.Object
            if not touchedCoins[coin] then
                local distance = (hrp.Position - coin.Position).Magnitude
                local duration = distance / (getgenv().FarmSpeed or 30)
                
                moveToPositionSmooth(coin.Position, duration)
                markCoinTouched(coin)
                task.wait(0.2)
            end
        else
            task.wait(1)
        end
    end
    
    -- Очистка
    for _, conn in pairs(connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    octree:ClearAllNodes()
    
    if getgenv().AutoFarmEnabled then
        LocalPlayer.Character:PivotTo(waypoint)
    end
    
    farmRunning = false
end

-- Запуск автофарма в отдельном потоке
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().AutoFarmEnabled and getgenv().isAlive() and getgenv().isInRound() then
            if not farmRunning then
                farmThread = coroutine.create(startZynicFarm)
                coroutine.resume(farmThread)
            end
        elseif farmRunning then
            farmRunning = false
            if farmThread then
                coroutine.close(farmThread)
                farmThread = nil
            end
        end
    end
end)

print("CrystalHub MM2 Ultimate - Fully Loaded!")
