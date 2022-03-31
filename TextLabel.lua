local ITextLabel = setmetatable({}, { __index = love.AUI.IUIObject })

function ITextLabel:draw()
	love.graphics.setScissor(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
	love.graphics.setColor(self.color)
	love.graphics.draw(unpack(self.__text_layer))
	love.graphics.setScissor()
end

function ITextLabel:checkHover(x, y)
	self:hover()
	return true
end

function ITextLabel:unhover()
	if not self.__hover then return end
	self.__hover = false
	for k, v in pairs(self.default) do
		self[k] = v
	end
end

function ITextLabel:hover()
	if self.__hover then return end
	self.__hover = true
	for k, v in pairs(self.hoverData) do
		self[k] = v
	end
end

function ITextLabel:recreate(parent)
	self.parent = parent or self.parent
	return love.AUI.TextLabel(self)
end

function ITextLabel:recreateText()
	self.__text_layer[1] = love.graphics.newText(self.font or love.AUI.font, self.text)
	if self.text_position then
		if self.text_position == "center" then
			self.__text_layer[2] = self.x - self.__text_layer[1]:getWidth() / 2
		elseif self.text_position == "left" then
			self.__text_layer[2] = self.x - math.floor(self.width / 2)
		elseif self.text_position == "right" then
			self.__text_layer[2] = self.x + math.floor(self.width / 2) - self.__text_layer[1]:getWidth()
		end
	else
		self.__text_layer[2] = self.x - self.__text_layer[1]:getWidth() / 2
	end
	self.__text_layer[3] = self.y - self.__text_layer[1]:getHeight() / 2
	if self.height == 0 then
		self.height = self.__text_layer[1]:getHeight()
	end
	if self.width == 0 then
		self.width = self.__text_layer[1]:getWidth()
	end
end

local function TextLabel(textlabel)
	local parent = textlabel.parent or love.AUI.ILayout.DefaultValue
	local font = textlabel.font or love.AUI.font
	if getmetatable(textlabel) == nil or getmetatable(textlabel).__index ~= ITextLabel then
		local tl = textlabel
		textlabel = setmetatable({
			id = textlabel.id,
			parent = textlabel.parent,
			x = (textlabel.x or parent.width),
			y = (textlabel.y or parent.width),
			width  = textlabel.width or  textlabel.w or math.floor(parent.width / 2),
			height = textlabel.height or textlabel.h or math.floor(parent.height / 2),
			text = textlabel.text,
			font = font,
			text_position = textlabel.text_position,
			color = textlabel.color or {1, 1, 1},
			__text_layer = { nil, 0, 0 },
			__hover = false,
			onMouseMove = textlabel.onMouseMove or nil,
			hoverData = textlabel.hoverData or {},
			default = {}
		}, { __index = ITextLabel })
		for k, v in pairs(tl) do if not rawget(textlabel, k) then textlabel[k] = v end end
	end
	local text_str = textlabel.text
	local width, wrappedtext = font:getWrap(text_str, textlabel.width)
	wrappedtext = (width == 0) and (text_str) or (table.concat(wrappedtext, "\n"))
	textlabel.__text_layer[1] = love.graphics.newText(font, wrappedtext)
	if textlabel.text_position then
		if textlabel.text_position == "center" then
			textlabel.__text_layer[2] = textlabel.x - textlabel.__text_layer[1]:getWidth() / 2
		elseif textlabel.text_position == "left" then
			textlabel.__text_layer[2] = textlabel.x - math.floor(textlabel.width / 2) + math.sin(textlabel.angle) * button.height
		elseif textlabel.text_position == "right" then
			textlabel.__text_layer[2] = textlabel.x + math.floor(textlabel.width / 2) - textlabel.__text_layer[1]:getWidth() - math.sin(button.angle) * button.height
		end
	else
		textlabel.__text_layer[2] = textlabel.x - textlabel.__text_layer[1]:getWidth() / 2
	end
	textlabel.__text_layer[3] = textlabel.y - textlabel.__text_layer[1]:getHeight() / 2
	if textlabel.height == 0 then
		textlabel.height = textlabel.__text_layer[1]:getHeight()
	end
	if textlabel.width == 0 then
		textlabel.width = textlabel.__text_layer[1]:getWidth()
	end
	if textlabel.x == 0 then
		textlabel.x = math.floor(textlabel.width / 2)
	end
	if textlabel.y == 0 then
		textlabel.y = math.floor(textlabel.height / 2)
	end
	for k, v in pairs(textlabel.hoverData) do
		textlabel.default[k] = textlabel[k]
	end
	return textlabel
end

return {ITextLabel, TextLabel}