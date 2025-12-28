--!optimize 2
--!native

local RunService = game:GetService("RunService")

local debugger = require("@shared/debugger")

local std = require("@kit/std")
local types = require("@kit/types")

local players = std.players
local objects = std.objects
local attributes = std.attributes
local property = std.property

local ALLOWED_CFRAME_COMPONENTS = {
	"UpVector",
	"RightVector",
	"LookVector",
	"ZVector",
}

local object = objects.register({
	events = {},

	attributes = {
		max_force = attributes.attributes.number({
			min = 0,
			max = math.huge,
			default = math.huge,
		}),

		speed = attributes.attributes.number({
			min = 1,
			max = 250,
			default = 40,
		}),

		move_vector = attributes.attributes.string({
			enums = ALLOWED_CFRAME_COMPONENTS,
			default = "UpVector",
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

local overlap_params = OverlapParams.new()

overlap_params.FilterType = Enum.RaycastFilterType.Include

function get_velocity(part: BasePart)
	local attachment = part:FindFirstChild("elevator_attachment") :: Attachment?

	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "elevator_attachment"
		attachment.Parent = part
	end

	local velocity = part:FindFirstChild("elevator_velocity") :: LinearVelocity?

	if not velocity then
		velocity = Instance.new("LinearVelocity")
		velocity.Name = "elevator_velocity"
		velocity.Attachment0 = attachment
		velocity.RelativeTo = Enum.ActuatorRelativeTo.World
		velocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		velocity.ForceLimitsEnabled = true
		velocity.Parent = part
	end

	return velocity
end

function object.events.load(self: object, pillar: pillar)
	--// initialise player variables
	local player = players.get_player()
	local character = players.get_character(player)
	local root: BasePart = character:WaitForChild("HumanoidRootPart")

	--// connect refreshing character variables to the CharacterAdded event
	self.group:add(player.CharacterAdded:Connect(function(char)
		character = char
		root = char:WaitForChild("HumanoidRootPart")
	end))

	self.group:add(RunService.PreRender:Connect(function(delta_time: number)
		delta_time = math.clamp(delta_time, 0, 1)

		local instance = self.instance

		if not instance or not instance:IsA("Part") then
			return
		end

		local object_attributes = attributes.get(self)

		local speed = object_attributes.speed
		local max_force = object_attributes.max_force
		local move_vector = object_attributes.move_vector

		local face_vector: Vector3 = property.get_property(instance.CFrame, move_vector)

		if not face_vector then
			return
		end

		local max_axes_force = Vector3.new(0, max_force, 0)

		if face_vector.X ~= 0 then
			max_axes_force = Vector3.new(max_force, max_axes_force.Y, max_axes_force.Z)
		end

		if face_vector.Z ~= 0 then
			max_axes_force = Vector3.new(max_axes_force.X, max_axes_force.Y, max_force)
		end

		overlap_params.FilterDescendantsInstances = { root }

		local touching = false
		local parts = workspace:GetPartsInPart(instance, overlap_params)

		for _, part in pairs(parts) do
			if part == root then
				touching = true

				local velocity = get_velocity(root)

				velocity.MaxAxesForce = max_axes_force
				velocity.VectorVelocity = face_vector * speed
				velocity.Enabled = true

				break
			end
		end

		if not touching then
			local velocity = root:FindFirstChild("elevator_velocity")

			if velocity then
				velocity.Enabled = false
			end
		end
	end))
	
	debugger.log(`object {self.id} has successfully loaded`, "success")
end

function object.events.unload(self: object, pillar: pillar)
	local instance = self.instance

	if not instance or not instance:IsA("Model") then
		return
	end

	for _, descendant in pairs(instance:GetDescendants()) do
		if descendant:IsA("LinearVelocity") and descendant.Name == "elevator_velocity" then
			descendant:Destroy()
		elseif descendant:IsA("Attachment") and descendant.Name == "elevator_attachment" then
			descendant:Destroy()
		end
	end

	self.group:clean()
	
	debugger.log(`object {self.id} has successfully unloaded`, "success")
end

return object
