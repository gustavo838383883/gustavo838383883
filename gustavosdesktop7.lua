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
					elseif #(temprom:ReadEntireDisk()) == 1 and temprom:Read("GustavOSLibrary") then
						temprom:Write("GustavOSLibrary", nil)
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
						rom = v
						romindexusing = index
						romport = i
						sharedport = true
						break
					elseif #(v:ReadEntireDisk()) == 1 and v:Read("GustavOSLibrary") then
						v:Write("GustavOSLibrary", nil)
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
	programholder1:AddChild(holderframe)
	local textlabel
	if typeof(title) == "string" then
		textlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1, -70, 0, 25), BackgroundTransparency = 1, Position = UDim2.new(0, 70, 0, 0), TextScaled = true, TextWrapped = true, Text = tostring(title)})
		holderframe:AddChild(textlabel)
	end
	local resizebutton
	local maximizepressed = false
	if not boolean2 then
		resizebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0,10,0,10), Image = "rbxassetid://15617867263", Position = UDim2.new(1, -10, 1, -10), BackgroundTransparency = 1})
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
		speaker:PlaySound(clicksound)
		holderframe:Destroy()
		holderframe = nil
	end)

	local maximizebutton
	local minimizebutton
	
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

		if boolean then
			minimizebutton.Position -= UDim2.new(0, 35, 0, 0)
		end
		
		minimizebutton.MouseButton1Up:Connect(function()
			if holding or holding2 then return end
			speaker:PlaySound(clicksound)
			minimizebutton.Image = "rbxassetid://15617867263"
			resolutionframe:AddChild(holderframe)
			local unminimizebutton = screen:CreateElement("ImageButton", {Image = "rbxassetid://15625805900", BackgroundTransparency = 1, Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(0, minimizedammount * 50, 0, 0)})
			local unminimizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(text)})
			unminimizebutton:AddChild(unminimizetext)
			taskbarholderscrollingframe:AddChild(unminimizebutton)
			taskbarholderscrollingframe.CanvasSize = UDim2.new(0, (minimizedammount * 50) + 50, 1, 0) 

			table.insert(minimizedprograms, unminimizebutton)
			minimizedammount += 1
			
			unminimizebutton.MouseButton1Down:Connect(function()
				unminimizebutton.Image = "rbxassetid://15625805069"
			end)
			
			unminimizebutton.MouseButton1Up:Connect(function()
				unminimizebutton.Image = "rbxassetid://15625805900"
				speaker:PlaySound(clicksound)
				unminimizebutton.Size = UDim2.new(1,0,1,0)
				unminimizebutton:Destroy()
				minimizedammount -= 1
				if maximizepressed then
					programholder2:AddChild(holderframe)
				else
					programholder1:AddChild(holderframe)
				end
				local start = 0
				for index, value in ipairs(minimizedprograms) do
					if value and value.Size ~= UDim2.new(1,0,1,0) then
						value.Position = UDim2.new(0, start * 50, 0, 0)
						taskbarholderscrollingframe.CanvasSize = UDim2.new(0, (50 * start) + 50, 1, 0)
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
			speaker:PlaySound(clicksound)
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
		if textlabel then
			textlabel.Position -= UDim2.new(0, 35, 0, 0)
			textlabel.Size += UDim2.new(0, 35, 0, 0)
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
		holderframe = CreateWindow(udim2, "Command Line", false, false, false, "Command Line", false)
		background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -35), BackgroundColor3 = Color3.new(0,0,0), Position = UDim2.new(0, 0, 0, 25)})
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

local name = "GustavOSDesktop7"

local keyboardevent
local cursorevent

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
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -35), Position = UDim2.new(0, 0, 0, 25), CanvasSize = UDim2.new(0, 0, 1, -35), BackgroundTransparency = 1})
	filegui:AddChild(scrollingframe)

	StringToGui(screen, txt, scrollingframe)

end

local function changecolor()
	local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Change Desktop Color", false, false)
	local color, color2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0, 25), "RGB (Click to update)", holderframe)
	local changecolorbutton, changecolorbutton2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0.8, -10), "Change Color", holderframe)
	
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
	local id, id2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0, 25), "Image ID (Click to update)", holderframe)
	local tiletoggle, tiletoggle2 = createnicebutton(UDim2.new(0.25,0,0.2,0), UDim2.new(0, 0, 0.2, 25), "Enable tile", holderframe)
	local tilenumber, tilenumber2 = createnicebutton(UDim2.new(0.75,0,0.2,0), UDim2.new(0.25, 0, 0.2, 25), "UDim2 (Click to update)", holderframe)
	local changebackimg, changebackimg2 = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0.8, -10), "Change Background Image", holderframe)


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
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -35), BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 25), CanvasSize = UDim2.new(1, 0, 0, 150), ScrollBarThickness = 5})
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
	local holderframe, closebutton = CreateWindow(UDim2.new(0.5, 0, 0.5, 0), nil, false, false, false, "Audio", false)
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
						print("No port connected to polysilicon")
					end
				else
					print("No polysilicon connected to microcontroller")
				end
			end
		end
	end
	if not success then
		local comandlines = commandline.new(true, UDim2.new(0.5, 0, 0.5, 0), screen)
		commandlines:insert("No microcontrollers left.")
	end
end

local function readfile(txt, nameondisk, boolean, directory)
	local filegui, closebutton, maximizebutton, textlabel = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), nil, false, false, false, "File", false)
	local deletebutton = nil

	local disktext = screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, -35), Position = UDim2.new(0, 0, 0, 25), TextScaled = true, Text = tostring(txt), RichText = true, BackgroundTransparency = 1})
	filegui:AddChild(disktext)
	
	print(txt)
	
	if boolean == true then
		deletebutton = createnicebutton2(UDim2.new(0, 25, 0, 25), UDim2.new(1, -25, 0, 0), "Delete", filegui)
		
		deletebutton.MouseButton1Up:Connect(function()
			local holdframe = CreateWindow(UDim2.new(0.4, 0, 0.25, 25), "Are you sure?", true, true, false, nil, true)
			local deletebutton = createnicebutton(UDim2.new(0.5, 0, 0.75, -25), UDim2.new(0, 0, 0.25, 25), "Yes", holdframe)
			local cancelbutton = createnicebutton(UDim2.new(0.5, 0, 0.75, -25), UDim2.new(0.5, 0, 0.25, 25), "No", holdframe)
				
			cancelbutton.MouseButton1Down:Connect(function()
				holdframe:Destroy()
				holdframe = nil
			end)

			deletebutton.MouseButton1Up:Connect(function()
				disk:Write(nameondisk, nil)
				holdframe:Destroy()
				if filegui then
					filegui:Destroy()
				end
				filegui = nil
			end)
		end)
	elseif directory then
		deletebutton = createnicebutton2(UDim2.new(0, 25, 0, 25), UDim2.new(1, -25, 0, 0), "Delete", filegui)
		
		deletebutton.MouseButton1Up:Connect(function()
			local holdframe = CreateWindow(UDim2.new(0.4, 0, 0.25, 25), "Are you sure?", true, true, false, nil, true)
			local deletebutton = createnicebutton(UDim2.new(0.5, 0, 0.75, -25), UDim2.new(0, 0, 0.25, 25), "Yes", holdframe)
			local cancelbutton = createnicebutton(UDim2.new(0.5, 0, 0.75, -25), UDim2.new(0.5, 0, 0.25, 25), "No", holdframe)
				
			cancelbutton.MouseButton1Down:Connect(function()
				holdframe:Destroy()
				holdframe = nil
			end)

			deletebutton.MouseButton1Up:Connect(function()
				createfileontable(disk, nameondisk, nil, directory)
				holdframe:Destroy()
				if filegui then
					filegui:Destroy()
				end
				filegui = nil
			end)
		end)
	end
	
	if string.find(string.lower(tostring(nameondisk)), ".aud") then
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

	if string.find(string.lower(tostring(nameondisk)), ".img") then
		woshtmlfile([[<img src="]]..tostring(txt)..[[" size="1,0,1,0" position="0,0,0,0">]], screen, true)
	end

	if string.find(string.lower(tostring(nameondisk)), ".lua") then
		loadluafile(microcontrollers, screen, tostring(txt))
	end
	if typeof(txt) == "table" then
		local newdirectory = nil
		if directory then
			newdirectory = directory.."/"..nameondisk
		else
			newdirectory = "/"..nameondisk
		end
		filegui:Destroy()
		filegui = nil
		
		local tableval = txt
		local start = 0
		local holderframe, closebutton, maximizebutton, textlabel = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Table Content", false, false, false, "Table Content", false)
		local scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.new(1, 0, 1, -35), CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0, 25), BackgroundTransparency = 1})
		holderframe:AddChild(scrollingframe)
		textlabel.Size -= UDim2.new(0, 0, 0, 25)
		
		if boolean == true then
			local alldata = disk:ReadEntireDisk()
			local deletebutton = createnicebutton2(UDim2.new(0, 25, 0, 25), UDim2.new(1, -25, 0, 0), "Delete", holderframe)
			textlabel.Size = UDim2.new(1,-130,0,25)
			
			deletebutton.MouseButton1Up:Connect(function()
				local holdframe = CreateWindow(UDim2.new(0.4, 0, 0.25, 25), "Are you sure?", true, true, false, nil, true)
				local deletebutton = createnicebutton(UDim2.new(0.5, 0, 0.75, -25), UDim2.new(0, 0, 0.25, 25), "Yes", holdframe)
				local cancelbutton = createnicebutton(UDim2.new(0.5, 0, 0.75, -25), UDim2.new(0.5, 0, 0.25, 25), "No", holdframe)
					
				cancelbutton.MouseButton1Down:Connect(function()
					holdframe:Destroy()
					holdframe = nil
				end)
	
				deletebutton.MouseButton1Up:Connect(function()
					disk:Write(nameondisk, nil)
					if holderframe then
						holderframe:Destroy()
					end
					holdframe:Destroy()
					holderframe = nil
				end)
			end)
		elseif directory then
			local alldata = disk:ReadEntireDisk()
			local deletebutton = createnicebutton2(UDim2.new(0, 25, 0, 25), UDim2.new(1, -25, 0, 0), "Delete", holderframe)
			textlabel.Size = UDim2.new(1,-130,0,25)
			
			deletebutton.MouseButton1Up:Connect(function()
				local holdframe = CreateWindow(UDim2.new(0.4, 0, 0.25, 25), "Are you sure?", true, true, false, nil, true)
				local deletebutton = createnicebutton(UDim2.new(0.5, 0, 0.75, -25), UDim2.new(0, 0, 0.25, 25), "Yes", holdframe)
				local cancelbutton = createnicebutton(UDim2.new(0.5, 0, 0.75, -25), UDim2.new(0.5, 0, 0.25, 25), "No", holdframe)
				
				cancelbutton.MouseButton1Down:Connect(function()
					holdframe:Destroy()
					holdframe = nil
				end)
	
				deletebutton.MouseButton1Up:Connect(function()
					createfileontable(disk, nameondisk, nil, directory)
					holdframe:Destroy()
					if holderframe then
						holderframe:Destroy()
					end
					holderframe = nil
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
	end
	
	if string.find(string.lower(tostring(txt)), "<woshtml>") then
		woshtmlfile(txt, screen)
	end
	
end

local function loaddisk()
	local start = 0
	local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Disk Content", false, false, false, "Files", false)
	local scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.new(1, 0, 1, -25), CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0, 25), BackgroundTransparency = 1})
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
end

local function writedisk()
	local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Create File", false, false, false, "File Creator", false)
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Position = UDim2.new(0, 0, 0, 25), ScrollBarThickness = 5, CanvasSize = UDim2.new(1, 0, 0, 150), Size = UDim2.new(1,0,1,-35), BackgroundTransparency = 1})
	holderframe:AddChild(scrollingframe)
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
			filenamebutton2.Text = keyboardinput:gsub("\n", ""):gsub("/", "")
			filename = keyboardinput:gsub("\n", ""):gsub("/", "")
		end
	end)

	directorybutton.MouseButton1Down:Connect(function()
		if keyboardinput then
			local inputtedtext = keyboardinput:gsub("\n", "")
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
			filedatabutton2.Text = keyboardinput
			data = keyboardinput
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
		if filenamebutton.Text ~= "File Name(Case Sensitive if on a table) (Click to update)" and filename ~= "Color" and filename ~= "BackgroundImage" and filename ~= "GustavOS Library" then
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
	local holderframe = CreateWindow(UDim2.new(0.75, 0, 0.75, 0), nil, false ,false, false, "Microcontroller manager", false)
	
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -35), Position = UDim2.new(0, 0, 0, 25), BackgroundTransparency = 1})
	holderframe:AddChild(scrollingframe)

	local start = 0
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

	local codebutton, codebutton2 = createnicebutton(UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0, 25), "Enter lua here (Click to update)", holderframe)

	codebutton.MouseButton1Up:Connect(function()
		if keyboardinput then
			codebutton2.Text = tostring(keyboardinput)
			code = tostring(keyboardinput)
		end
	end)

	local stopcodesbutton = createnicebutton(UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.6, -10), "Shutdown microcontrollers", holderframe)

	stopcodesbutton.MouseButton1Up:Connect(function()
		shutdownmicros(screen, microcontrollers)
	end)

	local runcodebutton, runcodebutton2 = createnicebutton(UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.8, -10), "Run lua", holderframe)

	runcodebutton.MouseButton1Up:Connect(function()
		if code ~= "" then
			loadluafile(microcontrollers, screen, code, runcodebutton2)
		end
	end)
end

local function mediaplayer()
	local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Media player", false, false, false, "Media player", false)
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Position = UDim2.new(0, 0, 0, 25), ScrollBarThickness = 5, CanvasSize = UDim2.new(1, 0, 0, 150), Size = UDim2.new(1,0,1,-35), BackgroundTransparency = 1})
	holderframe:AddChild(scrollingframe)
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
			Filename2.Text = keyboardinput:gsub("\n", "")
			data = keyboardinput:gsub("\n", "")
		end
	end)

	local directorybutton2, directorybutton = createnicebutton(UDim2.new(1,0,0.2,0), UDim2.new(0, 0, 0.4, 0), [[Directory (Click to update) example: "/sounds"]], scrollingframe)
	local directory = ""
	
	directorybutton2.MouseButton1Down:Connect(function()
		if keyboardinput then
			local inputtedtext = keyboardinput:gsub("\n", "")
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
		local togglea, togglea2 = createnicebutton(UDim2.new(0.4, 0, 0.1, 0), UDim2.new(0,0,0,25), "Enable anonymous mode", holderframe)
		
		local idui, idui2 = createnicebutton(UDim2.new(0.6, 0, 0.1, 0), UDim2.new(0.4,0,0,25), "Network id", holderframe)
		
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
	
		local scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.new(1, 0, 0.8, -25), Position = UDim2.new(0, 0, 0.1, 25), BackgroundTransparency = 1})
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
		local textlabel = screen:CreateElement("TextLabel", {Text = "You need a modem.", Size = UDim2.new(1,0,1,-25), Position = UDim2.new(0,0,0,25), BackgroundTransparency = 1})
		holderframe:AddChild(textlabel)
	end
end

local function calculator(screen)
	local holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), nil, false, false, false, "Calculator", false)
	local part1 = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(0.45, 0, 0.15, 0), Position = UDim2.new(0, 0, 0, 25), Text = "0", BackgroundTransparency = 1})
	local part3 = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(0.1, 0, 0.15, 0), Position = UDim2.new(0.45, 0, 0, 25), Text = "", BackgroundTransparency = 1})
	local part2 = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(0.45, 0, 0.15, 0), Position = UDim2.new(0.55, 0, 0, 25), Text = "", BackgroundTransparency = 1})
	holderframe:AddChild(part1)
	holderframe:AddChild(part2)
	holderframe:AddChild(part3)

	local number1 = 0
	local type = nil
	local number2 = 0

	local data = nil
	local filename = nil

	local  button1 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.50, 0, 0.15, 25), "9", holderframe})
	button1.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(9))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(9))
			part2.Text = number2
		end
	end)

	local  button2 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.25, 0, 0.15, 25), "8", holderframe})
	button2.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(8))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(8))
			part2.Text = number2
		end
	end)

	local  button3 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0, 0, 0.15, 25), "7", holderframe})
	button3.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(7))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(7))
			part2.Text = number2
		end
	end)

	local  button4 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.50, 0, 0.3, 25), "6", holderframe})
	button4.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(6))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(6))
			part2.Text = number2
		end
	end)
	
	local  button5 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.25, 0, 0.3, 25), "5", holderframe})
	button5.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(5))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(5))
			part2.Text = number2
		end
	end)

	local  button6 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0, 0, 0.3, 25), "4", holderframe})
	button6.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(4))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(4))
			part2.Text = number2
		end
	end)
	
	local  button7 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.50, 0, 0.45, 25), "3", holderframe})
	button7.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(3))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(3))
			part2.Text = number2
		end
	end)

	local  button8 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.25, 0, 0.45, 25), "2", holderframe})
	button8.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(2))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(2))
			part2.Text = number2
		end
	end)

	local  button9 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0, 0, 0.45, 25), "1", holderframe})
	button9.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(1))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(1))
			part2.Text = number2
		end
	end)
	
	local  button10 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.25, 0, 0.6, 25), "0", holderframe})
	button10.MouseButton1Down:Connect(function()
		if not type then
			if tostring(number1) ~= "0" then
				if tonumber(tostring(number1).."0") then
					number1 = tostring(number1).."0"
					part1.Text = number1
				end
			else
				number1 = 0
				part1.Text = number1
			end
		else
			if tostring(number2) ~= "0" then
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

	local  button19 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.50, 0, 0.6, 25), ".", holderframe})
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

	local  button20 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.50, 0, 0.75, 25), "(-)", holderframe})
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

	local  button11 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0, 0, 0.6, 25), "CE", holderframe})
	button11.MouseButton1Down:Connect(function()
		number1 = 0
		part1.Text = number1
		number2 = 0
		part2.Text = ""
		type = nil
		part3.Text = ""
	end)

	local  button12 = createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.75, 0, 0.15, 25), "+", holderframe})
	button12.MouseButton1Down:Connect(function()
		type = "+"
		part3.Text = "+"
	end)

	local  button13 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.75, 0, 0.3, 25), "-", holderframe})
	button13.MouseButton1Down:Connect(function()
		type = "-"
		part3.Text = "-"
	end)

	local  button14 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.75, 0, 0.45, 25), "*", holderframe})
	button14.MouseButton1Down:Connect(function()
		type = "*"
		part3.Text = "*"
	end)

	local  button15 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.75, 0, 0.6, 25), "/", holderframe})
	holderframe:AddChild(button15)
	button15.MouseButton1Down:Connect(function()
		type = "/"
		part3.Text = "/"
	end)

	local  button17 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0, 0, 0.75, 25), "√", holderframe})
	holderframe:AddChild(button17)
	button17.MouseButton1Down:Connect(function()
		type = "√"
		part3.Text = "√"
	end)

	local  button18 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.25, 0, 0.75, 25), "^", holderframe})
	holderframe:AddChild(button18)
	button18.MouseButton1Down:Connect(function()
		type = "^"
		part3.Text = "^"
	end)

	local  button16 =  createnicebutton(UDim2.new(0.25, 0, 0.15, 0), UDim2.new(0.75, 0, 0.75, 25), "=", holderframe})
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

local bootos

local players = {}

local function loaddesktop()
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
	programholder2:AddChild(programholder1)

	taskbarholder = screen:CreateElement("ImageButton", {Image = "rbxassetid://15619032563", Position = UDim2.new(0, 0, 0.9, 0), Size = UDim2.new(1, 0, 0.1, 0), BackgroundTransparency = 1, ImageTransparency = 0.2})
	taskbarholder:AddChild(startbutton7)

	taskbarholderscrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(0.9, 0, 1, 0), BackgroundTransparency = 1, CanvasSize = UDim2.new(0.9, 0, 1, 0), Position = UDim2.new(0.1, 0, 0, 0), ScrollBarThickness = 2.5})
	taskbarholder:AddChild(taskbarholderscrollingframe)
	rom:Write("GD7Library", {
		Screen = screen,
		Keyboard = keyboard,
		Modem = modem,
		Speaker = speaker,
		Disk = disk,
		programholder1 = programholder1,
		programholder2 = programholder2,
		Taskbar = {taskbarholderscrollingframe, taskbarholder},
		screenresolution = screenresolution,
	})
	
	if not disk:Read("sounds") then
		local window = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Welcome to GustavOS", true, true, false, "Welcome", false)
		local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,0,0.8,-25), Position = UDim2.new(0, 0, 0, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Would you like to add some sounds to the hard drive?", BackgroundTransparency = 1})
		window:AddChild(textlabel)
		local yes = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0, 0, 0.8, 0), "Yes", window)
		local no = createnicebutton(UDim2.new(0.5,0,0.2,0), UDim2.new(0.5, 0, 0.8, 0), "No", window)

		no.MouseButton1Up:Connect(function()
			window:Destroy()
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
			window:Destroy()
		end)
	end
	local pressed = false
	local startmenu
	local function openstartmenu()
		if not pressed then
			startmenu = screen:CreateElement("ImageButton", {BackgroundTransparency = 1, Image = "rbxassetid://15619032563", Size = UDim2.new(0.3, 0, 5, 0), Position = UDim2.new(0, 0, -5, 0), ImageTransparency = 0.2})
			taskbarholder:AddChild(startmenu)
			local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1,0,0.8,0), CanvasSize = UDim2.new(1, 0, 1.4, 0), BackgroundTransparency = 1, ScrollBarThickness = 5})
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
				local window = CreateWindow(UDim2.new(0.4, 0, 0.25, 25), "Are you sure?",true,true,false,nil,true)
				local yes = createnicebutton(UDim2.new(0.5, 0, 0.75, -25), UDim2.new(0, 0, 0.25, 25), "Yes", window)
				local no = createnicebutton(UDim2.new(0.5, 0, 0.75, -25), UDim2.new(0.5, 0, 0.25, 25), "No", window)
				no.MouseButton1Up:Connect(function()
					window:Destroy()
				end)
				yes.MouseButton1Up:Connect(function()
					if window then
					window:Destroy()
					end
					if startbutton7 then
						startbutton7:Destroy()
					end
					if taskbarholder then
						taskbarholder:Destroy()
					end
					if programholder2 then
						programholder2:Destroy()
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
				local window = CreateWindow(UDim2.new(0.4, 0, 0.25, 25), "Are you sure?",true,true,false,nil,true)
				local yes = createnicebutton(UDim2.new(0.5, 0, 0.75, -25), UDim2.new(0, 0, 0.25, 25), "Yes", window)
				local no = createnicebutton(UDim2.new(0.5, 0, 0.75, -25), UDim2.new(0.5, 0, 0.25, 25), "No", window)
				no.MouseButton1Up:Connect(function()
					window:Destroy()
				end)
				yes.MouseButton1Up:Connect(function()
					if window then
						window:Destroy()
					end
					if startbutton7 then
						startbutton7:Destroy()
					end
					if taskbarholder then
						taskbarholder:Destroy()
					end
					if programholder2 then
						programholder2:Destroy()
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
						if newX < 135 then newX = 135 end
						if newY < 100 then newY = 100 end
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
			local a = screen:CreateElement("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Image = "rbxassetid://8679825641", BackgroundTransparency = 1, Size = UDim2.fromScale(0.2, 0.2), Position = UDim2.fromScale(0.5, 0.5)})
			players[cursor.Player] = {tick(), a}
		end
		players[cursor.Player][2].Position = UDim2.fromOffset(cursor.X, cursor.Y)
		players[cursor.Player][1] = tick()
	end)
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
			if not disk:Read("BackgroundImage") then disk:Write("BackgroundImage", "15617469527,false") end
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
		loaddesktop()
		SpeakerHandler.PlaySound(startsound, 1, nil, speaker)
		if keyboardevent then keyboardevent:Unbind() end
		keyboardevent = keyboard:Connect("TextInputted", function(text, player)
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
			commandlines:insert([[No empty disk or disk with the file "GustavOSLibrary" was found.]])
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
	for i,v in pairs(players) do
		if tick() - v[1] > 0.5 then
			v[2]:Destroy()
			players[i] = nil
		end
	end
end
