--!optimize 2
--!native

local Players = game:GetService("Players")

local group = require("@shared/modules/group")

local death_controller = {}

export type self = typeof(death_controller)

local checkpoint_utils = require("@shared/utils/checkpoints")

local player: Player
local character: Model
local humanoid: Humanoid

function death_controller.start(self: self)
	--// initialize group for this controller
	self.group = group.create()

	--// setup character/player
	player = Players.LocalPlayer or Players.PlayerAdded:Wait()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid") :: Humanoid

	--// setup death event
	self.group:add(humanoid.Died:Connect(function()
		checkpoint_utils.on_death(player)
	end))
end

function death_controller.stop(self: self)
	--// cleanup this controller's group instance
	task.defer(function()
	    self.group:clean()
	end)
end

return death_controller
