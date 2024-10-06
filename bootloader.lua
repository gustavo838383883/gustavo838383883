local screen = nil
local disk = GetPartFromPort(1, "Disk")
local keyboard = nil
local ports = GetPartsFromPort(2, "Port")
local microcontroller = GetPartFromPort(10, "Microcontroller")
local polysilicon = GetPartFromPort(1, "Polysilicon")
local micropolysilicon = GetPartFromPort(10, "Polysilicon")
do
	local regularscreen = nil

	for i, port in ipairs(ports) do
		local ts = GetPartFromPort(port, "TouchScreen")
		local rs = GetPartFromPort(port, "Screen")
		local k = GetPartFromPort(port, "Keyboard")
		
		if ts and not screen then
			screen = ts
		end

		if rs and not regularscreen and not screen then
			regularscreen = rs
		end

		if k and not keyboard then
			keyboard = k
		end

		if screen and keyboard then
			break
		end
	end
	
	if not screen and regularscreen then
		screen = regularscreen
		regularscreen = nil
	end
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

local commandline = {}

function commandline.new(scr)
	local screen = scr or screen
	local background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0), ScrollBarThickness = 5})
	local lines = {
		number = UDim2.new(0,0,0,0)
	}
	local biggesttextx = 0

	function lines.clear()
		for i, child in ipairs(background:GetChildren()) do
			child:Destroy()
		end
		lines.number = UDim2.new(0,0,0,0)
		biggesttextx = 0
	end

	function lines.insert(text, udim2)
		print(text)
		local textlabel = screen:CreateElement("TextBox", {TextSize = 10, ClearTextOnFocus = false, TextEditable = false, BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Text = tostring(text):gsub("\n", ""), RichText = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Position = lines.number})
		if textlabel then
			textlabel.Size = UDim2.new(0, math.max(textlabel.TextBounds.X, textlabel.TextSize), 0, math.max(textlabel.TextBounds.Y, textlabel.TextSize))
			local textbounds = textlabel.TextBounds

			if textbounds.X > biggesttextx then
				biggesttextx = textbounds.X
			end
			textlabel.Parent = background
			background.CanvasSize = UDim2.new(0, biggesttextx, 0, lines.number.Y.Offset + math.max(textbounds.Y, textlabel.TextSize))
			if typeof(udim2) == "UDim2" then
				textlabel.Size = udim2
				local newsizex = if udim2.X.Offset > biggesttextx then udim2.X.Offset else 0
				background.CanvasSize -= UDim2.fromOffset(newsizex, math.max(textbounds.Y, textlabel.TextSize))
				background.CanvasSize += UDim2.new(0, newsizex, 0, udim2.Y.Offset)
				if udim2.X.Offset > screen:GetDimensions().X then
					background.CanvasSize += UDim2.new(0, udim2.X.Offset - screen:GetDimensions().X, 0, 0)
				end
				lines.number -= UDim2.new(0,0,0,math.max(textbounds.Y, textlabel.TextSize))
				lines.number += UDim2.new(0, 0, udim2.Y.Scale, udim2.Y.Offset)
			end
			lines.number += UDim2.new(0, 0, 0, math.max(textbounds.Y, textlabel.TextSize))
			background.CanvasPosition = Vector2.new(0, lines.number.Y.Offset-5)
		end
		return textlabel
	end
	return lines, background
end


local name = "Bootloader"

local function loadmicro(micro, text, lines)
	if micro then
		micro:Configure({Code = tostring(text)})
		screen:ClearElements()

		micropolysilicon:Configure({PolysiliconMode = 1})

		TriggerPort(10)

		micropolysilicon:Configure({PolysiliconMode = 0})

		TriggerPort(10)
		TriggerPort(1)
	else
		lines.insert("No microcontroller found.")
	end
end

local function boot()
	micropolysilicon:Configure({PolysiliconMode = 1})

	TriggerPort(10)

	if screen then

		screen:ClearElements()

		local lines, background = commandline.new(screen)

		lines.insert(name)

		Beep(1)

		task.wait(1)

		if disk then
			
			local inputfunc = nil
			local allbootable = disk:Read("Boot")
			local autobootfile = disk:Read("AutoBoot")
			local autobootcode = (allbootable or {})[autobootfile]
			local inputentered
			
			if keyboard then

				keyboard.TextInputted:Connect(function(text)
					inputentered = true
					if inputfunc then
						inputfunc(text)
					end
				end)

			else
				lines.insert("No keyboard was found.")
			end
			
			if autobootcode then
				lines.insert("Auto booting...")
				lines.insert("Type anything to cancel")
				task.wait(2)
				if not inputentered then
					loadmicro(microcontroller, autobootcode, lines)
					TriggerPort(polysilicon)
				end
			end
			
			local function showfiles(f, boolean)
				local amount = 0
				local names = {}
				
				for name, data in pairs(allbootable or {}) do
					amount += 1
					lines.insert(amount)
					lines.insert(name)

					names[amount] = name
				end
				
				if amount < 1 then
					return true
				end
				
				if not boolean then
					lines.insert("Enter file number.")
				end

				inputfunc = function(text)
					local text = text:gsub("\n", "")

					lines.insert(text)

					if (tonumber(text) and not boolean) or boolean then
						local name = names[tonumber(text)]

						f(text, name)

					else
						lines.insert("Invalid")
					end
				end
			end

			local function filecreator()
				lines.insert("Enter file name")

				local name = ""
				local data = ""

				inputfunc = function(text)
					name = text:gsub("\n", "")

					if name == "" then return end

					lines.insert(name)

					lines.insert("Enter file data")

					inputfunc = function(text)
						data = text

						lines.insert(data:gsub("\n", ""))

						if text:gsub("\n", "") == "" then return end

						lines.insert("Save? (Y/N)")

						inputfunc = function(text)
							local gsubed = text:gsub("\n", "")
							lines.insert(gsubed)

							if gsubed:lower() ~= "y" and gsubed:lower() ~= "n" then
								lines.insert("Save? (Y/N)")
							elseif gsubed:lower() == "n" then
								boot()
							elseif gsubed:lower() == "y" then
								if name ~= "" and data ~= "" then
									if disk then
										if not disk:Read("Boot") then
											disk:Write("Boot", {})
										end

										createfileontable(disk, name, data, "/Boot")

										boot()
									else
										lines.insert("No disk was found.")
									end
								else
									lines.insert("No name or data was specified.")
									task.wait(1)
									boot()
								end
							end
						end
					end
				end
			end
			
			local function autobootdeleter()
				lines.insert("Are you sure?")
				
				inputfunc = function(text)
					local gsubed = text:gsub("\n", "")
					lines.insert(gsubed)

					if gsubed:lower() ~= "y" and gsubed:lower() ~= "n" then
						lines.insert("Are you sure? (Y/N)")
					elseif gsubed:lower() == "n" then
						boot()
					elseif gsubed:lower() == "y" then
						if disk then
							disk:Write("AutoBoot", nil)

							boot()
						else
							lines.insert("No disk was found.")
						end
					end
				end
			end
			
			local function autobootcreator()
				lines.insert("Enter file name")

				local name = ""
				local data = ""
				
				showfiles(function(text, name)
					if name then
						lines.insert("Are you sure? (Y/N)")

						inputfunc = function(text)
							local gsubed = text:gsub("\n", "")
							lines.insert(gsubed)

							if gsubed:lower() ~= "y" and gsubed:lower() ~= "n" then
								lines.insert("Are you sure? (Y/N)")
							elseif gsubed:lower() == "n" then
								boot()
							elseif gsubed:lower() == "y" then
								if disk then
									disk:Write("AutoBoot", name)

									boot()
								else
									lines.insert("No disk was found.")
								end
							end
						end
					else
						lines.insert("No file was selected.")
						lines.clear()
						autobootcreator()
					end
				end)
			end
			
			local function filedeleter()
				lines.insert("Enter file name")

				local name = ""
				local data = ""

				showfiles(function(text, name)
					if name then
						lines.insert("Delete? (Y/N)")
						
						inputfunc = function(text)
							local gsubed = text:gsub("\n", "")
							lines.insert(gsubed)

							if gsubed:lower() ~= "y" and gsubed:lower() ~= "n" then
								lines.insert("Delete? (Y/N)")
							elseif gsubed:lower() == "n" then
								boot()
							elseif gsubed:lower() == "y" then
								if disk then
									if not disk:Read("Boot") then
										disk:Write("Boot", {})
									end

									createfileontable(disk, name, nil, "/Boot")

									boot()
								else
									lines.insert("No disk was found.")
								end
							end
						end
					else
						lines.insert("No file was selected.")
						lines.clear()
						filedeleter()
					end
				end)
			end

			local function bootcreate()
				lines.insert("Would you like to create a bootable file? (Y/N)")

				inputfunc = function(text)
					local gsubed = text:gsub("\n", "")
					lines.insert(gsubed)
					if gsubed:lower() ~= "y" and gsubed:lower() ~= "n" then
						lines.clear()
						bootcreate()
					elseif gsubed:lower() == "y" then
						lines.clear()
						filecreator()
					elseif gsubed:lower() == "n" then
						screen:ClearElements()

						TriggerPort(polysilicon)
					end
				end
			end

			if allbootable then
				lines.insert("Enter file number to boot.")
				lines.insert("Enter createfile to create a bootable file.")
				lines.insert("Enter deletefile to delete a bootable file.")
				lines.insert("Enter setautobootfile to make the computer automatically run a bootable file when turned on.")
				lines.insert("Enter disableautoboot to disable auto boot.")
				lines.insert("Enter shutdown to shutdown.")
				local isempty = showfiles(function(text, name)
					local lowered = text:lower()
					if lowered == "createfile" then
						lines.clear()
						filecreator()
					elseif lowered == "setautobootfile" then
						lines.clear()
						autobootcreator()
					elseif lowered == "disableautoboot" then
						lines.clear()
						autobootdeleter()
					elseif lowered == "deletefile" then
						lines.clear()
						filedeleter()
					elseif lowered == "shutdown" then
						screen:ClearElements()

						TriggerPort(polysilicon)
					elseif name then
						local code = allbootable[name]

						if code then
							loadmicro(microcontroller, code, lines)
						else
							lines.insert("Invalid number")
						end

					else
						lines.insert("Invalid")
					end
				end, true)
				
				if isempty then
					lines.insert("No bootable file was found.")
					bootcreate()
				end

			else

				lines.insert("No bootable file was found.")
				bootcreate()

			end

		else

			lines.insert("No disk was found.")

		end

	else

		Beep(0.5)

	end

end

boot()
