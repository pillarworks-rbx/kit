--!optimize 2
--!native

local RunService = game:GetService("RunService")

local group = require("@shared/modules/group")

local network = require("@shared/network/server")

local network_service = {}

export type self = typeof(network_service)

function network_service.handle_character(self: self, delta_time: number)
	for _, player, cframe in network.reload_character.iter() do		
		--// reload their character
		player:LoadCharacterAsync()
		
		--// position the player to the correct location
		player.CharacterAppearanceLoaded:Once(function(character: Model)  
			if cframe then
				character:PivotTo(cframe)
			end
		end)
	end
end

function network_service.handle_damage(self: self, delta_time: number)
	for _, player, damage in network.kit.damage.iter() do
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid?

		if not humanoid then
			continue
		end

		if humanoid.Health <= 0 then
			continue
		end
		
		--// damage the player
		humanoid:TakeDamage(damage)
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
