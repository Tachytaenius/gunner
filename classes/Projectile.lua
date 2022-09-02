local class = require("lib.middleclass")
local classes = require("classes")

local vec2 = require("lib.vec2")

local Projectile = class("Projectile", classes.Entity)

function Projectile:initialize(world, shooter, x, y, vx, vy, damage, apothem, theta, vtheta)
	apothem = apothem or 1
	classes.Entity.initialize(self, world, x, y, apothem, vx, vy, theta, vtheta)
	self.shooter = shooter
	self.damage = damage or 10
	self.isProjectile = true
	self.isNonSolid = true
end

function Projectile:draw()
	-- local img = assets.projectile[self.class.name]
	-- love.graphics.draw(img, self.position.x, self.position.y, self.angle, 1, 1, img:getWidth()/2, img:getHeight()/2)
	love.graphics.setColor(0, 0, 0)
	-- love.graphics.circle("fill", self.position.x, self.position.y, self.apothem)
	love.graphics.setColor(1, 1, 1)
	
	-- HACK: didn't bother to derive the maths dont mind messy code blah blah. in my next perfectionist project with this feature it'll be different
	love.graphics.push("all")
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(self.apothem * 2)
	local prevDrawPos = self.previousPosition - self.world.cameraEntity.previousPosition + vec2(love.graphics.getDimensions())/2
	local thisDrawPos = self.position - self.world.cameraEntity.position + vec2(love.graphics.getDimensions())/2
	local t = self.timeWhenHitDuringTick or 1
	thisDrawPos = prevDrawPos * (1 - t) + thisDrawPos * t
	love.graphics.origin()
	love.graphics.line(prevDrawPos.x, prevDrawPos.y, thisDrawPos.x, thisDrawPos.y)
	love.graphics.pop()
end

function Projectile:filter(other)
	if self.hitAABB then return false end
	if other == self.shooter then return false end
	if other.isNonSolid then return false end
	
	return "cross"
end

function Projectile:hit(col)
	if col.other.takeDamage then col.other:takeDamage(self.damage) end
	self.world:removeEntity(self)
	self.hitAABB = true
	self.timeWhenHitDuringTick = col.ti
end

return Projectile
