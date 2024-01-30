local modem = GetPartFromPort(1, "Modem")
local id = 20
modem:Configure({NetworkId = id})

modem:Connect("MessageSent", function(text1)
	local success = pcall(JSONDecode, text1)

	if success then
		local table1 = JSONDecode(text1)
		local mode = table1["Mode"]
		local text = table1["Text"]

		if mode == "SendMessage" then
			local result = {["Mode"] = "ServerSend", ["Text"] = "Test is a success"}
			for index, value in pairs(result) do print(value) end
			task.wait(1)
			modem:SendMessage(JSONEncode(result), id)
		end
		
	end
end)
