--!optimize 2
--!native

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local group = require("@shared/modules/group")

local movement_controller = {}

export type self = typeof(movement_controller)

local player: Player
local character: typeof(Players.LocalPlayer.Character)
local root: Part

local last_cframe: CFrame? = nil
local raycast_params = RaycastParams.new()

raycast_params.FilterType = Enum.RaycastFilterType.Include

function movement_controller.get_raycast_result(self: self, position: Vector3)
	--// loop through all stick parts and only add them to the filter
	--// if they have the "stick_active" attribute set to true
	for _, part in pairs(CollectionService:GetTagged("stick_part")) do
		if part:GetAttribute("stick_active") then
			--// add part to the filter
			raycast_params:AddToFilter(part)
		end
	end

	--// return raycast result
	return workspace:Raycast(position, Vector3.new(0, -7.5, 0), raycast_params)
end

function movement_controller.handle_stick(self: self, delta_time: number)
	--// get raycast result
	local raycast_result = self:get_raycast_result(root.CFrame.Position)

	--// idk what any of this code below does
	--// i stole it from one of my other games
	if raycast_result and raycast_result.Instance:IsA("BasePart") then
		local active_part = raycast_result.Instance :: BasePart

		if not last_cframe then
			last_cframe = active_part.CFrame
		end

		if not last_cframe then
			return
		end

		last_cframe = last_cframe :: CFrame

		local active_cframe = active_part.CFrame
		local relative_cframe = active_cframe * last_cframe:Inverse()

		last_cframe = active_cframe
		root.CFrame = relative_cframe * root.CFrame
	else
		last_cframe = nil
	end
end

function movement_controller.start(self: self)
	--// initialize group for this controller
	self.group = group.create()

	--// setup character/player
	player = Players.LocalPlayer or Players.PlayerAdded:Wait()
	character = player.Character or player.CharacterAdded:Wait()
	root = character:WaitForChild("HumanoidRootPart")

	--// connect refreshing character variables to the CharacterAdded event
	self.group:add(player.CharacterAdded:Connect(function(new_character)
		character = new_character
		root = character:WaitForChild("HumanoidRootPart")

		last_cframe = nil
	end))

	--// connect the handle_stick method to the PostSimulation event
	self.group:add(RunService.PostSimulation:Connect(function(delta_time: number)
		delta_time = math.min(delta_time, 1)

		self:handle_stick(delta_time)
	end))
end

function movement_controller.stop(self: self)
	--// cleanup this controller's group instance
	self.group:clean()
end

return movement_controller
