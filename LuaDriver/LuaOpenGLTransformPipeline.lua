

local OpenGLMath = require "LuaOpenGLMath"


local OpenGLTransformPipeline = {}



function OpenGLTransformPipeline:new()
	self.__index = OpenGLTransformPipeline
	
	local r = {}
	local identitiy = { 1, 0, 0, 0,
						0, 1, 0, 0,
						0, 0, 1, 0,
						0, 0, 0, 1 }
	r.modelView = identitiy
	r.projection = identitiy
	setmetatable(r, self)
	return r
end




function OpenGLTransformPipeline:getMVP()
	return OpenGLMath.multiply44(self.projection, self.modelView)
end



function OpenGLTransformPipeline:getNormalMatrix(bNormalize)
	local mvp = self:getMVP()
	local m33 = {
		{ mvp[1], mvp[2], mvp[3] },
		{ mvp[5], mvp[6], mvp[7] },
		{ mvp[9], mvp[10], mvp[11] }
	}

	if bNormalize then
		OpenGLMath.normalizeArray(m33)
	end

	return { m33[1][1], m33[1][2], m33[1][3],
			 m33[2][1], m33[2][2], m33[2][3],
			 m33[3][1], m33[3][2], m33[3][3] }
end



return OpenGLTransformPipeline




