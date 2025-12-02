-- YURO UNIVERSAL SCRIPT
-- Right Shift - открыть/закрыть

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local AimbotEnabled = true
local ESPEnabled = true
local WallcheckEnabled = true
local MAX_DISTANCE = 500
local AIM_SMOOTHNESS = 0.15
local AIM_FOV = 90 -- Угол обзора для аима (градусы)

local AimBind = Enum.UserInputType.MouseButton2
local AimKeyBind = nil
local IsAiming = false
local WaitingForBind = false
local GuiVisible = true
local ESPHighlights = {}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(100, 100, 255)
FOVCircle.Visible = true
FOVCircle.Transparency = 0.7

-- ══════════════════════════════════════════════════════════
-- GUI
-- ══════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YuroScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainContainer = Instance.new("CanvasGroup")
MainContainer.Size = UDim2.new(0, 320, 0, 395)
MainContainer.Position = UDim2.new(1, -340, 0, 20)
MainContainer.BackgroundTransparency = 1
MainContainer.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = MainContainer

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(100, 100, 255)
MainStroke.Thickness = 2

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 15)
TitleFix.Position = UDim2.new(0, 0, 1, -15)
TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ Yuro Universal"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -36, 0, 7)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -16, 1, -52)
ContentFrame.Position = UDim2.new(0, 8, 0, 48)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- ══════════════════════════════════════════════════════════
-- TOGGLE ФУНКЦИЯ
-- ══════════════════════════════════════════════════════════

local function CreateToggle(yPos, labelText, defaultState, callback)
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
	ToggleFrame.Position = UDim2.new(0, 0, 0, yPos)
	ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	ToggleFrame.BorderSizePixel = 0
	ToggleFrame.Parent = ContentFrame
	Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.7, 0, 1, 0)
	Label.Position = UDim2.new(0, 12, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = labelText
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.TextSize = 14
	Label.Font = Enum.Font.GothamSemibold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame

	local SwitchBg = Instance.new("Frame")
	SwitchBg.Size = UDim2.new(0, 46, 0, 24)
	SwitchBg.Position = UDim2.new(1, -58, 0.5, -12)
	SwitchBg.BackgroundColor3 = defaultState and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 100)
	SwitchBg.BorderSizePixel = 0
	SwitchBg.Parent = ToggleFrame
	Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

	local SwitchCircle = Instance.new("Frame")
	SwitchCircle.Size = UDim2.new(0, 18, 0, 18)
	SwitchCircle.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SwitchCircle.BorderSizePixel = 0
	SwitchCircle.Parent = SwitchBg
	Instance.new("UICorner", SwitchCircle).CornerRadius = UDim.new(1, 0)

	local state = defaultState
	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
	ToggleBtn.BackgroundTransparency = 1
	ToggleBtn.Text = ""
	ToggleBtn.Parent = ToggleFrame

	ToggleBtn.MouseButton1Click:Connect(function()
		state = not state
		local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
		TweenService:Create(SwitchBg, ti, {BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 100)}):Play()
		TweenService:Create(SwitchCircle, ti, {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
		callback(state)
	end)
end

-- ══════════════════════════════════════════════════════════
-- SLIDER ФУНКЦИЯ
-- ══════════════════════════════════════════════════════════

local function CreateSlider(yPos, labelText, minVal, maxVal, defaultVal, callback)
	local SliderFrame = Instance.new("Frame")
	SliderFrame.Size = UDim2.new(1, 0, 0, 50)
	SliderFrame.Position = UDim2.new(0, 0, 0, yPos)
	SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	SliderFrame.BorderSizePixel = 0
	SliderFrame.Parent = ContentFrame
	Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.Size = UDim2.new(1, -16, 0, 18)
	Label.Position = UDim2.new(0, 12, 0, 5)
	Label.BackgroundTransparency = 1
	Label.Text = labelText .. ": " .. defaultVal
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.TextSize = 13
	Label.Font = Enum.Font.GothamSemibold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = SliderFrame

	local SliderBg = Instance.new("Frame")
	SliderBg.Name = "SliderBg"
	SliderBg.Size = UDim2.new(1, -24, 0, 8)
	SliderBg.Position = UDim2.new(0, 12, 0, 32)
	SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	SliderBg.BorderSizePixel = 0
	SliderBg.Parent = SliderFrame
	Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

	local fillPercent = (defaultVal - minVal) / (maxVal - minVal)
	
	local SliderFill = Instance.new("Frame")
	SliderFill.Name = "Fill"
	SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
	SliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	SliderFill.BorderSizePixel = 0
	SliderFill.Parent = SliderBg
	Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

	local SliderKnob = Instance.new("Frame")
	SliderKnob.Name = "Knob"
	SliderKnob.Size = UDim2.new(0, 16, 0, 16)
	SliderKnob.Position = UDim2.new(fillPercent, -8, 0.5, -8)
	SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SliderKnob.BorderSizePixel = 0
	SliderKnob.Parent = SliderBg
	Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

	local dragging = false
	
	SliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	SliderBg.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	RunService.RenderStepped:Connect(function()
		if dragging then
			local mousePos = UserInputService:GetMouseLocation()
			local sliderAbsPos = SliderBg.AbsolutePosition.X
			local sliderAbsSize = SliderBg.AbsoluteSize.X
			local relX = math.clamp((mousePos.X - sliderAbsPos) / sliderAbsSize, 0, 1)
			local value = minVal + (maxVal - minVal) * relX
			
			if maxVal >= 10 then
				value = math.floor(value)
			else
				value = math.floor(value * 100) / 100
			end
			
			SliderFill.Size = UDim2.new(relX, 0, 1, 0)
			SliderKnob.Position = UDim2.new(relX, -8, 0.5, -8)
			Label.Text = labelText .. ": " .. value
			callback(value)
		end
	end)
	
	return SliderFrame
end

-- ══════════════════════════════════════════════════════════
-- СОЗДАНИЕ ЭЛЕМЕНТОВ
-- ══════════════════════════════════════════════════════════

CreateToggle(0, "🎯 Aimbot", AimbotEnabled, function(state)
	AimbotEnabled = state
end)

CreateToggle(46, "👁️ ESP (Highlight)", ESPEnabled, function(state)
	ESPEnabled = state
end)

CreateToggle(92, "🧱 Wallcheck", WallcheckEnabled, function(state)
	WallcheckEnabled = state
end)

CreateSlider(138, "📏 Дистанция", 50, 1000, MAX_DISTANCE, function(value)
	MAX_DISTANCE = value
end)

CreateSlider(194, "🎯 Плавность", 5, 100, AIM_SMOOTHNESS * 100, function(value)
	AIM_SMOOTHNESS = value / 100
end)

CreateSlider(250, "👁️ FOV (угол)", 5, 180, AIM_FOV, function(value)
	AIM_FOV = value
	-- Обновляем радиус круга FOV
	local viewportSize = Camera.ViewportSize
	FOVCircle.Radius = (value / 180) * (viewportSize.Y / 2)
end)

-- Bind кнопка
local BindFrame = Instance.new("Frame")
BindFrame.Size = UDim2.new(1, 0, 0, 40)
BindFrame.Position = UDim2.new(0, 0, 0, 306)
BindFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
BindFrame.BorderSizePixel = 0
BindFrame.Parent = ContentFrame
Instance.new("UICorner", BindFrame).CornerRadius = UDim.new(0, 8)

local BindLabel = Instance.new("TextLabel")
BindLabel.Size = UDim2.new(0.5, 0, 1, 0)
BindLabel.Position = UDim2.new(0, 12, 0, 0)
BindLabel.BackgroundTransparency = 1
BindLabel.Text = "🔑 Aim Bind:"
BindLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
BindLabel.TextSize = 14
BindLabel.Font = Enum.Font.GothamSemibold
BindLabel.TextXAlignment = Enum.TextXAlignment.Left
BindLabel.Parent = BindFrame

local BindButton = Instance.new("TextButton")
BindButton.Size = UDim2.new(0, 90, 0, 28)
BindButton.Position = UDim2.new(1, -102, 0.5, -14)
BindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
BindButton.Text = "RMB"
BindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BindButton.TextSize = 13
BindButton.Font = Enum.Font.GothamBold
BindButton.Parent = BindFrame
Instance.new("UICorner", BindButton).CornerRadius = UDim.new(0, 6)

BindButton.MouseButton1Click:Connect(function()
	WaitingForBind = true
	BindButton.Text = "..."
	BindButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
end)

-- ══════════════════════════════════════════════════════════
-- DRAG & MINIMIZE
-- ══════════════════════════════════════════════════════════

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainContainer.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

TitleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	TweenService:Create(MainContainer, TweenInfo.new(0.25), {Size = minimized and UDim2.new(0, 320, 0, 42) or UDim2.new(0, 320, 0, 395)}):Play()
	MinimizeBtn.Text = minimized and "+" or "−"
end)

-- ══════════════════════════════════════════════════════════
-- ФУНКЦИИ
-- ══════════════════════════════════════════════════════════

local function GetBindName()
	if AimKeyBind then return AimKeyBind.Name end
	if AimBind == Enum.UserInputType.MouseButton1 then return "LMB" end
	if AimBind == Enum.UserInputType.MouseButton2 then return "RMB" end
	if AimBind == Enum.UserInputType.MouseButton3 then return "MMB" end
	return "???"
end

local function IsVisible(targetPos, targetChar)
	local origin = Camera.CFrame.Position
	local direction = (targetPos - origin)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
	local result = workspace:Raycast(origin, direction, params)
	return result == nil
end

-- Проверка находится ли игрок в пределах FOV
local function IsInFOV(targetPos)
	local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
	
	if not onScreen then
		return false, math.huge
	end
	
	local screenCenter = Camera.ViewportSize / 2
	local targetScreen = Vector2.new(screenPos.X, screenPos.Y)
	local distanceFromCenter = (targetScreen - screenCenter).Magnitude
	
	-- Радиус FOV в пикселях
	local fovRadius = (AIM_FOV / 180) * (Camera.ViewportSize.Y / 2)
	
	return distanceFromCenter <= fovRadius, distanceFromCenter
end

local function GetNearestPlayer()
	if not LocalPlayer.Character then return nil end
	local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil end
	
	local myPos = myHRP.Position
	local closest = nil
	local closestScreenDist = math.huge
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			local hum = player.Character:FindFirstChild("Humanoid")
			
			if hrp and hum and hum.Health > 0 then
				local dist = (myPos - hrp.Position).Magnitude
				
				-- Проверка дистанции
				if dist <= MAX_DISTANCE then
					-- Проверка FOV (не за спиной)
					local inFOV, screenDist = IsInFOV(hrp.Position)
					
					if inFOV then
						-- Проверка стен
						local canSee = true
						if WallcheckEnabled then
							canSee = IsVisible(hrp.Position, player.Character)
						end
						
						-- Выбираем ближайшего к центру экрана
						if canSee and screenDist < closestScreenDist then
							closestScreenDist = screenDist
							closest = player
						end
					end
				end
			end
		end
	end
	
	return closest
end

-- ══════════════════════════════════════════════════════════
-- INPUT
-- ══════════════════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.KeyCode == Enum.KeyCode.RightShift then
		GuiVisible = not GuiVisible
		TweenService:Create(MainContainer, TweenInfo.new(0.2), {GroupTransparency = GuiVisible and 0 or 1}):Play()
		return
	end
	
	if WaitingForBind then
		if input.UserInputType == Enum.UserInputType.MouseButton1 or 
		   input.UserInputType == Enum.UserInputType.MouseButton2 or 
		   input.UserInputType == Enum.UserInputType.MouseButton3 then
			AimBind = input.UserInputType
			AimKeyBind = nil
		elseif input.KeyCode ~= Enum.KeyCode.Unknown then
			AimKeyBind = input.KeyCode
			AimBind = nil
		end
		WaitingForBind = false
		BindButton.Text = GetBindName()
		BindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
		return
	end
	
	if AimKeyBind and input.KeyCode == AimKeyBind then
		IsAiming = true
	elseif AimBind and input.UserInputType == AimBind then
		IsAiming = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if AimKeyBind and input.KeyCode == AimKeyBind then
		IsAiming = false
	elseif AimBind and input.UserInputType == AimBind then
		IsAiming = false
	end
end)

-- ══════════════════════════════════════════════════════════
-- FOV CIRCLE UPDATE
-- ══════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
	-- Обновляем позицию круга FOV
	local viewportSize = Camera.ViewportSize
	FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
	FOVCircle.Radius = (AIM_FOV / 180) * (viewportSize.Y / 2)
	FOVCircle.Visible = AimbotEnabled
end)

-- ══════════════════════════════════════════════════════════
-- AIMBOT (ПЛАВНЫЙ + FOV)
-- ══════════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
	if AimbotEnabled and IsAiming then
		local target = GetNearestPlayer()
		if target and target.Character then
			local hrp = target.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local targetPos = hrp.Position
				local currentCF = Camera.CFrame
				local targetCF = CFrame.lookAt(currentCF.Position, targetPos)
				
				local smoothing = math.clamp(AIM_SMOOTHNESS, 0.05, 1)
				Camera.CFrame = currentCF:Lerp(targetCF, smoothing)
			end
		end
	end
end)

-- ══════════════════════════════════════════════════════════
-- ESP
-- ══════════════════════════════════════════════════════════

local function UpdateESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if ESPHighlights[player] then
				local highlight = ESPHighlights[player]
				if not player.Character or not highlight.Parent or highlight.Adornee ~= player.Character then
					highlight:Destroy()
					ESPHighlights[player] = nil
				end
			end
			
			if ESPEnabled and player.Character then
				local hum = player.Character:FindFirstChild("Humanoid")
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				
				if hum and hum.Health > 0 and hrp then
					if not ESPHighlights[player] then
						local highlight = Instance.new("Highlight")
						highlight.FillTransparency = 1
						highlight.OutlineTransparency = 0
						highlight.Adornee = player.Character
						highlight.Parent = player.Character
						ESPHighlights[player] = highlight
					end
					
					local visible = IsVisible(hrp.Position, player.Character)
					ESPHighlights[player].OutlineColor = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
				end
			else
				if ESPHighlights[player] then
					ESPHighlights[player]:Destroy()
					ESPHighlights[player] = nil
				end
			end
		end
	end
end

spawn(function()
	while true do
		UpdateESP()
		wait(0.1)
	end
end)

for _, player in pairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		player.CharacterAdded:Connect(function()
			wait(0.5)
			if ESPHighlights[player] then
				ESPHighlights[player]:Destroy()
				ESPHighlights[player] = nil
			end
		end)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		wait(0.5)
		if ESPHighlights[player] then
			ESPHighlights[player]:Destroy()
			ESPHighlights[player] = nil
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	if ESPHighlights[player] then
		ESPHighlights[player]:Destroy()
		ESPHighlights[player] = nil
	end
end)

-- Удаляем круг при выходе
game:BindToClose(function()
	FOVCircle:Remove()
end)

print("✅ Yuro Universal Script загружен!")
print("📌 [Right Shift] - открыть/закрыть меню")
print("📌 FOV - угол обзора аима (игнорирует игроков за спиной)")
