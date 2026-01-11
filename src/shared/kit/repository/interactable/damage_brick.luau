--!optimize 2
--!native

local debugger = require("@shared/debugger")
local misc_utils = require("@shared/utils/misc")

local std = require("@kit/std")
local types = require("@kit/types")

local object_utils = std.object
local attributes = std.attributes
local players = std.players

local network = require("@shared/network/client")

local object = object_utils.register({
	events = {},

	attributes = {
		damage = attributes.attributes.number({
			min = -100,
			max = 100,
			default = 10,
		}),

		cooldown = attributes.attributes.number({
			default = 0.1,
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

function on_hit(self: object, hit: BasePart, _pillar: pillar)
	local player = players.from_hit(hit) :: Player?

	if not player then
		return
	end

	local object_attributes = attributes.get(self)

	local damage: number = object_attributes.damage
	local cooldown: number = object_attributes.cooldown

	--// only fire once every few seconds
	if misc_utils.throttle(`damage {player.UserId} in {self.id}`, cooldown) then
		--// send request damage event to server
		network.kit.damage.fire(damage)
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
