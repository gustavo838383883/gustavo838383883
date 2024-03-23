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

local function jsontogui(screen, json, parent, boolean1)
	local returnval
	local success = pcall(function() JSONDecode(json) end)
	if not success then
		returnval = nil
	else
		local table1 = JSONDecode(json)
		local name = table1["ClassName"]
		local properties = table1["Properties"]
		local children = table1["Children"]

        if not properties then return end

    	pcall(function()
		    local object = screen:CreateElement(name, {Size = UDim2.new(0,0,0,0)})
			for index, value in pairs(properties) do
			    print(index)
			    print(value)
				local newval = nil
				local json = value
				
				
			   if typeof(json) == "table" then
    				if json["Type"] == "Vector3" then
    					newval = Vector3.new(json["X"], json["Y"], json["Z"])
    				elseif json["Type"] == "Vector2" then
    					newval = Vector2.new(json["X"], json["Y"])
    				elseif json["Type"] == "UDim2" then
    					local x = json["X"]
    					local y = json["Y"]
    					newval = UDim2.new(x["Scale"], x["Offset"], y["Scale"], y["Offset"])
    				elseif json["Type"] == "UDim" then
    					newval = UDim.new(json["Scale"], json["Offset"])
    				elseif json["Type"] == "Color3" then
    					newval = Color3.new(json["R"], json["G"], json["B"])
    				elseif json["Type"] == "Enum" then
    					local val = nil
    					if typeof(json["Enum"]) ~= "string" then return end
    					local split = json["Enum"]:split(".")
    					for index, value in pairs(split) do
    						if index == 2 then
    							val = Enum[value]
    						elseif index >= 3 then
    							val = val[value]
    						end
					    end
    					newval = val
    				else
    					newval = value
    				end
				else
				    newval = value
				end
				object[index] = newval
			end
			returnval = object
			parent:AddChild(object)
			if children and not boolean1 then
				local json = children
				local length = 0
				for i, v in pairs(json) do
					jsontogui(screen, JSONEncode(v), object, false)
				end
			end
		end)
	end 

	return returnval
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
		window = nil
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

local function createnicebutton(udim2, pos, text, Parent)
		local txtbutton = screen:CreateElement("ImageButton", {Size = udim2, Image = "rbxassetid://15625805900", Position = pos, BackgroundTransparency = 1})
		local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(text), RichText = true})
		txtbutton:AddChild(txtlabel)
		if Parent then
			Parent:AddChild(txtbutton)
		end
		txtbutton.MouseButton1Down:Connect(function()
			txtbutton.Image = "rbxassetid://15625805069"
		end)
		txtbutton.MouseButton1Up:Connect(function()
			speaker:PlaySound(clicksound)
			txtbutton.Image = "rbxassetid://15625805900"
		end)
		return txtbutton, txtlabel
	end

	local function createnicebutton2(udim2, pos, text, Parent)
		local txtbutton = screen:CreateElement("ImageButton", {Size = udim2, Image = "rbxassetid://15617867263", Position = pos, BackgroundTransparency = 1})
		local txtlabel = screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = tostring(text), RichText = true})
		txtbutton:AddChild(txtlabel)
		if Parent then
			Parent:AddChild(txtbutton)
		end
		txtbutton.MouseButton1Down:Connect(function()
			txtbutton.Image = "rbxassetid://15617866125"
		end)
		txtbutton.MouseButton1Up:Connect(function()
			speaker:PlaySound(clicksound)
			txtbutton.Image = "rbxassetid://15617867263"
		end)
		return txtbutton, txtlabel
	end

local playerthatinputted
local keyboardinput
local keyboardevent

local function webbrowser()
	local holderframe

	if not gputer["CreateWindow"] then
		holderframe = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Web Browser", false, false, false, "Web Browser", false)
	else
		holderframe = gputer.CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Web Browser", false, false, false, "Web Browser", false)
	end

	local messagesent = nil

	if modem then

		local id = 0

		local idui, idui2 = createnicebutton(UDim2.new(1, 0, 0.1, 0), UDim2.new(0,0,0,0), "Network id", holderframe)

		idui.MouseButton1Up:Connect(function()
			if tonumber(keyboardinput) then
				idui2.Text = tonumber(keyboardinput)
				id = tonumber(keyboardinput)
				modem:Configure({NetworkID = tonumber(keyboardinput)})
			end
		end)

		local text1 = screen:CreateElement("TextLabel", {TextScaled = true, Text = "", Size = UDim2.new(1, 0, 0.8, 0), Position = UDim2.new(0, 0, 0.1, 0), BackgroundTransparency = 1})
		holderframe:AddChild(text1)

		local sendbox, sendbox2 = createnicebutton(UDim2.new(0.6, 0, 0.1, 0), UDim2.new(0.2,0,0.9,0), "Message (Click to update)", holderframe)

		local sendtext = nil
		local player = nil

		sendbox.MouseButton1Up:Connect(function()
			if keyboardinput then
				sendbox2.Text = keyboardinput:gsub("\n", "")
				sendtext = keyboardinput:gsub("\n", "")
				player = playerthatinputted
			end
		end)

		local sendbutton, sendbutton2 = createnicebutton(UDim2.new(0.2, 0, 0.1, 0), UDim2.new(0.8,0,0.9,0), "Send", holderframe)
		local reset = createnicebutton(UDim2.new(0.2, 0, 0.1, 0), UDim2.new(0,0,0.9,0), "Reset", holderframe)

		reset.MouseButton1Up:Connect(function()
			if keyboardevent then keyboardevent:Unbind() end
			keyboardevent = keyboard:Connect("TextInputted", function(text, player)
				keyboardinput = text
				playerthatinputted = player
			end)
		end)

        local send = true

		sendbutton.MouseButton1Up:Connect(function()
		    if not send then return end
			if sendtext then
				local result = {
					["Mode"] = "SendMessage",
					["Text"] = sendtext,
					["Player"] = player
				}
				modem:SendMessage(JSONEncode(result), id)
				sendbutton2.Text = "Sent"
				task.wait(2)
				sendbutton2.Text = "Send"
			end
			send = false
		end)

		messagesent = modem:Connect("MessageSent", function(text)
			print(text)
			if not holderframe then messagesent:Unbind() end
			send = true
			local success = pcall(JSONDecode, text)
			if not success then return end
				
			local table1 = JSONDecode(text)

			if typeof(table1) ~= "table" then return end
			
			local mode = table1["Mode"]
			local texta = table1["Text"] 
			local player1 = table1["Player"]
			
			if mode == "ServerSend" and player1 == player then
				text1.Text = tostring(texta)
				
				local success = pcall(JSONDecode, texta)
				
				if success then
					local window = CreateWindow(UDim2.fromScale(0.7, 0.7), "JSON To Gui", false, false, false, nil, false)

					local table1 = JSONDecode(texta)
                    
                    for index, value in pairs(table1) do
					    jsontogui(screen, JSONEncode(value), window, false)
					end
				end
	    	elseif mode == "ServerSend" and not player1 then
		        text1.Text = tostring(texta)
				
				local success = pcall(JSONDecode, texta)
				
				if success then
					local window = CreateWindow(UDim2.fromScale(0.7, 0.7), "JSON To Gui", false, false, false, nil, false)

                    local table1 = JSONDecode(texta)
                    
                    for index, value in pairs(table1) do
					    jsontogui(screen, JSONEncode(value), window, false)
					end
				end
			end
		end)
	else
		local textlabel = screen:CreateElement("TextLabel", {Text = "You need a modem.", Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
		holderframe:AddChild(textlabel)
	end
end

webbrowser()

keyboardevent = keyboard:Connect("TextInputted", function(text, player)
	keyboardinput = text
	playerthatinputted = player
end)

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
