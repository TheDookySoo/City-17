local SCRIPT_ENABLED = true

local LOCAL_PLAYER = game.Players.LocalPlayer
local MOUSE = LOCAL_PLAYER:GetMouse()
local RNG = Random.new()

local INPUT_SERVICE = game:GetService("UserInputService")

local APPLICATION_GUI_PARENT = game:GetService("RunService"):IsStudio() and game.Players.LocalPlayer.PlayerGui or game.CoreGui
local APPLICATION_SIZE = UDim2.new(0, 280, 0, 235)
local APPLICATION_MINIMIZED = false

local ELEMENT_CONTAINER_EXTRA_PADDING = 0
local ELEMENT_CONTAINER_HEIGHT = 19
local ELEMENT_TITLE_PADDING = 10
local SLIDER_MAX_DECIMAL_PLACES = 2

local APPLICATION_THEME = {}
do
	APPLICATION_THEME.TextColor = Color3.fromRGB(255, 255, 255)
	APPLICATION_THEME.Padding_TextColor = Color3.fromRGB(100, 120, 190)

	APPLICATION_THEME.TextFont_Standard = Enum.Font.Gotham
	APPLICATION_THEME.TextFont_SemiBold = Enum.Font.GothamSemibold
	APPLICATION_THEME.TextFont_Bold = Enum.Font.GothamBold

	APPLICATION_THEME.Cursor_Color = Color3.new(1, 1, 1)

	APPLICATION_THEME.Color_Light = Color3.fromRGB(45, 45, 45)
	APPLICATION_THEME.Color_Medium = Color3.fromRGB(30, 30, 30)
	APPLICATION_THEME.Color_Dark = Color3.fromRGB(15, 15, 15)

	APPLICATION_THEME.Slider_Background_Color = Color3.fromRGB(60, 60, 60)
	APPLICATION_THEME.Slider_Bar_Color = Color3.fromRGB(190, 190, 190)

	APPLICATION_THEME.Keybind_Engaged_Color = Color3.fromRGB(110, 40, 40)
	APPLICATION_THEME.Keybind_NotEngaged_Color = Color3.fromRGB(30, 30, 30)

	APPLICATION_THEME.Button_Engaged_Color = Color3.fromRGB(110, 40, 40)
	APPLICATION_THEME.Button_NotEngaged_Color = Color3.fromRGB(30, 30, 30)

	APPLICATION_THEME.Input_Background_Color = Color3.fromRGB(30, 30, 30)

	APPLICATION_THEME.Switch_Background_Color = Color3.fromRGB(60, 60, 60)
	APPLICATION_THEME.Switch_Knob_Color = Color3.fromRGB(220, 220, 220)
	APPLICATION_THEME.Switch_Off_Color = Color3.fromRGB(30, 30, 30)
	APPLICATION_THEME.Switch_On_Color = Color3.fromRGB(30, 120, 190)
end

-- Functions
local function Lerp(start, finish, alpha)
	return start * (1 - alpha) + (finish * alpha)
end

-- Gui Functions
local function CreateGui(parent, name, resetOnSpawn, ignoreGuiInset)
	local gui = Instance.new("ScreenGui", parent)
	gui.Name = name

	gui.IgnoreGuiInset = ignoreGuiInset
	gui.ResetOnSpawn = resetOnSpawn

	return gui
end

local function AddPadding(parent, size, text)
	local paddingText = text ~= nil and text or ""

	local padding = Instance.new("TextButton", parent)
	padding.Name = "Padding"
	padding.BackgroundTransparency = 1
	padding.BorderSizePixel = 0
	padding.Size = UDim2.new(1, 0, 0, size)
	padding.Font = APPLICATION_THEME.TextFont_SemiBold
	padding.TextColor3 = APPLICATION_THEME.Padding_TextColor
	padding.TextSize = 12
	padding.TextXAlignment = Enum.TextXAlignment.Left
	padding.TextYAlignment = Enum.TextYAlignment.Bottom
	padding.Text = "  " .. paddingText

	return padding
end

local function CreateFrame(parent, name, borderRounding, size, position, anchorPoint, color)
	local frame_Position = position ~= nil and position or UDim2.new(0, 0, 0, 0)
	local frame_AnchorPoint = anchorPoint ~= nil and anchorPoint or Vector2.new(0, 0)

	local frame = Instance.new("ImageLabel", parent)
	frame.Name = name
	frame.Image = "rbxassetid://3570695787"
	frame.ImageColor3 = color == nil and APPLICATION_THEME.Color_Light or color
	frame.ScaleType = Enum.ScaleType.Slice
	frame.SliceCenter = Rect.new(Vector2.new(100, 100), Vector2.new(100, 100))
	frame.SliceScale = 0.01 * borderRounding
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Active = true

	frame.Size = size
	frame.Position = frame_Position
	frame.AnchorPoint = frame_AnchorPoint

	return frame
end

local function CreateDragHandle(parent, attachedGui, name, size, position, anchorPoint, text)
	local handle_Size = size ~= nil and size or UDim2.new(1, 0, 1, 0)
	local handle_Position = position ~= nil and position or UDim2.new(0, 0, 0, 0)
	local handle_AnchorPoint = anchorPoint ~= nil and anchorPoint or Vector2.new(0, 0)

	local handle = Instance.new("TextButton", parent)
	handle.Name = name
	handle.Size = handle_Size
	handle.Position = handle_Position
	handle.AnchorPoint = handle_AnchorPoint
	handle.BackgroundTransparency = 1
	handle.Text = "  " .. text
	handle.TextSize = 14
	handle.Font = APPLICATION_THEME.TextFont_SemiBold
	handle.TextXAlignment = Enum.TextXAlignment.Left
	handle.TextColor3 = APPLICATION_THEME.TextColor

	local border = Instance.new("Frame", handle)
	border.Name = "TitleBorder"
	border.Size = UDim2.new(1, 0, 0, 1)
	border.Position = UDim2.new(0.5, 0, 0, 20)
	border.AnchorPoint = Vector2.new(0.5, 0)
	border.BorderSizePixel = 0
	border.Active = false

	local titleBorder_Gradient = Instance.new("UIGradient", border)
	border.BackgroundColor3 = Color3.new(1, 1, 1)
	titleBorder_Gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.05, 0.5),
		NumberSequenceKeypoint.new(0.95, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	}

	local closeButton = Instance.new("ImageButton", handle)
	closeButton.Name = "CloseButton"
	closeButton.Image = "rbxassetid://4389749368"
	closeButton.Size = UDim2.new(0, 12, 0, 12)
	closeButton.AnchorPoint = Vector2.new(0, 0.5)
	closeButton.BackgroundTransparency = 1
	closeButton.AutoButtonColor = false
	closeButton.Position = UDim2.new(1, -18, 0.5, 0)

	local miniButton = Instance.new("ImageButton", handle)
	miniButton.Name = "MinimizeButton"
	miniButton.Image = "rbxassetid://4530358017"
	miniButton.Size = UDim2.new(0, 12, 0, 12)
	miniButton.AnchorPoint = Vector2.new(0, 0.5)
	miniButton.BackgroundTransparency = 1
	miniButton.AutoButtonColor = false
	miniButton.Position = UDim2.new(1, -37, 0.5, 0)

	-- Enable Disable
	miniButton.MouseButton1Click:Connect(function()
		if APPLICATION_MINIMIZED then
			APPLICATION_MINIMIZED = false

			--parent.Visible = true
			--parent.Size = UDim2.new(0, APPLICATION_SIZE.X, 0, APPLICATION_SIZE.Y)
		else
			APPLICATION_MINIMIZED = true

			--parent.Visible = false
			--parent.Size = UDim2.new(0, APPLICATION_SIZE.X, 0, ELEMENT_CONTAINER_HEIGHT)

			-- localPlayer.CameraMinZoomDistance = before_CameraMinZoom
			-- localPlayer.CameraMaxZoomDistance = before_CameraMaxZoom
		end
	end)

	closeButton.MouseButton1Click:Connect(function()
		SCRIPT_ENABLED = false
		attachedGui:Destroy()
	end)



	local dragging = false

	handle.MouseButton1Down:Connect(function()
		dragging = true

		local dragStartOffset = Vector2.new(MOUSE.X, MOUSE.Y) - handle.AbsolutePosition

		repeat
			parent.Position = UDim2.new(0, MOUSE.X - dragStartOffset.X, 0, MOUSE.Y - dragStartOffset.Y)

			game:GetService("RunService").RenderStepped:Wait()
		until dragging == false
	end)

	handle.MouseButton1Up:Connect(function()
		dragging = false
	end)

	return handle
end

local function CreateScrollingFrame(parent, name, size, position, anchorPoint, padding)
	local container_Position = position ~= nil and position or UDim2.new(0, 0, 0, 0)
	local container_AnchorPoint = anchorPoint ~= nil and anchorPoint or Vector2.new(0, 0)

	local container = Instance.new("ScrollingFrame", parent)
	container.Name = name
	container.BorderSizePixel = 0
	container.BackgroundTransparency = 1
	container.ScrollingEnabled = true
	container.Size = size
	container.Position = container_Position
	container.AnchorPoint = container_AnchorPoint
	container.BottomImage = container.MidImage
	container.TopImage = container.MidImage
	container.ScrollBarThickness = 4

	local list = Instance.new("UIListLayout", container)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, padding)

	local scrolling = false
	local engaged = false

	container.CanvasSize = UDim2.new(0, 0, 0, ELEMENT_CONTAINER_EXTRA_PADDING)

	container.ChildAdded:Connect(function(c)
		pcall(function()
			wait()
			container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + c.AbsoluteSize.Y + ELEMENT_CONTAINER_EXTRA_PADDING)
		end)
	end)

	container.ChildRemoved:Connect(function(c)
		pcall(function()
			wait()
			container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y - c.AbsoluteSize.Y + ELEMENT_CONTAINER_EXTRA_PADDING)
		end)
	end)

	return container
end

-- Elements
local function CreateSlider(parent, name, titleText, min, max, defaultValue, inputSuffix)
	local suffix = inputSuffix ~= nil and inputSuffix or ""

	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	-- Element
	local sliderBackground = CreateFrame(elementContainer, "SliderBackground", 3, UDim2.new(1, -180, 0, 7), UDim2.new(1, -10, 0.5, 0), Vector2.new(1, 0.5), APPLICATION_THEME.Slider_Background_Color)
	local sliderBar = CreateFrame(sliderBackground, "SliderBar", 3, UDim2.new(Lerp(0, 1, (defaultValue - min) / (max - min)), 0, 1, 0), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0), APPLICATION_THEME.Slider_Bar_Color)

	local sliderClickBox = Instance.new("TextButton", sliderBackground)
	sliderClickBox.Name = "ClickBox"
	sliderClickBox.BackgroundTransparency = 1
	sliderClickBox.Text = ""
	sliderClickBox.Size = UDim2.new(1, 0, 1, 0)

	local valueTextLabel = Instance.new("TextLabel", sliderClickBox)
	valueTextLabel.Name = "ValueLabel"
	valueTextLabel.BackgroundTransparency = 1
	valueTextLabel.Size = UDim2.new(0, 1000, 0, 14)
	valueTextLabel.Font = APPLICATION_THEME.TextFont_SemiBold
	valueTextLabel.TextSize = 12
	valueTextLabel.TextColor3 = APPLICATION_THEME.TextColor
	valueTextLabel.TextTransparency = 1
	valueTextLabel.Text = ""

	-- Functionality
	local mouseDown = false
	local currentValue = defaultValue

	sliderClickBox.MouseButton1Down:Connect(function()
		mouseDown = true

		do
			local goal = {}
			goal.TextTransparency = 0

			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

			local tween = game:GetService("TweenService"):Create(valueTextLabel, tweenInfo, goal)
			tween:Play()
		end

		repeat
			local dt = game:GetService("RunService").RenderStepped:Wait()

			local alpha = (MOUSE.X - sliderClickBox.AbsolutePosition.X) / sliderClickBox.AbsoluteSize.X
			alpha = math.clamp(alpha, 0, 1)

			sliderBar.Size = UDim2.new(Lerp(sliderBar.Size.X.Scale, alpha, 1 - (0.0000001 ^ dt)), 0, 1, 0)

			-- Label
			local realAlpha = sliderBar.AbsoluteSize.X / sliderBackground.AbsoluteSize.X
			local realValue = Lerp(min, max, sliderBar.AbsoluteSize.X / sliderBackground.AbsoluteSize.X)
			local realValueShortened = math.floor((realValue * (10 ^ SLIDER_MAX_DECIMAL_PLACES)) + 0.5) / (10 ^ SLIDER_MAX_DECIMAL_PLACES)

			currentValue = realValue
			valueTextLabel.Text = realValueShortened .. suffix

			valueTextLabel.AnchorPoint = Vector2.new(0.5, 0)
			valueTextLabel.Position = UDim2.new(realAlpha, 0, 1, 4)
			valueTextLabel.ZIndex = 100
		until mouseDown == false

		do
			local goal = {}
			goal.TextTransparency = 1

			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

			local tween = game:GetService("TweenService"):Create(valueTextLabel, tweenInfo, goal)
			tween:Play()
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			mouseDown = false
			wait(0.25)
			valueTextLabel.ZIndex = 1
		end
	end)

	-- Return
	local t = {}

	function t.GetValue()
		return currentValue
	end

	return t
end

local function CreateSwitch(parent, name, titleText, onByDefault)
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	-- Element
	local backgroundColor = onByDefault and APPLICATION_THEME.Switch_On_Color or APPLICATION_THEME.Switch_Off_Color

	local switchBackground = CreateFrame(elementContainer, "SliderBackground", 7, UDim2.new(0, 30, 0, 13), UDim2.new(0, 170, 0.5, 0), Vector2.new(0, 0.5), backgroundColor)

	local knob = Instance.new("ImageLabel", switchBackground)
	knob.Name = "Knob"
	knob.Image = "rbxassetid://3570695787"
	knob.BackgroundTransparency = 1
	knob.ImageColor3 = APPLICATION_THEME.Switch_Knob_Color
	knob.Size = UDim2.new(0, 11, 0, 11)
	knob.Position = UDim2.new(0, 1, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0, 0.5)

	local switchClickBox = Instance.new("TextButton", switchBackground)
	switchClickBox.Name = "ClickBox"
	switchClickBox.BackgroundTransparency = 1
	switchClickBox.Text = ""
	switchClickBox.Size = UDim2.new(1, 0, 1, 0)

	-- Functionality
	local switchUpdated = false
	local switchOn = not onByDefault

	local firstUpdate = false

	local function UpdateSwitch()
		switchOn = not switchOn

		switchUpdated = true

		if firstUpdate == false then
			firstUpdate = true
			switchUpdated = false
		end



		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

		if switchOn then
			local goal_1 = {}
			goal_1.AnchorPoint = Vector2.new(1, 0.5)
			goal_1.Position = UDim2.new(1, -1, 0.5, 0)

			local goal_2 = {}
			goal_2.ImageColor3 = APPLICATION_THEME.Switch_On_Color

			local tween_1 = game:GetService("TweenService"):Create(knob, tweenInfo, goal_1) tween_1:Play()
			local tween_1 = game:GetService("TweenService"):Create(switchBackground, tweenInfo, goal_2) tween_1:Play()
		else
			local goal_1 = {}
			goal_1.AnchorPoint = Vector2.new(0, 0.5)
			goal_1.Position = UDim2.new(0, 1, 0.5, 0)

			local goal_2 = {}
			goal_2.ImageColor3 = APPLICATION_THEME.Switch_Off_Color

			local tween_1 = game:GetService("TweenService"):Create(knob, tweenInfo, goal_1) tween_1:Play()
			local tween_1 = game:GetService("TweenService"):Create(switchBackground, tweenInfo, goal_2) tween_1:Play()
		end
	end

	switchClickBox.MouseButton1Click:Connect(function()
		UpdateSwitch()
	end)

	UpdateSwitch()

	-- Return
	local t = {}

	function t.ValueChanged()
		local r = switchUpdated
		switchUpdated = false

		return r
	end

	function t.GetValue()
		return switchOn
	end

	return t
end

local function CreateKeybind(parent, name, titleText, defaultKeyCode) -- Allows you to set keybinds
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	local background = CreateFrame(elementContainer, "Background", 5, UDim2.new(0, 90, 0, 15), UDim2.new(0, 170, 0.5, 0), Vector2.new(0, 0.5))
	background.Name = "Background"
	background.ImageColor3 = APPLICATION_THEME.Keybind_NotEngaged_Color

	local clickBox = Instance.new("TextButton", background)
	clickBox.Name = "ClickBox"
	clickBox.BackgroundTransparency = 1
	clickBox.Font = APPLICATION_THEME.TextFont_SemiBold
	clickBox.TextSize = 12
	clickBox.Size = UDim2.new(1, 0, 1, 0)
	clickBox.TextColor3 = APPLICATION_THEME.TextColor
	clickBox.Text = string.sub(tostring(defaultKeyCode), 14, string.len(tostring(defaultKeyCode)))

	-- Functionality
	local engaged = false

	local function Update(keyName, isEngaged)
		local textWidth = game:GetService("TextService"):GetTextSize(keyName, 12, APPLICATION_THEME.TextFont_SemiBold, Vector2.new(math.huge, math.huge)).X
		background.Size = UDim2.new(0, textWidth + 14, 0, 15)

		if isEngaged then
			background.ImageColor3 = APPLICATION_THEME.Keybind_Engaged_Color
		else
			background.ImageColor3 = APPLICATION_THEME.Keybind_NotEngaged_Color
		end
	end

	Update(clickBox.Text, engaged)

	game:GetService("UserInputService").InputBegan:Connect(function(key)
		if engaged then
			local keyName = tostring(key.KeyCode)
			keyName = string.sub(keyName, 14, string.len(keyName))

			if keyName ~= "Unknown" then
				engaged = false
				clickBox.Text = keyName

				-- Tween
				Update(keyName, engaged)
			end
		end
	end)

	clickBox.MouseButton1Click:Connect(function()
		engaged = true

		-- Tween
		Update(clickBox.Text, engaged)
	end)

	-- Return
	local t = {}

	function t.GetKeyCode()
		return Enum.KeyCode[clickBox.Text]
	end

	return t
end

local function CreateButton(parent, name, titleText, buttonText) -- Allows you to set keybinds
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	local button = CreateFrame(elementContainer, "ButtonBackground", 4, UDim2.new(0, 90, 0, 15), UDim2.new(0, 170, 0.5, 0), Vector2.new(0, 0.5))
	button.ImageColor3 = APPLICATION_THEME.Button_NotEngaged_Color

	local clickBox = Instance.new("TextButton", button)
	clickBox.Name = "ClickBox"
	clickBox.BackgroundTransparency = 1
	clickBox.Font = APPLICATION_THEME.TextFont_SemiBold
	clickBox.TextSize = 12
	clickBox.Size = UDim2.new(1, 0, 1, 0)
	clickBox.TextColor3 = APPLICATION_THEME.TextColor
	clickBox.Text = buttonText

	-- Functionality
	local pressed = false
	local mouseEnter = false

	clickBox.MouseEnter:Connect(function()
		button.ImageColor3 = APPLICATION_THEME.Button_Engaged_Color
		mouseEnter = true
	end)

	clickBox.MouseLeave:Connect(function()
		button.ImageColor3 = APPLICATION_THEME.Button_NotEngaged_Color
		mouseEnter = false
	end)

	clickBox.MouseButton1Click:Connect(function()
		pressed = true

		button.ImageColor3 = APPLICATION_THEME.Button_NotEngaged_Color
		wait()
		button.ImageColor3 = APPLICATION_THEME.Button_Engaged_Color
	end)

	-- Return
	local t = {}

	function t.ButtonPressed()
		local p = pressed
		pressed = false

		return p
	end

	function t.HoveringOver()
		return mouseEnter
	end

	return t
end

local function CreateInput(parent, name, titleText, default) -- Allows the user to provide input
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	local background = CreateFrame(elementContainer, "ButtonBackground", 4, UDim2.new(1, -180, 0, 15), UDim2.new(0, 170, 0.5, 0), Vector2.new(0, 0.5))
	background.ImageColor3 = APPLICATION_THEME.Input_Background_Color

	local inputBox = Instance.new("TextBox", background)
	inputBox.Name = "InputBox"
	inputBox.BackgroundTransparency = 1
	inputBox.Font = APPLICATION_THEME.TextFont_SemiBold
	inputBox.TextSize = 12
	inputBox.Size = UDim2.new(1, -5, 1, 0)
	inputBox.TextXAlignment = Enum.TextXAlignment.Left
	inputBox.AnchorPoint = Vector2.new(1, 0)
	inputBox.Position = UDim2.new(1, 0, 0, 0)
	inputBox.TextColor3 = APPLICATION_THEME.TextColor
	inputBox.Text = default ~= nil and default or "Enter Here"

	-- Functionality
	local textChanged = false
	local previousText = inputBox.Text

	inputBox.FocusLost:Connect(function()
		if previousText ~= inputBox.Text then
			textChanged = true
		end

		previousText = inputBox.Text
	end)

	-- Return
	local t = {}

	function t.InputChanged()
		local v = textChanged
		textChanged = false

		return v
	end

	function t.GetText()
		return inputBox.Text
	end

	function t.GetNumber()
		return typeof(tonumber(inputBox.Text)) == "number" and tonumber(inputBox.Text) or 0
	end

	function t.SetText(t)
		inputBox.Text = t
	end

	return t
end

local function CreateColorPicker(parent, name, titleText)
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, 160)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	-- Gradient Map
	local backplate = Instance.new("Frame", elementContainer)
	backplate.Name = "Backplate"
	backplate.BorderSizePixel = 0
	backplate.BackgroundColor3 = Color3.new(0, 0, 0)
	backplate.Position = UDim2.new(0, 10, 0, 20)
	backplate.Size = UDim2.new(0, 100, 0, 100)

	local colorGradientBox = Instance.new("ImageLabel", backplate)
	colorGradientBox.Name = "ColorGradientBox"
	colorGradientBox.Image = "rbxassetid://1280017782"
	colorGradientBox.Size = UDim2.new(1, 0, 1, 0)
	colorGradientBox.Position = UDim2.new(0, 0, 0, 0)
	colorGradientBox.Rotation = 90
	colorGradientBox.BackgroundTransparency = 1

	local whiteGradientBox = Instance.new("ImageLabel", backplate)
	whiteGradientBox.Name = "WhiteGradientBox"
	whiteGradientBox.Image = "rbxassetid://1280017782"
	whiteGradientBox.ImageColor3 = Color3.new(1, 1, 1)
	whiteGradientBox.Size = UDim2.new(1, 0, 1, 0)
	whiteGradientBox.Position = UDim2.new(0, 0, 0, 0)
	whiteGradientBox.BackgroundTransparency = 1

	local blackGradientBox = Instance.new("ImageLabel", backplate)
	blackGradientBox.Name = "BlackGradientBox"
	blackGradientBox.Image = "rbxassetid://1280017782"
	blackGradientBox.ImageColor3 = Color3.new(0, 0, 0)
	blackGradientBox.Size = UDim2.new(1, 0, 1, 0)
	blackGradientBox.Position = UDim2.new(0, 0, 0, 0)
	blackGradientBox.Rotation = -90
	blackGradientBox.BackgroundTransparency = 1

	-- Color Map
	local backplate2 = Instance.new("Frame", elementContainer)
	backplate2.Name = "Backplate2"
	backplate2.BorderSizePixel = 0
	backplate2.BackgroundColor3 = Color3.new(0, 0, 0)
	backplate2.Position = UDim2.new(0, 115, 0, 20)
	backplate2.Size = UDim2.new(0, 100, 0, 100)

	local colorMap = Instance.new("ImageLabel", backplate2)
	colorMap.Name = "ColorMap"
	colorMap.Image = "rbxassetid://5425155739"
	colorMap.Size = UDim2.new(1, 0, 1, 0)
	colorMap.Position = UDim2.new(0, 0, 0, 0)
	colorMap.BackgroundTransparency = 1

	local desaturatedMap = Instance.new("ImageLabel", backplate2)
	desaturatedMap.Name = "DesaturatedMap"
	desaturatedMap.Image = "rbxassetid://5425157396"
	desaturatedMap.Size = UDim2.new(1, 0, 1, 0)
	desaturatedMap.Position = UDim2.new(0, 0, 0, 0)
	desaturatedMap.BackgroundTransparency = 1

	spawn(function()
		local t = 0
		local t2 = 0

		while true do
			local dt = game:GetService("RunService").RenderStepped:Wait()
			t = t + (dt / 2) if t > 1 then t = 0 end
			t2 = t2 + (dt * 2)

			colorGradientBox.ImageColor3 = Color3.fromHSV(t, 1, 1)

			desaturatedMap.ImageTransparency = math.sin(t2) / 2 + 0.5
		end
	end)
end

local function CreateOutput(parent, name, elementCount) -- Allows the script to show the user info
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, 18 * elementCount + 6)

	local background = CreateFrame(elementContainer, "ButtonBackground", 4, UDim2.new(1, -20, 0, 18 * elementCount), UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5))
	background.ImageColor3 = APPLICATION_THEME.Input_Background_Color

	local elements = {} -- Table which store the individual status text labels

	for i = 1, elementCount do
		local label = Instance.new("TextBox", background)
		label.Name = "InputBox"
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Code --APPLICATION_THEME.TextFont_SemiBold
		label.TextSize = 14
		label.Size = UDim2.new(1, -5, 0, 15)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.AnchorPoint = Vector2.new(1, 0)
		label.Position = UDim2.new(1, 0, 0, 18 * (i - 1) + 1)
		label.TextColor3 = APPLICATION_THEME.TextColor
		label.Text = ""

		table.insert(elements, label)
	end

	-- Return
	local t = {}

	function t.EditStatus(id, text)
		elements[id].Text = text
	end



	return t
end

-- Misc. Functions
local function MatchPlayerWithString(str)
	for _, v in pairs(game.Players:GetPlayers()) do
		if string.find(string.lower(v.Name), string.lower(str)) then
			return v
		end
	end
end

local function StringToNumber(str, returnValueIfNotValid)
	local ret = returnValueIfNotValid ~= nil and returnValueIfNotValid or 0
	return typeof(tonumber(str)) == "number" and tonumber(str) or ret
end

-- Math Functions
local function RoundNumber(number, decimals)
	local multiplier = 10 ^ decimals

	return math.floor(number * multiplier + 0.5) / multiplier
end



-- Application Gui
local APP_GUI = CreateGui(APPLICATION_GUI_PARENT, "APPLICATION", false, false)

local mainFrame = CreateFrame(APP_GUI, "MainFrame", 3, APPLICATION_SIZE, UDim2.new(0, 0, 0, 0))
mainFrame.ClipsDescendants = true

local dragHandle = CreateDragHandle(mainFrame, APP_GUI, "DragHandle", UDim2.new(1, 0, 0, 20), nil, nil, "City-17")

local elements_Container = CreateScrollingFrame(mainFrame, "ElementsContainer", UDim2.new(1, 0, 1, -22), UDim2.new(0, 0, 0, 22), nil, 0)

local cursor = Instance.new("Frame", APP_GUI)
cursor.BorderSizePixel = 0
cursor.Size = UDim2.new(0, 2, 0, 2)
cursor.AnchorPoint = Vector2.new(0.5, 0.5)
cursor.BackgroundColor3 = Color3.new(1, 1, 1)

-- GUI elements here
AddPadding(elements_Container, 17, "Proximity Prompts")
local button_VendingMachine = CreateButton(elements_Container, "", "Vending Machine", "Access")
local button_GunDealerEveryone = CreateButton(elements_Container, "", "Gun Dealer Everyone", "Access")
local button_GunDealerRebel = CreateButton(elements_Container, "", "Gun Dealer Rebel", "Access")
local button_GunDealer = CreateButton(elements_Container, "", "Gun Dealer", "Access")
local button_PrinterDealer = CreateButton(elements_Container, "", "Printer Dealer", "Access")

AddPadding(elements_Container, 4, "")
local button_CleanNearestTrash = CreateButton(elements_Container, "", "Clean Nearest Trash", "Clean")

AddPadding(elements_Container, 17, "Auto Cashier")
local switch_AutoCashierSouvenirs = CreateSwitch(elements_Container, "", "Souvenirs Shop", false)
local switch_AutoCashierUnknownOwner = CreateSwitch(elements_Container, "", "Unknown Owner Shop", false)

-- Events
local chatConnection = game:GetService("Chat").Chatted:Connect(function(part, message, color)
	local objects = nil
	
	if switch_AutoCashierSouvenirs.GetValue() == true then
		objects = workspace.cShopFile["Shop1"].Shop.Objects
	elseif switch_AutoCashierUnknownOwner.GetValue() == true then
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

while SCRIPT_ENABLED do
	local camera = workspace.CurrentCamera

	-- Cursor
	cursor.Position = UDim2.new(0, MOUSE.X, 0, MOUSE.Y)
	if MOUSE.X > mainFrame.AbsolutePosition.X and MOUSE.X < mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X and MOUSE.Y > mainFrame.AbsolutePosition.Y and MOUSE.Y < mainFrame.AbsolutePosition.Y + mainFrame.AbsoluteSize.Y then
		cursor.Visible = true
	else
		cursor.Visible = false
	end

	-- Humanoid
	local humanoid = nil

	if LOCAL_PLAYER.Character then
		if LOCAL_PLAYER.Character:FindFirstChild("Humanoid") then
			humanoid = LOCAL_PLAYER.Character.Humanoid
		end
	end

	-- Proximity prompts
	pcall(function()
		if button_VendingMachine.ButtonPressed() then
			fireproximityprompt(workspace.VendingMachines.VMachine.ProximityPrompt)
		end
		
		if button_GunDealerEveryone.ButtonPressed() then
			fireproximityprompt(workspace["gun_dealer_everyone"].HumanoidRootPart.ProximityPrompt)
		end
		
		if button_GunDealerRebel.ButtonPressed() then
			fireproximityprompt(workspace["gun_dealer_rebel"].HumanoidRootPart.ProximityPrompt)
		end
		
		if button_GunDealer.ButtonPressed() then
			fireproximityprompt(workspace["gun_dealer"].HumanoidRootPart.ProximityPrompt)
		end
		
		if button_PrinterDealer.ButtonPressed() then
			fireproximityprompt(workspace["printer_dealer"].HumanoidRootPart.ProximityPrompt)
		end
		
		
		if button_CleanNearestTrash.ButtonPressed() then
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
	end)
	

	game:GetService("RunService").RenderStepped:Wait()
end

chatConnection:Disconnect()
