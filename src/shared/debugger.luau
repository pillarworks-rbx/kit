--!optimize 2
--!native

local iris = require("@pkg/iris").Init()
local stack = require("@shared/modules/stack")

--[=[
	@interface log
	@within debugger
	
	@field message string -- the message logged.
	@field status "success" | "warn" | "error" -- the status of the log.
	@field time number -- when the message was logged.
	@field count number -- the amount of times the same message was sent. a value of 1 means the message isn't repeated.

	represents a logged message.
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
	
	this module implements logging and debug widgets.
]=]
local debugger = {}

--[=[
	@prop iris typeof(iris)
	@within debugger

	a reference to the iris library, which implements immediate-mode ui. this is used for debugger windows.
	
	see [iris' documentation](https://sirmallard.github.io/Iris/docs/intro)
	and [api reference](https://sirmallard.github.io/Iris/api/Iris)
	for more detail.
]=]
debugger.iris = iris

--[=[
	@prop output stack<log>
	@within debugger

	a stack of all messages logged, which is rendered in the output.
	
	the maximum amount of logs that can be stored is determined by the `MAX_LOGS` constant.
	by default, this is set to 200.
]=]
debugger.output = output

--[=[
	@function log
	@within debugger

	logs a message to the output. logs are categorized by status:
	- `success`
	- `warn`
	- `error`, although errors do not block execution
	
	if the message is the same as the last message, the count is incremented instead of pushing a new log.
	
	messages are automatically prefixed with the current time and status, and have richtext enabled.
	
	@param message string -- the message to log.
	@param status "success" | "warn" | "error" -- the status of the message
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

	adds a new window to the debugger. every frame, the callback is called to render the window.

	@param window { string } -- an Iris window. see [window](https://sirmallard.github.io/Iris/api/Window#Window) for more information.
	@param callback () -> () -- a callback which is called every frame to render the window.
	@param priority number -- the priority of the debugger widget.
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

	starts the debugger.

	@param validate () -> boolean? -- if specified, returns a boolean which determines if the debugger should be rendered.
]=]
function debugger.start(validate: () -> boolean?)
	if started then
		return
	end

	started = true

	iris:Connect(function()
		if validate ~= nil and validate() == false then
			return
		end

		iris.PushConfig({ RichText = true })

		for _, rendered_debugger in ipairs(debuggers) do
			iris.Window(rendered_debugger.window)

			rendered_debugger.callback()

			iris.End()
		end

		iris.PopConfig()
	end)
end

--[=[
	@function cleanup
	@within debugger

	cleans outputted logs and all debuggers.
]=]
function debugger.cleanup()
	table.clear(debuggers)

	output:clear()
end

return table.freeze(debugger)
