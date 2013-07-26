

local OpenGLMath = require "LuaOpenGLMath"

local GLFrame = {}


GLFrame.__index = GLFrame



function GLFrame:new()
	local r = {
		origin = { x = 0, y = 0, z = 0 },
		up = { x = 0, y = 1, z = 0 },
		forward = { x = 0, y = 0, z = -1 }
	}
	setmetatable(r, self)
	return r
end




function GLFrame:translateWorld(x, y, z)
	self.origin.x = self.origin.x + x
	self.origin.y = self.origin.y + y
	self.origin.z = self.origin.z + z
end




function GLFrame:translateLocal(x, y, z)
	self:moveForward(z)
	self:moveUp(y)
	self:moveRight(x)
end



function GLFrame:moveUp(delta)
	self.origin.x = self.origin.x + self.up.x * delta
	self.origin.y = self.origin.y + self.up.y * delta
	self.origin.z = self.origin.z + self.up.z * delta
end



function GLFrame:moveForward(delta)
	self.origin.x = self.origin.x + self.forward.x * delta
	self.origin.y = self.origin.y + self.forward.y * delta
	self.origin.z = self.origin.z + self.forward.z * delta
end



function GLFrame:moveRight(delta)
	local cross = OpenGLMath.crossProduct(self.up, self.forward)
	self.origin.x = self.origin.x + cross.x * delta
	self.origin.y = self.origin.y + cross.y * delta
	self.origin.z = self.origin.z + cross.z * delta
end




function GLFrame:getMatrix(rotateOnly)
	local xAxis = OpenGLMath.crossProduct(self.up, self.forward)

	local matrix = { xAxis.x, xAxis.y, xAxis.z, 0,
					 self.up.x, self.up.y, self.up.z, 0,
					 self.forward.x, self.forward.y, self.forward.z, 0,
					 0, 0, 0, 1 }

	if not rotateOnly then
		matrix[13], matrix[14], matrix[15] = self.origin.x, self.origin.y, self.origin.z
	end
	
	return matrix
end




function GLFrame:getCameraMatrix(rotateOnly)
	local z = {}
	z.x, z.y, z.z = -self.forward.x, -self.forward.y, -self.forward.z

	local x = OpenGLMath.crossProduct(self.up, z)
	local m = { x.x, self.up.x, z.x, 0,
				x.y, self.up.y, z.y, 0,
				x.z, self.up.z, z.z, 0,
				0, 0, 0, 1 }

	if rotateOnly then
		return m
	end

	local trans = OpenGLMath.translationMatrix(-self.origin.x,
											   -self.origin.y,
											   -self.origin.z)
	return OpenGLMath.multiply44(m, trans)
end



function GLFrame:rotateLocalY(angle)
	local rotMat = OpenGLMath.rotationMatrix(angle, self.up)
	self.up = { x = rotMat[1] * self.forward.x + rotMat[5] * self.forward.y + rotMat[9] * self.forward.z,
				y = rotMat[2] * self.forward.x + rotMat[6] * self.forward.y + rotMat[10] * self.forward.z,
				z = rotMat[3] * self.forward.x + rotMat[7] * self.forward.y + rotMat[11] * self.forward.z }
end



function GLFrame:rotateLocalZ(angle)
	local rotMat = OpenGLMath.rotationMatrix(angle, self.forward)
	self.up = { x = rotMat[1] * self.up.x + rotMat[5] * self.up.y + rotMat[9] * self.up.z,
				y = rotMat[2] * self.up.x + rotMat[6] * self.up.y + rotMat[10] * self.up.z,
				z = rotMat[3] * self.up.x + rotMat[7] * self.up.y + rotMat[11] * self.up.z }
end



function GLFrame:rotateLocalX(angle)
	local x = OpenGLMath.crossProduct(self.up, self.forward)
	local rotMat = OpenGLMath.rotationMatrix(angle, x)
	self.up = OpenGLMath.rotateVector(self.up, rotMat)
	self.forward = OpenGLMath.rotateVector(self.forward, rotMat)
end




function GLFrame:rotateWorld(angle, v)
	local rotMat = OpenGLMath.rotationMatrix(angle, v)
	self.up = {
		x = rotMat[1] * self.up.x + rotMat[5] * self.up.y + rotMat[9] *  self.up.z,
		y = rotMat[2] * self.up.x + rotMat[6] * self.up.y + rotMat[10] *  self.up.z,
		z = rotMat[3] * self.up.x + rotMat[7] * self.up.y + rotMat[11] *  self.up.z,
	}
	self.forward = {
		x = rotMat[1] * self.forward.x + rotMat[5] * self.forward.y + rotMat[9] *  self.forward.z,
		y = rotMat[2] * self.forward.x + rotMat[6] * self.forward.y + rotMat[10] *  self.forward.z,
		z = rotMat[3] * self.forward.x + rotMat[7] * self.forward.y + rotMat[11] *  self.forward.z,
	}
end



function GLFrame:normalize()
	local cross = OpenGLMath.crossProduct(self.up, self.forward)
	self.forward = OpenGLMath.crossProduct(cross, self.up)
	OpenGLMath.normalize(self.up)
	OpenGLMath.normalize(self.forward)
end




return GLFrame




