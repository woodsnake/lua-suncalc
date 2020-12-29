#!/usr/bin/env lua
-- require("mobdebug").start("192.168.10.83")
com = require("suncalc/common")
SunCalc = require("suncalc/suncalc")

pcall( function () 
	sc = SunCalc:new ()
	while (true) do
		print(sc:get_sun_hight())
		com.timeDelay(1)
	end
end)

