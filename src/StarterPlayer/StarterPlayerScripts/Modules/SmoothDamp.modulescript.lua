-- Smooth Damp
-- Crazyman32
-- January 30, 2017

--[[
	
	local SmoothDamp = require(this)
	
	smooth = SmoothDamp.new()
	smooth.MaxSpeed
	smooth:Update(currentVector, targetVector, smoothTime)
	smooth:UpdateAngle(currentVector, targetVector, smoothTime)
	
	
	Use UpdateAngle if smoothing out angles. The only difference is that
	it makes sure angles wrap properly (in radians). For instance, if
	damping a rotating wheel, UpdateAngle should be used.
	
	
	-- Example:
	
	local smooth = SmoothDamp.new()
	function Update()
		local current = camera.CFrame.p
		local target = (part.CFrame * CFrame.new(0, 5, -10)).p
		local camPos = smooth:Update(current, target, 0.2)
		camera.CFrame = CFrame.new(camPos, part.Position)
	end
	
--]]

local g=Vector3.new local b=math.max local c=math.pi local e=c*2 local f=tick local d=g().Dot local function a(a,b)local a=((b-a)%e)return(a>c and(a-e)or a)end local function c(b,c)return g(a(b.X,c.X),a(b.Y,c.Y),a(b.Z,c.Z))end local function a(b,a)return(b.magnitude>a and(b.unit*a)or b)end local e={}e.__index=e function e.new()local a=setmetatable({MaxSpeed=math.huge;_update=f();_velocity=g()},e)return a end function e:Update(h,i,k)local m=self._velocity local c=f()local f=(c-self._update)k=b(0.0001,k)local g=(2/k)local b=(g*f)local e=(1/(1+b+0.48*b*b+0.235*b*b*b))local l=(h-i)local j=i local b=(self.MaxSpeed*k)l=a(l,b)i=(h-l)local a=((m+g*l)*f)m=((m-g*a)*e)local a=(i+(l+a)*e)if(d(j-h,a-j)>0)then a=j m=((a-j)/f)end self._velocity=m self._update=c return a end function e:UpdateAngle(d,b,a)return self:Update(d,(d+c(d,b)),a)end return e