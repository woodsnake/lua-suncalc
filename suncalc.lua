#!/usr/bin/env lua
-- require("mobdebug").start("192.168.10.83")
com = require("suncalc/common")
SunCalc = require("suncalc/suncalc")

local ran, err = pcall( function () 
	sc = SunCalc:new ({latitude=48.58, longitude=10.49})
	while (true) do
		local azi, alti = sc:get_sun_pos()
		print("azimuth: " .. azi .. "\taltitude: " .. alti )
		com.timeDelay(1)
	end
end)
print(err)
