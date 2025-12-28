--!optimize 2
--!native

local RunService = game:GetService("RunService")

local debugger = require("@shared/debugger")

local std = require("@kit/std")
local types = require("@kit/types")

local objects = std.objects
local attributes = std.attributes

local object = objects.register({
	events = {},

	attributes = {
		loop = attributes.attributes.boolean({
			default = true,
		}),

		speed = attributes.attributes.number({
			min = 0,
			max = 100,
			default = 20,
		}),
	},
})

export type pillar = types.pillar
export type object = types.object<typeof(object)>

function object.events.load(self: object, pillar: pillar)
	local current_index, next_index = 1, 2
	local alpha, direction = 0, 1

	self.group:add(RunService.PreRender:Connect(function(delta_time: number)
	    delta_time = math.clamp(delta_time, 0, 1)
					
		local object_attributes = attributes.get(self)

		local platform_loop = object_attributes.loop
		local platform_speed = object_attributes.speed * delta_time

		local instance = self.instance

		if not instance or not instance:IsA("Model") then
			return
		end

		local platform = instance:FindFirstChild("platform") :: Model?
		local positions = instance:FindFirstChild("positions") :: (Folder & { [string]: BasePart })?

		if not platform or not positions then
			return
		end

		local position_parts = positions:GetChildren()

		table.sort(position_parts, function(a: Instance, b: Instance): boolean
			return a.Name < b.Name
		end)

		if #position_parts <= 1 then
			return
		end
		
		local current_position = position_parts[current_index].Position
		local next_position = position_parts[next_index].Position

		alpha += platform_speed / (next_position - current_position).Magnitude

		if alpha >= 1 then
			current_index = next_index
			alpha = 0

			if direction == 1 then
				if current_index < #position_parts then
					next_index = current_index + 1
				else
					if platform_loop then
						next_index = 1
					else
						direction = -1
						next_index = current_index - 1
					end
				end
			else
				if current_index > 1 then
					next_index = current_index - 1
				else
					if platform_loop then
						next_index = #position_parts
					else
						direction = 1
						next_index = current_index + 1
					end
				end
			end
		end
		
		local cframe_a = position_parts[current_index].CFrame
		local cframe_b = position_parts[next_index].CFrame
		
		local target_cframe = cframe_a:Lerp(cframe_b, alpha)
		
		platform:PivotTo(target_cframe)
	end))
	
	debugger.log(`object {self.id} has successfully loaded`, "success")
end

function object.events.unload(self: object, pillar: pillar)
	self.group:clean()
	
	debugger.log(`object {self.id} has successfully unloaded`, "success")
end

return object
