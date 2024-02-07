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

local window = CreateWindow(UDim2.fromScale(0.5, 0.7), "Minesweeper test", false, false, false, "Minesweeper", false, false)

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

local placeflag = false
local Trigger
local bombpositions = {}
local donttrigger = false

local function findbombsnear(square)
	local found = 0

	for index, value in ipairs(bombpositions) do
		if value == square.Position + UDim2.fromScale(0, 0.125) then
			found += 1
		elseif value == square.Position - UDim2.fromScale(0, 0.125) then
			found += 1
		elseif value == square.Position - UDim2.fromScale(0.125, 0.125) then
			found += 1
		elseif value == square.Position + UDim2.fromScale(0.125, 0.125) then
			found += 1
		elseif value == square.Position - UDim2.fromScale(0.125, 0) then
			found += 1
		elseif value == square.Position + UDim2.fromScale(0.125, 0) then
			found += 1
		elseif value == square.Position + UDim2.fromScale(0.125, -0.125) then
			found += 1
		elseif value == square.Position + UDim2.fromScale(-0.125, 0.125) then
			found += 1
		end
	end

	return found
end

local function youwon()
	local windowb = CreateWindow(UDim2.fromScale(0.5, 0.5), "You won", true, true, false, nil, true, false)

	windowb:AddChild(screen:CreateElement("TextLabel", {Text = "You won!", Size = UDim2.fromScale(1, 1), TextScaled = true, BackgroundTransparency = 1}))
end

local function shownear(square)
	for index, value in ipairs(guis) do
		if value.Position ~= square.Position and value.Image ~= "rbxassetid://15625805069" then
			if value.Position == square.Position + UDim2.fromScale(0, 0.125) then
				Trigger(1, value, txts[index])
			elseif value.Position == square.Position - UDim2.fromScale(0, 0.125) then
				Trigger(1, value, txts[index])
			elseif value.Position == square.Position - UDim2.fromScale(0.125, 0.125) then
				Trigger(1, value, txts[index])
			elseif value.Position == square.Position + UDim2.fromScale(0.125, 0.125) then
				Trigger(1, value, txts[index])
			elseif value.Position == square.Position - UDim2.fromScale(0.125, 0) then
				Trigger(1, value, txts[index])
			elseif value.Position == square.Position + UDim2.fromScale(0.125, 0) then
				Trigger(1, value, txts[index])
			elseif value.Position == square.Position + UDim2.fromScale(0.125, -0.125) then
				Trigger(1, value, txts[index])
			elseif value.Position == square.Position + UDim2.fromScale(-0.125, 0.125) then
				Trigger(1, value, txts[index])
			end
		end
	end
end

local function died()
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
			local bomb = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(0.125, 0.125), Image = "rbxassetid://16268280434", Position = value, BackgroundTransparency = 1})

			squareholder:AddChild(bomb)
		end
	elseif not found then
		local returnval = findbombsnear(square)
		if returnval > 0 then
			txtlabel.Text = returnval
			square.Image = "rbxassetid://15625805069"
		else
			square.Image = "rbxassetid://15625805069"
			shownear(square, txtlabel)
		end
	end
	
	local clickednumber = 0

	for index, value in ipairs(gui) do
		if value.Image == "rbxassetid://15625805069" then
			clickednumber += 1
		end
	end

	if clickednumber == #guis - bombnumber then
		youwon()
	end
end

flagbutton.MouseButton1Up:Connect(function()
	if placeflag then
		placeflag = false
		flagbutton.Image = "rbxassetid://15617866125"
	else
		placeflag = true
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

	for x = 0, 0.875, 0.125 do

		for y = 0, 0.875, 0.125 do
			local square, txt = createnicebutton(UDim2.fromScale(0.125, 0.125), UDim2.fromScale(x, y), "", squareholder)
			local flag = false

			square.MouseButton1Up:Connect(function()
				if firstclick then
					startgame(square)
					firstclick = false
				end
				if not donttrigger then
					if not placeflag then
						if not flag then
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
							flag = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(0.125, 0.125), Image = "rbxassetid://16268281465", Position = square.Position, BackgroundTransparency = 1})
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
		if selectedsize <= 5 then return end
		selectedsize -= 1
		textlabel2.Text = selectedsize
	end)

	enterbutton.MouseButton1Up:Connect(function()
		bombnumber = selectedsize
		frame1:Destroy()
		restartgamenow()
	end)
end

local loop1 = coroutine.create(function()
	while true do
		task.wait()
		if starttime then
			curtime.Text = math.floor(tick() - starttime)
		else
			curtime.Text = 0
		end
	end
end)
