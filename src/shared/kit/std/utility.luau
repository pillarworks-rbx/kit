--!optimize 2
--!native

local utility = {}

local systems: { [any]: number } = {}
local uuids: { [string]: { string } } = {}

export type throttle = (name: any, time: number) -> boolean | (time: number) -> boolean

function utility.collect<T...>(event: RBXScriptSignal<T...>)
	local storage = {}
	local mt = {}

	local iter = function()
		local n = #storage

		return function()
			if n <= 0 then
				mt.__iter = nil
				return nil
			end

			n -= 1

			return n + 1, unpack(table.remove(storage, 1) :: any)
		end
	end

	local disconnect = event:Connect(function(...)
		table.insert(storage, { ... })

		mt.__iter = iter
	end)

	setmetatable(storage, mt)

	return (storage :: any) :: () -> (number, T...), function()
		disconnect()
	end
end

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
	for _, char in pairs(tbl) do
		table.insert(all_characters, char)
	end
end

function utility.create_uuid(uuid_type: "object")
	local uuid = string.gsub("xxxxxxxxxxxxxx", "x", function()
		return all_characters[math.random(1, #all_characters)]
	end)

	uuids[uuid_type] = uuids[uuid_type] or {}

	table.insert(uuids[uuid_type], uuid)

	return uuid
end

return utility
