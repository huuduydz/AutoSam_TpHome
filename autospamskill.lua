--[[
    Cập nhật:
    ✅ Thêm luồng Auto Click M1 riêng (Tốc độ cao)
    ✅ Tự động nhận diện vũ khí để Click
    ✅ Vẫn giữ luồng Spam Skill (Z, X, C, V)
]]

print("=== BẮT ĐẦU TEST V2: SKILL + CLICK M1 ===")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local workspace = game.Workspace

-- ============================================
-- 1. HÀM TÌM MỤC TIÊU
-- ============================================
local function getBossRoot()
    local targetRoot = nil
    local closestDist = 500

    -- Ưu tiên Boss
    local bossFolders = {workspace:FindFirstChild("SeaMonster"), workspace:FindFirstChild("GhostMonster")}
    for _, folder in pairs(bossFolders) do
        if folder then
            for _, boss in pairs(folder:GetChildren()) do
                if boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                    return boss.HumanoidRootPart
                end
            end
        end
    end

    -- Nếu không có Boss -> Tìm Quái gần nhất
    local char = lplr.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v ~= char and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                if not Players:GetPlayerFromCharacter(v) then
                    local dist = (char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        targetRoot = v.HumanoidRootPart
                    end
                end
            end
        end
    end
    return targetRoot
end

-- ============================================
-- 2. HÀM LẤY VŨ KHÍ (AUTO EQUIP)
-- ============================================
local function getWeapon()
    local char = lplr.Character
    if not char then return nil end
    
    -- Kiểm tra tay đang cầm gì
    local tool = char:FindFirstChildOfClass("Tool")
    
    -- Nếu đang cầm Tool và không phải Trái Ác Quỷ (thường tên có Fruit) thì OK
    if tool and not tool.Name:match("Fruit") then
        return tool
    end
    
    -- Nếu chưa cầm, lục Balo lấy Kiếm/Melee ra
    for _, t in pairs(lplr.Backpack:GetChildren()) do
        if t:IsA("Tool") and not t.Name:match("Fruit") and not t.Name:match("Compass") then
            char.Humanoid:EquipTool(t)
            return t
        end
    end
    return nil
end

-- ============================================
-- 3. LUỒNG AUTO CLICK M1 (RIÊNG BIỆT - TỐC ĐỘ CAO)
-- ============================================
task.spawn(function()
    print("⚔️ Đã kích hoạt Auto Click M1...")
    local skillAction = ReplicatedStorage.Chest.Remotes.Functions.SkillAction
    
    while task.wait(0.15) do -- Tốc độ đánh thường (0.15s/hit)
        pcall(function()
            local target = getBossRoot()
            local weapon = getWeapon()
            
            if target and weapon then
                -- Cấu trúc lệnh M1: SW_[TênVũKhí]_M1
                local remoteName = "SW_" .. weapon.Name .. "_M1"
                
                local args = {
                    [1] = remoteName,
                    [2] = {
                        ["MouseHit"] = target.CFrame,
                        ["Type"] = "Click"
                    }
                }
                
                -- Gửi lệnh Click
                skillAction:InvokeServer(unpack(args))
                
                -- Một số vũ khí cần gửi thêm lệnh "Up" để kết thúc đòn đánh
                -- skillAction:InvokeServer("SW_"..weapon.Name.."_M1", {["MouseHit"] = target.CFrame, ["Type"] = "Up"}) 
            end
        end)
    end
end)

-- ============================================
-- 4. LUỒNG AUTO SKILL (Z, X, C, V - RIÊNG BIỆT)
-- ============================================
task.spawn(function()
    print("🔥 Đã kích hoạt Auto Skill (Z,X,C,V)...")
    local skillAction = ReplicatedStorage.Chest.Remotes.Functions.SkillAction
    
    while task.wait(0.5) do -- Tốc độ spam skill (chậm hơn M1)
        pcall(function()
            local target = getBossRoot()
            local weapon = getWeapon()
            
            if target and weapon then
                local skills = {"Z", "X", "C", "V", "E"}
                
                for _, key in ipairs(skills) do
                    task.spawn(function()
                        -- Thử gửi dạng Sword (SW)
                        local argsSW = {
                            [1] = "SW_" .. weapon.Name .. "_" .. key,
                            [2] = {["MouseHit"] = target.CFrame, ["Type"] = "Down"}
                        }
                        skillAction:InvokeServer(unpack(argsSW))
                        
                        -- Thử gửi dạng Fruit (DF) - Đề phòng bạn cầm trái
                        local argsDF = {
                            [1] = "DF_" .. weapon.Name .. "_" .. key,
                            [2] = {["MouseHit"] = target.CFrame, ["Type"] = "Down"}
                        }
                        skillAction:InvokeServer(unpack(argsDF))
                        
                        -- Gửi lệnh nhả phím (Up)
                        task.wait(0.05)
                        argsSW[2].Type = "Up"
                        argsDF[2].Type = "Up"
                        skillAction:InvokeServer(unpack(argsSW))
                        skillAction:InvokeServer(unpack(argsDF))
                    end)
                end
            end
        end)
    end
end)
