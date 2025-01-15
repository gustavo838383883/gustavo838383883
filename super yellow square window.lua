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
						if ui.AbsolutePosition.Y - gui.AbsolutePosition.Y + gui.AbsoluteSize.Y >= -ui.AbsoluteSize.Y - gui.AbsoluteSize.Y and ui.AbsolutePosition.Y - gui.AbsolutePosition.Y + gui.AbsoluteSize.Y <= 0 and ui.AbsolutePosition.X - gui.AbsolutePosition.X + gui.AbsoluteSize.X >= -ui.AbsoluteSize.X - gui.AbsoluteSize.X and ui.AbsolutePosition.X - gui.AbsolutePosition.X + gui.AbsoluteSize.X <= 0 then
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
						if ui.AbsolutePosition.Y - gui.AbsolutePosition.Y + gui.AbsoluteSize.Y > -ui.AbsoluteSize.Y - gui.AbsoluteSize.Y and ui.AbsolutePosition.Y - gui.AbsolutePosition.Y + gui.AbsoluteSize.Y <= 0 and ui.AbsolutePosition.X - gui.AbsolutePosition.X + gui.AbsoluteSize.X > -ui.AbsoluteSize.X - gui.AbsoluteSize.X and ui.AbsolutePosition.X - gui.AbsolutePosition.X + gui.AbsoluteSize.X < 0 then
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
							if ui.AbsolutePosition.Y - gui.AbsolutePosition.Y + gui.AbsoluteSize.Y > -ui.AbsoluteSize.Y - gui.AbsoluteSize.Y and ui.AbsolutePosition.Y - gui.AbsolutePosition.Y + gui.AbsoluteSize.Y <= 0 and ui.AbsolutePosition.X - gui.AbsolutePosition.X + gui.AbsoluteSize.X > -ui.AbsoluteSize.X - gui.AbsoluteSize.X and ui.AbsolutePosition.X - gui.AbsolutePosition.X + gui.AbsoluteSize.X < 0 then
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
							if ui.AbsolutePosition.Y - gui.AbsolutePosition.Y + gui.AbsoluteSize.Y >= -ui.AbsoluteSize.Y - gui.AbsoluteSize.Y and ui.AbsolutePosition.Y - gui.AbsolutePosition.Y + gui.AbsoluteSize.Y <= 0 and ui.AbsolutePosition.X - gui.AbsolutePosition.X + gui.AbsoluteSize.X >= -ui.AbsoluteSize.X - gui.AbsoluteSize.X and ui.AbsolutePosition.X - gui.AbsolutePosition.X + gui.AbsoluteSize.X <= 0 then
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
