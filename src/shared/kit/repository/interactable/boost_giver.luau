--!optimize 2
--!native

local debugger = require("@shared/debugger")
local effects = require("@shared/utils/effects")

local std = require("@kit/std")
local types = require("@kit/types")

local objects = std.objects
local attributes = std.attributes
local players = std.players
local utility = std.utility

local object = objects.register({
	events = {},

	attributes = {
		effect = attributes.attributes.string({
			enums = { "speed", "jump" },
			default = "speed",
		}),

		change = attributes.attributes.number({
			min = 1,
			max = 100,
			default = 20,
		}),

		duration = attributes.attributes.number({
			min = 0,
			default = 5,
		}),

		cooldown = attributes.attributes.number({
			min = 0,
			max = 100,
			default = 1,
		}),

		refill_timer = attributes.attributes.boolean({
			default = true,
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

function on_hit(self: object, hit: BasePart, _pillar: pillar)
	local object_attributes = attributes.get(self)

	local effect = object_attributes.effect
	local change = object_attributes.change
	local duration = object_attributes.duration
	local cooldown = object_attributes.cooldown
	local refill_timer = object_attributes.refill_timer

	local player = players.from_hit(hit)

	if not player then
		debugger.log(`no player found from hit "{hit:GetFullName()}"`, "warn")

		return
	end

	local character = players.get_character(player)
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root then
		debugger.log(`player "{player.Name}" does not have a humanoidrootpart`, "warn")

		return
	end

	if utility.throttle(`give {effect} to {player.UserId} in {self.id}`, cooldown) then
		if refill_timer then
			effects.remove(player, effect)

			debugger.log(`effect "{effect}" has been removed from "{player.Name}" in preparation for refill`, "success")
		end

		effects.give(player, effect, change, duration)

		debugger.log(`effect "{effect}" has been given to "{player.Name}"`, "success")
	end
end

function object.events.load(self: object, pillar: pillar)
	local instance = self.instance

	if not instance or not instance:IsA("Part") then
		debugger.log(`object {self.id} does not have a valid part`, "warn")

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
