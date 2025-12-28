--!optimize 2
--!native

local stack = {}
stack.__index = stack

function stack.new(maximum_size: number)
	local self = setmetatable({}, stack)

	self._stack = {}
	self._maximum_size = maximum_size

	return self
end

function stack:is_empty()
	return #self._stack == 0
end

function stack:push(value)
	table.insert(self._stack, value)

	if #self._stack > self._maximum_size then
		table.remove(self._stack, 1)
	end
end

function stack:pop()
	if self:is_empty() then
		return nil
	end

	return table.remove(self._stack, #self._stack)
end

function stack:peek()
	if self:is_empty() then
		return nil
	end

	return self._stack[#self._stack]
end

function stack:clear()
	table.clear(self._stack)
end

return stack
