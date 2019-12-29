-- Easing
-- Stephen Leitnick
-- June 21, 2017

-- Source: https://github.com/RoStrap/Interpolation/blob/master/EasingFunctions.lua

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

local sin, cos, asin = math.sin, math.cos, math.asin

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
	return c * (1 - (sin(t * 1.5707963267948965579989817342720925807952880859375) + (sin(t * 3.14159265358979311599796346854418516159057617187) * (cos(t * 3.14159265358979311599796346854418516159057617187) + 1) * 0.5))) + b
end

local function RidiculousWiggle(t, b, c, d)
	t = t / d
	return c * sin(sin(t * 3.14159265358979311599796346854418516159057617187) * 1.5707963267948965579989817342720925807952880859375) + b
end

-- YellowTide's Easing Functions
local function Spring(t, b, c, d)
	t = t / d
	return (1 + (-2.72 ^ (-6.9 * t) * cos(-20.1061929829746759423869661986827850341796875 * t))) * c + b
end

local function SoftSpring(t, b, c, d)
	t = t / d
	return (1 + (-2.72 ^ (-7.5 * t) * cos(-10.05309649148733797119348309934139251708984375 * t))) * c + b
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
	return t < 1 and c * 0.5 * t * t + b or -c * 0.5 * ((t - 1) * (t - 3) - 1) + b
end

local function OutInQuad(t, b, c, d)
	if t < d * 0.5 then
		t = 2 * t / d
		return -0.5 * c * t * (t - 2) + b
	else
		t, c = ((t * 2) - d) / d, 0.5 * c
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
		return c * 0.5 * t * t * t + b
	else
		t = t - 2
		return c * 0.5 * (t * t * t + 2) + b
	end
end

local function OutInCubic(t, b, c, d)
	if t < d * 0.5 then
		t = t * 2 / d - 1
		return c * 0.5 * (t * t * t + 1) + b
	else
		t, c = ((t * 2) - d) / d, c * 0.5
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
		return c * 0.5 * t * t * t * t + b
	else
		t = t - 2
		return -c * 0.5 * (t * t * t * t - 2) + b
	end
end

local function OutInQuart(t, b, c, d)
	if t < d * 0.5 then
		t, c = t * 2 / d - 1, c * 0.5
		return -c * (t * t * t * t - 1) + b
	else
		t, c = ((t * 2) - d) / d, c * 0.5
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
		return c * 0.5 * t * t * t * t * t + b
	else
		t = t - 2
		return c * 0.5 * (t * t * t * t * t + 2) + b
	end
end

local function OutInQuint(t, b, c, d)
	if t < d * 0.5 then
		t = t * 2 / d - 1
		return c * 0.5 * (t * t * t * t * t + 1) + b
	else
		t, c = ((t * 2) - d) / d, c * 0.5
		return c * t * t * t * t * t + b + c
	end
end

local function InSine(t, b, c, d)
	return -c * cos(t / d * 1.5707963267948965579989817342720925807952880859375) + c + b
end

local function OutSine(t, b, c, d)
	return c * sin(t / d * 1.5707963267948965579989817342720925807952880859375) + b
end

local function InOutSine(t, b, c, d)
	return -c * 0.5 * (cos(3.14159265358979311599796346854418516159057617187 * t / d) - 1) + b
end

local function OutInSine(t, b, c, d)
	c = c * 0.5
	return t < d * 0.5 and c * sin(t * 2 / d * 1.5707963267948965579989817342720925807952880859375) + b or -c * cos(((t * 2) - d) / d * 1.5707963267948965579989817342720925807952880859375) + 2 * c + b
end

local function InExpo(t, b, c, d)
	return t == 0 and b or c * 2 ^ (10 * (t / d - 1)) + b - c * 0.001
end

local function OutExpo(t, b, c, d)
	return t == d and b + c or c * 1.001 * (1 - 2 ^ (-10 * t / d)) + b
end

local function InOutExpo(t, b, c, d)
	t = t / d * 2
	return t == 0 and b or t == 2 and b + c or t < 1 and c * 0.5 * 2 ^ (10 * (t - 1)) + b - c * 0.0005 or c * 0.5 * 1.0005 * (2 - 2 ^ (-10 * (t - 1))) + b
end

local function OutInExpo(t, b, c, d)
	c = c * 0.5
	return t < d * 0.5 and (t * 2 == d and b + c or c * 1.001 * (1 - 2 ^ (-20 * t / d)) + b) or t * 2 - d == 0 and b + c or c * 2 ^ (10 * ((t * 2 - d) / d - 1)) + b + c - c * 0.001
end

local function InCirc(t, b, c, d)
	t = t / d
	return -c * ((1 - t * t) ^ 0.5 - 1) + b
end

local function OutCirc(t, b, c, d)
	t = t / d - 1
	return c * (1 - t * t) ^ 0.5 + b
end

local function InOutCirc(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return -c * 0.5 * ((1 - t * t) ^ 0.5 - 1) + b
	else
		t = t - 2
		return c * 0.5 * ((1 - t * t) ^ 0.5 + 1) + b
	end
end

local function OutInCirc(t, b, c, d)
	c = c * 0.5
	if t < d * 0.5 then
		t = t * 2 / d - 1
		return c * (1 - t * t) ^ 0.5 + b
	else
		t = (t * 2 - d) / d
		return -c * ((1 - t * t) ^ 0.5 - 1) + b + c
	end
end

local function InElastic(t, b, c, d, a, p)
	t = t / d - 1
	p = p or d * 0.3
	return t == -1 and b or t == 0 and b + c or (not a or a < (c >= 0 and c or 0 - c)) and -(c * 2 ^ (10 * t) * sin((t * d - p * 0.25) * 6.28318530717958623199592693708837032318115234375 / p)) + b or -(a * 2 ^ (10 * t) * sin((t * d - p / 6.28318530717958623199592693708837032318115234375 * asin(c / a)) * 6.28318530717958623199592693708837032318115234375 / p)) + b
end

local function OutElastic(t, b, c, d, a, p)
	t = t / d
	p = p or d * 0.3
	return t == 0 and b or t == 1 and b + c or (not a or a < (c >= 0 and c or 0 - c)) and c * 2 ^ (-10 * t) * sin((t * d - p * 0.25) * 6.28318530717958623199592693708837032318115234375 / p) + c + b or a * 2 ^ (-10 * t) * sin((t * d - p / 6.28318530717958623199592693708837032318115234375 * asin(c / a)) * 6.28318530717958623199592693708837032318115234375 / p) + c + b
end

local function InOutElastic(t, b, c, d, a, p)
	if t == 0 then
		return b
	end

	t = t / d * 2 - 1

	if t == 1 then
		return b + c
	end

	p = p or d * 0.45
	a = a or 0

	local s

	if not a or a < (c >= 0 and c or 0 - c) then
		a = c
		s = p * 0.25
	else
		s = p / 6.28318530717958623199592693708837032318115234375 * asin(c / a)
	end

	if t < 1 then
		return -0.5 * a * 2 ^ (10 * t) * sin((t * d - s) * 6.28318530717958623199592693708837032318115234375 / p) + b
	else
		return a * 2 ^ (-10 * t) * sin((t * d - s) * 6.28318530717958623199592693708837032318115234375 / p ) * 0.5 + c + b
	end
end

local function OutInElastic(t, b, c, d, a, p)
	if t < d * 0.5 then
		return OutElastic(t * 2, b, c * 0.5, d, a, p)
	else
		return InElastic(t * 2 - d, b + c * 0.5, c * 0.5, d, a, p)
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
		return c * 0.5 * (t * t * ((s + 1) * t - s)) + b
	else
		t = t - 2
		return c * 0.5 * (t * t * ((s + 1) * t + s) + 2) + b
	end
end

local function OutInBack(t, b, c, d, s)
	c = c * 0.5
	s = s or 1.70158
	if t < d * 0.5 then
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
	if t < d * 0.5 then
		return InBounce(t * 2, 0, c, d) * 0.5 + b
	else
		return OutBounce(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
	end
end

local function OutInBounce(t, b, c, d)
	if t < d * 0.5 then
		return OutBounce(t * 2, b, c * 0.5, d)
	else
		return InBounce(t * 2 - d, b + c * 0.5, c * 0.5, d)
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
		[Enum.EasingStyle.Exponential.Name] = InExpo;
		[Enum.EasingStyle.Circular.Name] = InCirc;
		[Enum.EasingStyle.Cubic.Name] = InCubic;
		Smooth = Smooth;
		Smoother = Smoother;
		RevBack = RevBack;
		RidiculousWiggle = RidiculousWiggle;
		Spring = Spring;
		SoftSpring = SoftSpring;
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
		[Enum.EasingStyle.Exponential.Name] = OutExpo;
		[Enum.EasingStyle.Circular.Name] = OutCirc;
		[Enum.EasingStyle.Cubic.Name] = OutCubic;
		Smooth = Smooth;
		Smoother = Smoother;
		RevBack = RevBack;
		RidiculousWiggle = RidiculousWiggle;
		Spring = Spring;
		SoftSpring = SoftSpring;
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
		[Enum.EasingStyle.Exponential.Name] = InOutExpo;
		[Enum.EasingStyle.Circular.Name] = InOutCirc;
		[Enum.EasingStyle.Cubic.Name] = InOutCubic;
		Smooth = Smooth;
		Smoother = Smoother;
		RevBack = RevBack;
		RidiculousWiggle = RidiculousWiggle;
		Spring = Spring;
		SoftSpring = SoftSpring;
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
		[Enum.EasingStyle.Exponential.Name] = OutInExpo;
		[Enum.EasingStyle.Circular.Name] = OutInCirc;
		[Enum.EasingStyle.Cubic.Name] = OutInCubic;
		Smooth = Smooth;
		Smoother = Smoother;
		RevBack = RevBack;
		RidiculousWiggle = RidiculousWiggle;
		Spring = Spring;
		SoftSpring = SoftSpring;
	};
}
