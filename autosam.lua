--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

local obf_stringchar = string.char;
local obf_stringbyte = string.byte;
local obf_stringsub = string.sub;
local obf_bitlib = bit32 or bit;
local obf_XOR = obf_bitlib.bxor;
local obf_tableconcat = table.concat;
local obf_tableinsert = table.insert;
local function LUAOBFUSACTOR_DECRYPT_STR_0(LUAOBFUSACTOR_STR, LUAOBFUSACTOR_KEY)
	local result = {};
	for i = 1, #LUAOBFUSACTOR_STR do
		obf_tableinsert(result, obf_stringchar(obf_XOR(obf_stringbyte(obf_stringsub(LUAOBFUSACTOR_STR, i, i + 1)), obf_stringbyte(obf_stringsub(LUAOBFUSACTOR_KEY, 1 + (i % #LUAOBFUSACTOR_KEY), 1 + (i % #LUAOBFUSACTOR_KEY) + 1))) % 256));
	end
	return obf_tableconcat(result);
end
local v0 = game.Players.LocalPlayer;
local v1 = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\226\192\201\32\227\181\224\11\216", "\126\177\163\187\69\134\219\167"), v0:WaitForChild(LUAOBFUSACTOR_DECRYPT_STR_0("\19\193\43\220\249\49\234\63\204", "\156\67\173\74\165")));
v1.Name = LUAOBFUSACTOR_DECRYPT_STR_0("\25\182\64\24\143\63\85\32\178\68\41\155\19\111", "\38\84\215\41\118\220\70");
v1.ResetOnSpawn = false;
local v4 = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\118\4\35\31\251", "\158\48\118\66\114"), v1);
v4.BackgroundColor3 = Color3.fromRGB(25, 25, 25);
v4.BackgroundTransparency = 0.1;
v4.Size = UDim2.new(0, 270, 0, 290);
v4.Position = UDim2.new(0.05, 0, 0.2, 0);
v4.Active = true;
v4.Draggable = true;
v4.BorderSizePixel = 0;
local v12 = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\159\33\8\34\95\164\249\174\40", "\155\203\68\112\86\19\197"), v4);
v12.Text = "🧭 Auto Compass + Anti-AFK";
v12.TextColor3 = Color3.new(1, 1, 1);
v12.TextScaled = true;
v12.Size = UDim2.new(1, 0, 0, 30);
v12.BackgroundTransparency = 1;
v12.Font = Enum.Font.SourceSansBold;
local v20 = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\114\216\46\232\108\121\231\253\74", "\152\38\189\86\156\32\24\133"), v4);
v20.Size = UDim2.new(1, -10, 0, 25);
v20.Position = UDim2.new(0, 5, 0, 40);
v20.TextColor3 = Color3.fromRGB(0, 255, 255);
v20.TextScaled = true;
v20.BackgroundTransparency = 1;
v20.Font = Enum.Font.SourceSansBold;
local v27 = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\200\82\191\82\208\86\165\67\240", "\38\156\55\199"), v4);
v27.Size = UDim2.new(1, -10, 0, 25);
v27.Position = UDim2.new(0, 5, 0, 70);
v27.TextColor3 = Color3.fromRGB(255, 255, 0);
v27.TextScaled = true;
v27.BackgroundTransparency = 1;
v27.Font = Enum.Font.SourceSansBold;
local v34 = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\156\120\100\60\63\117\248\70\164", "\35\200\29\28\72\115\20\154"), v4);
v34.Size = UDim2.new(1, -10, 0, 25);
v34.Position = UDim2.new(0, 5, 0, 100);
v34.TextColor3 = Color3.fromRGB(0, 255, 0);
v34.TextScaled = true;
v34.BackgroundTransparency = 1;
v34.Font = Enum.Font.SourceSansBold;
local v41 = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\45\186\201\203\161\45\54\28\179", "\84\121\223\177\191\237\76"), v4);
v41.Size = UDim2.new(1, -10, 0, 25);
v41.Position = UDim2.new(0, 5, 0, 130);
v41.TextColor3 = Color3.fromRGB(255, 180, 80);
v41.TextScaled = true;
v41.BackgroundTransparency = 1;
v41.Font = Enum.Font.SourceSansBold;
v41.Text = "🧭 Compass: 0 (0 Equipped)";
local v49 = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\143\83\209\180\24\69\36\213\180\88", "\161\219\54\169\192\90\48\80"), v4);
v49.BackgroundColor3 = Color3.fromRGB(50, 200, 50);
v49.Size = UDim2.new(1, -20, 0, 35);
v49.Position = UDim2.new(0, 10, 0, 160);
v49.Text = "Bật Auto Compass";
v49.TextScaled = true;
v49.TextColor3 = Color3.new(1, 1, 1);
v49.Font = Enum.Font.SourceSansBold;
local v57 = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\125\71\24\49\101\67\2\32\69", "\69\41\34\96"), v4);
v57.Parent = v4;
v57.BackgroundTransparency = 1;
v57.Position = UDim2.new(0, 10, 0, 200);
v57.Size = UDim2.new(1, -20, 0, 25);
v57.Text = "Trạng thái: Tắt";
v57.TextScaled = true;
v57.TextColor3 = Color3.new(1, 1, 1);
v57.Font = Enum.Font.SourceSans;
local v67 = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\136\198\207\30\32\62\168\215\216\4", "\75\220\163\183\106\98"), v4);
v67.BackgroundColor3 = Color3.fromRGB(0, 150, 255);
v67.Size = UDim2.new(1, -20, 0, 35);
v67.Position = UDim2.new(0, 10, 0, 235);
v67.Text = "🏠 Teleport Home";
v67.TextScaled = true;
v67.TextColor3 = Color3.new(1, 1, 1);
v67.Font = Enum.Font.SourceSansBold;
local v75 = Vector3.new(1105.378662109375, 61.88255310058594, 795.1483764648438);
v67.MouseButton1Click:Connect(function()
	local v78 = v0.Character or v0.CharacterAdded:Wait();
	local v79 = v78:WaitForChild(LUAOBFUSACTOR_DECRYPT_STR_0("\42\175\134\54\215\13\179\143\5\214\13\174\187\54\203\22", "\185\98\218\235\87"));
	v79.CFrame = CFrame.new(v75);
end);
local v76 = false;
local function v77()
	while v76 do
		local v88 = v0.Character or v0.CharacterAdded:Wait();
		local v89 = v0:WaitForChild(LUAOBFUSACTOR_DECRYPT_STR_0("\233\61\36\237\206\171\200\55", "\202\171\92\71\134\190"));
		for v101, v102 in pairs(v89:GetChildren()) do
			if (v102:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\29\206\35\132", "\232\73\161\76")) and string.find(v102.Name:lower(), LUAOBFUSACTOR_DECRYPT_STR_0("\184\214\79\77\31\168\202", "\126\219\185\34\61"))) then
				v88.Humanoid:EquipTool(v102);
			end
		end
		local v90 = v88:FindFirstChildOfClass(LUAOBFUSACTOR_DECRYPT_STR_0("\56\193\81\126", "\135\108\174\62\18\30\23\147"));
		if (v90 and v90:FindFirstChild(LUAOBFUSACTOR_DECRYPT_STR_0("\130\232\56\204\29\186\3\200\165", "\167\214\137\74\171\120\206\83"))) then
			local v113 = v90.TargetPos.Value;
			if v113 then
				v88.PrimaryPart.CFrame = CFrame.new(v113);
			end
		end
		if v90 then
			pcall(function()
				v90:Activate();
			end);
		end
		task.wait(0.3);
	end
end
v49.MouseButton1Click:Connect(function()
	v76 = not v76;
	if v76 then
		v49.BackgroundColor3 = Color3.fromRGB(200, 50, 50);
		v49.Text = "Tắt Auto Compass";
		v57.Text = "Trạng thái: Đang hoạt động...";
		task.spawn(v77);
	else
		v49.BackgroundColor3 = Color3.fromRGB(50, 200, 50);
		v49.Text = "Bật Auto Compass";
		v57.Text = "Trạng thái: Tắt";
	end
end);
task.spawn(function()
	local v81 = tick();
	local v82 = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\185\229\60\110\253\181\157\249\49\88", "\199\235\144\82\61\152"));
	local v83 = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\52\2\184\63\20", "\75\103\118\217"));
	local v84, v85, v86 = 0, tick(), 60;
	v82.RenderStepped:Connect(function()
		v84 += 1
		if ((tick() - v85) >= 1) then
			v86 = v84;
			v84, v85 = 0, tick();
		end
	end);
	while true do
		local v91 = math.floor(tick() - v81);
		local v92, v93 = math.floor(v91 / 60), v91 % 60;
		v34.Text = string.format("⏲️ Time: %02d:%02d", v92, v93);
		local v95 = v83.Network.ServerStatsItem[LUAOBFUSACTOR_DECRYPT_STR_0("\227\85\100\21\249\46\206\90\119", "\126\167\52\16\116\217")]:GetValueString() or LUAOBFUSACTOR_DECRYPT_STR_0("\230\97\1", "\156\168\78\64\224\212\121");
		v20.Text = "📶 Ping: " .. v95;
		v27.Text = "🎮 FPS: " .. tostring(v86);
		local v98, v99 = 0, 0;
		for v109, v110 in pairs(v0.Backpack:GetChildren()) do
			if (v110:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\51\225\170\194", "\174\103\142\197")) and string.find(v110.Name:lower(), LUAOBFUSACTOR_DECRYPT_STR_0("\85\39\82\40\36\77\235", "\152\54\72\63\88\69\62"))) then
				v98 += 1
			end
		end
		for v111, v112 in pairs(v0.Character:GetChildren()) do
			if (v112:IsA(LUAOBFUSACTOR_DECRYPT_STR_0("\224\203\225\80", "\60\180\164\142")) and string.find(v112.Name:lower(), LUAOBFUSACTOR_DECRYPT_STR_0("\91\81\8\57\38\254\1", "\114\56\62\101\73\71\141"))) then
				v99 += 1
			end
		end
		v41.Text = string.format("🧭 Compass: %d (%d Equipped)", v98, v99);
		task.wait(1);
	end
end);
task.spawn(function()
	local v87 = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\142\224\201\208\173\232\215\241\171\236\201", "\164\216\137\187"));
	v0.Idled:Connect(function()
		v87:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame);
		task.wait(1);
		v87:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame);
	end);
end);
