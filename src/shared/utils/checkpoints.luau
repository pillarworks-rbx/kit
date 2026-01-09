--!optimize 2
--!native

local debugger = require("@shared/debugger")

local network = require("@shared/network/client")
local types = require("@kit/types")
local effects = require("@shared/utils/effects")

--[=[
	@interface checkpoint_data
	@within checkpoint_utils
	@tag utility
	
	@field effect string -- the name of the effect.
	@field change number -- the amount of change the effect will apply.
	
	@field lifetime number -- the time, in seconds, the effect will last.
	@field start number -- the timestamp of when the most recent time the effect was applied.

	represents an active effect that the player has.
]=]
export type checkpoint_data = {
	pillar: types.pillar,
	id: string,
	position: CFrame,
}

--[=[
	@class checkpoint_utils
	@tag utility
	
	this module contains checkpoint utils that is used by the death manager.
	this module is responsible for handling player checkpoints.
]=]
local checkpoint_utils = {}
local checkpoints = {} :: { [Player]: checkpoint_data }

--[=[
	@function on_death
	@within checkpoint_utils
	@tag utility

	run the death event for the player specified.
	
	@param player Player -- the player that died.
]=]
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

		debugger.log(`{player.Name} died in pillar {pillar.id} at checkpoint {id}`, "success")

		network.reload_character.fire(position * CFrame.new(0, character_size.Y / 2, 0))
	else
		debugger.log(`{player.Name} died`, "success")
	end
	
	effects.clear(player)
end

--[=[
	@function set
	@within checkpoint_utils
	@tag utility

	run the death event for the player specified.
	
	@param player Player -- the player that died.
	@param pillar pillar -- the pillar that the checkpoint is in.
	@param id string -- the id of the checkpoint.
	@param position CFrame -- the position of the checkpoint.
]=]
function checkpoint_utils.set(player: Player, pillar: types.pillar, id: string, position: CFrame)
	checkpoints[player] = {
		pillar = pillar,
		id = id,
		position = position,
	}
end

--[=[
	@function get
	@within checkpoint_utils
	@tag utility

	get the checkpoint for the player specified.
	
	@param player Player -- the player that died.
	@return checkpoint_data? -- the checkpoint data for the player, or nil if none exists.
]=]
function checkpoint_utils.get(player: Player): checkpoint_data?
	return checkpoints[player]
end

--[=[
	@function clear
	@within checkpoint_utils
	@tag utility

	remove the checkpoint for the player specified.
	
	@param player Player -- the player that died.
]=]
function checkpoint_utils.clear(player: Player)
	checkpoints[player] = nil
end

return checkpoint_utils
