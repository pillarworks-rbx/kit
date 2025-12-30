--!optimize 2
--!native

local misc_utils = {}

function misc_utils.traverse(root: Instance, tbl: { any }, parse_fn: (child: Instance) -> ())
	for _, child in pairs(root:GetChildren()) do
		if child:IsA("ModuleScript") then
			task.spawn(parse_fn, child)
		else
			misc_utils.traverse(child, tbl, parse_fn)
		end
	end
end

function misc_utils.copy(root: Instance, destination: Folder)
	for _, child in pairs(root:GetChildren()) do
		if child:IsA("ModuleScript") then
			child:Clone().Parent = destination
		else
			misc_utils.copy(child, destination)
		end
	end
end

function misc_utils.get_table_size(tbl: { any } | { [string]: any }): number
	local size = 0
	
	for _ in pairs(tbl) do
		size += 1
	end
	
	return size
end

return misc_utils
