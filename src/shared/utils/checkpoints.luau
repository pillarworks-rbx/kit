--!optimize 2
--!native

local network = require("@shared/network/client")
local types = require("@kit/types")
local effects = require("@shared/utils/effects")

export type checkpoint_data = {
	pillar: types.pillar,
	id: string,
	position: CFrame,
}

local checkpoint_utils = {}
local checkpoints = {} :: { [Player]: checkpoint_data }

function checkpoint_utils.on_death(player: Player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid?
    
    if not humanoid or humanoid.Health > 0 then
        return
    end
    
    local character_size = character:GetExtentsSize()
    
	local current_checkpoint = checkpoints[player]

	if current_checkpoint then
		local pillar = current_checkpoint.pillar
		local id = current_checkpoint.id
		local position = current_checkpoint.position

		print(`{player.Name} died in pillar {pillar.id} at checkpoint {id}`)

		network.reload_character.fire(position * CFrame.new(0, character_size.Y / 2, 0))
	else
		print(`{player.Name} died`)
	end
	
	effects.clear(player)
end

function checkpoint_utils.set_checkpoint(player: Player, pillar: types.pillar, id: string, position: CFrame)
	checkpoints[player] = {
		pillar = pillar,
		id = id,
		position = position,
	}
end

function checkpoint_utils.get_checkpoint(player: Player): checkpoint_data?
	return checkpoints[player]
end

function checkpoint_utils.clear_checkpoint(player: Player)
	checkpoints[player] = nil
end

return checkpoint_utils
