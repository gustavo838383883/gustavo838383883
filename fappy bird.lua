--[[

Fappy bird test

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
local disk = gputer.Disk

local window, holderframe = CreateWindow(UDim2.fromScale(0.7, 0.7), "Fappy bird", false, false, false, "Fappy bird", false, false)


local function GetCollidingGuiObjects(gui, folder)

	if gui then
		if not folder then print("Table was not specified.") return end

		if type(folder) ~= "table" then print("The specified table is not a valid table") return end

		if gui.ClassName == "Frame" or gui.ClassName == "ImageLabel" or gui.ClassName == "TextLabel" or gui.ClassName == "TextButton" then
			local instances = {}

			for i, ui in pairs(folder) do

				if ui.ClassName == "Frame" or ui.ClassName == "ImageLabel" or ui.ClassName == "TextLabel" or ui.ClassName == "TextButton" then
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

local jumpbutton = Object.new("JumpButton", "TextButton", false)
local bird
local bestscore = tonumber(disk:Read("FappyBirdBestScore")) or 0
local scorenumber = 0

jumpbutton.Instance:ChangeProperties({Transparency = 1, Size = UDim2.fromScale(1, 1)})

local restartGAME

function died()
	for index, value in pairs(GAME.Workspace:GetObjects()) do
		if string.find(tostring(index), "Pipe") then
			value:Destroy()
		end
	end
	if scorenumber > bestscore then
		bestscore = scorenumber
		disk:Write("FappyBirdBestScore", bestscore)
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

function restartGAME()

	local wallpaper = Object.new("Wallpaper", "ImageLabel", false)

	wallpaper.Instance:ChangeProperties({BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Image = "rbxassetid://149868773"})

	bird = Object.new("Bird", "ImageLabel", false)

	bird.Instance:ChangeProperties({Size = UDim2.fromScale(0.15, 0.15), Position = UDim2.fromScale(0.2, 0.3), BackgroundTransparency = 1, Image = "rbxassetid://347189324"})

	local loop = GAME.LoopService.new()

	local pipeholder = Object.new("Pipeholder", "Frame", false)

	local score = Object.new("Score", "TextLabel", false)

	score.Instance:ChangeProperties({Size = UDim2.fromScale(1, 0.2), BackgroundTransparency = 1, TextScaled = true, Text = "0", TextColor3 = Color3.new(1, 1, 1)})

	local pipenumber = 0

	pipeholder.Instance:ChangeProperties({Size = UDim2.fromScale(1, 1), Transparency = 1})

	local loop1

	local function disconnectloop1()
		loop1:Disconnect()
	end

	local prevtime = 0
	local prevdistancex = -pipeholder.Instance.AbsoluteSize.X/2
	local newposx = 0
	local successpipes = {}
	local ended = false
	local pipeholdersize = pipeholder.Instance.AbsoluteSize
	local windowres = window.AbsoluteSize
	local pipeholderpos = Vector2.new(0, 0)
	loop1 = loop:Connect(function(delta, time)
		if time - prevtime < 0.02 then return end
		if ended then disconnectloop1() return end
		prevtime = time

		if not window then disconnectloop1() end

		if not pipeholder then return end
		
		if not bird then return end

		pipeholder.Instance.Position -= UDim2.fromScale(0.01, 0)
		pipeholderpos -= Vector2.new(windowres.X * 0.01, 0)
		newposx += 0.01

		for i=1,pipenumber do
			local pipe = GAME.Workspace["Pipe"..i]
			if pipe then
				if pipe.Instance.AbsolutePosition.X + pipe.Instance.AbsoluteSize.X < holderframe.AbsolutePosition.X then
					pipe:Destroy()
				end
			end
		end

		for index, value in pairs(GAME.Workspace:GetObjects()) do
			if value["PrimaryPipe"] == true then
				if not table.find(successpipes, index) then
					if bird.Instance.AbsolutePosition.X > value.Instance.AbsolutePosition.X then
						table.insert(successpipes, index)
						scorenumber += 1
						score.Instance.Text = scorenumber
						speaker:Configure({Audio = 144686873})
						speaker:Trigger()
					end
				end
			end
		end

		if prevdistancex - pipeholderpos.X > pipeholdersize.X/2 then
			pipenumber += 1
			local pipetest = Object.new("Pipe"..pipenumber, "ImageLabel", true)

			pipetest["PrimaryPipe"] = true
			
			local random1 = math.random(1, 3)
			local pipetest2
			if random1 == 2 then
				pipenumber += 1
				pipetest2 = Object.new("Pipe"..pipenumber, "ImageLabel", true)
			end

			local pipepos = UDim2.fromScale(-pipeholder.Instance.Position.X.Scale + newposx, 0)

			pipetest.Instance:ChangeProperties({Size = UDim2.fromScale(0.2, if random1 == 2 then 0.3 else 0.6), Position = if random1 ~= 3 then pipepos else pipepos + UDim2.fromScale(0, 0.4), BackgroundTransparency = 1, Image = "rbxassetid://14410471826"})
			
			if random1 == 2 then
				pipetest2.Instance:ChangeProperties({Size = UDim2.fromScale(0.2, 0.3), Position = pipepos + UDim2.fromScale(0, 0.7), BackgroundTransparency = 1, Image = "rbxassetid://14410471826"})
				pipetest2["PrimaryPipe"] = false
				pipeholder.Instance:AddChild(pipetest2.Instance)
			end

			pipeholder.Instance:AddChild(pipetest.Instance)

			prevdistancex = pipeholderpos.X
		end

		local colliding = bird:GetCollidingInstances()

		if #colliding > 0 then
			bird:Destroy()
			bird = nil
			wallpaper:Destroy()
			wallpaper = nil
			pipeholder:Destroy()
			pipeholder = nil
			score:Destroy()
			score = nil
			disconnectloop1()
			ended = true
			died()
		end

		bird.Instance.Position += UDim2.fromScale(0, 0.02)
		if bird.Instance.Position.Y.Scale > 1 then
			bird:Destroy()
			bird = nil
			wallpaper:Destroy()
			wallpaper = nil
			pipeholder:Destroy()
			pipeholder = nil
			score:Destroy()
			score = nil
			disconnectloop1()
			ended = true
			died()
		end
	end)
end

local function startgame()
	local text1 = Object.new("StartText", "TextLabel", false)
	text1.Instance:ChangeProperties({BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0.5), TextScaled = true, Text = "Fappy Bird"})

	local text2 = Object.new("StartText2", "TextLabel", false)
	text2.Instance:ChangeProperties({BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0.2), Position = UDim2.fromScale(0, 0.5), TextScaled = true, Text = "Warning: Don't resize or move the window while playing"})

	local button1 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.8), "Start", GAME.Holder)

	button1.MouseButton1Up:Connect(function()
		text1:Destroy()
		text2:Destroy()
		button1:Destroy()
		restartGAME()
	end)
end

startgame()

jumpbutton.Instance.MouseButton1Click:Connect(function()
	if bird then
		for i=1,6 do
			task.wait(0.01)
			if not bird then break end
			if bird.Instance.Position.Y.Scale >= 0 then
				bird.Instance.Position -= UDim2.fromScale(0, 0.04)
			end
			if i <= 3 then
				bird.Instance.Rotation -= 15
			else
				bird.Instance.Rotation += 15
			end
		end
	end
end)
