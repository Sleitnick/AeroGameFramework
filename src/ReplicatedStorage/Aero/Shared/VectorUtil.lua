-- Vector Util
-- Stephen Leitnick
-- April 22, 2020

--[[

	VectorUtil.ClampMagnitude(vector, maxMagnitude)
	VectorUtil.AngleBetween(vector1, vector2)
	VectorUtil.AngleBetweenSigned(vector1, vector2, axisVector)


	EXAMPLES:

		ClampMagnitude:

			Clamps the magnitude of a vector so it is only a certain length.

			ClampMagnitude(Vector3.new(100, 0, 0), 15) == Vector3.new(15, 0, 0)
			ClampMagnitude(Vector3.new(10, 0, 0), 20)  == Vector3.new(10, 0, 0)

		
		AngleBetween:

			Finds the angle (in radians) between two vectors.

			v1 = Vector3.new(10, 0, 0)
			v2 = Vector3.new(0, 10, 0)
			AngleBetween(v1, v2) == math.rad(90)

		
		AngleBetweenSigned:

			Same as AngleBetween, but returns a signed value.

			v1 = Vector3.new(10, 0, 0)
			v2 = Vector3.new(0, 0, -10)
			axis = Vector3.new(0, 1, 0)
			AngleBetweenSigned(v1, v2, axis) == math.rad(90)

--]]


local VectorUtil = {}


function VectorUtil.ClampMagnitude(vector, maxMagnitude)
	return (vector.Magnitude > maxMagnitude and (vector.Unit * maxMagnitude) or vector)
end


function VectorUtil.AngleBetween(vector1, vector2)
	return math.acos(math.clamp(vector1.Unit:Dot(vector2.Unit), -1, 1))
end


function VectorUtil.AngleBetweenSigned(vector1, vector2, axisVector)
	local angle = VectorUtil.AngleBetween(vector1, vector2)
	return angle * math.sign(axisVector:Dot(vector1:Cross(vector2)))
end


return VectorUtil