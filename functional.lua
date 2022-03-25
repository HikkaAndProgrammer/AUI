function love.AUI.sort(t, f)
	table.sort(t, f)
	return t
end

local function num_sort(a, b)
	return a < b
end

function love.AUI.sort_numbers(t)
	table.sort(t, num_sort)
	return t
end

local function key_num_sort(key)
	return function(a, b)
		return a[key] < b[key]
	end
end

function love.AUI.sort_key_numbers(t, key)
	table.sort(t, key_num_sort(key))
	return t
end

function love.AUI.map(t, l)
	for k, v in pairs(t) do
		t[k] = l(v)
	end
	return t
end

function love.AUI.get_first(t, n)
	local _t = {}
	local k, v
	for i = 1, n do
		if k then
			k, v = next(t, k)
		else
			k, v = next(t)
		end
		_t[k] = v
	end
	return _t
end

function love.AUI.get_first(t, n)
	local _t = {}
	local k, v
	for i = 1, n do
		if k then
			k, v = next(t, k)
		else
			k, v = next(t)
		end
		if k and v then
			_t[k] = v
		end
	end
	return _t
end

function love.AUI.get_last(t, n)
	local _t = {}
	for i = #t - n, #t do
		_t[i] = t[i]
	end
	return _t
end