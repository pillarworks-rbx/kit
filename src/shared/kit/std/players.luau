--!optimize 2
--!native

local Players = game:GetService("Players")
local players_utils = {}

function players_utils.from_hit(hit: BasePart): Player?
	if not hit or not hit.Parent then
		return nil
	end

	if not hit.Parent:FindFirstChildOfClass("Humanoid") then
		return nil
	end

	local player = Players:GetPlayerFromCharacter(hit.Parent)

	return player
end

function players_utils.get_player(): Player?
	local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

	return player
end

function players_utils.get_character(player: Player): Model?
	if not player then
		return nil
	end

	local character = player.Character or player.CharacterAdded:Wait()

	return character
end

function players_utils.get_humanoid(player: Player): Humanoid?
	if not player then
		return nil
	end

	local character = player.Character or player.CharacterAdded:Wait()

	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	return humanoid
end

return players_utils
