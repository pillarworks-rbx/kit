--!optimize 2
--!native

local debugger = require("@shared/debugger")
local effects = require("@shared/utils/effects")

local std = require("@kit/std")
local types = require("@kit/types")

local object_utils = std.object
local attributes = std.attributes
local players = std.players

local object = object_utils.register({
	events = {},

	attributes = {
		effect = attributes.attributes.string({
			enums = { "speed", "jump" },
			default = "speed",
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

function on_hit(self: object, hit: BasePart, _pillar: pillar)
	local object_attributes = attributes.get(self)
	local effect = object_attributes.effect

	local player = players.from_hit(hit)

	if not player then
		return
	end

	local character = players.get_character(player)
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	effects.remove(player, effect)
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
