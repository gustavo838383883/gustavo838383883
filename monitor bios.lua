local ts = GetPart("TouchScreen") or GetPart("Screen")
local speaker = GetPart("Speaker")
local upport = GetPort(1)
local downport = GetPort(2)
local hasvolumecontrol = false

if upport and downport and speaker then
	hasvolumecontrol = true
end

local volumeframe
local volumebar

local function createvolumegui()
	volumeframe = screen:CreateElement("Frame", {BackgroundColor3 = Color3.new(0, 0, 1), Size = UDim2.new(0.5, 0, 0, 25), Position = UDim2.new(0.25, 0, 1, -50)})
	local speakerimage = screen:CreateElement("ImageLabel", {BackgroundTransparency = 1, Image = "rbxassetid://83229244752624", Size = UDim2.fromOffset(25, 25), ResampleMode = Enum.ResamplerMode.Pixelated})
	local minusimage = screen:CreateElement("ImageLabel", {BackgroundTransparency = 1, Image = "rbxassetid://105700715661994", Position = UDim2.fromOffset(25, 0), Size = UDim2.fromOffset(25, 25), ResampleMode = Enum.ResamplerMode.Pixelated})
	local plusimage = screen:CreateElement("ImageLabel", {BackgroundTransparency = 1, Image = "rbxassetid://134501568804650", Position = UDim2.new(1, -25, 0, 0), Size = UDim2.fromOffset(25, 25), ResampleMode = Enum.ResamplerMode.Pixelated})
	local barbackground = screen:CreateElement("Frame", {Size = UDim2.new(1, -75, 0.5, 0), BorderSizePixel = 0, Position = UDim2.new(0, 50, 0.25, 0), BackgroundColor3 = Color3.new(0, 0, 0})
	volumebar = screen:CreateElement("Frame", {Size = UDim2.fromScale(speaker.Volume, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1})
	speakerimage.Parent = volumeframe
	minusimage.Parent = volumeframe
	plusimage.Parent = volumeframe
	barbackground.Parent = volumeframe
	volumebar.Parent = barbackground
end

local pressedtick

local function getportfunction(x)
	return function()
		pressedtick = tick()
		if not volumeframe then
			createvolumegui()
		else
			local newvolume = math.clamp(x + math.floor(speaker.Volume*10)/10, 0, 1)
			speaker.Volume = newvolume
			volumebar.Size = UDim2.fromScale(newvolume, 1)
		end
	end
end

upport.Triggered:Connect(getportfunction(0.1))

downport.Triggered:Connect(getportfunction(-0.1))

local imagelabel = nil
local screencanvas = ts:GetCanvas()
local screensize = ts:GetDimensions()

local function isscreenempty()
	local screencontents = screencanvas:GetDescendants()

	if #screencontents > 1 then
		return false
	elseif #screencontents == 1 and (screencontents[1].ClassName == "ImageLabel" and screencontents[1].Image == "rbxassetid://123464338631816") then
		return true, screencontents[1]
	elseif #screencontents == 1 then
		return false
	end

	return true
end

local xspeed = 5
local yspeed = 5
local maxy = screensize.Y-15.8
local maxx = screensize.X-68
local direction = ""
local translatex = 0
local translatey = 0

if math.random(1, 2) == 1 then
	translatey = -yspeed
	direction = direction.."n"
else
	translatey = yspeed
	direction = direction.."s"
end

if math.random(1, 2) == 1 then
	translatex = -xspeed
	direction = direction.."w"
else
	translatex = xspeed
	direction = direction.."e"
end

local function exists(frame)
	if frame and pcall(function() frame.Name = frame.Name end) then
		return true
	end
	return false
end

local function setlimits(frame)
	if frame.Position.Y.Offset <= 0 then
		if direction == 'nw' then
			direction = 'sw'
		elseif direction == 'ne' then
			direction = 'se'
		end
	elseif frame.Position.Y.Offset >= maxy then
		if direction == 'se' then
			direction = 'ne'
		elseif direction == 'sw' then
			direction = 'nw'
		end
	end
	if frame.Position.X.Offset <= 0 then
		if direction == 'nw' then
			direction = 'ne'
		elseif direction == 'sw' then
			direction = 'se'
		end
	elseif frame.Position.X.Offset >= maxx then
		if direction == 'ne' then
			direction = 'nw'
		elseif direction == 'se' then
			direction = 'sw'
		end
	end
end

local function setdirection(frame)
	setlimits(frame)
	if direction == "se" then
		translatex = xspeed
		translatey = yspeed
	elseif direction == "sw" then
		translatex = -xspeed
		translatey = yspeed
	elseif direction == "ne" then
		translatex = xspeed
		translatey = -yspeed
	elseif direction == "nw" then
		translatex = -xspeed
		translatey = -yspeed
	end
end

local waittime = 1
local main = false
while true do
	if volumeframe then
		if tick() - pressedtick() > 2 then
			volumeframe:Destroy()
			volumeframe = nil
			volumebar = nil
		end
	end
	if main then
		if exists(imagelabel) then
			setdirection(imagelabel)
			imagelabel.Position += UDim2.fromOffset(translatex, translatey)
		end

		local empty = isscreenempty()
		if not empty then
			if exists(imagelabel) then
				imagelabel:Destroy()
			end
			main = false
			waittime = 1
		end
	else
		local empty, e = isscreenempty()
		if empty then
			if exists(e) then e:Destroy() end
			imagelabel = ts:CreateElement("ImageLabel", {ResampleMode = Enum.ResamplerMode.Pixelated, Image = "rbxassetid://123464338631816", Size = UDim2.fromOffset(68, 15.8), BackgroundColor3 = Color3.new(0, 0, 1), Position = UDim2.fromOffset(math.random(0, math.floor(maxx/20))*20, math.random(0, math.floor(maxy/20))*20)})
			main = true
			waittime = 0.25
		end
	end
	task.wait(waittime)
end
