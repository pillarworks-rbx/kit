local process = require("@lune/process")

return function(task: string, args: { string })
	process.exec(task, args, {
		stdio = "forward",
	})
end
