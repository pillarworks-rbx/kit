--!optimize 2
--!native

local RunService = game:GetService("RunService")

local group = require("@pkg/group")
local network = require("@shared/network/server")

local network_service = {}

network_service.priority = 1
network_service.identifier = "network_service"

export type self = typeof(network_service)

function network_service.handle_character(_self: self, _delta_time: number)
	for _, player, cframe in network.reload_character.iter() do
		--// reload their character
		player:LoadCharacterAsync()

		if cframe then
			--// position the player to the correct location
			player.CharacterAppearanceLoaded:Once(function(character: Model)
				character:PivotTo(cframe)
			end)
		end
	end
end

function network_service.handle_damage(_self: self, _delta_time: number)
	for _, player, damage in network.kit.damage.iter() do
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid?

		if not humanoid then
			continue
		end

		if humanoid.Health <= 0 then
			continue
		end

		--// damage/heal the player
		humanoid.Health = math.clamp(humanoid.Health - damage, 0, 100)
	end
end

function network_service.start(self: self)
	--// initialize group for this service
	self.group = group.create()

	--// start handling damage
	self.group:add(RunService.PostSimulation:Connect(function(delta_time: number)
		self:handle_damage(delta_time)
		self:handle_character(delta_time)
	end))
end

function network_service.stop(self: self)
	--// clean this service's group
	self.group:clean()
end

return network_service
