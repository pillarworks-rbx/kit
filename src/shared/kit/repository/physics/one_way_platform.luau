--!optimize 2
--!native

local RunService = game:GetService("RunService")

local debugger = require("@shared/debugger")

local std = require("@kit/std")
local types = require("@kit/types")

local objects = std.objects
local attributes = std.attributes
local players = std.players

local object = objects.register({
	events = {},

	attributes = {
		enabled = attributes.attributes.boolean({
			default = true,
		}),

		min_distance = attributes.attributes.number({
			min = 0,
			max = 100,
			default = 0.1,
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

function object.events.load(self: object, _pillar: pillar)
	self.group:add(RunService.PreRender:Connect(function(delta_time: number)
	    delta_time = math.clamp(delta_time, 0, 1)
		
		local object_attributes = attributes.get(self)

		local object_enabled = object_attributes.enabled
		local min_distance = object_attributes.min_distance

		if not object_enabled then
			debugger.log(`object {self.id} is disabled`, "warn")
			
			return
		end

		local player = players.get_player()

		if not player then
			debugger.log(`player not found`, "warn")
			
			return
		end

		local character = players.get_character(player)

		if not character then
			debugger.log(`character not found`, "warn")
			
			return
		end

		local root: BasePart? = character:FindFirstChild("HumanoidRootPart")

		if not root then
			debugger.log(`root part not found`, "warn")
			
			return
		end

		local instance = self.instance

		if not instance or not instance:IsA("Part") then
			debugger.log(`instance not found`, "warn")
			
			return
		end

		local player_position: Vector3 = root.Position
		local object_position: Vector3 = instance.Position

		local target: Vector3 = object_position + Vector3.one * min_distance

		instance.CanCollide = player_position.Y >= target.Y
	end))
	
	debugger.log(`object {self.id} has successfully loaded`, "success")
end

function object.events.unload(self: object, _pillar: pillar)
	self.group:clean()
	
	debugger.log(`object {self.id} has successfully unloaded`, "success")
end

return object
