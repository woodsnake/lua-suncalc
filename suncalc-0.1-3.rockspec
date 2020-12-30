package = "suncalc"
version = "0.1-3"
source = {
	url = "git+https://github.com/woodsnake/lua-suncalc.git"
}
description = {
	summary = "SunCalc is a package to calculate the sun positon",
	detailed = [[
		Package to calculate the sun position    
	]],
	homepage = "https://github.com/woodsnake/lua-suncalc",
	license = "MIT"
}
dependencies = {
	"lua >= 5.1"
}
build = {
	type = "builtin",
	modules = {
		SunCalc = "lib/suncalc.lua"
	},
	install = {
		bin = {
			"SunCalc"
		}
	}
}
