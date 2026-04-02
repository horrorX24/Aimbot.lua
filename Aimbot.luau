--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "CleanAimbotUI"

--// Main Frame
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 260)
Main.Position = UDim2.new(0, 50, 0.5, -130)
Main.BackgroundColor3 = Color3.fromRGB(30,30,30)

--// Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "Aimbot Panel"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)

--// Settings
local Settings = {
	Aimbot = false,
	FOVVisible = false,
	FOV = 100
}

--// Toggle Creator
local function CreateToggle(name, yPos)
	local btn = Instance.new("TextButton", Main)
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Text = name .. ": OFF"

	btn.MouseButton1Click:Connect(function()
		Settings[name] = not Settings[name]
		btn.Text = name .. ": " .. (Settings[name] and "ON" or "OFF")
	end)
end

--// Toggles (ALL OFF default)
CreateToggle("Aimbot", 40)
CreateToggle("TeamCheck", 80)
CreateToggle("WallCheck", 120)
CreateToggle("AliveCheck", 160)

--// FOV Toggle Button (opens drawer)
local FOVButton = Instance.new("TextButton", Main)
FOVButton.Size = UDim2.new(1, -20, 0, 30)
FOVButton.Position = UDim2.new(0, 10, 0, 200)
FOVButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
FOVButton.TextColor3 = Color3.new(1,1,1)
FOVButton.Text = "FOV Settings ▶"

--// SIDE PANEL (hidden at first)
local Side = Instance.new("Frame", ScreenGui)
Side.Size = UDim2.new(0, 180, 0, 120)
Side.Position = UDim2.new(0, -200, 0.5, -60) -- hidden left
Side.BackgroundColor3 = Color3.fromRGB(25,25,25)

--// FOV Label
local FOVText = Instance.new("TextLabel", Side)
FOVText.Size = UDim2.new(1,0,0,30)
FOVText.Text = "FOV: 100"
FOVText.BackgroundTransparency = 1
FOVText.TextColor3 = Color3.new(1,1,1)

--// FOV Slider
local Slider = Instance.new("TextButton", Side)
Slider.Size = UDim2.new(1, -20, 0, 20)
Slider.Position = UDim2.new(0, 10, 0, 50)
Slider.BackgroundColor3 = Color3.fromRGB(60,60,60)
Slider.Text = "Slide"
Slider.TextColor3 = Color3.new(1,1,1)

--// Slider Logic (click to increase)
Slider.MouseButton1Click:Connect(function()
	Settings.FOV = Settings.FOV + 10
	if Settings.FOV > 300 then Settings.FOV = 50 end
	FOVText.Text = "FOV: " .. Settings.FOV
end)

--// Slide Animation
local openPos = UDim2.new(0, 280, 0.5, -60)
local closedPos = UDim2.new(0, -200, 0.5, -60)

FOVButton.MouseButton1Click:Connect(function()
	Settings.FOVVisible = not Settings.FOVVisible
	
	local goal = Settings.FOVVisible and openPos or closedPos
	
	TweenService:Create(Side, TweenInfo.new(0.3), {Position = goal}):Play()
end)
