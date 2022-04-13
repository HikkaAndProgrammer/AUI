local IButton = setmetatable({}, { __index = love.AUI.IUIObject })

function IButton:draw()
	love.graphics.setColor(self.color)
	if self.line then
		love.graphics.setLineWidth(self.lineWidth)
		love.graphics.polygon("line", self.__p)
	end
	love.graphics.draw(unpack(self.__text_layer))
end

function IButton:checkHover(x, y)
	if self.angle >= 0 then
		if self.x > x then
			if (y - self.precounted[1]) > (x - self.precounted[2]) * self.__k then self:hover() end
		elseif self.x <= x then
			if (y - self.precounted[3]) < (x - self.precounted[4]) * self.__k then self:hover() end
		else
			self:unhover()
		end
	else
		if self.x > x then
			if (y + self.precounted[1]) < (x + self.precounted[2]) * self.__k then self:hover() end
		elseif self.x <= x then
			if (y - self.precounted[3]) > (x - self.precounted[4]) * self.__k then self:hover() end
		else
			self:unhover()
		end
	end
	return self.__hover
end

function IButton:unhover()
	if not self.__hover then return end
	self.__hover = false
	for k, v in pairs(self.default) do
		self[k] = v
	end
end

function IButton:hover()
	if self.__hover then return end
	self.__hover = true
	for k, v in pairs(self.hoverData) do
		self[k] = v
	end
end

function IButton:click(x, y, button)
	if self:checkHover(x, y) then
		self:onClick(x, y, button)
	end
end

function IButton:recreate(parent)
	self.parent = parent or self.parent
	return love.AUI.Button(self)
end

function IButton:updatePosition()
	if self.angle == 0 then
		self.__p[1], self.__p[2] = math.round(self.x - self.width / 2), math.round(self.y - self.height / 2)
		self.__p[3], self.__p[4] = math.round(self.x - self.width / 2), math.round(self.y + self.height / 2)
		self.__p[5], self.__p[6] = math.round(self.x + self.width / 2), math.round(self.y + self.height / 2)
		self.__p[7], self.__p[8] = math.round(self.x + self.width / 2), math.round(self.y - self.height / 2)
	elseif self.angle > 0 then
		self.__p[1], self.__p[2] = math.round(self.x - self.width / 2 + math.sin(self.angle) * self.height), math.round(self.y - self.height / 2)
		self.__p[3], self.__p[4] = math.round(self.x - self.width / 2), math.round(self.y + self.height / 2)
		self.__p[5], self.__p[6] = math.round(self.x + self.width / 2 - math.sin(self.angle) * self.height), math.round(self.y + self.height / 2)
		self.__p[7], self.__p[8] = math.round(self.x + self.width / 2), math.round(self.y - self.height / 2)
	else
		self.__p[1], self.__p[2] = math.round(self.x - self.width / 2), math.round(self.y - self.height / 2)
		self.__p[3], self.__p[4] = math.round(self.x - self.width / 2 - math.sin(self.angle) * self.height), math.round(self.y + self.height / 2)
		self.__p[5], self.__p[6] = math.round(self.x + self.width / 2), math.round(self.y + self.height / 2)
		self.__p[7], self.__p[8] = math.round(self.x + self.width / 2 + math.sin(self.angle) * self.height), math.round(self.y - self.height / 2)
	end
	self.__k = (self.__p[6] - self.__p[8]) / (self.__p[5] - self.__p[7])
	self.__text_layer[3] = self.y - self.__text_layer[1]:getHeight() / 2
	if self.text_position then
		if self.text_position == "center" then
			self.__text_layer[2] = self.x - self.__text_layer[1]:getWidth() / 2
		elseif self.text_position == "left" then
			self.__text_layer[2] = self.x - math.floor(self.width / 2) + math.sin(self.angle) * self.height
		elseif self.text_position == "right" then
			self.__text_layer[2] = self.x + math.floor(self.width / 2) - self.__text_layer[1]:getWidth() - math.sin(self.angle) * self.height
		end
	else
		self.__text_layer[2] = self.x - self.__text_layer[1]:getWidth() / 2
	end
end

local function Button(button)
	local parent = button.parent or love.AUI.ILayout.DefaultValue
	local text_position = button.text_position
	if getmetatable(button) == nil or getmetatable(button).__index ~= IButton then
		local b = button
		button = setmetatable({
			id = button.id,
			parent = button.parent,
			x = button.x or math.floor(parent.width / 2),
			y = button.y or math.floor(parent.height / 2),
			width  = button.width or  button.w or math.floor(parent.width / 2),
			height = button.height or button.h or math.floor(parent.height / 2),
			angle = button.angle or 0,
			text = button.text or "",
			line = button.line == nil and true or button.line,
			__p = {
				0, 0,
				0, 0,
				0, 0,
				0, 0
			},
			k = (button.angle or 0) / (3.1415926535 / 2),
			font = button.font or love.AUI.font,
			color = button.color or {1, 1, 1},
			lineWidth = button.lineWidth or 1,
			text_position = text_position,
			__text_layer = { love.graphics.newText(button.font or love.AUI.font, button.text), 0, 0 },
			__hover = false,
			onClick = button.onClick or function(s, x, y, b)end,
			onMouseMove = button.onMouseMove or nil,
			hoverData = button.hoverData or {},
			default = {}
		}, { __index = IButton })
		for k, v in pairs(b) do if not rawget(button, k) then button[k] = v end end
	end
	IButton.updatePosition(button)
	if button.height == 0 then
		button.height = button.__text_layer[1]:getHeight()
	end
	if button.width == 0 then
		button.width = button.__text_layer[1]:getWidth() + 2 * math.sin(button.angle) * button.height
	end
	if button.x == 0 then
		button.x = math.floor(button.width / 2)
	end
	if button.y == 0 then
		button.y = math.floor(button.height / 2)
	end
	button.precounted = {
		math.floor(button.y + button.height / 2), math.floor(button.x - button.width / 2),
		math.floor(button.y - button.height / 2), math.floor(button.x + button.width / 2)
	}
	for k, v in pairs(button.hoverData) do
		button.default[k] = button[k]
	end
	return button
end

return {IButton, Button}