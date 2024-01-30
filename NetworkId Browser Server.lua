local modem = GetPartFromPort(1, "Modem")
local disk = GetPartFromPort(2, "Disk")
local id = 20
modem:Configure({NetworkID = id})

modem:Connect("MessageSent", function(text1)
	local success = pcall(JSONDecode, text1)

	if success then
		local table1 = JSONDecode(text1)
		local mode = table1["Mode"]
		local text = table1["Text"]

		if mode == "SendMessage" then
			local command = if text then string.sub(text, 1, 6):lower() else ""
			if command == "make, " then
				local data = string.sub(text, 7, string.len(text))
				
				local s = string.find(data, "/")

				local text1 = string.sub(data, 1, s-1)
				local text2 = string.sub(data, s+1, string.len(data))

				local returntext = "Failed"

				if text1 and text2 then
					disk:Write(text1, text2)
				end

				if disk:Read(text1) == text2 then returntext = "Success" end
				
				local result = {["Mode"] = "ServerSend", ["Text"] = returntext}
				task.wait()
				modem:SendMessage(JSONEncode(result), id)
			elseif command == "dele, " then
				local data = string.sub(text, 7, string.len(text))

				local returntext = "Failed"

				if text1 and text2 then
					disk:Write(data, nil)
				end

				if disk:Read(data) == nil then returntext = "Success" end
				
				local result = {["Mode"] = "ServerSend", ["Text"] = returntext}
				task.wait()
				modem:SendMessage(JSONEncode(result), id)
			elseif command == "read, " then
				local data = string.sub(text, 7, string.len(text))

				local returntext = ""

				returntext = disk:Read(data) or "Failed"

				local result = {["Mode"] = "ServerSend", ["Text"] = returntext}
				task.wait()
				modem:SendMessage(JSONEncode(result), id)
			elseif command == "fuldir" then
				local resulttext = ""

				for i, v in pairs(disk:ReadEntireDisk()) do
					resulttext = if resulttext ~= "" then resulttext..","..i else i
				end

				local result = {["Mode"] = "ServerSend", ["Text"] = JSONEncode(returntable)}
				task.wait()
				modem:SendMessage(JSONEncode(result), id)
			else
				local result = {["Mode"] = "ServerSend", ["Text"] = "Invalid command"}
				task.wait()
				modem:SendMessage(JSONEncode(result), id)
			end
		end
	else
		local result = {["Mode"] = "ServerSend", ["Text"] = "Invalid Request"}
		task.wait()
		modem:SendMessage(JSONEncode(result), id)
	end
end)
