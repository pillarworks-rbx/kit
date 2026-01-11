--!optimize 2
--!native

local types = require("@kit/types")

--[=[
	@class object_utils
	@tag std
	
	this module provides utilities for *creating kit objects*.
]=]
local object_utils = {}

--[=[
	@function register
	@within object_utils

	register an object with the kit, preparing it for further use.

	@param object object -- the object to register.
	@return object -- the registered object.
]=]
function object_utils.register(object: types.object<any>): types.object<any>
	local new_object = table.clone(object)

	--// created in kit_controller as an extension of the pillar's group
	new_object.group = nil

	new_object.attributes = new_object.attributes or {}
	new_object.events = new_object.events or {}

	new_object.id = nil
	new_object.instance = nil

	return new_object
end

return object_utils
