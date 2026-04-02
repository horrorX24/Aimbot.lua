--// grab the main services we need
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// settings
local Settings = {
	SilentAim = false,
	ShowCircle = true,
	TeamCheck = true,
	WallCheck = true,
	AliveCheck = true,
	ESP = false,
	FOV = 150,
	Smoothness = 0,
	HitPart = "Head"
}

local Offset = Vector2.new(0,0)
local Step = 12

--// GUI ROOT
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "ObsidianHub"
gui.ResetOnSpawn = false

--// MAIN FRAME
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

--// MINI BUTTON (THIS IS THE NEW PART 🔥)
local miniBtn = Instance.new("TextButton", gui)
miniBtn.Size = UDim2.fromOffset(40,40)
miniBtn.Position = UDim2.fromScale(0.01,0.5)
miniBtn.Text = "⚙"
miniBtn.BackgroundColor3 = Color3.fromRGB(25,25,35)
miniBtn.TextColor3 = Color3.fromRGB(200,200,255)
miniBtn.TextScaled = true
miniBtn.BorderSizePixel = 0
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)

--// SLIDE OUT PANEL
local fovPanel = Instance.new("Frame", gui)
fovPanel.Size = UDim2.fromOffset(140,200)
fovPanel.Position = UDim2.fromScale(0.01,0.5)
fovPanel.BackgroundColor3 = Color3.fromRGB(20,20,30)
fovPanel.Visible = false
fovPanel.BorderSizePixel = 0
Instance.new("UICorner", fovPanel).CornerRadius = UDim.new(0,12)

--// PANEL TOGGLE
local opened = false
miniBtn.MouseButton1Click:Connect(function()
	opened = not opened
	fovPanel.Visible = opened
end)

--// FOV MOVE BUTTONS
local function MoveBtn(txt, pos, fn)
	local b = Instance.new("TextButton", fovPanel)
	b.Size = UDim2.fromScale(0.4,0.2)
	b.Position = pos
	b.Text = txt
	b.BackgroundColor3 = Color3.fromRGB(35,35,50)
	b.TextColor3 = Color3.fromRGB(230,230,255)
	b.TextScaled = true
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

	b.MouseButton1Click:Connect(fn)
end

-- directions (like a D-pad 🔥)
MoveBtn("↑", UDim2.fromScale(0.3,0.05), function()
	Offset -= Vector2.new(0, Step)
end)

MoveBtn("↓", UDim2.fromScale(0.3,0.55), function()
	Offset += Vector2.new(0, Step)
end)

MoveBtn("←", UDim2.fromScale(0.05,0.3), function()
	Offset -= Vector2.new(Step, 0)
end)

MoveBtn("→", UDim2.fromScale(0.55,0.3), function()
	Offset += Vector2.new(Step, 0)
end)

MoveBtn("R", UDim2.fromScale(0.3,0.3), function()
	Offset = Vector2.new(0,0)
end)

--// FOV circle
local circle = Instance.new("Frame", gui)
circle.AnchorPoint = Vector2.new(0.5,0.5)
circle.BackgroundTransparency = 1
circle.BorderSizePixel = 0
Instance.new("UIAspectRatioConstraint", circle).AspectRatio = 1

local circleStroke = Instance.new("UIStroke", circle)
circleStroke.Thickness = 2
circleStroke.Color = Color3.fromRGB(170,90,255)
Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

--// rest of your original UI (UNCHANGED BELOW)
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

Toggle("Silent Aim", function(v) Settings.SilentAim = v end)
Toggle("FOV Circle", function(v) Settings.ShowCircle = v end)
Toggle("Team Check", function(v) Settings.TeamCheck = v end)
Toggle("Wall Check", function(v) Settings.WallCheck = v end)
Toggle("Alive Check", function(v) Settings.AliveCheck = v end)
Toggle("ESP", function(v) Settings.ESP = v end)

Slider("Smoothness", 0, 1, Settings.Smoothness, function(v)
	Settings.Smoothness = v
end)

Slider("FOV Size", 50, 400, Settings.FOV, function(v)
	Settings.FOV = v
end)

--// loop
local function getCenter()
	local v = Camera.ViewportSize
	return Vector2.new(v.X/2, v.Y/2)
end

RunService.RenderStepped:Connect(function()
	local center = getCenter() + Offset

	circle.Position = UDim2.fromOffset(center.X, center.Y)
	circle.Size = UDim2.fromOffset(Settings.FOV*2, Settings.FOV*2)
	circle.Visible = Settings.ShowCircle
end)

print("Obsidian Hub loaded")
