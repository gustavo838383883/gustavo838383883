local reactor = GetPartFromPort(1, "Reactor")
local dispenser = GetPartFromPort(4, "Dispenser")

while true do
	task.wait(1)
	local temp = reactor:GetTemp()
	if temp < 900 then
		TriggerPort(2)
	elseif temp > 1000 then
		TriggerPort(3)
		task.wait(0.1)
		TriggerPort(3)
	end
	local fuel = reactor:GetFuel()

	for index, value in ipairs(fuel) do
		if value <= 0 then
			dispenser:Dispense()
		end
	end
end
