--!optimize 2
--!native

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = ReplicatedStorage:WaitForChild("assets") :: Folder?

local group = require("@shared/modules/group")

local kit_service = {}

export type self = typeof(kit_service)

function kit_service.prepare_pillar(self: self)
	if not assets then
		return
	end

	local pillar = workspace:WaitForChild("pillar") :: Folder?

	if pillar then
		local objects = pillar:WaitForChild("objects") :: Folder?

		if objects then
			objects.Name = "unloaded_objects"
			objects.Parent = assets
		end
	end
end

function kit_service.start(self: self)
	--// initialize group for this service
	self.group = group.create()

	--// prepare the pillar
	self:prepare_pillar()
end

function kit_service.stop(self: self)
	--// clean this service's group
	self.group:clean()
end

return kit_service
