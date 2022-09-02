local class = require("lib.middleclass")
local classes = require("classes")

local assets = require("assets")

local Item = class("Item", classes.Entity)

function Item:initialize(world, holder, x, y, apothem, vx, vy, theta, vtheta)
	classes.Entity.initialize(self, world, x, y, apothem, vx, vy, theta, vtheta)
	self.holder = holder
	self.isNonSolid = true
	self.isItem = true
end

function Item:filter(other)
	return other.isBlock and "slide"
end

function Item:draw()
	local img = assets.items[self.class.name]
	love.graphics.draw(img, self.position.x, self.position.y, self.angle, 1, 1, img:getWidth()/2, img:getHeight()/2)
end

function Item:update(dt)
	if self.holder then return end
	classes.Entity.update(self, dt)
end

function Item:toGround()
	assert(self.holder)
	self.position.x, self.position.y = self.holder.position.x, self.holder.position.y
	self.holder.item = nil
	self.world:addEntity(self)
	self.holder = nil
end

return Item
