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

function string.startswith(str, start)
   return str:sub(1, #start) == start
end

function string.endswith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

function string.split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function love.AUI.filter(t, f)
	r = {}
	if type(f) == "function" then
		for k, v in pairs(t) do if f(v) then r[#r + 1] = v end end
	else
		for k, v in pairs(t) do if v == f then r[#r + 1] = v end end
	end
	return r
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

function love.AUI.search(t, n)
	for i, v in ipairs(t) do
		if v == n then
			return true
		end
	end
	return false
end

function love.AUI.inspect(table, deep)
    deep = deep or 0
    for k, v in pairs(table) do
        print(("\t"):rep(deep) .. tostring(k), v)
        if type(v) == "table" then
            inspect(v, deep + 1)
        end
    end
end