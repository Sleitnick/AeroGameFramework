-- Vector Util
-- Stephen Leitnick
-- April 22, 2020

--[[

	VectorUtil.ClampMagnitude(vector, maxMagnitude)
	VectorUtil.AngleBetween(vector1, vector2)


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

--]]


local VectorUtil = {}


function VectorUtil.ClampMagnitude(vector, maxMagnitude)
	return (vector.Magnitude > maxMagnitude and (vector.Unit * maxMagnitude) or vector)
end


function VectorUtil.AngleBetween(vector1, vector2)
	return math.acos(math.clamp(vector1.Unit:Dot(vector2.Unit), -1, 1))
end

-- clamp magnitude, find angle

return VectorUtil