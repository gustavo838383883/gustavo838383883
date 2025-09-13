if not createnicebutton then
	error("This is supposed to run in GustavOS")
end

local normalcreatenicebutton = createnicebutton
local clicksound = getsystemsoundid("clicksound")

local function createnicebutton(udim2, pos, text, Parent)
	local txtbutton = screen:CreateElement("ImageButton", {Size = udim2, Image = "rbxassetid://15625805900", Position = pos, BackgroundTransparency = 1})
	local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tonumber(text) or tostring(text), RichText = true})
	txtlabel.Parent = txtbutton
	if Parent then
		txtbutton.Parent = Parent
	end
	txtbutton.MouseButton1Up:Connect(function()
		speaker:PlaySound(clicksound)
	end)
	return txtbutton, txtlabel
end

local function othercreatenicebutton2(udim2, pos, text, Parent)
	local txtbutton = screen:CreateElement("ImageButton", {Size = udim2, Image = "rbxassetid://15617867263", Position = pos, BackgroundTransparency = 1})
	local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tonumber(text) or tostring(text), RichText = true})
	txtlabel.Parent = txtbutton
	if Parent then
		txtbutton.Parent = Parent
	end
	txtbutton.MouseButton1Up:Connect(function()
		speaker:PlaySound(clicksound)
	end)
	return txtbutton, txtlabel
end

local function GetTouchingGuiObjects(gui, folder)

	if gui then

		local instances = {}

		for i, ui in folder do

			if ui.Visible then
				if (ui.AbsolutePosition.X - (gui.AbsolutePosition.X + gui.AbsoluteSize.X) >= -ui.AbsoluteSize.X - gui.AbsoluteSize.X and ui.AbsolutePosition.X - (gui.AbsolutePosition.X + gui.AbsoluteSize.X) <= 0 and ui.AbsolutePosition.Y - (gui.AbsolutePosition.Y + gui.AbsoluteSize.Y) >= -ui.AbsoluteSize.Y - gui.AbsoluteSize.Y and ui.AbsolutePosition.Y - (gui.AbsolutePosition.Y + gui.AbsoluteSize.Y) <= 0) then
					table.insert(instances, ui)
				end
			end
		end
		return instances
	end
end

local window, winfunc = CreateWindow(UDim2.fromScale(0.5, 0.7), "Minesweeper", false, false, false, "Minesweeper", false, false)

local smilebutton, t = createnicebutton2(UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0.5, 0), "", window)

local smileimg = screen:CreateElement("ImageLabel", {Image = "rbxassetid://16268341143", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)})

smileimg.Parent = smilebutton

t:Destroy()

local flagbutton, t = othercreatenicebutton2(UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0, 0), "", window)

screen:CreateElement("ImageLabel", {Image = "rbxassetid://16268281465", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}).Parent = flagbutton

t:Destroy()

local score = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(0.35, 0.2), Position = UDim2.fromScale(0.15, 0), Text = "0", BackgroundTransparency = 1, TextScaled = true})
score.Parent = window

local curtime = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(0.35, 0.2), Position = UDim2.fromScale(0.65, 0), Text = "0", BackgroundTransparency = 1, TextScaled = true})
local starttime = nil
curtime.Parent = window

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

local function createfakebigsquare(square)
	return {Visible = true, ClassName = "Frame", AbsoluteSize = square.AbsoluteSize*2, AbsolutePosition = square.AbsolutePosition - square.AbsoluteSize/2}
end

local function findbombsnear(square)
	local found = 0

	local bombs = {}

	for index, value in ipairs(bombpositions) do
		print(squareholder.AbsolutePosition + Vector2.new(squareholder.AbsoluteSize.X*value.X.Scale, squareholder.AbsoluteSize.Y*value.Y.Scale))
		print(square.AbsolutePosition, "ME")
		table.insert(bombs, {Visible = true, ClassName = "Frame", AbsoluteSize = square.AbsoluteSize, AbsolutePosition = squareholder.AbsolutePosition + Vector2.new(squareholder.AbsoluteSize.X*value.X.Scale, squareholder.AbsoluteSize.Y*value.Y.Scale)})
	end

	local bigsquare = createfakebigsquare(square)

	local colliding = GetTouchingGuiObjects(bigsquare, bombs)

	found = #colliding

	bombs = {}

	return found
end

local function youwon()
	local windowb = CreateWindow(UDim2.fromScale(0.5, 0.5), "Message", true, true, false, nil, true, false)

	screen:CreateElement("TextLabel", {Text = "You won!", Size = UDim2.fromScale(1, 1), TextScaled = true, BackgroundTransparency = 1}).Parent = windowb

	coroutine.resume(coroutine.create(function()
		local sound = speaker:LoadSound("rbxassetid://12222253")
		sound.Volume = 1
		sound:Play()
		speaker.Volume = speaker.Volume
		task.wait(2)
		sound:Destroy()
	end))
end

local function shownear(square)
	local bigsquare = createfakebigsquare(square)

	local colliding = GetTouchingGuiObjects(bigsquare, guis)

	local previ = 0
	for index, value in ipairs(colliding) do
		if index - previ > 5 then
			task.wait()
		end
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
end

local function died()
	starttime = nil
	smileimg.Image = "rbxassetid://16268745056"
	donttrigger = true
	coroutine.resume(coroutine.create(function()
		local sound = speaker:LoadSound("rbxassetid://3802269741")
		sound.Volume = 1
		sound:Play()
		speaker.Volume = speaker.Volume
		task.wait(2)
		sound:Destroy()
	end))
end

local textcolors = {
	[1] = Color3.fromRGB(0, 0, 125),
	[2] = Color3.fromRGB(0, 255, 0),
	[3] = Color3.fromRGB(255, 0, 0),
	[4] = Color3.fromRGB(0, 0, 255),
	[5] = Color3.fromRGB(190, 42, 42),
	[6] = Color3.fromRGB(0, 200, 200),
	[7] = Color3.fromRGB(20, 20, 20),
	[8] = Color3.fromRGB(100, 100, 100)
}

function Trigger(mode, square, txtlabel)
	if donttrigger then return end
	local found = table.find(bombpositions, square.Position)
	if found and mode == 0 then
		pcall(died)
		square.Image = "rbxassetid://15625805069"

		for index, value in ipairs(bombpositions) do
			local bomb = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(squaresize, squaresize), Image = "rbxassetid://16268280434", Position = value, BackgroundTransparency = 1})
			bomb.Parent = squareholder
		end
	elseif not found then
		local returnval = findbombsnear(square)
		print(returnval)
		if returnval > 0 then
			txtlabel.Text = returnval
			local textcolor = textcolors[returnval]
			if textcolor then
				txtlabel.TextColor3 = textcolor
			end
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

local function placeflagfunc(square, flag)
	if flag then
		flag:Destroy()
		flag = nil
		bombshower += 1
		score.Text = bombshower
	elseif square.Image ~= "rbxassetid://15625805069" and bombshower > 0 then
		flag = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(squaresize, squaresize), Image = "rbxassetid://16268281465", Position = square.Position, BackgroundTransparency = 1})
		flag.Parent = squareholder

		bombshower -= 1
		score.Text = bombshower

		coroutine.resume(coroutine.create(function()
			local sound = speaker:LoadSound("rbxassetid://4831091467")
			sound.Volume = 1
			sound:Play()
			speaker.Volume = speaker.Volume
			task.wait(1)
			sound:Destroy()
		end))
	end

	return flag
end

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
	squareholder.Parent = window

	for x = 0, 1-squaresize, squaresize do

		for y = 0, 1-squaresize, squaresize do
			local square, txt = createnicebutton(UDim2.fromScale(squaresize, squaresize), UDim2.fromScale(x, y), "", squareholder)
			local flag = false

			square.MouseButton1Up:Connect(function()
				if firstclick then
					startgame(square)
					firstclick = false
					shownear(square)
				end
				if not donttrigger then
					if not placeflag then
						if not flag and square.Image ~= "rbxassetid://15625805069" then
							square.Image = "rbxassetid://15625805069"
							Trigger(0, square, txt)
						end
					else
						flag = placeflagfunc(square, flag)
					end
				end
			end)
			square.MouseButton2Up:Connect(function()
				if firstclick then
					startgame(square)
					firstclick = false
					shownear(square)
				end
				if not donttrigger then
					flag = placeflagfunc(square, flag)
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

			if #tabletoloop <= 0 then return end

			local random1 = math.random(1, #tabletoloop)

			local pos = tabletoloop[random1].Position

			table.insert(bombpositions, pos)
		end

	end
end

local function createlist(frame, content, func)
	local frame1 = screen:CreateElement("ImageLabel", {Image = "rbxassetid://8677487226", Size = UDim2.fromScale(1, 2), Position = UDim2.fromScale(1, 0), BackgroundTransparency = 1})
	frame1.Parent = frame

	local scrollframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.fromScale(0, 0.5), BackgroundTransparency = 1, ScrollBarThickness = 5})
	scrollframe.Parent = frame1

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
	local windowa, frame1, closebutton, maximizebutton, textlabel, resizebutton, minimizebutton, functions, frameindex = CreateWindow(UDim2.fromScale(0.7, 0.7), "Select", false, false, false, nil, true, false)

	local textlabel1 = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(1, 0.2), TextScaled = true, BackgroundTransparency = 1, Text = "Select Amount of mines"})
	textlabel1.Parent = windowa

	local textlabel2 = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(0.5, 0.2), Position = UDim2.fromScale(0.25, 0.2), TextScaled = true, BackgroundTransparency = 1, Text = bombnumber})
	textlabel2.Parent = windowa

	local selectedsize = bombnumber

	local subbutton = normalcreatenicebutton(UDim2.fromScale(0.25, 0.2), UDim2.fromScale(0, 0.2), "-", windowa)
	local addbutton = normalcreatenicebutton(UDim2.fromScale(0.25, 0.2), UDim2.fromScale(0.75, 0.2), "+", windowa)
	local enterbutton = normalcreatenicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.8), "Start", windowa)

	addbutton.MouseButton1Up:Connect(function()
		if selectedsize >= 40 then return end
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
		[3] = 1/10,
		[4] = 1/16
	}

	local textlabel3 = screen:CreateElement("TextLabel", {Position = UDim2.fromScale(0, 0.4), Size = UDim2.fromScale(1, 0.2), TextScaled = true, BackgroundTransparency = 1, Text = "Select the size of the squares"})
	textlabel3.Parent = windowa

	local changesize, changetext = normalcreatenicebutton(UDim2.fromScale(0.25, 0.2), UDim2.fromScale(0, 0.6), tempsize, windowa)

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
		functions:Close()
		if not window then return end
		restartgamenow()
	end)
end

restartgame()

while true do
	task.wait(1)
	if winfunc:IsClosed() then
		break
	end
	if not donttrigger and not firstclick then
		if starttime then
			curtime.Text = math.floor(tick() - starttime)
		else
			curtime.Text = 0
		end
	end

	if not donttrigger and not firstclick then

		local clickednumber = 0

		for index, value in ipairs(guis) do
			if value.Image == "rbxassetid://15625805069" and not table.find(bombpositions, value.Position) then
				clickednumber += 1
			end
		end

		if clickednumber == #guis - bombnumber then
			donttrigger = true
			youwon()
		end
	end
end
