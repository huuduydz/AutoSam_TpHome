-- 🧭 Tạo GUI
local player = game.Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Name = "AutoCompassGUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false -- ⚡ Giữ GUI khi reset nhân vật

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Size = UDim2.new(0, 220, 0, 180) -- tăng chiều cao để thêm nút Home
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1

ToggleButton.Parent = Frame
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
ToggleButton.Size = UDim2.new(1, -20, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0.45, -10)
ToggleButton.Text = "Bật Auto"
ToggleButton.TextScaled = true
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.SourceSansBold

StatusLabel.Parent = Frame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10, 0.1, 0)
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Text = "Trạng thái: Tắt"
StatusLabel.TextScaled = true
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Font = Enum.Font.SourceSans

-- ⚙️ Biến điều khiển
local autoEnabled = false

-- 🔁 Hàm chính
local function autoCompass()
	while autoEnabled do
		local char = player.Character or player.CharacterAdded:Wait()
		local backpack = player:WaitForChild("Backpack")

		-- 1️⃣ Equip tất cả compass
		for _, tool in pairs(backpack:GetChildren()) do
			if tool:IsA("Tool") and string.find(tool.Name:lower(), "compass") then
				char.Humanoid:EquipTool(tool)
			end
		end

		-- 2️⃣ Teleport nếu có TargetPos
		local tool = char:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("TargetPos") then
			local pos = tool.TargetPos.Value
			if pos then
				char.PrimaryPart.CFrame = CFrame.new(pos)
			end
		end

		-- 3️⃣ Giả lập click tool (Activate)
		if tool then
			pcall(function()
				tool:Activate()
			end)
		end

		task.wait(0.3) -- tốc độ lặp
	end
end

-- 🧩 Nút bật/tắt
ToggleButton.MouseButton1Click:Connect(function()
	autoEnabled = not autoEnabled
	if autoEnabled then
		ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		ToggleButton.Text = "Tắt Auto"
		StatusLabel.Text = "Trạng thái: Đang hoạt động..."
		task.spawn(autoCompass)
	else
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		ToggleButton.Text = "Bật Auto"
		StatusLabel.Text = "Trạng thái: Tắt"
	end
end)

-- 🏠 Nút Teleport Home
local homeButton = Instance.new("TextButton")
homeButton.Parent = Frame
homeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
homeButton.Size = UDim2.new(1, -20, 0, 40)
homeButton.Position = UDim2.new(0, 10, 0.8, -10)
homeButton.Text = "🏠 Teleport Home"
homeButton.TextScaled = true
homeButton.TextColor3 = Color3.new(1, 1, 1)
homeButton.Font = Enum.Font.SourceSansBold

local homePosition = Vector3.new(1105.378662109375, 61.88255310058594, 795.1483764648438)

homeButton.MouseButton1Click:Connect(function()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	hrp.CFrame = CFrame.new(homePosition)
	print("✅ Đã teleport về Home!")
end)
