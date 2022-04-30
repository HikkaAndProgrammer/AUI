local IListFile = setmetatable({}, { __index = love.AUI.IUIObject })

function IListFile:draw()
	love.graphics.setScissor(self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
	love.graphics.setColor(self.color)
	if self.hover_line then
		for i = 0, self.displayN do
			if i == self.hover_line then
				love.graphics.setColor(self.hoverData.color or self.color)
			elseif i - 1 == self.hover_line then
				love.graphics.setColor(self.color)
			end
			love.graphics.draw(unpack(self.__text[i]))
		end
	else
		for i = 0, self.displayN do
			love.graphics.draw(unpack(self.__text[i]))
		end
	end
	if self.line then
		love.graphics.setLineWidth(self.line.width)
		love.graphics.setColor(self.line.color)
		love.graphics.polygon("line", unpack(self.__p))
	end
	love.graphics.setScissor()
end

function IListFile:update()
	local text = ""
	if self.offsetY >= self.line_height then 
		text = self.list[math.floor(self.offsetY / self.line_height)]
	end
	self.__text[0] = {love.graphics.newText(self.font, text), 
		self.x - self.width / 2, self.y - self.height / 2 - self.offsetY % self.line_height
	}
	for i = 1, self.displayN do
		self.__text[i] = {love.graphics.newText(self.font, self.list[i + math.floor(self.offsetY / self.line_height)]), 
			self.x - self.width / 2, self.y - self.height / 2 + i * self.line_height - self.offsetY % self.line_height
		}
	end
end

function IListFile:onMouseMove(x, y, dx, dy)
	if love.mouse.isDown(1) then
		self.offsetY = self.offsetY - dy
		if self.offsetY < self.line_height then self.offsetY = self.line_height end
		if self.offsetY > self.line_height * (#self.list - self.displayN + 2) then self.offsetY = self.line_height * (#self.list - self.displayN + 2) end
		self:update()
	end
end

function IListFile:checkHover(x, y)
	self.hover_line = math.floor((y + (self.offsetY % self.line_height) + self.height / 2 - self.y) / self.line_height)
	self:hover()
	return true
end

function IListFile:press(x, y, button)
	if button == 1 then
		self.__click[1] = x
		self.__click[2] = y
	end
end	

function IListFile:click(x, y, button)
	if button == 1 then
		if (self.__click[1] == x) and (self.__click[2] == y) then
			print("booba")
		end
	end
end

function IListFile:unhover()
	if not self.__hover then return end
	self.__hover = false
	self.hover_line = nil
end

function IListFile:hover()
	if self.__hover then return end
	self.__hover = true
end


local function ListFile(listfile)
	local parent = listfile.parent or love.AUI.ILayout.DefaultValue
	local font = listfile.font or love.AUI.font
	if getmetatable(listfile) == nil or getmetatable(listfile).__index ~= IListFile then
		local tl = listfile
		listfile = setmetatable({
			id = listfile.id,
			parent = listfile.parent,
			x = (listfile.x or parent.width),
			y = (listfile.y or parent.width),
			line = listfile.line,
			__p = {
				0, 0, 0, 0, 0, 0, 0, 0
			},
			width  = listfile.width or  listfile.w or math.floor(parent.width / 2),
			height = listfile.height or listfile.h or math.floor(parent.height / 2),
			font = font,
			line_height = love.graphics.newText(font, "^|lLI"):getHeight(),
			color = listfile.color or {1, 1, 1},
			list = listfile.list or {},
			__click = {0, 0},
			__text = {}, 
			__hover = false,
			onMouseMove = listfile.onMouseMove or nil,
			hoverData = listfile.hoverData or {},
			default = {},
			offsetY = 0,
			displayN = 0
		}, { __index = IListFile })
		for k, v in pairs(tl) do if not rawget(listfile, k) then listfile[k] = v end end
	end

	if listfile.line then
		listfile.__p[1], listfile.__p[2] = listfile.x - listfile.width / 2, listfile.y - listfile.height / 2
		listfile.__p[3], listfile.__p[4] = listfile.x + listfile.width / 2, listfile.y - listfile.height / 2
		listfile.__p[5], listfile.__p[6] = listfile.x + listfile.width / 2, listfile.y + listfile.height / 2
		listfile.__p[7], listfile.__p[8] = listfile.x - listfile.width / 2, listfile.y + listfile.height / 2
	end

	if listfile.line then
		if type(listfile.line) ~= "table" then listfile.line = {} end
		if not listfile.line.color then
			listfile.line.color = {1, 1, 1}
		end
		if not listfile.line.width then
			listfile.line.width = 1
		end
	end

	if listfile.height == 0 then
		listfile.height = parent.height
	end
	if listfile.width == 0 then
		listfile.width = parent.width
	end
	if listfile.x == 0 then
		listfile.x = math.floor(listfile.width / 2)
	end
	if listfile.y == 0 then
		listfile.y = math.floor(listfile.height / 2)
	end

	listfile:update()

	for k, v in pairs(listfile.hoverData) do
		listfile.default[k] = listfile[k]
	end

	listfile.displayN = math.ceil(listfile.height / listfile.line_height)
	listfile.offsetY = listfile.line_height

	return listfile
end

function IListFile:recreate(parent)
	self.parent = parent or self.parent
	return ListFile(self)
end

return {IListFile, ListFile} 