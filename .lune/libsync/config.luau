local richterm = require("@libsync/vendor/richterm")

return table.freeze({
	name = "sync",

	description = {
		`sync - the official pillarworks initialiser`,
		``,
		`{richterm.bold("notes")}:`,
		`- leaving all flags out will run {richterm.italic("all")} tasks.`,
		`- you can still use the provided zed tasks. this is just a basic wrapper.`,
	},

	delimiter = "\n     ",
})
