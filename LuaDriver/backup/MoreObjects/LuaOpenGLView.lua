



local bundle = NSBundle:getMainBundle()
local path = bundle:pathForResource("LuaOpenGLFrame", "lua")

path = string.sub(path, 1, string.len(path) - string.len("LuaOpenGLFrame.lua"))
path = path .. "?.lua"
package.path = package.path .. ";" .. path

bundle = nil
path = nil




local OpenGLMath = require "LuaOpenGLMath"
local OpenGLFrame = require "LuaOpenGLFrame"
local OpenGLFrustum = require "LuaOpenGLFrustum"
local OpenGLTransPipeline = require "LuaOpenGLTransformPipeline"

LDOpenGLView = {}

local LDUtilities = {}
local VertArrayObject = {}
local TriangleBatch = {}




-------------------------------------------------------------------------
------------------             LDOpenGLView            ------------------
-------------------------------------------------------------------------


function LDOpenGLView:prepareOpenGL()
	NSOpenGL.clearColor(0.7, 0.7, 0.7, 1.0)
	
	self:initializeShaders()

	NSOpenGL.enable("GL_DEPTH_TEST")

	self.cameraFrame = OpenGLFrame:new()
	self.cameraFrame:moveForward(-15.0)
	self.objectFrame = OpenGLFrame:new()

	--self.cameraFrame:rotateWorld(-38.0 * 3.14 / 180, { x = 0, y = 1, z = 0 });
	--self.objectFrame:rotateWorld(-38.0 * 3.14 / 180, { x = 0, y = 1, z = 0 });
	--self.objectFrame:rotateWorld(30.0 * 3.14 / 180, { x = 0, y = 0, z = 1 });
	--self.cameraFrame:rotateWorld(30.0 * 3.14 / 180, { x = 0, y = 0, z = 1 });

	self:initializeObject()

	local frame = self:getFrame()
	self:setScene(frame)
end



function LDOpenGLView:initializeShaders()
	local vertShader = NSOpenGL.createShader("GL_VERTEX_SHADER")
	local fragShader = NSOpenGL.createShader("GL_FRAGMENT_SHADER")
	local vertSrc = LDUtilities.loadShaderSource("flat.vert")
	local fragSrc = LDUtilities.loadShaderSource("flat.frag")

	NSOpenGL.shaderSource(1, vertSrc)
	NSOpenGL.compileShader(1)

	NSOpenGL.shaderSource(2, fragSrc)
	NSOpenGL.compileShader(2)

	local program = NSOpenGL.createProgram()
	NSOpenGL.attachShader(program, 1)
	NSOpenGL.attachShader(program, 2)
	NSOpenGL.linkProgram(program)
	NSOpenGL.useProgram(program)

	NSOpenGL.deleteShader(vertShader)
	NSOpenGL.deleteShader(fragShader)

	self.program = program
end




function LDOpenGLView:initializeObject()
	self.torus = TriangleBatch:begin()
	self.torus.program = self.program
	self.sphere = TriangleBatch:begin()
	self.sphere.program = self.program
	makeTorus(self.torus, 3.0, 0.75, 15, 15);
	makeSphere(self.sphere, 3, 10, 20)
	self.currentObject = self.torus
end




function LDOpenGLView:drawRect(dirtyRect)
	local frame = self:getFrame()
	local location = NSOpenGL.getAttribLocation(self.program, "vVertex")
	
	NSOpenGL.clear("GL_COLOR_BUFFER_BIT", "GL_DEPTH_BUFFER_BIT", "GL_STENCIL_BUFFER_BIT")

	local cameraMatrix = self.cameraFrame:getCameraMatrix()
	local objectMatrix = self.objectFrame:getMatrix()
	local mvMatrix = OpenGLMath.multiply44(cameraMatrix, objectMatrix)

	local transPipeline = OpenGLTransPipeline:new()
	transPipeline.modelView = mvMatrix
	transPipeline.projection = self.viewFrustum.projMatrix

	local transformLocation = NSOpenGL.getUniformLocation(self.program, "mvpMatrix")
	NSOpenGL.uniformMatrix(transformLocation, "GL_FALSE", transPipeline:getMVP())

	local colorLocation = NSOpenGL.getUniformLocation(self.program, "vColor")
	NSOpenGL.uniform(colorLocation, { 0, 1, 0, 1 })

	self.currentObject:draw()

	
	NSOpenGL.polygonOffset(-1, -0.2)
	NSOpenGL.enable("GL_LINE_SMOOTH")
	NSOpenGL.enable("GL_BLEND")
	NSOpenGL.blendFunc("GL_SRC_ALPHA", "GL_ONE_MINUS_SRC_ALPHA")
    NSOpenGL.enable("GL_POLYGON_OFFSET_LINE")
    NSOpenGL.polygonMode("GL_FRONT_AND_BACK", "GL_LINE")
    NSOpenGL.lineWidth(2.5)
    NSOpenGL.uniform(colorLocation, { 0, 0, 0.5, 1 } )

    self.currentObject:draw()

    NSOpenGL.polygonMode("GL_FRONT_AND_BACK", "GL_FILL");
    NSOpenGL.disable("GL_POLYGON_OFFSET_LINE");
    NSOpenGL.lineWidth(1);
    NSOpenGL.disable("GL_BLEND");
    NSOpenGL.disable("GL_LINE_SMOOTH");
end




function LDOpenGLView:keyDown(event)
	local b1, b2, b3 = string.byte(event:getCharacters(), 1, 3)

	if b1 ~= 239 or b2 ~= 156 then
		return
	end

	local step = 1.0

	if b3 == 128 then
		-- key up
		self.objectFrame:rotateWorld(-step * 3.1416 / 180, { x=1, y=0, z=0 })
	elseif b3 == 129 then
		-- key down
		self.objectFrame:rotateWorld(step * 3.1416 / 180, { x=1, y=0, z=0 })
	elseif b3 == 130 then
		-- key left
		self.objectFrame:rotateWorld(-step * 3.1416 / 180, { x=0, y=1, z=0 })
	elseif b3 == 131 then
		-- key right
		self.objectFrame:rotateWorld(step * 3.1416 / 180, { x=0, y=1, z=0 })
	end

	self:setNeedsDisplay(true)
end



function LDOpenGLView:rightMouseDown(event)
	-- Nothing
end




function LDOpenGLView:drawObjectType(menuItem)
	
	-- Do nothing if it is ON
	if menuItem:getState() == "NSOnState" then
		return
	end

	local menu = menuItem:getMenu()

	for _, item in ipairs(menu:getItems()) do
		item:setState("NSOffState")
	end
	menuItem:setState("NSOnState")

	if menuItem:getTitle() == "Draw Sphere" then
		self.currentObject = self.sphere
	else
		self.currentObject = self.torus
	end

	self:setNeedsDisplay(true)
end




function LDOpenGLView:setFrame(frameRect)
	self:setScene(frameRect)
end




function LDOpenGLView:setScene(frameRect)
	local w, h = frameRect.width, frameRect.height
	NSOpenGL.viewPort(0, 0, w, h)

	self.viewFrustum = OpenGLFrustum:new()
	self.viewFrustum:setPerspective(35, w / h, 1.0, 500)
end




function LDOpenGLView:dealloc()
	NSOpenGL.deleteProgram(self.program)
end




-------------------------------------------------------------------------
------------------             LDUtilities             ------------------
-------------------------------------------------------------------------




function LDUtilities.loadShaderSource(name)
	local mainBundle = NSBundle.getMainBundle()
	local path = mainBundle:pathForResource(name)
	local shaderFile = io.open(path, "r")
	local src = shaderFile:read("*a")
	return src
end




-------------------------------------------------------------------------
------------------             TriangleBatch           ------------------
-------------------------------------------------------------------------


function TriangleBatch:__gc()
	if self.vertObject then
		NSOpenGL.deleteVertexArrays(self.vertObject)
	end
	NSOpenGL.deleteBuffers(self.indexBuffer)
end



function TriangleBatch:begin()
	local r = {}
	self.__index = TriangleBatch
	setmetatable(r, TriangleBatch)

	r.indexes = {}
	r.verts = {}
	r.normals = {}
	r.texCoords = {}

	return r
end




function TriangleBatch:addTriangle(verts, normals, texCoords)
	local e = 0.0001
	OpenGLMath.normalizeArray(normals)

	for iVertex = 1, 3 do

		local bVertExist = false

		-- For existing one, add index only
        for iMatch = 1, #self.verts do
            if vectorClose(self.verts[iMatch], verts[iVertex], e) and
               vectorClose(self.normals[iMatch], normals[iVertex], e) and
               vectorClose(self.texCoords[iMatch], texCoords[iVertex], e) then
                self.indexes[#self.indexes + 1] = { iMatch - 1 }
                bVertExist = true
                break
            end
        end

        -- No match for this vertex, add to end of list
        if not bVertExist then
           	self.verts[#self.verts + 1] = verts[iVertex]
            self.normals[#self.normals + 1] = normals[iVertex]
            self.texCoords[#self.texCoords + 1] = texCoords[iVertex]
            self.indexes[#self.indexes + 1] = { #self.verts - 1 }
        end
    end
end




function TriangleBatch:endBatch()
	self.vertObject = VertArrayObject:new()
	self.vertObject.program = self.program

	self.vertObject:genBuffer("vert", self.verts, "vVertex")
	--self.vertObject:genBuffer("norm", self.normals)
	--self.vertObject:genBuffer("texC", self.texCoords)

	self.indexBuffer = NSOpenGL.genBuffers(1)
	NSOpenGL.bindBuffer("GL_ELEMENT_ARRAY_BUFFER", self.indexBuffer)
	NSOpenGL.bufferData("GL_ELEMENT_ARRAY_BUFFER", "GL_UNSIGNED_SHORT",
						self.indexes, "GL_STATIC_DRAW")

	self.vertObject:unbind()
end




function TriangleBatch:draw()
	self.vertObject:bind()

	self.vertObject:bindBuffer("vert")
	--self.vertObject:bindBuffer("norm")
	--self.vertObject:bindBuffer("texC")

	NSOpenGL.bindBuffer("GL_ELEMENT_ARRAY_BUFFER", self.indexBuffer)
	NSOpenGL.drawElements("GL_TRIANGLES", #self.indexes, "GL_UNSIGNED_SHORT");
end




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



function VertArrayObject:genBuffer(name, verts, attribName)
	self.buffers[name] = {}
	self.buffers[name].handle = NSOpenGL.genBuffers(1)
	NSOpenGL.bindBuffer("GL_ARRAY_BUFFER", self.buffers[name].handle)
	NSOpenGL.bufferData("GL_ARRAY_BUFFER", "GL_FLOAT", verts, "GL_DYNAMIC_DRAW")
	NSOpenGL.vertexAttribPointer(self.nextAttribPointer, 3, "GL_FLOAT", false)

	self.buffers[name].location = NSOpenGL.getAttribLocation(self.program, attribName)
end




function VertArrayObject:bindBuffer(name)
	NSOpenGL.bindBuffer("GL_ARRAY_BUFFER", self.buffers[name].handle)
	NSOpenGL.enableVertexAttribArray(self.buffers[name].location);
	NSOpenGL.vertexAttribPointer(self.buffers[name].location, 3, "GL_FLOAT", false)
end




-------------------------------------------------------------------------
------------------              Math Tools             ------------------
-------------------------------------------------------------------------



function close(a, b, e)
	return math.abs(a - b) < e
end



function vectorClose(v1, v2, e)
	if #v1 ~= #v2 then
		return false
	end

	for i = 1, #v1 do
		if not close(v1[i], v2[i], e) then
			return false
		end
	end

	return true
end




function makeTorus(torusBatch, majorRadius, minorRadius, numMajor, numMinor)

	local pi = 3.1415926534

    local majorStep = 2.0 * pi / numMajor
    local minorStep = 2.0 * pi / numMinor

    for i = 1, numMajor do

		local a0 = (i - 1) * majorStep
		local a1 = a0 + majorStep
		local x0 = math.cos(a0)
		local y0 = math.sin(a0)
		local x1 = math.cos(a1)
		local y1 = math.sin(a1)

		local vVertex = {}
		local vNormal = {}
		local vTexture = {}
		
		for j = 1, numMinor + 1 do

			local b = (j - 1) * minorStep;
			local c = math.cos(b);
			local r = minorRadius * c + majorRadius;
			local z = minorRadius * math.sin(b);
			
			-- First point
			vTexture[1] = { 
				(i - 1) / (numMajor),
				(j - 1) / numMinor
			}
			vNormal[1] = {
				(x0 * c),
				(y0 * c),
				z / minorRadius
			}
			vVertex[1] = {
				(x0 * r),
				(y0 * r),
				z
			}
			
			-- Second point
			vTexture[2] = {
				(i / numMajor),
				(j - 1) / numMinor
			}
			vNormal[2] = {
				(x1 * c),
				(y1 * c),
				z / minorRadius
			}
			vVertex[2] = {
				(x1 * r),
				(y1 * r),
				z
			}

			-- Next one over
			b = j * minorStep;
			c = math.cos(b);
			r = minorRadius * c + majorRadius;
			z = minorRadius * math.sin(b);
						
			-- Third (based on first)
			vTexture[3] = {
				(i - 1) / numMajor,
				j / numMinor
			}
			vNormal[3] = {
				(x0 * c),
				(y0 * c),
				(z / minorRadius)
			}
			vVertex[3] = {
				(x0 * r),
				(y0 * r),
				z
			}
			
			-- Fourth (based on second)
			vTexture[4] = {
				(i / numMajor),
				(j / numMinor)
			}
			vNormal[4] = {
				(x1 * c),
				(y1 * c),
				z / minorRadius
			}
			vVertex[4] = {
				(x1 * r),
				(y1 * r),
				z
			}

			OpenGLMath.normalizeArray(vNormal)

			torusBatch:addTriangle(vVertex, vNormal, vTexture);			
			
			-- Rearrange for next triangle
			vVertex[1] = vVertex[2]
			vNormal[1] = vNormal[2]
			vTexture[1] = vTexture[2]
			
			vVertex[2] = vVertex[4]
			vNormal[2] = vNormal[4]
			vTexture[2] = vTexture[4]
					
			torusBatch:addTriangle(vVertex, vNormal, vTexture)
		
		end
	end

	torusBatch:endBatch()
end




function makeSphere(sphere, radius, slices, stacks)
    local drho = 3.141592653589 / stacks
    local dtheta = 2 * 3.141592653589 / slices
	local ds = 1 / slices
	local dt = 1 / stacks
	local t = 1
	local s = 0
    
	for i = 1, stacks do
		
		local rho = (i - 1) * drho
		local srho = math.sin(rho)
		local crho = math.cos(rho)
		local srhodrho = math.sin(rho + drho)
		local crhodrho = math.cos(rho + drho)
		
        -- Many sources of OpenGL sphere drawing code uses a triangle fan
        -- for the caps of the sphere. This however introduces texturing 
        -- artifacts at the poles on some OpenGL implementations
        s = 0
		local vVertex = {}
		local vNormal = {}
		local vTexture = {}

		for j = 1, slices do

			local theta = (j - 1) * dtheta
			local stheta = -math.sin(theta)
			local ctheta = math.cos(theta)
			
			local x = stheta * srho
			local y = ctheta * srho
			local z = crho
        
			vTexture[1] = { s, t }
			vNormal[1] = { x, y, z }
			vVertex[1] = { x * radius, y * radius, z * radius }
			
            x = stheta * srhodrho
			y = ctheta * srhodrho
			z = crhodrho

 			vTexture[2] = { s, t - dt }
			vNormal[2] = { x, y, z }
			vVertex[2] = { x * radius, y * radius, z * radius }
			

			theta = (j == iSlices) and 0 or (j * dtheta)
			stheta = -math.sin(theta)
			ctheta = math.cos(theta)
			
			x = stheta * srho
			y = ctheta * srho
			z = crho
        
            s = s + ds
			vTexture[3]= { s, t }
			vNormal[3] = { x, y, z }
			vVertex[3] = { x * radius, y * radius, z * radius }
			
            x = stheta * srhodrho
			y = ctheta * srhodrho
			z = crhodrho

 			vTexture[4] = { s, t - dt }
			vNormal[4] = { x, y, z }
			vVertex[4] = { x * radius, y * radius, z * radius }
		
			sphere:addTriangle(vVertex, vNormal, vTexture);			
			
			-- Rearrange for next triangle
			vVertex[1] = vVertex[2]
			vNormal[1] = vNormal[2]
			vTexture[1] = vTexture[2]

			vVertex[2] = vVertex[4]
			vNormal[2] = vNormal[4]
			vTexture[2] = vTexture[4]
			
			sphere:addTriangle(vVertex, vNormal, vTexture)
		end

        t = t - dt
    end
	sphere:endBatch()
end

