#!/usr/bin/env lua
-- require("mobdebug").start("192.168.10.83")
com = require("common")
Inv = require("zoe-loader/inverter")

pcall( function () 
	inverter_4kW = Inv:new({ip="192.168.10.66"})
	inverter_8kW = Inv:new({ip="192.168.10.43"})
	while (true) do
		print(inverter_8kW:get_power())
		print(inverter_4kW:get_power())
		print("\n")
		com.timeDelay(10)
	end
end)

-- add
