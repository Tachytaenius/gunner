local class = require("lib.middleclass")
local classes = require("classes")

local Player = class("Player", classes.Actor)

Player.static.apothem = 11
-- acceleration has to fight friction every frame
Player.static.acceleration = 2000
Player.static.maxSpeed = 500
Player.static.friction = 1000
Player.static.angularAcceleration = 120
Player.static.maxAngularSpeed = math.tau
Player.static.angularFriction = 60
Player.static.walkCycleSpeed = 2
Player.static.walkCycleStages = 8
Player.static.spriteWidth = 32
Player.static.spriteHeight = 32
Player.static.poses = 2
Player.static.maxHealth = 100
Player.static.poseTable = {Pistol = 1}

function Player:initialize(world, x, y, theta, health, walkCyclePos, vx, vy, vtheta)
	classes.Actor.initialize(self, world, x, y, Player.static.apothem, vx, vy, theta, vtheta, Player.static.acceleration, Player.static.maxSpeed, Player.static.friction, Player.static.walkCycleSpeed, Player.static.walkCycleStages, walkCyclePos, Player.static.spriteWidth, Player.static.spriteHeight, Player.static.poses, Player.static.maxHealth, health, walkCyclePos, Player.static.angularAcceleration, Player.static.maxAngularSpeed, Player.static.angularFriction)
	self.item = classes.Pistol(self.world, self)
end

function Player:update(dt)
	classes.Actor.update(self, dt)
	self.poseNumber = self.item and Player.static.poseTable[self.item.class.name] or 0
end

return Player
