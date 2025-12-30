--!optimize 2
--!native

local debugger = require("@shared/debugger")

local std = require("@kit/std")
local types = require("@kit/types")

local objects = std.objects
local attributes = std.attributes
local players = std.players
local utility = std.utility

local checkpoint_utils = require("@shared/utils/checkpoints")

local object = objects.register({
	events = {},

	attributes = {
		checkpoint_id = attributes.attributes.string({
			default = "Checkpoint",
		}),

		cooldown = attributes.attributes.number({
			default = 0.1,
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

function on_hit(self: object, hit: BasePart, pillar: pillar)
	local player = players.from_hit(hit) :: Player?

	if not player then
		return
	end

	local object_attributes = attributes.get(self)

	local checkpoint_id: string = object_attributes.checkpoint_id
	local cooldown: number = object_attributes.cooldown
	
	local checkpoint_cframe = self.instance.CFrame

	--// only fire once every few seconds
	if utility.throttle(`update checkpoint for {player.UserId} in {self.id}`, cooldown) then
		debugger.log(`update checkpoint for {player.UserId} as {self.id}`, "success")

		checkpoint_utils.set_checkpoint(player, pillar, checkpoint_id, checkpoint_cframe)
	end
end

function object.events.load(self: object, pillar: pillar)
	local instance = self.instance

	if not instance or not instance:IsA("Part") then
		debugger.log(`object {self.id} is not a valid part`, "error")

		return
	end

	self.group:add(instance.Touched:Connect(function(hit: BasePart)
		debugger.log(`object {self.id} has been hit by "{hit:GetFullName()}"`, "success")

		on_hit(self, hit, pillar)
	end))

	debugger.log(`object {self.id} has successfully loaded`, "success")
end

function object.events.unload(self: object, _pillar: pillar)
	self.group:clean()

	debugger.log(`object {self.id} has successfully unloaded`, "success")
end

return object
