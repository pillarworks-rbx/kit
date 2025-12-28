--!optimize 2
--!native

local misc_utils = {}

function misc_utils.traverse(root: Folder, tbl: { any })
	for _, child in pairs(root:GetChildren()) do
		if child:IsA("ModuleScript") then
			tbl[child.Name] = require(child)
		elseif child:IsA("Folder") then
			misc_utils.traverse(child, tbl)
		end
	end
end

function misc_utils.copy(root: Folder, destination: Folder)
	for _, child in pairs(root:GetChildren()) do
		if child:IsA("ModuleScript") then
			child:Clone().Parent = destination
		elseif child:IsA("Folder") then
			misc_utils.copy(child, destination)
		end
	end
end

return misc_utils