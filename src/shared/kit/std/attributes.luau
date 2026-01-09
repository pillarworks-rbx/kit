--!optimize 2
--!native

local types = require("@kit/types")

--[=[
	@interface string_data
	@within attribute_utils
	@tag std
	
	@field enums { string }? -- the different options the attribute can take. if not provided, the attribute can take any string value.
	@field default string -- the default value of the attribute.
	
	@field __type "string" -- the type of the attribute. this will always be "string".

	represents a string attribute.
]=]
export type string_data = {
	enums: { string }?,
	default: string,

	__type: "string",
}

--[=[
	@interface number_data
	@within attribute_utils
	@tag std
	
	@field min number? -- the minimum value the attribute can take. if not provided, the attribute can take any number value.
	@field max number? -- the maximum value the attribute can take. if not provided, the attribute can take any number value.
	@field default number -- the default value of the attribute.
	
	@field __type "number" -- the type of the attribute. this will always be "number".

	represents a number attribute.
]=]
export type number_data = {
	min: number?,
	max: number?,
	default: number,

	__type: "number",
}

--[=[
	@interface boolean_data
	@within attribute_utils
	@tag std
	
	@field default boolean -- the default value of the attribute.
	@field __type "boolean" -- the type of the attribute. this will always be "boolean".

	represents a boolean attribute.
]=]
export type boolean_data = {
	default: boolean,

	__type: "boolean",
}

--[=[
	@interface cframe_data
	@within attribute_utils
	@tag std
	
	@field default CFrame -- the default value of the attribute.
	@field __type "cframe" -- the type of the attribute. this will always be "cframe".

	represents a cframe attribute.
]=]
export type cframe_data = {
	default: CFrame,

	__type: "cframe",
}

--[=[
	@class attribute_utils
	@tag std
	
	this module provides utilities for working with attributes in kit objects.
]=]
local attribute_utils = {}

attribute_utils.attributes = {}

--[=[
	@function get
	@within attribute_utils
	@tag std

	get all attributes for an object.

	@param object object -- the object to get attributes for.
	@return { [string]: any } -- the attributes for the object.
]=]
function attribute_utils.get(object: types.object<any>): { [string]: any }
	local instance = object.instance

	local obj_attributes = object.attributes
	local inst_attributes = instance:GetAttributes()

	local attributes = {}

	for name, value in pairs(obj_attributes) do
		attributes[name] = value.default
	end

	for name, value in pairs(inst_attributes) do
		local obj_attribute = obj_attributes[name]

		if not obj_attribute then
			continue
		end

		local default = obj_attribute.default

		if default then
			if not value then
				value = default
			end

			if obj_attribute.__type == "string" then
				local enums = obj_attribute.enums

				if enums and typeof(enums) == "table" and #enums > 0 then
					if not table.find(enums, value) then
						value = default
					end
				end
			elseif obj_attribute.__type == "number" then
				local min = obj_attribute.min or -math.huge
				local max = obj_attribute.max or math.huge

				value = math.clamp(value, min, max)
			end
		end

		attributes[name] = value
	end

	return attributes
end

---------------------------------------------------
--         attribute creators are below!         --
---------------------------------------------------

--[=[
	@function attributes.string
	@within attribute_utils
	@tag std

	create a new string attribute.

	@param data { enums: { string }?, default: string } -- the attribute data.
	@return string_data -- the actual attribute data, used by the "get" function.
]=]
function attribute_utils.attributes.string(data: {
	enums: { string }?,
	default: string,
}): string_data
	return {
		enums = data.enums or {},
		default = data.default,

		__type = "string",
	}
end

--[=[
	@function attributes.number
	@within attribute_utils
	@tag std

	create a new number attribute.

	@param data { min: number?, max: number?, default: number } -- the attribute data.
	@return number_data -- the actual attribute data, used by the "get" function.
]=]
function attribute_utils.attributes.number(data: {
	min: number?,
	max: number?,
	default: number,
}): number_data
	return {
		min = data.min,
		max = data.max,
		default = data.default,

		__type = "number",
	}
end

--[=[
	@function attributes.boolean
	@within attribute_utils
	@tag std

	create a new boolean attribute.

	@param data { default: boolean } -- the attribute data.
	@return boolean_data -- the actual attribute data, used by the "get" function.
]=]
function attribute_utils.attributes.boolean(data: {
	default: boolean,
}): boolean_data
	return {
		default = data.default,

		__type = "boolean",
	}
end

--[=[
	@function attributes.cframe
	@within attribute_utils
	@tag std

	create a new cframe attribute.

	@param data { default: CFrame } -- the attribute data.
	@return cframe_data -- the actual attribute data, used by the "get" function.
]=]
function attribute_utils.attributes.cframe(data: {
	default: CFrame,
}): cframe_data
	return {
		default = data.default,

		__type = "cframe",
	}
end

return attribute_utils
