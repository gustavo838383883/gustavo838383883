--temporarily gustavos unstable

local Players = require("players")

local function createfileontable(disk, filename, filedata, directory)
	local returntable = nil
	local directory = directory
	if directory:sub(-1, -1) == "/" then directory = directory:sub(1, -2) end
	local split = string.split(directory, "/")

	if split then
		if split[1] and split[2] then
			local rootfile = disk:Read(split[2])
			local tablez = {
				[1] = rootfile,
			}
			if typeof(rootfile) == "table" then
				local resulttable = rootfile
				if #split >= 3 then
					for i=3,#split,1 do
						if resulttable[split[i]] then
							resulttable = resulttable[split[i]]
							table.insert(tablez, resulttable)
						end
					end
				end
			end
			tablez[#tablez][filename] = filedata

			returntable = rootfile

			disk:Write(split[2], rootfile)
		end
	end
	return returntable
end

local function getfileontable(disk, filename, directory)
	local directory = directory
	if directory:sub(-1, -1) == "/" then directory = directory:sub(1, -2) end
	local split = string.split(directory, "/")
	local file = nil
	if split then
		if split[1] and split[2] then
			local rootfile = disk:Read(split[2])
			local tablez = {
				[1] = rootfile,
			}
			if typeof(rootfile) == "table" then
				local resulttable = rootfile
				if #split >= 3 then
					for i=3,#split,1 do
						if resulttable[split[i]] then
							resulttable = resulttable[split[i]]
							table.insert(tablez, resulttable)
						end
					end
				end
				file = resulttable[filename]
			end
		end
	end
	return file
end

local disks = nil
local screen = nil
local keyboard = nil
local speaker = nil
local modem = nil
local rom = nil
local disk = nil
local regularscreen = nil
local keyboardinput
local microphoneevent
local playerthatinputted
local backgroundimage
local color
local iconsdisabled
local iconsize
local tile = false
local tilesize
local clicksound
local smallestaxis
local startsound
local shutdownsound
local romport
local disksport
local romindexusing
local sharedport
local microphone = nil

local bootos

local CreateWindow

local disk6 = GetPartFromPort(6, "Disk")
local putermode = false

if disk6 and disk6:Read("PuterLibrary") then
	disk6:ClearDisk()
	disk6:Write("PuterMode", true)
	putermode = true
elseif disk6 and disk6:Read("PuterMode") == true then
	putermode = true
end

if putermode then
	pcall(TriggerPort, 4)
end

local function getstuff()
	disks = nil
	rom = nil
	disk = nil
	screen = nil
	keyboard = nil
	speaker = nil
	modem = nil
	regularscreen = nil
	disksport = nil
	romport = nil
	romindexusing = nil
	sharedport = nil
	microphone = nil

	local previ = 0
	for i=0, 64 do
		if not GetPort(i) then
			continue
		end
		if i - previ > 5 then
			previ = i
			task.wait(0.1)
		end
		if not rom then
			local temprom = GetPartFromPort(i, "Disk")
			if temprom then
				if #temprom:ReadAll() == 0 then
					rom = temprom
					romport = i
				elseif temprom:Read("SysDisk") then
					rom = temprom
					romport = i
				end
			end
		end
		if not disks then
			local disktable = GetPartsFromPort(i, "Disk")
			if disktable then
				if #disktable > 0 then
					local cancel = false
					local tempport = GetPartFromPort(i, "Port")
					if tempport and tempport.PortID == romport then
						cancel = true
					end
					if romport == i and #disktable == 1 then
						cancel = true
					end
					if not cancel then
						disks = disktable
						disksport = i
					end
				end
			end
		end

		if disks and #disks > 1 and romport == disksport and not sharedport then
			for index,v in ipairs(disks) do
				if v then
					if #v:ReadAll() == 0 then
						rom = v
						romport = i
						romindexusing = index
						sharedport = true
						break
					elseif v:Read("SysDisk") then
						rom = v
						romindexusing = index
						romport = i
						sharedport = true
						break
					end
				end
			end
		end

		if not modem then
			local tempmodem = GetPartFromPort(i, "Modem")
			if tempmodem then
				modem = tempmodem
			end
		end

		if not microphone then
			local tempmicrphone = GetPartFromPort(i, "Microphone")
			if tempmicrphone then
				microphone = tempmicrphone
			end
		end

		if not speaker then
			local tempspeaker = GetPartFromPort(i, "Speaker")
			if tempspeaker then
				speaker = tempspeaker
			end
		end
		if not screen then
			local tempscreen = GetPartFromPort(i, "TouchScreen")
			if tempscreen then
				screen = tempscreen
			end
		end
		if not regularscreen then
			local tempscreen = GetPartFromPort(i, "Screen")
			if tempscreen then
				regularscreen = tempscreen
			end
		end
		if not keyboard then
			local tempkeyboard = GetPartFromPort(i, "Keyboard")
			if tempkeyboard then
				keyboard = tempkeyboard
			end
		end
	end
end
getstuff()


local name = "GustavOSDesktop7"
local commandline = {}
local defaultbuttonsize = Vector2.new(0,0)
local players = {}
local keyboardevent
local cursorevent
local startCursorPos
local videovolume = 0.5
local loadingscreen
local mainframe
local windows = {}

local holding = false
local holding2 = false

local prevCursorPos
local uiStartPos
local minimizedprograms = {}

local function getCursorColliding(X, Y, ui)
	if X and Y and ui then else return end
	local x = ui.AbsolutePosition.X
	local y = ui.AbsolutePosition.Y
	local y_axis = nil
	local x_axis = nil
	local guiposx = X + 5
	local number = ui.AbsoluteSize.X + 5

	if x - guiposx > -number then
		if x - guiposx < 0 then
			x_axis = X - guiposx
		end
	end

	local guiposy = Y + 5
	local number2 = ui.AbsoluteSize.Y + 5

	if y - guiposy > -number2 then
		if y - guiposy < 0 then
			y_axis = y - guiposy
		end
	end

	if x_axis and y_axis then
		return true, x_axis, y_axis
	end
end
local holderframetouse
local resizebuttontouse

local programholder1
local programholder2
local taskbarholder

local function exists(frame)
	if frame and pcall(function() frame.Parent = frame.Parent end) then
		return true
	end
	return false
end

local buttondown = false
local taskbarholderscrollingframe

local resolutionframe

local minimizedammount = 0

function CreateWindow(udim2, title, boolean, boolean2, boolean3, text, boolean4, boolean5, boolean6)
	local holderframe = screen:CreateElement("ImageButton", {Size = udim2, BackgroundTransparency = 1, Image = "rbxassetid://8677487226", ImageTransparency = 0.2})
	if not holderframe then return end
	holderframe.Parent = programholder1

	for i, v in pairs(windows) do
		v.Focused = false

		if v.CloseButton then
			v.CloseButton.Image = "rbxassetid://16821401308"
		end
	end

	local closed = false

	local frameindex = 0

	local textlabel
	if typeof(title) == "string" then
		textlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1, -(defaultbuttonsize.X*2), 0, defaultbuttonsize.Y), BackgroundTransparency = 1, Position = UDim2.new(0, defaultbuttonsize.X*2, 0, 0), TextScaled = true, TextWrapped = true, Text = tostring(title)})
		textlabel.Parent = holderframe
	end
	local window = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1,0,1,-(defaultbuttonsize.Y + (defaultbuttonsize.Y/2))), CanvasSize = UDim2.new(1,0,1,-(defaultbuttonsize.Y + (defaultbuttonsize.Y/2))), Position = UDim2.new(0, 0, 0, defaultbuttonsize.Y), BackgroundTransparency = 1})
	window.Parent = holderframe
	local resizebutton
	local maximizepressed = false
	local minimizepressed = false
	local maximizebutton
	local maximizetext
	local minimizebutton

	local functions = {}

	local closebutton

	local function createresizebutton()
		resizebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0,defaultbuttonsize.Y/2,0,defaultbuttonsize.Y/2), Image = "rbxassetid://15617867263", Position = UDim2.new(1, -defaultbuttonsize.Y/2, 1, -defaultbuttonsize.Y/2), BackgroundTransparency = 1})
		resizebutton.Parent = holderframe

		resizebutton.MouseButton1Down:Connect(function()
			if not boolean6 then
				resizebutton.Image = "rbxassetid://15617866125"
			end
			if holding2 then return end
			if boolean2 then return end
			if not maximizepressed then
				local cursors = screen:GetCursors()
				local cursor
				local x_axis
				local y_axis

				for index,cur in pairs(cursors) do
					local boolean, x_Axis, y_Axis = getCursorColliding(cur.X, cur.Y, resizebutton)
					if boolean then
						cursor = cur
						x_axis = x_Axis
						y_axis = y_Axis
						break
					end
				end
				startCursorPos = cursor
				holderframetouse = holderframe
				resizebuttontouse = resizebutton
				holding = true
			end
		end)

		resizebutton.MouseButton1Up:Connect(function()
			if not boolean6 then
				resizebutton.Image = "rbxassetid://15617867263"
			end
			holding = false
		end)
	end

	function functions:IsMaximized()
		return maximizepressed
	end

	function functions:IsMaximizingDisabled()
		return boolean
	end

	function functions:IsMovingDisabled()
		return boolean3
	end

	function functions:IsResizingDisabled()
		return boolean2
	end

	function functions:ToggleMaximizing()
		boolean = not boolean
	end

	function functions:IsMinizingDisabled()
		return boolean4
	end

	function functions:IsMinimized()
		return minimizepressed
	end

	function functions:ToggleMinimizing()
		boolean4 = not boolean4
	end

	function functions:UseAsResizeButton(button)
		button.MouseButton1Down:Connect(function()
			if holding2 then return end
			if boolean2 then return end
			if not maximizepressed then
				local cursors = screen:GetCursors()
				local cursor
				local x_axis
				local y_axis

				for index,cur in pairs(cursors) do
					local boolean, x_Axis, y_Axis = getCursorColliding(cur.X, cur.Y, button)
					if boolean then
						cursor = cur
						x_axis = x_Axis
						y_axis = y_Axis
						break
					end
				end
				startCursorPos = cursor
				holderframetouse = holderframe
				resizebuttontouse = button
				holding = true
			end
		end)
		button.MouseButton1Up:Connect(function()
			holding = false
		end)
	end

	local unminimize

	function functions:Unminimize()
		if minimizepressed and unminimize then
			unminimize()
		end
	end

	function functions:Close()
		if not holderframe then return end
		if not window then return end
		if typeof(windows[frameindex]) ~= "table" or functions:IsClosed() then return end
		windows[frameindex] =  nil
		if minimizepressed then
			functions:Unminimize()
		end
		window:Destroy()
		window = nil
		holderframe:Destroy()
		holderframe = nil
		closed = true
	end

	function functions:Destroy()
		functions:Close()
	end

	local unmaximizedsize = holderframe.Size
	local unmaximizedpos = holderframe.Position

	function functions:IsClosed()
		if closed or not (holderframe or exists(holderframe)) then
			return true
		else
			return false
		end
	end

	function functions:IsFocused()
		if typeof(windows[frameindex]) ~= "table" or functions:IsClosed() then return end
		return windows[frameindex].Focused
	end

	function functions:Minimize(mintext)
		if not mintext then mintext = text end
		if holding or holding2 then return end
		if minimizepressed then return end
		if boolean4 then return end
		holderframe.Parent = resolutionframe
		holderframe.Visible = false
		minimizepressed = true
		if typeof(windows[frameindex]) ~= "table" or functions:IsClosed() then return end
		windows[frameindex].Focused = false
		local unminimizebutton = screen:CreateElement("ImageButton", {Image = "rbxassetid://15625805900", BackgroundTransparency = 1, Size = UDim2.new(0, defaultbuttonsize.X*2, 1, 0), Position = UDim2.new(0, minimizedammount * (defaultbuttonsize.X*2), 0, 0)})
		local unminimizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = if typeof(mintext) == "function" then tostring(mintext()) else tostring(mintext)})
		unminimizetext.Parent = unminimizebutton
		unminimizebutton.Parent = taskbarholderscrollingframe
		minimizedammount += 1
		taskbarholderscrollingframe.CanvasSize = UDim2.new(0, (minimizedammount * (defaultbuttonsize.X*2)) + (defaultbuttonsize.X*2), 1, 0)

		table.insert(minimizedprograms, unminimizebutton)

		if not boolean5 then
			unminimizebutton.MouseButton1Down:Connect(function()
				unminimizebutton.Image = "rbxassetid://15625805069"
			end)
		end

		function unminimize()
			unminimizebutton.Size = UDim2.new(1,0,1,0)
			unminimizebutton:Destroy()
			minimizepressed = false
			minimizedammount -= 1
			for i, v in pairs(windows) do
				v.Focused = false

				if v.CloseButton then
					v.CloseButton.Image = "rbxassetid://16821401308"
				end
			end

			if typeof(windows[frameindex]) ~= "table" or functions:IsClosed() then return end
			windows[frameindex].Focused = true

			if closebutton then
				closebutton.Image = "rbxassetid://15617983488"
			end

			if holderframe then
				holderframe.Parent = programholder1
				holderframe.Visible = true
			end
			local start = 0
			for index, value in ipairs(minimizedprograms) do
				if value and value.Size ~= UDim2.new(1,0,1,0) then
					value.Position = UDim2.new(0, start * (defaultbuttonsize.X*2), 0, 0)
					taskbarholderscrollingframe.CanvasSize = UDim2.new(0, ((defaultbuttonsize.X*2) * start) + defaultbuttonsize.X, 1, 0)
					start += 1
				end
			end
		end

		unminimizebutton.MouseButton1Up:Connect(function()
			unminimizebutton.Image = "rbxassetid://15625805900"
			speaker:PlaySound(clicksound)
			functions:Unminimize()
		end)

		return unminimizebutton
	end

	function functions:ToggleMaximized()
		local holderframe = holderframe
		if holding or holding2 then return end
		if boolean then return end
		if not resizebutton then
			createresizebutton()
		end
		if not maximizepressed then
			if not boolean2 then
				resizebutton.Visible = false
				resizebutton.ImageTransparency = 1
				resizebutton.Size = UDim2.new(0,0,0,0)
				window.Size += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
				window.CanvasSize += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
			end
			unmaximizedsize = holderframe.Size
			unmaximizedpos = holderframe.Position
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizetext.Text = "-"
			maximizepressed = true
		else
			if not boolean2 then
				resizebutton.Visible = true
				resizebutton.ImageTransparency = 0
				resizebutton.Size = UDim2.fromOffset(defaultbuttonsize.Y/2, defaultbuttonsize.Y/2)
				window.Size -= UDim2.fromOffset(0, defaultbuttonsize.Y/2)
				window.CanvasSize -= UDim2.fromOffset(0, defaultbuttonsize.Y/2)
			end
			holderframe.Size = unmaximizedsize
			holderframe.Position = unmaximizedpos
			maximizetext.Text = "+"
			maximizepressed = false
		end
	end

	function functions:ToggleResizing()
		boolean2 = not boolean2
		if not resizebutton then
			window.Size -= UDim2.fromOffset(0, defaultbuttonsize.Y/2)
			window.CanvasSize -= UDim2.fromOffset(0, defaultbuttonsize.Y/2)
			createresizebutton()
		end
		if not boolean2 then
			if resizebutton.ImageTransparency == 1 then return end
			resizebutton.Visible = false
			resizebutton.ImageTransparency = 1
			resizebutton.Size = UDim2.new(0,0,0,0)
			window.Size += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
			window.CanvasSize += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
		else
			if resizebutton.ImageTransparency == 0 then return end
			resizebutton.Visible = true
			resizebutton.ImageTransparency = 0
			resizebutton.Size = UDim2.fromOffset(defaultbuttonsize.Y/2, defaultbuttonsize.Y/2)
			window.Size -= UDim2.fromOffset(0, defaultbuttonsize.Y/2)
			window.CanvasSize -= UDim2.fromOffset(0, defaultbuttonsize.Y/2)
		end
	end

	function functions:ToggleMoving()
		boolean3 = not boolean3
	end

	function functions:AddChild(child)
		if child then
			child.Parent = window
		end
	end

	function functions:CreateElement(name: string, properties: {any})
		local object = screen:CreateElement(name, properties)

		if object then
			object.Parent = window
		end

		return object
	end

	if not boolean2 then
		createresizebutton()
	else
		window.Size += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
		window.CanvasSize += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
	end

	holderframe.MouseButton1Down:Connect(function(x, y)
		if holding then return end
		holderframe.Parent = programholder2
		holderframe.Parent = programholder1
		for i, v in pairs(windows) do
			v.Focused = false

			if v.CloseButton then
				v.CloseButton.Image = "rbxassetid://16821401308"
			end
		end

		if typeof(windows[frameindex]) ~= "table" or functions:IsClosed() then return end
		windows[frameindex].Focused = true

		if closebutton then
			closebutton.Image = "rbxassetid://15617983488"
		end

		if boolean3 then return end
		if maximizepressed then return end
		local cursors = screen:GetCursors()
		local cursor
		local x_axis
		local y_axis

		for index,cur in pairs(cursors) do
			if (Vector2.new(x, y) - Vector2.new(cur.X, cur.Y)).Magnitude < 10 and getCursorColliding(cur.X, cur.Y, holderframe) then
				cursor = cur
				x_axis = x_Axis
				y_axis = y_Axis
				break
			end
		end
		startCursorPos = cursor
		uiStartPos = holderframe.Position
		holderframetouse = holderframe
		holding2 = true
	end)

	holderframe.MouseButton1Up:Connect(function(x, y)
	    for index,cur in pairs(screen:GetCursors()) do
			if (Vector2.new(x, y) - Vector2.new(cur.X, cur.Y)).Magnitude < 10 and cur.Player == startCursorPos.Player then
	        	holding2 = false
				break
			end
		end
	end)

	closebutton = screen:CreateElement("ImageButton", {BackgroundTransparency = 1, Size = UDim2.new(0, defaultbuttonsize.X, 0, defaultbuttonsize.Y), BackgroundColor3 = Color3.new(1,0,0), Image = "rbxassetid://15617983488"})
	closebutton.Parent = holderframe

	closebutton.MouseButton1Up:Connect(function()
		closebutton.Image = "rbxassetid://15617984474"
	end)

	closebutton.MouseButton1Up:Connect(function()
		closebutton.Image = "rbxassetid://15617983488"
		speaker:PlaySound(clicksound)
		functions:Close()
	end)

	if not boolean4 then
		minimizebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0,defaultbuttonsize.X,0,defaultbuttonsize.Y), Image = "rbxassetid://15617867263", Position = UDim2.new(0, defaultbuttonsize.X*2, 0, 0), BackgroundTransparency = 1})
		minimizebutton.Parent = holderframe
		local minimizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "↓"})
		minimizetext.Parent = minimizebutton
		if title then
			if textlabel then
				textlabel.Position += UDim2.new(0, defaultbuttonsize.X, 0, 0)
				textlabel.Size -= UDim2.new(0, defaultbuttonsize.X, 0, 0)
			end
		end

		if not boolean5 then
			minimizebutton.MouseButton1Down:Connect(function()
				minimizebutton.Image = "rbxassetid://15617866125"
			end)
		end

		if boolean then
			minimizebutton.Position -= UDim2.new(0, defaultbuttonsize.X, 0, 0)
		end

		minimizebutton.MouseButton1Up:Connect(function()
			if holding or holding2 then return end
			speaker:PlaySound(clicksound)
			minimizebutton.Image = "rbxassetid://15617867263"
			functions:Minimize()
		end)
	end

	if not boolean then
		maximizebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0,defaultbuttonsize.X,0,defaultbuttonsize.Y), Image = "rbxassetid://15617867263", Position = UDim2.new(0, defaultbuttonsize.X, 0, 0), BackgroundTransparency = 1})
		maximizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "+"})
		maximizetext.Parent = maximizebutton

		maximizebutton.Parent = holderframe

		maximizebutton.MouseButton1Down:Connect(function()
			maximizebutton.Image = "rbxassetid://15617866125"
		end)

		maximizebutton.MouseButton1Up:Connect(function()
			if holding or holding2 then return end
			speaker:PlaySound(clicksound)
			maximizebutton.Image = "rbxassetid://15617867263"
			functions:ToggleMaximized()
		end)
	else
		if textlabel then
			textlabel.Position -= UDim2.new(0, defaultbuttonsize.X, 0, 0)
			textlabel.Size += UDim2.new(0, defaultbuttonsize.X, 0, 0)
		end
	end


	frameindex = #windows + 1

	functions.FrameIndex = frameindex

	local prevfunctions = table.clone(functions)

	functions = setmetatable({}, {
		__index = functions,
		__newindex = function(array, i, v)
			print("Attempt to write to the functions table")
			error("Attempt to write to the functions table")
		end,
	})

	prevfunctions.AddChild = function(self, child)
		child.Parent = holderframe
	end

	local windowmeta = setmetatable(prevfunctions, {
		__index = holderframe,
		__newindex = function(array, i, v)
			if not pcall(function() return holderframe[i] end) then
				print(`{i} is not a valid nember of the Instance: {holderframe}`)
				error(`{i} is not a valid nember of the Instance: {holderframe}`)
			else
				holderframe[i] = v
			end
		end,
		__len = function()
			return 0
		end,
	})

	windows[frameindex] = {Name = text or title, Holderframe = window, Window = holderframe, CloseButton = closebutton, MaximizeButton = maximizebutton, TextLabel = textlabel, ResizeButton = resizebutton, MinimizeButton = minimizebutton, FunctionsTable = functions, Focused = true}

	return window, windowmeta, closebutton, maximizebutton, textlabel, resizebutton, minimizebutton, functions, frameindex
end

function commandline.new(boolean, udim2, scr, richtext)
	local screen = scr or screen
	local background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0), ScrollBarThickness = 5})
	local holderframe
	local window
	if boolean then
		holderframe, window = CreateWindow(udim2, "Command Line", false, false, false, "Command Line", false)
		background.Parent = holderframe
	end
	local lines = {
		number = UDim2.new(0,0,0,0)
	}
	local biggesttextx = 0

	function lines.clear()
		pcall(function()
			background:Destroy()
			background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0), ScrollBarThickness = 5})
			if boolean then
				background.Parent = holderframe
			end
		end)
		lines.number = UDim2.new(0,0,0,0)
		biggesttextx = 0
	end

	function lines.insert(text, vec2, dontscroll)
		print(text)
		local textlabel = screen:CreateElement("TextBox", {ClearTextOnFocus = false, TextEditable = false, BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Text = tostring(text):gsub("\n", ""), RichText = (richtext or function() return false end)(), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Position = lines.number})
		if textlabel then
			textlabel.Size = UDim2.new(0, math.max(textlabel.TextBounds.X, textlabel.TextSize), 0, math.max(textlabel.TextBounds.Y, textlabel.TextSize))
			if textlabel.TextBounds.X > biggesttextx then
				biggesttextx = textlabel.TextBounds.X
			end
			textlabel.Parent = background
			print(lines.number.Y.Offset)
			background.CanvasSize = UDim2.new(0, biggesttextx, 0, math.max(background.AbsoluteSize.Y, lines.number.Y.Offset + math.max(textlabel.TextBounds.Y, textlabel.TextSize)))
			if typeof(vec2) == "UDim2" then
				vec2 = Vector2.new(vec2.X.Offset + vec2.X.Scale*background.AbsoluteSize.X, vec2.Y.Offset + vec2.Y.Scale*background.AbsoluteSize.Y)
			end
			if typeof(vec2) == "Vector2" then
				textlabel.Size = vec2
				local newsizex = if vec2.X > biggesttextx then vec2.X else 0
				background.CanvasSize -= UDim2.fromOffset(newsizex, math.max(textlabel.TextBounds.Y, textlabel.TextSize))
				background.CanvasSize += UDim2.new(0, newsizex, 0, vec2.Y)
				if udim2.X.Offset > background.AbsoluteSize.X then
					background.CanvasSize += UDim2.new(0, vec2.X - background.AbsoluteSize.X, 0, 0)
				end
				lines.number -= UDim2.new(0,0,0,math.max(textlabel.TextBounds.Y, textlabel.TextSize))
				lines.number += UDim2.new(0, 0, vec2.Y, vec2.Y)
			end
			lines.number += UDim2.new(0, 0, 0, math.max(textlabel.TextBounds.Y, textlabel.TextSize))
			if not dontscroll then
				background.CanvasPosition = Vector2.new(0, lines.number.Y)
			end
		end
		return textlabel
	end
	return lines, setmetatable({}, {
		__index = function(t, a)
			return background[a]
		end,
		__newindex = function(t, a, b)
			background[a] = b
		end,
		__metatable = "This metatable is locked."
	}), holderframe, window
end

local startbutton7
local wallpaper
local backgroundcolor

local function createnicebutton(udim2, pos, text, Parent)
	local txtbutton = screen:CreateElement("ImageButton", {Size = udim2, Image = "rbxassetid://15625805900", Position = pos, BackgroundTransparency = 1})
	local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(text), RichText = true})
	txtlabel.Parent = txtbutton
	if Parent then
		txtbutton.Parent = Parent
	end
	txtbutton.MouseButton1Down:Connect(function()
		txtbutton.Image = "rbxassetid://15625805069"
	end)
	txtbutton.MouseButton1Up:Connect(function()
		speaker:PlaySound(clicksound)
		txtbutton.Image = "rbxassetid://15625805900"
	end)
	return txtbutton, txtlabel
end

local function createnicebutton2(udim2, pos, text, Parent)
	local txtbutton = screen:CreateElement("ImageButton", {Size = udim2, Image = "rbxassetid://15617867263", Position = pos, BackgroundTransparency = 1})
	local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(text), RichText = true})
	txtlabel.Parent = txtbutton
	if Parent then
		txtbutton.Parent = Parent
	end
	txtbutton.MouseButton1Down:Connect(function()
		txtbutton.Image = "rbxassetid://15617866125"
	end)
	txtbutton.MouseButton1Up:Connect(function()
		speaker:PlaySound(clicksound)
		txtbutton.Image = "rbxassetid://15617867263"
	end)
	return txtbutton, txtlabel
end

local function StringToGui(screen, text, parent)
	local start = UDim2.new(0,0,0,0)
	local source = text

	for name, value in source:gmatch('<backimg(.-)(.-)>') do
		local link = nil
		if (string.find(value, 'src="')) then
			local link = string.sub(value, string.find(value, 'src="') + string.len('src="'), string.len(value))
			link = string.sub(link, 1, string.find(link, '"') - 1)
			if true then

				local url = screen:CreateElement("ImageLabel", { })
				url.BackgroundTransparency = 1
				url.Image = "http://www.roblox.com/asset/?id=8552847009"
				if (link ~= "") then
					if tonumber(link) then
						url.Image = "rbxthumb://type=Asset&id="..tonumber(link).."&w=420&h=420"
					else
						url.Image = "rbxthumb://type=Asset&id="..tonumber(string.match(link, "%d+")).."&w=420&h=420"
						print(string.match(link, "%d+"))
					end
				end
				url.ScaleType = Enum.ScaleType.Tile
				url.TileSize = UDim2.new(0, 256, 0, 256)
				url.Size = UDim2.new(1, 0, 1, 0)
				url.Position = UDim2.new(0, 0, 0, 0)
				if (string.find(value, [[tile="]])) then
					local text = string.sub(value, string.find(value, [[tile="]]) + string.len([[tile="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					local udim2 = string.split(text, ",")
					url.TileSize = UDim2.new(tonumber(udim2[1]),tonumber(udim2[2]),tonumber(udim2[3]),tonumber(udim2[4]))
				end
				if (string.find(value, [[transparency="]])) then
					local text = string.sub(value, string.find(value, [[transparency="]]) + string.len([[transparency="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					url.ImageTransparency = tonumber(text) or 0
				end
				url.Parent = parent
			end
		end
	end
	for name, value in source:gmatch('<frame(.-)(.-)>') do
		local link = nil
		if true then

			local url = screen:CreateElement("Frame", { })
			url.Size = UDim2.new(0, 50, 0, 50)
			if (string.find(value, [[rotation="]])) then
				local text = string.sub(value, string.find(value, [[rotation="]]) + string.len([[rotation="]]), string.len(value))
				text = string.sub(text, 1, string.find(text, '"') - 1)
				url.Rotation = tonumber(text)
			end
			if (string.find(value, [[transparency="]])) then
				local text = string.sub(value, string.find(value, [[transparency="]]) + string.len([[transparency="]]), string.len(value))
				text = string.sub(text, 1, string.find(text, '"') - 1)
				url.Transparency = tonumber(text) or 0
			end
			if (string.find(value, [[zindex="]])) then
				local text = string.sub(value, string.find(value, [[zindex="]]) + string.len([[zindex="]]), string.len(value))
				text = string.sub(text, 1, string.find(text, '"') - 1)
				url.ZIndex = tonumber(text) or 1
			end
			if (string.find(value, [[size="]])) then
				local text = string.sub(value, string.find(value, [[size="]]) + string.len([[size="]]), string.len(value))
				text = string.sub(text, 1, string.find(text, '"') - 1)
				local udim2 = string.split(text, ",")
				url.Size = UDim2.new(tonumber(udim2[1]),tonumber(udim2[2]),tonumber(udim2[3]),tonumber(udim2[4]))
			end
			if (string.find(value, [[color="]])) then
				local text = string.sub(value, string.find(value, [[color="]]) + string.len([[color="]]), string.len(value))
				text = string.sub(text, 1, string.find(text, '"') - 1)
				local color = string.split(text, ",")
				url.BackgroundColor3 = Color3.new(tonumber(color[1])/255,tonumber(color[2])/255,tonumber(color[3])/255)
			end
			url.Position = start
			if (string.find(value, [[position="]])) then
				local text = string.sub(value, string.find(value, [[position="]]) + string.len([[position="]]), string.len(value))
				text = string.sub(text, 1, string.find(text, '"') - 1)
				local udim2 = string.split(text, ",")
				url.Position = UDim2.new(tonumber(udim2[1]),tonumber(udim2[2]),tonumber(udim2[3]),tonumber(udim2[4]))
			else
				start = UDim2.new(0,0,start.Y.Scale+url.Size.Y.Scale,start.Y.Offset+url.Size.Y.Offset)
			end
			url.Parent = parent
		end
	end
	for name, value in source:gmatch('<img(.-)(.-)>') do
		local link = nil
		if (string.find(value, 'src="')) then
			local link = string.sub(value, string.find(value, 'src="') + string.len('src="'), string.len(value))
			link = string.sub(link, 1, string.find(link, '"') - 1)
			if true then

				local url = screen:CreateElement("ImageLabel", { })
				url.BackgroundTransparency = 1
				url.Image = "http://www.roblox.com/asset/?id=8552847009"
				if (link ~= "") then
					if tonumber(link) then
						url.Image = "rbxthumb://type=Asset&id="..tonumber(link).."&w=420&h=420"
					else
						url.Image = "rbxthumb://type=Asset&id="..tonumber(string.match(link, "%d+")).."&w=420&h=420"
						print(string.match(link, "%d+"))
					end
				end
				url.Size = UDim2.new(0, 50, 0, 50)
				if (string.find(value, [[rotation="]])) then
					local text = string.sub(value, string.find(value, [[rotation="]]) + string.len([[rotation="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					url.Rotation = tonumber(text)
				end
				if (string.find(value, [[transparency="]])) then
					local text = string.sub(value, string.find(value, [[transparency="]]) + string.len([[transparency="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					url.ImageTransparency = tonumber(text) or 0
				end
				if (string.find(value, [[zindex="]])) then
					local text = string.sub(value, string.find(value, [[zindex="]]) + string.len([[zindex="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					url.ZIndex = tonumber(text) or 1
				end
				if (string.find(value, [[size="]])) then
					local text = string.sub(value, string.find(value, [[size="]]) + string.len([[size="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					local udim2 = string.split(text, ",")
					url.Size = UDim2.new(tonumber(udim2[1]),tonumber(udim2[2]),tonumber(udim2[3]),tonumber(udim2[4]))
				end
				if (string.find(value, [[fit="]])) then
					local text = string.sub(value, string.find(value, [[fit="]]) + string.len([[fit="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					if text == "true" then
						url.ScaleType = Enum.ScaleType.Fit
					end
				end
				url.Position = start
				if (string.find(value, [[position="]])) then
					local text = string.sub(value, string.find(value, [[position="]]) + string.len([[position="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					local udim2 = string.split(text, ",")
					url.Position = UDim2.new(tonumber(udim2[1]),tonumber(udim2[2]),tonumber(udim2[3]),tonumber(udim2[4]))
				else
					start = UDim2.new(0,0,start.Y.Scale+url.Size.Y.Scale,start.Y.Offset+url.Size.Y.Offset)
				end
				url.Parent = parent
			end
		end
	end
	for name, value in source:gmatch('<txt(.-)(.-)>') do
		local link = nil
		if (string.find(value, 'display="')) then
			local link = string.sub(value, string.find(value, 'display="') + string.len('display="'), string.len(value))
			link = string.sub(link, 1, string.find(link, '"') - 1)
			if true then

				local url = screen:CreateElement("TextLabel", { })
				url.BackgroundTransparency = 1
				url.Size = UDim2.new(0, 100, 0, 50)

				link = string.gsub(link, "_quote_", '"')
				link = string.gsub(link, "_higher_", '>')
				link = string.gsub(link, "_lower_", '<')

				url.Text = link
				url.RichText = true
				if (string.find(value, [[rotation="]])) then
					local text = string.sub(value, string.find(value, [[rotation="]]) + string.len([[rotation="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					url.Rotation = tonumber(text)
				end
				if (string.find(value, [[size="]])) then
					local text = string.sub(value, string.find(value, [[size="]]) + string.len([[size="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					local udim2 = string.split(text, ",")
					url.Size = UDim2.new(tonumber(udim2[1]),tonumber(udim2[2]),tonumber(udim2[3]),tonumber(udim2[4]))
				end
				if (string.find(value, [[color="]])) then
					local text = string.sub(value, string.find(value, [[color="]]) + string.len([[color="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					local color = string.split(text, ",")
					url.TextColor3 = Color3.new(tonumber(color[1])/255,tonumber(color[2])/255,tonumber(color[3])/255)
				end
				if (string.find(value, [[zindex="]])) then
					local text = string.sub(value, string.find(value, [[zindex="]]) + string.len([[zindex="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					url.ZIndex = tonumber(text) or 1
				end
				url.TextScaled = true
				url.TextWrapped = true
				url.Position = start
				if (string.find(value, [[position="]])) then
					local text = string.sub(value, string.find(value, [[position="]]) + string.len([[position="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					local udim2 = string.split(text, ",")
					url.Position = UDim2.new(tonumber(udim2[1]),tonumber(udim2[2]),tonumber(udim2[3]),tonumber(udim2[4]))
				else
					start = UDim2.new(0,0,start.Y.Scale+url.Size.Y.Scale,start.Y.Offset+url.Size.Y.Offset)
				end
				url.Parent = parent
			end
		end
	end
end

local function getfileextension(filename, boolean, only1)
	local result = string.match(filename, "%.[%w%p]+%s*$")
	if not result then return end
	result = result:lower()
	local nospace = string.gsub(result, "%s", "")

	if not only1 then
	    print(only1)
	    local splitted = string.split(boolean and result or nospace, ".")
	    print(splitted[#splitted])
	    if nospace then
	        nospace = "."..splitted[#splitted] or nospace
        else
            result = "."..splitted[#splitted] or result
        end
    end

	if result then
		return boolean and result or nospace
	end
end
local function woshtmlfile(txt, screen, boolean, name)
	local size = UDim2.new(0.7, 0, 0.7, 0)

	if boolean then
		size = UDim2.new(0.5, 0, 0.5, 0)
	end
	local filegui = CreateWindow(size, nil, false, false, false, name or "File", false)
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
	scrollingframe.Parent = filegui

	StringToGui(screen, txt, scrollingframe)

end

local function videoplayer(id, name)
	local window = CreateWindow(UDim2.fromScale(0.7, 0.7), nil, false, false, false, name or "Video", false)

	local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.fromScale(1, 0.85), BackgroundTransparency = 1, Video = "rbxassetid://"..id, Volume = math.floor(videovolume*10)/10})
	videoframe.Parent = window

	local playpause = createnicebutton2(UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0, 0.85), "Play", window)
	local loop, text1 = createnicebutton2(UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0.15, 0.85), "Loop", window)

	local up = createnicebutton2(UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0.85, 0.85), "+", window)
	local ammount = screen:CreateElement("TextLabel", {Text = videovolume, Size = UDim2.fromScale(0.1, 0.15), Position = UDim2.fromScale(0.75, 0.85), TextScaled = true, BackgroundTransparency = 1})
	ammount.Parent = window
	local down = createnicebutton2(UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0.6, 0.85), "-", window)

	local prevtime = 0
	local playing = false
	local looped = false

	playpause.MouseButton1Up:Connect(function()
		if playing == false then
			playing = true
			videoframe.Playing = playing
		else
			playing = false
			videoframe.Playing = playing
		end
	end)

	loop.MouseButton1Up:Connect(function()
		if looped == false then
			videoframe.Looped = true
			looped = true
			text1.Text = "Unloop"
		else
			looped = false
			videoframe.Looped = false
			text1.Text = "Loop"
		end
	end)

	up.MouseButton1Up:Connect(function()
		if math.floor(videovolume*10)/10 < 2 then
			videovolume += 0.1
			videoframe.Volume = math.floor(videovolume*10)/10
			ammount.Text = math.floor(videovolume*10)/10
		end
	end)

	down.MouseButton1Up:Connect(function()
		if math.floor(videovolume*10)/10 > 0 then
			videovolume -= 0.1
			videoframe.Volume = math.floor(videovolume*10)/10
			ammount.Text = math.floor(videovolume*10)/10
		end
	end)
end

local function changecolor()
	local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Change Desktop Color", false, false, false, "Change Desktop Color", false)
	local color1, color2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0, 0), "RGB (Click to update)", holderframe)
	local changecolorbutton, changecolorbutton2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0.8, 0), "Change Color", holderframe)

	local data = nil

	color1.MouseButton1Down:Connect(function()
		if keyboardinput then
			color2.Text = keyboardinput:gsub("\n", "")
			data = keyboardinput:gsub("\n", "")
		end
	end)

	changecolorbutton.MouseButton1Down:Connect(function()
		if data then
			disk:Write("BackgroundColor", data)
			local colordata = string.split(data, ",")
			if colordata then
				if tonumber(colordata[1]) and tonumber(colordata[2]) and tonumber(colordata[3]) then
					local color3 = Color3.new(tonumber(colordata[1])/255, tonumber(colordata[2])/255, tonumber(colordata[3])/255)
					color = color3
					backgroundcolor.BackgroundColor3 = color3
					changecolorbutton2.Text = "Success"
					if backgroundimage then
						disk:Write("BackgroundImage", "")
						wallpaper.Image = ""
					end
					task.wait(2)
					changecolorbutton2.Text = "Change Color"
				else
					changecolorbutton2.Text = "Invalid RGB color."
					task.wait(2)
					changecolorbutton2.Text = "Change Color"
				end
			else
				changecolorbutton2.Text = "Invalid RGB color."
				task.wait(2)
				changecolorbutton2.Text = "Change Color"
			end
		else
			changecolorbutton2.Text = "No RGB color was inputted."
			task.wait(2)
			changecolorbutton2.Text = "Change Color"
		end
	end)
end

local function changebackgroundimage()
	local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Change Background Image", false, false, false, "Settings", false)
	local id, id2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0, 0), "Image ID (Click to update)", holderframe)
	local tiletoggle, tiletoggle2 = createnicebutton(UDim2.new(0.25,0,0.2,0), UDim2.new(0, 0, 0.2, 0), "Enable tile", holderframe)
	local tilenumber, tilenumber2 = createnicebutton(UDim2.new(0.75,0,0.2,0), UDim2.new(0.25, 0, 0.2, 0), "UDim2 (Click to update)", holderframe)
	local changebackimg, changebackimg2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0.8, 0), "Change Background Image", holderframe)


	local data = nil
	local tilen = false
	local tilenumb = "0.2, 0, 0.2, 0"

	id.MouseButton1Down:Connect(function()
		if keyboardinput then
			id2.Text = keyboardinput:gsub("\n", "")
			data = keyboardinput:gsub("\n", "")
		end
	end)

	tiletoggle.MouseButton1Down:Connect(function()
		if tilen then
			tilen = false
			tiletoggle2.Text = "Enable tile"
		else
			tiletoggle2.Text = "Disable tile"
			tilen = true
		end
	end)


	tilenumber.MouseButton1Down:Connect(function()
		if keyboardinput then
			tilenumber2.Text = keyboardinput:gsub("\n", "")
			tilenumb = keyboardinput:gsub("\n", "")
		end
	end)

	changebackimg.MouseButton1Down:Connect(function()
		if data then
			if tonumber(data) then
				disk:Write("BackgroundImage", data..","..tostring(tilen)..","..tilenumb)
				backgroundimage = "rbxthumb://type=Asset&id="..tonumber(data).."&w=420&h=420"
				wallpaper.Image = backgroundimage
				changebackimg2.Text = "Success"
				if tilen then
					local tilenumb = string.split(tilenumb, ",")
					if tonumber(tilenumb[1]) and tonumber(tilenumb[2]) and tonumber(tilenumb[3]) and tonumber(tilenumb[4]) then
						tile = true
						tilesize = UDim2.new(tonumber(tilenumb[1]), tonumber(tilenumb[2]), tonumber(tilenumb[3]), tonumber(tilenumb[4]))
						wallpaper.ScaleType = Enum.ScaleType.Tile
						wallpaper.TileSize = tilesize
					end
				else
					wallpaper.ScaleType = Enum.ScaleType.Stretch
				end
				task.wait(2)
				changebackimg2.Text = "Change Background Image"
			else
				changebackimg2.Text = "The image id is not a number."
				task.wait(2)
				changebackimg2.Text = "Change Background Image"
			end
			changebackimg2.Text = "No id was entered."
			task.wait(2)
			changebackimg2.Text = "Change Background Image"
		end
	end)
end

local desktopscrollingframe = nil
local loaddesktopicons
local rightclickmenu
local openrightclickprompt

local function configicons()
	local window = CreateWindow(UDim2.fromScale(0.7, 0.7), "Desktop Icons", false, false, false, "Icons", false)

	local disable, text1 = createnicebutton(UDim2.fromScale(1, 0.25), UDim2.fromScale(0, 0), if iconsdisabled then "Enable icons" else "Disable icons", window)
	local textlabel = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(1, 0.25), Position = UDim2.fromScale(0, 0.25), Text = "Icons Size:", BackgroundTransparency = 1, TextScaled = true, TextWrapped = true})
	textlabel.Parent = window
	local size, text2 = createnicebutton(UDim2.fromScale(1, 0.25), UDim2.fromScale(0, 0.5), tostring(iconsize), window)

	disable.MouseButton1Up:Connect(function()
		if iconsdisabled then
			iconsdisabled = false
			text1.Text = "Disable icons"
			loaddesktopicons()
			rom:Write("Disabled", false)
		else
			iconsdisabled = true
			text1.Text = "Enable icons"
			desktopscrollingframe:Destroy()
			if rightclickmenu then
				rightclickmenu:Destroy()
				rightclickmenu = nil
			end
			rom:Write("Disabled", true)
		end
	end)

	size.MouseButton1Up:Connect(function()
		if tonumber(keyboardinput) then
			local number = tonumber(keyboardinput)
			if number < 0.05 then
				text2.Text = "The icon size can't be lower than 0.05"
				task.wait(2)
				text2.Text = tostring(iconsize)
			elseif number > 0.8 then
				text2.Text = "The icon size can't be higher than 0.8."
				task.wait(2)
				text2.Text = tostring(iconsize)
			else
				iconsize = tonumber(keyboardinput)
				text2.Text = tostring(iconsize)
				if not iconsdisabled then
					loaddesktopicons()
				end
				rom:Write("IconSize", iconsize)
			end
		end
	end)

end

local function settings()
	local window = CreateWindow(UDim2.fromScale(0.7, 0.7), "Settings", false, false, false, "Settings", false)
	local scrollingframe = window
	local changeclicksound, text1 = createnicebutton(UDim2.fromScale(0.6, 0.2), UDim2.new(0,0,0,0), "Click Sound ID (Click to update)", scrollingframe)
	local saveclicksound, text2 = createnicebutton(UDim2.fromScale(0.4, 0.2), UDim2.new(0.6,0,0,0), "Save", scrollingframe)

	local changeshutdownsound, text3 = createnicebutton(UDim2.fromScale(0.6, 0.2), UDim2.new(0,0,0.2,0), "Shutdown Sound ID (Click to update)", scrollingframe)
	local saveshutdownsound, text4 = createnicebutton(UDim2.fromScale(0.4, 0.2), UDim2.new(0.6,0,0.2,0), "Save", scrollingframe)

	local changestartsound, text5 = createnicebutton(UDim2.fromScale(0.6, 0.2), UDim2.new(0,0,0.4,0), "Startup Sound ID (Click to update)", scrollingframe)
	local savestartsound, text6 = createnicebutton(UDim2.fromScale(0.4, 0.2), UDim2.new(0.6,0,0.4,0), "Save", scrollingframe)

	local input1
	local input2
	local input3
	changeclicksound.MouseButton1Up:Connect(function()
		if tonumber(keyboardinput) then
			input1 = tonumber(keyboardinput)
			text1.Text = tonumber(keyboardinput)
		end
	end)
	saveclicksound.MouseButton1Up:Connect(function()
		if input1 then
			rom:Write("ClickSound", tostring(input1))
			text2.Text = "Saved"
			task.wait(2)
			text2.Text = "Save"
			clicksound = "rbxassetid://"..input1
		end
	end)

	changeshutdownsound.MouseButton1Up:Connect(function()
		if tonumber(keyboardinput) then
			input2 = tonumber(keyboardinput)
			text3.Text = tonumber(keyboardinput)
		end
	end)
	saveshutdownsound.MouseButton1Up:Connect(function()
		if input2 then
			rom:Write("ShutdownSound", tostring(input2))
			text4.Text = "Saved"
			task.wait(2)
			text4.Text = "Save"
			shutdownsound = input2
		end
	end)

	changestartsound.MouseButton1Up:Connect(function()
		if tonumber(keyboardinput) then
			input3 = tonumber(keyboardinput)
			text5.Text = tonumber(keyboardinput)
		end
	end)
	savestartsound.MouseButton1Up:Connect(function()
		if input3 then
			rom:Write("StartSound", tostring(input3))
			text6.Text = "Saved"
			task.wait(2)
			text6.Text = "Save"
			startsound = input3
		end
	end)

	local configureicons = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.new(0,0,0.6,0), "Desktop Icons", scrollingframe)
	configureicons.MouseButton1Up:Connect(function()
		configicons()
	end)

	local openchangecolor = createnicebutton(UDim2.fromScale(0.5, 0.2), UDim2.new(0,0,0.8,0), "Change Background Color", scrollingframe)
	openchangecolor.MouseButton1Up:Connect(function()
		changecolor()
	end)
	local openchangeimage = createnicebutton(UDim2.fromScale(0.5, 0.2), UDim2.new(0.5,0,0.8,0), "Change Background Image", scrollingframe)
	openchangeimage.MouseButton1Up:Connect(function()
		changebackgroundimage()
	end)
end

local function audioui(screen, disk, data, speaker, pitch, length, name)
	local holderframe, window, closebutton = CreateWindow(UDim2.new(0.5, 0, 0.5, 0), nil, false, false, false, name or "Audio", false)
	local sound = nil
	closebutton.MouseButton1Down:Connect(function()
		sound:Stop()
		sound:Destroy()
	end)

	if not pitch then
		pitch = 1
	end

	local pausebutton, pausebutton2 = createnicebutton2(UDim2.new(0.2, 0, 0.2, 0), UDim2.new(0, 0, 0.8, 0), "Stop", holderframe)

	sound = speaker:LoadSound(`rbxassetid://{tonumber(data)}`)
	sound.Pitch = tonumber(pitch)
	sound.Volume = 1


	if length then
		sound.Looped = true
	end
	sound:Play()

	local soundplaying = true

	pausebutton.MouseButton1Down:Connect(function()
		if soundplaying == true then
			pausebutton2.Text = "Play"
			soundplaying = false
			sound:Stop()
		else
			pausebutton2.Text = "Stop"
			soundplaying = true
			if length then
				sound:Loop()
			else
				sound:Play()
			end
		end
	end)

end

local loaddisk

local filesystem = {
	Write = function(filename, filedata, directory, cd)
		local disk = cd or disk
		local directory = directory or "/"
		local dir = directory
		local value = "No filename or filedata specified"
		if filename then
			local split = nil
			local returntable = nil
			if directory ~= "" then
				split = string.split(dir, "/")
			end
			if not split or split[2] == "" then
				disk:Write(filename, filedata)
			else
				returntable = createfileontable(disk, filename, filedata, dir)
			end
			if not split or split[2] == "" then
				if disk:Read(filename) then
					if disk:Read(filename) == filedata then
						value = "Success i think"
					else
						value = "Failed"
					end
				else
					value = "Failed"
				end
			else
				if disk:Read(split[2]) == returntable and disk:Read(split[2]) then
					value = "Success i think"
				else
					value = "Failed i think"
				end
			end
		else
			value = "No filename specified"
		end
		return value
	end,
	Read = function(filename, directory, boolean1, cd)
		local disk = cd or disk
		local directory = directory or "/"
		local dir = directory
		local value = if boolean1 then nil else "No filename specified"
		if filename and filename ~= "" then
			local split = nil
			if dir ~= "" then
				split = string.split(dir, "/")
			end
			if not split or split[2] == "" then
				local output = disk:Read(filename)
				value = output
				print(output)
			else
				local output = getfileontable(disk, filename, dir)
				value = output
				print(output)
			end
		else
			value = if boolean1 then nil else "No filename specified"
		end
		return value
	end,
}

table.freeze(filesystem)

local coroutineprograms = {}

local function getprograms()
	local t = {}

	for i, v in ipairs(coroutineprograms) do
		if coroutine.status(v.coroutine) == "dead" then
			table.remove(coroutineprograms, i)
			continue
		end
		table.insert(t, v.name)
	end

	return t
end

local function stopprogram(i)
	local program = coroutineprograms[i]
	if not program then
		return false
	end

	if coroutine.status(program.coroutine) ~= "dead" then
		coroutine.close(program.coroutine)
	end

	table.remove(coroutineprograms, i)

	return true
end

local function stopprogrambyname(name)
	for i, program in ipairs(coroutineprograms) do
		if coroutine.status(program.coroutine) ~= "dead" then
			coroutine.close(program.coroutine)
			table.remove(coroutineprograms, table.find(coroutineprograms, program))
		end
	end
end

local luaprogram
local runtext
local cmdsenabled = true
local readfile
local openstartmenu
local shutdownprompt
local restartprompt

local function runprogram(text, name, extraname, extra)
	if not text then error("no code to run was given in parameter two.") end
	if typeof(name) ~= "string" then
		name = "untitled"
	end
	local fenv = table.clone(getfenv())
	fenv["luaprogram"] = luaprogram
	fenv["filesystem"] = filesystem
	if extraname then
		fenv[extraname] = extra
	end
	fenv["screen"] = screen
	fenv["getsystemsoundid"] = function(name)
		if name == "startsound" then
			return `rbxassetid://{startsound}`
		elseif name == "shutdownsound" then
			return `rbxassetid://{shutdownsound}`
		elseif name == "clicksound" then
			return clicksound
		end
	end
	fenv["keyboard"] = keyboard
	fenv["modem"] = modem
	fenv["speaker"] = speaker
	fenv["commandline"] = commandline
	fenv["disk"] = disk
	fenv["shutdownprompt"] = shutdownprompt
	fenv["restartprompt"] = restartprompt
	fenv["disks"] = disks
	fenv["rom"] = rom
	fenv["CreateWindow"] = CreateWindow
	fenv["createnicebutton"] = createnicebutton
	fenv["createnicebutton2"] = createnicebutton2
	fenv["openstartmenu"] = openstartmenu
	fenv["programholder1"] = programholder1
	fenv["programholder2"] = programholder2
	fenv["resolutionframe"] = resolutionframe
	fenv["mainframe"] = mainframe
	fenv["TaskBar"] = {taskbarholderscrollingframe, taskbarholder, startbutton7}
	fenv["filereader"] = readfile
	fenv["wallpaper"] = wallpaper
	fenv["backgroundcolor"] = backgroundcolor
	fenv["microphone"] = microphone
	fenv["fileexplorer"] = loaddisk
	fenv["getWindows"] = function()
		return table.clone(windows)
	end
	local prg
	fenv["getprg"] = function() return prg end

	local func, b = loadstring(text)
	if func then
		setfenv(func, fenv)
		prg = coroutine.create(func)
		table.insert(coroutineprograms, {name = name, coroutine = prg})
		coroutine.resume(prg)
	end
	return b
end

local function stopprograms()
	for i, v in ipairs(coroutineprograms) do
		if coroutine.status(v.coroutine) ~= "dead" then
			coroutine.close(v.coroutine)
		end
	end
	coroutineprograms = {}
end

luaprogram = {
	getPrograms = getprograms,
	stopProgram = stopprogram,
	stopProgramByName = stopprogrambyname,
	runProgram = runprogram,
}

table.freeze(luaprogram)

function readfile(txt, nameondisk, directory, cd)
	local disk = cd or disk
	local filegui, window, closebutton, maximizebutton, textlabel, resize, min, funcs = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), nil, false, false, false, nameondisk or "File", false)
	local deletebutton = nil
	local prevdir = directory
	local prevtxt = txt
	local prevname = nameondisk

	local disktext = screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), TextScaled = true, Text = tostring(txt), RichText = true, BackgroundTransparency = 1})
	disktext.Parent = filegui

	print(txt)

	if string.find(string.lower(tostring(nameondisk)), "%.lnk") then
		local split = tostring(txt):split("/")
		local file = split[#split]
		local dir = ""

		disk = disks[1]

		if tonumber(split[1]) then
			disk = disks[tonumber(split[1])]
		end

		for index, value in ipairs(split) do
			if index < #split and index > 1 then
				dir = dir.."/"..value
			end
		end

		local data1 = filesystem.Read(file, if dir == "" then "/" else dir, true, disk)

		if data1 then
			txt = data1
			nameondisk = file
			directory = dir
		elseif dir == "" and file == "" then
			txt = {}
			nameondisk = ""
			directory = "/"
		end

		if not string.find(string.lower(nameondisk), "%.gui") and not string.find(string.lower(nameondisk), "%.lnk") and not string.find(string.lower(nameondisk), "%.lua") and not string.find(string.lower(nameondisk), "%.img") and not string.find(string.lower(nameondisk), "%.aud") and not string.find(string.lower(nameondisk), "%.vid") and typeof(txt) ~= "table" then
			readfile(txt, nameondisk, directory, disk)
		end
	end

	if string.find(string.lower(tostring(nameondisk)), "%.aud") then
		local txt = string.lower(tostring(txt))
		if string.find(tostring(txt), "pitch:") then
			local length = nil

			local pitch = nil
			local splitted = string.split(tostring(txt), "pitch:")
			local spacesplitted = string.split(tostring(txt), " ")

			if string.find(splitted[2], " ") then
				pitch = (string.split(splitted[2], " "))[1]
			else
				pitch = splitted[2]
			end

			if string.find(tostring(txt), "length:") then
				local splitted = string.split(tostring(txt), "length:")
				if string.find(splitted[2], " ") then
					length = (string.split(splitted[2], " "))[1]
				else
					length = splitted[2]
				end
			end

			audioui(screen, disk, spacesplitted[1], speaker, tonumber(pitch), tonumber(length), nameondisk)

		elseif string.find(tostring(txt), "length:") then

			local splitted = string.split(tostring(txt), "length:")

			local spacesplitted = string.split(tostring(txt), " ")

			local length = nil

			if string.find(splitted[2], " ") then
				length = (string.split(splitted[2], " "))[1]
			else
				length = splitted[2]
			end

			audioui(screen, disk, spacesplitted[1], speaker, nil, tonumber(length), nameondisk)

		else
			audioui(screen, disk, txt, speaker, nil, nil, nameondisk)
		end
	end

	if string.find(string.lower(tostring(nameondisk)), "%.img") then
		woshtmlfile([[<img src="]]..tostring(txt)..[[" size="1,0,1,0" position="0,0,0,0" fit="true">]], screen, true, nameondisk)
	end

	if string.find(string.lower(tostring(nameondisk)), "%.vid") then
		videoplayer(tostring(txt), nameondisk)
	end

	if string.find(string.lower(tostring(nameondisk)), "%.lua") then
		runprogram(tostring(txt), nameondisk)
	end
	if typeof(txt) == "table" then
		local newdirectory = nil
		if directory and directory ~= "/" then
			newdirectory = directory.."/"..nameondisk
		else
			newdirectory = "/"..nameondisk
		end
		if prevtxt == txt then
			funcs:Close()
		end

		loaddisk(newdirectory, nil, nil, disk)
	end

	if string.find(string.lower(tostring(txt)), "<woshtml>") or string.find(string.lower(tostring(nameondisk)), "%.gui") then
		woshtmlfile(txt, screen, nameondisk)
	end

end

function loaddisk(directory: string, func: any, boolean1: boolean, cd)
	local currentdisk = cd
	local scrollsize = if boolean1 then UDim2.new(1, 0, 0.7, 0) else UDim2.new(1, 0, 0.85, 0)
	local directory = directory or "/"
	local start = 0
	local holderframe, window, closebutton, maximizebutton, titletext, resizebutton, minimize, funcs = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), directory, false, false, false, if not boolean1 then function() return directory end else "Select File", false)
	local scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = scrollsize, CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
	scrollingframe.Parent = holderframe

	local refreshbutton = createnicebutton(UDim2.new(0.2, 0, 0.15, 0), UDim2.new(0, 0, 0, 0), "Refresh", holderframe)

	local parentbutton = createnicebutton(UDim2.new(0.2, 0, 0.15, 0), UDim2.new(0.2, 0, 0, 0), "Parent", holderframe)

	local data
	local split = directory:split("/")

	if #split == 2 and split[2] == "" then
		data = (currentdisk or disk):ReadAll()
	elseif #split == 2 and split[2] ~= "" then
		data = (currentdisk or disk):Read(split[2])
	elseif #split > 2 then
		local removedlast = directory:sub(1, -(string.len(split[#split]))-2)
		data = filesystem.Read(split[#split], removedlast, nil, currentdisk)
	end

	if #disks == 1 and not currentdisk then
		currentdisk = disk
	end

	local deletebutton = createnicebutton(UDim2.new(0.2, 0, 0.15, 0), UDim2.new(0.8, 0, 0, 0), "Delete", holderframe)

	local selected
	local selecteddir
	local selectedname
	local selecteddisk = currentdisk
	local diskin = table.find(disks, currentdisk) or 0

	if boolean1 then
		selected = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(0.8, 0.15), Position = UDim2.fromScale(0, 0.85), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Select a file"})
		selected.Parent = holderframe

		local sendbutton = createnicebutton(UDim2.fromScale(0.2, 0.15), UDim2.fromScale(0.8, 0.85), "Send", holderframe)

		sendbutton.MouseButton1Up:Connect(function()
			funcs:Close()
			if typeof(func) == "function" then
				func(selectedname or "", selecteddir or directory, selecteddisk, diskin)
			end
		end)
	end

	local loadfile

	local function loaddiskicon(disk, index)
		if currentdisk then return end
		if disk then
			local button, textlabel = createnicebutton(UDim2.new(1,0,0,25), UDim2.new(0, 0, 0, start), tostring(index), scrollingframe)
			textlabel.Size = UDim2.new(1, -25, 1, 0)
			textlabel.Position = UDim2.new(0, 25, 0, 0)

			local imagebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0, 25, 0, 25), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Image = "rbxassetid://16971885886"})
			imagebutton.Parent = button

			if index == 1 then
				imagebutton.Image = "rbxassetid://16985185504"
			end

			scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start + 25)
			start += 25
			imagebutton.MouseButton1Up:Connect(function()
				speaker:PlaySound(clicksound)

				loaddisk("/", nil, nil, disk)
			end)

			button.MouseButton1Up:Connect(function(x, y)
				diskin = index
				currentdisk = disk

				local information = disk:ReadAll()

				start = 0
				scrollingframe:Destroy()
				scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = scrollsize, CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
				scrollingframe.Parent = holderframe

				directory = "/"
				titletext.Text = directory

				if boolean1 then
					selecteddisk = disk
					selecteddir = "/"
					selectedname = nil
					selecteddisk = currentdisk
					selected.Text = "Root"
				end


				if directory == "/" then
					deletebutton.Size = UDim2.new(0,0,0,0)
					deletebutton.Visible = false
					if not currentdisk then
						parentbutton.Size = UDim2.new(0,0,0,0)
						parentbutton.Visible = false
					else
						parentbutton.Size = UDim2.new(0.2, 0, 0.15, 0)
						parentbutton.Visible = true
						refreshbutton.Size = UDim2.new(0.2, 0, 0.15, 0)
						refreshbutton.Visible = true
					end
				else
					deletebutton.Size = UDim2.new(0.2, 0, 0.15, 0)
					deletebutton.Visible = true
					parentbutton.Size = UDim2.new(0.2, 0, 0.15, 0)
					parentbutton.Visible = true
				end
				local startdir = directory
				for index, value in pairs(information) do
					if directory ~= startdir then break end
					loadfile(index, value, currentdisk)
					task.wait()
				end

			end)
		end
	end

	function loadfile(filename, dataz, disk)
		if filename then
			local button, textlabel = createnicebutton(UDim2.new(1,0,0,25), UDim2.new(0, 0, 0, start), tostring(filename), scrollingframe)
			textlabel.Size = UDim2.new(1, -25, 1, 0)
			textlabel.Position = UDim2.new(0, 25, 0, 0)

			local imagebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0, 25, 0, 25), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Image = "rbxassetid://16137083118"})
			imagebutton.Parent = button

			if string.find(filename, "%.gui") or string.find(string.lower(tostring(dataz)), "<woshtml>") then
				imagebutton.Image = "rbxassetid://17104255245"
			end

			if string.find(filename, "%.aud") then
				imagebutton.Image = "rbxassetid://16137076689"
			end

			if string.find(filename, "%.img") then
				imagebutton.Image = "rbxassetid://16138716524"
			end

			if string.find(filename, "%.vid") then
				imagebutton.Image = "rbxassetid://16137079551"
			end

			if string.find(filename, "%.lua") then
				imagebutton.Image = "rbxassetid://16137086052"
			end

			if typeof(dataz) == "function" then
				imagebutton.Image = "rbxassetid://17205316410"
			end

			if typeof(dataz) == "table" then
				local length = 0

				for i, v in pairs(dataz) do
					length += 1
				end


				if length > 0 then
					imagebutton.Image = "rbxassetid://16137091192"
				else
					imagebutton.Image = "rbxassetid://16137073439"
				end
			end

			if string.find(filename, "%.lnk") then
				local image2 = screen:CreateElement("ImageLabel", {Size = UDim2.new(0.4, 0, 0.4, 0), Position = UDim2.new(0, 0, 0.6, 0), BackgroundTransparency = 1, Image = "rbxassetid://16180413404", ScaleType = Enum.ScaleType.Fit})
				image2.Parent = imagebutton

				local split = tostring(dataz):split("/")
				local file = split[#split]
				local dir = ""

				local disk = disks[1]

				if tonumber(split[1]) then
					disk = disks[tonumber(split[1])]
				end

				for index, value in ipairs(split) do
					if index < #split and index > 1 then
						dir = dir.."/"..value
					end
				end

				local data1 = filesystem.Read(file, if dir == "" then "/" else dir, true, disk)

				if dir == "" and file == "" then
					data1 = disk:ReadAll()
				end

				if string.find(file, "%.gui") or string.find(string.lower(tostring(data1)), "<woshtml>") then
					imagebutton.Image = "rbxassetid://17104255245"
				end

				if string.find(file, "%.aud") then
					imagebutton.Image = "rbxassetid://16137076689"
				end

				if string.find(file, "%.img") then
					imagebutton.Image = "rbxassetid://16138716524"
				end

				if string.find(file, "%.vid") then
					imagebutton.Image = "rbxassetid://16137079551"
				end

				if string.find(file, "%.lua") then
					imagebutton.Image = "rbxassetid://16137086052"
				end

				if typeof(data1) == "function" then
					imagebutton.Image = "rbxassetid://17205316410"
				end

				if typeof(data1) == "table" then
					local length = 0

					for i, v in pairs(data1) do
						length += 1
					end


					if length > 0 then
						imagebutton.Image = "rbxassetid://16137091192"
					else
						imagebutton.Image = "rbxassetid://16137073439"
					end
				end
			end

			scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start + 25)
			start += 25
			imagebutton.MouseButton1Up:Connect(function()
				speaker:PlaySound(clicksound)

				readfile(filesystem.Read(filename, directory, nil, disk), filename, directory)
			end)

			button.MouseButton1Up:Connect(function(x, y)
				local information = filesystem.Read(filename, directory, nil, disk)

				if typeof(information) ~= "table" then
					if not boolean1 then
						openrightclickprompt(button, filename, directory, false, true, x, y, disk)
					else
						selecteddir = directory
						selectedname = filename
						selecteddisk = disk
						selected.Text = tostring(filename)
					end
				else
					if boolean1 then
						selecteddir = directory
						selectedname = filename
						selecteddisk = disk
						selected.Text = tostring(filename)
					end
					start = 0
					scrollingframe:Destroy()
					scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = scrollsize, CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
					scrollingframe.Parent = holderframe

					directory = if directory ~= "/" then directory.."/"..filename else "/"..filename
					titletext.Text = directory

					if directory == "/" then
						deletebutton.Size = UDim2.new(0,0,0,0)
						deletebutton.Visible = false
						parentbutton.Size = UDim2.new(0,0,0,0)
						parentbutton.Visible = false
					else
						deletebutton.Size = UDim2.new(0.2, 0, 0.15, 0)
						deletebutton.Visible = true
						parentbutton.Size = UDim2.new(0.2, 0, 0.15, 0)
						parentbutton.Visible = true
					end
					local startdir = directory
					for index, value in pairs(information) do
						if directory ~= startdir then break end
						loadfile(index, value, currentdisk)
						task.wait()
					end
				end

			end)
		end
	end

	if currentdisk then
		local startdir = directory
		for filename, dataz in pairs(data) do
			if directory ~= startdir then break end
			loadfile(filename, dataz, currentdisk)
			task.wait()
		end

	else

		for i, disc in ipairs(disks) do
			loaddiskicon(disc, i)
			task.wait()
		end

	end

	if directory == "/" then
		deletebutton.Size = UDim2.new(0,0,0,0)
		deletebutton.Visible = false
		if not currentdisk then
			titletext.Text = "Select storage media"
			parentbutton.Size = UDim2.new(0,0,0,0)
			parentbutton.Visible = false
			refreshbutton.Size = UDim2.new(0,0,0,0)
			refreshbutton.Visible = false
		end
	end

	local pressed = false
	deletebutton.MouseButton1Up:Connect(function()
		if pressed then return end
		pressed = true

		local holdframe, windowz, closebutton, maximize, textlabel, resize, minimize, funcs = CreateWindow(UDim2.new(0.4, 0, 0.25, 0), "Are you sure?", true, true, false, nil, true)
		local deletebutton1 = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0, 0, 0.25, 0), "Yes", holdframe)
		local cancelbutton = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 0.25, 0), "No", holdframe)

		closebutton.MouseButton1Up:Connect(function()
			pressed = false
		end)

		cancelbutton.MouseButton1Up:Connect(function()
			pressed = false
			funcs:Close()
		end)

		deletebutton1.MouseButton1Up:Connect(function()
			pressed = false
			local split = directory:split("/")
			if scrollingframe then
				local data
				if #split > 2 then
					local removedlast1 = directory:sub(1, -(string.len(split[#split]))-2)
					local split2 = removedlast1:split("/")
					local removedlast = removedlast1:sub(1, -(string.len(split2[#split2]))-2)
					filesystem.Write(split[#split], nil, removedlast1, currentdisk)
					data = filesystem.Read(split2[#split2], removedlast, nil, currentdisk)
					if boolean1 then
						selectedname = split2[#split2]
						selected.Text = selectedname
						selecteddir = removedlast
					end
					directory = removedlast1
				else
					data = currentdisk:ReadAll()
					filesystem.Write(split[#split], nil, "/", currentdisk)
					if boolean1 then
						selectedname = nil
						selected.Text = "Root"
					end
					if boolean1 then
						selecteddir = "/"
					end
					directory = "/"
				end
				if directory == "/" then
					deletebutton.Size = UDim2.new(0,0,0,0)
					deletebutton.Visible = false

					if not currentdisk then
						parentbutton.Size = UDim2.new(0,0,0,0)
						parentbutton.Visible = false
					end
				end
				titletext.Text = directory
				start = 0
				scrollingframe:Destroy()
				scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = scrollsize, CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
				scrollingframe.Parent = holderframe
				if typeof(data) == "table" then
					local startdir = directory
					for filename, dataz in pairs(data) do
						if directory ~= startdir then break end
						loadfile(filename, dataz, currentdisk)
						task.wait()
					end
				end
			end

			funcs:Close()
		end)
	end)

	refreshbutton.MouseButton1Up:Connect(function()
		if not currentdisk then return end

		local data
		local split = directory:split("/")

		if #split == 2 and split[2] == "" then
			data = (currentdisk or disk):ReadAll()
		elseif #split == 2 and split[2] ~= "" then
			data = (currentdisk or disk):Read(split[2])
		elseif #split > 2 then
			local removedlast = directory:sub(1, -(string.len(split[#split]))-2)
			data = filesystem.Read(split[#split], removedlast, nil, currentdisk)
		end
		start = 0
		scrollingframe:Destroy()
		scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = scrollsize, CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
		scrollingframe.Parent = holderframe

		if typeof(data) ~= "table" then data = {} end
		local startdir = directory
		for filename, dataz in pairs(data) do
			if directory ~= startdir then break end
			loadfile(filename, dataz, currentdisk)
			task.wait()
		end
	end)

	parentbutton.MouseButton1Up:Connect(function()
		if currentdisk then

			if directory ~= "/" then
				local data
				local split = directory:split("/")

				if #split == 2 and split[2] ~= "" then
					data = currentdisk:ReadAll()
					directory = "/"
					if boolean1 then
						selectedname = nil
						selected.Text = "Root"
						selecteddir = "/"
					end
				elseif #split > 2 then
					local removedlast1 = directory:sub(1, -(string.len(split[#split]))-2)
					local split2 = removedlast1:split("/")
					local removedlast = removedlast1:sub(1, -(string.len(split2[#split2]))-2)
					data = filesystem.Read(split2[#split2], removedlast, nil, currentdisk)
					if boolean1 then
						selectedname = split2[#split2]
						selected.Text = selectedname
					end
					directory = removedlast1
					if boolean1 then
						selecteddir = removedlast
					end
				end

				titletext.Text = tostring(directory)

				start = 0
				scrollingframe:Destroy()
				scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = scrollsize, CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
				scrollingframe.Parent = holderframe

				if typeof(data) ~= "table" then data = {} end

				if directory == "/" then
					deletebutton.Size = UDim2.new(0,0,0,0)
					deletebutton.Visible = false
					if not currentdisk then
						parentbutton.Size = UDim2.new(0,0,0,0)
						parentbutton.Visible = false
					end
				end
				local startdir = directory
				for filename, dataz in pairs(data) do
					if directory ~= startdir then break end
					loadfile(filename, dataz, currentdisk)
					task.wait()
				end

			else

				if boolean1 then
					selecteddisk = nil
				end

				refreshbutton.Size = UDim2.new(0,0,0,0)
				refreshbutton.Visible = false
				parentbutton.Size = UDim2.new(0,0,0,0)
				parentbutton.Visible = false

				titletext.Text = "Select storage media"

				currentdisk = nil
				diskin = nil

				start = 0
				scrollingframe:Destroy()
				scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = scrollsize, CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
				scrollingframe.Parent = holderframe

				for i, disc in ipairs(disks) do
					loaddiskicon(disc, i)
					task.wait()
				end

			end

		end
	end)
end

local function writedisk()
	local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Create File", false, false, false, "File Creator", false)
	local scrollingframe = holderframe
	local filenamebutton, filenamebutton2 = createnicebutton(UDim2.new(1,0,1/6,0), UDim2.new(0, 0, 0, 0), "File Name(Case Sensitive) (Click to update)", scrollingframe)
	local filedatabutton, filedatabutton2 = createnicebutton(UDim2.new(1,0,1/6,0), UDim2.new(0, 0, 1/6, 0), "File Data (Click to update)", scrollingframe)
	local createfilebutton, createfilebutton2 = createnicebutton(UDim2.new(0.5,0,1/6, 0), UDim2.new(0, 0, 1-(1/6), 0), "Save", scrollingframe)

	local createtablebutton, createtablebutton2 = createnicebutton(UDim2.new(0.5,0,1/6,0), UDim2.new(0.5, 0, 1-(1/6), 0), "Create Table", scrollingframe)

	local directorybutton, directorybutton2 = createnicebutton(UDim2.new(1,0,1/6,0), UDim2.new(0, 0, (1/6)*2, 0), [[Directory(Case Sensitive) (Click to update) example: "/sounds"]], scrollingframe)
	local disknum, disktext = createnicebutton(UDim2.new(1,0,1/6,0), UDim2.new(0, 0, (1/6)*4, 0), "Storage media number", scrollingframe)

	local data = nil
	local filename = nil
	local directory = ""
	local disk = disk

	local getfilebutton, getfilebutton2 = createnicebutton(UDim2.new(1,0,1/6,0), UDim2.new(0, 0, (1/6)*3, 0), [[Select directory instead]], scrollingframe)

	getfilebutton.MouseButton1Up:Connect(function()
		loaddisk(if directory == "" then "/" else directory, function(name, dir, cd, cdi)
			if not holderframe then return end
			if dir == "/" and name == "" then
				directory = dir
				disk = cd
				disktext.Text = cdi

				directorybutton2.Text = directory
			elseif typeof(filesystem.Read(name, dir, nil, cd)) == "table" then
				directory = if dir == "/" then "/"..name else dir.."/"..name
				disk = cd
				disktext.Text = cdi
				directorybutton2.Text = directory
			elseif dir ~= directory then
				getfilebutton2.Text = "The selected folder/table is not a valid folder/table."
				task.wait(2)
				getfilebutton2.Text = "Select directory instead"
			end
		end, true, disk)
	end)

	disknum.MouseButton1Up:Connect(function()
		local disknumber = tonumber(keyboardinput)

		if disknumber then
			if disks[disknumber] then
				disktext.Text = disknumber

				disk = disks[disknumber]
			else
				disktext.Text = "Invalid"
				task.wait(2)
				disktext.Text = "Storage media number"
			end
		end
	end)

	filenamebutton.MouseButton1Down:Connect(function()
		if keyboardinput then
			filenamebutton2.Text = keyboardinput:gsub("\n", ""):gsub("/", "")
			filename = keyboardinput:gsub("\n", ""):gsub("/", "")
		end
	end)

	directorybutton.MouseButton1Down:Connect(function()
		if keyboardinput then
			local inputtedtext = keyboardinput:gsub("\n", "")
			local tempsplit = string.split(inputtedtext, "/")
			if tempsplit then
				if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
					inputtedtext = "/"..inputtedtext
				end
			end
			local tempsplit2 = string.split(inputtedtext, "/")
			if tempsplit2 then
				if inputtedtext:sub(-1, -1) == "/" and tempsplit2[2] ~= "" then inputtedtext = inputtedtext:sub(0, -2); end
			end
			if inputtedtext == " " then inputtedtext = ""; end
			local split = string.split(inputtedtext, "/")
			if split then
				local removedlast = inputtedtext:sub(1, -(string.len(split[#split]))-2)
				if #split >= 3 then
					if typeof(getfileontable(disk, split[#split], removedlast)) == "table" then
						directorybutton2.Text = inputtedtext
						directory = inputtedtext
					else
						directorybutton2.Text = "Invalid"
						task.wait(2)
						if directory ~= "" then
							directorybutton2.Text = [[Directory(Case Sensitive) (Click to update) example: "/sounds"]]
						else
							directorybutton2.Text = directory
						end
					end
				else
					if disk:Read(split[#split]) or split[2] == "" then
						directorybutton2.Text = inputtedtext
						directory = inputtedtext
					else
						directorybutton2.Text = "Invalid"
						task.wait(2)
						if directory == "" then
							directorybutton2.Text = [[Directory(Case Sensitive) (Click to update) example: "/sounds"]]
						else
							directorybutton2.Text = directory
						end
					end
				end
			elseif inputtedtext == "" then
				directorybutton2.Text = [[Directory(Case Sensitive) (Click to update) example: "/sounds"]]
				directory = inputtedtext
			else
				directorybutton2.Text = "Invalid"
				task.wait(2)
				directorybutton2.Text = [[Directory(Case Sensitive) (Click to update) example: "/sounds"]]
			end
		end
	end)

	filedatabutton.MouseButton1Down:Connect(function()
		if keyboardinput then
			if keyboardinput:sub(1, 2) == "!s" then
				local keyboardinput = keyboardinput:sub(3, string.len(keyboardinput)):gsub("\n", " ")
				filedatabutton2.Text = keyboardinput
				data = keyboardinput
			elseif keyboardinput:sub(1, 2) == "!k" then
				local keyboardinput = keyboardinput:sub(3, string.len(keyboardinput))
				filedatabutton2.Text = keyboardinput
				data = keyboardinput
			elseif  keyboardinput:sub(1, 2) == "!n" then
				local keyboardinput = keyboardinput:sub(3, string.len(keyboardinput)):gsub("\n", ""):gsub("\\n", "\n")
				filedatabutton2.Text = keyboardinput
				data = keyboardinput
			else
				local newtext = keyboardinput:gsub("\n", "")
				if string.sub(newtext, 1, 1) == "\\" then
					newtext = newtext:sub(2, -1)
				end
				filedatabutton2.Text = newtext
				data = newtext
			end
		end
	end)

	createfilebutton.MouseButton1Down:Connect(function()
		local disk = disk or disks[1]
		if filename and filename ~= "" then
			if data then
				local split = nil
				local returntable = nil
				if directory ~= "" then
					split = string.split(directory, "/")
				end
				if not split or split[2] == "" then
					disk:Write(filename, data)
				else
					returntable = createfileontable(disk, filename, data, directory)
				end
				if not split or split[2] == "" then
					if disk:Read(filename) then
						if disk:Read(filename) == data then
							createfilebutton2.Text = "Success i think"
						else
							createfilebutton2.Text = "Failed"
						end
					else
						createfilebutton2.Text = "Failed"
					end
				else
					if disk:Read(split[2]) == returntable and disk:Read(split[2]) then
						createfilebutton2.Text = "Success i think"
					else
						createfilebutton2.Text = "Failed i think"
					end
				end
				task.wait(2)
				createfilebutton2.Text = "Save"
			end
		end
	end)

	createtablebutton.MouseButton1Down:Connect(function()
		local disk = disk or disks[1]
		if filename ~= "" and filename then
			local split = nil
			local returntable = nil
			if directory ~= "" then
				split = string.split(directory, "/")
			end
			if not split or split[2] == "" then
				disk:Write(filename, {
				})
			else
				returntable = createfileontable(disk, filename, {}, directory)
			end
			if not split then
				if disk:Read(filename) then
					createtablebutton2.Text = "Success i think"
				else
					createtablebutton2.Text = "Failed"
				end
			else
				if disk:Read(split[2]) == returntable then
					createtablebutton2.Text = "Success i think"
				else
					createtablebutton2.Text = "Failed i think"
				end
			end
			task.wait(2)
			createtablebutton2.Text = "Create Table"
		end
	end)
end

local function copyfile()
	local window = CreateWindow(UDim2.fromScale(0.7, 0.7), "Copy File", false, false ,false, "Copy File", false)

	local filebutton, text1 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0), "Select File", window)
	local folderbutton, text2 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0.2), "Select new path", window)
	local renamebutton, text4 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0.4), "Enter new filename (Click to update)", window)
	local confirm, text3 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0.8), "Confirm", window)

	local filename
	local newname
	local directory
	local sdisk
	local ndisk
	local newdirectory
	local newdirname
	local newdir

	filebutton.MouseButton1Up:Connect(function()
		loaddisk(if not directory then "/" else directory, function(name, dir, cd)
			if not window then return end
			directory = dir
			filename = name
			sdisk = cd

			text1.Text = filename
		end, true)
	end)

	renamebutton.MouseButton1Up:Connect(function()
		if keyboardinput then
			newname = keyboardinput:gsub("/", ""):gsub("\n", "")
			if newname == "" then
				newname = nil
			end
			text4.Text = newname or "Enter new filename (Click to update)"
		end
	end)

	folderbutton.MouseButton1Up:Connect(function()
		loaddisk(if not newdirectory then "/" else newdirectory, function(name, dir, cd)
			if not window then return end
			if name ~= "" or dir == "/" then
				newdirectory = if dir ~= "/" then dir.."/"..name else "/"..name
			end
			newdirname = name
			newdir = dir
			ndisk = cd

			text2.Text = newdirectory
		end, true)
	end)

	confirm.MouseButton1Up:Connect(function()
		if newdirectory then
			if filename and directory then
				local data = filesystem.Read(filename, directory, nil, sdisk)
				if data then
					if newdirectory == "/" or typeof(filesystem.Read(newdirname, newdir, nil, ndisk)) == "table" then
						if directory == "/" and filename == "" then
							local newdata = JSONDecode(JSONEncode(sdisk:ReadAll()))
							local result = filesystem.Write(newname or "Root", newdata, newdirectory, ndisk)
							if result == "Success i think" then
								text3.Text = "Success?"
								task.wait(2)
								text3.Text = "Confirm"
							else
								text3.Text = "Failed?"
								task.wait(2)
								text3.Text = "Confirm"
							end
						else
							local newdata = data
							if typeof(data) == "table" then
								newdata = JSONDecode(JSONEncode(data))
							end
							local result = filesystem.Write(newname or filename, newdata, newdirectory, ndisk)
							if result == "Success i think" then
								text3.Text = "Success?"
								task.wait(2)
								text3.Text = "Confirm"
							else
								text3.Text = "Failed?"
								task.wait(2)
								text3.Text = "Confirm"
							end
						end

					else
						text3.Text = "The selected new path is not a valid table/folder."
						task.wait(2)
						text3.Text = "Confirm"
					end
				else
					text3.Text = "File does not exist."
					task.wait(2)
					text3.Text = "Confirm"
				end
			else
				text3.Text = "No file selected."
				task.wait(2)
				text3.Text = "Confirm"
			end
		else
			text3.Text = "Selected new path is not a valid folder/table."
			task.wait(2)
			text3.Text = "Confirm"
		end
	end)
end

local function renamefile()
	local window = CreateWindow(UDim2.fromScale(0.7, 0.7), "Rename File", false, false ,false, "Rename File", false)

	local filebutton, text1 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0), "Select File", window)
	local namebutton, text2 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0.2), "New filename (Click to update)", window)
	local confirm, text3 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0.8), "Confirm", window)

	local filename
	local directory
	local sdisk
	local newname

	filebutton.MouseButton1Up:Connect(function()
		loaddisk(if not directory then "/" else directory, function(name, dir, cd)
			if not window then return end
			directory = dir
			sdisk = cd
			filename = name

			text1.Text = filename
		end, true)
	end)

	namebutton.MouseButton1Up:Connect(function()
		if keyboardinput then
			newname = keyboardinput:gsub("\n", "")
			text2.Text = newname
		end
	end)

	confirm.MouseButton1Up:Connect(function()
		if newname then
			if filename and directory then
				local data = filesystem.Read(filename, directory, nil, sdisk)
				if data then
					if directory == "/" and filename == "" then
						text3.Text = "Cannot rename Root."
						task.wait(2)
						text3.Text = "Confirm"
					else
						filesystem.Write(filename, nil, directory)
						local result = filesystem.Write(newname, data, directory, sdisk)
						if result == "Success i think" then
							text3.Text = "Success?"
							task.wait(2)
							text3.Text = "Confirm"
						else
							filesystem.Write(filename, data, directory, sdisk)
							text3.Text = "Failed?"
							task.wait(2)
							text3.Text = "Confirm"
						end
					end
				else
					text3.Text = "File does not exist."
					task.wait(2)
					text3.Text = "Confirm"
				end
			else
				text3.Text = "No file selected."
				task.wait(2)
				text3.Text = "Confirm"
			end
		else
			text3.Text = "The new filename wasn't specified."
			task.wait(2)
			text3.Text = "Confirm"
		end
	end)
end

local function createshortcut()
	local window = CreateWindow(UDim2.fromScale(0.7, 0.7), "Create Shortcut", false, false ,false, "Create Shortcut", false)

	local filebutton, text1 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0), "Select File", window)
	local folderbutton, text2 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0.2), "Select shortcut path", window)
	local renamebutton, text4 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0.4), "Enter shortcut name (Click to update)", window)
	local confirm, text3 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0.8), "Confirm", window)

	local filename
	local directory
	local sdisk
	local sindex
	local newdirectory
	local ndisk
	local newdirname
	local newdir
	local newname
	local nindex

	renamebutton.MouseButton1Up:Connect(function()
		if keyboardinput then
			newname = keyboardinput:gsub("/", ""):gsub("\n", "")
			if newname == "" then
				newname = nil
			end
			text4.Text = newname or "Enter shortcut name (Click to update)"
		end
	end)

	filebutton.MouseButton1Up:Connect(function()
		loaddisk(if not directory then "/" else directory, function(name, dir, cd, index)
			if not window then return end
			if string.find(name, "%.lnk") then
				local data = tostring(filesystem.Read(name, dir, nil, cd)) or ""
				local split = data:split("/")
				local file = split[#split]
				local dir1 = ""

				for index, value in ipairs(split) do
					if index < #split and index > 1 then
						dir1 = dir1.."/"..value
					end
				end

				local data1 = filesystem.Read(file, if dir1 == "" then "/" else dir1, true)

				if data1 then
					name = file
					dir = dir1
				end
			end
			directory = dir
			filename = name
			sdisk = cd
			sindex = index

			text1.Text = filename
		end, true)
	end)

	folderbutton.MouseButton1Up:Connect(function()
		loaddisk(if not newdirectory then "/" else newdirectory, function(name, dir, cd, index)
			if not window then return end
			if name ~= "" or dir == "/" then
				newdirectory = if dir ~= "/" then dir.."/"..name else "/"..name
			end
			newdirname = name
			newdir = dir
			ndisk = cd
			nindex = index

			text2.Text = newdirectory
		end, true)
	end)

	confirm.MouseButton1Up:Connect(function()
		if newdirectory then
			if filename and directory then
				local data = filesystem.Read(filename, directory, nil, sdisk)
				if data then
					if newdirectory == "/" or typeof(filesystem.Read(newdirname, newdir, nil, ndisk)) == "table" then
						if directory == "/" and filename == "" then
							local result = filesystem.Write((newname or "Root")..".lnk", (if sindex ~= 1 then sindex else "").."/", newdirectory, ndisk)
							if result == "Success i think" then
								text3.Text = "Success?"
								task.wait(2)
								text3.Text = "Confirm"
							else
								text3.Text = "Failed?"
								task.wait(2)
								text3.Text = "Confirm"
							end
						else
							local filedata1 = if sindex ~= 1 then sindex else ""

							filedata1 = tostring(filedata1)..if directory ~= "/" then directory.."/"..filename else "/"..filename

							local result = filesystem.Write((newname or filename)..".lnk", filedata1, newdirectory, ndisk)
							if result == "Success i think" then
								text3.Text = "Success?"
								task.wait(2)
								text3.Text = "Confirm"
							else
								text3.Text = "Failed?"
								task.wait(2)
								text3.Text = "Confirm"
							end
						end

					else
						text3.Text = "The selected new path is not a valid table/folder."
						task.wait(2)
						text3.Text = "Confirm"
					end
				else
					text3.Text = "File does not exist."
					task.wait(2)
					text3.Text = "Confirm"
				end
			else
				text3.Text = "No file selected."
				task.wait(2)
				text3.Text = "Confirm"
			end
		else
			text3.Text = "Selected new path is not a valid folder/table."
			task.wait(2)
			text3.Text = "Confirm"
		end
	end)
end

local function movefile()
	local window = CreateWindow(UDim2.fromScale(0.7, 0.7), "Move File", false, false ,false, "Move File", false)

	local filebutton, text1 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0), "Select File", window)
	local folderbutton, text2 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0.2), "Select new path", window)
	local confirm, text3 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0,0.8), "Confirm", window)

	local filename
	local directory
	local sdisk
	local ndisk
	local newdirectory
	local newdirname
	local newdir

	filebutton.MouseButton1Up:Connect(function()
		loaddisk(if not directory then "/" else directory, function(name, dir, cd)
			if not window then return end
			directory = dir
			filename = name
			sdisk = cd

			text1.Text = filename
		end, true)
	end)

	folderbutton.MouseButton1Up:Connect(function()
		loaddisk(if not newdirectory then "/" else newdirectory, function(name, dir, cd)
			if not window then return end
			if name ~= "" or dir == "/" then
				newdirectory = if dir ~= "/" then dir.."/"..name else "/"..name
			end
			newdirname = name
			newdir = dir
			ndisk = cd

			text2.Text = newdirectory
		end, true)
	end)

	confirm.MouseButton1Up:Connect(function()
		if newdirectory then
			if filename and directory then
				local data = filesystem.Read(filename, directory, nil, sdisk)
				if data then
					if newdirectory == "/" or typeof(filesystem.Read(newdirname, newdir, nil, ndisk)) == "table" then
						local newpath = ""
						if directory == "/" then
							newpath = directory..filename
						else
							newpath = directory.."/"..filename
						end
						if typeof(data) ~= "table" or string.sub(newdirectory, 1, string.len(newpath)) ~= newpath then
							if directory == "/" and filename == "" then
								text3.Text = "Cannot move Root."
								task.wait(2)
								text3.Text = "Confirm"
							else
								filesystem.Write(filename, nil, directory, sdisk)
								local result = filesystem.Write(filename, data, newdirectory, ndisk)
								if result == "Success i think" then
									text3.Text = "Success?"
									task.wait(2)
									text3.Text = "Confirm"
								else
									filesystem.Write(filename, data, directory, sdisk)
									text3.Text = "Failed?"
									task.wait(2)
									text3.Text = "Confirm"
								end
							end
						else
							text3.Text = "Can't move a table/folder to itself."
							task.wait(2)
							text3.Text = "Confirm"
						end
					else
						text3.Text = "The selected new path is not a valid table/folder."
						task.wait(2)
						text3.Text = "Confirm"
					end
				else
					text3.Text = "File does not exist."
					task.wait(2)
					text3.Text = "Confirm"
				end
			else
				text3.Text = "No file selected."
				task.wait(2)
				text3.Text = "Confirm"
			end
		else
			text3.Text = "Selected new path is not a valid folder/table."
			task.wait(2)
			text3.Text = "Confirm"
		end
	end)
end

local function programmanager()
	local holderframe = CreateWindow(UDim2.new(0.75, 0, 0.75, 0), "Program Manager", false ,false, false, "Prg. m.", false)
	local scrollingframe
	local upd = false

	local reloadbutton = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0), "Reload", holderframe)

	local function update()
		if scrollingframe then
			scrollingframe:Destroy()
		end
		scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 0.8, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
		scrollingframe.Parent = holderframe
		for index, value in pairs(getprograms()) do
			local button, button2 = createnicebutton(UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, (index-1)*25), index, scrollingframe)
			scrollingframe.CanvasSize = UDim2.new(0, 0, 0, index + 25)
			button.MouseButton1Up:Connect(function()
				stopprogram(index)
				button2.Text = "Program closed."
				button.Active = false
				upd = true
				task.wait(2)
				if not upd then
					update()
				end
			end)
		end
		upd = false
	end

	reloadbutton.MouseButton1Up:Connect(function()
		if not upd then
			update()
		end
	end)

	update()
end


local function windowsmanager()
	local window, holderframe, closebutton, maximize, textlabel, resize, minimize, funcs = CreateWindow(UDim2.fromScale(0.7, 0.7), "Windows Manager", false, false, false, "WM", false)

	local scroll

	local selectedwindow = nil

	local function reload()

		if scroll then scroll:Destroy() end

		selectedwindow = nil

		scroll = funcs:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.fromScale(1, 0.6), CanvasSize = UDim2.fromScale(0, 0), BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0.2)})

		scroll.CanvasSize += UDim2.fromOffset(0, 25)

		local selectionui = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(1, 1), Image = "rbxassetid://8677487226", ImageTransparency = 1, BackgroundTransparency = 1})

		selectionui.Parent = scroll

		local start = 0

		for i, window in pairs(windows) do

			if window and window.FunctionsTable and not window.FunctionsTable:IsClosed() then
				local text = if typeof(window.Name) == "function" then tostring(window.Name()) else tostring(window.Name)

				if text == "nil" then
					text = "Untitled program"
				end

				local button = createnicebutton(UDim2.new(1, 0, 0, 25), UDim2.fromOffset(0, 25*start), text, scroll)

				button.MouseButton1Up:Connect(function()
					selectionui.ImageTransparency = 0.2
					selectionui.Parent = button
					selectedwindow = window
				end)

				scroll.CanvasSize += UDim2.fromOffset(0, 25)

				start += 1
			end
		end
	end

	reload()

	local refresh = createnicebutton(UDim2.fromScale(1, 0.15), UDim2.fromScale(0, 0), "Refresh", window)
	local endbutton = createnicebutton(UDim2.fromScale(1/3, 0.15), UDim2.fromScale(0, 0.85), "Close", window)
	local resetposbutton = createnicebutton(UDim2.fromScale(1/3, 0.15), UDim2.fromScale(1/3, 0.85), "Reset Pos.", window)
	local toggleminbutton = createnicebutton(UDim2.fromScale(1/3, 0.15), UDim2.fromScale((1/3)*2, 0.85), "Toggle minimized", window)

	resetposbutton.MouseButton1Up:Connect(function()
		if selectedwindow then
			selectedwindow.Window.Position = UDim2.fromScale(0, 0)
		end
	end)

	endbutton.MouseButton1Up:Connect(function()
		if selectedwindow then
			selectedwindow.FunctionsTable:Close()
			reload()
		end
	end)

	toggleminbutton.MouseButton1Up:Connect(function()
		if selectedwindow then
			if selectedwindow.FunctionsTable:IsMinimized() then
				selectedwindow.FunctionsTable:Unminimize()
			else
				selectedwindow.FunctionsTable:Minimize()
			end
		end
	end)

	refresh.MouseButton1Up:Connect(function()
		reload()
	end)
end

local function customprogramthing()
	local holderframe = CreateWindow(UDim2.new(0.75, 0, 0.75, 10), nil, false, false, false, "Lua executor", false)

	local code = ""

	local codebutton, codebutton2 = createnicebutton(UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0, 0), "Enter lua here (Click to update)", holderframe)

	codebutton.MouseButton1Up:Connect(function()
		if keyboardinput then
			codebutton2.Text = tostring(keyboardinput)
			code = tostring(keyboardinput)
		end
	end)

	local stopcodesbutton = createnicebutton(UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.6, 0), "Program Manager", holderframe)

	stopcodesbutton.MouseButton1Up:Connect(function()
		programmanager()
	end)

	local windowsbutton = createnicebutton(UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.4, 0), "Windows Manager", holderframe)

	windowsbutton.MouseButton1Up:Connect(function()
		windowsmanager()
	end)

	local runcodebutton, runcodebutton2 = createnicebutton(UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.8, 0), "Run lua", holderframe)

	runcodebutton.MouseButton1Up:Connect(function()
		if code ~= "" then
			local err = runprogram(code, runcodebutton2)
			runcodebutton2.Text = if not err then "Code ran" else err
			task.wait(2)
			runcodebutton2.Text = "Run lua"
		end
	end)
end

local function mediaplayer()
	local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Media player", false, false, false, "Media player", false)
	local imagelabel = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Image = "rbxassetid://15940016124"})
	imagelabel.Parent = holderframe

	local mainframe = screen:CreateElement("Frame", {Size = UDim2.fromScale(0.9, 0.9), Position = UDim2.fromScale(0.05, 0.05), BackgroundTransparency = 1})
	mainframe.Parent = imagelabel

	local directory = nil
	local filename = nil
	local sdisk = nil
	local id = nil
	local toggled = 1

	local filebutton, text1 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0), "Select file", mainframe)

	filebutton.MouseButton1Up:Connect(function()
		if toggled == 1 then
			loaddisk(if directory == "" then "/" else directory, function(name, dir, cd)
				if not holderframe then return end
				if toggled ~= 1 then return end
				directory = dir
				filename = name
				sdisk = cd

				text1.Text = filename
			end, true)
		elseif toggled == 2 then
			if keyboardinput then
				id = keyboardinput:gsub("\n", "")
				text1.Text = id
			end
		end
	end)


	local toggle, text2 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.3), "File mode", mainframe)

	toggle.MouseButton1Up:Connect(function()
		if toggled == 1 then
			toggled = 2
			text2.Text = "ID mode"
			text1.Text = id or "ID (click to update)"
		elseif toggled == 2 then
			toggled = 1
			text2.Text = "File mode"
			text1.Text = filename or "Select file"
		end
	end)

	local openimage = createnicebutton(UDim2.new(1/3,0,0.2,0), UDim2.new(0, 0, 0.75, 0), "Image", mainframe)
	local openaudio = createnicebutton(UDim2.new(1/3,0,0.2,0), UDim2.new(1/3, 0, 0.75, 0), "Audio", mainframe)
	local openvideo = createnicebutton(UDim2.new(1/3,0,0.2,0), UDim2.new((1/3)*2, 0, 0.75, 0), "Video", mainframe)

	openaudio.MouseButton1Up:Connect(function()
		if filename or id then
			local readdata = nil
			if toggled == 1 then
				readdata = filesystem.Read(filename, directory, nil, sdisk)
			else
				readdata = string.lower(tostring(id))
			end
			local data = readdata

			if string.find(tostring(data), "pitch:") then
				local length = nil

				local pitch = nil
				local splitted = string.split(tostring(data), "pitch:")
				local spacesplitted = string.split(tostring(data), " ")

				if string.find(splitted[2], " ") then
					pitch = (string.split(splitted[2], " "))[1]
				else
					pitch = splitted[2]
				end

				if string.find(tostring(data), "length:") then
					local splitted = string.split(tostring(data), "length:")
					if string.find(splitted[2], " ") then
						length = (string.split(splitted[2], " "))[1]
					else
						length = splitted[2]
					end
				end

				audioui(screen, disk, spacesplitted[1], speaker, tonumber(pitch), tonumber(length), if toggled == 1 then filename else "Audio")

			elseif string.find(tostring(data), "length:") then

				local splitted = string.split(tostring(data), "length:")

				local spacesplitted = string.split(tostring(data), " ")

				local length = nil

				if string.find(splitted[2], " ") then
					length = (string.split(splitted[2], " "))[1]
				else
					length = splitted[2]
				end

				audioui(screen, disk, spacesplitted[1], speaker, nil, tonumber(length), if toggled == 1 then filename else "Audio")

			else
				audioui(screen, disk, data, speaker, nil, nil, if toggled == 1 then filename else "Audio")
			end
		end
	end)

	openimage.MouseButton1Up:Connect(function()
		if filename or id then
			local readdata = nil
			if toggled == 1 then
				readdata = filesystem.Read(filename, directory, nil, sdisk)
			else
				readdata = tonumber(id)
			end
			woshtmlfile([[<img src="]]..readdata..[[" size="1,0,1,0" position="0,0,0,0" fit="true">]], screen, true, if toggled == 1 then filename else "Image")
		end
	end)

	openvideo.MouseButton1Up:Connect(function()
		if filename or id then
			local readdata = nil
			if toggled == 1 then
				readdata = filesystem.Read(filename, directory, nil, sdisk)
			else
				readdata = tonumber(id)
			end
			videoplayer(readdata, if toggled == 1 then filename else "Video")
		end
	end)
end

local function chatthing()
	local holderframe, window = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), nil, false, false, false, "Chat", false)

	local messagesent = nil

	if modem then

		local toggleanonymous = false
		local togglea, togglea2 = createnicebutton(UDim2.new(0.4, 0, 0.1, 0), UDim2.new(0,0,0,0), "Enable anonymous", holderframe)

		local idui, idui2 = createnicebutton(UDim2.new(0.6, 0, 0.1, 0), UDim2.new(0.4,0,0,0), "Network id", holderframe)

		idui.MouseButton1Up:Connect(function()
			if keyboardinput and keyboardinput ~= "" then
				local keyboardinput = keyboardinput:gsub("\n", "")
				idui2.Text = keyboardinput
				modem.NetworkID = keyboardinput
			end
		end)

		togglea.MouseButton1Up:Connect(function()
			if toggleanonymous then
				togglea2.Text = "Enable anonymous"
				toggleanonymous = false
			else
				toggleanonymous = true
				togglea2.Text = "Disable anonymous"
			end
		end)

		local scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.new(1, 0, 0.8, 0), Position = UDim2.new(0, 0, 0.1, 0), BackgroundTransparency = 1})
		scrollingframe.Parent = holderframe

		local sendbox, sendbox2 = createnicebutton(UDim2.new(0.8, 0, 0.1, 0), UDim2.new(0,0,0.9,0), "Message (Click to update)", holderframe)

		local sendtext = nil
		local player = nil

		sendbox.MouseButton1Up:Connect(function()
			if keyboardinput then
				sendbox2.Text = keyboardinput:gsub("\n", "")
				sendtext = keyboardinput:gsub("\n", "")
				player = playerthatinputted
			end
		end)

		local sendbutton, sendbutton2 = createnicebutton(UDim2.new(0.2, 0, 0.1, 0), UDim2.new(0.8,0,0.9,0), "Send", holderframe)

		sendbutton.MouseButton1Up:Connect(function()
			if sendtext then
				if not toggleanonymous then
					modem:SendMessage(player..":"..sendtext, id)
				else
					modem:SendMessage(sendtext, id)
				end
				sendbutton2.Text = "Sent"
				task.wait(2)
				sendbutton2.Text = "Send"
			end
		end)

		local start = 0
		local mevent

        if microphone then
    		mevent = microphone.Chatted:Connect(function(player, text)
    			if window:IsClosed() then mevent:Disconnect() return end
    			local subbed = text:lower():sub(1, 5)
    			local sendtext = text:sub(6, string.len(text))

    			if subbed == "chat " then
    				if not toggleanonymous then
    					modem:SendMessage(Players:GetUsername(player)..":"..sendtext, id)
    				else
    					modem:SendMessage(sendtext, modem.NetworkID)
    				end
    			end
    	    end)
    	end
		local backcolor = Color3.new(1, 1, 1)
		messagesent = modem.MessageSent:Connect(function(text)
			if not holderframe then messagesent:Disconnect() end
			print(text)
			local player, data = text:match("(.*):(.*)")
			if not player or not data then
				player, data = "Anonymous", text
			end

			local holdframe = screen:CreateElement("Frame", {BorderSizePixel = 0, BackgroundColor3 = backcolor, BackgroundTransparency = 0.5, Size = UDim2.new(1, 0, 0, 100), Position = UDim2.fromOffset(0, start)})
			local playerlabel = screen:CreateElement("TextLabel", {Text = player, Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, TextScaled = true, BackgroundColor3 = backcolor})
			local textlabel = screen:CreateElement("TextLabel", {Text = data, Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 50), TextScaled = true, BackgroundColor3 = backcolor})
			textlabel.Parent = holdframe
			playerlabel.Parent = holdframe
			holdframe.Parent = scrollingframe
			if backcolor == Color3.new(1, 1, 1) then
				backcolor = Color3.new(0, 0, 0)
			else
				backcolor = Color3.new(1, 1, 1)
			end
			start += 100
			scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start)
			scrollingframe.CanvasPosition = Vector2.new(0, start + 100)
		end)
	else
		local textlabel = screen:CreateElement("TextLabel", {Text = "You need a modem.", Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
		textlabel.Parent = holderframe
	end
end

local function calculator()
	local window = CreateWindow(UDim2.new(0.7, 0, 0.7, 10), nil, false, false, false, "Calculator", false)
	local holderframe = window
	local part1 = screen:CreateElement("TextBox", {ClearTextOnFocus = false, TextEditable = false, TextScaled = true, Size = UDim2.new(0.45, 0, 0.15, 0), Position = UDim2.new(0, 0, 0, 0), Text = "0", BackgroundTransparency = 1})
	local part3 = screen:CreateElement("TextBox", {ClearTextOnFocus = false, TextEditable = false, TextScaled = true, Size = UDim2.new(0.1, 0, 0.15, 0), Position = UDim2.new(0.45, 0, 0, 0), Text = "", BackgroundTransparency = 1})
	local part2 = screen:CreateElement("TextBox", {ClearTextOnFocus = false, TextEditable = false, TextScaled = true, Size = UDim2.new(0.45, 0, 0.15, 0), Position = UDim2.new(0.55, 0, 0, 0), Text = "", BackgroundTransparency = 1})
	part1.Parent = holderframe
	part2.Parent = holderframe
	part3.Parent = holderframe

	local number1 = 0
	local type = nil
	local number2 = 0

	local  button1 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.50, 0, 0.15, 0), "9", holderframe)
	button1.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(9))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(9))
			part2.Text = number2
		end
	end)

	local  button2 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.25, 0, 0.15, 0), "8", holderframe)
	button2.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(8))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(8))
			part2.Text = number2
		end
	end)

	local  button3 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0, 0, 0.15, 0), "7", holderframe)
	button3.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(7))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(7))
			part2.Text = number2
		end
	end)

	local  button4 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.50, 0, 0.3, 0), "6", holderframe)
	button4.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(6))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(6))
			part2.Text = number2
		end
	end)

	local  button5 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.25, 0, 0.3, 0), "5", holderframe)
	button5.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(5))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(5))
			part2.Text = number2
		end
	end)

	local  button6 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0, 0, 0.3, 0), "4", holderframe)
	button6.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(4))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(4))
			part2.Text = number2
		end
	end)

	local  button7 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.50, 0, 0.45, 0), "3", holderframe)
	button7.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(3))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(3))
			part2.Text = number2
		end
	end)

	local  button8 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.25, 0, 0.45, 0), "2", holderframe)
	button8.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(2))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(2))
			part2.Text = number2
		end
	end)

	local  button9 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0, 0, 0.45, 0), "1", holderframe)
	button9.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(1))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(1))
			part2.Text = number2
		end
	end)

	local  button10 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.25, 0, 0.6, 0), "0", holderframe)
	button10.MouseButton1Down:Connect(function()
		if not type then
			if tostring(number1) ~= "0" and tostring(number1) ~= "-0" then
				if tonumber(tostring(number1).."0") then
					number1 = tostring(number1).."0"
					part1.Text = number1
				end
			else
				number1 = 0
				part1.Text = number1
			end
		else
			if tostring(number2) ~= "0" and tostring(number2) ~= "-0" then
				if tonumber(tostring(number2).."0") then
					number2 = tostring(number2).."0"
					part2.Text = number2
				end
			else
				number2 = 0
				part2.Text = number2
			end
		end
	end)

	local  button19 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.50, 0, 0.6, 0), ".", holderframe)
	button19.MouseButton1Down:Connect(function()
		if not type then
			number1 = string.gsub(tostring(number1), "%.", "")
			number1 = tostring(number1).."."
			part1.Text = number1
		else
			number2 = string.gsub(tostring(number2), "%.", "")
			number2 = tostring(number2).."."
			part2.Text = number2
		end
	end)

	local  button20 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.50, 0, 0.75, 0), "(-)", holderframe)
	button20.MouseButton1Down:Connect(function()
		if not type then
			if not tonumber(number1) then return end
			number1 = tonumber(number1) * -1
			part1.Text = number1
		else
			if not tonumber(number2) then return end
			number2 = tonumber(number2) * -1
			part2.Text = number2
		end
	end)

	local  button11 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0, 0, 0.6, 0), "C", holderframe)
	button11.MouseButton1Down:Connect(function()
		number1 = 0
		part1.Text = number1
		number2 = 0
		part2.Text = ""
		type = nil
		part3.Text = ""
	end)

	local  button12 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.75, 0, 0.15, 0), "+", holderframe)
	button12.MouseButton1Down:Connect(function()
		type = "+"
		part3.Text = "+"
	end)

	local  button13 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.75, 0, 0.3, 0), "-", holderframe)
	button13.MouseButton1Down:Connect(function()
		type = "-"
		part3.Text = "-"
	end)

	local  button14 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.75, 0, 0.45, 0), "*", holderframe)
	button14.MouseButton1Down:Connect(function()
		type = "*"
		part3.Text = "*"
	end)

	local  button15 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.75, 0, 0.6, 0), "/", holderframe)
	button15.Parent = holderframe
	button15.MouseButton1Down:Connect(function()
		type = "/"
		part3.Text = "/"
	end)

	local  button17 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0, 0, 0.75, 0), "√", holderframe)
	button17.Parent = holderframe
	button17.MouseButton1Down:Connect(function()
		type = "√"
		part3.Text = "√"
	end)

	local  button18 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.25, 0, 0.75, 0), "^", holderframe)
	button18.Parent = holderframe
	button18.MouseButton1Down:Connect(function()
		type = "^"
		part3.Text = "^"
	end)

	local  button16 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.75, 0, 0.75, 0), "=", holderframe)
	button16.Parent = holderframe
	button16.MouseButton1Down:Connect(function()
		if type == "+" then
			part1.Text = tonumber(number1) + tonumber(number2)
			number1 = tonumber(number1) + tonumber(number2)
			part2.Text = ""
			number2 = 0
			part3.Text = ""
			type = nil
		end

		if type == "-" then
			part1.Text = tonumber(number1) - tonumber(number2)
			number1 = tonumber(number1) - tonumber(number2)
			part2.Text = ""
			number2 = 0
			part3.Text = ""
			type = nil
		end

		if type == "*" then
			part1.Text = tonumber(number1) * tonumber(number2)
			number1 = tonumber(number1) * tonumber(number2)
			part2.Text = ""
			number2 = 0
			part3.Text = ""
			type = nil
		end

		if type == "/" then
			part1.Text = tonumber(number1) / tonumber(number2)
			number1 = tonumber(number1) / tonumber(number2)
			part2.Text = ""
			number2 = 0
			part3.Text = ""
			type = nil
		end

		if type == "√" then
			part1.Text = tonumber(number2) ^ (1 / tonumber(number1))
			number1 = tonumber(number2) ^ (1 / tonumber(number1))
			part2.Text = ""
			number2 = 0
			part3.Text = ""
			type = nil
		end

		if type == "^" then
			part1.Text = tonumber(number1) ^ tonumber(number2)
			number1 = tonumber(number1) ^ tonumber(number2)
			part2.Text = ""
			number2 = 0
			part3.Text = ""
			type = nil
		end
	end)
end

local function restartnow()
	task.wait(1)
	screen:ClearElements()
	local commandlines = commandline.new(false, nil, screen)
	commandlines:insert("Restarting...")
	task.wait(2)
	screen:ClearElements()
	getstuff()
	task.wait(1)
	bootos()
end

local function shutdownnow()
	task.wait(1)
	screen:ClearElements()
	local commandlines = commandline.new(false, nil, screen)
	commandlines:insert("Shutting Down...")
	task.wait(2)
	screen:ClearElements()
	if not putermode then
	    if not back then
		    Microcontroller:Shutdown()
	    else
	        back()
	    end
	else
		pcall(TriggerPort, 2)
	end
end

local prevprompt = nil
function shutdownprompt()
	if prevprompt and not prevprompt:IsClosed() then return end
	local window, holderframe, closebutton, maximize, textlabel, resize, minimize, funcs, index = CreateWindow(UDim2.new(0.4, 0, 0.25, 0), "Are you sure?",true,true,false,nil,true)
	prevprompt = holderframe
	holderframe.ZIndex = (2^31)-3

	windows[index] = {Focused = windows[index].Focused, CloseButton = closebutton}

	local yes = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0, 0, 0.25, 0), "Yes", window)
	local no = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 0.25, 0), "No", window)
	no.MouseButton1Up:Connect(function()
		funcs:Close()
	end)
	yes.MouseButton1Up:Connect(function()
		if holderframe then
			funcs:Close()
		end
		if startbutton7 then
			startbutton7:Destroy()
		end
		if taskbarholder then
			taskbarholder:Destroy()
		end
		if programholder1 then
			programholder1:Destroy()
		end
		if desktopscrollingframe then
		    desktopscrollingframe:Destroy()
	    end

		if cursorevent then cursorevent:Disconnect() end
		keyboardinput = nil
		playerthatinputted = nil
		minimizedprograms = {}
		minimizedammount = 0
		if desktopscrollingframe then desktopscrollingframe:Destroy() end
		task.wait(1)
		if speaker and not speaker:IsDestroyed() then
			task.spawn(function()
				speaker:ClearSounds()
				local sound = speaker:LoadSound(`rbxassetid://{shutdownsound}`)
				sound.Volume = 1
				sound:Play()

				task.wait(2)
				sound:Destroy()
			end)
		end
		for i=0,1,0.01 do
			task.wait(0.01)
			backgroundcolor.BackgroundTransparency = i
			wallpaper.ImageTransparency = i
		end

		if mainframe then
			mainframe:Destroy()
		end

		loadingscreen(true, true)
	end)
	return window, holderframe
end

function restartprompt()
	if prevprompt and not prevprompt:IsClosed() then return end
	local window, holderframe, closebutton, maximize, textlabel, resize, minimize, funcs, index = CreateWindow(UDim2.new(0.4, 0, 0.25, 0), "Are you sure?",true,true,false,nil,true)
	prevprompt = holderframe
	holderframe.ZIndex = (2^31)-3

	windows[index] = {Focused = windows[index].Focused, CloseButton = closebutton}

	local yes = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0, 0, 0.25, 0), "Yes", window)
	local no = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 0.25, 0), "No", window)
	no.MouseButton1Up:Connect(function()
		funcs:Close()
	end)
	yes.MouseButton1Up:Connect(function()
		if holderframe then
			funcs:Close()
		end
		if startbutton7 then
			startbutton7:Destroy()
		end
		if taskbarholder then
			taskbarholder:Destroy()
		end
		if programholder1 then
			programholder1:Destroy()
		end
		if desktopscrollingframe then
		    desktopscrollingframe:Destroy()
	    end

		if cursorevent then cursorevent:Disconnect() end
		minimizedprograms = {}
		minimizedammount = 0
		if desktopscrollingframe then desktopscrollingframe:Destroy() end
		task.wait(1)
		if speaker and not speaker:IsDestroyed() then
				task.spawn(function()
				speaker:ClearSounds()
				local sound = speaker:LoadSound(`rbxassetid://{shutdownsound}`)
				sound:Play()

				task.wait(2)
				sound:Destroy()
			end)
		end
		for i=0,1,0.05 do
			task.wait(0.05)
			backgroundcolor.BackgroundTransparency = i
			wallpaper.ImageTransparency = i
		end

		if mainframe then
			mainframe:Destroy()
		end

		loadingscreen(true, false)
	end)
	return window, holderframe
end

local previousframe
function openrightclickprompt(frame, name, dir, boolean1, boolean2, x, y, cd)
	local disk = cd or disk

	if rightclickmenu then
		rightclickmenu:Destroy()
		rightclickmenu = nil
	else
		previousframe = nil
	end
	if previousframe == frame then previousframe = nil; rightclickmenu = nil; return end


	previousframe = frame

	local size = UDim2.new(0.2, 0, 0.4, 0)

	if not boolean2 then

		size = UDim2.fromScale(0.2/desktopscrollingframe.CanvasSize.X.Scale, 0.3)

		if boolean1 then
			size = UDim2.fromScale(0.2/desktopscrollingframe.CanvasSize.X.Scale, 0.5)
		end

	end

	local position = UDim2.new(0, math.min(x or frame.AbsolutePosition.X, screen:GetDimensions().X*0.8), 0, math.min(y or frame.AbsolutePosition.Y, screen:GetDimensions().Y*0.6))

	if not boolean2 then

		position = UDim2.fromScale(frame.Position.X.Scale + frame.Size.X.Scale, frame.Position.Y.Scale)

		if frame.Position.Y.Scale >= 0.5 then
			position = UDim2.fromScale(position.X.Scale, frame.Position.Y.Scale - if boolean1 then frame.Size.Y.Scale*2.5 else 0)
		end

		if frame.Position.X.Scale >= desktopscrollingframe.CanvasSize.X.Scale - 0.2 then
			position = UDim2.fromScale(frame.Position.X.Scale - frame.Size.X.Scale, position.Y.Scale)
		end

	end

	rightclickmenu = screen:CreateElement("ImageButton", {Size = size, Position = position, BackgroundTransparency = 1, Image = "rbxassetid://15619032563"})
	if not boolean2 then
		rightclickmenu.Parent = desktopscrollingframe
	end
	local closebutton = createnicebutton(if not boolean1 then UDim2.fromScale(1, 1/3) else UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0), "Close", rightclickmenu)
	if not boolean1 then
		local openbutton = createnicebutton(UDim2.fromScale(1, 1/3), UDim2.fromScale(0, 1/3), "Open", rightclickmenu)

		openbutton.MouseButton1Up:Connect(function()
			rightclickmenu:Destroy()
			rightclickmenu = nil
			readfile(filesystem.Read(name, dir, nil, disk), name, dir)
		end)

		local deletebutton = createnicebutton(UDim2.fromScale(1, 1/3), UDim2.fromScale(0, (1/3) + (1/3)), "Delete", rightclickmenu)
		deletebutton.MouseButton1Up:Connect(function()
			rightclickmenu:Destroy()
			rightclickmenu = nil
			local holdframe, windowz, closebutton, maximize, textlabel, resize, minimize, funcs = CreateWindow(UDim2.new(0.4, 0, 0.25, 0), "Are you sure?", true, true, false, nil, true)
			local deletebutton = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0, 0, 0.25, 0), "Yes", holdframe)
			local cancelbutton = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 0.25, 0), "No", holdframe)

			cancelbutton.MouseButton1Up:Connect(function()
				funcs:Close()
			end)

			deletebutton.MouseButton1Up:Connect(function()
				filesystem.Write(name, nil, dir, disk)
				funcs:Close()
				loaddesktopicons()
			end)
		end)
	else
		local filesbutton = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.2), "Files", rightclickmenu)
		local settingsbutton = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.4), "Settings", rightclickmenu)
		local reload = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.8), "Reload", rightclickmenu)
		local luas = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.6), "Lua", rightclickmenu)

		filesbutton.MouseButton1Up:Connect(function()
			rightclickmenu:Destroy()
			rightclickmenu = nil
			loaddisk("/")
		end)

		settingsbutton.MouseButton1Up:Connect(function()
			rightclickmenu:Destroy()
			rightclickmenu = nil
			settings()
		end)

		reload.MouseButton1Up:Connect(function()
			rightclickmenu:Destroy()
			rightclickmenu = nil
			loaddesktopicons()
		end)

		luas.MouseButton1Up:Connect(function()
			rightclickmenu:Destroy()
			rightclickmenu = nil
			customprogramthing()
		end)
	end

	closebutton.MouseButton1Up:Connect(function()
		rightclickmenu:Destroy()
		rightclickmenu = nil
	end)
end

local desktopicons = {}
local selectedicon = nil
local selectionimage = nil

function loaddesktopicons()
	previousframe = nil
	if exists(desktopscrollingframe) then
		pcall(desktopscrollingframe.Destroy, selectionimage)
		desktopicons = {}
		selectedicon = nil
	end

	if exists(selectionimage) then
		pcall(selectionimage.Destroy, selectionimage)
	end

	selectionimage = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ImageTransparency = 0.5, Image = "rbxassetid://8677487226"})
	if resolutionframe then
		selectionimage.Parent = resolutionframe
	end

	print("z")

	desktopscrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1,0,0.9,0), BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0.9,0), ScrollBarThickness = 5})
	desktopscrollingframe.Parent = wallpaper

	local desktopfiles = filesystem.Read("Desktop", "/")

	if not desktopfiles then
		disk:Write("Desktop", {})
		desktopfiles = {}
	end


	local xScale = 0
	local yScale = 0

	local scrollX = iconsize
	local scrollY = 0.9 * iconsize
	if typeof(desktopfiles) == "table" then
		for i, v in pairs(desktopfiles) do
			if scrollY > 1-iconsize then
				scrollY = 0
				scrollX += iconsize
			end
			scrollY += 0.9 * iconsize
		end

		if scrollY < 0.9 then scrollY = 0.9 end
		if scrollX < 1 then scrollX = 1 else scrollX += 0.2 end
		if scrollX < 1-iconsize then scrollX = 1-iconsize end

		desktopscrollingframe.CanvasSize = UDim2.fromScale(scrollX, scrollY)
	else
		desktopscrollingframe.CanvasSize = UDim2.fromScale(1, 0.9)
	end

	local mycomputer = screen:CreateElement("TextButton", {Size = UDim2.fromScale(iconsize/desktopscrollingframe.CanvasSize.X.Scale, iconsize), BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0), TextTransparency = 1})
	mycomputer.Parent = desktopscrollingframe
	local imagelabel1 = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(1, 0.5), ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1, Image = "rbxassetid://16168953881"})
	imagelabel1.Parent = mycomputer
	local textlabel1 = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(1, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Computer", TextStrokeColor3 = Color3.new(0,0,0), TextColor3 = Color3.new(1,1,1), TextStrokeTransparency = 0.25})
	textlabel1.Parent = mycomputer
	mycomputer.MouseButton1Up:Connect(function()
		if selectedicon ~= mycomputer then
			selectedicon = mycomputer
			selectionimage.Parent = mycomputer
			for i, v in ipairs(desktopicons) do
				v.TextLabel.Size = UDim2.fromScale(1, 0.5)
				v.TextLabel.Position = UDim2.fromScale(0, 0.5)
			end

			textlabel1.Size = UDim2.fromScale(1, 1)
			textlabel1.Position = UDim2.fromScale(0, 0)
		else
			openrightclickprompt(mycomputer, nil, "/Desktop", true)
			selectedicon = nil
			if resolutionframe then
				selectionimage.Parent = resolutionframe
			end
			for i, v in ipairs(desktopicons) do
				v.TextLabel.Size = UDim2.fromScale(1, 0.5)
				v.TextLabel.Position = UDim2.fromScale(0, 0.5)
			end
			if speaker then speaker:PlaySound(clicksound) end
		end
	end)

	table.insert(desktopicons, {["Holder"] = mycomputer, ["Icon"] = imagelabel1, ["TextLabel"] = textlabel1})

	if typeof(desktopfiles) == "table" then
		for filename, data in pairs(desktopfiles) do
			if yScale + iconsize >= 1 - iconsize then
				yScale = 0
				xScale += iconsize
			else
				yScale += iconsize
			end
			local holderbutton = screen:CreateElement("TextButton", {Size = UDim2.fromScale(iconsize/desktopscrollingframe.CanvasSize.X.Scale, iconsize), BackgroundTransparency = 1, Position = UDim2.fromScale(xScale/desktopscrollingframe.CanvasSize.X.Scale, yScale/desktopscrollingframe.CanvasSize.Y.Scale), TextTransparency = 1})
			holderbutton.Parent = desktopscrollingframe
			local imagelabel = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(1, 0.5), ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1, Image = "rbxassetid://16137083118"})
			imagelabel.Parent = holderbutton
			local textlabel = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(1, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(filename), TextStrokeColor3 = Color3.new(0,0,0), TextColor3 = Color3.new(1,1,1), TextStrokeTransparency = 0.25})
			textlabel.Parent = holderbutton

			if string.find(filename, "%.gui") or string.find(string.lower(tostring(data)), "<woshtml>") then
				imagelabel.Image = "rbxassetid://17104255245"
			end

			if string.find(filename, "%.aud") then
				imagelabel.Image = "rbxassetid://16137076689"
			end

			if string.find(filename, "%.img") then
				imagelabel.Image = "rbxassetid://16138716524"
			end

			if string.find(filename, "%.vid") then
				imagelabel.Image = "rbxassetid://16137079551"
			end

			if string.find(filename, "%.lua") then
				imagelabel.Image = "rbxassetid://16137086052"
			end

			if typeof(data) == "function" then
				imagelabel.Image = "rbxassetid://17205316410"
			end

			if typeof(data) == "table" then
				local length = 0

				for i, v in pairs(data) do
					length += 1
				end


				if length > 0 then
					imagelabel.Image = "rbxassetid://16137091192"
				else
					imagelabel.Image = "rbxassetid://16137073439"
				end
			end

			if string.find(filename, "%.lnk") then
				local image2 = screen:CreateElement("ImageLabel", {Size = UDim2.new(0.4, 0, 0.4, 0), Position = UDim2.new(0, 0, 0.6, 0), BackgroundTransparency = 1, Image = "rbxassetid://16180413404", ScaleType = Enum.ScaleType.Fit})
				image2.Parent = imagelabel

				local split = tostring(data):split("/")
				if split then
					local file = split[#split]
					local dir = ""

					local disk = disks[1]

					if tonumber(split[1]) then
						disk = disks[tonumber(split[1])]
					end

					for index, value in ipairs(split) do
						if index < #split and index > 1 then
							dir = dir.."/"..value
						end
					end

					local data1 = filesystem.Read(file, if dir == "" then "/" else dir, true, disk)

					if dir == "" and file == "" then
						data1 = disk:ReadAll()
					end

					if data1 then

						if string.find(file, "%.gui") or string.find(string.lower(tostring(data1)), "<woshtml>") then
							imagelabel.Image = "rbxassetid://17104255245"
						end

						if string.find(file, "%.aud") then
							imagelabel.Image = "rbxassetid://16137076689"
						end

						if string.find(file, "%.img") then
							imagelabel.Image = "rbxassetid://16138716524"
						end

						if string.find(file, "%.vid") then
							imagelabel.Image = "rbxassetid://16137079551"
						end

						if string.find(file, "%.lua") then
							imagelabel.Image = "rbxassetid://16137086052"
						end

						if typeof(data1) == "function" then
							imagelabel.Image = "rbxassetid://17205316410"
						end

						if typeof(data1) == "table" then
							local length = 0

							for i, v in pairs(data1) do
								length += 1
							end


							if length > 0 then
								imagelabel.Image = "rbxassetid://16137091192"
							else
								imagelabel.Image = "rbxassetid://16137073439"
							end
						end
					end
				end
			end

			holderbutton.MouseButton1Down:Connect(function()
				if selectedicon ~= holderbutton then
					selectedicon = holderbutton
					selectionimage.Parent = holderbutton
					for i, v in ipairs(desktopicons) do
						v.TextLabel.Size = UDim2.fromScale(1, 0.5)
						v.TextLabel.Position = UDim2.fromScale(0, 0.5)
					end

					textlabel.Size = UDim2.fromScale(1, 1)
					textlabel.Position = UDim2.fromScale(0, 0)
				else
					openrightclickprompt(holderbutton, filename, "/Desktop", false)
					selectedicon = nil
					if resolutionframe then
						selectionimage.Parent = resolutionframe
					end
					for i, v in ipairs(desktopicons) do
						v.TextLabel.Size = UDim2.fromScale(1, 0.5)
						v.TextLabel.Position = UDim2.fromScale(0, 0.5)
					end
					if speaker then speaker:PlaySound(clicksound) end
				end
			end)

			table.insert(desktopicons, {["Holder"] = holderbutton, ["Icon"] = imagelabel, ["TextLabel"] = textlabel})
			task.wait()
		end
	end
end

local function terminal()
	local richtext = false
	local keyboardevent
	local position = UDim2.new(0,0,0,0)

	local commandlines, background, holderframe, windowz = commandline.new(true, UDim2.fromScale(0.7, 0.7), screen, function() return richtext end)

	local window = holderframe

	local name = "GustavDOS For GustavOSDesktop7"

	local copydir
	local copydisk
	local copyname
	local copydata

	local disk = disk

	local bootdos
	local dir = "/"

	local function playsound(txt, name)
		if txt then
			if string.find(tostring(txt), "pitch:") then
				local length = nil

				local pitch = nil
				local splitted = string.split(tostring(txt), "pitch:")
				local spacesplitted = string.split(tostring(txt), " ")

				if string.find(splitted[2], " ") then
					pitch = (string.split(splitted[2], " "))[1]
				else
					pitch = splitted[2]
				end

				if string.find(tostring(txt), "length:") then
					local splitted = string.split(tostring(txt), "length:")
					if string.find(splitted[2], " ") then
						length = (string.split(splitted[2], " "))[1]
					else
						length = splitted[2]
					end
				end
				audioui(screen, disk, spacesplitted[1], speaker, tonumber(pitch), tonumber(length), name)
			elseif string.find(tostring(txt), "length:") then

				local splitted = string.split(tostring(txt), "length:")

				local spacesplitted = string.split(tostring(txt), " ")

				local length = nil

				if string.find(splitted[2], " ") then
					length = (string.split(splitted[2], " "))[1]
				else
					length = splitted[2]
				end

				audioui(screen, disk, spacesplitted[1], speaker, nil, tonumber(length), name)

			else
				audioui(screen, disk, txt, speaker, nil, nil, name)
			end
		end
	end

	local prglines = {
		clear = commandlines.clear,
		insert = commandlines.insert,
		background = background,
		disablecmds = function()
			cmdsenabled = false
		end,
		enablecmds = function()
			cmdsenabled = true
		end,
		cmdsenabled = function()
			return cmdsenabled
		end,
	}

	local function runtext(text)
		local lowered = text:lower()
		if lowered:sub(1, 4) == "dir " then
			local txt = text:sub(5, string.len(text))
			local inputtedtext = txt
			local tempsplit = string.split(inputtedtext, "/")
			if tempsplit then
				if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
					inputtedtext = "/"..inputtedtext
				end
			end
			local tempsplit2 = string.split(inputtedtext, "/")
			if tempsplit2 then
				if inputtedtext:sub(-1, -1) == "/" and tempsplit2[2] ~= "" then inputtedtext = inputtedtext:sub(0, -2); end
			end
			if inputtedtext == " " then inputtedtext = ""; end
			local split = string.split(inputtedtext, "/")
			if split then
				local removedlast = inputtedtext:sub(1, -(string.len(split[#split]))-2)
				if #split >= 3 then
					if typeof(getfileontable(disk, split[#split], removedlast)) == "table" then
						commandlines.insert(inputtedtext..":")
						dir = inputtedtext
					else
						commandlines.insert("Invalid directory")
						commandlines.insert(dir..":")
					end
				else
					if disk:Read(split[#split]) or split[2] == "" then
						if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
							commandlines.insert(inputtedtext..":")
							dir = inputtedtext
						elseif tempsplit[1] == "" and tempsplit[2] == "" then
							commandlines.insert(inputtedtext..":")
							dir = inputtedtext
						elseif tempsplit[1] == "" and tempsplit[2] ~= "" then
							if typeof(disk:Read(split[#split])) == "table" then
								commandlines.insert(inputtedtext..":")
								dir = inputtedtext
							end
						else
							commandlines.insert("Invalid directory")
							commandlines.insert(dir..":")
						end
					else
						commandlines.insert("Invalid directory")
						commandlines.insert(dir..":")
					end
				end
			elseif inputtedtext == "" then
				commandlines.insert(dir..":")
			else
				commandlines.insert("Invalid directory")
				commandlines.insert(dir..":")
			end
		elseif lowered:gsub("%s", "") == "clear" then
			task.wait(0.1)
			commandlines.clear()
			position = UDim2.new(0,0,0,0)
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 11) == "setstorage " then
			local text = text:sub(12, string.len(text))

			local text = tonumber(text)

			if disks[text] then
				disk = disks[text]
				dir = "/"
				commandlines.insert("Success")
			else
				commandlines.insert("Invalid storage media number.")
			end
			commandlines.insert(dir..":")
		elseif lowered:gsub("%s", "") == "showstorages" then
			for i, val in ipairs(disks) do
				commandlines.insert(tostring(i))
			end
			commandlines.insert(dir..":")
		elseif lowered:gsub("%s", "") == "reboot" then
			task.wait(1)
			Beep(1)
			getstuff()
			dir = "/"
			if keyboardevent then keyboardevent:Disconnect() end
			bootos()
		elseif lowered:gsub("%s", "") == "shutdown" then
			if text:sub(9, string.len(text)) == nil or text:sub(9, string.len(text)) == "" then
				task.wait(1)
				Beep(1)
				screen:ClearElements()
				if speaker then
					speaker:ClearSounds()
				end
				Microcontroller:Shutdown()
			else
				commandlines.insert(dir..":")
			end
		elseif lowered:sub(1, 9) == "richtext " then
			local bool = text:sub(10, string.len(text)):gsub("%s", ""):lower()
			if bool == "true" then
				richtext = true
			elseif bool == "false" then
				richtext = false
			else
				commandlines.insert("No valid boolean was given.")
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 6) == "print " then
			local output = text:sub(7, string.len(text))
			local spacesplitted = string.split(tostring(output), "\n")
			if spacesplitted then
				for i, v in ipairs(spacesplitted) do
					commandlines.insert(v)
				end
			else
				commandlines.insert(tostring(output))
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 5) == "copy " then
			local filename = text:sub(6, string.len(text))
			if filename and filename ~= "" then
				local file = filesystem.Read(filename, dir, true, disk)

				if file then
					copydir = dir
					copydisk = disk
					copyname = filename
					copydata = file
					commandlines.insert("Copied, use the paste command to paste the file.")
				else
					commandlines.insert("The specified file was not found on this directory.")
				end
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 5) == "paste" then
			if copydir ~= "" and copyname ~= "" then
				local file = filesystem.Read(copyname, copydir, true, copydisk)

				if not file then
					file = copydata
				end

				if file then
					local result = filesystem.Write(copyname, file, dir, disk)
					commandlines.insert(result)
				else
					commandlines.insert("File does not exist.")
				end
			else
				commandlines.insert("No file has been copied.")
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 7) == "rename " then
			local misc = text:sub(8, string.len(text))
			local split1 = misc:split("/")
			local filename = split1[1]
			local newname = ""

			for index, value in ipairs(split1) do
				if index >= 2 then
					newname = newname..value
				end
			end

			if filename and filename ~= "" then
				local file = filesystem.Read(filename, dir, true, disk)
				if file then
					if newname ~= "" then
						filesystem.Write(newname, file, dir, disk)
						filesystem.Write(filename, nil, dir, disk)
						commandlines.insert("Renamed.")
					else
						commandlines.insert("The new filename wasn't specified.")
					end
				else
					commandlines.insert("The specified file was not found on this directory.")
				end
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 3) == "cd " then
			local filename = text:sub(4, string.len(text))

			if filename and filename ~= "" and filename ~= "./" then
				local file = filesystem.Read(filename, dir, true, disk)

				if typeof(file) == "table" then
					dir = if dir == "/" then dir..filename else dir.."/"..filename
					commandlines.insert("Success?")
				else
					commandlines.insert("The specified file is not a table.")
				end
			elseif filename == "./" then
				local split = dir:split("/")
				if #split == 2 and split[2] == "" then
					commandlines.insert("Cannot use ./ on root.")
				else
					local newdir = dir:sub(1, -(string.len(split[#split]))-2)
					dir = if newdir == "" then "/" else newdir
				end
			else
				commandlines.insert("The table/folder name was not specified.")
			end
			commandlines.insert(dir..":")
		elseif lowered:gsub("%s", "") == "showluas" then
			for i,v in pairs(getprograms()) do
				commandlines.insert(v)
				commandlines.insert(i)
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 8) == "stoplua " then
			local number = tonumber(text:sub(9, string.len(text)))
			local success = false
			if typeof(number) == "number" then
				success = stopprogram(number)
			end
			if not success then
				commandlines.insert("Invalid program number.")
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 7) == "runlua " then
			local err = runprogram(text:sub(8, string.len(text)), nil, "lines", prglines)
			if err then commandlines.insert(err) end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 8) == "readlua " then
			local filename = text:sub(9, string.len(text))
			if filename and filename ~= "" then
				local output = filesystem.Read(filename, dir, true, disk)
				local output = output
				local err = runprogram(output, filename, "lines", prglines)
				if err then commandlines.insert(err) end
			else
				commandlines.insert("No filename specified")
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 5) == "beep " then
			local number = tonumber(text:sub(6, string.len(text)))
			if number then
				Beep(number)
			else
				commandlines.insert("Invalid number")
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 10) == "setvolume " then
			if speaker then
				local number = tonumber(text:sub(11, string.len(text)))
				if number then
					speaker.Volume = number
				else
					commandlines.insert("Invalid number")
				end
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 7) == "showdir" then
			local inputtedtext = dir
			local tempsplit = string.split(inputtedtext, "/")
			if tempsplit then
				if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
					inputtedtext = "/"..inputtedtext
				end
			end
			local tempsplit2 = string.split(inputtedtext, "/")
			if tempsplit2 then
				if inputtedtext:sub(-1, -1) == "/" and tempsplit2[2] ~= "" then inputtedtext = inputtedtext:sub(0, -2); end
			end
			if inputtedtext == " " then inputtedtext = ""; end
			local split = string.split(inputtedtext, "/")
			if split then
				local removedlast = inputtedtext:sub(1, -(string.len(split[#split]))-2)
				if #split >= 3 then
					local output = getfileontable(disk, split[#split], removedlast)
					if typeof(output) == "table" then
						for i,v in pairs(output) do
							commandlines.insert(tostring(i))
						end
					else
						commandlines.insert("Invalid directory")
					end
				else
					local output = disk:Read(split[#split])
					if output or split[2] == "" then
						if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
							if typeof(output) == "table" then
								for i,v in pairs(output) do
									commandlines.insert(tostring(i))
								end
							end
						elseif tempsplit[1] == "" and tempsplit[2] == "" then
							for i,v in pairs(disk:ReadAll()) do
								commandlines.insert(tostring(i))
							end
						elseif tempsplit[1] == "" and tempsplit[2] ~= "" then
							if typeof(disk:Read(split[#split])) == "table" then
								for i,v in pairs(disk:Read(split[#split])) do
									commandlines.insert(tostring(i))
								end
							end
						else
							commandlines.insert("Invalid directory")
						end
					else
						commandlines.insert("Invalid directory")
					end
				end
			elseif inputtedtext == "" then
				for i,v in pairs(disk:ReadAll()) do
					commandlines.insert(tostring(i))
				end
			else
				commandlines.insert("Invalid directory")
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 10) == "createdir " then
			local filename = text:sub(11, string.len(text))
			if filename and filename ~= "" then
				local result = filesystem.Write(filename, {}, dir, disk)

				commandlines.insert(result)
			else
				commandlines.insert("No filename specified")
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 6) == "write " then
			local texts = text:sub(7, string.len(text))
			local filename = texts:split("/")[1]
			local filedata = texts:split("/")[2]
			for i,v in ipairs(texts:split("/")) do
				if i > 2 then
					filedata = filedata.."/"..v
				end
			end
			if filename and filename ~= "" then
				if filedata and filedata ~= "" then
					local result = filesystem.Write(filename, filedata, dir, disk)

					commandlines.insert(result)
				else
					commandlines.insert("No filedata specified")
				end
			else
				commandlines.insert("No filename specified")
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 7) == "delete " then
			local filename = text:sub(8, string.len(text))
			if filename then
				local result = filesystem.Write(filename, nil, dir, disk)

				commandlines.insert(result)
			else
				commandlines.insert("No filename specified")
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 5) == "read " then
			local filename = text:sub(6, string.len(text))
			if filename then
				local output = filesystem.Read(filename, dir, true, disk)
				if string.find(string.lower(tostring(output)), "<woshtml>") then
					local textlabel = commandlines.insert(tostring(output), UDim2.fromScale(1, 1))
					StringToGui(screen, tostring(output):lower(), textlabel)
					textlabel.TextTransparency = 1
				else
					local spacesplitted = string.split(tostring(output), "\n")
					if spacesplitted then
						for i, v in ipairs(spacesplitted) do
							commandlines.insert(v)
						end
					else
						commandlines.insert(tostring(output))
					end
				end
			else
				commandlines.insert("No filename specified")
			end
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 10) == "readimage " then
			local filename = text:sub(11, string.len(text))
			if filename and filename ~= "" then
				local output = filesystem.Read(filename, dir, true, disk)
				local textlabel = commandlines.insert(tostring(output), UDim2.fromScale(1, 1))
				StringToGui(screen, [[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
			else
				commandlines.insert("No filename specified")
			end
			commandlines.insert(dir..":")
			if filename and filename ~= "" then
				background.CanvasPosition -= Vector2.new(0, 25)
			end
		elseif lowered:sub(1, 10) == "readvideo " then
			local filename = text:sub(11, string.len(text))
			if filename and filename ~= "" then
				local output = filesystem.Read(filename, dir, true, disk)
				local textlabel = commandlines.insert(output, UDim2.fromScale(1, 1))
				local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..tostring(tonumber(output))})
				videoframe.Parent = textlabel
				videoframe.Playing = true
			else
				commandlines.insert("No filename specified")
			end
			commandlines.insert(dir..":")
			if filename and filename ~= "" then
				background.CanvasPosition -= Vector2.new(0, 25)
			end
		elseif lowered:sub(1, 13) == "displayimage " then
			local id = text:sub(14, string.len(text))
			if id and id ~= "" then
				local textlabel = commandlines.insert(tostring(id), UDim2.fromScale(1, 1))
				StringToGui(screen, [[<img src="]]..tostring(tonumber(id))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
			else
				commandlines.insert("No id specified")
			end
			commandlines.insert(dir..":")
			if id and id ~= "" then
				background.CanvasPosition -= Vector2.new(0, 25)
			end
		elseif lowered:sub(1, 13) == "displayvideo " then
			local id = text:sub(14, string.len(text))
			if id and id ~= "" then
				local textlabel = commandlines.insert(tostring(id), UDim2.fromScale(1, 1))
				local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..id})
				videoframe.Parent = textlabel
				videoframe.Playing = true
			else
				commandlines.insert("No id specified")
			end
			commandlines.insert(dir..":")
			if id and id ~= "" then
				background.CanvasPosition -= Vector2.new(0, 25)
			end
		elseif lowered:sub(1, 10) == "readsound " then
			local filename = text:sub(11, string.len(text))
			local txt
			if filename and filename ~= "" then
				local output = filesystem.Read(filename, dir, true, disk)
				local textlabel = commandlines.insert(tostring(output))
				txt = output
			else
				commandlines.insert("No filename specified")
			end
			playsound(txt)
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 10) == "playsound " then
			local txt = text:sub(11, string.len(text))
			playsound(txt)
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 10) == "stopsounds" then
			speaker:ClearSounds()
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 11) == "soundpitch " then
			if speaker and tonumber(text:sub(12, string.len(text))) then
				speaker:Configure({Pitch = tonumber(text:sub(12, string.len(text)))})
				speaker:Trigger()
			else
				commandlines.insert("Invalid pitch number or no speaker was found.")
			end
			commandlines.insert(dir..":")
		elseif lowered:gsub("%s", "") == "cmds" then
			commandlines.insert("Commands:")
			commandlines.insert("cmds")
			commandlines.insert("stopsounds")
			commandlines.insert("soundpitch number")
			commandlines.insert("readsound filename")
			commandlines.insert("read filename")
			commandlines.insert("readimage filename")
			commandlines.insert("dir directory")
			commandlines.insert("showdir")
			commandlines.insert("write filename/filedata (with the /)")
			commandlines.insert("shutdown")
			commandlines.insert("clear")
			commandlines.insert("showstorages")
			commandlines.insert("setstorage number")
			commandlines.insert("reboot")
			commandlines.insert("delete filename")
			commandlines.insert("createdir filename")
			commandlines.insert("stoplua number")
			commandlines.insert("runlua lua")
			commandlines.insert("showluas")
			commandlines.insert("richtext boolean")
			commandlines.insert("readlua filename")
			commandlines.insert("beep number")
			commandlines.insert("print text")
			commandlines.insert("playsound id")
			commandlines.insert("displayimage id")
			commandlines.insert("displayvideo id")
			commandlines.insert("readvideo id")
			commandlines.insert("cd table/folder or ./ for parent table/folder")
			commandlines.insert("copy filename")
			commandlines.insert("paste")
			commandlines.insert("rename filename/new filename (with the /)")
			commandlines.insert("Put !s before the command to replace the new lines with spaces instead of removing them.")
			commandlines.insert("Put !n before the command to replace \\\\n with a new line.")
			commandlines.insert("Put !k before the command to not remove the new lines.")
			commandlines.insert(dir..":")
		elseif lowered:sub(1, 4) == "help" then
			keyboard:SimulateTextInput("cmds", "Microcontroller")

		elseif lowered:sub(1, 10) == "stopmicro " then
			keyboard:SimulateTextInput("stoplua "..text:sub(11, string.len(text)), "Microcontroller")
		elseif lowered:sub(1, 10) == "showmicros" then
			keyboard:SimulateTextInput("showluas", "Microcontroller")

		elseif lowered:sub(1, 10) == "playvideo " then
			keyboard:SimulateTextInput("displayvideo "..text:sub(11, string.len(text)), "Microcontroller")

		elseif lowered:sub(1, 8) == "makedir " then
			keyboard:SimulateTextInput("createdir "..text:sub(9, string.len(text)), "Microcontroller")
		elseif lowered:sub(1, 6) == "mkdir " then
			keyboard:SimulateTextInput("createdir "..text:sub(7, string.len(text)), "Microcontroller")
		elseif lowered:sub(1, 5) == "echo " then
			keyboard:SimulateTextInput("print "..text:sub(6, string.len(text)), "Microcontroller")
		elseif lowered:sub(1, 10) == "playaudio " then
			keyboard:SimulateTextInput("playsound "..text:sub(11, string.len(text)), "Microcontroller")
		elseif lowered:sub(1, 10) == "readaudio " then
			keyboard:SimulateTextInput("readsound "..text:sub(11, string.len(text)), "Microcontroller")
		elseif lowered:sub(1, 10) == "stopaudios" then
			keyboard:SimulateTextInput("stopsounds", "Microcontroller")
		elseif lowered:sub(1, 9) == "stopaudio" then
			keyboard:SimulateTextInput("stopsounds", "Microcontroller")
		elseif lowered:sub(1, 9) == "stopsound" then
			keyboard:SimulateTextInput("stopsounds", "Microcontroller")
		else
			local filename = text
			local output = filesystem.Read(filename, dir, true, disk)
			if output then
				if getfileextension(filename, true) == ".aud" then
					commandlines.insert(tostring(output))
					playsound(output)
					commandlines.insert(dir..":")
				elseif getfileextension(filename, true) == ".img" then
					local textlabel = commandlines.insert(tostring(output), UDim2.fromScale(1, 1))
					StringToGui(screen, [[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
					commandlines.insert(dir..":")
					background.CanvasPosition -= Vector2.new(0, 25)
				elseif getfileextension(filename, true) == ".lua" then
					local err = runprogram(output, filename, "lines", prglines)
					if err then commandlines.insert(err) end
					commandlines.insert(dir..":")
				else
					if string.find(string.lower(tostring(output)), "<woshtml>") then
						local textlabel = commandlines.insert(tostring(output), UDim2.fromScale(1, 1))
						StringToGui(screen, tostring(output):lower(), textlabel)
						textlabel.TextTransparency = 1
						commandlines.insert(dir..":")
						background.CanvasPosition -= Vector2.new(0, 25)
					else
						local spacesplitted = string.split(tostring(output), "\n")
						if spacesplitted then
							for i, v in ipairs(spacesplitted) do
								commandlines.insert(v)
							end
						else
							commandlines.insert(tostring(output))
						end
						commandlines.insert(dir..":")
					end
				end
			else
				commandlines.insert("Imcomplete or Command was not found.")
				commandlines.insert(dir..":")
			end
		end
	end

	function bootdos()
		if screen and keyboard and disk and rom then
			background.Parent = window
			task.wait(1)
			Beep(1)
			commandlines:insert(name.." Command line")
			task.wait(1)
			commandlines:insert("/:")
			if keyboardevent then keyboardevent:Disconnect() end
			local exclmarkthings = {
				["!s"] = function(text)
					local text = string.sub(tostring(text), 3, string.len(text)):gsub("\n", " ")
					commandlines.insert(text)
					runtext(text)
				end,
				["!n"] = function(text)
					local text = string.sub(tostring(text), 3, string.len(text)):gsub("\n", ""):gsub("\\n", "\n")
					commandlines.insert(text)
					runtext(text)
				end,
				["!k"] = function(text)
					local text = string.sub(tostring(text), 3, string.len(text))
					commandlines.insert(text)
					runtext(text)
				end,
			}
			keyboardevent = keyboard.TextInputted:Connect(function(text, player)
				if windowz:IsClosed() then keyboardevent:Disconnect() return end
				if not windowz:IsFocused() then return end
				local func = exclmarkthings[string.sub(tostring(text), 1, 2)]
				if not func then
					commandlines.insert(text)
					runtext(text)
				else
					func(text)
				end
			end)
		else
			print("how the hell")
		end
	end
	bootdos()

	return prglines
end
local restartkey
local ctrlpressed = false
local altpressed = false
local shiftpressed = false

local function loaddesktop()
	minimizedammount = 0
	minimizedprograms = {}
	resolutionframe = screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Position = UDim2.new(2,0,0,0)})
	mainframe = screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0)})
	backgroundcolor = screen:CreateElement("Frame", {Size = UDim2.new(1,0,1,0), BackgroundColor3 = color})
	wallpaper = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1})
	backgroundcolor.Parent = mainframe
	wallpaper.Parent = backgroundcolor
	if backgroundimage then
		wallpaper.Image = backgroundimage
		if tile then
			if tilesize then
				wallpaper.ScaleType = Enum.ScaleType.Tile
				wallpaper.TileSize = UDim2.new(tilesize.X.Scale, tilesize.X.Offset, tilesize.Y.Scale, tilesize.Y.Offset)
			end
		else
			wallpaper.ScaleType = Enum.ScaleType.Stretch
		end
	end

	if restartkey then restartkey:Disconnect() end

	restartkey = keyboard.UserInput:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
			if input.UserInputState == Enum.UserInputState.Begin then
				ctrlpressed = true
			else
				ctrlpressed = false
			end
		elseif input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
			if input.UserInputState == Enum.UserInputState.Begin then
				altpressed = true
			else
				altpressed = false
			end
		elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			if input.UserInputState == Enum.UserInputState.Begin then
				shiftpressed = true
			else
				shiftpressed = false
			end
		elseif input.KeyCode == Enum.KeyCode.R and ctrlpressed then
			if startbutton7 then
				startbutton7:Destroy()
			end
			if taskbarholder then
				taskbarholder:Destroy()
			end

			for i, window in pairs(windows) do
				if window.FunctionsTable then
					window.FunctionsTable:Close()
				end
			end

			windows = {}

			if programholder1 then
				programholder1:Destroy()
			end

			if mainframe then
				mainframe:Destroy()
			end

			if resolutionframe then
				resolutionframe:Destroy()
			end
			loaddesktop()
		elseif input.KeyCode == Enum.KeyCode.Q and ctrlpressed then
			for i, window in pairs(windows) do
				if typeof(window) ~= "table" then continue end

				if not window.Focused then continue end

				window.FunctionsTable:Close()
				break
			end
		elseif input.KeyCode == Enum.KeyCode.M and ctrlpressed then

			for i, window in pairs(windows) do
				if typeof(window) ~= "table" then continue end
				if window.FunctionsTable then
					window.FunctionsTable:Minimize()
				end
			end
		elseif input.KeyCode == Enum.KeyCode.W then
			if ctrlpressed and shiftpressed and altpressed then
				if screen:GetFocusedTextBox() then return end
				windowsmanager()
				return
			end
		end
	end)

	local taskbarheight = mainframe.AbsoluteSize.Y*0.1
	taskbarholder = screen:CreateElement("ImageButton", {Image = "rbxassetid://15619032563", Position = UDim2.new(0, 0, 0.9, 0), Size = UDim2.new(1, 0, 0, taskbarheight), BackgroundTransparency = 1, ImageTransparency = 0.25, ZIndex = 2})
	taskbarholder.Parent = mainframe
	startbutton7 = screen:CreateElement("ImageButton", {Image = "rbxassetid://15617867263", BackgroundTransparency = 1, Size = UDim2.new(0, taskbarheight, 1, 0), Position = UDim2.new(0, 0, 0, 0)})
	local textlabel = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = "G", TextScaled = true, TextWrapped = true})
	textlabel.Parent = startbutton7
	local speakerbutton = screen:CreateElement("ImageButton", {Size = startbutton7.Size, Position = UDim2.new(1, -smallestaxis*0.1, 0, 0), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, Image = "rbxassetid://13771136869"})
	if math.ceil(speaker.Volume) == 0 then
		speakerbutton.Image = "rbxassetid://13771148216"
	end
	speakerbutton.Parent = taskbarholder

	programholder1 = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
	programholder1.Parent = mainframe
	programholder2 = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
	programholder2.Parent = programholder1
	startbutton7.Parent = taskbarholder

	taskbarholderscrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, -taskbarheight*2, 1, 0), BackgroundTransparency = 1, CanvasSize = UDim2.new(1, -taskbarheight*2, 1, 0), Position = UDim2.new(0, taskbarheight, 0, 0), ScrollBarThickness = 2.5, Active = true, ScrollingDirection = Enum.ScrollingDirection.X})
	taskbarholderscrollingframe.Parent = taskbarholder

	if not disk:Read("sounds") and not disk:Read("Desktop") then
		local window, holderframe, closebutton, maximize, textlabel, resize, minimize, funcs = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Welcome to GustavOS", false, false, false, "Welcome", false)
		local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,0,0.8,0), Position = UDim2.new(0, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Would you like to add some sounds to the hard drive?", BackgroundTransparency = 1})
		textlabel.Parent = window
		local yes = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0, 0, 0.8, 0), "Yes", window)
		local no = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0.5, 0, 0.8, 0), "No", window)

		no.MouseButton1Up:Connect(function()
			funcs:Close()
		end)

		yes.MouseButton1Up:Connect(function()
			disk:Read("sounds")
			disk:Write("sounds", {
				["quiz.aud"] = "9042796147 length:197.982",
				["meltdown.aud"] = "1845092181",
				["Synthwar.aud"] = "4580911200",
				["SynthBetter.aud"] = "4580911200 pitch:1.15",
				["DISTANT.aud"] = "4611202823 pitch:1.15",
				["blade.aud"] = "10951049295",
				["Climber.aud"] = "10951047950",
				["tune.aud"] = "1846897737",
				["Synthwar-remix.aud"] = "9223412780",
				["Wasting-Space.aud"] = "4715885427",
				["Mobius.aud"] = "10951050091",
				["Productive.aud"] = "10951166364",
				["Landing.aud"] = "10951045010",
				["Travel.aud"] = "10951043922",
				["Solar-wind.aud"] = "8887201925",
				["4th-axis.aud"] = "8909965418",
			})
			funcs:Close()
		end)
	end

	local volumeframe

	local function togglevolumeframe()
		if volumeframe then
			volumeframe:Destroy()
			volumeframe = nil
		else
			volumeframe = screen:CreateElement("ImageLabel", {
				Size = UDim2.fromScale(3, 3),
				Position = UDim2.fromScale(-2, -3),
				BackgroundTransparency = 1,
				ImageTransparency = 0.2,
				Image = "rbxassetid://8677487226",
			})
			local plus = createnicebutton(UDim2.fromScale(1, 1/3), UDim2.fromScale(0, 0), "+", volumeframe)
			local minus = createnicebutton(UDim2.fromScale(1, 1/3), UDim2.fromScale(0, 2/3), "-", volumeframe)
			local curvolume = Instance.new("TextLabel")
			curvolume.Text = math.round(speaker.Volume*100)/100
			curvolume.Size = UDim2.fromScale(1, 1/3)
			curvolume.Position = UDim2.fromScale(0, 1/3)
			curvolume.BackgroundTransparency = 0
			curvolume.TextScaled = true
			curvolume.BackgroundTransparency = 1
			curvolume.Parent = volumeframe

			plus.MouseButton1Up:Connect(function()
				speaker.Volume = math.min(speaker.Volume + 0.1, 2)
				curvolume.Text = math.round(speaker.Volume*100)/100
				speakerbutton.Image = "rbxassetid://13771136869"
			end)

			minus.MouseButton1Up:Connect(function()
				local newvolume = math.max(speaker.Volume - 0.1, 0)
				speaker.Volume = newvolume
				curvolume.Text = math.round(newvolume*100)/100
				if newvolume == 0 then
					speakerbutton.Image = "rbxassetid://13771148216"
				end
			end)

			volumeframe.Parent = speakerbutton
		end
	end

	speakerbutton.MouseButton1Up:Connect(togglevolumeframe)

	if not iconsdisabled then
		pcall(loaddesktopicons)
	end

	local startmenu
	function openstartmenu(object, func)
		if not startmenu then
			startmenu = screen:CreateElement("ImageButton", {BackgroundTransparency = 1, Image = "rbxassetid://15619032563", Size = UDim2.new(0.3, 0, 5, 0), Position = UDim2.new(0, 0, -5, 0), ImageTransparency = 0.2})
			if not object then
				startmenu.Parent = taskbarholder
			elseif typeof(object) == "Instance" then
				startmenu.Parent = object
			end
			local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1,0,0.8,0), CanvasSize = UDim2.new(1, 0, 2.6, 0), BackgroundTransparency = 1, ScrollBarThickness = 5, Active = true})
			scrollingframe.Parent = startmenu
			local buttons = {
				{Text = "Settings", Function = function()
				    startmenu:Destroy()
					settings()

					if func then
						func("settings")
					end
				end},
				{Text = "Create/Overwrite file", Function = function()
				    startmenu:Destroy()
					writedisk()
					pressed = false

					if func then
						func("writedisk")
					end
				end},
				{Text = "Files", Function = function()
				    startmenu:Destroy()
					loaddisk("/", true)


					if func then
						func("loaddisk")
					end
				end},
				{Text = "Lua executor", Function = function()
				    startmenu:Destroy()
					customprogramthing(screen, {})


					if func then
						func("customprogramthing")
					end
				end},
				{Text = "Mediaplayer", Function = function()
				    startmenu:Destroy()
					mediaplayer()


					if func then
						func("mediaplayer")
					end
				end},
				{Text = "Chat", Function = function()
				    startmenu:Destroy()
					chatthing()


					if func then
						func("chatthing")
					end
				end},
				{Text = "Calculator", Function = function()
				    startmenu:Destroy()
					calculator()


					if func then
						func("calculator")
					end
				end},
				{Text = "Terminal", Function = function()
				    startmenu:Destroy()
					terminal()


					if func then
						func("terminal")
					end
				end},
				{Text = "Copy File", Function = function()
				    startmenu:Destroy()
					copyfile()


					if func then
						func("copyfile")
					end
				end},
				{Text = "Rename File", Function = function()
				    startmenu:Destroy()
					renamefile()


					if func then
						func("renamefile")
					end
				end},
				{Text = "Create Shortcut", Function = function()
				    startmenu:Destroy()
					createshortcut()


					if func then
						func("createshortcut")
					end
				end},
				{Text = "Move File", Function = function()
				    startmenu:Destroy()
					movefile()


					if func then
						func("movefile")
					end
				end},
			}

			local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1,0,0.8,0), CanvasSize = UDim2.new(1, 0, 0.2*#buttons, 0), BackgroundTransparency = 1, ScrollBarThickness = 5, Active = true})
			scrollingframe.Parent = startmenu

			for i, t in ipairs(buttons) do
				local button = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.fromScale(0, (0.2/scrollingframe.CanvasSize.Y.Scale)*(i-1)), t.Text, scrollingframe)
				button.MouseButton1Up:Connect(t.Function)
			end

			local shutdown = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0, 0, 0.8, 0), "Shutdown", startmenu)
			shutdown.MouseButton1Up:Connect(function()

				startmenu:Destroy()
				shutdownprompt()

				if func then
					func("shutdown")
				end
			end)

			local restart = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0.5, 0, 0.8, 0), "Reboot", startmenu)
			restart.MouseButton1Up:Connect(function()

				startmenu:Destroy()
				restartprompt()

				if func then
					func("reboot")
				end
			end)
			pressed = true
		else
			pcall(startmenu.Destroy, startmenu)
			startmenu = nil

		end

		return startmenu
	end

	startbutton7.MouseButton1Down:Connect(function()
		startbutton7.Image = "rbxassetid://15617867263"
		buttondown = true
	end)
	startbutton7.MouseButton1Up:Connect(function()
		startbutton7.Image = "rbxassetid://15617866125"
		buttondown = false
		openstartmenu()
		speaker:PlaySound(clicksound)
	end)
	cursorevent = screen.CursorMoved:Connect(function(cursor)
		if screen then
			if startbutton7 then
				local cursors = screen:GetCursors()
				local success = false
				if not buttondown then
					for index,cur in pairs(cursors) do
						if typeof(cur) ~= "table" then return end
						local boolean, x_Axis, y_Axis = getCursorColliding(cur.X, cur.Y, startbutton7)
						if boolean then
							startbutton7.Image = "rbxassetid://15617866125"
							success = true
							break
						end
					end
					if not success then
						startbutton7.Image = "rbxassetid://15617867263"
					end
				end
			end
			if holding2 then
				local cursors = screen:GetCursors()
				local cursor
				local x_axis
				local y_axis
				if not startCursorPos["Player"] then return end
				for index,cur in pairs(cursors) do
					if startCursorPos and cur then
						if not cur["Player"] then return end
						if cur.Player == startCursorPos.Player then
							cursor = cur
							break
						end
					end
				end
				if not cursor then holding2 = false end
				if cursor then
					local screenresolution = resolutionframe.AbsoluteSize
					local startCursorPos = startCursorPos
					if typeof(cursor["X"]) == "number" and typeof(cursor["Y"]) == "number" and typeof(screenresolution["X"]) == "number" and typeof(screenresolution["Y"]) == "number" and typeof(startCursorPos["X"]) == "number" and typeof(startCursorPos["Y"]) == "number" then
						local newX = uiStartPos.X.Scale - (startCursorPos.X - cursor.X)/screenresolution.X
						local newY = uiStartPos.Y.Scale - (startCursorPos.Y - cursor.Y)/screenresolution.Y
						if newY + 0.1 > 0.9 then
							newY = 0.8
						end
						if holderframetouse then
							holderframetouse.Position = UDim2.fromScale(newX, newY)
						else
							holding2 = false
						end
					end
				end
			end

			if holding then
				if not holderframetouse then holding = false; return end
				if not resizebuttontouse then holding = false; return end
				local cursors = screen:GetCursors()
				local cursor
				for index,cur in pairs(cursors) do
					if startCursorPos and cur then
						if not cur["Player"] then return end
						if cur.Player == startCursorPos.Player then
							cursor = cur
						end
					end
				end
				if not cursor then holding = false end
				if cursor then
					local newX = (cursor.X - holderframetouse.AbsolutePosition.X) + (resizebuttontouse.AbsoluteSize.X/2) + ((holderframetouse.AbsolutePosition.X + holderframetouse.AbsoluteSize.X) - (resizebuttontouse.AbsolutePosition.X + resizebuttontouse.AbsoluteSize.X))
					local newY = (cursor.Y - holderframetouse.AbsolutePosition.Y) + (resizebuttontouse.AbsoluteSize.Y/2) + ((holderframetouse.AbsolutePosition.Y + holderframetouse.AbsoluteSize.Y) - (resizebuttontouse.AbsolutePosition.Y + resizebuttontouse.AbsoluteSize.Y))
					local screenresolution = resolutionframe.AbsoluteSize

					if typeof(cursor["X"]) == "number" and typeof(cursor["Y"]) == "number" and typeof(screenresolution["X"]) == "number" and typeof(screenresolution["Y"]) == "number" and typeof(startCursorPos["X"]) == "number" and typeof(startCursorPos["Y"]) == "number" then
						if newX < defaultbuttonsize.X*4 then newX = defaultbuttonsize.X*4 end
						if newY < defaultbuttonsize.Y*4 then newY = defaultbuttonsize.Y*4 end
						if newX/screenresolution.X > 1 then newX = screenresolution.X end
						if newY/screenresolution.Y > 0.9 then newY = screenresolution.Y * 0.9 end
						if holderframetouse then
							holderframetouse.Size = UDim2.fromScale(newX/screenresolution.X, newY/screenresolution.Y)
						end
					end
				end
			end
		end
		if not players[cursor.Player] then
			local a = screen:CreateElement("ImageLabel", {ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5, 0.5), Image = "rbxassetid://8679825641", BackgroundTransparency = 1, Size = UDim2.fromOffset(smallestaxis*0.1, smallestaxis*0.1), Position = UDim2.fromScale(0.5, 0.5), ZIndex = (2^31)-2})
			local b = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(1.5, 0.25), Position = UDim2.fromScale(-0.25, 1), BackgroundTransparency = 1, TextScaled = true, Text = tostring(cursor.Player), TextStrokeTransparency = 0, TextStrokeColor3 = Color3.new(1, 1, 1)})
			b.Parent = a

			players[cursor.Player] = {tick(), a}
		end
		players[cursor.Player][2].Position = UDim2.fromOffset(cursor.X, cursor.Y)
		players[cursor.Player][1] = tick()
	end)
end

function loadingscreen(boolean1, boolean2)
	screen:ClearElements()

	if restartkey then restartkey:Disconnect() end

	local wallpaper = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), Image = "rbxassetid://"..tostring(disk:Read("LoadingImage") or 16204218577), BackgroundTransparency = 1})
	local spinner = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(0.1, 0.1), Position = UDim2.fromScale(0.7, 0.4), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, Image = "rbxassetid://16204406408"})
	spinner.Parent = wallpaper

	local textlabel = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(0.4, 0.1), Position = UDim2.fromScale(0.3, 0.4), BackgroundTransparency = 1, TextScaled = true, TextColor3 = Color3.new(1,1,1), Text = if not boolean1 then "Welcome" elseif not boolean2 then "Restarting" elseif boolean2 then "Shutting down" else "how the hell", TextWrapped = true, TextStrokeColor3 = Color3.new(0,0,0), TextStrokeTransparency = 0.25})
	textlabel.Parent = wallpaper

	local coroutine1 = coroutine.create(function()
		while true do
			task.wait(0.01)
			spinner.Rotation += 4
		end
	end)

	coroutine.resume(coroutine1)

	if boolean1 then
		stopprograms()
	end

	task.wait(3)

	coroutine.close(coroutine1)

	wallpaper:Destroy()

	if not boolean1 then
		local blackframe = screen:CreateElement("TextButton", {ZIndex = 10, Text = "", TextTransparency = 1, BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1), AutoButtonColor = false})
		task.spawn(function()
			if speaker:IsDestroyed() then return end
			local sound = speaker:LoadSound(`rbxassetid://{startsound}`)
			sound.Volume = 1
			sound:Play()

			task.wait(3)
			sound:Destroy()
		end)
		task.spawn(function()
			for i=0, 1, 0.01 do
				task.wait(0.01)
				blackframe.BackgroundTransparency = i
			end
			blackframe:Destroy()
		end)
		loaddesktop()
	else
		if boolean2 then
			speaker:ClearSounds()
			shutdownnow()
		else
			speaker:ClearSounds()
			restartnow()
		end
	end
end

function bootos()
	if disks and #disks > 0 then
		print(`{romport}\\{disksport}`)
		if romport ~= disksport then
			local indexusing1

			for i,v in ipairs(disks) do
				if rom ~= v then
					disk = v
					indexusing1 = i

					if v:Read("BackgroundImage") then
						break
					end
				end
			end

			local diskstable2 = {
				[1] = disk
			}

			for i, v in ipairs(disks) do
				if i ~= indexusing1 then
					table.insert(diskstable2, v)
				end
			end

			disks = diskstable2
		else
			local diskstable = {}

			for i, v in ipairs(disks) do
				if rom ~= v and i ~= romindexusing then
					table.insert(diskstable, v)
				end
			end

			disks = diskstable

			local indexusing1

			for i, v in ipairs(disks) do
				disk = v
				indexusing1 = i

				if v:Read("BackgroundImage") then
					break
				end
			end

			local diskstable2 = {
				[1] = disk
			}

			for i, v in ipairs(disks) do
				if i ~= indexusing1 then
					table.insert(diskstable2, v)
				end
			end

			disks = diskstable2
		end
	end
	if screen and keyboard and speaker and disk and rom then
		prevprompt = nil
		rom:Write("SysDisk")
		speaker:ClearSounds()
		screen:ClearElements()
		local commandlines = commandline.new(false, nil, screen)
		commandlines:insert(name.." Command line")
		task.wait(1)
		commandlines:insert("Welcome")
		task.wait(2)
		screen:ClearElements()

		if disk then
			clicksound = rom:Read("ClickSound")
			shutdownsound = rom:Read("ShutdownSound")
			startsound = rom:Read("StartSound")
			if not clicksound then clicksound = "rbxassetid://6977010128"; else clicksound = "rbxassetid://"..tostring(clicksound); end
			if not startsound then startsound = 182007357; end
			if not shutdownsound then shutdownsound = 7762841318; end
			color = disk:Read("BackgroundColor")
			if rom:Read("Disabled") == nil then
				rom:Write("Disabled", false)
			end
			iconsdisabled = rom:Read("Disabled")

			if typeof(iconsdisabled) == "string" then
				iconsdisabled = iconsdisabled:lower()
			end

			if iconsdisabled == "true" then
				iconsdisabled = true
			elseif typeof(iconsdisabled) == "string" then
				iconsdisabled = false
			end

			windows = {}

			stopprograms()

			iconsize = rom:Read("IconSize")
			iconsize = tonumber(iconsize) or 0.2
			if not color then color = disk:Read("Color") end
			if not disk:Read("BackgroundImage") then disk:Write("BackgroundImage", "15705296956,false") end
			local diskbackgroundimage = disk:Read("BackgroundImage")
			if color then
				color = string.split(color, ",")
				if color then
					if tonumber(color[1]) and tonumber(color[2]) and tonumber(color[3]) then
						color = Color3.fromRGB(tonumber(color[1]), tonumber(color[2]), tonumber(color[3]))
					else
						color = Color3.fromRGB(0, 128, 218)
					end
				else
					color = Color3.fromRGB(0, 128, 218)
				end
			else
				color = Color3.fromRGB(0, 128, 218)
			end

			if diskbackgroundimage then
				local idandbool = string.split(diskbackgroundimage, ",")
				if tonumber(idandbool[1]) then
					backgroundimage = "rbxthumb://type=Asset&id="..tonumber(idandbool[1]).."&w=420&h=420"
					if idandbool[2] == "true" then
						tile = true
					else
						tile = false
					end
					if tonumber(idandbool[3]) and tonumber(idandbool[4]) and tonumber(idandbool[5]) and tonumber(idandbool[6]) then
						tilesize = UDim2.new(tonumber(idandbool[3]), tonumber(idandbool[4]), tonumber(idandbool[5]), tonumber(idandbool[6]))
					end
				else
					backgroundimage = nil
				end
			else
				backgroundimage = nil
			end
		end
		smallestaxis = math.min(screen:GetDimensions().X, screen:GetDimensions().Y)
		defaultbuttonsize = Vector2.new(smallestaxis*0.14, smallestaxis*0.1)
		if defaultbuttonsize.X > 35 then defaultbuttonsize = Vector2.new(35, defaultbuttonsize.Y); end
		if defaultbuttonsize.Y > 25 then defaultbuttonsize = Vector2.new(defaultbuttonsize.X, 25); end

		loadingscreen(false)
		if keyboardevent then keyboardevent:Disconnect() end
		keyboardevent = keyboard.TextInputted:Connect(function(text, player)
			keyboardinput = text
			playerthatinputted = player
		end)

	elseif not screen and regularscreen then
		regularscreen:ClearElements()
		local commandlines = commandline.new(false, nil, regularscreen)
		commandlines:insert(name.." Command line")
		task.wait(1)
		commandlines:insert("Regular screen is not supported.")
		if not speaker then
			commandlines:insert("No speaker was found.")
		end
		task.wait(1)
		if not keyboard then
			commandlines:insert("No keyboard was found.")
		end
		task.wait(1)
		if not disk then
			commandlines:insert("You need 2 or more disks, 2 or more ports must not be connected to the same disks.")
		end
		if not rom then
			commandlines:insert([[No empty disk or disk with the file "SysDisk" was found.]])
		end
		if keyboard then
			local keyboardevent = keyboard.KeyPressed:Connect(function(key)
				if key == Enum.KeyCode.Return then
					getstuff()
					bootos()
					keyboardevent:Disconnect()
				end
			end)
		end
	elseif screen then
		screen:ClearElements()
		local commandlines = commandline.new(false, nil, screen)
		commandlines:insert(name.." Command line")
		task.wait(1)
		if not speaker then
			commandlines:insert("No speaker was found.")
		end
		task.wait(1)
		if not keyboard then
			commandlines:insert("No keyboard was found.")
		end
		task.wait(1)
		if not disk then
			commandlines:insert("You need 2 or more disks, 2 or more ports must not be connected to the same disks.")
		end
		if not rom then
			commandlines:insert([[No empty disk or disk with the file "SysDisk" was found.]])
		end
		if keyboard then
			local keyboardevent = keyboard.KeyPressed:Connect(function(key)
				if key == Enum.KeyCode.Return then
					getstuff()
					bootos()
					keyboardevent:Disconnect()
				end
			end)
		end
	elseif not regularscreen and not screen then
		Beep(0.5)
		print("No screen was found.")
		if keyboard then
			local keyboardevent = keyboard.KeyPressed:Connect(function(key)
				if key == Enum.KeyCode.Return then
					getstuff()
					bootos()
					keyboardevent:Disconnect()
				end
			end)
		end
	end
end
bootos()

while true do
	task.wait(2)
	if players then
		for i,v in pairs(players) do
			if tick() - v[1] > 0.5 then
				v[2]:Destroy()
				players[i] = nil
			end
		end
    end
    if startCursorPos and not screen:GetCursors()[startCursorPos] then
        holding2 = false
        holding = false
    end
end










