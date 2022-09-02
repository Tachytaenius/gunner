local class = require("lib.middleclass")
local classes = require("classes")

local Blood = class("Blood", classes.Entity)

function Blood:initialize(world, x, y, colour, startSize, endSize, growthRate, growthDelay)
	classes.Entity.initialize(self, world, x, y, 1, 0, 0, 0, 0)
	self.size = startSize or 10
	self.endSize = endSize or self.size
	self.growthRate = growthRate or 1
	self.timeUntilGrow = growthDelay or 0
	self.isNonSolid = true
	self.isDecal = true
	self.colour = colour
end

function Blood:filter(other)
	return false
end

local function takeFromDt(dt, timer)
	local timer2 = math.max(timer - dt, 0)
	local dt2 = dt - (timer - timer2)
	assert(timer2 <= timer)
	assert(dt2 <= dt)
	return dt2, timer2
end

function Blood:update(dt)
	dt, self.timeUntilGrow = takeFromDt(dt, self.timeUntilGrow)
	if self.timeUntilGrow > 0 then return end
	self.size = math.min(self.size + self.growthRate * dt, self.endSize)
end

function Blood:draw()
	if self.colour then love.graphics.setColor(self.colour) end
	love.graphics.circle("fill", self.position.x, self.position.y, self.size)
	love.graphics.setColor(1, 1, 1)
end

return Blood
