-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--            ALL FUNCTIONS FROM YOUR SOURCES
--            - ESP: Murder_Mystery_2-simple_ESP
--            - Silent Aim: Stefanuk12
--            - AutoFarm: MarsInsanity
--            - Fling: joshclark756
--            - Admin Panel: MarsInsanity
--                           PART 1/4
-- =================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "CrystalHub | MM2 Ultimate",
   Icon = 0,
   LoadingTitle = "CrystalHub MM2",
   LoadingSubtitle = "All Sources Integrated",
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
local MiscTab     = Window:CreateTab("Misc", 4483362458)

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ================= ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ =================
getgenv().SilentAimEnabled = false
getgenv().ShowFOV = false
getgenv().AutoFarmEnabled = false
getgenv().ESPEnabled = false
getgenv().GunESPEnabled = false
getgenv().XRayEnabled = false
getgenv().NoclipEnabled = false
getgenv().FlyEnabled = false
getgenv().InfiniteJumpEnabled = false
getgenv().AutoGrabGunEnabled = false
getgenv().CustomSpeed = 16
getgenv().CustomJump = 50
getgenv().FarmSpeed = 30
getgenv().farmRadius = 200
getgenv().ShowRoleNotifications = false
getgenv().SmartFarm = true

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

-- ================= РОЛИ (ИЗ ВАШЕГО ОРИГИНАЛЬНОГО КОДА) =================
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
            if getgenv().ShowRoleNotifications then
                Rayfield:Notify({ Title = "CrystalHub", Content = "Murderer: " .. player.Name, Duration = 3 })
            end
        end
    elseif name:find("gun") or name:find("revolver") or name:find("pistol") or name:find("пест") or name:find("luger") then
        if getgenv().playerRoles[player] ~= getgenv().COLOR_SHERIFF then
            getgenv().playerRoles[player] = getgenv().COLOR_SHERIFF
            if getgenv().ShowRoleNotifications then
                Rayfield:Notify({ Title = "CrystalHub", Content = "Sheriff: " .. player.Name, Duration = 3 })
            end
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
--                           PART 2/4
-- =================================================================

-- ================= SILENT AIM (ИЗ STEFANUK12) =================
local ValiantAimHacks = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Stefanuk12/ROBLOX/master/Universal/Experimental%20Silent%20Aim%20Module.lua"))()

ValiantAimHacks.SilentAimEnabled = false
ValiantAimHacks.ShowFOV = false
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

SilentTab:CreateToggle({
   Name = "Show FOV Circle",
   CurrentValue = false,
   Flag = "ShowFOVToggle",
   Callback = function(Value)
       ValiantAimHacks.ShowFOV = Value
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
   Name = "Visible Check",
   CurrentValue = true,
   Flag = "VisibleCheckToggle",
   Callback = function(Value)
       ValiantAimHacks.VisibleCheck = Value
   end,
})

-- Перехват для Silent Aim
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
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            Tool = bp:FindFirstChildOfClass("Tool")
            if Tool then
                LocalPlayer.Character.Humanoid:EquipTool(Tool)
                task.wait(0.1)
                Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            end
        end
    end
    if not Tool then
        Rayfield:Notify({ Title = "CrystalHub", Content = "No tool equipped!", Duration = 2 })
        return
    end
    
    local Handle = Tool:FindFirstChild("Handle")
    if not Handle then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Tool has no Handle!", Duration = 2 })
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
                task.wait(0.02)
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

getgenv().flingTarget = function(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        Rayfield:Notify({ Title = "CrystalHub", Content = "Target not found!", Duration = 2 })
        return
    end
    
    teleportEnabled = true
    Rayfield:Notify({ Title = "CrystalHub", Content = "Flinging target...", Duration = 2 })
    
    task.wait(2)
    teleportEnabled = false
    Rayfield:Notify({ Title = "CrystalHub", Content = "Fling completed!", Duration = 2 })
end

-- ================= SHOT BUTTON (ИЗ MARSINSANITY) =================
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

            local stroke = Instance.new("UIStroke")
            stroke.Parent = btn
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Thickness = 2

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
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 3/4
-- =================================================================

-- ================= ВКЛАДКА: COMBAT =================
CombatTab:CreateToggle({
   Name = "Auto Grab Gun",
   CurrentValue = false,
   Flag = "AutoGrabToggle",
   Callback = function(Value) getgenv().AutoGrabGunEnabled = Value end,
})

CombatTab:CreateButton({
   Name = "Fling Murderer",
   Callback = function()
       local m = getgenv().getPlayerByRole(getgenv().COLOR_MURDERER)
       if not m then
           Rayfield:Notify({ Title = "CrystalHub", Content = "Murderer not found!", Duration = 2 })
           return
       end
       getgenv().flingTarget(m)
   end,
})

CombatTab:CreateButton({
   Name = "Fling Sheriff",
   Callback = function()
       local s = getgenv().getPlayerByRole(getgenv().COLOR_SHERIFF)
       if not s then
           Rayfield:Notify({ Title = "CrystalHub", Content = "Sheriff not found!", Duration = 2 })
           return
       end
       getgenv().flingTarget(s)
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

CombatTab:CreateToggle({
   Name = "Show Shot Button",
   CurrentValue = false,
   Flag = "AutoShotToggle",
   Callback = function(Value) getgenv().toggleShotButton(Value) end,
})

-- ================= ВКЛАДКА: AUTO FARM =================
FarmTab:CreateToggle({
   Name = "Auto Farm Coins",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       getgenv().AutoFarmEnabled = Value
       if not Value then
           if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
               LocalPlayer.Character.Humanoid.PlatformStand = false
           end
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

-- ================= ВКЛАДКА: TELEPORTS =================
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

-- ================= ВКЛАДКА: VISUALS =================
VisualsTab:CreateToggle({
   Name = "ESP ON (E)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       getgenv().ESPEnabled = Value
   end,
})

VisualsTab:CreateToggle({
   Name = "ESP OFF (F)",
   CurrentValue = false,
   Flag = "ESPOffToggle",
   Callback = function(Value)
       if Value then
           for _, p in ipairs(Players:GetPlayers()) do
               if p.Character and p.Character:FindFirstChild("Head") then
                   for _, child in ipairs(p.Character.Head:GetChildren()) do
                       if child:IsA("BoxHandleAdornment") then
                           child:Destroy()
                       end
                   end
               end
           end
           getgenv().ESPEnabled = false
       end
   end,
})

VisualsTab:CreateButton({
   Name = "Refresh ESP",
   Callback = function()
       for _, p in ipairs(Players:GetPlayers()) do
           if p.Character and p.Character:FindFirstChild("Head") then
               for _, child in ipairs(p.Character.Head:GetChildren()) do
                   if child:IsA("BoxHandleAdornment") then
                       child:Destroy()
                   end
               end
           end
       end
       if getgenv().ESPEnabled then
           for _, p in ipairs(Players:GetPlayers()) do
               createESP(p)
           end
       end
       Rayfield:Notify({ Title = "CrystalHub", Content = "ESP Refreshed!", Duration = 2 })
   end,
})

VisualsTab:CreateToggle({
   Name = "ESP Gun Drop",
   CurrentValue = false,
   Flag = "GunESPToggle",
   Callback = function(Value)
       getgenv().GunESPEnabled = Value
   end,
})

VisualsTab:CreateToggle({
   Name = "X-Ray",
   CurrentValue = false,
   Flag = "XRayToggle",
   Callback = function(Value)
       getgenv().XRayEnabled = Value
       for _, v in pairs(Workspace:GetDescendants()) do
           if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
               if Value then
                   v.LocalTransparencyModifier = 0.75
               else
                   v.LocalTransparencyModifier = 0
               end
           end
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "Role Notifications",
   CurrentValue = false,
   Flag = "RoleNotificationsToggle",
   Callback = function(Value)
       getgenv().ShowRoleNotifications = Value
   end,
})

-- ================= ВКЛАДКА: PLAYER =================
PlayerTab:CreateToggle({
   Name = "Fly [X]",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
       getgenv().FlyEnabled = Value
       if Value then
           local char = LocalPlayer.Character
           if char then
               local humanoid = char:FindFirstChild("Humanoid")
               if humanoid then
                   humanoid.PlatformStand = true
               end
           end
           Rayfield:Notify({ Title = "CrystalHub", Content = "Fly ON (WASD)", Duration = 2 })
       else
           local char = LocalPlayer.Character
           if char then
               local humanoid = char:FindFirstChild("Humanoid")
               if humanoid then
                   humanoid.PlatformStand = false
               end
           end
           Rayfield:Notify({ Title = "CrystalHub", Content = "Fly OFF", Duration = 2 })
       end
   end,
})

PlayerTab:CreateToggle({
   Name = "Noclip [C]",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
       getgenv().NoclipEnabled = Value
       Rayfield:Notify({ Title = "CrystalHub", Content = "Noclip " .. (Value and "ON" or "OFF"), Duration = 2 })
   end,
})

PlayerTab:CreateToggle({
   Name = "Infinite Jump [V]",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
       getgenv().InfiniteJumpEnabled = Value
       Rayfield:Notify({ Title = "CrystalHub", Content = "Infinite Jump " .. (Value and "ON" or "OFF"), Duration = 2 })
   end,
})

PlayerTab:CreateTextBox({
   Name = "Walkspeed",
   PlaceholderText = "Insert Walkspeed",
   CurrentValue = "",
   Flag = "WalkspeedTB",
   Callback = function(Value)
       local num = tonumber(Value)
       if num then
           getgenv().CustomSpeed = num
           Rayfield:Notify({ Title = "CrystalHub", Content = "Speed set to " .. num, Duration = 2 })
       end
   end,
})

PlayerTab:CreateButton({
   Name = "Reset Speed",
   Callback = function()
       getgenv().CustomSpeed = 16
       Rayfield:Notify({ Title = "CrystalHub", Content = "Speed reset to 16", Duration = 2 })
   end,
})

PlayerTab:CreateTextBox({
   Name = "Jump Power",
   PlaceholderText = "Insert JumpPower",
   CurrentValue = "",
   Flag = "JumpPowerTB",
   Callback = function(Value)
       local num = tonumber(Value)
       if num then
           getgenv().CustomJump = num
           Rayfield:Notify({ Title = "CrystalHub", Content = "JumpPower set to " .. num, Duration = 2 })
       end
   end,
})

PlayerTab:CreateButton({
   Name = "Reset Jump",
   Callback = function()
       getgenv().CustomJump = 50
       Rayfield:Notify({ Title = "CrystalHub", Content = "JumpPower reset to 50", Duration = 2 })
   end,
})

-- ================= ВКЛАДКА: MISC =================
MiscTab:CreateButton({
   Name = "Anti-Lag (FPS Boost)",
   Callback = function() antiLag() end,
})

MiscTab:CreateButton({
   Name = "FullBright",
   Callback = function() fullBright() end,
})

MiscTab:CreateButton({
   Name = "Remove Shadows",
   Callback = function() removeShadows() end,
})

MiscTab:CreateButton({
   Name = "Server Hop",
   Callback = function()
       local TeleportService = game:GetService("TeleportService")
       TeleportService:Teleport(game.PlaceId)
       Rayfield:Notify({ Title = "CrystalHub", Content = "Server hopping...", Duration = 2 })
   end,
})
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 4/4
-- =================================================================

-- ================= ESP (ИЗ MURDER_MYSTERY_2-SIMPLE_ESP) =================
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
        if getgenv().ESPEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                createESP(p)
            end
        else
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

-- ================= FLY (ИЗ MARSINSANITY) =================
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyControls = {F = 0, B = 0, L = 0, R = 0}

task.spawn(function()
    while true do
        task.wait()
        if getgenv().FlyEnabled and LocalPlayer.Character then
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

-- ================= INFINITE JUMP (ИЗ MARSINSANITY) =================
game:GetService("UserInputService").JumpRequest:Connect(function()
    if getgenv().InfiniteJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ================= АВТОФАРМ (ИЗ MARSINSANITY) =================
task.spawn(function()
    while true do
        task.wait(0.2)
        if getgenv().AutoFarmEnabled and getgenv().isInRound() and getgenv().isAlive() then
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                continue
            end
            
            local hrp = char.HumanoidRootPart
            
            local bestCoin = nil
            local bestDist = math.huge
            
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("монет")) then
                    if getgenv().SmartFarm then
                        local murderer = getgenv().getPlayerByRole(getgenv().COLOR_MURDERER)
                        if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                            local murdPos = murderer.Character.HumanoidRootPart.Position
                            if (obj.Position - murdPos).Magnitude < 30 then
                                continue
                            end
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
                hrp.CFrame = CFrame.new(bestCoin.Position)
                task.wait(0.1)
            end
        else
            task.wait(0.5)
        end
    end
end)

print("CrystalHub MM2 Ultimate - Fully Loaded!")
