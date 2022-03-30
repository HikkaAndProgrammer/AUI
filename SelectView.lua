local ISelectView = setmetatable({}, { __index = love.AUI.IUIObject })

function ISelectView:draw()
	love.graphics.setScissor(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
	love.graphics.setColor(self.color)
	love.graphics.draw(unpack(self.__text_layer))
	love.graphics.setScissor()
	love.graphics.polygon("line", self.__p[1])
	love.graphics.polygon("line", self.__p[2])
end

function ISelectView:checkHover(x, y)
	self:hover()
	return true
end

function ISelectView:unhover()
	if not self.__hover then return end
	self.__hover = false
	for k, v in pairs(self.default) do
		self[k] = v
	end
end

function ISelectView:hover()
	if self.__hover then return end
	self.__hover = true
	for k, v in pairs(self.hoverData) do
		self[k] = v
	end
end

function ISelectView:onSelect() end

function ISelectView:click(x, y, button)
	if self:checkHover(x, y) then
		if x < self.precounted[1] then
			self.position = (self.position - 1 > 0) and (self.position - 1) or (#self.variants)
			self:update_text()
			self:onSelect()
		elseif x > self.precounted[2] then
			self.position = (self.position + 1 > #self.variants) and (1) or (self.position + 1)
			self:update_text()
			self:onSelect()
		end
	end
end

function ISelectView:recreate(parent)
	self.parent = parent
	return love.AUI.SelectView(self)
end

function ISelectView:update_text()
	local font = self.font or love.AUI.font
	self.text = self.variants[self.position]
	local text_str = self.text
	local width, wrappedtext = font:getWrap(text_str, self.width)
	wrappedtext = (width == 0) and (text_str) or (table.concat(wrappedtext, "\n"))
	self.__text_layer[1] = love.graphics.newText(font, wrappedtext)
	self.__text_layer[2] = self.x - self.__text_layer[1]:getWidth() / 2
	self.__text_layer[3] = self.y - self.__text_layer[1]:getHeight() / 2
end

local function SelectView(selectview)
	local parent = selectview.parent or love.AUI.ILayout.DefaultValue
	local font = selectview.font or love.AUI.font
	if getmetatable(selectview) == nil or getmetatable(selectview).__index ~= ISelectView then
		local sv = selectview
		selectview = setmetatable({
			id = selectview.id,
			parent = selectview.parent,
			x = (selectview.x or parent.width),
			y = (selectview.y or parent.width),
			width  = selectview.width or  selectview.w or math.floor(parent.width / 2),
			height = selectview.height or selectview.h or math.floor(parent.height / 2),
			font = font,
			variants = selectview.variants or { "default" },
			position = selectview.position or selectview.pos or 1,
			color = selectview.color or {1, 1, 1},
			lines = selectview.lines,
			__text_layer = { nil, 0, 0 },
			__hover = false,	
			__p = {{}, {}, {}, {}},
			onMouseMove = selectview.onMouseMove or nil,
			hoverData = selectview.hoverData or {},
			default = {}
		}, { __index = ISelectView })
		for k, v in pairs(sv) do if not rawget(selectview, k) then selectview[k] = v end end
	end
	if type(selectview.position) ~= "number" then
		for k, v in pairs(selectview.variants) do
			if v == selectview.position then
				selectview.position = k
				break
			end
		end
	end
	if type(selectview.position) ~= "number" then
		selectview.position = 1
	end
	ISelectView.update_text(selectview)
	if selectview.height == 0 then
		selectview.height = selectview.__text_layer[1]:getHeight()
	end
	if selectview.width == 0 then
		selectview.width = selectview.__text_layer[1]:getWidth() + selectview.height * 2 + 2
	end
	if selectview.x == 0 then
		selectview.x = math.floor(selectview.width / 2)
	end
	if selectview.y == 0 then
		selectview.y = math.floor(selectview.height / 2)
	end
	-- left triangle
	selectview.__p[1][1] = selectview.x - math.round(selectview.width / 2)
	selectview.__p[1][2] = selectview.y
	selectview.__p[1][3] = selectview.x + selectview.height - math.round(selectview.width / 2)
	selectview.__p[1][4] = selectview.y - math.round(selectview.height / 2)
	selectview.__p[1][5] = selectview.x + selectview.height - math.round(selectview.width / 2)
	selectview.__p[1][6] = selectview.y + math.round(selectview.height / 2)
	-- right triangle
	selectview.__p[2][1] = selectview.x  - selectview.height + math.round(selectview.width / 2)
	selectview.__p[2][2] = selectview.y - math.round(selectview.height / 2)
	selectview.__p[2][3] = selectview.x - selectview.height + math.round(selectview.width / 2)
	selectview.__p[2][4] = selectview.y + math.round(selectview.height / 2)
	selectview.__p[2][5] = selectview.x + math.round(selectview.width / 2)
	selectview.__p[2][6] = selectview.y
	for k, v in pairs(selectview.hoverData) do
		selectview.default[k] = selectview[k]
	end
	selectview.precounted = {
		selectview.x - selectview.width / 2 + selectview.height,
		selectview.x + selectview.width / 2 - selectview.height
	}
	return selectview
end

return {ISelectView, SelectView}