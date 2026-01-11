--// pillarworks internal sync tool 0.1.0
--// pls contribute improvements, i don't like this either

local commands = require("@libsync/commands")
local runner = require("@libsync/runner")

local richterm = require("@vendor/richterm")

local options = {}

local found_error = false
local version = "0.1.0"

print(`\n{richterm.bold(`pillarworks internal sync tool {version}`)}`)
print(`now syncing kit\n`)

for _, command: commands.command in pairs(commands) do
	local name = command.command
	local args = command.args
	local colour = command.colour
	
	local combined = richterm.combine(colour, richterm.bold)

	print(`running command "{combined(name.. " " .. table.concat(args, " "))}"`)
	
	local new_options = table.clone(options)
	
	if name == "darklua" then
    	new_options.stdio = "inherit"
    end

	local result = runner(name, args, new_options)

	if not result.success then
		local task_error = result.result.stderr

		if task_error == nil or task_error == "" then
			task_error = result.stdout

			if task_error == nil or task_error == "" then
				task_error = "unknown error"
			end
		end

		print(`command "{combined(name.. " " .. table.concat(args, " "))}" failed with error:\n{richterm.red(task_error)}`)

		found_error = true
	end

	print(`ran command "{combined(name.. " " .. table.concat(args, " "))}" with no errors\n`)
end

if found_error then
	print("one or more commands failed")
end

print(`darklua process output below:\n`)