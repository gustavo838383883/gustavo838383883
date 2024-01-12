--og bluecoin atm made by blueloops9
--gui made by Gustavo12345687890 / Gustavo242
--reskin of the puter bluecoin atm for gd7
--made in 2024

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
                    window.Visible = true
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
                    window.Visible = false
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

local gui = {}

local screen = Screen

gui[`TextLabel4`] = screen:CreateElement('TextLabel', {
	Name = [[TextLabel4]],
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	Position = UDim2.new(0, 0, -0.01287001185119152, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	RichText = true,
	Text = [[Sign up]],
	TextColor3 = Color3.new(0, 0, 0),
	TextScaled = true,
	TextWrapped = true,
	TextSize = 14,
})

gui[`signupbutton`] = screen:CreateElement('ImageButton', {
	Name = [[signupbutton]],
	BorderSizePixel = 0,
	Size = UDim2.new(0.20000000298023224, 0, 0.15000000596046448, 0),
	Position = UDim2.new(0.20000000298023224, 0, 0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	Image = [[http://www.roblox.com/asset/?id=15625805900]],
	PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
})

gui[`TextLabel2`] = screen:CreateElement('TextLabel', {
	Name = [[TextLabel2]],
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	Position = UDim2.new(0, 0, -0.01286996342241764, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	RichText = true,
	Text = [[Manage]],
	TextColor3 = Color3.new(0, 0, 0),
	TextScaled = true,
	TextWrapped = true,
	TextSize = 14,
})

gui[`Username`] = screen:CreateElement('TextLabel', {
	Name = [[Username]],
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(0.5, 0, 1, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	Text = [[Not Signed in.]],
	TextColor3 = Color3.new(0, 0, 0),
	TextScaled = true,
	TextWrapped = true,
	TextSize = 14,
})

gui[`TextLabel5`] = screen:CreateElement('TextLabel', {
	Name = [[TextLabel5]],
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	RichText = true,
	Text = [[Transaction]],
	TextColor3 = Color3.new(0, 0, 0),
	TextScaled = true,
	TextWrapped = true,
	TextSize = 14,
})

gui[`TextLabel3`] = screen:CreateElement('TextLabel', {
	Name = [[TextLabel3]],
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	RichText = true,
	Text = [[Mining]],
	TextColor3 = Color3.new(0, 0, 0),
	TextScaled = true,
	TextWrapped = true,
	TextSize = 14,
})

gui[`TextLabel`] = screen:CreateElement('TextLabel', {
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	RichText = true,
	Text = [[Sign in]],
	TextColor3 = Color3.new(0, 0, 0),
	TextScaled = true,
	TextWrapped = true,
	TextSize = 14,
})

gui[`MainFrame`] = screen:CreateElement('Frame', {
	Name = [[MainFrame]],
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0.8500000238418579, 0),
	Position = UDim2.new(0, 0, 0.14864864945411682, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
})

gui[`transactionbutton`] = screen:CreateElement('ImageButton', {
	Name = [[transactionbutton]],
	BorderSizePixel = 0,
	Size = UDim2.new(0.20000000298023224, 0, 0.15000000596046448, 0),
	Position = UDim2.new(0.6000000238418579, 0, 0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	Image = [[http://www.roblox.com/asset/?id=15625805900]],
	PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
})

gui[`miningbutton`] = screen:CreateElement('ImageButton', {
	Name = [[miningbutton]],
	BorderSizePixel = 0,
	Size = UDim2.new(0.20000000298023224, 0, 0.15000000596046448, 0),
	Position = UDim2.new(0.800000011920929, 0, 0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	Image = [[http://www.roblox.com/asset/?id=15625805900]],
	PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
})

gui[`signinbutton`] = screen:CreateElement('ImageButton', {
	Name = [[signinbutton]],
	BorderSizePixel = 0,
	Size = UDim2.new(0.20000000298023224, 0, 0.15000000596046448, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	Image = [[http://www.roblox.com/asset/?id=15625805900]],
	PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
})

gui[`managebutton`] = screen:CreateElement('ImageButton', {
	Name = [[managebutton]],
	BorderSizePixel = 0,
	Size = UDim2.new(0.20000000298023224, 0, 0.15000000596046448, 0),
	Position = UDim2.new(0.4000000059604645, 0, 0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	Image = [[http://www.roblox.com/asset/?id=15625805900]],
	PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
})

gui[`TextLabel6`] = screen:CreateElement('TextLabel', {
	Name = [[TextLabel6]],
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	RichText = true,
	Text = [[Log out]],
	TextColor3 = Color3.new(0, 0, 0),
	TextScaled = true,
	TextWrapped = true,
	TextSize = 14,
})

gui[`TextLabel7`] = screen:CreateElement('TextLabel', {
	Name = [[TextLabel7]],
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	RichText = true,
	Text = [[Reset Keyboard Event]],
	TextColor3 = Color3.new(0, 0, 0),
	TextScaled = true,
	TextWrapped = true,
	TextSize = 14,
})

gui[`logoutbutton`] = screen:CreateElement('ImageButton', {
	Name = [[logoutbutton]],
	BorderSizePixel = 0,
	Size = UDim2.new(0.25, 0, 1, 0),
	Position = UDim2.new(0.5, 0, 0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	Image = [[http://www.roblox.com/asset/?id=15625805900]],
	PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
})

gui[`resetkeyboardinput`] = screen:CreateElement('ImageButton', {
	Name = [[Reset Keyboard Event]],
	BorderSizePixel = 0,
	Size = UDim2.new(0.25, 0, 1, 0),
	Position = UDim2.new(0.75, 0, 0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	Image = [[http://www.roblox.com/asset/?id=15625805900]],
	PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
})

gui[`StatusFrame`] = screen:CreateElement('Frame', {
	Name = [[StatusFrame]],
	BorderSizePixel = 0,
	BackgroundTransparency = 0.5,
	Size = UDim2.new(1, 0, 0.10038609802722931, 0),
	Position = UDim2.new(0, 0, 0.8996139168739319, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
})

gui[`ImageLabel`] = screen:CreateElement('ImageLabel', {
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	Image = [[rbxassetid://15940016124]],
})
gui[`signupbutton`]:AddChild(gui[`TextLabel4`])
gui[`ImageLabel`]:AddChild(gui[`signupbutton`])
gui[`managebutton`]:AddChild(gui[`TextLabel2`])
gui[`StatusFrame`]:AddChild(gui[`Username`])
gui[`transactionbutton`]:AddChild(gui[`TextLabel5`])
gui[`miningbutton`]:AddChild(gui[`TextLabel3`])
gui[`signinbutton`]:AddChild(gui[`TextLabel`])
gui[`ImageLabel`]:AddChild(gui[`MainFrame`])
gui[`ImageLabel`]:AddChild(gui[`transactionbutton`])
gui[`ImageLabel`]:AddChild(gui[`miningbutton`])
gui[`ImageLabel`]:AddChild(gui[`signinbutton`])
gui[`ImageLabel`]:AddChild(gui[`managebutton`])
gui[`logoutbutton`]:AddChild(gui[`TextLabel6`])
gui[`StatusFrame`]:AddChild(gui[`logoutbutton`])
gui[`StatusFrame`]:AddChild(gui[`resetkeyboardinput`])
gui[`resetkeyboardinput`]:AddChild(gui[`TextLabel7`])
gui[`ImageLabel`]:AddChild(gui[`StatusFrame`])

local signinbutton = gui["signinbutton"]
local signupbutton = gui["signupbutton"]
local managebutton = gui["managebutton"]
local miningbutton = gui["miningbutton"]
local transactionbutton = gui["transactionbutton"]
local mainFrame = gui["MainFrame"]

local window = CreateWindow(UDim2.new(0.7, 0, 0.7, 0), "Bluecoin ATM", false, false, false, "Bluecoin ATM", false)
window:AddChild(gui["ImageLabel"])

local mainframeelements = {}
local availableComponents = {["keyboard"] = Keyboard, ["modem"] = Modem}
local funnytable = {
	account = {};
	signup = {};
	signin = {};
	mining = {};
	transaction = {};
}

local function printd(text)
	if Disk ~= nil then
		Disk:Write("error", text)
	end
end

local logContainer
local keyboardinput = ""
local player = ""

local connections = {}

local keyboardevent = keyboard:Connect("TextInputted", function(text, theplayer)
    keyboardinput = text
    player = theplayer
end)

gui["resetkeyboardinput"].MouseButton1Up:Connect(function()
    speaker:PlaySound(clicksound)
    if keyboardevent then keyboardevent:Unbind() end
    keyboardevent = keyboard:Connect("TextInputted", function(text, theplayer)
        keyboardinput = text
        player = theplayer
    end)
end)

local function errorPopup(text)
    print(text)
    local window = CreateWindow(UDim2.new(0.7, 0, 0.5, 0), "Error", false, false, false, "Error", false)
    window:AddChild(screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), Text = text, TextScaled = true, BackgroundTransparency = 1}))
    printd(text)
end

local function xSpawn(func)
	local thread = coroutine.create(func)
	coroutine.resume(thread)
	return thread
end
local loginData = {}
local errors = {
	signUp = {
		["400"] = "Account already exists.";
		["200"] = "Account created.";
	};
	transaction = {
		["404"] = "Username or pass invalid.";
		["400"] = "Username or pass invalid.";
		["407"] = "Invalid recepient.";
		["402"] = "you cant take bluecoin dingus";
		["401"] = "Insufficient bluecoin.";
		["200"] = "Transaction successful.";
	};
	checkBalance = {
		["E407"] = "Username or pass invalid.";
		["E406"] = "Username or pass invalid.";
	}
}
local function send(content)
    local Data
    local Success
    if Modem then
    	Data, Success = Modem:RealPostRequest("https://darkbluestealth.pythonanywhere.com", content, false, buh, {["Content-Type"]="application/json"})
	else
	    errorPopup("You need a modem.")
	end
	printd(Data)
	return Data, Success
end
local function transaction(recepient, amount)
	if loginData.Username ~= nil and loginData.Password ~= nil then
		local Content = JSONEncode({Method="Transaction",Username=loginData.Username,Password=loginData.Password,ReceivingUser=recepient,Amount=amount})
		local data, success = send(Content)
		errorPopup(errors.transaction[data] or data)
	end
end
local function checkBalance()
	if loginData.Username ~= nil and loginData.Password ~= nil then
		local Content = JSONEncode({Method="CheckBalance",Username=loginData.Username,Password=loginData.Password})
		local data, success = send(Content)
		if errors.checkBalance[data] == nil then
			return data
		else
			errorPopup(errors.checkBalance[data] or data)
		end
	else
		errorPopup("You're not logged in!")
		return "You're not logged in!"
	end
end
local function accountExists(username)
	local Content = JSONEncode({Method="AccountValid",Username=username})
	local data, success = send(Content)
	if data == "True" then
		return true
	else
		return false
	end
end
local function signUp(username, password)
	local Content = JSONEncode({Method="Signup",Username=username,Password=password})
	local data, success = send(Content)
	printd(data)
	errorPopup(errors.signUp[data] or data)
end
local function signIn(username, password)
	local Content = JSONEncode({Method="VerifyUser",Username=username,Password=password})
	local data, success = send(Content)
	if data == "True" then
		loginData = {Username = username, Password = password}
		gui["Username"].Text = username
		print(username, password)
	else
		printd(data)
		errorPopup("Username or pass is invalid.")
	end
end
local function deleteAccount(username, password)
	local Content = JSONEncode({Method="DeleteAccount",Username=username,Password=password})
	local data, success = send(Content)
	local accountvalid = accountExists(username)
	if accountvalid == false then
		loginData = {}
		gui["Username"].Text = "You're not logged in!"
		print(username, password)
	else
		printd(data)
		errorPopup("Not logged in.")
	end
end
local function changePassword(newPassword)
	if loginData ~= nil then
		local Content = JSONEncode({Method="ChangePassword",Username=loginData.Username,Password=loginData.Password,NewPassword = newPassword})
		local data, success = send(Content)
		return data
	else
		return "You're not logged in!"
	end
end
local function logOut()
	loginData = {}
	gui["Username"].Text = "You're not logged in!"
end
local function bluecoinMiner(username)
	local success, err = pcall(function()
		--MADE BY BLUELOOPS9 FOR BLUECOIN
		--Made in 2023.
		--Have fun mining BlueCoin!


		--This is for the SHA-256 algorithm.
		local mod = 2^32
		local modm = mod-1

		local function memoize(f)
			local mt = {}
			local t = setmetatable({}, mt)
			function mt:__index(k)
				local v = f(k)
				t[k] = v
				return v
			end
			return t
		end

		local function make_bitop_uncached(t, m)
			local function bitop(a, b)
				local res,p = 0,1
				while a ~= 0 and b ~= 0 do
					local am, bm = a % m, b % m
					res = res + t[am][bm] * p
					a = (a - am) / m
					b = (b - bm) / m
					p = p*m
				end
				res = res + (a + b) * p
				return res
			end
			return bitop
		end

		local function make_bitop(t)
			local op1 = make_bitop_uncached(t,2^1)
			local op2 = memoize(function(a) return memoize(function(b) return op1(a, b) end) end)
			return make_bitop_uncached(op2, 2 ^ (t.n or 1))
		end

		local bxor1 = make_bitop({[0] = {[0] = 0,[1] = 1}, [1] = {[0] = 1, [1] = 0}, n = 4})

		local function bxor(a, b, c, ...)
			local z = nil
			if b then
				a = a % mod
				b = b % mod
				z = bxor1(a, b)
				if c then z = bxor(z, c, ...) end
				return z
			elseif a then return a % mod
			else return 0 end
		end

		local function band(a, b, c, ...)
			local z
			if b then
				a = a % mod
				b = b % mod
				z = ((a + b) - bxor1(a,b)) / 2
				if c then z = bit32_band(z, c, ...) end
				return z
			elseif a then return a % mod
			else return modm end
		end

		local function bnot(x) return (-1 - x) % mod end

		local function rshift1(a, disp)
			if disp < 0 then return lshift(a,-disp) end
			return math.floor(a % 2 ^ 32 / 2 ^ disp)
		end

		local function rshift(x, disp)
			if disp > 31 or disp < -31 then return 0 end
			return rshift1(x % mod, disp)
		end

		local function lshift(a, disp)
			if disp < 0 then return rshift(a,-disp) end
			return (a * 2 ^ disp) % 2 ^ 32
		end

		local function rrotate(x, disp)
			x = x % mod
			disp = disp % 32
			local low = band(x, 2 ^ disp - 1)
			return rshift(x, disp) + lshift(low, 32 - disp)
		end

		local k = {
			0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
			0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
			0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
			0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
			0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
			0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
			0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
			0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
			0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
			0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
			0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
			0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
			0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
			0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
			0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
			0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
		}

		local function str2hexa(s)
			return (string.gsub(s, ".", function(c) return string.format("%02x", string.byte(c)) end))
		end

		local function num2s(l, n)
			local s = ""
			for i = 1, n do
				local rem = l % 256
				s = string.char(rem) .. s
				l = (l - rem) / 256
			end
			return s
		end

		local function s232num(s, i)
			local n = 0
			for i = i, i + 3 do n = n*256 + string.byte(s, i) end
			return n
		end

		local function preproc(msg, len)
			local extra = 64 - ((len + 9) % 64)
			len = num2s(8 * len, 8)
			msg = msg .. "\128" .. string.rep("\0", extra) .. len
			assert(#msg % 64 == 0)
			return msg
		end

		local function InitH256(H)
			H[1] = 0x6a09e667
			H[2] = 0xbb67ae85
			H[3] = 0x3c6ef372
			H[4] = 0xa54ff53a
			H[5] = 0x510e527f
			H[6] = 0x9b05688c
			H[7] = 0x1f83d9ab
			H[8] = 0x5be0cd19
			return H
		end

		local function DigestBlock(msg, i, H)
			local w = {}
			for j = 1, 16 do w[j] = s232num(msg, i + (j - 1)*4) end
			for j = 17, 64 do
				local v = w[j - 15]
				local s0 = bxor(rrotate(v, 7), rrotate(v, 18), rshift(v, 3))
				v = w[j - 2]
				w[j] = w[j - 16] + s0 + w[j - 7] + bxor(rrotate(v, 17), rrotate(v, 19), rshift(v, 10))
			end

			local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
			for i = 1, 64 do
				local s0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
				local maj = bxor(band(a, b), band(a, c), band(b, c))
				local t2 = s0 + maj
				local s1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
				local ch = bxor (band(e, f), band(bnot(e), g))
				local t1 = h + s1 + ch + k[i] + w[i]
				h, g, f, e, d, c, b, a = g, f, e, d + t1, c, b, a, t1 + t2
			end

			H[1] = band(H[1] + a)
			H[2] = band(H[2] + b)
			H[3] = band(H[3] + c)
			H[4] = band(H[4] + d)
			H[5] = band(H[5] + e)
			H[6] = band(H[6] + f)
			H[7] = band(H[7] + g)
			H[8] = band(H[8] + h)
		end

		local function SHA256(msg)
			msg = preproc(msg, #msg)
			local H = InitH256({})
			for i = 1, #msg, 64 do DigestBlock(msg, i, H) end
			return str2hexa(num2s(H[1], 4) .. num2s(H[2], 4) .. num2s(H[3], 4) .. num2s(H[4], 4)
				.. num2s(H[5], 4) .. num2s(H[6], 4) .. num2s(H[7], 4) .. num2s(H[8], 4))
		end
		local function output(text)
			if #minerLog <= 10 then
				minerLog[#minerLog + 1] = text
				return #minerLog
			else
				minerLog[1] = nil
				for i, v in pairs(minerLog) do
					if i >= 2 and i <= 11 then
						minerLog[i - 1] = minerLog[i]
					end
				end
				minerLog[11] = text
				return 11
			end
		end
		output("Bootup sequence...")
		local Hash = "None"
		local Nonce = 0
		local Username = username
		local Wait = true
		local SHAED = ""
		local Content2 = ""
		local RealMethod = false
		output("Global variables initialized.")
		--This checks if the hash it has is the current one.
		coroutine.resume(coroutine.create(function()
			while wait(5) do
				local Content = JSONEncode({Method="CheckHash",Hash=Hash})
				--Yes this has my website, but you can find my location with it because its not on my RPi4 anymore :>
				local Data, Success = Modem:RealPostRequest("https://darkbluestealth.pythonanywhere.com", Content, false, buh, {["Content-Type"]="application/json"})
				if Data ~= "405" then
					Hash = Data
					Nonce = 0
					Wait = false
					output("New hash found.")
				end
			end
		end))
		output("Hash receiver initialized")
		--The main algorithm.
		output("Beginning main loop.")
		while task.wait() do
			SHAED = SHA256(Hash..Nonce)
			if SHAED:sub(1,3) == "000" and not Wait then
				print(SHAED)
				Wait = true
				Content2 = JSONEncode({Hash=Hash,Nonce=Nonce,Username=Username,Outcome=SHAED,Method="FoundHash"})
				local Data2, Success = Modem:RealPostRequest("https://darkbluestealth.pythonanywhere.com", Content2, false, buh, {["Content-Type"]="application/json"})
				if Data2 == "100" then
					output("Number found! One morsel of bluecoin added.")
				end
				if Data2 == "402" then
					Wait = false
					output("Invalid?")
				end
				if Data2 == "403" then
					Wait = false
					output("Invalid hash.")
				end
			end
			Nonce = tostring(math.random(0,99999999))
		end
		output("Loop halted")
		--GiB ME BlUECoIN At blueloops9
	end)
	if success == false then
		errorPopup(err)
	end
end
local function startMining()
	if loginData.Username ~= nil then
		if minerInstance ~= nil then
			coroutine.close(minerInstance)
		end
		minerInstance = coroutine.create(function()
			local dingus, doofus = pcall(function()
				bluecoinMiner(loginData.Username)
			end)
			if dingus == false then
				errorPopup(doofus)
			end
		end)
		coroutine.resume(minerInstance)
	else
		errorPopup("You're not logged in!")
	end
end
local function stopMining()
	if minerInstance ~= nil then
		coroutine.close(minerInstance)
	end
end

local function ClearElements()
    logContainer = nil
	for index, value in ipairs(mainframeelements) do
		value:Destroy()
	end
	mainframeelements = {}
end

gui["Username"].Text = loginData.Username or "You're not logged in!"

local function createButton(text, size, pos)
   local button = screen:CreateElement('ImageButton', {
		Name = text,
		BorderSizePixel = 0,
		Size = size,
		Position = pos,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		Image = [[http://www.roblox.com/asset/?id=15625805900]],
		PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
	})

	local textlabel = screen:CreateElement("TextLabel", {Text = text, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true})
	button:AddChild(textlabel)
	mainFrame:AddChild(button)
	table.insert(mainframeelements, button)
	return button, textlabel
end

local function CreateElement(name, properties)
    local object = screen:CreateElement(name, properties)
    table.insert(mainframeelements, object)
	mainFrame:AddChild(object)
	return object
end

local function openAccountManagement()
	local success, err = pcall(function()
		ClearElements()
		funnytable.signup.focused = nil
		funnytable.signin.focused = nil
		funnytable.transaction.focused = nil
		log = nil
		local accountName = loginData.Username or "You're not logged in!"
		local textlabel1 = screen:CreateElement("TextLabel", {
			Text = accountName;
			TextScaled = true;
			TextColor3 = Color3.fromRGB(255,255,255);
			BackgroundTransparency = 1;
			Size = UDim2.fromScale(1, 0.2);
			Position = UDim2.fromOffset(0, 0);
			TextXAlignment = Enum.TextXAlignment.Left;
		})
		table.insert(mainframeelements, textlabel1)
		mainFrame:AddChild(textlabel1)
		local logoutbutton = createButton("Logout", UDim2.new(0.25, 0, 0.25, 0), UDim2.new(0, 0, 0.65, 0))
		logoutbutton.MouseButton1Click:Connect(function()
			logOut()
			openAccountManagement()
			speaker:PlaySound(clicksound)
		end)
		local changepasswordbutton = createButton("Change Access Code", UDim2.new(0.5, 0, 0.25, 0), UDim2.new(0.5, 0, 0.65, 0))
		changepasswordbutton.MouseButton1Click:Connect(function()
		    speaker:PlaySound(clicksound)
			local window, holderframe = CreateWindow(UDim2.fromScale(0.5, 0.5), "Change Access Code", false, false, false, "Change Access Code", false)
			window:AddChild(screen:CreateElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.25);
				Position = UDim2.fromScale(0, 0);
				Text = "New Access Code:";
				TextScaled = true;
				BackgroundTransparency = 1;
			}))
			local newPassword = nil
			local newPasswordLabel, text1 = createButton("Click to Update", UDim2.fromScale(1, 0.25), UDim2.fromScale(0, 0.25))
			window:AddChild(newPasswordLabel)
			local confirm = createButton("Confirm", UDim2.new(1, 0, 0.25, 0), UDim2.new(0, 0, 0.75, 0))
			window:AddChild(confirm)
			confirm.MouseButton1Click:Connect(function()
				if newPassword ~= nil then
					changePassword(newPassword)
					holderframe:Destroy()
				end
				speaker:PlaySound(clicksound)
			end)
			newPasswordLabel.MouseButton1Up:Connect(function()
				text = string.sub(keyboardinput, 1, #keyboardinput - 1)
				if window ~= nil then
					newPassword = text
					local passwordtext = ""
            	    for i=0, string.len(newPassword) do
            	        if i > 0 then
                            passwordtext = passwordtext.."*"
            	        end
                    end
					text1:ChangeProperties({Text = passwordtext})
    			end
    			speaker:PlaySound(clicksound)
			end)
	    end)
	    local deleteaccountbutton = createButton("Delete Account", UDim2.new(0.25, 0, 0.25, 0), UDim2.new(0.25, 0, 0.65, 0))
	    deleteaccountbutton.MouseButton1Click:Connect(function()
            speaker:PlaySound(clicksound)
            local window, holderframe = CreateWindow(UDim2.fromScale(0.5, 0.5), "Delete Account", false, false, false, "Delete Account", false)
			window:AddChild(screen:CreateElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.75);
				Position = UDim2.fromScale(0, 0);
				Text = "Are you sure?";
				TextScaled = true;
				BackgroundTransparency = 1;
			}))
			local confirm = createButton("Yes", UDim2.new(0.5, 0, 0.25, 0), UDim2.new(0, 0, 0.75, 0))
			window:AddChild(confirm)
			confirm.MouseButton1Click:Connect(function()
			    speaker:PlaySound(clicksound)
				deleteAccount(loginData["Username"] or "", loginData["Password"] or "")
				holderframe:Destroy()
			end)
			local cancel = createButton("No", UDim2.new(0.5, 0, 0.25, 0), UDim2.new(0.5, 0, 0.75, 0))
			window:AddChild(cancel)
			cancel.MouseButton1Click:Connect(function()
				holderframe:Destroy()
				speaker:PlaySound(clicksound)
			end)
        end)
		local balance = tostring(checkBalance()) or "N/A"
		local balanceText = screen:CreateElement("TextLabel", {
			Text = balance;
			TextScaled = true;
			BackgroundTransparency = 1;
			Size = UDim2.fromScale(1, 0.2);
			Position = UDim2.fromScale(0, 0.2);
			TextColor3 = Color3.fromRGB(255,255,255);
			TextXAlignment = Enum.TextXAlignment.Left;
		})
		table.insert(mainframeelements, balanceText)
		mainFrame:AddChild(balanceText)
		local refreshBalance = createButton("Refresh Balance", UDim2.new(1, 0, 0.15, 0), UDim2.new(0, 0, 0.5, 0))
		refreshBalance.MouseButton1Click:Connect(function()
			balance = tostring(checkBalance()) or "N/A"
			balanceText:ChangeProperties({Text = balance})
			speaker:PlaySound(clicksound)
		end)
	end)
	if success == false then
		printd(err)
	end
end

local function openSignUp()
    if not loginData["Username"] then
    else
        openAccountManagement()
        errorPopup("You're already signed in")
        return
    end
	ClearElements()
	funnytable.signup.focused = nil
	funnytable.signin.focused = nil
	funnytable.transaction.focused = nil
	log = nil
	CreateElement("TextLabel", {
		Size = UDim2.fromScale(1, 0.15);
		Position = UDim2.fromScale(0, 0);
		Text = "Username:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	CreateElement("TextLabel", {
		Size = UDim2.fromScale(1, 0.15);
		Position = UDim2.fromScale(0, 0.3);
		Text = "Access Code:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	local passwordHidden = ""
	if funnytable.signup.Password ~= nil then
		for i = 1, #funnytable.signup.Password, 1 do
			passwordHidden = passwordHidden .. "*"
		end
	end
	local usernameButton, text1 = createButton(funnytable.signup.Username or "", UDim2.fromScale(1, 0.15), UDim2.fromScale(0, 0.15))
	local passwordButton, text2 = createButton(passwordHidden, UDim2.fromScale(1, 0.15), UDim2.fromScale(0, 0.45))
	local confirm = createButton("Sign up", UDim2.fromScale(1, 0.15), UDim2.fromScale(0, 0.6))
	confirm.MouseButton1Click:Connect(function()
		signUp(funnytable.signup.Username or "", funnytable.signup.Password or "")
		speaker:PlaySound(clicksound)
	end)
	usernameButton.MouseButton1Click:Connect(function()
		funnytable.signup.focused = "username"
		text1.Text = string.sub(keyboardinput, 1, #keyboardinput - 1)
		funnytable.signup.Username = string.sub(keyboardinput, 1, #keyboardinput - 1)
		speaker:PlaySound(clicksound)
	end)
	passwordButton.MouseButton1Click:Connect(function()
		funnytable.signup.focused = "password"
		local passwordtext = ""
	    for i=0, string.len(string.sub(keyboardinput, 1, #keyboardinput - 1)) do
	        if i > 0 then
                passwordtext = passwordtext.."*"
	        end
        end
        text2.Text = passwordtext
        funnytable.signup.Password = string.sub(keyboardinput, 1, #keyboardinput - 1)
        speaker:PlaySound(clicksound)
	end)
end

local function openSignIn()
    if not loginData["Username"] then
    else
        openAccountManagement()
        errorPopup("You're already signed in")
        return
    end

	ClearElements()
	funnytable.signup.focused = nil
	funnytable.signin.focused = nil
	funnytable.transaction.focused = nil
	log = nil
	CreateElement("TextLabel", {
		Size = UDim2.fromScale(1, 0.15);
		Position = UDim2.fromScale(0, 0);
		Text = "Username:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	CreateElement("TextLabel", {
		Size = UDim2.fromScale(1, 0.15);
		Position = UDim2.fromScale(0, 0.3);
		Text = "Access Code:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	local usernameButton, text1 = createButton(funnytable.signin.Username or "", UDim2.fromScale(1, 0.15), UDim2.fromScale(0, 0.15))
	local passwordHidden = ""
	if funnytable.signin.Password ~= nil then
		for i = 1, #funnytable.signin.Password, 1 do
			passwordHidden = passwordHidden .. "*"
		end
	end
	local passwordButton, text2 = createButton(passwordHidden, UDim2.fromScale(1, 0.15), UDim2.fromScale(0, 0.45))
	local confirm = createButton("Sign in", UDim2.fromScale(1, 0.15), UDim2.fromScale(0, 0.6))
	confirm.MouseButton1Click:Connect(function()
		signIn(funnytable.signin.Username or "", funnytable.signin.Password or "")
		speaker:PlaySound(clicksound)
		if loginData["Username"] then
		    openAccountManagement()
	    end
	end)
	usernameButton.MouseButton1Click:Connect(function()
		funnytable.signin.focused = "username"
		text1.Text = string.sub(keyboardinput, 1, #keyboardinput - 1)
		funnytable.signin.Username = string.sub(keyboardinput, 1, #keyboardinput - 1)
		speaker:PlaySound(clicksound)
	end)
	passwordButton.MouseButton1Click:Connect(function()
	    local passwordtext = ""
	    for i=0, string.len(string.sub(keyboardinput, 1, #keyboardinput - 1)) do
	        if i > 0 then
                passwordtext = passwordtext.."*"
	        end
        end
	    text2.Text = passwordtext
	    funnytable.signin.Password = string.sub(keyboardinput, 1, #keyboardinput - 1)
	    speaker:PlaySound(clicksound)
	end)
end

gui["logoutbutton"].MouseButton1Up:Connect(function()
	logOut()
	openAccountManagement()
	speaker:PlaySound(clicksound)
end)

local function openMining()
	ClearElements()
	funnytable.signup.focused = nil
	funnytable.signin.focused = nil
	funnytable.transaction.focused = nil
	log = nil
	local startButton = screen:CreateElement('ImageButton', {
		Name = "Start mining",
		BorderSizePixel = 0,
		Size = UDim2.new(0.3, 0, 0.3, 0),
		Position = UDim2.new(0.7, 0, 0, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		Image = [[http://www.roblox.com/asset/?id=15625805900]],
		PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
	})
	startButton:AddChild(screen:CreateElement("TextLabel", {Text = "Start Mining", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true}))
	mainFrame:AddChild(startButton)
	table.insert(mainframeelements, startButton)


	local stopButton = screen:CreateElement('ImageButton', {
		Name = "Stop mining",
		BorderSizePixel = 0,
		Size = UDim2.new(0.3, 0, 0.3, 0),
		Position = UDim2.new(0.7, 0, 0.3, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		Image = [[http://www.roblox.com/asset/?id=15625805900]],
		PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
	})
	mainFrame:AddChild(stopButton)
	table.insert(mainframeelements, stopButton)
	stopButton:AddChild(screen:CreateElement("TextLabel", {Text = "Stop Mining", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true}))

	logContainer = CreateElement("ScrollingFrame", {
		Size = UDim2.fromScale(0.7, 0.9);
		Position = UDim2.fromScale(0, 0);
	    BackgroundTransparency = 1;
	    CanvasSize = UDim2.new(0,0,0,0);
		BorderSizePixel = 0;
	})
	mainFrame:AddChild(logContainer)
	table.insert(mainframeelements, logContainer)
	log = screen:CreateElement("Frame", {
		Size = UDim2.fromScale(1, 1);
		Position = UDim2.fromScale(0, 0);
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
	})

	logContainer:AddChild(log)
	local logtextcontainer
	startButton.MouseButton1Click:Connect(function()
	    speaker:PlaySound(clicksound)
		if minerInstance ~= nil then
			if coroutine.status(minerInstance) ~= "running" then
				minerLog = {}
				if miningUIUpdater ~= nil then
					coroutine.close(miningUIUpdater)
				end
				miningUIUpdater = coroutine.create(function()
					while true do
						wait(0.5)
						if log ~= nil then
							wait(0.1)
							if logContainer ~= nil then
								wait(0.1)
								log:Destroy()

								    if logContainer then
    									log = screen:CreateElement("Frame", {
                                    		Size = UDim2.fromScale(1, 1);
                                    		Position = UDim2.fromScale(0, 0);
                                    		BackgroundTransparency = 1;
                                    		BorderSizePixel = 0;
                                    	})

                                    	logContainer:AddChild(log)
                                	end
							end
							wait(0.1)
							if logtextcontainer then
					            logtextcontainer:Destroy()
					        end
					        if logContainer then
    					        logtextcontainer = screen:CreateElement("Frame", {
                            		Size = UDim2.fromScale(1, 1);
                            		Position = UDim2.fromScale(0, 0);
                            		BackgroundTransparency = 1;
                            		BorderSizePixel = 0;
                            	})
                                logContainer:AddChild(logtextcontainer)
    							for i, v in pairs(minerLog) do
    							    if logContainer then
    							        if logtext then
    							            logtext:Destroy()
    							        end
    							        local logtext = screen:CreateElement("TextLabel", {
        									Text = v;
        									TextScaled = true;
        									TextColor3 = Color3.fromRGB(0,0,0);
        									BackgroundTransparency = 1;
        									BorderSizePixel = 0;
        									Size = UDim2.new(1, 0, 0, 10);
        									Position = UDim2.fromOffset(0, (i - 1) * 10);
        									TextXAlignment = Enum.TextXAlignment.Left;
        								})
        								logContainer.CanvasSize = UDim2.fromOffset(0, ((i - 1) * 10) + 10)
        								logtextcontainer:AddChild(logtext)
    								end
    					        end
					    	end
				    	else
							printd("log is nil")
						end
					end
				end)
				coroutine.resume(miningUIUpdater)
				startMining()
			end
		else
			minerLog = {}
			if miningUIUpdater ~= nil then
				coroutine.close(miningUIUpdater)
			end
			miningUIUpdater = coroutine.create(function()
				while true do
					wait(0.5)
					if log ~= nil then
						log:Destroy()
						if logContainer then
    						log = screen:CreateElement("Frame", {
                        		Size = UDim2.fromScale(1, 1);
                        		Position = UDim2.fromScale(0, 0);
                        		BackgroundTransparency = 1;
                        		BorderSizePixel = 0;
                        	})

                        	logContainer:AddChild(log)
                    	end
					end
					for i, v in pairs(minerLog) do
					    if logContainer then
    						log:AddChild(screen:CreateElement("TextLabel", {
    							Text = v;
    							TextScaled = true;
    							TextColor3 = Color3.fromRGB(0,0,0);
    							BackgroundTransparency = 1;
    							BorderSizePixel = 0;
    							Size = UDim2.new(1, 0, 0, 10);
    							Position = UDim2.fromOffset(0, (i - 1) * 10);
    							TextXAlignment = Enum.TextXAlignment.Left;
    						}))
    						logContainer.CanvasSize = UDim2.fromOffset(0, ((i - 1) * 10) + 10)
						end
					end
				end
			end)
			coroutine.resume(miningUIUpdater)
			startMining()
		end
	end)
	stopButton.MouseButton1Click:Connect(function()
	    speaker:PlaySound(clicksound)
		if miningUIUpdater ~= nil then
			coroutine.close(miningUIUpdater)
			stopMining()
			if logContainer ~= nil then
			    if logtextcontainer then
            	    logtextcontainer:Destroy()
        	    end
				log:Destroy()
				log = screen:CreateElement("Frame", {
            		Size = UDim2.fromScale(1, 1);
            		Position = UDim2.fromScale(0, 0);
            		BackgroundTransparency = 1;
            		BorderSizePixel = 0;
            	})

            	logContainer:AddChild(log)
			end
			minerLog = {}
		end
	end)
end

local function openTransaction()
	ClearElements()
	funnytable.signup.focused = nil
	funnytable.signin.focused = nil
	funnytable.transaction.focused = nil
	log = nil
	local frame1 = screen:CreateElement("TextLabel", {
		Size = UDim2.fromScale(0.7, 0.3);
		Position = UDim2.fromScale(0, 0);
		Text = "Recepient:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	table.insert(mainframeelements, frame1)
	local frame2 = screen:CreateElement("TextLabel", {
		Size = UDim2.fromScale(0.7, 0.3);
		Position = UDim2.fromScale(0, 0.3);
		Text = "Amount:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	table.insert(mainframeelements, frame2)

	mainFrame:AddChild(frame1)
	mainFrame:AddChild(frame2)

	local recepientButton, text1 = createButton(funnytable.transaction.recepient or "", UDim2.new(0.3, 0, 0.3, 0), UDim2.new(0.7, 0, 0, 0))
	local amountButton, text2 = createButton(funnytable.transaction.amount or "", UDim2.new(0.3, 0, 0.3, 0), UDim2.new(0.7, 0, 0.3, 0))
	local confirm = createButton("Confirm", UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.7, 0))

	confirm.MouseButton1Click:Connect(function()
		transaction(funnytable.transaction.recepient or "", funnytable.transaction.amount or "")
		speaker:PlaySound(clicksound)
	end)
	recepientButton.MouseButton1Click:Connect(function()
		funnytable.transaction.focused = "recepient"
		text1.Text = string.sub(keyboardinput, 1, #keyboardinput - 1)
		speaker:PlaySound(clicksound)
		funnytable.transaction.recepient = string.sub(keyboardinput, 1, #keyboardinput - 1)
	end)
	amountButton.MouseButton1Click:Connect(function()
		funnytable.transaction.focused = "amount"
		text2.Text = string.sub(keyboardinput, 1, #keyboardinput - 1)
		speaker:PlaySound(clicksound)
		funnytable.transaction.amount = string.sub(keyboardinput, 1, #keyboardinput - 1)
	end)
end

managebutton.MouseButton1Click:Connect(function()
	openAccountManagement()
	speaker:PlaySound(clicksound)
end)
signinbutton.MouseButton1Click:Connect(function()
	openSignIn()
	speaker:PlaySound(clicksound)
end)
signupbutton.MouseButton1Click:Connect(function()
	openSignUp()
	speaker:PlaySound(clicksound)
end)
miningbutton.MouseButton1Click:Connect(function()
	openMining()
	speaker:PlaySound(clicksound)
end)
transactionbutton.MouseButton1Click:Connect(function()
	openTransaction()
	speaker:PlaySound(clicksound)
end)

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
