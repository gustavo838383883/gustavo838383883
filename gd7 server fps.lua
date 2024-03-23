local prevCursorPos
local uiStartPos
local minimizedprograms = {}
local defaultbuttonsize = Vector2.new(0,0)

local function getCursorColliding(X, Y, ui)
	if X and Y and ui then else return end
	local x = ui.AbsolutePosition.X
	local y = ui.AbsolutePosition.Y
	local y_axis = nil
	local x_axis = nil
	local guiposx = X + 5
	local number = ui.AbsoluteSize.X + 5

	if x - guiposx > -number then
		if x - guiposx < 0 then
			x_axis = X - guiposx
		end
	end

	local guiposy = Y + 5
	local number2 = ui.AbsoluteSize.Y + 5

	if y - guiposy > -number2 then
		if y - guiposy < 0 then
			y_axis = y - guiposy
		end
	end

	if x_axis and y_axis then
		return true, x_axis, y_axis
	end
end

local gputer = GetPartFromPort(1, "Disk"):Read("GD7Library") or GetPartFromPort(1, "Disk"):Read("GDOSLibrary") or GetPartFromPort(1, "Disk"):Read("GustavOSLibrary") or {}

if typeof(gputer) == "function" then gputer = gputer() end

local Modem = gputer.Modem or GetPartFromPort(1, "Modem") or GetPartFromPort(2, "Modem")
local Screen = gputer.Screen or GetPartFromPort(1, "TouchScreen") or GetPartFromPort(2, "TouchScreen")
local programholder1 = gputer.programholder1
local programholder2 = gputer.programholder2

local resolutionframe = Screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0)})
local Keyboard = gputer.Keyboard or GetPartFromPort(1, "Keyboard") or GetPartFromPort(2, "Keyboard")
local Speaker = gputer.Speaker or GetPartFromPort(1, "Speaker") or GetPartFromPort(2, "Speaker")
local speaker = Speaker
local Disk = gputer.Disk or GetPartFromPort(1, "Disk") or GetPartFromPort(2, "Disk")
local holding
local holding2
local holderframetouse
local startCursorPos
local uiStartPos
local minerInstance
local clicksound = GetPartFromPort(1, "Disk"):Read("ClickSound") or "rbxassetid://6977010128"
if tonumber(clicksound) then clicksound = "rbxassetid://"..clicksound end
local screen = Screen

function CreateWindow(udim2, title, boolean, boolean2, boolean3, text, boolean4)
	local udim2 = udim2 + UDim2.new(0, 0, 0, defaultbuttonsize.Y + (defaultbuttonsize.Y/2))
	local holderframe = screen:CreateElement("ImageButton", {ClipsDescendants = true, Size = udim2, BackgroundTransparency = 1, Image = "rbxassetid://8677487226", ImageTransparency = 0.2})
	if not holderframe then return end
	if programholder1 then
	programholder1:AddChild(holderframe)
	end
	if not gputer["Screen"] then
		holderframe.ZIndex = 3
	end
	local textlabel
	if typeof(title) == "string" then
		textlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1, -(defaultbuttonsize.X*2), 0, defaultbuttonsize.Y), BackgroundTransparency = 1, Position = UDim2.new(0, defaultbuttonsize.X*2, 0, 0), TextScaled = true, TextWrapped = true, Text = tostring(title)})
		holderframe:AddChild(textlabel)
	end
	local window = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1,0,1,-(defaultbuttonsize.Y + (defaultbuttonsize.Y/2))), CanvasSize = UDim2.new(1,0,1,-(defaultbuttonsize.Y + (defaultbuttonsize.Y/2))), Position = UDim2.new(0, 0, 0, defaultbuttonsize.Y), BackgroundTransparency = 1})
	holderframe:AddChild(window)
	local resizebutton
	local minimizepressed = false
	local maximizepressed = false
	if not boolean2 then
		resizebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0,defaultbuttonsize.Y/2,0,defaultbuttonsize.Y/2), Image = "rbxassetid://15617867263", Position = UDim2.new(1, -defaultbuttonsize.Y/2, 1, -defaultbuttonsize.Y/2), BackgroundTransparency = 1})
		holderframe:AddChild(resizebutton)

		resizebutton.MouseButton1Down:Connect(function()
			resizebutton.Image = "rbxassetid://15617866125"
			if holding2 then return end
			if not maximizepressed then
				local cursors = screen:GetCursors()
				local cursor
				local x_axis
				local y_axis

				for index,cur in pairs(cursors) do
					local boolean, x_Axis, y_Axis = getCursorColliding(cur.X, cur.Y, holderframe)
					if boolean then
						cursor = cur
						x_axis = x_Axis
						y_axis = y_Axis
						break
					end
				end
				startCursorPos = cursor
				holderframetouse = holderframe
				holding = true
			end
		end)

		resizebutton.MouseButton1Up:Connect(function()
			resizebutton.Image = "rbxassetid://15617867263"
			holding = false
		end)
	else
		window.Size += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
		window.CanvasSize += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
	end

	if not boolean3 then

		holderframe.MouseButton1Down:Connect(function()
			if holding then return end
			if programholder1 and programholder2 then
    			programholder2:AddChild(holderframe)
    			programholder1:AddChild(holderframe)
			end
			if maximizepressed then return end
			local cursors = screen:GetCursors()
			local cursor
			local x_axis
			local y_axis

			for index,cur in pairs(cursors) do
				local boolean, x_Axis, y_Axis = getCursorColliding(cur.X, cur.Y, holderframe)
				if boolean then
					cursor = cur
					x_axis = x_Axis
					y_axis = y_Axis
					break
				end
			end
			startCursorPos = cursor
			uiStartPos = holderframe.Position
			holderframetouse = holderframe
			holding2 = true
		end)

		holderframe.MouseButton1Up:Connect(function()
			holding2 = false
		end)
	else
		holderframe.MouseButton1Down:Connect(function()
		    if programholder1 and programholder2 then
    			programholder2:AddChild(holderframe)
    			programholder1:AddChild(holderframe)
			end
		end)
	end

	local closebutton = screen:CreateElement("ImageButton", {BackgroundTransparency = 1, Size = UDim2.new(0, defaultbuttonsize.X, 0, defaultbuttonsize.Y), BackgroundColor3 = Color3.new(1,0,0), Image = "rbxassetid://15617983488"})
	holderframe:AddChild(closebutton)

	closebutton.MouseButton1Down:Connect(function()
		closebutton.Image = "rbxassetid://15617984474"
	end)

	closebutton.MouseButton1Up:Connect(function()
		closebutton.Image = "rbxassetid://15617983488"
		speaker:PlaySound(clicksound)
		holderframe:Destroy()
		holderframe = nil
	end)

	local maximizebutton
	local minimizebutton

	if not boolean4 then
		minimizebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0,defaultbuttonsize.X,0,defaultbuttonsize.Y), Image = "rbxassetid://15617867263", Position = UDim2.new(0, defaultbuttonsize.X*2, 0, 0), BackgroundTransparency = 1})
		holderframe:AddChild(minimizebutton)
		local minimizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "↑"})
		minimizebutton:AddChild(minimizetext)
		if title then
			if textlabel then
				textlabel.Position += UDim2.new(0, defaultbuttonsize.X, 0, 0)
				textlabel.Size -= UDim2.new(0, defaultbuttonsize.X, 0, 0)
			end
		end
		minimizebutton.MouseButton1Down:Connect(function()
			minimizebutton.Image = "rbxassetid://15617866125"
		end)

		if boolean then
			minimizebutton.Position -= UDim2.new(0, defaultbuttonsize.X, 0, 0)
		end

        local unminimizedsize = UDim2.new(0,0,0,0)

		minimizebutton.MouseButton1Up:Connect(function()
			if holding or holding2 then return end
			speaker:PlaySound(clicksound)
			minimizebutton.Image = "rbxassetid://15617867263"
            if not minimizepressed then
                if not maximizepressed then
                    minimizetext.Text = "↓"
                    window.Visible = false
        	        minimizepressed = true
        	        window.Position = UDim2.new(-1, 0, -1, 0)
                	unminimizedsize = holderframe.Size
                	holderframe.Size = UDim2.new(holderframe.Size.X.Scale, holderframe.Size.X.Offset, 0, defaultbuttonsize.Y)
                	if not boolean2 then
                        resizebutton.Visible = false
                        resizebutton.ImageTransparency = 1
                        resizebutton.Size = UDim2.new(0,0,0,0)
                        window.Size += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
                        window.CanvasSize += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
            	    end
        	    end
            else
                if not maximizepressed then
                    minimizetext.Text = "↑"
                    holderframe.Size = unminimizedsize
                    window.Visible = true
                    window.Position = UDim2.new(0, 0, 0, defaultbuttonsize.Y)
        	        minimizepressed = false
                    if not boolean2 then
                        resizebutton.Visible = true
                        resizebutton.ImageTransparency = 0
                        resizebutton.Size = UDim2.fromOffset(defaultbuttonsize.Y/2, defaultbuttonsize.Y/2)
                        window.Size -= UDim2.fromOffset(0, defaultbuttonsize.Y/2)
                        window.CanvasSize -= UDim2.fromOffset(0, defaultbuttonsize.Y/2)
                    end
                end
            end
		end)
	end

	if not boolean then
		maximizebutton = screen:CreateElement("ImageButton", {Size = UDim2.new(0,defaultbuttonsize.X,0,defaultbuttonsize.Y), Image = "rbxassetid://15617867263", Position = UDim2.new(0, defaultbuttonsize.X, 0, 0), BackgroundTransparency = 1})
		local maximizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "+"})
		maximizebutton:AddChild(maximizetext)

		holderframe:AddChild(maximizebutton)
		local unmaximizedsize = holderframe.Size
		local unmaximizedpos = holderframe.Position

		maximizebutton.MouseButton1Down:Connect(function()
			maximizebutton.Image = "rbxassetid://15617866125"
		end)

		maximizebutton.MouseButton1Up:Connect(function()
			if holding or holding2 then return end
			speaker:PlaySound(clicksound)
			maximizebutton.Image = "rbxassetid://15617867263"
			if minimizepressed then return end
			local holderframe = holderframe
			if not maximizepressed then
				if not boolean2 then
					resizebutton.Visible = false
					resizebutton.ImageTransparency = 1
					resizebutton.Size = UDim2.new(0,0,0,0)
					window.Size += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
					window.CanvasSize += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
				end
				unmaximizedsize = holderframe.Size
				unmaximizedpos = holderframe.Position
				holderframe.Size = UDim2.new(1, 0, 0.9, 0)
				holderframe.Position = UDim2.new(0, 0, 1, 0)
				holderframe.Position = UDim2.new(0, 0, 0, 0)
				maximizetext.Text = "-"
				maximizepressed = true
			else
				if not boolean2 then
					resizebutton.Visible = true
					resizebutton.ImageTransparency = 0
					resizebutton.Size = UDim2.fromOffset(defaultbuttonsize.Y/2, defaultbuttonsize.Y/2)
					window.Size -= UDim2.fromOffset(0, defaultbuttonsize.Y/2)
					window.CanvasSize -= UDim2.fromOffset(0, defaultbuttonsize.Y/2)
				end
				holderframe.Size = unmaximizedsize
				holderframe.Position = unmaximizedpos
				maximizetext.Text = "+"
				maximizepressed = false
			end
		end)
	else
		if textlabel then
			textlabel.Position -= UDim2.new(0, defaultbuttonsize.X, 0, 0)
			textlabel.Size += UDim2.new(0, defaultbuttonsize.X, 0, 0)
		end
	end
	return window, holderframe, closebutton, maximizebutton, textlabel, resizebutton
end

local screen = Screen
local modem = Modem
local disk = Disk
local keyboard = Keyboard

defaultbuttonsize = Vector2.new(Screen:GetDimensions().X*0.14, Screen:GetDimensions().Y*0.1)
if defaultbuttonsize.X > 35 then defaultbuttonsize = Vector2.new(35, defaultbuttonsize.Y); end
if defaultbuttonsize.Y > 25 then defaultbuttonsize = Vector2.new(defaultbuttonsize.X, 25); end

local window

local gputerlength = 0

for i,v in pairs(gputer) do
	gputerlength += 1
end

if gputerlength == 0 and gputer["CreateWindow"] then
	window = CreateWindow(UDim2.new(0.6, 0, 0.6, 0), "Server FPS", false, false, false, nil, false)
else
	window = gputer.CreateWindow(UDim2.new(0.6, 0, 0.6, 0), "Server FPS", false, false, false, "Server FPS", false)
end

local textlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), TextScaled = true, BackgroundTransparency = 1, TextWrapped = true, Text = "nan"})
window:AddChild(textlabel)

coroutine.resume(coroutine.create(function()
    while true do
	task.wait(0.02)
	if screen then
		if holding2 then
			local cursors = screen:GetCursors()
			local cursor
			local x_axis
			local y_axis
			local plr
			if startCursorPos then
				for i,v in pairs(startCursorPos) do
					if i == "Player" then
						plr = v
					end
				end
			end
			if not plr then return end
			for index,cur in pairs(cursors) do
				if not cur["Player"] then return end
				if cur.Player == startCursorPos.Player then
					cursor = cur
					break
				end
			end
			if not cursor then holding2 = false end
			if cursor then
				local screenresolution = resolutionframe.AbsoluteSize
				local startCursorPos = startCursorPos
				if typeof(cursor["X"]) == "number" and typeof(cursor["Y"]) == "number" and typeof(screenresolution["X"]) == "number" and typeof(screenresolution["Y"]) == "number" and typeof(startCursorPos["X"]) == "number" and typeof(startCursorPos["Y"]) == "number" then
					local newX = uiStartPos.X.Scale - (startCursorPos.X - cursor.X)/screenresolution.X
					local newY = uiStartPos.Y.Scale - (startCursorPos.Y - cursor.Y)/screenresolution.Y
					if newY + 0.1 > 0.9 then
						newY = 0.8
					end
					if holderframetouse then
						holderframetouse.Position = UDim2.fromScale(newX, newY)
					end
				end
			end
		end

		if holding then
			if not holderframetouse then holding = false; return end
			local cursors = screen:GetCursors()
			local cursor
			for index,cur in pairs(cursors) do
				if startCursorPos and cur then
					if cur.Player == startCursorPos.Player then
						cursor = cur
					end
				end
			end
			if not cursor then holding = false end
			if cursor then
				local newX = (cursor.X - holderframetouse.AbsolutePosition.X) +((defaultbuttonsize.Y/2)/2)
				local newY = (cursor.Y - holderframetouse.AbsolutePosition.Y) +((defaultbuttonsize.Y/2)/2)
				local screenresolution = resolutionframe.AbsoluteSize
	
				if typeof(cursor["X"]) == "number" and typeof(cursor["Y"]) == "number" and typeof(screenresolution["X"]) == "number" and typeof(screenresolution["Y"]) == "number" and typeof(startCursorPos["X"]) == "number" and typeof(startCursorPos["Y"]) == "number" then
					if newX < defaultbuttonsize.X*4 then newX = defaultbuttonsize.X*4 end
					if newY < defaultbuttonsize.Y*4 then newY = defaultbuttonsize.Y*4 end
					if newX/screenresolution.X > 1 then newX = screenresolution.X end
					if newY/screenresolution.Y > 0.9 then newY = screenresolution.Y * 0.9 end
					if holderframetouse then
						holderframetouse.Size = UDim2.fromScale(newX/screenresolution.X, newY/screenresolution.Y)
					end
				end
			end
		end
	end
  end
end))

while true do
	local timetook = task.wait()
	textlabel.Text = math.floor(1 / timetook)
end
