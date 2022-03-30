local date = {
	__def_val = {
		boolean = true,
		string = true,
		number = true
	},
	__shorten_val = {
		["function"] = true,
		thread = true,
		userdata = true,
		["nil"] = true
	},
	__spec_val = {
		table = true
	}
}

--[==[ UNIT TEST FUNCTION
local function test(t)
	for i, v in ipairs(t) do
		local passed
		if type(v[2]) == "table" then
			passed = v[2][v[1]]
		elseif type(v[2]) == "function" then
			passed = v[2](v[1])
		else
			passed = v[1] == v[2]
		end
		if not passed then
			print("Test " .. i .. " failed!")
			print(v[1], v[2])
			return false
		end
	end
	return true
end
]==]

local function trim(s)
	local n = s:find"%S"
	return n and s:match(".*%S", n) or ""
end

function date.encode(t, st)
	if date.__shorten_val[type(t)] then
		return type(t)
	elseif date.__def_val[type(t)] then
		return trim(tostring(t):gsub("\\", "\\\\"):gsub(":", "\\:")
				:gsub("%-", "\\-"):gsub("%^", "\\^"):gsub("{", "\\{"):gsub("}", "\\}"))
	elseif st then
		if st[1][t] then
			return "{^" .. st[2][t] .. "}"
		end
	end
	st = st or {{}, {}, 0}
	if not st[1][t] then
		st[3] = st[3] + 1
		st[1][t] = true
		st[2][t] = st[3]
	end
	local result = {}
	local c = 1
	local ordered = true
	for k, v in pairs(t) do
		ordered = ordered and c == k
		local append = ""
		if not ordered then
			append = date.encode(k, st) .. "-"
		end
		if date.__spec_val[type(v)] then
			if st[1][v] then append = append .. "{^" .. st[2][v] .. "}"
			else
				append = append .. "{" .. date.encode(v, st) .. "}"
				if not st[1][t] then
					st[3] = st[3] + 1
					st[1][t] = true
					st[2][t] = st[3]
				end
			end
		elseif date.__shorten_val[type(v)] then
			append = append .. type(v)
		elseif date.__def_val[type(v)] then
			append = append .. trim(tostring(v):gsub("\\", "\\\\"):gsub(":", "\\:")
					:gsub("%-", "\\-"):gsub("%^", "\\^"):gsub("{", "\\{"):gsub("}", "\\}"))
		end
		result[#result + 1] = append
		c = c + 1
	end
	return table.concat(result, ":")
end

function date.decode(s, st)
	if type(s) ~= "string" then return error("date.decode arg #1 must be string") end
	s = trim(s)
	if #s:gsub("\\?%-?%d+%.?$d*", "") == 0 then return tonumber(({s:gsub("\\", "")})[1])
	elseif s == "true" then return true
	elseif s == "false" then return false
	elseif s == "function" then return function() end
	elseif s == "thread" then return coroutine.create(function() end)
	elseif s == "userdata" then return "userdata"
	elseif s == "nil" then return nil end
	local result = {}
	if st == nil then
		st = { result }
	else
		st[#st + 1] = result
	end
	local sv = {}
	local key, last

	local function parseValue(x)
		if type(x) ~= "string" then return error("date.decode.parseValue arg #1 must be string") end
		x = trim(x)
		if x == "false" then return false
		elseif #x:gsub("%{%^%d+%}", "") == 0 then return st[tonumber(x:gmatch"%d+"())]
		elseif x == "true" then return true
		elseif x == "nil" then return nil
		elseif #x:gsub("\\?%-?%d+%.?%d*", "") == 0 then return tonumber(({x:gsub("\\", "")})[1])
		elseif x == "function" then return function() end
		elseif x == "thread" then return coroutine.create(function() end)
		elseif x == "userdata" then return "userdata"
		elseif x:sub(1, 1) == "{" then return date.decode(x:sub(2, #x - 1), st)
		else return x:gsub("\\%-", "-"):gsub("\\:", ":"):gsub("\\{", "{"):gsub("\\%^", "^") end
	end

	local d = 0
	for c in s:gmatch"." do
		if c == '{' and last ~= '\\' then
			d = d + 1
			sv[#sv + 1] = c
		elseif c == '}' and last ~= '\\' then
			d = d - 1
			sv[#sv + 1] = c
		elseif c == '-' and last ~= '\\' and d == 0 then
			key = sv
			sv = {}
		elseif c == ':' and last ~= '\\' and d == 0 then
			if key then
				result[parseValue(table.concat(key, ""))] = parseValue(table.concat(sv, ""))
				key = nil
				sv = {}
			else
				result[#result + 1] = parseValue(table.concat(sv, ""))
				sv = {}
			end
		else sv[#sv + 1] = c end
		last = c
	end
	if #sv > 0 then
		if key then
			result[parseValue(table.concat(key, ""))] = parseValue(table.concat(sv, ""))
		else
			result[#result + 1] = parseValue(table.concat(sv, ""))
		end
	end

	return result
end

--[==[ UNIT TEST
local self_ref = {}
self_ref[1] = self_ref

local self_ref2 = {}
self_ref2[self_ref2] = self_ref2

for i = 1, 0x40 do
	local s = test{
		-- 0-7
		{date.encode{1, 2}, "1:2"},
		{date.encode{1, 3, 2}, "1:3:2"},
		{date.encode{"str", 3, "ing"}, "str:3:ing"},
		{date.encode{"str", {"table"} ,"ing"}, "str:{table}:ing"},
		{date.encode{"str", {{"table"}} ,"ing"}, "str:{{table}}:ing"},
		{date.encode{"str", {{"table", 2}, 1} ,"ing"}, "str:{{table:2}:1}:ing"},
		{date.encode{ function()end, coroutine.create(function()end) }, "function:thread"},
		{date.encode{ true, false, nil, 1, -1, "-:" }, "true:false:4-1:5-\\-1:6-\\-\\:"},
		-- 10-17
		{date.encode"q+u:e-i", "q+u\\:e\\-i"},
		{date.encode(-5), "\\-5"},
		{date.encode(true), "true"},
		{date.encode(false), "false"},
		{date.encode(nil), "nil"},
		{date.encode{}, ""},
		{date.encode{nil}, ""},
		{date.encode{nil, nil}, ""},
		-- 20-27
		{date.encode{a = 1}, "a-1"},
		{date.encode{a = {b = {c = 1}}}, "a-{b-{c-1}}"},
		{date.encode{x = [[big
		python]]}, [[x-big
		python]]},
		{date.encode{["-"] = "-", [":"] = ":"}, {["\\:-\\::\\--\\-"] = true, ["\\--\\-:\\:-\\:"] = true}},
		{date.encode{self_ref}, "{{^2}}"},
		{date.encode(self_ref), "{^1}"},
		{date.encode(self_ref2), "{^1}-{^1}"},
		{date.encode(date.decode("1")), "1"},
		-- 30-37
		{date.encode(date.decode("\\-1")), "\\-1"},
		{date.encode(date.decode("str+ing")), "str+ing"},
		{date.encode(date.decode("st\\:ri\\-ng")), "st\\:ri\\-ng"},
		{date.decode("true"), true},
		{date.decode("false"), false},
		{date.decode("nil"), nil},
		{date.encode(date.decode("function")), "function"},
		{date.encode(date.decode("thread")), "thread"},
		-- 40-47
		{date.encode(date.decode("userdata")), "userdata"},
		{date.encode(date.decode("1:2")), "1:2"},
		{date.decode"1:2"[1], 1},
		{date.decode"1:2"[2], 2},
		{date.encode(date.decode"str:3:ing"), "str:3:ing"},
		{date.decode"str:3:ing"[1], "str"},
		{date.decode"str:3:ing"[2], 3},
		{date.decode"str:3:ing"[3], "ing"},
		-- 50-57
		{date.decode"str:{table}:ing"[1], "str"},
		{date.decode"str:{table}:ing"[2][1], "table"},
		{date.decode"str:{table}:ing"[3], "ing"},
		{date.decode(date.encode{"str", {{"table", 2}, 1} ,"ing"})[1], "str"},
		{date.decode(date.encode{"str", {{"table", 2}, 1} ,"ing"})[2][1][1], "table"},
		{date.decode(date.encode{"str", {{"table", 2}, 1} ,"ing"})[2][1][2], 2},
		{date.decode(date.encode{"str", {{"table", 2}, 1} ,"ing"})[2][2], 1},
		{date.decode(date.encode{"str", {{"table", 2}, 1} ,"ing"})[3], "ing"},
		-- 60-67
		{date.decode"q+u\\:e\\-i"[1], "q+u:e-i"},
		{date.decode"true:false:4-1:5-\\-1:6-\\-\\:"[1], true},
		{date.decode"true:false:4-1:5-\\-1:6-\\-\\:"[2], false},
		{date.decode"true:false:4-1:5-\\-1:6-\\-\\:"[3], nil},
		{date.decode"true:false:4-1:5-\\-1:6-\\-\\:"[4], 1},
		{date.decode"true:false:4-1:5-\\-1:6-\\-\\:"[5], -1},
		{date.decode"true:false:4-1:5-\\-1:6-\\-\\:"[6], "-:"},
		{date.decode"a-1"["a"], 1},
		-- 70-77
		{date.decode"a-1".a, 1},
		{date.decode"a-{b-{c-1}}".a.b.c, 1},
		{date.decode[[x-big
		python]].x, [[big
		python]]},
		{date.decode"\\:-\\::\\--\\-"[":"], ":"},
		{date.decode"\\:-\\::\\--\\-"["-"], "-"},
		{date.decode"{{^2}}", function(x) return x[1][1] == x[1] end},
		{date.decode"{^1}", function(x) return x[1] == x end},
		{date.decode"{^1}-{^1}", function(x) return x[x] == x end}
	}
	if not s then print("(iteration [" .. i .. "])") break end
end
]==]

return date