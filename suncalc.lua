#!/usr/bin/env lua
-- require("mobdebug").start("192.168.10.83")
com = require("suncalc/common")
SunCalc = require("suncalc/SunCalc")

pcall( function () 
	sc = SunCalc:new ()
	while (true) do
		print("\n")
		com.timeDelay(10)
	end
end)

