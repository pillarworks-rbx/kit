--!optimize 2
--!native

--[=[
	@class misc_utils
	@tag utility
	
	this module contains miscellaneous utils that all scripts can access and use.
]=]
local misc_utils = {}

--[=[
	@function traverse
	@within misc_utils
	@tag utility

	loop through all descendants of the given instance and call the parse function for each child.
	children have to be ModuleScripts in order to be parsed.

	@param root Instance -- the roblox instance to loop through.
	@param parse_fn (child: Instance) -> () -- the function to call for each child.
]=]
function misc_utils.traverse(root: Instance, parse_fn: (child: Instance) -> ())
	for _, child in pairs(root:GetChildren()) do
		if child:IsA("ModuleScript") then
			task.spawn(parse_fn, child)
		else
			misc_utils.traverse(child, parse_fn)
		end
	end
end

--[=[
	@function copy
	@within misc_utils
	@tag utility

	copy all children of the given instance to the destination folder.
	children have to be ModuleScripts in order to be copied.

	@param root Instance -- the roblox instance to loop through.
	@param destination Folder -- the folder to copy the children to.
]=]
function misc_utils.copy(root: Instance, destination: Folder)
	for _, child in pairs(root:GetChildren()) do
		if child:IsA("ModuleScript") then
			child:Clone().Parent = destination
		else
			misc_utils.copy(child, destination)
		end
	end
end

--[=[
	@function get_table_size
	@within misc_utils
	@tag utility

	get the size of an array or a dictionary.

	@param tbl { any } | { [string]: any } -- the table to get the size of.
	@return number -- the size of the table.
]=]
function misc_utils.get_table_size(tbl: { any } | { [string]: any }): number
	local size = 0
	
	for _ in pairs(tbl) do
		size += 1
	end
	
	return size
end

return misc_utils
