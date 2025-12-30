--!optimize 2
--!native
-- @author znotfireman
-- Implementation based on Welcome To Hell:
-- https://github.com/wthrblx/archive/blob/58ad4779ea49e1ec738455903043183af5c7180d/kit/scripts/Core/Gameplay/Button/init.luau

local debugger = require("@shared/debugger")
local effects = require("@shared/utils/effects")

local std = require("@kit/std")
local types = require("@kit/types")

local objects = std.objects
local attributes = std.attributes
local players = std.players
local utility = std.utility

local BUTTON_ENABLED_TAG = "button_enabled"
local BUTTON_ID_ATTRIBUTE = "button_id"

type ButtonIdCache = { [string]: { [Instance]: true } }
local button_id_caches: { [pillar]: ButtonIdCache } = {}

local object = objects.register({
	events = {},
	attributes = {
		[BUTTON_ID_ATTRIBUTE] = attributes.attributes.string(),
		plays_sound = attributes.attributes.boolean({ default = true }),
		duration = attributes.attributes.number({ default = 0 }),
		cooldown = attributes.attributes.number({ min = 0, default = 0 }),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

local function setup_cache(pillar: pillar) end

function on_hit(self: object, hit: BasePart, pillar: pillar) end

function object.events.load(self: object, pillar: pillar)
	local instance = self.instance

	if not instance or not instance:IsA("Part") then
		return
	end

	self.group:add(instance.Touched:Connect(function(hit: BasePart)
		on_hit(self, hit, pillar)
	end))
end

function object.events.unload(self: object, pillar: pillar)
	self.group:clean()
end

return object
