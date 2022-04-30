local ILayout = setmetatable({
	DefaultValue = { width = 0, height = 0, __offset = { 0, 0 } }
}, { __index = function(self, k)
		if type(k) == "number" then
			return rawget(self, "children")[k]
		else
			return rawget(self, k) or rawget(love.AUI.ILayout, k) or love.AUI.IUIObject[k]
		end
	end
})

function ILayout:draw()
	for i, v in ipairs(self.children) do
		v:draw(self)
		love.graphics.setColor({1, 1, 1, 1})
	end
	if self.line then
		love.graphics.setLineWidth(self.line.width)
		love.graphics.setColor(self.line.color)
		love.graphics.polygon("line", unpack(self.__p))
	end
end

function ILayout:checkHover(x, y)
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
		elseif v.__hover then v:unhover() end
	end
	return self.__hover
end

function ILayout:onMouseMove(x, y, dx, dy)
	for i, v in ipairs(self.children) do
		if (((v.x - v.width / 2) < x) and ((v.y - v.height / 2) < y))
		and (((v.x + v.width / 2) > x) and ((v.y + v.height / 2) > y)) then
			v:onMouseMove(x, y, dx, dy)
		end
	end
end

function ILayout:click(x, y, button)
	for i, v in ipairs(self.children) do
		if (((v.x - v.width / 2) < x) and ((v.y - v.height / 2) < y))
		and (((v.x + v.width / 2) > x) and ((v.y + v.height / 2) > y)) then
			v:click(x, y, button)
		end
	end
end

function ILayout:press(x, y, button)
	for i, v in ipairs(self.children) do
		if (((v.x - v.width / 2) < x) and ((v.y - v.height / 2) < y))
		and (((v.x + v.width / 2) > x) and ((v.y + v.height / 2) > y)) then
			v:press(x, y, button)
		end
	end
end

function ILayout:unhover()
	if not self.__hover then return end
	self.__hover = false
	for k, v in pairs(self.default) do
		self[k] = v
	end
	for i, v in ipairs(self.children) do
		v:unhover()
	end
end

function ILayout:hover()
	if self.__hover then return end
	self.__hover = true
	for k, v in pairs(self.hoverData) do
		self[k] = v
	end
end

function ILayout:addChild(child)
	self.children[#self.children + 1] = child
end

function ILayout:removeChild(id)
	for k, v in pairs(self.children) do
		if v.id and v.id == id or k == id then table.remove(self.children[k]) end
	end
end

function ILayout:getElementById(id)
	for i, v in pairs(self.children) do
		if v.id then
			if v.id == id then return v
			end
		end
		if v.type == "container" then
			local t = v:getElementById(id)
			if t then return t end
		end
	end
end

function ILayout:recreate(parent)
	self.parent = parent or self.parent
	return love.AUI.Layout(self)
end

local function Layout(layout)
	layout = layout or {}
	local parent = layout.parent or layout.scene or { width = 0, height = 0 }
	local children = layout.children or layout
	local padding = layout.padding or { 0, 0 }
	local offsetfx = layout.offset_fx or function(x) return 0 end
	local offsetfy = layout.offset_fy or function(x) return x end
	if getmetatable(layout) == nil or getmetatable(layout).__index ~= getmetatable(ILayout).__index then
		local l = layout
		layout = setmetatable({
			id = layout.id,
			type = "container",
			parent = layout.parent,
			x = layout.x or math.floor(parent.width / 2),
			y = layout.y or math.floor(parent.height / 2),
			width  = layout.width  or layout.w or parent.width,
			height = layout.height or layout.h or parent.height,
			children = {},
			__p = {
				0, 0, 0, 0, 0, 0, 0, 0
			},
			line = layout.line,
			__hover = false,
			hoverData = layout.hoverData or {},
			default = {},
			onMouseMove = layout.onMouseMove or nil,
			name = layout.name or "layout"
		}, { __index = getmetatable(ILayout).__index })
		for k, v in pairs(l) do if not rawget(layout, k) then layout[k] = v end end
	end
	if layout.line then
		layout.__p[1], layout.__p[2] = layout.x - layout.width / 2, layout.y - layout.height / 2
		layout.__p[3], layout.__p[4] = layout.x + layout.width / 2, layout.y - layout.height / 2
		layout.__p[5], layout.__p[6] = layout.x + layout.width / 2, layout.y + layout.height / 2
		layout.__p[7], layout.__p[8] = layout.x - layout.width / 2, layout.y + layout.height / 2
	end
	if layout.line then
		if type(layout.line) ~= "table" then layout.line = {} end
		if not layout.line.color then
			layout.line.color = {1, 1, 1}
		end
		if not layout.line.width then
			layout.line.width = 1
		end
	end
	if layout.recreate_children ~= false then
		for i, v in ipairs(children) do
			layout.children[i] = v:recreate(layout)
		end
		layout.recreate_children = false
	end
	for k, v in pairs(layout.hoverData) do
		layout.default[k] = layout[k]
	end
	return layout
end

return {ILayout, Layout}