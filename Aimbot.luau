--// SERVICES
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// SETTINGS
local Offset = Vector2.new(0,0)
local Step = 12

--// GUI ROOT
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "ObsidianHubKRNL"
gui.ResetOnSpawn = false

--// MINI BUTTON
local miniBtn = Instance.new("TextButton", gui)
miniBtn.Size = UDim2.fromOffset(16,60)
miniBtn.Position = UDim2.fromScale(0,0.5) - UDim2.fromOffset(0,30)
miniBtn.BackgroundColor3 = Color3.fromRGB(120,60,255)
miniBtn.BorderSizePixel = 0
miniBtn.Text = ""
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1,0)
local miniGlow = Instance.new("UIStroke", miniBtn)
miniGlow.Color = Color3.fromRGB(170,120,255)
miniGlow.Thickness = 2

--// PANEL
local PANEL_WIDTH, PANEL_HEIGHT = 200, 260
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.fromOffset(PANEL_WIDTH,PANEL_HEIGHT)
panel.Position = UDim2.fromScale(0,0.5) - UDim2.fromOffset(PANEL_WIDTH + 20,PANEL_HEIGHT/2)
panel.BackgroundColor3 = Color3.fromRGB(12,12,18)
panel.BorderSizePixel = 0
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,14)

-- gradient + glow
local grad = Instance.new("UIGradient", panel)
grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(22,22,35)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,15))}
grad.Rotation = 90
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(120,60,255)
stroke.Thickness = 1.2

-- title
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.fromOffset(PANEL_WIDTH,40)
title.BackgroundTransparency = 1
title.Text = "FOV CONTROL"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(200,200,255)

-- d-pad container
local center = Instance.new("Frame", panel)
center.Size = UDim2.fromOffset(140,140)
center.Position = UDim2.fromScale(0.5,0.55)
center.AnchorPoint = Vector2.new(0.5,0.5)
center.BackgroundTransparency = 1

-- d-pad buttons
local function DPadButton(text,pos,callback)
	local b = Instance.new("TextButton", center)
	b.Size = UDim2.fromOffset(40,40)
	b.Position = pos
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(28,28,45)
	b.TextColor3 = Color3.fromRGB(220,220,255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 18
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	local s = Instance.new("UIStroke", b)
	s.Color = Color3.fromRGB(110,70,255)
	s.Transparency = 0.3

	b.MouseButton1Down:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(50,50,80)}):Play()
	end)
	b.MouseButton1Up:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(28,28,45)}):Play()
	end)
	b.MouseButton1Click:Connect(callback)
end

--// buttons
DPadButton("↑", UDim2.fromOffset(50,0), function() Offset -= Vector2.new(0,Step) end)
DPadButton("↓", UDim2.fromOffset(50,100), function() Offset += Vector2.new(0,Step) end)
DPadButton("←", UDim2.fromOffset(0,50), function() Offset -= Vector2.new(Step,0) end)
DPadButton("→", UDim2.fromOffset(100,50), function() Offset += Vector2.new(Step,0) end)
DPadButton("•", UDim2.fromOffset(50,50), function() Offset = Vector2.new(0,0) end)

--// SLIDE PANEL
local open = false
local openPos = UDim2.fromScale(0,0.5) - UDim2.fromOffset(-10,PANEL_HEIGHT/2)
local closedPos = UDim2.fromScale(0,0.5) - UDim2.fromOffset(PANEL_WIDTH + 20,PANEL_HEIGHT/2)

miniBtn.MouseButton1Click:Connect(function()
	open = not open
	TweenService:Create(panel,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=open and openPos or closedPos}):Play()
end)
