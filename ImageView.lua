local IImageView = setmetatable({}, { __index = love.AUI.IUIObject })

function IImageView:draw()
	love.graphics.setColor(self.color)
	love.graphics.draw(self.__image_layer, self.__p[1], self.__p[2])
end

function IImageView:setImage(path)
	self.image = path
	local xw, xh = self.__image_layer:getWidth(), self.__image_layer:getHeight()
	self.__image_layer = love.graphics.newImage(self.image)
	if not imageview.width then
		imageview.width = imageview.__image_layer:getWidth()
	end
	if not imageview.height then
		imageview.height = imageview.__image_layer:getHeight()
	end
	imageview.__p[1] = math.round(imageview.x - imageview.width / 2)
	imageview.__p[2] = math.round(imageview.y - imageview.height / 2)
end

function IImageView:checkHover(x, y)
	self:hover()
	return self.__hover
end

function IImageView:recreate(parent)
	self.parent = parent or self.parent
	return love.AUI.ImageView(self)
end

local function ImageView(imageview)
	local parent = imageview.parent or love.AUI.ILayout.DefaultValue
	if getmetatable(imageview) == nil or getmetatable(imageview).__index ~= IImageView then
		local iv = imageview
		imageview = setmetatable({
			id = imageview.id,
			x = imageview.x,
			y = imageview.y,
			color = imageview.color or {1, 1, 1, 1},
			width  = (imageview.width or  imageview.w),
			height = (imageview.height or imageview.h),
			image = imageview.image,
			__image_layer = imageview.__image_layer or love.graphics.newImage(imageview.image),
			__hover = false,
			__p = {0, 0}
		}, { __index = IImageView })
		for k, v in pairs(iv) do if not rawget(imageview, k) then imageview[k] = v end end
	end
	if not imageview.width then
		imageview.width = imageview.__image_layer:getWidth()
	end
	if not imageview.height then
		imageview.height = imageview.__image_layer:getHeight()
	end
	imageview.__p[1] = math.round(imageview.x - imageview.width / 2)
	imageview.__p[2] = math.round(imageview.y - imageview.height / 2)
	return imageview
end

return {IImageView, ImageView}