--!optimize 2
--!native

local iris = require("@pkg/iris").Init()
local stack = require("@pkg/stack")

--[=[
	@interface log
	@within debugger
	@field message string -- The message logged.
	@field status "success" | "warn" | "error" -- The status of the log.
	@field time number -- When the message was logged.
	@field count number -- The amount of times the same message was sent. A value of 1 means the message isn't repeated.

	Represents a logged message.
]=]
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

--[=[
	@class debugger

	Implements logging and debug widgets.
]=]
local debugger = {}

--[=[
	@prop iris typeof(iris)
	@within debugger

	A reference to the Iris library, which implements immediate-mode UI.
	This is used for debugger windows.

	See [Iris' documentation](https://sirmallard.github.io/Iris/docs/intro)
	and it's [API reference.](https://sirmallard.github.io/Iris/api/Iris)
]=]
debugger.iris = iris

--[=[
	@prop output stack<Log>
	@within debugger

	A stack of all messages logged, which is rendered in the output.
]=]
debugger.output = output

--[=[
	@function log
	@within debugger

	Logs a message to the output. Logs are categorized by status:

	- `success`
	- `warn`
	- `error`, noting that errors do not block execution

	@param message string -- The message to log.
	@param status "success" | "warn" | "error" -- The status of the message.
]=]
function debugger.log(message: string, status: "success" | "warn" | "error")
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
end

--[=[
	@function add_debugger
	@within debugger

	Adds a new window to the debugger. Every frame, the callback is called to
	render the window.

	@param window { string } -- A tuple table, where the first value is the window's name.
	@param callback () -> () -- A callback which is called every frame to render the window.
	@param priority number -- The priority of the debugger.
]=]
function debugger.add_debugger(window: { string }, callback: () -> (), priority: number)
	table.insert(debuggers, {
		window = window,
		callback = callback,
		priority = priority,
	})

	table.sort(debuggers, function(a, b)
		return a.priority < b.priority
	end)
end

--[=[
	@function start
	@within debugger

	Starts the debugger.

	@param start_callback () -> boolean? -- If specified, whether if the debugger should be rendered.
]=]
function debugger.start(start_callback: () -> boolean?)
	if started then
		return
	end

	started = true

	iris:Connect(function()
		if start_callback ~= nil and start_callback() == false then
			return
		end

		iris.PushConfig({ RichText = true })

		for name, debugger in ipairs(debuggers) do
			iris.Window(debugger.window)

			debugger.callback()

			iris.End()
		end

		iris.PopConfig()
	end)
end

--[=[
	@function cleanup
	@within debugger

	Cleans outputted logs and all debuggers.
]=]
function debugger.cleanup()
	table.clear(debuggers)

	output:clear()
end

return table.freeze(debugger)
