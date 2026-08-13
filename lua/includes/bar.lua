local mon = peripheral.find("monitor")


function connect_bar(motors, h)
	mon.setCursorPos(1,1)
	mon.clearLine()
	write("Flight Controller Pairing... ")

	for i, m in ipairs(motors) do 
		if m[1] then
			mon.setBackgroundColor(colors.green)
			write("M"..i)
		else 
			mon.setBackgroundColor(colors.red)
			write("M"..i)

		end
		mon.setBackgroundColor(colors.black)
		write(" ")
	end
	

	mon.setBackgroundColor(colors.black)
	mon.setCursorPos(1,2)
	write("---------------------------------------------------------\n")
	mon.setCursorPos(1,h)
end

function regular_bar(motors, h, target, angles, altitude) 


	mon.setTextColor(colors.yellow)
	mon.setCursorPos(1,1)
	mon.clearLine()
	write("|FC|")

	write(" |")
	for i, m in ipairs(motors) do 
		if i == 4 then 
			write("M"..i..": "..fmtnum(m[2],0).."|")
		else
			write("M"..i..": "..fmtnum(m[2],0).." ")
		end
		
	end

	write(" |Target Y: "..target.."|")

	mon.setCursorPos(1,2)
	mon.setTextColor(colors.magenta)
	mon.clearLine()

	write("|Altitude: "..fmtnum(altitude, 2).."|")
	write(" |Roll: "..fmtnum(angles[1],2).."|")
	write(" |Pitch: "..fmtnum(angles[2],2).."|")

	mon.setBackgroundColor(colors.black)


	mon.setTextColor(colors.yellow)
	mon.setCursorPos(1,3)
	write("---------------------------------------------------------\n")
	mon.setTextColor(colors.white)
	mon.setCursorPos(1,h)
end

function error_write(string) 

	mon.setTextColor(colors.red)
	write(string.."\n")
	mon.setTextColor(colors.white)
end

function fmtnum(num, dec)
	if num ~= nil then
		return math.floor(num*math.pow(10,dec),1)/math.pow(10,dec)
	else
		return "nil"
	end
end

