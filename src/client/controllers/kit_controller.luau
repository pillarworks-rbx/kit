--!optimize 2
--!native

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:WaitForChild("assets") :: Folder?
local unloaded_objects = assets and assets:WaitForChild("unloaded_objects") :: Folder?

local group = require("@shared/modules/group")
local debugger = require("@shared/debugger")

local kit_types = require("@kit/types")
local repository = require("@kit/repository") :: { [string]: any }
local std = require("@kit/std")

local utility = std.utility

local kit_controller = {}

local OBJECT_TAG = "pillarworks_obj"
local OBJECT_TYPES = {}

for name in pairs(repository) do
	table.insert(OBJECT_TYPES, name)
end

--// store a list of loaded objects for future use
--// separated by pillar id (e.g everpresent and normal pillars are in different tables)
kit_controller.loaded_objects = {} :: { [string]: { [string]: kit_types.object<any> } }

export type self = typeof(kit_controller)

export type pillar_data = kit_types.pillar_data

function kit_controller.load_object_type(self: self, instance: Instance, obj_type: string, pillar_data: pillar_data)
	--// get object type from attribute
	if not obj_type or not table.find(OBJECT_TYPES, obj_type) then
		debugger.log(`object type "{obj_type}" does not exist!`, "warn")

		return
	end

	--// check if the object type exists in the repository
	local repo_object = repository[obj_type]

	if not repo_object then
		debugger.log(`object type "{obj_type}" does not exist in the repository!`, "warn")

		return
	end

	local obj_id = instance:GetAttribute("obj_id")

	--// check if the pillar already has a loaded objects table
	local pillar_objects = self.loaded_objects[pillar_data.id]

	if not pillar_objects then
		--// if not, create it
		pillar_objects = {}
	end

	--// clone the repository module and set the instance
	repo_object = table.clone(repo_object)

	repo_object.id = `{obj_id}-{obj_type}`
	repo_object.instance = instance

	--// create a group for the object
	--// object group is stored inside of the pillar group, and is cleaned up when the pillar is destroyed
	repo_object.group = pillar_data.group:extend()

	--// load the object
	repo_object.events.load(repo_object, pillar_data)

	--// add the object to the pillar's loaded objects table
	--// and set the pillar's loaded objects table
	pillar_objects[repo_object.id] = repo_object
	self.loaded_objects[pillar_data.id] = pillar_objects
end

function kit_controller.load_object(self: self, instance: Instance, pillar_data: pillar_data)
	--// check if the instance has the OBJECT_TAG tag
	if not instance:HasTag(OBJECT_TAG) then
		debugger.log(`instance "{instance:GetFullName()}" does not have tag "{OBJECT_TAG}"!`, "warn")

		return
	end

	--// get object type from attribute
	local obj_type = instance:GetAttribute("obj_type")

	--// if it doesn't exist, return early
	if not obj_type then
		debugger.log(`object "{instance:GetFullName()}" does not have an object type!`, "warn")

		return
	end

	--// check if the pillar already has a loaded objects table
	local pillar_objects = self.loaded_objects[pillar_data.id]

	if not pillar_objects then
		--// if not, create it
		pillar_objects = {}
	end

	--// check if the object already has an id
	local obj_id = instance:GetAttribute("obj_id")

	--// if it does, return early
	if pillar_objects[obj_id] then
		debugger.log(`object "{obj_id}" already exists in the pillar!`, "warn")

		return
	end

	--// generate a new id for the object
	obj_id = utility.create_uuid("object")

	--// set the object id attribute on the instance
	instance:SetAttribute("obj_id", obj_id)

	--// split the object type string into an array of object types
	--// e.g "conveyor,damage_brick" would turn into {"conveyor", "damage_brick"} and both would be added to the part
	local obj_types = string.split(obj_type, ",")

	for _, object_type in pairs(obj_types) do
		object_type = string.gsub(object_type, "^%s*(.-)%s*$", "%1")

		self:load_object_type(instance, object_type, pillar_data)
	end
end

function kit_controller.unload_objects(self: self, pillar_data: pillar_data)
	local pillar_objects = self.loaded_objects[pillar_data.id] or {}

	for _, object: kit_types.object<any> in pairs(pillar_objects) do
		object.events.unload(object, pillar_data)
	end
end

function kit_controller.start(self: self)
	--// initialize group for this controller
	self.group = group.create()

	--// initialize objects group
	local objects_group = group.create()

	--// initialize pillar data
	local pillar_data = {
		id = "pillarworks",
		group = objects_group,
	}

	local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	--// add death connection to the group
	self.group:add(humanoid.Died:Connect(function()
		self.group:clean()
	end))

	--// add a cleanup function that cleans all of the repo objects
	self.group:add(function()
		objects_group:clean()
		self:unload_objects(pillar_data)
	end)

	if not unloaded_objects then
		return
	end

	--// delete previous loaded objects
	if workspace:FindFirstChild("loaded_objects") then
		workspace:FindFirstChild("loaded_objects"):Destroy()
	end

	--// clone unloaded objects into workspace
	local loaded_objects = unloaded_objects:Clone()

	loaded_objects.Name = "loaded_objects"
	loaded_objects.Parent = workspace

	--// loop through all descendants and load them
	for _, instance in pairs(loaded_objects:GetDescendants()) do
		if instance:HasTag(OBJECT_TAG) then
			task.spawn(self.load_object, self, instance, pillar_data)
		end
	end
end

function kit_controller.stop(self: self)
	--// clean this controller's group
	self.group:clean()
end

return kit_controller
