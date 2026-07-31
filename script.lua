-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                ВСЕ ФУНКЦИИ ИЗ MARSINSANITY MM2ADMINPANEL
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
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ================= ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ (ИЗ MARSINSANITY) =================
getgenv().AutoGrabGunEnabled = false
getgenv().AutoFarmEnabled = false
getgenv().ESPEnabled = false
getgenv().NoclipEnabled = false
getgenv().FlyEnabled = false
getgenv().InfiniteJumpEnabled = false
getgenv().XRayEnabled = false
getgenv().CustomSpeed = 16
getgenv().CustomJump = 50

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

-- ================= ОПРЕДЕЛЕНИЕ РОЛЕЙ (ИЗ MARSINSANITY) =================
local function GetMurderer()
    local plrs = game:GetService("Players")
    for i, v in pairs(plrs:GetPlayers()) do
        if v.Character:FindFirstChild("Knife") or v.Backpack:FindFirstChild("Knife") then
            return v
        end
    end
end

local function GetSheriff()
    local plrs = game:GetService("Players")
    for i, v in pairs(plrs:GetPlayers()) do
        if v.Character:FindFirstChild("Gun") or v.Backpack:FindFirstChild("Gun") then
            return v
        end
    end
end
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 2/4
-- =================================================================

-- ================= FLY (ИЗ MARSINSANITY) =================
local flying = false
local lplayer = game.Players.LocalPlayer
local speedget = 1
local speedfly = 1

local function startFly()
    if flying == false then
        flying = true
        repeat task.wait() until lplayer and lplayer.Character and lplayer.Character:FindFirstChild('HumanoidRootPart') and lplayer.Character:FindFirstChild('Humanoid')
        
        local T = lplayer.Character.HumanoidRootPart
        local CONTROL = {F = 0, B = 0, L = 0, R = 0}
        local lCONTROL = {F = 0, B = 0, L = 0, R = 0}
        local SPEED = speedget
        
        local function fly()
            flying = true
            local BG = Instance.new('BodyGyro', T)
            local BV = Instance.new('BodyVelocity', T)
            BG.P = 9e4
            BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.cframe = T.CFrame
            BV.velocity = Vector3.new(0, 0.1, 0)
            BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
            spawn(function()
                repeat task.wait()
                    lplayer.Character.Humanoid.PlatformStand = true
                    if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 then
                        SPEED = 50
                    elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0) and SPEED ~= 0 then
                        SPEED = 0
                    end
                    if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 then
                        BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                        lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                    elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and SPEED ~= 0 then
                        BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                    else
                        BV.velocity = Vector3.new(0, 0.1, 0)
                    end
                    BG.cframe = workspace.CurrentCamera.CoordinateFrame
                until not flying
                CONTROL = {F = 0, B = 0, L = 0, R = 0}
                lCONTROL = {F = 0, B = 0, L = 0, R = 0}
                SPEED = 0
                BG:Destroy()
                BV:Destroy()
                lplayer.Character.Humanoid.PlatformStand = false
            end)
        end
        
        Mouse.KeyDown:Connect(function(KEY)
            if KEY:lower() == 'w' then
                CONTROL.F = speedfly
            elseif KEY:lower() == 's' then
                CONTROL.B = -speedfly
            elseif KEY:lower() == 'a' then
                CONTROL.L = -speedfly
            elseif KEY:lower() == 'd' then
                CONTROL.R = speedfly
            end
        end)
        Mouse.KeyUp:Connect(function(KEY)
            if KEY:lower() == 'w' then
                CONTROL.F = 0
            elseif KEY:lower() == 's' then
                CONTROL.B = 0
            elseif KEY:lower() == 'a' then
                CONTROL.L = 0
            elseif KEY:lower() == 'd' then
                CONTROL.R = 0
            end
        end)
        fly()
    else
        flying = false
        lplayer.Character.Humanoid.PlatformStand = false
    end
end

-- ================= NOCLIP (ИЗ MARSINSANITY) =================
local noclip = false

RunService.Stepped:Connect(function()
    if noclip then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(11)
        end
    end
end)

-- ================= INFINITE JUMP (ИЗ MARSINSANITY) =================
local InfiniteJump = false

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJump then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

-- ================= X-RAY (ИЗ MARSINSANITY) =================
local obj = game.Workspace

function XrayOn(obj)
    for _, v in pairs(obj:GetChildren()) do
        if (v:IsA("BasePart")) and not v.Parent:FindFirstChild("Humanoid") then
            v.LocalTransparencyModifier = 0.75
        end
        XrayOn(v)
    end
end

function XrayOff(obj)
    for _, v in pairs(obj:GetChildren()) do
        if (v:IsA("BasePart")) and not v.Parent:FindFirstChild("Humanoid") then
            v.LocalTransparencyModifier = 0
        end
        XrayOff(v)
    end
end

-- ================= KILL MURDERER (ИЗ MARSINSANITY) =================
local function KillMurderer()
    local Murderer = GetMurderer()
    repeat
        if Murderer ~= nil then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Murderer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
            workspace.CurrentCamera.CFrame = Murderer.Character.HumanoidRootPart.CFrame
        end
        task.wait()
    until Murderer.Character.Humanoid.Health == 0
end

-- ================= KILL ALL (ИЗ MARSINSANITY) =================
local function KillAll()
    for i, Victim in pairs(Players:GetPlayers()) do
        if Victim.Name ~= LocalPlayer.Name then
            repeat
                task.wait()
                LocalPlayer.Character.HumanoidRootPart.CFrame = Victim.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
            until Victim.Character.Humanoid.Health == 0
        end
    end
end

-- ================= GUN GRABBER (ИЗ MARSINSANITY) =================
local function GunGrabber()
    local currentX = LocalPlayer.Character.HumanoidRootPart.CFrame.X
    local currentY = LocalPlayer.Character.HumanoidRootPart.CFrame.Y
    local currentZ = LocalPlayer.Character.HumanoidRootPart.CFrame.Z

    if workspace:FindFirstChild("GunDrop") ~= nil then
        LocalPlayer.Character.HumanoidRootPart.CFrame = workspace:FindFirstChild("GunDrop").CFrame
        task.wait(0.25)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(currentX, currentY, currentZ)
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "CrystalHub",
            Text = "Wait for the Sheriff's death to grab the gun",
            Icon = "",
            Duration = 2,
        })
    end
end

-- ================= COIN FARM (ИЗ MARSINSANITY) =================
local function CoinFarm()
    local toggle = false
    
    toggle = not toggle
    while toggle do
        task.wait(0.25)
        local place = workspace:GetChildren()
        local currentX = LocalPlayer.Character.HumanoidRootPart.CFrame.X
        local currentY = LocalPlayer.Character.HumanoidRootPart.CFrame.Y
        local currentZ = LocalPlayer.Character.HumanoidRootPart.CFrame.Z

        for i, v in pairs(place) do
            local vChildren = v:GetChildren()
            for i, child in pairs(vChildren) do
                if child.Name == "CoinContainer" then
                    if child.Coin_Server:FindFirstChild("Coin") ~= nil then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = child.Coin_Server.Coin.CFrame
                    else
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(currentX, currentY, currentZ)
                        toggle = false
                    end
                end
            end
        end
    end
end

-- ================= ESP (ИЗ MARSINSANITY) =================
local ESPToggle = false
local faces = {"Back", "Bottom", "Front", "Left", "Right", "Top"}

function MakeESP()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Name ~= LocalPlayer.Name then
            local bgui = Instance.new("BillboardGui", v.Character.Head)
            bgui.Name = ("EGUI")
            bgui.AlwaysOnTop = true
            bgui.ExtentsOffset = Vector3.new(0, 2, 0)
            bgui.Size = UDim2.new(0, 200, 0, 50)
            local nam = Instance.new("TextLabel", bgui)
            nam.Text = v.Name
            nam.BackgroundTransparency = 1
            nam.TextSize = 15
            nam.Font = ("GothamBold")
            nam.TextColor3 = Color3.new(255, 255, 255)
            nam.Size = UDim2.new(0, 200, 0, 50)
            
            if v.Backpack:FindFirstChild("Gun") or v.Character:FindFirstChild("Gun") then
                for _, p in pairs(v.Character:GetChildren()) do
                    if p.Name == ("Head") or p.Name == ("Torso") or p.Name == ("Right Arm") or p.Name == ("Right Leg") or p.Name == ("Left Arm") or p.Name == ("Left Leg") then
                        for _, f in pairs(faces) do
                            local m = Instance.new("SurfaceGui", p)
                            m.Name = ("EGUI")
                            m.Face = f
                            m.AlwaysOnTop = true
                            local mf = Instance.new("Frame", m)
                            mf.Size = UDim2.new(1, 0, 1, 0)
                            mf.BorderSizePixel = 0
                            mf.BackgroundTransparency = 0.5
                            mf.BackgroundColor3 = Color3.new(0, 0, 255)
                        end
                    end
                end
            elseif v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife") then
                for _, p in pairs(v.Character:GetChildren()) do
                    if p.Name == ("Head") or p.Name == ("Torso") or p.Name == ("Right Arm") or p.Name == ("Right Leg") or p.Name == ("Left Arm") or p.Name == ("Left Leg") then
                        for _, f in pairs(faces) do
                            local m = Instance.new("SurfaceGui", p)
                            m.Name = ("EGUI")
                            m.Face = f
                            m.AlwaysOnTop = true
                            local mf = Instance.new("Frame", m)
                            mf.Size = UDim2.new(1, 0, 1, 0)
                            mf.BorderSizePixel = 0
                            mf.BackgroundTransparency = 0.5
                            mf.BackgroundColor3 = Color3.new(255, 0, 0)
                        end
                    end
                end
            else
                for _, p in pairs(v.Character:GetChildren()) do
                    if p.Name == ("Head") or p.Name == ("Torso") or p.Name == ("Right Arm") or p.Name == ("Right Leg") or p.Name == ("Left Arm") or p.Name == ("Left Leg") then
                        for _, f in pairs(faces) do
                            local m = Instance.new("SurfaceGui", p)
                            m.Name = ("EGUI")
                            m.Face = f
                            m.AlwaysOnTop = true
                            local mf = Instance.new("Frame", m)
                            mf.Size = UDim2.new(1, 0, 1, 0)
                            mf.BorderSizePixel = 0
                            mf.BackgroundTransparency = 0.5
                            mf.BackgroundColor3 = Color3.new(255, 255, 255)
                        end
                    end
                end
            end
        end
    end
end

function ClearESP()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == ("EGUI") then
            v:Destroy()
        end
    end
end

function RefreshESP()
    if ESPToggle then
        task.wait(1)
        ClearESP()
        MakeESP()
    end
end
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 3/4
-- =================================================================

-- ================= ВКЛАДКА: БОЙ =================
CombatTab:CreateToggle({
   Name = "Gun Grabber",
   CurrentValue = false,
   Flag = "GunGrabberToggle",
   Callback = function(Value)
       getgenv().AutoGrabGunEnabled = Value
       if Value then GunGrabber() end
   end,
})

CombatTab:CreateButton({
   Name = "Kill Murderer",
   Callback = function()
       KillMurderer()
   end,
})

CombatTab:CreateButton({
   Name = "Kill All",
   Callback = function()
       KillAll()
   end,
})

-- ================= ВКЛАДКА: ВИЗУАЛЫ =================
VisualsTab:CreateToggle({
   Name = "Everyone ESP",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       ESPToggle = Value
       if Value then
           ClearESP()
           MakeESP()
       else
           ClearESP()
       end
   end,
})

VisualsTab:CreateButton({
   Name = "Refresh ESP",
   Callback = function()
       RefreshESP()
   end,
})

VisualsTab:CreateToggle({
   Name = "X-Ray",
   CurrentValue = false,
   Flag = "XRayToggle",
   Callback = function(Value)
       getgenv().XRayEnabled = Value
       if Value then
           XrayOn(obj)
       else
           XrayOff(obj)
       end
   end,
})

-- ================= ВКЛАДКА: АВТОФАРМ =================
FarmTab:CreateToggle({
   Name = "Coin Farm (RISKY)",
   CurrentValue = false,
   Flag = "CoinFarmToggle",
   Callback = function(Value)
       getgenv().AutoFarmEnabled = Value
       if Value then
           CoinFarm()
       end
   end,
})

-- ================= ВКЛАДКА: ТЕЛЕПОРТЫ =================
TeleportTab:CreateButton({
   Name = "TP to Lobby",
   Callback = function()
       LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-108.5, 145, 0.6)
   end,
})

TeleportTab:CreateButton({
   Name = "TP to Map",
   Callback = function()
       local Workplace = workspace:GetChildren()
       for i, Thing in pairs(Workplace) do
           local ThingChildren = Thing:GetChildren()
           for i, Child in pairs(ThingChildren) do
               if Child.Name == "Spawns" then
                   LocalPlayer.Character.HumanoidRootPart.CFrame = Child.Spawn.CFrame
               end
           end
       end
   end,
})

TeleportTab:CreateButton({
   Name = "TP to Murderer",
   Callback = function()
       local Players = game:GetService("Players")
       for i, player in pairs(Players:GetPlayers()) do
           local bp = player.Backpack:GetChildren()
           for i, tool in pairs(bp) do
               if tool.Name == "Knife" then
                   LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[tool.Parent.Parent.Name].Character.HumanoidRootPart.CFrame
               end
           end
       end
   end,
})

TeleportTab:CreateButton({
   Name = "TP to Sheriff",
   Callback = function()
       local Players = game:GetService("Players")
       for i, player in pairs(Players:GetPlayers()) do
           local bp = player.Backpack:GetChildren()
           for i, tool in pairs(bp) do
               if tool.Name == "Gun" then
                   LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[tool.Parent.Parent.Name].Character.HumanoidRootPart.CFrame
               end
           end
       end
   end,
})

TeleportTab:CreateTextBox({
   Name = "TP to Player",
   PlaceholderText = "Insert Name",
   CurrentValue = "",
   Flag = "TeleportTB",
   Callback = function(Value)
       local Victim = Value
       LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[Victim].Character.HumanoidRootPart.CFrame
   end,
})

-- ================= ВКЛАДКА: ИГРОК =================
PlayerTab:CreateToggle({
   Name = "Fly [X]",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
       getgenv().FlyEnabled = Value
       if Value then
           startFly()
       else
           flying = false
           if LocalPlayer.Character then
               LocalPlayer.Character.Humanoid.PlatformStand = false
           end
       end
   end,
})

PlayerTab:CreateToggle({
   Name = "Noclip [C]",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
       noclip = Value
       getgenv().NoclipEnabled = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Infinite Jump [V]",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
       InfiniteJump = Value
       getgenv().InfiniteJumpEnabled = Value
   end,
})

PlayerTab:CreateTextBox({
   Name = "Walkspeed",
   PlaceholderText = "Insert Walkspeed",
   CurrentValue = "",
   Flag = "WalkspeedTB",
   Callback = function(Value)
       LocalPlayer.Character.Humanoid.WalkSpeed = Value
       getgenv().CustomSpeed = tonumber(Value) or 16
   end,
})

PlayerTab:CreateButton({
   Name = "Reset Walkspeed",
   Callback = function()
       LocalPlayer.Character.Humanoid.WalkSpeed = 16
       getgenv().CustomSpeed = 16
   end,
})

PlayerTab:CreateTextBox({
   Name = "Jump Power",
   PlaceholderText = "Insert JumpPower",
   CurrentValue = "",
   Flag = "JumpPowerTB",
   Callback = function(Value)
       LocalPlayer.Character.Humanoid.JumpPower = Value
       getgenv().CustomJump = tonumber(Value) or 50
   end,
})

PlayerTab:CreateButton({
   Name = "Reset Jump",
   Callback = function()
       LocalPlayer.Character.Humanoid.JumpPower = 50
       getgenv().CustomJump = 50
   end,
})
-- =================================================================
--                CRYSTALHUB MM2 ULTIMATE EDITION
--                           PART 4/4
-- =================================================================

-- ================= ОБНОВЛЕНИЕ ESP (ИЗ MARSINSANITY) =================
Players.PlayerAdded:Connect(function(v)
    if ESPToggle then
        task.wait(1)
        ClearESP()
        MakeESP()
    end
end)

Players.PlayerRemoving:Connect(function(v)
    if ESPToggle then
        task.wait(1)
        ClearESP()
        MakeESP()
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        if ESPToggle then
            task.wait(1)
            ClearESP()
            MakeESP()
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
