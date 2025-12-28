--!optimize 2
--!native

local RunService = game:GetService("RunService")

local debugger = require("@shared/debugger")

local std = require("@kit/std")
local types = require("@kit/types")

local objects = std.objects
local attributes = std.attributes

local object = objects.register({
	events = {},

	attributes = {
		speed = attributes.attributes.number({
			min = 1,
			max = 100,
			default = 20,
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

function object.events.load(self: object, pillar: pillar)
	self.group:add(RunService.PreRender:Connect(function(delta_time: number)
	    delta_time = math.clamp(delta_time, 0, 1)
		
		local object_attributes = attributes.get(self)
		local speed = object_attributes.speed * delta_time

		local instance = self.instance

		if not instance or not instance:IsA("Part") then
			debugger.log(`object {self.id} does not have an instance or is not a part`, "warn")

			return
		end
		
		instance.AssemblyLinearVelocity = instance.CFrame.RightVector * -speed
	end))
	
	debugger.log(`object {self.id} has successfully loaded`, "success")
end

function object.events.unload(self: object, pillar: pillar)
	self.group:clean()
	
	debugger.log(`object {self.id} has successfully loaded`, "success")
end

return object
