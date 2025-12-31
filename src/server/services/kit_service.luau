--!optimize 2
--!native

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KIT_TAG = "pillarworks_kit"
local assets = ReplicatedStorage:WaitForChild("assets") :: Folder?

local group = require("@pkg/group")

local kit_service = {}

kit_service.priority = 2
kit_service.identifier = "kit_service"

export type self = typeof(kit_service)

function kit_service.prepare_pillar(_self: self, pillar: Folder)
	if not assets then
		return
	end

	if pillar then
		local objects = pillar:WaitForChild("objects") :: Folder

		if objects then
			objects.Name = "unloaded_objects"
			objects.Parent = assets
		end
	end
end

function kit_service.start(self: self)
	--// initialize group for this service
	self.group = group.create()

	local pillars = CollectionService:GetTagged(KIT_TAG)
	local pillar = pillars[1]
	
	if pillar and pillar:HasTag(KIT_TAG) and pillar:IsA("Folder") then
		self:prepare_pillar(pillar)
	end
end

function kit_service.stop(self: self)
	--// clean this service's group
	self.group:clean()
end

return kit_service
