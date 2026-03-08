local process = require("@lune/process")

local richterm = require("@libsync/vendor/richterm")
local frkcli = require("@libsync/vendor/frkcli")

local config = require("@libsync/config")

local name = `lune run {config.name}`
local description = table.concat(config.description, config.delimiter)

local cli = frkcli.new(name, description)

cli:add_flag("sourcemap", {
	aliases = { "-so" },
	help = "generate sourcemap",
})

cli:add_flag("network", {
	aliases = { "-n" },
	help = "generate network",
})

cli:add_flag("process", {
	aliases = { "-p" },
	help = "process src using darklua",
})

cli:add_flag("serve", {
	aliases = { "-se" },
	help = "serve out using rojo",
})

local start = require("@libsync/start")

local args = process.args or {}
local parsed, err = cli:parse(args)

if err ~= nil then
	print(`[{richterm.red("error")}] error while parsing command line arguments: {err}`)

	process.exit(1)
end

assert(parsed)

local flags = parsed.flags
local true_args = {} :: { string }

for flag_name, value in pairs(flags) do
	if value then
		table.insert(true_args, flag_name)
	end
end

if #true_args <= 0 then
	for flag_name, _ in pairs(flags) do
		flags[flag_name] = true
	end
end

start(flags)
