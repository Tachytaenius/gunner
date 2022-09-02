local consts = require("consts")

local class = require("lib.middleclass")
local classes = require("classes")

local vec2 = require("lib.vec2")

local Gun = class("Gun", classes.Item)

function Gun:initialize(...)
	classes.Item.initialize(self, ...)
	self.cooldownTimer = 0
end

local function progressTimeWithTimer(curTime, dt, timer)
	assert(curTime <= dt)
	local usableTime = dt - curTime
	local timer2 = math.max(timer - usableTime, 0) -- use usableTime to progress/increase timer, stopping at 0
	local usableTime2 = usableTime - (timer - timer2) -- get new used usable time using change in timer
	local curTime2 = curTime + (usableTime - usableTime2) -- progress current time by how much usable time was used
	assert(timer2 <= timer)
	assert(usableTime2 <= usableTime)
	assert(curTime2 >= curTime)
	assert(curTime2 <= dt)
	return curTime2, timer2
end

local function shortestAngleDist(a, b)
	local da = (b - a) % math.tau
	return 2 * da % math.tau - da
end

local function angleLerp(a, b, i)
	return a + shortestAngleDist(a, b) * i
end

local function numLerp(a, b, i)
	return a + (b - a) * i
end

function Gun:tickFiringMechanism(dt, shoot)
	local curTime = 0
	while curTime < dt do
		curTime, self.cooldownTimer = progressTimeWithTimer(curTime, dt, self.cooldownTimer)
		if self.cooldownTimer == 0 then
			if shoot then
				if not self.auto then
					shoot = false -- only once
				end
				-- shooting is done here
				local curTime = dt - curTime -- HACK: this approach actually kind of messes up with semi-auto weapons as they do jump ahead when they shouldnt. this sort of thing should be done in a whole robust engine designed for it, really...
				local lerp = curTime / dt
				assert(lerp >= 0 and lerp <= 1, lerp)
				local shootPos = numLerp(self.holder.previousPosition, self.holder.position, lerp)
				local shooterVelocity = numLerp(self.holder.previousVelocity, self.holder.velocity, lerp)
				local shootAngle = angleLerp(self.holder.previousAngle, self.holder.angle, lerp) - math.tau / 4
				self.cooldownTimer = self.cooldown
				local aimDir = vec2.rotate(vec2(0, 1), shootAngle)
				for _=1, self.bulletCount do
					local vel = shooterVelocity + aimDir * self.bulletSpeed + vec2.rotate(love.math.random() * vec2.rotate(vec2(1, 0), love.math.random()*math.tau) * vec2(self.bulletSpreadFactorX, self.bulletSpreadFactorY) * self.bulletSpeed, shootAngle)
					local pos = shootPos + vel * (dt - curTime) -- using (dt - curTime) because the earlier the bullet was shot, the more time will have passed by the end of the tick. counterintuitive at first, then very intuitive :p
					local newEntity = classes.Projectile(self.world, self.holder, pos.x, pos.y, vel.x, vel.y, self.bulletDamage, 0.5)
					self.world:addEntity(newEntity)
				end
			else
				break
			end
		end
	end
end

function Gun:update(dt)
	classes.Item.update(self, dt)
	local shoot = false
	if self.holder and self.holder == self.world.playerEntity then
		if self.auto then
			shoot = type(consts.commands.shoot) == "number" and love.mouse.isDown(consts.commands.shoot) or love.keyboard.isDown(consts.commands.shoot)
		else
			shoot = self.world.keypressed[consts.commands.shoot] or self.world.mousepressed[consts.commands.shoot]
		end
	end
	self:tickFiringMechanism(dt, shoot)
end

return Gun
