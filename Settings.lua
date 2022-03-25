return function()
	if not love.filesystem.getInfo("settings.date") then
	love.AUI.logger:log("info", "settings created")
		love.filesystem.write("settings.date", "theme-default:font-default")
	end 
	love.AUI.logger:log("success", "settings loaded")
	return {
		get = function(self, k)
			return self.data[k]
		end,
		set = function(self, k, v)
			self.data[k] = v
			love.filesystem.write("settings.date", love.AUI.date.encode(self.data))
			return v
		end,
		getTheme = function(self)
			return tostring(self.data.theme)
		end,
		getFont = function(self)
			return tostring(self.data.font)
		end,
		data = love.AUI.date.decode(({love.filesystem.read("settings.date")})[1])
	}
end