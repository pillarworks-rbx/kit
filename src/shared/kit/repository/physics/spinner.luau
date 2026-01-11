--!optimize 2
--!native

local RunService = game:GetService("RunService")

local debugger = require("@shared/debugger")

local std = require("@kit/std")
local types = require("@kit/types")

local object_utils = std.object
local attributes = std.attributes

local object = object_utils.register({
	events = {},

	attributes = {
		speed = attributes.attributes.number({
			min = 1,
			max = 100,
			default = 5,
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

function object.events.load(self: object, _pillar: pillar)
	self.group:add(RunService.PreRender:Connect(function(delta_time: number)
	    delta_time = math.clamp(delta_time, 0, 1)
					
		local object_attributes = attributes.get(self)
		local speed = object_attributes.speed * delta_time

		local instance = self.instance

		if not instance or not instance:IsA("Model") then
			debugger.log(`instance not found`, "warn")
			
			return
		end

		instance:PivotTo(instance:GetPivot() * CFrame.Angles(0, speed, 0))
	end))
	
	debugger.log(`object {self.id} has successfully loaded`, "success")
end

function object.events.unload(self: object, _pillar: pillar)
	self.group:clean()
	
	debugger.log(`object {self.id} has successfully unloaded`, "success")
end

return object
