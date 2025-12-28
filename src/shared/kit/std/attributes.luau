--!optimize 2
--!native

local types = require("@kit/types")

export type string_data = {
	enums: { string }?,
	default: string,

	__type: "string",
}

export type number_data = {
	min: number?,
	max: number?,
	default: number,

	__type: "number",
}

export type boolean_data = {
	default: boolean,

	__type: "boolean",
}

export type cframe_data = {
	default: CFrame,

	__type: "cframe",
}

return {
	attributes = {
		string = function(data: {
			enums: { string }?,
			default: string,
		}): string_data
			return {
				enums = data.enums or {},
				default = data.default,

				__type = "string",
			}
		end,

		number = function(data: {
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
		end,

		boolean = function(data: {
			default: boolean,
		}): boolean_data
			return {
				default = data.default,

				__type = "boolean",
			}
		end,

		cframe = function(data: {
			default: CFrame,
		}): cframe_data
			return {
				default = data.default,

				__type = "cframe",
			}
		end,
	},

	get = function(object: types.object<any>)
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
	end,
}
