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
						if typeof(split2) == table then
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

local disk = nil
local screen = nil
local keyboard = nil
local speaker = nil
local modem = nil
local microcontrollers = nil

local shutdownpoly = nil

local function getstuff()
	disk = nil
	screen = nil
	keyboard = nil
	speaker = nil
	shutdownpoly = nil
	modem = nil
	microcontrollers = nil

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
			success, Error = pcall(GetPartFromPort, i, "Screen")
			if success then
				if GetPartFromPort(i, "Screen") then
					screen = GetPartFromPort(i, "Screen")
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

local color = nil
local backgroundimage = nil
local backgroundimageframe = nil
local programholder1 = nil
local programholder2 = nil
local tile = false
local tilesize = nil

if disk then
	color = disk:Read("Color")
	local diskbackgroundimage = disk:Read("BackgroundImage")
	if color then
		color = string.split(color, ",")
		if color then
			if tonumber(color[1]) and tonumber(color[2]) and tonumber(color[3]) then
				color = Color3.new(tonumber(color[1])/255, tonumber(color[2])/255, tonumber(color[3])/255)
			else
				color = Color3.new(0, 128/255, 218/255)
			end
		else
			color = Color3.new(0, 128/255, 218/255)
		end
	else
		color = Color3.new(0, 128/255, 218/255)
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

local keyboardinput = nil
local playerthatinputted = nil
local backgroundframe = nil


if speaker then
	speaker:ClearSounds()
end

if screen then
	screen:ClearElements()
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

	
	local filegui = screen:CreateElement("TextButton", {Size = size, Active = true, Draggable = true, TextTransparency = 1})
	programholder1:AddChild(filegui)
	local closebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25), BackgroundColor3 = Color3.new(1,0,0), Text = "Close", TextScaled = true})
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -25), Position = UDim2.new(0, 0, 0, 25), CanvasSize = UDim2.new(0, 0, 1, -25)})
	filegui:AddChild(scrollingframe)
	filegui:AddChild(closebutton)
	closebutton.MouseButton1Down:Connect(function()
		filegui:Destroy()
		filegui = nil
	end)

	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	filegui:AddChild(maximizebutton)
	local unmaximizedsize = filegui.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = filegui
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			programholder2:AddChild(holderframe)
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			programholder1:AddChild(holderframe)
			holderframe.Size = unmaximizedsize
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)
	StringToGui(screen, txt, scrollingframe)

end

local function audioui(screen, disk, data, speaker, pitch, length)
	local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.5, 0, 0.5, 0), Active = true, Draggable = true, TextTransparency = 1})
	programholder1:AddChild(holderframe)
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(closebutton)
	local sound = nil
	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
		sound:Stop()
		sound:Destroy()
	end)

	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	holderframe:AddChild(maximizebutton)
	local unmaximizedsize = holderframe.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = holderframe
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			programholder2:AddChild(holderframe)
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			programholder1:AddChild(holderframe)
			holderframe.Size = unmaximizedsize
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)

	if not pitch then
		pitch = 1
	end
	
	local pausebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0.2, 0, 0.2, 0), Position = UDim2.new(0, 0, 0.8, 0), Text = "Stop", TextScaled = true})
	holderframe:AddChild(pausebutton)

	
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
	

	
	pausebutton.MouseButton1Down:Connect(function()
		if pausebutton.Text == "Stop" then
			pausebutton.Text = "Play"
			sound:Stop()
		else
			pausebutton.Text = "Stop"

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
					local holderframe = screen:CreateElement("TextButton", {Draggable = true, TextTransparency = 1, Size = UDim2.new(0.5, 0, 0.5, 0)})
					local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
					holderframe:AddChild(closebutton)
				
					closebutton.MouseButton1Down:Connect(function()
						holderframe:Destroy()
					end)
			
					local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
					local maximizepressed = false
				
					holderframe:AddChild(maximizebutton)
					local unmaximizedsize = holderframe.Size
					maximizebutton.MouseButton1Up:Connect(function()
				
						local holderframe = holderframe
						if not maximizepressed then
							unmaximizedsize = holderframe.Size
							if programholder2 then
								programholder2:AddChild(holderframe)
							end
							holderframe.Size = UDim2.new(1, 0, 0.9, 0)
							holderframe:ChangeProperties({Active = false, Draggable = false;})
							holderframe.Position = UDim2.new(0, 0, 1, 0)
							holderframe.Position = UDim2.new(0, 0, 0, 0)
							maximizebutton.Text = "-"
							maximizepressed = true
						else
							if programholder1 then
								programholder1:AddChild(holderframe)
							end
							holderframe.Size = unmaximizedsize
							holderframe:ChangeProperties({Active = true, Draggable = true;})
							maximizebutton.Text = "+"
							maximizepressed = false
						end
					end)
					local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,0.5,-25), Position = UDim2.new(0, 0, 0, 25), Text = "Using microcontroller:", TextWrapped = true, TextScaled = true})
					holderframe:AddChild(txtlabel)
					
					local txtlabel2 = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,0.5,0), Position = UDim2.new(0, 0, 0.5, 0), Text = micronumber, TextWrapped = true, TextScaled = true})
					holderframe:AddChild(txtlabel2)
					
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
	if not success then
		local holderframe = screen:CreateElement("TextButton", {Draggable = true, TextTransparency = 1, Size = UDim2.new(0.5, 0, 0.5, 0)})
		local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
		holderframe:AddChild(closebutton)
	
		closebutton.MouseButton1Down:Connect(function()
			holderframe:Destroy()
		end)

		local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
		local maximizepressed = false
	
		holderframe:AddChild(maximizebutton)
		local unmaximizedsize = holderframe.Size
		maximizebutton.MouseButton1Up:Connect(function()
	
			local holderframe = holderframe
			if not maximizepressed then
				unmaximizedsize = holderframe.Size
				if programholder2 then
					programholder2:AddChild(holderframe)
				end
				holderframe.Size = UDim2.new(1, 0, 0.9, 0)
				holderframe:ChangeProperties({Active = false, Draggable = false;})
				holderframe.Position = UDim2.new(0, 0, 1, 0)
				holderframe.Position = UDim2.new(0, 0, 0, 0)
				maximizebutton.Text = "-"
				maximizepressed = true
			else
				if programholder1 then
					programholder1:AddChild(holderframe)
				end
				holderframe.Size = unmaximizedsize
				holderframe:ChangeProperties({Active = true, Draggable = true;})
				maximizebutton.Text = "+"
				maximizepressed = false
			end
		end)
		local frame = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,-25), Position = UDim2.new(0, 0, 0, 25), Text = "No microcontrollers left.", TextWrapped = true, TextScaled = true})
		holderframe:AddChild(frame)
	end
end

local function readfile(txt, nameondisk, boolean, directory)
	local filegui = screen:CreateElement("TextButton", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true, TextTransparency = 1})
	local closebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25), BackgroundColor3 = Color3.new(1,0,0), Text = "Close", TextScaled = true})
	local deletebutton = nil

	programholder1:AddChild(filegui)
	
	filegui:AddChild(closebutton)

	
	closebutton.MouseButton1Down:Connect(function()
		filegui:Destroy()
		filegui = nil
	end)

	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	filegui:AddChild(maximizebutton)
	local unmaximizedsize = filegui.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = filegui
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			programholder2:AddChild(holderframe)
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			programholder1:AddChild(holderframe)
			holderframe.Size = unmaximizedsize
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)
	
	local disktext = screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, -25), Position = UDim2.new(0, 0, 0, 25), TextScaled = true, Text = tostring(txt), RichText = true})
	
	filegui:AddChild(disktext)
	
	print(txt)
	
	if boolean == true then
		deletebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25),Position = UDim2.new(1, -25, 0, 0), Text = "Delete", TextScaled = true})
		filegui:AddChild(deletebutton)
		
		deletebutton.MouseButton1Up:Connect(function()
			disk:Write(nameondisk, nil)
			filegui:Destroy()
			filegui = nil
		end)
	elseif directory then
		deletebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25),Position = UDim2.new(1, -25, 0, 0), Text = "Delete", TextScaled = true})
		filegui:AddChild(deletebutton)
		
		deletebutton.MouseButton1Up:Connect(function()
			createfileontable(disk, nameondisk, nil, directory)
			filegui:Destroy()
			filegui = nil
		end)
	end
	
	if string.find(string.lower(tostring(nameondisk)), ".aud") then
		local txt = string.lower(txt)
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
			woshtmlfile([[<img src="]]..txt..[[" size="1,0,1,0" position="0,0,0,0">]], screen, true)
	end

	if string.find(string.lower(tostring(nameondisk)), ".lua") then
		loadluafile(microcontrollers, screen, txt)
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
		local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true, TextTransparency = 1})
		programholder1:AddChild(holderframe)
		local scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.new(1, 0, 1, -25), CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0, 25)})
		holderframe:AddChild(scrollingframe)
		local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-50,0,25), Position = UDim2.new(0, 50, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Table Content"})
		holderframe:AddChild(textlabel)
		
		if boolean == true then
			local alldata = disk:ReadEntireDisk()
			local deletebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25),Position = UDim2.new(1, -25, 0, 0), Text = "Delete", TextScaled = true})
			holderframe:AddChild(deletebutton)
			textlabel.Size = UDim2.new(1,-75,0,25)
			
			deletebutton.MouseButton1Up:Connect(function()
				disk:ClearDisk()
				for name, data in pairs(alldata) do
					if name ~= nameondisk then
						disk:Write(name, data)
					end
				end
				holderframe:Destroy()
				holderframe = nil
			end)
		elseif directory then
			deletebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25),Position = UDim2.new(1, -25, 0, 0), Text = "Delete", TextScaled = true})
			holderframe:AddChild(deletebutton)
			
			deletebutton.MouseButton1Up:Connect(function()
				createfileontable(disk, nameondisk, nil, directory)
				holderframe:Destroy()
				holderframe = nil
			end)
		end
		
		local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
		holderframe:AddChild(closebutton)
	
		closebutton.MouseButton1Down:Connect(function()
			holderframe:Destroy()
		end)

		local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
		local maximizepressed = false
		
		holderframe:AddChild(maximizebutton)
		local unmaximizedsize = holderframe.Size
		maximizebutton.MouseButton1Up:Connect(function()
			local holderframe = holderframe
			if not maximizepressed then
				unmaximizedsize = holderframe.Size
				programholder2:AddChild(holderframe)
				holderframe.Size = UDim2.new(1, 0, 0.9, 0)
				holderframe:ChangeProperties({Active = false, Draggable = false;})
				holderframe.Position = UDim2.new(0, 0, 1, 0)
				holderframe.Position = UDim2.new(0, 0, 0, 0)
				maximizebutton.Text = "-"
				maximizepressed = true
			else
				programholder1:AddChild(holderframe)
				holderframe.Size = unmaximizedsize
				holderframe:ChangeProperties({Active = true, Draggable = true;})
				maximizebutton.Text = "+"
				maximizepressed = false
			end
		end)
	
		for index, data in pairs(tableval) do
			local button = screen:CreateElement("TextButton", {TextScaled = true, Text = index, Size = UDim2.new(1,0,0,25), Position = UDim2.new(0, 0, 0, start)})
			scrollingframe:AddChild(button)
			scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start + 25)
			start += 25
			button.MouseButton1Down:Connect(function()
				readfile(data, index, false, newdirectory)
			end)
		end
	end
	
	if string.find(string.lower(tostring(txt)), "<woshtml>") then
		woshtmlfile(txt, screen)
	end
	
end

local function loaddisk(screen, disk)
	local start = 0
	local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true, TextTransparency = 1})
	programholder1:AddChild(holderframe)
	local scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.new(1, 0, 1, -25), CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0, 25)})
	holderframe:AddChild(scrollingframe)
	local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-50,0,25), Position = UDim2.new(0, 50, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Disk Content"})
	holderframe:AddChild(textlabel)
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(closebutton)

	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
	end)

	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	holderframe:AddChild(maximizebutton)
	local unmaximizedsize = holderframe.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = holderframe
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			programholder2:AddChild(holderframe)
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			programholder1:AddChild(holderframe)
			holderframe.Size = unmaximizedsize
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)

	for filename, data in pairs(disk:ReadEntireDisk()) do
		if filename ~= "Color" and filename ~= "BackgroundImage" then
			local button = screen:CreateElement("TextButton", {TextScaled = true, Text = filename, Size = UDim2.new(1,0,0,25), Position = UDim2.new(0, 0, 0, start)})
			scrollingframe:AddChild(button)
			scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start + 25)
			start += 25
			button.MouseButton1Down:Connect(function()
				local data = disk:Read(filename)
				readfile(data, filename, true)
			end)
		end
	end
end

local function writedisk(screen, disk)
	local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true, TextTransparency = 1})
	if programholder1 then programholder1:AddChild(holderframe) end
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Position = UDim2.new(0, 0, 0, 25), ScrollBarThickness = 5, CanvasSize = UDim2.new(1, 0, 0, 150), Size = UDim2.new(1,0,1,-25), BackgroundTransparency = 1})
	holderframe:AddChild(scrollingframe)
	local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-50,0,25), Position = UDim2.new(0, 50, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Create File"})
	local filenamebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0.2,0), Position = UDim2.new(0, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "File Name (Click to update)"})
	local filedatabutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0.2,0), Position = UDim2.new(0, 0, 0.2, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "File Data (Click to update)"})
	local createfilebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.5,0,0.2, 0), Position = UDim2.new(0, 0, 0.8, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Apply"})
	holderframe:AddChild(textlabel)
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(closebutton)
	scrollingframe:AddChild(filenamebutton)
	scrollingframe:AddChild(filedatabutton)
	scrollingframe:AddChild(createfilebutton)

	local createtablebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.5,0,0.2, 0), Position = UDim2.new(0.5, 0, 0.8, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Create Table"})
	scrollingframe:AddChild(createtablebutton)

	local directorybutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0.2,0), Position = UDim2.new(0, 0, 0.4, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = [[Directory(Case Sensitive) (Click to update) example: "/sounds"]]})
	scrollingframe:AddChild(directorybutton)
	
	local data = nil
	local filename = nil

	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
	end)

	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	local directory = ""
	
	holderframe:AddChild(maximizebutton)
	local unmaximizedsize = holderframe.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = holderframe
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			if programholder2 then programholder2:AddChild(holderframe) end
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			holderframe.Size = unmaximizedsize
			if programholder1 then programholder1:AddChild(holderframe) end
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)

	filenamebutton.MouseButton1Down:Connect(function()
		if keyboardinput then
			filenamebutton.Text = keyboardinput:gsub("\n", ""):gsub("/", "")
			filename = keyboardinput:gsub("\n", ""):gsub("/", "")
		end
	end)

	directorybutton.MouseButton1Down:Connect(function()
		if keyboardinput then
			local inputtedtext = keyboardinput:gsub("\n", "")
			local split = string.split(inputtedtext, "/")
			if split then
				print(inputtedtext)
				print(split)
				local removedlast = inputtedtext:sub(1, -split[#split]-1)
				print(removedlast)
				if getfilefromtable(disk, split[#split], removedlast) then
					directorybutton.Text = inputtedtext
					directory = inputtedtext
				else
					directorybutton.Text = "Invalid"
					task.wait(2)
					directorybutton.Text = [[Directory(Case Sensitive) (Click to update) example: "/sounds"]]
				end
			else
				directorybutton.Text = "Invalid"
				task.wait(2)
				directorybutton.Text = [[Directory(Case Sensitive) (Click to update) example: "/sounds"]]
			end
		end
	end)

	filedatabutton.MouseButton1Down:Connect(function()
		if keyboardinput then
			filedatabutton.Text = keyboardinput
			data = keyboardinput
		end
	end)

	createfilebutton.MouseButton1Down:Connect(function()
		if filenamebutton.Text ~= "File Name (Click to update)" and filename ~= "Color" and filename ~= "BackgroundImage" then
			if filedatabutton.Text ~= "File Data (Click to update)" then
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
				if not split then
					if disk:Read(filename) then
						if disk:Read(filename) == data then
							createfilebutton.Text = "Success i think"
						else
							createfilebutton.Text = "Failed"
						end
					else
						createfilebutton.Text = "Failed"
					end
				else
					if disk:Read(split[2]) == returntable and disk:Read(split[2]) then
						createfilebutton.Text = "Success i think"
					else
						createfilebutton.Text = "Failed i think"
					end	
				end
				task.wait(2)
				createfilebutton.Text = "Apply"
			end
		end
	end)

	createtablebutton.MouseButton1Down:Connect(function()
		if filenamebutton.Text ~= "File Name (Click to update)" and filename ~= "Color" and filename ~= "BackgroundImage" then
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
					createtablebutton.Text = "Success i think"
				else
					createtablebutton.Text = "Failed"
				end
			else
				if disk:Read(split[2]) == returntable then
					createtablebutton.Text = "Success i think"
				else
					createtablebutton.Text = "Failed i think"
				end	
			end
			task.wait(2)
			createtablebutton.Text = "Create Table"
		end
	end)
end

local function changecolor(screen, disk)
	local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true, TextTransparency = 1})
	programholder1:AddChild(holderframe)
	local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-50,0,25), Position = UDim2.new(0, 50, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Change Color"})
	local color = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0.2,0), Position = UDim2.new(0, 0, 0, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "RGB (Click to update)"})
	local changecolorbutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0.2,0), Position = UDim2.new(0, 0, 0.8, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Change Color"})
	holderframe:AddChild(textlabel)
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(changecolorbutton)
	holderframe:AddChild(color)
	holderframe:AddChild(closebutton)

	
	local data = nil
	local filename = nil

	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
	end)

	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	holderframe:AddChild(maximizebutton)
	local unmaximizedsize = holderframe.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = holderframe
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			programholder2:AddChild(holderframe)
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			programholder1:AddChild(holderframe)
			holderframe.Size = unmaximizedsize
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)

	color.MouseButton1Down:Connect(function()
		if keyboardinput then
			color.Text = keyboardinput:gsub("\n", "")
			data = keyboardinput:gsub("\n", "")
		end
	end)

	changecolorbutton.MouseButton1Down:Connect(function()
		if color.Text ~= "RGB (Click to update)" then
			disk:Write("Color", data)
			local colordata = string.split(data, ",")
			if colordata then
				if tonumber(colordata[1]) and tonumber(colordata[2]) and tonumber(colordata[3]) then
					backgroundframe.BackgroundColor3 = Color3.new(tonumber(colordata[1])/255, tonumber(colordata[2])/255, tonumber(colordata[3])/255)
					changecolorbutton.Text = "Success"
					if backgroundimage then
						disk:Write("BackgroundImage", "")
						backgroundimageframe.Image = ""
					end
				end
			end
		end
	end)
end

local function changebackgroundimage(screen, disk)
	local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true, TextTransparency = 1})
	programholder1:AddChild(holderframe)
	local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-50,0,25), Position = UDim2.new(0, 50, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Change Background Image"})
	local id = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0.2,0), Position = UDim2.new(0, 0, 0, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Image ID"})
	local tiletoggle = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25,0,0.2,0), Position = UDim2.new(0, 0, 0.2, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Enable tile"})
	local tilenumber = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.75,0,0.2,0), Position = UDim2.new(0.25, 0, 0.2, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "UDim2"})
	local changebackimg = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0.2,0), Position = UDim2.new(0, 0, 0.8, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Change Background Image"})
	holderframe:AddChild(textlabel)
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(changebackimg)
	holderframe:AddChild(id)
	holderframe:AddChild(tiletoggle)
	holderframe:AddChild(tilenumber)
	holderframe:AddChild(closebutton)


	local data = nil
	local filename = nil
	local tile = false
	local tilenumb = "0.2, 0, 0.2, 0"

	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
	end)

	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	holderframe:AddChild(maximizebutton)
	local unmaximizedsize = holderframe.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = holderframe
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			programholder2:AddChild(holderframe)
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			programholder1:AddChild(holderframe)
			holderframe.Size = unmaximizedsize
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)
	
	id.MouseButton1Down:Connect(function()
		if keyboardinput then
			id.Text = keyboardinput:gsub("\n", "")
			data = keyboardinput:gsub("\n", "")
		end
	end)

	tiletoggle.MouseButton1Down:Connect(function()
		if tile then
			tile = false
			tiletoggle.Text = "Enable tile"
		else
			tiletoggle.Text = "Disable tile"
			tile = true
		end
	end)

	
	tilenumber.MouseButton1Down:Connect(function()
		if keyboardinput then
			tilenumber.Text = keyboardinput:gsub("\n", "")
			tilenumb = keyboardinput:gsub("\n", "")
		end
	end)

	changebackimg.MouseButton1Down:Connect(function()
		if id.Text ~= "Image ID" then
			if tonumber(data) then
				disk:Write("BackgroundImage", data..","..tostring(tile)..","..tilenumb)
				backgroundimageframe.Image = "rbxthumb://type=Asset&id="..tonumber(data).."&w=420&h=420"
				changebackimg.Text = "Success"
				if tile then
					local tilenumb = string.split(tilenumb, ",")
					if tonumber(tilenumb[1]) and tonumber(tilenumb[2]) and tonumber(tilenumb[3]) and tonumber(tilenumb[4]) then
						backgroundimageframe.ScaleType = Enum.ScaleType.Tile
						backgroundimageframe.TileSize = UDim2.new(tonumber(tilenumb[1]), tonumber(tilenumb[2]), tonumber(tilenumb[3]), tonumber(tilenumb[4]))
					end
				else
					backgroundimageframe.ScaleType = Enum.ScaleType.Stretch
				end
			end
		end
	end)
end

local function chatthing(screen, disk, modem)
	local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true, TextTransparency = 1})
	if programholder1 then
		programholder1:AddChild(holderframe)
	end
	local messagesent = nil
	
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(closebutton)

	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
		if messagesent then
			messagesent:UnBind()
		end
	end)

	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	holderframe:AddChild(maximizebutton)
	local unmaximizedsize = holderframe.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = holderframe
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			if programholder2 then
				programholder2:AddChild(holderframe)
			end
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			if programholder1 then
				programholder1:AddChild(holderframe)
			end
			holderframe.Size = unmaximizedsize
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)

	if modem then
	
		local id = 0

		local toggleanonymous = false
		local togglea = screen:CreateElement("TextButton", {Size = UDim2.new(0.4, 0, 0.1, 0), Position = UDim2.new(0,0,0,25), Text = "Enable anonymous mode", TextScaled = true})
		holderframe:AddChild(togglea)
		
		local idui = screen:CreateElement("TextButton", {Size = UDim2.new(0.6, 0, 0.1, 0), Position = UDim2.new(0.4,0,0,25), Text = "Network id", TextScaled = true})
		holderframe:AddChild(idui)
		
		idui.MouseButton1Up:Connect(function()
			if tonumber(keyboardinput) then
				idui.Text = tonumber(keyboardinput)
				id = tonumber(keyboardinput)
				modem:Configure({NetworkID = tonumber(keyboardinput)})
			end
		end)

		togglea.MouseButton1Up:Connect(function()
			if toggleanonymous then
				togglea.Text = "Enable anonymous mode"
				toggleanonymous = false
			else
				toggleanonymous = true
				togglea.Text = "Disable anonymous mode"
			end
		end)
	
		local scrollingframe = screen:CreateElement("ScrollingFrame", {ScrollBarThickness = 5, Size = UDim2.new(1, 0, 0.8, -25), Position = UDim2.new(0, 0, 0.1, 25)})
		holderframe:AddChild(scrollingframe)
	
		local sendbox =  screen:CreateElement("TextButton", {Size = UDim2.new(0.8, 0, 0.1, 0), Position = UDim2.new(0,0,0.9,0), Text = "Message (Click to update)", TextScaled = true})
		holderframe:AddChild(sendbox)
	
		local sendtext = nil
		local player = nil
		
		sendbox.MouseButton1Up:Connect(function()
			if keyboardinput then
				sendbox.Text = keyboardinput:gsub("\n", "")
				sendtext = keyboardinput:gsub("\n", "")
				player = playerthatinputted
			end
		end)
	
		local sendbutton =  screen:CreateElement("TextButton", {Size = UDim2.new(0.2, 0, 0.1, 0), Position = UDim2.new(0.8,0,0.9,0), Text = "Send", TextScaled = true})
		holderframe:AddChild(sendbutton)
	
		sendbutton.MouseButton1Up:Connect(function()
			if sendtext then
				if not toggleanonymous then
					modem:SendMessage("[ "..player.." ]: "..sendtext, id)
				else
					modem:SendMessage(sendtext, id)
				end
				sendbutton.Text = "Sent"
				task.wait(2)
				sendbutton.Text = "Send"
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
		local textlabel = screen:CreateElement("TextLabel", {Text = "You need a modem.", Size = UDim2.new(1,0,1,-25), Position = UDim2.new(0,0,0,25)})
		holderframe:AddChild(textlabel)
	end
end

local function calculator(screen)
	local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true, TextTransparency = 1})
	programholder1:AddChild(holderframe)
	local part1 = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(0.45, 0, 0.1, 0), Position = UDim2.new(0, 0, 0, 25), Text = "0"})
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	local part3 = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(0.1, 0, 0.1, 0), Position = UDim2.new(0.45, 0, 0, 25), Text = ""})
	local part2 = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(0.45, 0, 0.1, 0), Position = UDim2.new(0.55, 0, 0, 25), Text = ""})
	holderframe:AddChild(part1)
	holderframe:AddChild(part2)
	holderframe:AddChild(part3)
	holderframe:AddChild(closebutton)

	local number1 = 0
	local type = nil
	local number2 = 0

	local data = nil
	local filename = nil

	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
	end)

	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	holderframe:AddChild(maximizebutton)
	local unmaximizedsize = holderframe.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = holderframe
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			programholder2:AddChild(holderframe)
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			programholder1:AddChild(holderframe)
			holderframe.Size = unmaximizedsize
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)

	local  button1 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.50, 0, 0.1, 25), Text = "9"})
	holderframe:AddChild(button1)
	button1.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(9))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(9))
			part2.Text = number2
		end
	end)

	local  button2 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.25, 0, 0.1, 25), Text = "8"})
	holderframe:AddChild(button2)
	button2.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(8))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(8))
			part2.Text = number2
		end
	end)

	local  button3 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0, 0, 0.1, 25), Text = "7"})
	holderframe:AddChild(button3)
	button3.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(7))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(7))
			part2.Text = number2
		end
	end)

	local  button4 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.50, 0, 0.2, 25), Text = "6"})
	holderframe:AddChild(button4)
	button4.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(6))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(6))
			part2.Text = number2
		end
	end)
	
	local  button5 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.25, 0, 0.2, 25), Text = "5"})
	holderframe:AddChild(button5)
	button5.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(5))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(5))
			part2.Text = number2
		end
	end)

	local  button6 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0, 0, 0.2, 25), Text = "4"})
	holderframe:AddChild(button6)
	button6.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(4))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(4))
			part2.Text = number2
		end
	end)
	
	local  button7 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.50, 0, 0.3, 25), Text = "3"})
	holderframe:AddChild(button7)
	button7.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(3))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(3))
			part2.Text = number2
		end
	end)

	local  button8 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.25, 0, 0.3, 25), Text = "2"})
	holderframe:AddChild(button8)
	button8.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(2))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(2))
			part2.Text = number2
		end
	end)

	local  button9 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0, 0, 0.3, 25), Text = "1"})
	holderframe:AddChild(button9)
	button9.MouseButton1Down:Connect(function()
		if not type then
			number1 = tonumber(tostring(number1)..tostring(1))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(1))
			part2.Text = number2
		end
	end)
	
	local  button10 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.25, 0, 0.4, 25), Text = "0"})
	holderframe:AddChild(button10)
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

	local  button19 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.50, 0, 0.4, 25), Text = "."})
	holderframe:AddChild(button19)
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

	local  button20 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.50, 0, 0.5, 25), Text = "(-)"})
	holderframe:AddChild(button20)
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

	local  button11 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0, 0, 0.4, 25), Text = "CE"})
	holderframe:AddChild(button11)
	button11.MouseButton1Down:Connect(function()
		number1 = 0
		part1.Text = number1
		number2 = 0
		part2.Text = ""
		type = nil
		part3.Text = ""
	end)

	local  button12 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.75, 0, 0.1, 25), Text = "+"})
	holderframe:AddChild(button12)
	button12.MouseButton1Down:Connect(function()
		type = "+"
		part3.Text = "+"
	end)

	local  button13 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.75, 0, 0.2, 25), Text = "-"})
	holderframe:AddChild(button13)
	button13.MouseButton1Down:Connect(function()
		type = "-"
		part3.Text = "-"
	end)

	local  button14 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.75, 0, 0.3, 25), Text = "*"})
	holderframe:AddChild(button14)
	button14.MouseButton1Down:Connect(function()
		type = "*"
		part3.Text = "*"
	end)

	local  button15 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.75, 0, 0.4, 25), Text = "/"})
	holderframe:AddChild(button15)
	button15.MouseButton1Down:Connect(function()
		type = "/"
		part3.Text = "/"
	end)

	local  button17 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0, 0, 0.5, 25), Text = "√", RichText = true})
	holderframe:AddChild(button17)
	button17.MouseButton1Down:Connect(function()
		type = "√"
		part3.Text = "√"
	end)

	local  button18 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.25, 0, 0.5, 25), Text = "^", RichText = true})
	holderframe:AddChild(button18)
	button18.MouseButton1Down:Connect(function()
		type = "^"
		part3.Text = "^"
	end)

	local  button16 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25, 0, 0.1, 0), Position = UDim2.new(0.75, 0, 0.5, 25), Text = "="})
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

local function mediaplayer(screen, disk, speaker)
	local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true, TextTransparency = 1})
	programholder1:AddChild(holderframe)
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Position = UDim2.new(0, 0, 0, 25), ScrollBarThickness = 5, CanvasSize = UDim2.new(1, 0, 0, 150), Size = UDim2.new(1,0,1,-25), BackgroundTransparency = 1})
	holderframe:AddChild(scrollingframe)
	local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-50,0,25), Position = UDim2.new(0, 50, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Media Player"})
	local Filename = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0.2,0), Position = UDim2.new(0, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "File with id (Click to update)"})
	local openimage = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.5,0,0.2,0), Position = UDim2.new(0, 0, 0.8, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Open as image"})
	local openaudio = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.5,0,0.2,0), Position = UDim2.new(0.5, 0, 0.8, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Open as audio"})
	holderframe:AddChild(textlabel)
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	scrollingframe:AddChild(openimage)
	scrollingframe:AddChild(Filename)
	holderframe:AddChild(closebutton)
	scrollingframe:AddChild(openaudio)

	local data = nil
	local filename = nil

	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
	end)

	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	holderframe:AddChild(maximizebutton)
	local unmaximizedsize = holderframe.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = holderframe
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			programholder2:AddChild(holderframe)
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			programholder1:AddChild(holderframe)
			holderframe.Size = unmaximizedsize
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)
	local toggleopen = true
	local Toggle1 = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0.2,0), Position = UDim2.new(0, 0, 0.2, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Open from File: Yes"})
	scrollingframe:AddChild(Toggle1)

	Toggle1.MouseButton1Up:Connect(function()
		if toggleopen then
			toggleopen = false
			Toggle1.Text = "Open from File: No"
		else
			toggleopen = true
			Toggle1.Text = "Open from File: Yes"
		end
	end)
	
	Filename.MouseButton1Down:Connect(function()
		if keyboardinput then
			Filename.Text = keyboardinput:gsub("\n", "")
			data = keyboardinput:gsub("\n", "")
		end
	end)

	local directorybutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0.2,0), Position = UDim2.new(0, 0, 0.4, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = [[Directory (Click to update) example: "/sounds"]]})
	scrollingframe:AddChild(directorybutton)
	local directory = ""
	
	directorybutton.MouseButton1Down:Connect(function()
		if keyboardinput then
			directorybutton.Text = keyboardinput:gsub("\n", "")
			directory = keyboardinput:gsub("\n", "")
		end
	end)
	
	openaudio.MouseButton1Down:Connect(function()
		if Filename.Text ~= "File with id (Click to update)" then
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
		if Filename.Text ~= "File with id (Click to update)" then
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

local function shutdownmicros(screen, micros)
	local holderframe = screen:CreateElement("TextButton", {Draggable = true, TextTransparency = 1, Size = UDim2.new(0.75, 0, 0.75, 0)})
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(closebutton)

	if programholder1 then
		programholder1:AddChild(holderframe)
	end
	
	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
	end)

	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	holderframe:AddChild(maximizebutton)
	local unmaximizedsize = holderframe.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = holderframe
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			if programholder2 then
				programholder2:AddChild(holderframe)
			end
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			if programholder1 then
				programholder1:AddChild(holderframe)
			end
			holderframe.Size = unmaximizedsize
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)
	
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -25), Position = UDim2.new(0, 0, 0, 25)})
	holderframe:AddChild(scrollingframe)

	local start = 0
	for index, value in pairs(microcontrollers) do
		local button = screen:CreateElement("TextButton", {Text = (start/25)+1, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0, start)})
		scrollingframe:AddChild(button)
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
					button.Text = "Microcontroller turned off."
					task.wait(2)
					button.Text = oldstart/25
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
	local holderframe = screen:CreateElement("TextButton", {Draggable = true, TextTransparency = 1, Size = UDim2.new(0.75, 0, 0.75, 0)})
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(closebutton)
	
	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
	end)

	if programholder1 then
		programholder1:AddChild(holderframe)
	end

	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	holderframe:AddChild(maximizebutton)
	local unmaximizedsize = holderframe.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = holderframe
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			if programholder2 then
				programholder2:AddChild(holderframe)
			end
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			if programholder1 then
				programholder1:AddChild(holderframe)
			end
			holderframe.Size = unmaximizedsize
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)

	local code = ""

	local codebutton = screen:CreateElement("TextButton", {Size = UDim2.new(1, 0, 0.2, 0), Position = UDim2.new(0, 0, 0, 25), Text = "Enter lua here (Click to update)", TextScaled = true, TextWrapped = true})
	holderframe:AddChild(codebutton)

	codebutton.MouseButton1Up:Connect(function()
		if keyboardinput then
			codebutton.Text = tostring(keyboardinput)
			code = tostring(keyboardinput)
		end
	end)

	local stopcodesbutton = screen:CreateElement("TextButton", {Size = UDim2.new(1, 0, 0.2, 0), Position = UDim2.new(0, 0, 0.6, 0), Text = "Shutdown microcontrollers", TextScaled = true, TextWrapped = true})
	holderframe:AddChild(stopcodesbutton)

	stopcodesbutton.MouseButton1Up:Connect(function()
		shutdownmicros(screen, microcontrollers)
	end)

	local runcodebutton = screen:CreateElement("TextButton", {Size = UDim2.new(1, 0, 0.2, 0), Position = UDim2.new(0, 0, 0.8, 0), Text = "Run lua", TextScaled = true, TextWrapped = true})
	holderframe:AddChild(runcodebutton)

	runcodebutton.MouseButton1Up:Connect(function()
		if code ~= "" then
			loadluafile(microcontrollers, screen, code, runcodebutton)
		end
	end)
end

local keyboardevent = nil

local function loadmenu(screen, disk)
	local pressed = false
	local startui = nil
	
	backgroundframe = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = color})
	backgroundimageframe = screen:CreateElement("ImageLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})

	if backgroundimage then
		backgroundimageframe.Image = backgroundimage
		if tile then
			if tilesize then
				backgroundimageframe.ScaleType = Enum.ScaleType.Tile
				backgroundimageframe.TileSize = UDim2.new(tilesize.X.Scale, tilesize.X.Offset, tilesize.Y.Scale, tilesize.Y.Offset)
			end
		else
			backgroundimageframe.ScaleType = Enum.ScaleType.Stretch
		end
	end
	backgroundframe:AddChild(backgroundimageframe)
	
	local startmenu = screen:CreateElement("TextButton", {TextScaled = true, Text = "GustavOS", Size = UDim2.new(0.2,0,0.1,0), Position = UDim2.new(0, 0, 0.9, 0)})
	backgroundframe:AddChild(startmenu)

	programholder1 = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
	programholder2 = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
	programholder2:AddChild(programholder1)

	startmenu.MouseButton1Down:Connect(function()
		if pressed == true then
			if startui then
				startui:Destroy()
				startui = nil
				pressed = false
			end
		else
			startui = screen:CreateElement("TextButton", {Size = UDim2.new(0.3, 0, 0.5, 0), Position = UDim2.new(0, 0, 0.4, 0), TextTransparency = 1})
			local programs = screen:CreateElement("TextButton", {Text = "Programs", TextScaled = true, Size = UDim2.new(1, 0, 0.2, 0)})
			startui:AddChild(programs)
			local settings = screen:CreateElement("TextButton", {Text = "Settings", TextScaled = true, Size = UDim2.new(1, 0, 0.2, 0), Position = UDim2.new(0, 0, 0.2, 0)})
			startui:AddChild(settings)

			local shutdown = nil

			restart = screen:CreateElement("TextButton", {Text = "Restart", TextScaled = true, Size = UDim2.new(0.5, 0, 0.2, 0), Position = UDim2.new(0.5, 0, 0.8, 0)})
			startui:AddChild(restart)
			
			if shutdownpoly then
				shutdown = screen:CreateElement("TextButton", {Text = "Shutdown", TextScaled = true, Size = UDim2.new(0.5, 0, 0.2, 0), Position = UDim2.new(0, 0, 0.8, 0)})
				startui:AddChild(shutdown)
			end

			pressed = true

			local holdingframe = nil
			local holdingframe2 = nil
			programs.MouseButton1Down:Connect(function()
				if not holdingframe then
					if holdingframe2 then
						holdingframe2:Destroy()
						holdingframe2 = nil
					end
					
					holdingframe = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(1, 0, 0, 0)})
					startui:AddChild(holdingframe)
					local opencalculator = screen:CreateElement("TextButton", {Text = "Calculator", TextScaled = true, Size = UDim2.new(1, 0, 1/5, 0)})
					holdingframe:AddChild(opencalculator)
					local openfiles = screen:CreateElement("TextButton", {Text = "Files", TextScaled = true, Size = UDim2.new(1, 0, 1/5, 0), Position = UDim2.new(0, 0, 1/5, 0)})
					holdingframe:AddChild(openfiles)
					local openmediaplayer = screen:CreateElement("TextButton", {Text = "Mediaplayer", TextScaled = true, Size = UDim2.new(1, 0, 1/5, 0), Position = UDim2.new(0, 0, 1/5*2, 0)})
					holdingframe:AddChild(openmediaplayer)
					local openchat = screen:CreateElement("TextButton", {Text = "Chat", TextScaled = true, Size = UDim2.new(1, 0, 1/5, 0), Position = UDim2.new(0, 0, 1/5*3, 0)})
					holdingframe:AddChild(openchat)
					local openluaexecutor = screen:CreateElement("TextButton", {Text = "Lua executor", TextScaled = true, Size = UDim2.new(1, 0, 1/5, 0), Position = UDim2.new(0, 0, 1/5*4, 0)})
					holdingframe:AddChild(openluaexecutor)

					opencalculator.MouseButton1Down:Connect(function()
						calculator(screen)
						startui:Destroy()
						startui = nil
						pressed = false
					end)

							
					openluaexecutor.MouseButton1Down:Connect(function()
						customprogramthing(screen)
						startui:Destroy()
						startui = nil
						pressed = false
					end)

					openchat.MouseButton1Down:Connect(function()
						startui:Destroy()
						startui = nil
						pressed = false
						chatthing(screen, disk, modem)
					end)
							
					openmediaplayer.MouseButton1Down:Connect(function()
						mediaplayer(screen, disk, speaker)
						startui:Destroy()
						startui = nil
						pressed = false
					end)

					openfiles.MouseButton1Down:Connect(function()
						loaddisk(screen, disk)
						startui:Destroy()
						startui = nil
						pressed = false
					end)
				else
					holdingframe:Destroy()
					holdingframe = nil
				end
			end)

			settings.MouseButton1Down:Connect(function()
				if not holdingframe2 then
					if holdingframe then
						holdingframe:Destroy()
						holdingframe = nil
					end
					holdingframe2 = screen:CreateElement("Frame", { Size = UDim2.new(1, 0, 0.6, 0), Position = UDim2.new(1, 0, 0.2, 0)})
					startui:AddChild(holdingframe2)
					local openwrite = screen:CreateElement("TextButton", {Text = "Create/Overwrite File", TextScaled = true, Size = UDim2.new(1, 0, 1/3, 0)})
					holdingframe2:AddChild(openwrite)
					local openchangebackimg = screen:CreateElement("TextButton", {Text = "Change Background Image", TextScaled = true, Size = UDim2.new(1, 0, 1/3, 0), Position = UDim2.new(0, 0, 1/3, 0)})
					holdingframe2:AddChild(openchangebackimg)
					local openchangecolor = screen:CreateElement("TextButton", {Text = "Change Background Color", TextScaled = true, Size = UDim2.new(1, 0, 1/3, 0), Position = UDim2.new(0, 0, 1/3*2, 0)})
					holdingframe2:AddChild(openchangecolor)

					openwrite.MouseButton1Down:Connect(function()
						writedisk(screen, disk)
						startui:Destroy()
						startui = nil
						pressed = false
					end)

					openchangebackimg.MouseButton1Down:Connect(function()
						changebackgroundimage(screen, disk)
						startui:Destroy()
						startui = nil
						pressed = false
					end)

					openchangecolor.MouseButton1Down:Connect(function()
						changecolor(screen, disk)
						startui:Destroy()
						startui = nil
						pressed = false
					end)
				else
					holdingframe2:Destroy()
					holdingframe2 = nil
				end
			end)

			--restart:

			restart.MouseButton1Up:Connect(function()
				local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.4, 0, 0.25, 25), Active = true, Draggable = true, TextTransparency = 1})
				local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-25,0,25), Position = UDim2.new(0, 25, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Are you sure?"})
				local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
				holderframe:AddChild(textlabel)
				holderframe:AddChild(closebutton)
				local restartbutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.5, 0, 0.75, -25), Position = UDim2.new(0, 0, 0.25, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Yes"})
				holderframe:AddChild(restartbutton)
				local cancelbutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.5, 0, 0.75, -25), Position = UDim2.new(0.5, 0, 0.25, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "No"})
				holderframe:AddChild(cancelbutton)
				
				closebutton.MouseButton1Down:Connect(function()
					holderframe:Destroy()
					holderframe = nil
				end)	
					
				cancelbutton.MouseButton1Down:Connect(function()
					holderframe:Destroy()
					holderframe = nil
				end)
					
				restartbutton.MouseButton1Down:Connect(function()
					screen:ClearElements()
					speaker:ClearSounds()
					Beep(1)
					backgroundimageframe = nil
					backgroundimage = nil
					getstuff()
					if screen then
						if disk then
							color = disk:Read("Color")
							local diskbackgroundimage = disk:Read("BackgroundImage")
							if color then
								color = string.split(color, ",")
								if color then
									if tonumber(color[1]) and tonumber(color[2]) and tonumber(color[3]) then
										color = Color3.new(tonumber(color[1])/255, tonumber(color[2])/255, tonumber(color[3])/255)
									else
										color = Color3.new(0, 128/255, 218/255)
									end
								else
									color = Color3.new(0, 128/255, 218/255)
								end
							else
								color = Color3.new(0, 128/255, 218/255)
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
							if speaker then
								if keyboard then
									loadmenu(screen, disk)
									Beep(0.25)
									task.wait(0.1)
									Beep(0.5)
									task.wait(0.1)
									Beep(1)
									task.wait(0.1)
									Beep(0.5)
									task.wait(0.1)
									Beep(0.75)
									task.wait(0.1)
									Beep(1)
									if keyboardevent then
										keyboardevent:UnBind()
										keyboardevent = nil
									end
									keyboardevent = keyboard:Connect("TextInputted", function(text, plr)
										keyboardinput = text
										playerthatinputted = plr
									end)
								else
									local textbutton = screen:CreateElement("TextButton", {Size = UDim2.new(1, 0, 1, 0), Text = "No keyboard was found.", TextScaled = true})
									Beep(1)
									textbutton.MouseButton1Down:Connect(function()
										screen:ClearElements()
										getstuff()
										startload()
									end)
								end
							else
								local textbutton = screen:CreateElement("TextButton", {Size = UDim2.new(1, 0, 1, 0), Text = "No speaker was found.", TextScaled = true})
								Beep(1) 
								textbutton.MouseButton1Down:Connect(function()
									screen:ClearElements()
									getstuff()
									startload()
								end)
							end
						else
							local textbutton = screen:CreateElement("TextButton", {Size = UDim2.new(1, 0, 1, 0), Text = "No disk was found.", TextScaled = true})
							Beep(1)
							textbutton.MouseButton1Down:Connect(function()
								screen:ClearElements()
								getstuff()
								startload()
							end)
						end
					else
						print("No screen was found.")
						Beep(1)
					end
				end)
			end)
			--shutdown:

			if shutdown then
				shutdown.MouseButton1Up:Connect(function()
					local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.4, 0, 0.25, 25), Active = true, Draggable = true, TextTransparency = 1})
					local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-25,0,25), Position = UDim2.new(0, 25, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Are you sure?"})
					local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
					holderframe:AddChild(textlabel)
					holderframe:AddChild(closebutton)
					local shutdownbutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.5, 0, 0.75, -25), Position = UDim2.new(0, 0, 0.25, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Yes"})
					holderframe:AddChild(shutdownbutton)
					local cancelbutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.5, 0, 0.75, -25), Position = UDim2.new(0.5, 0, 0.25, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "No"})
					holderframe:AddChild(cancelbutton)
					
					closebutton.MouseButton1Down:Connect(function()
						holderframe:Destroy()
						holderframe = nil
					end)

					cancelbutton.MouseButton1Down:Connect(function()
						holderframe:Destroy()
						holderframe = nil
					end)

					shutdownbutton.MouseButton1Down:Connect(function()
						screen:ClearElements()
						speaker:ClearSounds()
						Beep(1)
						task.wait(0.1)
						Beep(0.75)
						task.wait(0.1)
						Beep(0.5)
						task.wait(0.1)
						Beep(1)
						task.wait(0.1)
						Beep(0.5)
						task.wait(0.1)
						Beep(0.25)
						if keyboardevent then
							keyboardevent:UnBind()
							keyboardevent = nil
						end
						TriggerPort(shutdownpoly)
					end)
				end)
			end
			
		end
	end)
end

function startload()
	if screen then
		if disk then
	
			if speaker then
				if keyboard then
					if keyboardevent then
						keyboardevent:UnBind()
						keyboardevent = nil
					end
					keyboardevent = keyboard:Connect("TextInputted", function(text, plr)
						keyboardinput = text
						playerthatinputted = plr
					end)
					if disk:Read("BackgroundImage") or disk:Read("BackgroundColor") or disk:Read("sounds") then
						loadmenu(screen, disk)
						Beep(0.25)
						task.wait(0.1)
						Beep(0.5)
						task.wait(0.1)
						Beep(1)
						task.wait(0.1)
						Beep(0.5)
						task.wait(0.1)
						Beep(0.75)
						task.wait(0.1)
						Beep(1)
					else
						
						Beep(1)
						local backgroundimageframe = screen:CreateElement("ImageLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = "rbxassetid://15185996180"})
						
						local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.7, 0, 0.7, 0), Position = UDim2.new(0.15, 0, 0.15, 0), Active = true, TextTransparency = 1})
						local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-25,0,25), Position = UDim2.new(0, 25, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Welcome to GustavOS"})
						local textlabel2 = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,0,0.8,-25), Position = UDim2.new(0, 0, 0, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Would you like to add a background image and some sounds to the hard drive?"})
						local yes = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.5,0,0.2,0), Position = UDim2.new(0, 0, 0.8, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Yes"})
						local no = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.5,0,0.2,0), Position = UDim2.new(0.5, 0, 0.8, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "No"})
						holderframe:AddChild(textlabel)
						holderframe:AddChild(textlabel2)
						local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
						holderframe:AddChild(no)
						holderframe:AddChild(closebutton)
						holderframe:AddChild(yes)
	
							local function loados()
								backgroundimageframe:Destroy()
								holderframe:Destroy()
								holderframe = nil
								loadmenu(screen, disk)
								Beep(0.25)
								task.wait(0.1)
								Beep(0.5)
								task.wait(0.1)
								Beep(1)
								task.wait(0.1)
								Beep(0.5)
								task.wait(0.1)
								Beep(0.75)
								task.wait(0.1)
								Beep(1)
							end
						
						closebutton.MouseButton1Up:Connect(function()
							loados()
						end)
	
						no.MouseButton1Up:Connect(function()
							loados()
						end)
	
						yes.MouseButton1Up:Connect(function()
							disk:Read("BackgroundImage")
							disk:Write("BackgroundImage", "15185998460,false,0.2,0,0.2,0")
							backgroundimage = "rbxthumb://type=Asset&id=15185998460&w=420&h=420"
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
							disk:Write([[File "Extensions"]], [[There are 3 different File "Extensions", they are: .lua, .img and .aud.]])
							
							loados()
						end)
						
					end
				else
					local textbutton = screen:CreateElement("TextButton", {Size = UDim2.new(1, 0, 1, 0), Text = "No keyboard was found.", TextScaled = true})
					Beep(1)
					textbutton.MouseButton1Down:Connect(function()
						screen:ClearElements()
						getstuff()
						startload()
					end)
					task.wait(0.1)
					Beep(1)
					task.wait(0.1)
					Beep(1)
					task.wait(0.1)
					Beep(1)
				end
			else
				local textbutton = screen:CreateElement("TextButton", {Size = UDim2.new(1, 0, 1, 0), Text = "No speaker was found.", TextScaled = true})
				Beep(1) 
				textbutton.MouseButton1Down:Connect(function()
					screen:ClearElements()
					getstuff()
					startload()
				end)
				task.wait(0.1)
				Beep(1)
				task.wait(0.1)
				Beep(1)
			end
		else
			local textbutton = screen:CreateElement("TextButton", {Size = UDim2.new(1, 0, 1, 0), Text = "No disk was found.", TextScaled = true})
			Beep(1)
			textbutton.MouseButton1Down:Connect(function()
				screen:ClearElements()
				getstuff()
				startload()
			end)
			task.wait(0.1)
			Beep(1)
		end
	else
		Beep(1)
		print("No screen was found.")
	end
end
startload()
