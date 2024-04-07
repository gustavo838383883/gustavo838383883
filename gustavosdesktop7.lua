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
						if typeof(disk:Read(split[2])) == "table" then
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
local microphoneevent
local playerthatinputted
local backgroundimage
local color
local iconsdisabled
local iconsize
local tile = false
local tilesize
local microphonefuncs = {}
local clicksound
local startsound
local shutdownsound
local romport
local disksport
local romindexusing
local sharedport
local microphone = nil

local bootos

local shutdownpoly = nil

local CreateWindow

local disk6 =  GetPartFromPort(6, "Disk")
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
	shutdownpoly = nil
	modem = nil
	microcontrollers = nil
	regularscreen = nil
	disksport = nil
	romport = nil
	romindexusing = nil
	sharedport = nil
	microphone = nil

	for i=1, 128 do
		if not rom then
			local cancel = false
			if i ~= 6 and putermode then
				cancel = true
			end
			if not cancel then
    				success, Error = pcall(GetPartFromPort, i, "Disk")
    				if success then
    					local temprom = GetPartFromPort(i, "Disk")
    					if temprom then
	    					if #(temprom:ReadEntireDisk()) == 0 then
	    						rom = temprom
	    						romport = i
	    					elseif temprom:Read("GD7Library") then
	    						if temprom:Read("GustavOSLibrary") then
	    							temprom:Write("GustavOSLibrary", nil)
	    						end
	    						rom = temprom
	    						romport = i
	    					elseif #(temprom:ReadEntireDisk()) == 1 and temprom:Read("GDOSLibrary") then
	    						temprom:Write("GDOSLibrary", nil)
	    						rom = temprom
	    						romport = i
    						end
    					end
				end
			end
		end
		if not disks then
			success, Error = pcall(GetPartsFromPort, i, "Disk")
			if success then
				local disktable = GetPartsFromPort(i, "Disk")
				if disktable then
					if #disktable > 0 then
						local cancel = false
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
		end

		if disks and #disks > 1 and romport == disksport and not sharedport then
			local cancel = false
			if i ~= 6 and putermode then
				cancel = true
			end

			if not cancel then
				for index,v in ipairs(disks) do
					if v then
						if #(v:ReadEntireDisk()) == 0 then
							rom = v
							romport = i
							romindexusing = index
							sharedport = true
							break
						elseif v:Read("GD7Library") then
							if v:Read("GustavOSLibrary") then
								v:Write("GustavOSLibrary", nil)
							end
							if v:Read("GDOSLibrary") then
								v:Write("GDOSLibrary", nil)
							end
							rom = v
							romindexusing = index
							romport = i
							sharedport = true
							break
						elseif #(v:ReadEntireDisk()) == 1 and v:Read("GustavOSLibrary") or v:Read("GDOSLibrary") then
							v:Write("GustavOSLibrary", nil)
							v:Write("GDOSLibrary", nil)
							rom = v
							romport = i
							romindexusing = index
							sharedport = true
							break
						end
					end
				end
			end
		end

		if not microcontrollers then
			local cancel = false
			if i ~= 6 and putermode then
				cancel = true
			end
			if not cancel then
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
		end

		if not modem then
			success, Error = pcall(GetPartFromPort, i, "Modem")
			if success then
				if GetPartFromPort(i, "Modem") then
					modem = GetPartFromPort(i, "Modem")
				end
			end
		end

		if not microphone then
			success, Error = pcall(GetPartFromPort, i, "Microphone")
			if success then
				if GetPartFromPort(i, "Microphone") then
					microphone = GetPartFromPort(i, "Microphone")
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

local success, Error1 = pcall(function()
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

	local buttondown = false
	local taskbarholderscrollingframe

	local resolutionframe

	local minimizedammount = 0

	function CreateWindow(udim2, title, boolean, boolean2, boolean3, text, boolean4, boolean5, boolean6)
		local holderframe = screen:CreateElement("ImageButton", {Size = udim2, BackgroundTransparency = 1, Image = "rbxassetid://8677487226", ImageTransparency = 0.2})
		if not holderframe then return end
		programholder1:AddChild(holderframe)
		
		for i, v in ipairs(windows) do
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
			holderframe:AddChild(textlabel)
		end
		local window = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1,0,1,-(defaultbuttonsize.Y + (defaultbuttonsize.Y/2))), CanvasSize = UDim2.new(1,0,1,-(defaultbuttonsize.Y + (defaultbuttonsize.Y/2))), Position = UDim2.new(0, 0, 0, defaultbuttonsize.Y), BackgroundTransparency = 1})
		holderframe:AddChild(window)
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
			holderframe:AddChild(resizebutton)

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

		function functions:IsMaximizedDisabled()
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
			windows[frameindex].Focused = false
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
			if closed or not holderframe then
				return true
			else
				return false
			end
		end

		function functions:IsFocused()
			return windows[frameindex].Focused
		end

		function functions:Minimize(mintext)
			if not mintext then mintext = text end
			if holding or holding2 then return end
			if minimizepressed then return end
			if boolean4 then return end
			resolutionframe:AddChild(holderframe)
			holderframe.Visible = false
			minimizepressed = true
			windows[frameindex].Focused = false
			local unminimizebutton = screen:CreateElement("ImageButton", {Image = "rbxassetid://15625805900", BackgroundTransparency = 1, Size = UDim2.new(0, defaultbuttonsize.X*2, 1, 0), Position = UDim2.new(0, minimizedammount * (defaultbuttonsize.X*2), 0, 0)})
			local unminimizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = if typeof(mintext) == "function" then tostring(mintext()) else tostring(mintext)})
			unminimizebutton:AddChild(unminimizetext)
			taskbarholderscrollingframe:AddChild(unminimizebutton)
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
				for i, v in ipairs(windows) do
					v.Focused = false

					if v.CloseButton then
						v.CloseButton.Image = "rbxassetid://16821401308"
					end
				end
	
				windows[frameindex].Focused = true

				if closebutton then
					closebutton.Image = "rbxassetid://15617983488"
				end
				
				if holderframe then
					programholder1:AddChild(holderframe)
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
				window:AddChild(child)
			end
		end

		function functions:CreateElement(name: string, properties: {any})			
			local object = screen:CreateElement(name, properties)

			if object then
				window:AddChild(object)
			end

			return object
		end
		
		if not boolean2 then
			createresizebutton()
		else
			window.Size += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
			window.CanvasSize += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
		end
		
		holderframe.MouseButton1Down:Connect(function()
			if holding then return end
			programholder2:AddChild(holderframe)
			programholder1:AddChild(holderframe)
			for i, v in ipairs(windows) do
				v.Focused = false

				if v.CloseButton then
					v.CloseButton.Image = "rbxassetid://16821401308"
				end
			end

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

		closebutton = screen:CreateElement("ImageButton", {BackgroundTransparency = 1, Size = UDim2.new(0, defaultbuttonsize.X, 0, defaultbuttonsize.Y), BackgroundColor3 = Color3.new(1,0,0), Image = "rbxassetid://15617983488"})
		holderframe:AddChild(closebutton)

		closebutton.MouseButton1Down:Connect(function()
			closebutton.Image = "rbxassetid://15617984474"
		end)

		closebutton.MouseButton1Up:Connect(function()
			closebutton.Image = "rbxassetid://15617983488"
			speaker:PlaySound(clicksound)
			functions:Close()
		end)

		if not boolean4 then
			minimizebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0,defaultbuttonsize.X,0,defaultbuttonsize.Y), Image = "rbxassetid://15617867263", Position = UDim2.new(0, defaultbuttonsize.X*2, 0, 0), BackgroundTransparency = 1})
			holderframe:AddChild(minimizebutton)
			local minimizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "↓"})
			minimizebutton:AddChild(minimizetext)
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
			maximizebutton:AddChild(maximizetext)

			holderframe:AddChild(maximizebutton)

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
			holderframe:AddChild(child)
		end
	
		windowmeta = setmetatable(prevfunctions, {
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

	function commandline.new(boolean, udim2, screen)
		local holderframe
		local background
		local lines = {
			number = 0
		}
		if boolean then
			holderframe = CreateWindow(udim2, "Command Line", false, false, false, "Command Line", false)
			background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0), Position = UDim2.new(0, 0, 0, 0)})
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
	local backgroundcolor

	local function createnicebutton(udim2, pos, text, Parent)
		local txtbutton = screen:CreateElement("ImageButton", {Size = udim2, Image = "rbxassetid://15625805900", Position = pos, BackgroundTransparency = 1})
		local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(text), RichText = true})
		txtbutton:AddChild(txtlabel)
		if Parent then
			Parent:AddChild(txtbutton)
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
		txtbutton:AddChild(txtlabel)
		if Parent then
			Parent:AddChild(txtbutton)
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

	local function MicrophoneChatted(func)
		if not microphone then return end
		local returntable = {
			["Function"] = func
		}

		if microphoneevent then microphoneevent:Unbind() end

		table.insert(microphonefuncs, func)

		local index = #microphonefuncs

		function returntable:Unbind()
			microphonefuncs[index] = false
		end

		microphoneevent = microphone:Connect("Chatted", function(player, text)
			for index, value in ipairs(microphonefuncs) do
				if typeof(value) == "function" then
					value(player, text)
				end
			end
		end)

		return returntable
	end

	local function StringToGui(screen, text, parent)
		local start = UDim2.new(0,0,0,0)
		local source = string.lower(text)

		for name, value in source:gmatch('<backimg(.-)(.-)>') do
			local link = nil
			if (string.find(value, 'src="')) then
				local link = string.sub(value, string.find(value, 'src="') + string.len('src="'), string.len(value))
				link = string.sub(link, 1, string.find(link, '"') - 1)
				if not(string.find(value, "load")) then

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
						url.ImageTransparency = tonumber(text)
					end
					parent:AddChild(url)
				end
			end
		end
		for name, value in source:gmatch('<frame(.-)(.-)>') do
			local link = nil
			if not(string.find(value, "load")) then

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
					url.Transparency = tonumber(text)
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
				parent:AddChild(url)
			end
		end
		for name, value in source:gmatch('<img(.-)(.-)>') do
			local link = nil
			if (string.find(value, 'src="')) then
				local link = string.sub(value, string.find(value, 'src="') + string.len('src="'), string.len(value))
				link = string.sub(link, 1, string.find(link, '"') - 1)
				if not(string.find(value, "load")) then

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
						url.ImageTransparency = tonumber(text)
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
					parent:AddChild(url)
				end
			end
		end
		for name, value in source:gmatch('<txt(.-)(.-)>') do
			local link = nil
			if (string.find(value, 'display="')) then
				local link = string.sub(value, string.find(value, 'display="') + string.len('display="'), string.len(value))
				link = string.sub(link, 1, string.find(link, '"') - 1)
				if not(string.find(value, "load")) then

					local url = screen:CreateElement("TextLabel", { })
					url.BackgroundTransparency = 1
					url.Size = UDim2.new(0, 250, 0, 50)

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
					parent:AddChild(url)
				end
			end
		end
	end

	local function woshtmlfile(txt, screen, boolean, name)
		local size = UDim2.new(0.7, 0, 0.7, 0)

		if boolean then
			size = UDim2.new(0.5, 0, 0.5, 0)
		end
		local filegui = CreateWindow(size, nil, false, false, false, name or "File", false)
		local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
		filegui:AddChild(scrollingframe)

		StringToGui(screen, txt, scrollingframe)

	end

	local function videoplayer(id, name)
		local window = CreateWindow(UDim2.fromScale(0.7, 0.7), nil, false, false, false, name or "Video", false)

		local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.fromScale(1, 0.85), BackgroundTransparency = 1, Video = "rbxassetid://"..id, Volume = math.floor(videovolume*10)/10})
		window:AddChild(videoframe)

		local playpause = createnicebutton2(UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0, 0.85), "Play", window)
		local loop, text1 = createnicebutton2(UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0.15, 0.85), "Loop", window)

		local up = createnicebutton2(UDim2.fromScale(0.15, 0.15), UDim2.fromScale(0.85, 0.85), "+", window)
		local ammount = screen:CreateElement("TextLabel", {Text = videovolume, Size = UDim2.fromScale(0.1, 0.15), Position = UDim2.fromScale(0.75, 0.85), TextScaled = true, BackgroundTransparency = 1})
		window:AddChild(ammount)
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
		local color, color2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0, 0), "RGB (Click to update)", holderframe)
		local changecolorbutton, changecolorbutton2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0.8, 0), "Change Color", holderframe)

		local data = nil
		local filename = nil

		color.MouseButton1Down:Connect(function()
			if keyboardinput then
				color2.Text = keyboardinput:gsub("\n", "")
				data = keyboardinput:gsub("\n", "")
			end
		end)

		changecolorbutton.MouseButton1Down:Connect(function()
			if color2.Text ~= "RGB (Click to update)" and data then
				disk:Write("BackgroundColor", data)
				local colordata = string.split(data, ",")
				if colordata then
					if tonumber(colordata[1]) and tonumber(colordata[2]) and tonumber(colordata[3]) then
						backgroundcolor.BackgroundColor3 = Color3.new(tonumber(colordata[1])/255, tonumber(colordata[2])/255, tonumber(colordata[3])/255)
						changecolorbutton2.Text = "Success"
						if backgroundimage then
							disk:Write("BackgroundImage", "")
							wallpaper.Image = ""
						end
						task.wait(2)
						changecolorbutton2.Text = "Change Color"
					end
				end
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
		local filename = nil
		local tile = false
		local tilenumb = "0.2, 0, 0.2, 0"

		id.MouseButton1Down:Connect(function()
			if keyboardinput then
				id2.Text = keyboardinput:gsub("\n", "")
				data = keyboardinput:gsub("\n", "")
			end
		end)

		tiletoggle.MouseButton1Down:Connect(function()
			if tile then
				tile = false
				tiletoggle2.Text = "Enable tile"
			else
				tiletoggle2.Text = "Disable tile"
				tile = true
			end
		end)


		tilenumber.MouseButton1Down:Connect(function()
			if keyboardinput then
				tilenumber2.Text = keyboardinput:gsub("\n", "")
				tilenumb = keyboardinput:gsub("\n", "")
			end
		end)

		changebackimg.MouseButton1Down:Connect(function()
			if id2.Text ~= "Image ID (Click to update)" and data then
				if tonumber(data) then
					disk:Write("BackgroundImage", data..","..tostring(tile)..","..tilenumb)
					wallpaper.Image = "rbxthumb://type=Asset&id="..tonumber(data).."&w=420&h=420"
					changebackimg2.Text = "Success"
					if tile then
						local tilenumb = string.split(tilenumb, ",")
						if tonumber(tilenumb[1]) and tonumber(tilenumb[2]) and tonumber(tilenumb[3]) and tonumber(tilenumb[4]) then
							wallpaper.ScaleType = Enum.ScaleType.Tile
							wallpaper.TileSize = UDim2.new(tonumber(tilenumb[1]), tonumber(tilenumb[2]), tonumber(tilenumb[3]), tonumber(tilenumb[4]))
						end
					else
						wallpaper.ScaleType = Enum.ScaleType.Stretch
					end
					task.wait(2)
					changebackimg2.Text = "Change Background Image"
				end
			end
		end)
	end

	local desktopscrollingframe = nil
	local loaddesktopicons
	local rightclickmenu

	local function configicons()
		local window = CreateWindow(UDim2.fromScale(0.7, 0.7), "Desktop Icons", false, false, false, "Icons", false)

		local disable, text1 = createnicebutton(UDim2.fromScale(1, 0.25), UDim2.fromScale(0, 0), if iconsdisabled then "Enable icons" else "Disable icons", window)
		local textlabel = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(1, 0.25), Position = UDim2.fromScale(0, 0.25), Text = "Icons Size:", BackgroundTransparency = 1, TextScaled = true, TextWrapped = true})
		window:AddChild(textlabel)
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


		sound = SpeakerHandler.CreateSound({
			Id = tonumber(data),
			Pitch = tonumber(pitch),
			Speaker = speaker,
			Length = tonumber(length),
		})


		if length then
			sound:Loop()
		else
			sound:Play()
		end

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

	local usedmicros = {}

	local function loadluafile(microcontrollers, screen, code, runcodebutton)
		local success = false
		local micronumber = 0
		if typeof(microcontrollers) == "table" and #microcontrollers > 0 then
			for index, value in pairs(microcontrollers) do
				micronumber += 1
				if not table.find(usedmicros, value) then
					table.insert(usedmicros, value)
					local polysilicon = GetPartFromPort(value, "Polysilicon")
					local polyport = GetPartFromPort(polysilicon, "Port")
					if polysilicon then
						if polyport then
							value:Configure({Code = code})
							polysilicon:Configure({PolysiliconMode = 0})
							TriggerPort(polyport)
							success = true
							local commandlines = commandline.new(true, UDim2.new(0.5, 0, 0.5, 0), screen)

							commandlines:insert("Using microcontroller:")

							commandlines:insert(micronumber)

							if runcodebutton then
								runcodebutton.Text = "Code Ran"
								task.wait(2)
								runcodebutton.Text = "Run lua"
							end
							break
						else
							local commandlines = commandline.new(true, UDim2.new(0.5, 0, 0.5, 0), screen)

							commandlines:insert("No port connected to polysilicon")
						end
					else
						local commandlines = commandline.new(true, UDim2.new(0.5, 0, 0.5, 0), screen)

						commandlines:insert("No polysilicon connected to microcontroller")
					end
				end
			end
		end
		if not success then
			local commandlines = commandline.new(true, UDim2.new(0.5, 0, 0.5, 0), screen)
			commandlines:insert("No microcontrollers left.")
		end
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

	local function readfile(txt, nameondisk, directory, cd)
	    local disk = cd or disk
		local filegui, window, closebutton, maximizebutton, textlabel, resize, min, funcs = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), nil, false, false, false, nameondisk or "File", false)
		local deletebutton = nil
		local prevdir = directory
		local prevtxt = txt
		local prevname = nameondisk

		local disktext = screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), TextScaled = true, Text = tostring(txt), RichText = true, BackgroundTransparency = 1})
		filegui:AddChild(disktext)

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

			if not string.find(nameondisk, "%.lnk") and not string.find(nameondisk, "%.lua") and not string.find(nameondisk, "%.img") and not string.find(nameondisk, "%.aud") and not string.find(nameondisk, "%.vid") and typeof(txt) ~= "table" then
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
			loadluafile(microcontrollers, screen, tostring(txt))
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

		if string.find(string.lower(tostring(txt)), "<woshtml>") then
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
		holderframe:AddChild(scrollingframe)

		local refreshbutton = createnicebutton(UDim2.new(0.2, 0, 0.15, 0), UDim2.new(0, 0, 0, 0), "Refresh", holderframe)

		local parentbutton = createnicebutton(UDim2.new(0.2, 0, 0.15, 0), UDim2.new(0.2, 0, 0, 0), "Parent", holderframe)

		local data
		local split = directory:split("/")

		if #split == 2 and split[2] == "" then
			data = (currentdisk or disk):ReadEntireDisk()
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
			holderframe:AddChild(selected)

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
			if disk then
				local button, textlabel = createnicebutton(UDim2.new(1,0,0,25), UDim2.new(0, 0, 0, start), tostring(index), scrollingframe)
				textlabel.Size = UDim2.new(1, -25, 1, 0)
				textlabel.Position = UDim2.new(0, 25, 0, 0)

				local imagebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0, 25, 0, 25), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Image = "rbxassetid://16971885886"})
				button:AddChild(imagebutton)

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

				    local information = disk:ReadEntireDisk()

					start = 0
					scrollingframe:Destroy()
					scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = scrollsize, CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
					holderframe:AddChild(scrollingframe)

					directory = "/"
					titletext.Text = directory

					if boolean1 then
					    selecteddisk = disk
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

					for index, value in pairs(information) do
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
				button:AddChild(imagebutton)

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
					imagebutton:AddChild(image2)

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
						data1 = disk:ReadEntireDisk()
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
						holderframe:AddChild(scrollingframe)

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

						for index, value in pairs(information) do
							loadfile(index, value, currentdisk)
							task.wait()
						end
					end

				end)
			end
		end

        if currentdisk then

		    for filename, dataz in pairs(data) do
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
						end
						if boolean1 then
							selecteddir = removedlast
						end
						directory = removedlast1
					else
						data = currentdisk:ReadEntireDisk()
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
					holderframe:AddChild(scrollingframe)
					if typeof(data) == "table" then
						for filename, dataz in pairs(data) do
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
				data = (currentdisk or disk):ReadEntireDisk()
			elseif #split == 2 and split[2] ~= "" then
				data = (currentdisk or disk):Read(split[2])
			elseif #split > 2 then
				local removedlast = directory:sub(1, -(string.len(split[#split]))-2)
				data = filesystem.Read(split[#split], removedlast, nil, currentdisk)
			end
			start = 0
			scrollingframe:Destroy()
			scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = scrollsize, CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
			holderframe:AddChild(scrollingframe)

			if typeof(data) ~= "table" then data = {} end

			for filename, dataz in pairs(data) do
				loadfile(filename, dataz, currentdisk)
			end
		end)

		parentbutton.MouseButton1Up:Connect(function()
		    if currentdisk then

		        if directory ~= "/" then
            		local data
            		local split = directory:split("/")

            		if #split == 2 and split[2] ~= "" then
            			data = currentdisk:ReadEntireDisk()
            			directory = "/"
            			if boolean1 then
            				selectedname = nil
            				selected.Text = "Root"
            			end
            			if boolean1 then
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
            		holderframe:AddChild(scrollingframe)

            		if typeof(data) ~= "table" then data = {} end

            		if directory == "/" then
            			deletebutton.Size = UDim2.new(0,0,0,0)
            			deletebutton.Visible = false
            			if not currentdisk then
            			    parentbutton.Size = UDim2.new(0,0,0,0)
            			    parentbutton.Visible = false
            			end
            		end

            		for filename, dataz in pairs(data) do
            			loadfile(filename, dataz, currentdisk)
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
                    holderframe:AddChild(scrollingframe)

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
		local disk = nil

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
				filenamebutton2.Text = keyboardinput:gsub("\n", ""):gsub("/n\\", "\n"):gsub("/", "")
				filename = keyboardinput:gsub("\n", ""):gsub("/n\\", "\n"):gsub("/", "")
			end
		end)

		directorybutton.MouseButton1Down:Connect(function()
			if keyboardinput then
				local inputtedtext = keyboardinput:gsub("\n", ""):gsub("/n\\", "\n")
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
				if keyboardinput:sub(1, 2) ~= "!s" then
					filedatabutton2.Text = keyboardinput:gsub("\n", ""):gsub("/n\\", "\n")
					data = keyboardinput:gsub("\n", ""):gsub("/n\\", "\n")
				else
					local keyboardinput = keyboardinput:sub(3, string.len(keyboardinput))
					filedatabutton2.Text = keyboardinput:gsub("\n", " "):gsub("/n\\", "\n")
					data = keyboardinput:gsub("\n", " "):gsub("/n\\", "\n")
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
				newname = keyboardinput:gsub("\n", ""):gsub("/n\\", "\n")
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
								local newdata = JSONDecode(JSONEncode(sdisk:ReadEntireDisk()))
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
				newname = keyboardinput:gsub("\n", ""):gsub("/n\\", "\n")
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
				newname = keyboardinput:gsub("\n", ""):gsub("/n\\", "\n")
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

	function shutdownallmicros(micros)
		if not micros then return end
		for index, value in pairs(micros) do
			local polysilicon = GetPartFromPort(value, "Polysilicon")
			local polyport = GetPartFromPort(polysilicon, "Port")
			if polysilicon then
				if polyport then
					value:Configure({Code = ""})
					polysilicon:Configure({PolysiliconMode = 1})
					TriggerPort(polyport)
					if table.find(usedmicros, value) then
						table.remove(usedmicros, table.find(usedmicros, value))
					end
				else
					print("No port connected to polysilicon")
				end
			else
				print("No polysilicon connected to microcontroller")
			end
		end
	end

	local function shutdownmicros(screen, micros)
		local holderframe = CreateWindow(UDim2.new(0.75, 0, 0.75, 0), "Microcontroller Manager", false ,false, false, "Microcontroller Manager", false)

		local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
		holderframe:AddChild(scrollingframe)

		local start = 0
		if not micros then return end
		for index, value in pairs(micros) do
			local button, button2 = createnicebutton(UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, start), (start/25)+1, scrollingframe)
			scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start + 25)
			local oldstart = start + 25
			button.MouseButton1Up:Connect(function()
				local polysilicon = GetPartFromPort(value, "Polysilicon")
				local polyport = GetPartFromPort(polysilicon, "Port")
				if polysilicon then
					if polyport then
						value:Configure({Code = ""})
						polysilicon:Configure({PolysiliconMode = 1})
						TriggerPort(polyport)
						if table.find(usedmicros, value) then
							table.remove(usedmicros, table.find(usedmicros, value))
						end
						button2.Text = "Microcontroller turned off."
						task.wait(2)
						button2.Text = oldstart/25
					else
						print("No port connected to polysilicon")
					end
				else
					print("No polysilicon connected to microcontroller")
				end
			end)
			start += 25
		end
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

			scroll:AddChild(selectionui)

			local start = 0

			for i, window in ipairs(windows) do

				if window.FunctionsTable and not window.FunctionsTable:IsClosed() then
					local text = if typeof(window.Name) == "function" then tostring(window.Name()) else tostring(window.Name)

					if text == "nil" then
						text = "Untitled program"
					end

					local button = createnicebutton(UDim2.new(1, 0, 0, 25), UDim2.fromOffset(0, 25*start), text, scroll)

					button.MouseButton1Up:Connect(function()
						selectionui.ImageTransparency = 0.2
						button:AddChild(selectionui)
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

	local function customprogramthing(screen, micros)
		local holderframe = CreateWindow(UDim2.new(0.75, 0, 0.75, 10), nil, false, false, false, "Lua executor", false)

		local code = ""

		local codebutton, codebutton2 = createnicebutton(UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0, 0), "Enter lua here (Click to update)", holderframe)

		codebutton.MouseButton1Up:Connect(function()
			if keyboardinput then
				codebutton2.Text = tostring(keyboardinput)
				code = tostring(keyboardinput)
			end
		end)

		local stopcodesbutton = createnicebutton(UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.6, 0), "Shutdown microcontrollers", holderframe)

		stopcodesbutton.MouseButton1Up:Connect(function()
			shutdownmicros(screen, microcontrollers)
		end)

		local windowsbutton = createnicebutton(UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.4, 0), "Windows Manager", holderframe)

		windowsbutton.MouseButton1Up:Connect(function()
			windowsmanager()
		end)

		local runcodebutton, runcodebutton2 = createnicebutton(UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.8, 0), "Run lua", holderframe)

		runcodebutton.MouseButton1Up:Connect(function()
			if code ~= "" then
				loadluafile(microcontrollers, screen, code, runcodebutton2)
			end
		end)
	end

	local function mediaplayer()
		local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Media player", false, false, false, "Media player", false)
		local imagelabel = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Image = "rbxassetid://15940016124"})
		holderframe:AddChild(imagelabel)

		local mainframe = screen:CreateElement("Frame", {Size = UDim2.fromScale(0.9, 0.9), Position = UDim2.fromScale(0.05, 0.05), BackgroundTransparency = 1})
		imagelabel:AddChild(mainframe)

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
				if tonumber(keyboardinput) then
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
		local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), nil, false, false, false, "Chat", false)

		local messagesent = nil

		if modem then

			local id = 0

			local toggleanonymous = false
			local togglea, togglea2 = createnicebutton(UDim2.new(0.4, 0, 0.1, 0), UDim2.new(0,0,0,0), "Enable anonymous", holderframe)

			local idui, idui2 = createnicebutton(UDim2.new(0.6, 0, 0.1, 0), UDim2.new(0.4,0,0,0), "Network id", holderframe)

			idui.MouseButton1Up:Connect(function()
				if tonumber(keyboardinput) then
					idui2.Text = tonumber(keyboardinput)
					id = tonumber(keyboardinput)
					modem:Configure({NetworkID = tonumber(keyboardinput)})
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
			holderframe:AddChild(scrollingframe)

			local sendbox, sendbox2 = createnicebutton(UDim2.new(0.8, 0, 0.1, 0), UDim2.new(0,0,0.9,0), "Message (Click to update)", holderframe)

			local sendtext = nil
			local player = nil

			sendbox.MouseButton1Up:Connect(function()
				if keyboardinput then
					sendbox2.Text = keyboardinput:gsub("\n", " ")
					sendtext = keyboardinput:gsub("\n", " ")
					player = playerthatinputted
				end
			end)

			local sendbutton, sendbutton2 = createnicebutton(UDim2.new(0.2, 0, 0.1, 0), UDim2.new(0.8,0,0.9,0), "Send", holderframe)

			sendbutton.MouseButton1Up:Connect(function()
				if sendtext then
					if not toggleanonymous then
						modem:SendMessage("[ "..player.." ]: "..sendtext, id)
					else
						modem:SendMessage(sendtext, id)
					end
					sendbutton2.Text = "Sent"
					task.wait(2)
					sendbutton2.Text = "Send"
				end
			end)

			local start = 0

			MicrophoneChatted(function(player, text)
				local subbed = text:lower():sub(1, 5)
				local sendtext = text:sub(6, string.len(text))

				if subbed == "chat " then
					if not toggleanonymous then
						modem:SendMessage("[ "..player.." ]: "..sendtext, id)
					else
						modem:SendMessage(sendtext, id)
					end
				end
			end)

			messagesent = modem:Connect("MessageSent", function(text)
				if not holderframe then messagesent:Unbind() end
				print(text)
				local textlabel = screen:CreateElement("TextLabel", {Text = tostring(text), Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, start), TextScaled = true})

				if string.find(text, "b/") then
					textlabel.TextColor3 = Color3.fromRGB(85, 85, 255)
				end

				scrollingframe:AddChild(textlabel)
				start += 25
				scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start)
				scrollingframe.CanvasPosition = Vector2.new(0, start + 25)
			end)
		else
			local textlabel = screen:CreateElement("TextLabel", {Text = "You need a modem.", Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
			holderframe:AddChild(textlabel)
		end
	end

	local function calculator()
		local window = CreateWindow(UDim2.new(0.7, 0, 0.7, 10), nil, false, false, false, "Calculator", false)
		local holderframe = window
		local part1 = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(0.45, 0, 0.15, 0), Position = UDim2.new(0, 0, 0, 0), Text = "0", BackgroundTransparency = 1})
		local part3 = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(0.1, 0, 0.15, 0), Position = UDim2.new(0.45, 0, 0, 0), Text = "", BackgroundTransparency = 1})
		local part2 = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(0.45, 0, 0.15, 0), Position = UDim2.new(0.55, 0, 0, 0), Text = "", BackgroundTransparency = 1})
		holderframe:AddChild(part1)
		holderframe:AddChild(part2)
		holderframe:AddChild(part3)

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
				if tostring(number2) ~= "0" and tostring(number2) ~= "-0" then
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
		holderframe:AddChild(button15)
		button15.MouseButton1Down:Connect(function()
			type = "/"
			part3.Text = "/"
		end)

		local  button17 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0, 0, 0.75, 0), "√", holderframe)
		holderframe:AddChild(button17)
		button17.MouseButton1Down:Connect(function()
			type = "√"
			part3.Text = "√"
		end)

		local  button18 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.25, 0, 0.75, 0), "^", holderframe)
		holderframe:AddChild(button18)
		button18.MouseButton1Down:Connect(function()
			type = "^"
			part3.Text = "^"
		end)

		local  button16 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.75, 0, 0.75, 0), "=", holderframe)
		holderframe:AddChild(button16)
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
		if shutdownpoly and not putermode then
			TriggerPort(shutdownpoly)
		elseif putermode then
	        pcall(TriggerPort, 2)
		end
	end

	local function shutdownprompt()
		local window, holderframe, closebutton, maximize, textlabel, resize, minimize, funcs, index = CreateWindow(UDim2.new(0.4, 0, 0.25, 0), "Are you sure?",true,true,false,nil,true)

        holderframe.ZIndex = (2^31)-2

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

			if cursorevent then cursorevent:Unbind() end
			keyboardinput = nil
			playerthatinputted = nil
			minimizedprograms = {}
			minimizedammount = 0
			if desktopscrollingframe then desktopscrollingframe:Destroy() end
			task.wait(1)
			if speaker then
				speaker:ClearSounds()
				SpeakerHandler.PlaySound(shutdownsound, 1, nil, speaker)
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
	end

	local function restartprompt()
		local window, holderframe, closebutton, maximize, textlabel, resize, minimize, funcs, index = CreateWindow(UDim2.new(0.4, 0, 0.25, 0), "Are you sure?",true,true,false,nil,true)

        holderframe.ZIndex = (2^31)-2

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

			if cursorevent then cursorevent:Unbind() end
			minimizedprograms = {}
			minimizedammount = 0
			if desktopscrollingframe then desktopscrollingframe:Destroy() end
			task.wait(1)
			if speaker then
				speaker:ClearSounds()
				SpeakerHandler.PlaySound(shutdownsound, 1, nil, speaker)
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

        local position = UDim2.new(0, x or frame.AbsolutePosition.X, 0, math.min(y or frame.AbsolutePosition.Y, screen:GetDimensions().Y*0.6))

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
		    desktopscrollingframe:AddChild(rightclickmenu)
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
			local luas = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.6), "Cores", rightclickmenu)

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
				customprogramthing(screen, microcontrollers)
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
		if desktopscrollingframe then
			desktopscrollingframe:Destroy()
			desktopicons = {}
			selectedicon = nil
		end

		if selectionimage then
			selectionimage:Destroy()
		end

		selectionimage = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ImageTransparency = 0.5, Image = "rbxassetid://8677487226"})
		if resolutionframe then
			resolutionframe:AddChild(selectionimage)
		end

		desktopscrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1,0,0.9,0), BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0.9,0), ScrollBarThickness = 5})
		wallpaper:AddChild(desktopscrollingframe)

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
		desktopscrollingframe:AddChild(mycomputer)
		local imagelabel1 = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(1, 0.5), ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1, Image = "rbxassetid://16168953881"})
		mycomputer:AddChild(imagelabel1)
		local textlabel1 = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(1, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Computer", TextStrokeColor3 = Color3.new(0,0,0), TextColor3 = Color3.new(1,1,1), TextStrokeTransparency = 0.25})
		mycomputer:AddChild(textlabel1)
		mycomputer.MouseButton1Up:Connect(function()
			if selected ~= mycomputer then
				selected = mycomputer
				mycomputer:AddChild(selectionimage)
				for i, v in ipairs(desktopicons) do
					v.TextLabel.Size = UDim2.fromScale(1, 0.5)
					v.TextLabel.Position = UDim2.fromScale(0, 0.5)
				end

				textlabel1.Size = UDim2.fromScale(1, 1)
				textlabel1.Position = UDim2.fromScale(0, 0)
			else
				openrightclickprompt(mycomputer, nil, "/Desktop", true)
				selected = nil
				if resolutionframe then
					resolutionframe:AddChild(selectionimage)
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
				desktopscrollingframe:AddChild(holderbutton)
				local imagelabel = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(1, 0.5), ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1, Image = "rbxassetid://16137083118"})
				holderbutton:AddChild(imagelabel)
				local textlabel = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(1, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(filename), TextStrokeColor3 = Color3.new(0,0,0), TextColor3 = Color3.new(1,1,1), TextStrokeTransparency = 0.25})
				holderbutton:AddChild(textlabel)

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
					imagelabel:AddChild(image2)

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
                            data1 = disk:ReadEntireDisk()
                        end

                        if data1 then

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
					if selected ~= holderbutton then
						selected = holderbutton
						holderbutton:AddChild(selectionimage)
						for i, v in ipairs(desktopicons) do
							v.TextLabel.Size = UDim2.fromScale(1, 0.5)
							v.TextLabel.Position = UDim2.fromScale(0, 0.5)
						end

						textlabel.Size = UDim2.fromScale(1, 1)
						textlabel.Position = UDim2.fromScale(0, 0)
					else
						openrightclickprompt(holderbutton, filename, "/Desktop", false)
						selected = nil
						if resolutionframe then
							resolutionframe:AddChild(selectionimage)
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
		local keyboardevent
		local commandline = {}

		function commandline.new(screen)
			local background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0), ScrollBarThickness = 5})
			local lines = {
				number = UDim2.new(0,0,0,0)
			}

			function lines:insert(text, udim2)
				local textlabel = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Text = tostring(text), TextScaled = true, RichText = true, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Size = UDim2.new(1, 0, 0, 25), Position = lines.number})
				if textlabel then
					background:AddChild(textlabel)
					background.CanvasSize = UDim2.new(1, 0, 0, lines.number.Y.Offset + 25)
					if typeof(udim2) == "UDim2" then
						textlabel.Size = udim2
						background.CanvasSize -= UDim2.fromOffset(0, 25)
						background.CanvasSize += UDim2.new(0, 0, 0, udim2.Y.Offset)
						if udim2.X.Offset > screen:GetDimensions().X then
							background.CanvasSize += UDim2.new(0, udim2.X.Offset - screen:GetDimensions().X, 0, 0)
						end
						lines.number -= UDim2.new(0,0,0,25)
						lines.number += UDim2.new(0, 0, udim2.Y.Scale, udim2.Y.Offset)
					end
					lines.number += UDim2.new(0, 0, 0, 25)
					background.CanvasPosition = Vector2.new(0, lines.number.Y.Offset)
				end
				return textlabel
			end
			return lines, background
		end
		local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Terminal", false, false ,false, "Terminal", false)

		local window = holderframe

		local name = "GustavDOS For GustavOS Unstable"

		local button = createnicebutton(UDim2.new(0.2, 0, 0.2, 0), UDim2.new(0.8, 0, 0.8, 0), "Run", window)

		local textbox, textboxtext = createnicebutton(UDim2.new(0.8, 0, 0.2, 0), UDim2.new(0, 0, 0.8, 0), "Command (Click to update)", window)
		local textinput

		textbox.MouseButton1Up:Connect(function()
			if keyboardinput then
				textinput = tostring(keyboardinput)
				textboxtext.Text = tostring(keyboardinput):gsub("\n", " ")
			end
		end)

		local background
		local commandlines

		local copydir
		local copydisk
		local copyname
		local copydata

		local disk = disk

		local function loadluafile(microcontrollers, screen, code)
			local success = false
			local micronumber = 0
			if typeof(microcontrollers) == "table" and #microcontrollers > 0 then
				for index, value in pairs(microcontrollers) do
					micronumber += 1
					if not table.find(usedmicros, value) then
						table.insert(usedmicros, value)
						local polysilicon = GetPartFromPort(value, "Polysilicon")
						local polyport = GetPartFromPort(polysilicon, "Port")
						if polysilicon then
							if polyport then
								value:Configure({Code = code})
								polysilicon:Configure({PolysiliconMode = 0})
								TriggerPort(polyport)
								success = true

								commandlines:insert("Using microcontroller:")

								commandlines:insert(micronumber)
								break
							else
								commandlines:insert("No port connected to polysilicon")
							end
						else
							commandlines:insert("No polysilicon connected to microcontroller")
						end
					end
				end
			end
			if not success then
				commandlines:insert("No microcontrollers left.")
			end
		end

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

		local function runtext(text)
			if text:lower():sub(1, 4) == "dir " then
				local txt = text:sub(5, string.len(text))
				local inputtedtext = txt
				local tempsplit = string.split(inputtedtext, "/")
				print(inputtedtext)
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
							commandlines:insert(inputtedtext..":")
							dir = inputtedtext
						else
							commandlines:insert("Invalid directory")
							commandlines:insert(dir..":")
						end
					else
						if disk:Read(split[#split]) or split[2] == "" then
							if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
								commandlines:insert(inputtedtext..":")
								dir = inputtedtext
							elseif tempsplit[1] == "" and tempsplit[2] == "" then
								commandlines:insert(inputtedtext..":")
								dir = inputtedtext
							elseif tempsplit[1] == "" and tempsplit[2] ~= "" then
								if typeof(disk:Read(split[#split])) == "table" then
									commandlines:insert(inputtedtext..":")
									dir = inputtedtext
								end
							else
								commandlines:insert("Invalid directory")
								commandlines:insert(dir..":")
							end
						else
							commandlines:insert("Invalid directory")
							commandlines:insert(dir..":")
						end
					end
				elseif inputtedtext == "" then
					commandlines:insert(dir..":")
				else
					commandlines:insert("Invalid directory")
					commandlines:insert(dir..":")
				end
			elseif text:lower():sub(1, 5) == "clear" then
				task.wait(0.1)
				if background then background:Destroy() end
				commandlines, background = commandline.new(screen)
				background.Size = UDim2.new(1, 0, 0.8, 0)
				window:AddChild(background)
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 11) == "setstorage " then
				local text = text:sub(12, string.len(text))

				local text = tonumber(text)

				if disks[text] then
				    disk = disks[text]
				    directory = ""
				    commandlines:insert("Success")
			    else
			       commandlines:insert("Invalid storage media number.")
			    end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 12) == "showstorages" then
				for i, val in ipairs(disks) do
				    commandlines:insert(tostring(i))
			    end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 6) == "reboot" then
				restartprompt()
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 8) == "shutdown" then
				shutdownprompt()
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 6) == "print " then
				commandlines:insert(text:sub(7, string.len(text)))
				print(text:sub(7, string.len(text)))
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 11) == "soundpitch " then
				if speaker and tonumber(text:sub(12, string.len(text))) then
					speaker:Configure({Pitch = tonumber(text:sub(12, string.len(text)))})
					speaker:Trigger()
					print(text:sub(12, string.len(text)))
				else
					commandlines:insert("Invalid pitch number or no speaker was found.")
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 10) == "showmicros" then
				if microcontrollers then
					local start = 0
					for i,v in pairs(microcontrollers) do
						start += 1
						commandlines:insert("Microcontroller")
						commandlines:insert(start)
					end
				else
					commandlines:insert("No microcontrollers found.")
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 8) == "stoplua " then
				local number = tonumber(text:sub(9, string.len(text)))
				print(number)
				local start = 0
				local success = false
				for index,value in pairs(microcontrollers) do
					start += 1
					if start == number then
						local polysilicon = GetPartFromPort(value, "Polysilicon")
						local polyport = GetPartFromPort(polysilicon, "Port")
						if polysilicon then
							if polyport then
								value:Configure({Code = ""})
								polysilicon:Configure({PolysiliconMode = 1})
								TriggerPort(polyport)
								if table.find(usedmicros, value) then
									table.remove(usedmicros, table.find(usedmicros, value))
								end
								success = true
								commandlines:insert("Microcontroller turned off.")
							else
								commandlines:insert("No port connected to polysilicon")
							end
						else
							commandlines:insert("No polysilicon connected to microcontroller")
						end
					end
				end
				if not success then
					commandlines:insert("Invalid microcontroller number")
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 7) == "runlua " then
				print(text)
				loadluafile(microcontrollers, screen, text:sub(8, string.len(text)))
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 8) == "readlua " then
				local filename = text:sub(9, string.len(text))
				print(filename)
				if filename and filename ~= "" then
					local split = nil
					if dir ~= "" then
						split = string.split(dir, "/")
					end
					if not split or split[2] == "" then
						local output = disk:Read(filename)
						commandlines:insert(output)
						loadluafile(microcontrollers, screen, output)
					else
						local output = getfileontable(disk, filename, dir)
						commandlines:insert(output)
						loadluafile(microcontrollers, screen, output)
					end
				else
					commandlines:insert("No filename specified")
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 5) == "beep " then
				local number = tonumber(text:sub(6, string.len(text)))
				print(number)
				if number then
					Beep(number)
				else
					commandlines:insert("Invalid number")
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 7) == "showdir" then
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
								commandlines:insert(tostring(i))
								print(i)
							end
						else
							commandlines:insert("Invalid directory")
						end
					else
						local output = disk:Read(split[#split])
						if output or split[2] == "" then
							if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
								if typeof(output) == "table" then
									for i,v in pairs(output) do
										commandlines:insert(tostring(i))
										print(i)
									end
								end
							elseif tempsplit[1] == "" and tempsplit[2] == "" then
								for i,v in pairs(disk:ReadEntireDisk()) do
									commandlines:insert(tostring(i))
									print(i)
								end
							elseif tempsplit[1] == "" and tempsplit[2] ~= "" then
								if typeof(disk:Read(split[#split])) == "table" then
									for i,v in pairs(disk:Read(split[#split])) do
										commandlines:insert(tostring(i))
										print(i)
									end
								end
							else
								commandlines:insert("Invalid directory")
							end
						else
							commandlines:insert("Invalid directory")
						end
					end
				elseif inputtedtext == "" then
					for i,v in pairs(disk:ReadEntireDisk()) do
						commandlines:insert(tostring(i))
					end
				else
					commandlines:insert("Invalid directory")
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 10) == "createdir " then
				local filename = text:sub(11, string.len(text))
				print(filename)
				if filename and filename ~= "" then
					local split = nil
					local returntable = nil
					if dir ~= "" then
						split = string.split(dir, "/")
					end
					if not split or split[2] == "" then
						disk:Write(filename, {
						})
					else
						returntable = createfileontable(disk, filename, {}, dir)
					end
					if not split then
						if disk:Read(filename) then
							commandlines:insert("Success i think")
						else
							commandlines:insert("Failed")
						end
					else
						if disk:Read(split[2]) == returntable then
							commandlines:insert("Success i think")
						else
							commandlines:insert("Failed i think")
						end
					end
				else
					commandlines:insert("No filename specified")
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 6) == "write " then
				local texts = text:sub(7, string.len(text))
				local filename = texts:split("/")[1]
				local filedata = texts:split("/")[2]
				for i,v in ipairs(texts:split("/")) do
					if i > 2 then
						filedata = filedata.."/"..v
					end
				end
				print(filename, filedata)
				if filename and filename ~= "" then
					if filedata and filedata ~= "" then
						local split = nil
						local returntable = nil
						if dir ~= "" then
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
									commandlines:insert("Success i think")
								else
									commandlines:insert("Failed")
								end
							else
								commandlines:insert("Failed")
							end
						else
							if disk:Read(split[2]) == returntable and disk:Read(split[2]) then
								commandlines:insert("Success i think")
							else
								commandlines:insert("Failed i think")
							end
						end
					else
						commandlines:insert("No filedata specified")
					end
				else
					commandlines:insert("No filename specified")
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 5) == "copy " then
				local filename = text:sub(6, string.len(text))
				print(filename)
				if filename and filename ~= "" then
					local file
					local split = dir:split("/")
					if #split == 2 and split[2] == "" then
						file = disk:Read(filename)
					else
						file = getfileontable(disk, filename, dir)
					end

					if file then
						copydir = dir
						copyname = filename
						copydisk = disk
						copydata = file
						commandlines:insert("Copied, use the paste command to paste the file.")
					else
						commandlines:insert("The specified file was not found on this directory.")
					end
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 5) == "paste" then
				if copydir ~= "" and copyname ~= "" then
					local split = copydir:split("/")
					local file
					if #split == 2 and split[2] == "" then
						file = copydisk:Read(copyname)
					else
						file = getfileontable(copydisk, copyname, copydir)
					end

					if not file then
						file = copydata
					end

					if file then
						local split = dir:split("/")
						if #split == 2 and split[2] == "" then
							disk:Write(copyname, file)
							if disk:Read(copyname) then
								commandlines:insert("Success?")
							else
								commandlines:insert("Failed?")
							end
						else
							local result = createfileontable(disk, copyname, file, dir)

							if disk:Read(split[2]) == result then
								commandlines:insert("Success?")
							else
								commandlines:insert("Failed?")
							end
						end
					else
						commandlines:insert("File does not exist.")
					end
				else
					commandlines:insert("No file has been copied.")
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 7) == "rename " then
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
					local file
					local split = dir:split("/")
					if #split == 2 and split[2] == "" then
						file = disk:Read(filename)
					else
						file = getfileontable(disk, filename, dir)
					end
					if file then
						if newname ~= "" then
							if #split == 2 and split[2] == "" then
								disk:Write(newname, file)
								disk:Write(filename, nil)
							else
								createfileontable(disk, newname, file, dir)
								createfileontable(disk, filename, nil, dir)
							end
							commandlines:insert("Renamed.")
						else
							commandlines:insert("The new filename wasn't specified.")
						end
					else
						commandlines:insert("The specified file was not found on this directory.")
					end
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 3) == "cd " then
				local filename = text:sub(4, string.len(text))

				if filename and filename ~= "" and filename ~= "./" then
					local split = dir:split("/")
					local file
					if #split == 2 and split[2] == "" then
						file = disk:Read(filename)
					else
						file = getfileontable(disk, filename, dir)
					end

					if file then
						dir = if dir == "/" then dir..filename else dir.."/"..filename
						commandlines:insert("Success?")
					else
						commandlines:insert("The table/folder does not exist.")
					end
				elseif filename == "./" then
					local split = dir:split("/")
					if #split == 2 and split[2] == "" then
						commandlines:insert("Cannot use ./ on root.")
					else
						local newdir = dir:sub(1, -(string.len(split[#split]))-2)
						dir = if newdir == "" then "/" else newdir
					end
				else
					commandlines:insert("The table/folder name was not specified.")
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 7) == "delete " then
				local filename = text:sub(8, string.len(text))
				print(filename)
				if filename and filename ~= "" then
					local split = nil
					local returntable = nil
					if dir ~= "" then
						split = string.split(dir, "/")
					end
					if split and split[2] ~= "" then
						returntable = createfileontable(disk, filename, nil, dir)
					end
					if not split or split[2] == "" then
						if disk:Read(filename) then
							disk:Write(filename, nil)
							if not disk:Read(filename) then
								commandlines:insert("Success i think")
							else
								commandlines:insert("Failed")
							end
						else
							commandlines:insert("File does not exist.")
						end
					else
						if disk:Read(split[2]) == returntable then
							commandlines:insert("Success i think")
						else
							commandlines:insert("Failed i think")
						end
					end
				else
					commandlines:insert("No filename specified")
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 5) == "read " then
				local filename = text:sub(6, string.len(text))
				print(filename)
				if filename and filename ~= "" then
					local split = nil
					if dir ~= "" then
						split = string.split(dir, "/")
					end
					if not split or split[2] == "" then
						local output = disk:Read(filename)
						if string.find(string.lower(tostring(output)), "<woshtml>") then
							local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
							StringToGui(screen, tostring(output):lower(), textlabel)
							textlabel.TextTransparency = 1
							print(output)
						else
							commandlines:insert(tostring(output))
							print(output)
						end
					else
						local output = getfileontable(disk, filename, dir)
						if string.find(string.lower(tostring(output)), "<woshtml>") then
							local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
							StringToGui(screen, tostring(output):lower(), textlabel)
							textlabel.TextTransparency = 1
							print(output)
						else
							commandlines:insert(tostring(output))
							print(output)
						end
					end
				else
					commandlines:insert("No filename specified")
				end
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 10) == "readimage " then
				local filename = text:sub(11, string.len(text))
				print(filename)
				if filename and filename ~= "" then
					local split = nil
					if dir ~= "" then
						split = string.split(dir, "/")
					end
					if not split or split[2] == "" then
						local textlabel = commandlines:insert(tostring(disk:Read(filename)), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
						StringToGui(screen, [[<img src="]]..tostring(tonumber(disk:Read(filename)))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
						print(disk:Read(filename))
					else
						local textlabel = commandlines:insert(tostring(getfileontable(disk, filename, dir)), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
						StringToGui(screen, [[<img src="]]..tostring(tonumber(getfileontable(disk, filename, dir)))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
						print(getfileontable(disk, filename, dir))
					end
				else
					commandlines:insert("No filename specified")
				end
				commandlines:insert(dir..":")
				if filename and filename ~= "" then
					background.CanvasPosition -= Vector2.new(0, 25)
				end
			elseif text:lower():sub(1, 10) == "readvideo " then
				local filename = text:sub(11, string.len(text))
				print(filename)
				if filename and filename ~= "" then
					local split = nil
					if dir ~= "" then
						split = string.split(dir, "/")
					end
					if not split or split[2] == "" then
						local id = disk:Read(filename)
						local textlabel = commandlines:insert(id, UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
						local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..id})
						textlabel:AddChild(videoframe)
						videoframe.Playing = true
						print(disk:Read(filename))
					else
						local id = tostring(getfileontable(disk, filename, dir))
						local textlabel = commandlines:insert(tostring(getfileontable(disk, filename, dir)), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
						local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..id})
						textlabel:AddChild(videoframe)
						videoframe.Playing = true
						print(getfileontable(disk, filename, dir))
					end
				else
					commandlines:insert("No filename specified")
				end
				commandlines:insert(dir..":")
				if filename and filename ~= "" then
					background.CanvasPosition -= Vector2.new(0, 25)
				end
			elseif text:lower():sub(1, 13) == "displayimage " then
				local id = text:sub(14, string.len(text))
				print(id)
				if id and id ~= "" then
					local textlabel = commandlines:insert(tostring(id), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
					StringToGui(screen, [[<img src="]]..tostring(tonumber(id))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
				else
					commandlines:insert("No id specified")
				end
				commandlines:insert(dir..":")
				if id and id ~= "" then
					background.CanvasPosition -= Vector2.new(0, 25)
				end
			elseif text:lower():sub(1, 13) == "displayvideo " then
				local id = text:sub(14, string.len(text))
				print(id)
				if id and id ~= "" then
					local textlabel = commandlines:insert(tostring(id), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
					local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..id})
					textlabel:AddChild(videoframe)
					videoframe.Playing = true
				else
					commandlines:insert("No id specified")
				end
				commandlines:insert(dir..":")
				if id and id ~= "" then
					background.CanvasPosition -= Vector2.new(0, 25)
				end
			elseif text:lower():sub(1, 10) == "readsound " then
				local filename = text:sub(11, string.len(text))
				local txt
				print(filename)
				if filename and filename ~= "" then
					local split = nil
					if dir ~= "" then
						split = string.split(dir, "/")
					end
					if not split or split[2] == "" then
						local textlabel = commandlines:insert(tostring(disk:Read(filename)))
						txt = disk:Read(filename)
						print(disk:Read(filename))
					else
						local textlabel = commandlines:insert(tostring(getfileontable(disk, filename, dir)))
						txt = getfileontable(disk, filename, dir)
						print(getfileontable(disk, filename, dir))
					end
				else
					commandlines:insert("No filename specified")
				end
				playsound(txt, filename)
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 10) == "playsound " then
				local txt = text:sub(11, string.len(text))
				playsound(txt)
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 10) == "stopsounds" then
				speaker.ClearSounds()
				SpeakerHandler:RemoveSpeakerFromLoop(speaker)
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 4) == "cmds" then
				commandlines:insert("Commands:")
				commandlines:insert("cmds")
				commandlines:insert("stopsounds")
				commandlines:insert("soundpitch number")
				commandlines:insert("readsound filename")
				commandlines:insert("read filename")
				commandlines:insert("readimage filename")
				commandlines:insert("dir directory")
				commandlines:insert("showdir")
				commandlines:insert("write filename/filedata (with the /)")
				commandlines:insert("shutdown")
				commandlines:insert("clear")
				commandlines:insert("reboot")
				commandlines:insert("delete filename")
				commandlines:insert("createdir filename")
				commandlines:insert("stoplua number")
				commandlines:insert("runlua lua")
				commandlines:insert("showmicros")
				commandlines:insert("readlua filename")
				commandlines:insert("beep number")
				commandlines:insert("print text")
				commandlines:insert("playsound id")
				commandlines:insert("displayimage id")
				commandlines:insert("displayvideo id")
				commandlines:insert("readvideo id")
				commandlines:insert("rename filename/new filename (with the /)")
				commandlines:insert("cd table/folder or ./ for parent table/folder")
				commandlines:insert("copy filename")
				commandlines:insert("paste")
				commandlines:insert("showstorages")
				commandlines:insert("setstorage number")
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 4) == "help" then
				commandlines:insert("Did you mean cmds")
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 10) == "stopmicro " then
				commandlines:insert("Did you mean stoplua "..text:sub(11, string.len(text)))
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 10) == "playvideo " then
				commandlines:insert("Did you mean displayvideo "..text:sub(11, string.len(text)))
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 8) == "makedir " then
				commandlines:insert("Did you mean createdir "..text:sub(9, string.len(text)))
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 6) == "mkdir " then
				commandlines:insert("Did you mean createdir "..text:sub(7, string.len(text)))
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 5) == "echo " then
				commandlines:insert("Did you mean print "..text:sub(6, string.len(text)))
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 10) == "playaudio " then
				commandlines:insert("Did you mean playsound "..text:sub(11, string.len(text)))
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 10) == "readaudio " then
				commandlines:insert("Did you mean readsound "..text:sub(11, string.len(text)))
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 10) == "stopaudios" then
				commandlines:insert("Did you mean stopsounds")
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 9) == "stopaudio" then
				commandlines:insert("Did you mean stopsounds")
				commandlines:insert(dir..":")
			elseif text:lower():sub(1, 9) == "stopsound" then
				commandlines:insert("Did you mean stopsounds")
				commandlines:insert(dir..":")
			else
				local filename = text
				local split = nil
				if dir ~= "" then
					split = string.split(dir, "/")
				end
				if not split or split[2] == "" then
					local output = disk:Read(filename)
					if output then
						if string.find(filename, "%.aud") then
							commandlines:insert(tostring(output))
							playsound(output, filename)
							commandlines:insert(dir..":")
							print(output)
						elseif string.find(filename, "%.vid") then
							commandlines:insert(tostring(output))
							local id = output
							local textlabel = commandlines:insert(tostring(id), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
							local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..id})
							textlabel:AddChild(videoframe)
							videoframe.Playing = true
							commandlines:insert(dir..":")
							print(output)
							background.CanvasPosition -= Vector2.new(0, 25)
						elseif string.find(filename, "%.img") then
							local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
							StringToGui(screen, [[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
							commandlines:insert(dir..":")
							background.CanvasPosition -= Vector2.new(0, 25)
							print(output)
						elseif string.find(filename, "%.lua") then
							commandlines:insert(tostring(output))
							loadluafile(microcontrollers, screen, output)
							commandlines:insert(dir..":")
						else
							if string.find(string.lower(tostring(output)), "<woshtml>") then
								local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
								StringToGui(screen, tostring(output):lower(), textlabel)
								textlabel.TextTransparency = 1
								commandlines:insert(dir..":")
								background.CanvasPosition -= Vector2.new(0, 25)
								print(output)
							else
								commandlines:insert(tostring(output))
								commandlines:insert(dir..":")
								print(output)
							end
						end
					else
						commandlines:insert("Imcomplete or Command was not found.")
						commandlines:insert(dir..":")
					end
				else
					local output = getfileontable(disk, filename, dir)
					if output then
						if string.find(filename, "%.aud") then
							commandlines:insert(tostring(output))
							playsound(output)
							commandlines:insert(dir..":")
							print(output)
						elseif string.find(filename, "%.img") then
							local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
							StringToGui(screen, [[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
							commandlines:insert(dir..":")
							background.CanvasPosition -= Vector2.new(0, 25)
							print(output)
						elseif string.find(filename, "%.lua") then
							commandlines:insert(tostring(output))
							loadluafile(microcontrollers, screen, output)
							commandlines:insert(dir..":")
						else
							if string.find(string.lower(tostring(output)), "<woshtml>") then
								local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
								StringToGui(screen, tostring(output):lower(), textlabel)
								textlabel.TextTransparency = 1
								commandlines:insert(dir..":")
								background.CanvasPosition -= Vector2.new(0, 25)
								print(output)
							else
								commandlines:insert(tostring(output))
								commandlines:insert(dir..":")
								print(output)
							end
						end
					else
						commandlines:insert("Imcomplete or Command was not found.")
						commandlines:insert(dir..":")
					end
				end
			end
		end

		function bootdos()
			if not screen then
				if regularscreen then screen = regularscreen end
			end
			if screen and keyboard and disk and rom then
				commandlines, background = commandline.new(screen)
				window:AddChild(background)
				background.Size = UDim2.new(1, 0, 0.8, 0)
				task.wait(1)
				Beep(1)
				commandlines:insert(name.." Command line")
				task.wait(1)
				commandlines:insert("/:")
				if keyboardevent then keyboardevent:Unbind() end
				keyboardevent = button.MouseButton1Up:Connect(function()
				    local text = keyboardinput
					if text:sub(1, 2) ~= "!s" then
						commandlines:insert(tostring(text):gsub("\n", ""):gsub("/n\\", "\n"))
						runtext(tostring(text):gsub("\n", ""):gsub("/n\\", "\n"))
					else
						text = text:sub(3, string.len(text))
						commandlines:insert(tostring(text):gsub("\n", " "):gsub("/n\\", "\n"))
						runtext(tostring(text):gsub("\n", " "):gsub("/n\\", "\n"))
					end
				end)
			elseif screen then
				screen:ClearElements()
				local commandlines = commandline.new(screen)
				commandlines:insert(name.." Command line")
				task.wait(1)
				if not speaker then
					commandlines:insert("No speaker was found. (Optional)")
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
					commandlines:insert([[No empty disk or disk with the file "GDOSLibrary" was found.]])
				end
				if keyboard then
					local keyboardevent = button.MouseButton1Up:Connect(function()
						getstuff()
						bootdos()
						keyboardevent:Unbind()
					end)
				end
			elseif not screen then
				Beep(0.5)
				print("No screen was found.")
				if keyboard then
					local keyboardevent = button.MouseButton1Up:Connect(function()
						getstuff()
						bootdos()
						keyboardevent:Unbind()
					end)
				end
			end
		end
		bootdos()
	end
	local restartkey
	local leftctrlpressed = false

	function loaddesktop()
		minimizedammount = 0
		minimizedprograms = {}
		resolutionframe = screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Position = UDim2.new(2,0,0,0)})
		mainframe = screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0)})
		backgroundcolor = screen:CreateElement("Frame", {Size = UDim2.new(1,0,1,0), BackgroundColor3 = color})
		wallpaper = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1})
		mainframe:AddChild(backgroundcolor)
		backgroundcolor:AddChild(wallpaper)
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

		if restartkey then restartkey:Unbind() end

		restartkey = keyboard:Connect("KeyPressed", function(key)
			if key == Enum.KeyCode.LeftControl then
				leftctrlpressed = true
				task.wait(0.1)
				leftctrlpressed = false
			elseif key == Enum.KeyCode.R then
				if leftctrlpressed == true then
					if startbutton7 then
						startbutton7:Destroy()
					end
					if taskbarholder then
						taskbarholder:Destroy()
					end					

					for i, window in ipairs(windows) do
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
				end
			end
		end)

		startbutton7 = screen:CreateElement("ImageButton", {Image = "rbxassetid://15617867263", BackgroundTransparency = 1, Size = UDim2.new(0.1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)})
		local textlabel = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = "G", TextScaled = true, TextWrapped = true})
		startbutton7:AddChild(textlabel)

		programholder1 = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
		mainframe:AddChild(programholder1)
		programholder2 = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
		programholder1:AddChild(programholder2)

		taskbarholder = screen:CreateElement("ImageButton", {Image = "rbxassetid://15619032563", Position = UDim2.new(0, 0, 0.9, 0), Size = UDim2.new(1, 0, 0.1, 0), BackgroundTransparency = 1, ImageTransparency = 0.25})
		mainframe:AddChild(taskbarholder)
		taskbarholder:AddChild(startbutton7)

		taskbarholderscrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(0.9, 0, 1, 0), BackgroundTransparency = 1, CanvasSize = UDim2.new(0.9, 0, 1, 0), Position = UDim2.new(0.1, 0, 0, 0), ScrollBarThickness = 2.5})
		taskbarholder:AddChild(taskbarholderscrollingframe)

		if not disk:Read("sounds") and not disk:Read("Desktop") then
			local window, holderframe, closebutton, maximize, textlabel, resize, minimize, funcs = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Welcome to GustavOS", false, false, false, "Welcome", false)
			local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,0,0.8,0), Position = UDim2.new(0, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Would you like to add some sounds to the hard drive?", BackgroundTransparency = 1})
			window:AddChild(textlabel)
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

		if not iconsdisabled then
			pcall(loaddesktopicons)
		end

		local pressed = false
		local startmenu
		local function openstartmenu(object, func)
			if not pressed then
				startmenu = screen:CreateElement("ImageButton", {BackgroundTransparency = 1, Image = "rbxassetid://15619032563", Size = UDim2.new(0.3, 0, 5, 0), Position = UDim2.new(0, 0, -5, 0), ImageTransparency = 0.2})
				if not object then
				    taskbarholder:AddChild(startmenu)
			   	elseif typeof(object) == "Instance" then
					object:AddChild(startmenu)
				end
				local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1,0,0.8,0), CanvasSize = UDim2.new(1, 0, 2.6, 0), BackgroundTransparency = 1, ScrollBarThickness = 5})
				startmenu:AddChild(scrollingframe)
				local settingsopen = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.fromScale(0, 0), "Settings", scrollingframe)
				settingsopen.MouseButton1Up:Connect(function()
					settings()
					pressed = false
					startmenu:Destroy()

					if func then
					   func("settings")
					end
				end)

				local diskwriteopen = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.new(0, 0, 0.2/scrollingframe.CanvasSize.Y.Scale, 0), "Create/Overwrite file", scrollingframe)
				diskwriteopen.MouseButton1Up:Connect(function()
					writedisk()
					pressed = false
					startmenu:Destroy()

					if func then
					   func("diskwrite")
					end
				end)

				local filesopen = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*2, 0), "Files", scrollingframe)
				filesopen.MouseButton1Up:Connect(function()
					loaddisk("/", true)
					pressed = false
					startmenu:Destroy()

					if func then
					   func("loaddisk")
					end
				end)

				local luasopen = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*3, 0), "Lua executor", scrollingframe)
				luasopen.MouseButton1Up:Connect(function()
					customprogramthing(screen, microcontrollers)
					pressed = false
					startmenu:Destroy()

					if func then
					   func("luaopen")
					end
				end)

				local mediaopen = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*4, 0), "Mediaplayer", scrollingframe)
				mediaopen.MouseButton1Up:Connect(function()
					mediaplayer()
					pressed = false
					startmenu:Destroy()

					if func then
					   func("mediaplayer")
					end
				end)

				local chatopen = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*5, 0), "Chat", scrollingframe)
				chatopen.MouseButton1Up:Connect(function()
					chatthing()
					pressed = false
					startmenu:Destroy()

					if func then
					   func("chat")
					end
				end)

				local calculatoropen = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*6, 0), "Calculator", scrollingframe)
				calculatoropen.MouseButton1Up:Connect(function()
					calculator()
					pressed = false
					startmenu:Destroy()

					if func then
					   func("calculator")
					end
				end)

				local terminalopen = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*7, 0), "Terminal", scrollingframe)
				terminalopen.MouseButton1Up:Connect(function()
					pressed = false
					startmenu:Destroy()
					terminal()

					if func then
					   func("terminal")
					end
				end)

				local copy = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*8, 0), "Copy File", scrollingframe)
				copy.MouseButton1Up:Connect(function()
					pressed = false
					startmenu:Destroy()
					copyfile()

					if func then
					   func("copy")
					end
				end)

				local rename = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*9, 0), "Rename File", scrollingframe)
				rename.MouseButton1Up:Connect(function()
					pressed = false
					startmenu:Destroy()
					renamefile()

					if func then
					   func("rename")
					end
				end)

				local short = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*10, 0), "Create Shortcut", scrollingframe)
				short.MouseButton1Up:Connect(function()
					pressed = false
					startmenu:Destroy()
					createshortcut()

					if func then
					   func("shortcut")
					end
				end)

				local move = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*11, 0), "Move File", scrollingframe)
				move.MouseButton1Up:Connect(function()
					pressed = false
					startmenu:Destroy()
					movefile()

					if func then
					   func("move")
					end
				end)

				local reset = createnicebutton(UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*12, 0), "Reset Keyboard Event", scrollingframe)
				reset.MouseButton1Up:Connect(function()
					pressed = false
					startmenu:Destroy()

					if func then
					   func("resetkeyboardevent")
					end

					if keyboardevent then keyboardevent:Unbind() end
					keyboardevent = keyboard:Connect("TextInputted", function(text, player)
						keyboardinput = text
						playerthatinputted = player
					end)
					if restartkey then restartkey:Unbind() end

		            		restartkey = keyboard:Connect("KeyPressed", function(key)
						if key == Enum.KeyCode.LeftControl then
							leftctrlpressed = true
							task.wait(0.1)
							leftctrlpressed = false
						elseif key == Enum.KeyCode.R then
							if leftctrlpressed == true then
								if startbutton7 then
									startbutton7:Destroy()
								end
								if taskbarholder then
									taskbarholder:Destroy()
								end					
			
								for i, window in ipairs(windows) do
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
							end
						end
					end)
				end)

				local shutdown = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0, 0, 0.8, 0), "Shutdown", startmenu)
				shutdown.MouseButton1Up:Connect(function()
					pressed = false
					startmenu:Destroy()
					shutdownprompt()

					if func then
					   func("shutdown")
					end
				end)

				local restart = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0.5, 0, 0.8, 0), "Reboot", startmenu)
				restart.MouseButton1Up:Connect(function()
					pressed = false
					startmenu:Destroy()
					restartprompt()

					if func then
					   func("reboot")
					end
				end)
				pressed = true
			else
				startmenu:Destroy()
				pressed = false
			end

			return startmenu
	   	end

		rom:Write("GustavOSLibrary", nil)
		rom:Write("GD7Library", nil)
		rom:Write("GDOSLibrary", nil)
		rom:Write("GD7Library", function() return {
			Screen = screen,
			Keyboard = keyboard,
			Modem = modem,
			Speaker = speaker,
			Disk = disk,
			Disks = disks,
			CreateWindow = CreateWindow,
			createnicebutton = createnicebutton,
			createnicebutton2 = createnicebutton2,
			openstartmenu = openstartmenu,
			programholder1 = programholder1,
			programholder2 = programholder2,
			screenresolution = resolutionframe,
			mainframe = mainframe,
			Taskbar = {taskbarholderscrollingframe, taskbarholder, startbutton7},
			FileExplorer = loaddisk,
			filesystem = filesystem,
			filereader = readfile,
			Chatted = MicrophoneChatted,
			wallpaper = wallpaper,
			backgroundcolor = backgroundcolor,
			getWindows = function()
			    return windows
			end,
		} end)

		startbutton7.MouseButton1Down:Connect(function()
			startbutton7.Image = "rbxassetid://15617867263"
			buttondown = true
		end)
		startbutton7.MouseButton1Up:Connect(function()
			buttondown = false
			openstartmenu()
			speaker:PlaySound(clicksound)
		end)
		cursorevent = screen:Connect("CursorMoved", function(cursor)
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
				local a = screen:CreateElement("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Image = "rbxassetid://8679825641", BackgroundTransparency = 1, Size = UDim2.fromScale(0.2, 0.2), Position = UDim2.fromScale(0.5, 0.5), ZIndex = (2^31)-1})
				local b = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(1.5, 0.25), Position = UDim2.fromScale(-0.25, 1), BackgroundTransparency = 1, TextScaled = true, Text = tostring(cursor.Player), TextStrokeTransparency = 0, TextStrokeColor3 = Color3.new(1, 1, 1)})
				a:AddChild(b)
				
				players[cursor.Player] = {tick(), a}
			end
			players[cursor.Player][2].Position = UDim2.fromOffset(cursor.X, cursor.Y)
			players[cursor.Player][1] = tick()
		end)
	end

	function loadingscreen(boolean1, boolean2)
		screen:ClearElements()

		if restartkey then restartkey:Unbind() end
		
		local wallpaper = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), Image = "rbxassetid://"..tostring(disk:Read("LoadingImage") or 16204218577), BackgroundTransparency = 1})
		local spinner = screen:CreateElement("ImageLabel", {Size = UDim2.fromScale(0.1, 0.1), Position = UDim2.fromScale(0.7, 0.4), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, Image = "rbxassetid://16204406408"})
		wallpaper:AddChild(spinner)

		local textlabel = screen:CreateElement("TextLabel", {Size = UDim2.fromScale(0.4, 0.1), Position = UDim2.fromScale(0.3, 0.4), BackgroundTransparency = 1, TextScaled = true, TextColor3 = Color3.new(1,1,1), Text = if not boolean1 then "Welcome" elseif not boolean2 then "Restarting" elseif boolean2 then "Shutting down" else "how the hell", TextWrapped = true, TextStrokeColor3 = Color3.new(0,0,0), TextStrokeTransparency = 0.25})
		wallpaper:AddChild(textlabel)

		local coroutine1 = coroutine.create(function()
			while true do
				task.wait(0.01)
				spinner.Rotation += 2
			end
		end)

		coroutine.resume(coroutine1)

		if boolean1 then
			if boolean2 then
				shutdownallmicros(microcontrollers)
			else
				shutdownallmicros(microcontrollers)
			end
		end

		task.wait(3)

		coroutine.close(coroutine1)

		wallpaper:Destroy()

		if not boolean1 then
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

end)

local function bluescreen()
	if not screen then
		screen = regularscreen
	end

	if screen then

		screen:ClearElements()

		local backimg = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), Image = "rbxassetid://15940016124"})

		local text = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, TextScaled = true, Text = ":(", Size = UDim2.new(0.25, 0, 0.25, 0), TextColor3 = Color3.new(1,1,1)})

		local text2 = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, TextScaled = true, Text = "An error has occurred.", Position = UDim2.new(0.25, 0, 0, 0), Size = UDim2.new(0.75, 0, 0.25, 0), TextColor3 = Color3.new(1, 0, 0)})

		local text3 = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, TextScaled = true, Text = tostring(Error1), Position = UDim2.new(0, 0, 0.25, 0), Size = UDim2.new(1,0,0.5,0)})
		print(Error1)

		local text4 = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, TextScaled = true, Text = if game and workspace then "Reason: pilot.lua emulator skill issue." else "Reason: the Creator messed up the code.", Size = UDim2.new(1, 0, 0.25, 0), Position = UDim2.new(0, 0, 0.75, 0)})
		backimg:AddChild(text)
		backimg:AddChild(text2)
		backimg:AddChild(text3)
		backimg:AddChild(text4)
	else
		Beep(0.5)
	end
end

if not success then
	commandline = {}
	function commandline.new(boolean, udim2, screen)
		local holderframe
		local background
		local lines = {
			number = 0
		}
		background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0)})

		function lines:insert(text)
			local textlabel = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Text = tostring(text), TextScaled = true, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.fromOffset(0, lines.number * 25)})
			background:AddChild(textlabel)
			background.CanvasSize = UDim2.new(1, 0, 0, (lines.number * 25) + 25)
			lines.number += 1
		end
		return lines, background
	end
end

function bootos()
	if disks and #disks > 0 then
		print(tostring(romport).."\\"..tostring(disksport))
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
		speaker:ClearSounds()
		screen:ClearElements()
		local commandlines = commandline.new(false, nil, screen)
		commandlines:insert(name.." Command line")
		task.wait(1)
		if game and workspace then
			commandlines:insert("What the... pilot.lua emulator!?")
		end
		commandlines:insert("Welcome To "..name)
		task.wait(2)
		screen:ClearElements()
		microphonefuncs = {}
		
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
			elseif typeof(iconsdisabled) == "boolean" then
				iconsdisabled = false
			end

			windows = {}

			if microcontrollers then

				shutdownallmicros(microcontrollers)
		
			end

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
		defaultbuttonsize = Vector2.new(screen:GetDimensions().X*0.14, screen:GetDimensions().Y*0.1)
		if defaultbuttonsize.X > 35 then defaultbuttonsize = Vector2.new(35, defaultbuttonsize.Y); end
		if defaultbuttonsize.Y > 25 then defaultbuttonsize = Vector2.new(defaultbuttonsize.X, 25); end

		if success then
			loadingscreen(false)
			SpeakerHandler.PlaySound(startsound, 1, nil, speaker)
			if keyboardevent then keyboardevent:Unbind() end
			keyboardevent = keyboard:Connect("TextInputted", function(text, player)
				keyboardinput = text
				playerthatinputted = player
			end)
		else
			bluescreen()
			SpeakerHandler.PlaySound(669574849, 1, nil, speaker)
		end

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
			commandlines:insert([[No empty disk or disk with the file "GD7Library" was found.]])
		end
		if keyboard then
			local keyboardevent = keyboard:Connect("KeyPressed", function(key)
				if key == Enum.KeyCode.Return then
					getstuff()
					bootos()
					keyboardevent:Unbind()
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
			commandlines:insert([[No empty disk or disk with the file "GD7Library" was found.]])
		end
		if keyboard then
			local keyboardevent = keyboard:Connect("KeyPressed", function(key)
				if key == Enum.KeyCode.Return then
					getstuff()
					bootos()
					keyboardevent:Unbind()
				end
			end)
		end
	elseif not regularscreen and not screen then
		Beep(0.5)
		print("No screen was found.")
		if keyboard then
			local keyboardevent = keyboard:Connect("KeyPressed", function(key)
				if key == Enum.KeyCode.Return then
					getstuff()
					bootos()
					keyboardevent:Unbind()
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
end
