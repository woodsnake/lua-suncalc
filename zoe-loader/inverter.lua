local mb = require("libmodbus")

local Inverter = {}

Inverter.var1 = 12

function Inverter:new (o)
	o = o or {}
	o.ip = o.ip or "192.168.10.66"
	o.port = o.port or 502
	o.unit_id = o.unit_id or 3
	o.register_power_start = 30775
	o.register_power_count = 2
	o.dev = mb.new_tcp_pi(o.ip, o.port)
	o.dev:set_slave(o.unit_id)
  
	setmetatable(o, self)
	self.__index = self
 	self.__tostring = function (self)
			return ( self:get_power() .. " W" ) 
		end
	return o
end
 
function Inverter:get_power ()
	self.dev:connect()
	local regs, err = self.dev:read_registers(self.register_power_start, self.register_power_count)
	self.dev:close()
	return (regs[1] * 0x10000 + regs[2]) / 1000.0
end
  
function Inverter:get_port ()
	return self.port
end

function Inverter:set_port(i)
	self.port = i
end


return Inverter
