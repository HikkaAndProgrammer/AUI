local ITextEditor = setmetatable({}, { __index = love.AUI.IUIObject })

function ITextEditor:draw()
	love.graphics.setScissor(self.x - self.width / 2 + math.sin(self.angle) * self.height, self.y - self.height / 2, self.width - 2 * math.sin(self.angle) * self.height, self.height)
	love.graphics.setColor(self.color)
	for i = 0, self.displayN do
		love.graphics.draw(unpack(self.__text[i]))
	end
	if self.line then
		love.graphics.setLineWidth(self.line.width)
		love.graphics.setColor(self.line.color)
		love.graphics.polygon("line", unpack(self.__p))
	end
	love.graphics.setScissor(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
	love.graphics.setScissor()
end

function ITextEditor:checkHover(x, y)
	self:hover()
	return true
end

function ITextEditor:unhover()
	if not self.__hover then return end
	self.__hover = false
	for k, v in pairs(self.default) do
		self[k] = v
	end
end

function ITextEditor:hover()
	if self.__hover then return end
	self.__hover = true
	for k, v in pairs(self.hoverData) do
		self[k] = v
	end
	love.AUI.selected = self
end

function ITextEditor:update()
	local t = ""
	if self.offsetY >= self.line_height then 
		t = self.text[math.floor(self.offsetY / self.line_height)]
	end
	self.__text[0] = {love.graphics.newText(self.font, t), 
		self.x - self.width / 2, self.y - self.height / 2 - self.offsetY % self.line_height
	}
	for i = 1, self.displayN do
		local t = self.text[i + math.floor(self.offsetY / self.line_height)] or ""
		self.__text[i] = {love.graphics.newText(self.font, t), 
			self.x - self.width / 2, self.y - self.height / 2 + i * self.line_height - self.offsetY % self.line_height
		}
	end
end

function ITextEditor:onMouseMove(x, y, dx, dy)
	if love.mouse.isDown(1) then
		if self.line_height * #self.text > self.height then
			self.offsetY = self.offsetY - dy
			if self.offsetY < self.line_height then self.offsetY = self.line_height end
			if self.offsetY > self.line_height * (#self.text - self.displayN + 2) then 
				self.offsetY = self.line_height * (#self.text - self.displayN + 2)
			end 
		end
		self:update()
	end
end

function ITextEditor:recreate(parent)
	self.parent = parent or self.parent
	return love.AUI.TextEditor(self)
end

function ITextEditor:click(x, y, button)
	love.keyboard.setTextInput(true)
end

function ITextEditor:hot_key(key)
	if love.keyboard.isScancodeDown"s" then
		love.filesystem.write(self.file, table.concat( self.text, "\n"))
	end
end

function ITextEditor:onKeyEvent(key)
	if love.AUI.utf8.len(key) == 1 then
		if #self.text == 0 then table.insert(self.text, #self.text + 1, "") end
		self.text[#self.text] = self.text[#self.text] .. key
		self:update()
	elseif key == "return" then
		table.insert(self.text, #self.text + 1, "")
	elseif key == "backspace" then
		if #self.text > 0 then
			if self.text[#self.text] == "" then
				table.remove(self.text, #self.text)
			else
				local text = self.text[#self.text]
				self.text[#self.text] = love.AUI.utf8.sub(text, 1, love.AUI.utf8.len(text) - 1)
				self:update()
			end
		end
	end
end

local function TextEditor(texteditor)
	local parent = texteditor.parent or love.AUI.ILayout.DefaultValue
	local font = texteditor.font or love.AUI.font
	if getmetatable(texteditor) == nil or getmetatable(texteditor).__index ~= ITextEditor then
		local ti = texteditor
		texteditor = setmetatable({
			id = texteditor.id,
			parent = texteditor.parent,
			x = (texteditor.x or parent.width),
			y = (texteditor.y or parent.width),
			width  = texteditor.width or  texteditor.w or math.floor(parent.width / 2),
			height = texteditor.height or texteditor.h or math.floor(parent.height / 2),
			angle = texteditor.angle or 0,
			file = texteditor.file or "",
			line = texteditor.line,
			text = (love.filesystem.read(texteditor.file)):split("\n") or "",
			font = texteditor.font or love.AUI.font,
			line_height = love.graphics.newText(font, "^|lLI"):getHeight(),
			offsetY = 0,
			text_position = texteditor.text_position,
			__text = {}, 
			color = texteditor.color or {1, 1, 1},
			__p = {
				0, 0, 0, 0, 0, 0, 0, 0
			},
			__hover = false,
			onMouseMove = texteditor.onMouseMove or nil,
			hoverData = texteditor.hoverData or {},
			default = {},
			displayN = 0
		}, { __index = ITextEditor })
		for k, v in pairs(ti) do if not rawget(texteditor, k) then texteditor[k] = v end end
	end

	if texteditor.line then	
		texteditor.__p[1], texteditor.__p[2] = texteditor.x - texteditor.width / 2, texteditor.y - texteditor.height / 2
		texteditor.__p[3], texteditor.__p[4] = texteditor.x + texteditor.width / 2, texteditor.y - texteditor.height / 2
		texteditor.__p[5], texteditor.__p[6] = texteditor.x + texteditor.width / 2, texteditor.y + texteditor.height / 2
		texteditor.__p[7], texteditor.__p[8] = texteditor.x - texteditor.width / 2, texteditor.y + texteditor.height / 2
	end

	if texteditor.line then
		if type(texteditor.line) ~= "table" then texteditor.line = {} end
		if not texteditor.line.color then
			texteditor.line.color = {1, 1, 1}
		end
		if not texteditor.line.width then
			texteditor.line.width = 1
		end
	end

	if texteditor.height == 0 then
		texteditor.height = parent.height
	end
	if texteditor.width == 0 then
		texteditor.width = parent.width
	end
	if texteditor.x == 0 then
		texteditor.x = math.floor(texteditor.width / 2)
	end
	if texteditor.y == 0 then
		texteditor.y = math.floor(texteditor.height / 2)
	end


	for k, v in pairs(texteditor.hoverData) do
		texteditor.default[k] = texteditor[k]
	end

	texteditor.displayN = math.ceil(texteditor.height / texteditor.line_height)
	texteditor.offsetY = texteditor.line_height

	texteditor:update()

	return texteditor
end

return {ITextEditor, TextEditor}