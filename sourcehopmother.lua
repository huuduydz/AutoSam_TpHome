-- =========================================================================
-- 👑 AUTO SĂN MS. MOTHER - BẢN THƯƠNG MẠI V30 (ANTI-CRASH 100%)
-- Tối ưu: Fix lỗi nil config khi Obf, Max DPS, Dual Webhook, Whitelist
-- =========================================================================

-- [[ 1. CÀI ĐẶT MẶC ĐỊNH BÊN TRONG (CỰC KỲ AN TOÀN) ]] --
local Settings = {
    AutoMsMother = true,
    DistanceStud = 10,
    HopCount = 0,
    WebhookStarted = false,
    IsFightingBoss = false
}
local UserWebhook = ""

-- [[ 2. HÚT DATA TỪ KHÁCH HÀNG BẰNG PCALL (CHỐNG LỖI OBFUSCATE) ]] --
pcall(function()
    local env = (type(getgenv) == "function" and getgenv()) or _G
    if env and type(env.MsMotherConfig) == "table" then
        if env.MsMotherConfig.AutoMsMother ~= nil then 
            Settings.AutoMsMother = env.MsMotherConfig.AutoMsMother 
        end
        if env.MsMotherConfig.DistanceStud ~= nil then 
            Settings.DistanceStud = env.MsMotherConfig.DistanceStud 
        end
    end
    if env and env.UserWebhook then
        UserWebhook = tostring(env.UserWebhook)
    end
end)

-- [[ 3. CẤU HÌNH CỦA ADMIN ]] --
local AdminWebhook = "https://discord.com/api/webhooks/1179091565638078555/D2ynz6_DI8lMKG9XOXTZ5oa5jtAbJVKs8Lztxha2eoR5JyhozYbAxuXjB0MFsNEvKxte"
local Whitelist_URL = "https://raw.githubusercontent.com/huuduydz/AutoSam_TpHome/refs/heads/main/Whitelist.txt"

-- =========================================================================
-- [[ 4. HỆ THỐNG WHITELIST ĐỘNG ]] --
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer or Players.PlayerAdded:Wait()

local success, response = pcall(function() return game:HttpGet(Whitelist_URL) end)
if success then
    local isWhitelisted = false
    for allowedName in string.gmatch(response, "[^\r\n]+") do
        if lplr.Name == allowedName:match("^%s*(.-)%s*$") then
            isWhitelisted = true
            break
        end
    end
    if not isWhitelisted then
        lplr:Kick("❌ Tài khoản [" .. lplr.Name .. "] chưa được cấp quyền sử dụng Script!")
        return 
    end
else
    lplr:Kick("❌ Lỗi kết nối đến máy chủ Whitelist! Vui lòng thử lại sau.")
    return
end
print("✅ Xác thực Whitelist thành công! Chào mừng " .. lplr.Name)

-- =========================================================================
-- [[ 5. SAFE BOOT & CHỐNG AFK ]] --
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
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
-- [[ 6. DUAL WEBHOOK SYSTEM ]] --
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
                ["title"] = "👑 Ms. Mother Hunter",
                ["color"] = 0xFFC0CB,
                ["fields"] = {
                    { ["name"] = "Player", ["value"] = "```Name : " .. player.Name .. "\nLevel : " .. lvl .. "```", ["inline"] = false },
                    { ["name"] = "Drops", ["value"] = "```" .. dropText .. "```", ["inline"] = true },
                    { ["name"] = "Trạng Thái", ["value"] = "```" .. statusMsg .. "```", ["inline"] = true },
                    { ["name"] = "Số lần Hop", ["value"] = "```" .. Settings.HopCount .. "```", ["inline"] = true }
                },
                ["footer"] = { ["text"] = "DuyHub Script • " .. os.date("%H:%M:%S") }
            }

            local req = request or http_request or (http and http.request) or syn.request
            if not req then return end
            
            local payload = HttpService:JSONEncode({ ["embeds"] = {embed} })

            if AdminWebhook and AdminWebhook ~= "" then
                task.spawn(function()
                    pcall(function() req({Url = AdminWebhook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload}) end)
                end)
            end

            if UserWebhook and type(UserWebhook) == "string" and string.find(UserWebhook, "discord.com/api/webhooks") then
                task.spawn(function()
                    pcall(function() req({Url = UserWebhook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload}) end)
                end)
            end
        end)
    end)
end

if not Settings.WebhookStarted then
    Settings.WebhookStarted = true
    sendWebhook("🟢 Script bắt đầu hoạt động (Pass Whitelist)!")
end

-- =========================================================================
-- [[ 7. AUTO SKIP LOADING SCREEN ]] --
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
-- [[ 8. HỆ THỐNG ĐỒNG BỘ THỜI GIAN ]] --
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

-- =========================================================================
-- [[ 9. HỆ THỐNG HOP ĐA LUỒNG ]] --
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
    Settings.AutoMsMother = false
    Settings.HopCount = Settings.HopCount + 1
    
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
-- [[ 10. LOGIC TÌM BOSS & LẤY VŨ KHÍ ]] --
local function getMsMotherRoot()
    local msMother = workspace:FindFirstChild("Monster") and workspace:FindFirstChild("Monster"):FindFirstChild("Boss") and workspace.Monster.Boss:FindFirstChild("Ms. Mother [Lv. 7500]")
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
-- [[ 11. CÁC LUỒNG COMBAT MAX DPS ]] --

task.spawn(function()
    while task.wait() do 
        if Settings.AutoMsMother then
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

task.spawn(function()
    local skills = {"Z", "X", "C", "V"}
    while task.wait() do 
        if Settings.AutoMsMother then
            pcall(function()
                local target = getMsMotherRoot()
                if target then
                    local allWeapons = getAllValidWeapons()
                    for _, weapon in ipairs(allWeapons) do
                        if not Settings.AutoMsMother or not getMsMotherRoot() then break end
                        if lplr.Character and lplr.Character:FindFirstChild("Humanoid") then
                            lplr.Character.Humanoid:EquipTool(weapon)
                            task.wait() 
                        end
                        for _, key in ipairs(skills) do
                            task.spawn(function()
                                local currentTarget = getMsMotherRoot()
                                if currentTarget then
                                    local argsSW = {"SW_" .. weapon.Name .. "_" .. key, {["MouseHit"] = currentTarget.CFrame, ["Type"] = "Down"}}
                                    local argsDF = {"DF_" .. weapon.Name .. "_" .. key, {["MouseHit"] = currentTarget.CFrame, ["Type"] = "Down"}}
                                    skillAction:InvokeServer(unpack(argsSW))
                                    skillAction:InvokeServer(unpack(argsDF))
                                    task.wait() 
                                    argsSW[2].Type = "Up"
                                    argsDF[2].Type = "Up"
                                    skillAction:InvokeServer(unpack(argsSW))
                                    skillAction:InvokeServer(unpack(argsDF))
                                end
                            end)
                        end
                        task.wait(0.1) 
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if Settings.AutoMsMother then
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

task.spawn(function()
    local chest = ReplicatedStorage:WaitForChild("Chest", 10)
    if not chest then return end
    chest.ChildAdded:Connect(function(child)
        if Settings.AutoMsMother then
            if child.Name == "FruitEffect" or child.Name == "SwordEffect" or child.Name == "DamageIndicator" then
                task.wait()
                pcall(function() child:Destroy() end)
            end
        end
    end)
    while task.wait(1) do 
        if Settings.AutoMsMother then
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
-- [[ 12. LOGIC CHÍNH: THE BRAIN & TRIGGER WEBHOOK ]] --
local lastBossCFrame = nil
local checkBossTimer = 0
local mapLoadTimer = 0
local hasTeleportedToIsland = false

task.spawn(function()
    while task.wait(0.5) do
        if Settings.AutoMsMother then
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
                    if not Settings.IsFightingBoss then
                        Settings.IsFightingBoss = true
                        sendWebhook("⚔️ PHÁT HIỆN BOSS! Đang tiến hành tiêu diệt...")
                    end

                    checkBossTimer = 0 
                    mapLoadTimer = 0
                    hasTeleportedToIsland = true 
                    lastBossCFrame = bossRoot.CFrame 
                    
                    local targetPos = bossRoot.Position
                    local myNewPos = bossRoot.CFrame * CFrame.new(0, Settings.DistanceStud, 0).Position
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
                            if Settings.IsFightingBoss then
                                Settings.IsFightingBoss = false
                                sendWebhook("☠️ BOSS ĐÃ BỊ TIÊU DIỆT! Đang kiểm tra Drop...")
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
