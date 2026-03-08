local fs = require("@lune/fs")
local task = require("@lune/task")
local process = require("@lune/process")

local exec_config = {
	stdio = "forward",
}

return function(flags: { [string]: boolean })
	if fs.isDir("out") then
		fs.removeDir("out")
	end

	if flags.sourcemap then
		process.exec("rojo", { "sourcemap", "sourcemap.project.json", "--output", "sourcemap.json" }, exec_config)
	end

	if flags.network then
		process.exec("blink", { "ext/network/core.blink" }, exec_config)
	end

	if flags.process then
		process.exec("darklua", { "process", "src", "out" }, exec_config)
	end

	if flags.serve then
		task.spawn(
			process.exec,
			"rojo",
			{ "sourcemap", "sourcemap.project.json", "--output", "sourcemap.json", "--watch" },
			{
				stdio = "forward",
			}
		)

		task.spawn(process.exec, "blink", { "ext/network/core.blink", "--watch" }, exec_config)
		task.spawn(process.exec, "darklua", { "process", "src", "out", "--watch" }, exec_config)
		task.spawn(process.exec, "rojo", { "serve", "kit.project.json" }, exec_config)
	end
end
