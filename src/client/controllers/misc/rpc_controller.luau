--!optimize 2
--!native

local group = require("@shared/modules/group")
local rpc = require("@shared/modules/rpc")

local rpc_controller = {}

export type self = typeof(rpc_controller)

function rpc_controller.start(self: self)
	--// initialize group for this controller
	self.group = group.create()

	--// set initial rpc state
	rpc.SetRichPresence({
		details = "pillarworks kit",
		state = "testing the kit",
	})
end

function rpc_controller.stop(self: self)
	--// clean this controller's group
	self.group:clean()
end

return rpc_controller
