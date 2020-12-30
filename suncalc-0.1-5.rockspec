package = "suncalc"
version = "0.1-5"
source = {
	url = "git://github.com/woodsnake/lua-suncalc.git",
	branch = "master"
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
		suncalc = "suncalc.lua"
	}
}
