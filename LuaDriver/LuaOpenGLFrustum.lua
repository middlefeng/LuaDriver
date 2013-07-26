


local Frustum = {}



function Frustum:new()
	self.__index = Frustum
	local r = {}
	setmetatable(r, self)
	return r
end




function Frustum:setPerspective(fov, aspect, near, far)
	local pi = 3.1415926536
	local ymax = near * math.tan(fov * pi / 360)
	local ymin = -ymax
	local xmin = ymin * aspect
	local xmax = -xmin

	self.projMatrix = {
		(2 * near) / (xmax - xmin), 0, 0, 0,
		0, (2 * near) / (ymax - ymin), 0, 0,
		(xmax + xmin) / (xmax - xmin), (ymax + ymin) / (ymax - ymin), -(far + near) / (far - near), -1,
		0, 0, -(2 * far * near) / (far - near), 0
	}
end


return Frustum