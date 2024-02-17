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

local function getstuff()
	disk = nil
	screen = nil
	keyboard = nil
	speaker = nil

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
end
getstuff()

local color = Color3.new(0, 0, 0)
local backgroundimage = nil
local backgroundimageframe = nil

if disk then
	color = disk:Read("Color")
	local diskbackgroundimage = disk:Read("BackgroundImage")
	if color then
		color = string.split(color, ",")
		color = Color3.new(tonumber(color[1])/255, tonumber(color[2])/255, tonumber(color[3])/255)
	else
		color = Color3.new(0, 0, 0)
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
local backgroundframe = nil

if speaker then
	speaker:ClearSounds()
end

if screen then
	screen:ClearElements()
end

local function readfile(txt, nameondisk)
	if not disk then return end
	local alldata = disk:ReadEntireDisk()
	local filegui = screen:CreateElement("TextButton", {TextTransparency = 1, Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
	local closebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25), BackgroundColor3 = Color3.new(1,0,0), Text = "Close", TextScaled = true})
	local deletebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25),Position = UDim2.new(1, -25, 0, 0), Text = "Delete", TextScaled = true})
	local disktext = screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, -25), Position = UDim2.new(0, 0, 0, 25), TextScaled = true, Text = tostring(txt)})
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
end
local function loaddisk(screen, disk)
	if not disk then return end
	local start = 0
	local holderframe = screen:CreateElement("TextButton", {TextTransparency = 1, Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
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
	if not disk then return end
	local holderframe = screen:CreateElement("TextButton", {TextTransparency = 1, Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
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
		if filenamebutton.Text ~= "File Name (Click to update)" and filenamebutton.Text ~= "Color" then
			if filedatabutton.Text ~= "File Data (Click to update)" then
				disk:Write(filename, data)
				createfilebutton.Text = "Success"
			end
		end
	end)
end

local function changecolor(screen, disk)
	if not disk then return end
	local holderframe = screen:CreateElement("TextButton", {TextTransparency = 1, Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
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
			backgroundimageframe.Image = ""
			disk:Write("BackgroundImage", nil)
			local colordata = string.split(data, ",");
			backgroundframe.BackgroundColor3 = Color3.new(tonumber(colordata[1])/255, tonumber(colordata[2])/255, tonumber(colordata[3])/255)
			changecolorbutton.Text = "Success"
		end
	end)
end

local function changebackgroundimage(screen, disk)
	if not disk then return end
	local holderframe = screen:CreateElement("TextButton", {TextTransparency = 1, Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
	local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,-25,0,25), Position = UDim2.new(0, 25, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Change Background Image"})
	local id = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0,25), Position = UDim2.new(0, 0, 0, 25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Image ID (Click to update)"})
	local changeimagebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(1,0,0,25), Position = UDim2.new(0, 0, 0, 75), TextXAlignment = Enum.TextXAlignment.Left, Text = "Change Background Image"})
	holderframe:AddChild(textlabel)
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(changeimagebutton)
	holderframe:AddChild(id)
	holderframe:AddChild(closebutton)

	local tiletoggle = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.25,0,0,25), Position = UDim2.new(0, 0, 0, 50), TextXAlignment = Enum.TextXAlignment.Left, Text = "Enable tile"})
	local tilenumber = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0.75,0,0,25), Position = UDim2.new(0.25, 0, 0, 50), TextXAlignment = Enum.TextXAlignment.Left, Text = "UDim2"})
	
	holderframe:AddChild(tiletoggle)
	holderframe:AddChild(tilenumber)

	local tile = false
	local tilenumb = "0.2, 0, 0.2, 0"
	local data = nil
	local filename = nil
	
	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
	end)
	
	id.MouseButton1Down:Connect(function()
		if keyboardinput then
			id.Text = keyboardinput
			data = keyboardinput
		end
	end)

	tiletoggle.MouseButton1Down:Connect(function()
		if tile then
			tile = false
			tiletoggle.Text = "Enable tile"
		else
			tile = true
			tiletoggle.Text = "Disable tile"
		end
	end)

	tilenumber.MouseButton1Down:Connect(function()
		if keyboardinput then
			tilenumber.Text = keyboardinput
			tilenumb = keyboardinput
		end
	end)
	
	changeimagebutton.MouseButton1Down:Connect(function()
		if id.Text ~= "Image ID (Click to update)" then
			if tonumber(data) then
				disk:Write("BackgroundImage", data..","..tostring(tile)..","..tilenumb)
				backgroundimageframe.Image = "rbxthumb://type=Asset&id="..tonumber(data).."&w=420&h=420"
				changeimagebutton.Text = "Success"
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

local function audioui(screen, disk, data, speaker)
	if not speaker or not disk then return end
	local holderframe = screen:CreateElement("TextButton", {TextTransparency = 1, Size = UDim2.new(0.5, 0, 0.5, 0), Active = true, Draggable = true})
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(closebutton)
	local sound = nil


	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
		if sound then
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
	if not disk then return end
	local holderframe = screen:CreateElement("TextButton", {TextTransparency = 1, Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true})
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
		local holderframe = screen:CreateElement("TextButton", {TextTransparency = 1, Size = UDim2.new(0.5, 0, 0.5, 0), Active = true, Draggable = true})
		local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
		holderframe:AddChild(closebutton)

		local image = screen:CreateElement("ImageLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -25), Position = UDim2.new(0, 0, 0, 25), Image = "rbxthumb://type=Asset&id="..tostring(tonumber(disk:Read(data))).."&w=420&h=420"})
		holderframe:AddChild(image)

		closebutton.MouseButton1Down:Connect(function()
			holderframe:Destroy()
		end)
	end)
end


local function loadmenu(screen, disk)
	if not screen then Beep(0.5) return end
	local pressed = false
	local startui = nil
	local opendiskreader = nil
	local opencreatefile = nil
	backgroundframe = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = color})
	backgroundimageframe = screen:CreateElement("ImageLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1})
	backgroundframe:AddChild(backgroundimageframe)
	local startmenu = screen:CreateElement("TextButton", {TextScaled = true, Text = "GustavOS", Size = UDim2.new(0,50,0,25), Position = UDim2.new(0, 0, 1, -25)})

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
			openchangebackgroundimage = screen:CreateElement("TextButton", {Text = "Change Background Image", TextScaled = true, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0, 75)})
			openmediaplayer = screen:CreateElement("TextButton", {Text = "Media Player", TextScaled = true, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0, 100)})
			startui:AddChild(opendiskreader)
			startui:AddChild(opencreatefile)
			startui:AddChild(openchangebackgroundimage)
			startui:AddChild(openchangecolor)
			startui:AddChild(openmediaplayer)
			
			opendiskreader.MouseButton1Down:Connect(function()
				loaddisk(screen, disk)
				startui:Destroy()
				startui = nil
				pressed = false
			end)

			openchangebackgroundimage.MouseButton1Down:Connect(function()
				changebackgroundimage(screen, disk)
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

loadmenu(screen, disk)

if not keyboard then return end

keyboard:Connect("TextInputted", function(text)
	keyboardinput = text:gsub("\n", ""):gsub("/n\\", "\n")
end)
