


LDAppDelegate = {}




function LDAppDelegate:applicationDidFinishLaunching()
	local window = self:getMainWindow()

	window:setTitle("Lua OpenGL Driver")
	window:makeKeyAndOrderFront(self)

	local screen = NSScreen.getMainScreen()
	local screenFrame = screen:getFrame()

	local openPanel = NSOpenPanel.getOpenPanel()
	local completeFunc = function(state)
		local url = openPanel:getURLs()
		local image = NSImage.newWithContentsOfFile(url:getPath())
		local view = window:getOpenGLView()
		view:initializeObject(image:getSize())
		view:initializeTexture(image)
		view:setNeedsDisplay(true)
	end
	
	openPanel:setAllowsMultipleSelection(false)
	openPanel:beginSheetModalForWindow(window, completeFunc)
end




function LDAppDelegate:applicationWillTerminate()
	local view = self:getMainWindow():getOpenGLView()
	view:dealloc()
end




function LDAppDelegate:applicationShouldHandleReopen(theApp, flag)
	local window = self:getMainWindow()
	window:makeKeyAndOrderFront(self)
	return true
end


