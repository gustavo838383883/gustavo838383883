local disk = GetPartFromPort(1, "Disk")

local gputer = disk:Read("GD7Library")

local createwindow = gputer.CreateWindow
local screen = gputer.Screen
local createnicebutton = gputer.createnicebutton

local window = createwindow(UDim2.fromScale(0.7, 0.7), "Resources", false, false, false, "Resources", false, false)

local resetbutton = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0), "Refresh", window)

local mainscrollframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.fromScale(1, 0.8), Position = UDim2.fromScale(0, 0.2), BackgroundTransparency = 1, CanvasSize = UDim2.fromOffset(0, 25)})

local stuff = {}

local function startnow()

	for index, value in ipairs(stuff) do
		value:Destroy()
	end

	stuff = {}

	mainscrollframe.CanvasSize = UDim2.fromOffset(0, 25)

	local start = 0

	local bins = GetPartsFromPort(1, "Bin")
	local containers = GetPartsFromPort(1, "Container")

	for i, value in ipairs(bins) do
		mainscrollframe.CanvasSize += UDim2.fromOffset(0, 25)

		start += 1

		local textlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(0.5, 0, 0, 25), Position = UDim2.fromOffset(0, 25*start), BackgroundTransparency = 1, TextScaled = true, Text = tostring(value:GetResource())})
		local textlabel2 = screen:CreateElement("TextLabel", {Size = UDim2.new(0.5, 0, 0, 25), Position = UDim2.new(0.5, 0, 0, 25*start), BackgroundTransparency = 1, TextScaled = true, Text = tostring(value:GetAmount())})
		mainscrollframe:AddChild(textlabel)
		mainscrollframe:AddChild(textlabel2)
		table.insert(stuff, textlabel)
		table.insert(stuff, textlabel2)
	end

	for i, value in ipairs(containers) do
		mainscrollframe.CanvasSize += UDim2.fromOffset(0, 25)

		start += 1

		local textlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(0.5, 0, 0, 25), Position = UDim2.fromOffset(0, 25*start), BackgroundTransparency = 1, TextScaled = true, Text = tostring(value:GetResource())})
		local textlabel2 = screen:CreateElement("TextLabel", {Size = UDim2.new(0.5, 0, 0, 25), Position = UDim2.fromOffset(0.5, 0, 0, 25*start), BackgroundTransparency = 1, TextScaled = true, Text = tostring(value:GetAmount())})
		mainscrollframe:AddChild(textlabel)
		mainscrollframe:AddChild(textlabel2)
		table.insert(stuff, textlabel)
		table.insert(stuff, textlabel2)
	end

end

startnow()

resetbutton.MouseButton1Up:Connect(function()
	startnow()

end)
