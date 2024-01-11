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

local gputer = GetPartFromPort(1, "Disk"):Read("GD7Library")
local Modem = gputer.Modem
local programholder1 = gputer.programholder1
local programholder2 = gputer.programholder2
local Screen = gputer.Screen
local Keyboard = gputer.Keyboard
local holding
local holding2
local holderframetouse
local startCursorPos
local uiStartPos
local clicksound = GetPartFromPort(1, "Disk"):Read("ClickSound") or "rbxassetid://6977010128"
if tonumber(clicksound) then clicksound = "rbxassetid://"..clicksound end

function CreateWindow(udim2, title, boolean, boolean2, boolean3, text, boolean4)
	local holderframe = screen:CreateElement("ImageButton", {Size = udim2, BackgroundTransparency = 1, Image = "rbxassetid://8677487226", ImageTransparency = 0.2})
	if not holderframe then return end
	programholder1:AddChild(holderframe)
	local textlabel
	if typeof(title) == "string" then
		textlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1, -(defaultbuttonsize.X*2), 0, defaultbuttonsize.Y), BackgroundTransparency = 1, Position = UDim2.new(0, defaultbuttonsize.X*2, 0, 0), TextScaled = true, TextWrapped = true, Text = tostring(title)})
		holderframe:AddChild(textlabel)
	end
	local window = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1,0,1,-(defaultbuttonsize.Y + (defaultbuttonsize.Y/2))), CanvasSize = UDim2.new(1,0,1,-(defaultbuttonsize.Y + (defaultbuttonsize.Y/2))), Position = UDim2.new(0, 0, 0, defaultbuttonsize.Y), BackgroundTransparency = 1})
	holderframe:AddChild(window)
	local resizebutton
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
			programholder2:AddChild(holderframe)
			programholder1:AddChild(holderframe)
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
			programholder2:AddChild(holderframe)
			programholder1:AddChild(holderframe)
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
		local minimizetext = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "↓"})
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
		
		minimizebutton.MouseButton1Up:Connect(function()
			if holding or holding2 then return end
			speaker:PlaySound(clicksound)
			minimizebutton.Image = "rbxassetid://15617867263"
			window.Visible = false
	                if minimizepressed == false then
	                	unminimizedsize = holderframe.Size
	                	holderframe.Size = UDim2.new(holderframe.Size.X.Scale, holderframe.Size.X.Offset, defaultbuttonsize.Y)
	                	if not boolean2 then
		                        resizebutton.Visible = false
		                        resizebutton.ImageTransparency = 1
		                        resizebutton.Size = UDim2.new(0,0,0,0)
		                        window.Size += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
		                        window.CanvasSize += UDim2.fromOffset(0, defaultbuttonsize.Y/2)
		        	end
	                else
	                    holderframe.Size = unminimizedsize
	                    if not boolean2 then
	                        resizebutton.Visible = true
	                        resizebutton.ImageTransparency = 0
	                        resizebutton.Size = UDim2.fromOffset(defaultbuttonsize.Y/2, defaultbuttonsize.Y/2)
	                        window.Size -= UDim2.fromOffset(0, defaultbuttonsize.Y/2)
	                        window.CanvasSize -= UDim2.fromOffset(0, defaultbuttonsize.Y/2)
	                    end
	                end
			window.Visible = not wimdow.Visible
	                minimizepressed = not minimizepressed
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

defaultbuttonsize = Vector2.new(screen:GetDimensions().X*0.14, screen:GetDimensions().Y*0.1)
if defaultbuttonsize.X > 35 then defaultbuttonsize = Vector2.new(35, defaultbuttonsize.Y); end
if defaultbuttonsize.Y > 25 then defaultbuttonsize = Vector2.new(defaultbuttonsize.X, 25); end

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
			if not holderframetouse then return end
			local cursors = screen:GetCursors()
			local cursor
			local success = false
			for index,cur in pairs(cursors) do
				if startCursorPos and cur then
					if cur.Player == startCursorPos.Player then
						cursor = cur
						success = true
					end
				end
			end
			if not success then holding = false end
			if cursor then
				local newX = (cursor.X - holderframetouse.AbsolutePosition.X) +5
				local newY = (cursor.Y - holderframetouse.AbsolutePosition.Y) +5
				local screenresolution = resolutionframe.AbsoluteSize
	
				if typeof(cursor["X"]) == "number" and typeof(cursor["Y"]) == "number" and typeof(screenresolution["X"]) == "number" and typeof(screenresolution["Y"]) == "number" and typeof(startCursorPos["X"]) == "number" and typeof(startCursorPos["Y"]) == "number" then
					if newX < 135 then newX = 135 end
					if newY < 100 then newY = 100 end
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
