--!optimize 2
--!native

local group = require("@shared/modules/group")

local debugger = require("@shared/debugger")
local iris = debugger.iris

local debug_controller = {}

export type self = typeof(debug_controller)

function format_ms(total_seconds)
	local hours = math.floor(total_seconds / 3600)
	local minutes = math.floor((total_seconds % 3600) / 60)
	local seconds = math.floor(total_seconds % 60)
	local milliseconds = math.floor((total_seconds - math.floor(total_seconds)) * 1000)

	return string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
end

function debug_controller.start(self: self)
	--// initialize group for this controller
	self.group = group.create()

	--// add a cleanup function to the group
	self.group:add(function()
		debugger.cleanup()
	end)

	--// initialize debugger
	local debugger_open = true
	
	debugger.cleanup()

	debugger.start(function()
		return debugger_open
	end)

	task.spawn(function()
		while task.wait(1) do
			--debugger_open = not debugger_open
		end
	end)

	--// add output debugger
	debugger.add_debugger({ "pillarworks kit output" }, function()
		local stack = debugger.output._stack

		for _, message in pairs(stack) do
			local message_time = message.time
			local message_status = message.status
			local message_text = message.message
			local message_count = message.count
			
			local formatted_time = format_ms(message_time)
			local text = `[{formatted_time}] [{message_status}] {message_text}`
			
			if message.count > 1 then
				text = `{text} (x{message_count})`
			end

			iris.Text({ text })
		end
	end, 1)
end

function debug_controller.stop(self: self)
	--// clean this controller's group
	self.group:clean()
end

return debug_controller
