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
			max = 500,
			default = 50,
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

function object.events.load(self: object, _pillar: pillar)
    local instance = self.instance
    local arrow = instance:FindFirstChild("arrow")
    
	self.group:add(RunService.PreRender:Connect(function(delta_time: number)
		delta_time = math.clamp(delta_time, 0, 1)

		local object_attributes = attributes.get(self)
		local speed = object_attributes.speed * delta_time

		if not instance or not instance:IsA("Part") then
			debugger.log(`object {self.id} does not have an instance or is not a part`, "warn")

			return
		end

		instance.AssemblyLinearVelocity = instance.CFrame.UpVector * -speed

		if arrow and arrow:IsA("Texture") then
			arrow.OffsetStudsV -= speed * delta_time

			if arrow.OffsetStudsV <= -arrow.StudsPerTileV then
				arrow.OffsetStudsV = 0
			end
		end
	end))

	debugger.log(`object {self.id} has successfully loaded`, "success")
end

function object.events.unload(self: object, _pillar: pillar)
	self.group:clean()

	debugger.log(`object {self.id} has successfully loaded`, "success")
end

return object
