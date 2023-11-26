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








local disk = GetPartFromPort(1, "Disk")
local screen = GetPartFromPort(2, "Screen")
local keyboard = GetPartFromPort(7, "Keyboard")
local speaker = GetPartFromPort(3, "Speaker")

local color = disk:Read("Color")
if color then
	color = string.split(color, ",")
	color = Color3.new(tonumber(color[1])/255, tonumber(color[2])/255, tonumber(color[3])/255)
else
	color = Color3.new(0, 0, 0)
end

local keyboardinput = nil
local backgroundframe = nil

speaker:ClearSounds()
screen:ClearElements()

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
		if filenamebutton.Text ~= "File Name (Click to update)" and filenamebutton.Text ~= "Color" then
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
			local colordata = string.split(data, ",");
			backgroundframe.BackgroundColor3 = Color3.new(tonumber(colordata[1])/255, tonumber(colordata[2])/255, tonumber(colordata[3])/255)
			changecolorbutton.Text = "Success"
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

loadmenu(screen, disk)

keyboard:Connect("TextInputted", function(text)
	keyboardinput = text
end)
