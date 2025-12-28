--!optimize 2
--!native

export type Disconnect = () -> ()

local create
local __extend
local __children

export type ItemGroup<T = any> = {
	add: (ItemGroup<T>, item: T) -> Disconnect,
	clean: (ItemGroup<T>) -> (),
	extend: typeof(__extend),

	items: {T},
	cleanup_handler: (T) -> (),
	children: typeof(__children),
}

__children = {(nil :: any) :: ItemGroup<any>}

function __extend<T>(self: any, new_cleanup_handler: (T) -> (), items: { T }?): ItemGroup<T>
	return nil :: any
end

local function group_add(self: ItemGroup, item: any)
	local items = self.items
	
	table.insert(items, item)

	return function()
		local idx = table.find(items, item)
		
		if idx then
			table.remove(items, idx)
		end
	end
end

local function group_clean(self: ItemGroup)
	local items = self.items
	local cleanup_handler = self.cleanup_handler
	local children = self.children

	for _, child: any in children do
		child:clean()
	end
	
	for _, item in items do
		cleanup_handler(item)
	end
	
	table.clear(items)
end

local function group_extend<A>(self: ItemGroup)
	local new = create()
	
	table.insert(self.children, new)
	
	return new
end

function create<T>(): ItemGroup<T>
	return {
		items = {},
		children = {},
		cleanup_handler = function(item: any)
			if typeof(item) == "Instance" then
				item:Destroy()
			elseif typeof(item) == "table" then
				table.clear(item)
			elseif typeof(item) == "function" then
				item()
			elseif typeof(item) == "thread" then
				task.cancel(item)
			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()
			end
		end,

		clean = group_clean,
		add = group_add,
		extend = group_extend,
	} :: ItemGroup<T>
end

return {
	create = create
}
