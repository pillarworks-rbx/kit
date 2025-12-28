--!optimize 2
--!native

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local group = require("@shared/modules/group")

local debugger = require("@shared/debugger")
local effects = require("@shared/utils/effects")

local std = require("@kit/std")
local utility = std.utility

local effects_controller = {}

export type self = typeof(effects_controller)

function effects_controller.start(self: self)
	--// initialize group for this controller
	self.group = group.create()
	
	local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
	
	--// connect the cleanup methods to the PostSimulation event
	self.group:add(RunService.PostSimulation:Connect(function(delta_time: number)
		delta_time = math.min(delta_time, 1)

		if utility.throttle(`step effects for {player.UserId}`, 1 / 10) then
			if #effects.get(player) > 0 then
				local result = effects.step()
				local effects_table = table.concat(result, ", ")
				
				debugger.log(`stepping player effects: {effects_table}`, "success")
			end
		end
	end))
end

function effects_controller.stop(self: self)
	--// clean this controller's group
	self.group:clean()
end

return effects_controller
