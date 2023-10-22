local SpeakerHandler = {
	_LoopedSounds = {},
	_ChatCooldowns = {}, -- Cooldowns of Speaker:Chat
	_SoundCooldowns = {}, -- Sounds played by SpeakerHandler.PlaySound
	DefaultSpeaker = nil,
}

function SpeakerHandler.CreateSound(config: { Id: number, Pitch: number, Length: number, Speaker: any } )
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


	function sound:Destroy()
		table.clear(sound)
	end

	return sound
end

local disk = nil
local screen = nil
local keyboard = nil
local speaker = nil

for i=1, 128 do
	if not disk then
		success, Error = pcall(GetPartFromPort, i, "Disk")
		if success then
			if GetPartFromPort(i, "Disk") then
				disk = GetPartFromPort(i, "Disk")
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

local color = nil
if disk then
	color = disk:Read("Color")
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
end

local keyboardinput = nil
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
					url.Image = "rbxthumb://type=Asset&id="..link.."&w=420&h=420"
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
					url.Image = "rbxthumb://type=Asset&id="..link.."&w=420&h=420"
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

local function woshtmlfile(txt, screen)
	local filegui = screen:CreateElement("Frame", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
	local closebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25), BackgroundColor3 = Color3.new(1,0,0), Text = "Close", TextScaled = true})
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -25), Position = UDim2.new(0, 0, 0, 25), CanvasSize = UDim2.new(0, 0, 1, 0)})
	filegui:AddChild(scrollingframe)
	filegui:AddChild(closebutton)
	closebutton.MouseButton1Down:Connect(function()
		filegui:Destroy()
		filegui = nil
	end)
	StringToGui(screen, txt, scrollingframe)

end


local function readfile(txt, nameondisk)
	local alldata = disk:ReadEntireDisk()
	local filegui = screen:CreateElement("Frame", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
	local closebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25), BackgroundColor3 = Color3.new(1,0,0), Text = "Close", TextScaled = true})
	local deletebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25),Position = UDim2.new(1, -25, 0, 0), Text = "Delete", TextScaled = true})
	local disktext = screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, -25), Position = UDim2.new(0, 0, 0, 25), TextScaled = true, Text = txt})



	filegui:AddChild(disktext)
	filegui:AddChild(closebutton)
	filegui:AddChild(deletebutton)

	closebutton.MouseButton1Down:Connect(function()
		filegui:Destroy()
		filegui = nil
	end)

	deletebutton.MouseButton1Down:Connect(function()
		disk:ClearDisk()
		for name, data in pairs(alldata) do
			if name ~= nameondisk then
				disk:Write(name, data)
			end
		end
		filegui:Destroy()
		filegui = nil
	end)

	if string.find(string.lower(txt), "<woshtml>") then
		woshtmlfile(txt,  screen)
	end
end

local function loaddisk(screen, disk)
	local start = 0
	local holderframe = screen:CreateElement("Frame", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -25), CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0, 25)})
	holderframe:AddChild(scrollingframe)
	local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-25,0,25), Position = UDim2.new(0, 25, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Disk Content"})
	holderframe:AddChild(textlabel)
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(closebutton)

	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
	end)

	for filename, data in pairs(disk:ReadEntireDisk()) do
		if filename ~= "Color" then
			local button = screen:CreateElement("TextButton", {TextScaled = true, Text = filename, Size = UDim2.new(1,0,0,25), Position = UDim2.new(0, 0, 0, start)})
			scrollingframe:AddChild(button)
			scrollingframe.CanvasSize = UDim2.new(0, 0, 0, start + 25)
			start += 25
			button.MouseButton1Down:Connect(function()
				local data = disk:Read(filename)
				readfile(data, filename)
			end)
		end
	end
end

local function writedisk(screen, disk)
	local holderframe = screen:CreateElement("Frame", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
	local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-25,0,25), Position = UDim2.new(0, 25, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Create File"})
	local filenamebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0,25), Position = UDim2.new(0, 0, 0, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "File Name (Click to update)"})
	local filedatabutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0,25), Position = UDim2.new(0, 0, 0, 50), TextXAlignment = Enum.TextXAlignment.Left, Text = "File Data (Click to update)"})
	local createfilebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0,25), Position = UDim2.new(0, 0, 0, 75), TextXAlignment = Enum.TextXAlignment.Left, Text = "Apply"})
	holderframe:AddChild(textlabel)
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(closebutton)
	holderframe:AddChild(filenamebutton)
	holderframe:AddChild(filedatabutton)
	holderframe:AddChild(createfilebutton)


	local data = nil
	local filename = nil

	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
	end)

	filenamebutton.MouseButton1Down:Connect(function()
		if keyboardinput then
			filenamebutton.Text = keyboardinput
			filename = keyboardinput
		end
	end)

	filedatabutton.MouseButton1Down:Connect(function()
		if keyboardinput then
			filedatabutton.Text = keyboardinput
			data = keyboardinput
		end
	end)

	createfilebutton.MouseButton1Down:Connect(function()
		if filenamebutton.Text ~= "File Name (Click to update)" and filename ~= "Color" then
			if filedatabutton.Text ~= "File Data (Click to update)" then
				disk:Write(filename, data)
				createfilebutton.Text = "Success"
			end
		end
	end)
end

local function changecolor(screen, disk)
	local holderframe = screen:CreateElement("Frame", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
	local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-25,0,25), Position = UDim2.new(0, 25, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Change Color"})
	local color = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0,25), Position = UDim2.new(0, 0, 0, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "RGB (Click to update)"})
	local changecolorbutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0,25), Position = UDim2.new(0, 0, 0, 75), TextXAlignment = Enum.TextXAlignment.Left, Text = "Change Color"})
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

	color.MouseButton1Down:Connect(function()
		if keyboardinput then
			color.Text = keyboardinput
			data = keyboardinput
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
				end
			end
		end
	end)
end

local function calculator(screen)
	local holderframe = screen:CreateElement("Frame", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
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
			number1 = tonumber(tostring(number1)..tostring(0))
			part1.Text = number1
		else
			number2 = tonumber(tostring(number2)..tostring(0))
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
			part1.Text = number1 + number2
			number1 = number1 + number2
			part2.Text = ""
			number2 = 0
			part3.Text = ""
			type = nil
		end
		
		if type == "-" then
			part1.Text = number1 - number2
			number1 = number1 - number2
			part2.Text = ""
			number2 = 0
			part3.Text = ""
			type = nil
		end

		if type == "*" then
			part1.Text = number1 * number2
			number1 = number1 * number2
			part2.Text = ""
			number2 = 0
			part3.Text = ""
			type = nil
		end

		if type == "/" then
			part1.Text = number1 / number2
			number1 = number1 / number2
			part2.Text = ""
			number2 = 0
			part3.Text = ""
			type = nil
		end
			
		if type == "√" then
			part1.Text = number2 ^ (1 / number1)
			number1 = number2 ^ (1 / number1)
			part2.Text = ""
			number2 = 0
			part3.Text = ""
			type = nil
		end
			
		if type == "^" then
			part1.Text = number1 ^ number2
			number1 = number1 ^ number2
			part2.Text = ""
			number2 = 0
			part3.Text = ""
			type = nil
		end
	end)
end

local function audioui(screen, disk, data, speaker)
	local holderframe = screen:CreateElement("Frame", {Size = UDim2.new(0.5, 0, 0.5, 0), Active = true, Draggable = true})
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(closebutton)
	local sound = nil


	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
		if sound then
			sound:Stop()
			sound:Destroy()
		end
	end)

	local data = disk:Read(data)
	local pausebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25), Position = UDim2.new(0, 0, 1, -25), Text = "Stop", TextScaled = true})
	holderframe:AddChild(pausebutton)

	sound = SpeakerHandler.CreateSound({
		Id = tonumber(data),
		Pitch = 1,
		Speaker = speaker,
	})
	sound:Play()

	pausebutton.MouseButton1Down:Connect(function()
		if pausebutton.Text == "Stop" then
			pausebutton.Text = "Play"
			sound:Stop()
		else
			pausebutton.Text = "Stop"
			sound:Play()
		end
	end)

end

local function mediaplayer(screen, disk, speaker)
	local holderframe = screen:CreateElement("Frame", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
	local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-25,0,25), Position = UDim2.new(0, 25, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Media Player"})
	local Filename = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0,25), Position = UDim2.new(0, 0, 0, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "File with id (Click to update)"})
	local openimage = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.5,0,0,25), Position = UDim2.new(0, 0, 1, -25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Open as image"})
	local openaudio = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.5,0,0,25), Position = UDim2.new(0.5, 0, 1, -25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Open as audio"})
	holderframe:AddChild(textlabel)
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(openimage)
	holderframe:AddChild(Filename)
	holderframe:AddChild(closebutton)
	holderframe:AddChild(openaudio)


	local data = nil
	local filename = nil

	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
	end)

	Filename.MouseButton1Down:Connect(function()
		if keyboardinput then
			Filename.Text = keyboardinput
			data = keyboardinput
		end
	end)

	openaudio.MouseButton1Down:Connect(function()
		if Filename.Text ~= "File with id (Click to update)" then
			audioui(screen, disk, data, speaker)
		end
	end)

	openimage.MouseButton1Down:Connect(function()
		if Filename.Text ~= "File with id (Click to update)" then
			local data = disk:Read(data)
			local holderframe = screen:CreateElement("Frame", {Size = UDim2.new(0.5, 0, 0.5, 0), Active = true, Draggable = true})
			local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
			holderframe:AddChild(closebutton)
			closebutton.MouseButton1Down:Connect(function()
				holderframe:Destroy()
				holderframe = nil
			end)
			local imageframe = screen:CreateElement("ImageLabel", {Size = UDim2.new(1, 0, 1, -25), Position = UDim2.new(0, 0, 0, 25), BackgroundTransparency = 1, Image = "rbxassetid://"..data})
			holderframe:AddChild(imageframe)
		end
	end)
end


local function loadmenu(screen, disk)
	local pressed = false
	local startui = nil
	local opendiskreader = nil
	local opencreatefile = nil

	backgroundframe = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = color})
	local startmenu = screen:CreateElement("TextButton", {TextScaled = true, Text = "GustavOS", Size = UDim2.new(0,50,0,25), Position = UDim2.new(0, 0, 1, -25)})

	backgroundframe:AddChild(startmenu)

	startmenu.MouseButton1Down:Connect(function()
		if pressed == true then
			if startui then
				startui:Destroy()
				startui = nil
				pressed = false
			end
		else
			startui = screen:CreateElement("Frame", {Size = UDim2.new(0.3, 0, 0.5, 0), Position = UDim2.new(0, 0, 0.5, -25)})
			local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 4, CanvasSize = UDim2.new(0, 0, 0, 125)})
			opendiskreader = screen:CreateElement("TextButton", {Text = "Files", TextScaled = true, Size = UDim2.new(1, 0, 0, 25)})
			opencreatefile = screen:CreateElement("TextButton", {Text = "Create/Overwrite File", TextScaled = true, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0, 25)})
			local openchangecolor = screen:CreateElement("TextButton", {Text = "Change Background Color", TextScaled = true, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0, 50)})
			local openmediaplayer = screen:CreateElement("TextButton", {Text = "Media Player", TextScaled = true, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0, 75)})
			local opencalculator = screen:CreateElement("TextButton", {Text = "Calculator", TextScaled = true, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0, 100)})
			scrollingframe:AddChild(opendiskreader)
			scrollingframe:AddChild(opencreatefile)
			scrollingframe:AddChild(openchangecolor)
			scrollingframe:AddChild(openmediaplayer)
			scrollingframe:AddChild(opencalculator)
			startui:AddChild(scrollingframe)

			opendiskreader.MouseButton1Down:Connect(function()
				loaddisk(screen, disk)
				startui:Destroy()
				startui = nil
				pressed = false
			end)

			opencreatefile.MouseButton1Down:Connect(function()
				writedisk(screen, disk)
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

			openmediaplayer.MouseButton1Down:Connect(function()
				mediaplayer(screen, disk, speaker)
				startui:Destroy()
				startui = nil
				pressed = false
			end)

			opencalculator.MouseButton1Down:Connect(function()
				calculator(screen)
				startui:Destroy()
				startui = nil
				pressed = false
			end)
			pressed = true
		end
	end)
end

if screen then
	if disk then

		if speaker then
			if keyboard then
				loadmenu(screen, disk)
			else
				screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, 0), Text = "No keyboard was found.", TextScaled = true})
				Beep(1)
			end
		else
			screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, 0), Text = "No speaker was found.", TextScaled = true})
			Beep(1)
		end
	else
		screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, 0), Text = "No disk was found.", TextScaled = true})
		Beep(1)
	end
else
	Beep(1)
	print("No screen was found.")
end
if keyboard then
	keyboard:Connect("TextInputted", function(text)
		keyboardinput = text
	end)
end
