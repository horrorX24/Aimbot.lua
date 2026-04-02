--// SERVICES
local TweenService = game:GetService("TweenService")

--// MINI BUTTON (premium look)
local miniBtn = Instance.new("TextButton", gui)
miniBtn.Size = UDim2.fromOffset(42,42)
miniBtn.Position = UDim2.fromScale(0.01,0.5)
miniBtn.Text = ""
miniBtn.BackgroundColor3 = Color3.fromRGB(25,25,35)
miniBtn.BorderSizePixel = 0
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)

local icon = Instance.new("TextLabel", miniBtn)
icon.Size = UDim2.fromScale(1,1)
icon.BackgroundTransparency = 1
icon.Text = "≡"
icon.Font = Enum.Font.GothamBold
icon.TextScaled = true
icon.TextColor3 = Color3.fromRGB(200,200,255)

local glow = Instance.new("UIStroke", miniBtn)
glow.Color = Color3.fromRGB(140,80,255)
glow.Thickness = 1.5

--// SLIDING PANEL
local panelWidth = 180

local fovPanel = Instance.new("Frame", gui)
fovPanel.Size = UDim2.fromOffset(panelWidth,240)
fovPanel.Position = UDim2.fromScale(0,0.5) - UDim2.fromOffset(panelWidth + 10,120)
fovPanel.BackgroundColor3 = Color3.fromRGB(18,18,28)
fovPanel.BorderSizePixel = 0
Instance.new("UICorner", fovPanel).CornerRadius = UDim.new(0,16)

-- gradient = instant drip
local gradient = Instance.new("UIGradient", fovPanel)
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30,30,50)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(15,15,25))
}
gradient.Rotation = 90

local stroke = Instance.new("UIStroke", fovPanel)
stroke.Color = Color3.fromRGB(120,60,255)
stroke.Thickness = 1.5

--// TITLE
local title = Instance.new("TextLabel", fovPanel)
title.Size = UDim2.fromScale(1,0.2)
title.BackgroundTransparency = 1
title.Text = "FOV CONTROL"
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(210,210,255)

--// BUTTON GRID CONTAINER
local grid = Instance.new("Frame", fovPanel)
grid.Size = UDim2.fromScale(1,0.8)
grid.Position = UDim2.fromScale(0,0.2)
grid.BackgroundTransparency = 1

--// GRID LAYOUT
local layout = Instance.new("UIGridLayout", grid)
layout.CellSize = UDim2.fromScale(0.3,0.25)
layout.CellPadding = UDim2.fromScale(0.05,0.05)

--// BUTTON CREATOR
local function FancyBtn(txt, fn)
	local b = Instance.new("TextButton", grid)
	b.Text = txt
	b.BackgroundColor3 = Color3.fromRGB(35,35,55)
	b.TextColor3 = Color3.fromRGB(230,230,255)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)

	local s = Instance.new("UIStroke", b)
	s.Color = Color3.fromRGB(100,60,255)

	-- hover animation 🔥
	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(55,55,85)
		}):Play()
	end)

	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(35,35,55)
		}):Play()
	end)

	b.MouseButton1Click:Connect(fn)
end

--// BUTTONS (clean layout)
FancyBtn("↑", function() Offset -= Vector2.new(0,Step) end)
FancyBtn("↓", function() Offset += Vector2.new(0,Step) end)
FancyBtn("←", function() Offset -= Vector2.new(Step,0) end)
FancyBtn("→", function() Offset += Vector2.new(Step,0) end)
FancyBtn("RESET", function() Offset = Vector2.new(0,0) end)

--// SLIDE LOGIC
local opened = false

local openPos = UDim2.fromScale(0.01,0.5) - UDim2.fromOffset(0,120)
local closedPos = UDim2.fromScale(0,0.5) - UDim2.fromOffset(panelWidth + 10,120)

miniBtn.MouseButton1Click:Connect(function()
	opened = not opened

	local target = opened and openPos or closedPos

	TweenService:Create(fovPanel, TweenInfo.new(
		0.35,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.Out
	), {Position = target}):Play()
end)
