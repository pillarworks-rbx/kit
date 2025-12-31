--!optimize 2
--!native

local misc_utils = require("@shared/utils/misc")

local fluid = require("@pkg/fluid")
local create = fluid.create

return function(
	props: { [string]: any | fluid.Source<any> },
	states: { [string]: fluid.Source<any> },
	children: { [string]: Instance }?
)
	local new_props = table.clone(props)
	local parent = new_props.Parent

	local root = create("ScreenGui")({
		IgnoreGuiInset = new_props.IgnoreGuiInset,
		Parent = parent,
	})

	if children and typeof(children) == "table" and misc_utils.get_table_size(children) > 0 then
		for name, value in pairs(children) do
			root[name] = value
		end
	end

	local created_children = {
		base = {},
	}

	return {
		instance = root,
		children = created_children,
		states = states,
	}
end
