


LDAppDelegate = {}




function LDAppDelegate:applicationDidFinishLaunching()
	local window = self:getMainWindow()

	window:setTitle("Lua OpenGL Driver")
	window:makeKeyAndOrderFront(self)

	local screen = NSScreen.getMainScreen()
	local screenFrame = screen:getFrame()
end



