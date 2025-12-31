--!optimize 2
--!native

local fluid = require("@pkg/fluid")
local ui_labs = require("@pkg/ui_labs")

local CreateControlStates = ui_labs.CreateControlStates
local UpdateControlStates = ui_labs.UpdateControlStates

local CreateGenericStory = ui_labs.CreateGenericStory

local create, root = fluid.create, fluid.root

local controls = {
   visible = true
}

local story = CreateGenericStory({
	controls = controls,
}, function(properties)
    local target, converted, _controls = properties.target, properties.converted, properties.controls
    local states = CreateControlStates(converted, controls, function<T>(control: T): fluid.Source<T>
        return fluid.source(control)
    end)

	local component

	root(function()
		component = create("Frame")({
			Size = UDim2.fromOffset(200, 100),
			Visible = states.visible,

			Parent = target,
		})
	end)

	properties.subscribe(function(values: { [string]: any })
        UpdateControlStates(states, converted, values, function(state, value)
            state(value)
         end)
	end)

	return function()
    	if component then
    	    component:Destroy()
    	end
	end
end)

return story
