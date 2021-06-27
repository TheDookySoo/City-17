local SCRIPT_ENABLED = true

local LOCAL_PLAYER = game.Players.LocalPlayer
local MOUSE = LOCAL_PLAYER:GetMouse()
local RNG = Random.new()

local INPUT_SERVICE = game:GetService("UserInputService")
local RUN_SERVICE = game:GetService("RunService")
local TWEEN_SERVICE = game:GetService("TweenService")

local APPLICATION_GUI_PARENT = game:GetService("RunService"):IsStudio() and LOCAL_PLAYER.PlayerGui or game.CoreGui

-- Application Theme (determines how the application gui will look, what font is used for text and what colors are used for things)
local THEME = {}
THEME.Element_Height = 19 -- The height of the containers of switch, buttons, sliders, etc.
THEME.Element_Left_Padding = 180
THEME.Element_Title_Left_Padding = 10
THEME.Element_Title_Text_Size = 13

THEME.Folder_Handle_Height = 17
THEME.Folder_Title_Left_Padding = 20
THEME.Folder_Collapse_Left_Padding = 10
THEME.Folder_Collapse_Button_Dimensions = Vector2.new(15, 15)

THEME.Switch_Off_Color = Color3.fromRGB(30, 30, 30)
THEME.Switch_On_Color = Color3.fromRGB(30, 120, 190)
THEME.Switch_Knob_Color = Color3.fromRGB(220, 220, 220)
THEME.Switch_Dimensions = Vector2.new(30, 13)

THEME.Button_Background_Color = Color3.fromRGB(30, 30, 30)
THEME.Button_Engaged_Color = Color3.fromRGB(30, 120, 190)
THEME.Button_Dimensions = Vector2.new(100, 15)
THEME.Button_Border_Rounding = 3

THEME.Input_Background_Color = Color3.fromRGB(30, 30, 30)
THEME.Input_Height = 15
THEME.Input_Border_Rounding = 3
THEME.Input_Text_Size = 12 

THEME.Output_Background_Color = Color3.fromRGB(30, 30, 30)
THEME.Output_Background_Border_Rounding = 3
THEME.Output_Background_Side_Padding = 10
THEME.Output_Background_Vertical_Padding = 6
THEME.Output_Background_Extra_Height = 2 -- Extra bit at the bottom of the background, doesn't affect top side
THEME.Output_Label_Height = 16
THEME.Output_Label_Left_Text_Padding = 4
THEME.Output_Font = Enum.Font.Code
THEME.Output_Text_Size = 14

THEME.Keybind_Height = 15
THEME.Keybind_Background_Color = Color3.fromRGB(30, 30, 30)
THEME.Keybind_Engaged_Color = Color3.fromRGB(30, 120, 190)
THEME.Keybind_Border_Rounding = 3
THEME.Keybind_Text_Size = 12

THEME.Font_Regular = Enum.Font.Gotham
THEME.Font_SemiBold = Enum.Font.GothamSemibold
THEME.Font_Bold = Enum.Font.GothamBold

THEME.Text_Color = Color3.fromRGB(255, 255, 255)

THEME.Window_Handle_Color = Color3.fromRGB(60, 60, 60)
THEME.Window_Background_Color = Color3.fromRGB(45, 45, 45)
THEME.Folder_Title_Color = Color3.fromRGB(100, 120, 220)

-- Misc. Functions
local function Lerp(start, finish, alpha)
	return start * (1 - alpha) + (finish * alpha)
end

local function StringToNumber(str, returnValueIfNotValid)
	local ret = returnValueIfNotValid ~= nil and returnValueIfNotValid or 0
	return typeof(tonumber(str)) == "number" and tonumber(str) or ret
end

local function RoundNumber(number, decimalPlaces)
	local multiplier = 10 ^ decimalPlaces

	return math.floor(number * multiplier + 0.5) / multiplier
end

-- Core Gui Elements
local function CreateGui()
	local gui = Instance.new("ScreenGui", APPLICATION_GUI_PARENT)
	gui.Name = ""
	gui.ResetOnSpawn = false

	return gui
end

local function CreatePadding(parent, height)
	local padding = Instance.new("Frame", parent)
	padding.Name = ""
	padding.Size = UDim2.new(1, 0, 0, height)
	padding.BackgroundTransparency = 1

	return padding
end

local function CreateFrame(parent, size, position, anchorPoint, color, borderRounding)
	if size           == nil then size           = UDim2.new(0, 0, 0, 0) end
	if position       == nil then position       = UDim2.new(0, 0, 0, 0) end
	if anchorPoint    == nil then anchorPoint    = Vector2.new(0, 0)     end
	if color          == nil then color          = Color3.new(1, 1, 1)   end
	if borderRounding == nil then borderRounding = 0                     end

	local frame = Instance.new("ImageLabel", parent)
	frame.Name = ""
	frame.Image = "rbxassetid://3570695787"
	frame.ImageColor3 = color
	frame.BackgroundTransparency = 1
	frame.Active = true

	frame.ScaleType = Enum.ScaleType.Slice
	frame.SliceCenter = Rect.new(Vector2.new(100, 100), Vector2.new(100, 100))
	frame.SliceScale = 0.01 * borderRounding

	if frame.SliceScale == 0 then frame.SliceScale = 0.001 end -- Prevent weird thing from happening

	frame.Size = size
	frame.Position = position
	frame.AnchorPoint = anchorPoint

	return frame
end

local function CreateScrollingFrame(parent, size, position, anchorPoint, elementPadding, bottomPadding)
	if size           == nil then size           = UDim2.new(0, 0, 0, 0) end
	if position       == nil then position       = UDim2.new(0, 0, 0, 0) end
	if anchorPoint    == nil then anchorPoint    = Vector2.new(0, 0)     end
	if elementPadding == nil then elementPadding = 0                     end
	if bottomPadding  == nil then bottomPadding  = 0                     end

	local container = Instance.new("ScrollingFrame", parent)
	container.Name = ""
	container.BorderSizePixel = 0
	container.BackgroundTransparency = 1
	container.ScrollingEnabled = true
	container.Size = size
	container.Position = position
	container.AnchorPoint = anchorPoint
	container.BottomImage = container.MidImage
	container.TopImage = container.MidImage
	container.ScrollBarThickness = 4

	container.CanvasSize = UDim2.new(0, 0, 0, elementPadding + bottomPadding) -- Just incase the padding is massive

	local list = Instance.new("UIListLayout", container)
	list.Name = ""
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, elementPadding)

	local function CalculateSize()
		container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + bottomPadding)
	end

	container.ChildAdded:Connect(function(c)
		CalculateSize()

		pcall(function()
			c:GetPropertyChangedSignal("Size"):Connect(function()
				CalculateSize()
			end)
		end)
	end)

	container.ChildRemoved:Connect(function(c)
		CalculateSize()
	end)

	return container
end

local function CreateSwitch(parent, title, onByDefault)
	local container = Instance.new("Frame", parent)
	container.Name = ""
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
	titleLabel.Name = ""
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -THEME.Element_Title_Left_Padding, 1, 0)
	titleLabel.Position = UDim2.new(1, 0, 0, 0)
	titleLabel.AnchorPoint = Vector2.new(1, 0)
	titleLabel.Font = THEME.Font_SemiBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = THEME.Text_Color
	titleLabel.TextSize = THEME.Element_Title_Text_Size
	titleLabel.Text = title

	local switchBackground = CreateFrame(
		container,
		UDim2.new(0, THEME.Switch_Dimensions.X, 0, THEME.Switch_Dimensions.Y),
		UDim2.new(0, THEME.Element_Left_Padding, 0.5, 0),
		Vector2.new(0, 0.5),
		THEME.Switch_Off_Color,
		math.floor(THEME.Switch_Dimensions.Y / 2) + 1
	)

	local knobWidth = THEME.Switch_Dimensions.Y - 2

	local knob = Instance.new("ImageLabel", switchBackground)
	knob.Name = ""
	knob.Image = "rbxassetid://3570695787"
	knob.BackgroundTransparency = 1
	knob.ImageColor3 = THEME.Switch_Knob_Color
	knob.Size = UDim2.new(0, knobWidth, 0, knobWidth)
	knob.Position = UDim2.new(0, 1, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0, 0.5)

	local switchClickBox = Instance.new("TextButton", switchBackground)
	switchClickBox.Name = ""
	switchClickBox.BackgroundTransparency = 1
	switchClickBox.Size = UDim2.new(1, 0, 1, 0)
	switchClickBox.Text = ""

	-- Functionality
	local isOn = onByDefault
	local valueChanged = false

	local function UpdateSwitchAppearance()
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

		if isOn then
			local goal_1 = {}
			goal_1.AnchorPoint = Vector2.new(1, 0.5)
			goal_1.Position = UDim2.new(1, -1, 0.5, 0)

			local goal_2 = {}
			goal_2.ImageColor3 = THEME.Switch_On_Color

			local tween_1 = game:GetService("TweenService"):Create(knob, tweenInfo, goal_1) tween_1:Play()
			local tween_1 = game:GetService("TweenService"):Create(switchBackground, tweenInfo, goal_2) tween_1:Play()
		else
			local goal_1 = {}
			goal_1.AnchorPoint = Vector2.new(0, 0.5)
			goal_1.Position = UDim2.new(0, 1, 0.5, 0)

			local goal_2 = {}
			goal_2.ImageColor3 = THEME.Switch_Off_Color

			local tween_1 = game:GetService("TweenService"):Create(knob, tweenInfo, goal_1) tween_1:Play()
			local tween_1 = game:GetService("TweenService"):Create(switchBackground, tweenInfo, goal_2) tween_1:Play()
		end
	end

	switchClickBox.MouseButton1Click:Connect(function()
		isOn = not isOn
		valueChanged = true

		UpdateSwitchAppearance()
	end)

	UpdateSwitchAppearance()

	-- Switch class
	local switch = {}

	function switch.On()
		return isOn
	end

	function switch.ValueChanged()
		local r = valueChanged
		valueChanged = false

		return r
	end

	return switch
end

local function CreateButton(parent, title, buttonText)
	local container = Instance.new("Frame", parent)
	container.Name = ""
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
	titleLabel.Name = ""
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -THEME.Element_Title_Left_Padding, 1, 0)
	titleLabel.Position = UDim2.new(1, 0, 0, 0)
	titleLabel.AnchorPoint = Vector2.new(1, 0)
	titleLabel.Font = THEME.Font_SemiBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = THEME.Text_Color
	titleLabel.TextSize = THEME.Element_Title_Text_Size
	titleLabel.Text = title

	local buttonFrame = CreateFrame(
		container,
		UDim2.new(0, THEME.Button_Dimensions.X, 0, THEME.Button_Dimensions.Y),
		UDim2.new(0, THEME.Element_Left_Padding, 0.5, 0),
		Vector2.new(0, 0.5),
		THEME.Button_Background_Color,
		THEME.Button_Border_Rounding
	)

	local clickBox = Instance.new("TextButton", buttonFrame)
	clickBox.Name = ""
	clickBox.BackgroundTransparency = 1
	clickBox.Font = THEME.Font_SemiBold
	clickBox.TextSize = 12
	clickBox.Size = UDim2.new(1, 0, 1, 0)
	clickBox.TextColor3 = THEME.Text_Color
	clickBox.Text = buttonText

	-- Functionality
	local pressCount = 0

	clickBox.MouseButton1Click:Connect(function()
		pressCount = pressCount + 1

		buttonFrame.ImageColor3 = THEME.Button_Background_Color
		wait()
		buttonFrame.ImageColor3 = THEME.Button_Engaged_Color
	end)

	clickBox.MouseEnter:Connect(function()
		buttonFrame.ImageColor3 = THEME.Button_Engaged_Color
	end)

	clickBox.MouseLeave:Connect(function()
		buttonFrame.ImageColor3 = THEME.Button_Background_Color
	end)

	-- Button class
	local button = {}

	function button.GetPressCount()
		local r = pressCount
		pressCount = 0

		return r
	end

	return button
end

local function CreateInput(parent, title, default)
	if default == nil then default = "Enter here" end

	local container = Instance.new("Frame", parent)
	container.Name = ""
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
	titleLabel.Name = ""
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -THEME.Element_Title_Left_Padding, 1, 0)
	titleLabel.Position = UDim2.new(1, 0, 0, 0)
	titleLabel.AnchorPoint = Vector2.new(1, 0)
	titleLabel.Font = THEME.Font_SemiBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = THEME.Text_Color
	titleLabel.TextSize = THEME.Element_Title_Text_Size
	titleLabel.Text = title

	local backgroundWidth = parent.AbsoluteSize.X - THEME.Element_Left_Padding - 8

	local background = CreateFrame(
		container,
		UDim2.new(0, backgroundWidth, 0, THEME.Input_Height),
		UDim2.new(0, THEME.Element_Left_Padding, 0.5, 0),
		Vector2.new(0, 0.5),
		THEME.Input_Background_Color,
		THEME.Input_Border_Rounding
	)

	local inputTextBox = Instance.new("TextBox", background)
	inputTextBox.Name = ""
	inputTextBox.BackgroundTransparency = 1
	inputTextBox.Size = UDim2.new(1, -4, 0, THEME.Input_Text_Size)
	inputTextBox.Position = UDim2.new(1, 0, 0.5, 0)
	inputTextBox.AnchorPoint = Vector2.new(1, 0.5)
	inputTextBox.Font = THEME.Font_SemiBold
	inputTextBox.TextSize = THEME.Input_Text_Size
	inputTextBox.TextColor3 = THEME.Text_Color
	inputTextBox.TextXAlignment = Enum.TextXAlignment.Left
	inputTextBox.TextScaled = true
	inputTextBox.Text = default

	-- Functionality
	local textChanged = false
	local previousText = inputTextBox.Text

	inputTextBox.FocusLost:Connect(function()
		if previousText ~= inputTextBox.Text then
			textChanged = true
		end

		previousText = inputTextBox.Text
	end)

	-- Input class
	local input = {}

	function input.GetInputText()
		return inputTextBox.Text
	end

	function input.GetInputTextAsNumber()
		local n = tonumber(inputTextBox.Text)

		return n == nil and 0 or n
	end

	function input.InputChanged()
		local r = textChanged
		textChanged = false

		return r
	end

	return input
end

local function CreateKeybind(parent, title, defaultKeyCode)
	local container = Instance.new("Frame", parent)
	container.Name = ""
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
	titleLabel.Name = ""
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -THEME.Element_Title_Left_Padding, 1, 0)
	titleLabel.Position = UDim2.new(1, 0, 0, 0)
	titleLabel.AnchorPoint = Vector2.new(1, 0)
	titleLabel.Font = THEME.Font_SemiBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = THEME.Text_Color
	titleLabel.TextSize = THEME.Element_Title_Text_Size
	titleLabel.Text = title

	local background = CreateFrame(
		container,
		nil,
		UDim2.new(0, THEME.Element_Left_Padding, 0.5, 0),
		Vector2.new(0, 0.5),
		THEME.Keybind_Background_Color,
		THEME.Keybind_Border_Rounding
	)

	local textButton = Instance.new("TextButton", background)
	textButton.Name = ""
	textButton.Size = UDim2.new(1, 0, 1, 0)
	textButton.BackgroundTransparency = 1
	textButton.Font = THEME.Font_SemiBold
	textButton.TextColor3 = THEME.Text_Color
	textButton.TextSize = THEME.Keybind_Text_Size

	-- Functionality
	local keyCodeName = string.sub(tostring(defaultKeyCode), 14, string.len(tostring(defaultKeyCode)))
	local engaged = false

	local function Update()
		local textWidth = game:GetService("TextService"):GetTextSize(keyCodeName, THEME.Keybind_Text_Size, THEME.Font_SemiBold, Vector2.new(math.huge, math.huge)).X
		background.Size = UDim2.new(0, textWidth + 12, 0, THEME.Keybind_Height)
		textButton.Text = keyCodeName
	end

	textButton.MouseButton1Click:Connect(function()
		engaged = true
		background.ImageColor3 = THEME.Keybind_Engaged_Color
	end)

	INPUT_SERVICE.InputBegan:Connect(function(key)
		if engaged then
			engaged = false
			background.ImageColor3 = THEME.Keybind_Background_Color

			keyCodeName = string.sub(tostring(key.KeyCode), 14, string.len(tostring(key.KeyCode)))

			if keyCodeName ~= "Unknown" then
				Update()
			end
		end
	end)

	Update()

	-- Keybind class
	local keybind = {}

	function keybind.GetKeyCode()
		return Enum.KeyCode[keyCodeName]
	end

	return keybind
end

local function CreateOutput(parent, labelCount)
	if labelCount == nil then labelCount = 1 end

	local backgroundHeight = THEME.Output_Label_Height * labelCount

	local container = Instance.new("Frame", parent)
	container.Name = ""
	container.Size = UDim2.new(1, 0, 0, backgroundHeight + THEME.Output_Background_Vertical_Padding)
	container.BackgroundTransparency = 1

	local background = CreateFrame(
		container,
		UDim2.new(1, -THEME.Output_Background_Side_Padding, 0, backgroundHeight + THEME.Output_Background_Extra_Height),
		UDim2.new(0.5, 0, 0.5, THEME.Output_Background_Extra_Height / 2),
		Vector2.new(0.5, 0.5),
		THEME.Output_Background_Color,
		THEME.Output_Background_Border_Rounding
	)

	local labels = {}

	for i = 1, labelCount do
		local label = Instance.new("TextLabel", background)
		label.Name = ""
		label.Size = UDim2.new(1, -THEME.Output_Label_Left_Text_Padding, 0, THEME.Output_Label_Height)
		label.Position = UDim2.new(1, 0, 0, THEME.Output_Label_Height * (i - 1))
		label.AnchorPoint = Vector2.new(1, 0)
		label.BackgroundTransparency = 1
		label.Font = THEME.Output_Font
		label.TextSize = THEME.Output_Text_Size
		label.TextColor3 = THEME.Text_Color
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Text = ""

		labels[i] = label
	end

	-- Output class
	local output = {}

	function output.EditLabel(index, text)
		if labels[index] then
			labels[index].Text = text
		end
	end

	function output.GetLabel(index)
		return labels[index]
	end

	return output
end

-- Complex Gui Features
local function CreateWindow(parent, title, size)
	local borderRounding = 3
	local background = CreateFrame(parent, UDim2.new(0, size[1], 0, size[2]), nil, nil, THEME.Window_Background_Color, borderRounding)

	-- Handle backgroud
	local handleBackgroundRounding = CreateFrame(
		background,
		UDim2.new(1, 0, 0, borderRounding * 2),
		nil,
		nil,
		THEME.Window_Handle_Color,
		borderRounding
	)

	local handleBackground = CreateFrame(
		background,
		UDim2.new(1, 0, 0, 20 - borderRounding),
		UDim2.new(0, 0, 0, borderRounding),
		nil,
		THEME.Window_Handle_Color,
		0
	)

	handleBackgroundRounding.ZIndex = 2
	handleBackground.ZIndex = 2

	-- Title also acts as the handle with the minimize and maximize buttons
	local titleLabel = Instance.new("TextLabel", background)
	titleLabel.Name = ""
	titleLabel.Size = UDim2.new(1, 0, 0, 20)
	titleLabel.Position = UDim2.new(0, 8, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = THEME.Font_SemiBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = THEME.Text_Color
	titleLabel.TextSize = 14
	titleLabel.ZIndex = 2
	titleLabel.Text = title

	local dragHandle = Instance.new("TextButton", background)
	dragHandle.Name = ""
	dragHandle.Size = UDim2.new(1, 0, 0, 20)
	dragHandle.BackgroundTransparency = 1
	dragHandle.Text = ""

	-- Buttons
	local closeButton = Instance.new("ImageButton", background)
	closeButton.Name = ""
	closeButton.Image = "rbxassetid://4389749368"
	closeButton.Size = UDim2.new(0, 12, 0, 12)
	closeButton.BackgroundTransparency = 1
	closeButton.AutoButtonColor = false
	closeButton.Position = UDim2.new(1, -18, 0, 4)
	closeButton.ZIndex = 2

	local miniButton = Instance.new("ImageButton", background)
	miniButton.Name = ""
	miniButton.Image = "rbxassetid://4530358017"
	miniButton.Size = UDim2.new(0, 12, 0, 12)
	miniButton.BackgroundTransparency = 1
	miniButton.AutoButtonColor = false
	miniButton.Position = UDim2.new(1, -37, 0, 4)
	miniButton.ZIndex = 2

	-- Functionality
	local active = true
	local minimised = false

	-- Close window event
	closeButton.MouseButton1Click:Connect(function()
		active = false
	end)

	-- Minimize
	miniButton.MouseButton1Click:Connect(function()
		minimised = not minimised

		if minimised then
			local textWidth = game:GetService("TextService"):GetTextSize(title, 14, THEME.Font_SemiBold, Vector2.new(math.huge, math.huge)).X
			background.Size = UDim2.new(0, textWidth + 60, 0, 20)

			handleBackground.Visible = false
			background.ImageColor3 = THEME.Window_Handle_Color

			for _, v in pairs(background:GetChildren()) do
				if v:IsA("ScrollingFrame") then
					v.Visible = false
				end
			end
		else
			background.Size = UDim2.new(0, size[1], 0, size[2])

			handleBackground.Visible = true
			background.ImageColor3 = THEME.Window_Background_Color

			for _, v in pairs(background:GetChildren()) do
				if v:IsA("ScrollingFrame") then
					v.Visible = true
				end
			end
		end
	end)

	-- Dragging
	local startDragPos = Vector2.new(0, 0)
	local dragging = false

	dragHandle.MouseButton1Down:Connect(function()
		startDragPos = Vector2.new(MOUSE.X, MOUSE.Y)
		dragging = true

		local dragStartOffset = Vector2.new(MOUSE.X, MOUSE.Y) - dragHandle.AbsolutePosition

		repeat
			background.Position = UDim2.new(0, MOUSE.X - dragStartOffset.X, 0, MOUSE.Y - dragStartOffset.Y)

			RUN_SERVICE.RenderStepped:Wait()
		until dragging == false
	end)

	dragHandle.MouseButton1Up:Connect(function()
		dragging = false
	end)

	MOUSE.Button1Up:Connect(function()
		dragging = false
	end)

	-- Window class
	local class = {}

	-- Methods
	function class.IsActive()
		return active
	end

	function class.GetBackground()
		return background
	end

	return class
end

local function CreateFolder(scrollingFrame, folderName, elementPadding)
	if folderName     == nil then folderName     = "Folder" end
	if elementPadding == nil then elementPadding = 0        end

	local frame = Instance.new("Frame", scrollingFrame)
	frame.Name = ""
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, THEME.Folder_Handle_Height)

	local container = Instance.new("Frame", frame)
	container.Name = ""
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 0, 0)
	container.Position = UDim2.new(0, 0, 0, THEME.Folder_Handle_Height)

	local titleLabel = Instance.new("TextLabel", frame)
	titleLabel.Name = ""
	titleLabel.Size = UDim2.new(1, -THEME.Folder_Title_Left_Padding, 0, THEME.Folder_Handle_Height)
	titleLabel.Position = UDim2.new(1, 0, 0, 0)
	titleLabel.AnchorPoint = Vector2.new(1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = THEME.Font_Bold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	titleLabel.TextColor3 = THEME.Folder_Title_Color
	titleLabel.TextSize = 12
	titleLabel.Text = folderName

	local collapse = Instance.new("ImageButton", frame)
	collapse.Name = ""
	collapse.Image = "http://www.roblox.com/asset/?id=54479709"
	collapse.BackgroundTransparency = 1
	collapse.AnchorPoint = Vector2.new(0.5, 0.5)
	collapse.Size = UDim2.new(0, THEME.Folder_Collapse_Button_Dimensions.X, 0, THEME.Folder_Collapse_Button_Dimensions.Y)
	collapse.Position = UDim2.new(0, THEME.Folder_Collapse_Left_Padding, 0, THEME.Folder_Handle_Height / 2 + 3)

	local list = Instance.new("UIListLayout", container)
	list.Name = ""
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, elementPadding)

	-- Functionality
	local childrenHeight = 0
	local isCollapsed = false

	local function CalculateNewHeight()
		RUN_SERVICE.RenderStepped:Wait()
		childrenHeight = list.AbsoluteContentSize.Y

		frame.Size = UDim2.new(1, 0, 0, childrenHeight + THEME.Folder_Handle_Height)
		container.Size = UDim2.new(1, 0, 0, childrenHeight)
	end

	container.ChildAdded:Connect(function(c)
		if isCollapsed == false then
			CalculateNewHeight()
		end
	end)

	container.ChildRemoved:Connect(function(c)
		if isCollapsed == false then
			CalculateNewHeight()
		end
	end)

	-- Collapse
	local function Update()
		collapse.Rotation = isCollapsed and -180 or -90

		if isCollapsed then
			frame.Size = UDim2.new(1, 0, 0, THEME.Folder_Handle_Height)
		else
			frame.Size = UDim2.new(1, 0, 0, container.Size.Y.Offset + THEME.Folder_Handle_Height)
		end

		for _, v in pairs(container:GetDescendants()) do
			pcall(function()
				v.Visible = not isCollapsed
			end)
		end
	end

	collapse.MouseButton1Click:Connect(function()
		isCollapsed = not isCollapsed

		Update()
	end)

	container.DescendantAdded:Connect(function(c)
		if isCollapsed then
			pcall(function()
				c.Visible = not isCollapsed
			end)
		end
	end)

	Update()


	return container
end




-- Application Creation
local applicationGui = CreateGui()

local window = CreateWindow(applicationGui, "City-17", { 300, 230 })
local elementsContainer = CreateScrollingFrame(window.GetBackground(), UDim2.new(1, 0, 1, -20), UDim2.new(0, 0, 0, 20), nil, 0, 0)

-- Proximity Prompts
local folder_Proximity_Prompts   = CreateFolder(elementsContainer, "Proximity Prompts")
local button_Vending_Machine     = CreateButton(folder_Proximity_Prompts, "Vending Machine", "Access")
local button_Gun_Dealer_Everyone = CreateButton(folder_Proximity_Prompts, "Gun Dealer Everyone", "Access")
local button_Gun_Dealer_Rebel    = CreateButton(folder_Proximity_Prompts, "Gun Dealer Rebel", "Access")
local button_Gun_Dealer          = CreateButton(folder_Proximity_Prompts, "Gun Dealer", "Access")
local button_Illegal_Dealer      = CreateButton(folder_Proximity_Prompts, "Illegal Dealer", "Access")

-- Touch Interests
local folder_Touch_Interests = CreateFolder(elementsContainer, "Touch Interests")
local button_Grant_Green_Card = CreateButton(folder_Touch_Interests, "Grant Green Card", "Grant")

-- Clean Trash
local folder_Clean_Trash = CreateFolder(elementsContainer, "Clean Nearest Trash")
local button_Clean_Trash = CreateButton(folder_Clean_Trash, "Clean Trash", "Clean")

CreatePadding(folder_Clean_Trash, 4)
local button_Clean_Trash_Burst = CreateButton(folder_Clean_Trash, "Clean Trash Burst", "Clean")
local input_Clean_Trash_Burst_Count = CreateInput(folder_Clean_Trash, "Burst Count", 10)

-- Auto Cashier
local folder_Auto_Cashier   = CreateFolder(elementsContainer, "Auto Cashier")
local switch_Auto_Cashier_Souvenirs = CreateSwitch(folder_Auto_Cashier, "Souvenirs Shop", false)
local switch_Auto_Cashier_Unknown_Owner = CreateSwitch(folder_Auto_Cashier, "Unknown Owner Shop", false)



-- Cursor (used to show where the mouse incase the mouse icon is invisible)
local cursor = Instance.new("Frame", applicationGui)
cursor.Name = ""
cursor.BorderSizePixel = 0
cursor.Size = UDim2.new(0, 2, 0, 2)
cursor.AnchorPoint = Vector2.new(0.5, 0.5)
cursor.BackgroundColor3 = Color3.new(1, 1, 1)

-- Events
local chatConnection = game:GetService("Chat").Chatted:Connect(function(part, message, color)
	local objects = nil

	if switch_Auto_Cashier_Souvenirs.On() then
		objects = workspace.cShopFile["Shop1"].Shop.Objects
	elseif switch_Auto_Cashier_Unknown_Owner.On() then
		objects = workspace.cShopFile["Shop4"].Shop.Objects
	end

	if objects then
		local validObject = nil

		for _, v in pairs(objects:GetChildren()) do
			if string.find(string.lower(message), string.lower(v.Name)) then
				validObject = v
				break
			end
		end

		if validObject then
			local delayMin = 0.5
			local delayMax = 1.5

			local delayTime = RNG:NextNumber(delayMin, delayMax)
			wait(delayTime)

			local clickDetector = validObject:FindFirstChild("ClickDetector")

			if clickDetector then
				fireclickdetector(clickDetector)
			end
		end
	end
end)

-- Process is called every frame
local function Process(deltaTime)
	local camera = workspace.CurrentCamera

	-- Find character and humanoid
	local character = LOCAL_PLAYER.Character
	local humanoid = nil

	if character then
		humanoid = character:FindFirstChild("Humanoid")
	end

	-- Cursor handling
	local winPos = window.GetBackground().AbsolutePosition
	local winSize = window.GetBackground().AbsoluteSize

	cursor.Position = UDim2.new(0, MOUSE.X, 0, MOUSE.Y)

	if MOUSE.X > winPos.X and MOUSE.X < winPos.X + winSize.X and MOUSE.Y > winPos.Y and MOUSE.Y < winPos.Y + winSize.Y then
		cursor.Visible = true
	else
		cursor.Visible = false
	end

	-- Proximity prompts
	pcall(function()
		if button_Vending_Machine.GetPressCount() > 0 then
			fireproximityprompt(workspace.VendingMachines.VMachine.ProximityPrompt)
		end

		if button_Gun_Dealer_Everyone.GetPressCount() > 0 then
			fireproximityprompt(workspace["gun_dealer_everyone"].HumanoidRootPart.ProximityPrompt)
		end

		if button_Gun_Dealer_Rebel.GetPressCount() > 0 then
			fireproximityprompt(workspace["gun_dealer_rebel"].HumanoidRootPart.ProximityPrompt)
		end

		if button_Gun_Dealer.GetPressCount() > 0 then
			fireproximityprompt(workspace["gun_dealer"].HumanoidRootPart.ProximityPrompt)
		end

		if button_Illegal_Dealer.GetPressCount() > 0 then
			fireproximityprompt(workspace["printer_dealer"].HumanoidRootPart.ProximityPrompt)
		end


		for i = 1, button_Clean_Trash.GetPressCount() do
			for _, v in pairs(workspace.TrashFolder:GetChildren()) do
				if v:IsA("BasePart") then
					local prompt = v:FindFirstChild("trashprompt")

					if prompt then
						if prompt:IsA("ProximityPrompt") then
							fireproximityprompt(prompt, 0)
						end
					end
				end
			end
		end
		
		if button_Clean_Trash_Burst.GetPressCount() > 0 then
			local prompts = {}
			
			for _, v in pairs(workspace.TrashFolder:GetChildren()) do
				if v:IsA("BasePart") then
					if (v.Position - character:GetPrimaryPartCFrame().Position).Magnitude < 10 then
						local prompt = v:FindFirstChild("trashprompt")

						if prompt then
							if prompt:IsA("ProximityPrompt") then
								table.insert(prompts, prompt)
							end
						end
					end
				end
			end
			
			for i = 1, input_Clean_Trash_Burst_Count.GetInputTextAsNumber() do
				for _, v in pairs(prompts) do
					fireproximityprompt(v, 0)
				end
			end
		end
	end)
	
	-- Touch Interests
	if button_Grant_Green_Card.GetPressCount() > 0 then
		pcall(function()
			firetouchinterest(
				character.Torso,
				workspace.Ignore.Grant,
				0
			)

			print("Touched.")
		end)
	end
end

-- Bind process function to render step. Priority set to last so we can have control over everything (maybe)
local uniqueId = game:GetService("HttpService"):GenerateGUID(false)
RUN_SERVICE:BindToRenderStep(uniqueId, Enum.RenderPriority.Last.Value, Process)

-- Wait until window is closed
repeat RUN_SERVICE.RenderStepped:Wait() until window.IsActive() == false

RUN_SERVICE:UnbindFromRenderStep(uniqueId) -- Unbind loop
applicationGui:Destroy() -- Destroy GUI
script.Parent = nil -- Connections are destroyed if parent set to nil
