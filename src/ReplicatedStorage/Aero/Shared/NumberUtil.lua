-- Number Util
-- Stephen Leitnick
-- April 22, 2020

--[[

	NumberUtil.E
	NumberUtil.Tau

	NumberUtil.Lerp(min, max, alpha)
	NumberUtil.LerpClamp(min, max, alpha)
	NumberUtil.InverseLerp(min, max, num)
	NumberUtil.Map(num, inMin, inMax, outMin, outMax)
	NumberUtil.Round(num)
	NumberUtil.RoundTo(num, multiple)


	EXAMPLES:

		Lerp:

			Interpolate between two numbers by a certain alpha/percentage.

			Visually, think of a number line ranging from 'min' to 'max'
			and then move along that line by 'alpha' percent.

			Lerp(5, 15, 0.5) == 10
			Lerp(5, 15, 0)   == 5
			Lerp(5, 15, 0.7) == 12
			Lerp(5, 15, 2)   == 25  (unusual to have alpha outside of 0-1. See LerpClamp.)


		LerpClamp:

			The same as Lerp, but the 'alpha' value is clamped between 0-1,
			which will guarantee that the output is within bounds of the
			min and max values.

			LerpClamp(5, 15, 0.5) == 10
			LerpClamp(5, 15, 2)   == 15  (alpha of 2 was clamped down to 1)


		InverseLerp:

			The inverse of the Lerp function. It returns the alpha value
			between the range of [min, max] given the number.

			InverseLerp(5, 15, 10) == 0.5
			InverseLerp(5, 15, 12) == 0.7

		Map:

			Remaps the range of 'num' from its old range of [inMin, inMax]
			to a new range of [outMin, outMax]. This is useful when needing
			to convert a range of inputs to a different output. For instance,
			remapping gamepad stick input to a larger range controlling a
			vehicle steering wheel.

			Map(0.5, 0, 1, -10, 10) == 0
			Map(1, -1, 1, 0, 5)     == 5


		Round:

			Rounds a number to the nearest whole number.

			Round(1.5)  == 2
			Round(3.2)  == 3
			Round(-0.5) == -1


		RoundTo:

			Rounds a number to the nearest given multiple. An example would be
			locking world positions onto a larger grid.

			RoundTo(3.4, 5) == 5
			RoundTo(12, 5)  == 10

--]]


local NumberUtil = {}


NumberUtil.E = 2.7182818284590
NumberUtil.Tau = math.pi * 2


function NumberUtil.Lerp(min, max, alpha)
	return (min + ((max - min) * alpha))
end


function NumberUtil.LerpClamp(min, max, alpha)
	return NumberUtil.Lerp(min, max, math.clamp(alpha, 0, 1))
end


function NumberUtil.InverseLerp(min, max, num)
	return ((num - min) / (max - min))
end


function NumberUtil.Map(n, inMin, inMax, outMin, outMax)
	return (outMin + ((outMax - outMin) * ((n - inMin) / (inMax - inMin))))
end


function NumberUtil.Round(num)
	return (num >= 0 and math.floor(num + 0.5) or math.ceil(num - 0.5))
end


function NumberUtil.RoundTo(num, multiple)
	return NumberUtil.Round(num / multiple) * multiple
end


return NumberUtil