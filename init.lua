require"AUI/functional"

love.AUI = {
	font = love.graphics.getFont(),
	Settings = require"AUI/Settings",
	IUIObject = require"AUI/UIObject",
	selected = nil,
	mouse_pressed = false,
	date = require"AUI/date",
	logger = require"AUI/logger",
	MAS = require"AUI/MAS",
	utf8 = require"utf8"
}

function love.AUI.utf8.sub(s, i, j)
    i = love.AUI.utf8.offset(s, i)
    j = love.AUI.utf8.offset(s, j + 1) - 1
    return string.sub(s, i, j)
end


function love.AUI.setFont(name, size)
	love.AUI.font = love.graphics.newFont(name, size)
end


function math.round(num)
	return num + (2^52 + 2^51) - (2^52 + 2^51)
end


function table.join(t1, t2)
	t = {}
	for _, v in ipairs(t1) do t[#t + 1] = v end
	for _, v in ipairs(t2) do t[#t + 1] = v end
	return t
end

function table.append(t1, t2)
	for _, v in ipairs(t2) do t1[#t1 + 1] = v end
	return t1
end


love.AUI.ILayout, love.AUI.Layout = unpack(require"AUI/Layout")
love.AUI.ITabLayout, love.AUI.TabLayout = unpack(require"AUI/TabLayout")
love.AUI.IButton, love.AUI.Button = unpack(require"AUI/Button")
love.AUI.ITextLabel, love.AUI.TextLabel = unpack(require"AUI/TextLabel")
love.AUI.ITextInput, love.AUI.TextInput = unpack(require"AUI/TextInput")
love.AUI.IImageView, love.AUI.ImageView = unpack(require"AUI/ImageView")
love.AUI.IParticleSystem, love.AUI.ParticleSystem = unpack(require"AUI/ParticleSystem")
love.AUI.ISelectView, love.AUI.SelectView = unpack(require"AUI/SelectView")
love.AUI.IListFile, love.AUI.ListFile = unpack(require"AUI/ListFile")
love.AUI.IListFile, love.AUI.TextEditor = unpack(require"AUI/TextEditor")



love.AUI.defaultTheme, love.AUI.Theme = unpack(require"AUI/Theme")
love.AUI.theme = love.AUI.defaultTheme

love.AUI.settings = love.AUI.Settings()

love.AUI.logger:log("success", "AlmiriUI loaded")

return love.AUI 
