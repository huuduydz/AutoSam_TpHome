--[[
    🌟 COMPASS FARM PRO MAX + FPS BOOST
    ✅ Tích hợp: Auto Sam, Auto Drop, Anti-AFK, FPS Boost (Xóa Texture)
    🛠️ By: HuuDuy
]]

-- === 1. KHỞI TẠO DỊCH VỤ ===
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace:WaitForChild("Terrain")

local player = Players.LocalPlayer

-- === 2. BIẾN CẤU HÌNH ===
local isAutoClaiming = false
local isAutoDropping = false
local isFpsBoosted = false -- Trạng thái FPS Boost
local TOOL_NAME = "Compass"
local startTime = tick()

-- === 3. XÂY DỰNG GIAO DIỆN (GUI) ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CompassFarmProMax"
screenGui.ResetOnSpawn = false

if pcall(function() return CoreGui end) then
    screenGui.Parent = CoreGui
else
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Khung chính
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 330) -- Tăng chiều cao để thêm nút
mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner"); uiCorner.CornerRadius = UDim.new(0, 10); uiCorner.Parent = mainFrame

-- Tiêu đề
local title = Instance.new("TextLabel")
title.Text = "🛡️ AUTO Claim&Drop"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 170, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- === PHẦN 1: THÔNG SỐ ===
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(0.9, 0, 0, 85)
statsFrame.Position = UDim2.new(0.05, 0, 0.12, 0)
statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
statsFrame.Parent = mainFrame
local sfCorner = Instance.new("UICorner"); sfCorner.CornerRadius = UDim.new(0, 6); sfCorner.Parent = statsFrame

local timerLabel = Instance.new("TextLabel", statsFrame)
timerLabel.Size = UDim2.new(1, -10, 0, 25)
timerLabel.Position = UDim2.new(0, 10, 0, 5)
timerLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
timerLabel.BackgroundTransparency = 1
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.Font = Enum.Font.SourceSansBold
timerLabel.TextSize = 14
timerLabel.Text = "⏲️ Time: 00:00"

local fpsLabel = Instance.new("TextLabel", statsFrame)
fpsLabel.Size = UDim2.new(1, -10, 0, 25)
fpsLabel.Position = UDim2.new(0, 10, 0, 30)
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.TextSize = 14
fpsLabel.Text = "🎮 FPS: ..."

local pingLabel = Instance.new("TextLabel", statsFrame)
pingLabel.Size = UDim2.new(1, -10, 0, 25)
pingLabel.Position = UDim2.new(0, 10, 0, 55)
pingLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
pingLabel.BackgroundTransparency = 1
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.Font = Enum.Font.SourceSansBold
pingLabel.TextSize = 14
pingLabel.Text = "📶 Ping: ..."

-- === PHẦN 2: NÚT ĐIỀU KHIỂN ===

-- Nút Auto Claim
local btnClaim = Instance.new("TextButton")
btnClaim.Size = UDim2.new(0.9, 0, 0, 40)
btnClaim.Position = UDim2.new(0.05, 0, 0.45, 0)
btnClaim.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
btnClaim.Text = "AUTO SAM: TẮT"
btnClaim.TextColor3 = Color3.fromRGB(255, 255, 255)
btnClaim.Font = Enum.Font.GothamBold
btnClaim.TextSize = 14
btnClaim.Parent = mainFrame
local c1 = Instance.new("UICorner"); c1.CornerRadius = UDim.new(0, 6); c1.Parent = btnClaim

-- Nút Auto Drop
local btnDrop = Instance.new("TextButton")
btnDrop.Size = UDim2.new(0.9, 0, 0, 40)
btnDrop.Position = UDim2.new(0.05, 0, 0.60, 0)
btnDrop.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
btnDrop.Text = "AUTO DROP: TẮT"
btnDrop.TextColor3 = Color3.fromRGB(255, 255, 255)
btnDrop.Font = Enum.Font.GothamBold
btnDrop.TextSize = 14
btnDrop.Parent = mainFrame
local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0, 6); c2.Parent = btnDrop

-- Nút FPS Boost (MỚI)
local btnFps = Instance.new("TextButton")
btnFps.Size = UDim2.new(0.9, 0, 0, 40)
btnFps.Position = UDim2.new(0.05, 0, 0.75, 0)
btnFps.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
btnFps.Text = "FPS BOOST: TẮT"
btnFps.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFps.Font = Enum.Font.GothamBold
btnFps.TextSize = 14
btnFps.Parent = mainFrame
local c3 = Instance.new("UICorner"); c3.CornerRadius = UDim.new(0, 6); c3.Parent = btnFps

-- === 4. LOGIC CHỨC NĂNG ===

-- A. HÀM TỐI ƯU ĐỒ HỌA (FPS BOOST)
local function activateFpsBoost()
    print("🚀 Kích hoạt chế độ Potato Mode...")
    
    -- 1. Lighting
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 2
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") then v.Enabled = false end
    end

    -- 2. Terrain
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0

    -- 3. Quét Map
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
            if obj:IsA("MeshPart") then obj.TextureID = "" end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("SpecialMesh") then
            obj.TextureId = "" 
        end
    end
    
    -- 4. Auto Clean vật thể mới
    Workspace.DescendantAdded:Connect(function(obj)
        if isFpsBoosted then
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            end
        end
    end)
    print("✅ Đã xóa texture!")
end

-- B. Anti-AFK
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- C. Auto Sam & Drop logic
local function fireSamRemotes()
    pcall(function()
        if Workspace:FindFirstChild("GlobalReference") and Workspace.GlobalReference:FindFirstChild("SamQuestPrompt") then
            Workspace.GlobalReference.SamQuestPrompt:FireServer("Claim1")
        end
    end)
    pcall(function()
        if ReplicatedStorage:FindFirstChild("Connections") and ReplicatedStorage.Connections:FindFirstChild("Claim_Sam") then
            ReplicatedStorage.Connections.Claim_Sam:FireServer("Claim1")
        end
    end)
end

local function dropCompass()
    local char = player.Character
    local backpack = player.Backpack
    local humanoid = char and char:FindFirstChild("Humanoid")
    if not humanoid then return end

    local toolInBag = backpack:FindFirstChild(TOOL_NAME)
    if toolInBag then
        humanoid:EquipTool(toolInBag)
        task.wait(0.2)
    end

    if char:FindFirstChild(TOOL_NAME) then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
    end
end

-- D. Cập nhật Stats
task.spawn(function()
    local fpsCounter = 0
    local lastTick = tick()
    local currentFps = 60
    
    RunService.RenderStepped:Connect(function()
        fpsCounter = fpsCounter + 1
        if tick() - lastTick >= 1 then
            currentFps = fpsCounter
            fpsCounter = 0
            lastTick = tick()
        end
    end)

    while true do
        local elapsed = math.floor(tick() - startTime)
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60
        timerLabel.Text = string.format("⏲️ Treo máy: %02d:%02d:%02d", hours, minutes, seconds)
        
        local pingVal = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
        pingLabel.Text = "📶 Ping: " .. pingVal
        fpsLabel.Text = "🎮 FPS: " .. tostring(currentFps)
        task.wait(1)
    end
end)

-- === 5. XỬ LÝ SỰ KIỆN NÚT BẤM ===

-- Loop Auto
task.spawn(function()
    while true do
        if isAutoClaiming then fireSamRemotes() end
        task.wait(1.5)
    end
end)

task.spawn(function()
    while true do
        if isAutoDropping then dropCompass() end
        task.wait(0.5)
    end
end)

-- Click Events
btnClaim.MouseButton1Click:Connect(function()
    isAutoClaiming = not isAutoClaiming
    if isAutoClaiming then
        btnClaim.Text = "ĐANG LẤY SAM..."
        btnClaim.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    else
        btnClaim.Text = "AUTO SAM: TẮT"
        btnClaim.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
end)

btnDrop.MouseButton1Click:Connect(function()
    isAutoDropping = not isAutoDropping
    if isAutoDropping then
        btnDrop.Text = "ĐANG DROP..."
        btnDrop.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    else
        btnDrop.Text = "AUTO DROP: TẮT"
        btnDrop.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
end)

btnFps.MouseButton1Click:Connect(function()
    if not isFpsBoosted then
        isFpsBoosted = true
        activateFpsBoost() -- Chạy hàm xóa texture
        btnFps.Text = "FPS BOOST: BẬT"
        btnFps.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        -- Lưu ý: Không có nút tắt để hồi phục đồ họa vì phải rejoin mới hết
    end
end)

print("✅ COMPASS FARM PRO MAX ĐÃ TẢI!")
