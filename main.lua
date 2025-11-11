local MenuUI = {}
MenuUI.__index = MenuUI

-- Default styling
MenuUI.Defaults = {
	BackgroundColor = Color3.fromRGB(40, 40, 40),
	BackgroundTransparency = 0.1,
	TextColor = Color3.fromRGB(255, 255, 255),
	AccentColor = Color3.fromRGB(0, 162, 255),
	BorderColor = Color3.fromRGB(60, 60, 60),
	Font = Enum.Font.Gotham,
	TextSize = 14,
	CornerRadius = UDim.new(0, 6),
	Padding = 10,
	ItemHeight = 30
}

function MenuUI.new(options)
	options = options or {}
	local self = setmetatable({}, MenuUI)

	self._style = setmetatable(options.Style or {}, {__index = MenuUI.Defaults})
	self._parent = options.Parent or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	self._menus = {}
	self._openMenus = {}

	return self
end

-- Create a basic button element
function MenuUI:_CreateButton(text, callback, parent)
	local button = Instance.new("TextButton")
	button.Name = "MenuButton"
	button.Text = text
	button.BackgroundColor3 = self._style.BackgroundColor
	button.BackgroundTransparency = 0
	button.TextColor3 = self._style.TextColor
	button.Font = self._style.Font
	button.TextSize = self._style.TextSize
	button.Size = UDim2.new(1, 0, 0, self._style.ItemHeight)
	button.AutoButtonColor = false
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = self._style.CornerRadius
	corner.Parent = button

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = button

	-- Hover effects
	button.MouseEnter:Connect(function()
		if not self:_IsButtonDisabled(button) then
			game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
				BackgroundColor3 = self._style.AccentColor,
				TextColor3 = Color3.new(1, 1, 1)
			}):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		if not self:_IsButtonDisabled(button) then
			game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
				BackgroundColor3 = self._style.BackgroundColor,
				TextColor3 = self._style.TextColor
			}):Play()
		end
	end)

	button.MouseButton1Click:Connect(function()
		if not self:_IsButtonDisabled(button) then
			callback()
		end
	end)

	return button
end

function MenuUI:_IsButtonDisabled(button)
	return button.BackgroundTransparency > 0.5
end

-- Create a toggle button
function MenuUI:_CreateToggle(text, initialState, callback, parent)
	local isToggled = initialState or false

	local toggle = Instance.new("TextButton")
	toggle.Name = "ToggleButton"
	toggle.Text = text
	toggle.BackgroundColor3 = self._style.BackgroundColor
	toggle.BackgroundTransparency = 0
	toggle.TextColor3 = self._style.TextColor
	toggle.Font = self._style.Font
	toggle.TextSize = self._style.TextSize
	toggle.Size = UDim2.new(1, 0, 0, self._style.ItemHeight)
	toggle.AutoButtonColor = false
	toggle.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = self._style.CornerRadius
	corner.Parent = toggle

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = toggle

	local indicator = Instance.new("Frame")
	indicator.Name = "ToggleIndicator"
	indicator.Size = UDim2.new(0, 16, 0, 16)
	indicator.Position = UDim2.new(1, -24, 0.5, 0)
	indicator.AnchorPoint = Vector2.new(0, 0.5)
	indicator.BackgroundColor3 = isToggled and self._style.AccentColor or Color3.fromRGB(100, 100, 100)
	indicator.Parent = toggle

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(0, 4)
	indicatorCorner.Parent = indicator

	local function updateAppearance()
		indicator.BackgroundColor3 = isToggled and self._style.AccentColor or Color3.fromRGB(100, 100, 100)
	end

	toggle.MouseEnter:Connect(function()
		game:GetService("TweenService"):Create(toggle, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		}):Play()
	end)

	toggle.MouseLeave:Connect(function()
		game:GetService("TweenService"):Create(toggle, TweenInfo.new(0.1), {
			BackgroundColor3 = self._style.BackgroundColor
		}):Play()
	end)

	toggle.MouseButton1Click:Connect(function()
		isToggled = not isToggled
		updateAppearance()
		callback(isToggled)
	end)

	updateAppearance()
	return toggle
end

-- Create a slider element
function MenuUI:_CreateSlider(text, minValue, maxValue, initialValue, step, callback, parent)
	local sliderValue = initialValue or minValue

	local sliderContainer = Instance.new("Frame")
	sliderContainer.Name = "SliderContainer"
	sliderContainer.BackgroundTransparency = 1
	sliderContainer.Size = UDim2.new(1, 0, 0, self._style.ItemHeight + 20)
	sliderContainer.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "SliderLabel"
	label.Text = string.format("%s : %.1f", text, sliderValue)
	label.BackgroundTransparency = 1
	label.TextColor3 = self._style.TextColor
	label.Font = self._style.Font
	label.TextSize = self._style.TextSize
	label.Size = UDim2.new(1, 0, 0, self._style.ItemHeight)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = sliderContainer

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = label

	local track = Instance.new("Frame")
	track.Name = "SliderTrack"
	track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	track.Size = UDim2.new(1, -16, 0, 4)
	track.Position = UDim2.new(0, 8, 1, -8)
	track.BorderSizePixel = 0
	track.Parent = sliderContainer

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 2)
	trackCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Name = "SliderFill"
	fill.BackgroundColor3 = self._style.AccentColor
	fill.Size = UDim2.new((sliderValue - minValue) / (maxValue - minValue), 0, 1, 0)
	fill.BorderSizePixel = 0
	fill.Parent = track

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 2)
	fillCorner.Parent = fill

	local thumb = Instance.new("TextButton")
	thumb.Name = "SliderThumb"
	thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	thumb.Size = UDim2.new(0, 12, 0, 12)
	thumb.Position = UDim2.new(fill.Size.X.Scale, -6, 0.5, 0)
	thumb.AnchorPoint = Vector2.new(0, 0.5)
	thumb.Text = ""
	thumb.AutoButtonColor = false
	thumb.Parent = track

	local thumbCorner = Instance.new("UICorner")
	thumbCorner.CornerRadius = UDim.new(1, 0)
	thumbCorner.Parent = thumb
	
	local function roundToStep(value)
		return math.floor((value / step) + 0.5) * step
	end

	local function updateSlider(value)
		value = roundToStep(value)
		sliderValue = math.clamp(value, minValue, maxValue)
		local ratio = (sliderValue - minValue) / (maxValue - minValue)

		fill.Size = UDim2.new(ratio, 0, 1, 0)
		thumb.Position = UDim2.new(ratio, -6, 0.5, 0)
		label.Text = string.format("%s : %.1f", text, sliderValue)

		callback(sliderValue)
	end

	local isDragging = false

	thumb.MouseButton1Down:Connect(function()
		isDragging = true
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mousePos = game:GetService("UserInputService"):GetMouseLocation()
			local absolutePosition = track.AbsolutePosition
			local absoluteSize = track.AbsoluteSize

			local relativeX = (mousePos.X - absolutePosition.X) / absoluteSize.X
			relativeX = math.clamp(relativeX, 0, 1)

			local value = minValue + (relativeX * (maxValue - minValue))
			updateSlider(value)
		end
	end)

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mousePos = game:GetService("UserInputService"):GetMouseLocation()
			local absolutePosition = track.AbsolutePosition
			local absoluteSize = track.AbsoluteSize

			local relativeX = (mousePos.X - absolutePosition.X) / absoluteSize.X
			relativeX = math.clamp(relativeX, 0, 1)

			local value = minValue + (relativeX * (maxValue - minValue))
			updateSlider(value)
		end
	end)

	return sliderContainer
end

-- Create a menu container
function MenuUI:CreateMenu(menuId, options)
	options = options or {}

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = menuId .. "Menu"
	screenGui.Parent = self._parent
	screenGui.ResetOnSpawn = false

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.BackgroundColor3 = self._style.BackgroundColor
	mainFrame.BackgroundTransparency = self._style.BackgroundTransparency
	mainFrame.Size = UDim2.new(0, options.Width or 200, 0, 0) -- Height will be auto-adjusted
	mainFrame.Position = options.Position or UDim2.new(0, 10, 0, 10)
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = self._style.CornerRadius
	corner.Parent = mainFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = self._style.BorderColor
	stroke.Thickness = 1
	stroke.Parent = mainFrame

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 1, 0)
	container.Parent = mainFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 2)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = container

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	padding.Parent = container

	local menu = {
		ScreenGui = screenGui,
		MainFrame = mainFrame,
		Container = container,
		Layout = layout,
		Items = {}
	}

	self._menus[menuId] = menu

	-- Auto-size the menu
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		mainFrame.Size = UDim2.new(mainFrame.Size.X.Scale, mainFrame.Size.X.Offset, 0, layout.AbsoluteContentSize.Y + 16)
	end)

	return menu
end

-- Add items to menu
function MenuUI:AddButton(menuId, text, callback)
	local menu = self._menus[menuId]
	if not menu then return end

	local button = self:_CreateButton(text, callback, menu.Container)
	table.insert(menu.Items, {Type = "Button", Element = button})
	return button
end

function MenuUI:AddToggle(menuId, text, initialState, callback)
	local menu = self._menus[menuId]
	if not menu then return end

	local toggle = self:_CreateToggle(text, initialState, callback, menu.Container)
	table.insert(menu.Items, {Type = "Toggle", Element = toggle})
	return toggle
end

function MenuUI:AddSlider(menuId, text, minValue, maxValue, initialValue, step, callback)
	local menu = self._menus[menuId]
	if not menu then return end

	local slider = self:_CreateSlider(text, minValue, maxValue, initialValue, step, callback, menu.Container)
	table.insert(menu.Items, {Type = "Slider", Element = slider})
	return slider
end

function MenuUI:AddLabel(menuId, text)
	local menu = self._menus[menuId]
	if not menu then return end

	local label = Instance.new("TextLabel")
	label.Name = "MenuLabel"
	label.Text = text
	label.BackgroundTransparency = 1
	label.TextColor3 = self._style.TextColor
	label.Font = self._style.Font
	label.TextSize = self._style.TextSize
	label.Size = UDim2.new(1, 0, 0, self._style.ItemHeight)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = menu.Container

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = label

	table.insert(menu.Items, {Type = "Label", Element = label})
	return label
end

function MenuUI:AddSeparator(menuId)
	local menu = self._menus[menuId]
	if not menu then return end

	local separator = Instance.new("Frame")
	separator.Name = "Separator"
	separator.BackgroundColor3 = self._style.BorderColor
	separator.BorderSizePixel = 0
	separator.Size = UDim2.new(1, -16, 0, 1)
	separator.Position = UDim2.new(0, 8, 0, 0)
	separator.Parent = menu.Container

	table.insert(menu.Items, {Type = "Separator", Element = separator})
	return separator
end

-- Menu visibility control
function MenuUI:ShowMenu(menuId)
	local menu = self._menus[menuId]
	if menu then
		menu.ScreenGui.Enabled = true
		self._openMenus[menuId] = true
	end
end

function MenuUI:HideMenu(menuId)
	local menu = self._menus[menuId]
	if menu then
		menu.ScreenGui.Enabled = false
		self._openMenus[menuId] = nil
	end
end

function MenuUI:ToggleMenu(menuId)
	local menu = self._menus[menuId]
	if menu then
		if self._openMenus[menuId] then
			self:HideMenu(menuId)
		else
			self:ShowMenu(menuId)
		end
	end
end

function MenuUI:DestroyMenu(menuId)
	local menu = self._menus[menuId]
	if menu then
		menu.ScreenGui:Destroy()
		self._menus[menuId] = nil
		self._openMenus[menuId] = nil
	end
end

function MenuUI:SetMenuPosition(menuId, position)
	local menu = self._menus[menuId]
	if menu then
		menu.MainFrame.Position = position
	end
end

-- Style customization
function MenuUI:UpdateStyle(newStyle)
	for key, value in pairs(newStyle) do
		self._style[key] = value
	end

	-- Update all existing menus
	for menuId, menu in pairs(self._menus) do
		self:_UpdateMenuStyle(menu)
	end
end

function MenuUI:_UpdateMenuStyle(menu)
	menu.MainFrame.BackgroundColor3 = self._style.BackgroundColor
	menu.MainFrame.BackgroundTransparency = self._style.BackgroundTransparency

	for _, item in pairs(menu.Items) do
		if item.Type == "Button" or item.Type == "Toggle" then
			item.Element.BackgroundColor3 = self._style.BackgroundColor
			item.Element.TextColor3 = self._style.TextColor
			item.Element.Font = self._style.Font
			item.Element.TextSize = self._style.TextSize
		elseif item.Type == "Label" then
			item.Element.TextColor3 = self._style.TextColor
			item.Element.Font = self._style.Font
			item.Element.TextSize = self._style.TextSize
		end
	end
end

return MenuUI
