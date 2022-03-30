local ITabLayout = setmetatable({
	DefaultValue = { width = 0, height = 0, __offset = { 0, 0 } }
}, { __index = function(self, k)
		if type(k) == "number" then
			return rawget(self, "children")[k]
		else
			return rawget(self, k) or rawget(love.AUI.ITabLayout, k) or love.AUI.IUIObject[k]
		end
	end
})

function ITabLayout:draw()
	for i, v in ipairs(self.children) do
		v:draw(self)
	end
	if self.line then
		love.graphics.setLineWidth(self.line.width)
		love.graphics.setColor(self.line.color)
		love.graphics.polygon("line", unpack(self.__p))
	end
end

function ITabLayout:checkHover(x, y)
	self.__hover = false
	if (((self.x - self.width / 2) < x) and ((self.y - self.height / 2) < y))
				and (((self.x + self.width / 2) > x) and ((self.y + self.height / 2) > y)) then
		self:hover()
	else
		self:unhover()
		return self.__hover
	end
	for i, v in ipairs(self.children) do
		if (((v.x - v.width / 2) < x) and ((v.y - v.height / 2) < y))
			and (((v.x + v.width / 2) > x) and ((v.y + v.height / 2) > y)) then
				v:checkHover(x, y)
		else v:unhover() end
	end
	return self.__hover
end

function ITabLayout:onMouseMove(x, y, dx, dy)
	for i, v in ipairs(self.children) do
		if (((v.x - v.width / 2) < x) and ((v.y - v.height / 2) < y))
		and (((v.x + v.width / 2) > x) and ((v.y + v.height / 2) > y)) then
			v:onMouseMove(x, y, dx, dy)
		end
	end
end

function ITabLayout:click(x, y, button)
	for i, v in ipairs(self.children) do
		if (((v.x - v.width / 2) < x) and ((v.y - v.height / 2) < y))
		and (((v.x + v.width / 2) > x) and ((v.y + v.height / 2) > y)) then
			v:click(x, y, button)
		end
	end
end

function ITabLayout:unhover()
	if not self.__hover then return end
	self.__hover = false
	for k, v in pairs(self.default) do
		self[k] = v
	end
	for i, v in ipairs(self.children) do
		v:unhover()
	end
end

function ITabLayout:hover()
	if self.__hover then return end
	self.__hover = true
	for k, v in pairs(self.hoverData) do
		self[k] = v
	end
end

function ITabLayout:getElementById(id)
	for i, children in ipairs(self.tabs) do
		for i, v in ipairs(children) do
			if v.id == id then return v
			elseif v.type == "container" then return v:getElementById(id)
			end
		end
	end
end

function ITabLayout:addChild(child)
	self.children[#self.children + 1] = child
end

function ITabLayout:addChildToTab(child, n)
	if self.tabs[n] then
		self.tabs[n][#(self.tabs[n]) + 1] = child
	end
end

function ITabLayout:recreate(parent)
	self.parent = parent or self.parent
	return love.AUI.TabLayout(self)
end

function ITabLayout:setTab(n)
	if self.tabs[n] then
		self.children = self.tabs[n]
	end
end

local function TabLayout(tablayout)
	tablayout = tablayout or {}
	local parent = tablayout.parent or tablayout.scene or { width = 0, height = 0 }
	local tabs = tablayout.tabs or tablayout
	local padding = tablayout.padding or { 0, 0 }
	local offsetfx = tablayout.offset_fx or function(x) return 0 end
	local offsetfy = tablayout.offset_fy or function(x) return x end
	if getmetatable(tablayout) == nil or getmetatable(tablayout).__index ~= getmetatable(ITabLayout).__index then
		local tl = tablayout
		tablayout = setmetatable({
			id = tablayout.id,
			type = "container",
			parent = tablayout.parent,
			x = tablayout.x or math.floor(parent.width / 2),
			y = tablayout.y or math.floor(parent.height / 2),
			width  = tablayout.width  or tablayout.w or parent.width,
			height = tablayout.height or tablayout.h or parent.height,
			children = nil,
			tabs = {},
			__p = {
				0, 0, 0, 0, 0, 0, 0, 0
			},
			line = tablayout.line,
			__hover = false,
			hoverData = tablayout.hoverData or {},
			default = {},
			onMouseMove = tablayout.onMouseMove or nil,
			name = tablayout.name or "tablayout"
		}, { __index = getmetatable(ITabLayout).__index })
		for k, v in pairs(tl) do if not rawget(tablayout, k) then tablayout[k] = v end end
	end
	if tablayout.line then
		tablayout.__p[1], tablayout.__p[2] = tablayout.x - tablayout.width / 2, tablayout.y - tablayout.height / 2
		tablayout.__p[3], tablayout.__p[4] = tablayout.x + tablayout.width / 2, tablayout.y - tablayout.height / 2
		tablayout.__p[5], tablayout.__p[6] = tablayout.x + tablayout.width / 2, tablayout.y + tablayout.height / 2
		tablayout.__p[7], tablayout.__p[8] = tablayout.x - tablayout.width / 2, tablayout.y + tablayout.height / 2
	end
	if tablayout.line then
		if type(tablayout.line) ~= "table" then tablayout.line = {} end
		if not tablayout.line.color then
			tablayout.line.color = {1, 1, 1}
		end
		if not tablayout.line.width then
			tablayout.line.width = 1
		end
	end
	if tablayout.recreate_children ~= false then
		for i, children in ipairs(tabs) do
			for i, v in ipairs(children) do
				children[i] = v:recreate(tablayout)
			end
			tablayout.tabs[i] = children
		end
	end
	for k, v in pairs(tablayout.hoverData) do
		tablayout.default[k] = tablayout[k]
	end
	tablayout.children = tablayout.tabs[1]
	return tablayout
end

return {ITabLayout, TabLayout}