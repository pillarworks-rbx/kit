--!optimize 2
--!native

local fluid = require("@pkg/fluid")
local ui_labs = require("@pkg/ui_labs")

local boost_component = require("@shared/ui/components/kit/boost")

local CreateControlStates = ui_labs.CreateControlStates
local UpdateControlStates = ui_labs.UpdateControlStates

local CreateGenericStory = ui_labs.CreateGenericStory
local EnumList, Slider = ui_labs.Choose, ui_labs.Slider

local root = fluid.root

local controls = {
   visible = true,

   boost_type = EnumList({
       "speed",
       "jump"
   }, 1),

   percentage = Slider(0, 0, 1, 0.01)
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
		component = boost_component({
		    Size = UDim2.fromOffset(100, 100),
			Position = UDim2.fromOffset(0, 0),

			Visible = states.visible,

			Parent = target,
		}, states)
	end)

	properties.subscribe(function(values: { [string]: any })
        UpdateControlStates(states, converted, values, function(state, value)
            state(value)
         end)
	end)

	return function()
    	if component and component.instance then
    	    component.instance:Destroy()
    	end
	end
end)

return story
