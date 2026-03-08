--!optimize 2
--!native

--[=[
	@interface effect
	@within effect_utils
	
	@field effect string -- the name of the effect.
	@field change number -- the amount of change the effect will apply.
	
	@field lifetime number -- the time, in seconds, the effect will last.
	@field start number -- the timestamp of when the most recent time the effect was applied.

	represents an active effect that the player has.
]=]
export type effect = {
	effect: string,
	change: number,

	lifetime: number,
	start: number,
}

local std = require("@kit/std")
local players = std.players

local effects = {} :: { [Player]: { [string]: effect } }

local baselines = {} :: {
	[Player]: {
		speed: number,
		jump: number,
	},
}

--[=[
	@class effect_utils
	@tag utility
	
	this module contains effect utils that are used by the *effects manager*. those utils are responsible for *managing* and *applying* effects to players.
	
	the effects that can be applied are:
	- speed boost
	- jump boost
]=]
local effect_utils = {}

--[=[
	@function get
	@within effect_utils

	get all effects for a player.

	@param player Player -- the player to get effects for.
	@return { effect } -- the effects for the player.
]=]
function effect_utils.get(player: Player)
	effects[player] = effects[player] or {}

	return effects[player]
end

--[=[
	@function give
	@within effect_utils

	give an effect to a player.

	@param player Player -- the player to give the effect to.
	@param effect_name string -- the name of the effect to give.
	@param change number -- the amount of change the effect will apply.
	@param lifetime number? -- the time, in seconds, the effect will last.
]=]
function effect_utils.give(player: Player, effect_name: string, change: number, lifetime: number?)
	effects[player] = effects[player] or {}

	effects[player][effect_name] = {
		effect = effect_name,
		change = change,
		lifetime = lifetime or 0,
		start = os.clock(),
	}
end

--[=[
	@function remove
	@within effect_utils

	remove an effect from a player.

	@param player Player -- the player to remove the effect from.
	@param effect_name string -- the name of the effect to remove.
]=]
function effect_utils.remove(player: Player, effect_name: string)
	local player_effects = effects[player]

	if not player_effects then
		return
	end

	player_effects[effect_name] = nil
end

--[=[
	@function clear
	@within effect_utils

	remove all effects for a player.

	@param player Player -- the player to clear the effects for.
]=]
function effect_utils.clear(player: Player)
	effects[player] = {}
end

--[=[
	@function step
	@within effect_utils
	@client

	step all effects for the current player.
	
	@return { effect } -- the effects that were active and applied.
]=]
function effect_utils.step(): { effect }
	local applied = {}
	local now = os.clock()

	for player, player_effects in pairs(effects) do
		local humanoid = players.get_humanoid(player)

		if not humanoid then
			continue
		end

		if not baselines[player] then
			baselines[player] = {
				speed = humanoid.WalkSpeed,
				jump = humanoid.JumpPower,
			}
		end

		local base = baselines[player]

		local speed_delta = 0
		local jump_delta = 0

		for name, effect in pairs(player_effects) do
			if effect.lifetime > 0 and (now - effect.start) >= effect.lifetime then
				player_effects[name] = nil

				continue
			end

			if effect.effect == "speed" then
				speed_delta += effect.change
			elseif effect.effect == "jump" then
				jump_delta += effect.change
			end

			table.insert(applied, effect)
		end

		humanoid.WalkSpeed = base.speed + speed_delta
		humanoid.JumpPower = base.jump + jump_delta
	end

	return applied
end

return effect_utils
