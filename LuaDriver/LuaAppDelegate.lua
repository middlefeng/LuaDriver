


LDAppDelegate = {}




function LDAppDelegate:applicationDidFinishLaunching()
	local window = self:getMainWindow()

	window:setTitle("Lua OpenGL Driver")
	window:makeKeyAndOrderFront(self)

	local screen = NSScreen.getMainScreen()
	local screenFrame = screen:getFrame()
end




function LDAppDelegate:applicationShouldHandleReopen(theApp, flag)
	local window = self:getMainWindow()
	window:makeKeyAndOrderFront(self)
	return true
end
