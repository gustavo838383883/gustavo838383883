local disk = GetPartFromPort(1, "Disk")
local gputer = disk:Read("GD7Library")

local CreateWindow = gputer.CreateWindow
local speaker = gputer.Speaker
local createnicebutton2 = gputer.createnicebutton2
local normalcreatenicebutton = gputer.createnicebutton
local screen = gputer.Screen
local clicksound = GetPartFromPort(1, "Disk"):Read("ClickSound") or "rbxassetid://6977010128"

local function createnicebutton(udim2, pos, text, Parent)
	local txtbutton = screen:CreateElement("ImageButton", {Size = udim2, Image = "rbxassetid://15625805900", Position = pos, BackgroundTransparency = 1})
	local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(text), RichText = true})
	txtbutton:AddChild(txtlabel)
	if Parent then
		Parent:AddChild(txtbutton)
	end
	txtbutton.MouseButton1Up:Connect(function()
		speaker:PlaySound(clicksound)
	end)
	return txtbutton, txtlabel
end

local function othercreatenicebutton2(udim2, pos, text, Parent)
	local txtbutton = screen:CreateElement("ImageButton", {Size = udim2, Image = "rbxassetid://15617867263", Position = pos, BackgroundTransparency = 1})
	local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(text), RichText = true})
	txtbutton:AddChild(txtlabel)
	if Parent then
		Parent:AddChild(txtbutton)
	end
	txtbutton.MouseButton1Up:Connect(function()
		speaker:PlaySound(clicksound)
	end)
	return txtbutton, txtlabel
end

local function GetTouchingGuiObjects(gui, folder)

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

						if x - guiposx >= -number then
							if x - guiposx <= 0 then
								x_axis = true
							end
						end

						local guiposy = gui.AbsolutePosition.Y + gui.AbsoluteSize.Y
						local number2 = ui.AbsoluteSize.Y + gui.AbsoluteSize.Y

						if y - guiposy >= -number2 then
							if y - guiposy <= 0 then
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

local window = CreateWindow(UDim2.fromScale(0.5, 0.7), "Minesweeper", false, false, false, "Minesweeper", false, false)

local smilebutton, t = createnicebutton2(UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0.5, 0), "", window)

local smileimg = screen:CreateElement("ImageLabel", {Image = "rbxassetid://16268341143", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)})

smilebutton:AddChild(smileimg)

t:Destroy()

local flagbutton, t = othercreatenicebutton2(UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0, 0), "", window)

flagbutton:AddChild(screen:CreateElement("ImageLabel", {Image = "rbxassetid://16268281465", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}))

t:Destroy()

local score = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(0.35, 0.2), Position = UDim2.fromScale(0.15, 0), Text = "0", BackgroundTransparency = 1, TextScaled = true})

window:AddChild(score)

local curtime = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(0.35, 0.2), Position = UDim2.fromScale(0.65, 0), Text = "0", BackgroundTransparency = 1, TextScaled = true})
local starttime = nil

window:AddChild(curtime)

local restartgame
local bombshower

smilebutton.MouseButton1Up:Connect(function()
	smileimg.Image = "rbxassetid://16268341143"
	restartgame()
end)

local guis = {}
local txts = {}

local bombnumber = 10
local squaresize = 0.125

local placeflag = false
local Trigger
local bombpositions = {}
local donttrigger = false

local function findbombsnear(square)
	local found = 0

	local bombs = {}

	for index, value in ipairs(bombpositions) do
		local bomb = screen:CreateElement("Frame", {Size = UDim2.fromScale(squaresize, squaresize), Position = value, BackgroundTransparency = 1})
		
		squareholder:AddChild(bomb)

		table.insert(bombs, bomb)
	end

	local bigsquare = screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(2, 2), Position = UDim2.fromScale(-0.5, -0.5), BackgroundTransparency = 1})

	square:AddChild(bigsquare)

	local colliding = GetTouchingGuiObjects(bigsquare, bombs)
	
	for index, value in ipairs(colliding) do
		found += 1
	end

	bigsquare:Destroy()

	for i, val in ipairs(bombs) do
		val:Destroy()
	end

	bombs = {}
	
	return found
end

local function youwon()
	local windowb = CreateWindow(UDim2.fromScale(0.5, 0.5), "You won", true, true, false, nil, true, false)

	windowb:AddChild(screen:CreateElement("TextLabel", {Text = "You won!", Size = UDim2.fromScale(1, 1), TextScaled = true, BackgroundTransparency = 1}))
end

local function shownear(square)
	local bigsquare = screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.fromScale(2, 2), Position = UDim2.fromScale(-0.5, -0.5)})

	square:AddChild(bigsquare)
	
	local colliding = GetTouchingGuiObjects(bigsquare, guis)
	
	for index, value in ipairs(colliding) do
		if value.Image ~= "rbxassetid://15625805069" then
			local textlabl = nil
			for ind, val in ipairs(txts) do
				if val.AbsolutePosition == value.AbsolutePosition then
					textlabl = val
				end
			end
			
			Trigger(1, value, textlabl)
		end
	end

	bigsquare:Destroy()
end

local function died()
	starttime = nil
	smileimg.Image = "rbxassetid://16268745056"
	donttrigger = true
	speaker:Configure({Audio = 3802269741})
	speaker:Trigger()
end

function Trigger(mode, square, txtlabel)
	if donttrigger then return end
	local found = table.find(bombpositions, square.Position)
	if found and mode == 0 then
		died()
		square.Image = "rbxassetid://15625805069"

		for index, value in ipairs(bombpositions) do
			local bomb = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(squaresize, squaresize), Image = "rbxassetid://16268280434", Position = value, BackgroundTransparency = 1})

			squareholder:AddChild(bomb)
		end
	elseif not found then
		local returnval = findbombsnear(square)
		if returnval > 0 then
			txtlabel.Text = returnval
			square.Image = "rbxassetid://15625805069"
		else
			square.Image = "rbxassetid://15625805069"
			shownear(square)
		end
	end
end

flagbutton.MouseButton1Up:Connect(function()
	if not placeflag then
		placeflag = true
		flagbutton.Image = "rbxassetid://15617866125"
	else
		placeflag = false
		flagbutton.Image = "rbxassetid://15617867263"
	end
end)

local firstclick = true

local function restartgamenow()
	starttime = tick()
	local startgame
	guis = {}
	txts = {}
	firstclick = true
	bombshower = bombnumber
	score.Text = bombshower
	flagbutton.Image = "rbxassetid://15617867263"
	placeflag = false
	if squareholder then
		squareholder:Destroy()
	end

	squareholder = screen:CreateElement("Frame", {Size = UDim2.fromScale(1, 0.8), BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0.2)})
	window:AddChild(squareholder)

	for x = 0, 1-squaresize, squaresize do

		for y = 0, 1-squaresize, squaresize do
			local square, txt = createnicebutton(UDim2.fromScale(squaresize, squaresize), UDim2.fromScale(x, y), "", squareholder)
			local flag = false

			square.MouseButton1Up:Connect(function()
				if firstclick then
					startgame(square)
					firstclick = false
				end
				if not donttrigger then
					if not placeflag then
						if not flag and square.Image ~= "rbxassetid://15625805069" then
							square.Image = "rbxassetid://15625805069"
							Trigger(0, square, txt)
						end
					else

						if flag then
							flag:Destroy()
							flag = nil
							bombshower += 1
							score.Text = bombshower
						elseif square.Image ~= "rbxassetid://15625805069" then
							flag = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(squaresize, squaresize), Image = "rbxassetid://16268281465", Position = square.Position, BackgroundTransparency = 1})
							squareholder:AddChild(flag)

							bombshower -= 1
							score.Text = bombshower

						end
					end
				end
			end)

			table.insert(guis, square)
			table.insert(txts, txt)
		end

	end

	donttrigger = false
	
	bombpositions = {}

	function startgame(square)

		for i=1,bombnumber do

			local tabletoloop = {}

			for index, value in ipairs(guis) do
				if not table.find(bombpositions, value.Position) and value.Position ~= square.Position then
					table.insert(tabletoloop, value)
				end
			end

			local random1 = math.random(1, #tabletoloop)

			local pos = tabletoloop[random1].Position

			table.insert(bombpositions, pos)
		end

	end
end

local function createlist(frame, content, func)
	local frame1 = screen:CreateElement("ImageLabel", {Image = "rbxassetid://8677487226", Size = UDim2.fromScale(1, 2), Position = UDim2.fromScale(1, 0), BackgroundTransparency = 1})
	frame:AddChild(frame1)

	local scrollframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.fromScale(0, 0.5), BackgroundTransparency = 1, ScrollBarThickness = 5})

	frame1:AddChild(scrollframe)

	scrollframe.CanvasSize = UDim2.fromScale(0, #content*0.5)

	if scrollframe.CanvasSize.Y.Scale == 0.5 then
		scrollframe.CanvasSize = UDim2.fromScale(0, 1)
	end
	
	for index, value in ipairs(content) do
		local button1 = normalcreatenicebutton(UDim2.fromScale(1, (0.5/scrollframe.CanvasSize.Y.Scale)), UDim2.fromScale(0, ((0.5/scrollframe.CanvasSize.Y.Scale) * index) - (0.5/scrollframe.CanvasSize.Y.Scale)), tostring(value), scrollframe)

		button1.MouseButton1Up:Connect(function()
			func(value)
		end)
	end
	
	return frame1
end

function restartgame()
	local windowa, frame1 = CreateWindow(UDim2.fromScale(0.7, 0.7), "Select Amount", false, false, false, nil, true, false)

	local textlabel1 = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(1, 0.2), TextScaled = true, BackgroundTransparency = 1, Text = "Select Amount of mines"})
	windowa:AddChild(textlabel1)

	local textlabel2 = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(0.5, 0.2), Position = UDim2.fromScale(0.25, 0.2), TextScaled = true, BackgroundTransparency = 1, Text = bombnumber})
	windowa:AddChild(textlabel2)

	local selectedsize = bombnumber

	local subbutton = normalcreatenicebutton(UDim2.fromScale(0.25, 0.2), UDim2.fromScale(0, 0.2), "-", windowa)
	local addbutton = normalcreatenicebutton(UDim2.fromScale(0.25, 0.2), UDim2.fromScale(0.75, 0.2), "+", windowa)
	local enterbutton = normalcreatenicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.8), "Start", windowa)

	addbutton.MouseButton1Up:Connect(function()
		if selectedsize >= 32 then return end
		selectedsize += 1
		textlabel2.Text = selectedsize
	end)

	subbutton.MouseButton1Up:Connect(function()
		if selectedsize <= 2 then return end
		selectedsize -= 1
		textlabel2.Text = selectedsize
	end)

	local tempsize = squaresize

	local sizes = {
		[1] = 1/5,
		[2] = 1/8,
		[3] = 1/11,
		[4] = 1/16
	}

	local changesize, changetext = normalcreatenicebutton(UDim2.fromScale(0.25, 0.2), UDim2.fromScale(0, 0.4), tempsize, windowa)

	local list = nil
	
	changesize.MouseButton1Up:Connect(function()
		if list then
			list:Destroy()
			list = nil
		else
			list = createlist(changesize, sizes, function(numb)
				tempsize = numb
				changetext.Text = tempsize
				list:Destroy()
				list = nil
			end)
		end
	end)

	enterbutton.MouseButton1Up:Connect(function()
		bombnumber = selectedsize
		squaresize = tempsize
		frame1:Destroy()
		restartgamenow()
	end)
end

local loop1 = coroutine.create(function()
	while true do
		task.wait(1)
		if not donttrigger then
			if starttime then
				curtime.Text = math.floor(tick() - starttime)
			else
				curtime.Text = 0
			end
		end

		if not donttrigger then
	
			local clickednumber = 0
				
			for index, value in ipairs(guis) do
				if value.Image == "rbxassetid://15625805069" then
					clickednumber += 1
				end
			end
		
			if clickednumber == #guis - bombnumber then
				donttrigger = true
				youwon()
			end
		end
	end
end)

coroutine.resume(loop1)
