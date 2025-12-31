--!optimize 2
--!native

local property_utils = {}

function property_utils.get_property(instance: any, property: string): (any, boolean)
	local result

	local success = pcall(function()
		result = instance[property]
	end)

	return result, success
end

function property_utils.set_property(instance: any, property: string, value: any): boolean
	return (pcall(function()
		instance[property] = value
	end))
end

return property_utils
