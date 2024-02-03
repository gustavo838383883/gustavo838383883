local disk = GetPartFromPort(1, "Disk")

local gputer = disk:Read("GD7Library")

local filesystem = gputer.filesystem
local createnicebutton = gputer.createnicebutton
local explorer = gputer.FileExplorer
local CreateWindow = gputer.CreateWindow

local window, holderframe, closebutton, maximizebutton, textlabel, resizebutton, minimizebutton = CreateWindow(UDim2.fromScale(0.7, 0.7), "Folder to JSON", false, false, false, "Folder to JSON", false, false)

closebutton.Position = UDim2.new(1, -closebutton.Size.X.Offset, 0, 0)
maximizebutton.Position = UDim2.new(1, -(maximizebutton.Size.X.Offset*2), 0, 0)
minimizebutton.Position = UDim2.new(1, -(maximizebutton.Size.X.Offset*3), 0, 0)
textlabel.Position = UDim2.fromScale(0, 0)

local filebutton, text1 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0), "Select table/folder", window)

local directory
local filename

filebutton.MouseButton1Up:Connect(function()
	explorer(dir or "/", function(name, dir)
		text1.Text = name
		filename = name
		directory = dir
	end, true)
end)

local save, text2 = createnicebutton(UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.8), "Save", window)

save.MouseButton1Up:Connect(function()
	if directory and filename then

		if typeof(filesystem.Read(filename, directory)) == "table" then
			text2.Text = tostring(filesystem.Write(filename, JSONEncode(filesystem.Read(filename, directory)), directory))
		else
			local success = pcall(function()
				text2.Text = tostring(filesystem.Write(filename, JSONDecode(filesystem.Read(filename, directory)), directory))
			end)
			if not success then
				text2.Text = "The selected file is not a JSON."
			end
		end

		task.wait(2)
		text2.Text = "Save"
	else
		text2.Text = "No directory table/folder selected."
		task.wait(2)
		text2.Text = "Save"
	end
end)
