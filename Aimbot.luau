local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FOV_RADIUS = 120
local Smoothness = 0.2

local aimbotEnabled = false
local fovEnabled = false
local espEnabled = false
local teamCheck = false
local aliveCheck = false
local wallCheck = false

local Offset = Vector2.new(0,0)
local Step = 12

local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- drag
local dragging, dragObject, dragStart, startPos = false, nil, nil, nil
local function MakeDraggable(obj)
	obj.Active = true
	obj.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging=true; dragObject=obj; dragStart=input.Position; startPos=obj.Position
		end
	end)
end
UIS.InputChanged:Connect(function(input)
	if dragging and dragObject then
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
			local delta=input.Position-dragStart
			dragObject.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
		end
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
		dragging=false; dragObject=nil
	end
end)

-- mini purple button
local mini = Instance.new("TextButton", gui)
mini.Size = UDim2.fromOffset(20,60)
mini.Position = UDim2.fromOffset(10,200)
mini.BackgroundColor3 = Color3.fromRGB(140,70,255)
mini.Text = ""
mini.AutoButtonColor = true
Instance.new("UICorner", mini)
MakeDraggable(mini)

-- main panel
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(220,340)
frame.Position = UDim2.fromOffset(-260,200)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
Instance.new("UICorner", frame)
MakeDraggable(frame)

local OPEN_POS = UDim2.fromOffset(40,200)
local CLOSED_POS = UDim2.fromOffset(-260,200)
local open = false

mini.MouseButton1Click:Connect(function()
	open = not open
	local goal = open and OPEN_POS or CLOSED_POS
	TweenService:Create(frame,TweenInfo.new(0.35,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=goal}):Play()
end)

local function Toggle(name,y,callback)
	local b=Instance.new("TextButton",frame)
	b.Size=UDim2.fromOffset(180,30)
	b.Position=UDim2.fromOffset(20,y)
	b.Text=name..": OFF"
	b.BackgroundColor3=Color3.fromRGB(40,40,60)
	b.TextColor3=Color3.new(1,1,1)
	Instance.new("UICorner",b)
	local state=false
	b.MouseButton1Click:Connect(function()
		state=not state
		b.Text=name..(state and ": ON" or ": OFF")
		b.BackgroundColor3=state and Color3.fromRGB(0,170,0) or Color3.fromRGB(40,40,60)
		callback(state)
	end)
end

local function Slider(name,y,min,max,default,callback,div)
	local label=Instance.new("TextLabel",frame)
	label.Position=UDim2.fromOffset(20,y)
	label.Size=UDim2.fromOffset(180,20)
	label.BackgroundTransparency=1
	label.TextColor3=Color3.new(1,1,1)
	local bar=Instance.new("Frame",frame)
	bar.Position=UDim2.fromOffset(20,y+20)
	bar.Size=UDim2.fromOffset(180,10)
	bar.BackgroundColor3=Color3.fromRGB(60,60,80)
	local fill=Instance.new("Frame",bar)
	fill.BackgroundColor3=Color3.fromRGB(140,70,255)
	local draggingSlider=false
	local function setVal(v)
		local percent=(v-min)/(max-min)
		fill.Size=UDim2.fromScale(percent,1)
		if div then label.Text=name..": "..(v/div) else label.Text=name..": "..v end
		callback(v)
	end
	setVal(default)
	bar.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then draggingSlider=true end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then draggingSlider=false end
	end)
	UIS.InputChanged:Connect(function(i)
		if draggingSlider then
			if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
				local percent=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
				local val=math.floor(min+(max-min)*percent)
				setVal(val)
			end
		end
	end)
end

Toggle("Aimbot",10,function(v) aimbotEnabled=v end)
Toggle("FOV",50,function(v) fovEnabled=v end)
Toggle("ESP",90,function(v) espEnabled=v end)
Toggle("Team",130,function(v) teamCheck=v end)
Toggle("Alive",170,function(v) aliveCheck=v end)
Toggle("Wall",210,function(v) wallCheck=v end)

Slider("FOV Size",250,50,400,120,function(v) FOV_RADIUS=v end)
Slider("Smoothness",300,0,10,2,function(v) Smoothness=v/10 end,10)

local circle=Drawing.new("Circle")
circle.Thickness=2
circle.Color=Color3.fromRGB(140,70,255)
circle.Filled=false
circle.Visible=false

local ESPs={}
local function createESP(player)
	if ESPs[player] then return end
	local h=Instance.new("Highlight")
	h.FillTransparency=0.5
	h.OutlineTransparency=0
	h.Parent=gui
	ESPs[player]=h
end
local function removeESP(player)
	if ESPs[player] then
		ESPs[player]:Destroy()
		ESPs[player]=nil
	end
end

local function isVisible(part)
	local origin=Camera.CFrame.Position
	local direction=(part.Position-origin)
	local params=RaycastParams.new()
	params.FilterType=Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances={LocalPlayer.Character}
	local result=workspace:Raycast(origin,direction,params)
	if result then return result.Instance:IsDescendantOf(part.Parent) end
	return true
end

local function valid(plr)
	if plr==LocalPlayer then return false end
	if not plr.Character then return false end
	local head=plr.Character:FindFirstChild("Head")
	local hum=plr.Character:FindFirstChild("Humanoid")
	if not head then return false end
	if aliveCheck and (not hum or hum.Health<=0) then return false end
	if teamCheck and plr.Team==LocalPlayer.Team then return false end
	if wallCheck and not isVisible(head) then return false end
	return true
end

local function getTarget()
	local closest=nil
	local dist=FOV_RADIUS
	local center=Camera.ViewportSize/2
	for _,p in pairs(Players:GetPlayers()) do
		if valid(p) and p.Character and p.Character:FindFirstChild("Head") then
			local pos,vis=Camera:WorldToViewportPoint(p.Character.Head.Position)
			if vis then
				local mag=(Vector2.new(pos.X,pos.Y)-center).Magnitude
				if mag<dist then
					dist=mag
					closest=p.Character.Head
				end
			end
		end
	end
	return closest
end

-- mini FOV control panel
local fovPanel=Instance.new("Frame",frame)
fovPanel.Size=UDim2.fromOffset(100,140)
fovPanel.Position=UDim2.fromOffset(220,0)
fovPanel.BackgroundColor3=Color3.fromRGB(30,30,45)
Instance.new("UICorner",fovPanel)
fovPanel.Visible=false

local function DPadButton(text,pos,callback)
	local b=Instance.new("TextButton",fovPanel)
	b.Size=UDim2.fromOffset(40,40)
	b.Position=pos
	b.Text=text
	b.BackgroundColor3=Color3.fromRGB(50,50,70)
	b.TextColor3=Color3.fromRGB(255,255,255)
	Instance.new("UICorner",b)
	b.MouseButton1Click:Connect(callback)
end

DPadButton("↑",UDim2.fromOffset(30,0),function() Offset-=Vector2.new(0,Step) end)
DPadButton("↓",UDim2.fromOffset(30,80),function() Offset+=Vector2.new(0,Step) end)
DPadButton("←",UDim2.fromOffset(0,40),function() Offset-=Vector2.new(Step,0) end)
DPadButton("→",UDim2.fromOffset(60,40),function() Offset+=Vector2.new(Step,0) end)
DPadButton("•",UDim2.fromOffset(30,40),function() Offset=Vector2.new(0,0) end)

local toggleFOVBtn=Instance.new("TextButton",frame)
toggleFOVBtn.Size=UDim2.fromOffset(40,30)
toggleFOVBtn.Position=UDim2.fromOffset(160,10)
toggleFOVBtn.Text="FOV"
Instance.new("UICorner",toggleFOVBtn)
toggleFOVBtn.MouseButton1Click:Connect(function()
	fovPanel.Visible=not fovPanel.Visible
end)

RunService.RenderStepped:Connect(function()
	local center=Camera.ViewportSize/2
	circle.Position=center+Offset
	circle.Radius=FOV_RADIUS
	circle.Visible=fovEnabled
	for _,p in pairs(Players:GetPlayers()) do
		if p~=LocalPlayer and p.Character then
			if espEnabled then
				createESP(p)
				local esp=ESPs[p]
				esp.Adornee=p.Character
				if teamCheck and p.Team==LocalPlayer.Team then
					esp.FillColor=Color3.fromRGB(0,255,0)
				else
					esp.FillColor=Color3.fromRGB(255,0,0)
				end
			else
				removeESP(p)
			end
		end
	end
	local target=getTarget()
	if aimbotEnabled and target then
		if Smoothness==0 then
			Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position,target.Position)
		else
			Camera.CFrame=Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position,target.Position),Smoothness)
		end
	end
end)

print("obsidian hub loaded")
