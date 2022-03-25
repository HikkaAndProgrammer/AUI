local ITextInput = setmetatable({}, { __index = love.AUI.IUIObject })

function ITextInput:draw()
	love.graphics.setScissor(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
	love.graphics.setColor(self.color)
	love.graphics.draw(unpack(self.__text_layer))
	if self.line then
		love.graphics.setLineWidth(self.line.width)
		love.graphics.setColor(self.line.color)
		love.graphics.polygon("line", unpack(self.__p))
	end
	love.graphics.setScissor()
end

function ITextInput:checkHover(x, y)
	self:hover()
	return true
end

function ITextInput:unhover()
	if not self.__hover then return end
	self.__hover = false
	for k, v in pairs(self.default) do
		self[k] = v
	end
end

function ITextInput:hover()
	if self.__hover then return end
	self.__hover = true
	for k, v in pairs(self.hoverData) do
		self[k] = v
	end
	love.AUI.selected = self
end

function ITextInput:recreate(parent)
	self.parent = parent or self.parent
	return love.AUI.TextInput(self)
end

function ITextInput:recreateText()
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

function ITextInput:click(x, y, button)
	if button == 2 then
		self.text = ""
		self:recreateText()
	end
end

function ITextInput:onKeyEvent(key)
	if #key == 1 then
		self.text = self.text .. key
		self:recreateText()
	elseif key == "space" then
		self.text = self.text .. " "
		self:recreateText()
	elseif key == "backspace" then
		self.text = self.text:sub(1, #self.text - 1)
		self:recreateText()
	else
		print(key)
	end
end

local function TextInput(textinput)
	local parent = textinput.parent or love.AUI.ILayout.DefaultValue
	if getmetatable(textinput) == nil or getmetatable(textinput).__index ~= ITextInput then
		local ti = textinput
		textinput = setmetatable({
			parent = textinput.parent,
			x = (textinput.x or parent.width),
			y = (textinput.y or parent.width),
			width  = textinput.width or  textinput.w or math.floor(parent.width / 2),
			height = textinput.height or textinput.h or math.floor(parent.height / 2),
			text = textinput.text,
			text_position = textinput.text_position,
			color = textinput.color or {1, 1, 1},
			line = textinput.line,
			__p = {
				0, 0, 0, 0, 0, 0, 0, 0
			},
			__text_layer = { love.graphics.newText(textinput.font or love.AUI.font, textinput.text), 0, 0 },
			__hover = false,
			onMouseMove = textinput.onMouseMove or nil,
			hoverData = textinput.hoverData or {},
			default = {}
		}, { __index = ITextInput })
		for k, v in pairs(ti) do if not rawget(textinput, k) then textinput[k] = v end end
	end
	if textinput.text_position then
		if textinput.text_position == "center" then
			textinput.__text_layer[2] = textinput.x - textinput.__text_layer[1]:getWidth() / 2
		elseif textinput.text_position == "left" then
			textinput.__text_layer[2] = textinput.x - math.floor(textinput.width / 2)
		elseif textinput.text_position == "right" then
			textinput.__text_layer[2] = textinput.x + math.floor(textinput.width / 2) - textinput.__text_layer[1]:getWidth()
		end
	else
		textinput.__text_layer[2] = textinput.x - textinput.__text_layer[1]:getWidth() / 2
	end
	textinput.__text_layer[3] = textinput.y - textinput.__text_layer[1]:getHeight() / 2
	if textinput.height == 0 then
		textinput.height = textinput.__text_layer[1]:getHeight()
	end
	if textinput.width == 0 then
		textinput.width = textinput.__text_layer[1]:getWidth()
	end
	if textinput.x == 0 then
		textinput.x = math.floor(textinput.width / 2)
	end
	if textinput.y == 0 then
		textinput.y = math.floor(textinput.height / 2)
	end
	for k, v in pairs(textinput.hoverData) do
		textinput.default[k] = textinput[k]
	end
	if textinput.line then
		textinput.__p[1], textinput.__p[2] = textinput.x - textinput.width / 2, textinput.y - textinput.height / 2
		textinput.__p[3], textinput.__p[4] = textinput.x + textinput.width / 2, textinput.y - textinput.height / 2
		textinput.__p[5], textinput.__p[6] = textinput.x + textinput.width / 2, textinput.y + textinput.height / 2
		textinput.__p[7], textinput.__p[8] = textinput.x - textinput.width / 2, textinput.y + textinput.height / 2
	end
	return textinput
end

return {ITextInput, TextInput}