--!optimize 2
--!native

local iris = require("@pkg/iris").Init()
local stack = require("@pkg/stack")

export type log = {
	message: string,
	status: "success" | "warn" | "error",

	time: number,
	count: number,
}

local MAX_LOGS = 200

local debuggers = {}
local output = stack.new(MAX_LOGS)

local started = false

return {
	iris = iris,
	output = output,

	log = function(message: string, status: "success" | "warn" | "error")
		local now = os.clock()
		local last = output:peek() :: log?

		if last and last.message == message and last.status == status then
			last.count += 1
			last.time = now

			return
		end

		output:push({
			message = message,
			status = status,
			time = now,
			count = 1,
		})
	end,

	add_debugger = function(window: { string }, callback: () -> (), priority: number)
		table.insert(debuggers, {
			window = window,
			callback = callback,
			priority = priority,
		})

		table.sort(debuggers, function(a, b)
			return a.priority < b.priority
		end)
	end,

	start = function(start_callback: () -> boolean?)
		if started then
			return
		end

		started = true

		iris:Connect(function()
			if start_callback ~= nil and start_callback() == false then
				return
			end

			iris.PushConfig({ RichText = true })

			for _, debugger in ipairs(debuggers) do
				iris.Window(debugger.window)

				debugger.callback()

				iris.End()
			end

			iris.PopConfig()
		end)
	end,

	cleanup = function()
		table.clear(debuggers)

		output:clear()
	end,
}
