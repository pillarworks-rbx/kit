--!optimize 2
--!native

local stack = {}
stack.__index = stack

function stack.new(maximum_size: number)
	assert(type(maximum_size) == "number", "maximum_size must be a number")
	assert(maximum_size >= 1, "maximum_size must be >= 1")

	maximum_size = math.floor(maximum_size)

	local self = setmetatable({}, stack)

	self._stack = {}
	self._maximum_size = maximum_size

	return self
end

function stack:is_empty()
	if not self._stack then
		return true
	end

	if typeof(self._stack) ~= "table" then
		return true
	end

	return #self._stack == 0
end

function stack:push(value)
	table.insert(self._stack, value)

	if #self._stack > self._maximum_size then
		table.remove(self._stack, 1)
	end
end

function stack:pop(): any?
	if self:is_empty() then
		return nil
	end

	return table.remove(self._stack, #self._stack)
end

function stack:peek(): any?
	if self:is_empty() then
		return nil
	end

	return self._stack[#self._stack]
end

function stack:size(): number
	return #self._stack
end

function stack:clear()
	table.clear(self._stack)
	self._stack = {}
end

return stack
