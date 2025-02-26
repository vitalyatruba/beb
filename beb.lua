-- // Сервисы // --
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- // Глобальные переменные // --
_G.autoreload = false         -- автоприцеливание
_G.autoMove = false           -- автоматическое перемещение
_G.addTextLabels = false      -- добавление текстовых меток
_G.infiniteJumpEnabled = false-- бесконечный прыжок
getgenv().cframespeedtoggle = false -- для cframe скорости
getgenv().speedvalue = 0.1    -- начальное значение для слайдера скорости

-- Подключение Heartbeat (без изменений для cframe скорости)
RunService.Heartbeat:Connect(function()
    if cframespeedtoggle == true then
        LocalPlayer.Character.HumanoidRootPart.CFrame =
            LocalPlayer.Character.HumanoidRootPart.CFrame +
            LocalPlayer.Character.Humanoid.MoveDirection * speedvalue
    end
end)

-------------------------------
-- Вспомогательные функции UI и прочее
-------------------------------

-- Создание текстовой метки над объектом
local function createTextLabel(parent, text)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = parent
    billboardGui.Size = UDim2.new(0, 100, 0, 25)
    billboardGui.StudsOffset = Vector3.new(0, 5, 0)
    billboardGui.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = text
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(0, 0.5, 1)
    textLabel.TextScaled = true
    textLabel.TextSize = 10
    textLabel.Parent = billboardGui

    billboardGui.Parent = parent
end

-- Добавление/удаление текстовых меток на островах
local function updateTextLabels(state)
    if state then
        for _, island in ipairs(workspace.Islands:GetChildren()) do
            createTextLabel(island, island.Name)
        end
    else
        for _, island in ipairs(workspace.Islands:GetChildren()) do
            local billboardGui = island:FindFirstChildOfClass("BillboardGui")
            if billboardGui then
                billboardGui:Destroy()
            end
        end
    end
end

-- Функция автоприцеливания (без изменений)
local function autoreload()
    while _G.autoreload do
        task.wait()
        local npc = workspace.NPCs:FindFirstChild("Fishman Karate User")
        if not npc then
            warn("❌ NPC 'Fishman Karate User' не найден в workspace.NPCs!")
            return
        end
        local fish = npc:FindFirstChild("Head")
        if not fish then
            warn("❌ Голова NPC 'Fishman Karate User' не найдена!")
            return
        end

        local args = {
            [1] = "fire",
            [2] = {
                ["Start"] = CFrame.new(7729, -2158, -17227),
                ["Gun"] = "Rifle",
                ["joe"] = true,
                ["Position"] = fish.Position
            }
        }

        local event = ReplicatedStorage:WaitForChild("Events"):FindFirstChild("CIcklcon")
        if not event then
            warn("❌ 'CIcklcon' не найден в Events!")
            return
        end

        event:FireServer(unpack(args))
    end
end

-- Перемещение игрока к заданной позиции (без изменений)
local function movePlayerToPosition(target, speed)
    if not LocalPlayer.Character then
        warn("❌ Персонаж игрока не найден!")
        return
    end

    local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        warn("❌ HumanoidRootPart не найден!")
        return
    end

    local distance = (target - rootPart.Position).Magnitude
    local duration = distance / speed

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(target)})
    tween:Play()
    tween.Completed:Wait()

    game.StarterGui:SetCore("SendNotification", {
        Title = "Teleport",
        Text = "You have arrived at the destination!",
    })
end

local function autoMoveFunction()
    while _G.autoMove do
        task.wait()
        local quest = LocalPlayer.PlayerGui:FindFirstChild("Quest")
        if not quest then
            warn("❌ 'Quest' не найден в PlayerGui!")
            return
        end
        if quest.Enabled then
            warn("❌ Quest включен!")
            return
        end

        local levelText = LocalPlayer.PlayerGui.HUD.Main.Bars.Experience.Detail:FindFirstChild("Level")
        if not levelText then
            warn("❌ 'Level' не найден в PlayerGui.HUD.Main.Bars.Experience.Detail!")
            return
        end

        local currentLevel = tonumber(levelText.Text:match("%d+"))
        if not currentLevel or currentLevel <= 180 then
            warn("❌ Уровень игрока меньше или равен 180!")
            return
        end

        local targetPosition = Vector3.new(7734, -2165, -17218)
        movePlayerToPosition(targetPosition, 50)
    end
end

-- Бесконечный прыжок (без изменений)
UserInputService.JumpRequest:Connect(function()
    if _G.infiniteJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-------------------------------
-- UI через Fuzki-UI-Library
-------------------------------
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Fuzki-UI-Library/main/FuzkiLibrary.lua"))()
local MainUI = Library:Create("Fuzki", "Baseplate")

local Other = MainUI:CreateSection("Other")
local Preview = MainUI:CreateSection("Preview")

Preview:CreateLabel("Text Label")
Preview:CreateButton("Button Text", "Button Info", function()
    print("Wow, printed")
end)

Preview:CreateToggle("Auto Reload", function(state)
    _G.autoreload = state
    if state then
        task.spawn(autoreload)
    end
end)

Preview:CreateToggle("Auto Move", function(state)
    _G.autoMove = state
    if state then
        task.spawn(autoMoveFunction)
    end
end)

Preview:CreateToggle("Add Text Labels", function(state)
    _G.addTextLabels = state
    task.spawn(function() updateTextLabels(state) end)
end)

Preview:CreateToggle("Infinite Jump", function(state)
    _G.infiniteJumpEnabled = state
    print(state and "Бесконечный прыжок включен!" or "Бесконечный прыжок выключен!")
end)

------------------------------------------------
-- Новый режим полёта (плавное парение без падения)
------------------------------------------------
_G.flyEnabled = false         -- Глобально включается возможность полёта (через UI)
local flightActive = false     -- Текущее состояние полёта (включено/выключено)
local flySpeed = 50            -- Скорость полёта (по умолчанию)

-- Объекты для управления полётом
local BV, BG, BF  -- BodyVelocity, BodyGyro, BodyForce

-- UI переключатель для возможности полёта
Preview:CreateToggle("Fly", function(state)
    _G.flyEnabled = state
    if state then
        print("Fly включён. Нажми G для включения/выключения режима полёта.")
    else
        print("Fly выключен.")
        if flightActive then
            flightActive = false
            if BV then BV:Destroy() BV = nil end
            if BG then BG:Destroy() BG = nil end
            if BF then BF:Destroy() BF = nil end
        end
    end
end)

-- Слайдер для регулировки скорости полёта
Preview:CreateSlider(10, 200, "Flight Speed", function(value)
    flySpeed = value
    print("Flight speed set to: " .. value)
end)

-- Переключение режима полёта по нажатию G
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if _G.flyEnabled and input.KeyCode == Enum.KeyCode.G then
        flightActive = not flightActive
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            if flightActive then
                -- Создаём BodyVelocity для направления движения
                BV = Instance.new("BodyVelocity")
                BV.Parent = hrp
                BV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                BV.Velocity = Vector3.new(0, 0, 0)
                
                -- Создаём BodyGyro для плавного поворота
                BG = Instance.new("BodyGyro")
                BG.Parent = hrp
                BG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                BG.CFrame = hrp.CFrame
                
                -- Создаём BodyForce для компенсации гравитации (чтобы не падал)
                BF = Instance.new("BodyForce")
                BF.Parent = hrp
                BF.Force = Vector3.new(0, hrp:GetMass() * workspace.Gravity, 0)
                
                print("Flight activated")
            else
                if BV then BV:Destroy() BV = nil end
                if BG then BG:Destroy() BG = nil end
                if BF then BF:Destroy() BF = nil end
                print("Flight deactivated")
            end
        end
    end
end)

-- Обновление движения в режиме полёта через RenderStepped
RunService.RenderStepped:Connect(function(dt)
    if flightActive then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new()
            -- Горизонтальное управление: W, A, S, D
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + cam.CFrame.RightVector
            end
            -- Вертикальное управление: E (вверх), Q (вниз)
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
            end

            -- Прописываем новое значение скорости через BodyVelocity
            if BV then
                BV.Velocity = moveDir * flySpeed
            end

            -- Плавное поворачивание в сторону движения через BodyGyro
            if BG then
                if moveDir.Magnitude > 0 then
                    BG.CFrame = CFrame.new(hrp.Position, hrp.Position + moveDir)
                else
                    BG.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
                end
            end
        end
    end
end)
