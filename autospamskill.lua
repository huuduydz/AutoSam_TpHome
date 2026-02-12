-- DỊCH VỤ HỆ THỐNG
local CoreGui = game:GetService("CoreGui")
local Vim = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

-- CẤU HÌNH MẶC ĐỊNH
local Config = {
    Spamming = false,
    Keys = {"Z", "X", "C", "V"},
    BaseDelay = 0.5
}

-- XÓA GUI CŨ TRÁNH TRÙNG LẶP
if CoreGui:FindFirstChild("SafeMacroGUI") then
    CoreGui.SafeMacroGUI:Destroy()
end

-- TẠO GUI (NHỎ GỌN)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SafeMacroGUI"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Name = "Main"
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(0, 255, 127) -- Viền xanh lá an toàn
Frame.Position = UDim2.new(0.05, 0, 0.4, 0)
Frame.Size = UDim2.new(0, 180, 0, 200)
Frame.Active = true
Frame.Draggable = true -- Kéo thả được

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "SAFE MACRO"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.TextSize = 14

-- 1. NHẬP KEY
local KeyInput = Instance.new("TextBox")
KeyInput.Parent = Frame
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.Position = UDim2.new(0, 10, 0, 45)
KeyInput.Size = UDim2.new(0, 160, 0, 35)
KeyInput.Font = Enum.Font.GothamBold
KeyInput.Text = "Z,X,C,V"
KeyInput.PlaceholderText = "Key (VD: Z,X)"
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 14

KeyInput.FocusLost:Connect(function()
    Config.Keys = {}
    for w in string.gmatch(KeyInput.Text, "[^, ]+") do
        table.insert(Config.Keys, string.upper(w))
    end
end)

-- 2. NHẬP DELAY
local DelayInput = Instance.new("TextBox")
DelayInput.Parent = Frame
DelayInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DelayInput.Position = UDim2.new(0, 10, 0, 90)
DelayInput.Size = UDim2.new(0, 160, 0, 35)
DelayInput.Font = Enum.Font.GothamBold
DelayInput.Text = "0.5"
DelayInput.PlaceholderText = "Delay (Giây)"
DelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayInput.TextSize = 14

DelayInput.FocusLost:Connect(function()
    Config.BaseDelay = tonumber(DelayInput.Text) or 0.5
end)

-- 3. NÚT START
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = Frame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0, 140)
ToggleBtn.Size = UDim2.new(0, 160, 0, 50)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.Text = "BẬT (OFF)"
ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ToggleBtn.TextSize = 18

-- === LOGIC AN TOÀN (HUMANIZED) ===

local function HumanPress(k)
    local key = Enum.KeyCode[k]
    if key then
        -- 1. Nhấn xuống
        Vim:SendKeyEvent(true, key, false, game)
        
        -- Giả lập thời gian giữ phím (Hold Time) ngẫu nhiên từ 0.03s đến 0.07s
        -- Người thật không bao giờ bấm rồi thả ngay lập tức trong 0ms
        task.wait(7 + math.random(1, 40)/1000)
        
        -- 2. Thả ra
        Vim:SendKeyEvent(false, key, false, game)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    Config.Spamming = not Config.Spamming
    
    if Config.Spamming then
        ToggleBtn.Text = "ĐANG CHẠY..."
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 127) -- Xanh lá
        ToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        
        task.spawn(function()
            while Config.Spamming do
                for _, key in ipairs(Config.Keys) do
                    if not Config.Spamming then break end
                    
                    -- Bấm phím giả lập người thật
                    HumanPress(key)
                    
                    -- TÍNH TOÁN DELAY NGẪU NHIÊN (QUAN TRỌNG)
                    -- Cộng thêm từ 0ms đến 50ms ngẫu nhiên vào thời gian chờ
                    -- Giúp tránh bị hệ thống phát hiện macro đều chằn chặn
                    local randomJitter = math.random(0, 50) / 1000
                    local realDelay = Config.BaseDelay + randomJitter
                    
                    task.wait(realDelay)
                end
                task.wait() -- Nghỉ nhẹ
            end
        end)
    else
        ToggleBtn.Text = "BẬT (OFF)"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)
