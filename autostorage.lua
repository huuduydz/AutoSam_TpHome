--[[
    TEST MODULE 7: AUTO STORE FRUIT (CẤT TRÁI ÁC QUỶ)
    
    Chức năng:
    - Tự động quét Balo tìm trái ác quỷ.
    - So sánh với kho (FruitStorage).
    - Nếu chưa full -> Tự động lôi ra và cất vào kho.
    
    Cách test:
    1. Lấy 1 trái ác quỷ (loại cùi cũng được) để vào Balo.
    2. Chạy script.
    3. Quan sát nó tự cầm trái đó lên và cất đi.
]]

print("========================================")
print("TEST MODULE 7: AUTO STORE FRUIT")
print("========================================")

-- 1. KHAI BÁO DỊCH VỤ & BIẾN
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local lplr = Players.LocalPlayer

-- Giả lập Settings để test
local Settings = { autocat = true } 

-- Tìm folder chứa dữ liệu Fruit
local chest = ReplicatedStorage:WaitForChild("Chest", 10)
local fruitStorage = chest and chest:WaitForChild("Fruits", 10)

if not fruitStorage then
    warn("❌ Lỗi: Không tìm thấy folder FruitStorage trong ReplicatedStorage!")
    return
end

-- ============================================
-- 2. HÀM CLICK GUI (GIỮ NGUYÊN LOGIC CŨ)
-- ============================================
local function ClickButton(path)
    if path then
        GuiService.SelectedObject = path
        if GuiService.SelectedObject == path then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait()
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        end
        task.wait()
        GuiService.SelectedObject = nil
    end
end

-- ============================================
-- 3. HÀM TƯƠNG TÁC (EAT/STORE)
-- ============================================
local function InteractFruit()
    local character = lplr.Character
    if not character then return end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        print("👆 Đang thao tác với: " .. tool.Name)
        pcall(function()
            -- Tìm GUI tương tác
            local gui = lplr.PlayerGui:FindFirstChild("EatFruitBecky")
            local dialogue = gui and gui:FindFirstChild("Dialogue")
            
            -- Ưu tiên nút "Collect" (Cất) hoặc "Store"
            local btnCollect = dialogue and (dialogue:FindFirstChild("Collect") or dialogue:FindFirstChild("Store"))
            
            if btnCollect then
                print("✅ Tìm thấy nút Cất/Store -> Click!")
                ClickButton(btnCollect)
            else
                -- Nếu chưa hiện bảng, click chuột vào màn hình để kích hoạt trái
                print("🖱️ Click màn hình để mở menu trái...")
                VirtualUser:ClickButton1(Vector2.new(300, 300))
            end
        end)
    end
end

-- ============================================
-- 4. LOGIC CHÍNH (MAIN LOOP)
-- ============================================
task.spawn(function()
    print("🍎 Đang bắt đầu quét trái cây trong Balo...")
    
    while task.wait(1) do
        if not Settings.autocat then break end
        
        -- Lấy dữ liệu kho
        local stats = lplr:FindFirstChild("PlayerStats")
        local storeVal = stats and stats:FindFirstChild("FruitStore")
        local limitVal = stats and stats:FindFirstChild("FruitStorage")
        
        if not storeVal or not limitVal then 
            warn("⚠️ Đang chờ dữ liệu PlayerStats...")
            return 
        end

        local success, storedFruits = pcall(function() 
            return HttpService:JSONDecode(storeVal.Value) 
        end)
        if not success then storedFruits = {} end
        
        local storageLimit = limitVal.Value
        local backpack = lplr:FindFirstChild("Backpack")
        local character = lplr.Character
        
        if not backpack or not character then return end

        -- Quét từng loại trái trong game
        for _, fruitObj in ipairs(fruitStorage:GetChildren()) do
            local fruitName = fruitObj.Name
            
            -- Kiểm tra xem Balo có trái này không
            local foundInBag = backpack:FindFirstChild(fruitName)
            
            if foundInBag then
                -- Kiểm tra kho đã full chưa
                local currentQty = storedFruits[fruitName] or 0
                
                if currentQty < storageLimit then
                    print("\n📦 PHÁT HIỆN: " .. fruitName .. " (Kho: " .. currentQty .. "/" .. storageLimit .. ")")
                    print("➡️ Đang trang bị...")
                    
                    -- 1. Equip trái
                    foundInBag.Parent = character
                    task.wait(0.5)
                    
                    -- 2. Click màn hình để hiện menu
                    VirtualUser:ClickButton1(Vector2.new(300, 300))
                    task.wait(1)
                    
                    -- 3. Bấm nút cất
                    InteractFruit()
                    
                    -- 4. Click lại lần nữa cho chắc
                    task.wait(1)
                    VirtualUser:ClickButton1(Vector2.new(300, 300))
                    
                    -- 5. Đợi đến khi trái biến mất khỏi người
                    local waitTime = 0
                    while (backpack:FindFirstChild(fruitName) or character:FindFirstChild(fruitName)) and waitTime < 5 do
                        task.wait(0.5)
                        waitTime = waitTime + 0.5
                        -- Thử bấm lại nếu chưa cất được
                        InteractFruit() 
                    end
                    
                    if not (backpack:FindFirstChild(fruitName) or character:FindFirstChild(fruitName)) then
                        print("✅ Đã cất thành công: " .. fruitName)
                    else
                        print("⚠️ Cất thất bại hoặc bị lag, thử lại sau.")
                        -- Cất lại vào balo để vòng lặp sau xử lý
                        local stuckTool = character:FindFirstChild(fruitName)
                        if stuckTool then stuckTool.Parent = backpack end
                    end
                else
                    -- Kho full
                    -- print("⚠️ Kho đã đầy trái " .. fruitName .. ", bỏ qua.")
                end
            end
        end
    end
end)
