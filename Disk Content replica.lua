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

local function readfile(txt, nameondisk)
	if not disk then return end
	local alldata = disk:ReadEntireDisk()
	local filegui = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), Active = true})
	local closebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25), BackgroundColor3 = Color3.new(1,0,0), Text = "Close", TextScaled = true})
	--local deletebutton = screen:CreateElement("TextButton", {Size = UDim2.new(0, 25, 0, 25),Position = UDim2.new(1, -25, 0, 0), Text = "Delete", TextScaled = true})
	local disktext = screen:CreateElement("TextLabel", {Size = UDim2.new(1, 0, 1, -25), Position = UDim2.new(0, 0, 0, 25), TextScaled = true, Text = tostring(txt)})
	filegui:AddChild(disktext)
	filegui:AddChild(closebutton)
	--filegui:AddChild(deletebutton)
	closebutton.MouseButton1Down:Connect(function()
		filegui:Destroy()
		filegui = nil
	end)
	
	--deletebutton.MouseButton1Down:Connect(function()
	--	disk:Write(nameondisk, nil)
	--	filegui:Destroy()
	--	filegui = nil
	--end)
end

local function loaddisk(screen, disk)
	if not disk then return end
	local start = 0
	local holderframe = screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), Active = true})
	local scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -25), CanvasSize = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0, 25)})
	holderframe:AddChild(scrollingframe)
	local textlabel = screen:CreateElement("TextLabel", {TextScaled = true, Size = UDim2.new(1,0,0,25), Position = UDim2.new(0, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = "Disk Content"})
	holderframe:AddChild(textlabel)
	
	for filename, data in pairs(disk:ReadEntireDisk()) do
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

if screen then
	screen:ClearElements()
	loaddisk(screen, disk)
else
	Beep(0.5)
end

if keyboard then

	keyboard:Connect("TextInputted", function(text)
		text = text:gsub("\n", ""):gsub("/n\\", "\n")

		local split = text:split(":")

		local command = split[1]
		local data = split[2]
		local filename = split[3]

		if filename and data and command then
			if command == "write" then
				disk:Write(filename, data)
			end
		end
	end)

end
