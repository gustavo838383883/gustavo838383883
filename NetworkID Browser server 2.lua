local modem = GetPartFromPort(1, "Modem")
local disk = GetPartFromPort(2, "Disk")
local id = 20
modem:Configure({NetworkID = id})

local function udimtotable(udim)
	if typeof(udim) ~= "UDim" then return end
	local tablea = {
		["Type"] = "UDim",
		["Scale"] = udim.Scale,
		["Offset"] = udim.Offset
	}

	return tablea
end

local function udim2totable(udim2)
	if typeof(udim2) ~= "UDim2" then return end
	local tablea = {
		["Type"] = "UDim2",
		["X"] = udimtotable(udim2.X),
		["Y"] = udimtotable(udim2.Y)
	}

	return tablea
end

local function vector2totable(vector2)
	if typeof(vector2) ~= "Vector2" then return end
	local tablea = {
		["Type"] = "Vector2",
		["X"] = vector2.X,
		["Y"] = vector2.Y
	}

	return tablea
end

local function vector3totable(vector3)
	if typeof(vector3) ~= "Vector3" then return end
	local tablea = {
		["Type"] = "Vector3",
		["X"] = vector3.X,
		["Y"] = vector3.Y,
		["Z"] = vector3.Z
	}

	return tablea
end

local function color3totable(color3)
	if typeof(color3) ~= "Color3" then return end
	local tablea = {
		["Type"] = "Color3",
		["R"] = color3.R,
		["G"] = color3.G,
		["B"] = color3.B
	}

	return tablea
end

local function enumtostring(enum)
	if typeof(enum) ~= "Enum" then return end
	return {["Type"] = "Enum", ["Enum"] = tostring(enum)}
end

modem:Connect("MessageSent", function(text1)
	local success = pcall(JSONDecode, text1)

	if success then
		local message = JSONDecode(text1)
		local mode = message["Mode"]
		local player = message["Player"]
		local text = message["Text"]

		if mode == "SendMessage" then

			local table1 = {{
				["ClassName"] = "TextLabel",
				["Properties"] = {
					["Size"] = udim2totable(UDim2.fromScale(1, 1)),
					["TextScaled"] = true,
					["TextWrapped"] = true,
					["BackgroundColor3"] = color3totable(Color3.new(1,1,1)),
					["Text"] = text
				}
				["Children"] = {
					["ClassName"] = "TextLabel",
					["Properties"] = {
						["Size"] = udim2totable(UDim2.fromScale(1, 1)),
						["TextScaled"] = true,
						["TextWrapped"] = true,
						["BackgroundColor3"] = color3totable(Color3.new(1,1,1)),
						["Text"] = text
					}
				}
			}}
			local result = {["Mode"] = "ServerSend", ["Text"] = JSONEncode(table1), ["Player"] = player}
			print(JSONEncode(result))
			task.wait()
			modem:SendMessage(JSONEncode(result), id)
		end
	end
end)
