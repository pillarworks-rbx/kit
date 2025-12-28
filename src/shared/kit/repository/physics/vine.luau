--!optimize 2
--!native

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local debugger = require("@shared/debugger")

local std = require("@kit/std")
local types = require("@kit/types")

local objects = std.objects
local attributes = std.attributes
local players = std.players

local object = objects.register({
	events = {},

	attributes = {
		handle_animation = attributes.attributes.boolean({
			default = true,
		}),

		allow_jump_dismount = attributes.attributes.boolean({
			default = true,
		}),

		keep_momentum = attributes.attributes.boolean({
			default = true,
		}),

		respawn_time = attributes.attributes.number({
			min = 0,
			max = 10,
			default = 1,
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

local overlap_params = OverlapParams.new()

overlap_params.FilterType = Enum.RaycastFilterType.Exclude

function object.events.load(self: object, pillar: pillar)
	local player = players.get_player()
	local character = players.get_character(player)
	local root = character:WaitForChild("HumanoidRootPart") :: BasePart
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid

	self.group:add(player.CharacterAdded:Connect(function(char)
		character = char
		root = char:WaitForChild("HumanoidRootPart")
		humanoid = char:WaitForChild("Humanoid")
	end))

	local vine = self.instance

	if not vine or not vine:IsA("Model") then
		debugger.log(`object {self.id} is not a valid model!`, "warn")

		return
	end

	local vine_part = vine:FindFirstChild("vine_part") :: BasePart
	local attachment_part = vine:FindFirstChild("attachment_part") :: BasePart
	local constraint_template = vine:FindFirstChild("vine_constraint") :: Constraint
	local bar_template = vine:FindFirstChild("rope_bar") :: BasePart

	if not (vine_part and attachment_part and constraint_template and bar_template) then
		debugger.log(`object {self.id} at {vine:GetFullName()} is missing crucial parts`, "warn")

		return
	end

	bar_template.Parent = nil
	overlap_params.FilterDescendantsInstances = { vine }

	local riding = false
	local ride_group = self.group:extend()

	local function dismount()
		if not riding then
			return
		end

		riding = false
		ride_group:clean()

		if not attributes.get(self).keep_momentum then
			root.AssemblyLinearVelocity = Vector3.zero
		end

		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		humanoid.AutoRotate = true
	end

	local function mount()
		if riding then
			return
		end

		local SWING_FORCE = 150
		local DAMPING = 6
		local MAX_FORCE = 4000

		riding = true

		local object_attributes = attributes.get(self)
		local move_dir = Vector3.zero

		ride_group:add(RunService.Heartbeat:Connect(function()
			move_dir = humanoid.MoveDirection
		end))

		local bar = bar_template:Clone()

		bar.CFrame = root.CFrame * CFrame.new(0, character:GetExtentsSize().Y / 2, 0)
		bar.Anchored = false
		bar.Parent = vine

		local bar_attachment = Instance.new("Attachment")

		bar_attachment.Parent = bar

		local vector_force = Instance.new("VectorForce")

		vector_force.Attachment0 = bar_attachment
		vector_force.RelativeTo = Enum.ActuatorRelativeTo.World
		vector_force.ApplyAtCenterOfMass = true
		vector_force.Parent = bar

		local top_attachment = attachment_part:FindFirstChild("vine_attachment") or Instance.new("Attachment")

		top_attachment.Name = "vine_attachment"
		top_attachment.Parent = attachment_part

		local constraint = constraint_template:Clone()

		constraint.Attachment0 = bar_attachment
		constraint.Attachment1 = top_attachment
		constraint.Parent = bar
		constraint.Enabled = true

		local root_attachment = root:FindFirstChild("vine_root_attachment") or Instance.new("Attachment")

		root_attachment.Name = "vine_root_attachment"
		root_attachment.Parent = root

		local align_pos = Instance.new("AlignPosition")

		align_pos.Attachment0 = root_attachment
		align_pos.Attachment1 = bar_attachment
		align_pos.MaxForce = 15000
		align_pos.Responsiveness = 10
		align_pos.Mode = Enum.PositionAlignmentMode.TwoAttachment
		align_pos.ApplyAtCenterOfMass = true
		align_pos.Parent = root

		local align_ori = Instance.new("AlignOrientation")

		align_ori.Attachment0 = root_attachment
		align_ori.Attachment1 = bar_attachment
		align_ori.MaxTorque = 5000
		align_ori.Responsiveness = 8
		align_ori.Mode = Enum.OrientationAlignmentMode.TwoAttachment
		align_ori.Parent = root

		-- Humanoid state
		humanoid.AutoRotate = true
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)

		ride_group:add(RunService.Heartbeat:Connect(function(dt)
			local bar_velocity = bar.AssemblyLinearVelocity
			local rope_dir = (bar.Position - attachment_part.Position).Unit

			-- Tangential velocity (actual swing motion)
			local tangential_velocity = bar_velocity - rope_dir * bar_velocity:Dot(rope_dir)

			-- Player input force
			local input_force = Vector3.zero
			if move_dir.Magnitude > 0 then
				local tangent_input = (move_dir - move_dir:Dot(rope_dir) * rope_dir)

				input_force = tangent_input * SWING_FORCE
			end

			-- Damping force (opposes motion)
			local damping_force = -tangential_velocity * DAMPING

			local total_force = input_force + damping_force

			-- Clamp for stability
			if total_force.Magnitude > MAX_FORCE then
				total_force = total_force.Unit * MAX_FORCE
			end

			vector_force.Force = total_force
		end))

		ride_group:add(function()
			bar:Destroy()
			align_pos:Destroy()
			align_ori:Destroy()
		end)

		if object_attributes.allow_jump_dismount then
			ride_group:add(UserInputService.JumpRequest:Connect(dismount))
		end
	end

	self.group:add(RunService.Heartbeat:Connect(function()
		if not root or riding then
			return
		end

		local parts = workspace:GetPartsInPart(vine_part, overlap_params)

		for _, part in pairs(parts) do
			if part == root then
				mount()

				break
			end
		end
	end))

	debugger.log(`object {self.id} has successfully loaded`, "success")
end

function object.events.unload(self: object, pillar: pillar)
	self.group:clean()

	debugger.log(`object {self.id} has successfully unloaded`, "success")
end

return object
