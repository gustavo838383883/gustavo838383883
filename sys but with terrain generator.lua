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
						local x = ui.AbsolutePosition.X
						local y = ui.AbsolutePosition.Y
						local y_axis = false
						local x_axis = false
						local guiposx = gui.AbsolutePosition.X + gui.AbsoluteSize.X
						local number = ui.AbsoluteSize.X + gui.AbsoluteSize.X

						if x - guiposx >= -number then
							if x - guiposx <= 0 then
								x_axis = true
							end
						end

						local guiposy = gui.AbsolutePosition.Y + gui.AbsoluteSize.Y
						local number2 = ui.AbsoluteSize.Y + gui.AbsoluteSize.Y

						if y - guiposy >= -number2 then
							if y - guiposy <= 0 then
								y_axis = true
							end
						end

						if x_axis and y_axis then
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
						local x = ui.AbsolutePosition.X
						local y = ui.AbsolutePosition.Y
						local y_axis = false
						local x_axis = false
						local guiposx = gui.AbsolutePosition.X + gui.AbsoluteSize.X
						local number = ui.AbsoluteSize.X + gui.AbsoluteSize.X

						if x - guiposx > -number then
							if x - guiposx < 0 then
								x_axis = true
							end
						end

						local guiposy = gui.AbsolutePosition.Y + gui.AbsoluteSize.Y
						local number2 = ui.AbsoluteSize.Y + gui.AbsoluteSize.Y

						if y - guiposy > -number2 then
							if y - guiposy < 0 then
								y_axis = true
							end
						end

						if x_axis and y_axis then
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
							local x = ui.AbsolutePosition.X
							local y = ui.AbsolutePosition.Y
							local y_axis = false
							local x_axis = false

							local guiposy = gui.AbsolutePosition.Y + gui.AbsoluteSize.Y
							local number2 = ui.AbsoluteSize.Y + gui.AbsoluteSize.Y
							local guiposx = gui.AbsolutePosition.X + gui.AbsoluteSize.X
							local number = ui.AbsoluteSize.X + gui.AbsoluteSize.X

							if y - guiposy > -number2 then
								if y - guiposy < 0 then
									y_axis = true
								end
							end

							if x - guiposx > -number then
								if x - guiposx < 0 then
									x_axis = true
								end
							end

							if y_axis and x_axis then
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
							local x = ui.AbsolutePosition.X
							local y = ui.AbsolutePosition.Y
							local y_axis = false
							local x_axis = false

							local guiposy = gui.AbsolutePosition.Y + gui.AbsoluteSize.Y
							local number2 = ui.AbsoluteSize.Y + gui.AbsoluteSize.Y
							local guiposx = gui.AbsolutePosition.X + gui.AbsoluteSize.X
							local number = ui.AbsoluteSize.X + gui.AbsoluteSize.X

							if y - guiposy >= -number2 then
								if y - guiposy <= 0 then
									y_axis = true
								end
							end

							if x - guiposx >= -number then
								if x - guiposx <= 0 then
									x_axis = true
								end
							end

							if y_axis and x_axis then
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

local disk = GetPartFromPort(1, "Disk")
local gputer = disk:Read("GD7Library")()
local screen = gputer.Screen
local keyboard = gputer.Keyboard
local speaker = gputer.Speaker

local window, holderframe, closebutton, maximizebutton, textlabel, resizebutton, minimizebutton, functions = gputer.CreateWindow(UDim2.fromScale(0.7, 0.7), "Super Yellow Square Terrain Generator", false, false, false, "SYSTG", false)

local superyellowsquare = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=11693968379"})

window:AddChild(superyellowsquare )

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

local loadingframe = screen:CreateElement("ImageLabel", {Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0), Image = "rbxassetid://15440219329", ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0.2, 0, 0.2, 0)})
window:AddChild(loadingframe)

local loadingbar = screen:CreateElement("Frame", {Position = UDim2.new(0, 0, 0.4, 0), Size = UDim2.new(0, 0, 0.2, 0)})
loadingframe:AddChild(loadingbar)

local loadingcircle = screen:CreateElement("ImageLabel", {Image = "rbxassetid://8932511161", Size = UDim2.new(0.15, 0, 0.15, 0), Position = UDim2.new(0.85, 0, 0.85, 0), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit})

loadingframe:AddChild(loadingcircle)

local start = 0
local y = 25

local lavas = {}
local prevlava = 0

for i=1, 256 do
	task.wait()
	local grass = screen:CreateElement("ImageLabel", {Image = "rbxassetid://11693507606", Size = UDim2.new(0, 25, 0, 25), Position = UDim2.new(0, start, 0, y), BackgroundTransparency = 1})

	local randomnumber = math.random(1, 9)
	ground:AddChild(grass)
	
	loadingbar.Size = UDim2.new(i/256, 0, 0.2, 0)

	loadingcircle.Rotation += 5
	
	if randomnumber == 4 then
		y -= 25
	elseif randomnumber == 9 then
		if y <= 125 then
			y += 25
		end
	end

	table.insert(allobjects, grass)

	prevlava += 1

	if math.random(1, 20) == 20 and (randomnumber ~= 4 and randomnumber ~= 9) and prevlava > 2 then
		local lava = screen:CreateElement("ImageLabel", {Image = "rbxassetid://13289036106", Size = UDim2.new(0, 25, 0, 10), Position = UDim2.new(0, start, 0, y - 20), BackgroundTransparency = 1})

		lava.Size = UDim2.fromOffset(25, 15)

		ground:AddChild(lava)

		prevlava = 0

		lava.Position += UDim2.fromOffset(0, 10)

		table.insert(lavas, lava)
	end

	start += 25
	print(i)
end

loadingframe:Destroy()

local rightnum = 0
local leftnum = 0
local downnum = 0
local right = false
local left = false

keyboard:Connect("KeyPressed", function(key, keystring, state)
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
			hitbox.Position -= UDim2.new(0, 0, 0, 6)
			if not GetCollidedGuiObjects(hitbox, allobjects) then
				hitbox.Position += UDim2.new(0, 0, 0, 6)
				for i=1,13,1 do
					task.wait()
					hitbox.Position -= UDim2.new(0, 0, 0, 6)	
					if not GetCollidedGuiObjects(hitbox, allobjects) then
						hitbox.Position += UDim2.new(0, 0, 0, 6)	
						thegame.Position += UDim2.new(0, 0, 0, 6)
						plr.Position -= UDim2.new(0, 0, 0, 6)
					else
						hitbox.Position += UDim2.new(0, 0, 0, 6)	
						break
					end
				end
			else
				hitbox.Position += UDim2.new(0, 0, 0, 6)
			end
		end
	end
end)

local positionxcounter = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0.2, 0, 0.2, 0)})
local positionycounter = screen:CreateElement("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0.2, 0, 0.2, 0), Position = UDim2.new(0.2, 0, 0, 0)})

window:AddChild(positionxcounter)

window:AddChild(positionycounter)

coroutine.resume(coroutine.create(function()
while task.wait(0.01) do
	if functions:IsClosed() then break end

	positionxcounter.Text = plr.Position.X.Offset
	positionycounter.Text = plr.Position.Y.Offset
	
	if GetCollidedGuiObjects(hitbox, lavas) then
		plr.Position = UDim2.new(0,0,0,0)
		thegame.Position = UDim2.new(0.5, -25, 0.5, -25)
		speaker:PlaySound("rbxassetid://3802269741")
	end
	
	if plr.Position.Y.Offset > 150 then
		plr.Position = UDim2.new(0,0,0,0)
		thegame.Position = UDim2.new(0.5, -25, 0.5, -25)
		speaker:PlaySound("rbxassetid://3802269741")
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

	if functions:IsClosed() then break end

	hitbox.Position += UDim2.new(0, 0, 0, 2)
	if not DetectGuiBelow(hitbox, allobjects) then
		plr.Position += UDim2.new(0, 0, 0, 2)
		thegame.Position -= UDim2.new(0, 0, 0, 2)
		hitbox.Position -= UDim2.new(0, 0, 0, 2)
	else
		hitbox.Position -= UDim2.new(0, 0, 0, 2)
	end
end
end))
