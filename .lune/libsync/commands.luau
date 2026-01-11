local richterm = require("@vendor/richterm")

export type command = {
	command: string,
	colour: richterm.Formatter,
	args: { string },
}

return {
	sourcemap = {
		command = "rojo",
		colour = richterm.red,
		args = {
			"sourcemap",
			"sourcemap.project.json",
			"--output",
			"sourcemap.json",
			"--watch",
		},
	},

	net = {
		command = "blink",
		colour = richterm.yellow,
		args = {
			"ext/network/core.blink",
			"--watch",
		},
	},

	aliases = {
		command = "darklua",
		colour = richterm.magenta,
		args = {
			"process",
			"src",
			"out",
			"--watch",
		},
	},

	serve = {
		command = "rojo",
		colour = richterm.red,
		args = {
			"serve",
			"kit.project.json",
		},
	},
} :: { [string]: command }
