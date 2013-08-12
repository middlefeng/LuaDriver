


local VertArrayObject = {}

local OpenGLShaderManager = require "LuaOpenGLShaderManager"



-------------------------------------------------------------------------
------------------             Vertex Array            ------------------
-------------------------------------------------------------------------




function VertArrayObject:__gc()
	for _, buffer in pairs(self.buffers) do
		NSOpenGL.deleteBuffers(buffer.handle)
	end
	NSOpenGL.deleteVertexArrays(self.vertObj)
end




function VertArrayObject:new()
	self.__index = VertArrayObject
	local result = {}
	setmetatable(result, self)

	result.vertObj = NSOpenGL.genVertexArrays(1)
	result:bind()
	result.buffers = {}

	return result
end



function VertArrayObject:bind()
	NSOpenGL.bindVertexArray(self.vertObj)
end



function VertArrayObject:unbind()
	NSOpenGL.bindVertexArray(0)
end



function VertArrayObject:genBuffer(name, verts, purpose, normalized)
	purpose = purpose or "GL_DYNAMIC_DRAW"
	normalized = normalized or false

	self.buffers[name] = {}
	self.buffers[name].handle = NSOpenGL.genBuffers(1)
	self.buffers[name].stride = #verts[1]
	NSOpenGL.bindBuffer("GL_ARRAY_BUFFER", self.buffers[name].handle)
	NSOpenGL.bufferData("GL_ARRAY_BUFFER", "GL_FLOAT", verts, purpose)

	self.buffers[name].normalized = normalized
end




function VertArrayObject:bindBufferToAttrib(name, progName, attribName)
	local location = OpenGLShaderManager.getAttribLocation(progName, attribName)
	local buffer = self.buffers[name]

	-- do nothing for non-existent name
	if location < 0 or (not buffer) then
		return
	end

	NSOpenGL.bindBuffer("GL_ARRAY_BUFFER", self.buffers[name].handle)
	NSOpenGL.enableVertexAttribArray(location);
	NSOpenGL.vertexAttribPointer(location, self.buffers[name].stride, "GL_FLOAT",
								 self.buffers[name].normalized)
end




return VertArrayObject


