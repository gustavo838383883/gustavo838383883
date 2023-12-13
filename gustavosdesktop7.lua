local SpeakerHandler = {
	_LoopedSounds = {},
	_ChatCooldowns = {}, -- Cooldowns of Speaker:Chat
	_SoundCooldowns = {}, -- Sounds played by SpeakerHandler.PlaySound
	DefaultSpeaker = nil,
}

function SpeakerHandler.Chat(text, cooldownTime, speaker)
	speaker = speaker or SpeakerHandler.DefaultSpeaker or error("[SpeakerHandler.Chat]: No speaker provided")

	if SpeakerHandler._ChatCooldowns[speaker.GUID..text] then
		return
	end

	speaker:Chat(text)

	if not cooldownTime then
		return
	end

	SpeakerHandler._ChatCooldowns[speaker.GUID..text] = true
	task.delay(cooldownTime, function()
		SpeakerHandler._ChatCooldowns[speaker.GUID..text] = nil
	end)
end

function SpeakerHandler.PlaySound(id, pitch, cooldownTime, speaker)
	speaker = speaker or SpeakerHandler.DefaultSpeaker or error("[SpeakerHandler.PlaySound]: No speaker provided")
	id = tonumber(id)
	pitch = tonumber(pitch) or 1

	if SpeakerHandler._SoundCooldowns[speaker.GUID..id] then
		return
	end

	speaker:Configure({Audio = id, Pitch = pitch})
	speaker:Trigger()

	if cooldownTime then
		SpeakerHandler._SoundCooldowns[speaker.GUID..id] = true

		task.delay(cooldownTime, function()
			SpeakerHandler._SoundCooldowns[speaker.GUID..id] = nil
		end)
	end
end

function SpeakerHandler:LoopSound(id, soundLength, pitch, speaker)
	speaker = speaker or SpeakerHandler.DefaultSpeaker or error("[SpeakerHandler:LoopSound]: No speaker provided")
	id = tonumber(id)
	pitch = tonumber(pitch) or 1
	
	if SpeakerHandler._LoopedSounds[speaker.GUID] then
		SpeakerHandler:RemoveSpeakerFromLoop(speaker)
	end
	
	speaker:Configure({Audio = id, Pitch = pitch})
	
	SpeakerHandler._LoopedSounds[speaker.GUID] = {
		Speaker = speaker,
		Length = soundLength / pitch,
		TimePlayed = tick()
	}
	
	speaker:Trigger()
	return true
end

function SpeakerHandler:RemoveSpeakerFromLoop(speaker)
	SpeakerHandler._LoopedSounds[speaker.GUID] = nil
	
	speaker:Configure({Audio = 0, Pitch = 1})
	speaker:Trigger()
end

function SpeakerHandler:UpdateSoundLoop(dt) -- Triggers any speakers if it's time for them to be triggered
	dt = dt or 0
	
	for _, sound in pairs(SpeakerHandler._LoopedSounds) do
		local currentTime = tick() - dt
		local timePlayed = currentTime - sound.TimePlayed

		if timePlayed >= sound.Length then
			sound.TimePlayed = tick()
			sound.Speaker:Trigger()
		end
	end
end

function SpeakerHandler:StartSoundLoop() -- If you use this, you HAVE to put it at the end of your code.
	
	while true do
		local dt = task.wait()
		SpeakerHandler:UpdateSoundLoop(dt)
	end
end

function SpeakerHandler.CreateSound(config: { Id: number, Pitch: number, Length: number, Speaker: any } ) -- Psuedo sound object, kinda bad
	config.Pitch = config.Pitch or 1
	
	local sound = {
		ClassName = "SpeakerHandler.Sound",
		Id = config.Id,
		Pitch = config.Pitch,
		_Speaker = config.Speaker or SpeakerHandler.DefaultSpeaker or error("[SpeakerHandler.CreateSound]: A speaker must be provided"),
		_OnCooldown = false, -- For sound cooldowns
		_Looped = false
	}
	
	if config.Length then
		sound.Length = config.Length / config.Pitch
	end
	
	function sound:Play(cooldownSeconds)
		if sound._OnCooldown then
			return
		end
		
		sound._Speaker:Configure({Audio = sound.Id, Pitch = sound.Pitch})
		sound._Speaker:Trigger()
		
		if not cooldownSeconds then
			return
		end
		
		sound._OnCooldown = true
		task.delay(cooldownSeconds, function()
			sound._OnCooldown = false
		end)
	end
	
	function sound:Stop()
		sound._Speaker:Configure({Audio = 0, Pitch = 1})
		sound._Speaker:Trigger()
		
		sound._OnCooldown = false
	end
	
	function sound:Loop()
		sound._Looped = true
		SpeakerHandler:LoopSound(sound.Id, sound.Length, sound.Pitch, sound._Speaker)
	end
	
	function sound:Destroy()
		if sound._Looped then
			SpeakerHandler:RemoveSpeakerFromLoop(sound._Speaker)
		end
		
		table.clear(sound)
	end
	
	return sound
end

local function createfileontable(disk, filename, filedata, directory)
	local returntable = nil
	local directory = directory
	if directory:sub(-1, -1) == "/" then directory = directory:sub(0, -2) end
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
			if tablez then
				local lasttable = nil
				local number = 1
				for i=#split - number,0,-1 do
					if i == #split - number and i ~= 0 then
						local temptable = tablez[i]
						if temptable then
							if typeof(temptable) == "table" then
								temptable[filename] = filedata
								lasttable = temptable
							end
						end
					end
					if i < #split-number and i >= 1 then
						if lasttable then
							local temptable = tablez[i]
							if typeof(temptable) == "table" then
								temptable[split[i+2]] = lasttable
								lasttable = temptable
							end
						end
					elseif i == 0 then
						returntable = lasttable
						if typeof(split[2]) == "table" then
							disk:Write(split[2], lasttable)
						end
					end
				end
			end
		end
	end
	return returntable
end

local function getfileontable(disk, filename, directory)
	local directory = directory
	if directory:sub(-1, -1) == "/" then directory = directory:sub(0, -2) end
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
local microcontrollers = nil
local regularscreen = nil
local keyboardinput
local playerthatinputted

local shutdownpoly = nil

local createwindow

local function getstuff()
	disks = nil
	rom = nil
	disk = nil
	screen = nil
	keyboard = nil
	speaker = nil
	shutdownpoly = nil
	modem = nil
	microcontrollers = nil
	regularscreen = nil

	for i=1, 128 do
		if not disks then
			success, Error = pcall(GetPartsFromPort, i, "Disk")
			if success then
				local disktable = GetPartsFromPort(i, "Disk")
				if disktable then
					if #disktable > 0 then
						disks = disktable
					end
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
	if disks then
		for i,v in pairs(disks) do
			rom = v
			table.remove(disks, i)
			break
		end
	end
end
getstuff()

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

local programholder1
local programholder2
local taskbarholder

local buttondown = false

local resolutionframe

local minimizedammount = 0

function createwindow(udim2, title, boolean, boolean2, boolean3, text, boolean4)
	local holderframe = screen:CreateElement("ImageButton", {Size = udim2, BackgroundTransparency = 1, Image = "rbxassetid://8677487226", ImageTransparency = 0.2})

	programholder1:AddChild(holderframe)
	local textlabel
	if typeof(title) == "table" then
		textlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1, -70, 0, 25), BackgroundTransparency = 1, Position = UDim2.new(0, 70, 0, 0), TextScaled = true, TextWrapped = true, Text = tostring(title)})
	end
	local resizebutton
	local maximizepressed = false
	if not boolean2 then
		resizebutton = screen:CreateElement("TextButton", {TextScaled = true, TextWrapped = true, Size = UDim2.new(0, 10, 0, 10), Text = "", Position = UDim2.new(1,-10,1,-10), BackgroundColor3 = Color3.new(1,1,1)})
		
		holderframe:AddChild(resizebutton)
		
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
			if not maximizepressed then
				programholder2:AddChild(holderframe)
				programholder1:AddChild(holderframe)
			else
				programholder1:AddChild(holderframe)
				programholder2:AddChild(holderframe)
			end
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
	local minimizebutton
	local taskbarholderscrollingframe
	
	if not boolean4 then
		minimizebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0,35,0,25), Image = "rbxassetid://15617867263", Position = UDim2.new(0, 70, 0, 0), BackgroundTransparency = 1})
		holderframe:AddChild(minimizebutton)
		local minimizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "↓"})
		minimizebutton:AddChild(minimizetext)
		if title then
			if textlabel then
				textlabel.Position += UDim2.new(0, 35, 0, 0)
				textlabel.Size -= UDim2.new(0, 35, 0, 0)
			end
		end
		minimizebutton.MouseButton1Down:Connect(function()
			minimizebutton.Image = "rbxassetid://15617866125"
		end)
		
		minimizebutton.MouseButton1Up:Connect(function()
			if holding or holding2 then return end
			speaker:PlaySound("rbxassetid://6977010128")
			minimizebutton.Image = "rbxassetid://15617867263"
			resolutionframe:AddChild(holderframe)
			local unminimizebutton = screen:CreateElement("ImageButton", {Image = "rbxassetid://15625805069", BackgroundTransparency = 1, Size = UDim2.new(0, 35, 1, 0), Position = UDim2.new(0, minimizedammount * 35, 0, 0)})
			local unminimizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(text)})
			unminimizebutton:AddChild(unminimizetext)
			table.insert(unminimizedprograms, unminimizebutton)
			taskbarholderscrollingframe:AddChild(unminimizebutton)
			taskbarholderscrollingframe.CanvasSize = UDim2.new(0, (maximizedammount * 35) + 35, 1, 0) 

			unminimizebutton.MouseButton1Down:Connect(function()
				unminimizebutton.Image = "rbxassetid://15625805069"
			end)
			unminimizebutton.MouseButton1Up:Connect(function()
				unminimizebutton.Image = "rbxassetid://15625805069"
				unminimizebutton:Destroy()
				minimizedammount -= 1
				local start = 0
				for index, value in pairs(minimizedprograms) do
					if value then
						value.Position = start * 35
						taskbarholderscrollingframe.CanvasSize = UDim2.new(0, (35 * start) + 35, 1, 0)
						start += 1
					end
				end
			end)
		end)
	end
	
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
			textlabel.Position -= UDim2.new(0, 35, 0, 0)
			textlabel.Size += UDim2.new(0, -35, 0, 0)
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

local name = "GustavOSDesktop7"

local function loaddesktop()
	minimizedammount = 0
	minimizedprograms = {}
	resolutionframe = screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Position = UDim2.new(2,0,0,0)})
	wallpaper = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), Image = "rbxassetid://15617469527", BackgroundTransparency = 1})
	
	startbutton7 = screen:CreateElement("ImageButton", {Image = "rbxassetid://15617867263", BackgroundTransparency = 1, Size = UDim2.new(0.1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)})
	local textlabel = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = "G", TextScaled = true, TextWrapped = true})
	startbutton7:AddChild(textlabel)
	
	local textlabel2 = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0.5,0,0.5,0), Position = UDim2.new(0.25, 0, 0.25, 0), Text = "GustavOS 7", TextScaled = true, TextWrapped = true})
	wallpaper:AddChild(textlabel2)

	programholder1 = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
	programholder2 = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
	programholder2:AddChild(programholder1)

	taskbarholder = screen:CreateElement("ImageButton", {Image = "rbxassetid://15619032563", Position = UDim2.new(0, 0, 0.9, 0), Size = UDim2.new(1, 0, 0.1, 0), BackgroundTransparency = 1, ImageTransparency = 0.2})
	taskbarholder:AddChild(startbutton7)

	taskbarholderscrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(0.9, 0, 1, 0), BackgroundTransparency = 1, CanvasSize = UDim2.new(0.9, 0, 1, 0), Position = UDim2.new(0.1, 0, 0, 0)})
	taskbarholder:AddChild(taskbarholderscrollingframe)
	rom:Write("GustavOSLibrary", {
		Screen = screen,
		Keyboard = keyboard,
		Modem = modem,
		Speaker = speaker,
		Disk = disk,
		programholder1 = programholder1,
		programholder2 = programholder2,
		Taskbar = {taskbarholderscrollingframe, taskbarholder},
	})
	local pressed = false
	local startmenu
	local function openstartmenu()
		if not pressed then
			startmenu = screen:CreateElement("ImageButton", {BackgroundTransparency = 1, Image = "rbxassetid://15619032563", Size = UDim2.new(0.3, 0, 0.5, 0), Position = UDim2.new(0, 0, 0.4, 0), ImageTransparency = 0.2})
			local testopen = screen:CreateElement("ImageButton", {Size = UDim2.new(1,0,0.2,0), Image = "rbxassetid://15625805900", Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
			startmenu:AddChild(testopen)
			local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Test"})
			testopen:AddChild(txtlabel)
			testopen.MouseButton1Down:Connect(function()
				testopen.Image = "rbxassetid://15625805069"
			end)
			testopen.MouseButton1Up:Connect(function()
				speaker:PlaySound("rbxassetid://6977010128")
				testopen.Image = "rbxassetid://15625805900"
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
	startbutton7.MouseButton1Down:Connect(function()
		startbutton7.Image = "rbxassetid://15617867263"
		buttondown = true
	end)
	startbutton7.MouseButton1Up:Connect(function()
		buttondown = false
		openstartmenu()
		speaker:PlaySound("rbxassetid://6977010128")
	end)
end

function bootos()
	if #disks > 0 then
		for i,v in pairs(disks) do
			disk = v
			break
		end
	end
	if screen and keyboard and speaker and disk then
		speaker:ClearSounds()
		screen:ClearElements()
		local commandlines = commandline.new(false, nil, screen)
		commandlines:insert(name.." Command line")
		task.wait(1)
		commandlines:insert("Welcome To "..name)
		task.wait(2)
		screen:ClearElements()
		loaddesktop()
		SpeakerHandler.PlaySound(182007357, 1, nil, speaker)
		keyboard:Connect("TextInputted", function(text, player)
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
			commandlines:insert("You need 2 or more disks on the same port.")
		end
		if keyboard then
			keyboard:Connect("KeyPressed", function(key)
				if key == Enum.KeyCode.Enter then
					bootos()
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
			commandlines:insert("You need 2 or more disks on the same port.")
		end
		if keyboard then
			keyboard:Connect("KeyPressed", function(key)
				if key == Enum.KeyCode.Enter then
					bootos()
				end
			end)
		end
	elseif not regularscreen and not screen then
		Beep(0.5)
		print("No screen was found.")
	end
end
bootos()

local cursorsinscreen = {}

while true do
	task.wait(0.01)
	if startbutton7 then
		local cursors = screen:GetCursors()
		local success = false
		if not buttondown then
			for index,cur in pairs(cursors) do
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
			if not cur["Player"] then return end
			if cur.Player == startCursorPos.Player then
				cursor = cur
				break
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
				end
			end
		end
	end
	
	if holding then
		if not holderframetouse then return end
		local cursors = screen:GetCursors()
		local cursor
		local success = false
		for index,cur in pairs(cursors) do
			if startCursorPos and cur then
				if cur.Player == startCursorPos.Player then
					cursor = cur
					success = true
				end
			end
		end
		if not success then holding = false end
		if cursor then
			local newX = (cursor.X - holderframetouse.AbsolutePosition.X) +5
			local newY = (cursor.Y - holderframetouse.AbsolutePosition.Y) +5
			local screenresolution = resolutionframe.AbsoluteSize

			if typeof(cursor["X"]) == "number" and typeof(cursor["Y"]) == "number" and typeof(screenresolution["X"]) == "number" and typeof(screenresolution["Y"]) == "number" and typeof(startCursorPos["X"]) == "number" and typeof(startCursorPos["Y"]) == "number" then
				if newX/screenresolution.X < 0.4 then newX = screenresolution.X * 0.4 end
				if newY/screenresolution.Y < 0.4 then newY = screenresolution.Y * 0.4 end
				if newX/screenresolution.X > 1 then newX = screenresolution.X end
				if newY/screenresolution.Y > 0.9 then newY = screenresolution.Y * 0.9 end
				if holderframetouse then
					holderframetouse.Size = UDim2.fromScale(newX/screenresolution.X, newY/screenresolution.Y)
				end
			end
		end
	end
	if screen then
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
end
