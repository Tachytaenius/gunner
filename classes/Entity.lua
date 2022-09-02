local class = require("lib.middleclass")
local classes = require("classes")

local vec2 = require("lib.vec2")

local Entity = class("Entity")

function Entity:initialize(world, x, y, apothem, vx, vy, theta, vtheta)
	self.world = world
	-- x and y are at the centre of the entity, apothem is shortest line from the centre to one of the sides
	self.position = vec2(x, y)
	self.apothem = apothem
	self.angle = theta or 0
	self.velocity = vec2(vx, vy)
	self.angularVelocity = vtheta or 0
end

function Entity:toTopLeftXYAndWH()
	local pos, a = self.position, self.apothem
	return pos.x-a, pos.y-a, a*2, a*2
end

function Entity:fromTopLeftXYAndWH(x, y, w, h)
	local a = w and w/2 or self.apothem
	return x+a, y+a, a
end

function Entity:update(dt)
	self.previousAngle = self.angle
	self.angle = (self.angle + self.angularVelocity * dt) % math.tau
	self.previousPosition = self.position
	self.position = self.position + self.velocity * dt
	self.previousVelocity = self.velocity
	local x, y = self:toTopLeftXYAndWH()
	local x, y, cols, len = self.world.bumpWorld:move(self, x, y, self.filter or function(item, other)
		return not other.isNonSolid and "slide"
	end)
	if len ~= 0 and self.hit then
		self:hit(cols[1])
	end
	for _, col in ipairs(cols) do
		if col.normal.x ~= 0 then
			self.velocity.x = 0
		elseif col.normal.y ~= 0 then
			self.velocity.y = 0
		end
	end
	self.position.x, self.position.y = self:fromTopLeftXYAndWH(x, y)
end

function Entity:draw()
	love.graphics.rectangle("line", self:toTopLeftXYAndWH())
	love.graphics.line(self.position.x, self.position.y, self.position.x + self.apothem * math.sqrt(2) * math.cos(self.angle), self.position.y + self.apothem * math.sqrt(2) * math.sin(self.angle))
	love.graphics.line(self.position.x, self.position.y, self.position.x + self.velocity.x * 0.5, self.position.y + self.velocity.y * 0.5)
	love.graphics.circle("line", self.position.x, self.position.y, self.maxSpeed * 0.5)
end

return Entity
