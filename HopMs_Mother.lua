
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
-- [[ 1. SAFE BOOT & CHỐNG AFK ]] --
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lplr = Players.LocalPlayer or Players.PlayerAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local workspace = game.Workspace

task.spawn(function()
    lplr.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    while task.wait(1) do
        pcall(function()
            local promptOverlay = CoreGui:FindFirstChild("RobloxPromptGui")
            if promptOverlay and promptOverlay:FindFirstChild("promptOverlay") then
                local errorPrompt = promptOverlay.promptOverlay:FindFirstChild("ErrorPrompt")
                if errorPrompt and errorPrompt.Visible then errorPrompt.Visible = false end
            end
        end)
    end
end)

if not game:IsLoaded() then game.Loaded:Wait() end

-- =========================================================================
-- [[ 2. HỆ THỐNG WEBHOOK TRACKER (PHOENIX TEAR & BLADE) ]] --

local function SafeDecode(val)
    if type(val) == "table" then return val end
    if type(val) == "string" and val ~= "" then
        local s, r = pcall(function() return HttpService:JSONDecode(val) end)
        if s then return r end
    end
    return {}
end

local function sendWebhook(statusMsg)
    task.spawn(function()
        pcall(function()
            local player = game.Players.LocalPlayer
            
            local tearCount = 0
            pcall(function()
                local data = SafeDecode(player.PlayerStats.Material.Value)
                tearCount = data["Phoenix's Tear"] or data["Phoenix Tear"] or 0
            end)

            local hasBlade = false
            if player.Backpack:FindFirstChild("Phoenix Blade") or (player.Character and player.Character:FindFirstChild("Phoenix Blade")) or player.StarterGear:FindFirstChild("Phoenix Blade") then
                hasBlade = true
            end

            local dropText = string.format("💧 Phoenix's Tear : %d\n🗡️ Phoenix Blade : %s", tearCount, hasBlade and "✅ Đã Có" or "❌ Chưa Có")
            local lvl = player:FindFirstChild("PlayerStats") and player.PlayerStats:FindFirstChild("Lvl") and player.PlayerStats.Lvl.Value or 0

            local embed = {
                ["title"] = "👑 Ms. Mother Hunter V25 (Hyper Spam)",
                ["color"] = 0xFFC0CB,
                ["fields"] = {
                    { ["name"] = "👨‍🚀 Player", ["value"] = "```Name : " .. player.Name .. "\nLevel : " .. lvl .. "```", ["inline"] = false },
                    { ["name"] = "🎒 Ms. Mother Drops", ["value"] = "```" .. dropText .. "```", ["inline"] = true },
                    { ["name"] = "📊 Trạng Thái", ["value"] = "```" .. statusMsg .. "```", ["inline"] = true },
                    { ["name"] = "🔄 Số lần Hop", ["value"] = "```" .. getgenv().HopCount .. "```", ["inline"] = true }
                },
                ["footer"] = { ["text"] = "DuyHub | Tự động thông báo • " .. os.date("%H:%M:%S") }
            }

            local req = request or http_request or (http and http.request) or syn.request
            if req then
                req({
                    Url = Webhook_URL, Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({ ["embeds"] = {embed} })
                })
            end
        end)
    end)
end

if not getgenv().WebhookStarted then
    getgenv().WebhookStarted = true
    sendWebhook("🟢 Script bắt đầu hoạt động!")
end

-- =========================================================================
-- [[ 3. AUTO SKIP LOADING SCREEN ]] --
task.spawn(function()
    while task.wait(0.5) do
        if lplr:FindFirstChild("PlayerStats") and lplr.PlayerStats:FindFirstChild("beli") then 
            pcall(function()
                local pgui = lplr:FindFirstChild("PlayerGui")
                if pgui and pgui:FindFirstChild("LoadingGUI") then pgui.LoadingGUI.Enabled = false end
            end)
            break 
        end
        pcall(function()
            local pgui = lplr:FindFirstChild("PlayerGui")
            if pgui and pgui:FindFirstChild("LoadingGUI") then
                local lg = pgui.LoadingGUI
                if lg:FindFirstChild("Play") or lg:FindFirstChild("PlayButton") then
                    if ReplicatedStorage:FindFirstChild("Chest") then
                        ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("EnterTheGame", {})
                    end
                    if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                        lplr.Character.Humanoid.Health = 0
                    end
                end
            end
            if ReplicatedStorage:FindFirstChild("ChooseMapRemote") then
                ReplicatedStorage.ChooseMapRemote:FireServer("Hard")
            end
        end)
    end
end)

repeat task.wait(0.5) until lplr:FindFirstChild("PlayerStats") and lplr.PlayerStats:FindFirstChild("beli")
task.wait(1)

-- =========================================================================
-- [[ 4. HỆ THỐNG ĐỒNG BỘ THỜI GIAN ]] --
local currentServerOsTime = nil
task.spawn(function()
    pcall(function()
        local srvs = ReplicatedStorage.Chest.Remotes.Functions.GetServers:InvokeServer()
        if type(srvs) == "table" then
            for _, srv in pairs(srvs) do
                if srv.JobId == game.JobId and srv.ServerOsTime then
                    currentServerOsTime = srv.ServerOsTime
                    break
                end
            end
        end
    end)
end)

local function Notify(msg, dur)
    dur = dur or 3
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "👑 Kaitun Ms. Mother", Text = msg, Duration = dur })
end

-- =========================================================================
-- [[ 5. HỆ THỐNG HOP ĐA LUỒNG ]] --
local function toSeconds(h, m, s) return (h * 3600) + (m * 60) + (s or 0) end
local MsMotherSchedule = {
    { H = 1, M = 58, Window = 5, Group = "g1" }, { H = 3, M = 58, Window = 5, Group = "g2" },
    { H = 5, M = 58, Window = 5, Group = "g3" }, { H = 7, M = 58, Window = 5, Group = "g4" },
    { H = 9, M = 58, Window = 5, Group = "g5" }, { H = 11, M = 58, Window = 5, Group = "g6" },
    { H = 13, M = 58, Window = 5, Group = "g7" }, { H = 15, M = 58, Window = 5, Group = "g8" },
    { H = 17, M = 58, Window = 5, Group = "g9" }, { H = 19, M = 58, Window = 5, Group = "g10" },
    { H = 21, M = 58, Window = 5, Group = "g11" }, { H = 23, M = 58, Window = 5, Group = "g12" }
}

local visitedServers = {}
local function findValidServer()
    local ok, srvs = pcall(function() return ReplicatedStorage.Chest.Remotes.Functions.GetServers:InvokeServer() end)
    if not ok or type(srvs) ~= "table" then return nil end

    local validServers = {g1={},g2={},g3={},g4={},g5={},g6={},g7={},g8={},g9={},g10={},g11={},g12={}}
    for _, srv in pairs(srvs) do
        if type(srv)=="table" and srv.ServerOsTime and srv.JobId and srv.GetPlayers and srv.PlaceId == game.PlaceId and srv.JobId ~= game.JobId and not visitedServers[srv.JobId] and srv.GetPlayers > 0 and srv.GetPlayers < 13 then
            local uptime = os.time() - srv.ServerOsTime
            for _, sched in ipairs(MsMotherSchedule) do
                local startT = toSeconds(sched.H, sched.M)
                local endT = startT + (sched.Window * 60)
                if uptime >= startT and uptime <= endT then
                    table.insert(validServers[sched.Group], srv)
                    break
                end
            end
        end
    end

    math.randomseed(tick())
    for _, g in ipairs({"g1","g2","g3","g4","g5","g6","g7","g8","g9","g10","g11","g12"}) do
        if #validServers[g] > 0 then return validServers[g][math.random(#validServers[g])] end
    end
    return nil
end

local isHoppingFinal = false
local function FinalHop()
    if isHoppingFinal then return end
    isHoppingFinal = true
    getgenv().AutoMsMother = false
    getgenv().HopCount = getgenv().HopCount + 1
    
    Notify("🚀 Không có Boss/Đã tiêu diệt! Đang Hop Server...", 99)
    
    while true do
        for i = 1, 10 do
            task.spawn(function()
                pcall(function()
                    local srv = findValidServer()
                    if srv then
                        visitedServers[srv.JobId] = true
                        TeleportService:TeleportToPlaceInstance(srv.PlaceId, srv.JobId, lplr)
                    end
                end)
            end)
        end
        task.wait(1)
    end
end

-- =========================================================================
-- [[ 6. LOGIC TÌM BOSS & LẤY VŨ KHÍ ]] --
local function getMsMotherRoot()
    local msMother = workspace:FindFirstChild("Monster") and workspace.Monster:FindFirstChild("Boss") and workspace.Monster.Boss:FindFirstChild("Ms. Mother [Lv. 7500]")
    if msMother and msMother:FindFirstChild("Humanoid") and msMother.Humanoid.Health > 0 and msMother:FindFirstChild("HumanoidRootPart") then
        return msMother.HumanoidRootPart
    end
    return nil
end

local function getAllValidWeapons()
    local validTools = {}
    local char = lplr.Character
    if char then
        local equipped = char:FindFirstChildOfClass("Tool")
        if equipped and not equipped.Name:match("Compass") and not equipped.Name:match("Map") then
            table.insert(validTools, equipped)
        end
    end
    for _, t in pairs(lplr.Backpack:GetChildren()) do
        if t:IsA("Tool") and not t.Name:match("Compass") and not t.Name:match("Map") then
            table.insert(validTools, t)
        end
    end
    return validTools
end

local skillAction = ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("SkillAction")

-- =========================================================================
-- [[ 7. CÁC LUỒNG COMBAT (HYPER SPAM MAX DPS) ]] --

-- LUỒNG 1: AUTO CHÉM M1 (MƯA M1 KHÔNG NGHỈ)
task.spawn(function()
    while task.wait() do -- Tốc độ bàn thờ (bỏ số 0.1)
        if getgenv().AutoMsMother then
            pcall(function()
                local target = getMsMotherRoot()
                local char = lplr.Character
                if target and char then
                    local currentWeapon = char:FindFirstChildOfClass("Tool")
                    if currentWeapon then
                        skillAction:InvokeServer("SW_" .. currentWeapon.Name .. "_M1", {["MouseHit"] = target.CFrame, ["Type"] = "Click"})
                        skillAction:InvokeServer("DF_" .. currentWeapon.Name .. "_M1", {["MouseHit"] = target.CFrame, ["Type"] = "Click"})
                    end
                end
            end)
        end
    end
end)

-- LUỒNG 2: HYPER CYCLE EQUIP SPAM SKILL (XẢ Z,X,C,V,E ĐỒNG LOẠT)
task.spawn(function()
    local skills = {"Z", "X", "C", "V"}
    while task.wait() do -- Lặp vũ khí cực nhanh
        if getgenv().AutoMsMother then
            pcall(function()
                local target = getMsMotherRoot()
                if target then
                    local allWeapons = getAllValidWeapons()
                    for _, weapon in ipairs(allWeapons) do
                        if not getgenv().AutoMsMother or not getMsMotherRoot() then break end
                        
                        -- Cầm vũ khí lên
                        if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                            lplr.Character.Humanoid:EquipTool(weapon)
                            task.wait() -- Đợi 1 frame siêu nhỏ cho game nhận vũ khí
                        end
                        
                        -- BẤM ĐỒNG LOẠT TOÀN BỘ SKILL CÙNG 1 LÚC (Không có delay)
                        for _, key in ipairs(skills) do
                            task.spawn(function()
                                local currentTarget = getMsMotherRoot()
                                if currentTarget then
                                    local argsSW = {"SW_" .. weapon.Name .. "_" .. key, {["MouseHit"] = currentTarget.CFrame, ["Type"] = "Down"}}
                                    local argsDF = {"DF_" .. weapon.Name .. "_" .. key, {["MouseHit"] = currentTarget.CFrame, ["Type"] = "Down"}}
                                    
                                    skillAction:InvokeServer(unpack(argsSW))
                                    skillAction:InvokeServer(unpack(argsDF))
                                    
                                    task.wait() -- Nghỉ 1 frame để nhả phím
                                    
                                    argsSW[2].Type = "Up"
                                    argsDF[2].Type = "Up"
                                    skillAction:InvokeServer(unpack(argsSW))
                                    skillAction:InvokeServer(unpack(argsDF))
                                end
                            end)
                        end
                        
                        -- Chỉ đợi 0.1s cho game bung hết hiệu ứng rồi chuyển đồ tiếp theo ngay lập tức
                        task.wait() 
                    end
                end
            end)
        end
    end
end)

-- LUỒNG 3: AUTO HAKI (BUSO & KEN)
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoMsMother then
            local player = game.Players.LocalPlayer
            pcall(function()
                local cw = game.Workspace:FindFirstChild("CharacterWorkshop")
                if cw and not cw:FindFirstChild(player.Name.."ArmamentGroup") then
                    game:GetService("ReplicatedStorage").Chest.Remotes.Events.Armament:FireServer()
                end
            end)
            pcall(function()
                local pcChars = game.Workspace:FindFirstChild("PlayerCharacters")
                if pcChars and pcChars:FindFirstChild(player.Name) then
                    local services = pcChars[player.Name]:FindFirstChild("Services")
                    if services and services:FindFirstChild("KenOpen") and services.KenOpen.Value == false then
                        game:GetService("ReplicatedStorage").Chest.Remotes.Functions.KenEvent:InvokeServer()
                    end
                end
            end)
        end
    end
end)

-- LUỒNG 4: XÓA EFFECT GIẢM LAG TỐI ĐA (CHỐNG VĂNG KHI SPAM LIÊN TỤC)
task.spawn(function()
    local chest = ReplicatedStorage:WaitForChild("Chest", 10)
    if not chest then return end
    
    chest.ChildAdded:Connect(function(child)
        if getgenv().AutoMsMother then
            if child.Name == "FruitEffect" or child.Name == "SwordEffect" or child.Name == "DamageIndicator" then
                task.wait()
                pcall(function() child:Destroy() end)
            end
        end
    end)
    
    while task.wait(1) do -- Rút ngắn chu kỳ dọn dẹp xuống 1s vì skill xả quá nhiều
        if getgenv().AutoMsMother then
            pcall(function()
                for _, v in pairs(chest:GetChildren()) do
                    if v.Name == "FruitEffect" or v.Name == "SwordEffect" or v.Name == "DamageIndicator" then
                        v:Destroy()
                    end
                end
            end)
        end
    end
end)

-- =========================================================================
-- [[ 8. LOGIC CHÍNH: THE BRAIN & TRIGGER WEBHOOK ]] --
local lastBossCFrame = nil
local checkBossTimer = 0
local mapLoadTimer = 0
local hasTeleportedToIsland = false
getgenv().IsFightingBoss = false

task.spawn(function()
    Notify("Bắt đầu truy lùng Ms. Mother...", 5)
    
    while task.wait(0.5) do
        if getgenv().AutoMsMother then
            if isHoppingFinal then break end

            pcall(function()
                local char = lplr.Character
                local isAlive = char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart")

                if not isAlive then
                    if char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("FreezePos") then
                        char.HumanoidRootPart.FreezePos:Destroy()
                    end
                    return 
                end

                local uptime = 0
                if currentServerOsTime then
                    uptime = os.time() - currentServerOsTime
                else
                    uptime = workspace.DistributedGameTime
                end
                
                local cycle = uptime % 7200
                local isUnderTwoHours = (cycle >= 7080 and cycle < 7200)
                local isOverTwoHours = (cycle >= 0 and cycle <= 180) 

                local bossRoot = getMsMotherRoot()
                
                if bossRoot then
                    -- BÁO WEBHOOK: ĐÃ TÌM THẤY BOSS
                    if not getgenv().IsFightingBoss then
                        getgenv().IsFightingBoss = true
                        sendWebhook("⚔️ PHÁT HIỆN BOSS! Đang tiến hành tiêu diệt...")
                    end

                    checkBossTimer = 0 
                    mapLoadTimer = 0
                    hasTeleportedToIsland = true 
                    lastBossCFrame = bossRoot.CFrame 
                    
                    -- AUTO AIM BOSS THEO KHOẢNG CÁCH (STUD)
                    local targetPos = bossRoot.Position
                    local myNewPos = bossRoot.CFrame * CFrame.new(0, getgenv().DistanceStud, 0).Position
                    char.HumanoidRootPart.CFrame = CFrame.new(myNewPos, targetPos)
                    
                    if not char.HumanoidRootPart:FindFirstChild("FreezePos") then
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "FreezePos"
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Velocity = Vector3.new(0, 0, 0)
                        bv.Parent = char.HumanoidRootPart
                    end
                else
                    if char.HumanoidRootPart:FindFirstChild("FreezePos") then 
                        char.HumanoidRootPart.FreezePos:Destroy() 
                    end

                    if lastBossCFrame then
                        char.HumanoidRootPart.CFrame = lastBossCFrame 
                        checkBossTimer = checkBossTimer + 0.5
                        if checkBossTimer < 2 then 
                            return
                        else
                            -- BÁO WEBHOOK: BOSS ĐÃ CHẾT
                            if getgenv().IsFightingBoss then
                                getgenv().IsFightingBoss = false
                                sendWebhook("☠️ BOSS ĐÃ BỊ TIÊU DIỆT! Kiểm tra đồ Drop...")
                            end
                            lastBossCFrame = nil 
                            FinalHop()
                            return
                        end
                    end

                    if isUnderTwoHours or isOverTwoHours then
                        if not hasTeleportedToIsland then
                            local islandFolder = workspace:FindFirstChild("Island")
                            if islandFolder then
                                for _, v in pairs(islandFolder:GetChildren()) do
                                    if v.Name:match("Loaf") then
                                        local part = v:FindFirstChildWhichIsA("BasePart", true)
                                        if part then
                                            char.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 200, 0)
                                            break
                                        end
                                    end
                                end
                            end
                            hasTeleportedToIsland = true
                            task.wait(2) 
                            return
                        end

                        if isUnderTwoHours then
                            mapLoadTimer = 0
                        elseif isOverTwoHours then
                            mapLoadTimer = mapLoadTimer + 0.5
                            if mapLoadTimer >= 5 then FinalHop() end
                        end
                    else
                        FinalHop()
                    end
                end
            end)
        end
    end
end)
