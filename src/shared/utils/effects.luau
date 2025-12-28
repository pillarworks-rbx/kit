--!optimize 2
--!native

export type effect = {
	effect: string,
	change: string,

	lifetime: number,
	start: number,

	original_data: {
		speed: number,
		jump: number,
	},
}

export type handler_type = "apply" | "reset"

local std = require("@kit/std")
local players = std.players

local effects = {} :: { [Player]: effect }

local effect_handlers = {
	speed = function(player: Player, effect: effect)
		local effect_change = effect.change
		local original_data = effect.original_data

		local humanoid = players.get_humanoid(player)

		if not humanoid then
			return
		end

		humanoid.WalkSpeed = original_data.speed + effect_change
	end,

	jump = function(player: Player, effect: effect)
		local effect_change = effect.change
		local original_data = effect.original_data

		local humanoid = players.get_humanoid(player)

		if not humanoid then
			return
		end

		humanoid.JumpPower = original_data.jump + effect_change
	end,
}

function handle_effect(player: Player, effect: effect, type: handler_type)
	local effect_name = effect.effect

	if type == "reset" then
		local original_data = effect.original_data
		local humanoid = players.get_humanoid(player)

		if not humanoid then
			return
		end

		humanoid.WalkSpeed = original_data.speed
		humanoid.JumpPower = original_data.jump

		return
	end

	if effect_handlers[effect_name] then
		effect_handlers[effect_name](player, effect)
	end
end

return {
	--// effect helpers
	get = function(player: Player)
		if not effects[player] then
			effects[player] = {}
		end

		return effects[player]
	end,

	give = function(player: Player, effect_name: string, change: number, lifetime: number?)
		if not effects[player] then
			effects[player] = {}
		end

		print(`giving {effect_name} to {player.Name} with a lifetime of {lifetime}`)

		local humanoid = players.get_humanoid(player)

		if not humanoid then
			return
		end

		effects[player][effect_name] = {
			effect = effect_name,
			change = change,

			lifetime = lifetime or 0,
			start = os.clock(),

			original_data = {
				speed = humanoid.WalkSpeed,
				jump = humanoid.JumpPower,
			},
		}
	end,

	remove = function(player: Player, effect_name: string)
		if not effects[player] then
			effects[player] = {}
		end

		local effect: effect? = effects[player][effect_name]

		if not effect then
			return
		end

		handle_effect(player, effect, "reset")

		effects[player][effect_name] = nil
	end,

	clear = function(player: Player)
		effects[player] = {}
	end,

	--// effect handler
	step = function(): { string }
		local count = {}

		for player: Player, player_effects: { effect } in pairs(effects) do
			for _, effect: effect in pairs(player_effects) do
				local effect_name = effect.effect
				local effect_lifetime = effect.lifetime
				local effect_start = effect.start
				
				table.insert(count, effect_name)

				if effect_lifetime ~= 0 then
					local elapsed = os.clock() - effect_start

					if elapsed >= effect_lifetime then
						handle_effect(player, effect, "reset")

						effects[player][effect_name] = nil

						continue
					end
				end

				handle_effect(player, effect, "apply")
			end
		end

		return count
	end,
}
