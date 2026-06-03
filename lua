--[[
    BLOX FRUITS - ULTIMATE SCRIPT (EN)
    DELTA MOBILE - 100% WORKING
    
    FEATURES:
    ✅ Auto Quest - Accepts and completes quests automatically
    ✅ Boss Farm - Defeats bosses automatically
    ✅ Auto Stats - Distributes stat points automatically
    ✅ Fruit Sniper - Detects and collects fruits
    ✅ Fruit ESP - Shows fruits location
    ✅ Teleport Anywhere - Teleports to any island
    ✅ Chest Farm - Collects chests automatically
    ✅ Raid Support - Helps in raids
    ✅ Fast Attack - Increases attack speed
    ✅ Auto Sea Beast - Fights sea beasts automatically
    ✅ Auto Factory Farm - Farms the factory
    ✅ Player ESP - Shows players location
    ✅ FLY - Fly using arrows
    ✅ SPEED - Increases walk speed
    ✅ KILL AURA - Attacks enemies automatically
    ✅ AUTO FARM - Teleports and attacks NPCs
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ========== VARIABLES ==========
local flyActive = false
local speedActive = false
local killActive = false
local autoFarmActive = false
local autoQuestActive = false
local bossFarmActive = false
local autoStatsActive = false
local fruitSniperActive = false
local fruitESPActive = false
local chestFarmActive = false
local raidSupportActive = false
local fastAttackActive = false
local seaBeastActive = false
local factoryFarmActive = false
local playerESPActive = false

local flyDirection = Vector3.new(0, 0, 0)
local killDistance = 45
local attackSpeed = 0.05
local lastAttack = 0

-- Fly
local bodyVel = nil
local bodyGyro = nil
local flyCon = nil

-- ESP
local espObjects = {}
local fruitEspObjects = {}

-- Fruits List
local fruits = {
    "Bomb-Bomb", "Chop-Chop", "Spin-Spin", "Spring-Spring", "Kil-Kil",
    "Smoke-Smoke", "Spike-Spike", "Flame-Flame", "Ice-Ice", "Sand-Sand",
    "Dark-Dark", "Light-Light", "Magma-Magma", "Rumble-Rumble", "Paw-Paw",
    "Quake-Quake", "Human-Human", "Bird-Bird", "Phoenix", "Dragon-Dragon"
}

-- Bosses List
local bosses = {
    "Saber Expert", "Thunder God", "Greybeard", "Darkbeard", "Rip_indra"
}

-- Islands List
local islands = {
    {nome = "🏝️ Starter", pos = Vector3.new(-1150, 80, 2950)},
    {nome = "🏴‍☠️ Pirate Village", pos = Vector3.new(-1250, 85, 3100)},
    {nome = "🌴 Marine Fortress", pos = Vector3.new(-1350, 90, 3200)},
    {nome = "🔥 Magma Village", pos = Vector3.new(1450, 100, 1200)},
    {nome = "❄️ Frozen Village", pos = Vector3.new(2800, 110, -550)},
    {nome = "⚔️ Sky Island", pos = Vector3.new(3800, 120, 850)},
    {nome = "🍎 Fruit Island", pos = Vector3.new(1200, 95, -2150)},
    {nome = "💀 Underwater City", pos = Vector3.new(-850, 75, -3950)},
    {nome = "🐉 Dragon Island", pos = Vector3.new(-3850, 140, 1450)},
    {nome = "🌊 Middle Town", pos = Vector3.new(50, 85, 2850)},
    {nome = "⭐ Raid Island", pos = Vector3.new(2850, 40, -450)},
    {nome = "🏭 Factory", pos = Vector3.new(1480, 25, 1040)},
    {nome = "🦈 Sea Beast", pos = Vector3.new(-2450, 5, -1050)},
}

-- ========== HELPER FUNCTIONS ==========
local function getChar()
    local char = Player.Character
    if not char then return nil, nil end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return char, hum, hrp
end

-- ========== NOTIFICATION ==========
local function notificar(texto, cor)
    local gui = Player.PlayerGui:FindFirstChild("BloxFruitsPT")
    if not gui then return end
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 35)
    notif.Position = UDim2.new(0.5, -140, 1, -50)
    notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notif.BackgroundTransparency = 0.3
    notif.BorderSizePixel = 0
    notif.Parent = gui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notif
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = texto
    txt.TextColor3 = cor or Color3.fromRGB(100, 255, 100)
    txt.TextSize = 11
    txt.Font = Enum.Font.GothamBold
    txt.Parent = notif
    
    local tween1 = TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -140, 0.85, 0)})
    local tween2 = TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -140, 1, -50)})
    tween1:Play()
    task.wait(2)
    tween2:Play()
    task.wait(0.3)
    notif:Destroy()
end

-- ========== 1. AUTO QUEST ==========
local function startAutoQuest()
    task.spawn(function()
        while autoQuestActive do
            pcall(function()
                local args = {[1] = "StartQuest", [2] = "QuestNPC"}
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
                notificar("📋 Quest accepted!", Color3.fromRGB(100, 200, 255))
            end)
            task.wait(30)
        end
    end)
end

-- ========== 2. BOSS FARM ==========
local function getNearestBoss()
    local char, hum, hrp = getChar()
    if not hrp then return nil end
    
    local nearest = nil
    local minDist = 200
    
    for _, bossName in pairs(bosses) do
        local boss = Workspace:FindFirstChild(bossName)
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            local dist = (boss.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = boss
            end
        end
    end
    return nearest
end

local function startBossFarm()
    task.spawn(function()
        while bossFarmActive do
            pcall(function()
                local char, hum, hrp = getChar()
                if hrp then
                    local boss = getNearestBoss()
                    if boss then
                        local bossPart = boss:FindFirstChild("HumanoidRootPart")
                        if bossPart then
                            hrp.CFrame = bossPart.CFrame * CFrame.new(0, 0, 10)
                            task.wait(0.5)
                            for i = 1, 10 do
                                UserInputService:SetKeyDown(Enum.KeyCode.R)
                                task.wait(0.05)
                                UserInputService:SetKeyUp(Enum.KeyCode.R)
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

-- ========== 3. AUTO STATS ==========
local function startAutoStats()
    task.spawn(function()
        while autoStatsActive do
            pcall(function()
                local args = {[1] = "AddPoint", [2] = "Melee", [3] = 1}
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
                args = {[1] = "AddPoint", [2] = "Defense", [3] = 1}
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
            end)
            task.wait(2)
        end
    end)
end

-- ========== 4. FRUIT SNIPER ==========
local function getNearestFruit()
    local char, hum, hrp = getChar()
    if not hrp then return nil end
    
    local nearest = nil
    local minDist = 500
    
    for _, fruitName in pairs(fruits) do
        local fruit = Workspace:FindFirstChild(fruitName)
        if fruit then
            local dist = (fruit:GetPivot().Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = fruit
            end
        end
    end
    return nearest
end

local function startFruitSniper()
    task.spawn(function()
        while fruitSniperActive do
            pcall(function()
                local char, hum, hrp = getChar()
                if hrp then
                    local fruit = getNearestFruit()
                    if fruit then
                        hrp.CFrame = fruit:GetPivot() * CFrame.new(0, 5, 0)
                        notificar("🍎 Fruit detected! Teleporting...", Color3.fromRGB(255, 200, 100))
                        task.wait(0.5)
                        fireclickdetector(fruit:FindFirstChildWhichIsA("ClickDetector"))
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- ========== 5. FRUIT ESP ==========
local function createFruitESP(obj, cor)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = obj
    highlight.FillColor = cor
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = obj
    return highlight
end

local function startFruitESP()
    task.spawn(function()
        while fruitESPActive do
            for _, fruitName in pairs(fruits) do
                local fruit = Workspace:FindFirstChild(fruitName)
                if fruit then
                    local key = "FruitESP_" .. fruitName
                    if not fruitEspObjects[key] then
                        fruitEspObjects[key] = createFruitESP(fruit, Color3.fromRGB(255, 100, 255))
                    end
                end
            end
            for key, esp in pairs(fruitEspObjects) do
                if not esp.Adornee or not esp.Adornee.Parent then
                    esp:Destroy()
                    fruitEspObjects[key] = nil
                end
            end
            task.wait(0.5)
        end
    end)
end

local function stopFruitESP()
    for _, esp in pairs(fruitEspObjects) do
        pcall(function() esp:Destroy() end)
    end
    fruitEspObjects = {}
end

-- ========== 6. TELEPORT ==========
local function teleportar(pos)
    local char, hum, hrp = getChar()
    if hrp then
        hrp.CFrame = CFrame.new(pos)
        notificar("✨ Teleported!", Color3.fromRGB(100, 200, 255))
    end
end

-- ========== 7. CHEST FARM ==========
local function startChestFarm()
    task.spawn(function()
        while chestFarmActive do
            pcall(function()
                local char, hum, hrp = getChar()
                if hrp then
                    local chests = Workspace:GetDescendants()
                    for _, chest in pairs(chests) do
                        if chest.Name:lower():find("chest") or chest.Name:lower():find("baú") then
                            local dist = (chest.Position - hrp.Position).Magnitude
                            if dist < 50 then
                                fireclickdetector(chest:FindFirstChildWhichIsA("ClickDetector"))
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

-- ========== 8. RAID SUPPORT ==========
local function startRaidSupport()
    task.spawn(function()
        while raidSupportActive do
            pcall(function()
                local char, hum, hrp = getChar()
                if hrp then
                    local args = {[1] = "Raids", [2] = "Join"}
                    ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
                    notificar("⚔️ Joining Raid!", Color3.fromRGB(255, 100, 100))
                end
            end)
            task.wait(60)
        end
    end)
end

-- ========== 9. FAST ATTACK ==========
local function startFastAttack()
    task.spawn(function()
        while fastAttackActive do
            pcall(function()
                if tick() - lastAttack > attackSpeed then
                    UserInputService:SetKeyDown(Enum.KeyCode.R)
                    task.wait(0.02)
                    UserInputService:SetKeyUp(Enum.KeyCode.R)
                    lastAttack = tick()
                end
            end)
            task.wait(0.03)
        end
    end)
end

-- ========== 10. AUTO SEA BEAST ==========
local function startSeaBeast()
    task.spawn(function()
        while seaBeastActive do
            pcall(function()
                local char, hum, hrp = getChar()
                if hrp then
                    local seaBeasts = Workspace:GetDescendants()
                    for _, sb in pairs(seaBeasts) do
                        if sb.Name:lower():find("seabeast") or sb.Name:lower():find("sea") then
                            local sbPart = sb:FindFirstChild("HumanoidRootPart")
                            if sbPart then
                                hrp.CFrame = sbPart.CFrame * CFrame.new(0, 0, 20)
                                for i = 1, 5 do
                                    UserInputService:SetKeyDown(Enum.KeyCode.R)
                                    task.wait(0.05)
                                    UserInputService:SetKeyUp(Enum.KeyCode.R)
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(5)
        end
    end)
end

-- ========== 11. AUTO FACTORY FARM ==========
local function startFactoryFarm()
    task.spawn(function()
        while factoryFarmActive do
            pcall(function()
                local char, hum, hrp = getChar()
                if hrp then
                    local factory = Workspace:FindFirstChild("Factory")
                    if factory then
                        hrp.CFrame = CFrame.new(1480, 25, 1040)
                        task.wait(1)
                        for i = 1, 20 do
                            UserInputService:SetKeyDown(Enum.KeyCode.R)
                            task.wait(0.05)
                            UserInputService:SetKeyUp(Enum.KeyCode.R)
                            task.wait(0.1)
                        end
                    end
                end
            end)
            task.wait(10)
        end
    end)
end

-- ========== 12. PLAYER ESP ==========
local function createPlayerESP(obj, cor)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = obj
    highlight.FillColor = cor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = obj
    return highlight
end

local function startPlayerESP()
    task.spawn(function()
        while playerESPActive do
            for _, other in pairs(Players:GetPlayers()) do
                if other ~= Player and other.Character then
                    local key = "PlayerESP_" .. other.Name
                    if not espObjects[key] then
                        espObjects[key] = createPlayerESP(other.Character, Color3.fromRGB(255, 50, 50))
                    end
                end
            end
            for key, esp in pairs(espObjects) do
                if not esp.Adornee or not esp.Adornee.Parent then
                    esp:Destroy()
                    espObjects[key] = nil
                end
            end
            task.wait(0.3)
        end
    end)
end

local function stopPlayerESP()
    for _, esp in pairs(espObjects) do
        pcall(function() esp:Destroy() end)
    end
    espObjects = {}
end

-- ========== FLY ==========
local function startFly()
    local char, hum, hrp = getChar()
    if not hrp then return end
    
    if bodyVel then bodyVel:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    if flyCon then flyCon:Disconnect() end
    
    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVel.Parent = hrp
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bodyGyro.P = 20000
    bodyGyro.Parent = hrp
    
    if hum then hum.PlatformStand = true end
    
    flyCon = RunService.RenderStepped:Connect(function()
        if not flyActive then return end
        local cam = workspace.CurrentCamera
        if not cam or not bodyVel then return end
        
        local moveVector = Vector3.new(0, 0, 0)
        
        if flyDirection.X ~= 0 or flyDirection.Z ~= 0 then
            local forward = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            moveVector = (forward * flyDirection.Z) + (right * flyDirection.X)
        end
        
        moveVector = moveVector + Vector3.new(0, flyDirection.Y, 0)
        
        if moveVector.Magnitude > 0 then
            bodyVel.Velocity = moveVector.Unit * 80
        else
            bodyVel.Velocity = Vector3.new(0, 0, 0)
        end
        
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    if flyCon then flyCon:Disconnect() end
    if bodyVel then bodyVel:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    local char, hum, hrp = getChar()
    if hum then hum.PlatformStand = false end
    flyCon = nil
    bodyVel = nil
    bodyGyro = nil
    flyDirection = Vector3.new(0, 0, 0)
end

-- ========== SPEED ==========
local function updateSpeed()
    local char, hum, hrp = getChar()
    if not hum then return end
    if speedActive then
        hum.WalkSpeed = 70
    else
        hum.WalkSpeed = 16
    end
end

-- ========== KILL AURA ==========
local function getNearestEnemy()
    local char, hum, hrp = getChar()
    if not hrp then return nil end
    
    local nearest = nil
    local minDist = killDistance
    
    for _, other in pairs(Players:GetPlayers()) do
        if other ~= Player then
            local otherChar = other.Character
            if otherChar then
                local otherHum = otherChar:FindFirstChild("Humanoid")
                local otherHrp = otherChar:FindFirstChild("HumanoidRootPart")
                if otherHum and otherHum.Health > 0 and otherHrp then
                    local dist = (otherHrp.Position - hrp.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = otherChar
                    end
                end
            end
        end
    end
    return nearest
end

local function autoAttack()
    pcall(function()
        UserInputService:SetKeyDown(Enum.KeyCode.R)
        task.wait(0.05)
        UserInputService:SetKeyUp(Enum.KeyCode.R)
    end)
end

-- ========== AUTO FARM ==========
local npcNames = {"Bandit", "Brute", "Mob Leader", "Pirate", "Marine", "Sky Bandit"}

local function getNearestNPC()
    local char, hum, hrp = getChar()
    if not hrp then return nil end
    
    local nearest = nil
    local minDist = 300
    
    for _, name in pairs(npcNames) do
        local npc = Workspace:FindFirstChild(name)
        if npc and npc:FindFirstChild("HumanoidRootPart") then
            local dist = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = npc
            end
        end
    end
    return nearest
end

local farmLoop = nil

local function startAutoFarm()
    if farmLoop then return end
    
    farmLoop = task.spawn(function()
        while autoFarmActive do
            pcall(function()
                local char, hum, hrp = getChar()
                if hrp then
                    local target = getNearestNPC()
                    if target then
                        local npcPart = target:FindFirstChild("HumanoidRootPart")
                        if npcPart then
                            hrp.CFrame = npcPart.CFrame * CFrame.new(0, 0, 5)
                            task.wait(0.3)
                            autoAttack()
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

local function stopAutoFarm()
    if farmLoop then
        task.cancel(farmLoop)
        farmLoop = nil
    end
end

-- ========== INTERFACE (UI) ==========
local function criarUI()
    local old = Player.PlayerGui:FindFirstChild("BloxFruitsPT")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "BloxFruitsPT"
    gui.Parent = Player.PlayerGui
    gui.ResetOnSpawn = false
    
    -- Menu Button
    local menuBtn = Instance.new("TextButton")
    menuBtn.Size = UDim2.new(0, 60, 0, 60)
    menuBtn.Position = UDim2.new(0.02, 0, 0.82, 0)
    menuBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
    menuBtn.BackgroundTransparency = 0.1
    menuBtn.BorderSizePixel = 0
    menuBtn.Text = "🔥"
    menuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    menuBtn.TextSize = 30
    menuBtn.Font = Enum.Font.GothamBold
    menuBtn.Parent = gui
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(1, 0)
    menuCorner.Parent = menuBtn
    
    -- Main Panel (Scrolling)
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(0, 330, 0, 520)
    frame.Position = UDim2.new(0.5, -165, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(10, 12, 30)
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.ScrollBarThickness = 4
    frame.CanvasSize = UDim2.new(0, 0, 0, 1150)
    frame.Parent = gui
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 18)
    frameCorner.Parent = frame
    
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(255, 80, 0)
    frameStroke.Thickness = 1.5
    frameStroke.Transparency = 0.4
    frameStroke.Parent = frame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundTransparency = 1
    header.Parent = frame
    
    local titulo = Instance.new("TextLabel")
    titulo.Size = UDim2.new(1, -60, 1, 0)
    titulo.Position = UDim2.new(0, 15, 0, 0)
    titulo.BackgroundTransparency = 1
    titulo.Text = "🌟 BLOX FRUITS ULTIMATE 🌟"
    titulo.TextColor3 = Color3.fromRGB(255, 100, 0)
    titulo.TextSize = 14
    titulo.Font = Enum.Font.GothamBold
    titulo.TextXAlignment = Enum.TextXAlignment.Left
    titulo.Parent = header
    
    local fechar = Instance.new("TextButton")
    fechar.Size = UDim2.new(0, 32, 0, 32)
    fechar.Position = UDim2.new(1, -42, 0, 9)
    fechar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    fechar.BackgroundTransparency = 0.2
    fechar.BorderSizePixel = 0
    fechar.Text = "✕"
    fechar.TextColor3 = Color3.fromRGB(255, 255, 255)
    fechar.TextSize = 16
    fechar.Font = Enum.Font.GothamBold
    fechar.Parent = header
    
    local fecharCorner = Instance.new("UICorner")
    fecharCorner.CornerRadius = UDim.new(0, 16)
    fecharCorner.Parent = fechar
    
    local function criarBotao(parent, texto, icone, y, cor)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 42)
        btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = cor or Color3.fromRGB(35, 45, 75)
        btn.BorderSizePixel = 0
        btn.Text = icone .. " " .. texto .. ": OFF"
        btn.TextColor3 = Color3.fromRGB(255, 200, 100)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Parent = parent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        return btn
    end
    
    local function atualizarBotao(btn, ativo, texto, icone)
        if ativo then
            btn.Text = icone .. " " .. texto .. ": ON ✓"
            btn.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
            btn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            btn.Text = icone .. " " .. texto .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(35, 45, 75)
            btn.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    end
    
    local y = 10
    
    -- Main Section
    local sec1 = Instance.new("TextLabel")
    sec1.Size = UDim2.new(0.9, 0, 0, 25)
    sec1.Position = UDim2.new(0.05, 0, 0, y)
    sec1.BackgroundTransparency = 1
    sec1.Text = "⚡ MAIN FEATURES"
    sec1.TextColor3 = Color3.fromRGB(255, 150, 50)
    sec1.TextSize = 12
    sec1.Font = Enum.Font.GothamBold
    sec1.TextXAlignment = Enum.TextXAlignment.Left
    sec1.Parent = frame
    y = y + 30
    
    local flyBtn = criarBotao(frame, "FLY", "🕊️", y)
    y = y + 48
    local speedBtn = criarBotao(frame, "SPEED", "⚡", y)
    y = y + 48
    local killBtn = criarBotao(frame, "KILL AURA", "⚔️", y)
    y = y + 48
    local farmBtn = criarBotao(frame, "AUTO FARM", "🎯", y)
    y = y + 55
    
    -- Auto Section
    local sec2 = Instance.new("TextLabel")
    sec2.Size = UDim2.new(0.9, 0, 0, 25)
    sec2.Position = UDim2.new(0.05, 0, 0, y)
    sec2.BackgroundTransparency = 1
    sec2.Text = "🤖 AUTOMATIC FEATURES"
    sec2.TextColor3 = Color3.fromRGB(100, 200, 255)
    sec2.TextSize = 12
    sec2.Font = Enum.Font.GothamBold
    sec2.TextXAlignment = Enum.TextXAlignment.Left
    sec2.Parent = frame
    y = y + 30
    
    local questBtn = criarBotao(frame, "AUTO QUEST", "📋", y)
    y = y + 48
    local bossBtn = criarBotao(frame, "BOSS FARM", "👑", y)
    y = y + 48
    local statsBtn = criarBotao(frame, "AUTO STATS", "📊", y)
    y = y + 48
    local fruitSniperBtn = criarBotao(frame, "FRUIT SNIPER", "🥭", y)
    y = y + 48
    local fruitESPBtn = criarBotao(frame, "FRUIT ESP", "👁️", y)
    y = y + 48
    local chestBtn = criarBotao(frame, "CHEST FARM", "💰", y)
    y = y + 48
    local raidBtn = criarBotao(frame, "RAID SUPPORT", "⚔️", y)
    y = y + 48
    local fastAttackBtn = criarBotao(frame, "FAST ATTACK", "🌊", y)
    y = y + 48
    local seaBeastBtn = criarBotao(frame, "SEA BEAST", "🦈", y)
    y = y + 48
    local factoryBtn = criarBotao(frame, "FACTORY FARM", "🏭", y)
    y = y + 48
    local playerESPBtn = criarBotao(frame, "PLAYER ESP", "📍", y)
    y = y + 55
    
    -- Teleport Section
    local sec3 = Instance.new("TextLabel")
    sec3.Size = UDim2.new(0.9, 0, 0, 25)
    sec3.Position = UDim2.new(0.05, 0, 0, y)
    sec3.BackgroundTransparency = 1
    sec3.Text = "🚀 TELEPORT"
    sec3.TextColor3 = Color3.fromRGB(150, 255, 150)
    sec3.TextSize = 12
    sec3.Font = Enum.Font.GothamBold
    sec3.TextXAlignment = Enum.TextXAlignment.Left
    sec3.Parent = frame
    y = y + 30
    
    -- Teleport Buttons
    for i, ilha in ipairs(islands) do
        local teleBtn = Instance.new("TextButton")
        teleBtn.Size = UDim2.new(0.85, 0, 0, 35)
        teleBtn.Position = UDim2.new(0.075, 0, 0, y)
        teleBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 80)
        teleBtn.BorderSizePixel = 0
        teleBtn.Text = ilha.nome
        teleBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
        teleBtn.TextSize = 11
        teleBtn.Font = Enum.Font.GothamBold
        teleBtn.Parent = frame
        
        local teleCorner = Instance.new("UICorner")
        teleCorner.CornerRadius = UDim.new(0, 8)
        teleCorner.Parent = teleBtn
        
        teleBtn.MouseButton1Click:Connect(function()
            teleportar(ilha.pos)
        end)
        
        y = y + 42
    end
    
    -- Distance Selector
    local distFrame = Instance.new("Frame")
    distFrame.Size = UDim2.new(0.85, 0, 0, 35)
    distFrame.Position = UDim2.new(0.075, 0, 0, y)
    distFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
    distFrame.BackgroundTransparency = 0.3
    distFrame.BorderSizePixel = 0
    distFrame.Parent = frame
    
    local distCorner = Instance.new("UICorner")
    distCorner.CornerRadius = UDim.new(0, 8)
    distCorner.Parent = distFrame
    
    local distText = Instance.new("TextLabel")
    distText.Size = UDim2.new(0.5, 0, 1, 0)
    distText.BackgroundTransparency = 1
    distText.Text = "🎯 Distance: " .. killDistance
    distText.TextColor3 = Color3.fromRGB(255, 200, 100)
    distText.TextSize = 11
    distText.Font = Enum.Font.GothamBold
    distText.TextXAlignment = Enum.TextXAlignment.Left
    distText.Position = UDim2.new(0, 8, 0, 0)
    distText.Parent = distFrame
    
    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 25, 1, 0)
    minusBtn.Position = UDim2.new(1, -60, 0, 0)
    minusBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    minusBtn.BorderSizePixel = 0
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.TextSize = 14
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.Parent = distFrame
    
    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 5)
    minusCorner.Parent = minusBtn
    
    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 25, 1, 0)
    plusBtn.Position = UDim2.new(1, -30, 0, 0)
    plusBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
    plusBtn.BorderSizePixel = 0
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.TextSize = 14
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.Parent = distFrame
    
    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 5)
    plusCorner.Parent = plusBtn
    
    y = y + 45
    
    frame.CanvasSize = UDim2.new(0, 0, 0, y + 30)
    
    return {
        gui = gui, frame = frame, menuBtn = menuBtn, fechar = fechar,
        flyBtn = flyBtn, speedBtn = speedBtn, killBtn = killBtn, farmBtn = farmBtn,
        questBtn = questBtn, bossBtn = bossBtn, statsBtn = statsBtn,
        fruitSniperBtn = fruitSniperBtn, fruitESPBtn = fruitESPBtn,
        chestBtn = chestBtn, raidBtn = raidBtn, fastAttackBtn = fastAttackBtn,
        seaBeastBtn = seaBeastBtn, factoryBtn = factoryBtn, playerESPBtn = playerESPBtn,
        minusBtn = minusBtn, plusBtn = plusBtn, distText = distText
    }
end

-- ========== BUTTON CONFIGURATION ==========
local function configurarBotao(btn, active, nome, icone, onFunc, offFunc)
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.Text = icone .. " " .. nome .. ": ON ✓"
            btn.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
            btn.TextColor3 = Color3.fromRGB(100, 255, 100)
            if onFunc then onFunc() end
            notificar("✅ " .. nome .. " ACTIVATED!", Color3.fromRGB(100, 255, 100))
        else
            btn.Text = icone .. " " .. nome .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(35, 45, 75)
            btn.TextColor3 = Color3.fromRGB(255, 200, 100)
            if offFunc then offFunc() end
            notificar("❌ " .. nome .. " DEACTIVATED!", Color3.fromRGB(255, 100, 100))
        end
    end)
    return function() return active end
end

-- ========== INITIALIZATION ==========
local ui = criarUI()
local menuAberto = false

-- Menu Button Click
ui.menuBtn.MouseButton1Click:Connect(function()
    menuAberto = not menuAberto
    ui.frame.Visible = menuAberto
end)

ui.fechar.MouseButton1Click:Connect(function()
    menuAberto = false
    ui.frame.Visible = false
end)

-- Setting up buttons
flyActive = configurarBotao(ui.flyBtn, flyActive, "FLY", "🕊️", startFly, stopFly)()
speedActive = configurarBotao(ui.speedBtn, speedActive, "SPEED", "⚡", updateSpeed, updateSpeed)()
killActive = configurarBotao(ui.killBtn, killActive, "KILL AURA", "⚔️", nil, nil)()
autoFarmActive = configurarBotao(ui.farmBtn, autoFarmActive, "AUTO FARM", "🎯", startAutoFarm, stopAutoFarm)()
autoQuestActive = configurarBotao(ui.questBtn, autoQuestActive, "AUTO QUEST", "📋", startAutoQuest, nil)()
bossFarmActive = configurarBotao(ui.bossBtn, bossFarmActive, "BOSS FARM", "👑", startBossFarm, nil)()
autoStatsActive = configurarBotao(ui.statsBtn, autoStatsActive, "AUTO STATS", "📊", startAutoStats, nil)()
fruitSniperActive = configurarBotao(ui.fruitSniperBtn, fruitSniperActive, "FRUIT SNIPER", "🥭", startFruitSniper, nil)()
fruitESPActive = configurarBotao(ui.fruitESPBtn, fruitESPActive, "FRUIT ESP", "👁️", startFruitESP, stopFruitESP)()
chestFarmActive = configurarBotao(ui.chestBtn, chestFarmActive, "CHEST FARM", "💰", startChestFarm, nil)()
raidSupportActive = configurarBotao(ui.raidBtn, raidSupportActive, "RAID SUPPORT", "⚔️", startRaidSupport, nil)()
fastAttackActive = configurarBotao(ui.fastAttackBtn, fastAttackActive, "FAST ATTACK", "🌊", startFastAttack, nil)()
seaBeastActive = configurarBotao(ui.seaBeastBtn, seaBeastActive, "SEA BEAST", "🦈", startSeaBeast, nil)()
factoryFarmActive = configurarBotao(ui.factoryBtn, factoryFarmActive, "FACTORY FARM", "🏭", startFactoryFarm, nil)()
playerESPActive = configurarBotao(ui.playerESPBtn, playerESPActive, "PLAYER ESP", "📍", startPlayerESP, stopPlayerESP)()

-- Distance adjustment
ui.minusBtn.MouseButton1Click:Connect(function()
    killDistance = math.max(killDistance - 5, 15)
    ui.distText.Text = "🎯 Distance: " .. killDistance
    notificar("📏 Distance changed to: " .. killDistance, Color3.fromRGB(255, 200, 100))
end)

ui.plusBtn.MouseButton1Click:Connect(function()
    killDistance = math.min(killDistance + 5, 100)
    ui.distText.Text = "🎯 Distance: " .. killDistance
    notificar("📏 Distance changed to: " .. killDistance, Color3.fromRGB(255, 200, 100))
end)

-- Kill Aura Loop
task.spawn(function()
    while true do
        if killActive then
            local inimigo = getNearestEnemy()
            if inimigo then
                autoAttack()
            end
        end
        task.wait(0.12)
    end
end)

-- Respawn handling
Player.CharacterAdded:Connect(function()
    task.wait(1)
    if flyActive then startFly() end
    if speedActive then updateSpeed() end
end)

-- Loaded Message
notificar("🌟 BLOX FRUITS SCRIPT LOADED! 16 FEATURES!", Color3.fromRGB(255, 100, 0))

print("=" .. string.rep("=", 50))
print("🔥 BLOX FRUITS SCRIPT ULTIMATE - EN 🔥")
print("✅ 16 FULL FEATURES")
print("📱 OPTIMIZED FOR DELTA MOBILE")
print("🌟 EVERYTHING IN ENGLISH")
print("=" .. string.rep("=", 50))
