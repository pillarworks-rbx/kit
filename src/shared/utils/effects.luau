--!optimize 2
--!native

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

local effect_utils = {}

function effect_utils.get(player: Player)
	effects[player] = effects[player] or {}

	return effects[player]
end

function effect_utils.give(player: Player, effect_name: string, change: number, lifetime: number?)
	effects[player] = effects[player] or {}

	effects[player][effect_name] = {
		effect = effect_name,
		change = change,
		lifetime = lifetime or 0,
		start = os.clock(),
	}
end

function effect_utils.remove(player: Player, effect_name: string)
	local player_effects = effects[player]

	if not player_effects then
		return
	end

	player_effects[effect_name] = nil
end

function effect_utils.clear(player: Player)
	effects[player] = {}
end

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
