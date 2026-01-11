--!optimize 2
--!native

--[=[
	@class property_utils
	@tag std

	this module provides utilities for *safely* working with properties.
]=]
local property_utils = {}

--[=[
	@function get_property
	@within property_utils
	
	get a property from an instance.
	
	@param instance Instance -- the instance to get the property from.
	@param property string -- the property to get.
	
	@return (any, boolean) -- the value of the property (or nil) and whether or not the operation was successful.
]=]
function property_utils.get_property(instance: any, property: string): (any, boolean)
	local result

	local success = pcall(function()
		result = instance[property]
	end)

	return result, success
end

--[=[
	@function set_property
	@within property_utils
	
	set a property on an instance.
	
	@param instance Instance -- the instance to set the property on.
	@param property string -- the property to set.
	@param value any -- the value to set the property to.
	
	@return boolean -- whether or not the operation was successful.
]=]
function property_utils.set_property(instance: any, property: string, value: any): boolean
	return (pcall(function()
		instance[property] = value
	end))
end

return property_utils
