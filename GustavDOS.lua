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
	if typeof(soundLength) == "number" then
		SpeakerHandler._LoopedSounds[speaker.GUID] = {
			Speaker = speaker,
			Length = soundLength / pitch,
			TimePlayed = tick()
		}
	end
	
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
					if #temprom:ReadEntireDisk() == 0 then
						rom = temprom
						romport = i
					elseif temprom:Read("GDOSLibrary") then
						if temprom:Read("GustavOSLibrary") then
							temprom:Write("GustavOSLibrary", nil)
						end
						if temprom:Read("GD7Library") then
							temprom:Write("GD7Library", nil)
						end
						rom = temprom
						romport = i
					elseif #temprom:ReadEntireDisk() == 1 and temprom:Read("GD7Library") then
						temprom:Write("GD7Library", nil)
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
					if #v:ReadEntireDisk() == 0 then
						rom = v
						romport = i
						romindexusing = index
						sharedport = true
						break
					elseif v:Read("GDOSLibrary") then
						if v:Read("GustavOSLibrary") then
							v:Write("GustavOSLibrary", nil)
						end
						if v:Read("GD7Library") then
							v:Write("GD7Library", nil)
						end
						rom = v
						romindexusing = index
						romport = i
						sharedport = true
						break
					elseif #v:ReadEntireDisk() == 1 and v:Read("GustavOSLibrary") or v:Read("GD7Library") then
						v:Write("GustavOSLibrary", nil)
						v:Write("GD7Library", nil)
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
local commandline = {}

local position = UDim2.new(0,0,0,0)

function commandline.new(screen)
	local background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0), ScrollBarThickness = 5})
	local lines = {
		insert = function(text, udim2)
			local textlabel = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Text = tostring(text), TextScaled = true, RichText = true, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Size = UDim2.new(1, 0, 0, 25), Position = position})
			if textlabel then
				background:AddChild(textlabel)
				background.CanvasSize = UDim2.new(1, 0, 0, position.Y.Offset + 25)
				if typeof(udim2) == "UDim2" then
					textlabel.Size = udim2
					background.CanvasSize -= UDim2.fromOffset(0, 25)
					background.CanvasSize += UDim2.new(0, 0, 0, udim2.Y.Offset)
					if udim2.X.Offset > screen:GetDimensions().X then
						background.CanvasSize += UDim2.new(0, udim2.X.Offset - screen:GetDimensions().X, 0, 0)
					end
					position -= UDim2.new(0,0,0,25)
					position += UDim2.new(0, 0, udim2.Y.Scale, udim2.Y.Offset)
				end
				position += UDim2.new(0, 0, 0, 25)
				background.CanvasPosition = Vector2.new(0, position.Y.Offset)
			end
			return textlabel
		end,
	}
	return lines, background
end


local name = "GustavDOS"

local keyboardevent

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

local usedmicros = {}

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
				
						commandlines.insert("Using microcontroller:")
						
						commandlines.insert(micronumber)
						break
					else
						commandlines.insert("No port connected to polysilicon")
					end
				else
					commandlines.insert("No polysilicon connected to microcontroller")
				end
			end
		end
	end
	if not success then
		commandlines.insert("No microcontrollers left.")
	end
end

local bootos
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
			if not length then
				SpeakerHandler.PlaySound(spacesplitted[1], tonumber(pitch), nil, speaker)
			else
				SpeakerHandler:LoopSound(spacesplitted[1], tonumber(length), tonumber(pitch), speaker)
			end
		elseif string.find(tostring(txt), "length:") then
			
			local splitted = string.split(tostring(txt), "length:")
			
			local spacesplitted = string.split(tostring(txt), " ")
			
			local length = nil
				
			if string.find(splitted[2], " ") then
				length = (string.split(splitted[2], " "))[1]
			else
				length = splitted[2]
			end
			
			SpeakerHandler:LoopSound(spacesplitted[1], nil, tonumber(pitch), speaker)
			
		else
			SpeakerHandler.PlaySound(txt, nil, nil, speaker)
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
					commandlines.insert(inputtedtext..":")
					dir = inputtedtext
				else
					commandlines.insert("Invalid directory")
					commandlines.insert(dir..":")
				end
			else
				if disk:Read(split[#split]) or split[2] == "" then
					if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
						commandlines.insert(inputtedtext..":")
						dir = inputtedtext
					elseif tempsplit[1] == "" and tempsplit[2] == "" then
						commandlines.insert(inputtedtext..":")
						dir = inputtedtext
					elseif tempsplit[1] == "" and tempsplit[2] ~= "" then
						if typeof(disk:Read(split[#split])) == "table" then
							commandlines.insert(inputtedtext..":")
							dir = inputtedtext
						end
					else
						commandlines.insert("Invalid directory")
						commandlines.insert(dir..":")
					end
				else
					commandlines.insert("Invalid directory")
					commandlines.insert(dir..":")
				end
			end
		elseif inputtedtext == "" then
			commandlines.insert(dir..":")
		else
			commandlines.insert("Invalid directory")
			commandlines.insert(dir..":")
		end
	elseif text:lower():sub(1, 5) == "clear" then
		task.wait(0.1)
		screen:ClearElements()
		commandlines, background = commandline.new(screen)
		position = UDim2.new(0,0,0,0)
		commandlines.insert(dir..":")
	elseif text:lower():sub(1, 6) == "reboot" then
		task.wait(1)
		Beep(1)
		getstuff()
		dir = "/"
		if keyboardevent then keyboardevent:Unbind() end
		bootos()
	elseif text:lower():sub(1, 8) == "shutdown" then
		if text:sub(9, string.len(text)) == nil or text:sub(9, string.len(text)) == "" then
			task.wait(1)
			Beep(1)
			screen:ClearElements()
			if speaker then speaker:ClearSounds() end
			if shutdownpoly then
				TriggerPort(shutdownpoly)
			end
		else
			commandlines.insert(dir..":")
		end
	elseif text:lower():sub(1, 6) == "print " then
		commandlines.insert(text:sub(7, string.len(text)))
		print(text:sub(7, string.len(text)))
		commandlines.insert(dir..":")
	elseif text:lower():sub(1, 10) == "showmicros" then
		if microcontrollers then
			local start = 0
			for i,v in pairs(microcontrollers) do
				start += 1
				commandlines.insert("Microcontroller")
				commandlines.insert(start)
			end
		else
			commandlines.insert("No microcontrollers found.")
		end
		commandlines.insert(dir..":")
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
						commandlines.insert("Microcontroller turned off.")
					else
						commandlines.insert("No port connected to polysilicon")
					end
				else
					commandlines.insert("No polysilicon connected to microcontroller")
				end
			end
		end
		if not success then
			commandlines.insert("Invalid microcontroller number")
		end
		commandlines.insert(dir..":")
	elseif text:lower():sub(1, 7) == "runlua " then
		print(text)
		loadluafile(microcontrollers, screen, text:sub(8, string.len(text)))
		commandlines.insert(dir..":")
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
				commandlines.insert(output)
				loadluafile(microcontrollers, screen, output)
			else
				local output = getfileontable(disk, filename, dir)
				commandlines.insert(output)
				loadluafile(microcontrollers, screen, output)
			end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
	elseif text:lower():sub(1, 5) == "beep " then
		local number = tonumber(text:sub(6, string.len(text)))
		print(number)
		if number then
			Beep(number)
		else
			commandlines.insert("Invalid number")
		end
		commandlines.insert(dir..":")
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
						commandlines.insert(tostring(i))
						print(i)
					end
				else
					commandlines.insert("Invalid directory")
				end
			else
				local output = disk:Read(split[#split])
				if output or split[2] == "" then
					if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
						if typeof(output) == "table" then
							for i,v in pairs(output) do
								commandlines.insert(tostring(i))
								print(i)
							end
						end
					elseif tempsplit[1] == "" and tempsplit[2] == "" then
						for i,v in pairs(disk:ReadEntireDisk()) do
							commandlines.insert(tostring(i))
							print(i)
						end
					elseif tempsplit[1] == "" and tempsplit[2] ~= "" then
						if typeof(disk:Read(split[#split])) == "table" then
							for i,v in pairs(disk:Read(split[#split])) do
								commandlines.insert(tostring(i))
								print(i)
							end
						end
					else
						commandlines.insert("Invalid directory")
					end
				else
					commandlines.insert("Invalid directory")
				end
			end
		elseif inputtedtext == "" then
			for i,v in pairs(disk:ReadEntireDisk()) do
				commandlines.insert(tostring(i))
			end
		else
			commandlines.insert("Invalid directory")
		end
		commandlines.insert(dir..":")
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
					commandlines.insert("Success i think")
				else
					commandlines.insert("Failed")
				end
			else
				if disk:Read(split[2]) == returntable then
					commandlines.insert("Success i think")
				else
					commandlines.insert("Failed i think")
				end	
			end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
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
							commandlines.insert("Success i think")
						else
							commandlines.insert("Failed")
						end
					else
						commandlines.insert("Failed")
					end
				else
					if disk:Read(split[2]) == returntable and disk:Read(split[2]) then
						commandlines.insert("Success i think")
					else
						commandlines.insert("Failed i think")
					end	
				end
			else
				commandlines.insert("No filedata specified")
			end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
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
						commandlines.insert("Success i think")
					else
						commandlines.insert("Failed")
					end
				else
					commandlines.insert("File does not exist")
				end
			else
				if disk:Read(split[2]) == returntable then
					commandlines.insert("Success i think")
				else
					commandlines.insert("Failed i think")
				end	
			end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
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
					local textlabel = commandlines.insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
					StringToGui(screen, tostring(output):lower(), textlabel)
					textlabel.TextTransparency = 1
					print(disk:Read(output))
				else
					commandlines.insert(tostring(output))
					print(disk:Read(output))
				end
			else
				local output = getfileontable(disk, filename, dir)
				if string.find(string.lower(tostring(output)), "<woshtml>") then
					local textlabel = commandlines.insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
					StringToGui(screen, tostring(output):lower(), textlabel)
					textlabel.TextTransparency = 1
					print(disk:Read(output))
				else
					commandlines.insert(tostring(output))
					print(disk:Read(output))
				end
			end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
	elseif text:lower():sub(1, 10) == "readimage " then
		local filename = text:sub(11, string.len(text))
		print(filename)
		if filename and filename ~= "" then
			local split = nil
			if dir ~= "" then
				split = string.split(dir, "/")
			end
			if not split or split[2] == "" then
				local textlabel = commandlines.insert(tostring(disk:Read(filename)), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
				StringToGui(screen, [[<img src="]]..tostring(tonumber(disk:Read(filename)))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
				print(disk:Read(filename))
			else
				local textlabel = commandlines.insert(tostring(getfileontable(disk, filename, dir)), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
				StringToGui(screen, [[<img src="]]..tostring(tonumber(getfileontable(disk, filename, dir)))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
				print(getfileontable(disk, filename, dir))
			end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
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
				local textlabel = commandlines.insert(tostring(disk:Read(filename)), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
				local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..id})
				textlabel:AddChild(videoframe)
				videoframe.Playing = true
				print(disk:Read(filename))
			else
				local textlabel = commandlines.insert(tostring(getfileontable(disk, filename, dir)), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
				local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..id})
				textlabel:AddChild(videoframe)
				videoframe.Playing = true
				print(getfileontable(disk, filename, dir))
			end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
		if filename and filename ~= "" then
			background.CanvasPosition -= Vector2.new(0, 25)
		end
	elseif text:lower():sub(1, 13) == "displayimage " then
		local id = text:sub(14, string.len(text))
		print(id)
		if id and id ~= "" then
			local textlabel = commandlines.insert(tostring(id), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
			StringToGui(screen, [[<img src="]]..tostring(tonumber(id))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
		else
			commandlines.insert("No id specified")
		end
		commandlines.insert(dir..":")
		if id and id ~= "" then
			background.CanvasPosition -= Vector2.new(0, 25)
		end
	elseif text:lower():sub(1, 13) == "displayvideo " then
		local id = text:sub(14, string.len(text))
		print(id)
		if id and id ~= "" then
			local textlabel = commandlines.insert(tostring(id), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
			local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..id})
			textlabel:AddChild(videoframe)
			videoframe.Playing = true
		else
			commandlines.insert("No id specified")
		end
		commandlines.insert(dir..":")
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
				local textlabel = commandlines.insert(tostring(disk:Read(filename)))
				txt = disk:Read(filename)
				print(disk:Read(filename))
			else
				local textlabel = commandlines.insert(tostring(getfileontable(disk, filename, dir)))
				txt = getfileontable(disk, filename, dir)
				print(getfileontable(disk, filename, dir))
			end
		else
			commandlines.insert("No filename specified")
		end
		playsound(txt)
		commandlines.insert(dir..":")
	elseif text:lower():sub(1, 10) == "playsound " then
		local txt = text:sub(11, string.len(text))
		playsound(txt)
		commandlines.insert(dir..":")
	elseif text:lower():sub(1, 10) == "stopsounds" then
		speaker.ClearSounds()
		SpeakerHandler:RemoveSpeakerFromLoop(speaker)
		commandlines.insert(dir..":")
	elseif text:lower():sub(1, 4) == "cmds" then
		commandlines.insert("Commands:")
		commandlines.insert("cmds")
		commandlines.insert("stopsounds")
		commandlines.insert("readsound filename")
		commandlines.insert("read filename")
		commandlines.insert("readimage filename")
		commandlines.insert("dir directory")
		commandlines.insert("showdir")
		commandlines.insert("write filename::filedata")
		commandlines.insert("shutdown")
		commandlines.insert("clear")
		commandlines.insert("reboot")
		commandlines.insert("delete filename")
		commandlines.insert("createdir filename")
		commandlines.insert("stoplua number")
		commandlines.insert("runlua lua")
		commandlines.insert("showmicros")
		commandlines.insert("readlua filename")
		commandlines.insert("beep number")
		commandlines.insert("print text")
		commandlines.insert("playsound id")
		commandlines.insert("displayimage id")
		commandlines.insert("displayvideo id")
		commandlines.insert("readvideo id")
		commandlines.insert(dir..":")
	elseif text:lower():sub(1, 4) == "help" then
		keyboard:SimulateTextInput("cmds", "Microcontroller")
		
	elseif text:lower():sub(1, 10) == "stopmicro " then
		keyboard:SimulateTextInput("stoplua "..text:sub(11, string.len(text)), "Microcontroller")
		
	elseif text:lower():sub(1, 10) == "playvideo " then
		keyboard:SimulateTextInput("displayvideo "..text:sub(11, string.len(text)), "Microcontroller")
		
	elseif text:lower():sub(1, 8) == "makedir " then
		keyboard:SimulateTextInput("createdir "..text:sub(9, string.len(text)), "Microcontroller")
	elseif text:lower():sub(1, 6) == "mkdir " then
		keyboard:SimulateTextInput("createdir "..text:sub(7, string.len(text)), "Microcontroller")
	elseif text:lower():sub(1, 5) == "echo " then
		keyboard:SimulateTextInput("print "..text:sub(6, string.len(text)), "Microcontroller")
	elseif text:lower():sub(1, 10) == "playaudio " then
		keyboard:SimulateTextInput("playsound "..text:sub(11, string.len(text)), "Microcontroller")
	elseif text:lower():sub(1, 10) == "readaudio " then
		keyboard:SimulateTextInput("readsound "..text:sub(11, string.len(text)), "Microcontroller")
	elseif text:lower():sub(1, 10) == "stopaudios" then
		keyboard:SimulateTextInput("stopsounds", "Microcontroller")
	elseif text:lower():sub(1, 9) == "stopaudio" then
		keyboard:SimulateTextInput("stopsounds", "Microcontroller")
	elseif text:lower():sub(1, 9) == "stopsound" then
		keyboard:SimulateTextInput("stopsounds", "Microcontroller")
	else
		local filename = text
		local split = nil
		if dir ~= "" then
			split = string.split(dir, "/")
		end
		if not split or split[2] == "" then
			local output = disk:Read(filename)
			if output then
				if string.find(filename, ".aud") then
					commandlines.insert(tostring(output))
					playsound(output)
					commandlines.insert(dir..":")
					print(output)
				elseif string.find(filename, ".img") then
					local textlabel = commandlines.insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
					StringToGui(screen, [[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
					commandlines.insert(dir..":")
					background.CanvasPosition -= Vector2.new(0, 25)
					print(disk:Read(output))
				elseif string.find(filename, ".lua") then
					commandlines.insert(tostring(output))
					loadluafile(microcontrollers, screen, output)
					commandlines.insert(dir..":")
				else
					if string.find(string.lower(tostring(output)), "<woshtml>") then
						local textlabel = commandlines.insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
						StringToGui(screen, tostring(output):lower(), textlabel)
						textlabel.TextTransparency = 1
						commandlines.insert(dir..":")
						background.CanvasPosition -= Vector2.new(0, 25)
						print(disk:Read(output))
					else
						commandlines.insert(tostring(output))
						commandlines.insert(dir..":")
						print(disk:Read(output))
					end
				end
			else
				commandlines.insert("Imcomplete or Command was not found.")
				commandlines.insert(dir..":")
			end
		else
			local output = getfileontable(disk, filename, dir)
			if output then
				if string.find(filename, ".aud") then
					commandlines.insert(tostring(output))
					playsound(output)
					commandlines.insert(dir..":")
					print(output)
				elseif string.find(filename, ".img") then
					local textlabel = commandlines.insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
					StringToGui(screen, [[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
					commandlines.insert(dir..":")
					background.CanvasPosition -= Vector2.new(0, 25)
					print(disk:Read(output))
				elseif string.find(filename, ".lua") then
					commandlines.insert(tostring(output))
					loadluafile(microcontrollers, screen, output)
					commandlines.insert(dir..":")
				else
					if string.find(string.lower(tostring(output)), "<woshtml>") then
						local textlabel = commandlines.insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
						StringToGui(screen, tostring(output):lower(), textlabel)
						textlabel.TextTransparency = 1
						commandlines.insert(dir..":")
						background.CanvasPosition -= Vector2.new(0, 25)
						print(disk:Read(output))
					else
						commandlines.insert(tostring(output))
						commandlines.insert(dir..":")
						print(disk:Read(output))
					end
				end
			else
				commandlines.insert("Imcomplete or Command was not found.")
				commandlines.insert(dir..":")
			end
		end
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
	if not screen then
		if regularscreen then screen = regularscreen end
	end
	if screen and keyboard and disk and rom then
		if speaker then
			speaker:ClearSounds()
		end
		screen:ClearElements()

		rom:Write("GustavOSLibrary", nil)
		rom:Write("GD7Library", nil)
		rom:Write("GDOSLibrary", nil)
		rom:Write("GDOSLibrary", {
			Screen = screen,
			Keyboard = keyboard,
			Modem = modem,
			Speaker = speaker,
			Disk = disk,
			lines = commandlines,
			background = background,
		})
		commandlines, background = commandline.new(screen)
		task.wait(1)
		position = UDim2.new(0,0,0,0)
		Beep(1)
		commandlines.insert(name.." Command line")
		task.wait(1)
		commandlines.insert("/:")
		if keyboardevent then keyboardevent:Unbind() end
		keyboardevent = keyboard:Connect("TextInputted", function(text, player)
			commandlines.insert(tostring(text):gsub("\n", ""):gsub("/n\\", "\n"))
			runtext(tostring(text):gsub("\n", ""):gsub("/n\\", "\n"))
		end)
	elseif screen then
		screen:ClearElements()
		local commandlines = commandline.new(screen)
		commandlines.insert(name.." Command line")
		task.wait(1)
		if not speaker then
			commandlines.insert("No speaker was found. (Optional)")
		end
		task.wait(1)
		if not keyboard then
			commandlines.insert("No keyboard was found.")
		end
		task.wait(1)
		if not disk then
			commandlines.insert("You need 2 or more disks, 2 or more ports must not be connected to the same disks.")
		end
		if not rom then
			commandlines.insert([[No empty disk or disk with the file "GDOSLibrary" was found.]])
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
	elseif not screen then
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
