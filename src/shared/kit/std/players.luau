--!optimize 2
--!native

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--[=[
	@class players_utils
	@tag std

	this module provides utilities for *working with players*.
]=]
local players_utils = {}

--[=[
	@function from_hit
	@within players_utils
	
	get a player from a basepart.
	
	@param hit BasePart -- the hit to check.
	@return Player? -- the player that was hit. this can also return nil if no player was hit.
]=]
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

--[=[
	@function get_player
	@within players_utils
	@client

	gets the local player.

	@return Player? -- the local player. this returns nil if the player is not found or if it's called on the server.
]=]
function players_utils.get_player(): Player?
    if not RunService:IsClient() then
        return nil
    end

	local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

	return player
end

--[=[
	@function get_character
	@within players_utils

	gets the character of a player.

	@param player Player -- the player to get the character of.
	@return Model? -- the character of the player. this can also return nil if no character was found.
]=]
function players_utils.get_character(player: Player): Model?
	if not player then
		return nil
	end

	local character = player.Character or player.CharacterAdded:Wait()

	return character
end

--[=[
	@function get_humanoid
	@within players_utils

	gets the character of a player.

	@param player Player -- the player to get the character of.
	@return Humanoid? -- the humanoid of the player. this can also return nil if the player is nil or the humanoid was not found.
]=]
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
