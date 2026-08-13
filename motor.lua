-- 3 [4]
local power = true
local motor = peripheral.find("Create_RotationSpeedController")
local net = peripheral.find("modem")
local peripherals = peripheral.getNames();
local controller = nil;

local function disconnect() 
	write("Disconnected from controller " .. controller .. "\n")
	controller = nil;

end

local function set(speed)
	write("Controller " .. controller .. ": Set speed to ".. speed.."\n")
	motor.setTargetSpeed(speed)
end

local responses = {
	["DISCONNECT"] = disconnect,
	["SET"] = set,
}

for index,name in ipairs(peripherals) do 
	write("["..index.."] "..name.." Type: "..peripheral.getType(name).."\n")
end

rednet.open("top")


while power do 
	if controller == nil then 
		write("Waiting for connection...\n")
		local controller_a, message, protocol = rednet.receive("AEROONE")
		controller = controller_a
		rednet.send(controller, motor.getTargetSpeed())

		write("Connected to controller! ID: ".. controller .."\n")
	end


	local controller_b, message, protocol = rednet.receive("AEROONE")



	if message[1] == "WAKE" then 
		::continue::
	else
		local response = responses[message[1]]
		if (response) and controller==controller_b  then 
			if message[1] then
				response(message[2])
			else
				response()
			end
		else
			rednet.send(controller, "ERROR: Unknown command")
		end
	end
end


