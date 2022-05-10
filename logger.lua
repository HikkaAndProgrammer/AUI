-- here are placed ansi escapes to colorize/customize terminal
local ESC = "\27[%sm"
local log = "%s | %s[%s]%s: %s\n"

-- logger contains some ansi escapes
local Logger = setmetatable({
   -- some useful escapes: they are not used, but maybe...
   reset = ESC:format"0",
   bold = ESC:format"1",
   italic = ESC:format"3",
   underline = ESC:format"4",
   strike = ESC:format"9",
   -- logging levels
   success = ESC:format"32", -- some operation ended successfully
   send = ESC:format"38;5;98", -- some data was sent
   info = ESC:format"38;2;102;153;204", -- used to display some information
   debug = ESC:format"34", -- used to make debugging process easier
   warn = ESC:format"33;5;4", -- warn when something can go wrong
   error = ESC:format"31", -- use this when an error occures in some function (error is localized and bot continue working)
   critical = ESC:format"31;5;1;4" -- use this when an error occures and bot is dead
}, {
   __tostring = function(self) return "<Logger>" end
})

function Logger:log(level, message)
   io.write(log:format(os.date"%c", Logger[level:lower()], level:upper(), Logger.reset, message))
end

return Logger