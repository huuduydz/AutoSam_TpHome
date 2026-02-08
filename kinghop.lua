-- Script tự động ẩn bảng báo lỗi (Server Full, Disconnect...) mà không Rejoin
local CoreGui = game:GetService("CoreGui")

task.spawn(function()
    while true do
        task.wait(0.5) -- Kiểm tra mỗi 0.5 giây
        pcall(function()
            local promptOverlay = CoreGui:FindFirstChild("RobloxPromptGui")
            if promptOverlay then
                local overlay = promptOverlay:FindFirstChild("promptOverlay")
                if overlay then
                    local errorPrompt = overlay:FindFirstChild("ErrorPrompt")
                    
                    -- Nếu thấy bảng lỗi hiện lên -> Tắt nó đi
                    if errorPrompt and errorPrompt.Visible then
                        errorPrompt.Visible = false
                        
                        -- Tắt luôn hiệu ứng làm mờ màn hình (Blur) nếu có
                        local blur = game:GetService("Lighting"):FindFirstChild("RobloxGuiBlur")
                        if blur then blur.Enabled = false end
                    end
                end
            end
        end)
    end
end)
-- [[ SAFE BOOT AUTO.EXE: CHỐNG TREO TUYỆT ĐỐI ]] --
if not game:IsLoaded() then
    local notLoadedTime = tick()
    repeat task.wait() 
    until game:IsLoaded() or (tick() - notLoadedTime > 10) -- Chỉ đợi tối đa 10s để game load
end

local Players = game:GetService("Players")
local lplr = Players.LocalPlayer or Players.PlayerAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- 1. CHỐNG AFK NGAY LẬP TỨC (Để treo không bị kick)
lplr.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- 2. HÀM XÓA LOADING & VÀO GAME (CHẠY NGẦM)
task.spawn(function()
    local attempts = 0
    while attempts < 20 do -- Thử liên tục trong 10 giây
        attempts = attempts + 1
        
        -- A. Xóa GUI Loading ảo
        local gui = lplr:FindFirstChild("PlayerGui")
        if gui then
            local loading = gui:FindFirstChild("LoadingGUI") or gui:FindFirstChild("Loading")
            if loading then 
                loading:Destroy() 
                print("🗑️ Đã xóa màn hình Loading!")
            end
        end

        -- B. Spam Lệnh Vào Game (EnterTheGame)
        if ReplicatedStorage:FindFirstChild("Chest") then
             pcall(function()
                ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("EnterTheGame", {})
             end)
        end
        
        -- C. Chọn Map Hard luôn cho đỡ hỏi
        if ReplicatedStorage:FindFirstChild("ChooseMapRemote") then
             ReplicatedStorage.ChooseMapRemote:FireServer("Hard")
        end

        task.wait(0.5)
    end
end)

-- 3. CHECK DỮ LIỆU "MỀM" (KHÔNG TREO)
print("⏳ Đang kiểm tra dữ liệu...")
local waitTime = 0
repeat
    task.wait(0.5)
    waitTime = waitTime + 0.5
    
    -- Điều kiện thoát sớm:
    -- 1. Thấy Level > 0 (Nghĩa là data đã về)
    -- 2. Hoặc thấy Beli (Tiền) xuất hiện
    -- 3. Hoặc đã đợi quá 15 giây (Timeout)
    
    local stats = lplr:FindFirstChild("PlayerStats")
    local ready = false
    
    if stats then
        if stats:FindFirstChild("lvl") and stats.lvl.Value > 0 then ready = true end
        if stats:FindFirstChild("beli") then ready = true end
    end
    
    if ready then 
        print("✅ Dữ liệu đã nhận diện xong!")
        break 
    end
    
    if waitTime > 15 then
        warn("⚠️ Quá thời gian chờ (15s) -> Kích hoạt chế độ Cưỡng Ép Chạy!")
        break -- Phá vỡ vòng lặp để chạy script luôn
    end
until false -- Vòng lặp này được kiểm soát bằng break ở trên

print("🚀 Script KingHop bắt đầu hoạt động...")
-- [[ KẾT THÚC ĐOẠN FIX ]] --

-- ... (Dán phần code phía sau của bạn ở đây) ...
-- ============================================
-- King Legacy Kaitun Script - Optimized Version
-- Fix: Auto.exe load detection, Per-account hop counter, Safe teleport after chest collection
-- ============================================

print("DuyDZ - Optimized Version with Fixes")

-- ============================================
-- SERVICES & VARIABLES
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local lplr = Players.LocalPlayer
local name = lplr.Name
local dname = lplr.DisplayName
local workspace = game.Workspace 
local gravity = workspace.Gravity 
local executor = identifyexecutor() or "???"
local userid = lplr.UserId
local FPS = 0

-- ============================================
-- WAIT FOR PLAYER TO FULLY LOAD (FIX AUTO.EXE)
-- ============================================
local function waitForPlayerLoad()
    print("⏳ Đang chờ player load...")
    
    -- Wait for character
    if not lplr.Character then
        lplr.CharacterAdded:Wait()
    end
    
    local character = lplr.Character
    
    -- Wait for essential parts
    character:WaitForChild("HumanoidRootPart", 30)
    character:WaitForChild("Humanoid", 30)
    
    -- Wait for PlayerGui
    lplr:WaitForChild("PlayerGui", 30)
    
    -- Wait for PlayerStats
    lplr:WaitForChild("PlayerStats", 30)
    
    -- Wait for DataLoaded
    local maxWaitTime = 30
    local startTime = tick()
    while not lplr:FindFirstChild("DataLoaded") and (tick() - startTime) < maxWaitTime do
        task.wait(0.5)
    end
    
    -- Additional safety wait
    task.wait(3)
    
    print("✅ Player đã load đầy đủ!")
    return true
end

-- Call this before running main script
local playerLoaded = waitForPlayerLoad()

if not playerLoaded then
    warn("⚠️ Player không load đầy đủ, đang rejoin...")
    task.wait(2)
    TeleportService:Teleport(game.PlaceId, lplr)
    return
end

-- ============================================
-- GETGENV SETTINGS (Tối ưu hóa)
-- ============================================
getgenv().KaitunSettings = getgenv().KaitunSettings or {}

-- Merge default settings with existing settings
local defaultSettings = {
    -- Auto Features
    start = true,
    autoskillsea = true,
    autoskhd = true,
    autoskhdhop = true,
    autocat = true,
    autobuy = true,
    autoskhd = true,
    
    -- Shop Settings
    chonkey = "Copper Key",
    slkey = 10,
    
    -- Teleport & Hop Settings
    HopThreshold = 70,
    maxDistanceFromBoss = 190,
    docao = 50,
    safeZoneAfterChest = true, -- NEW: Tele về safe zone sau khi lụm chest
    safeZoneWaitTime = 2, -- NEW: Thời gian chờ ở safe zone trước khi hop
    
    -- Effects & Visual
    autoDeleteEffects = true,
    eff = true,
    giaodien = false,
    fpsbut = true,
    
    -- Advanced Settings
    hub = 0.98,
    alime = 0.7,
    bankin = 100,
    KL = 1,
    
    -- Webhook
    Webhook_URL2 = "https://discord.com/api/webhooks/1467903010062729438/S151mUICYjrXfrLE9oZFezgkEbsvIeHZSzvt1bevS0vKDmFxMe9a9M9fd2UqMTV8Oset",
    
    -- Other Features
    AutoRejoin = false,
    autoWhitelist = false,
    autoDodgeEnabled = true,
    autoTeleport = false,
    dropfruit = false,
    teleraid = false,
    opeskill = true,
    kioru = true,
    jobId = "",
}

-- Apply defaults for missing keys
for k, v in pairs(defaultSettings) do
    if getgenv().KaitunSettings[k] == nil then
        getgenv().KaitunSettings[k] = v
    end
end

local Settings = getgenv().KaitunSettings

-- ============================================
-- HỆ THỐNG ĐẾM HOP (HOP COUNTER - TABLE VERSION)
-- ============================================
local HopTable = {} -- Đặt tên là HopTable thay vì T cho rõ nghĩa
local hopFile = "HopHistory_" .. tostring(userid) .. ".json" -- File riêng theo ID

local function SaveHops()
    if writefile then
        -- Lưu dạng JSON để an toàn
        writefile(hopFile, HttpService:JSONEncode(HopTable))
    end
end

local function LoadHops()
    if isfile(hopFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(hopFile))
        end)
        if success and type(data) == "table" then
            HopTable = data
        else
            HopTable = {}
        end
    else
        HopTable = {}
    end
end

-- Load dữ liệu ngay khi chạy script
LoadHops()

--[[ 
    CODE MẪU ĐẾM SỐ LẦN HOP:
    
    T = {}          -- Khởi tạo table rỗng
    Load()          -- Load dữ liệu từ file
    
    print("Số sever hop : "..#T)    -- In ra số lần đã hop (#T là độ dài của table)
    table.insert(T, 1)               -- Thêm 1 vào table (đánh dấu hop mới)
    Save()                           -- Lưu lại file
    
    CÁCH SỬ DỤNG TRONG SCRIPT NÀY:
    - HopTable = table chứa lịch sử hop
    - LoadHops() = hàm load dữ liệu
    - SaveHops() = hàm lưu dữ liệu
    - #HopTable = số lần đã hop
    - table.insert(HopTable, os.time()) = thêm thời gian hop mới
]]

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function formatNumber(value)
    if value >= 1e9 then
        return string.format("%.1fB", value / 1e9)
    elseif value >= 1e6 then
        return string.format("%.1fM", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.1fK", value / 1e3)
    else
        return tostring(value)
    end
end

local function formatTime(seconds)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    return string.format("%d:%d:%d:%d", days, hours, minutes, seconds)
end

local function getISOTime()
    return os.date("!%Y-%m-%dT%H:%M:%S.000Z", os.time())
end

local function sea(value)
    if value == 3 and game.PlaceId == 15759515082 then
        return true
    elseif value == 1 and game.PlaceId == 4520749081 then
        return true
    elseif value == 2 and game.PlaceId == 6381829480 then
        return true
    elseif value == 4 and game.PlaceId == 5931540094 then
        return true
    else 
        return false
    end
end

-- Reset hop counter function
function resetHopCounter()
    HopTable = {}
    SaveHops()
    th.New("✅ Đã reset hop counter về 0 cho account " .. name .. "!", 3)
    print("Hop counter reset to 0 for account " .. name)
end

-- Get hop statistics
function getHopStats()
    return {
        accountName = name,
        userId = userid,
        totalHops = #HopTable,
        currentServer = game.JobId,
        serverName = serverName or "Unknown",
        uptime = uptime or 0,
        hopCountFile = hopFile
    }
end

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================
local th = {}
local notifications = {}

function th.New(message, duration)
    duration = duration or 3

    local playerGui = lplr:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("NotificationGui") or Instance.new("ScreenGui")
    screenGui.Name = "NotificationGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.35, 0, 0.08, 0)
    frame.Position = UDim2.new(0.325, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 120, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 255, 150))
    }
    gradient.Rotation = 45
    gradient.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, -20)
    textLabel.Position = UDim2.new(0, 10, 0, 10)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = message
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextScaled = true
    textLabel.TextWrapped = true
    textLabel.Parent = frame

    table.insert(notifications, frame)

    local targetPosition = UDim2.new(0.325, 0, 0.1 + ((#notifications - 1) * 0.1), 0)
    local showTween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = targetPosition})
    showTween:Play()

    task.delay(duration, function()
        local fadeTweenText = TweenService:Create(textLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            TextTransparency = 1
        })
        fadeTweenText:Play()

        local fadeTweenFrame = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        })
        fadeTweenFrame:Play()

        fadeTweenFrame.Completed:Connect(function()
            frame:Destroy()
            local index = table.find(notifications, frame)
            if index then
                table.remove(notifications, index)
            end

            for i, notif in ipairs(notifications) do
                local newPosition = UDim2.new(0.325, 0, 0.1 + ((i - 1) * 0.1), 0)
                local moveTween = TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = newPosition})
                moveTween:Play()
            end
        end)
    end)
end

-- ============================================
-- CHARACTER CONTROL
-- ============================================
function stop()
    local root = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
    if root and not root:FindFirstChild("FreezeVelocity") then
        local freeze = Instance.new("BodyVelocity")
        freeze.Name = "FreezeVelocity"
        freeze.Parent = root
        freeze.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        freeze.Velocity = Vector3.new(0, 0, 0)
    end
end

function ngungstop()
    local root = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
    if root and root:FindFirstChild("FreezeVelocity") then
        root.FreezeVelocity:Destroy()
    end
end

-- ============================================
-- SAFE ZONE TELEPORT (NEW FEATURE - ANTI REPORT)
-- ============================================
local function teleportToSafeZone()
    if not Settings.safeZoneAfterChest then return end
    
    local root = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Define safe zones based on sea (Các đảo/vị trí an toàn không bị report)
    local safeZones = {
        -- Sea 2 Safe Zones (PlaceId: 6381829480)
        [6381829480] = {
            Vector3.new(-1082, 127, -2571),  -- Pirate Starter Island
            Vector3.new(3698, 107, 1885),    -- Desert Island
            Vector3.new(-3183, 127, 3296),   -- Frozen Island
            Vector3.new(0, 250, 0),          -- Trên không (tránh player)
        },
        -- Sea 1 Safe Zones (PlaceId: 4520749081)
        [4520749081] = {
            Vector3.new(-2695, 127, 1552),   -- Marine Starter
            Vector3.new(876, 127, -179),     -- Pirate Starter
        }
    }
    
    local currentPlaceId = game.PlaceId
    local zones = safeZones[currentPlaceId]
    
    if zones then
        -- Chọn random một safe zone
        local randomZone = zones[math.random(#zones)]
        
        th.New("🛡️ Đang tele đến nơi an toàn (Anti-Report)...", 2)
        
        -- Tele với pcall để tránh lỗi
        pcall(function()
            root.CFrame = CFrame.new(randomZone)
        end)
        
        -- Wait at safe zone
        task.wait(Settings.safeZoneWaitTime or 2)
        th.New("✅ Đã ở nơi an toàn! Sẵn sàng hop server.", 2)
    else
        -- Fallback: Tele lên cao nếu không có safe zone
        pcall(function()
            local currentPos = root.Position
            root.CFrame = CFrame.new(currentPos.X, currentPos.Y + 300, currentPos.Z)
        end)
        task.wait(Settings.safeZoneWaitTime or 2)
    end
end

-- ============================================
-- FPS COUNTER
-- ============================================
task.spawn(function()
    RunService.RenderStepped:Connect(function()
        FPS = FPS + 1
    end)
    
    while task.wait(1) do
        FPS = 0
    end
end)

-- ============================================
-- AUTO PRESS KEY
-- ============================================
task.spawn(function()
    if game.PlaceId ~= 9821272782 then
        getgenv().Press = function(v)
            return game:GetService("VirtualInputManager"):SendKeyEvent(true, v, false, game)
        end
        while task.wait(500) do
            Press("RightBracket")
        end
    else
        while task.wait(500) do
            keypress(0xDD)
        end
    end
end)

-- ============================================
-- AUTO ENTER GAME (IMPROVED)
-- ============================================
task.spawn(function()
    local startTime = tick()

    while Settings.start do 
        task.wait(2)
        pcall(function()
            local playerGui = lplr:FindFirstChild("PlayerGui")

            if playerGui and playerGui:FindFirstChild("LoadingGUI") then
                local loadingGui = playerGui.LoadingGUI
                if loadingGui:FindFirstChild("Play") then
                    local args = {
                        [1] = "EnterTheGame",
                        [2] = {}
                    }
                    ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("EtcFunction"):InvokeServer(unpack(args))
                    repeat task.wait() until lplr.Character and lplr.Character:FindFirstChild("Humanoid")
                    lplr.Character.Humanoid.Health = 0
                end
            end

            if playerGui and playerGui:FindFirstChild("ChooseMap") then
                ReplicatedStorage:WaitForChild("ChooseMapRemote"):FireServer("Hard")
            end

            if not lplr:FindFirstChild("DataLoaded") and (tick() - startTime >= 15) then
                warn("⚠️ Nhân vật chưa load sau 15 giây, dịch chuyển...")
                TeleportService:Teleport(4520749081, lplr)
                return
            end
        end)
    end
end)

-- ============================================
-- SERVER INFO
-- ============================================
local servers = ReplicatedStorage.Chest.Remotes.Functions.GetServers:InvokeServer()
local currentJobId = game.JobId

local function getServerUptime(servers, currentJobId)
    for _, server in pairs(servers) do
        if type(server) == "table" and server.JobId == currentJobId and server.ServerOsTime then
            local uptime = os.time() - server.ServerOsTime
            return uptime, server.ServerName, server.JobId
        end
    end
    return nil, nil, nil
end

local uptime, serverName, jobId = getServerUptime(servers, currentJobId)

-- ============================================
-- SEA 2 FEATURES
-- ============================================
if sea(2) then

-- Get Boss Root Helper
local function getBossRoot()
    local bossFolders = {workspace.SeaMonster, workspace.GhostMonster}
    local bosses = {"SeaKing", "HydraSeaKing", "Ghost Ship"}

    for _, folder in ipairs(bossFolders) do
        if folder then
            for _, bossName in ipairs(bosses) do
                local boss = folder:FindFirstChild(bossName)
                if boss and boss:FindFirstChild("HumanoidRootPart") then
                    return boss.HumanoidRootPart
                end
            end
        end
    end
    return nil
end

-- ============================================
-- AUTO MELEE SPAM CLICK (HD + SK + GS)
-- ============================================
task.spawn(function()
    while task.wait(0.1) do
        if not Settings.autoskillsea then continue end
        
        pcall(function()
            local skillAction = ReplicatedStorage.Chest.Remotes.Functions.SkillAction
            local skRoot = getBossRoot()
            if not skRoot then return end

            -- Equip melee weapon
            local character = lplr.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local meleeWeapon = lplr.Backpack:FindFirstChild("CombatReplica") or 
                                   character:FindFirstChild("CombatReplica")
                
                if meleeWeapon and meleeWeapon.Parent == lplr.Backpack and humanoid then
                    humanoid:EquipTool(meleeWeapon)
                    task.wait(0.1)
                end
            end

            -- Spam melee click attack
            local args = {
                [1] = "SW_CombatReplica_M1",
                [2] = {["MouseHit"] = skRoot.CFrame, ["Type"] = "Click"}
            }
            
            -- Spam 5 clicks per loop
            for i = 1, 5 do
                skillAction:InvokeServer(unpack(args))
                task.wait(0.05)
            end
        end)
    end
end)

-- ============================================
-- AUTO TELEPORT LOOT (SK + HD + GS)
-- ============================================
task.spawn(function()
    while task.wait(0.5) do
        if not Settings.autoskhd then continue end
        
        pcall(function()
            local workspaceIsland = workspace.Island

            -- Check if any boss is alive
            local bossAlive = getBossRoot() ~= nil

            if not bossAlive then
                -- Look for chest spawners
                local foundSpawner = false

                for i = 1, 4 do
                    local island = workspaceIsland:FindFirstChild("Legacy Island" .. i)
                    if island and island:FindFirstChild("ChestSpawner") then
                        lplr.Character.HumanoidRootPart.CFrame = island.ChestSpawner.CFrame
                        foundSpawner = true
                        break
                    end
                end

                if not foundSpawner then
                    for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
                        local island = workspaceIsland:FindFirstChild(name)
                        if island and island:FindFirstChild("HydraStand") then
                            lplr.Character.HumanoidRootPart.CFrame = island.HydraStand.CFrame
                            foundSpawner = true
                            break
                        end
                    end
                end

                -- Collect chests
                local totalChests = 0
                for i = 1, 5 do
                    if workspace:FindFirstChild("Chest" .. i) then
                        totalChests = totalChests + 1
                    end
                end

                local collected = 0
                for i = 1, 5 do
                    local chest = workspace:FindFirstChild("Chest" .. i)
                    if chest and chest:FindFirstChild("Top") then
                        lplr.Character.HumanoidRootPart.CFrame = chest.Top.CFrame
                        task.wait(0.3)
                        collected = collected + 1
                    end
                end

                -- IMPORTANT: Teleport to safe zone after collecting all chests
                if collected == totalChests and totalChests > 0 then
                    th.New("✅ Đã lụm " .. collected .. "/" .. totalChests .. " rương!", 2)
                    teleportToSafeZone() -- NEW: Tele về nơi an toàn
                    return
                end
            else
                -- Teleport to boss
                local bossRoot = getBossRoot()
                if bossRoot then
                    lplr.Character.HumanoidRootPart.CFrame = bossRoot.CFrame * CFrame.new(0, -10, 100)
                end
            end
        end)
    end
end)

-- ============================================
-- SERVER HOP SYSTEM (IMPROVED WITH PER-ACCOUNT COUNTER)
-- ============================================
local fileName = "teleported_servers_" .. tostring(userid) .. ".txt"
local visitedServers = {}
local serverList = {}

-- Load visited servers
if isfile(fileName) then
    for id in string.gmatch(readfile(fileName), "[^\n]+") do
        visitedServers[id] = true
        table.insert(serverList, id)
    end
end

local function saveTeleportedServers(jobId)
    if not visitedServers[jobId] then
        visitedServers[jobId] = true
        table.insert(serverList, jobId)
        writefile(fileName, table.concat(serverList, "\n"))
    end
end

local function removeOldestServer()
    if #serverList > 0 then
        local removedId = table.remove(serverList, 1)
        visitedServers[removedId] = nil
        writefile(fileName, table.concat(serverList, "\n"))
    end
end

local function getServerUptimeFromData(server)
    return os.time() - server.ServerOsTime
end

local function findValidServer()
    local servers = ReplicatedStorage.Chest.Remotes.Functions.GetServers:InvokeServer()
    if type(servers) ~= "table" or not next(servers) then return nil end

    local validServers = {}
    for i = 1, 12 do
        validServers["group" .. i] = {}
    end

    local currentJobId, currentPlaceId = game.JobId, game.PlaceId

    for _, server in pairs(servers) do
        if type(server) == "table" and server.ServerOsTime and server.JobId and server.GetPlayers and server.PlaceId then
            local uptime = getServerUptimeFromData(server)
            local jobId = server.JobId
            local players = server.GetPlayers

            if server.PlaceId == currentPlaceId and jobId ~= currentJobId and not visitedServers[jobId] and players > 0 and players < 13 then
                -- Group by uptime ranges
                if uptime >= 4 * 3600 + 21 * 60 and uptime <= 4 * 3600 + 30 * 60 then
                    table.insert(validServers.group1, server)
                elseif uptime >= 8 * 3600 + 52 * 60 and uptime <= 9 * 3600 + 1 * 60 then
                    table.insert(validServers.group2, server)
                elseif uptime >= 59 * 60 + 1 and uptime <= 1 * 3600 + 7 * 60 then
                    table.insert(validServers.group3, server)
                elseif uptime >= 2 * 3600 + 7 * 60 and uptime <= 2 * 3600 + 14 * 60 then
                    table.insert(validServers.group4, server)
                elseif uptime >= 3 * 3600 + 14 * 60 and uptime <= 3 * 3600 + 21 * 60 then
                    table.insert(validServers.group5, server)
                elseif uptime >= 5 * 3600 + 31 * 60 and uptime <= 5 * 3600 + 37 * 60 then
                    table.insert(validServers.group6, server)
                elseif uptime >= 13 * 3600 + 28 * 60 and uptime <= 13 * 3600 + 35 * 60 then
                    table.insert(validServers.group7, server)
                elseif uptime >= 18 * 3600 + 10 * 60 and uptime <= 18 * 3600 + 17 * 60 then
                    table.insert(validServers.group8, server)
                elseif uptime >= 7 * 3600 + 45 * 60 and uptime <= 7 * 3600 + 52 * 60 then
                    table.insert(validServers.group9, server)
                elseif uptime >= 6 * 3600 + 38 * 60 and uptime <= 6 * 3600 + 45 * 60 then
                    table.insert(validServers.group10, server)
                elseif uptime >= 10 * 3600 + 3 * 60 and uptime <= 10 * 3600 + 9 * 60 then
                    table.insert(validServers.group11, server)
                elseif uptime >= 11 * 3600 + 11 * 60 and uptime <= 11 * 3600 + 17 * 60 then
                    table.insert(validServers.group12, server)
                end
            end
        end
    end

    math.randomseed(tick())
    local priorityGroups = {"group1", "group2", "group3", "group4", "group5", "group6", "group7", "group8", "group9", "group10", "group11", "group12"}
    
    for _, group in ipairs(priorityGroups) do
        if #validServers[group] > 0 then
            return validServers[group][math.random(#validServers[group])]
        end
    end

    return nil
end

local function Teleport()
    local selectedServer = findValidServer()
    if selectedServer then
        -- [[ CODE MỚI: Đếm Hop bằng Table ]] --
        table.insert(HopTable, os.time()) -- Thêm thời gian hiện tại vào danh sách
        SaveHops() -- Lưu lại file
        
        -- Thông báo ra màn hình
        th.New("Số server hop : " .. #HopTable, 5) 
        print("🚀 Đang Hop lần thứ: " .. #HopTable)
        -- [[ HẾT ]] --
        
        saveTeleportedServers(selectedServer.JobId)
        TeleportService:TeleportToPlaceInstance(selectedServer.PlaceId, selectedServer.JobId, lplr)
    else
        removeOldestServer()
        th.New("🔍 Đang Tìm Server Nâng Cao...", 5)
    end
end

-- ============================================
-- AUTO SERVER HOP (IMPROVED LOGIC WITH SAFE ZONE)
-- ============================================
local initialBeli = lplr:WaitForChild("PlayerStats"):WaitForChild("beli").Value
local initialGem = lplr:WaitForChild("PlayerStats"):WaitForChild("Gem").Value

task.spawn(function()
    while task.wait(0.6) do
        if not Settings.autoskhdhop then continue end
        
        local workspaceIsland = workspace.Island
        local MainGui = lplr.PlayerGui.MainGui
        local SecondSea = MainGui.StarterFrame.LegacyPoseFrame.SecondSea

        local seaKing = workspace.SeaMonster:FindFirstChild("SeaKing")
        local hydra = workspace.SeaMonster:FindFirstChild("HydraSeaKing")
        local gs = workspace.GhostMonster:FindFirstChild("Ghost Ship")

        local SKTimeLabel = SecondSea:FindFirstChild("SKTimeLabel")
        local GSTimeLabel = SecondSea:FindFirstChild("GSTimeLabel")

        local function ConvertTimeToSeconds(timeStr)
            local h, m, s = timeStr:match("(%d+):(%d+):(%d+)")
            if h and m and s then
                return tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s)
            end
            return 9999
        end

        local skSpawnTime = SKTimeLabel and ConvertTimeToSeconds(SKTimeLabel.Text) or 9999
        local gsSpawnTime = GSTimeLabel and ConvertTimeToSeconds(GSTimeLabel.Text) or 9999

        local function spamTeleport()
            coroutine.wrap(function()
                while Settings.autoskhdhop do
                    local success = pcall(Teleport)
                    if success then break end
                    task.wait(0.2)
                end
            end)()
        end

        -- Don't hop if boss spawning soon
        if skSpawnTime < Settings.HopThreshold then
            th.New("⏰ SK/Hydra spawn " .. skSpawnTime .. "s", 1)
            continue
        elseif gsSpawnTime < Settings.HopThreshold then
            th.New("⏰ GS spawn " .. gsSpawnTime .. "s", 1)
            continue
        elseif gs and gs:FindFirstChild("HumanoidRootPart") then
            th.New("👻 Ghost Ship đang có!", 1)
            continue
        elseif getBossRoot() then
            th.New("🐉 Boss đang có!", 1)
            continue
        end

        -- Check for chests/spawners
        local hasSeaKing = false
        for i = 1, 4 do
            local island = workspaceIsland:FindFirstChild("Legacy Island" .. i)
            if island and island:FindFirstChild("ChestSpawner") then
                hasSeaKing = true
                break
            end
        end

        local hasHydraStand = false
        for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
            local island = workspaceIsland:FindFirstChild(name)
            if island and island:FindFirstChild("HydraStand") then
                hasHydraStand = true
                break
            end
        end

        local hasGhostShipChest = workspace:FindFirstChild("Chest1") ~= nil

        -- If nothing valuable, hop immediately
        if not hasSeaKing and not hasHydraStand and not hasGhostShipChest and not hydra and not seaKing then
            spamTeleport()
            continue
        end

        -- Wait for chest collection
        local function waitForChestCollection()
            local timeout = 220
            local elapsedTime = 0

            while elapsedTime < timeout do
                task.wait(0.1)
                elapsedTime = elapsedTime + 0.1

                local currentBeli = lplr.PlayerStats.beli.Value
                local currentGem = lplr.PlayerStats.Gem.Value

                -- Check if collected chest
                if (hasSeaKing or hasHydraStand) and currentBeli > initialBeli and currentGem > initialGem then
                    th.New("💰 Đã nhặt rương!", 2)
                    
                    -- IMPORTANT: Teleport to safe zone before hopping
                    teleportToSafeZone()
                    
                    return true
                elseif hasGhostShipChest then
                    local chestCount = 0
                    for i = 1, 5 do
                        if workspace:FindFirstChild("Chest" .. i) then
                            chestCount = chestCount + 1
                        end
                    end
                    
                    if chestCount == 0 then
                        th.New("💰 Đã nhặt rương GS!", 2)
                        
                        -- IMPORTANT: Teleport to safe zone before hopping
                        teleportToSafeZone()
                        
                        return true
                    end
                end

                -- Recheck conditions
                hasSeaKing = false
                for i = 1, 4 do
                    local island = workspaceIsland:FindFirstChild("Legacy Island" .. i)
                    if island and island:FindFirstChild("ChestSpawner") then
                        hasSeaKing = true
                        break
                    end
                end

                hasHydraStand = false
                for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
                    local island = workspaceIsland:FindFirstChild(name)
                    if island and island:FindFirstChild("HydraStand") then
                        hasHydraStand = true
                        break
                    end
                end

                hasGhostShipChest = workspace:FindFirstChild("Chest1") ~= nil

                -- If all disappeared, stop waiting
                if not hasSeaKing and not hasHydraStand and not hasGhostShipChest then
                    return false
                end
            end

            return false
        end

        if waitForChestCollection() then
            spamTeleport()
        else
            th.New("⚠️ Timeout, hop ngay!", 2)
            spamTeleport()
        end
    end
end)

-- ============================================
-- AUTO STORE FRUIT
-- ============================================
local fruitStorage = ReplicatedStorage:FindFirstChild("Chest") and ReplicatedStorage.Chest:FindFirstChild("Fruits")

function ClickButton(path)
    if path then
        game:GetService("GuiService").SelectedObject = path
        if game:GetService("GuiService").SelectedObject == path then
            game:GetService("VirtualInputManager"):SendKeyEvent(true, 13, false, game)
            task.wait()
            game:GetService("VirtualInputManager"):SendKeyEvent(false, 13, false, game)
        end
        task.wait()
        game:GetService("GuiService").SelectedObject = nil
    end
end

local function EatFruit()
    local character = lplr.Character
    if not character then return end

    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function()
            local button = lplr.PlayerGui:FindFirstChild("EatFruitBecky") 
                and lplr.PlayerGui.EatFruitBecky:FindFirstChild("Dialogue") 
                and lplr.PlayerGui.EatFruitBecky.Dialogue:FindFirstChild("Collect")

            if button then
                ClickButton(button)
            end
        end)
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if not Settings.autocat then continue end
        
        local fruitStore = lplr.PlayerStats:FindFirstChild("FruitStore")
        local fruitStorageLimit = lplr.PlayerStats:FindFirstChild("FruitStorage")

        if not fruitStore or not fruitStorageLimit then
            warn("Không tìm thấy FruitStore hoặc FruitStorage!")
            continue
        end

        local storedFruits = HttpService:JSONDecode(fruitStore.Value)
        local storageLimit = fruitStorageLimit.Value
        local backpack = lplr:FindFirstChild("Backpack")
        local character = lplr.Character

        if not backpack or not character then continue end

        for _, fruit in ipairs(fruitStorage:GetChildren()) do
            if not Settings.autocat then break end

            local fruitName = fruit.Name
            local currentAmount = storedFruits[fruitName] or 0

            if currentAmount < storageLimit then
                local foundFruit = backpack:FindFirstChild(fruitName)

                if foundFruit then
                    foundFruit.Parent = character
                    task.wait(0.5)

                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(300, 300))
                    task.wait(1.5)

                    EatFruit()
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(300, 300))
                    task.wait(1.5)

                    local startTime = tick()
                    while (backpack:FindFirstChild(fruitName) or character:FindFirstChild(fruitName)) and (tick() - startTime < 5) do
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end)

-- ============================================
-- REMOVE EFFECTS
-- ============================================
if Settings.eff then
    for _, v in pairs(ReplicatedStorage.Chest:GetChildren()) do
        if v.Name == "FruitEffect" or v.Name == "SwordEffect" then
            v:Destroy()
        end
    end
end

-- ============================================
-- AUTO BUY KEYS
-- ============================================
task.spawn(function()
    while task.wait(0.2) do
        if not Settings.autobuy then continue end
        if Settings.chonkey == "Platinum Key" then continue end
        
        local args = {
            [1] = Settings.chonkey,
            [2] = Settings.slkey
        }
        ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("BuyKey"):InvokeServer(unpack(args))
    end
end)

-- ============================================
-- AUTO CONVERT FRUIT TO KEY
-- ============================================
local remote = ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("DealFruit")

local availableFruits = {}
for _, fruit in ipairs(ReplicatedStorage.Chest.Fruits:GetChildren()) do
    table.insert(availableFruits, fruit.Name)
end

local excludedFruits = {
    ["DoughFruit"] = true,
    ["GateFruit"] = true,
    ["DragonFruit"] = true,
    ["PhoenixFruit"] = true,
    ["ToyFruit"] = true,
    ["OpFruit"] = true,
    ["MelodyFruit"] = true
}

local function getFruitsInBackpack()
    local backpack = lplr:FindFirstChild("Backpack")
    if not backpack then return {} end

    local fruitsInBackpack = {}
    for _, item in ipairs(backpack:GetChildren()) do
        if table.find(availableFruits, item.Name) and not excludedFruits[item.Name] then
            table.insert(fruitsInBackpack, item.Name)
        end
    end

    return fruitsInBackpack
end

local autoConvert = false
local function convertFruitsToKey()
    if not autoConvert then return end

    local fruitsToConvert = getFruitsInBackpack()
    if #fruitsToConvert > 0 then
        local args = {
            [1] = Settings.chonkey,
            [2] = fruitsToConvert
        }

        remote:InvokeServer(unpack(args))
        th.New("✅ Đã chuyển Fruit thành Key: " .. Settings.chonkey, 5)
    else
        th.New("❌ Không có Fruit hợp lệ để đổi Key.", 5)
    end

    task.wait(4)
    convertFruitsToKey()
end

end -- End of Sea 2

-- ============================================
-- AUTO REJOIN
-- ============================================
local function Rejoin()
    if not sea(4) then
        TeleportService:Teleport(game.PlaceId)
    else
        TeleportService:Teleport(4520749081)
    end
end

if Settings.AutoRejoin then
    CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") and child.MessageArea:FindFirstChild("ErrorFrame") then
            task.wait(3)
            print("Lỗi phát hiện! Đang rejoin...")
            Rejoin()
        end
    end)
end

-- ============================================
-- WEBHOOK SYSTEM (IMPROVED WITH PER-ACCOUNT HOP COUNT)
-- ============================================
local Webhook_HydraChest = "https://discord.com/api/webhooks/1467749692992393402/JUHX9zfQZX2x0dj5FFW9cSIqA6gM2SnpjB0OaiWxhDZb5vyKJUtOM2PUx69fwvqK9Yf3"
local Webhook_URLshop = {
    "https://discord.com/api/webhooks/1179091565638078555/D2ynz6_DI8lMKG9XOXTZ5oa5jtAbJVKs8Lztxha2eoR5JyhozYbAxuXjB0MFsNEvKxte"
}

if Settings.Webhook_URL2 and Settings.Webhook_URL2 ~= "" then
    table.insert(Webhook_URLshop, Settings.Webhook_URL2)
end

local function getCurrentIsland()
    for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
        local island = workspace.Island:FindFirstChild(name)
        if island and island:FindFirstChild("ClockTime") and island.ClockTime:FindFirstChild("SurfaceGui") then
            return island, "Hydra"
        end
    end

    for i = 1, 4 do
        local island = workspace.Island:FindFirstChild("Legacy Island" .. i)
        if island and island:FindFirstChild("ChestSpawner") then
            return island, "Sea King"
        end
    end

    return nil, nil
end

local function getIslandInfo()
    local island, islandType = getCurrentIsland()
    if not island then return "Unknown", 0, "N/A" end

    local gateNumber = 0
    local sinkTime = "N/A"

    if islandType == "Sea King" then
        local clockTime = island:FindFirstChild("ClockTime")
        if clockTime and clockTime:FindFirstChild("SurfaceGui") then
            local textLabel = clockTime.SurfaceGui:FindFirstChild("TextLabel")
            if textLabel then
                sinkTime = textLabel.Text
            end
        end

        gateNumber = tonumber(island.Name:match("%d+")) or 0
    elseif islandType == "Hydra" then
        local clockTime = island:FindFirstChild("ClockTime")
        if clockTime and clockTime:FindFirstChild("SurfaceGui") then
            local textLabel = clockTime.SurfaceGui:FindFirstChild("TextLabel")
            if textLabel then
                sinkTime = textLabel.Text
            end
        end
    end

    return islandType, gateNumber, sinkTime
end

local function checkChests()
    local chests = {}
    
    -- Check Sea King/Hydra chests
    for i = 1, 5 do
        local chest = workspace:FindFirstChild("Chest" .. i)
        if chest and chest:FindFirstChild("Top") then
            table.insert(chests, "Chest " .. i)
        end
    end
    
    -- Check for spawners
    for i = 1, 4 do
        local island = workspace.Island:FindFirstChild("Legacy Island" .. i)
        if island and island:FindFirstChild("ChestSpawner") then
            table.insert(chests, "SK Spawner (Gate " .. i .. ")")
        end
    end
    
    for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
        local island = workspace.Island:FindFirstChild(name)
        if island and island:FindFirstChild("HydraStand") then
            table.insert(chests, "Hydra Stand (" .. name .. ")")
        end
    end
    
    return chests
end

local function getPlayerData()
    local items = {}
    local fruits = {}
    
    local backpack = lplr:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                if item.Name:match("Fruit") then
                    -- Format fruits: Do, Dr, P, G
                    local fruitName = item.Name
                    if fruitName:match("Dough") then
                        table.insert(fruits, "Do")
                    elseif fruitName:match("Dragon") then
                        table.insert(fruits, "Dr")
                    elseif fruitName:match("Phoenix") then
                        table.insert(fruits, "P")
                    elseif fruitName:match("Gate") then
                        table.insert(fruits, "G")
                    else
                        table.insert(fruits, "- " .. fruitName)
                    end
                else
                    -- Format items: F, S, B
                    local itemName = item.Name
                    if itemName:match("Sea King's Fin") or itemName:match("Fin") then
                        table.insert(items, "F")
                    elseif itemName:match("Sea King's Scale") or itemName:match("Hydra's Scale") or itemName:match("Scale") then
                        table.insert(items, "S")
                    elseif itemName:match("Sea King's Blood") or itemName:match("Blood") then
                        table.insert(items, "B")
                    else
                        table.insert(items, "- " .. itemName)
                    end
                end
            end
        end
    end
    
    return items, fruits
end

local initialBeli1 = lplr.PlayerStats.beli.Value
local initialGem1 = lplr.PlayerStats.Gem.Value
local lv = lplr.PlayerStats.lvl.Value

local function sendWebhook(webhookURL, includeItemsAndFruits)
    local chests = checkChests()
    if #chests == 0 then return end

    local islandType, gateNumber, sinkTime = getIslandInfo()
    
    local formattedChests = " Rương:" .. table.concat(chests, "\n")
    local playerCount1 = Players.NumPlayers
    local maxPlayer = Players.MaxPlayers or "??"
    
    -- Main field with per-account hop count
    local fields = {
        {
            ["name"] = "```Đảo : "..islandType.." | "..formattedChests.." | Chìm Sau : "..sinkTime.." | "..playerCount1.."/"..maxPlayer.." | "..serverName.."```",
            ["value"] = "",
            ["inline"] = true
        }
    }
    
    if islandType == "Sea King" then
        table.insert(fields, 2, {
            ["name"] = "```Cổng:"..gateNumber.."```",
            ["value"] = "",
            ["inline"] = true
        })
    end
    
    -- Add per-account hop count field
    table.insert(fields, {
        ["name"] = "📊 **Trạng Thái - " .. name .. "**",
        -- Thay hopCount bằng #HopTable (dấu thăng nghĩa là đếm số lượng phần tử)
        ["value"] = "```🔄 Đã Hop: " .. #HopTable .. " lần (Account: " .. userid .. ")```",
        ["inline"] = false
    })

    if includeItemsAndFruits then
        local items, fruits = getPlayerData()
        
        -- Format items: hiển thị cách nhau dấu phẩy
        local formattedItems = #items > 0 and "🛠️ **Items:** " .. table.concat(items, ", ") or ""
        
        -- Format fruits: hiển thị cách nhau dấu phẩy
        local formattedFruits = #fruits > 0 and "🍏 **Fruits:** " .. table.concat(fruits, ", ") or ""

        table.insert(fields, {
            ["name"] = "```Beli: "..formatNumber(initialBeli1).." | Gem: "..formatNumber(initialGem1).." | Lvl: "..formatNumber(lv).."```",
            ["value"] = formattedItems .. "\n" .. formattedFruits,
            ["inline"] = false
        })
    end

    local payload = HttpService:JSONEncode({
        ["content"] = "",
        ["embeds"] = {{
            ["author"] = {
                ["name"] = name .. " (ID: " .. userid .. ") | Executor: " .. executor .. " | Hop: #" .. #HopTable,
                ["icon"] = ""
            },
            ["type"] = "rich",
            ["color"] = tonumber(0xff0000),
            ["fields"] = fields,
            ["footer"] = {
                ["text"] = "DuyHub | Account: " .. name .. " | Tổng hop: " .. #HopTable,
                ["icon_url"] = "https://i.imgur.com/gtePhRZ.jpeg"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S.000Z", os.time())
        }}
    })

    local httprequest = request or http_request or (http and http.request) or (fluxus and fluxus.request) or syn.request
    httprequest({
        Url = webhookURL,
        Method = 'POST',
        Headers = { ['Content-Type'] = 'application/json' },
        Body = payload
    })
end

local lastSent = false
task.spawn(function()
    while task.wait(4) do
        local chests = checkChests()

        if #chests > 0 then
            if not lastSent then
                local islandType = getIslandInfo()

                for _, url in ipairs(Webhook_URLshop) do
                    sendWebhook(url, true)
                end

                if islandType == "Hydra" then
                    sendWebhook(Webhook_HydraChest, false)
                end

                lastSent = true
            end
        else
            lastSent = false
        end
    end
end)

-- Spawn Info Webhook
local playerGui = lplr:FindFirstChild("PlayerGui")
if playerGui then
    local mainGui = playerGui:FindFirstChild("MainGui")
    if mainGui then
        local starterFrame = mainGui:FindFirstChild("StarterFrame")
        if starterFrame then
            local legacyPoseFrame = starterFrame:FindFirstChild("LegacyPoseFrame")
            local serverBrowserFrame = starterFrame:FindFirstChild("ServerBrowserFrame")
            
            if legacyPoseFrame and serverBrowserFrame then
                local secondSeaFrame = legacyPoseFrame:FindFirstChild("SecondSea")
                
                if secondSeaFrame then
                    local SKTimeLabel = secondSeaFrame:FindFirstChild("SKTimeLabel")
                    local GSTimeLabel = secondSeaFrame:FindFirstChild("GSTimeLabel")
                    local serverTimeLabel = serverBrowserFrame:FindFirstChild("ServerTime")

                    if SKTimeLabel and GSTimeLabel and serverTimeLabel then
                        local Webhook_SpawnInfo = "https://discord.com/api/webhooks/1179091565638078555/D2ynz6_DI8lMKG9XOXTZ5oa5jtAbJVKs8Lztxha2eoR5JyhozYbAxuXjB0MFsNEvKxte"

                        local hasHydra = secondSeaFrame:FindFirstChild("HDImage") and secondSeaFrame.HDImage.Visible
                        local skTime = hasHydra and SKTimeLabel.Text ~= "" and SKTimeLabel.Text or nil
                        local gsTime = GSTimeLabel.Text

                        local function formatTimeWebhook(seconds)
                            local h = math.floor(seconds / 3600)
                            local m = math.floor((seconds % 3600) / 60)
                            local s = seconds % 60
                            return string.format("%02d:%02d:%02d", h, m, s)
                        end

                        local ghostShipCountdown = nil
                        if gsTime then
                            local h, m, s = gsTime:match("(%d+):(%d+):(%d+)")
                            if h and m and s then
                                local gsSeconds = (tonumber(h) * 3600) + (tonumber(m) * 60) + tonumber(s)
                                if gsSeconds <= 200 then
                                    ghostShipCountdown = formatTimeWebhook(gsSeconds)
                                end
                            end
                        end

                        if skTime or ghostShipCountdown then
                            local fields = {}
                            local playerCount2 = Players.NumPlayers
                            
                            if skTime then
                                table.insert(fields, {
                                    ["name"] = "```🌊Hydra Spawn Sau | "..skTime.." | Tại Server: "..serverName.." | "..playerCount2.."/12```",
                                    ["value"] = "",
                                    ["inline"] = false
                                })
                            end

                            if ghostShipCountdown then
                                table.insert(fields, {
                                    ["name"] = "```⛵GhostShip Spawn Sau | "..ghostShipCountdown.." | Tại Server: "..serverName.." | "..playerCount2.."/12```",
                                    ["value"] = "",
                                    ["inline"] = false
                                })
                            end
                            
                            -- Add per-account hop count
                            table.insert(fields, {
                                ["name"] = "📊 **Thống Kê - " .. name .. "**",
                                ["value"] = "```🔄 Tổng hop: " .. #HopTable .. " (Account: " .. userid .. ")```",
                                ["inline"] = false
                            })

                            local payload = HttpService:JSONEncode({
                                ["content"] = "",
                                ["embeds"] = {{
                                    ["title"] = name .. " (ID: " .. userid .. ") | Executor: " .. executor .. " | Hop: #" .. #HopTable,
                                    ["color"] = tonumber(0xFFC0CB),
                                    ["fields"] = fields,
                                    ["footer"] = {
                                        ["text"] = "DuyHub | Account: " .. name .. " | Tổng hop: " .. #HopTable,
                                        ["icon_url"] = "https://i.imgur.com/gtePhRZ.jpeg"
                                    },
                                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S.000Z", os.time())
                                }}
                            })

                            local httprequest = request or http_request or (http and http.request) or (fluxus and fluxus.request) or syn.request
                            httprequest({
                                Url = Webhook_SpawnInfo,
                                Method = 'POST',
                                Headers = { ['Content-Type'] = 'application/json' },
                                Body = payload
                            })
                        end
                    end
                end
            end
        end
    end
end

-- ============================================
-- STARTUP MESSAGE
-- ============================================
th.New("King Legacy Kaitun Loaded! | " .. name .. " | Hop: #" .. #HopTable, 5)
