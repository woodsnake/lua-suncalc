local SunCalc = {}

function SunCalc:new (o)
	o = o or {}
	o.latitude = o.latitude or 48.58
	o.longitude = o.longitude or 10.49
  
	setmetatable(o, self)
	self.__index = self

	return o
end
 
function SunCalc:get_sun_high ()
	return (12)
end
  
return SunCalc
