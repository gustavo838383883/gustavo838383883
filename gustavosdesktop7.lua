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
local backgroundimage
local color
local tile = false
local tilesize
local clicksound
local startsound
local shutdownsound
local romport
local disksport
local romindexusing
local sharedport

local shutdownpoly = nil

local CreateWindow

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

	for i=1, 128 do
		if not rom then
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
		if not disks then
			success, Error = pcall(GetPartsFromPort, i, "Disk")
			if success then
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
		end

		if disks and #disks > 1 and romport == disksport and not sharedport then
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


local name = "GustavOSDesktop7"
local commandline = {}
local defaultbuttonsize = Vector2.new(0,0)
local players = {}
local keyboardevent
local cursorevent

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

	local programholder1
	local programholder2
	local taskbarholder

	local buttondown = false
	local taskbarholderscrollingframe

	local resolutionframe

	local minimizedammount = 0

	function CreateWindow(udim2, title, boolean, boolean2, boolean3, text, boolean4)
		local holderframe = screen:CreateElement("ImageButton", {Size = udim2, BackgroundTransparency = 1, Image = "rbxassetid://8677487226", ImageTransparency = 0.2})
		if not holderframe then return end
		programholder1:AddChild(holderframe)
		local textlabel
		if typeof(title) == "string" then
			textlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1, -(defaultbuttonsize.X*2), 0, defaultbuttonsize.Y), BackgroundTransparency = 1, Position = UDim2.new(0, defaultbuttonsize.X*2, 0, 0), TextScaled = true, TextWrapped = true, Text = tostring(title)})
			holderframe:AddChild(textlabel)
		end
		local window = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1,0,1,-(defaultbuttonsize.Y + (defaultbuttonsize.Y/2))), CanvasSize = UDim2.new(1,0,1,-(defaultbuttonsize.Y + (defaultbuttonsize.Y/2))), Position = UDim2.new(0, 0, 0, defaultbuttonsize.Y), BackgroundTransparency = 1})
		holderframe:AddChild(window)
		local resizebutton
		local maximizepressed = false
		if not boolean2 then
			resizebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0,defaultbuttonsize.Y/2,0,defaultbuttonsize.Y/2), Image = "rbxassetid://15617867263", Position = UDim2.new(1, -defaultbuttonsize.Y/2, 1, -defaultbuttonsize.Y/2), BackgroundTransparency = 1})
			holderframe:AddChild(resizebutton)

			resizebutton.MouseButton1Down:Connect(function()
				resizebutton.Image = "rbxassetid://15617866125"
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
				resizebutton.Image = "rbxassetid://15617867263"
				holding = false
			end)
		else
			window.Size += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
			window.CanvasSize += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
		end

		if not boolean3 then

			holderframe.MouseButton1Down:Connect(function()
				if holding then return end
				programholder2:AddChild(holderframe)
				programholder1:AddChild(holderframe)
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
		else
			holderframe.MouseButton1Down:Connect(function()
				programholder2:AddChild(holderframe)
				programholder1:AddChild(holderframe)
			end)
		end

		local closebutton = screen:CreateElement("ImageButton", {BackgroundTransparency = 1, Size = UDim2.new(0, defaultbuttonsize.X, 0, defaultbuttonsize.Y), BackgroundColor3 = Color3.new(1,0,0), Image = "rbxassetid://15617983488"})
		holderframe:AddChild(closebutton)

		closebutton.MouseButton1Down:Connect(function()
			closebutton.Image = "rbxassetid://15617984474"
		end)

		closebutton.MouseButton1Up:Connect(function()
			closebutton.Image = "rbxassetid://15617983488"
			speaker:PlaySound(clicksound)
			holderframe:Destroy()
			holderframe = nil
		end)

		local maximizebutton
		local minimizebutton

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
			minimizebutton.MouseButton1Down:Connect(function()
				minimizebutton.Image = "rbxassetid://15617866125"
			end)

			if boolean then
				minimizebutton.Position -= UDim2.new(0, defaultbuttonsize.X, 0, 0)
			end

			minimizebutton.MouseButton1Up:Connect(function()
				if holding or holding2 then return end
				speaker:PlaySound(clicksound)
				minimizebutton.Image = "rbxassetid://15617867263"
				resolutionframe:AddChild(holderframe)
				holderframe.Visible = false
				local unminimizebutton = screen:CreateElement("ImageButton", {Image = "rbxassetid://15625805900", BackgroundTransparency = 1, Size = UDim2.new(0, defaultbuttonsize.X*2, 1, 0), Position = UDim2.new(0, minimizedammount * (defaultbuttonsize.X*2), 0, 0)})
				local unminimizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(text)})
				unminimizebutton:AddChild(unminimizetext)
				taskbarholderscrollingframe:AddChild(unminimizebutton)
				minimizedammount += 1
				taskbarholderscrollingframe.CanvasSize = UDim2.new(0, (minimizedammount * (defaultbuttonsize.X*2)) + (defaultbuttonsize.X*2), 1, 0)

				table.insert(minimizedprograms, unminimizebutton)

				unminimizebutton.MouseButton1Down:Connect(function()
					unminimizebutton.Image = "rbxassetid://15625805069"
				end)

				unminimizebutton.MouseButton1Up:Connect(function()
					unminimizebutton.Image = "rbxassetid://15625805900"
					speaker:PlaySound(clicksound)
					unminimizebutton.Size = UDim2.new(1,0,1,0)
					unminimizebutton:Destroy()
					minimizedammount -= 1
					programholder1:AddChild(holderframe)
					holderframe.Visible = true
					local start = 0
					for index, value in ipairs(minimizedprograms) do
						if value and value.Size ~= UDim2.new(1,0,1,0) then
							value.Position = UDim2.new(0, start * (defaultbuttonsize.X*2), 0, 0)
							taskbarholderscrollingframe.CanvasSize = UDim2.new(0, ((defaultbuttonsize.X*2) * start) + defaultbuttonsize.X, 1, 0)
							start += 1
						end
					end
				end)
			end)
		end

		if not boolean then
			maximizebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0,defaultbuttonsize.X,0,defaultbuttonsize.Y), Image = "rbxassetid://15617867263", Position = UDim2.new(0, defaultbuttonsize.X, 0, 0), BackgroundTransparency = 1})
			local maximizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "+"})
			maximizebutton:AddChild(maximizetext)

			holderframe:AddChild(maximizebutton)
			local unmaximizedsize = holderframe.Size
			local unmaximizedpos = holderframe.Position

			maximizebutton.MouseButton1Down:Connect(function()
				maximizebutton.Image = "rbxassetid://15617866125"
			end)

			maximizebutton.MouseButton1Up:Connect(function()
				if holding or holding2 then return end
				speaker:PlaySound(clicksound)
				maximizebutton.Image = "rbxassetid://15617867263"
				local holderframe = holderframe
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
			end)
		else
			if textlabel then
				textlabel.Position -= UDim2.new(0, defaultbuttonsize.X, 0, 0)
				textlabel.Size += UDim2.new(0, defaultbuttonsize.X, 0, 0)
			end
		end
		return window, holderframe, closebutton, maximizebutton, textlabel, resizebutton
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

	local function woshtmlfile(txt, screen, boolean)
		local size = UDim2.new(0.7, 0, 0.7, 0)

		if boolean then
			size = UDim2.new(0.5, 0, 0.5, 0)
		end
		local filegui = CreateWindow(size, nil, false, false, false, "File", false)
		local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
		filegui:AddChild(scrollingframe)

		StringToGui(screen, txt, scrollingframe)

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
			if color2.Text ~= "RGB (Click to update)" then
				disk:Write("Color", data)
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
			if id2.Text ~= "Image ID (Click to update)" then
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

	local function settings()
		local window = CreateWindow(UDim2.fromScale(0.7, 0.7), "Settings", false, false, false, "Settings", false)
		local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0), CanvasSize = UDim2.new(1, 0, 0, 150), ScrollBarThickness = 5})
		window:AddChild(scrollingframe)
		local changeclicksound, text1 = createnicebutton(UDim2.fromScale(0.6, 0.25), UDim2.new(0,0,0,0), "Click Sound ID (Click to update)", scrollingframe)
		local saveclicksound, text2 = createnicebutton(UDim2.fromScale(0.4, 0.25), UDim2.new(0.6,0,0,0), "Save", scrollingframe)

		local changeshutdownsound, text3 = createnicebutton(UDim2.fromScale(0.6, 0.25), UDim2.new(0,0,0.25,0), "Shutdown Sound ID (Click to update)", scrollingframe)
		local saveshutdownsound, text4 = createnicebutton(UDim2.fromScale(0.4, 0.25), UDim2.new(0.6,0,0.25,0), "Save", scrollingframe)

		local changestartsound, text5 = createnicebutton(UDim2.fromScale(0.6, 0.25), UDim2.new(0,0,0.5,0), "Startup Sound ID (Click to update)", scrollingframe)
		local savestartsound, text6 = createnicebutton(UDim2.fromScale(0.4, 0.25), UDim2.new(0.6,0,0.5,0), "Save", scrollingframe)

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

		local openchangecolor = createnicebutton(UDim2.fromScale(0.5, 0.25), UDim2.new(0,0,0.75,0), "Change Background Color", scrollingframe)
		openchangecolor.MouseButton1Up:Connect(function()
			changecolor()
		end)
		local openchangeimage = createnicebutton(UDim2.fromScale(0.5, 0.25), UDim2.new(0.5,0,0.75,0), "Change Background Image", scrollingframe)
		openchangeimage.MouseButton1Up:Connect(function()
			changebackgroundimage()
		end)
	end

	local function audioui(screen, disk, data, speaker, pitch, length)
		local holderframe, window, closebutton = CreateWindow(UDim2.new(0.5, 0, 0.5, 0), nil, false, false, false, "Audio", false)
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

	local function readfile(txt, nameondisk, boolean, directory)
		local filegui, window, closebutton, maximizebutton, textlabel = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), nil, false, false, false, "File", false)
		local deletebutton = nil

		local disktext = screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), TextScaled = true, Text = tostring(txt), RichText = true, BackgroundTransparency = 1})
		filegui:AddChild(disktext)

		print(txt)

		if boolean == true then
			deletebutton = createnicebutton2(UDim2.new(0, defaultbuttonsize.Y, 0, defaultbuttonsize.Y), UDim2.new(1, -defaultbuttonsize.Y, 0, 0), "Delete", window)

			deletebutton.MouseButton1Up:Connect(function()
				local holdframe, windowz = CreateWindow(UDim2.new(0.4, 0, 0.25, 0), "Are you sure?", true, true, false, nil, true)
				local deletebutton = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0, 0, 0.25, 0), "Yes", holdframe)
				local cancelbutton = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 0.25, 0), "No", holdframe)

				cancelbutton.MouseButton1Down:Connect(function()
					windowz:Destroy()
				end)

				deletebutton.MouseButton1Up:Connect(function()
					disk:Write(nameondisk, nil)
					windowz:Destroy()
					if window then
						window:Destroy()
					end
				end)
			end)
		elseif directory then
			deletebutton = createnicebutton2(UDim2.new(0, defaultbuttonsize.Y, 0, defaultbuttonsize.Y), UDim2.new(1, -defaultbuttonsize.Y, 0, 0), "Delete", window)

			deletebutton.MouseButton1Up:Connect(function()
				local holdframe, windowz = CreateWindow(UDim2.new(0.4, 0, 0.25, 0), "Are you sure?", true, true, false, nil, true)
				local deletebutton = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0, 0, 0.25, 0), "Yes", holdframe)
				local cancelbutton = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 0.25, 0), "No", holdframe)

				cancelbutton.MouseButton1Down:Connect(function()
					windowz:Destroy()
				end)

				deletebutton.MouseButton1Up:Connect(function()
					createfileontable(disk, nameondisk, nil, directory)
					windowz:Destroy()
					if window then
						window:Destroy()
					end
				end)
			end)
		end

		if string.find(string.lower(tostring(nameondisk)), "\.aud") then
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

				audioui(screen, disk, spacesplitted[1], speaker, tonumber(pitch), tonumber(length))

			elseif string.find(tostring(txt), "length:") then

				local splitted = string.split(tostring(txt), "length:")

				local spacesplitted = string.split(tostring(txt), " ")

				local length = nil

				if string.find(splitted[2], " ") then
					length = (string.split(splitted[2], " "))[1]
				else
					length = splitted[2]
				end

				audioui(screen, disk, spacesplitted[1], speaker, nil, tonumber(length))

			else
				audioui(screen, disk, txt, speaker)
			end
		end

		if string.find(string.lower(tostring(nameondisk)), "\.img") then
			woshtmlfile([[<img src="]]..tostring(txt)..[[" size="1,0,1,0" position="0,0,0,0">]], screen, true)
		end

		if string.find(string.lower(tostring(nameondisk)), "\.lua") then
			loadluafile(microcontrollers, screen, tostring(txt))
		end
		if typeof(txt) == "table" then
			local newdirectory = nil
			if directory then
				newdirectory = directory.."/"..nameondisk
			else
				newdirectory = "/"..nameondisk
			end
			window:Destroy()

			local tableval = txt
			local start = 0
			local holderframe, window, closebutton, maximizebutton, textlabel = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), newdirectory, false, false, false, "Table Content", false)
			local scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.new(1, 0, 0.85, 0), CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
			holderframe:AddChild(scrollingframe)

			local refreshbutton = createnicebutton(UDim2.new(0.2, 0, 0.15, 0), UDim2.new(0, 0, 0, 0), "Refresh", holderframe)

			if boolean == true then
				local alldata = disk:ReadEntireDisk()
				local deletebutton = createnicebutton(UDim2.new(0.2, 0, 0.15, 0), UDim2.new(0.8, 0, 0, 0), "Delete", holderframe)

				deletebutton.MouseButton1Up:Connect(function()
					local holdframe, windowz = CreateWindow(UDim2.new(0.4, 0, 0.25, 0), "Are you sure?", true, true, false, nil, true)
					local deletebutton = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0, 0, 0.25, 0), "Yes", holdframe)
					local cancelbutton = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 0.25, 0), "No", holdframe)

					cancelbutton.MouseButton1Down:Connect(function()
						windowz:Destroy()
					end)

					deletebutton.MouseButton1Up:Connect(function()
						disk:Write(nameondisk, nil)
						if holderframe then
							window:Destroy()
						end
						windowz:Destroy()
					end)
				end)
			elseif directory then
				local alldata = disk:ReadEntireDisk()
				local deletebutton = createnicebutton(UDim2.new(0.2, 0, 0.15, 0), UDim2.new(0.8, 0, 0, 0), "Delete", holderframe)

				deletebutton.MouseButton1Up:Connect(function()
					local holdframe, windowz = CreateWindow(UDim2.new(0.4, 0, 0.25, 0), "Are you sure?", true, true, false, nil, true)
					local deletebutton = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0, 0, 0.25, 0), "Yes", holdframe)
					local cancelbutton = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 0.25, 0), "No", holdframe)

					cancelbutton.MouseButton1Down:Connect(function()
						windowz:Destroy()
					end)

					deletebutton.MouseButton1Up:Connect(function()
						createfileontable(disk, nameondisk, nil, directory)
						windowz:Destroy()
						if window then
							window:Destroy()
						end
					end)
				end)
			end

			for index, data in pairs(tableval) do
				local button = createnicebutton(UDim2.new(1,0,0,25), UDim2.new(0, 0, 0, start), tostring(index), scrollingframe)
				scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start + 25)
				start += 25
				button.MouseButton1Down:Connect(function()
					readfile(getfileontable(disk, index, newdirectory), index, false, newdirectory)
				end)
			end

			refreshbutton.MouseButton1Up:Connect(function()
				start = 0
				scrollingframe:Destroy()
				scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.new(1, 0, 0.85, 0), CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
				holderframe:AddChild(scrollingframe)
				local tableval = if directory == nil or directory == "/" then disk:Read(nameondisk) else getfileontable(disk, nameondisk, directory)
				tableval = if typeof(tableval) == "table" then tableval else {}
				for index, data in pairs(tableval) do
					local button = createnicebutton(UDim2.new(1,0,0,25), UDim2.new(0, 0, 0, start), tostring(index), scrollingframe)
					scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start + 25)
					start += 25
					button.MouseButton1Down:Connect(function()
						readfile(getfileontable(disk, index, newdirectory), index, false, newdirectory)
					end)
				end
			end)
		end

		if string.find(string.lower(tostring(txt)), "<woshtml>") then
			woshtmlfile(txt, screen)
		end

	end

	local function loaddisk()
		local start = 0
		local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "/", false, false, false, "Files", false)
		local scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.new(1, 0, 0.85, 0), CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
		holderframe:AddChild(scrollingframe)

		local refreshbutton = createnicebutton(UDim2.new(0.2, 0, 0.15, 0), UDim2.new(0, 0, 0, 0), "Refresh", holderframe)

		for filename, data in pairs(disk:ReadEntireDisk()) do
			if filename ~= "Color" and filename ~= "BackgroundImage" then
				local button = createnicebutton(UDim2.new(1,0,0,25), UDim2.new(0, 0, 0, start), tostring(filename), scrollingframe)
				scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start + 25)
				start += 25
				button.MouseButton1Down:Connect(function()
					local data = disk:Read(filename)
					readfile(data, filename, true)
				end)
			end
		end

		refreshbutton.MouseButton1Up:Connect(function()
			start = 0
			scrollingframe:Destroy()
			scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.new(1, 0, 0.85, 0), CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0.15, 0), BackgroundTransparency = 1})
			holderframe:AddChild(scrollingframe)
			for filename, data in pairs(disk:ReadEntireDisk()) do
				if filename ~= "Color" and filename ~= "BackgroundImage" then
					local button = createnicebutton(UDim2.new(1,0,0,25), UDim2.new(0, 0, 0, start), tostring(filename), scrollingframe)
					scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start + 25)
					start += 25
					button.MouseButton1Down:Connect(function()
						local data = disk:Read(filename)
						readfile(data, filename, true)
					end)
				end
			end
		end)
	end

	local function writedisk()
		local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Create File", false, false, false, "File Creator", false)
		local scrollingframe = holderframe
		local filenamebutton, filenamebutton2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0, 0), "File Name(Case Sensitive) (Click to update)", scrollingframe)
		local filedatabutton, filedatabutton2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0.2, 0), "File Data (Click to update)", scrollingframe)
		local createfilebutton, createfilebutton2 = createnicebutton(UDim2.new(0.5,0,0.2, 0), UDim2.new(0, 0, 0.8, 0), "Save", scrollingframe)

		local createtablebutton, createtablebutton2 = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0.5, 0, 0.8, 0), "Create Table", scrollingframe)

		local directorybutton, directorybutton2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0.4, 0), [[Directory(Case Sensitive) (Click to update) example: "/sounds"]], scrollingframe)

		local data = nil
		local filename = nil


		local directory = ""


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
				filedatabutton2.Text = keyboardinput:gsub("\n", ""):gsub("/n\\", "\n")
				data = keyboardinput:gsub("\n", ""):gsub("/n\\", "\n")
			end
		end)

		createfilebutton.MouseButton1Down:Connect(function()
			if filenamebutton2.Text ~= "File Name(Case Sensitive if on a table) (Click to update)" and filename ~= "Color" and filename ~= "BackgroundImage" then
				if filedatabutton2.Text ~= "File Data (Click to update)" then
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
			if filenamebutton2.Text ~= "File Name(Case Sensitive if on a table) (Click to update)" and filename ~= "Color" and filename ~= "BackgroundImage" and filename ~= "GustavOS Library" then
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

	local function shutdownmicros(screen, micros)
		local holderframe = CreateWindow(UDim2.new(0.75, 0, 0.75, 0), "Microcontroller Manager", false ,false, false, "Microcontroller Manager", false)

		local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
		holderframe:AddChild(scrollingframe)

		local start = 0
		if not microcontrollers then return end
		for index, value in pairs(microcontrollers) do
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

		local runcodebutton, runcodebutton2 = createnicebutton(UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.8, 0), "Run lua", holderframe)

		runcodebutton.MouseButton1Up:Connect(function()
			if code ~= "" then
				loadluafile(microcontrollers, screen, code, runcodebutton2)
			end
		end)
	end

	local function mediaplayer()
		local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Media player", false, false, false, "Media player", false)
		local scrollingframe = holderframe
		local Filename, Filename2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0, 0), "File with id(Case Sensitive) (Click to update)", scrollingframe)
		local openimage = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0, 0, 0.8, 0), "Open as image", scrollingframe)
		local openaudio = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0.5, 0, 0.8, 0), "Open as audio", scrollingframe)

		local data = nil
		local filename = nil

		local toggleopen = true
		local Toggle1, Toggle12 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0.2, 0), "Open from File: Yes", scrollingframe)
		Toggle1.MouseButton1Up:Connect(function()
			if toggleopen then
				toggleopen = false
				Toggle12.Text = "Open from File: No"
			else
				toggleopen = true
				Toggle12.Text = "Open from File: Yes"
			end
		end)

		Filename.MouseButton1Down:Connect(function()
			if keyboardinput then
				Filename2.Text = keyboardinput:gsub("\n", ""):gsub("/n\\", "\n")
				data = keyboardinput:gsub("\n", ""):gsub("/n\\", "\n")
			end
		end)

		local directorybutton2, directorybutton = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0.4, 0), [[Directory (Click to update) example: "/sounds"]], scrollingframe)
		local directory = ""

		directorybutton2.MouseButton1Down:Connect(function()
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
							directorybutton.Text = inputtedtext
							directory = inputtedtext
						else
							directorybutton.Text = "Invalid"
							task.wait(2)
							if directory ~= "" then
								directorybutton.Text = [[Directory(Case Sensitive) (Click to update) example: "/sounds"]]
							else
								directorybutton.Text = directory
							end
						end
					else
						if disk:Read(split[#split]) or split[2] == "" then
							directorybutton.Text = inputtedtext
							directory = inputtedtext
						else
							directorybutton.Text = "Invalid"
							task.wait(2)
							if directory == "" then
								directorybutton.Text = [[Directory(Case Sensitive) (Click to update) example: "/sounds"]]
							else
								directorybutton.Text = directory
							end
						end
					end
				elseif inputtedtext == "" then
					directorybutton.Text = [[Directory(Case Sensitive) (Click to update) example: "/sounds"]]
					directory = inputtedtext
				else
					directorybutton.Text = "Invalid"
					task.wait(2)
					directorybutton.Text = [[Directory(Case Sensitive) (Click to update) example: "/sounds"]]
				end
			end
		end)


		openaudio.MouseButton1Down:Connect(function()
			if Filename.Text ~= "File with id(Case Sensitive if on a table) (Click to update)" then
				local readdata = nil
				if toggleopen then
					local split = nil
					if directory ~= "" then
						split = string.split(directory, "/")
					end
					if not split or split[2] == "" then
						readdata = tostring(disk:Read(data))
					else
						readdata = tostring(getfileontable(disk, data, directory))
					end
				else
					readdata = string.lower(tostring(data))
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

					audioui(screen, disk, spacesplitted[1], speaker, tonumber(pitch), tonumber(length))

				elseif string.find(tostring(data), "length:") then

					local splitted = string.split(tostring(data), "length:")

					local spacesplitted = string.split(tostring(data), " ")

					local length = nil

					if string.find(splitted[2], " ") then
						length = (string.split(splitted[2], " "))[1]
					else
						length = splitted[2]
					end

					audioui(screen, disk, spacesplitted[1], speaker, nil, tonumber(length))

				else
					audioui(screen, disk, data, speaker)
				end
			end
		end)

		openimage.MouseButton1Down:Connect(function()
			if Filename.Text ~= "File with id(Case Sensitive if on a table) (Click to update)" then
				local readdata = nil
				if toggleopen then
					local split = nil
					if directory ~= "" then
						split = string.split(directory, "/")
					end
					if not split or split[2] == "" then
						readdata = disk:Read(data)
					else
						readdata = getfileontable(disk, data, directory)
					end
				else
					readdata = tostring(data)
				end
				woshtmlfile([[<img src="]]..readdata..[[" size="1,0,1,0" position="0,0,0,0">]], screen, true)
			end
		end)
	end

	local function chatthing()
		local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), nil, false, false, false, "Chat", false)

		local messagesent = nil

		if modem then

			local id = 0

			local toggleanonymous = false
			local togglea, togglea2 = createnicebutton(UDim2.new(0.4, 0, 0.1, 0), UDim2.new(0,0,0,0), "Enable anonymous mode", holderframe)

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
					togglea2.Text = "Enable anonymous mode"
					toggleanonymous = false
				else
					toggleanonymous = true
					togglea2.Text = "Disable anonymous mode"
				end
			end)

			local scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.new(1, 0, 0.8, 0), Position = UDim2.new(0, 0, 0.1, 0), BackgroundTransparency = 1})
			holderframe:AddChild(scrollingframe)

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

			messagesent = modem:Connect("MessageSent", function(text)
				print(text)
				local textlabel = screen:CreateElement("TextLabel", {Text = tostring(text), Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, start), TextScaled = true})
				scrollingframe:AddChild(textlabel)
				scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start + 25)
				start += 25
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

		local data = nil
		local filename = nil

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
				number1 = string.gsub(tostring(number1), "-", "")
				number1 = "-"..tostring(number1)
				part1.Text = number1
			else
				number2 = string.gsub(tostring(number2), "-", "")
				number2 = "-"..tostring(number2)
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

	local function shutdownprompt()
		local window, holderframe = CreateWindow(UDim2.new(0.4, 0, 0.25, 0), "Are you sure?",true,true,false,nil,true)
		local yes = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0, 0, 0.25, 0), "Yes", window)
		local no = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 0.25, 0), "No", window)
		no.MouseButton1Up:Connect(function()
			holderframe:Destroy()
		end)
		yes.MouseButton1Up:Connect(function()
			if holderframe then
				holderframe:Destroy()
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
			task.wait(1)
			speaker:ClearSounds()
			SpeakerHandler.PlaySound(shutdownsound, 1, nil, speaker)
			for i=0,1,0.05 do
				task.wait(0.05)
				backgroundcolor.BackgroundTransparency = i
				wallpaper.ImageTransparency = i
			end
			task.wait(1)
			screen:ClearElements()
			local commandlines = commandline.new(false, nil, screen)
			commandlines:insert("Shutting Down...")
			task.wait(2)
			screen:ClearElements()
			if shutdownpoly then
				TriggerPort(shutdownpoly)
			end
		end)
	end

	local function restartprompt()
		local window, holderframe = CreateWindow(UDim2.new(0.4, 0, 0.25, 0), "Are you sure?",true,true,false,nil,true)
		local yes = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0, 0, 0.25, 0), "Yes", window)
		local no = createnicebutton(UDim2.new(0.5, 0, 0.75, 0), UDim2.new(0.5, 0, 0.25, 0), "No", window)
		no.MouseButton1Up:Connect(function()
			holderframe:Destroy()
		end)
		yes.MouseButton1Up:Connect(function()
			if holderframe then
				holderframe:Destroy()
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
			task.wait(1)
			speaker:ClearSounds()
			SpeakerHandler.PlaySound(shutdownsound, 1, nil, speaker)
			for i=0,1,0.01 do
				task.wait(0.01)
				backgroundcolor.BackgroundTransparency = i
				wallpaper.ImageTransparency = i
			end
			task.wait(1)
			screen:ClearElements()
			local commandlines = commandline.new(false, nil, screen)
			commandlines:insert("Restarting...")
			task.wait(2)
			screen:ClearElements()
			getstuff()
			task.wait(1)
			bootos()
		end)
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

		local name = "GustavDOS For GustavOSDesktop7"

		local button = createnicebutton(UDim2.new(0.2, 0, 0.2, 0), UDim2.new(0.8, 0, 0.8, 0), "Run", window)

		local textbox, textboxtext = createnicebutton(UDim2.new(0.8, 0, 0.2, 0), UDim2.new(0, 0, 0.8, 0), "Command (Click to update)", window)
		local textinput

		textbox.MouseButton1Up:Connect(function()
			if keyboardinput then
				textinput = tostring(keyboardinput)
				textboxtext.Text = tostring(keyboardinput):gsub("\n", "")
			end
		end)

		local background
		local commandlines

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

		local function playsound(txt)
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
					audioui(screen, disk, spacesplitted[1], speaker, tonumber(pitch), tonumber(length))
				elseif string.find(tostring(txt), "length:") then

					local splitted = string.split(tostring(txt), "length:")

					local spacesplitted = string.split(tostring(txt), " ")

					local length = nil

					if string.find(splitted[2], " ") then
						length = (string.split(splitted[2], " "))[1]
					else
						length = splitted[2]
					end

					audioui(screen, disk, spacesplitted[1], speaker, nil, tonumber(length))

				else
					audioui(screen, disk, txt, speaker)
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
				local filename = texts:split("::")[1]
				local filedata = texts:split("::")[2]
				for i,v in ipairs(texts:split("::")) do
					if i > 2 then
						filedata = filedata.."::"..v
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
						local textlabel = commandlines:insert(tostring(disk:Read(filename)), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
						local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..id})
						textlabel:AddChild(videoframe)
						videoframe.Playing = true
						print(disk:Read(filename))
					else
						local textlabel = commandlines:insert(tostring(getfileontable(disk, filename, dir)), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
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
				playsound(txt)
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
				commandlines:insert("write filename::filedata")
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
						if string.find(filename, "\.aud") then
							commandlines:insert(tostring(output))
							playsound(output)
							commandlines:insert(dir..":")
							print(output)
						elseif string.find(filename, "\.img") then
							local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
							StringToGui(screen, [[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
							commandlines:insert(dir..":")
							background.CanvasPosition -= Vector2.new(0, 25)
							print(output)
						elseif string.find(filename, "\.lua") then
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
						if string.find(filename, "\.aud") then
							commandlines:insert(tostring(output))
							playsound(output)
							commandlines:insert(dir..":")
							print(output)
						elseif string.find(filename, "\.img") then
							local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
							StringToGui(screen, [[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
							commandlines:insert(dir..":")
							background.CanvasPosition -= Vector2.new(0, 25)
							print(output)
						elseif string.find(filename, "\.lua") then
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
			if disks and #disks > 0 then
				print(tostring(romport).."\\"..tostring(disksport))
				if romport ~= disksport then
					for i,v in ipairs(disks) do
						if rom ~= v then
							disk = v
							break
						end
					end
				else
					for i,v in ipairs(disks) do
						if rom ~= v and i ~= romindexusing then
							disk = v
							break
						end
					end
				end
			end
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
					commandlines:insert(tostring(textinput):gsub("\n", ""))
					runtext(tostring(textinput):gsub("\n", ""))
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

	function loaddesktop()
		minimizedammount = 0
		minimizedprograms = {}
		resolutionframe = screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Position = UDim2.new(2,0,0,0)})
		backgroundcolor = screen:CreateElement("Frame", {Size = UDim2.new(1,0,1,0), BackgroundColor3 = color})
		wallpaper = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1})
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

		startbutton7 = screen:CreateElement("ImageButton", {Image = "rbxassetid://15617867263", BackgroundTransparency = 1, Size = UDim2.new(0.1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)})
		local textlabel = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = "G", TextScaled = true, TextWrapped = true})
		startbutton7:AddChild(textlabel)

		programholder1 = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
		programholder2 = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
		programholder1:AddChild(programholder2)

		taskbarholder = screen:CreateElement("ImageButton", {Image = "rbxassetid://15619032563", Position = UDim2.new(0, 0, 0.9, 0), Size = UDim2.new(1, 0, 0.1, 0), BackgroundTransparency = 1, ImageTransparency = 0.25})
		taskbarholder:AddChild(startbutton7)

		taskbarholderscrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(0.9, 0, 1, 0), BackgroundTransparency = 1, CanvasSize = UDim2.new(0.9, 0, 1, 0), Position = UDim2.new(0.1, 0, 0, 0), ScrollBarThickness = 2.5})
		taskbarholder:AddChild(taskbarholderscrollingframe)
		rom:Write("GustavOSLibrary", nil)
		rom:Write("GD7Library", nil)
		rom:Write("GDOSLibrary", nil)
		rom:Write("GD7Library", {
			Screen = screen,
			Keyboard = keyboard,
			Modem = modem,
			Speaker = speaker,
			Disk = disk,
			programholder1 = programholder1,
			programholder2 = programholder2,
			Taskbar = {taskbarholderscrollingframe, taskbarholder},
			screenresolution = resolutionframe,
		})

		if not disk:Read("sounds") then
			local window, holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Welcome to GustavOS", false, false, false, "Welcome", false)
			local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,0,0.8,0), Position = UDim2.new(0, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Would you like to add some sounds to the hard drive?", BackgroundTransparency = 1})
			window:AddChild(textlabel)
			local yes = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0, 0, 0.8, 0), "Yes", window)
			local no = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0.5, 0, 0.8, 0), "No", window)

			no.MouseButton1Up:Connect(function()
				holderframe:Destroy()
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
				holderframe:Destroy()
			end)
		end
		local pressed = false
		local startmenu
		local function openstartmenu()
			if not pressed then
				startmenu = screen:CreateElement("ImageButton", {BackgroundTransparency = 1, Image = "rbxassetid://15619032563", Size = UDim2.new(0.3, 0, 5, 0), Position = UDim2.new(0, 0, -5, 0), ImageTransparency = 0.2})
				taskbarholder:AddChild(startmenu)
				local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1,0,0.8,0), CanvasSize = UDim2.new(1, 0, 1.8, 0), BackgroundTransparency = 1, ScrollBarThickness = 5})
				startmenu:AddChild(scrollingframe)
				local settingsopen = screen:CreateElement("ImageButton", {Size = UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), Image = "rbxassetid://15625805900", Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
				scrollingframe:AddChild(settingsopen)
				local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Settings"})
				settingsopen:AddChild(txtlabel)
				settingsopen.MouseButton1Down:Connect(function()
					settingsopen.Image = "rbxassetid://15625805069"
				end)
				settingsopen.MouseButton1Up:Connect(function()
					speaker:PlaySound(clicksound)
					settingsopen.Image = "rbxassetid://15625805900"
					settings()
					pressed = false
					startmenu:Destroy()
				end)

				local diskwriteopen = screen:CreateElement("ImageButton", {Size = UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), Image = "rbxassetid://15625805900", Position = UDim2.new(0, 0, 0.2/scrollingframe.CanvasSize.Y.Scale, 0), BackgroundTransparency = 1})
				scrollingframe:AddChild(diskwriteopen)
				local txtlabel2 = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Create/Overwrite File"})
				diskwriteopen:AddChild(txtlabel2)
				diskwriteopen.MouseButton1Down:Connect(function()
					diskwriteopen.Image = "rbxassetid://15625805069"
				end)
				diskwriteopen.MouseButton1Up:Connect(function()
					speaker:PlaySound(clicksound)
					diskwriteopen.Image = "rbxassetid://15625805900"
					writedisk()
					pressed = false
					startmenu:Destroy()
				end)

				local filesopen = screen:CreateElement("ImageButton", {Size = UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), Image = "rbxassetid://15625805900", Position = UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*2, 0), BackgroundTransparency = 1})
				scrollingframe:AddChild(filesopen)
				local txtlabel3 = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Files"})
				filesopen:AddChild(txtlabel3)
				filesopen.MouseButton1Down:Connect(function()
					filesopen.Image = "rbxassetid://15625805069"
				end)
				filesopen.MouseButton1Up:Connect(function()
					speaker:PlaySound(clicksound)
					filesopen.Image = "rbxassetid://15625805900"
					loaddisk()
					pressed = false
					startmenu:Destroy()
				end)

				local luasopen = screen:CreateElement("ImageButton", {Size = UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), Image = "rbxassetid://15625805900", Position = UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*3, 0), BackgroundTransparency = 1})
				scrollingframe:AddChild(luasopen)
				local txtlabel4 = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Lua executor"})
				luasopen:AddChild(txtlabel4)
				luasopen.MouseButton1Down:Connect(function()
					luasopen.Image = "rbxassetid://15625805069"
				end)
				luasopen.MouseButton1Up:Connect(function()
					speaker:PlaySound(clicksound)
					luasopen.Image = "rbxassetid://15625805900"
					customprogramthing(screen, micros)
					pressed = false
					startmenu:Destroy()
				end)

				local mediaopen = screen:CreateElement("ImageButton", {Size = UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), Image = "rbxassetid://15625805900", Position = UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*4, 0), BackgroundTransparency = 1})
				scrollingframe:AddChild(mediaopen)
				local txtlabel5 = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Mediaplayer"})
				mediaopen:AddChild(txtlabel5)
				mediaopen.MouseButton1Down:Connect(function()
					mediaopen.Image = "rbxassetid://15625805069"
				end)
				mediaopen.MouseButton1Up:Connect(function()
					speaker:PlaySound(clicksound)
					mediaopen.Image = "rbxassetid://15625805900"
					mediaplayer()
					pressed = false
					startmenu:Destroy()
				end)

				local chatopen = screen:CreateElement("ImageButton", {Size = UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), Image = "rbxassetid://15625805900", Position = UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*5, 0), BackgroundTransparency = 1})
				scrollingframe:AddChild(chatopen)
				local txtlabel6 = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Chat"})
				chatopen:AddChild(txtlabel6)
				chatopen.MouseButton1Down:Connect(function()
					chatopen.Image = "rbxassetid://15625805069"
				end)
				chatopen.MouseButton1Up:Connect(function()
					speaker:PlaySound(clicksound)
					chatopen.Image = "rbxassetid://15625805900"
					chatthing()
					pressed = false
					startmenu:Destroy()
				end)

				local calculatoropen = screen:CreateElement("ImageButton", {Size = UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), Image = "rbxassetid://15625805900", Position = UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*6, 0), BackgroundTransparency = 1})
				scrollingframe:AddChild(calculatoropen)
				local txtlabel7 = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Calculator"})
				calculatoropen:AddChild(txtlabel7)
				calculatoropen.MouseButton1Down:Connect(function()
					calculatoropen.Image = "rbxassetid://15625805069"
				end)
				calculatoropen.MouseButton1Up:Connect(function()
					speaker:PlaySound(clicksound)
					calculatoropen.Image = "rbxassetid://15625805900"
					calculator()
					pressed = false
					startmenu:Destroy()
				end)

				local terminalopen = screen:CreateElement("ImageButton", {Size = UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), Image = "rbxassetid://15625805900", Position = UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*7, 0), BackgroundTransparency = 1})
				scrollingframe:AddChild(terminalopen)
				local txtlabel8 = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Terminal"})
				terminalopen:AddChild(txtlabel8)
				terminalopen.MouseButton1Down:Connect(function()
					terminalopen.Image = "rbxassetid://15625805069"
				end)
				terminalopen.MouseButton1Up:Connect(function()
					speaker:PlaySound(clicksound)
					terminalopen.Image = "rbxassetid://15625805900"
					pressed = false
					startmenu:Destroy()
					terminal()
				end)

				local restartkeyboardinput = screen:CreateElement("ImageButton", {Size = UDim2.new(1,0,0.2/scrollingframe.CanvasSize.Y.Scale,0), Image = "rbxassetid://15625805900", Position = UDim2.new(0, 0, (0.2/scrollingframe.CanvasSize.Y.Scale)*8, 0), BackgroundTransparency = 1})
				scrollingframe:AddChild(restartkeyboardinput)
				local txtlabel9 = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Reset Keyboard Event"})
				restartkeyboardinput:AddChild(txtlabel9)
				restartkeyboardinput.MouseButton1Up:Connect(function()
					speaker:PlaySound(clicksound)
					if keyboardevent then keyboardevent:Unbind() end
					keyboardevent = keyboard:Connect("TextInputted", function(text, player)
						keyboardinput = text
						playerthatinputted = player
					end)
					restartkeyboardinput.Image = "rbxassetid://15625805900"
					pressed = false
					startmenu:Destroy()
				end)

				local shutdown = screen:CreateElement("ImageButton", {Size = UDim2.new(0.5,0,0.2,0), Image = "rbxassetid://15625805900", Position = UDim2.new(0, 0, 0.8, 0), BackgroundTransparency = 1})
				startmenu:AddChild(shutdown)
				local shutdowntext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Shutdown"})
				shutdown:AddChild(shutdowntext)
				shutdown.MouseButton1Down:Connect(function()
					shutdown.Image = "rbxassetid://15625805069"
				end)

				shutdown.MouseButton1Up:Connect(function()
					speaker:PlaySound(clicksound)
					shutdown.Image = "rbxassetid://15625805900"
					pressed = false
					startmenu:Destroy()
					shutdownprompt()
				end)

				local restart = screen:CreateElement("ImageButton", {Size = UDim2.new(0.5,0,0.2,0), Image = "rbxassetid://15625805900", Position = UDim2.new(0.5, 0, 0.8, 0), BackgroundTransparency = 1})
				startmenu:AddChild(restart)
				local restarttext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "Restart"})
				restart:AddChild(restarttext)
				restart.MouseButton1Down:Connect(function()
					restart.Image = "rbxassetid://15625805069"
				end)

				restart.MouseButton1Up:Connect(function()
					speaker:PlaySound(clicksound)
					restart.Image = "rbxassetid://15625805900"
					pressed = false
					startmenu:Destroy()
					restartprompt()
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
			speaker:PlaySound(clicksound)
		end)
		cursorevent = screen:Connect("CursorMoved", function(cursor)
			if screen then
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
							else
								holding2 = false
							end
						end
					end
				end

				if holding then
					if not holderframetouse then holding = false; return end
					local cursors = screen:GetCursors()
					local cursor
					for index,cur in pairs(cursors) do
						if startCursorPos and cur then
							if cur.Player == startCursorPos.Player then
								cursor = cur
							end
						end
					end
					if not cursor then holding = false end
					if cursor then
						local newX = (cursor.X - holderframetouse.AbsolutePosition.X) +((defaultbuttonsize.Y/2)/2)
						local newY = (cursor.Y - holderframetouse.AbsolutePosition.Y) +((defaultbuttonsize.Y/2)/2)
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
				players[cursor.Player] = {tick(), a}
			end
			players[cursor.Player][2].Position = UDim2.fromOffset(cursor.X, cursor.Y)
			players[cursor.Player][1] = tick()
		end)
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

		local text4 = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, TextScaled = true, Text = if game and workspace then "Reason: pilot.lua emulator skill issue" else "Reason: Creator skill issue", Size = UDim2.new(1, 0, 0.25, 0), Position = UDim2.new(0, 0, 0.75, 0)})
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
		return lines, background, holderframe
	end
end

function bootos()
	if disks and #disks > 0 then
		print(tostring(romport).."\\"..tostring(disksport))
		if romport ~= disksport then
			for i,v in ipairs(disks) do
				if rom ~= v then
					disk = v
					break
				end
			end
		else
			for i,v in ipairs(disks) do
				if rom ~= v and i ~= romindexusing then
					disk = v
					break
				end
			end
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
		if disk then
			clicksound = rom:Read("ClickSound")
			shutdownsound = rom:Read("ShutdownSound")
			startsound = rom:Read("StartSound")
			if not clicksound then clicksound = "rbxassetid://6977010128"; else clicksound = "rbxassetid://"..tostring(clicksound); end
			if not startsound then startsound = 182007357; end
			if not shutdownsound then shutdownsound = 7762841318; end
			color = disk:Read("Color")
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
		    loaddesktop()
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
