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

print("Script KingHop bắt đầu hoạt động...")


-- ╔══════════════════════════════════════════════════════════╗
-- ║          KING HOP — KAITUN EDITION  (No GUI)             ║
-- ║   Sửa true/false ở phần CONFIG bên dưới rồi chạy lại    ║
-- ║              Cre: duydz  | Kaitun: Claude                ║
-- ╚══════════════════════════════════════════════════════════╝

-- ════════════════════════════════════════════════
--              ★  CẤU HÌNH TÍNH NĂNG  ★
--    Sửa true = BẬT  |  false = TẮT  rồi chạy lại
-- ════════════════════════════════════════════════

local CONFIG = {

    -- ── TÍNH NĂNG CHÍNH ─────────────────────────
    AutoHop          = true,   -- Auto Hop thông minh (SK + HD + GS)
    AutoTeleport     = true,   -- Auto Teleport lên boss / rương
    AutoSkill        = true,   -- Auto Aim Skill (SK / HD / GS)
    AutoStart        = true,   -- Auto Start, Skip loading, Kenbun, Armament Haki
    AutoCatFruit     = true,  -- Auto Cất Fruit vào kho
    AutoDropFruit    = false,  -- Auto Vứt Fruit
    AutoDeleteEffect = false,   -- Xóa FruitEffect / SwordEffect (giảm lag)
    AutoRejoin       = false,  -- Auto Rejoin khi bị lỗi kết nối
    FreePose         = true,  -- Free Pose — hiện UI SecondSea / ThirdSea

    -- ── KEY BUYING ───────────────────────────────
    AutoBuyKey       = true,  -- Tự động mua key
    AutoOpenKey      = false,  -- Tự động mở key x10
    AutoConvertFruit = true,  -- Tự động đổi Fruit → Key

    -- ── THÔNG SỐ ────────────────────────────────
    SelectedKey      = "Copper Key",  -- "Copper Key" | "Iron Key" | "Gold Key" | "Platinum Key"
    KeyQuantity      = 10,            -- Số lượng key mua mỗi lần
    HopThreshold     = 70,            -- Không hop nếu SK/HD/GS còn < X giây
    Webhook_URL2     = "https://discord.com/api/webhooks/1467875798831730913/zsa2TrwzhGh_wvRfZTF_Zhm85kJago6fZU0IEFZNxS2U1pHW203sAHVVFDPcRE_RSHH3",            -- Webhook phụ (để trống nếu không dùng)
}

-- ════════════════════════════════════════════════
--   Không cần chỉnh gì bên dưới — tự động chạy
-- ════════════════════════════════════════════════

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VIM               = game:GetService("VirtualInputManager")
local CoreGui           = game:GetService("CoreGui")

local lplr  = Players.LocalPlayer
local pName = lplr.Name

local httprequest = (request or http_request
    or (http and http.request)
    or (fluxus and fluxus.request)
    or (syn and syn.request))

-- Đẩy CONFIG vào getgenv để có thể thay đổi runtime
for k, v in pairs(CONFIG) do
    getgenv()["KT_"..k] = v
end

-- Shorthand: luôn đọc từ getgenv nên hỗ trợ đổi runtime
local function cfg(key) return getgenv()["KT_"..key] end

-- ════════════════════════════════════════════════
-- NOTIFICATION (nhẹ, không dùng OrionLib)
-- ════════════════════════════════════════════════
local _notifs = {}
local function Notify(msg, dur)
    dur = dur or 3
    task.spawn(function()
        local pgui = lplr:FindFirstChild("PlayerGui")
        if not pgui then return end

        local sg = pgui:FindFirstChild("_KT_Notif") or Instance.new("ScreenGui")
        sg.Name = "_KT_Notif"
        sg.ResetOnSpawn = false
        sg.Parent = pgui

        local f = Instance.new("Frame")
        f.Size = UDim2.new(0.30, 0, 0.06, 0)
        f.Position = UDim2.new(0.35, 0, 1.05, 0)
        f.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        f.BackgroundTransparency = 0.05
        f.BorderSizePixel = 0
        f.ZIndex = 99
        f.Parent = sg
        Instance.new("UICorner",f).CornerRadius = UDim.new(0,10)
        local stroke = Instance.new("UIStroke",f)
        stroke.Color = Color3.fromRGB(60,160,255)
        stroke.Thickness = 1.5

        local lbl = Instance.new("TextLabel",f)
        lbl.Size = UDim2.new(1,-12,1,-6)
        lbl.Position = UDim2.new(0,6,0,3)
        lbl.BackgroundTransparency = 1
        lbl.Text = msg
        lbl.TextColor3 = Color3.fromRGB(220,225,255)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
        lbl.TextWrapped = true
        lbl.ZIndex = 99

        table.insert(_notifs, f)
        local targetY = 0.90 - ((#_notifs - 1) * 0.07)

        TweenService:Create(f, TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
            {Position=UDim2.new(0.35,0,targetY,0)}):Play()

        task.wait(dur)

        TweenService:Create(lbl, TweenInfo.new(0.35),{TextTransparency=1}):Play()
        TweenService:Create(f,   TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.In),
            {Position=UDim2.new(0.35,0,1.1,0), BackgroundTransparency=1}):Play()
        task.wait(0.4)
        local idx = table.find(_notifs,f)
        if idx then table.remove(_notifs,idx) end
        pcall(function() f:Destroy() end)
    end)
end

-- ════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ════════════════════════════════════════════════
local function sea(v)
    local ids = {[1]=4520749081,[2]=6381829480,[3]=15759515082,[4]=5931540094}
    return game.PlaceId == ids[v]
end

local function getChar()  return lplr.Character end
local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function stop()
    local r = getRoot()
    if r and not r:FindFirstChild("_KTFreeze") then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "_KTFreeze"
        bv.MaxForce = Vector3.new(1e9,1e9,1e9)
        bv.Velocity = Vector3.zero
        bv.Parent = r
    end
end
local function unstop()
    local r = getRoot()
    if r and r:FindFirstChild("_KTFreeze") then r._KTFreeze:Destroy() end
end

local function getBossRoot()
    local folders = {workspace:FindFirstChild("SeaMonster"), workspace:FindFirstChild("GhostMonster")}
    for _, folder in ipairs(folders) do
        if folder then
            for _, bname in ipairs({"SeaKing","HydraSeaKing","Ghost Ship"}) do
                local b = folder:FindFirstChild(bname)
                if b and b:FindFirstChild("HumanoidRootPart") then
                    return b.HumanoidRootPart
                end
            end
        end
    end
    return nil
end

local function ClickButton(path)
    if not path then return end
    local gs = game:GetService("GuiService")
    gs.SelectedObject = path
    if gs.SelectedObject == path then
        VIM:SendKeyEvent(true,13,false,game)
        task.wait()
        VIM:SendKeyEvent(false,13,false,game)
    end
    task.wait()
    gs.SelectedObject = nil
end

-- ════════════════════════════════════════════════
-- SERVER HOP CORE
-- ════════════════════════════════════════════════
local visitedServers = {}
local serverList     = {}
local hopFile        = "KaitunKingHop_visited.txt"

if isfile(hopFile) then
    for id in string.gmatch(readfile(hopFile),"[^\n]+") do
        visitedServers[id] = true
        table.insert(serverList, id)
    end
end

-- ════════════════════════════════════════════════
-- HOP COUNTER SYSTEM  (counthop.lua)
-- Đếm số lần hop: session (lần này) + alltime (lưu file)
-- ════════════════════════════════════════════════
local hopCountFile = "KaitunHopCount_"..tostring(lplr.UserId)..".json"
local hopHistory   = {}   -- bảng lưu timestamp mỗi lần hop (all-time)
local hopSession   = 0    -- đếm hop trong phiên hiện tại (reset khi chạy lại)

-- Load lịch sử hop từ file
local function loadHopHistory()
    if isfile and isfile(hopCountFile) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(hopCountFile))
        end)
        if ok and type(data) == "table" then
            hopHistory = data
            print("📊 HopCounter: Load "..#hopHistory.." lan hop tu file")
        else
            hopHistory = {}
            warn("⚠️ HopCounter: File loi, tao moi")
        end
    else
        hopHistory = {}
        print("📝 HopCounter: Chua co file, tao moi")
    end
end

-- Lưu lịch sử hop ra file
local function saveHopHistory()
    if writefile then
        pcall(writefile, hopCountFile, HttpService:JSONEncode(hopHistory))
    end
end

-- Gọi khi hop thành công: tăng counter + lưu file + sync getgenv
local function recordHop()
    hopSession += 1
    table.insert(hopHistory, os.time())
    saveHopHistory()
    getgenv().hopCount        = hopSession
    getgenv().hopCountAllTime = #hopHistory
    print(string.format("🔵 Hop #%d session | #%d alltime", hopSession, #hopHistory))
end

-- Trả về (session, alltime, hop24h) để dùng trong webhook embed
local function getHopStats()
    local now   = os.time()
    local hop24 = 0
    for _, t in ipairs(hopHistory) do
        if (now - t) <= 86400 then hop24 += 1 end
    end
    return hopSession, #hopHistory, hop24
end

-- Khởi tạo ngay khi load script
loadHopHistory()
getgenv().hopCount        = hopSession
getgenv().hopCountAllTime = #hopHistory

local function saveVisited(jobId)
    if not visitedServers[jobId] then
        visitedServers[jobId] = true
        table.insert(serverList, jobId)
        pcall(writefile, hopFile, table.concat(serverList,"\n"))
    end
end

local function removeOldest()
    if #serverList > 0 then
        local id = table.remove(serverList,1)
        visitedServers[id] = nil
        pcall(writefile, hopFile, table.concat(serverList,"\n"))
    end
end

local function findValidServer()
    local ok, srvs = pcall(function()
        return ReplicatedStorage.Chest.Remotes.Functions.GetServers:InvokeServer()
    end)
    if not ok or type(srvs) ~= "table" or not next(srvs) then return nil end

    local validServers = {
        group1={},group2={},group3={},group4={},group5={},group6={},
        group7={},group8={},group9={},group10={},group11={},group12={}
    }

    for _, srv in pairs(srvs) do
        if type(srv)=="table" and srv.ServerOsTime and srv.JobId
            and srv.GetPlayers and srv.PlaceId
            and srv.PlaceId == game.PlaceId
            and srv.JobId ~= game.JobId
            and not visitedServers[srv.JobId]
            and srv.GetPlayers > 0 and srv.GetPlayers < 13 then

            local up = os.time() - srv.ServerOsTime

            if     up >= 4*3600+21*60  and up <= 4*3600+30*60  then table.insert(validServers.group1,  srv)
            elseif up >= 8*3600+52*60  and up <= 9*3600+1*60   then table.insert(validServers.group2,  srv)
            elseif up >= 59*60+1       and up <= 1*3600+7*60   then table.insert(validServers.group3,  srv)
            elseif up >= 2*3600+7*60   and up <= 2*3600+14*60  then table.insert(validServers.group4,  srv)
            elseif up >= 3*3600+14*60  and up <= 3*3600+21*60  then table.insert(validServers.group5,  srv)
            elseif up >= 5*3600+31*60  and up <= 5*3600+37*60  then table.insert(validServers.group6,  srv)
            elseif up >= 13*3600+28*60 and up <= 13*3600+35*60 then table.insert(validServers.group7,  srv)
            elseif up >= 18*3600+10*60 and up <= 18*3600+17*60 then table.insert(validServers.group8,  srv)
            elseif up >= 7*3600+45*60  and up <= 7*3600+52*60  then table.insert(validServers.group9,  srv)
            elseif up >= 6*3600+38*60  and up <= 6*3600+45*60  then table.insert(validServers.group10, srv)
            elseif up >= 10*3600+3*60  and up <= 10*3600+9*60  then table.insert(validServers.group11, srv)
            elseif up >= 11*3600+11*60 and up <= 11*3600+17*60 then table.insert(validServers.group12, srv)
            end
        end
    end

    math.randomseed(tick())
    local priority = {
        "group1","group2","group3","group4","group5","group6",
        "group7","group8","group9","group10","group11","group12"
    }
    for _, g in ipairs(priority) do
        if #validServers[g] > 0 then
            return validServers[g][math.random(#validServers[g])]
        end
    end
    return nil
end

-- ════════════════════════════════════════════════
-- HOP CORE: multi-coroutine spam — N luồng song song, không CD, không guard
-- ════════════════════════════════════════════════

local SPAM_THREADS = 15  -- Số luồng spam song song (tăng nếu muốn mạnh hơn)

-- TeleportInitFailed global: chỉ rollback counter, không block gì cả
TeleportService.TeleportInitFailed:Connect(function(p, reason)
    if p ~= lplr then return end
    if hopSession > 0 then
        hopSession -= 1
        if #hopHistory > 0 then
            table.remove(hopHistory, #hopHistory)
            saveHopHistory()
        end
        getgenv().hopCount        = hopSession
        getgenv().hopCountAllTime = #hopHistory
        warn(string.format("⚠️ GameFull (%s) → rollback #%d", tostring(reason), hopSession))
    end
end)

local _teleporting = false  -- chỉ dùng để block vòng [1] bên ngoài

local function doHop()
    if _teleporting then return end
    _teleporting = true

    recordHop()
    Notify(string.format("🔵 Hop #%d — %d luồng spam...", hopSession, SPAM_THREADS), 3)

    -- Spawn N coroutine cùng lúc, mỗi luồng tự tìm server và spam độc lập
    for i = 1, SPAM_THREADS do
        coroutine.wrap(function()
            while true do
                local srv = findValidServer()
                if srv then
                    saveVisited(srv.JobId)
                    pcall(TeleportService.TeleportToPlaceInstance,
                        TeleportService, srv.PlaceId, srv.JobId, lplr)
                else
                    removeOldest()
                end
                task.wait()  -- 1 frame, không CD
            end
        end)()
    end
end

-- ════════════════════════════════════════════════
-- [1] AUTO HOP THÔNG MINH
-- ════════════════════════════════════════════════
-- _teleporting đã được khai báo ở HOP CORE bên trên
-- Vòng này bỏ qua nếu đang trong spamTeleport retry

task.spawn(function()
    while true do
        task.wait(0.3)
        if not cfg("AutoHop") then continue end
        if _teleporting then continue end  -- Đang retry teleport → không trigger thêm
        pcall(function()
            local stats = lplr:FindFirstChild("PlayerStats")
            if not stats then return end

            local sk = workspace.SeaMonster:FindFirstChild("SeaKing")
            local hd = workspace.SeaMonster:FindFirstChild("HydraSeaKing")
            local gs = workspace.GhostMonster:FindFirstChild("Ghost Ship")

            local function getSpawnSec(label)
                local ok2, val = pcall(function()
                    return lplr.PlayerGui.MainGui.StarterFrame
                        .LegacyPoseFrame.SecondSea[label].Text
                end)
                if not ok2 then return 9999 end
                local h,m,s = val:match("(%d+):(%d+):(%d+)")
                return h and tonumber(h)*3600+tonumber(m)*60+tonumber(s) or 9999
            end

            local skSec = getSpawnSec("SKTimeLabel")
            local gsSec = getSpawnSec("GSTimeLabel")
            local thr   = cfg("HopThreshold")

            if skSec < thr then
                Notify("🟡 SK/HD spawn sau "..skSec.."s — giữ server", 1) return end
            if gsSec < thr then
                Notify("🟡 GS spawn sau "..gsSec.."s — giữ server", 1)   return end
            if gs and gs:FindFirstChild("HumanoidRootPart") then
                Notify("🟡 Ghost Ship đang hiện diện", 1)                 return end
            if getBossRoot() then
                Notify("🟡 Boss đang hiện diện", 1)                       return end

            -- Kiểm tra đảo / rương còn không
            local hasSK, hasHD, hasGSChest = false, false, false

            local islandFolder = workspace:FindFirstChild("Island")
            if islandFolder then
                for _, obj in ipairs(islandFolder:GetDescendants()) do
                    if obj:IsA("Model") then
                        local n = obj.Name
                        if n == "EpicChest" or n == "SeaBeastChest" or n == "DragonChest" then
                            hasSK = true
                        elseif n == "HydraChest" then
                            hasHD = true
                        end
                    end
                end
            end
            if workspace:FindFirstChild("Chest1") then hasGSChest = true end

            -- Không có gì → hop ngay
            if not hasSK and not hasHD and not hasGSChest
                and not hd
                and (not gs or not gs:FindFirstChild("HumanoidRootPart")) then
                doHop()
                return
            end

            -- Có rương → chờ nhặt rồi mới hop (vòng ngoài sẽ bị block bởi _teleporting sau khi hop)
            local initBeli = stats.beli.Value
            local initGem  = stats.Gem.Value
            local elapsed  = 0
            local hopped   = false

            while elapsed < 25 do
                task.wait(0.15)
                elapsed += 0.15
                if not cfg("AutoHop") then break end
                if _teleporting then hopped = true; break end  -- doHop đã được gọi từ ngoài → thoát

                -- Chỉ cần beli HOẶC gem tăng là đã nhận rương xong
                if stats.beli.Value > initBeli or stats.Gem.Value > initGem then
                    task.wait(0.8)
                    doHop(); hopped = true; break
                end

                -- Thoát sớm nếu rương đã biến mất (despawn hoặc đã nhặt hết)
                local stillHasChest = false
                if islandFolder then
                    for _, obj in ipairs(islandFolder:GetDescendants()) do
                        if obj:IsA("Model") then
                            local on = obj.Name
                            if on=="EpicChest" or on=="SeaBeastChest"
                                or on=="DragonChest" or on=="HydraChest" then
                                stillHasChest = true; break
                            end
                        end
                    end
                end
                for i = 1, 5 do
                    if workspace:FindFirstChild("Chest"..i) then
                        stillHasChest = true; break
                    end
                end
                if not stillHasChest then
                    Notify("🔴 Rương đã hết → hop ngay!", 1)
                    doHop(); hopped = true; break
                end
            end

            if not hopped then
                Notify("⏱ Timeout → hop tiếp!", 1)
                doHop()
            end
        end)
    end
end)

-- ════════════════════════════════════════════════
-- [2] AUTO TELEPORT LÊN BOSS / RƯƠNG
-- Ưu tiên: rương tồn tại → nhặt trước
--          không có rương → đứng cạnh boss đang sống
-- ════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        if not cfg("AutoTeleport") then unstop(); continue end
        pcall(function()
            stop()
            local wIsland = workspace.Island
            local root    = getRoot()
            if not root then return end

            -- ── Kiểm tra rương vật lý đang tồn tại ──────────────
            local hasHydraChest, hasSKChest, hasGSChest = false, false, false

            for _, n in ipairs({"Sea King Thunder","Sea King Water","Sea King Lava"}) do
                local isl = wIsland:FindFirstChild(n)
                if isl then
                    for _, obj in ipairs(isl:GetChildren()) do
                        if obj:IsA("Model") and obj.Name:match("Chest$") then
                            hasHydraChest = true; break
                        end
                    end
                end
                if hasHydraChest then break end
            end

            for _, n in ipairs({"Legacy Island1","Legacy Island2","Legacy Island3","Legacy Island4"}) do
                local isl = wIsland:FindFirstChild(n)
                if isl and isl:FindFirstChild("ChestSpawner") then
                    for _, obj in ipairs(isl.ChestSpawner:GetChildren()) do
                        if obj:IsA("Model") and obj.Name:match("Chest$") then
                            hasSKChest = true; break
                        end
                    end
                end
                if hasSKChest then break end
            end

            for i = 1, 5 do
                if workspace:FindFirstChild("Chest"..i) then
                    hasGSChest = true; break
                end
            end

            local hasAnyChest = hasHydraChest or hasSKChest or hasGSChest

            -- ── Nếu có rương → nhặt ngay, không quan tâm boss khác còn sống ──
            if hasAnyChest then
                -- Hydra chest
                if hasHydraChest then
                    for _, n in ipairs({"Sea King Thunder","Sea King Water","Sea King Lava"}) do
                        local isl = wIsland:FindFirstChild(n)
                        if isl and isl:FindFirstChild("HydraStand") then
                            root.CFrame = isl.HydraStand.CFrame
                        end
                    end
                end
                -- SK chest
                if hasSKChest then
                    for _, n in ipairs({"Legacy Island1","Legacy Island2","Legacy Island3","Legacy Island4"}) do
                        local isl = wIsland:FindFirstChild(n)
                        if isl and isl:FindFirstChild("ChestSpawner") then
                            root.CFrame = isl.ChestSpawner.CFrame
                        end
                    end
                end
                -- GS chest
                if hasGSChest then
                    local totalChests, collected = 0, 0
                    for i = 1, 5 do
                        if workspace:FindFirstChild("Chest"..i) then totalChests += 1 end
                    end
                    for i = 1, 5 do
                        local chest = workspace:FindFirstChild("Chest"..i)
                        if chest and chest:FindFirstChild("Top") then
                            root.CFrame = chest.Top.CFrame
                            task.wait(0.3)
                            collected += 1
                        end
                    end
                end
                return  -- Đã xử lý rương → thoát, không teleport sang boss
            end

            -- ── Không có rương → đứng cạnh boss đang sống ──────
            local bRoot = getBossRoot()
            if bRoot then
                root.CFrame = bRoot.CFrame * CFrame.new(0,-10,100)
            end
        end)
    end
end)

-- ════════════════════════════════════════════════
-- [3] AUTO AIM SKILL  (FIXED — autoskill_fixed.lua)
-- ✅ Fix sendSkill: đúng thứ tự prefix_tool_key
-- ✅ Fix lọc tool: dùng isBadTool() tránh equip Fruit/Compass...
-- ✅ Fix M1: gửi Down → Up đúng chuẩn (không dùng "Click")
-- ✅ Fix getWeapon(): ưu tiên SW trước DF, chờ equip đủ thời gian
-- ════════════════════════════════════════════════

-- Remote SkillAction (dùng chung cho [3] và các sub-loop)
local skillAction = ReplicatedStorage
    :WaitForChild("Chest")
    :WaitForChild("Remotes")
    :WaitForChild("Functions")
    :WaitForChild("SkillAction")

-- [FIX] Danh sách tool bị loại (không dùng để đánh)
local EXCLUDED_TOOLS = { Compass=true, LegacyPose=true, Cyborg=true }
local function isBadTool(name)
    if name:match("Fruit") then return true end
    for bad in pairs(EXCLUDED_TOOLS) do
        if name == bad or name:match(bad) then return true end
    end
    return false
end

-- [FIX] getWeapon: trả về { tool, isDF }
-- isDF=true → prefix "DF"  |  isDF=false → prefix "SW"
local function getWeapon()
    local c = getChar()
    if not c then return nil end
    -- Đang cầm gì hợp lệ?
    local eq = c:FindFirstChildOfClass("Tool")
    if eq and not isBadTool(eq.Name) then
        return { tool=eq, isDF=eq:FindFirstChild("DevilFruit")~=nil }
    end
    -- Ưu tiên kiếm/melee (SW)
    local bp = lplr:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and not isBadTool(t.Name) and not t:FindFirstChild("DevilFruit") then
                c.Humanoid:EquipTool(t)
                task.wait(0.2)
                return { tool=t, isDF=false }
            end
        end
        -- Fallback: DF
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t:FindFirstChild("DevilFruit") then
                c.Humanoid:EquipTool(t)
                task.wait(0.2)
                return { tool=t, isDF=true }
            end
        end
    end
    return nil
end

-- [FIX] sendSkill: prefix_toolName_key  + Down/Up đúng chuẩn
local function sendSkill(prefix, toolName, key, targetCF)
    local name = prefix.."_"..toolName.."_"..key
    skillAction:InvokeServer(name, {MouseHit=targetCF, Type="Down"})
    task.wait(0.05)
    skillAction:InvokeServer(name, {MouseHit=targetCF, Type="Up"})
end

-- ── AutoM1 loop (riêng biệt, rate 0.15s) ─────────────────────
task.spawn(function()
    while task.wait(0.15) do
        if not cfg("AutoSkill") then continue end
        pcall(function()
            local target = getBossRoot()
            local w      = getWeapon()
            if not target or not w then return end
            local prefix = w.isDF and "DF" or "SW"
            local tCF    = target.CFrame
            -- [FIX] M1: Down → Up (không dùng "Click")
            skillAction:InvokeServer(
                prefix.."_"..w.tool.Name.."_M1",
                {MouseHit=tCF, Type="Down"}
            )
            task.wait(0.05)
            skillAction:InvokeServer(
                prefix.."_"..w.tool.Name.."_M1",
                {MouseHit=tCF, Type="Up"}
            )
        end)
    end
end)

-- ── AutoSkill Z/X/C/V/E loop (rate 0.4s) ─────────────────────
task.spawn(function()
    local KEYS = {"Z","X","C","V","E"}
    while task.wait(0.4) do
        if not cfg("AutoSkill") then continue end
        pcall(function()
            local target = getBossRoot()
            local w      = getWeapon()
            if not target or not w then return end

            local tCF   = target.CFrame
            local tName = w.tool.Name

            -- Ope Room check: nếu boss ngoài Room → dùng DF_OpOp_Z kéo vào
            local opeRoom = workspace:FindFirstChild("OpeRoom"..pName)
            if opeRoom then
                local rCF, rSz = opeRoom.CFrame, opeRoom.Size
                local out, total = 0, 0
                for _, boss in pairs(workspace.SeaMonster:GetChildren()) do
                    if boss:FindFirstChild("HumanoidRootPart") and boss.Name ~= "Hydra's Minion" then
                        total += 1
                        local bp = boss.HumanoidRootPart.Position
                        if not (math.abs(bp.X-rCF.Position.X)<=rSz.X/2
                            and math.abs(bp.Y-rCF.Position.Y)<=rSz.Y/2
                            and math.abs(bp.Z-rCF.Position.Z)<=rSz.Z/2) then
                            out += 1
                        end
                    end
                end
                if total > 0 and (out/total) > 0.5 then
                    task.spawn(function()
                        skillAction:InvokeServer("DF_OpOp_Z",{MouseHit=CFrame.new(),Type="Down"})
                        task.wait(0.05)
                        skillAction:InvokeServer("DF_OpOp_Z",{MouseHit=CFrame.new(),Type="Up"})
                    end)
                end
            else
                task.spawn(function()
                    skillAction:InvokeServer("DF_OpOp_Z",{MouseHit=CFrame.new(),Type="Down"})
                    task.wait(0.05)
                    skillAction:InvokeServer("DF_OpOp_Z",{MouseHit=CFrame.new(),Type="Up"})
                end)
            end

            -- [FIX] Kioru V2 / Ope Ope mode
            local hasOpeV2 = lplr.Backpack:FindFirstChild("Kioru V2") ~= nil
                or tName == "Kioru V2"
            if hasOpeV2 then
                for _, key in ipairs({"X","C","V"}) do
                    task.spawn(function() sendSkill("DF","OpOp",key,tCF) end)
                end
                for _, key in ipairs({"M1","Z","X"}) do
                    task.spawn(function() sendSkill("SW","Kioru V2",key,tCF) end)
                end
                return
            end

            -- [FIX] Tool thường: prefix đúng theo loại, KHÔNG gửi cả SW lẫn DF cùng lúc
            local prefix = w.isDF and "DF" or "SW"
            for _, key in ipairs(KEYS) do
                task.spawn(function()
                    sendSkill(prefix, tName, key, tCF)
                end)
            end

            -- Nếu là Sword → thêm DF_OpOp_Z để pull boss vào room
            if not w.isDF then
                task.spawn(function()
                    skillAction:InvokeServer("DF_OpOp_Z",{MouseHit=CFrame.new(),Type="Down"})
                    task.wait(0.05)
                    skillAction:InvokeServer("DF_OpOp_Z",{MouseHit=CFrame.new(),Type="Up"})
                end)
            end
        end)
    end
end)

-- ════════════════════════════════════════════════
-- [4] AUTO START / SKIP LOADING / HAKI
-- ════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        if not cfg("AutoStart") then continue end
        pcall(function()
            local pgui = lplr:FindFirstChild("PlayerGui")
            if not pgui then return end

            -- Skip màn loading
            if pgui:FindFirstChild("LoadingGUI") then
                local lg = pgui.LoadingGUI
                if lg:FindFirstChild("Play") then
                    ReplicatedStorage.Chest.Remotes.Functions.EtcFunction
                        :InvokeServer("EnterTheGame",{})
                    repeat task.wait() until lplr.Character
                        and lplr.Character:FindFirstChild("Humanoid")
                    lplr.Character.Humanoid.Health = 0
                end
            end

            -- Chọn Hard mode
            if pgui:FindFirstChild("ChooseMap") then
                ReplicatedStorage:WaitForChild("ChooseMapRemote"):FireServer("Hard")
            end

            -- Armament Haki
            local cw = workspace:FindFirstChild("CharacterWorkshop")
            if cw and not cw:FindFirstChild(pName.."ArmamentGroup") then
                ReplicatedStorage.Chest.Remotes.Events.Armament:FireServer()
            end

            -- Kenbun Haki
            local pcChars = workspace:FindFirstChild("PlayerCharacters")
            if pcChars and pcChars:FindFirstChild(pName) then
                local kenOpen = pcChars[pName]:FindFirstChild("Services")
                    and pcChars[pName].Services:FindFirstChild("KenOpen")
                if kenOpen and kenOpen.Value == false then
                    ReplicatedStorage.Chest.Remotes.Functions.KenEvent:InvokeServer()
                end
            end

            -- Golden Arena auto start
            if sea(4) then
                local gaGui = pgui:FindFirstChild("GoldenArena GUI")
                if gaGui and gaGui:FindFirstChild("StartButton") then
                    ReplicatedStorage.GoldenArenaEvents.StartEvent:FireServer()
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════
-- [5] AUTO CẤT FRUIT  (FIXED — autostore_fixed.lua)
-- ✅ Fix vòng lặp chết: dùng continue thay vì return
-- ✅ Fix chờ GUI EatFruitBecky mở đúng cách (retry + WaitForChild)
-- ✅ Fix reload storedFruits sau mỗi lần cất (không bị cache cũ)
-- ✅ Fix equip → chờ → click đúng thứ tự
-- ════════════════════════════════════════════════
local fruitStorage = ReplicatedStorage:FindFirstChild("Chest")
    and ReplicatedStorage.Chest:FindFirstChild("Fruits")

-- [FIX] Chờ nút Collect/Store xuất hiện (tối đa timeout giây)
local function waitForCollectBtn(timeout)
    timeout = timeout or 3
    local t0 = tick()
    while tick() - t0 < timeout do
        local gui      = lplr.PlayerGui:FindFirstChild("EatFruitBecky")
        local dialogue = gui and gui:FindFirstChild("Dialogue")
        if dialogue then
            local btn = dialogue:FindFirstChild("Collect") or dialogue:FindFirstChild("Store")
            if btn and btn.Visible then return btn end
        end
        task.wait(0.1)
    end
    return nil
end

-- [FIX] Cất 1 trái: equip → chờ GUI → click Collect → xác nhận biến mất
local function storeFruit(fruitName)
    local backpack = lplr:FindFirstChild("Backpack")
    local c        = getChar()
    if not backpack or not c then return false end

    local fruitInBag = backpack:FindFirstChild(fruitName)
    if not fruitInBag then return false end

    -- 1. Equip trái vào tay
    fruitInBag.Parent = c
    task.wait(0.6)

    -- 2. Đảm bảo đang cầm (retry nếu equip chậm)
    if not c:FindFirstChild(fruitName) then
        local retry = backpack:FindFirstChild(fruitName)
        if retry then
            retry.Parent = c
            task.wait(0.6)
        end
    end
    if not c:FindFirstChild(fruitName) then
        warn("⚠️ Không equip được " .. fruitName)
        return false
    end

    -- 3. Click màn hình kích hoạt menu trái
    game:GetService("VirtualUser"):ClickButton1(Vector2.new(300,300))
    task.wait(0.3)

    -- 4. Chờ nút Collect (tối đa 3s), thử lại nếu chưa thấy
    local collectBtn = waitForCollectBtn(3)
    if not collectBtn then
        game:GetService("VirtualUser"):ClickButton1(Vector2.new(300,300))
        task.wait(0.8)
        collectBtn = waitForCollectBtn(2)
    end
    if collectBtn then
        ClickButton(collectBtn)
        task.wait(0.5)
    end

    -- 5. Xác nhận trái đã biến mất (tối đa 4s), bấm lại nếu GUI vẫn còn
    local elapsed = 0
    while elapsed < 4 do
        task.wait(0.4)
        elapsed += 0.4
        if not backpack:FindFirstChild(fruitName) and not c:FindFirstChild(fruitName) then
            return true
        end
        local btn2 = waitForCollectBtn(0.5)
        if btn2 then ClickButton(btn2) end
    end

    -- Thất bại → trả về balo
    warn("⚠️ Cất thất bại: " .. fruitName .. " → trả về Backpack")
    local stuck = c:FindFirstChild(fruitName)
    if stuck then stuck.Parent = backpack end
    return false
end

task.spawn(function()
    while task.wait(1) do
        -- [FIX] continue (không return) → vòng lặp không chết khi tắt
        if not cfg("AutoCatFruit") then continue end
        pcall(function()
            if not fruitStorage then return end
            local stats    = lplr:FindFirstChild("PlayerStats")
            local fStore   = stats and stats:FindFirstChild("FruitStore")
            local fLimit   = stats and stats:FindFirstChild("FruitStorage")
            -- [FIX] Stats chưa load → continue (không crash)
            if not fStore or not fLimit then
                warn("⚠️ Chờ PlayerStats...") return
            end

            -- [FIX] Reload storedFruits MỖI VÒNG (không dùng cache cũ)
            local ok, storedFruits = pcall(function()
                return HttpService:JSONDecode(fStore.Value)
            end)
            if not ok or type(storedFruits) ~= "table" then storedFruits = {} end

            local limit  = tonumber(fLimit.Value) or 1
            local bp     = lplr:FindFirstChild("Backpack")
            local c      = getChar()
            if not bp or not c then return end

            for _, fruitObj in ipairs(fruitStorage:GetChildren()) do
                if not cfg("AutoCatFruit") then break end
                local fn  = fruitObj.Name
                local qty = tonumber(storedFruits[fn]) or 0
                if qty < limit and bp:FindFirstChild(fn) then
                    storeFruit(fn)
                    -- [FIX] Reload sau mỗi lần cất để qty cập nhật đúng
                    local ok2, fresh = pcall(function()
                        return HttpService:JSONDecode(fStore.Value)
                    end)
                    if ok2 and type(fresh) == "table" then
                        storedFruits = fresh
                    end
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════
-- [6] AUTO VỨT FRUIT
-- ════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.5)
        if not cfg("AutoDropFruit") then continue end
        pcall(function()
            local bp  = lplr:FindFirstChild("Backpack")
            local c   = getChar()
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not bp or not hum or not c then return end
            local eq = hum:FindFirstChildOfClass("Tool")
            if not (eq and eq:FindFirstChild("FakeHandle")) then
                for _, tool in ipairs(bp:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Handle") and tool.Name ~= "LegacyPose" then
                        hum:EquipTool(tool)
                        task.wait(0.5)
                        eq = tool
                        break
                    end
                end
            end
            if eq and eq:FindFirstChild("Handle") then
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(50,50))
                task.wait(1)
            end
            local gui = lplr.PlayerGui:FindFirstChild("EatFruitBecky")
            local dropBtn = gui and gui:FindFirstChild("Dialogue")
                and gui.Dialogue:FindFirstChild("Drop")
            if dropBtn then ClickButton(dropBtn) end
            task.wait(0.8)
        end)
    end
end)

-- ════════════════════════════════════════════════
-- [7] XÓA EFFECT (giảm lag đáng kể)
-- ════════════════════════════════════════════════
local function deleteEffects()
    pcall(function()
        local chest = ReplicatedStorage:FindFirstChild("Chest")
        if not chest then return end
        for _, v in pairs(chest:GetChildren()) do
            if v.Name == "FruitEffect" or v.Name == "SwordEffect" then
                v:Destroy()
            end
        end
    end)
end

if cfg("AutoDeleteEffect") then deleteEffects() end

task.spawn(function()
    local chest = ReplicatedStorage:FindFirstChild("Chest")
    if not chest then return end
    chest.ChildAdded:Connect(function(child)
        if cfg("AutoDeleteEffect")
            and (child.Name=="FruitEffect" or child.Name=="SwordEffect") then
            task.wait(0.05)
            pcall(function() child:Destroy() end)
        end
    end)
end)

-- ════════════════════════════════════════════════
-- [8] AUTO REJOIN KHI LỖI
-- ════════════════════════════════════════════════
local rejoinConn
local function setupRejoin()
    if rejoinConn then rejoinConn:Disconnect(); rejoinConn = nil end
    if not cfg("AutoRejoin") then return end
    pcall(function()
        local overlay = CoreGui:WaitForChild("RobloxPromptGui",5)
        if not overlay then return end
        local promptOverlay = overlay:WaitForChild("promptOverlay",5)
        if not promptOverlay then return end
        rejoinConn = promptOverlay.ChildAdded:Connect(function(child)
            if child.Name == "ErrorPrompt"
                and child:FindFirstChild("MessageArea")
                and child.MessageArea:FindFirstChild("ErrorFrame") then
                task.wait(3)
                Notify("🔵 Lỗi phát hiện → rejoin...", 3)
                TeleportService:Teleport(sea(4) and 4520749081 or game.PlaceId)
            end
        end)
    end)
end
setupRejoin()

-- ════════════════════════════════════════════════
-- [9] FREE POSE (UI SecondSea / ThirdSea)
-- ════════════════════════════════════════════════
local function getSeaPose()
    if sea(2) then return "SecondSea"
    elseif sea(3) then return "ThirdSea"
    else return "" end
end

task.spawn(function()
    local ok, clientBeckUI = pcall(function()
        return ReplicatedStorage
            :WaitForChild("Chest",10)
            :WaitForChild("Remotes",10)
            :WaitForChild("Bindables",10)
            :WaitForChild("ClientBeckUI",10)
    end)
    if not ok or not clientBeckUI then return end
    while true do
        task.wait(2)
        if not cfg("FreePose") then continue end
        pcall(function()
            clientBeckUI:Fire("LegacyPoseFrame",{Sea=getSeaPose(),VisibleType=true})
        end)
    end
end)

-- ════════════════════════════════════════════════
-- [10] AUTO MUA KEY
-- ════════════════════════════════════════════════
local buyKeyRemote = ReplicatedStorage.Chest.Remotes.Functions.BuyKey

task.spawn(function()
    while true do
        task.wait(0.2)
        if not cfg("AutoBuyKey") then continue end
        pcall(function()
            local k = cfg("SelectedKey")
            if k == "Platinum Key" then return end
            buyKeyRemote:InvokeServer(k, cfg("KeyQuantity"))
        end)
    end
end)

-- ════════════════════════════════════════════════
-- [11] AUTO MỞ KEY x10
-- ════════════════════════════════════════════════
local useKeyRemote = ReplicatedStorage.Chest.Remotes.Functions.UseKey

task.spawn(function()
    while true do
        task.wait(0.1)
        if not cfg("AutoOpenKey") then continue end
        pcall(function()
            useKeyRemote:InvokeServer(cfg("SelectedKey"), "Open10")
        end)
    end
end)

-- ════════════════════════════════════════════════
-- [12] AUTO ĐỔI FRUIT → KEY
-- ════════════════════════════════════════════════
local dealFruitRemote = ReplicatedStorage.Chest.Remotes.Functions.DealFruit
local availableFruits = {}
local excludedFruits  = {
    DoughFruit=true, GateFruit=true, DragonFruit=true,
    PhoenixFruit=true, ToyFruit=true, OpFruit=true, MelodyFruit=true
}

pcall(function()
    for _, f in ipairs(ReplicatedStorage.Chest.Fruits:GetChildren()) do
        table.insert(availableFruits, f.Name)
    end
end)

local function getFruitsInBP()
    local bp = lplr:FindFirstChild("Backpack")
    if not bp then return {} end
    local res = {}
    for _, item in ipairs(bp:GetChildren()) do
        if table.find(availableFruits, item.Name) and not excludedFruits[item.Name] then
            table.insert(res, item.Name)
        end
    end
    return res
end

task.spawn(function()
    while true do
        task.wait(4)
        if not cfg("AutoConvertFruit") then continue end
        pcall(function()
            local fruits = getFruitsInBP()
            if #fruits > 0 then
                dealFruitRemote:InvokeServer(cfg("SelectedKey"), fruits)
                Notify("✅ Đổi "..#fruits.." fruit → "..cfg("SelectedKey"), 3)
            end
        end)
    end
end)

-- ════════════════════════════════════════════════
-- ════════════════════════════════════════════════
-- WEBHOOK SYSTEM  (FIXED — webhook_fixed.lua)
-- ✅ Fix checkChests(): tìm rương trong workspace.Island descendants
-- ✅ Fix getIslandInfo(): đọc đúng SurfaceGui → TextLabel Countdown
-- ✅ Fix SafeDecode(): không crash khi value là table sẵn
-- ✅ Fix embed: thêm Beli, Gem, Level, Server info, hopCount
-- ✅ Fix UTF-8 vỡ: toàn bộ text ASCII/plain
-- ════════════════════════════════════════════════
local Webhook_HydraChest = "https://discord.com/api/webhooks/1467903010062729438/S151mUICYjrXfrLE9oZFezgkEbsvIeHZSzvt1bevS0vKDmFxMe9a9M9fd2UqMTV8Osetssaw"
local Webhook_URLshop    = {}

-- Webhook chính từ CONFIG
if cfg("Webhook_URL2") and cfg("Webhook_URL2") ~= "" then
    table.insert(Webhook_URLshop, cfg("Webhook_URL2"))
end

-- [FIX] SafeDecode: handle khi value đã là table (không crash)
local function SafeDecode(val)
    if type(val) == "table" then return val end
    if type(val) == "string" and val ~= "" then
        local ok, res = pcall(function() return HttpService:JSONDecode(val) end)
        if ok and type(res) == "table" then return res end
    end
    return {}
end

-- [FIX] getCurrentIsland: tìm đúng path workspace.Island → tên đảo → ClockTime → SurfaceGui
local function getCurrentIsland()
    local islandFolder = workspace:FindFirstChild("Island")
    if not islandFolder then return nil, nil end

    for _, name in ipairs({"Sea King Thunder", "Sea King Water", "Sea King Lava"}) do
        local isl = islandFolder:FindFirstChild(name)
        if isl and isl:FindFirstChild("ClockTime")
            and isl.ClockTime:FindFirstChild("SurfaceGui") then
            return isl, "Hydra"
        end
    end

    for i = 1, 4 do
        local isl = islandFolder:FindFirstChild("Legacy Island"..i)
        if isl and isl:FindFirstChild("ClockTime")
            and isl.ClockTime:FindFirstChild("SurfaceGui") then
            return isl, "Sea King"
        end
    end

    return nil, nil
end

-- [FIX] getIslandInfo: đọc đúng TextLabel Countdown / Number trong SurfaceGui
local function getIslandInfo()
    local island, islandType = getCurrentIsland()
    if not island then return "Unknown", "N/A", "N/A" end

    local sinkTime = "N/A"
    local gateNum  = "N/A"

    local ct  = island:FindFirstChild("ClockTime")
    local gui = ct and ct:FindFirstChild("SurfaceGui")
    if gui then
        local lbl = gui:FindFirstChild("Countdown")
            or gui:FindFirstChildOfClass("TextLabel")
        if lbl then sinkTime = lbl.Text end

        if islandType == "Sea King" then
            local numLbl = gui:FindFirstChild("Number")
            if numLbl then gateNum = numLbl.Text end
        end
    end

    return islandType, gateNum, sinkTime
end

-- [FIX] checkChests: tìm rương trong Island descendants, bỏ qua Gacha Background
local function checkChests()
    local found        = {}
    local islandFolder = workspace:FindFirstChild("Island")
    if islandFolder then
        local tierMap = {
            EpicChest     = "Tier1 (Epic)",
            SeaBeastChest = "Tier2 (SeaBeast)",
            DragonChest   = "Tier3 (Dragon)",
            HydraChest    = "Tier4 (Hydra)",
        }
        for _, obj in ipairs(islandFolder:GetDescendants()) do
            if obj:IsA("Model") then
                local tier = tierMap[obj.Name]
                if tier and (not obj.Parent or obj.Parent.Name ~= "Gacha Background") then
                    table.insert(found, tier)
                end
            end
        end
    end
    -- Ghost Ship chests (Chest1..5 trực tiếp workspace)
    for i = 1, 5 do
        if workspace:FindFirstChild("Chest"..i) then
            table.insert(found, "GS Chest "..i)
        end
    end
    return found
end

-- [FIX] getPlayerData: đọc đúng Material + FruitStore, cộng thêm trái đang cầm/balo
local function getPlayerData()
    local stats = lplr:FindFirstChild("PlayerStats")
    if not stats then return {}, {} end

    local matData   = SafeDecode(stats:FindFirstChild("Material")  and stats.Material.Value  or {})
    local fruitData = SafeDecode(stats:FindFirstChild("FruitStore") and stats.FruitStore.Value or {})

    local targetMats = {
        "Sea King's Fin","Hydra's Tail","Sea's Wraith",
        "Sea King's Blood","Fortune Tales","Copper Key",
        "Sea King's Scale","Hydra's Scale"
    }
    local items = {}
    for _, key in ipairs(targetMats) do
        local qty = tonumber(matData[key]) or 0
        if qty > 0 then
            table.insert(items, string.format("  %-22s x%d", key, qty))
        end
    end

    local targetFruits = {
        "DoughFruit","DragonFruit","PhoenixFruit","ToyFruit","GateFruit","MelodyFruit"
    }
    local fruits = {}
    for _, fn in ipairs(targetFruits) do
        local qty = tonumber(fruitData[fn]) or 0
        local bp  = lplr:FindFirstChild("Backpack")
        local ch  = lplr.Character
        if bp and bp:FindFirstChild(fn) then qty += 1 end
        if ch and ch:FindFirstChild(fn) then qty += 1 end
        if qty > 0 then
            table.insert(fruits, string.format("  %-16s x%d", fn, qty))
        end
    end

    return items, fruits
end

-- [FIX] sendWebhook: embed mới với đầy đủ field, màu theo loại đảo, ASCII safe
local function sendWebhook(url, statusMsg, includeData)
    if not httprequest then
        warn("Executor khong ho tro request!")
        return
    end

    local islandType, gateNum, sinkTime = getIslandInfo()
    local chests     = checkChests()
    local chestStr   = #chests > 0 and table.concat(chests, ", ") or "Khong co ruong"
    local serverName = tostring(game.JobId):sub(1, 8).."..."

    local colorMap = { Hydra=0x00BFFF, ["Sea King"]=0xFF6600, Unknown=0x888888 }
    local embedColor = colorMap[islandType] or 0x888888

    local stats = lplr:FindFirstChild("PlayerStats")
    local beli  = stats and stats:FindFirstChild("beli")  and stats.beli.Value  or 0
    local gem   = stats and stats:FindFirstChild("Gem")   and stats.Gem.Value   or 0
    local lvl   = stats and stats:FindFirstChild("lvl")   and stats.lvl.Value   or 0
    local pCount = #Players:GetPlayers()
    local pMax   = Players.MaxPlayers

    local function fNum(n)
        n = tonumber(n) or 0
        if n >= 1e9 then return string.format("%.1fB", n/1e9)
        elseif n >= 1e6 then return string.format("%.1fM", n/1e6)
        elseif n >= 1e3 then return string.format("%.1fK", n/1e3)
        else return tostring(n) end
    end

    local fields = {}

    -- Field 1: Server + đảo
    local islandLine = islandType ~= "Unknown"
        and string.format("%s | Gate: %s | Chim sau: %s", islandType, gateNum, sinkTime)
        or "Chua tim duoc dao"
    table.insert(fields, {
        name   = "Thong tin server",
        value  = string.format("```%s\nServer: %s | Player: %d/%d\nRuong: %s```",
            islandLine, serverName, pCount, pMax, chestStr),
        inline = false
    })

    -- Field 2: Stats player
    table.insert(fields, {
        name   = "Player Stats",
        value  = string.format("```Name : %s\nLvl  : %s\nBeli : %s\nGem  : %s```",
            lplr.Name, fNum(lvl), fNum(beli), fNum(gem)),
        inline = true
    })

    -- Field 3: Hop count (session + alltime + 24h)
    local hSession, hAllTime, h24 = getHopStats()
    table.insert(fields, {
        name   = "Hop Count",
        value  = string.format("```Session : %d lan\nAll-time: %d lan\n24h     : %d lan```",
            hSession, hAllTime, h24),
        inline = true
    })

    -- Field 4: Trạng thái
    table.insert(fields, {
        name   = "Trang thai",
        value  = string.format("```%s```", statusMsg or "N/A"),
        inline = true
    })

    -- Field 5+6: Items & Fruits (tuỳ chọn)
    if includeData then
        local items, fruits = getPlayerData()
        if #items > 0 then
            table.insert(fields, {
                name   = "Materials",
                value  = "```"..table.concat(items, "\n").."```",
                inline = true
            })
        end
        if #fruits > 0 then
            table.insert(fields, {
                name   = "Fruits",
                value  = "```"..table.concat(fruits, "\n").."```",
                inline = true
            })
        end
    end

    local executor = "Unknown"
    pcall(function() executor = identifyexecutor() or "Unknown" end)

    local embed = {
        author    = { name = lplr.Name.." | "..executor },
        title     = "[ "..(islandType ~= "Unknown" and islandType or "King Legacy").." ]",
        color     = embedColor,
        fields    = fields,
        footer    = {
            text     = "KingHub | "..os.date("%H:%M:%S"),
            icon_url = "https://i.imgur.com/gtePhRZ.jpeg"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z", os.time())
    }

    local ok, err = pcall(function()
        httprequest({
            Url     = url,
            Method  = "POST",
            Headers = {["Content-Type"]="application/json"},
            Body    = HttpService:JSONEncode({embeds={embed}})
        })
    end)
    if ok then print("Webhook OK: "..statusMsg)
    else warn("Webhook LOI: "..tostring(err)) end
end

-- Gửi 1 lần khi khởi động
task.spawn(function()
    task.wait(2)
    for _, url in ipairs(Webhook_URLshop) do
        pcall(sendWebhook, url, "Script da khoi dong!", true)
    end
end)

-- Theo dõi rương (mỗi 4s)
task.spawn(function()
    local lastSent = false
    while task.wait(4) do
        local chests = checkChests()
        if #chests > 0 then
            if not lastSent then
                local msg = "Tim thay: "..table.concat(chests, ", ")
                for _, url in ipairs(Webhook_URLshop) do
                    pcall(sendWebhook, url, msg, true)
                end
                local iType = getIslandInfo()
                if iType == "Hydra" then
                    pcall(sendWebhook, Webhook_HydraChest, "Hydra Chest xuat hien!", false)
                end
                lastSent = true
            end
        else
            lastSent = false
        end
    end
end)

-- ANTI-AFK (giữ phiên)
-- ════════════════════════════════════════════════
task.spawn(function()
    if game.PlaceId ~= 9821272782 then
        getgenv().Press = function(v)
            VIM:SendKeyEvent(true,v,false,game)
        end
        while true do
            task.wait(500)
            pcall(function() getgenv().Press("RightBracket") end)
        end
    else
        while true do
            task.wait(500)
            pcall(function() keypress(0xDD) end)
        end
    end
end)

-- ════════════════════════════════════════════════
-- THÔNG BÁO KHỞI ĐỘNG + IN CONSOLE
-- ════════════════════════════════════════════════
task.delay(1, function()
    Notify("✅ KAITUN KING HOP loaded!\nSửa CONFIG ở đầu script để đổi tính năng.", 5)
end)

local function B(v) return v and "ON " or "OFF" end
print("=== KAITUN KING HOP - CONFIG ===")
