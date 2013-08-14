

local Batch = {}
local TriangleBatch = {}
Batch.Triangle = TriangleBatch

local MathTools = {}



local OpenGLMath = require "LuaOpenGLMath"
local VertArrayObject = require "LuaOpenGLVertexObject"
local OpenGLShaderManager = require "LuaOpenGLShaderManager"



-------------------------------------------------------------------------
------------------             TriangleBatch           ------------------
-------------------------------------------------------------------------


function TriangleBatch:__gc()
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
	if type(normals) == "table" then
		OpenGLMath.normalizeArray(normals)
	end

	for iVertex = 1, 3 do

		local bVertExist = false

		-- For existing one, add index only
        for iMatch = 1, #self.verts do
            if MathTools.vectorClose(self.verts[iMatch], verts[iVertex], e) and
               (type(normals) ~= "table" or MathTools.vectorClose(self.normals[iMatch], normals[iVertex], e)) and
        	   (type(texCoords) ~= "table" or MathTools.vectorClose(self.texCoords[iMatch], texCoords[iVertex], e)) then
                self.indexes[#self.indexes + 1] = { iMatch - 1 }
                bVertExist = true
                break
            end
        end

        -- No match for this vertex, add to end of list
        if not bVertExist then
           	self.verts[#self.verts + 1] = verts[iVertex]
           	self.indexes[#self.indexes + 1] = { #self.verts - 1 }

           	if type(normals) == "table" then
				self.normals[#self.normals + 1] = normals[iVertex]
			end
			if type(texCoords) == "table" then
	        	self.texCoords[#self.texCoords + 1] = texCoords[iVertex]
	        end
        end
    end
end




function TriangleBatch:endBatch()
	self.vertObject = VertArrayObject:new()
	self.vertObject.program = self.program

	self.vertObject:genBuffer("vert", self.verts)
	if #self.normals ~= 0 then
		self.vertObject:genBuffer("norm", self.normals)
	end
	if #self.texCoords ~= 0 then
		self.vertObject:genBuffer("texC", self.texCoords)
	end

	self.verts = nil
	self.normals = nil
	self.texCoords = nil

	self.indexBuffer = NSOpenGL.genBuffers(1)
	NSOpenGL.bindBuffer("GL_ELEMENT_ARRAY_BUFFER", self.indexBuffer)
	NSOpenGL.bufferData("GL_ELEMENT_ARRAY_BUFFER", "GL_UNSIGNED_SHORT",
						self.indexes, "GL_STATIC_DRAW")

	self.vertObject:unbind()
end




function TriangleBatch:draw()
	local progName = OpenGLShaderManager.currentProgramName

	self.vertObject:bind()
	self.vertObject:bindBufferToAttrib("vert", progName, "vVertex")
	self.vertObject:bindBufferToAttrib("norm", progName, "vNormal")
	self.vertObject:bindBufferToAttrib("texC", progName, "vTexture")

	NSOpenGL.bindBuffer("GL_ELEMENT_ARRAY_BUFFER", self.indexBuffer)
	NSOpenGL.drawElements("GL_TRIANGLES", #self.indexes, "GL_UNSIGNED_SHORT");
end




-------------------------------------------------------------------------
------------------              Math Tools             ------------------
-------------------------------------------------------------------------



function MathTools.close(a, b, e)
	return math.abs(a - b) < e * b
end



function MathTools.vectorClose(v1, v2, e)
	if #v1 ~= #v2 then
		return false
	end

	for i = 1, #v1 do
		if not MathTools.close(v1[i], v2[i], e) then
			return false
		end
	end

	return true
end



function MathTools.vectorArrayClose(va1, va2, e)
	if #va1 ~= #va2 then
		return false
	end

	for i = 1, #va1 do
		if type(va1) == "table" and
		   type(va2) == "table" then
			if not MathTools.vectorClose(va1[i], va2[i], e) then
				return false
			end
		end
	end

	return true
end





return Batch
