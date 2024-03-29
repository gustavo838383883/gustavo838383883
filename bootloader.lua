local screen = nil
local disk = nil
local keyboard = nil
local regularscreen = nil
local microcontroller = nil
local polysiliconport = nil

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

local function getstuff()
	screen = nil
	disk = nil
	regularscreen = nil
	keyboard = nil
	microcontroller = nil
	polysiliconport = nil

	for i=1, 128 do
		if not disk then
			success, Error = pcall(GetPartFromPort, i, "Disk")
			if success then
				local diskz = GetPartFromPort(i, "Disk")
				if diskz then
					disk = diskz
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
		if not microcontroller then
			success, Error = pcall(GetPartFromPort, i, "Microcontroller")
			if success then
				if GetPartFromPort(i, "Microcontroller") then
					microcontroller = GetPartFromPort(i, "Microcontroller")
				end
			end
		end
		if not polysiliconport then
			success, Error = pcall(GetPartFromPort, i, "Polysilicon")
			if success then
				if GetPartFromPort(i, "Polysilicon") then
					polysiliconport = GetPort(i)
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

function commandline.new(screen)
	local position = UDim2.new(0,0,0,0)

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


local name = "Bootloader"

if not screen then screen = regularscreen end

if microcontroller then
	local polyports = GetPartsFromPort(microcontroller, "Port")
	local polyport

	for i, val in ipairs(polyports) do
		if GetPartFromPort(val, "Polysilicon") then
			polyport = val
		end
	end

	if polyport then
		local poly = GetPartFromPort(polyport, "Polysilicon")

		if poly then
			poly:Configure({PolysiliconMode = 1})

			TriggerPort(polyport)
		end
	end
end

local function loadmicro(micro, text, lines)
	if micro then
		micro:Configure({Code = tostring(text)})

		local polyports = GetPartsFromPort(micro, "Port")
		local polyport

		for i, val in ipairs(polyports) do
			if GetPartFromPort(val, "Polysilicon") then
				polyport = val
			end
		end

		if polyport then
			local poly = GetPartFromPort(polyport, "Polysilicon")

			if poly then
				poly:Configure({PolysiliconMode = 1})

				TriggerPort(polyport)

				poly:Configure({PolysiliconMode = 0})

				TriggerPort(polyport)

				poly:Configure({PolysiliconMode = 1})

				screen:ClearElements()

				if polysiliconport then

					TriggerPort(polysiliconport)

				end

			else
				lines.insert("No polysilicon attached to the port of the found microcontroller.")
			end
		else
			lines.insert("No port attached to the found microcontroller or no polysilicon attached to that found port.")
		end
	else
		lines.insert("No microcontroller was found.")
	end
end

local function boot()

	if screen then

		screen:ClearElements()

		local lines, background = commandline.new(screen)

		lines.insert("Welcome to "..name)

		Beep(1)

		task.wait(1)
	
		if disk then

			local function filecreator()
				lines.insert("Enter file name")

				local name = ""
				local data = ""

				func = function(text)
					name = text:gsub("\n", "")

					if name == "" then return end

					lines.insert(name)

					lines.insert("Enter file data")

					func = function(text)
						data = text

						lines.insert(data:gsub("\n", ""))

						if text:gsub("\n", "") == "" then return end

						lines.insert("Save? (Y/N)")

						func = function(text)
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

			local function filedeletor()
				lines.insert("Enter file name")

				local name = ""
				local data = ""

				func = function(text)
					name = text:gsub("\n", "")

					if name == "" then return end

					lines.insert(name)

					lines.insert("Delete? (Y/N)")

					func = function(text)
						local gsubed = text:gsub("\n", "")
						lines.insert(gsubed)

						if gsubed:lower() ~= "y" and gsubed:lower() ~= "n" then
							lines.insert("Delete? (Y/N)")
						elseif gsubed:lower() == "n" then
							boot()
						elseif gsubed:lower() == "y" then
							if name ~= "" then
								if disk then
									if not disk:Read("Boot") then
										disk:Write("Boot", {})
									end

									createfileontable(disk, name, nil, "/Boot")

									boot()
								else
									lines.insert("No disk was found.")
								end
							else
								lines.insert("No name was specified.")
								task.wait(1)
								boot()
							end
						end
					end
				end
			end

			function bootcreate()
				lines.insert("Would you like to create a bootable file? (Y/N)")

				func = function(text)
					local gsubed = text:gsub("\n", "")
					lines.insert(gsubed)

					if gsubed:lower() ~= "y" and gsubed:lower() ~= "n" then
						bootcreate()
					elseif gsubed:lower() == "y" then
						filecreator()
					elseif gsubed:lower() == "n" then
						boot()
					end
				end
			end

			local allbootable = disk:Read("Boot")

			if allbootable then

				local amount = 0

				local codes = {}

				for name, data in pairs(allbootable) do
					amount += 1
					lines.insert(amount)
					print(name)
					lines.insert(name)

					codes[amount] = data
				end

				if amount == 0 then
					lines.insert("No bootable file was found.")
					bootcreate()
				else
					lines.insert("Enter file number to boot.")
					lines.insert("Enter createfile to create a bootable file.")
					lines.insert("Enter deletefile to delete a bootable file.")

					func = function(text)
						local text = text:gsub("\n", "")

						lines.insert(text)

						if text:lower() == "createfile" then
							filecreator()
						elseif text:lower() == "deletefile" then
							filedeletor()
						elseif tonumber(text) then
							local code = codes[tonumber(text)]

							if code then
								loadmicro(microcontroller, code, lines)
							else
								lines.insert("Invalid number")
							end
							
						else
							lines.insert("Invalid")
						end
					end
				end

			else

				lines.insert("No bootable file was found.")
				bootcreate()

			end

			if keyboard then

				keyboard:Connect("TextInputted", function(text)
					if func then
						func(text)
					end
				end)

			else
				lines.insert("No keyboard was found.")
			end

		else

			lines.insert("No disk was found.")

		end

	else

		Beep(0.5)

	end

end

boot()
