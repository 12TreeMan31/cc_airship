
require("includes/bar")
require("includes/controls")

--[[ Check peripherals
local peripherals = peripheral.getNames();
for index,name in ipairs(peripherals) do 
	write("["..index.."] "..name.." Type: "..peripheral.getType(name).."\n")
end
--]]

local net = peripheral.find("modem")
local mon = peripheral.find("monitor")
local speaker = peripheral.find("speaker")
local board = peripheral.find("linked_typewriter")
local gimbal = peripheral.find("gimbal_sensor")
local altitude = peripheral.find("altitude_sensor")

local power = true
local target = fmtnum(altitude.getHeight(),0)
local mtotal = 0
local error = 0

local motors = {
	[1]={false, 0},
	[2]={false, 0},
	[3]={false, 0},
	[4]={false, 0}
}

local ids = {
	[4]=3,
	[6]=1,
	[7]=4,
	[8]=2
}

local keycodes = {
	[87] = "FORWARD",
	[65] = "LEFT",
	[83] = "RIGHT",
	[68] = "BACKWARD",
	[32] = "UP",
	[340] = "DOWN"
}


function up() 
	if target < 320 then
		target = target + 1
	else 
		target = 320
		error_write("Target cannot be set higher")
	end
end
function down() 
	if target > -64 then
		target = target - 1
	else 
		target = -64
		error_write("Target cannot be set lower")
	end
end

local controls = {
	["FORWARD"] = forward,
	["LEFT"] = left,
	["RIGHT"] = right,
	["BACKWARD"] = backward,
	["UP"] = up,
	["DOWN"] = down
}

local function startup()

	mon.setTextColor(colors.white)
	mon.setBackgroundColor(colors.black)
	mon.clear()
	mon.setTextScale(0.5)
	mon.setCursorPos(1,3)
	term.redirect(mon)
	rednet.open("modem_1")
	local count = 1;
	while mtotal < 4 do 
		write("Broadcast Attempt #"..count.."\n")
		local w,h = mon.getCursorPos()
		connect_bar(motors,h)

		rednet.broadcast({"WAKE"}, "AEROONE")
		count = count+ 1 
		speaker.playNote("bit", 3.0, 0)
		sleep(1)
	end
	sleep(5)
end

local function listen()
	while mtotal < 4 do 
		local id, message, protocol = rednet.receive()
		if ids[id] then

			motors[ids[id]][1] = true
			motors[ids[id]][2] = message
			write(message.."["..id.."] " .. "connected...\n")
			speaker.playNote("bit", 3.0, 24)
			mtotal = mtotal +1
		else 
			write(message.."["..id.."] " .. "attempted to connect...\n")
			speaker.playNote("bit", 3.0, 24)
		end


	end
	
end

local function off_on()
	while power do 
		os.pullEvent("redstone")
		mon.clear()
		mon.setCursorPos(1,1)
		write("Program ended...")
		rednet.broadcast({"DISCONNECT"}, "AEROONE")
		power = false
	end
end

local timer = 0
local discrete_time_y = {}



local function error_diff() 
	return target - altitude.getHeight()
end

local function proportional_y(pgain)
	return pgain * error_diff()
end

local function integral_y(igain)
end

local function derivative_y(dgain) 
	local last_error  = discrete_time_y[timer-1]
		
	if last_error ~= nil then
		return ((error_diff() - last_error)/0.05)*dgain
	else
		return 0
	end
end

local function controller_step() 
	local error = error_diff()

	if error == 0 then 
		write("wrong")
		discrete_time_y = {}
		timer = 0
	else 
		discrete_time_y[timer] = error_diff()

		local p = proportional_y(0.001)
		local d = derivative_y(0.0001)




		if motors[1][2] >= 256 and p > 0 then
			motors[1][2] = 256
		elseif motors[1][2] <= 0 and p < 0 then
			motors[1][2] = 0
		else
			motors[1][2] = motors[1][2] + p + d
		end
		rednet.broadcast({"SET", motors[1][2]}, "AEROONE")



		timer = timer + 1
		
		return p, d
	end
end




local function ui() 
	while power do 
		sleep(0.05)


		local keys = board.getPressedKeyCodes()

		for i,k in ipairs(keys) do
			if keycodes[k] then
				local func = controls[keycodes[k]]
				if func then
					func()
				end
			else
				error_write("Unknown keybind: "..k)
			end
		end


		local p, d = controller_step()

		write("P+D= "..(p+d).."\n")

	

		local _,h = mon.getCursorPos()
		regular_bar(motors, h, target, {p,d}, altitude.getHeight())
	end
end


parallel.waitForAny(off_on, startup, listen)
if power ~= false then
	sleep(0.05)
	mon.clear()
	mon.setCursorPos(1,1)
	write("All devices connected!\n")
	speaker.playNote("pling", 3.0, 24)
	sleep(1.0)
	parallel.waitForAny(off_on, ui)
end
