local IUIObject = {}

function IUIObject:draw() end
function IUIObject:update() end
function IUIObject:checkHover(x, y) end
function IUIObject:unhover() self.__hover = false end
function IUIObject:hover() self.__hover = true end
function IUIObject:recreate(parent) end
function IUIObject:recreateSelf() end
function IUIObject:click(x, y, button) end
function IUIObject:press(x, y, button) end
function IUIObject:onKeyEvent(key) end
function IUIObject:onMouseMove(x, y, dx, dy) end

return IUIObject 