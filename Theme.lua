local ITheme = {
	fgcolors = {},
	bgcolors = {},
	colors = {}
}

function love.AUI.setTheme(t)
	if getmetatable(t).__index == ITheme then
		love.AUI.theme = t
	else
		error"love.AUI.setTheme arg #1 must be theme"
	end
end

function ITheme:getColor(cn)
	return self.colors[cn] or self.colors.default or {1, 1, 1}
end

function ITheme:getFGColor(cn)
	return self.fgcolors[cn] or self.fgcolors.default or self.colors[cn] or self.colors.default or {1, 1, 1}
end

function ITheme:getBGColor(cn)
	return self.bgcolors[cn] or self.bgcolors.default or self.colors[cn] or self.colors.default or {1, 1, 1}
end

return {
	setmetatable({
		fgcolors = {},
		bgcolors = {},
		colors = {}
	}, { __index = ITheme }), 
	function(filename)
		local data = love.filesystem.read(filename)
		if not data then
			love.AUI.logger:log("error", ("Theme file \"%s\" not found!"):format(filename))
			return love.AUI.defaultTheme
		end
		theme = love.AUI.date.decode(data)
		for _, v in ipairs{"fgcolors", "bgcolors", "colors"} do theme[v] = theme[v] or {} end
		return setmetatable(theme, { __index = ITheme })
	end
}