


local ShaderManager = {}



ShaderManager.shaders = {}




------------------------------------------------------------
--		name:			unique name for shader
--		srcFilePaths:	table with "vert" and "frag" prop
------------------------------------------------------------
function ShaderManager.loadShader(name, srcs)
	local vertShader = NSOpenGL.createShader("GL_VERTEX_SHADER")
	local fragShader = NSOpenGL.createShader("GL_FRAGMENT_SHADER")

	NSOpenGL.shaderSource(vertShader, srcs.vert)
	NSOpenGL.compileShader(vertShader)

	NSOpenGL.shaderSource(fragShader, srcs.frag)
	NSOpenGL.compileShader(fragShader)
	
	local program = NSOpenGL.createProgram()
	NSOpenGL.attachShader(program, vertShader)
	NSOpenGL.attachShader(program, fragShader)
	NSOpenGL.linkProgram(program)
	
	NSOpenGL.deleteShader(vertShader)
	NSOpenGL.deleteShader(fragShader)

	ShaderManager.shaders[name] = program
end




function ShaderManager.useProgram(name)
	NSOpenGL.useProgram(ShaderManager.shaders[name])
	ShaderManager.currentProgramName = name
end




function ShaderManager.setUniformMatrix(programName, uniName, matrix, transpose)
	transpose = transpose or false
	local program = ShaderManager.shaders[programName]
	local location = NSOpenGL.getUniformLocation(program, uniName)
	NSOpenGL.uniformMatrix(location, transpose, matrix)
end




function ShaderManager.setUniform(programName, uniName, ...)
	local program = ShaderManager.shaders[programName]
	local location = NSOpenGL.getUniformLocation(program, uniName)
	NSOpenGL.uniform(location, ...)
end




function ShaderManager.setTexture(programName, samplerName, textureUnit)
	local program = ShaderManager.shaders[programName]
	local location = NSOpenGL.getUniformLocation(program, samplerName)
	NSOpenGL.uniform1i(location, textureUnit)
end




function ShaderManager.getAttribLocation(programName, attribName)
	local program = ShaderManager.shaders[programName]
	return NSOpenGL.getAttribLocation(program, attribName)
end





function ShaderManager.uninstallAllPrograms()
	for _, program in pairs(ShaderManager.shaders) do
		NSOpenGL.deleteProgram(program)
	end
end





return ShaderManager

