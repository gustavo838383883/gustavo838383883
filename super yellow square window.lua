local function GetTouchingGuiObjects(gui, folder)

	if gui then
		if not folder then print("Table was not specified.") return end

		if type(folder) ~= "table" then print("The specified table is not a valid table") return end

		if gui.ClassName == "Frame" or gui.ClassName == "ImageLabel" or gui.ClassName == "TextLabel" or gui.ClassName == "TextButton" then
			local instances = {}

			local noinstance = true

			for i, ui in ipairs(folder) do

				if ui.ClassName == "Frame" or ui.ClassName == "ImageLabel" or ui.ClassName == "TextLabel" or ui.ClassName == "TextButton" and ui ~= gui then
					if ui.Visible then
						if ui.AbsolutePosition.X - (gui.AbsolutePosition.X + gui.AbsoluteSize.X) >= -ui.AbsoluteSize.X - gui.AbsoluteSize.X and ui.AbsolutePosition.X - (gui.AbsolutePosition.X + gui.AbsoluteSize.X) <= 0 and ui.AbsolutePosition.Y - (gui.AbsolutePosition.Y + gui.AbsoluteSize.Y) >= -ui.AbsoluteSize.Y - gui.AbsoluteSize.Y and ui.AbsolutePosition.Y - (gui.AbsolutePosition.Y + gui.AbsoluteSize.Y) <= 0 then
							table.insert(instances, ui)
							noinstance = false
						end
					end
				end
			end

			if not noinstance then
				return instances
			else
				return nil
			end

		else
			print(gui, "is not a valid Gui Object.")
		end
	else
		print("The specified instance is not valid.")
	end
end

local function GetCollidedGuiObjects(gui, folder)

	if gui then
		if not folder then print("Table was not specified.") return end

		if type(folder) ~= "table" then print("The specified table is not a valid table") return end

		if gui.ClassName == "Frame" or gui.ClassName == "ImageLabel" or gui.ClassName == "TextLabel" or gui.ClassName == "TextButton" then
			local instances = {}

			local noinstance = true

			for i, ui in ipairs(folder) do

				if ui.ClassName == "Frame" or ui.ClassName == "ImageLabel" or ui.ClassName == "TextLabel" or ui.ClassName == "TextButton" and ui ~= gui then
					if ui.Visible then
						if ui.AbsolutePosition.X - (gui.AbsolutePosition.X + gui.AbsoluteSize.X) > -ui.AbsoluteSize.X - gui.AbsoluteSize.X and ui.AbsolutePosition.X - (gui.AbsolutePosition.X + gui.AbsoluteSize.X) < 0 and ui.AbsolutePosition.Y - (gui.AbsolutePosition.Y + gui.AbsoluteSize.Y) > -ui.AbsoluteSize.Y - gui.AbsoluteSize.Y and ui.AbsolutePosition.Y - (gui.AbsolutePosition.Y + gui.AbsoluteSize.Y) < 0 then
							table.insert(instances, ui)
							noinstance = false
						end
					end
				end
			end

			if not noinstance then
				return instances
			else
				return nil
			end

		else
			print(gui, "is not a valid Gui Object.")
		end
	else
		print("The specified instance is not valid.")
	end
end

local function DetectGuiBelow(gui, folder)
	
	local stop = false
	
	if gui then
		if not folder then print("Table was not specified.") return end

		if type(folder) ~= "table" then print("The specified table is not a valid table") return end

		if gui.ClassName == "Frame" or gui.ClassName == "ImageLabel" or gui.ClassName == "TextLabel" or gui.ClassName == "TextButton" then
			local instance = nil

			local noinstance = true
			
			for i, ui in ipairs(folder) do
				
				if not stop then

					if ui.ClassName == "Frame" or ui.ClassName == "ImageLabel" or ui.ClassName == "TextLabel" or ui.ClassName == "TextButton" and ui ~= gui then
						if ui.Visible then
							if ui.AbsolutePosition.X - (gui.AbsolutePosition.X + gui.AbsoluteSize.X) > -ui.AbsoluteSize.X - gui.AbsoluteSize.X and ui.AbsolutePosition.X - (gui.AbsolutePosition.X + gui.AbsoluteSize.X) < 0 and ui.AbsolutePosition.Y - (gui.AbsolutePosition.Y + gui.AbsoluteSize.Y) > -ui.AbsoluteSize.Y - gui.AbsoluteSize.Y and ui.AbsolutePosition.Y - (gui.AbsolutePosition.Y + gui.AbsoluteSize.Y) < 0 then
								instance = ui
								noinstance = false
								stop = true
							end
						end
					end
				end

			end
			
			return instance

		else
			print(gui, "is not a valid Gui Object.")
		end
	else
		print("The specified instance is not valid.")
	end
end

local function DetectGuiBelow2(gui, folder)

	local stop = false

	if gui then
		if not folder then print("Table was not specified.") return end

		if type(folder) ~= "table" then print("The specified table is not a valid table") return end

		if gui.ClassName == "Frame" or gui.ClassName == "ImageLabel" or gui.ClassName == "TextLabel" or gui.ClassName == "TextButton" then
			local instance = nil

			local noinstance = true

			for i, ui in ipairs(folder) do

				if not stop then

					if ui.ClassName == "Frame" or ui.ClassName == "ImageLabel" or ui.ClassName == "TextLabel" or ui.ClassName == "TextButton" and ui ~= gui then
						if ui.Visible then
							if ui.AbsolutePosition.X - (gui.AbsolutePosition.X + gui.AbsoluteSize.X) >= -ui.AbsoluteSize.X - gui.AbsoluteSize.X and ui.AbsolutePosition.X - (gui.AbsolutePosition.X + gui.AbsoluteSize.X) <= 0 and ui.AbsolutePosition.Y - (gui.AbsolutePosition.Y + gui.AbsoluteSize.Y) >= -ui.AbsoluteSize.Y - gui.AbsoluteSize.Y and ui.AbsolutePosition.Y - (gui.AbsolutePosition.Y + gui.AbsoluteSize.Y) <= 0 then
								instance = ui
								noinstance = false
								stop = true
							end
						end
					end
				end

			end

			return instance

		else
			print(gui, "is not a valid Gui Object.")
		end
	else
		print("The specified instance is not valid.")
	end
end



local disk = nil
local screen = nil
local keyboard = nil
local speaker = nil

local shutdownpoly = nil

local function getstuff()
	disk = nil
	screen = nil
	keyboard = nil
	speaker = nil
	shutdownpoly = nil

	for i=1, 128 do
		if not disk then
			local success, Error = pcall(GetPartFromPort, i, "Disk")
			if success then
				if GetPartFromPort(i, "Disk") then
					disk = GetPartFromPort(i, "Disk")
				end
			end
		end

		if not shutdownpoly then
			local success, Error = pcall(GetPartFromPort, i, "Polysilicon")
			if success then
				if GetPartFromPort(i, "Polysilicon") then
					shutdownpoly = i
				end
			end
		end

		if not speaker then
			local success, Error = pcall(GetPartFromPort, i, "Speaker")
			if success then
				if GetPartFromPort(i, "Speaker") then
					speaker = GetPartFromPort(i, "Speaker")
				end
			end
		end
		if not screen then
			local success, Error = pcall(GetPartFromPort, i, "Screen")
			if success then
				if GetPartFromPort(i, "Screen") then
					screen = GetPartFromPort(i, "Screen")
				end
			end
		end
		if not screen then
			local success, Error = pcall(GetPartFromPort, i, "TouchScreen")
			if success then
				if GetPartFromPort(i, "TouchScreen") then
					screen = GetPartFromPort(i, "TouchScreen")
				end
			end
		end
		if not keyboard then
			local success, Error = pcall(GetPartFromPort, i, "Keyboard")
			if success then
				if GetPartFromPort(i, "Keyboard") then
					keyboard = GetPartFromPort(i, "Keyboard")
				end
			end
		end
	end
end

getstuff()

local keyboardevent = nil

local puter = disk:Read("PuterLibrary")
local window
local scrollingframe
if not puter then
	scrollingframe = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -25), Position = UDim2.new(0, 0, 0, 25), BackgroundTransparency = 1, CanvasSize = UDim2.new(1,0,1,-25)})
	local holderframe = screen:CreateElement("TextButton", {Size = UDim2.new(0.7, 0, 0.7, 0), Active = true, Draggable = true, TextTransparency = 1})
	holderframe:AddChild(scrollingframe)
	local closebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), TextXAlignment = Enum.TextXAlignment.Left, Text = "Close", BackgroundColor3 = Color3.new(1, 0, 0)})
	holderframe:AddChild(closebutton)
	
	closebutton.MouseButton1Down:Connect(function()
		holderframe:Destroy()
		holderframe = nil
		keyboardevent:UnBind()
		keyboardevent = nil
	end)
	
	local maximizebutton = screen:CreateElement("TextButton", {TextScaled = true, Size = UDim2.new(0,25,0,25), Text = "+", Position = UDim2.new(0, 25, 0, 0)})
	local maximizepressed = false
	
	holderframe:AddChild(maximizebutton)
	local unmaximizedsize = holderframe.Size
	maximizebutton.MouseButton1Up:Connect(function()
		local holderframe = holderframe
		if not maximizepressed then
			unmaximizedsize = holderframe.Size
			holderframe.Size = UDim2.new(1, 0, 0.9, 0)
			holderframe:ChangeProperties({Active = false, Draggable = false;})
			holderframe.Position = UDim2.new(0, 0, 1, 0)
			holderframe.Position = UDim2.new(0, 0, 0, 0)
			maximizebutton.Text = "-"
			maximizepressed = true
		else
			holderframe.Size = unmaximizedsize
			holderframe:ChangeProperties({Active = true, Draggable = true;})
			maximizebutton.Text = "+"
			maximizepressed = false
		end
	end)
else
	window = puter.CreateWindow(400, 350, "Super Yellow Square")
end


local superyellowsquare = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=11693968379"})
if not puter then
	scrollingframe:AddChild(superyellowsquare)
else
	window:AddChild(superyellowsquare)
end

local thegame = screen:CreateElement("Frame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Position = UDim2.new(0.5, -12, 0.5, -12)})
superyellowsquare:AddChild(thegame)

local ground = screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0)})
thegame:AddChild(ground)

local players = screen:CreateElement("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0)})
thegame:AddChild(players)

local plr = screen:CreateElement("ImageLabel", {Image = "rbxassetid://11696727579", Size = UDim2.new(0, 25, 0, 25), BackgroundTransparency = 1})
players:AddChild(plr)

local hitbox = screen:CreateElement("ImageLabel", {Image = "rbxassetid://11696727579", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ImageTransparency = 1})
plr:AddChild(hitbox)


local allobjects = {}

local grass1 = screen:CreateElement("ImageLabel", {Size = UDim2.new(0, 450, 0, 25), Image = "http://www.roblox.com/asset/?id=11693507606", BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 120), ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 25, 0, 25)})
ground:AddChild(grass1)
table.insert(allobjects, grass1)

local dirt1 = screen:CreateElement("ImageLabel", {Size = UDim2.new(0, 450, 0, 50), Image = "http://www.roblox.com/asset/?id=14648484477", BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 145), ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 25, 0, 25)})
ground:AddChild(dirt1)
table.insert(allobjects, dirt1)

local dirt2 = screen:CreateElement("ImageLabel", {Size = UDim2.new(0, 50, 0, 25), Image = "http://www.roblox.com/asset/?id=14648484477", BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 95), ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 25, 0, 25)})
ground:AddChild(dirt2)
table.insert(allobjects, dirt2)

local dirt3 = screen:CreateElement("ImageLabel", {Size = UDim2.new(0, 50, 0, 125), Image = "http://www.roblox.com/asset/?id=14648484477", BackgroundTransparency = 1, Position = UDim2.new(0, 250, 0, -30), ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 25, 0, 25)})
ground:AddChild(dirt3)
table.insert(allobjects, dirt3)

local dirt4 = screen:CreateElement("ImageLabel", {Size = UDim2.new(0, 150, 0, 25), Image = "http://www.roblox.com/asset/?id=14648484477", BackgroundTransparency = 1, Position = UDim2.new(0, 275, 0, -30), ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 25, 0, 25)})
ground:AddChild(dirt4)
table.insert(allobjects, dirt4)

local dirt5 = screen:CreateElement("ImageLabel", {Size = UDim2.new(0, 75, 0, 75), Image = "http://www.roblox.com/asset/?id=14648484477", BackgroundTransparency = 1, Position = UDim2.new(0, 350, 0, 45), ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 25, 0, 25)})
ground:AddChild(dirt5)
table.insert(allobjects, dirt5)

local dirt6 = screen:CreateElement("ImageLabel", {Size = UDim2.new(0, 25, 0, 150), Image = "http://www.roblox.com/asset/?id=14648484477", BackgroundTransparency = 1, Position = UDim2.new(0, 425, 0, -30), ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 25, 0, 25)})
ground:AddChild(dirt6)
table.insert(allobjects, dirt6)

local text = screen:CreateElement("TextLabel", {Size = UDim2.new(0, 50, 0, 25), Text = "More coming soon", TextScaled = true, BackgroundTransparency = 1, Position = UDim2.new(0, 375, 0, -5)})
ground:AddChild(text)

local lava1 = screen:CreateElement("ImageLabel", {Size = UDim2.new(0, 15, 0, 10), Image = "http://www.roblox.com/asset/?id=13289036106", BackgroundTransparency = 1, Position = UDim2.new(0, 150, 0, 110), ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 25, 0, 25)})
ground:AddChild(lava1)

local lavas = {}

table.insert(lavas, lava1)

local rightnum = 0
local leftnum = 0
local downnum = 0
local right = false
local left = false

keyboardevent = keyboard:Connect("KeyPressed", function(key, keystring, state)
	if string.lower(keystring) == "d" then
		rightnum += 1
		if left == true then
			leftnum = 0
			left = false
		end
		
		if rightnum == 1 then
			right = true
		else
			rightnum = 0
			right = false
		end
	end
	if string.lower(keystring) == "a" then
		leftnum += 1
		if right == true then
			rightnum = 0
			right = false
		end
		
		if leftnum == 1 then
			left = true
		else
			leftnum = 0
			left = false
		end
	end
	if string.lower(keystring) == "w" then
		if DetectGuiBelow2(hitbox, allobjects) then
			hitbox.Position -= UDim2.new(0, 0, 0, 5)
			if not GetCollidedGuiObjects(hitbox, allobjects) then
				hitbox.Position += UDim2.new(0, 0, 0, 5)
				for i=1,13,1 do
					task.wait()
					hitbox.Position -= UDim2.new(0, 0, 0, 5)	
					if not GetCollidedGuiObjects(hitbox, allobjects) then
						hitbox.Position += UDim2.new(0, 0, 0, 5)	
						thegame.Position += UDim2.new(0, 0, 0, 5)
						plr.Position -= UDim2.new(0, 0, 0, 5)
					else
						hitbox.Position += UDim2.new(0, 0, 0, 5)	
						break
					end
				end
			else
				hitbox.Position += UDim2.new(0, 0, 0, 5)
			end
		end
	end
end)

coroutine.resume(coroutine.create(
	function()
		while task.wait(0.01) do
			if not scrollingframe and not window then break end
			if GetCollidedGuiObjects(hitbox, lavas) then
				plr.Position = UDim2.new(0,0,0,0)
				thegame.Position = UDim2.new(0.5, -25, 0.5, -25)
				speaker:PlaySound("rbxassetid://3802269741")
			end
			
			if plr.Position.Y.Offset > 150 then
				plr.Position = UDim2.new(0,0,0,0)
				thegame.Position = UDim2.new(0.5, -25, 0.5, -25)
			end
			
			
			hitbox.Position += UDim2.new(0, 0, 0, 1)
			if not DetectGuiBelow(hitbox, allobjects) then
				plr.Position += UDim2.new(0, 0, 0, 1)
				thegame.Position -= UDim2.new(0, 0, 0, 1)
				hitbox.Position -= UDim2.new(0, 0, 0, 1)
			else
				hitbox.Position -= UDim2.new(0, 0, 0, 1)
			end
		
			if right == true then
				hitbox.Position += UDim2.new(0, 1, 0, 0)
				if not GetCollidedGuiObjects(hitbox, allobjects) then
					thegame.Position -= UDim2.new(0, 1, 0, 0)
					plr.Position += UDim2.new(0, 1, 0, 0)
					hitbox.Position -= UDim2.new(0, 1, 0, 0)
				else
					hitbox.Position -= UDim2.new(0, 1, 0, 0)
				end
			end
			
			if left == true then
				hitbox.Position -= UDim2.new(0, 1, 0, 0)
				if not GetCollidedGuiObjects(hitbox, allobjects) then
					thegame.Position += UDim2.new(0, 1, 0, 0)
					plr.Position -= UDim2.new(0, 1, 0, 0)
					hitbox.Position += UDim2.new(0, 1, 0, 0)
				else
					hitbox.Position += UDim2.new(0, 1, 0, 0)
				end
			end
		end
	end))
