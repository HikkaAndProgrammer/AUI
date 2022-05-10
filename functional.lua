function table.sort(t, f)
	table.sort(t, f)
	return t
end

local function num_sort(a, b)
	return a < b
end

function table.sort_numbers(t)
	table.sort(t, num_sort)
	return t
end

local function key_num_sort(key)
	return function(a, b)
		return a[key] < b[key]
	end
end

function table.sort_key_numbers(t, key)
	table.sort(t, key_num_sort(key))
	return t
end

function table.map(t, l)
	for k, v in pairs(t) do
		t[k] = l(v)
	end
	return t
end

function string.startswith(str, start)
   return str:sub(1, #start) == start
end

function string.endswith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

function string.split(s, delimiter)
	result = {}
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match)
	end
	return result
end

function table.filter(t, f)
	r = {}
	if type(f) == "function" then
		for k, v in pairs(t) do if f(v) then r[#r + 1] = v end end
	else
		for k, v in pairs(t) do if v == f then r[#r + 1] = v end end
	end
	return r
end

function table.get_first(t, n)
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

function table.get_last(t, n)
	local _t = {}
	for i = #t - n, #t do
		_t[i] = t[i]
	end
	return _t
end

function table.search(t, n)
	for i, v in ipairs(t) do
		if v == n then
			return true
		end
	end
	return false
end

function table.inspect(t, deep)
	if t == love.AUI.logger then return end
	deep = deep or 0
	for k, v in pairs(t) do
		print(("\t"):rep(deep) .. tostring(k), v)
		if type(v) == "table" then
			table.inspect(v, deep + 1)
		end
	end
end

function raw(x) return x end