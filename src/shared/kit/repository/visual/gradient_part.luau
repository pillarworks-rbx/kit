--!optimize 2
--!native

local RunService = game:GetService("RunService")

local debugger = require("@shared/debugger")

local std = require("@kit/std")
local types = require("@kit/types")

local object_utils = std.object
local property = std.property

local object = object_utils.register({
	events = {},
	attributes = {},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

local EFFECT_COLOUR_PROPERTIES = {
	"Color",
	"Color3",
	"BackgroundColor3",
	"TextColor3",
	"ImageColor3",
	"SurfaceColor3",
}

--// code taken from etoh tower creation kit v6 ♥
function evaluate_colour_sequence(sequence: ColorSequence, alpha: number)
	if alpha <= 0 then
		return sequence.Keypoints[1].Value
	elseif alpha >= 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end

	for i = 1, #sequence.Keypoints - 1 do
		local this_keypoint = sequence.Keypoints[i]
		local next_keypoint = sequence.Keypoints[i + 1]

		if alpha >= this_keypoint.Time and alpha < next_keypoint.Time then
			local colour_alpha = (alpha - this_keypoint.Time) / (next_keypoint.Time - this_keypoint.Time)

			local this_colour = this_keypoint.Value
			local next_colour = next_keypoint.Value

			return Color3.new(
				math.lerp(this_colour.R, next_colour.R, colour_alpha),
				math.lerp(this_colour.G, next_colour.G, colour_alpha),
				math.lerp(this_colour.B, next_colour.B, colour_alpha)
			)
		end
	end

	return Color3.new()
end

function object.events.load(self: object, _pillar: pillar)
	local alpha = 0

	self.group:add(RunService.PreRender:Connect(function(delta_time: number)
		delta_time = math.clamp(delta_time, 0, 1)
		alpha += delta_time

		alpha = alpha % 1

		local instance = self.instance

		if not instance then
			debugger.log(`instance not found`, "warn")

			return
		end

		local gradient = instance:FindFirstChildOfClass("UIGradient")

		if not gradient then
			return
		end

		local colour = evaluate_colour_sequence(gradient.Color, alpha)

		for _, property_name in pairs(EFFECT_COLOUR_PROPERTIES) do
			property.set_property(instance, property_name, colour)
		end

		--debugger.log(`colour for object {self.id} has been set`, "success")
	end))

	debugger.log(`object {self.id} has successfully loaded`, "success")
end

function object.events.unload(self: object, _pillar: pillar)
	self.group:clean()

	debugger.log(`object {self.id} has successfully unloaded`, "success")
end

return object
