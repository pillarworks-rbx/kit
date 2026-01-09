--!optimize 2
--!native

--[=[
	@class utility
	@tag std

	this module provides a collection of utility functions.
]=]
local utility = {}

local systems: { [any]: number } = {}
local uuids: { [uuid_type]: { string } } = {}

--[=[
	@type uuid_type "object"
	@within utility
	
	a type of uuid. represents a category of uuids.
]=]
export type uuid_type = "object"

--[=[
	@function collect
	@within utility
	@tag std
	
	collect events from a signal.
	
	@param event RBXScriptSignal -- the signal to collect events from.
	@return (() -> (number, any), () -> ()) -- the iterator function and the disconnect function.
]=]
function utility.collect(event: RBXScriptSignal)
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
	@within utility
	@tag std
	
	throttle a certain event. this works identically to matter's useThrottle hook.
	
	@param time_or_name number | any -- the identifier for the throttle system.
	@param time number? -- the time to wait before allowing the event to fire again.
	
	@return boolean -- whether or not the event can continue.
]=]
function utility.throttle(time_or_name: number | any, time: number?): boolean
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
	@within utility
	@tag std
	
	create a random uuid in a category.
	
	the uuid is 14 characters long, and consists of both uppercase and lowercase letters, and numbers from 0-9.
	
	@param uuid_type uuid_type -- the type of uuid to create.
	@return string -- the created uuid.
]=]
function utility.create_uuid(uuid_type: uuid_type): string
	local uuid = string.gsub("xxxxxxxxxxxxxx", "x", function()
		return all_characters[math.random(1, #all_characters)]
	end)

	uuids[uuid_type] = uuids[uuid_type] or {}

	table.insert(uuids[uuid_type], uuid)

	return uuid
end

return utility
