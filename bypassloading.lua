
while not pcall(function() return game:GetService("RunService") end) do
    wait(0.1) 
end
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
if not game:IsLoaded() then
    repeat
        RunService.Heartbeat:Wait()
    until game:IsLoaded()
end
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    RunService.Heartbeat:Wait()
    LocalPlayer = Players.LocalPlayer
end
while not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) do
    RunService.Heartbeat:Wait()
end
