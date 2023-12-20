local window = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Terminal", false, false ,false, "Terminal", false)

local name = "GustavDOS For GustavOSDesktop7"
local usedmicros = {}

local button = createnicebutton(UDim2.new(0.2, 0, 0.2, -35), UDim2.new(0.8, 0, 1, -10), "Run", window)

local textbox = createnicebutton(UDim2.new(0.8, 0, 0.2, -35), UDim2.new(0, 0, 1, -10), "Command (Click to update)", window)
local textinput

textbox.MouseButton1Up:Connect(function()
	textinput = tostring(keyboardinput)
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
			audioui(screen, disk, data, speaker)
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
		screen:ClearElements()
		commandlines, background = commandline.new(screen)
		background.Size = UDim2.new(1, 0, 0.8, -35)
		background.Position = UDim2.new(0, 0, 0, 25)
		window:AddChild(background)
		commandlines:insert(dir..":")
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
			background:Destroy()
		else
			commandlines:insert(dir..":")
		end
	elseif text:lower():sub(1, 6) == "print " then
		commandlines:insert(text:sub(7, string.len(text)))
		print(text:sub(7, string.len(text)))
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
					local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
					StringToGui(screen, tostring(output):lower(), textlabel)
					textlabel.TextTransparency = 1
					print(disk:Read(output))
				else
					commandlines:insert(tostring(output))
					print(disk:Read(output))
				end
			else
				local output = getfileontable(disk, filename, dir)
				if string.find(string.lower(tostring(output)), "<woshtml>") then
					local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
					StringToGui(screen, tostring(output):lower(), textlabel)
					textlabel.TextTransparency = 1
					print(disk:Read(output))
				else
					commandlines:insert(tostring(output))
					print(disk:Read(output))
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
				local textlabel = commandlines:insert(tostring(disk:Read(filename)), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
				StringToGui(screen, [[<img src="]]..tostring(tonumber(disk:Read(filename)))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
				print(disk:Read(filename))
			else
				local textlabel = commandlines:insert(tostring(getfileontable(disk, filename, dir)), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
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
				local textlabel = commandlines:insert(tostring(disk:Read(filename)), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
				local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..id})
				textlabel:AddChild(videoframe)
				videoframe.Playing = true
				print(disk:Read(filename))
			else
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
			local textlabel = commandlines:insert(tostring(id), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
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
			local textlabel = commandlines:insert(tostring(id), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
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
	elseif text:lower():sub(1, 4) == "cmds" then
		commandlines:insert("Commands:")
		commandlines:insert("cmds")
		commandlines:insert("stopsounds")
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
					commandlines:insert(tostring(output))
					playsound(output)
					commandlines:insert(dir..":")
					print(output)
				elseif string.find(filename, ".img") then
					local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
					StringToGui(screen, [[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
					commandlines:insert(dir..":")
					background.CanvasPosition -= Vector2.new(0, 25)
					print(disk:Read(output))
				elseif string.find(filename, ".lua") then
					commandlines:insert(tostring(output))
					loadluafile(microcontrollers, screen, output)
					commandlines:insert(dir..":")
				else
					if string.find(string.lower(tostring(output)), "<woshtml>") then
						local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
						StringToGui(screen, tostring(output):lower(), textlabel)
						textlabel.TextTransparency = 1
						commandlines:insert(dir..":")
						background.CanvasPosition -= Vector2.new(0, 25)
						print(disk:Read(output))
					else
						commandlines:insert(tostring(output))
						commandlines:insert(dir..":")
						print(disk:Read(output))
					end
				end
			else
				commandlines:insert("Imcomplete or Command was not found.")
				commandlines:insert(dir..":")
			end
		else
			local output = getfileontable(disk, filename, dir)
			if output then
				if string.find(filename, ".aud") then
					commandlines:insert(tostring(output))
					playsound(output)
					commandlines:insert(dir..":")
					print(output)
				elseif string.find(filename, ".img") then
					local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
					StringToGui(screen, [[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
					commandlines:insert(dir..":")
					background.CanvasPosition -= Vector2.new(0, 25)
					print(disk:Read(output))
				elseif string.find(filename, ".lua") then
					commandlines:insert(tostring(output))
					loadluafile(microcontrollers, screen, output)
					commandlines:insert(dir..":")
				else
					if string.find(string.lower(tostring(output)), "<woshtml>") then
						local textlabel = commandlines:insert(tostring(output), UDim2.fromOffset(screen:GetDimensions().X, screen:GetDimensions().Y))
						StringToGui(screen, tostring(output):lower(), textlabel)
						textlabel.TextTransparency = 1
						commandlines:insert(dir..":")
						background.CanvasPosition -= Vector2.new(0, 25)
						print(disk:Read(output))
					else
						commandlines:insert(tostring(output))
						commandlines:insert(dir..":")
						print(disk:Read(output))
					end
				end
			else
				commandlines:insert("Imcomplete or Command was not found.")
				commandlines:insert(dir..":")
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
		commandlines, background = commandline.new(screen)
		window:AddChild(background)
		background.Size = UDim2.new(1, 0, 0.8, -35)
		background.Position = UDim2.new(0, 0, 0, 25)
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
				bootos()
				keyboardevent:Unbind()
			end)
		end
	elseif not screen then
		Beep(0.5)
		print("No screen was found.")
		if keyboard then
			local keyboardevent = button.MouseButton1Up:Connect(function()
				getstuff()
				bootos()
				keyboardevent:Unbind()
			end)
		end
	end
end
bootos()
