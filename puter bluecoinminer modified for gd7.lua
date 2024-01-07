--OG atm made by blueloops9
--this GUI version made by robloxboxertBLOCKED / 0mori2
--*Cough cough* All rights reserved.
-- Made in 2023.
--Modified to work on GustavOSDesktop7

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
local minerLog = {}
local minerInstance
local log
local function printd(text)
	if GetPartFromPort(10, "Disk") ~= nil then
		GetPartFromPort(10, "Disk"):Write("error", text)
	end
end
local gputer = GetPartFromPort(1, "Disk"):Read("GD7Library")
local Modem = gputer.Modem
local programholder1 = gputer.programholder1
local programholder2 = gputer.programholder2
local Sign = GetPartFromPort(1, "Sign")
local Screen = gputer.Screen
local Keyboard = gputer.Keyboard
local holding
local holding2
local holderframetouse
local startCursorPos
local uiStartPos
local clicksound = GetPartFromPort(1, "Disk"):Read("ClickSound") or "rbxassetid://6977010128"
if tonumber(clicksound) then clicksound = "rbxassetid://"..clicksound end

local function CreateWindow(udim2, title, boolean, boolean2, boolean3)
	local holderframe = Screen:CreateElement("ImageButton", {Size = udim2, BackgroundTransparency = 1, Image = "rbxassetid://8677487226", ImageTransparency = 0.2})
	programholder1:AddChild(holderframe)
	local textlabel
	if typeof(title) == "string" then
		textlabel = Screen:CreateElement("TextLabel", {Size = UDim2.new(1, -(defaultbuttonsize.X*2), 0, defaultbuttonsize.Y), BackgroundTransparency = 1, Position = UDim2.new(0, defaultbuttonsize.X*2, 0, 0), TextScaled = true, TextWrapped = true, Text = tostring(title)})
		holderframe:AddChild(textlabel)
	end
	local resizebutton
	local maximizepressed = false
	if not boolean2 then
		resizebutton = Screen:CreateElement("ImageButton", {Size = UDim2.new(0,defaultbuttonsize.Y/2,0,defaultbuttonsize.Y/2), Image = "rbxassetid://15617867263", Position = UDim2.new(1, -defaultbuttonsize.Y/2, 1, -defaultbuttonsize.Y/2), BackgroundTransparency = 1})
		holderframe:AddChild(resizebutton)
		
		resizebutton.MouseButton1Down:Connect(function()
			resizebutton.Image = "rbxassetid://15617866125"
			if holding2 then return end
			if not maximizepressed then
				local cursors = Screen:GetCursors()
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
	end

	if not boolean3 then
	
		holderframe.MouseButton1Down:Connect(function()
			if holding then return end
			programholder2:AddChild(holderframe)
			programholder1:AddChild(holderframe)
			if maximizepressed then return end
			local cursors = Screen:GetCursors()
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

	local closebutton = Screen:CreateElement("ImageButton", {BackgroundTransparency = 1, Size = UDim2.new(0, defaultbuttonsize.X, 0, defaultbuttonsize.Y), BackgroundColor3 = Color3.new(1,0,0), Image = "rbxassetid://15617983488"})
	holderframe:AddChild(closebutton)
	
	closebutton.MouseButton1Down:Connect(function()
		closebutton.Image = "rbxassetid://15617984474"
	end)
	
	closebutton.MouseButton1Up:Connect(function()
		closebutton.Image = "rbxassetid://15617983488"
		Speaker:PlaySound(clicksound)
		holderframe:Destroy()
		holderframe = nil
	end)

	local maximizebutton
	
	if not boolean then
		maximizebutton = Screen:CreateElement("ImageButton", {Size = UDim2.new(0,defaultbuttonsize.X,0,defaultbuttonsize.Y), Image = "rbxassetid://15617867263", Position = UDim2.new(0, defaultbuttonsize.X, 0, 0), BackgroundTransparency = 1})
		local maximizetext = Screen:CreateElement("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextScaled = true, TextWrapped = true, Text = "+"})
		maximizebutton:AddChild(maximizetext)
		
		holderframe:AddChild(maximizebutton)
		local unmaximizedsize = holderframe.Size
		
		maximizebutton.MouseButton1Down:Connect(function()
			maximizebutton.Image = "rbxassetid://15617866125"
		end)
		
		maximizebutton.MouseButton1Up:Connect(function()
			if holding or holding2 then return end
			Speaker:PlaySound(clicksound)
			maximizebutton.Image = "rbxassetid://15617867263"
			local holderframe = holderframe
			if not maximizepressed then
				unmaximizedsize = holderframe.Size
				holderframe.Size = UDim2.new(1, 0, 0.9, 0)
				holderframe.Position = UDim2.new(0, 0, 1, 0)
				holderframe.Position = UDim2.new(0, 0, 0, 0)
				maximizetext.Text = "-"
				maximizepressed = true
			else
				holderframe.Size = unmaximizedsize
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
	local windowz = Screen:CreateElement("ScrollingFrame", {CanvasSize = UDim2.new(udim2.X.Scale, udim2.X.Offset,udim2.Y.Scale,udim2.Y.Offset), Size = UDim2.new(1, 0, 1, -(defaultbuttonsize.Y + (defaultbuttonsize.Y/2))), Position = UDim2.new(0, 0, 0, defaultbuttonsize.Y), BackgroundTransparency = 1})
	holderframe:AddChild(windowz)
	local window = {}
	function window:CreateElement(name, properties)
		local object = Screen:CreateElement(name, properties)
		windowz:AddChild(object)
		return object
	end
	function window:AddChild(object)
		windowz:AddChild(object)
	end
	return window, closebutton, holderframe, maximizebutton, textlabel, resizebutton
end
defaultbuttonsize = Vector2.new(screen:GetDimensions().X*(0.1 + (0.1/3)),screen:GetDimensions().Y*0.1)
if defaultbuttonsize.X > 35 then defaultbuttonsize = Vector2.new(35, defaultbuttonsize.Y); end
if defaultbuttonsize.Y > 25 then defaultbuttonsize = Vector2.new(defaultbuttonsize.X, 25); end

local function AddElement(parent, name, properties)
	local object = screen:CreateElement(name, properties)
	parent:AddChild(object)
	return object
end

local availableComponents = {["keyboard"] = Keyboard, ["modem"] = Modem}
local window, closebutton, titlebar = CreateWindow(UDim2.fromOffset(400, 225), "Bluecoin ATM")
local function errorPopup(err)
	local window, closebutton, titlebar = CreateWindow(UDim2.fromOffset(200, 100), "Info")
	window:CreateElement("TextLabel", {
		Text = err;
		TextColor3 = Color3.fromRGB(255,255,255);
		TextScaled = true;
		Size = UDim2.fromOffset(200, 100);
		Position = UDim2.fromOffset(0, 0);
	})
end
local connections = {}
local function xConnect(part, eventname, func, ID)
	if availableComponents[part] ~= nil then
		if connections[part] == nil then
			connections[part] = {}
		end
		if connections[part][eventname] == nil then
			connections[part][eventname] = {}
			availableComponents[part]:Connect(eventname, function(a, b, c, d, e, f)
				for i, v in pairs(connections[part][eventname]) do
					v(a, b, c, d, e, f)
				end
			end)
		end
		connections[part][eventname][ID or #connections[part][eventname] + 1] = func
	else	
		error("attempted to connect to event " .. eventname .. " of nil component " .. part)
	end
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
	local Data, Success = Modem:RealPostRequest("https://darkbluestealth.pythonanywhere.com", content, false, buh, {["Content-Type"]="application/json"})
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
	else
		printd(data)
		errorPopup("Username or pass invalid.")
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
local managebutton = window:CreateElement("TextButton", {
	Size = UDim2.fromOffset(80, 25);
	Position = UDim2.fromOffset(0,0);
	Text = "Account";
	TextColor3 = Color3.fromRGB(255,255,255);
	TextScaled = true;
	BackgroundColor3 = Color3.fromRGB(100,100,100);
	BorderSizePixel = 0;
})
local signinbutton = window:CreateElement("TextButton", {
	Size = UDim2.fromOffset(80, 25);
	Position = UDim2.fromOffset(80,0);
	Text = "Sign in";
	TextColor3 = Color3.fromRGB(255,255,255);
	BackgroundColor3 = Color3.fromRGB(100,100,100);
	BorderSizePixel = 0;
})
local signupbutton = window:CreateElement("TextButton", {
	Size = UDim2.fromOffset(80, 25);
	Position = UDim2.fromOffset(160,0);
	Text = "Sign up";
	TextColor3 = Color3.fromRGB(255,255,255);
	BackgroundColor3 = Color3.fromRGB(100,100,100);
	BorderSizePixel = 0;
})
local miningbutton = window:CreateElement("TextButton", {
	Size = UDim2.fromOffset(80, 25);
	Position = UDim2.fromOffset(240,0);
	Text = "Mining";
	TextColor3 = Color3.fromRGB(255,255,255);
	BackgroundColor3 = Color3.fromRGB(100,100,100);
	BorderSizePixel = 0;
})
local transactionbutton = window:CreateElement("TextButton", {
	Size = UDim2.fromOffset(80, 25);
	Position = UDim2.fromOffset(320,0);
	Text = "Transaction";
	TextColor3 = Color3.fromRGB(255,255,255);
	BackgroundColor3 = Color3.fromRGB(100,100,100);
	BorderSizePixel = 0;
})
local mainFrame = window:CreateElement("Frame", {
	Size = UDim2.fromOffset(400, 200);
	Position = UDim2.fromOffset(0,25);
	BackgroundColor3 = Color3.fromRGB(0,0,0);
	BorderSizePixel = 0;
})
local funnytable = {
	account = {};
	signup = {};
	signin = {};
	mining = {};
	transaction = {};
}
local function CreateElement(className, Properties)
	local element = window:CreateElement(className, Properties)
	mainFrame:AddChild(element)
	return element
end
local function ClearElements()
	mainFrame:Destroy()
	mainFrame = window:CreateElement("Frame", {
		Size = UDim2.fromOffset(400, 200);
		Position = UDim2.fromOffset(0,25);
		BackgroundColor3 = Color3.fromRGB(0,0,0);
		BorderSizePixel = 0;
	})
end
local function createButton(text, size, position)
	local button = CreateElement("TextButton", {
		Text = text;
		TextColor3 = Color3.fromRGB(0,0,0);
		TextScaled = true;
		BackgroundColor3 = Color3.fromRGB(255,255,255);
		Size = size;
		Position = position;
	})
	return button
end
local function openAccountManagement()
	local success, err = pcall(function()
		ClearElements()
		funnytable.signup.focused = nil
		funnytable.signin.focused = nil
		funnytable.transaction.focused = nil
		log = nil
		managebutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(0,0,0)})
		miningbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
		signinbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
		signupbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
		transactionbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
		local accountName = loginData.Username or "You're not logged in!"
		CreateElement("TextLabel", {
			Text = accountName;
			TextScaled = true;
			TextColor3 = Color3.fromRGB(255,255,255);
			BackgroundTransparency = 1;
			Size = UDim2.fromOffset(250, 25);
			Position = UDim2.fromOffset(5, 10);
			TextXAlignment = Enum.TextXAlignment.Left;
		})
		local logoutbutton = createButton("Log out", UDim2.fromOffset(50, 25), UDim2.fromOffset(260, 10))
		logoutbutton.MouseButton1Click:Connect(function()
			logOut()
			openAccountManagement()
		end)
		local changepasswordbutton = createButton("Change Pass", UDim2.fromOffset(75, 25), UDim2.fromOffset(320, 10))
		changepasswordbutton.MouseButton1Click:Connect(function()
			local window, closebutton, titlebar = CreateWindow(UDim2.fromOffset(250, 100), "Change Pass")
			window:CreateElement("TextLabel", {
				Size = UDim2.fromOffset(75, 25);
				Position = UDim2.fromOffset(20, 20);
				Text = "New Pass:";
				TextScaled = true;
				TextColor3 = Color3.fromRGB(255,255,255);
				BackgroundTransparency = 1;
			})
			local newPassword = nil
			local newPasswordLabel = window:CreateElement("TextLabel", {
				Size = UDim2.fromOffset(100, 25);
				Position = UDim2.fromOffset(120, 20);
				Text = "";
				TextScaled = true;
				TextColor3 = Color3.fromRGB(255,255,255);
				BackgroundTransparency = 1;
				TextXAlignment = Enum.TextXAlignment.Left;
			})
			local confirm = createButton("Confirm", UDim2.fromOffset(50, 25), UDim2.fromOffset(25, 55))
			window:AddChild(confirm)
			confirm.MouseButton1Click:Connect(function()
				if newPassword ~= nil then
					changePassword(newPassword)
					window:Close()
				end
			end)
			xConnect("keyboard", "TextInputted", function(text, plr)
				text = string.sub(text, 1, #text - 1)
				if window ~= nil then
					if window:Active() == true then
						newPassword = text
						newPasswordLabel:ChangeProperties({Text = newPassword})
						window:Close()
					end
				end
			end)
		end)
		local balance = tostring(checkBalance()) or "N/A"
		local balanceText = CreateElement("TextLabel", {
			Text = balance;
			TextScaled = true;
			TextColor3 = Color3.fromRGB(255,255,255);
			BackgroundTransparency = 1;
			Size = UDim2.fromOffset(200, 25);
			Position = UDim2.fromOffset(5, 45);
			TextXAlignment = Enum.TextXAlignment.Left;
		})
		local refreshBalance = createButton("Refresh", UDim2.fromOffset(50, 25), UDim2.fromOffset(320, 45))
		refreshBalance.MouseButton1Click:Connect(function()
			balance = tostring(checkBalance()) or "N/A"
			balanceText:ChangeProperties({Text = balance})
		end)
	end)
	if success == false then
		printd(err)
	end
end
local function openSignIn()
	ClearElements()
	funnytable.signup.focused = nil
	funnytable.signin.focused = nil
	funnytable.transaction.focused = nil
	log = nil
	managebutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	miningbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	signinbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(0,0,0)})
	signupbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	transactionbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	CreateElement("TextLabel", {
		Size = UDim2.fromOffset(75, 25);
		Position = UDim2.fromOffset(25, 25);
		Text = "Username:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	CreateElement("TextLabel", {
		Size = UDim2.fromOffset(75, 25);
		Position = UDim2.fromOffset(25, 60);
		Text = "Pass:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	local usernameButton = createButton(funnytable.signin.Username or "", UDim2.fromOffset(200, 25), UDim2.fromOffset(110, 25))
	local passwordHidden = ""
	if funnytable.signin.Password ~= nil then
		for i = 1, #funnytable.signin.Password, 1 do
			passwordHidden = passwordHidden .. "*"
		end
	end
	local passwordButton = createButton(passwordHidden, UDim2.fromOffset(200, 25), UDim2.fromOffset(110, 60))
	local confirm = createButton("Sign in", UDim2.fromOffset(100, 50), UDim2.fromOffset(25, 95))
	confirm.MouseButton1Click:Connect(function()
		signIn(funnytable.signin.Username or "", funnytable.signin.Password or "")
	end)
	usernameButton.MouseButton1Click:Connect(function()
		funnytable.signin.focused = "username"
		usernameButton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(0,255,0)})
		passwordButton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(255,255,255)})
	end)
	passwordButton.MouseButton1Click:Connect(function()
		funnytable.signin.focused = "password"
		usernameButton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(255,255,255)})
		passwordButton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(0,255,0)})
	end)
	xConnect("keyboard", "TextInputted", function(text, plr)
		text = string.sub(text, 1, #text - 1)
		if funnytable.signin.focused == "username" then
			funnytable.signin.Username = text
			usernameButton:ChangeProperties({Text = text})
		elseif funnytable.signin.focused == "password" then
			funnytable.signin.Password = text
			local passwordHidden = ""
			for i = 1, #text, 1 do
				passwordHidden = passwordHidden .. "*"
			end
			passwordButton:ChangeProperties({Text = passwordHidden})
		end
	end)
end
local function openSignUp()
	ClearElements()
	funnytable.signup.focused = nil
	funnytable.signin.focused = nil
	funnytable.transaction.focused = nil
	log = nil
	managebutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	miningbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	signinbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	signupbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(0,0,0)})
	transactionbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	CreateElement("TextLabel", {
		Size = UDim2.fromOffset(75, 25);
		Position = UDim2.fromOffset(25, 25);
		Text = "Username:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	CreateElement("TextLabel", {
		Size = UDim2.fromOffset(75, 25);
		Position = UDim2.fromOffset(25, 60);
		Text = "Pass:";
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
	local usernameButton = createButton(funnytable.signup.Username or "", UDim2.fromOffset(200, 25), UDim2.fromOffset(110, 25))
	local passwordButton = createButton(passwordHidden, UDim2.fromOffset(200, 25), UDim2.fromOffset(110, 60))
	local confirm = createButton("Sign up", UDim2.fromOffset(100, 50), UDim2.fromOffset(25, 95))
	confirm.MouseButton1Click:Connect(function()
		signUp(funnytable.signup.Username or "", funnytable.signup.Password or "")
	end)
	usernameButton.MouseButton1Click:Connect(function()
		funnytable.signup.focused = "username"
		usernameButton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(0,255,0)})
		passwordButton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(255,255,255)})
	end)
	passwordButton.MouseButton1Click:Connect(function()
		funnytable.signup.focused = "password"
		usernameButton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(255,255,255)})
		passwordButton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(0,255,0)})
	end)
	xConnect("keyboard", "TextInputted", function(text, plr)
		text = string.sub(text, 1, #text - 1)
		if funnytable.signup.focused == "username" then
			funnytable.signup.Username = text
			usernameButton:ChangeProperties({Text = text})
		elseif funnytable.signup.focused == "password" then
			funnytable.signup.Password = text
			local passwordHidden = ""
			for i = 1, #text, 1 do
				passwordHidden = passwordHidden .. "*"
			end
			passwordButton:ChangeProperties({Text = passwordHidden})
		end
	end, "signup")
end
local miningUIUpdater
local function openMining()
	ClearElements()
	funnytable.signup.focused = nil
	funnytable.signin.focused = nil
	funnytable.transaction.focused = nil
	log = nil
	managebutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	miningbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(0,0,0)})
	signinbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	signupbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100,100,100)})
	transactionbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	local startButton = createButton("Start mining", UDim2.fromOffset(50, 25), UDim2.fromOffset(25, 25))
	local stopButton = createButton("Stop mining", UDim2.fromOffset(50, 25), UDim2.fromOffset(85, 25))
	local logContainer = CreateElement("Frame", {
		Size = UDim2.fromOffset(150, 110);
		Position = UDim2.fromOffset(25, 60);
		BackgroundColor3 = Color3.fromRGB(255,255,255);
		BorderSizePixel = 0;
	})
	log = AddElement(logContainer, "Frame", {
		Size = UDim2.fromOffset(150, 110);
		Position = UDim2.fromOffset(0, 0);
		BackgroundColor3 = Color3.fromRGB(255,255,255);
		BorderSizePixel = 0;
	})
	startButton.MouseButton1Click:Connect(function()
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
								log = AddElement(logContainer, "Frame", {
									Size = UDim2.fromOffset(150, 110);
									Position = UDim2.fromOffset(0, 0);
									BackgroundColor3 = Color3.fromRGB(255,255,255);
									BorderSizePixel = 0;
								})
							end
							wait(0.1)
							for i, v in pairs(minerLog) do
								AddElement(log, "TextLabel", {
									Text = v;
									TextScaled = true;
									TextColor3 = Color3.fromRGB(0,0,0);
									BackgroundTransparency = 1;
									BorderSizePixel = 0;
									Size = UDim2.fromOffset(150, 10);
									Position = UDim2.fromOffset(0, (i - 1) * 10);
									TextXAlignment = Enum.TextXAlignment.Left;
								})
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
						log = AddElement(logContainer, "Frame", {
							Size = UDim2.fromOffset(150, 110);
							Position = UDim2.fromOffset(0, 0);
							BackgroundColor3 = Color3.fromRGB(255,255,255);
							BorderSizePixel = 0;
						})
					end
					for i, v in pairs(minerLog) do
						AddElement(log, "TextLabel", {
							Text = v;
							TextScaled = true;
							TextColor3 = Color3.fromRGB(0,0,0);
							BackgroundTransparency = 1;
							BorderSizePixel = 0;
							Size = UDim2.fromOffset(150, 10);
							Position = UDim2.fromOffset(0, (i - 1) * 10);
							TextXAlignment = Enum.TextXAlignment.Left;
						})
					end
				end
			end)
			coroutine.resume(miningUIUpdater)
			startMining()
		end
	end)
	stopButton.MouseButton1Click:Connect(function()
		if miningUIUpdater ~= nil then
			coroutine.close(miningUIUpdater)
			stopMining()
			if logContainer ~= nil then
				log:Destroy()
				log = AddElement(logContainer, "Frame", {
					Size = UDim2.fromOffset(150, 110);
					Position = UDim2.fromOffset(0, 0);
					BackgroundColor3 = Color3.fromRGB(255,255,255);
					BorderSizePixel = 0;
				})
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
	managebutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	miningbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	signinbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
	signupbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(100,100,100)})
	transactionbutton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(0,0,0)})
	CreateElement("TextLabel", {
		Size = UDim2.fromOffset(75, 25);
		Position = UDim2.fromOffset(25, 25);
		Text = "Recepient:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	CreateElement("TextLabel", {
		Size = UDim2.fromOffset(75, 25);
		Position = UDim2.fromOffset(25, 60);
		Text = "Amount:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	local recepientButton = createButton(funnytable.transaction.recepient or "", UDim2.fromOffset(200, 25), UDim2.fromOffset(110, 25))
	local amountButton = createButton(funnytable.transaction.amount or "", UDim2.fromOffset(200, 25), UDim2.fromOffset(110, 60))
	local confirm = createButton("Confirm", UDim2.fromOffset(100, 50), UDim2.fromOffset(25, 95))
	confirm.MouseButton1Click:Connect(function()
		transaction(funnytable.transaction.recepient or "", funnytable.transaction.amount or "")
	end)
	recepientButton.MouseButton1Click:Connect(function()
		funnytable.transaction.focused = "recepient"
		recepientButton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(0,255,0)})
		amountButton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(255,255,255)})
	end)
	amountButton.MouseButton1Click:Connect(function()
		funnytable.transaction.focused = "amount"
		recepientButton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(255,255,255)})
		amountButton:ChangeProperties({BackgroundColor3 = Color3.fromRGB(0,255,0)})
	end)
	xConnect("keyboard", "TextInputted", function(text, plr)
		text = string.sub(text, 1, #text - 1)
		if funnytable.transaction.focused == "recepient" then
			funnytable.transaction.recepient = text
			recepientButton:ChangeProperties({Text = text})
		elseif funnytable.transaction.focused == "amount" then
			funnytable.transaction.amount = text
			amountButton:ChangeProperties({Text = text})
		end
	end)
end
managebutton.MouseButton1Click:Connect(function()
	openAccountManagement()
end)
signinbutton.MouseButton1Click:Connect(function()
	openSignIn()
end)
signupbutton.MouseButton1Click:Connect(function()
	openSignUp()
end)
miningbutton.MouseButton1Click:Connect(function()
	openMining()
end)
transactionbutton.MouseButton1Click:Connect(function()
	openTransaction()
end)
openAccountManagement()

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
