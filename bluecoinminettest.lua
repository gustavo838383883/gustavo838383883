
local screen = GetPartFromPort(1, "Screen")
local modem = GetPartFromPort(2, "Modem")
local disk = GetPartFromPort(3, "Disk")

local Screen = screen
local Modem = modem
local Disk = disk

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
	Size = UDim2.new(0.25, 0, 1, 0),
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

gui[`TextLabel7`] = screen:CreateElement('TextLabel', {
	Name = [[TextLabel7]],
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	RichText = true,
	Text = [[Change Access Code]],
	TextColor3 = Color3.new(0, 0, 0),
	TextScaled = true,
	TextWrapped = true,
	TextSize = 14,
})

gui[`TextLabel8`] = screen:CreateElement('TextLabel', {
	Name = [[TextLabel8]],
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	RichText = true,
	Text = [[Refresh Balance]],
	TextColor3 = Color3.new(0, 0, 0),
	TextScaled = true,
	TextWrapped = true,
	TextSize = 14,
})

gui[`refreshbalancebutton`] = screen:CreateElement('ImageButton', {
	Name = [[refreshbalancebutton]],
	BorderSizePixel = 0,
	Size = UDim2.new(0.25, 0, 1, 0),
	Position = UDim2.new(0.25, 0, 0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderColor3 = Color3.new(0, 0, 0),
	Image = [[http://www.roblox.com/asset/?id=15625805900]],
	PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
})

gui[`newcodebutton`] = screen:CreateElement('ImageButton', {
	Name = [[newcodebutton]],
	BorderSizePixel = 0,
	Size = UDim2.new(0.25, 0, 1, 0),
	Position = UDim2.new(0.75, 0, 0, 0),
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
gui[`newcodebutton`]:AddChild(gui[`TextLabel7`])
gui[`refreshbalancebutton`]:AddChild(gui[`TextLabel8`])
gui[`StatusFrame`]:AddChild(gui[`refreshbalancebutton`])
gui[`StatusFrame`]:AddChild(gui[`newcodebutton`])
gui[`logoutbutton`]:AddChild(gui[`TextLabel6`])
gui[`StatusFrame`]:AddChild(gui[`logoutbutton`])
gui[`ImageLabel`]:AddChild(gui[`StatusFrame`])

local signinbutton = gui["signinbutton"]
local signupbutton = gui["signupbutton"]
local managebutton = gui["managebutton"]
local miningbutton = gui["miningbutton"]
local transactionbutton = gui["transactionbutton"]
local mainFrame = gui["MainFrame"]

local mainframeelements = {}

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

local function ClearElements()
	for index, value in ipairs(mainframeelements) do
		value:Destroy()
	end
	mainframeelements = {}
end

local function openTransaction()
	ClearElements()
	funnytable.signup.focused = nil
	funnytable.signin.focused = nil
	funnytable.transaction.focused = nil
	log = nil
	local frame1 = screen:CreateElement("TextLabel", {
		Size = UDim2.fromScale(0.2, 0.2);
		Position = UDim2.fromScale(0.2, 0);
		Text = "Recepient:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	table.insert(mainframeelements, frame1)
	local frame2 = screen:CreateElement("TextLabel", {
		Size = UDim2.fromScale(0.5, 0.2);
		Position = UDim2.fromScale(0.2, 0.4);
		Text = "Amount:";
		TextScaled = true;
		TextColor3 = Color3.fromRGB(255,255,255);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
	})
	table.insert(mainframeelements, frame2)

	mainFrame:AddChild(frame1)
	mainFrame:AddChild(frame2)

	local recepientButton = screen:CreateElement('ImageButton', {
		Name = funnytable.transaction.recepient or "",
		BorderSizePixel = 0,
		Size = UDim2.new(0.25, 0, 0.25, 0),
		Position = UDim2.new(0.2, 0, 0, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		Image = [[http://www.roblox.com/asset/?id=15625805900]],
		PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
	})
	table.insert(mainframeelements, recepientButton)

	local amountButton = screen:CreateElement('ImageButton', {
		Name = funnytable.transaction.amount or "",
		BorderSizePixel = 0,
		Size = UDim2.new(0.25, 0, 0.25, 0),
		Position = UDim2.new(0.2, 0, 0.25, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		Image = [[http://www.roblox.com/asset/?id=15625805900]],
		PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
	})
	table.insert(mainframeelements, amountButton)
	local confirm = screen:CreateElement('ImageButton', {
		Name = "Confirm",
		BorderSizePixel = 0,
		Size = UDim2.new(0.25, 0, 0.25, 0),
		Position = UDim2.new(0.2, 0, 0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		Image = [[http://www.roblox.com/asset/?id=15625805900]],
		PressedImage = [[http://www.roblox.com/asset/?id=15625805069]],
	})
	table.insert(mainframeelements, confirm)

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

