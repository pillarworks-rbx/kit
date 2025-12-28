--!optimize 2
--!native

return {
	get_property = function(instance: any, property: string): (any, boolean)
		local result

		local success = pcall(function()
			result = instance[property]
		end)

		return result, success
	end,

	set_property = function(instance: any, property: string, value: any): boolean
		return (pcall(function()
			instance[property] = value
		end))
	end,
}
