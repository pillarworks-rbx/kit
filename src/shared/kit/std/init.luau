--!optimize 2
--!native

--[=[
	@class root
	@tag std
	
	this module is the root for the standard library that kit scripts can use.
	
	the current standard library modules are:
	- objects
	- attributes
	- players
	- property
	- utility
]=]
local std = {
	objects = require("@self/objects"),
	attributes = require("@self/attributes"),
	players = require("@self/players"),
	property = require("@self/property"),
	utility = require("@self/utility"),
}

return std
