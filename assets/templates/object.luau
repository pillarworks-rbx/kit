--!optimize 2
--!native

local RunService = game:GetService("RunService")

local debugger = require(game:GetService("ReplicatedStorage"):FindFirstChild("shared"):FindFirstChild("debugger"))

local std =
	require(game:GetService("ReplicatedStorage"):FindFirstChild("shared"):FindFirstChild("kit"):FindFirstChild("std"))
local types =
	require(game:GetService("ReplicatedStorage"):FindFirstChild("shared"):FindFirstChild("kit"):FindFirstChild("types"))

local object_utils = std.object

local object = object_utils.register({
	events = {},

	attributes = {},
})

export type pillar = types.pillar
export type object = types.processed_object<typeof(object)>

function object.events.load(self: object, _pillar: pillar)
	self.group:add(RunService.PreRender:Connect(function(delta_time: number)
		delta_time = math.clamp(delta_time, 0, 1)

		-- do whatever here
	end))

	debugger.log(`object {self.id} has successfully loaded`, "success")
end

function object.events.unload(self: object, _pillar: pillar)
	self.group:clean()

	debugger.log(`object {self.id} has successfully unloaded`, "success")
end

return object

