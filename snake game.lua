--[[

snake game test

test
test
test
test
]]--




local gputer = GetPartFromPort(1, "Disk"):Read("GD7Library")

local screen = gputer.Screen
local CreateWindow = gputer.CreateWindow
local createnicebutton = gputer.createnicebutton
local speaker = gputer.Speaker
local keyboard = gputer.Keyboard
local disk = gputer.Disk

local window, holderframe = CreateWindow(UDim2.fromScale(0.7, 0.7), "Snake", false, false, false, "Snake", false, false)


local function GetCollidingGuiObjects(gui, folder)

	if gui then
		if not folder then print("Table was not specified.") return end

		if type(folder) ~= "table" then print("The specified table is not a valid table") return end

		if gui.ClassName == "Frame" or gui.ClassName == "ImageLabel" or gui.ClassName == "TextLabel" or gui.ClassName == "TextButton" then
			local instances = {}

			for i, ui in pairs(folder) do

				if ui.ClassName == "Frame" or ui.ClassName == "ImageLabel" or ui.ClassName == "TextLabel" or ui.ClassName == "TextButton" and ui ~= gui then
					if ui.Visible then
						local x = ui.AbsolutePosition.X
						local y = ui.AbsolutePosition.Y
						local y_axis = false
						local x_axis = false
						local guiposx = gui.AbsolutePosition.X + gui.AbsoluteSize.X
						local number = ui.AbsoluteSize.X + gui.AbsoluteSize.X

						if x - guiposx > -number then
							if x - guiposx <= 0 then
								x_axis = true
							end
						end

						local guiposy = gui.AbsolutePosition.Y + gui.AbsoluteSize.Y
						local number2 = ui.AbsoluteSize.Y + gui.AbsoluteSize.Y

						if y - guiposy > -number2 then
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

local GAME = {
	Holder = screen:CreateElement("ScrollingFrame", {CanvasSize = UDim2.fromScale(0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)}),
	Workspace = {
		["ClassName"] = "Workspace"
	},
	LoopService = {
		["ClassName"] = "LoopService"
	}
}

window:AddChild(GAME.Holder)

function GAME.LoopService:GetObjects()
	return {}
end

GAME.LoopService.new = function()

	local Loop = {
		RunCoroutine = nil,
		Functions = {}
	}

	function Loop:Connect(func)

		if Loop["RunCoroutine"] then
			coroutine.close(Loop["RunCoroutine"])
			Loop["RunCoroutine"]  = nil
		end

		table.insert(Loop["Functions"], func)

		local index = #Loop["Functions"]

		Loop["RunCoroutine"] = coroutine.create(function()
			local runtime = 0
			while true do
				local delta = task.wait()
				runtime += delta
				for i, v in ipairs(Loop["Functions"]) do
					if typeof(v) == "function" then
						v(delta, runtime)
					end
				end
			end
		end)
	
		coroutine.resume(Loop["RunCoroutine"])
	
		local signal1 = {
			ClassName = "LoopSignal"
		}

		function signal1:Disconnect()
			Loop["Functions"][index] = false
		end

		function signal1:Pause()
			pcall(function()
				coroutine.yield(Loop["RunCoroutine"])
			end)
		end

		function signal1:Resume()
			coroutine.Resume(Loop["RunCoroutine"])
		end

		return signal1
	end

	function Loop:StopLoops()
		coroutine.close(Loop["RunCoroutine"])
		Loop["Functions"] = {}
	end

	function Loop:Pause(signal1)
		assert(typeof(signal1) == "table", "The given argument is not a Table.")
		assert(signal1["ClassName"] == "LoopSignal", "The given argument is not a LoopSignal.")

		if typeof(signal1) == "table" and signal1["ClassName"] == "LoopSignal" then
			signal1:Pause()
		end
	end

	function Loop:Resume(signal1)
		assert(typeof(signal1) == "table", "The given argument is not a Table.")
		assert(signal1["ClassName"] == "LoopSignal", "The given argument is not a LoopSignal.")

		if typeof(signal1) == "table" and signal1["ClassName"] == "LoopSignal" then
			signal1:Resume()
		end
	end

	function Loop:Disconnect(signal1)
		assert(typeof(signal1) == "table", "The given argument is not a Table.")
		assert(signal1["ClassName"] == "LoopSignal", "The given argument is not a LoopSignal.")

		if typeof(signal1) == "table" and signal1["ClassName"] == "LoopSignal" then
			signal1:Disconnect()
		end
	end


	function Loop:Wait()
		return task.wait()
	end

	function Loop:Disconnect()
		if Loop["RunCoroutine"] then
			coroutine.close(Loop["RunCoroutine"])
			Loop["RunCoroutine"] = nil
		end

		Loop = nil
	end

	return Loop
end

function GAME.Workspace:GetObjects()
	local objects = {}

	for index, value in pairs(GAME.Workspace) do
		if typeof(value) == "table" and value["ClassName"] == "Object" then
			objects[index] = value
		end
	end

	return objects
end

function GAME.Workspace.Changed()
	local prevstate = GAME.Workspace
	local loopcoroutine = coroutine.create(function()
		while prevstate == GAME.Workspace do
			task.wait()
		end
		func()
		prevstate = GAME.Workspace
	end)

	coroutine.resume(loopcoroutine)

	local tabletoreturn = {
		["ClassName"] = "ChangedEvent"
	}

	function tabletoreturn:Unbind()
		coroutine.close(loopcoroutine)
	end

	function tabletoreturn:Bind()
		coroutine.resume(loopcoroutine)
	end

	return tabletoreturn
end

function GAME:GetService(name)
	if name == "Workspace" then
		return GAME.Workspace
	elseif name == "Holder" then
		return GAME.Holder
	elseif name == "LoopService" then
		return GAME.LoopService
	else
		error("Invalid Service")
	end
end

local Object = {}

function Object.new(name: string, ClassName: string, boolean: boolean)

	if typeof(name) ~= "string" then error("Name is not a string") end
	if typeof(ClassName) ~= "string" then error("ClassName is not a string") end

	if name == "Workspace" then error("Name can't be Workspace") end

	local guiobject = screen:CreateElement(ClassName, {Size = UDim2.fromScale(0, 0)})

	local object = {
		ClassName = "Object",
		Name = name,
		Instance = guiobject,
		CanCollide = if boolean == false then false else true
	}

	GAME.Holder:AddChild(guiobject)

	function object:GetPropertyChanged(property, func)
		if not object then return end
		local gui = object.Instance
		local prevproperty = gui[property]
		local loopcoroutine = coroutine.create(function()
			while prevproperty == gui[property] do
				task.wait()
			end
			func(gui[property])
			prevproperty = gui[property]
		end)

		coroutine.resume(loopcoroutine)

		local tabletoreturn = {
			["ClassName"] = "PropertyChangedEvent"
		}

		function tabletoreturn:Unbind()
			coroutine.close(loopcoroutine)
		end

		function tabletoreturn:Bind()
			coroutine.resume(loopcoroutine)
		end

		return tabletoreturn
	end

	function object:GetCollidingInstances()
		if not object then return end
		local tabletogive = {}

		for index, value in pairs(GAME.Workspace:GetObjects()) do
			if value["CanCollide"] == true and index ~= name then
				table.insert(tabletogive, value["Instance"])
			end
		end
		local Collidingtable = GetCollidingGuiObjects(guiobject, tabletogive)
		return Collidingtable
	end

	function object:Destroy()
		object.Instance:Destroy()
		object = nil
		GAME.Workspace[name] = nil
	end

	GAME.Workspace[name] = object
	
	return GAME.Workspace[name]
end

local died

local bestscore = tonumber(disk:Read("SnakeBestScore")) or 0
local scorenumber = 0
local paused = false

local restartGAME

function died()
	paused = false
	for index, value in pairs(GAME.Workspace:GetObjects()) do
		value:Destroy()
	end
	if scorenumber > bestscore then
		bestscore = scorenumber
		disk:Write("SnakeBestScore", bestscore)
	end
	scorenumber = 0
	speaker:Configure({Audio = 144686858})
	speaker:Trigger()
	local text1 = Object.new("DiedText", "TextLabel", false)
	text1.Instance:ChangeProperties({BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0.5), TextScaled = true, Text = "You died!"})

	local text2 = Object.new("BestScoreText", "TextLabel", false)
	text2.Instance:ChangeProperties({BackgroundTransparency = 1, Size = UDim2.fromScale(0.5, 0.2), Position = UDim2.fromScale(0, 0.5), TextScaled = true, Text = "Best score:"})

	local text3 = Object.new("BestScorNumber", "TextLabel", false)
	text3.Instance:ChangeProperties({BackgroundTransparency = 1, Size = UDim2.fromScale(0.5, 0.2), Position = UDim2.fromScale(0.5, 0.5), TextScaled = true, Text = bestscore or 0})

	local button1 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.8), "Restart", GAME.Holder)

	button1.MouseButton1Up:Connect(function()
		text1:Destroy()
		text2:Destroy()
		text3:Destroy()
		button1:Destroy()
		restartGAME()
	end)
end

function youwon()
	paused = false
	for index, value in pairs(GAME.Workspace:GetObjects()) do
		value:Destroy()
	end
	if scorenumber > bestscore then
		bestscore = scorenumber
		disk:Write("SnakeBestScore", bestscore)
	end
	scorenumber = 0
	speaker:Configure({Audio = 144686858})
	speaker:Trigger()
	local text1 = Object.new("WonText", "TextLabel", false)
	text1.Instance:ChangeProperties({BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0.5), TextScaled = true, Text = "You won!"})

	local text2 = Object.new("BestScoreText", "TextLabel", false)
	text2.Instance:ChangeProperties({BackgroundTransparency = 1, Size = UDim2.fromScale(0.5, 0.2), Position = UDim2.fromScale(0, 0.5), TextScaled = true, Text = "Best score:"})

	local text3 = Object.new("BestScorNumber", "TextLabel", false)
	text3.Instance:ChangeProperties({BackgroundTransparency = 1, Size = UDim2.fromScale(0.5, 0.2), Position = UDim2.fromScale(0.5, 0.5), TextScaled = true, Text = bestscore or 0})

	local button1 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.8), "Restart", GAME.Holder)

	button1.MouseButton1Up:Connect(function()
		text1:Destroy()
		text2:Destroy()
		text3:Destroy()
		button1:Destroy()
		restartGAME()
	end)
end

local snakeparts = {}
local snakehead = nil
local direction = "right"
local apple = nil

local function spawnapple()

	local usedpositions = {}

	for i, v in pairs(GAME.Workspace:GetObjects()) do
		if string.find(i, "SnakePart") then
			table.insert(usedpositions, v.Instance.Position)
		end
	end

	local poslist = {}

	for x = 0, 0.875, 0.125 do
		for y = 0, 0.875, 0.125 do
			local udim2 = UDim2.fromScale(x, y)
			if not table.find(usedpositions, udim2) then
				table.insert(poslist, udim2)
			end
		end
	end

	if #poslist > 0 then

		local random1 = math.random(1, #poslist)

		apple = Object.new("ApplePart", "ImageLabel", false)

		apple.Instance:ChangeProperties({Size = UDim2.fromScale(0.125, 0.125), Position = poslist[random1], BackgroundTransparency = 1, Image = "rbxassetid://16098315503"})
	else
		youwon()
	end

end

function restartGAME()
	paused = false

	local loop = GAME.LoopService.new()

	local pipeholder = Object.new("Pipeholder", "Frame", false)

	local score = Object.new("Score", "TextLabel", false)

	score.Instance:ChangeProperties({ZIndex = 2, Size = UDim2.fromScale(1, 0.2), BackgroundTransparency = 1, TextScaled = true, Text = "0", TextColor3 = Color3.new(1, 1, 1)})

	local pipenumber = 0

	pipeholder.Instance:ChangeProperties({Size = UDim2.fromScale(1, 1), Transparency = 1})

	local loop1

	local function disconnectloop1()
		loop1:Disconnect()
	end

	snakehead = Object.new("SnakePart1", "Frame", false)

	local snakeinstance = snakehead.Instance

	snakeinstance:ChangeProperties({Size = UDim2.fromScale(0.125, 0.125), BackgroundColor3 = Color3.fromRGB(0, 200, 200), Position = UDim2.fromScale(0.375, 0.375)})
	
	spawnapple()

	local prevtime = 0
	local ended = false
	loop1 = loop:Connect(function(delta, time)
		local timetowait = 0.5

		if snakehead then
			if snakeinstance.Position.X.Scale >= 0.875 or snakeinstance.Position.Y.Scale >= 0.875 or snakeinstance.Position.X.Scale <= 0.125 or snakeinstance.Position.Y.Scale <= 0.125 then
				timetowait = 0.75
			end
		end
		if time - prevtime < 0.5 then return end
		if paused then return end
		if ended then disconnectloop1() return end
		prevtime = time

		if not window then disconnectloop1() end

		local prevsnakepos = snakeinstance.Position

		if direction == "right" then
			snakeinstance.Position += UDim2.fromScale(0.125, 0)
		elseif direction == "left" then
			snakeinstance.Position -= UDim2.fromScale(0.125, 0)
		elseif direction == "up" then
			snakeinstance.Position -= UDim2.fromScale(0, 0.125)
		elseif direction == "down" then
			snakeinstance.Position += UDim2.fromScale(0, 0.125)
		end

		local table1 = {}

		for index, value in ipairs(snakeparts) do
			if value["CanCollide"] and value.Name ~= snakehead.Name then
				table.insert(table1, value.Instance)
			end
		end

		local colliding = false

		for index, value in pairs(snakeparts) do
			if value.Instance.Position == snakeinstance.Position and value.CanCollide == true then
				colliding = true
				break
			end
		end

		if colliding then
			snakehead:Destroy()
			snakehead = nil
			snakeparts = {}
			score:Destroy()
			score = nil
			disconnectloop1()
			ended = true
			apple = nil
			died()
		end

		for i,v in ipairs(snakeparts) do
			local oldpos = v.Instance.Position
			v.Instance.Position = prevsnakepos
			if v.Name ~= snakehead.Name and v.Instance.Position ~= snakehead.Instance.Position then
				v.CanCollide = true
			else
				v.CanCollide = false
			end

			prevsnakepos = oldpos
		end

		if apple and snakeinstance.Position == apple.Instance.Position then
			apple:Destroy()
			local snakepart = Object.new("SnakePart"..#snakeparts + 2, "Frame", false)
			local snakeinstance = snakepart.Instance

			local newpos

			if #snakeparts > 0 then
				newpos = snakeparts[#snakeparts].Instance.Position
			else
				newpos = snakehead.Instance.Position
			end

			scorenumber += 1

			GAME.Workspace.Score.Instance.Text = scorenumber

			snakeinstance:ChangeProperties({Size = UDim2.fromScale(0.125, 0.125), BackgroundColor3 = Color3.fromRGB(0, 100, 200), Position = newpos})

			table.insert(snakeparts, snakepart)

			speaker:Configure({Audio = 12544690})
			speaker:Trigger()

			spawnapple()
		end
		
		if snakeinstance.Position.X.Scale >= 1 or snakeinstance.Position.X.Scale < 0 or snakeinstance.Position.Y.Scale >= 1 or snakeinstance.Position.Y.Scale < 0 then
			snakehead:Destroy()
			snakehead = nil
			snakeparts = {}
			score:Destroy()
			score = nil
			disconnectloop1()
			ended = true
			apple = nil
			died()
		end
	end)
end

keyboard:Connect("KeyPressed", function(key)

	if key == Enum.KeyCode.W then
		if direction == "down" then return end
		direction = "up"
	end

	if key == Enum.KeyCode.S then
		if direction == "up" then return end
		direction = "down"
	end

	if key == Enum.KeyCode.D then
		if direction == "left" then return end
		direction = "right"
	end

	if key == Enum.KeyCode.A then
		if direction == "right" then return end
		direction = "left"
	end

	if key == Enum.KeyCode.K then
		paused = not paused
	end
end)

local function startgame()
	local text1 = Object.new("StartText", "TextLabel", false)
	text1.Instance:ChangeProperties({BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0.5), TextScaled = true, Text = "Snake"})

	local button1 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.8), "Start", GAME.Holder)

	button1.MouseButton1Up:Connect(function()
		text1:Destroy()
		button1:Destroy()
		restartGAME()
	end)
end

startgame()
