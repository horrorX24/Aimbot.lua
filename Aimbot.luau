--// grab the main services we need
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// main settings (you can tweak these anytime)
local Settings = {
	SilentAim = false,   -- redirects shots instead of moving your camera
	ShowCircle = true,   -- shows the FOV circle
	TeamCheck = true,    -- ignores teammates
	WallCheck = true,    -- ignores targets behind walls
	AliveCheck = true,   -- ignores dead players
	ESP = false,         -- shows player boxes
	FOV = 150,           -- size of targeting area
	Smoothness = 0,      -- 0 = instant snap, 1 = very smooth
	HitPart = "Head"     -- where to aim (Head, HumanoidRootPart, etc.)
}

--// used for moving the FOV circle around
local Offset = Vector2.new(0,0)
local Step = 12

--// create the main UI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "ObsidianHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.32,0.7)
frame.Position = UDim2.fromScale(0.02,0.2)
frame.BackgroundColor3 = Color3.fromRGB(18,18,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(120,60,255)

--// FOV circle (just visual)
local circle = Instance.new("Frame", gui)
circle.AnchorPoint = Vector2.new(0.5,0.5)
circle.BackgroundTransparency = 1
circle.BorderSizePixel = 0
Instance.new("UIAspectRatioConstraint", circle).AspectRatio = 1

local circleStroke = Instance.new("UIStroke", circle)
circleStroke.Thickness = 2
circleStroke.Color = Color3.fromRGB(170,90,255)
Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

--// layout helper
local y = 0.03

--// toggle button (on/off switch)
local function Toggle(text, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.fromScale(0.9,0.07)
	btn.Position = UDim2.fromScale(0.05,y)
	y += 0.08

	btn.BackgroundColor3 = Color3.fromRGB(30,30,40)
	btn.TextColor3 = Color3.fromRGB(220,220,255)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

	local state = false
	btn.Text = text .. ": OFF"

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = text .. ": " .. (state and "ON" or "OFF")
		callback(state)
	end)
end

--// simple button (for arrows, reset, etc.)
local function Button(text, pos, fn)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.fromScale(0.28,0.07)
	btn.Position = pos
	btn.Text = text

	btn.BackgroundColor3 = Color3.fromRGB(35,35,50)
	btn.TextColor3 = Color3.fromRGB(230,230,255)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

	btn.MouseButton1Click:Connect(fn)
end

--// slider (drag to change value)
local function Slider(text, min, max, default, callback)
	local holder = Instance.new("Frame", frame)
	holder.Size = UDim2.fromScale(0.9,0.09)
	holder.Position = UDim2.fromScale(0.05,y)
	y += 0.1
	holder.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", holder)
	label.Size = UDim2.fromScale(1,0.4)
	label.BackgroundTransparency = 1
	label.Text = text .. ": " .. tostring(default)

	label.TextColor3 = Color3.fromRGB(220,220,255)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true

	local bar = Instance.new("Frame", holder)
	bar.Size = UDim2.fromScale(1,0.3)
	bar.Position = UDim2.fromScale(0,0.6)
	bar.BackgroundColor3 = Color3.fromRGB(40,40,55)
	bar.BorderSizePixel = 0
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

	local fill = Instance.new("Frame", bar)
	fill.Size = UDim2.fromScale((default-min)/(max-min),1)
	fill.BackgroundColor3 = Color3.fromRGB(170,90,255)
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

	local dragging = false

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.fromScale(percent,1)

			local value = min + (max - min) * percent
			value = tonumber(string.format("%.2f", value))

			label.Text = text .. ": " .. value
			callback(value)
		end
	end)
end

--// toggles
Toggle("Silent Aim", function(v) Settings.SilentAim = v end)
Toggle("FOV Circle", function(v) Settings.ShowCircle = v end)
Toggle("Team Check", function(v) Settings.TeamCheck = v end)
Toggle("Wall Check", function(v) Settings.WallCheck = v end)
Toggle("Alive Check", function(v) Settings.AliveCheck = v end)
Toggle("ESP", function(v) Settings.ESP = v end)

--// sliders
Slider("Smoothness", 0, 1, Settings.Smoothness, function(v)
	Settings.Smoothness = v
end)

Slider("FOV Size", 50, 400, Settings.FOV, function(v)
	Settings.FOV = v
end)

--// helpers
local function getCenter()
	local v = Camera.ViewportSize
	return Vector2.new(v.X/2, v.Y/2)
end

local function isAlive(p)
	local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	return h and h.Health > 0
end

local function isVisible(part)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {LocalPlayer.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist

	local hit = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
	return hit and hit.Instance:IsDescendantOf(part.Parent)
end

--// find the closest valid target inside FOV
local function getTarget()
	local best, dist = nil, Settings.FOV
	local center = getCenter() + Offset

	for _,p in pairs(Players:GetPlayers()) do
		if p == LocalPlayer then continue end
		if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
		if Settings.AliveCheck and not isAlive(p) then continue end

		local part = p.Character and p.Character:FindFirstChild(Settings.HitPart)
		if part then
			local pos, vis = Camera:WorldToViewportPoint(part.Position)
			if vis then
				local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
				if mag < dist then
					if Settings.WallCheck and not isVisible(part) then continue end
					dist = mag
					best = part
				end
			end
		end
	end
	return best
end

--// main loop (handles visuals + optional smooth camera assist)
RunService.RenderStepped:Connect(function()
	local center = getCenter() + Offset

	circle.Position = UDim2.fromOffset(center.X, center.Y)
	circle.Size = UDim2.fromOffset(Settings.FOV*2, Settings.FOV*2)
	circle.Visible = Settings.ShowCircle

	-- optional smooth aim (visual only)
	if Settings.SilentAim and Settings.Smoothness > 0 then
		local target = getTarget()
		if target then
			local camCF = Camera.CFrame
			local newCF = CFrame.new(camCF.Position, target.Position)

			Camera.CFrame = camCF:Lerp(newCF, 1 - Settings.Smoothness)
		end
	end
end)

print("Obsidian Hub loaded")local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(120,60,255)

--// FOV circle (unchanged)
local circle = Instance.new("Frame", gui)
circle.AnchorPoint = Vector2.new(0.5,0.5)
circle.BackgroundTransparency = 1
circle.BorderSizePixel = 0
Instance.new("UIAspectRatioConstraint", circle).AspectRatio = 1

local circleStroke = Instance.new("UIStroke", circle)
circleStroke.Thickness = 2
circleStroke.Color = Color3.fromRGB(170,90,255)
Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

--// UI helper functions (Toggle, Button, getCenter, isAlive, isVisible, ESP stuff) remain the same
-- ... (I'll keep them to avoid making the answer too long, copy them from your original)

local y = 0.03
local function Toggle(text, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.fromScale(0.9,0.07)
	btn.Position = UDim2.fromScale(0.05,y)
	y += 0.08
	btn.BackgroundColor3 = Color3.fromRGB(30,30,40)
	btn.TextColor3 = Color3.fromRGB(220,220,255)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

	local state = false
	btn.Text = text .. ": OFF"

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = text .. ": " .. (state and "ON" or "OFF")
		callback(state)
	end)
end

local function Button(text, pos, fn)
	-- same as your original
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.fromScale(0.28,0.07)
	btn.Position = pos
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(35,35,50)
	btn.TextColor3 = Color3.fromRGB(230,230,255)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
	btn.MouseButton1Click:Connect(fn)
end

--// Toggles
Toggle("Silent Aim", function(v) Settings.SilentAim = v end)
Toggle("FOV Circle", function(v) Settings.ShowCircle = v end)
Toggle("Team Check", function(v) Settings.TeamCheck = v end)
Toggle("Wall Check", function(v) Settings.WallCheck = v end)
Toggle("Alive Check", function(v) Settings.AliveCheck = v end)
Toggle("ESP", function(v) Settings.ESP = v end)

--// Offset buttons (unchanged)
Button("↑", UDim2.fromScale(0.36,0.55), function() Offset += Vector2.new(0,-Step) end)
Button("↓", UDim2.fromScale(0.36,0.71), function() Offset += Vector2.new(0,Step) end)
Button("←", UDim2.fromScale(0.05,0.63), function() Offset += Vector2.new(-Step,0) end)
Button("→", UDim2.fromScale(0.67,0.63), function() Offset += Vector2.new(Step,0) end)
Button("Reset", UDim2.fromScale(0.36,0.85), function() Offset = Vector2.new(0,0) end)

--// getCenter, isAlive, isVisible, clearESP, addESP (copy exactly from your original code)
local function getCenter()
	local v = Camera.ViewportSize
	return Vector2.new(v.X/2, v.Y/2)
end

local function isAlive(p)
	local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	return h and h.Health > 0
end

local function isVisible(part)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {LocalPlayer.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local hit = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
	return hit and hit.Instance:IsDescendantOf(part.Parent)
end

local ESPFolder = Instance.new("Folder", gui)
local function clearESP()
	for _,v in pairs(ESPFolder:GetChildren()) do v:Destroy() end
end

local function addESP(p)
	-- copy your original addESP function here
	if p == LocalPlayer then return end
	if Settings.TeamCheck and p.Team == LocalPlayer.Team then return end
	if Settings.AliveCheck and not isAlive(p) then return end
	local char = p.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local bb = Instance.new("BillboardGui", ESPFolder)
	bb.Adornee = hrp
	bb.Size = UDim2.fromScale(4,5)
	bb.AlwaysOnTop = true
	local box = Instance.new("Frame", bb)
	box.Size = UDim2.fromScale(1,1)
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 2
	box.BorderColor3 = Color3.fromRGB(255,80,80)
	local name = Instance.new("TextLabel", bb)
	name.Size = UDim2.fromScale(1,0.2)
	name.Position = UDim2.fromScale(0,-0.2)
	name.BackgroundTransparency = 1
	name.Text = p.Name
	name.TextColor3 = Color3.fromRGB(255,120,120)
	name.Font = Enum.Font.GothamBold
	name.TextScaled = true
end

--// find closest target (same as before, but now used for silent aim)
local function getTarget()
	local best, dist = nil, Settings.FOV
	local center = getCenter() + Offset

	for _,p in pairs(Players:GetPlayers()) do
		if p == LocalPlayer then continue end
		if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
		if Settings.AliveCheck and not isAlive(p) then continue end

		local part = p.Character and p.Character:FindFirstChild(Settings.HitPart)
		if part then
			local pos, vis = Camera:WorldToViewportPoint(part.Position)
			if vis then
				local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
				if mag < dist then
					if Settings.WallCheck and not isVisible(part) then continue end
					dist = mag
					best = part
				end
			end
		end
	end
	return best
end

--// ==================== SILENT AIM HOOK ====================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	local args = {...}

	if Settings.SilentAim and method == "FireServer" then
		local target = getTarget()
		if target and (self.Name:find("Shoot") or self.Name:find("Fire") or self.Name:find("Bullet") or self.Name == "RemoteEvent" or self.Name == "GunRemote") then
			-- Most games send the direction or mouse hit position
			-- This is the most common way:
			if #args >= 1 and typeof(args[1]) == "Vector3" then
				args[1] = target.Position + Vector3.new(0, 0.1, 0) -- slight offset to hit head better
			elseif #args >= 2 and typeof(args[2]) == "Vector3" then
				args[2] = target.Position
			end
		end
	end

	return oldNamecall(self, unpack(args))
end)

--// main loop (now only handles visuals, no camera snapping)
RunService.RenderStepped:Connect(function()
	local center = getCenter() + Offset

	circle.Position = UDim2.fromOffset(center.X, center.Y)
	circle.Size = UDim2.fromOffset(Settings.FOV*2, Settings.FOV*2)
	circle.Visible = Settings.ShowCircle

	clearESP()

	if Settings.ESP then
		for _,p in pairs(Players:GetPlayers()) do
			addESP(p)
		end
	end
end)

print("Obsidian Hub loaded")
