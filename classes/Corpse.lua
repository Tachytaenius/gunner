local class = require("lib.middleclass")
local classes = require("classes")

local assets = require("assets")

local Corpse = class("Corpse", classes.Entity)

function Corpse:initialize(world, x, y, apothem, type, theta, vx, vy)
	classes.Entity.initialize(self, world, x, y, apothem, vx, vy, theta, vtheta)
	self.corpseType = type
	self.isNonSolid = true
	self.isCorpse = true
end

function Corpse:filter(other)
	return other.isBlock and "slide"
end

function Corpse:draw()
	local img = assets.corpses[self.corpseType]
	love.graphics.draw(img, self.position.x, self.position.y, self.angle, 1, 1, img:getWidth()/2, img:getHeight()/2)
end

return Corpse
