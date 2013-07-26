




local delegate = ...
local window = delegate:getMainWindow()

window:setTitle("Lua OpenGL Driver")
window:makeKeyAndOrderFront(delegate)

local screen = NSScreen.getMainScreen()
local screenFrame = screen:getFrame()




