-- YURO UNIVERSAL SCRIPT v2.1
-- Right Shift - открыть/закрыть

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Настройки
local Settings = {
	AimbotEnabled = true,
	ESPEnabled = true,
	WallcheckEnabled = true,
	TeamCheck = false,
	ShowFOVCircle = false,
	SpeedEnabled = false,
	SpeedValue = 32,
	AimPart = "HumanoidRootPart",
	MAX_DISTANCE = 500,
	AIM_SMOOTHNESS = 0.15,
	AIM_FOV = 90
}

local AimBind = Enum.UserInputType.MouseButton2
local AimKeyBind = nil
local IsAiming = false
local WaitingForBind = false
local GuiVisible = true
local CurrentTab = "Aimbot"
local ESPHighlights = {}
local OriginalSpeed = 16

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(100, 100, 255)
FOVCircle.Visible = false
FOVCircle.Transparency = 0.7

-- ══════════════════════════════════════════════════════════
-- GUI СОЗДАНИЕ
-- ══════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YuroScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success = pcall(function()
	ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainContainer = Instance.new("CanvasGroup")
MainContainer.Size = UDim2.new(0, 500, 0, 400)
MainContainer.Position = UDim2.new(0.5, -250, 1, -420) -- Снизу экрана
MainContainer.BackgroundTransparency = 1
MainContainer.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = MainContainer

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(80, 80, 180)
MainStroke.Thickness = 2

local TopGradient = Instance.new("Frame")
TopGradient.Size = UDim2.new(1, 0, 0, 3)
TopGradient.Position = UDim2.new(0, 0, 0, 0)
TopGradient.BorderSizePixel = 0
TopGradient.Parent = MainFrame

local Gradient = Instance.new("UIGradient", TopGradient)
Gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 100, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 255))
})

-- ══════════════════════════════════════════════════════════
-- TITLE BAR
-- ══════════════════════════════════════════════════════════

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.Position = UDim2.new(0, 0, 0, 3)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ YURO UNIVERSAL"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 50, 0, 20)
VersionLabel.Position = UDim2.new(0, 200, 0.5, -10)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v2.1"
VersionLabel.TextColor3 = Color3.fromRGB(100, 100, 255)
VersionLabel.TextSize = 12
VersionLabel.Font = Enum.Font.GothamBold
VersionLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -46, 0.5, -18)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 36, 0, 36)
MinBtn.Position = UDim2.new(1, -88, 0.5, -18)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

-- ══════════════════════════════════════════════════════════
-- TAB BUTTONS
-- ══════════════════════════════════════════════════════════

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 45)
TabBar.Position = UDim2.new(0, 10, 0, 58)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local Tabs = {"Aimbot", "Visuals", "Player", "Settings"}
local TabButtons = {}
local TabContents = {}

for i, tabName in ipairs(Tabs) do
	local TabBtn = Instance.new("TextButton")
	TabBtn.Size = UDim2.new(0, 110, 0, 35)
	TabBtn.BackgroundColor3 = CurrentTab == tabName and Color3.fromRGB(80, 80, 180) or Color3.fromRGB(40, 40, 60)
	TabBtn.Text = tabName
	TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	TabBtn.TextSize = 14
	TabBtn.Font = Enum.Font.GothamBold
	TabBtn.Parent = TabBar
	Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
	TabButtons[tabName] = TabBtn
end

-- ══════════════════════════════════════════════════════════
-- CONTENT AREA
-- ══════════════════════════════════════════════════════════

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -20, 1, -120)
ContentArea.Position = UDim2.new(0, 10, 0, 110)
ContentArea.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ContentArea.BorderSizePixel = 0
ContentArea.ClipsDescendants = true
ContentArea.Parent = MainFrame
Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 10)

-- ══════════════════════════════════════════════════════════
-- UI ФУНКЦИИ
-- ══════════════════════════════════════════════════════════

local function CreateToggle(parent, yPos, labelText, settingKey)
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(1, -20, 0, 45)
	ToggleFrame.Position = UDim2.new(0, 10, 0, yPos)
	ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	ToggleFrame.BorderSizePixel = 0
	ToggleFrame.Parent = parent
	Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.7, 0, 1, 0)
	Label.Position = UDim2.new(0, 15, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = labelText
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.TextSize = 14
	Label.Font = Enum.Font.GothamSemibold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame

	local SwitchBg = Instance.new("Frame")
	SwitchBg.Size = UDim2.new(0, 50, 0, 26)
	SwitchBg.Position = UDim2.new(1, -65, 0.5, -13)
	SwitchBg.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 100)
	SwitchBg.BorderSizePixel = 0
	SwitchBg.Parent = ToggleFrame
	Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

	local SwitchCircle = Instance.new("Frame")
	SwitchCircle.Size = UDim2.new(0, 20, 0, 20)
	SwitchCircle.Position = Settings[settingKey] and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
	SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SwitchCircle.BorderSizePixel = 0
	SwitchCircle.Parent = SwitchBg
	Instance.new("UICorner", SwitchCircle).CornerRadius = UDim.new(1, 0)

	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
	ToggleBtn.BackgroundTransparency = 1
	ToggleBtn.Text = ""
	ToggleBtn.Parent = ToggleFrame

	ToggleBtn.MouseButton1Click:Connect(function()
		Settings[settingKey] = not Settings[settingKey]
		local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
		TweenService:Create(SwitchBg, ti, {BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(80, 80, 100)}):Play()
		TweenService:Create(SwitchCircle, ti, {Position = Settings[settingKey] and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)}):Play()
	end)
end

local function CreateSlider(parent, yPos, labelText, minVal, maxVal, settingKey)
	local SliderFrame = Instance.new("Frame")
	SliderFrame.Size = UDim2.new(1, -20, 0, 55)
	SliderFrame.Position = UDim2.new(0, 10, 0, yPos)
	SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	SliderFrame.BorderSizePixel = 0
	SliderFrame.Parent = parent
	Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

	local defaultVal = Settings[settingKey]
	if settingKey == "AIM_SMOOTHNESS" then
		defaultVal = defaultVal * 100
	end

	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.Size = UDim2.new(1, -20, 0, 20)
	Label.Position = UDim2.new(0, 15, 0, 5)
	Label.BackgroundTransparency = 1
	Label.Text = labelText .. ": " .. math.floor(defaultVal)
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.TextSize = 13
	Label.Font = Enum.Font.GothamSemibold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = SliderFrame

	local SliderBg = Instance.new("Frame")
	SliderBg.Size = UDim2.new(1, -30, 0, 10)
	SliderBg.Position = UDim2.new(0, 15, 0, 35)
	SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	SliderBg.BorderSizePixel = 0
	SliderBg.Parent = SliderFrame
	Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

	local fillPercent = (defaultVal - minVal) / (maxVal - minVal)

	local SliderFill = Instance.new("Frame")
	SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
	SliderFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
	SliderFill.BorderSizePixel = 0
	SliderFill.Parent = SliderBg
	Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

	local SliderKnob = Instance.new("Frame")
	SliderKnob.Size = UDim2.new(0, 18, 0, 18)
	SliderKnob.Position = UDim2.new(fillPercent, -9, 0.5, -9)
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

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	RunService.RenderStepped:Connect(function()
		if dragging then
			local mousePos = UserInputService:GetMouseLocation()
			local relX = math.clamp((mousePos.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
			local value = math.floor(minVal + (maxVal - minVal) * relX)

			SliderFill.Size = UDim2.new(relX, 0, 1, 0)
			SliderKnob.Position = UDim2.new(relX, -9, 0.5, -9)
			Label.Text = labelText .. ": " .. value

			if settingKey == "AIM_SMOOTHNESS" then
				Settings[settingKey] = value / 100
			else
				Settings[settingKey] = value
			end
		end
	end)
end

local function CreateDropdown(parent, yPos, labelText, options, settingKey)
	local DropFrame = Instance.new("Frame")
	DropFrame.Size = UDim2.new(1, -20, 0, 45)
	DropFrame.Position = UDim2.new(0, 10, 0, yPos)
	DropFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	DropFrame.BorderSizePixel = 0
	DropFrame.ClipsDescendants = false
	DropFrame.Parent = parent
	Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 8)

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.5, 0, 1, 0)
	Label.Position = UDim2.new(0, 15, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = labelText
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.TextSize = 14
	Label.Font = Enum.Font.GothamSemibold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = DropFrame

	local DropBtn = Instance.new("TextButton")
	DropBtn.Size = UDim2.new(0, 150, 0, 32)
	DropBtn.Position = UDim2.new(1, -165, 0.5, -16)
	DropBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
	DropBtn.Text = Settings[settingKey] .. " ▼"
	DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	DropBtn.TextSize = 13
	DropBtn.Font = Enum.Font.GothamBold
	DropBtn.Parent = DropFrame
	Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 6)

	local DropList = Instance.new("Frame")
	DropList.Size = UDim2.new(0, 150, 0, #options * 30)
	DropList.Position = UDim2.new(1, -165, 1, 5)
	DropList.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	DropList.BorderSizePixel = 0
	DropList.Visible = false
	DropList.ZIndex = 10
	DropList.Parent = DropFrame
	Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 6)

	for i, option in ipairs(options) do
		local OptBtn = Instance.new("TextButton")
		OptBtn.Size = UDim2.new(1, 0, 0, 30)
		OptBtn.Position = UDim2.new(0, 0, 0, (i-1) * 30)
		OptBtn.BackgroundTransparency = 1
		OptBtn.Text = option
		OptBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
		OptBtn.TextSize = 13
		OptBtn.Font = Enum.Font.GothamSemibold
		OptBtn.ZIndex = 11
		OptBtn.Parent = DropList

		OptBtn.MouseButton1Click:Connect(function()
			Settings[settingKey] = option
			DropBtn.Text = option .. " ▼"
			DropList.Visible = false
		end)
	end

	DropBtn.MouseButton1Click:Connect(function()
		DropList.Visible = not DropList.Visible
	end)
end

local function CreateBindButton(parent, yPos)
	local BindFrame = Instance.new("Frame")
	BindFrame.Size = UDim2.new(1, -20, 0, 45)
	BindFrame.Position = UDim2.new(0, 10, 0, yPos)
	BindFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	BindFrame.BorderSizePixel = 0
	BindFrame.Parent = parent
	Instance.new("UICorner", BindFrame).CornerRadius = UDim.new(0, 8)

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.5, 0, 1, 0)
	Label.Position = UDim2.new(0, 15, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = "🔑 Aim Bind"
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.TextSize = 14
	Label.Font = Enum.Font.GothamSemibold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = BindFrame

	local BindBtn = Instance.new("TextButton")
	BindBtn.Name = "BindBtn"
	BindBtn.Size = UDim2.new(0, 100, 0, 32)
	BindBtn.Position = UDim2.new(1, -115, 0.5, -16)
	BindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
	BindBtn.Text = "RMB"
	BindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	BindBtn.TextSize = 13
	BindBtn.Font = Enum.Font.GothamBold
	BindBtn.Parent = BindFrame
	Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)

	BindBtn.MouseButton1Click:Connect(function()
		WaitingForBind = true
		BindBtn.Text = "..."
		BindBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
	end)
	
	return BindBtn
end

-- ══════════════════════════════════════════════════════════
-- TAB CONTENTS
-- ══════════════════════════════════════════════════════════

-- AIMBOT TAB
local AimbotTab = Instance.new("ScrollingFrame")
AimbotTab.Size = UDim2.new(1, 0, 1, 0)
AimbotTab.BackgroundTransparency = 1
AimbotTab.ScrollBarThickness = 4
AimbotTab.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
AimbotTab.CanvasSize = UDim2.new(0, 0, 0, 280)
AimbotTab.Parent = ContentArea
TabContents["Aimbot"] = AimbotTab

CreateToggle(AimbotTab, 10, "🎯 Enable Aimbot", "AimbotEnabled")
CreateSlider(AimbotTab, 65, "📏 Distance", 50, 1000, "MAX_DISTANCE")
CreateSlider(AimbotTab, 130, "🎯 Smoothness", 5, 100, "AIM_SMOOTHNESS")
CreateSlider(AimbotTab, 195, "👁️ FOV", 5, 180, "AIM_FOV")

-- VISUALS TAB
local VisualsTab = Instance.new("ScrollingFrame")
VisualsTab.Size = UDim2.new(1, 0, 1, 0)
VisualsTab.BackgroundTransparency = 1
VisualsTab.ScrollBarThickness = 4
VisualsTab.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
VisualsTab.CanvasSize = UDim2.new(0, 0, 0, 180)
VisualsTab.Visible = false
VisualsTab.Parent = ContentArea
TabContents["Visuals"] = VisualsTab

CreateToggle(VisualsTab, 10, "👁️ Enable ESP", "ESPEnabled")
CreateToggle(VisualsTab, 65, "🔵 Show FOV Circle", "ShowFOVCircle")
CreateToggle(VisualsTab, 120, "🧱 Wallcheck", "WallcheckEnabled")

-- PLAYER TAB
local PlayerTab = Instance.new("ScrollingFrame")
PlayerTab.Size = UDim2.new(1, 0, 1, 0)
PlayerTab.BackgroundTransparency = 1
PlayerTab.ScrollBarThickness = 4
PlayerTab.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
PlayerTab.CanvasSize = UDim2.new(0, 0, 0, 130)
PlayerTab.Visible = false
PlayerTab.Parent = ContentArea
TabContents["Player"] = PlayerTab

CreateToggle(PlayerTab, 10, "⚡ Speed Hack", "SpeedEnabled")
CreateSlider(PlayerTab, 65, "🏃 Speed Value", 16, 300, "SpeedValue")

-- SETTINGS TAB
local SettingsTab = Instance.new("ScrollingFrame")
SettingsTab.Size = UDim2.new(1, 0, 1, 0)
SettingsTab.BackgroundTransparency = 1
SettingsTab.ScrollBarThickness = 4
SettingsTab.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
SettingsTab.CanvasSize = UDim2.new(0, 0, 0, 180)
SettingsTab.Visible = false
SettingsTab.Parent = ContentArea
TabContents["Settings"] = SettingsTab

CreateDropdown(SettingsTab, 10, "🎯 Aim Part", {"HumanoidRootPart", "Head", "Torso"}, "AimPart")
CreateToggle(SettingsTab, 65, "👥 Team Check", "TeamCheck")
local BindButton = CreateBindButton(SettingsTab, 120)

-- ══════════════════════════════════════════════════════════
-- TAB SWITCHING
-- ══════════════════════════════════════════════════════════

local function SwitchTab(tabName)
	CurrentTab = tabName
	for name, btn in pairs(TabButtons) do
		local isActive = name == tabName
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = isActive and Color3.fromRGB(80, 80, 180) or Color3.fromRGB(40, 40, 60)
		}):Play()
	end
	for name, content in pairs(TabContents) do
		content.Visible = name == tabName
	end
end

for name, btn in pairs(TabButtons) do
	btn.MouseButton1Click:Connect(function()
		SwitchTab(name)
	end)
end

-- ══════════════════════════════════════════════════════════
-- DRAG & CLOSE
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

CloseBtn.MouseButton1Click:Connect(function()
	GuiVisible = false
	TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, -250, 1, 50)
	}):Play()
	task.delay(0.3, function()
		MainContainer.Visible = false
	end)
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	TweenService:Create(MainContainer, TweenInfo.new(0.25), {
		Size = minimized and UDim2.new(0, 500, 0, 53) or UDim2.new(0, 500, 0, 400)
	}):Play()
	MinBtn.Text = minimized and "+" or "−"
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

local function IsInFOV(targetPos)
	local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
	if not onScreen then return false, math.huge end
	
	local screenCenter = Camera.ViewportSize / 2
	local targetScreen = Vector2.new(screenPos.X, screenPos.Y)
	local distanceFromCenter = (targetScreen - screenCenter).Magnitude
	local fovRadius = (Settings.AIM_FOV / 180) * (Camera.ViewportSize.Y / 2)
	
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
			if Settings.TeamCheck and player.Team == LocalPlayer.Team then
				continue
			end
			
			local aimPart = player.Character:FindFirstChild(Settings.AimPart) or player.Character:FindFirstChild("HumanoidRootPart")
			local hum = player.Character:FindFirstChild("Humanoid")
			
			if aimPart and hum and hum.Health > 0 then
				local dist = (myPos - aimPart.Position).Magnitude
				
				if dist <= Settings.MAX_DISTANCE then
					local inFOV, screenDist = IsInFOV(aimPart.Position)
					
					if inFOV then
						local canSee = true
						if Settings.WallcheckEnabled then
							canSee = IsVisible(aimPart.Position, player.Character)
						end
						
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
-- SPEEDHACK (WalkSpeed метод)
-- ══════════════════════════════════════════════════════════

local function UpdateSpeed()
	if LocalPlayer.Character then
		local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
		if humanoid then
			if Settings.SpeedEnabled then
				humanoid.WalkSpeed = Settings.SpeedValue
			else
				humanoid.WalkSpeed = OriginalSpeed
			end
		end
	end
end

spawn(function()
	while true do
		UpdateSpeed()
		wait(0.1)
	end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	wait(0.5)
	local humanoid = char:FindFirstChild("Humanoid")
	if humanoid then
		OriginalSpeed = humanoid.WalkSpeed
	end
	UpdateSpeed()
end)

-- ══════════════════════════════════════════════════════════
-- INPUT (МЕНЮ ВЫЕЗЖАЕТ СНИЗУ)
-- ══════════════════════════════════════════════════════════

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.KeyCode == Enum.KeyCode.RightShift then
		GuiVisible = not GuiVisible
		if GuiVisible then
			MainContainer.Visible = true
			MainContainer.Position = UDim2.new(0.5, -250, 1, 50) -- Начинаем за экраном снизу
			TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.new(0.5, -250, 1, -420) -- Выезжает снизу
			}):Play()
		else
			TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Position = UDim2.new(0.5, -250, 1, 50) -- Уезжает вниз
			}):Play()
			task.delay(0.3, function()
				if not GuiVisible then
					MainContainer.Visible = false
				end
			end)
		end
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
-- FOV CIRCLE
-- ══════════════════════════════════════════════════════════

RunService.RenderStepped:Connect(function()
	local viewportSize = Camera.ViewportSize
	FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
	FOVCircle.Radius = (Settings.AIM_FOV / 180) * (viewportSize.Y / 2)
	FOVCircle.Visible = Settings.AimbotEnabled and Settings.ShowFOVCircle
end)

-- ══════════════════════════════════════════════════════════
-- AIMBOT
-- ══════════════════════════════════════════════════════════

RunService.Heartbeat:Connect(function()
	if Settings.AimbotEnabled and IsAiming then
		local target = GetNearestPlayer()
		if target and target.Character then
			local aimPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
			if aimPart then
				local targetPos = aimPart.Position
				local currentCF = Camera.CFrame
				local targetCF = CFrame.lookAt(currentCF.Position, targetPos)
				local smoothing = math.clamp(Settings.AIM_SMOOTHNESS, 0.05, 1)
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
			
			if Settings.ESPEnabled and player.Character then
				if Settings.TeamCheck and player.Team == LocalPlayer.Team then
					if ESPHighlights[player] then
						ESPHighlights[player]:Destroy()
						ESPHighlights[player] = nil
					end
					continue
				end
				
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

game:BindToClose(function()
	FOVCircle:Remove()
end)

print("✅ Yuro Universal v2.1 загружен!")
print("📌 [Right Shift] - открыть/закрыть меню")
print("📌 Меню выезжает снизу экрана")
