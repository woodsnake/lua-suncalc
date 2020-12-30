#!/usr/bin/env lua
SunCalc = require("lib/suncalc")

local ran, err = pcall( function () 
	sc = SunCalc:new( {latitude=48.85, longitude=10.5} )
	while (true) do
		local az, al = sc:get_sun_pos()
		print("azimuth: " .. az .. "\taltitude: " .. al )
		os.execute("sleep 1")
	end
end)
print(err)
