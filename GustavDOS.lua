local function getfileextension(filename, boolean)
	local result = string.match(filename, "%.[%w%p]+%s*$")
	if not result then return end
	result = result:lower()
	local nospace = string.gsub(result, "%s", "")

	if result then
		return boolean and result or nospace
	end
end

local function createfileontable(disk, filename, filedata, directory)
	local returntable = nil
	local directory = directory
	if directory:sub(-1, -1) == "/" then directory = directory:sub(1, -2) end
	local split = string.split(directory, "/")

	if split then
		if split[1] and split[2] then
			local rootfile = disk:Read(split[2])
			local tablez = {
				[1] = rootfile,
			}
			if typeof(rootfile) == "table" then
				local resulttable = rootfile
				if #split >= 3 then
					for i=3,#split,1 do
						if resulttable[split[i]] then
							resulttable = resulttable[split[i]]
							table.insert(tablez, resulttable)
						end
					end
				end
			end
			tablez[#tablez][filename] = filedata

			returntable = rootfile

			disk:Write(split[2], rootfile)
		end
	end
	return returntable
end

local function getfileontable(disk, filename, directory)
	local directory = directory
	if directory:sub(-1, -1) == "/" then directory = directory:sub(1, -2) end
	local split = string.split(directory, "/")
	local file = nil
	if split then
		if split[1] and split[2] then
			local rootfile = disk:Read(split[2])
			local tablez = {
				[1] = rootfile,
			}
			if typeof(rootfile) == "table" then
				local resulttable = rootfile
				if #split >= 3 then
					for i=3,#split,1 do
						if resulttable[split[i]] then
							resulttable = resulttable[split[i]]
							table.insert(tablez, resulttable)
						end
					end
				end
				file = resulttable[filename]
			end
		end
	end
	return file
end

local disks = nil
local screen = nil
local keyboard = nil
local speaker = nil
local modem = nil
local rom = nil
local disk = nil
local microcontrollers = {}
local regularscreen = nil
local keyboardinput
local playerthatinputted
local backgroundimage
local color
local tile = false
local tilesize
local clicksound
local startsound
local shutdownsound
local romport
local disksport
local romindexusing
local sharedport

local CreateWindow

local found, disk1s = pcall(GetPartsFromPort, 1, "Disk")
local putermode = false

if found and #disk1s > 0 then
	for i, disk in disk1s do
		if disk:Read("/") == "t:folder" then
			putermode = true
			print("putermode")
			break
		end
	end
end

local function getstuff()
	disks = nil
	rom = nil
	disk = nil
	screen = nil
	keyboard = nil
	speaker = nil
	modem = nil
	regularscreen = nil
	disksport = nil
	romport = nil
	romindexusing = nil
	sharedport = nil

	local previ = 0
	for i=0, 64 do
		if not GetPort(i) then
			continue
		end
		if i - previ > 5 then
			previ = i
			task.wait(0.1)
		end
		if not rom then
			if (putermode and i ~= 1) or not putermode then
				local temprom = GetPartFromPort(i, "Disk")
				if temprom then
					if #temprom:ReadAll() == 0 then
						rom = temprom
						romport = i
					elseif temprom:Read("SysDisk") then
						rom = temprom
						romport = i
					end
				end
			end
		end
		if not disks then
			if (putermode and i == 1) or not putermode then
				local disktable = GetPartsFromPort(i, "Disk")
				if disktable then
					if #disktable > 0 then
						local cancel = false
						local tempport = GetPartFromPort(i, "Port")
						if tempport and tempport.PortID == romport then
							cancel = true
						end
						if romport == i and #disktable == 1 then
							cancel = true
						end
						if not cancel then
							disks = disktable
							disksport = i
						end
					end
				end
			end
		end

		if disks and #disks > 1 and romport == disksport and not sharedport then
			for index,v in ipairs(disks) do
				if v then
					if #v:ReadAll() == 0 then
						rom = v
						romport = i
						romindexusing = index
						sharedport = true
						break
					elseif v:Read("SysDisk") then
						rom = v
						romindexusing = index
						romport = i
						sharedport = true
						break
					end
				end
			end
		end

		if not modem then
			local tempmodem = GetPartFromPort(i, "Modem")
			if tempmodem then
				modem = tempmodem
			end
		end

		if not speaker then
			local tempspeaker = GetPartFromPort(i, "Speaker")
			if tempspeaker then
				speaker = tempspeaker
			end
		end
		if not screen then
			local tempscreen = GetPartFromPort(i, "TouchScreen")
			if tempscreen then
				screen = tempscreen
			end
		end
		if not regularscreen then
			local tempscreen = GetPartFromPort(i, "Screen")
			if tempscreen then
				regularscreen = tempscreen
			end
		end
		if not keyboard then
			local tempkeyboard = GetPartFromPort(i, "Keyboard")
			if tempkeyboard then
				keyboard = tempkeyboard
			end
		end
	end
end
getstuff()
local commandline = {}

local position = UDim2.new(0,0,0,0)
local richtext = false

function commandline.new(scr)
	local screen = scr or screen
	local background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0), ScrollBarThickness = 5})
	local lines = {
		number = UDim2.new(0,0,0,0)
	}
	local biggesttextx = 0

	function lines.clear()
		pcall(function()
			background:Destroy()
			background = screen:CreateElement("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0,0,0), ScrollBarThickness = 5})
		end)
		lines.number = UDim2.new(0,0,0,0)
		biggesttextx = 0
	end

	function lines.insert(text, vec2, dontscroll)
		print(text)
		local textlabel = screen:CreateElement("TextBox", {ClearTextOnFocus = false, TextEditable = false, BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Text = tonumber(text) or tostring(text):gsub("\n", ""), RichText = (richtext or function() return false end)(), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Position = lines.number})
		if textlabel then
			textlabel.Size = UDim2.new(0, math.max(textlabel.TextBounds.X, textlabel.TextSize), 0, textlabel.TextSize)
			if textlabel.TextBounds.X > biggesttextx then
				biggesttextx = textlabel.TextBounds.X
			end
			textlabel.Parent = background
			background.CanvasSize = UDim2.new(0, biggesttextx, 0, math.max(background.AbsoluteSize.Y, lines.number.Y.Offset + textlabel.TextSize))
			if typeof(vec2) == "UDim2" then
				vec2 = Vector2.new(vec2.X.Offset + vec2.X.Scale*background.AbsoluteSize.X, vec2.Y.Offset + vec2.Y.Scale*background.AbsoluteSize.Y)
			end
			if typeof(vec2) == "Vector2" then
				textlabel.Size = UDim2.fromOffset(vec2.X, vec2.Y)
				local newsizex = if vec2.X > biggesttextx then vec2.X else 0
				background.CanvasSize -= UDim2.fromOffset(newsizex, math.max(textlabel.TextBounds.Y, textlabel.TextSize))
				background.CanvasSize += UDim2.new(0, newsizex, 0, vec2.Y)
				if vec2.X > background.AbsoluteSize.X then
					background.CanvasSize += UDim2.new(0, vec2.X - background.AbsoluteSize.X, 0, 0)
				end
				lines.number -= UDim2.new(0,0,0,math.max(textlabel.TextBounds.Y, textlabel.TextSize))
				lines.number += UDim2.new(0, 0, vec2.Y, vec2.Y)
			end
			lines.number += UDim2.new(0, 0, 0, math.max(textlabel.TextBounds.Y, textlabel.TextSize))
			if not dontscroll then
				background.CanvasPosition = Vector2.new(0, lines.number.Y)
			end
		end
		return textlabel
	end
	return lines, setmetatable({}, {
		__index = function(t, a)
			return background[a]
		end,
		__newindex = function(t, a, b)
			background[a] = b
		end,
		__metatable = "This metatable is locked."
	})
end

local filesystem = {
	Write = function(filename, filedata, directory, cd)
		local disk = cd or disk
		local directory = directory or "/"
		local dir = directory
		local value = "No filename or filedata specified"
		if filename then
			local split = nil
			local returntable = nil
			if directory ~= "" then
				split = string.split(dir, "/")
			end
			if not split or split[2] == "" then
				disk:Write(filename, filedata)
			else
				returntable = createfileontable(disk, filename, filedata, dir)
			end
			if not split or split[2] == "" then
				if disk:Read(filename) == filedata then
					value = "Success i think"
				else
					value = "Failed"
				end
			else
				if disk:Read(split[2]) == returntable and disk:Read(split[2]) then
					value = "Success i think"
				else
					value = "Failed i think"
				end
			end
		else
			value = "No filename specified"
		end
		return value
	end,
	Read = function(filename, directory, boolean1, cd)
		local disk = cd or disk
		local directory = directory or "/"
		local dir = directory
		local value = if boolean1 then nil else "No filename specified"
		if filename and filename ~= "" then
			local split = nil
			if dir ~= "" then
				split = string.split(dir, "/")
			end
			if not split or split[2] == "" then
				local output = disk:Read(filename)
				value = output
				print(output)
			else
				local output = getfileontable(disk, filename, dir)
				value = output
				print(output)
			end
		else
			value = if boolean1 then nil else "No filename specified"
		end
		return value
	end,
}

local name = "GustavDOS"

local keyboardevent
local runtext

-- gui file stuff
local loadtext

local function converttostring(value)
	return value:gsub("_quote_", '"'):gsub("_higher_", ">"):gsub("_lower_", "<")
end

local function strtoimg(str)
	if str and (str:sub(1, 13) == "rbxassetid://" or str:sub(1, 11) == "rbxassetid://") then
		return str
	else
		return str and (tonumber(str) and "rbxthumb://type=Asset&id="..tonumber(str).."&w=420&h=420" or "rbxthumb://type=Asset&id="..tonumber(string.match(str, "%d+")).."&w=420&h=420") or "http://www.roblox.com/asset/?id=8552847009"
	end
end

local function strtoasset(str)
	if str and (str:sub(1, 13) == "rbxassetid://" or str:sub(1, 11) == "rbxassetid://") then
		return str
	else
		return `rbxassetid://{tonumber(str) or 0}`
	end
end

local function addbuttonscript(values, obj, page, scrollingframe, title)
	if values and values.href then
		local split = tostring(values.href):split("/")
		local file = split[#split]
		local dir = ""

		local cd = disks[1]

		if tonumber(split[1]) then
			cd = disks[tonumber(split[1])]
		end

		for index, value in ipairs(split) do
			if index < #split and index > 1 then
				dir = dir.."/"..value
			end
		end

		local data1 = filesystem.Read(file, if dir == "" then "/" else dir, true, cd)

		if dir == "" and file == "" then
			data1 = cd:ReadAll()
		end

		obj.MouseButton1Up:Connect(function()
			local fileextension = getfileextension(tostring(file))
			if typeof(data1) == "string" and fileextension == ".gui" then
				if title then
					title.Text = string.sub(tostring(file), 1, -#fileextension - 1)
				end
				loadtext(data1, page, scrollingframe, title)
			else
				disk = cd
				runtext("dir "..dir)
				runtext(tostring(file))
			end
		end)

		obj.MouseButton2Up:Connect(function()
			disk = cd
			runtext("dir "..dir)
			runtext(tostring(file))
		end)
	end
end

local enumitems = {
	AutomaticSize = {},
	ButtonStyle = {},
	ScrollingDirection = {},
	ElasticBehavior = {},
	ScrollBarInset = {},
	VerticalScrollBarPosition = {},
	AspectType = {},
	DominantAxis = {},
	ApplyStrokeMode = {},
	LineJoinMode = {},
	Font = {},
	TextXAlignment = {},
	TextYAlignment = {}
}

for enumname, dict in enumitems do
	for i, v in Enum[enumname]:GetEnumItems() do
		dict[v.Name:lower()] = v
	end
end

local defaultproperties = {
	backimg = {
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(0, 256, 0, 256),
		Size = UDim2.new(1, 0, 1, 0),
		Name = "backimg"
	},
	frame = {
		Size = UDim2.new(0, 50, 0, 50),
		BorderSizePixel = 0,
	},
	scrollframe = {
		Size = UDim2.new(0, 50, 0, 50),
		BorderSizePixel = 0,
	},
	img = {
		Size = UDim2.new(0, 50, 0, 50),
		BackgroundTransparency = 1
	},
	txt = {
		Size = UDim2.new(0, 250, 0, 50),
		TextScaled = true,
		TextWrapped = true,
		BackgroundTransparency = 1,
		TextEditable = false,
		ClearTextOnFocus = false
	},
	button = {
		Size = UDim2.new(0, 250, 0, 50),
		TextScaled = true,
		TextWrapped = true,
		BorderSizePixel = 0
	},
	imagebutton = {
		Size = UDim2.new(0, 50, 0, 50),
		BackgroundTransparency = 1
	}
}

local guiobjectproperties = {
	all = {
		rotation = "Rotation",
		position = "Position",
		size = "Size",
		anchorpoint = "AnchorPoint",
		automaticsize = "AutomaticSize",
		zindex = "ZIndex",
		name = "Name"
	},
	UICorner = {
		radius = "CornerRadius"
	},
	UIScale = {
		scale = "Scale"
	},
	UISizeConstraint = {
		maxsize = "MaxSize",
		minsize = "MinSize"
	},
	UIAspectRatioConstraint = {
		aspectratio = "AspectRatio",
		aspecttype = "AspectType",
		dominantaxis = "DominantAxis"
	},
	UIPadding = {
		bottom = "PaddingBottom",
		top = "PaddingTop",
		right = "PaddingRight",
		left = "PaddingLeft"
	},
	UIStroke = {
		applystrokemode = "ApplyStrokeMode",
		color = "Color",
		linejoinmode = "LineJoinMode",
		thickness = "Thickness",
		transparency = "Transparency",
		enabled = "Enabled"
	},
	UITextSizeConstraint = {
		maxsize = "MaxTextSize",
		minsize = "MinTextSize"
	},
	Frame = {
		transparency = "BackgroundTransparency",
		color = "BackgroundColor3",
		bordersize = "BorderSizePixel",
		bordercolor = "BorderColor3"
	},
	ScrollingFrame = {
		transparency = "BackgroundTransparency",
		color = "BackgroundColor3",
		bordersize = "BorderSizePixel",
		bordercolor = "BorderColor3",
		canvassize = "CanvasSize",
		canvasposition = "CanvasPosition",
		automaticcanvassize = "AutomaticSize",
		scrollingdirection = "ScrollingDirection",
		scrollbarthickness = "ScrollBarThickness",
		scrollingenabled = "ScrollingEnabled",
		bottomimage = "BottomImage",
		midimage = "MidImage",
		topimage = "TopImage",
		scrollbarimagetransparency = "ScrollBarImageTransparency",
		scrollbarimagecolor3 = "ScrollBarImageColor3",
		verticalscrollbarinset = "VerticalScrollBarInset",
		horizontalscrollbarinset = "HorizontalScrollBarInset",
		verticalscrollbarposition = "VerticalScrollBarPosition",
		elasticbehavior = "ElasticBehavior"

	},
	ImageLabel = {
		transparency = "ImageTransparency",
		src = "Image",
		fit = "ScaleType",
		color = "ImageColor3",
		tile = "TileSize"
	},
	ImageButton = {
		transparency = "ImageTransparency",
		img = "Image",
		hover = "HoverImage",
		press = "PressedImage",
		fit = "ScaleType",
		color = "ImageColor3",
	},
	TextBox = {
		color = "TextColor3",
		textscaled = "TextScaled",
		textwrapped = "TextWrapped",
		textsize = "TextSize",
		richtext = "RichText",
		display = "Text",
		transparency = "TextTransparency",
		strokecolor = "TextStrokeColor3",
		stroketransparency = "TextStrokeTransparency",
		interactable = "Interactable",
		font = "Font",
		xalignment = "TextXAlignment",
		yalignment = "TextYAlignment",
	},
	TextButton = {
		color = "TextColor3",
		backgroundcolor = "BackgroundColor3",
		textscaled = "TextScaled",
		textwrapped = "TextWrapped",
		style = "Style",
		textsize = "TextSize",
		richtext = "RichText",
		display = "Text",
		transparency = "TextTransparency",
		backgroundtransparency = "BackgroundTransparency",
		bordersize = "BorderSizePixel",
		bordercolor = "BorderColor3",
		autobuttoncolor = "AutoButtonColor",
		strokecolor = "TextStrokeColor3",
		stroketransparency = "TextStrokeTransparency",
		font = "Font",
		xalignment = "TextXAlignment",
		yalignment = "TextYAlignment",
	}
}

local tags = {
	page = {
		func = function(values, obj, page, scrollingframe)
			if not values then return end
			if values.size then
				scrollingframe.CanvasSize = values.size
			end
		end,
		properties = {
			size = "udim2"
		}
	},
	title = {
		func = function(values, obj, page, scrollingframe, title)
			if values and values.display and title then
				title.Text = values.display
			end
		end,
		properties = {display = "string"}
	},
	backimg = {
		class = "ImageLabel",
		properties = {
			transparency = "number",
			tile = "udim2",
			color = "color3",
			src = "string",
		}
	},
	corner = {
		class = "UICorner",
		properties = {
			radius = "udim",
			name = "string"
		}
	},
	textsizeconstraint = {
		class = "UITextSizeConstraint",
		properties = {
			minsize = "number",
			maxsize = "number"
		}
	},
	aspectratio = {
		class = "UIAspectRatioConstraint",
		properties = {
			aspectratio = "number",
			aspecttype = Enum.AspectType,
			dominantaxis = Enum.DominantAxis,
			name = "string"
		}
	},
	padding = {
		class = "UIPadding",
		properties = {
			bottom = "udim",
			top = "udim",
			right = "udim",
			left = "udim",
			name = "string"
		}
	},
	scale = {
		class = "UIScale",
		properties = {
			scale = "number",
			name = "string"
		}
	},
	sizeconstraint = {
		class = "UISizeConstraint",
		properties = {
			maxsize = "vector2",
			minsize = "vector2",
			name = "string"
		}
	},
	stroke = {
		class = "UIStroke",
		properties = {
			applystrokemode = Enum.ApplyStrokeMode,
			color = "color3",
			linejoinmode = Enum.LineJoinMode,
			thickness = "number",
			transparency = "number",
			enabled = "boolean",
			name = "string"
		}
	},
	frame = {
		class = "Frame",
		properties = {
			rotation = "number",
			transparency = "number",
			zindex = "number",
			size = "udim2",
			position = "udim2",
			color = "color3",
			anchorpoint = "vector2",
			automaticsize = Enum.AutomaticSize,
			bordersize = "number",
			bordercolor = "color3",
			name = "string"
		}
	},
	scrollframe = {
		class = "ScrollingFrame",
		properties = {
			rotation = "number",
			transparency = "number",
			zindex = "number",
			size = "udim2",
			position = "udim2",
			color = "color3",
			anchorpoint = "vector2",
			automaticsize = Enum.AutomaticSize,
			automaticcanvassize = Enum.AutomaticSize,
			canvassize = "udim2",
			canvasposition = "vector2",
			name = "string",
			scrollingdirection = Enum.ScrollingDirection,
			scrollbarthickness = "number",
			scrollingenabled = "boolean",
			bottomimage = "string",
			topimage = "string",
			midimage = "string",
			scrollbartransparency = "number",
			scrollbarimagecolor3 = "color3",
			verticalscrollbarinset = Enum.ScrollBarInset,
			horizontalscrollbarinset = Enum.ScrollBarInset,
			verticalscrollbarposition = Enum.VerticalScrollBarPosition,
			elasticbehavior = Enum.ElasticBehavior
		}
	},
	img = {
		class = "ImageLabel",
		properties = {
			rotation = "number",
			transparency = "number",
			zindex = "number",
			size = "udim2",
			position = "udim2",
			color = "color3",
			anchorpoint = "vector2",
			automaticsize = Enum.AutomaticSize,
			src = "string",
			fit = "boolean",
			name = "string"
		}
	},
	txt = {
		class = "TextBox",
		properties = {
			rotation = "number",
			transparency = "number",
			zindex = "number",
			size = "udim2",
			position = "udim2",
			color = "color3",
			richtext = "boolean",
			anchorpoint = "vector2",
			automaticsize = Enum.AutomaticSize,
			display = "string",
			textscaled = "boolean",
			textsize = "number",
			textwrapped = "boolean",
			name = "string",
			strokecolor = "color3",
			stroketransparency = "number",
			interactable = "boolean",
			font = Enum.Font,
			xalignment = Enum.TextXAlignment,
			yalignment = Enum.TextYAlignment
		}
	},
	button = {
		func = function(values, obj, page, scrollingframe, title)
			addbuttonscript(values, obj, page, scrollingframe, title)
		end,
		class = "TextButton",
		properties = {
			rotation = "number",
			transparency = "number",
			zindex = "number",
			size = "udim2",
			position = "udim2",
			color = "color3",
			backgroundcolor = "color3",
			anchorpoint = "vector2",
			automaticsize = Enum.AutomaticSize,
			display = "string",
			richtext = "boolean",
			href = "string",
			donate = "string",
			textscaled = "boolean",
			textsize = "number",
			style = Enum.ButtonStyle,
			textwrapped = "boolean",
			bordersize = "number",
			bordercolor = "color3",
			name = "string",
			backgroundtransparency = "number",
			autobuttoncolor = "boolean",
			strokecolor = "color3",
			stroketransparency = "number",
			font = Enum.Font,
			xalignment = Enum.TextXAlignment,
			yalignment = Enum.TextYAlignment
		}
	},
	imagebutton = {
		func = function(values, obj, page, scrollingframe, title)
			addbuttonscript(values, obj, page, scrollingframe, title)
		end,
		class = "ImageButton",
		properties = {
			rotation = "number",
			transparency = "number",
			zindex = "number",
			size = "udim2",
			position = "udim2",
			color = "color3",
			anchorpoint = "vector2",
			automaticsize = Enum.AutomaticSize,
			fit = "boolean",
			img = "string",
			hover = "string",
			press = "string",
			href = "string",
			donate = "string",
			name = "string"
		}
	}
}

local function strtovalue(str, type)
	if type == "vector2" then
		local numbers = str:split(",")
		return Vector2.new(tonumber(numbers[1]) or 0, tonumber(numbers[2]) or 0)
	elseif type == "color3" then
		local numbers = str:split(",")
		return Color3.fromRGB(tonumber(numbers[1]) or 0, tonumber(numbers[2]) or 0, tonumber(numbers[3]) or 0)
	elseif type == "udim" then
		local numbers = str:split(",")
		return UDim.new((tonumber(numbers[1]) or 0),(tonumber(numbers[2]) or 0))
	elseif type == "udim2" then
		local numbers = str:split(",")
		return UDim2.new((tonumber(numbers[1]) or 0),(tonumber(numbers[2]) or 0), (tonumber(numbers[3]) or 0), (tonumber(numbers[4]) or 0))
	elseif type == "number" then
		return tonumber(str) or 0
	elseif type == "boolean" then
		if str:lower() == "true" then
			return true
		else
			return false
		end
	elseif typeof(type) == "Enum" then
		return enumitems[tostring(type)][str:lower()]
	else
		return str
	end
end

function loadtext(source, page, scrollingframe, title)
	page.Parent = scrollingframe.Parent
	page:ClearAllChildren()
	scrollingframe:ClearAllChildren()
	page.Parent = scrollingframe
	scrollingframe.CanvasSize = UDim2.fromScale(0, 0)
	source = source:gsub("\\<", "_lower_"):gsub("\\>", "_higher_")
	local start = UDim2.new(0,0,0,0)

	--gtml 2.0
	local storedelements = {}
	local backimg
	for tag, properties in string.gmatch(source, "<%s*(%w+)(%s*[^>]*)>") do
		if backimg and tag == "backimg" then
			continue
		end
		local values
		local variablename
		local parent
		tag = tag:lower()
		local info = tags[tag]
		if info then
			local ignore = false
			local obj = nil
			if properties and properties ~= "" then
				values = {}
				properties = properties:gsub('\\"', "_quote_")
				for key, value in string.gmatch(properties, '(%S*)%s*=%s*(%b"")') do
					key = key:lower()
					value = converttostring(value):sub(2, -2)
					if key == "ignore" then
						if value:lower() == "true" then
							ignore = true
						end
					elseif key == "variable" then
						variablename = value
					elseif key == "parent" and tag ~= "backimg" then
						if storedelements[value] then
							parent = storedelements[value]
						end
					else
						if info.properties[key] then
							values[key] = strtovalue(value, info.properties[key])
						end
					end
				end

			end
			if ignore then
				values = nil
				info = nil
				continue
			end
			if info.class then
				obj = Instance.new(info.class)
				if defaultproperties[tag] then
					for key, value in defaultproperties[tag] do
						obj[key] = value
					end
				end
				if obj:IsA("GuiObject") and not parent and tag ~= "backimg" then
					obj.Position = start
					if (values and not values.position) or not values then
						start += UDim2.new(0,0,0, obj.AbsoluteSize.Y)
					end
				end
				if values then
					for key, value in values do
						local property = guiobjectproperties[info.class][key] or guiobjectproperties.all[key]
						if property and value ~= nil then
							if key == "fit" and property == "ScaleType" and value then
								value = Enum.ScaleType.Fit
							elseif property == "Video" or property == "SoundId" then
								value = strtoasset(value)
							elseif property:sub(-6, -1) == "Image" then
								value = strtoimg(value)
							end
							obj[property] = value
						end
					end
				end
				obj.Parent = parent or (tag ~= "backimg" and page or scrollingframe)
			end
			if info.func then
				info.func(values, obj, page, scrollingframe, title)
			end
			if variablename and obj then
				storedelements[variablename] = obj
			end
			if tag == "backimg" then
				backimg = obj
			end
		end
	end
	if backimg then
		page.Parent = backimg
	end
	storedelements = nil
end

local function StringToGui(text, parent, title)
	local scrollingframe = Instance.new("ScrollingFrame")
	scrollingframe.Size = UDim2.fromScale(1, 1)
	scrollingframe.ScrollBarThickness = 5
	scrollingframe.BackgroundTransparency = 1
	scrollingframe.Parent = parent
	local page = Instance.new("Frame")
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.Parent = scrollingframe
	loadtext(text, page, scrollingframe, title)
end
-- end gui file stuff

local usedmicros = {}

local background
local commandlines

local bootos
local dir = "/"

local function playsound(txt)
	if txt then
		if string.find(tostring(txt), "pitch:") then
			local length = nil

			local pitch = nil
			local splitted = string.split(tostring(txt), "pitch:")
			local spacesplitted = string.split(tostring(txt), " ")

			if string.find(splitted[2], " ") then
				pitch = (string.split(splitted[2], " "))[1]
			else
				pitch = splitted[2]
			end

			if string.find(tostring(txt), "length:") then
				local splitted = string.split(tostring(txt), "length:")
				if string.find(splitted[2], " ") then
					length = (string.split(splitted[2], " "))[1]
				else
					length = splitted[2]
				end
			end
			if not length then
				local sound = speaker:LoadSound(`rbxassetid://{spacesplitted[1]}`)
				sound.Pitch = pitch or 1
				sound.Volume = 1
				sound:Play()

				if sound.Ended then
					sound.Ended:Connect(function() sound:Destroy() end)
				end
			else
				local sound = speaker:LoadSound(`rbxassetid://{spacesplitted[1]}`)
				sound.Volume = 1
				sound.Pitch = pitch or 1
				sound.Looped = true
				sound:Play()
			end
		elseif string.find(tostring(txt), "length:") then

			local splitted = string.split(tostring(txt), "length:")

			local spacesplitted = string.split(tostring(txt), " ")

			local length = nil

			if string.find(splitted[2], " ") then
				length = (string.split(splitted[2], " "))[1]
			else
				length = splitted[2]
			end

			local sound = speaker:LoadSound(`rbxassetid://{spacesplitted[1]}`)
			sound.Volume = 1
			sound.Looped = true
			sound:Play()
		else
			local sound = speaker:LoadSound(`rbxassetid://{txt}`)
			sound.Volume = 1
			sound:Play()
			if sound.Ended then
				sound.Ended:Connect(function() sound:Destroy() end)
			end
		end
	end
	speaker.Volume = speaker.Volume
end

local coroutineprograms = {}

local function getprograms()
	local t = {}

	for i, v in ipairs(coroutineprograms) do
		if coroutine.status(v.coroutine) == "dead" then
			table.remove(coroutineprograms, i)
			continue
		end
		table.insert(t, v.name)
	end

	return t
end

local function stopprogram(i)
	local program = coroutineprograms[i]
	if not program then
		return false
	end

	if coroutine.status(program.coroutine) ~= "dead" then
		coroutine.close(program.coroutine)
	end

	table.remove(coroutineprograms, i)

	return true
end

local function stopprogrambyname(name)
	for i, program in ipairs(coroutineprograms) do
		if coroutine.status(program.coroutine) ~= "dead" and program.name == name then
			coroutine.close(program.coroutine)
			table.remove(coroutineprograms, table.find(coroutineprograms, program))
		end
	end
end

local luaprogram
local cmdsenabled = true
local iconnections = {}

local programglobals = {
	luaprogram = luaprogram,
	filesystem = filesystem,
	screen = screen,
	keyboard = keyboard,
	modem = modem,
	speaker = speaker,
	commandline = commandline,
	disk = disk,
	disks = disks,
	rom = rom,
	getFileExtension = getfileextension,
	StringToGui = StringToGui,
	runtext = runtext
}

local function runprogram(text, name)
	if not text then error("no code to run was given in parameter two.") end
	if typeof(name) ~= "string" then
		name = "untitled"
	end
	local fenv = table.clone(getfenv())

	for name, value in pairs(programglobals) do
		fenv[name] = value
	end

	fenv["lines"] = {
		clear = commandlines.clear,
		insert = commandlines.insert,
		background = background,
		disablecmds = function()
			cmdsenabled = false
		end,
		enablecmds = function()
			cmdsenabled = true
		end,
		cmdsenabled = function()
			return cmdsenabled
		end,
		getinput = function(prg, func)
			assert(type(func) == "function", "The given parameter is not a function")
			local disconnect
			disconnect = function()
				local found = table.find(iconnections, func)
				if found then
					table.remove(iconnections, found)
				end
				found = nil
			end
			table.insert(iconnections, func)
			return disconnect
		end,
		getdir = function() return dir, disk end
	}
	local prg
	fenv["getSelf"] = function()
		return prg, name
	end
	local func, b = loadstring(text)
	if func then
		setfenv(func, fenv)
		prg = coroutine.create(func)
		table.insert(coroutineprograms, {name = name, coroutine = prg})
		local success, error = coroutine.resume(prg)
		if error then
			b = error
		end
	end
	return b
end

local function stopprograms()
	for i, v in ipairs(coroutineprograms) do
		if coroutine.status(v.coroutine) ~= "dead" then
			coroutine.close(v.coroutine)
		end
	end
	coroutineprograms = {}
end

luaprogram = {
	getPrograms = getprograms,
	stopProgram = stopprogram,
	stopProgramByName = stopprogrambyname,
	runProgram = runprogram,
}

table.freeze(luaprogram)

local copydir = ""
local copyname = ""
local copydata = ""
local copydisk

function runtext(text)
	local lowered = text:lower()
	if lowered:sub(1, 4) == "dir " then
		local txt = text:sub(5, string.len(text))
		local inputtedtext = txt
		local tempsplit = string.split(inputtedtext, "/")
		if tempsplit then
			if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
				inputtedtext = "/"..inputtedtext
			end
		end
		local tempsplit2 = string.split(inputtedtext, "/")
		if tempsplit2 then
			if inputtedtext:sub(-1, -1) == "/" and tempsplit2[2] ~= "" then inputtedtext = inputtedtext:sub(0, -2); end
		end
		if inputtedtext == " " then inputtedtext = ""; end
		local split = string.split(inputtedtext, "/")
		if split then
			local removedlast = inputtedtext:sub(1, -(string.len(split[#split]))-2)
			if #split >= 3 then
				if typeof(getfileontable(disk, split[#split], removedlast)) == "table" then
					commandlines.insert(inputtedtext..":")
					dir = inputtedtext
				else
					commandlines.insert("Invalid directory")
					commandlines.insert(dir..":")
				end
			else
				if disk:Read(split[#split]) or split[2] == "" then
					if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
						commandlines.insert(inputtedtext..":")
						dir = inputtedtext
					elseif tempsplit[1] == "" and tempsplit[2] == "" then
						commandlines.insert(inputtedtext..":")
						dir = inputtedtext
					elseif tempsplit[1] == "" and tempsplit[2] ~= "" then
						if typeof(disk:Read(split[#split])) == "table" then
							commandlines.insert(inputtedtext..":")
							dir = inputtedtext
						end
					else
						commandlines.insert("Invalid directory")
						commandlines.insert(dir..":")
					end
				else
					commandlines.insert("Invalid directory")
					commandlines.insert(dir..":")
				end
			end
		elseif inputtedtext == "" then
			commandlines.insert(dir..":")
		else
			commandlines.insert("Invalid directory")
			commandlines.insert(dir..":")
		end
	elseif lowered:gsub("%s", "") == "clear" then
		task.wait(0.1)
		commandlines.clear()
		position = UDim2.new(0,0,0,0)
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 11) == "setstorage " then
		local text = text:sub(12, string.len(text))

		local text = tonumber(text)

		if disks[text] then
			disk = disks[text]
			dir = "/"
			commandlines.insert("Success")
		else
			commandlines.insert("Invalid storage media number.")
		end
		commandlines.insert(dir..":")
	elseif lowered:gsub("%s", "") == "showstorages" then
		for i, val in ipairs(disks) do
			commandlines.insert(tostring(i))
		end
		commandlines.insert(dir..":")
	elseif lowered:gsub("%s", "") == "reboot" then
		iconnections = {}
		task.wait(1)
		Beep(1)
		getstuff()
		dir = "/"
		if keyboardevent then keyboardevent:Disconnect() end
		if not putermode then
			bootos()
		else
			pcall(TriggerPort, 3)
		end
	elseif lowered:gsub("%s", "") == "shutdown" then
		if text:sub(9, string.len(text)) == nil or text:sub(9, string.len(text)) == "" then
			iconnections = {}
			task.wait(1)
			Beep(1)
			screen:ClearElements()
			if speaker then
				speaker:ClearSounds()
			end
			if not putermode then
				if not back then
					Microcontroller:Shutdown()
				else
					back()
				end
			else
				pcall(TriggerPort, 2)
			end
		else
			commandlines.insert(dir..":")
		end
	elseif lowered:sub(1, 9) == "richtext " then
		local bool = text:sub(10, string.len(text)):gsub("%s", ""):lower()
		if bool == "true" then
			richtext = true
		elseif bool == "false" then
			richtext = false
		else
			commandlines.insert("No valid boolean was given.")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 6) == "print " then
		local output = text:sub(7, string.len(text))
		local spacesplitted = string.split(tostring(output), "\n")
		if spacesplitted then
			for i, v in ipairs(spacesplitted) do
				commandlines.insert(v)
			end
		else
			commandlines.insert(tostring(output))
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 5) == "copy " then
		local filename = text:sub(6, string.len(text))
		if filename and filename ~= "" then
			local file = filesystem.Read(filename, dir, true, disk)

			if file then
				copydir = dir
				copydisk = disk
				copyname = filename
				copydata = file
				commandlines.insert("Copied, use the paste command to paste the file.")
			else
				commandlines.insert("The specified file was not found on this directory.")
			end
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 5) == "paste" then
		if copydir ~= "" and copyname ~= "" then
			local file = filesystem.Read(copyname, copydir, true, copydisk)

			if not file then
				file = copydata
			end

			if file then
				local result = filesystem.Write(copyname, file, dir, disk)
				commandlines.insert(result)
			else
				commandlines.insert("File does not exist.")
			end
		else
			commandlines.insert("No file has been copied.")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 7) == "rename " then
		local misc = text:sub(8, string.len(text))
		local split1 = misc:split("/")
		local filename = split1[1]
		local newname = ""

		for index, value in ipairs(split1) do
			if index >= 2 then
				newname = newname..value
			end
		end

		if filename and filename ~= "" then
			local file = filesystem.Read(filename, dir, true, disk)
			if file then
				if newname ~= "" then
					filesystem.Write(newname, file, dir, disk)
					filesystem.Write(filename, nil, dir, disk)
					commandlines.insert("Renamed.")
				else
					commandlines.insert("The new filename wasn't specified.")	
				end
			else
				commandlines.insert("The specified file was not found on this directory.")
			end
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 3) == "cd " then
		local filename = text:sub(4, string.len(text))

		if filename and filename ~= "" and filename ~= "./" then
			local file = filesystem.Read(filename, dir, true, disk)

			if typeof(file) == "table" then
				dir = if dir == "/" then dir..filename else dir.."/"..filename
				commandlines.insert("Success?")
			else
				commandlines.insert("The specified file is not a table.")
			end
		elseif filename == "./" then
			local split = dir:split("/")
			if #split == 2 and split[2] == "" then
				commandlines.insert("Cannot use ./ on root.")
			else
				local newdir = dir:sub(1, -(string.len(split[#split]))-2)
				dir = if newdir == "" then "/" else newdir
			end
		else
			commandlines.insert("The table/folder name was not specified.")
		end
		commandlines.insert(dir..":")
	elseif lowered:gsub("%s", "") == "showluas" then
		for i,v in pairs(getprograms()) do
			commandlines.insert(v)
			commandlines.insert(i)
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 8) == "stoplua " then
		local number = tonumber(text:sub(9, string.len(text)))
		local success = false
		if typeof(number) == "number" then
			success = stopprogram(number)
		end
		if not success then
			commandlines.insert("Invalid program number.")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 7) == "runlua " then
		local err = runprogram(text:sub(8, string.len(text)))
		if err then commandlines.insert(err) end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 8) == "readlua " then
		local filename = text:sub(9, string.len(text))
		if filename and filename ~= "" then
			local output = filesystem.Read(filename, dir, true, disk)
			local output = output
			local err = runprogram(output, filename)
			if err then commandlines.insert(err) end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 5) == "beep " then
		local number = tonumber(text:sub(6, string.len(text)))
		if number then
			Beep(number)
		else
			commandlines.insert("Invalid number")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 10) == "setvolume " then
		if speaker then
			local number = tonumber(text:sub(11, string.len(text)))
			if number then
				speaker.Volume = number
			else
				commandlines.insert("Invalid number")
			end
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 7) == "showdir" then
		local inputtedtext = dir
		local tempsplit = string.split(inputtedtext, "/")
		if tempsplit then
			if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
				inputtedtext = "/"..inputtedtext
			end
		end
		local tempsplit2 = string.split(inputtedtext, "/")
		if tempsplit2 then
			if inputtedtext:sub(-1, -1) == "/" and tempsplit2[2] ~= "" then inputtedtext = inputtedtext:sub(0, -2); end
		end
		if inputtedtext == " " then inputtedtext = ""; end
		local split = string.split(inputtedtext, "/")
		if split then
			local removedlast = inputtedtext:sub(1, -(string.len(split[#split]))-2)
			if #split >= 3 then
				local output = getfileontable(disk, split[#split], removedlast)
				if typeof(output) == "table" then
					for i,v in pairs(output) do
						commandlines.insert(tostring(i))
					end
				else
					commandlines.insert("Invalid directory")
				end
			else
				local output = disk:Read(split[#split])
				if output or split[2] == "" then
					if tempsplit[1] ~= "" and disk:Read(tempsplit[1]) then
						if typeof(output) == "table" then
							for i,v in pairs(output) do
								commandlines.insert(tostring(i))
							end
						end
					elseif tempsplit[1] == "" and tempsplit[2] == "" then
						for i,v in pairs(disk:ReadAll()) do
							commandlines.insert(tostring(i))
						end
					elseif tempsplit[1] == "" and tempsplit[2] ~= "" then
						if typeof(disk:Read(split[#split])) == "table" then
							for i,v in pairs(disk:Read(split[#split])) do
								commandlines.insert(tostring(i))
							end
						end
					else
						commandlines.insert("Invalid directory")
					end
				else
					commandlines.insert("Invalid directory")
				end
			end
		elseif inputtedtext == "" then
			for i,v in pairs(disk:ReadAll()) do
				commandlines.insert(tostring(i))
			end
		else
			commandlines.insert("Invalid directory")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 10) == "createdir " then
		local filename = text:sub(11, string.len(text))
		if filename and filename ~= "" then
			local result = filesystem.Write(filename, {}, dir, disk)

			commandlines.insert(result)
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 6) == "write " then
		local texts = text:sub(7, string.len(text))
		local filename = texts:split("/")[1]
		local filedata = texts:split("/")[2]
		for i,v in ipairs(texts:split("/")) do
			if i > 2 then
				filedata = filedata.."/"..v
			end
		end
		if filename and filename ~= "" then
			if filedata and filedata ~= "" then
				local result = filesystem.Write(filename, filedata, dir, disk)

				commandlines.insert(result)
			else
				commandlines.insert("No filedata specified")
			end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 7) == "delete " then
		local filename = text:sub(8, string.len(text))
		if filename then
			local result = filesystem.Write(filename, nil, dir, disk)

			commandlines.insert(result)
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 5) == "read " then
		local filename = text:sub(6, string.len(text))
		if filename then
			local output = filesystem.Read(filename, dir, true, disk)
			if string.find(string.lower(tostring(output)), "<woshtml>") then
				local textlabel = commandlines.insert(tostring(output), UDim2.fromScale(1, 1))
				StringToGui(tostring(output), textlabel)
				textlabel.TextTransparency = 1
			else
				local spacesplitted = string.split(tostring(output), "\n")
				if spacesplitted then
					for i, v in ipairs(spacesplitted) do
						commandlines.insert(v)
					end
				else
					commandlines.insert(tostring(output))
				end
			end
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 10) == "readimage " then
		local filename = text:sub(11, string.len(text))
		if filename and filename ~= "" then
			local output = filesystem.Read(filename, dir, true, disk)
			local textlabel = commandlines.insert(tostring(output), UDim2.fromScale(1, 1))
			StringToGui([[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
		if filename and filename ~= "" then
			background.CanvasPosition -= Vector2.new(0, 24)
		end
	elseif lowered:sub(1, 10) == "readvideo " then
		local filename = text:sub(11, string.len(text))
		if filename and filename ~= "" then
			local output = filesystem.Read(filename, dir, true, disk)
			local textlabel = commandlines.insert(output, UDim2.fromScale(1, 1))
			local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..tostring(tonumber(output))})
			videoframe.Parent = textlabel
			videoframe.Playing = true
		else
			commandlines.insert("No filename specified")
		end
		commandlines.insert(dir..":")
		if filename and filename ~= "" then
			background.CanvasPosition -= Vector2.new(0, 24)
		end
	elseif lowered:sub(1, 13) == "displayimage " then
		local id = text:sub(14, string.len(text))
		if id and id ~= "" then
			local textlabel = commandlines.insert(tostring(id), UDim2.fromScale(1, 1))
			StringToGui([[<img src="]]..tostring(tonumber(id))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
		else
			commandlines.insert("No id specified")
		end
		commandlines.insert(dir..":")
		if id and id ~= "" then
			background.CanvasPosition -= Vector2.new(0, 24)
		end
	elseif lowered:sub(1, 13) == "displayvideo " then
		local id = text:sub(14, string.len(text))
		if id and id ~= "" then
			local textlabel = commandlines.insert(tostring(id), UDim2.fromScale(1, 1))
			local videoframe = screen:CreateElement("VideoFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Video = "rbxassetid://"..id})
			videoframe.Parent = textlabel
			videoframe.Playing = true
		else
			commandlines.insert("No id specified")
		end
		commandlines.insert(dir..":")
		if id and id ~= "" then
			background.CanvasPosition -= Vector2.new(0, 24)
		end
	elseif lowered:sub(1, 10) == "readsound " then
		local filename = text:sub(11, string.len(text))
		local txt
		if filename and filename ~= "" then
			local output = filesystem.Read(filename, dir, true, disk)
			local textlabel = commandlines.insert(tostring(output))
			txt = output
		else
			commandlines.insert("No filename specified")
		end
		playsound(txt)
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 10) == "playsound " then
		local txt = text:sub(11, string.len(text))
		playsound(txt)
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 10) == "stopsounds" then
		speaker:ClearSounds()
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 11) == "soundpitch " then
		if speaker and tonumber(text:sub(12, string.len(text))) then
			speaker:Configure({Pitch = tonumber(text:sub(12, string.len(text)))})
			speaker:Trigger()
		else
			commandlines.insert("Invalid pitch number or no speaker was found.")
		end
		commandlines.insert(dir..":")
	elseif lowered:gsub("%s", "") == "cmds" then
		commandlines.insert("Commands:")
		commandlines.insert("cmds")
		commandlines.insert("stopsounds")
		commandlines.insert("soundpitch number")
		commandlines.insert("readsound filename")
		commandlines.insert("read filename")
		commandlines.insert("readimage filename")
		commandlines.insert("dir directory")
		commandlines.insert("showdir")
		commandlines.insert("write filename/filedata (with the /)")
		commandlines.insert("shutdown")
		commandlines.insert("clear")
		commandlines.insert("showstorages")
		commandlines.insert("setstorage number")
		commandlines.insert("reboot")
		commandlines.insert("delete filename")
		commandlines.insert("createdir filename")
		commandlines.insert("stoplua number")
		commandlines.insert("runlua lua")
		commandlines.insert("showluas")
		commandlines.insert("richtext boolean")
		commandlines.insert("readlua filename")
		commandlines.insert("beep number")
		commandlines.insert("print text")
		commandlines.insert("playsound id")
		commandlines.insert("displayimage id")
		commandlines.insert("displayvideo id")
		commandlines.insert("readvideo id")
		commandlines.insert("cd table/folder or ./ for parent table/folder")
		commandlines.insert("copy filename")
		commandlines.insert("paste")
		commandlines.insert("rename filename/new filename (with the /)")
		commandlines.insert("Put !s before the command to replace the new lines with spaces instead of removing them.")
		commandlines.insert("Put !n before the command to replace \\\\n with a new line.")
		commandlines.insert("Put !k before the command to not remove the new lines.")
		commandlines.insert(dir..":")
	elseif lowered:sub(1, 4) == "help" then
		keyboard:SimulateTextInput("cmds", "Microcontroller")

	elseif lowered:sub(1, 10) == "stopmicro " then
		keyboard:SimulateTextInput("stoplua "..text:sub(11, string.len(text)), "Microcontroller")
	elseif lowered:sub(1, 10) == "showmicros" then
		keyboard:SimulateTextInput("showluas", "Microcontroller")

	elseif lowered:sub(1, 10) == "playvideo " then
		keyboard:SimulateTextInput("displayvideo "..text:sub(11, string.len(text)), "Microcontroller")

	elseif lowered:sub(1, 8) == "makedir " then
		keyboard:SimulateTextInput("createdir "..text:sub(9, string.len(text)), "Microcontroller")
	elseif lowered:sub(1, 6) == "mkdir " then
		keyboard:SimulateTextInput("createdir "..text:sub(7, string.len(text)), "Microcontroller")
	elseif lowered:sub(1, 5) == "echo " then
		keyboard:SimulateTextInput("print "..text:sub(6, string.len(text)), "Microcontroller")
	elseif lowered:sub(1, 10) == "playaudio " then
		keyboard:SimulateTextInput("playsound "..text:sub(11, string.len(text)), "Microcontroller")
	elseif lowered:sub(1, 10) == "readaudio " then
		keyboard:SimulateTextInput("readsound "..text:sub(11, string.len(text)), "Microcontroller")
	elseif lowered:sub(1, 10) == "stopaudios" then
		keyboard:SimulateTextInput("stopsounds", "Microcontroller")
	elseif lowered:sub(1, 9) == "stopaudio" then
		keyboard:SimulateTextInput("stopsounds", "Microcontroller")
	elseif lowered:sub(1, 9) == "stopsound" then
		keyboard:SimulateTextInput("stopsounds", "Microcontroller")
	else
		local filename = text
		local output = filesystem.Read(filename, dir, true, disk)
		if output then
			if getfileextension(filename, true) == ".aud" then
				commandlines.insert(tostring(output))
				playsound(output)
				commandlines.insert(dir..":")
			elseif getfileextension(filename, true) == ".img" then
				local textlabel = commandlines.insert(tostring(output), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
				StringToGui([[<img src="]]..tostring(tonumber(output))..[[" size="1,0,1,0" position="0,0,0,0">]], textlabel)
				commandlines.insert(dir..":")
				background.CanvasPosition -= Vector2.new(0, 24)
			elseif getfileextension(filename, true) == ".lua" then
				local err = runprogram(output, filename)
				if err then commandlines.insert(err) end
				commandlines.insert(dir..":")
			elseif getfileextension(filename, true) == ".gui" then
				local textlabel = commandlines.insert(tostring(output), UDim2.fromScale(1, 1))
				StringToGui(output, textlabel)
				textlabel.TextTransparency = 1
				commandlines.insert(dir..":")
			else
				if string.find(string.lower(tostring(output)), "<woshtml>") then
					local textlabel = commandlines.insert(tostring(output), UDim2.fromOffset(background.AbsoluteSize.X, background.AbsoluteSize.Y))
					StringToGui(tostring(output):lower(), textlabel)
					textlabel.TextTransparency = 1
					commandlines.insert(dir..":")
					background.CanvasPosition -= Vector2.new(0, 24)
				else
					local spacesplitted = string.split(tostring(output), "\n")
					if spacesplitted then
						for i, v in ipairs(spacesplitted) do
							commandlines.insert(v)
						end
					else
						commandlines.insert(tostring(output))
					end
					commandlines.insert(dir..":")
				end
			end
		else
			commandlines.insert("Imcomplete or Command was not found.")
			commandlines.insert(dir..":")
		end
	end
end

function bootos()
	if disks and #disks > 0 then
		print(`{romport}\\{disksport}`)
		if romport ~= disksport then
			local indexusing1

			for i,v in ipairs(disks) do
				if rom ~= v then
					disk = v
					indexusing1 = i

					break
				end
			end

			local diskstable2 = {
				[1] = disk
			}

			for i, v in ipairs(disks) do
				if i ~= indexusing1 then
					table.insert(diskstable2, v)
				end
			end

			disks = diskstable2
		else
			local diskstable = {}

			for i, v in ipairs(disks) do
				if rom ~= v and i ~= romindexusing then
					table.insert(diskstable, v)
				end
			end

			disks = diskstable

			local indexusing1

			for i, v in ipairs(disks) do
				disk = v
				indexusing1 = i

				break
			end

			local diskstable2 = {
				[1] = disk
			}

			for i, v in ipairs(disks) do
				if i ~= indexusing1 then
					table.insert(diskstable2, v)
				end
			end

			disks = diskstable2
		end
	else
		disk = rom
        disks = {disk}
	end
	if not screen then
		if regularscreen then screen = regularscreen end
	end
	if screen and keyboard and disk and rom then
		table.clear(iconnections)
		disks = table.freeze(disks)

		disk:Write("test.gui", '<button href="/test2.gui" display="test2">')
		disk:Write("test2.gui", '<button href="/test.gui" display="test">')
		rom:Write("SysDisk", true)
		if speaker then
			speaker:ClearSounds()
		end
		screen:ClearElements()

		commandlines, background = commandline.new(screen)
		task.wait(1)
		position = UDim2.new(0,0,0,0)
		Beep(1)
		commandlines.insert(name.." Command line")
		task.wait(1)
		commandlines.insert("/:")
		local exclmarkthings = {
			["!s"] = function(text)
				local text = string.sub(tostring(text), 3, string.len(text)):gsub("\n", " ")

				commandlines.insert(text)
				runtext(text)
			end,
			["!n"] = function(text)
				local text = string.sub(tostring(text), 3, string.len(text)):gsub("\n", ""):gsub("\\n", "\n")

				commandlines.insert(text)
				runtext(text)
			end,
			["!k"] = function(text)
				local text = string.sub(tostring(text), 3, string.len(text))

				commandlines.insert(text)
				runtext(text)
			end,
		}
		if keyboardevent then keyboardevent:Disconnect() end
		keyboardevent = keyboard.TextInputted:Connect(function(text, player)			
			for i, f in iconnections do
				pcall(task.spawn, f, text, player)
			end
			if not cmdsenabled then return end
			local func = exclmarkthings[string.sub(tostring(text), 1, 2)]
			if not func then
				commandlines.insert(tostring(text):gsub("\n", ""))
				runtext(tostring(text):gsub("\n", ""))
			else
				func(text)
			end
		end)
	elseif screen then
		screen:ClearElements()
		local commandlines = commandline.new(screen)
		commandlines.insert(name.." Command line")
		task.wait(1)
		if not speaker then
			commandlines.insert("No speaker was found. (Optional)")
		end
		task.wait(1)
		if not keyboard then
			commandlines.insert("No keyboard was found.")
		end
		task.wait(1)
		if not disk then
			commandlines.insert("You need 2 or more disks, 2 or more ports must not be connected to the same disks.")
		end
		if not rom then
			commandlines.insert([[No empty disk or disk with the file "GDOSLibrary" was found.]])
		end
		if keyboard then
			local keyboardevent = keyboard.KeyPressed:Connect(function(key)
				if key == Enum.KeyCode.Return then
					getstuff()
					bootos()
					keyboardevent:Disconnect()
				end
			end)
		else
			while true do task.wait(1) end
		end
	elseif not screen then
		Beep(0.5)
		print("No screen was found.")
		if keyboard then
			local keyboardevent = keyboard.KeyPressed:Connect(function(key)
				if key == Enum.KeyCode.Return then
					getstuff()
					bootos()
					keyboardevent:Disconnect()
				end
			end)
		else
			while true do task.wait(1) end
		end
	end
end
bootos()
