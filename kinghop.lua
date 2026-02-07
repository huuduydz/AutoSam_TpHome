
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


-- [[ KẾT THÚC ĐOẠN FIX ]] --

local players = game:GetService("Players")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lplr = game.Players.LocalPlayer

local name = lplr.Name
local dname = lplr.DisplayName
local workspace = game.Workspace 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gravity = workspace.Gravity 
local executor = identifyexecutor() or "???"
local userid = lplr.UserId
local RunService = game:GetService("RunService")
local FPS = 0
local HTTP = game:GetService("HttpService")

local HttpService = game:GetService("HttpService")

local function getISOTime()
    return os.date("!%Y-%m-%dT%H:%M:%S.000Z", os.time()) -- Lấy UTC gốc
end



local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

local player = players.LocalPlayer
local TweenService = game:GetService("TweenService")
local th = {}
local notifications = {} -- Lưu trữ danh sách thông báo hiện tại

function th.New(message, duration)
    duration = duration or 3 -- Thời gian hiển thị mặc định là 3 giây

    -- Tạo ScreenGui nếu chưa tồn tại
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("NotificationGui") or Instance.new("ScreenGui")
    screenGui.Name = "NotificationGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Tạo khung thông báo
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.35, 0, 0.08, 0) -- Kích thước khung thông báo
    frame.Position = UDim2.new(0.325, 0, 1, 0) -- Xuất hiện từ bên dưới màn hình
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Màu nền
    frame.BackgroundTransparency = 0.15 -- Độ trong suốt
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    -- Bo góc mềm mại
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = frame

    -- Hiệu ứng gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 120, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 255, 150))
    }
    gradient.Rotation = 45
    gradient.Parent = frame

    -- Tạo văn bản thông báo
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

    -- Thêm thông báo vào danh sách
    table.insert(notifications, frame)

    -- Tween để thông báo xuất hiện ở vị trí phù hợp
    local targetPosition = UDim2.new(0.325, 0, 0.1 + ((#notifications - 1) * 0.1), 0)
    local showTween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = targetPosition})
    showTween:Play()

    -- Xóa thông báo sau thời gian hiển thị với hiệu ứng mờ dần
    task.delay(duration, function()
        -- Fade out `TextLabel`
        local fadeTweenText = TweenService:Create(textLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            TextTransparency = 1
        })
        fadeTweenText:Play()

        -- Fade out `Frame`
        local fadeTweenFrame = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        })
        fadeTweenFrame:Play()

        -- Sau khi fade hoàn tất, xóa thông báo
        fadeTweenFrame.Completed:Connect(function()
            frame:Destroy()
            table.remove(notifications, table.find(notifications, frame))

            -- Dịch chuyển các thông báo còn lại lên trên
            for i, notif in ipairs(notifications) do
                local newPosition = UDim2.new(0.325, 0, 0.1 + ((i - 1) * 0.1), 0)
                local moveTween = TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = newPosition})
                moveTween:Play()
            end
        end)
    end)
end
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
getgenv().start = true

task.spawn(function()
    local player = game.Players.LocalPlayer
    local startTime = tick() -- Lấy thời gian bắt đầu

    while getgenv().start do 
        task.wait(2)
        pcall(function()
            local playerGui = player:FindFirstChild("PlayerGui")

            -- Kiểm tra và xử lý màn hình tải
            if playerGui and playerGui:FindFirstChild("LoadingGUI") then
                local loadingGui = playerGui.LoadingGUI
                if loadingGui:FindFirstChild("Play") then
                    local args = {
                        [1] = "EnterTheGame",
                        [2] = {}
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("EtcFunction"):InvokeServer(table.unpack(args))
                    -- Chờ nhân vật xuất hiện rồi tự sát
                    repeat task.wait() until player.Character and player.Character:FindFirstChild("Humanoid")
                    player.Character.Humanoid.Health = 0
                end
            end

            -- Kiểm tra và chọn chế độ "Hard"
            if playerGui and playerGui:FindFirstChild("ChooseMap") then
                game:GetService("ReplicatedStorage"):WaitForChild("ChooseMapRemote"):FireServer("Hard")
            end

            if not player:FindFirstChild("DataLoaded") and (tick() - startTime >= 10) then
                warn("Nhân vật chưa load sau 10 giây, dịch chuyển")
                game:GetService("TeleportService"):Teleport(4520749081, player)
                return -- Thoát vòng lặp sau khi dịch chuyển
            end
        end)
    end
end)

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
local function updateFPS() 
        FPS += 1 
end 
local player = game.Players.LocalPlayer
local workspace = game.Workspace
local RunService = game:GetService("RunService")
local teleportService = game:GetService("TeleportService")

local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local effectsFolder = game.Workspace:FindFirstChild("Effects")
local mobFolder = game.Workspace:WaitForChild("MOB")
local HttpService = game:GetService("HttpService")
task.spawn(function()
    if game.PlaceId ~= 9821272782 then
        getgenv().Press = function(v)
            return game:GetService("VirtualInputManager"):SendKeyEvent(true, v, false, game);
        end
        while true do wait(500)
            Press("RightBracket");
        end
    else
        while true do wait(500)
            keypress(0xDD);
        end
    end
end)
local FilePath = "TestHubSaveKingLegacy"
local SettingsFile = FilePath .. "/CombinedSettings.json"  -- Đảm bảo sử dụng đúng ký tự phân cách thư mục

local combinedData = {}

-- Kiểm tra và tạo thư mục nếu chưa tồn tại
if not isfolder(FilePath) then
    makefolder(FilePath)
end

-- Khởi tạo combinedData với giá trị mặc định
combinedData = {
    Settings = {
        autoDeleteEffects = false,
        teleraid = false,
        start = true,
        opeskill = true,
        kioru = true,
        eff = true,
        bankin = 100,
        autoDodgeEnabled = true,
        autoTeleport = false,
        maxDistanceFromBoss = 190,
        docao = 50,
        autoWhitelist = false,
        fpsbut = true,
        jobId = "",
        Webhook_URL2 = "",
        AutoRejoin = false,
        hub = 0.98,
        alime = 0.7,
        giaodien = true,
        autobuy = true,
        chonkey = "Copper Key",
        KL = 1,
        slkey = 10,
        autoskhd = true,
        autoskillsea = true,
        autoskhdhop = true,
        autocat = true,
        HopThreshold = 70,
        dropfruit = false
        
        
    }
}

local Settings = combinedData.Settings

-- Hàm tải dữ liệu đã lưu
local function loadSavedData()
    if isfile(SettingsFile) then
        local success, json = pcall(readfile, SettingsFile)
        if success then
            local decodeSuccess, decodedData = pcall(function()
                return HttpService:JSONDecode(json)
            end)
            if decodeSuccess and type(decodedData) == "table" then
                combinedData = decodedData
                Settings = combinedData.Settings  -- Cập nhật lại Settings sau khi tải dữ liệu
            else
                warn("Failed to decode settings: " .. tostring(decodedData))
            end
        else
            warn("Failed to read settings file: " .. tostring(json))
        end
    end
end
local httprequest = request or http_request or (http and http.request) or (fluxus and fluxus.request) or syn.request
-- Hàm lưu dữ liệu vào tệp
local function SaveSettings()
    local success, json = pcall(function()
        return HttpService:JSONEncode(combinedData)
    end)
    
    if not success then
        warn("Failed to encode settings: " .. tostring(json))
        return
    end
    
    -- Ghi tệp với dữ liệu đã mã hóa
    local successWrite = pcall(function()
        writefile(SettingsFile, json)
    end)
    
end

-- Đảm bảo rằng loadSavedData được gọi để tải dữ liệu
loadSavedData()


local function getServerUptime(servers, currentJobId)
    for _, server in pairs(servers) do
        if type(server) == "table" and server.JobId == currentJobId and server.ServerOsTime then
            local uptime = os.time() - server.ServerOsTime -- Tính thời gian server đã hoạt động
            return uptime, server.ServerName, server.JobId
        end
    end
    return nil, nil, nil -- Không tìm thấy server hiện tại
end
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Hàm chuyển đổi giây thành dạng ngày, giờ, phút, giây
local function formatTime(seconds)
    local days = math.floor(seconds / 86400) -- 1 ngày = 86400 giây
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600) -- 1 giờ = 3600 giây
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60) -- 1 phút = 60 giây
    seconds = seconds % 60
    return string.format("%d:%d:%d:%d", days, hours, minutes, seconds)
end

-- Lấy danh sách server
local servers = ReplicatedStorage.Chest.Remotes.Functions.GetServers:InvokeServer()
local currentJobId = game.JobId

-- Gọi hàm để lấy thời gian hoạt động của server hiện tại
local uptime, serverName, jobId = getServerUptime(servers, currentJobId)

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/NamG2657/Scripting/refs/heads/main/OrionLib.lua?t=" .. os.time(), true))()

local pe = game:GetService("Players").LocalPlayer.Name
local Window = OrionLib:MakeWindow({
    Name = "TestHubV2",
    IntroEnabled = false,
    IntroText = "Welcome to TestHubV2, "..pe.."!",
    IntroIcon = "rbxassetid://6031094686",
    HidePremium = true, 
    SaveConfig = false, 
    ConfigFolder = "TestHubV2"
})

function stop()
    local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and not root:FindFirstChild("FreezeVelocity") then
        local freeze = Instance.new("BodyVelocity")
        freeze.Name = "FreezeVelocity"
        freeze.Parent = root
        freeze.MaxForce = Vector3.new(math.huge, math.huge, math.huge) -- Lực cực lớn
        freeze.Velocity = Vector3.new(0, 0, 0) -- Vận tốc bằng 0
    end
end

function ngungstop()
    local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and root:FindFirstChild("FreezeVelocity") then
        root.FreezeVelocity:Destroy()
    end
end

if sea(2) then
local sTab = Window:MakeTab({
    Name = "Sea Hop Beta ",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
if servers then
local Section = sTab:AddSection({Name = serverName})
         end
local function getBossRoot()
    local workspace = game:GetService("Workspace")
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

sTab:AddToggle({
    Name = "Auto Aim Skill HD+SK+GS",
    Default = Settings.autoskillsea,
    Callback = function(value)
        getgenv().AutoS = value
        Settings.autoskillsea = value
        SaveSettings()
        if not value then return end

        task.spawn(function()
            while Settings.autoskillsea do
                task.wait(0.3)
                pcall(function()
                    local workspace = game:GetService("Workspace")
                    local player = game.Players.LocalPlayer
                    local skillAction = game:GetService("ReplicatedStorage").Chest.Remotes.Functions.SkillAction
                    
                    -- Lấy root của boss
                    local skRoot = getBossRoot()
                    if not skRoot then return end

                    local function sendSkill(toolName, prefix, skill)
                        local args = {
                            [1] = prefix.."_"..toolName.."_"..skill,
                            [2] = {["MouseHit"] = skRoot.CFrame, ["Type"] = skill == "M1" and "Click" or "Down"}
                        }
                        skillAction:InvokeServer(table.unpack(args))
                        if skill ~= "M1" then
                            task.wait(0.05)
                            args[2].Type = "Up"
                            skillAction:InvokeServer(table.unpack(args))
                        end
                    end

                    -- Kiểm tra Ope V2
                    local hasOpOp = player.Backpack:FindFirstChild("Kioru V2") ~= nil

                    -- Quản lý Ope Room
                    local opeRoom = workspace:FindFirstChild("OpeRoom" .. player.Name)
                    if opeRoom then
                        local roomCFrame, roomSize = opeRoom.CFrame, opeRoom.Size
                        local bossOutsideCount, totalBosses = 0, 0

                        for _, boss in pairs(workspace.SeaMonster:GetChildren()) do
                            if boss:FindFirstChild("HumanoidRootPart") and boss.Name ~= "Hydra's Minion" then
                                totalBosses += 1
                                local bossPos = boss.HumanoidRootPart.Position
                                local isInside = 
                                    math.abs(bossPos.X - roomCFrame.Position.X) <= roomSize.X / 2 and
                                    math.abs(bossPos.Y - roomCFrame.Position.Y) <= roomSize.Y / 2 and
                                    math.abs(bossPos.Z - roomCFrame.Position.Z) <= roomSize.Z / 2
                                
                                if not isInside then
                                    bossOutsideCount += 1
                                end
                            end
                        end

                        if totalBosses > 0 and (bossOutsideCount / totalBosses) > 0.5 then
                            task.spawn(function()
                                skillAction:InvokeServer("DF_OpOp_Z", {["MouseHit"] = CFrame.new(), ["Type"] = "Down"})
                                task.wait(0.05)
                                skillAction:InvokeServer("DF_OpOp_Z", {["MouseHit"] = CFrame.new(), ["Type"] = "Up"})
                            end)
                        end
                    else
                        task.spawn(function()
                            skillAction:InvokeServer("DF_OpOp_Z", {["MouseHit"] = CFrame.new(), ["Type"] = "Down"})
                            task.wait(0.05)
                            skillAction:InvokeServer("DF_OpOp_Z", {["MouseHit"] = CFrame.new(), ["Type"] = "Up"})
                        end)
                    end

                    -- Sử dụng skill
                    if not hasOpOp then
                        local skills = {"M1", "Z", "X", "C", "V", "E"}
                        for _, tool in ipairs(player.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and not tool:FindFirstChild("DevilFruit") and tool.Name ~= "Cyborg" then
                                player.Character.Humanoid:EquipTool(tool)
                                task.wait(0.2)
                                for _, skill in ipairs(skills) do
                                    task.spawn(function()
                                        sendSkill(tool.Name, "SW", skill)
                                        sendSkill(tool.Name, "DF", skill)
                                    end)
                                end
                            end
                        end
                    else
                        -- Skill cho Ope V2 và Kioru V2
                        local opeSkills = {"X", "C", "V"}
                        local kioruSkills = {"M1", "Z", "X"}
                        
                        for _, skill in ipairs(opeSkills) do
                            task.spawn(function() sendSkill("OpOp", "DF", skill) end)
                        end
                        for _, skill in ipairs(kioruSkills) do
                            task.spawn(function() sendSkill("Kioru V2", "SW", skill) end)
                        end
                    end
                end)
            end
        end)
    end
})
getgenv().AutoSeaKing = false

sTab:AddToggle({
    Name = "Auto Teleport SK+HD+GS",
    Default = Settings.autoskhd,
    Callback = function(value)
        getgenv().AutoSeaKing = value
        Settings.autoskhd = value
        SaveSettings()
        if not value then ngungstop() return end
        
        spawn(function()
            while getgenv().AutoSeaKing do
                pcall(function()
                    stop()
                    local player = game.Players.LocalPlayer
                    local workspaceIsland = game:GetService("Workspace").Island
                    local workspace = game:GetService("Workspace")
                    local seaKing = workspace.SeaMonster:FindFirstChild("SeaKing")
                    local hydra = workspace.SeaMonster:FindFirstChild("HydraSeaKing")
                    local gs = workspace.GhostMonster:FindFirstChild("Ghost Ship")

                    local skHealth = seaKing and seaKing:FindFirstChild("Humanoid") and seaKing.Humanoid.Health or 0
                    local hydraHealth = hydra and hydra:FindFirstChild("Humanoid") and hydra.Humanoid.Health or 0
                    local gsHealth = gs and gs:FindFirstChild("Humanoid") and gs.Humanoid.Health or 0

                    -- 🔹 Nếu tất cả đều chết hoặc không tồn tại, dịch chuyển đến các vị trí loot
                    if (not seaKing or skHealth <= 0) and (not hydra or hydraHealth <= 0) and (not gs or gsHealth <= 0) then
                        
                        -- 🔹 Dịch chuyển vào Hydra Stand
                        for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
                            local island = workspaceIsland:FindFirstChild(name)
                            if island and island:FindFirstChild("HydraStand") then
                                
                                player.Character.HumanoidRootPart.CFrame = island.HydraStand.CFrame*CFrame.new(0,0,0)
                                
                            end
                        end                     

                        -- 🔹 Dịch chuyển vào Sea King ChestSpawner
                        local legacyIslands = {"Legacy Island1", "Legacy Island2", "Legacy Island3", "Legacy Island4"}
                        for _, islandName in ipairs(legacyIslands) do
                            local island = workspaceIsland:FindFirstChild(islandName)
                            if island and island:FindFirstChild("ChestSpawner") then
                                player.Character.HumanoidRootPart.CFrame = island.ChestSpawner.CFrame*CFrame.new(0,0,0)
                                
                            end
                        end

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
        player.Character.HumanoidRootPart.CFrame = chest.Top.CFrame
        task.wait(0.3)
        collected = collected + 1
    end
end

if collected == totalChests then
    return -- Chỉ thoát khi đã nhặt tất cả rương có trong game
end
                    else
                        -- 🔹 Nếu có Boss, dịch chuyển lên trên đầu Sea King
                        if getBossRoot() then
                            player.Character.HumanoidRootPart.CFrame = getBossRoot().CFrame * CFrame.new(0, -10, 100)
                        end
                    end
                end)
                task.wait(1) -- Để tránh treo vòng lặp
            
            end
        end)
    end
})
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fileName = "teleported_servers.txt"
local visitedServers = {}
local serverList = {}

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

local function getServerUptime(server)
    return os.time() - server.ServerOsTime
end

local function findValidServer()
    local servers = ReplicatedStorage.Chest.Remotes.Functions.GetServers:InvokeServer()
    if type(servers) ~= "table" or not next(servers) then return nil end

    local validServers = { group1 = {}, group2 = {}, group3 = {}, group4 = {}, group5 = {} ,group6 = {}, group7 = {}, group8 = {},group9 = {}, group10 = {} , group11 = {}, group12 = {}}
    local currentJobId, currentPlaceId = game.JobId, game.PlaceId

    for _, server in pairs(servers) do
    if type(server) == "table" and server.ServerOsTime and server.JobId and server.GetPlayers and server.PlaceId then
        local uptime, jobId, players = getServerUptime(server), server.JobId, server.GetPlayers

        if server.PlaceId == currentPlaceId and jobId ~= currentJobId and not visitedServers[jobId] and players > 0 and players < 13 then
             if uptime >= 4 * 60 * 60 + 21 * 60 and uptime <= 4 * 60 * 60 + 30 * 60 then
                table.insert(validServers.group1, server) 
                elseif uptime >= 8 * 60 * 60 + 52 * 60 and uptime <= 9 * 60 * 60 + 1 * 60 then
            
                table.insert(validServers.group2, server)
             elseif uptime >= 59 * 60 + 1 and uptime <= 1 * 60 * 60 + 7 * 60 then
                table.insert(validServers.group3, server)
              elseif uptime >= 2 * 60 * 60 + 7 * 60 and uptime <= 2 * 60 * 60 + 14 * 60 then
                table.insert(validServers.group4, server)
            elseif uptime >= 3 * 60 * 60 + 14 * 60 and uptime <= 3 * 60 * 60 + 21 * 60 then
                table.insert(validServers.group5, server)
            elseif uptime >= 5 * 60 * 60 + 31 * 60 and uptime <= 5 * 60 * 60 + 37 * 60 then
                table.insert(validServers.group6, server)
                elseif uptime >= 13 * 60 * 60 + 28 * 60 and uptime <= 13 * 60 * 60 + 35 * 60 then
                table.insert(validServers.group7, server)
                elseif uptime >= 18 * 60 * 60 + 10 * 60 and uptime <= 18 * 60 * 60 + 17 * 60 then
                table.insert(validServers.group8, server)
                elseif uptime >= 7 * 60 * 60 + 45 * 60 and uptime <= 7 * 60 * 60 + 52 * 60 then
                table.insert(validServers.group9, server)
                elseif uptime >= 6 * 60 * 60 + 38 * 60 and uptime <= 6 * 60 * 60 + 45 * 60 then
                table.insert(validServers.group10, server)
                elseif uptime >= 10 * 60 * 60 + 3 * 60 and uptime <= 10 * 60 * 60 + 9 * 60 then
                table.insert(validServers.group11, server)
            elseif uptime >= 11 * 60 * 60 + 11 * 60 and uptime <= 11 * 60 * 60 + 17 * 60 then
                table.insert(validServers.group12, server)
            end
        end
    end
end
    math.randomseed(tick())
    local priorityGroups = { "group1", "group2", "group3", "group4" ,"group5","group6","group7","group8","group9","group10","group11","group12"}
    for _, group in ipairs(priorityGroups) do
        if #validServers[group] > 0 then
            return validServers[group][math.random(#validServers[group])]
        end
    end

    return nil
end

-- 🏆 Hàm Teleport() mới
local function Teleport()
    
        local selectedServer = findValidServer()
        if selectedServer then
            saveTeleportedServers(selectedServer.JobId)
            th.New("Đang Tìm Server")
            TeleportService:TeleportToPlaceInstance(selectedServer.PlaceId, selectedServer.JobId, game.Players.LocalPlayer)
            
        else
            removeOldestServer()
            
            th.New("Đang Tìm Server Nâng Cao",5)
         
        
    end
end

local waitedOnce = false -- Đánh dấu đã chờ 10s chưa
local initialBeli = game.Players.LocalPlayer:WaitForChild("PlayerStats"):WaitForChild("beli").Value
 local initialGem = game.Players.LocalPlayer:WaitForChild("PlayerStats"):WaitForChild("Gem").Value
sTab:AddToggle({
    Name = "Auto Hop Thông Minh | Beta (Sea King, Hydra)",
    Default = Settings.autoskhdhop,
    Callback = function(value)
        getgenv().SeaKinghop = value
        Settings.autoskhdhop = value
        SaveSettings()
        if not value then return end

        spawn(function()
            while getgenv().SeaKinghop do
                task.wait(0.6) -- Giảm xuống 0.1 giây để kiểm tra nhanh hơn

                local Workspace = game:GetService("Workspace")
                local workspaceIsland = Workspace.Island -- Định nghĩa workspaceIsland
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local PlayerStats = LocalPlayer.PlayerStats
                local MainGui = LocalPlayer.PlayerGui.MainGui
                local SecondSea = MainGui.StarterFrame.LegacyPoseFrame.SecondSea
                -- Lấy đối tượng trong game
                local seaKing = Workspace.SeaMonster:FindFirstChild("SeaKing")
                local hydra = Workspace.SeaMonster:FindFirstChild("HydraSeaKing")
                local gs = Workspace.GhostMonster:FindFirstChild("Ghost Ship")

                -- Lấy thời gian spawn từ GUI
                local skTimeLabel = SecondSea:FindFirstChild("SKTimeLabel")
                local gsTimeLabel = SecondSea:FindFirstChild("GSTimeLabel")

                local function ConvertTimeToSeconds(timeStr)
                    local h, m, s = timeStr:match("(%d+):(%d+):(%d+)")
                    if h and m and s then
                        return tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s)
                    end
                    return 9999
                end

                local skSpawnTime = skTimeLabel and ConvertTimeToSeconds(skTimeLabel.Text) or 9999
                local gsSpawnTime = gsTimeLabel and ConvertTimeToSeconds(gsTimeLabel.Text) or 9999

local function spamTeleport()
    coroutine.wrap(function()
        while getgenv().SeaKinghop do
            local success = pcall(function()
                -- Gọi hàm Teleport ở đây
                Teleport()
            end)
            
            -- Nếu teleport thành công, thoát vòng lặp
            if success then
                break
            end

            task.wait(0.2)
        end
    end)()
end
                -- Kiểm tra thời gian spawn và quyết định hop
                if skSpawnTime < Settings.HopThreshold then
                    th.New("Sea King hoặc Hydra spawn sau " .. skSpawnTime .. " giây, không hop!", 1)
                    task.wait()
                elseif gsSpawnTime < Settings.HopThreshold then
                    th.New("Ghost Ship spawn sau " .. gsSpawnTime .. " giây, không hop!", 1)
                    task.wait()
                elseif gs and gs:FindFirstChild("HumanoidRootPart") then
                    th.New("Ghost Ship đang hiện diện, không hop!", 1)
                    task.wait()
                elseif getBossRoot() then
                    th.New("Boss đang hiện diện, không hop!", 1)
                    task.wait()
                else

                    local hasSeaKing = false
                    
                    for _, islandName in ipairs({"Legacy Island1", "Legacy Island2", "Legacy Island3", "Legacy Island4"}) do
                        local island = workspaceIsland:FindFirstChild(islandName)
                        if island and island:FindFirstChild("ChestSpawner") then
                            hasSeaKing = true -- Có ChestSpawner
                
                        end
                    
                    end

                    local hasHydraStand = false
                    
                    for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
                        local island = workspaceIsland:FindFirstChild(name)
                        if island then
                            if island:FindFirstChild("HydraStand") then
                                hasHydraStand = true -- Có HydraStand
                            end
                            
                        end
                        
                    end

                    local hasGhostShipChest = false
                    local ghostShipChest = Workspace:FindFirstChild("Chest1")
                    if ghostShipChest then
                        hasGhostShipChest = true
                    end

                    -- Kiểm tra ngoài hasCollectedChest
                    if not hasSeaKing and not hasHydraStand and not hasGhostShipChest and not hydra and (not gs or not gs:FindFirstChild("HumanoidRootPart") or not seaKing:FindFirstChild("HumanoidRootPart")) then

                            spamTeleport()
                     
                    else
                        -- Nếu có Sea King, Hydra hoặc rương, kiểm tra thu thập trong hasCollectedChest
                        local function hasCollectedChest()
                            
                            local timeout = 220 -- Timeout 5 giây
                            local elapsedTime = 0

                            -- Chờ nhặt rương
                            while elapsedTime < timeout do
                                task.wait(0.1)
                                elapsedTime = elapsedTime + 0.1

                                local currentBeli = PlayerStats.beli.Value
                                local currentGem = PlayerStats.Gem.Value

                                -- Kiểm tra nếu nhặt được rương (dựa trên Beli/Gem)
                                if (hasSeaKing or hasSeaKingChest or hasHydraStand or hasHydraChest) and currentBeli > initialBeli and currentGem > initialGem then
                                    
                                    return true
                                elseif hasGhostShipChest then
                                    th.New("Đã nhặt rương Ghost Ship!", 2)
                                    
                                    return true
                                end

                                -- Kiểm tra lại Sea King, Hydra, và rương để thoát sớm nếu đảo chìm
                                hasSeaKing = false
                                hasSeaKingChest = false
                                for _, islandName in ipairs({"Legacy Island1", "Legacy Island2", "Legacy Island3", "Legacy Island4"}) do
                                    local island = workspaceIsland:FindFirstChild(islandName)
                                    if island and island:FindFirstChild("ChestSpawner") then
                                        hasSeaKing = true
                                        for _, v in pairs(island.ChestSpawner:GetChildren()) do
                                            if v:IsA("Model") and v.Name:match("Chest$") then
                                                hasSeaKingChest = true
                                                break
                                            end
                                        end
                                    end
                                    if hasSeaKingChest then break end
                                end

                                hasHydraStand = false
                                hasHydraChest = false
                                for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
                                    local island = workspaceIsland:FindFirstChild(name)
                                    if island then
                                        if island:FindFirstChild("HydraStand") then
                                            hasHydraStand = true
                                        end
                                        for _, chest in ipairs(island:GetChildren()) do
                                            if chest:IsA("Model") and chest.Name:match("Chest$") then
                                                hasHydraChest = true
                                                break
                                            end
                                        end
                                    end
                                    if hasHydraChest then break end
                                end

                                local ghostShipChestCheck = Workspace:FindFirstChild("Chest1")
                                if ghostShipChestCheck and ghostShipChestCheck:FindFirstChild("Top") then
                                    hasGhostShipChest = true
                                end

                                local seaKingCheck = Workspace.SeaMonster:FindFirstChild("SeaKing")
                                local hydraCheck = Workspace.SeaMonster:FindFirstChild("HydraSeaKing")
                                local gsCheck = Workspace.GhostMonster:FindFirstChild("Ghost Ship")

                                -- Thoát sớm nếu không còn rương hoặc boss (đảo chìm)
                                if not hasSeaKing and not hasSeaKingChest and not hasHydraStand and not hasHydraChest and not hasGhostShipChest and not seaKingCheck and not hydraCheck and (not gsCheck or not gsCheck:FindFirstChild("HumanoidRootPart")) then
                                    
                                    return false
                                end
                            end

                            
                            return false
                        end

                        -- Thực hiện hop dựa trên kết quả nhặt rương
                        if hasCollectedChest() then
                        
                            
                            spamTeleport() -- Bỏ  để hop ngay
                        else
                            th.New("Không nhặt được rương, dịch chuyển ngay!", 2)
                            spamTeleport()
                        end
                    end
                end
            end
        end)
    end
})
sTab:AddSlider({
    Name = "Thời gian Chờ GS+HD+SK (giây)",
    Min = 0,
    Max = 300,
    Default = Settings.HopThreshold,
    Increment = 5,
    ValueName = "giây",
    Callback = function(value)
        Settings.HopThreshold = value
        SaveSettings()
    end
})


-- ============================================
-- AUTO STORE FRUIT (NEW FIXED VERSION)
-- ============================================
local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local virtualUser = game:GetService("VirtualUser")
local httpService = game:GetService("HttpService")
local guiService = game:GetService("GuiService")
local virtualInputManager = game:GetService("VirtualInputManager")

-- Biến điều khiển
getgenv().AutoStoreFruit = Settings.autocat or false

-- Hàm click nút GUI an toàn
local function ClickStoreButton(path)
    if path then
        guiService.SelectedObject = path
        if guiService.SelectedObject == path then
            virtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait()
            virtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        end
        task.wait()
        guiService.SelectedObject = nil
    end
end

-- Hàm tìm và bấm nút Cất/Store
local function AttemptStoreFruit()
    local character = player.Character
    if not character then return end

    pcall(function()
        -- Tìm GUI tương tác (EatFruitBecky)
        local gui = player.PlayerGui:FindFirstChild("EatFruitBecky")
        local dialogue = gui and gui:FindFirstChild("Dialogue")
        
        -- Tìm nút Collect hoặc Store
        local btn = dialogue and (dialogue:FindFirstChild("Collect") or dialogue:FindFirstChild("Store"))
        
        if btn then
            ClickStoreButton(btn)
        else
            -- Nếu chưa hiện bảng, click chuột vào màn hình để kích hoạt trái
            virtualUser:ClickButton1(Vector2.new(300, 300))
        end
    end)
end

-- Logic chính chạy ngầm (Chỉ chạy 1 luồng duy nhất)
task.spawn(function()
    local fruitStorageFolder = replicatedStorage:FindFirstChild("Chest") and replicatedStorage.Chest:FindFirstChild("Fruits")
    
    while task.wait(1) do
        -- Nếu tắt toggle thì bỏ qua vòng lặp này
        if not getgenv().AutoStoreFruit then continue end
        
        if not fruitStorageFolder then continue end

        local stats = player:FindFirstChild("PlayerStats")
        local storeVal = stats and stats:FindFirstChild("FruitStore")
        local limitVal = stats and stats:FindFirstChild("FruitStorage")
        
        if not storeVal or not limitVal then continue end

        -- Giải mã dữ liệu kho
        local success, storedFruits = pcall(function() 
            return httpService:JSONDecode(storeVal.Value) 
        end)
        if not success then storedFruits = {} end
        
        local storageLimit = limitVal.Value
        local backpack = player:FindFirstChild("Backpack")
        local character = player.Character
        
        if not backpack or not character then continue end

        -- Quét toàn bộ danh sách trái cây trong game để đối chiếu
        for _, fruitObj in ipairs(fruitStorageFolder:GetChildren()) do
            if not getgenv().AutoStoreFruit then break end
            
            local fruitName = fruitObj.Name
            local foundInBag = backpack:FindFirstChild(fruitName)
            
            if foundInBag then
                local currentQty = storedFruits[fruitName] or 0
                
                -- Nếu kho chưa đầy thì cất
                if currentQty < storageLimit then
                    -- 1. Trang bị trái
                    foundInBag.Parent = character
                    task.wait(0.5)
                    
                    -- 2. Click màn hình để hiện menu
                    virtualUser:ClickButton1(Vector2.new(300, 300))
                    task.wait(0.5)
                    
                    -- 3. Bấm nút cất
                    AttemptStoreFruit()
                    task.wait(1)
                    
                    -- 4. Click lại lần nữa để xác nhận/đóng
                    virtualUser:ClickButton1(Vector2.new(300, 300))
                    
                    -- 5. Kiểm tra xem trái đã mất chưa
                    local waitTime = 0
                    while (backpack:FindFirstChild(fruitName) or character:FindFirstChild(fruitName)) and waitTime < 3 do
                        task.wait(0.5)
                        waitTime = waitTime + 0.5
                        AttemptStoreFruit() -- Thử bấm lại nếu bị kẹt
                    end
                end
            end
        end
    end
end)

-- Toggle trong Menu
sTab:AddToggle({
    Name = "Auto Cất Fruit (Fix)",
    Default = Settings.autocat,
    Callback = function(Value)
        Settings.autocat = Value
        getgenv().AutoStoreFruit = Value -- Chỉ cần đổi biến này, vòng lặp trên sẽ tự chạy/dừng
        SaveSettings()
    end
})


sTab:AddToggle({
    Name = "Xóa Effect",
    Default = Settings.eff, 
    Callback = function(state)
        Settings.eff = state
        SaveSettings() 
    end
})






sTab:AddToggle({
    Name = "Auto Start, Skip, Haki",
    Default = Settings.start,
    Callback = function(value)
    Settings.start = value
        
        SaveSettings()
        getgenv().start = value
        spawn(function()
        while getgenv().start do
        pcall(function()
            wait(1)
     if not value then return end
if game.Workspace.CharacterWorkshop:FindFirstChild(game.Players.LocalPlayer.Name.."ArmamentGroup") then

else
game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("Armament"):FireServer()
end
if workspace.PlayerCharacters[game.Players.LocalPlayer.Name].Services.KenOpen.Value == false then

game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("KenEvent"):InvokeServer()

else

end
if sea(4) then
if game.Players.LocalPlayer.PlayerGui: WaitForChild("GoldenArena GUI"): FindFirstChild("StartButton")
then
game:GetService("ReplicatedStorage"):WaitForChild("GoldenArenaEvents"):WaitForChild("StartEvent"):FireServer()
end

            
end
            end)
        end
        end)
    end
})
end
if not sea(4) then
local latTab = Window:MakeTab({
    Name = "Lặt Vặt",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
local Section = latTab:AddSection({
	Name = "Hoàng Anh"
})
latTab:AddTextbox({
    Name = "Webhook Theo Dõi Khi Gặp Rương Hoặc Khi Xong Raid",
    Default = Webhook_URL2,
    TextDisappear = false,
    Callback = function(value)
        if value and value:match("^https://discord.com/api/webhooks/") then
            Webhook_URL2 = value
            Settings.Webhook_URL2 = value
            SaveSettings()
            StarterGui:SetCore("SendNotification", {
                Title = "Webhook URL2",
                Text = "Đã lưu Webhook_URL2 thành công!",
                Duration = 5
            })
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Lỗi Webhook",
                Text = "URL không hợp lệ!",
                Duration = 5
            })
        end
    end
})


latTab:AddToggle({
    Name = "Auto Vứt Fruit",
    Default = dropfruit,
    Callback = function(value)
        Settings.dropfruit = value
        SaveSettings()
        getgenv().AutoDrop = value
        local player = game:GetService("Players").LocalPlayer
local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

local function DropFruit()
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    if not backpack or not humanoid or not character then return end

    local equippedTool = humanoid:FindFirstChildOfClass("Tool")

    -- Nếu không cầm Tool có "FakeHandle", thử trang bị từ Backpack
    if not (equippedTool and equippedTool:FindFirstChild("FakeHandle")) then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") and tool.Name ~= "LegacyPose" then
                humanoid:EquipTool(tool)
                task.wait(0.5)
                equippedTool = tool
                break
            end
        end
    end

    -- Nếu có Tool hợp lệ, nhấn chuột để mở giao diện
    if equippedTool and equippedTool:FindFirstChild("Handle") then
        print("Đang cầm:", equippedTool.Name)
        game:GetService("VirtualUser"):ClickButton1(Vector2.new(50, 50))
        wait(1) -- Chờ UI xuất hiện
    end
if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") then
        
        game:GetService("VirtualUser"):ClickButton1(Vector2.new(50, 50))
        wait(1) -- Chờ UI xuất hiện
    end

    -- Tìm và nhấn nút Drop
    local gui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("EatFruitBecky")
    local dropButton = gui and gui:FindFirstChild("Dialogue") and gui.Dialogue:FindFirstChild("Drop")

    if dropButton then
       
        ClickButton(dropButton)
    end

    wait(0.8)
end
        spawn(function()
            while getgenv().AutoDrop do
                DropFruit()
                wait()
            end
        end)
    end
})
latTab:AddButton({
    Name = "Unlock Passive",
    Callback = function()
    local player = game:GetService("Players").LocalPlayer
local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local passiveTree = game:GetService("Workspace"):FindFirstChild("AllNPC") and game.Workspace.AllNPC:FindFirstChild("PassiveTree")

local replicatedStorage = game:GetService("ReplicatedStorage")
local remote = replicatedStorage.Chest.Remotes.Functions.EtcFunction

if humanoidRootPart and passiveTree then
    -- Dịch chuyển đến cây
    humanoidRootPart.CFrame = passiveTree.CFrame*CFrame.new(10,10,0)
    wait(1) -- Chờ để đảm bảo dịch chuyển xong

    -- Gọi Remote
    local success, result = pcall(function()
        return remote:InvokeServer("Blessing Passive", {})
    end)

    
else
    th.New("Không Tìm Thấy PassiveTree",5)
end
    end
})
local selectedKey = "Copper Key"
local quantityToBuy = 1
local autoBuy = false

local keyTab = Window:MakeTab({
    Name = "Key Buying",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Dropdown chọn loại chìa khóa
keyTab:AddDropdown({
    Name = "Chọn Loại Chìa Khóa",
    Default = Settings.chonkey,
    Options = {"Copper Key", "Iron Key", "Gold Key","Platinum Key"},
    Callback = function(value)
    Settings.chonkey = value
    SaveSettings()
        selectedKey = value
    end
})

-- Slider điều chỉnh số lượng
keyTab:AddSlider({
    Name = "Số Lượng Cần Mua",
    Min = 1,
    Max = 100,
    Default = Settings.slkey,
    Color = Color3.fromRGB(255, 170, 0),
    Increment = 1,
    ValueName = "Số Lượng",
    Callback = function(value)
    Settings.slkey = value
    SaveSettings()
        quantityToBuy = value
    end
})

-- Nút nhấn mua chìa khóa
keyTab:AddButton({
    Name = "Mua Ngay",
    Callback = function()
    if selectedKey == "Platinum Key" then 
    th.New("Không Thể Mua Key Này❌")
    else
        local args = {
            [1] = selectedKey,
            [2] = quantityToBuy
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("BuyKey"):InvokeServer(table.unpack(args))
end
    end
})

-- Công tắc tự động mua
keyTab:AddToggle({
    Name = "Tự Động Mua",
    Default = Settings.autobuy,
    Callback = function(state)
    if selectedKey == "Platinum Key" and state == true then 
    th.New("Không Thể Mua Key Này❌")
    end
        autoBuy = state
        Settings.autobuy = state
        SaveSettings()
        spawn(function()
            while task.wait(0.2) do
            if Settings.autobuy then
            if not state then return end
                local args = {
                    [1] = selectedKey,
                    [2] = quantityToBuy
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("BuyKey"):InvokeServer(table.unpack(args))
                
            end
        end
    end)
    end
})
keyTab:AddToggle({
    Name = "Tự Động Mở Key Đã Chọn X10 ",
    Default = false,
    Callback = function(state)
    getgenv().autopen = state
        spawn(function()
            while task.wait() do
            if getgenv().autopen then
            if not state then return end
local args = {
    [1] = selectedKey,
    [2] = "Open10"
                }
game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("UseKey"):InvokeServer(table.unpack(args))

            end
        end
        end)
    end
})

-- 📌 Khai báo biến
local autoConvert = false -- Công tắc tự động chuyển đổi

-- 🏆 Lấy remote chuyển đổi Fruit sang Key
local remote = game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("DealFruit")

-- 📜 Lấy danh sách Fruit có thể chuyển đổi từ ReplicatedStorage
local availableFruits = {}
for _, fruit in ipairs(game:GetService("ReplicatedStorage").Chest.Fruits:GetChildren()) do
    table.insert(availableFruits, fruit.Name)
end

-- ❌ Danh sách Fruit cần loại trừ
local excludedFruits = {
    ["DoughFruit"] = true,
    ["GateFruit"] = true,
    ["DragonFruit"] = true,
    ["PhoenixFruit"] = true,
    ["ToyFruit"] = true,
    ["OpFruit"] = true,
    ["MelodyFruit"] = true
}

-- 🔍 Kiểm tra Backpack và tìm các Fruit hợp lệ
local function getFruitsInBackpack()
    local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return {} end

    local fruitsInBackpack = {}
    for _, item in ipairs(backpack:GetChildren()) do
        if table.find(availableFruits, item.Name) and not excludedFruits[item.Name] then
            table.insert(fruitsInBackpack, item.Name)
        end
    end

    return fruitsInBackpack
end

-- 🔄 Chuyển đổi Fruit sang Key
local function convertFruitsToKey()
    if not autoConvert then return end

    local fruitsToConvert = getFruitsInBackpack()
    if #fruitsToConvert > 0 then
        local args = {
            [1] = selectedKey, -- Chìa khóa đã chọn
            [2] = fruitsToConvert -- Danh sách Fruit hợp lệ
        }

        remote:InvokeServer(table.unpack(args))
        print("✅ Đã chuyển Fruit thành Key:", selectedKey, "với các Fruit:", table.concat(fruitsToConvert, ", "))
        StarterGui:SetCore("SendNotification", {
                Title = "TestHubV2",
                Text = "Đã chuyển Fruit thành Key :"..selectedKey.." | Fruit:"..table.concat(fruitsToConvert, ", "),
                Duration = 2
            })
        th.New("✅ Đã chuyển Fruit thành Key :"..selectedKey,5)
    else
   
        th.New("❌ Không có Fruit hợp lệ trong Backpack để đổi Key.",5)
    end

    task.wait(4) -- Chờ 5 giây trước khi tiếp tục kiểm tra
    convertFruitsToKey() -- Lặp lại nếu công tắc đang bật
end



-- 🔘 Công tắc tự động đổi Fruit
keyTab:AddToggle({
    Name = "Tự Động Đổi Fruit Sang Key Đã Chọn",
    Default = false,
    Callback = function(value)
        autoConvert = value
        if value then
        th.New("Sẽ Loại Tự Lọai Trừ Fruit Legendary Và Trái Ope",5)
            convertFruitsToKey()
        end
    end
})

end

local TeleportTab = Window:MakeTab({
 
    Name = "Server Info",
 
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local function Rejoin()
    if not sea(4) then
        TeleportService:Teleport(game.PlaceId)
    else
        TeleportService:Teleport(4520749081)
    end
end

local rejoinConnection

TeleportTab:AddToggle({
    Name = "Auto Rejoin",
    Default = Settings.AutoRejoin,
    Callback = function(value)
        Settings.AutoRejoin = value
        SaveSettings()
        _G.AutoRejoin = value

        -- Hủy kết nối cũ nếu có
        if rejoinConnection then
            rejoinConnection:Disconnect()
            rejoinConnection = nil
        end

        if value then
            rejoinConnection = CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
                if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") and child.MessageArea:FindFirstChild("ErrorFrame") then
                wait(3)
                    print("Lỗi phát hiện! Đang rejoin...")
                    Rejoin()
                end
            end)
        end
    end
})
TeleportTab:AddButton({



    Name = "Copy Script Server",

    Callback = function()
        local currentPlayers = #game.Players:GetPlayers()
local maxPlayers = game.Players.MaxPlayers
local playerInfo = string.format(" %d/%d", currentPlayers, maxPlayers)
 
setclipboard("--[[ " .. playerInfo .. " ]]--\n"
    .. "game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId,' "..game.JobId.." ',game.Players.LocalPlayer)")
    end
})
 TeleportTab:AddButton({



    Name = "Copy Jobid Server",

    Callback = function()
 
setclipboard(game.JobId)
    end
})
local Section = TeleportTab:AddSection({Name = "Teleport"})
if sea(4) then
TeleportTab:AddButton({



    Name = "Dịch Chuyển Thẳng Về Sea1",

    Callback = function()
    OrionLib:MakeNotification({
    Name = "TestHubV2",
    Content = "Đang Dịch Chuyển",
    Image = "rbxassetid://4483345998",
    Time = 5
})
        TeleportService:Teleport(4520749081)
    end
})
end
-- Change Server Button
TeleportTab:AddButton({
    Name = "Đổi Server",
    Callback = function()
        local httprequest = request or http_request or (http and http.request) or (fluxus and fluxus.request) or syn.request
        local PlaceId = game.PlaceId
        local JobId = game.JobId
        if httprequest then
            local servers = {}
            local req = httprequest({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", PlaceId)})
            local body = game:GetService("HttpService"):JSONDecode(req.Body)
            if body and body.data then
                for i, v in next, body.data do
                    if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
                        table.insert(servers, 1, v.id)
                    end
                end
            end
            if #servers > 0 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], game:GetService("Players").LocalPlayer)
            else
                OrionLib:MakeNotification({
    Name = "TestHubV2",
    Content = "Không Tìm Được Server",
    Image = "rbxassetid://4483345998",
    Time = 5
})
            end
        end
    end
})


TeleportTab:AddButton({
    Name = "Đổi Server Ít Người",
    Callback = function()
        local httprequest = request or http_request or (http and http.request) or (fluxus and fluxus.request) or syn.request
        local PlaceId = game.PlaceId
        local JobId = game.JobId
        if httprequest then
            local servers = {}
            local req = httprequest({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", PlaceId)})
            local body = game:GetService("HttpService"):JSONDecode(req.Body)
            if body and body.data then
                for _, v in next, body.data do
                    if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
                        table.insert(servers, {id = v.id, players = v.playing})
                    end
                end
            end

            if #servers > 0 then
                -- Sắp xếp servers theo số người chơi tăng dần
                table.sort(servers, function(a, b)
                    return a.players < b.players
                end)
                -- Dịch chuyển tới server ít người chơi nhất
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, servers[1].id, game:GetService("Players").LocalPlayer)
            else
                OrionLib:MakeNotification({
                    Name = "TestHubV2",
                    Content = "Không Tìm Được Server",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
            end
        end
    end
})
local Ping = TeleportTab:AddLabel("Ping [ "..game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString().." ]")
ServerPlayer = TeleportTab:AddLabel("Player In Server [ "..#game.Players:GetPlayers().." / "..game.Players.MaxPlayers.." ]")
 
local fps = TeleportTab:AddLabel("FPS: "..workspace:GetRealPhysicsFPS()) 
 
 spawn(function() 
 
 while task.wait(1) do 
 
     Ping:Set("Ping [ "..game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString().." ]")
     
     ServerPlayer:Set("Player In Server [ "..#game.Players:GetPlayers().." / "..game.Players.MaxPlayers.." ]")
     
         fps:Set("FPS: "..FPS) 
         FPS = 0 
 end 
 end)
 
 
local time = TeleportTab:AddLabel(""..os.date("%A, %B %d, %I:%M:%S %p", os.time()))
spawn(function()
while task.wait() do
    time:Set(""..os.date("%A, %B %d, %I:%M:%S %p", os.time()))
end
end)
 
 
TeleportTab:AddLabel("Name: "..name..".")
TeleportTab:AddLabel("Display name: "..dname..".")
TeleportTab:AddLabel("User id: "..userid..".")
local Section = TeleportTab:AddSection({Name = " "})
TeleportTab:AddLabel("Executor: "..executor)
TeleportTab:AddButton({
    Name = "Rejoin",
    Callback = function()
        local tps = game:GetService("TeleportService")
        local plr = game:GetService("Players").LocalPlayer
        tps:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
    end
})
 
-- Create a Miscellaneous tab
local MiscTab = Window:MakeTab({
    Name = "❕Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
 
 
-- Fast Mode Button
MiscTab:AddButton({
    Name = "Fast Mode",
    Callback = function()
        local ToDisable = {
            Textures = true,
            VisualEffects = true,
            Parts = true,
            Particles = true,
            Sky = true
        }
 
        local ToEnable = {
            FullBright = false
        }
 
        local Stuff = {}
 
        for _, v in next, game:GetDescendants() do
            if ToDisable.Parts then
                if v:IsA("Part") or v:IsA("Union") or v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    table.insert(Stuff, 1, v)
                end
            end
 
            if ToDisable.Particles then
                if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire") then
                    v.Enabled = false
                    table.insert(Stuff, 1, v)
                end
            end
 
            if ToDisable.VisualEffects then
                if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                    v.Enabled = false
                    table.insert(Stuff, 1, v)
                end
            end
 
            if ToDisable.Textures then
                if v:IsA("Decal") or v:IsA("Texture") then
                    v.Texture = ""
                    table.insert(Stuff, 1, v)
                end
            end
 
            if ToDisable.Sky then
                if v:IsA("Sky") then
                    v.Parent = nil
                    table.insert(Stuff, 1, v)
                end
            end
        end
 
        game:GetService("TestService"):Message("Effects Disabler Script : Successfully disabled "..#Stuff.." assets / effects. Settings :")
 
        for i, v in next, ToDisable do
            print(tostring(i) .. ": " .. tostring(v))
        end
 
        if ToEnable.FullBright then
            local Lighting = game:GetService("Lighting")
 
            Lighting.FogColor = Color3.fromRGB(255, 255, 255)
            Lighting.FogEnd = math.huge
            Lighting.FogStart = math.huge
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 5
            Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
            Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Outlines = true
        end
    end
})
 -- Pose cũ
 local player = game:GetService("Players").LocalPlayer
local gui

-- Chờ GUI tải xong
repeat
    gui = player.PlayerGui:FindFirstChild("MainGui")
        and player.PlayerGui.MainGui:FindFirstChild("StarterFrame")
        and player.PlayerGui.MainGui.StarterFrame:FindFirstChild("LegacyPoseFrame")
        and player.PlayerGui.MainGui.StarterFrame.LegacyPoseFrame:FindFirstChild("SecondSea")
    task.wait()
until gui

local skTimeLabel, gsTimeLabel, skImage, gsImage, hdImage

repeat
    skTimeLabel = gui:FindFirstChild("SKTimeLabel")
    gsTimeLabel = gui:FindFirstChild("GSTimeLabel")
    skImage = gui:FindFirstChild("SKImage")
    gsImage = gui:FindFirstChild("GSImage")
    hdImage = gui:FindFirstChild("HDImage")
    task.wait()
until skTimeLabel and gsTimeLabel and skImage and gsImage and hdImage
local player = game:GetService("Players").LocalPlayer
local gui = player.PlayerGui.MainGui.StarterFrame.LegacyPoseFrame.SecondSea

-- Đặt vị trí ban đầu
gui.SKTimeLabel.Position = UDim2.new(0.5, 100, 0, -130) -- Căn giữa
gui.GSTimeLabel.Position = UDim2.new(0.5, 250, 0, -130)  -- Cạnh SKTimeLabel


-- Hàm cập nhật vị trí hình ảnh
local function updateImagePosition(label, image)
    if label and image then
        image.Position = UDim2.new(0, label.Position.X.Offset + label.Size.X.Offset + 70, label.Position.Y.Scale, label.Position.Y.Offset)
    end
end

-- Theo dõi vị trí thay đổi
gsTimeLabel:GetPropertyChangedSignal("Position"):Connect(function()
    updateImagePosition(gsTimeLabel, gsImage)
end)

skTimeLabel:GetPropertyChangedSignal("Position"):Connect(function()
    updateImagePosition(skTimeLabel, skImage)
    updateImagePosition(skTimeLabel, hdImage)
end)

-- Cập nhật ban đầu
updateImagePosition(gsTimeLabel, gsImage)
updateImagePosition(skTimeLabel, skImage)
updateImagePosition(skTimeLabel, hdImage)

-- Chờ ReplicatedStorage
repeat task.wait(.1) until game:GetService("ReplicatedStorage"):FindFirstChild("Chest")
    and game.ReplicatedStorage.Chest:FindFirstChild("Remotes")
    and game.ReplicatedStorage.Chest.Remotes:FindFirstChild("Bindables")
    and game.ReplicatedStorage.Chest.Remotes.Bindables:FindFirstChild("ClientBeckUI")

local var17 = game:GetService("ReplicatedStorage").Chest.Remotes.Bindables.ClientBeckUI
getgenv().AutoUpdateUI = false

-- Xác định khu vực biển
local function getSeaPose()
    if sea(2) then
        return "SecondSea"
    elseif sea(3) then
        return "ThirdSea"
    end
    return ""
end


local function AutoUpdate()
    -- Hàm gửi remote mỗi giây
spawn(function()
    while getgenv().AutoUpdateUI do
        var17:Fire("LegacyPoseFrame", {
            Sea = getSeaPose(),
            VisibleType = true
        })
        task.wait(2) -- Lặp lại mỗi giây
    end
    end)
end

-- Tạo công tắc bật/tắt UI với vòng lặp
MiscTab:AddToggle({
    Name = "Free Pose",
    Default = true,
    Callback = function(Value)
        getgenv().AutoUpdateUI = Value
        if Value then
            AutoUpdate()
        else
            var17:Fire("LegacyPoseFrame", { Sea = getSeaPose(), VisibleType = false })
        end
    end
})

 
-- Infinite Yield Button
MiscTab:AddButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})
 
-- Anti AFK Button
MiscTab:AddButton({
    Name = "Anti AFK",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ginchao/Anti-AFK/main/NO%20KICK", true))()
    end
})
 
-- Keyboard Button
MiscTab:AddButton({
    Name = "Keyboard",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/advxzivhsjjdhxhsidifvsh/mobkeyboard/main/main.txt", true))()
    end
})
 
-- FlyV3 Button
MiscTab:AddButton({
    Name = "FlyV3",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end
})
 
-- Shift Lock Button
MiscTab:AddButton({
    Name = "Shift Lock",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MiniNoobie/ShiftLockx/main/Shiftlock-MiniNoobie", true))()
    end
})
local hubTab = Window:MakeTab({
 
    Name = "Hub",
 
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
hubTab:AddButton({
 
    Name = "Xoá Toàn Bộ Giao Diện",
 
    Callback = function()
        OrionLib:Destroy()
        if game.Players.LocalPlayer.PlayerGui:FindFirstChild("ToggleUi") then
            game.Players.LocalPlayer.PlayerGui:FindFirstChild("ToggleUi"):Destroy()
        end
    end 
})
 
--------------------------------------------------------
local rd = {104752867797759,88832603203016,121648173742029,132902492294028}
if gethui():FindFirstChild("Orion") and game.Players.LocalPlayer.PlayerGui:FindFirstChild("ToggleUi") == nil then
    local TOGGLE = {}
    TOGGLE["Ui"] = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
    TOGGLE["DaIcon"] = Instance.new("ImageButton", TOGGLE["Ui"])
    TOGGLE["das"] = Instance.new("UICorner", TOGGLE["DaIcon"])
 
    TOGGLE["Ui"].Name = "ToggleUi"
    TOGGLE["Ui"].ResetOnSpawn = false
 
    TOGGLE["DaIcon"].Size = UDim2.new(0,45,0,45)
    TOGGLE["DaIcon"].Position = UDim2.new(0,0,0)
    TOGGLE["DaIcon"].Draggable = true
TOGGLE["DaIcon"].Image = "rbxassetid://" .. rd[math.random(#rd)]
    TOGGLE["DaIcon"].BackgroundColor3 = Color3.fromRGB(255, 182, 193)
    TOGGLE["DaIcon"].BorderColor3 = Color3.fromRGB(255, 105, 180)
    task.spawn(function()
        while true do
            for i = 0, 255, 4 do
                TOGGLE["DaIcon"].BorderColor3 = Color3.fromHSV(i/256, 1, 1)
                TOGGLE["DaIcon"].BackgroundColor3 = Color3.fromHSV(i/256, .5, .8)
                task.wait()
            end
        end
    end)
    TOGGLE["DaIcon"].MouseButton1Click:Connect(function()
        if gethui():FindFirstChild("Orion") then
            for i,v in pairs(gethui():GetChildren()) do
                if v.Name == "Orion" then
                    v.Enabled = not v.Enabled
                end
            end
        end
    end)
    TOGGLE["das"]["CornerRadius"] = UDim.new(0.20000000298023224, 0)
end 

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local hubColorFile = "HubColor.json"
local textAndBorderColorFile = "TextAndBorderColor.json"
local savedHubColor = nil
local savedTextAndBorderColor = nil

-- Hàm lưu màu vào file
local function saveColor(color, path)
    local colorData = { r = color.R, g = color.G, b = color.B }
    local jsonData = HttpService:JSONEncode(colorData)
    writefile(path, jsonData)
end

-- Hàm tải màu từ file
local function loadColor(path, defaultColor)
    if isfile(path) then
        local jsonData = readfile(path)
        local colorData = HttpService:JSONDecode(jsonData)
        return Color3.new(colorData.r, colorData.g, colorData.b)
    else
        return defaultColor -- Màu mặc định nếu file không tồn tại
    end
end

-- Hàm áp dụng màu nền cho Hub
local function applyHubColor(hubColor)
    if gethui():FindFirstChild("Orion") then
        for _, i in pairs(gethui():GetChildren()) do
            if i.Name == "Orion" then
                for _, v in pairs(i:GetDescendants()) do
                    if v.ClassName == "Frame" and v.BackgroundTransparency < 0.99 then
                        
                        v.BackgroundColor3 = hubColor -- Màu nền
                    end
                end
            end
        end
    end
end

-- Hàm áp dụng màu viền và chữ
local function applyTextAndBorderColor(color)
    if gethui():FindFirstChild("Orion") then
        for _, i in pairs(gethui():GetChildren()) do
            if i.Name == "Orion" then
                for _, v in pairs(i:GetDescendants()) do
                    if v.ClassName == "Frame" then
                        v.BorderColor3 = color -- Màu viền
                    end

                    if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                        v.TextColor3 = color -- Màu chữ
                    end
                end
            end
        end
    end
end


 -- Màu viền và chữ mặc định
savedHubColor = loadColor(hubColorFile, Color3.fromRGB(0, 0, 0)) -- Màu nền mặc định
savedTextAndBorderColor = loadColor(textAndBorderColorFile, Color3.fromRGB(255, 255, 255))
-- Áp dụng màu đã lưu


local Anh_Gai_Alimi = {
    "18273888587", "18275995451", "", "18277860491", "","72316572273088"
}

local previousBackgroundId = nil -- Biến lưu lại ID hình nền trước khi bật công tắc

-- Hàm chọn ngẫu nhiên một ID trong danh sách
local function getRandomImageId()
    local randomIndex = math.random(1, #Anh_Gai_Alimi)
    return Anh_Gai_Alimi[randomIndex]
end

-- Hàm để áp dụng hình nền mới
local function applyHubBackground(imageId)
    if gethui():FindFirstChild("Orion") then
        for _, gui in pairs(gethui():GetChildren()) do
            if gui.Name == "Orion" then
                local largestFrame = nil
                local maxSize = 0

                -- Duyệt qua tất cả các frame con
                for _, frame in pairs(gui:GetDescendants()) do
                    if frame:IsA("Frame") and frame.BackgroundTransparency < 1 then
                        local frameSize = frame.AbsoluteSize.X * frame.AbsoluteSize.Y
                        if frameSize > maxSize then
                            maxSize = frameSize
                            largestFrame = frame
                        end
                    end
                end

                -- Nếu tìm thấy Frame lớn nhất
                if largestFrame then
                    -- Lưu lại hình nền cũ
                    if largestFrame:FindFirstChild("HubBackground") then
                        previousBackgroundId = largestFrame.HubBackground.Image
                        largestFrame:FindFirstChild("HubBackground"):Destroy()
                    end

                    -- Thêm hình nền mới
                    local background = Instance.new("ImageLabel")
                    background.Name = "HubBackground"
                    background.Parent = largestFrame
                    background.Size = UDim2.new(1, 0, 1, 0) -- Full kích thước
                    background.Position = UDim2.new(0, 0, 0, 0) -- Đặt ở góc trái, trên cùng
                    background.Image = "rbxassetid://" .. imageId
                    background.BackgroundTransparency = 1
                    background.ImageTransparency = Settings.alime or 0.7 -- Mờ hơn
                    background.ScaleType = Enum.ScaleType.Stretch
                end
            end
        end
    end
end

-- Hàm để trả về trạng thái ban đầu (xóa hình nền)
local function resetBackground()
    if gethui():FindFirstChild("Orion") then
        for _, gui in pairs(gethui():GetChildren()) do
            if gui.Name == "Orion" then
                for _, frame in pairs(gui:GetDescendants()) do
                    if frame:IsA("Frame") then
                        -- Xóa hình nền nếu có
                        if frame:FindFirstChild("HubBackground") then
                            frame:FindFirstChild("HubBackground"):Destroy()
                        end
                    end
                end
            end
        end
    end
end

-- Hàm gọi khi công tắc thay đổi trạng thái
local function toggleBackground(isOn)
    if isOn then
        -- Áp dụng hình nền mới khi bật
        local randomImageId = getRandomImageId()
        applyHubBackground(randomImageId)
    else
        -- Trả về trạng thái cũ khi tắt
        resetBackground()
        if previousBackgroundId then
            -- Có thể áp dụng lại hình nền cũ nếu cần
            applyHubBackground(previousBackgroundId)
        end
    end
end

-- Tạo GUI với công tắc
hubTab:AddToggle({
    Name = "Bật/Tắt Hình Nền",
    Default = Settings.giaodien,
    Callback = function(isOn)
        Settings.giaodien = isOn
        toggleBackground(isOn)
        SaveSettings()
    end
})

-- Hàm áp dụng độ trong suốt của Hub
local function applyHubTransparency(transparency)
    if gethui():FindFirstChild("Orion") then
        for _, gui in pairs(gethui():GetChildren()) do
            if gui.Name == "Orion" then
                for _, frame in pairs(gui:GetDescendants()) do
                    if frame:IsA("Frame") and frame.BackgroundTransparency < 0.99 then
                        -- Đảm bảo rằng đối tượng frame có thể thay đổi độ trong suốt
                        if frame.BackgroundTransparency ~= transparency then
                            frame.BackgroundTransparency = transparency
                        end
                    end
                end
            end
        end
    end
end

-- Hàm thay đổi độ trong suốt của hình nền
local function applyBackgroundTransparency(transparency)
    if gethui():FindFirstChild("Orion") then
        for _, gui in pairs(gethui():GetChildren()) do
            if gui.Name == "Orion" then
                for _, frame in pairs(gui:GetDescendants()) do
                    if frame:IsA("Frame") then
                        -- Tìm đối tượng ImageLabel với hình nền và thay đổi độ trong suốt
                        if frame:FindFirstChild("HubBackground") then
                            local hubBackground = frame.HubBackground
                            if hubBackground.ImageTransparency ~= transparency then
                                hubBackground.ImageTransparency = transparency
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Các slider cho việc điều chỉnh độ trong suốt
hubTab:AddSlider({
    Name = "Độ Trong Suốt Hub",
    Min = 0.0,  -- Thay đổi Min thành 0.0
    Max = 0.98,  -- Thay đổi Max thành 1.0
    Default = Settings.hub,  -- Giá trị mặc định là 0.0
    Increment = 0.1,  -- Thêm Increment để tăng độ chính xác
    Callback = function(value)
    Settings.hub = value
    SaveSettings()
        applyHubTransparency(value)
    end
})

hubTab:AddSlider({
    Name = "Độ Rõ Hình Nền",
    Min = 0.1,  -- Thay đổi Min thành 0.1
    Max = 0.98,  -- Thay đổi Max thành 0.9
    Default = Settings.alime,  -- Giá trị mặc định là 0.8
    Increment = 0.1,  -- Thêm Increment để tăng độ chính xác
    Callback = function(value)
    Settings.alime = value
    SaveSettings()
    applyBackgroundTransparency(value)
    end
})

hubTab:AddColorpicker({
    Name = "Đổi Màu Hub",
    Default = savedHubColor,
    Callback = function(Value)
        savedHubColor = Value
        saveColor(Value, hubColorFile)
        applyHubColor(savedHubColor)
    end
})

hubTab:AddColorpicker({
    Name = "Đổi Màu Chữ",
    Default = savedTextAndBorderColor,
    Callback = function(Value)
        savedTextAndBorderColor = Value
        saveColor(Value, textAndBorderColorFile)
        applyTextAndBorderColor(savedTextAndBorderColor)
    end
})
applyBackgroundTransparency(Settings.alime)
applyHubTransparency(Settings.hub)
applyHubColor(savedHubColor)
applyTextAndBorderColor(savedTextAndBorderColor)

-- Thêm Label cập nhật thông tin
if game.CoreGui:FindFirstChild("TestHubLabelV2") then
    game.CoreGui.TestHubLabelV2:Destroy()
end

local TestHubLabel = Instance.new("ScreenGui")
TestHubLabel.Name = "TestHubLabelV2"
local Label = Instance.new("TextLabel")

-- Đảm bảo GUI được hiển thị trên màn hình
TestHubLabel.Parent = game.CoreGui

-- Cài đặt thuộc tính cho Label
Label.Parent = TestHubLabel
Label.Size = UDim2.new(0, 200, 0, 30)
Label.Position = UDim2.new(0, 190, 0, -57)
Label.BackgroundTransparency = 1
Label.TextScaled = true
Label.TextColor3 = savedTextAndBorderColor -- Áp dụng màu chữ đã lưu
Label.Font = Enum.Font.SourceSans
Label.Text = "Loading..."

-- Biến lưu thời gian lần cập nhật gần nhất
local lastUpdate = 0

-- Cập nhật FPS, Ping, và Thời gian
RunService.RenderStepped:Connect(function()
    if tick() - lastUpdate >= 1 then
        lastUpdate = tick()

        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        local time = os.date("%H:%M:%S")

        Label.Text = string.format("Time: %s | FPS: %d | Ping: %s ms", time, fps, ping)
    end
end)

hubTab:AddSection({
    Name = "Cre: ginchao"
})

hubTab:AddSection({
    Name = "Duydz | King Legacy"
})

local HttpService = game:GetService("HttpService")
local Webhook_HydraChest = "https://discord.com/api/webhooks/1467749692992393402/JUHX9zfQZX2x0dj5FFW9cSIqA6gM2SnpjB0OaiWxhDZb5vyKJUtOM2PUx69fwvqK9Yf3"
local Webhook_URLshop = {
    "https://discord.com/api/webhooks/1179091565638078555/D2ynz6_DI8lMKG9XOXTZ5oa5jtAbJVKs8Lztxha2eoR5JyhozYbAxuXjB0MFsNEvKxte"
}
if Settings.Webhook_URL2 and Settings.Webhook_URL2 ~= "" then
    table.insert(Webhook_URLshop, Settings.Webhook_URL2)
end


-- Tìm đảo Sea King hoặc Hydra hiện tại
local function getCurrentIsland()
    -- Kiểm tra đảo Hydra trước
    for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
        local island = workspace.Island:FindFirstChild(name)
        if island and island:FindFirstChild("ClockTime") and island.ClockTime:FindFirstChild("SurfaceGui") then
            return island, "Hydra"
        end
    end

    -- Nếu không tìm thấy Hydra, kiểm tra đảo Sea King
    for i = 1, 4 do
        local island = workspace.Island:FindFirstChild("Legacy Island" .. i)
        if island and island:FindFirstChild("ClockTime") and island.ClockTime:FindFirstChild("SurfaceGui") then
            return island, "Sea King"
        end
    end

    return nil, "Không xác định"
end

-- Lấy thông tin cổng và thời gian đảo chìm
local function getIslandInfo()
    local island, islandType = getCurrentIsland()
    if not island then return "Không xác định", "Không xác định", "Không xác định" end

    local gui = island.ClockTime.SurfaceGui
    local sinkTime = gui:FindFirstChild("Countdown") and gui.Countdown.Text or "Không xác định"
    
    local gateNumber = "Không xác định"
    if islandType == "Sea King" then
        gateNumber = gui:FindFirstChild("Number") and gui.Number.Text or "Không xác định"
    end

    return islandType, gateNumber, sinkTime
end

local function checkChests()
    local foundChests = {}

    for _, chest in pairs(workspace.Island:GetDescendants()) do
        if chest:IsA("Model") and chest.Name:match("Chest$") then
            if chest.Parent and chest.Parent.Name == "Gacha Background" then
                return
            end

            local tier = "???"
            if chest.Name == "EpicChest" then
                tier = "Tier1"
            elseif chest.Name == "SeaBeastChest" then
                tier = "Tier2"
            elseif chest.Name == "DragonChest" then
                tier = "Tier3"
            elseif chest.Name == "HydraChest" then
                tier = "Tier4"
            end
            
            table.insert(foundChests, "".. tier.." ")
        end
    end

    return foundChests
end

local function getPlayerData()
    local targetItems, targetFruits = {}, {}

    pcall(function()
        local materialData = game:GetService("Players").LocalPlayer.PlayerStats.Material.Value
        if type(materialData) == "string" then
            materialData = HttpService:JSONDecode(materialData)
        end
        for item, amount in pairs(materialData) do
            if (item == "Sea King's Fin" or item == "Hydra's Tail" or item == "Sea's Wraith" or item == "Sea King's Blood" or item == "Fortune Tales" or item == "Copper Key") and tonumber(amount) and tonumber(amount) > 0 then
                table.insert(targetItems, "- " .. item .. " x" .. amount)
            end
        end
    end)

    pcall(function()
        local fruitData = game:GetService("Players").LocalPlayer.PlayerStats.FruitStore.Value
        if type(fruitData) == "string" then
            fruitData = HttpService:JSONDecode(fruitData)
        end
        for fruit, amount in pairs(fruitData) do
            if (fruit == "DoughFruit" or fruit == "DragonFruit" or fruit == "PhoenixFruit" or fruit == "ToyFruit" or fruit == "GateFruit") and tonumber(amount) and tonumber(amount) > 0 then
                table.insert(targetFruits, "- " .. fruit .. " x" .. amount)
            end
        end
    end)

    return targetItems, targetFruits
end
local initialBeli1 = game.Players.LocalPlayer:FindFirstChild("PlayerStats"):FindFirstChild("beli").Value
 local initialGem1 = game.Players.LocalPlayer:FindFirstChild("PlayerStats"):FindFirstChild("Gem").Value
 local lv = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerStats"):FindFirstChild("lvl").Value
local function sendWebhook(webhookURL, includeItemsAndFruits)
    local chests = checkChests()
    if #chests == 0 then return end

    local islandType, gateNumber, sinkTime = getIslandInfo()
    local executor = "Unknown"
    pcall(function()
        executor = identifyexecutor() or "Unknown"
    end)

    local formattedChests = " Rương:" .. table.concat(chests, "\n")
local playerCount1 = game.Players.NumPlayers
local maxPlayer = game.Players.MaxPlayers or "??" -- Lấy số lượng tối đa (nếu có)
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

    if includeItemsAndFruits then
        local items, fruits = getPlayerData()
        local formattedItems = #items > 0 and "🛠️ **Items:**\n" .. table.concat(items, "\n") or ""
        local formattedFruits = #fruits > 0 and "🍏 **Fruits:**\n" .. table.concat(fruits, "\n") or ""

        table.insert(fields, {
            ["name"] = "```Beli: "..formatNumber(initialBeli1).." | Gem: "..formatNumber(initialGem1).." | Lvl: "..formatNumber(lv).."```",
            ["value"] = formattedItems .. "\n\n" .. formattedFruits,
            ["inline"] = false
        })
    end

    local payload = HttpService:JSONEncode({
        ["content"] = "",
        ["embeds"] = {{
            ["author"] = {
                ["name"] = game.Players.LocalPlayer.Name .. " | Executor: " .. executor,
                ["icon"] = ""
            },
            ["type"] = "rich",
            ["color"] = tonumber(0xff0000),
            ["fields"] = fields,
            ["footer"] = {
                ["text"] = "TestHub | Thông báo tự động",
                ["icon_url"] = "https://i.imgur.com/gtePhRZ.jpeg"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S.000Z", os.time())
        }}
    })

    httprequest({
        Url = webhookURL,
        Method = 'POST',
        Headers = { ['Content-Type'] = 'application/json' },
        Body = payload
    })
end

-- Kiểm tra rương mỗi 5 giây, chỉ gửi khi có thay đổi
local lastSent = false
task.spawn(function()
    while true do
        task.wait(4)
        local chests = checkChests()

        if #chests > 0 then
            if not lastSent then
                local islandType = getIslandInfo()

                -- Gửi vào Webhook_URLshop (luôn có item & fruit)
                for _, url in ipairs(Webhook_URLshop) do
                    sendWebhook(url, true)
                end

                -- Nếu là Hydra, gửi thêm vào Webhook_HydraChest (không có item & fruit)
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

local player = game:GetService("Players").LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui")

local Webhook_SpawnInfo = "https://discord.com/api/webhooks/1179091565638078555/D2ynz6_DI8lMKG9XOXTZ5oa5jtAbJVKs8Lztxha2eoR5JyhozYbAxuXjB0MFsNEvKxte"

-- Kiểm tra GUI
if not playerGui then return warn("Không tìm thấy PlayerGui!") end
local mainGui = playerGui:FindFirstChild("MainGui")
if not mainGui then return warn("Không tìm thấy MainGui!") end
local starterFrame = mainGui:FindFirstChild("StarterFrame")
if not starterFrame then return warn("Không tìm thấy StarterFrame!") end
local legacyPoseFrame = starterFrame:FindFirstChild("LegacyPoseFrame")
if not legacyPoseFrame then return warn("Không tìm thấy LegacyPoseFrame!") end
local secondSeaFrame = legacyPoseFrame:FindFirstChild("SecondSea")
if not secondSeaFrame then return warn("Không tìm thấy SecondSea Frame!") end
local serverBrowserFrame = starterFrame:FindFirstChild("ServerBrowserFrame")
if not serverBrowserFrame then return warn("Không tìm thấy ServerBrowserFrame!") end

local SKTimeLabel = secondSeaFrame:FindFirstChild("SKTimeLabel") -- Hydra/Sea King
local GSTimeLabel = secondSeaFrame:FindFirstChild("GSTimeLabel") -- Ghost Ship
local serverTimeLabel = serverBrowserFrame:FindFirstChild("ServerTime") -- Thời gian server

if not SKTimeLabel or not GSTimeLabel or not serverTimeLabel then
    return warn("Không tìm thấy một hoặc nhiều Label thời gian!")
end



-- Kiểm tra Hydra
local hasHydra = secondSeaFrame:FindFirstChild("HDImage") and secondSeaFrame.HDImage.Visible
local skTime = hasHydra and SKTimeLabel.Text ~= "" and SKTimeLabel.Text or nil
local gsTime = GSTimeLabel.Text
local serverTimeText = serverTimeLabel.Text

-- Hàm chuyển đổi giây thành định dạng HH:MM:SS
local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- Xử lý thời gian Ghost Ship (nếu dưới 3 phút)
local ghostShipCountdown = nil
if gsTime then
    local h, m, s = gsTime:match("(%d+):(%d+):(%d+)")
    if h and m and s then
        local gsSeconds = (tonumber(h) * 3600) + (tonumber(m) * 60) + tonumber(s)
        if gsSeconds <= 200 then
            ghostShipCountdown = formatTime(gsSeconds)
        end
    end
end


-- Nếu không có gì để gửi, thoát
if not skTime and not ghostShipCountdown and not bigMomCountdown then return end

-- Tạo nội dung webhook
local fields = {}
local playerCount2 = game.Players.NumPlayers
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


local payload = HttpService:JSONEncode({
    ["content"] = "",
    ["embeds"] = {{
        ["title"] = game.Players.LocalPlayer.Name .. " | Executor: " .. executor,
["color"] = tonumber(0xFFC0CB),
        ["fields"] = fields,
        ["footer"] = {
            ["text"] = "DuyHub | Thông báo tự động",
            ["icon_url"] = "https://i.imgur.com/gtePhRZ.jpeg"
        },
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S.000Z", os.time())
    }}
})

-- Gửi webhook
httprequest({
    Url = Webhook_SpawnInfo,
    Method = 'POST',
    Headers = { ['Content-Type'] = 'application/json' },
    Body = payload
})
OrionLib:Init()
