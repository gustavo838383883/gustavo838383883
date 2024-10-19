local function getfileextension(filename, boolean)
	local result = string.match(filename, "%.[%w%p]+%s*$")
	if not result then return end
	result = result:lower()
	local nospace = string.gsub(result, "%s", "")

	if result then
		return boolean and result or nospace
	end
end

local function createfileontable(disk, filename, filedata, directory)
	local returntable = nil
	local directory = directory
	if directory:sub(-1, -1) == "/" then directory = directory:sub(1, -2) end
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
			tablez[#tablez][filename] = filedata

			returntable = rootfile

			disk:Write(split[2], rootfile)
		end
	end
	return returntable
end

local function getfileontable(disk, filename, directory)
	local directory = directory
	if directory:sub(-1, -1) == "/" then directory = directory:sub(1, -2) end
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
local microcontrollers = {}
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

local CreateWindow

local function getstuff()
	disks = nil
	rom = nil
	disk = nil
	screen = nil
	keyboard = nil
	speaker = nil
	modem = nil
	regularscreen = nil
	disksport = nil
	romport = nil
	romindexusing = nil
	sharedport = nil

	local previ = 0
	for i=1, 64 do
		if not GetPort(i) then
			continue
		end
		if i - previ > 5 then
			previ = i
			task.wait(0.1)
		end
		if not rom then
			local temprom = GetPartFromPort(i, "Disk")
			if temprom then
				if #temprom:ReadAll() == 0 then
					rom = temprom
					romport = i
				elseif temprom:Read("SysDisk") then
					rom = temprom
					romport = i
				end
			end
		end
		if not disks then
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

		if disks and #disks > 1 and romport == disksport and not sharedport then
			for index,v in ipairs(disks) do
				if v then
					if #v:ReadAll() == 0 then
						rom = v
						romport = i
						romindexusing = index
						sharedport = true
						break
					elseif v:Read("SysDisk") then
						rom = v
						romindexusing = index
						romport = i
						sharedport = true
						break
					end
				end
			end
		end

		if not modem then
			local tempmodem = GetPartFromPort(i, "Modem")
			if tempmodem then
				modem = tempmodem
			end
		end

		if not speaker then
			local tempspeaker = GetPartFromPort(i, "Speaker")
			if tempspeaker then
				speaker = tempspeaker
			end
		end
		if not screen then
			local tempscreen = GetPartFromPort(i, "TouchScreen")
			if tempscreen then
				screen = tempscreen
			end
		end
		if not regularscreen then
			local tempscreen = GetPartFromPort(i, "Screen")
			if tempscreen then
				regularscreen = tempscreen
			end
		end
		if not keyboard then
			local tempkeyboard = GetPartFromPort(i, "Keyboard")
			if tempkeyboard then
				keyboard = tempkeyboard
			end
		end
	end
end
getstuff()
local commandline = {}

local position = UDim2.new(0,0,0,0)
local richtext = false

function commandline.new(scr)
	local screen = scr or screen
	local background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0), ScrollBarThickness = 5})
	local lines = {
		number = UDim2.new(0,0,0,0)
	}
	local biggesttextx = 0

	function lines.clear()
		pcall(function()
			background:Destroy()
			background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0), ScrollBarThickness = 5})
		end)
		lines.number = UDim2.new(0,0,0,0)
		biggesttextx = 0
	end

	function lines.insert(text, udim2, dontscroll)
		print(text)
		local textlabel = screen:CreateElement("TextBox", {ClearTextOnFocus = false, TextEditable = false, BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Text = tostring(text):gsub("\n", ""), RichText = (richtext or function() return false end)(), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Position = lines.number})
		if textlabel then
			textlabel.Size = UDim2.new(0, math.max(textlabel.TextBounds.X, textlabel.TextSize), 0, math.max(textlabel.TextBounds.Y, textlabel.TextSize))
			if textlabel.TextBounds.X > biggesttextx then
				biggesttextx = textlabel.TextBounds.X
			end
			textlabel.Parent = background
			background.CanvasSize = UDim2.new(0, biggesttextx, 0, math.max(background.AbsoluteSize.Y, lines.number.Y.Offset + math.max(textlabel.TextBounds.Y, textlabel.TextSize)))
			if typeof(udim2) == "UDim2" then
				textlabel.Size = udim2
				local newsizex = if udim2.X.Offset > biggesttextx then udim2.X.Offset else 0
				background.CanvasSize -= UDim2.fromOffset(newsizex, math.max(textlabel.TextBounds.Y, textlabel.TextSize))
				background.CanvasSize += UDim2.new(0, newsizex, 0, udim2.Y.Offset)
				if udim2.X.Offset > background.AbsoluteSize.X then
					background.CanvasSize += UDim2.new(0, udim2.X.Offset - background.AbsoluteSize.X, 0, 0)
				end
				lines.number -= UDim2.new(0,0,0,math.max(textlabel.TextBounds.Y, textlabel.TextSize))
				lines.number += UDim2.new(0, 0, udim2.Y.Scale, udim2.Y.Offset)
			end
			lines.number += UDim2.new(0, 0, 0, math.max(textlabel.TextBounds.Y, textlabel.TextSize))
			if dontscroll then
				background.CanvasPosition = Vector2.new(0, lines.number.Y.Offset)
			end
		end
		return textlabel
	end
	return lines, setmetatable({}, {
		__index = function(t, a)
			return background[a]
		end,
		__newindex = function(t, a, b)
			background[a] = b
		end,
		__metatable = "This metatable is locked."
	})
end

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
				if disk:Read(filename) == filedata then
					value = "Success i think"
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

local name = "GustavDOS"

local keyboardevent

local function StringToGui(screen, text, parent)
	-- big mess from september 2023 that im too lazy to recode
	local start = UDim2.new(0,0,0,0)
	local source = text

	for name, value in source:gmatch('<backimg(.-)(.-)>') do
		local link = nil
		if (string.find(value, 'src="')) then
			local link = string.sub(value, string.find(value, 'src="') + string.len('src="'), string.len(value))
			link = string.sub(link, 1, string.find(link, '"') - 1)
			if true then

				local url = screen:CreateElement("ImageLabel", { })
				url.BackgroundTransparency = 1
				url.Image = "http://www.roblox.com/asset/?id=8552847009"
				if (link ~= "") then
					if tonumber(link) then
						url.Image = "rbxthumb://type=Asset&id="..tonumber(link).."&w=420&h=420"
					else
						url.Image = "rbxthumb://type=Asset&id="..tonumber(string.match(link, "%d+")).."&w=420&h=420"
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
					url.ImageTransparency = tonumber(text) or 0
				end
				url.Parent = parent
			end
		end
	end
	for name, value in source:gmatch('<frame(.-)(.-)>') do
		local link = nil
		if true then

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
				url.Transparency = tonumber(text) or 0
			end
			if (string.find(value, [[zindex="]])) then
				local text = string.sub(value, string.find(value, [[zindex="]]) + string.len([[zindex="]]), string.len(value))
				text = string.sub(text, 1, string.find(text, '"') - 1)
				url.ZIndex = tonumber(text) or 1
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
			url.Parent = parent
		end
	end
	for name, value in source:gmatch('<img(.-)(.-)>') do
		local link = nil
		if (string.find(value, 'src="')) then
			local link = string.sub(value, string.find(value, 'src="') + string.len('src="'), string.len(value))
			link = string.sub(link, 1, string.find(link, '"') - 1)
			if true then

				local url = screen:CreateElement("ImageLabel", { })
				url.BackgroundTransparency = 1
				url.Image = "http://www.roblox.com/asset/?id=8552847009"
				if (link ~= "") then
					if tonumber(link) then
						url.Image = "rbxthumb://type=Asset&id="..tonumber(link).."&w=420&h=420"
					else
						url.Image = "rbxthumb://type=Asset&id="..tonumber(string.match(link, "%d+")).."&w=420&h=420"
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
					url.ImageTransparency = tonumber(text) or 0
				end
				if (string.find(value, [[zindex="]])) then
					local text = string.sub(value, string.find(value, [[zindex="]]) + string.len([[zindex="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					url.ZIndex = tonumber(text) or 1
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
				url.Parent = parent
			end
		end
	end
	for name, value in source:gmatch('<txt(.-)(.-)>') do
		local link = nil
		if (string.find(value, 'display="')) then
			local link = string.sub(value, string.find(value, 'display="') + string.len('display="'), string.len(value))
			link = string.sub(link, 1, string.find(link, '"') - 1)
			if true then

				local url = screen:CreateElement("TextLabel", { })
				url.BackgroundTransparency = 1
				url.Size = UDim2.new(0, 100, 0, 50)

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
				if (string.find(value, [[zindex="]])) then
					local text = string.sub(value, string.find(value, [[zindex="]]) + string.len([[zindex="]]), string.len(value))
					text = string.sub(text, 1, string.find(text, '"') - 1)
					url.ZIndex = tonumber(text) or 1
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
				url.Parent = parent
			end
		end
	end
end

local usedmicros = {}

local background
local commandlines

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
				local sound = speaker:LoadSound(`rbxassetid://{spacesplitted[1]}`)
				sound.Pitch = pitch or 1
				sound.Volume = 1
				sound:Play()

				if sound.Ended then
					sound.Ended:Connect(function() sound:Destroy() end)
				end
			else
				local sound = speaker:LoadSound(`rbxassetid://{spacesplitted[1]}`)
				sound.Volume = 1
				sound.Pitch = pitch or 1
				sound.Looped = true
				sound:Play()
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

			local sound = speaker:LoadSound(`rbxassetid://{spacesplitted[1]}`)
			sound.Volume = 1
			sound.Looped = true
			sound:Play()
		else
			local sound = speaker:LoadSound(`rbxassetid://{txt}`)
			sound.Volume = 1
			sound:Play()
			if sound.Ended then
				sound.Ended:Connect(function() sound:Destroy() end)
			end
		end
	end
end

local coroutineprograms = {}

local function getprograms()
	local t = {}
	
	for i, v in ipairs(coroutineprograms) do
		if coroutine.status(v.coroutine) == "dead" then
			table.remove(coroutineprograms, i)
			continue
		end
		table.insert(t, v.name)
	end
	
	return t
end

local function stopprogram(i)
	local program = coroutineprograms[i]
	if not program then
		return false
	end
	
	if coroutine.status(program.coroutine) ~= "dead" then
		coroutine.close(program.coroutine)
	end
	
	table.remove(coroutineprograms, i)
	
	return true
end

local function stopprogrambyname(name)
	for i, program in ipairs(coroutineprograms) do
		if coroutine.status(program.coroutine) ~= "dead" then
			coroutine.close(program.coroutine)
			table.remove(coroutineprograms, table.find(coroutineprograms, program))
		end
	end
end

local luaprogram
local runtext
local cmdsenabled = true

local function runprogram(text, name)
	if not text then error("no code to run was given in parameter two.") end
	if typeof(name) ~= "string" then
		name = "untitled"
	end
	local fenv = table.clone(getfenv())
	fenv["luaprogram"] = luaprogram
	fenv["filesystem"] = filesystem
	fenv["lines"] = {
		clear = commandlines.clear,
		insert = commandlines.insert,
		background = background,
		disablecmds = function()
			cmdsenabled = false
		end,
		enablecmds = function()
			cmdsenabled = true
		end,
		cmdsenabled = function()
			return cmdsenabled
		end,
	}
	fenv["screen"] = screen
	fenv["keyboard"] = keyboard
	fenv["modem"] = modem
	fenv["speaker"] = speaker
	fenv["disk"] = disk
	fenv["disks"] = disks
	fenv["runtext"] = runtext
	local prg
	fenv["getprg"] = function() return prg end
	local func, b = loadstring(text)
	if func then
		setfenv(func, fenv)
		prg = coroutine.create(func)
		table.insert(coroutineprograms, {name = name, coroutine = prg})
		coroutine.resume(prg)
	end
	return b
end

local function stopprograms()
	for i, v in ipairs(coroutineprograms) do
		if coroutine.status(v.coroutine) ~= "dead" then
			coroutine.close(v.coroutine)
		end
	end
	coroutineprograms = {}
end

luaprogram = {
	getPrograms = getprograms,
	stopProgram = stopprogram,
	stopProgramByName = stopprogrambyname,
	runProgram = runprogram,
}

table.freeze(luaprogram)

local copydir = ""
local copyname = ""
local copydata = ""
local copydisk

function runtext(text)
	local lowered = text:lower()
	if lowered:sub(1, 4) == "dir " then
		local txt = text:sub(5, string.len(text))
		local inputtedtext = txt
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
	elseif lowered:gsub("%s", "") == "clear" then
		task.wait(0.1)
		commandlines.clear()
		position = UDim2.new(0,0,0,0)
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 11) == "setstorage " then
		local text = text:sub(12, string.len(text))

		local text = tonumber(text)

		if disks[text] then
			disk = disks[text]
			dir = "/"
			commandlines.insert("Success")
		else
			commandlines.insert("Invalid storage media number.")
		end
		commandlines.insert(dir..":")
	elseif lowered:gsub("%s", "") == "showstorages" then
		for i, val in ipairs(disks) do
			commandlines.insert(tostring(i))
		end
		commandlines.insert(dir..":")
	elseif lowered:gsub("%s", "") == "reboot" then
		task.wait(1)
		Beep(1)
		getstuff()
		dir = "/"
		if keyboardevent then keyboardevent:Disconnect() end
		bootos()
	elseif lowered:gsub("%s", "") == "shutdown" then
		if text:sub(9, string.len(text)) == nil or text:sub(9, string.len(text)) == "" then
			task.wait(1)
			Beep(1)
			screen:ClearElements()
			if speaker then
				speaker:ClearSounds()
			end
			Microcontroller:Shutdown()
		else
			commandlines.insert(dir..":")
		end
	elseif lowered:sub(1, 9) == "richtext " then
		local bool = text:sub(10, string.len(text)):gsub("%s", ""):lower()
		if bool == "true" then
			richtext = true
		elseif bool == "false" then
			richtext = false
		else
			commandlines.insert("No valid boolean was given.")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 6) == "print " then
		local output = text:sub(7, string.len(text))
		local spacesplitted = string.split(tostring(output), "\n")
		if spacesplitted then
			for i, v in ipairs(spacesplitted) do
				commandlines.insert(v)
			end
		else
			commandlines.insert(tostring(output))
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 5) == "copy " then
		local filename = text:sub(6, string.len(text))
		if filename and filename ~= "" then
			local file = filesystem.Read(filename, dir, true, disk)

			if file then
				copydir = dir
				copydisk = disk
				copyname = filename
				copydata = file
				commandlines.insert("Copied, use the paste command to paste the file.")
			else
				commandlines.insert("The specified file was not found on this directory.")
			end
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 5) == "paste" then
		if copydir ~= "" and copyname ~= "" then
			local file = filesystem.Read(copyname, copydir, true, copydisk)

			if not file then
				file = copydata
			end

			if file then
				local result = filesystem.Write(copyname, file, dir, disk)
				commandlines.insert(result)
			else
				commandlines.insert("File does not exist.")
			end
		else
			commandlines.insert("No file has been copied.")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 7) == "rename " then
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
			local file = filesystem.Read(filename, dir, true, disk)
			if file then
				if newname ~= "" then
					filesystem.Write(newname, file, dir, disk)
					filesystem.Write(filename, nil, dir, disk)
					commandlines.insert("Renamed.")
				else
					commandlines.insert("The new filename wasn't specified.")	
				end
			else
				commandlines.insert("The specified file was not found on this directory.")
			end
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 3) == "cd " then
		local filename = text:sub(4, string.len(text))

		if filename and filename ~= "" and filename ~= "./" then
			local file = filesystem.Read(filename, dir, true, disk)

			if typeof(file) == "table" then
				dir = if dir == "/" then dir..filename else dir.."/"..filename
				commandlines.insert("Success?")
			else
				commandlines.insert("The specified file is not a table.")
			end
		elseif filename == "./" then
			local split = dir:split("/")
			if #split == 2 and split[2] == "" then
				commandlines.insert("Cannot use ./ on root.")
			else
				local newdir = dir:sub(1, -(string.len(split[#split]))-2)
				dir = if newdir == "" then "/" else newdir
			end
		else
			commandlines.insert("The table/folder name was not specified.")
		end
		commandlines.insert(dir..":")
	elseif lowered:gsub("%s", "") == "showluas" then
		for i,v in pairs(getprograms()) do
			commandlines.insert(v)
			commandlines.insert(i)
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 8) == "stoplua " then
		local number = tonumber(text:sub(9, string.len(text)))
		local success = false
		if typeof(number) == "number" then
			success = stopprogram(number)
		end
		if not success then
			commandlines.insert("Invalid program number.")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 7) == "runlua " then
		local err = runprogram(text:sub(8, string.len(text)))
		if err then commandlines.insert(err) end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 8) == "readlua " then
		local filename = text:sub(9, string.len(text))
		if filename and filename ~= "" then
			local output = filesystem.Read(filename, dir, true, disk)
			local output = output
			local err = runprogram(output, filename)
			if err then commandlines.insert(err) end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 5) == "beep " then
		local number = tonumber(text:sub(6, string.len(text)))
		if number then
			Beep(number)
		else
			commandlines.insert("Invalid number")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 10) == "setvolume " then
		if speaker then
			local number = tonumber(text:sub(11, string.len(text)))
			if number then
				speaker.Volume = number
			else
				commandlines.insert("Invalid number")
			end
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 7) == "showdir" then
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
							end
						end
					elseif tempsplit[1] == "" and tempsplit[2] == "" then
						for i,v in pairs(disk:ReadAll()) do
							commandlines.insert(tostring(i))
						end
					elseif tempsplit[1] == "" and tempsplit[2] ~= "" then
						if typeof(disk:Read(split[#split])) == "table" then
							for i,v in pairs(disk:Read(split[#split])) do
								commandlines.insert(tostring(i))
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
			for i,v in pairs(disk:ReadAll()) do
				commandlines.insert(tostring(i))
			end
		else
			commandlines.insert("Invalid directory")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 10) == "createdir " then
		local filename = text:sub(11, string.len(text))
		if filename and filename ~= "" then
			local result = filesystem.Write(filename, {}, dir, disk)

			commandlines.insert(result)
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 6) == "write " then
		local texts = text:sub(7, string.len(text))
		local filename = texts:split("/")[1]
		local filedata = texts:split("/")[2]
		for i,v in ipairs(texts:split("/")) do
			if i > 2 then
				filedata = filedata.."/"..v
			end
		end
		if filename and filename ~= "" then
			if filedata and filedata ~= "" then
				local result = filesystem.Write(filename, filedata, dir, disk)

				commandlines.insert(result)
			else
				commandlines.insert("No filedata specified")
			end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 7) == "delete " then
		local filename = text:sub(8, string.len(text))
		if filename then
			local result = filesystem.Write(filename, nil, dir, disk)

			commandlines.insert(result)
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 5) == "read " then
		local filename = text:sub(6, string.len(text))
		if filename then
			local output = filesystem.Read(filename, dir, true, disk)
			if string.find(string.lower(tostring(output)), "<woshtml>") then
				local textlabel = commandlines.insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
				StringToGui(screen, tostring(output):lower(), textlabel)
				textlabel.TextTransparency = 1
			else
				local spacesplitted = string.split(tostring(output), "\n")
				if spacesplitted then
					for i, v in ipairs(spacesplitted) do
						commandlines.insert(v)
					end
				else
					commandlines.insert(tostring(output))
				end
			end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 10) == "readimage " then
		local filename = text:sub(11, string.len(text))
		if filename and filename ~= "" then
			local output = filesystem.Read(filename, dir, true, disk)
			local textlabel = commandlines.insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
			StringToGui(screen, [[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
		if filename and filename ~= "" then
			background.CanvasPosition -= Vector2.new(0, 25)
		end
	elseif lowered:sub(1, 10) == "readvideo " then
		local filename = text:sub(11, string.len(text))
		if filename and filename ~= "" then
			local output = filesystem.Read(filename, dir, true, disk)
			local textlabel = commandlines.insert(output, UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
			local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..tostring(tonumber(output))})
			videoframe.Parent = textlabel
			videoframe.Playing = true
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
		if filename and filename ~= "" then
			background.CanvasPosition -= Vector2.new(0, 25)
		end
	elseif lowered:sub(1, 13) == "displayimage " then
		local id = text:sub(14, string.len(text))
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
	elseif lowered:sub(1, 13) == "displayvideo " then
		local id = text:sub(14, string.len(text))
		if id and id ~= "" then
			local textlabel = commandlines.insert(tostring(id), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
			local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..id})
			videoframe.Parent = textlabel
			videoframe.Playing = true
		else
			commandlines.insert("No id specified")
		end
		commandlines.insert(dir..":")
		if id and id ~= "" then
			background.CanvasPosition -= Vector2.new(0, 25)
		end
	elseif lowered:sub(1, 10) == "readsound " then
		local filename = text:sub(11, string.len(text))
		local txt
		if filename and filename ~= "" then
			local output = filesystem.Read(filename, dir, true, disk)
			local textlabel = commandlines.insert(tostring(output))
			txt = output
		else
			commandlines.insert("No filename specified")
		end
		playsound(txt)
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 10) == "playsound " then
		local txt = text:sub(11, string.len(text))
		playsound(txt)
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 10) == "stopsounds" then
		speaker:ClearSounds()
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 11) == "soundpitch " then
		if speaker and tonumber(text:sub(12, string.len(text))) then
			speaker:Configure({Pitch = tonumber(text:sub(12, string.len(text)))})
			speaker:Trigger()
		else
			commandlines.insert("Invalid pitch number or no speaker was found.")
		end
		commandlines.insert(dir..":")
	elseif lowered:gsub("%s", "") == "cmds" then
		commandlines.insert("Commands:")
		commandlines.insert("cmds")
		commandlines.insert("stopsounds")
		commandlines.insert("soundpitch number")
		commandlines.insert("readsound filename")
		commandlines.insert("read filename")
		commandlines.insert("readimage filename")
		commandlines.insert("dir directory")
		commandlines.insert("showdir")
		commandlines.insert("write filename/filedata (with the /)")
		commandlines.insert("shutdown")
		commandlines.insert("clear")
		commandlines.insert("showstorages")
		commandlines.insert("setstorage number")
		commandlines.insert("reboot")
		commandlines.insert("delete filename")
		commandlines.insert("createdir filename")
		commandlines.insert("stoplua number")
		commandlines.insert("runlua lua")
		commandlines.insert("showluas")
		commandlines.insert("richtext boolean")
		commandlines.insert("readlua filename")
		commandlines.insert("beep number")
		commandlines.insert("print text")
		commandlines.insert("playsound id")
		commandlines.insert("displayimage id")
		commandlines.insert("displayvideo id")
		commandlines.insert("readvideo id")
		commandlines.insert("cd table/folder or ./ for parent table/folder")
		commandlines.insert("copy filename")
		commandlines.insert("paste")
		commandlines.insert("rename filename/new filename (with the /)")
		commandlines.insert("Put !s before the command to replace the new lines with spaces instead of removing them.")
		commandlines.insert("Put !n before the command to replace \\\\n with a new line.")
		commandlines.insert("Put !k before the command to not remove the new lines.")
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 4) == "help" then
		keyboard:SimulateTextInput("cmds", "Microcontroller")

	elseif lowered:sub(1, 10) == "stopmicro " then
		keyboard:SimulateTextInput("stoplua "..text:sub(11, string.len(text)), "Microcontroller")
	elseif lowered:sub(1, 10) == "showmicros" then
		keyboard:SimulateTextInput("showluas", "Microcontroller")

	elseif lowered:sub(1, 10) == "playvideo " then
		keyboard:SimulateTextInput("displayvideo "..text:sub(11, string.len(text)), "Microcontroller")

	elseif lowered:sub(1, 8) == "makedir " then
		keyboard:SimulateTextInput("createdir "..text:sub(9, string.len(text)), "Microcontroller")
	elseif lowered:sub(1, 6) == "mkdir " then
		keyboard:SimulateTextInput("createdir "..text:sub(7, string.len(text)), "Microcontroller")
	elseif lowered:sub(1, 5) == "echo " then
		keyboard:SimulateTextInput("print "..text:sub(6, string.len(text)), "Microcontroller")
	elseif lowered:sub(1, 10) == "playaudio " then
		keyboard:SimulateTextInput("playsound "..text:sub(11, string.len(text)), "Microcontroller")
	elseif lowered:sub(1, 10) == "readaudio " then
		keyboard:SimulateTextInput("readsound "..text:sub(11, string.len(text)), "Microcontroller")
	elseif lowered:sub(1, 10) == "stopaudios" then
		keyboard:SimulateTextInput("stopsounds", "Microcontroller")
	elseif lowered:sub(1, 9) == "stopaudio" then
		keyboard:SimulateTextInput("stopsounds", "Microcontroller")
	elseif lowered:sub(1, 9) == "stopsound" then
		keyboard:SimulateTextInput("stopsounds", "Microcontroller")
	else
		local filename = text
		local output = filesystem.Read(filename, dir, true, disk)
		if output then
			if getfileextension(filename, true) == ".aud" then
				commandlines.insert(tostring(output))
				playsound(output)
				commandlines.insert(dir..":")
			elseif getfileextension(filename, true) == ".img" then
				local textlabel = commandlines.insert(tostring(output), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
				StringToGui(screen, [[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
				commandlines.insert(dir..":")
				background.CanvasPosition -= Vector2.new(0, 25)
			elseif getfileextension(filename, true) == ".lua" then
				local err = runprogram(output, filename)
				if err then commandlines.insert(err) end
				commandlines.insert(dir..":")
			else
				if string.find(string.lower(tostring(output)), "<woshtml>") then
					local textlabel = commandlines.insert(tostring(output), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
					StringToGui(screen, tostring(output):lower(), textlabel)
					textlabel.TextTransparency = 1
					commandlines.insert(dir..":")
					background.CanvasPosition -= Vector2.new(0, 25)
				else
					local spacesplitted = string.split(tostring(output), "\n")
					if spacesplitted then
						for i, v in ipairs(spacesplitted) do
							commandlines.insert(v)
						end
					else
						commandlines.insert(tostring(output))
					end
					commandlines.insert(dir..":")
				end
			end
		else
			commandlines.insert("Imcomplete or Command was not found.")
			commandlines.insert(dir..":")
		end
	end
end

function bootos()
	if disks and #disks > 0 then
		print(`{romport}\\{disksport}`)
		if romport ~= disksport then
			local indexusing1

			for i,v in ipairs(disks) do
				if rom ~= v then
					disk = v
					indexusing1 = i

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

				break
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
	if not screen then
		if regularscreen then screen = regularscreen end
	end
	if screen and keyboard and disk and rom then
		rom:Write("SysDisk", true)
		if speaker then
			speaker:ClearSounds()
		end
		screen:ClearElements()

		commandlines, background = commandline.new(screen)
		task.wait(1)
		position = UDim2.new(0,0,0,0)
		Beep(1)
		commandlines.insert(name.." Command line")
		task.wait(1)
		commandlines.insert("/:")
		local exclmarkthings = {
			["!s"] = function(text)
				local text = string.sub(tostring(text), 3, string.len(text)):gsub("\n", " ")

				commandlines.insert(text)
				runtext(text)
			end,
			["!n"] = function(text)
				local text = string.sub(tostring(text), 3, string.len(text)):gsub("\n", ""):gsub("\\n", "\n")

				commandlines.insert(text)
				runtext(text)
			end,
			["!k"] = function(text)
				local text = string.sub(tostring(text), 3, string.len(text))

				commandlines.insert(text)
				runtext(text)
			end,
		}
		if keyboardevent then keyboardevent:Disconnect() end
		keyboardevent = keyboard.TextInputted:Connect(function(text, player)
			if not cmdsenabled then return end
			local func = exclmarkthings[string.sub(tostring(text), 1, 2)]
			if not func then
				commandlines.insert(tostring(text):gsub("\n", ""))
				runtext(tostring(text):gsub("\n", ""))
			else
				func(text)
			end
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
			local keyboardevent = keyboard.KeyPressed:Connect(function(key)
				if key == Enum.KeyCode.Return then
					getstuff()
					bootos()
					keyboardevent:Disconnect()
				end
			end)
		else
			while true do task.wait(1) end
		end
	elseif not screen then
		Beep(0.5)
		print("No screen was found.")
		if keyboard then
			local keyboardevent = keyboard.KeyPressed:Connect(function(key)
				if key == Enum.KeyCode.Return then
					getstuff()
					bootos()
					keyboardevent:Disconnect()
				end
			end)
		else
			while true do task.wait(1) end
		end
	end
end
bootos()
