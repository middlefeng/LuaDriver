



local OpenGLMath = {}




function OpenGLMath.crossProduct(a, b)
	return {
		x = a.y * b.z - b.y * a.z,
		y = -a.x * b.z + b.x * a.z,
		z = a.x * b.y - b.x * a.y
	}
end




function OpenGLMath.translationMatrix(x, y, z)
	return { 1, 0, 0, 0,
			 0, 1, 0, 0,
			 0, 0, 1, 0,
			 x, y, z, 1 }
end




function OpenGLMath.multiply44(m1, m2)
	local p = {}

	local function A(row, col)
		return m1[col * 4 + row + 1]
	end

	local function B(row, col)
		return m2[col * 4 + row + 1]
	end

	local function setP(row, col, v)
		p[col * 4 + row + 1] = v
	end

	for i = 1, 4 do
		local ai = { A(i - 1, 0), A(i - 1, 1), A(i - 1, 2), A(i - 1, 3) }
		setP(i - 1, 0, ai[1] * B(0, 0) + ai[2] * B(1, 0) + ai[3] * B(2, 0) + ai[4] * B(3, 0))
		setP(i - 1, 1, ai[1] * B(0, 1) + ai[2] * B(1, 1) + ai[3] * B(2, 1) + ai[4] * B(3, 1))
		setP(i - 1, 2, ai[1] * B(0, 2) + ai[2] * B(1, 2) + ai[3] * B(2, 2) + ai[4] * B(3, 2))
		setP(i - 1, 3, ai[1] * B(0, 3) + ai[2] * B(1, 3) + ai[3] * B(2, 3) + ai[4] * B(3, 3))
	end

	return p
end




function OpenGLMath.rotationMatrix(angle, v)
	local s = math.sin(angle)
	local c = math.cos(angle)
	local mag = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)

	if mag == 0 then
		return { 1, 0, 0, 0,
				 0, 1, 0, 0,
				 0, 0, 1, 0,
				 0, 0, 0, 1 }
	end

	v.x, v.y, v.z = v.x / mag, v.y / mag, v.z / mag
	local xx, yy, zz = v.x * v.x, v.y * v.y, v.z * v.z
	local xy, yz, zx = v.x * v.y, v.y * v.z, v.z * v.x
	local xs, ys, zs = v.x * s, v.y * s, v.z * s
	local oneC = 1.0 - c

	return {
		(oneC * xx) + c,  (oneC * xy) + zs, (oneC * zx) - ys, 0,
		(oneC * xy) - zs, (oneC * yy) + c,  (oneC * yz) + xs, 0,
		(oneC * zx) + ys, (oneC * yz) - xs, (oneC * zz) + c,  0,
		0, 0, 0, 1
	}
end



function OpenGLMath.extractRotation33(m44)
	return {
		m44[1], m44[2], m44[3],
		m44[5], m44[6], m44[7],
		m44[9], m44[10], m44[11]
	}
end




function OpenGLMath.rotateVector(p, m)
	return { x = m[1] * p.x + m[4] * p.y + m[7] * p.z,
    		 y = m[2] * p.x + m[5] * p.y + m[8] * p.z,
    		 y = m[3] * p.x + m[6] * p.y + m[9] * p.z }
end



function OpenGLMath.squareSum(vector)
	local sum = 0
	for i = 1, #vector do
		local square = vector[i] * vector[i]
		sum = sum + square
	end
	return sum
end




function OpenGLMath.normalize(vector)
	local length = math.sqrt(OpenGLMath.squareSum(vector))
	for i = 1, #vector do
		vector[i] = vector[i] / length
	end
end



function OpenGLMath.normalizeArray(vectorArray)
	for i = 1, #vectorArray do
		OpenGLMath.normalize(vectorArray[i])
	end
end






return OpenGLMath



