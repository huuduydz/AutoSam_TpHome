local _vb090 = game.Players.LocalPlayer
local _v44a7 = Instance.new(string.char(83,99,114,101,101,110,71,117,105))
local _vdc7f = Instance.new(string.char(70,114,97,109,101))
local _vc5a3 = Instance.new(string.char(84,101,120,116,66,117,116,116,111,110))
local _vff11 = Instance.new(string.char(84,101,120,116,76,97,98,101,108))
_v44a7.Name = string.char(65,117,116,111,67,111,109,112,97,115,115,71,85,73)
_v44a7.Parent = _vb090:WaitForChild(string.char(80,108,97,121,101,114,71,117,105))
_v44a7.ResetOnSpawn = false
_vdc7f.Parent = _v44a7
_vdc7f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
_vdc7f.Size = UDim2.new(0, 220, 0, 180)
_vdc7f.Position = UDim2.new(0.05, 0, 0.2, 0)
_vdc7f.Active = true
_vdc7f.Draggable = true
_vdc7f.BorderSizePixel = 0
_vdc7f.BackgroundTransparency = 0.1
_vc5a3.Parent = _vdc7f
_vc5a3.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
_vc5a3.Size = UDim2.new(1, -20, 0, 40)
_vc5a3.Position = UDim2.new(0, 10, 0.45, -10)
_vc5a3.Text = string.char(66,7853,116,32,65,117,116,111)
_vc5a3.TextScaled = true
_vc5a3.TextColor3 = Color3.new(1, 1, 1)
_vc5a3.Font = Enum.Font.SourceSansBold
_vff11.Parent = _vdc7f
_vff11.BackgroundTransparency = 1
_vff11.Position = UDim2.new(0, 10, 0.1, 0)
_vff11.Size = UDim2.new(1, -20, 0, 40)
_vff11.Text = string.char(84,114,7841,110,103,32,116,104,225,105,58,32,84,7855,116)
_vff11.TextScaled = true
_vff11.TextColor3 = Color3.new(1, 1, 1)
_vff11.Font = Enum.Font.SourceSans
local _v9a10 = false
local _v7644 _vc6e1()
while _v9a10 do
local _v9d7f = _vb090.Character or _vb090.CharacterAdded:Wait()
local _v7286 = _vb090:WaitForChild(string.char(66,97,99,107,112,97,99,107))
for _, _v7701 in pairs(_v7286:GetChildren()) do
if _v7701:IsA(string.char(84,111,111,108)) and string.find(_v7701.Name:lower(), string.char(70,114,97,109,101)0) then
_v9d7f.Humanoid:EquipTool(_v7701)
end
end
local _v7701 = _v9d7f:FindFirstChildOfClass(string.char(70,114,97,109,101)1)
if _v7701 and _v7701:FindFirstChild(string.char(70,114,97,109,101)2) then
local _vb0bf = _v7701.TargetPos.Value
if _vb0bf then
_v9d7f.PrimaryPart.CFrame = CFrame.new(_vb0bf)
end
end
if _v7701 then
pcall(_v7644()
_v7701:Activate()
end)
end
task.wait(0.3)
end
end
_vc5a3.MouseButton1Click:Connect(_v7644()
_v9a10 = not _v9a10
if _v9a10 then
_vc5a3.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
_vc5a3.Text = string.char(70,114,97,109,101)3
_vff11.Text = string.char(70,114,97,109,101)4
task.spawn(_vc6e1)
else
_vc5a3.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
_vc5a3.Text = string.char(70,114,97,109,101)5
_vff11.Text = string.char(70,114,97,109,101)6
end
end)
local _vfd9f = Instance.new(string.char(70,114,97,109,101)7)
_vfd9f.Parent = _vdc7f
_vfd9f.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
_vfd9f.Size = UDim2.new(1, -20, 0, 40)
_vfd9f.Position = UDim2.new(0, 10, 0.8, -10)
_vfd9f.Text = string.char(70,114,97,109,101)8
_vfd9f.TextScaled = true
_vfd9f.TextColor3 = Color3.new(1, 1, 1)
_vfd9f.Font = Enum.Font.SourceSansBold
local _vf40 = Vector3.new(1105.378662109375, 61.88255310058594, 795.1483764648438)
_vfd9f.MouseButton1Click:Connect(_v7644()
local _v9d7f = _vb090.Character or _vb090.CharacterAdded:Wait()
local _v9bab = _v9d7f:WaitForChild(string.char(70,114,97,109,101)9)
_v9bab.CFrame = CFrame.new(_vf40)
print(string.char(84,101,120,116,66,117,116,116,111,110)0)
end)