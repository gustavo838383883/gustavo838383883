
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
		success, error = pcall(GetPartFromPort, i, "Disk")
		if success then
			if GetPartFromPort(i, "Disk") then
				disk = GetPartFromPort(i, "Disk")
			end
		end
	end
	if not speaker then
		success, error = pcall(GetPartFromPort, i, "Speaker")
		if success then
			if GetPartFromPort(i, "Speaker") then
				speaker = GetPartFromPort(i, "Speaker")
			end
		end
	end
	if not screen then
		success, error = pcall(GetPartFromPort, i, "Screen")
		if success then
			if GetPartFromPort(i, "Screen") then
				screen = GetPartFromPort(i, "Screen")
			end
		end
	end
	if not screen then
		success, error = pcall(GetPartFromPort, i, "TouchScreen")
		if success then
			if GetPartFromPort(i, "TouchScreen") then
				screen = GetPartFromPort(i, "TouchScreen")
			end
		end
	end
	if not keyboard then
		success, error = pcall(GetPartFromPort, i, "Keyboard")
		if success then
			if GetPartFromPort(i, "Keyboard") then
				keyboard = GetPartFromPort(i, "Keyboard")
			end
		end
	end
end

local success, error = pcall(disk:Read, "Color")
if success then
	local color = disk:Read("Color")
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
			startui = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, -25)})
			opendiskreader = screen:CreateElement("TextButton", {Text = "Files", TextScaled = true, Size = UDim2.new(1, 0, 0, 25)})
			opencreatefile = screen:CreateElement("TextButton", {Text = "Create/Overwrite File", TextScaled = true, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0, 25)})
			openchangecolor = screen:CreateElement("TextButton", {Text = "Change Background Color", TextScaled = true, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0, 50)})
			openmediaplayer = screen:CreateElement("TextButton", {Text = "Media Player", TextScaled = true, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0, 75)})
			startui:AddChild(opendiskreader)
			startui:AddChild(opencreatefile)
			startui:AddChild(openchangecolor)
			startui:AddChild(openmediaplayer)

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
				screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, 0), Text = "No keyboard was found."})
			end
		else
			screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, 0), Text = "No speaker was found."})
		end
	else
		screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, 0), Text = "No disk was found."})
	end
else
	print("No screen was found.")
end
if keyboard then
	keyboard:Connect("TextInputted", function(text)
		keyboardinput = text
	end)
end
