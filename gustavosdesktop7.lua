local disk = nil
local screen = nil
local keyboard = nil
local speaker = nil
local modem = nil
local microcontrollers = nil
local regularscreen = nil

local shutdownpoly = nil

local createwindow

local function getstuff()
	disk = nil
	screen = nil
	keyboard = nil
	speaker = nil
	shutdownpoly = nil
	modem = nil
	microcontrollers = nil
	regularscreen = nil

	for i=1, 128 do
		if not disk then
			success, Error = pcall(GetPartFromPort, i, "Disk")
			if success then
				if GetPartFromPort(i, "Disk") then
					disk = GetPartFromPort(i, "Disk")
				end
			end
		end

		if not microcontrollers then
			success, Error = pcall(GetPartsFromPort, i, "Microcontroller")
			if success then
				local microtable = GetPartsFromPort(i, "Microcontroller")
				if microtable then
					if #microtable > 0 then
						microcontrollers = microtable
					end
				end
			end
		end

		if not modem then
			success, Error = pcall(GetPartFromPort, i, "Modem")
			if success then
				if GetPartFromPort(i, "Modem") then
					modem = GetPartFromPort(i, "Modem")
				end
			end
		end
	
		if not shutdownpoly then
			success, Error = pcall(GetPartFromPort, i, "Polysilicon")
			if success then
				if GetPartFromPort(i, "Polysilicon") then
					shutdownpoly = i
				end
			end
		end
		
		if not speaker then
			success, Error = pcall(GetPartFromPort, i, "Speaker")
			if success then
				if GetPartFromPort(i, "Speaker") then
					speaker = GetPartFromPort(i, "Speaker")
				end
			end
		end
		if not screen then
			success, Error = pcall(GetPartFromPort, i, "TouchScreen")
			if success then
				if GetPartFromPort(i, "TouchScreen") then
					screen = GetPartFromPort(i, "TouchScreen")
				end
			end
		end
		if not regularscreen then
			success, Error = pcall(GetPartFromPort, i, "Screen")
			if success then
				if GetPartFromPort(i, "Screen") then
					regularscreen = GetPartFromPort(i, "Screen")
				end
			end
		end
		if not keyboard then
			success, Error = pcall(GetPartFromPort, i, "Keyboard")
			if success then
				if GetPartFromPort(i, "Keyboard") then
					keyboard = GetPartFromPort(i, "Keyboard")
				end
			end
		end
	end
end
getstuff()

local holding = false
local holding2 = false

local prevCursorPos
local uiStartPos

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

local programholder1
local programholder2

function createwindow(udim2, title, boolean, boolean2, boolean3)
	local holderframe = screen:CreateElement("ImageButton", {Size = udim2, BackgroundTransparency = 1, Image = "rbxassetid://8677487226", ImageTransparency = 0.2})

	programholder1:AddChild(holderframe)
	local textlabel
	if typeof(title) == "table" then
		textlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1, -70, 0, 25), BackgroundTransparency = 1, Position = UDim2.new(0, 70, 0, 0), TextScaled = true, TextWrapped = true, Text = tostring(title)})
	end
	local resizebutton
	if not boolean2 then
		resizebutton = screen:CreateElement("TextButton", {TextScaled = true, TextWrapped = true, Size = UDim2.new(0, 10, 0, 10), Text = "", Position = UDim2.new(1,-10,1,-10), BackgroundColor3 = Color3.new(1,1,1)})
		
		holderframe:AddChild(resizebutton)
		
		local maximizepressed = false
		resizebutton.MouseButton1Down:Connect(function()
			if holding2 then return end
			if not maximizepressed then
				local cursors = screen:GetCursors()
				local cursor
				local x_axis
				local y_axis
		
				for index,cur in pairs(cursors) do
					local boolean, x_Axis, y_Axis = getCursorColliding(cur.X, cur.Y, holderframe)
					if boolean then
						cursor = cur
						x_axis = x_Axis
						y_axis = y_Axis
						break
					end
				end
				startCursorPos = cursor
				holderframetouse = holderframe
				holding = true
			end
		end)
		
		resizebutton.MouseButton1Up:Connect(function()
			holding = false
		end)
	end

	if not boolean3 then
	
		holderframe.MouseButton1Down:Connect(function()
			if holding then return end
			if maximizepressed then return end
			local cursors = screen:GetCursors()
			local cursor
			local x_axis
			local y_axis
		
			for index,cur in pairs(cursors) do
				local boolean, x_Axis, y_Axis = getCursorColliding(cur.X, cur.Y, holderframe)
				if boolean then
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
		
		holderframe.MouseButton1Up:Connect(function()
			holding2 = false
		end)
	end
	
	local closebutton = screen:CreateElement("ImageButton", {BackgroundTransparency = 1, Size = UDim2.new(0, 35, 0, 25), BackgroundColor3 = Color3.new(1,0,0), Image = "rbxassetid://15617983488"})
	holderframe:AddChild(closebutton)
	
	closebutton.MouseButton1Down:Connect(function()
		closebutton.Image = "rbxassetid://15617984474"
	end)
	
	closebutton.MouseButton1Up:Connect(function()
		closebutton.Image = "rbxassetid://15617983488"
		speaker:PlaySound("rbxassetid://6977010128")
		holderframe:Destroy()
		holderframe = nil
	end)

	local maximizebutton
	if not boolean then
		maximizebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0,35,0,25), Image = "rbxassetid://15617867263", Position = UDim2.new(0, 35, 0, 0), BackgroundTransparency = 1})
		local maximizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "+"})
		maximizebutton:AddChild(maximizetext)
		
		holderframe:AddChild(maximizebutton)
		local unmaximizedsize = holderframe.Size
		
		maximizebutton.MouseButton1Down:Connect(function()
			maximizebutton.Image = "rbxassetid://15617866125"
		end)
		
		maximizebutton.MouseButton1Up:Connect(function()
			if holding or holding2 then return end
			speaker:PlaySound("rbxassetid://6977010128")
			maximizebutton.Image = "rbxassetid://15617867263"
			local holderframe = holderframe
			if not maximizepressed then
				unmaximizedsize = holderframe.Size
				holderframe.Size = UDim2.new(1, 0, 0.9, 0)
				holderframe.Position = UDim2.new(0, 0, 1, 0)
				holderframe.Position = UDim2.new(0, 0, 0, 0)
				programholder2:AddChild(holderframe)
				maximizetext.Text = "-"
				maximizepressed = true
			else
				holderframe.Size = unmaximizedsize
				maximizetext.Text = "+"
				programholder1:AddChild(holderframe)
				maximizepressed = false
			end
		end)
	else
		if title then
			textlabel.Position = UDim2.new(0, 35, 0, 0)
			textlabel.Size = UDim2.new(1, -35, 0, 25)
		end
	end
	return holderframe, closebutton, maximizebutton, textlabel, resizebutton
end

local commandline = {}

function commandline.new(boolean, udim2, screen)
	local holderframe
	local background
	local lines = {
		number = 0
	}
	if boolean then
		holderframe = createwindow(udim2, "Command Line", false, false, false)
		background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0)})
		holderframe:AddChild(background)
	else
		background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0)})
	end

	function lines:insert(text)
		local textlabel = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Text = tostring(text), TextScaled = true, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.fromOffset(0, lines.number * 25)})
		background:AddChild(textlabel)
		background.CanvasSize = UDim2.new(1, 0, 0, (lines.number * 25) + 25)
		lines.number += 1
	end
	return lines, background, holderframe
end

local startbutton7
local wallpaper
local resolutionframe

local function loaddesktop()
	resolutionframe = screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0)})
	wallpaper = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), Image = "rbxassetid://15617469527", BackgroundTransparency = 1})
	
	startbutton7 = screen:CreateElement("ImageButton", {Image = "rbxassetid://15617867263", BackgroundTransparency = 1, Size = UDim2.new(0.1, 0, 0.1, 0), Position = UDim2.new(0, 0, 0.9, 0)})
	local textlabel = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = "G", TextScaled = true, TextWrapped = true})
	startbutton7:AddChild(textlabel)
	
	local textlabel2 = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0.5,0,0.5,0), Position = UDim2.new(0.25, 0, 0.25, 0), Text = "GustavOS 7", TextScaled = true, TextWrapped = true})
	wallpaper:AddChild(textlabel2)

	programholder1 = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
	programholder2 = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
	programholder2:AddChild(programholder1)
	
	local pressed = false
	local startmenu
	local function openstartmenu()
		if not pressed then
			startmenu = screen:CreateElement("ImageButton", {BackgroundTransparency = 1, Image = "rbxassetid://15619032563", Size = UDim2.new(0.3, 0, 0.5, 0), Position = UDim2.new(0, 0, 0.4, 0), ImageTransparency = 0.1})
			local testopen = screen:CreateElement("ImageButton", {Size = UDim2.new(1,0,0.2,0), Image = "rbxassetid://15617867263", Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
			startmenu:AddChild(testopen)
			local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Test"})
			testopen:AddChild(txtlabel)
			testopen.MouseButton1Down:Connect(function()
				testopen.Image = "rbxassetid://15617866125"
			end)
			testopen.MouseButton1Up:Connect(function()
				speaker:PlaySound("rbxassetid://6977010128")
				testopen.Image = "rbxassetid://15617867263"
				createwindow(UDim2.new(0.5, 0, 0.5, 0), "Test", false, false, false)
				pressed = false
				startmenu:Destroy()
			end)
			pressed = true
		else
			startmenu:Destroy()
			pressed = false
		end
	end
	
	startbutton7.MouseButton1Up:Connect(function()
		openstartmenu()
		speaker:PlaySound("rbxassetid://6977010128")
	end)
end
if screen and keyboard and speaker and disk then
	screen:ClearElements()
	loaddesktop()
elseif not screen and regularscreen then
	local commandlines = commandline.new(false, nil, regularscreen)
	commandlines:insert("Regular screen is not supported.")
	if not speaker then
		commandlines:insert("No speaker was found.")
	end
	if not keyboard then
		commandlines:insert("No keyboard was found.")
	end
	if not disk then
		commandlines:insert("No disk was found.")
	end
elseif screen then
	local commandlines = commandline.new(false, nil, screen)
	if not speaker then
		commandlines:insert("No speaker was found.")
	end
	if not keyboard then
		commandlines:insert("No keyboard was found.")
	end
	if not disk then
		commandlines:insert("No disk was found.")
	end
end

local cursorsinscreen = {}

while true do
	task.wait(0.01)
	if startbutton7 then
		local cursors = screen:GetCursors()
		local success = false
		for index,cur in pairs(cursors) do
			local boolean, x_Axis, y_Axis = getCursorColliding(cur.X, cur.Y, startbutton7)
			if boolean then
				print(Vector2.new(x_Axis, y_Axis))
				startbutton7.Image = "rbxassetid://15617866125"
				success = true
				break
			end
		end
		if not success then
			startbutton7.Image = "rbxassetid://15617867263"
		end
	end
	if holding2 then
		local cursors = screen:GetCursors()
		local cursor
		local x_axis
		local y_axis

		for index,cur in pairs(cursors) do
			local boolean, x_Axis, y_Axis = getCursorColliding(cur.X, cur.Y, holderframetouse)
			if boolean then
				cursor = cur
				x_axis = x_Axis
				y_axis = y_Axis
				break
			end
		end
		if cursor then
			local screenresolution = resolutionframe.AbsoluteSize
			local startCursorPos = startCursorPos
			if typeof(cursor["X"]) == "number" and typeof(cursor["Y"]) == "number" and typeof(screenresolution["X"]) == "number" and typeof(screenresolution["Y"]) == "number" and typeof(startCursorPos["X"]) == "number" and typeof(startCursorPos["Y"]) == "number" then
				holderframetouse.Position = uiStartPos - UDim2.fromScale((startCursorPos.X - cursor.X)/screenresolution.X, (startCursorPos.Y - cursor.Y)/screenresolution.Y)
			end
		end
	end
	
	if holding then
		if not holderframetouse then return end
		local cursors = screen:GetCursors()
		local cursor

		for index,cur in pairs(cursors) do
			if startCursorPos and cur then
				if cur.Player == startCursorPos.Player then
					cursor = cur
				end
			end
		end
		if cursor then
			local newX = (cursor.X - holderframetouse.AbsolutePosition.X) +5
			local newY = (cursor.Y - holderframetouse.AbsolutePosition.Y) +5
			if newX < 100 then newX = 100 end
			if newY < 100 then newY = 100 end
			local screenresolution = resolutionframe.AbsoluteSize

			if typeof(cursor["X"]) == "number" and typeof(cursor["Y"]) == "number" and typeof(screenresolution["X"]) == "number" and typeof(screenresolution["Y"]) == "number" and typeof(startCursorPos["X"]) == "number" and typeof(startCursorPos["Y"]) == "number" then
				holderframetouse.Size = UDim2.fromScale(newX/screenresolution.X, newY/screenresolution.Y)
			end
		end
	end
	for i,v in pairs(cursorsinscreen) do
		v:Destroy()
		table.remove(cursorsinscreen, i)
	end
	local cursors = screen:GetCursors()
	for i,v in pairs(cursors) do
		local cursor = screen:CreateElement("ImageLabel", {Size = UDim2.new(0.2, 0, 0.2, 0), BackgroundTransparency = 1, Image = "rbxassetid://8679825641"})
		table.insert(cursorsinscreen, cursor)
		if v then
			cursor.Position = UDim2.new(0, tonumber(v.X) - cursor.AbsoluteSize.X/2, 0, tonumber(v.Y) - cursor.AbsoluteSize.Y/2)
		end
	end
end
