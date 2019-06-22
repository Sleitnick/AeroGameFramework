-- Easing
-- Crazyman32
-- June 21, 2017

-- Source: https://github.com/RoStrap/Interpolation/blob/master/EasingFunctions.lua

local BezierCreator do
	local NEWTON_ITERATIONS = 4
	local NEWTON_MIN_SLOPE = 0.001
	local SUBDIVISION_PRECISION = 0.0000001
	local SUBDIVISION_MAX_ITERATIONS = 10
	local K_SPLINE_TABLE_SIZE = 11
	
	local K_SAMPLE_STEP_SIZE = 1 / (K_SPLINE_TABLE_SIZE - 1)
	
	local function Linear(t, b, c, d)
		return (c or 1)*t / (d or 1) + (b or 0)
	end
	
	function BezierCreator(x1, y1, x2, y2)
		if not (x1 and y1 and x2 and y2) then error("Need 4 numbers to construct a Bezier curve") end
		if not (0 <= x1 and x1 <= 1 and 0 <= x2 and x2 <= 1) then error("The x values must be within range [0, 1]") end
	
		if x1 == y1 and x2 == y2 then
			return Linear
		end
	
		-- Precompute redundant values
		local e, f = 3*x1, 3*x2
		local g, h, i = 1 - f + e, f - 2*e, 3*(1 - f + e)
		local j, k = 2*h, 3*y1
		local l, m = 1 - 3*y2 + k, 3*y2 - 2*k
	
		-- Precompute samples table
		local SampleValues = { }
		for a = 0, K_SPLINE_TABLE_SIZE - 1 do
			local z = a*K_SAMPLE_STEP_SIZE
			SampleValues[a] = ((g*z + h)*z + e)*z -- CalcBezier
		end
	
		return function(t, b, c, d)
			t = (c or 1)*t / (d or 1) + (b or 0)
	
			if t == 0 or t == 1 then -- Make sure the endpoints are correct
				return t
			end
	
			local CurrentSample = K_SPLINE_TABLE_SIZE - 2
	
			for a = 1, CurrentSample do
				if SampleValues[a] > t then
					CurrentSample = a - 1
					break
				end
			end
	
			-- Interpolate to provide an initial guess for t
			local IntervalStart = CurrentSample*K_SAMPLE_STEP_SIZE
			local GuessForT = IntervalStart + K_SAMPLE_STEP_SIZE*(t - SampleValues[CurrentSample]) / (SampleValues[CurrentSample + 1] - SampleValues[CurrentSample])
			local InitialSlope = (i*GuessForT + j)*GuessForT + e
	
			if InitialSlope >= NEWTON_MIN_SLOPE then
				for NewtonRaphsonIterate = 1, NEWTON_ITERATIONS do
					local CurrentSlope = (i*GuessForT + j)*GuessForT + e
					if CurrentSlope == 0 then break end
					GuessForT = GuessForT - (((g*GuessForT + h)*GuessForT + e)*GuessForT - t) / CurrentSlope
				end
			elseif InitialSlope ~= 0 then
				local IntervalStep = IntervalStart + K_SAMPLE_STEP_SIZE
	
				for BinarySubdivide = 1, SUBDIVISION_MAX_ITERATIONS do
					GuessForT = IntervalStart + (IntervalStep - IntervalStart) / 2
					local BezierCalculation = ((g*GuessForT + h)*GuessForT + e)*GuessForT - t
	
					if BezierCalculation > 0 then
						IntervalStep = GuessForT
					else
						IntervalStart = GuessForT
						BezierCalculation = -BezierCalculation
					end
	
					if BezierCalculation <= SUBDIVISION_PRECISION then break end
				end
			end
	
			return ((l*GuessForT + m)*GuessForT + k)*GuessForT
		end
	end
end

-- @specs https://material.io/guidelines/motion/duration-easing.html#duration-easing-natural-easing-curves
local Sharp = BezierCreator(0.4, 0, 0.6, 1)
local Standard = BezierCreator(0.4, 0, 0.2, 1)
local Acceleration = BezierCreator(0.4, 0, 1, 1)
local Deceleration = BezierCreator(0, 0, 0.2, 1)

-- @specs https://developer.microsoft.com/en-us/fabric#/styles/web/motion#basic-animations
local FabricStandard = BezierCreator(0.8, 0, 0.2, 1) -- used for moving.
local FabricAccelerate = BezierCreator(0.9, 0.1, 1, 0.2) -- used for exiting.
local FabricDecelerate = BezierCreator(0.1, 0.9, 0.2, 1) -- used for entering.

-- @specs https://docs.microsoft.com/en-us/windows/uwp/design/motion/timing-and-easing
local UWPAccelerate = BezierCreator(0.7, 0, 1, 0.5)

--[[
	Disclaimer for Robert Penner's Easing Equations license:

	TERMS OF USE - EASING EQUATIONS

	Open source under the BSD License.

	Copyright © 2001 Robert Penner
	All rights reserved.

	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

	* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
	* Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
	OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- For all easing functions:
-- t = elapsed time
-- b = beginning value
-- c = change in value same as: ending - beginning
-- d = duration (total time)

-- Where applicable
-- a = amplitude
-- p = period

local math_sin = math.sin
local math_cos = math.cos
local math_asin = math.asin
local math_exp = math.exp
local math_sqrt = math.sqrt

local function Linear(t, b, c, d)
	return c * t / d + b
end

local function Smooth(t, b, c, d)
	t = t / d
	return c * t * t * (3 - 2 * t) + b
end

local function Smoother(t, b, c, d)
	t = t / d
	return c * t * t * t * (t * (6 * t - 15) + 10) + b
end

-- Arceusinator's Easing Functions
local function RevBack(t, b, c, d)
	t = 1 - t / d
	return c * (1 - (math_sin(t * 1.5707963267948965579989817342720925807952880859375) + (math_sin(t * 3.141592653589793115997963468544185161590576171875) * (math_cos(t * 3.141592653589793115997963468544185161590576171875) + 1) / 2))) + b
end

local function RidiculousWiggle(t, b, c, d)
	t = t / d
	return c * math_sin(math_sin(t * 3.141592653589793115997963468544185161590576171875) * 1.5707963267948965579989817342720925807952880859375) + b
end

-- YellowTide's Easing Functions
local function Spring(t, b, c, d)
	t = t / d
	return (1 + (-math_exp(-6.9 * t) * math_cos(-20.1061929829746759423869661986827850341796875 * t))) * c + b
end

local function SoftSpring(t, b, c, d)
	t = t / d
	return (1 + (-math_exp(-7.5 * t) * math_cos(-10.05309649148733797119348309934139251708984375 * t))) * c + b
end
-- End of YellowTide's functions

local function InQuad(t, b, c, d)
	t = t / d
	return c * t * t + b
end

local function OutQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

local function InOutQuad(t, b, c, d)
	t = t / d * 2
	return t < 1 and c / 2 * t * t + b or -c / 2 * ((t - 1) * (t - 3) - 1) + b
end

local function OutInQuad(t, b, c, d)
	if t < d / 2 then
		t = 2 * t / d
		return -c / 2 * t * (t - 2) + b
	else
		t, c = ((t * 2) - d) / d, c / 2
		return c * t * t + b + c
	end
end

local function InCubic(t, b, c, d)
	t = t / d
	return c * t * t * t + b
end

local function OutCubic(t, b, c, d)
	t = t / d - 1
	return c * (t * t * t + 1) + b
end

local function InOutCubic(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t + b
	else
		t = t - 2
		return c / 2 * (t * t * t + 2) + b
	end
end

local function OutInCubic(t, b, c, d)
	if t < d / 2 then
		t = t * 2 / d - 1
		return c / 2 * (t * t * t + 1) + b
	else
		t, c = ((t * 2) - d) / d, c / 2
		return c * t * t * t + b + c
	end
end

local function InQuart(t, b, c, d)
	t = t / d
	return c * t * t * t * t + b
end

local function OutQuart(t, b, c, d)
	t = t / d - 1
	return -c * (t * t * t * t - 1) + b
end

local function InOutQuart(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t * t + b
	else
		t = t - 2
		return -c / 2 * (t * t * t * t - 2) + b
	end
end

local function OutInQuart(t, b, c, d)
	if t < d / 2 then
		t, c = t * 2 / d - 1, c / 2
		return -c * (t * t * t * t - 1) + b
	else
		t, c = ((t * 2) - d) / d, c / 2
		return c * t * t * t * t + b + c
	end
end

local function InQuint(t, b, c, d)
	t = t / d
	return c * t * t * t * t * t + b
end

local function OutQuint(t, b, c, d)
	t = t / d - 1
	return c * (t * t * t * t * t + 1) + b
end

local function InOutQuint(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t * t * t + b
	else
		t = t - 2
		return c / 2 * (t * t * t * t * t + 2) + b
	end
end

local function OutInQuint(t, b, c, d)
	if t < d / 2 then
		t = t * 2 / d - 1
		return c / 2 * (t * t * t * t * t + 1) + b
	else
		t, c = ((t * 2) - d) / d, c / 2
		return c * t * t * t * t * t + b + c
	end
end

local function InSine(t, b, c, d)
	return -c * math_cos(t / d * 1.5707963267948965579989817342720925807952880859375) + c + b
end

local function OutSine(t, b, c, d)
	return c * math_sin(t / d * 1.5707963267948965579989817342720925807952880859375) + b
end

local function InOutSine(t, b, c, d)
	return -c / 2 * (math_cos(3.141592653589793115997963468544185161590576171875 * t / d) - 1) + b
end

local function OutInSine(t, b, c, d)
	c = c / 2
	return t < d / 2 and c * math_sin(t * 2 / d * 1.5707963267948965579989817342720925807952880859375) + b or -c * math_cos(((t * 2) - d) / d * 1.5707963267948965579989817342720925807952880859375) + 2 * c + b
end

local function InExpo(t, b, c, d)
	if t == 0 then
		return b
	else
		return c * 1024 ^ (t / d - 1) + b - c / 1000
	end
end

local function OutExpo(t, b, c, d)
	if t == d then
		return b + c
	else
		return c * 1.001 * (1 - math_exp(-6.9314718055994531 * (t / d))) + b
	end
end

local function InOutExpo(t, b, c, d)
	t = t / d * 2

	if t == 0 then
		return b
	elseif t == 2 then
		return b + c
	elseif t < 1 then
		return c / 2 * 1024 ^ (t - 1) + b - c / 2000
	else
		return c * 0.50025 * (2 - math_exp(-6.9314718055994531 * (t - 1))) + b
	end
end

local function OutInExpo(t, b, c, d)
	c = c / 2
	if t < d / 2 then
		if t * 2 == d then
			return b + c
		else
			return c * 1.001 * (1 - math_exp(13.8629436111989062 * t / d)) + b
		end
	else
		if t * 2 - d == 0 then
			return b + c
		else
			return c * 1024 ^ ((t * 2 - d) / d - 1) + b + c - c / 1000
		end
	end
end

local function InCirc(t, b, c, d)
	t = t / d
	return -c * (math_sqrt(1 - t * t) - 1) + b
end

local function OutCirc(t, b, c, d)
	t = t / d - 1
	return c * math_sqrt(1 - t * t) + b
end

local function InOutCirc(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return -c / 2 * (math_sqrt(1 - t * t) - 1) + b
	else
		t = t - 2
		return c / 2 * (math_sqrt(1 - t * t) + 1) + b
	end
end

local function OutInCirc(t, b, c, d)
	c = c / 2
	if t < d / 2 then
		t = t * 2 / d - 1
		return c * math_sqrt(1 - t * t) + b
	else
		t = (t * 2 - d) / d
		return -c * (math_sqrt(1 - t * t) - 1) + b + c
	end
end

local function InElastic(t, b, c, d, a, p)
	t = t / d - 1
	if t == -1 then
		return b
	else
		if t == 0 then
			return b + c
		else
			p = p or d * 0.3
			if a == nil or a < (c >= 0 and c or 0 - c) then
				return -(c * 1024 ^ t * math_sin((t * d - p / 4) * 6.28318530717958623199592693708837032318115234375 / p)) + b
			else
				return -(a * 1024 ^ t * math_sin((t * d - p / 6.28318530717958623199592693708837032318115234375 * math_asin(c / a)) * 6.28318530717958623199592693708837032318115234375 / p)) + b
			end
		end
	end
end

local function OutElastic(t, b, c, d, a, p)
	t = t / d
	if t == 0 then
		return b
	else
		if t == 1 then
			return b + c
		else
			p = p or d * 0.3
			if a == nil or a < (c >= 0 and c or 0 - c) then
				return c * math_exp(-6.9314718055994531 * t) * math_sin((t * d - p / 4) * 6.28318530717958623199592693708837032318115234375 / p) + c + b
			else
				return a * math_exp(-6.9314718055994531 * t) * math_sin((t * d - p / 6.28318530717958623199592693708837032318115234375 * math_asin(c / a)) * 6.28318530717958623199592693708837032318115234375 / p) + c + b
			end
		end
	end
end

local function InOutElastic(t, b, c, d, a, p)
	if t == 0 then return b end
	t = t / d * 2 - 1
	if t == 1 then return b + c end

	p = p or d * 0.45
	a = a or 0

	local s

	if not a or a < (c >= 0 and c or 0 - c) then
		a = c
		s = p / 4
	else
		s = p / 6.28318530717958623199592693708837032318115234375 * math_asin(c / a)
	end

	if t < 1 then
		return -a / 2 * 1024 ^ t * math_sin((t * d - s) * 6.28318530717958623199592693708837032318115234375 / p) + b
	else
		return a * math_exp(-6.9314718055994531 * t) * math_sin((t * d - s) * 6.28318530717958623199592693708837032318115234375 / p) / 2 + c + b
	end
end

local function OutInElastic(t, b, c, d, a, p)
	if t < d / 2 then
		return OutElastic(t * 2, b, c / 2, d, a, p)
	else
		return InElastic(t * 2 - d, b + c / 2, c / 2, d, a, p)
	end
end

local function InBack(t, b, c, d, s)
	s = s or 1.70158
	t = t / d
	return c * t * t * ((s + 1) * t - s) + b
end

local function OutBack(t, b, c, d, s)
	s = s or 1.70158
	t = t / d - 1
	return c * (t * t * ((s + 1) * t + s) + 1) + b
end

local function InOutBack(t, b, c, d, s)
	s = (s or 1.70158) * 1.525
	t = t / d * 2
	if t < 1 then
		return c / 2 * (t * t * ((s + 1) * t - s)) + b
	else
		t = t - 2
		return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
	end
end

local function OutInBack(t, b, c, d, s)
	c = c / 2
	s = s or 1.70158
	if t < d / 2 then
		t = (t * 2) / d - 1
		return c * (t * t * ((s + 1) * t + s) + 1) + b
	else
		t = ((t * 2) - d) / d
		return c * t * t * ((s + 1) * t - s) + b + c
	end
end

local function OutBounce(t, b, c, d)
	t = t / d
	if t < 1 / 2.75 then
		return c * (7.5625 * t * t) + b
	elseif t < 2 / 2.75 then
		t = t - (1.5 / 2.75)
		return c * (7.5625 * t * t + 0.75) + b
	elseif t < 2.5 / 2.75 then
		t = t - (2.25 / 2.75)
		return c * (7.5625 * t * t + 0.9375) + b
	else
		t = t - (2.625 / 2.75)
		return c * (7.5625 * t * t + 0.984375) + b
	end
end

local function InBounce(t, b, c, d)
	return c - OutBounce(d - t, 0, c, d) + b
end

local function InOutBounce(t, b, c, d)
	if t < d / 2 then
		return InBounce(t * 2, 0, c, d) / 2 + b
	else
		return OutBounce(t * 2 - d, 0, c, d) / 2 + c / 2 + b
	end
end

local function OutInBounce(t, b, c, d)
	if t < d / 2 then
		return OutBounce(t * 2, b, c / 2, d)
	else
		return InBounce(t * 2 - d, b + c / 2, c / 2, d)
	end
end

return {
	[Enum.EasingDirection.In.Name] = {
		[Enum.EasingStyle.Linear.Name] = Linear;
		[Enum.EasingStyle.Sine.Name] = InSine;
		[Enum.EasingStyle.Back.Name] = InBack;
		[Enum.EasingStyle.Quad.Name] = InQuad;
		[Enum.EasingStyle.Quart.Name] = InQuart;
		[Enum.EasingStyle.Quint.Name] = InQuint;
		[Enum.EasingStyle.Bounce.Name] = InBounce;
		[Enum.EasingStyle.Elastic.Name] = InElastic;
		Smooth = Smooth;
		Smoother = Smoother;
		RevBack = RevBack;
		RidiculousWiggle = RidiculousWiggle;
		Spring = Spring;
		SoftSpring = SoftSpring;
		Sharp = Sharp;
		Standard = Standard;
		Acceleration = Acceleration;
		Deceleration = Deceleration;
		FabricStandard = FabricStandard;
		FabricAccelerate = FabricAccelerate;
		FabricDecelerate = FabricDecelerate;
		UWPAccelerate = UWPAccelerate;
		Expo = InExpo;
		Cubic = InCubic;
		Circ = InCirc;
	};

	[Enum.EasingDirection.Out.Name] = {
		[Enum.EasingStyle.Linear.Name] = Linear;
		[Enum.EasingStyle.Sine.Name] = OutSine;
		[Enum.EasingStyle.Back.Name] = OutBack;
		[Enum.EasingStyle.Quad.Name] = OutQuad;
		[Enum.EasingStyle.Quart.Name] = OutQuart;
		[Enum.EasingStyle.Quint.Name] = OutQuint;
		[Enum.EasingStyle.Bounce.Name] = OutBounce;
		[Enum.EasingStyle.Elastic.Name] = OutElastic;
		Smooth = Smooth;
		Smoother = Smoother;
		RevBack = RevBack;
		RidiculousWiggle = RidiculousWiggle;
		Spring = Spring;
		SoftSpring = SoftSpring;
		Sharp = Sharp;
		Standard = Standard;
		Acceleration = Acceleration;
		Deceleration = Deceleration;
		FabricStandard = FabricStandard;
		FabricAccelerate = FabricAccelerate;
		FabricDecelerate = FabricDecelerate;
		UWPAccelerate = UWPAccelerate;
		Expo = OutExpo;
		Cubic = OutCubic;
		Circ = OutCirc;
	};

	[Enum.EasingDirection.InOut.Name] = {
		[Enum.EasingStyle.Linear.Name] = Linear;
		[Enum.EasingStyle.Sine.Name] = InOutSine;
		[Enum.EasingStyle.Back.Name] = InOutBack;
		[Enum.EasingStyle.Quad.Name] = InOutQuad;
		[Enum.EasingStyle.Quart.Name] = InOutQuart;
		[Enum.EasingStyle.Quint.Name] = InOutQuint;
		[Enum.EasingStyle.Bounce.Name] = InOutBounce;
		[Enum.EasingStyle.Elastic.Name] = InOutElastic;
		Smooth = Smooth;
		Smoother = Smoother;
		RevBack = RevBack;
		RidiculousWiggle = RidiculousWiggle;
		Spring = Spring;
		SoftSpring = SoftSpring;
		Sharp = Sharp;
		Standard = Standard;
		Acceleration = Acceleration;
		Deceleration = Deceleration;
		FabricStandard = FabricStandard;
		FabricAccelerate = FabricAccelerate;
		FabricDecelerate = FabricDecelerate;
		UWPAccelerate = UWPAccelerate;
		Expo = InOutExpo;
		Cubic = InOutCubic;
		Circ = InOutCirc;
	};

	OutIn = {
		[Enum.EasingStyle.Linear.Name] = Linear;
		[Enum.EasingStyle.Sine.Name] = OutInSine;
		[Enum.EasingStyle.Back.Name] = OutInBack;
		[Enum.EasingStyle.Quad.Name] = OutInQuad;
		[Enum.EasingStyle.Quart.Name] = OutInQuart;
		[Enum.EasingStyle.Quint.Name] = OutInQuint;
		[Enum.EasingStyle.Bounce.Name] = OutInBounce;
		[Enum.EasingStyle.Elastic.Name] = OutInElastic;
		Smooth = Smooth;
		Smoother = Smoother;
		RevBack = RevBack;
		RidiculousWiggle = RidiculousWiggle;
		Spring = Spring;
		SoftSpring = SoftSpring;
		Sharp = Sharp;
		Standard = Standard;
		Acceleration = Acceleration;
		Deceleration = Deceleration;
		FabricStandard = FabricStandard;
		FabricAccelerate = FabricAccelerate;
		FabricDecelerate = FabricDecelerate;
		UWPAccelerate = UWPAccelerate;
		Expo = OutInExpo;
		Cubic = OutInCubic;
		Circ = OutInCirc;
	};
}
