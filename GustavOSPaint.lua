--GustavOS Paint
--a
--a
--a
--a
--a
--a
--a
--made by Gustavo12345687890

local disk = GetPartFromPort(1, "Disk")
local gputer = disk:Read("GD7Library")()
local filesystem = gputer.filesystem
local speaker = gputer.Speaker
local keyboard = gputer.Keyboard
local clicksound = "rbxassetid://"..(disk:Read("ClickSound") or "rbxassetid://6977010128")

local keyboardevent
local keyboardinput

local window, holderframe, closebutton, maximizebutton, textlabel, resizebutton, minimizebutton, functions = gputer.CreateWindow(UDim2.fromScale(0.7, 0.7), "GustavOS Paint", false, false, false, "Paint", false)

local screen = gputer.Screen

local function createnicebutton(udim2, pos, text, Parent)
	local txtbutton = screen:CreateElement("ImageButton", {Size = udim2, Image = "rbxassetid://15625805900", Position = pos, BackgroundTransparency = 1})
	local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(text), RichText = true})
	txtbutton:AddChild(txtlabel)
	if Parent then
		Parent:AddChild(txtbutton)
	end
	return txtbutton, txtlabel
end

local colorbutton, text1 = createnicebutton(UDim2.fromScale(0.5, 0.1), UDim2.fromScale(0, 0), "Primary Color", window)
local colorbutton2, text2 = createnicebutton(UDim2.fromScale(0.5, 0.1), UDim2.fromScale(0.5, 0), "Secondary Color", window)

local canOpen = true

local funcs

local resx = 20
local resy = 20

local pencilerasersize = 1

local function getCursorColliding(X, Y, ui)
	if X and Y and ui then else return end
	X -= pencilerasersize/2
	Y -= pencilerasersize/2
	local x = ui.AbsolutePosition.X
	local y = ui.AbsolutePosition.Y
	local y_axis = nil
	local x_axis = nil
	local guiposx = X + pencilerasersize
	local number = ui.AbsoluteSize.X + pencilerasersize

	if x - guiposx > -number then
		if x - guiposx < 0 then
			x_axis = X - guiposx
		end
	end

	local guiposy = Y + pencilerasersize
	local number2 = ui.AbsoluteSize.Y + pencilerasersize

	if y - guiposy > -number2 then
		if y - guiposy < 0 then
			y_axis = y - guiposy
		end
	end

	if x_axis and y_axis then
		return true, x_axis, y_axis
	end
end

local function getCursorCollidingCopy(X, Y, ui)
	if X and Y and ui then else return end
	local x = ui.AbsolutePosition.X
	local y = ui.AbsolutePosition.Y
	local y_axis = nil
	local x_axis = nil
	local guiposx = X
	local number = ui.AbsoluteSize.X

	if x - guiposx > -number then
		if x - guiposx < 0 then
			x_axis = X - guiposx
		end
	end

	local guiposy = Y
	local number2 = ui.AbsoluteSize.Y

	if y - guiposy > -number2 then
		if y - guiposy < 0 then
			y_axis = y - guiposy
		end
	end

	if x_axis and y_axis then
		return true, x_axis, y_axis
	end
end

local selectedcolor = BrickColor.new("Really black").Color
local selectedcolor2 = BrickColor.new("Institutional white").Color

local brickcolorpallete = {}

local brickcolornames = {}

for i=1, 1032 do
	local brickcolor = BrickColor.new(i)

	if brickcolor.Name ~= "Medium stone grey" or i == 194 then
		table.insert(brickcolorpallete, brickcolor.Color)
		table.insert(brickcolornames, brickcolor.Name)
	end
end


local function open(mode)
	local window, holderframe, closebutton, maximizebutton, textlabel, resizebutton, minimizebutton, functions = gputer.CreateWindow(UDim2.fromScale(0.3, 0.5), "Color Selector", true, true, false, nil, true)

	funcs = functions

	window.ScrollBarThickness = 5

	local x = 0
	local y = 0

	for i, color in ipairs(brickcolorpallete) do
		x += 0.1

		if x > 0.9 then
			x = 0
			y += 0.1

			if y > 0.9 then
				window.CanvasSize += UDim2.fromScale(0, 0.1)
			end

		end
	end

	closebutton.MouseButton1Up:Connect(function()
		if mode == 1 then
			colorbutton.Image = "rbxassetid://15625805900"
		else
			colorbutton2.Image = "rbxassetid://15625805900"
		end
	end)

	x = 0
	y = 0

	for i, color in ipairs(brickcolorpallete) do
		local button = functions:CreateElement("TextButton", {TextTransparency = 1, BackgroundColor3 = color, Size = UDim2.fromScale(0.1, 0.1/window.CanvasSize.Y.Scale), Position = UDim2.fromScale(x, y/window.CanvasSize.Y.Scale)})

		if color == selectedcolor and mode == 1 then
			button.BorderColor3 = Color3.new(0, 1, 0)
			button.ZIndex = 2
		end

		if color == selectedcolor2 and mode == 2 then
			button.BorderColor3 = Color3.new(0, 1, 0)
			button.ZIndex = 2
		end

		if (mode == 1 and color ~= selectedcolor) or (mode == 2 and color ~= selectedcolor2) then
			button.BorderSizePixel = 0
		end

		x += 0.1

		if x > 0.9 then
			x = 0
			y += 0.1
		end

		button.MouseButton1Up:Connect(function()
			speaker:PlaySound(clicksound)
			functions:Close()
			canOpen = true
			if mode == 1 then
				selectedcolor = color
				text1.Text = brickcolornames[i]
				colorbutton.Image = "rbxassetid://15625805900"
			elseif mode == 2 then
				selectedcolor2 = color
				text2.Text = brickcolornames[i]
				colorbutton2.Image = "rbxassetid://15625805900"
			end
		end)
	end
end

colorbutton.MouseButton1Up:Connect(function()
	speaker:PlaySound(clicksound)
	if canOpen then
		colorbutton.Image = "rbxassetid://15625805069"
		canOpen = false

		open(1)
	else
		if funcs then
			if funcs:IsClosed() then
				colorbutton.Image = "rbxassetid://15625805069"
				open(1)
			end
		end
	end
end)

colorbutton2.MouseButton1Up:Connect(function()
	speaker:PlaySound(clicksound)
	if canOpen then
		colorbutton2.Image = "rbxassetid://15625805069"
		canOpen = false

		open(2)
	else
		if funcs then
			if funcs:IsClosed() then
				colorbutton2.Image = "rbxassetid://15625805069"
				open(2)
			end
		end
	end
end)

local painting = functions:CreateElement("TextButton", {TextTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(0.8, 0.8), Position = UDim2.fromScale(0.1, 0.1), BackgroundColor3 = Color3.fromRGB(200, 200, 200)})

local pressed = false

painting.MouseButton1Down:Connect(function()
	pressed = true
end)

painting.MouseButton1Up:Connect(function()
	pressed = false
end)

local colorblocks = {}

local x = 0
local y = 0

local blocksizexy = Vector2.new(0, 0)
local isset = false

local total = math.round(resx*resy)

for i=1, total do
	local colorblock = gputer.Screen:CreateElement("Frame", {BorderSizePixel = 0, BackgroundColor3 = selectedcolor2, Size = UDim2.fromScale(1/resx, 1/resy), Position = UDim2.fromScale(x, y)})

	painting:AddChild(colorblock)

	if not isset then
		blocksizexy = colorblock.AbsoluteSize
		isset = true
	end

	x += 1/resx

	if x >= 1 then
		x = 0
		y += 1/resy
	end

	table.insert(colorblocks, colorblock)
end

local function load(filename, dir)
	local file = filesystem.Read(filename, dir)

	if typeof(file) == "string" then
		local split = string.split(file, ",")

		local data = {}

		for i, val in ipairs(split) do
			data[#data+1] = tonumber(val)
		end

		return data
	end
end

local function save(filename, data, dir)
	if typeof(data) == "table" then
		local newtext = ""

		for i, val in ipairs(data) do
			if newtext == "" then
				newtext = val
			else
				newtext = newtext..","..val
			end
		end

		return filesystem.Write(filename, newtext, dir), newtext
	end
end

local function savegui()
	local window, holderframe, closebutton, maximizebutton, textlabel, resizebutton, minimizebutton, functions = gputer.CreateWindow(UDim2.fromScale(0.7, 0.7), "Save", false, false, false, nil, true)

	local directory = "/"
	local filename = ""

	local namebutton, nametext = gputer.createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0), "Enter filename here", window)
	local dirbutton, dirtext = gputer.createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.2), "Select directory", window)
	local rkebutton = gputer.createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.6), "Reset Keyboard Event", window)
	local savebutton, savetext = gputer.createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.8), "Save", window)

	rkebutton.MouseButton1Up:Connect(function()
		if keyboardevent then keyboardevent:Unbind() end

		keyboardevent = keyboard:Connect("TextInputted", function(text)
			keyboardinput = text:gsub("\n", ""):gsub("/", "")
		end)
	end)

	namebutton.MouseButton1Up:Connect(function()
		if not keyboardinput then return end

		filename = keyboardinput
		nametext.Text = filename
	end)

	dirbutton.MouseButton1Up:Connect(function()
		gputer.FileExplorer(directory, function(name, dir)
			if dir == "/" and name == "" then
				directory = dir
				dirtext.Text = directory
			elseif typeof(filesystem.Read(name, dir)) == "table" then
				directory = if dir == "/" then "/"..name else dir.."/"..name
				dirtext.Text = directory
			elseif dir ~= directory then
				dirtext.Text = "The selected folder/table is not a valid folder/table."
				task.wait(2)
				dirtext.Text = "Select directory"
			end
		end, true)
	end)

	savebutton.MouseButton1Up:Connect(function()
		if filename ~= "" then
			local data = {}

			for i, block in ipairs(colorblocks) do
				local blockindex = table.find(brickcolorpallete, block.BackgroundColor3)

				if blockindex then
					data[#data + 1] = blockindex
				end
			end
			local text1, text2 = save(filename, data, directory)

			savetext.Text = text2
			
			task.wait(2)
			savetext.Text = "Save"
		end
	end)
end

local mode = 0

local eraserbutton = createnicebutton(UDim2.fromScale(0.1, 0.1), UDim2.fromScale(0, 0.4), "", window)
local pencilbutton = createnicebutton(UDim2.fromScale(0.1, 0.1), UDim2.fromScale(0, 0.3), "", window)
local copybutton = createnicebutton(UDim2.fromScale(0.1, 0.1), UDim2.fromScale(0, 0.1), "", window)
local copybutton2 = createnicebutton(UDim2.fromScale(0.1, 0.1), UDim2.fromScale(0.9, 0.1), "", window)
local paintbutton = createnicebutton(UDim2.fromScale(0.1, 0.1), UDim2.fromScale(0, 0.2), "", window)
local paintbutton2 = createnicebutton(UDim2.fromScale(0.1, 0.1), UDim2.fromScale(0.9, 0.2), "", window)
--local savebutton = gputer.createnicebutton(UDim2.fromScale(0.1, 0.1), UDim2.fromScale(0.9, 0.2), "", window)

local eraserimage = gputer.Screen:CreateElement("ImageLabel", {Image = "rbxassetid://16821121269", Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1})
local pencilimage = gputer.Screen:CreateElement("ImageLabel", {Image = "rbxassetid://16821120420", Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1})
local copyimage = gputer.Screen:CreateElement("ImageLabel", {Image = "rbxassetid://16833148719", Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1})
local paintimage = gputer.Screen:CreateElement("ImageLabel", {Image = "rbxassetid://16869921844", Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1})
local paintimage2 = gputer.Screen:CreateElement("ImageLabel", {Image = "rbxassetid://16869921844", Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1})
local copyimage2 = gputer.Screen:CreateElement("ImageLabel", {Image = "rbxassetid://16833148719", Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1})
--local saveimage = gputer.Screen:CreateElement("ImageLabel", {Image = "rbxassetid://16827485976", Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1})

local sizetext = functions:CreateElement("TextLabel", {Size = UDim2.fromScale(0.1, 0.1), Position = UDim2.fromScale(0, 0.7), BackgroundTransparency = 1, Text = 1, TextScaled = true, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.new(1, 1, 1)})
local increasebutton = gputer.createnicebutton(UDim2.fromScale(0.1, 0.1), UDim2.fromScale(0, 0.8), "+", window)
local descreasebutton = gputer.createnicebutton(UDim2.fromScale(0.1, 0.1), UDim2.fromScale(0, 0.6), "-", window)

local number = 1

pencilerasersize = number*(((blocksizexy.X*blocksizexy.Y)^0.5)/2)

increasebutton.MouseButton1Up:Connect(function()
	if number < 10 then
		number += 1

		sizetext.Text = number

		pencilerasersize = number*(((blocksizexy.X*blocksizexy.Y)^0.5)/2)
	end
end)

descreasebutton.MouseButton1Up:Connect(function()
	if number > 1 then
		number -= 1

		sizetext.Text = number

		pencilerasersize = number*(((blocksizexy.X*blocksizexy.Y)^0.5)/2)
	end
end)

eraserbutton:AddChild(eraserimage)
pencilbutton:AddChild(pencilimage)
copybutton:AddChild(copyimage)
copybutton2:AddChild(copyimage2)
paintbutton:AddChild(paintimage)
paintbutton2:AddChild(paintimage2)
--savebutton:AddChild(saveimage)

eraserbutton.MouseButton1Up:Connect(function()
	speaker:PlaySound(clicksound)
	if mode ~= 2 then
		eraserbutton.Image = "rbxassetid://15625805069"
		copybutton2.Image = "rbxassetid://15625805900"
		paintbutton2.Image = "rbxassetid://15625805069"
		paintbutton.Image = "rbxassetid://15625805069"
		copybutton.Image = "rbxassetid://15625805900"
		pencilbutton.Image = "rbxassetid://15625805900"
		mode = 2
	else
		eraserbutton.Image = "rbxassetid://15625805900"
		mode = 0
	end
end)

paintbutton.MouseButton1Up:Connect(function()
	speaker:PlaySound(clicksound)
	if mode ~= 5 then
		paintbutton.Image = "rbxassetid://15625805069"
		eraserbutton.Image = "rbxassetid://15625805900"
		paintbutton2.Image = "rbxassetid://15625805900"
		copybutton2.Image = "rbxassetid://15625805900"
		copybutton.Image = "rbxassetid://15625805900"
		pencilbutton.Image = "rbxassetid://15625805900"
		mode = 5
	else
		eraserbutton.Image = "rbxassetid://15625805900"
		mode = 0
	end
end)

paintbutton2.MouseButton1Up:Connect(function()
	speaker:PlaySound(clicksound)
	if mode ~= 6 then
		paintbutton2.Image = "rbxassetid://15625805069"
		eraserbutton.Image = "rbxassetid://15625805900"
		paintbutton.Image = "rbxassetid://15625805900"
		copybutton2.Image = "rbxassetid://15625805900"
		copybutton.Image = "rbxassetid://15625805900"
		pencilbutton.Image = "rbxassetid://15625805900"
		mode = 6
	else
		eraserbutton.Image = "rbxassetid://15625805900"
		mode = 0
	end
end)

copybutton.MouseButton1Up:Connect(function()
	speaker:PlaySound(clicksound)
	if mode ~= 3 then
		copybutton.Image = "rbxassetid://15625805069"
		pencilbutton.Image = "rbxassetid://15625805900"
		paintbutton2.Image = "rbxassetid://15625805069"
		paintbutton.Image = "rbxassetid://15625805069"
		copybutton2.Image = "rbxassetid://15625805900"
		eraserbutton.Image = "rbxassetid://15625805900"
		mode = 3
	else
		copybutton.Image = "rbxassetid://15625805900"
		mode = 0
	end
end)

copybutton2.MouseButton1Up:Connect(function()
	speaker:PlaySound(clicksound)
	if mode ~= 4 then
		copybutton2.Image = "rbxassetid://15625805069"
		copybutton.Image = "rbxassetid://15625805900"
		pencilbutton.Image = "rbxassetid://15625805900"
		paintbutton2.Image = "rbxassetid://15625805069"
		paintbutton.Image = "rbxassetid://15625805069"
		eraserbutton.Image = "rbxassetid://15625805900"
		mode = 4
	else
		copybutton.Image = "rbxassetid://15625805900"
		mode = 0
	end
end)

pencilbutton.MouseButton1Up:Connect(function()
	speaker:PlaySound(clicksound)
	if mode ~= 1 then
		pencilbutton.Image = "rbxassetid://15625805069"
		copybutton.Image = "rbxassetid://15625805900"
		copybutton2.Image = "rbxassetid://15625805900"
		eraserbutton.Image = "rbxassetid://15625805900"
		paintbutton2.Image = "rbxassetid://15625805069"
		paintbutton.Image = "rbxassetid://15625805069"
		mode = 1
	else
		pencilbutton.Image = "rbxassetid://15625805900"
		mode = 0
	end
end)

local function GetCollidingGuiObjects(gui, folder)

	if gui then
		if not folder then print("Table was not specified.") return end

		if typeof(folder) ~= "table" then print("The specified table is not a valid table") return end

		if gui.ClassName == "Frame" or gui.ClassName == "ImageLabel" or gui.ClassName == "TextLabel" or gui.ClassName == "TextButton" or gui.ClassName == "ImageButton" then
			local instances = {}

			for i, ui in pairs(folder) do

				if ui.ClassName == "Frame" or ui.ClassName == "ImageLabel" or ui.ClassName == "TextLabel" or ui.ClassName == "TextButton" or ui.ClassName == "ImageButton" then
					if ui.Visible then
						local x = ui.AbsolutePosition.X
						local y = ui.AbsolutePosition.Y
						local y_axis = false
						local x_axis = false
						local guiposx = gui.AbsolutePosition.X + gui.AbsoluteSize.X
						local number = ui.AbsoluteSize.X + gui.AbsoluteSize.X

						if x - guiposx > -number then
							if x - guiposx < 0 then
								x_axis = true
							end
						end

						local guiposy = gui.AbsolutePosition.Y + gui.AbsoluteSize.Y
						local number2 = ui.AbsoluteSize.Y + gui.AbsoluteSize.Y

						if y - guiposy > -number2 then
							if y - guiposy < 0 then
								y_axis = true
							end
						end

						if x_axis and y_axis then
							table.insert(instances, ui)
						end
					end
				end
			end

			return instances

		else
			print(`{gui} is not a valid Gui Object.`)
		end
	else
		print("The specified instance is not valid.")
	end
end

local filling = false
	
function fill(block, newcolor)
	if block.BackgroundColor3 == newcolor then return end
	task.wait()
		
	local similar = {}

	for index, blockv in ipairs(colorblocks) do
		if blockv.BackgroundColor3 == block.BackgroundColor3 and blockv.Position ~= block.Position then
			table.insert(similar, blockv)
		enD
	end

	local bigsquare1 = gputer.Screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(0.9, 0.9), Position = UDim2.fromScale(0, 0.9), BackgroundTransparency = 1})
	local bigsquare2 = gputer.Screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(0.9, 0.9), Position = UDim2.fromScale(0, -0.9), BackgroundTransparency = 1})
	local bigsquare3 = gputer.Screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(0.9, 0.9), Position = UDim2.fromScale(0.9, 0), BackgroundTransparency = 1})
	local bigsquare4 = gputer.Screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(0.9, 0.9), Position = UDim2.fromScale(-0.9, 0), BackgroundTransparency = 1})

	block:AddChild(bigsquare1)
	block:AddChild(bigsquare2)
	block:AddChild(bigsquare3)
	block:AddChild(bigsquare4)

	block.BackgroundColor3 = newcolor

	local colliding = GetCollidingGuiObjects(bigsquare1, similar)
	local colliding2 = GetCollidingGuiObjects(bigsquare2, similar)
	local colliding3 = GetCollidingGuiObjects(bigsquare3, similar)
	local colliding4 = GetCollidingGuiObjects(bigsquare4, similar)

	bigsquare1:Destroy()
	bigsquare2:Destroy()
	bigsquare3:Destroy()
	bigsquare4:Destroy()

	for i, val in ipairs(colliding) do
		fill(val, newcolor)
	end

	for i, val in ipairs(colliding2) do
		fill(val, newcolor)
	end

	for i, val in ipairs(colliding3) do
		fill(val, newcolor)
	end

	for i, val in ipairs(colliding4) do
		fill(val, newcolor)
	end
end

local function fillcolor(block, newcolor)
	filling = true
	if filling then return end

	fill(block, newcolor)

	filling = false
end

--savebutton.MouseButton1Up:Connect(function()
--	savegui()
--end)

local CoroutineLoop = coroutine.create(function()
	while true do
		task.wait(0.1)
		if pressed then
			local cursors = gputer.Screen:GetCursors()

			for i, cursor in pairs(cursors) do	
				for i, ui in ipairs(colorblocks) do
					if mode < 3 then
						if getCursorColliding(cursor.X, cursor.Y, ui) then
							if mode == 1 then
								ui.BackgroundColor3 = selectedcolor
							elseif mode == 2 then
								ui.BackgroundColor3 = selectedcolor2
							end
						end
					elseif mode == 3 then
						if getCursorCollidingCopy(cursor.X, cursor.Y, ui) then
							selectedcolor = ui.BackgroundColor3
							text1.Text = BrickColor.new(ui.BackgroundColor3).Name
						end
					elseif mode == 4 then
						if getCursorCollidingCopy(cursor.X, cursor.Y, ui) then
							selectedcolor2 = ui.BackgroundColor3
							text2.Text = BrickColor.new(ui.BackgroundColor3).Name
						end
					elseif mode == 5 then
						if getCursorCollidingCopy(cursor.X, cursor.Y, ui) then
							fillcolor(ui, selectedcolor)
						end
					elseif mode == 6 then
						if getCursorCollidingCopy(cursor.X, cursor.Y, ui) then
							fillcolor(ui, selectedcolor2)
						end
					end
				end
			end
		end
	end
end)

coroutine.resume(CoroutineLoop)

--keyboardevent = keyboard:Connect("TextInputted", function(text)
--	keyboardinput = text:gsub("\n", ""):gsub("/", "")
--end)
