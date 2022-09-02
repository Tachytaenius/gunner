local class = require("lib.middleclass")
local classes = require("classes")

local Pistol = class("Pistol", classes.Gun)

function Pistol:initialize(world, holder, x, y, apothem, vx, vy, theta, vtheta)
	classes.Gun.initialize(self, world, holder, x, y, 5, vx, vy, theta, vtheta)
	self.bulletDamage, self.bulletCount = 100, 1
	self.bulletSpeed, self.bulletSpreadFactorX, self.bulletSpreadFactorY = 1000, 0.05, 0.05
	self.auto = true
	self.cooldown = 0.1
end

return Pistol
