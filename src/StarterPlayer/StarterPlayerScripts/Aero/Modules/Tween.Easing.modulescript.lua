-- Easing
-- Crazyman32
-- June 21, 2017

-- Source: https://github.com/EmmanuelOga/easing

local sin = math.sin
local cos = math.cos
local pi = math.pi
local abs = math.abs
local asin  = math.asin

local function linear(t, b, c, d)
	return c * t / d + b
end

local function inQuad(t, b, c, d)
	t = t / d
	return c * t * t + b
end

local function outQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

local function inOutQuad(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

local function outInQuad(t, b, c, d)
	if t < d / 2 then
		return outQuad (t * 2, b, c / 2, d)
	else
		return inQuad((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function inCubic (t, b, c, d)
	t = t / d
	return c * t * t * t + b
end

local function outCubic(t, b, c, d)
	t = t / d - 1
	return c * (t * t * t + 1) + b
end

local function inOutCubic(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t + b
	else
		t = t - 2
		return c / 2 * (t * t * t + 2) + b
	end
end

local function outInCubic(t, b, c, d)
	if t < d / 2 then
		return outCubic(t * 2, b, c / 2, d)
	else
		return inCubic((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function inQuart(t, b, c, d)
	t = t / d
	return c * t * t * t * t + b
end

local function outQuart(t, b, c, d)
	t = t / d - 1
	return -c * (t * t * t * t - 1) + b
end

local function inOutQuart(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t * t + b
	else
		t = t - 2
		return -c / 2 * (t * t * t * t - 2) + b
	end
end

local function outInQuart(t, b, c, d)
	if t < d / 2 then
		return outQuart(t * 2, b, c / 2, d)
	else
		return inQuart((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function inQuint(t, b, c, d)
	t = t / d
	return c * t * t * t * t * t + b
end

local function outQuint(t, b, c, d)
	t = t / d - 1
	return c * (t * t * t * t * t + 1) + b
end

local function inOutQuint(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t * t * t + b
	else
		t = t - 2
		return c / 2 * (t * t * t * t * t + 2) + b
	end
end

local function outInQuint(t, b, c, d)
	if t < d / 2 then
		return outQuint(t * 2, b, c / 2, d)
	else
		return inQuint((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function inSine(t, b, c, d)
	return -c * cos(t / d * (pi / 2)) + c + b
end

local function outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, c, d)
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

local function outInSine(t, b, c, d)
	if t < d / 2 then
		return outSine(t * 2, b, c / 2, d)
	else
		return inSine((t * 2) -d, b + c / 2, c / 2, d)
	end
end

local function inExpo(t, b, c, d)
	if t == 0 then
		return b
	else
		return c * 2 ^ (10 * (t / d - 1)) + b - c * 0.001
	end
end

local function outExpo(t, b, c, d)
	if t == d then
		return b + c
	else
		return c * 1.001 * (-2 ^ (-10 * t / d) + 1) + b
	end
end

local function inOutExpo(t, b, c, d)
	if t == 0 then return b end
	if t == d then return b + c end
	t = t / d * 2
	if t < 1 then
		return c / 2 * 2 ^ (10 * (t - 1)) + b - c * 0.0005
	else
		t = t - 1
		return c / 2 * 1.0005 * (-2 ^ (-10 * t) + 2) + b
	end
end

local function outInExpo(t, b, c, d)
	if t < d / 2 then
		return outExpo(t * 2, b, c / 2, d)
	else
		return inExpo((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function inCirc(t, b, c, d)
	t = t / d
	return(-c * ((1 - t * t) ^ 0.5 - 1) + b)
end

local function outCirc(t, b, c, d)
	t = t / d - 1
	return(c * (1 - t * t) ^ 0.5 + b)
end

local function inOutCirc(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return -c / 2 * ((1 - t * t) ^ 0.5 - 1) + b
	else
		t = t - 2
		return c / 2 * ((1 - t * t) ^ 0.5 + 1) + b
	end
end

local function outInCirc(t, b, c, d)
	if t < d / 2 then
		return outCirc(t * 2, b, c / 2, d)
	else
		return inCirc((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local function inElastic(t, b, c, d, a, p)
	if t == 0 then return b end

	t = t / d

	if t == 1  then return b + c end

	if not p then p = d * 0.3 end

	local s

	if not a or a < abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c/a)
	end

	t = t - 1

	return -(a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

-- a: amplitud
-- p: period
local function outElastic(t, b, c, d, a, p)
	if t == 0 then return b end

	t = t / d

	if t == 1 then return b + c end

	if not p then p = d * 0.3 end

	local s

	if not a or a < abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c/a)
	end

	return a * 2 ^ (-10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

-- p = period
-- a = amplitud
local function inOutElastic(t, b, c, d, a, p)
	if t == 0 then return b end

	t = t / d * 2

	if t == 2 then return b + c end

	if not p then p = d * (0.3 * 1.5) end
	if not a then a = 0 end

	local s

	if not a or a < abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c / a)
	end

	if t < 1 then
		t = t - 1
		return -0.5 * (a * 2 ^ (10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
	else
		t = t - 1
		return a * 2 ^ (-10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
	end
end

-- a: amplitud
-- p: period
local function outInElastic(t, b, c, d, a, p)
	if t < d / 2 then
		return outElastic(t * 2, b, c / 2, d, a, p)
	else
		return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
	end
end

local function inBack(t, b, c, d, s)
	if not s then s = 1.70158 end
	t = t / d
	return c * t * t * ((s + 1) * t - s) + b
end

local function outBack(t, b, c, d, s)
	if not s then s = 1.70158 end
	t = t / d - 1
	return c * (t * t * ((s + 1) * t + s) + 1) + b
end

local function inOutBack(t, b, c, d, s)
	if not s then s = 1.70158 end
	s = s * 1.525
	t = t / d * 2
	if t < 1 then
		return c / 2 * (t * t * ((s + 1) * t - s)) + b
	else
		t = t - 2
		return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
	end
end

local function outInBack(t, b, c, d, s)
	if t < d / 2 then
		return outBack(t * 2, b, c / 2, d, s)
	else
		return inBack((t * 2) - d, b + c / 2, c / 2, d, s)
	end
end

local function outBounce(t, b, c, d)
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

local function inBounce(t, b, c, d)
	return c - outBounce(d - t, 0, c, d) + b
end

local function inOutBounce(t, b, c, d)
	if t < d / 2 then
		return inBounce(t * 2, 0, c, d) * 0.5 + b
	else
		return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
	end
end

local function outInBounce(t, b, c, d)
	if t < d / 2 then
		return outBounce(t * 2, b, c / 2, d)
	else
		return inBounce((t * 2) - d, b + c / 2, c / 2, d)
	end
end

return {
	[Enum.EasingDirection.In.Name] = {
		[Enum.EasingStyle.Linear.Name] = linear;
		[Enum.EasingStyle.Sine.Name] = inSine;
		[Enum.EasingStyle.Back.Name] = inBack;
		[Enum.EasingStyle.Quad.Name] = inQuad;
		[Enum.EasingStyle.Quart.Name] = inQuart;
		[Enum.EasingStyle.Quint.Name] = inQuint;
		[Enum.EasingStyle.Bounce.Name] = inBounce;
		[Enum.EasingStyle.Elastic.Name] = inElastic;
		Expo = inExpo;
		Cubic = inCubic;
		Circ = inCirc;
	};
	[Enum.EasingDirection.Out.Name] = {
		[Enum.EasingStyle.Linear.Name] = linear;
		[Enum.EasingStyle.Sine.Name] = outSine;
		[Enum.EasingStyle.Back.Name] = outBack;
		[Enum.EasingStyle.Quad.Name] = outQuad;
		[Enum.EasingStyle.Quart.Name] = outQuart;
		[Enum.EasingStyle.Quint.Name] = outQuint;
		[Enum.EasingStyle.Bounce.Name] = outBounce;
		[Enum.EasingStyle.Elastic.Name] = outElastic;
		Expo = outExpo;
		Cubic = outCubic;
		Circ = outCirc;
	};
	[Enum.EasingDirection.InOut.Name] = {
		[Enum.EasingStyle.Linear.Name] = linear;
		[Enum.EasingStyle.Sine.Name] = inOutSine;
		[Enum.EasingStyle.Back.Name] = inOutBack;
		[Enum.EasingStyle.Quad.Name] = inOutQuad;
		[Enum.EasingStyle.Quart.Name] = inOutQuart;
		[Enum.EasingStyle.Quint.Name] = inOutQuint;
		[Enum.EasingStyle.Bounce.Name] = inOutBounce;
		[Enum.EasingStyle.Elastic.Name] = inOutElastic;
		Expo = inOutExpo;
		Cubic = inOutCubic;
		Circ = inOutCirc;
	};
	OutIn = {
		[Enum.EasingStyle.Sine.Name] = outInSine;
		[Enum.EasingStyle.Back.Name] = outInBack;
		[Enum.EasingStyle.Quad.Name] = outInQuad;
		[Enum.EasingStyle.Quart.Name] = outInQuart;
		[Enum.EasingStyle.Quint.Name] = outInQuint;
		[Enum.EasingStyle.Bounce.Name] = outInBounce;
		[Enum.EasingStyle.Elastic.Name] = outInElastic;
		Expo = outInExpo;
		Cubic = outInCubic;
		Circ = outInCirc;
	};
}
