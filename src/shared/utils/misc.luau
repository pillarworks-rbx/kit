--!optimize 2
--!native

--[=[
	@class misc_utils
	@tag utility

	this module contains *miscellaneous utils* that *all* scripts can access and use.
]=]
local misc_utils = {}

--[=[
	@type uuid_type "object"
	@within misc_utils

	a type of uuid. represents a category of uuids.
]=]
export type uuid_type = "object"

local systems: { [any]: number } = {}
local uuids: { [uuid_type]: { string } } = {}

--[=[
	@function traverse
	@within misc_utils

	loop through all descendants of the given instance and call the parse function for each child.
	
	you can also provide an optional class name to filter by.

	@param root Instance -- the roblox instance to loop through.
	@param parse_fn (child: Instance) -> () -- the function to call for each child.
	@param class string? -- the class to filter by.
]=]
function misc_utils.traverse(root: Instance, parse_fn: (child: Instance) -> (), class: string?)
	for _, child in pairs(root:GetChildren()) do
		if class then
			if child:IsA(class) then
				task.spawn(parse_fn, child)
			else
				misc_utils.traverse(child, parse_fn)
			end
		else
			task.spawn(parse_fn, child)
		end
	end
end



--[=[
	@function copy
	@within misc_utils
	@deprecated 0.1.0 -- use `misc_utils.traverse` instead

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

--[=[
	@function collect
	@within misc_utils

	collect events from a signal.

	@param event RBXScriptSignal -- the signal to collect events from.
	@return (() -> (number, any), () -> ()) -- the iterator function and the disconnect function.
]=]
function misc_utils.collect(event: RBXScriptSignal)
	local storage = {}
	local meta = {}

	local iter = function()
		local n = #storage

		return function()
			if n <= 0 then
				meta.__iter = nil

				return nil
			end

			n -= 1

			return n + 1, unpack(table.remove(storage, 1) :: any)
		end
	end

	local disconnect = event:Connect(function(...)
		table.insert(storage, { ... })

		meta.__iter = iter
	end)

	setmetatable(storage, meta)

	return (storage :: any) :: () -> (number, any), function()
		disconnect()
	end
end

--[=[
	@function throttle
	@within misc_utils

	throttle a certain event. this works identically to matter's useThrottle hook.

	@param time_or_name number | any -- the identifier for the throttle system.
	@param time number? -- the time to wait before allowing the event to fire again.

	@return boolean -- whether or not the event can continue.
]=]
function misc_utils.throttle(time_or_name: number | any, time: number?): boolean
	local name = time_or_name

	if time == nil then
		local file, line = debug.info(2, "sl")

		name = file .. ":" .. tostring(line)
		time = time_or_name
	end

	assert(time, "[throttle] no 'time' argument provided, please provide a number (in seconds) to wait")

	if systems[name] and systems[name] + time > os.clock() then
		return false
	end

	systems[name] = os.clock()

	return true
end

function get_char_range(start_code, end_code)
	local characters = {}

	for code = start_code, end_code do
		table.insert(characters, string.char(code))
	end

	return characters
end

local lowercase = get_char_range(string.byte("a"), string.byte("z"))
local uppercase = get_char_range(string.byte("A"), string.byte("Z"))
local digits = get_char_range(string.byte("0"), string.byte("9"))

local all_characters = {}

for _, tbl in pairs({ lowercase, uppercase, digits }) do
	for _, range in pairs(tbl) do
		table.insert(all_characters, range)
	end
end

--[=[
	@function create_uuid
	@within misc_utils

	create a random uuid in a category.

	the uuid is 14 characters long, and consists of both uppercase and lowercase letters, and numbers from 0-9.

	@param uuid_type uuid_type -- the type of uuid to create.
	@return string -- the created uuid.
]=]
function misc_utils.create_uuid(uuid_type: uuid_type): string
	local uuid = string.gsub("xxxxxxxxxxxxxx", "x", function()
		return all_characters[math.random(1, #all_characters)]
	end)

	uuids[uuid_type] = uuids[uuid_type] or {}

	table.insert(uuids[uuid_type], uuid)

	return uuid
end

return misc_utils
