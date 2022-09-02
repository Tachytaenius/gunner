local class = require("lib.middleclass")
local classes = require("classes")
local quadreasonable = require("lib.quadreasonable")

local assets = require("assets")
local consts = require("consts")
local vec2 = require("lib.vec2")

local Actor = class("Actor", classes.Entity)

function Actor:initialize(world, x, y, apothem, vx, vy, theta, vtheta, acceleration, maxSpeed, friction, walkCycleSpeed, walkCycleStages, walkCyclePos, spriteWidth, spriteHeight, poses, maxHealth, health, angularAcceleration, maxAngularSpeed, angularFriction)
	classes.Entity.initialize(self, world, x, y, apothem, vx, vy, theta, vtheta)
	self.acceleration = acceleration
	self.maxSpeed = maxSpeed
	self.friction = friction
	self.walkCycleSpeed = walkCycleSpeed or 1 -- frequency of walk cycle repeating at full speed
	self.walkCycleStages = walkCycleStages or 1
	self.spritesheetWidth = self.walkCycleStages
	self.spriteWidth = spriteWidth or self.apothem * 2
	self.spriteHeight = spriteHeight or self.apothem * 2
	self.walkCyclePos = walkCyclePos or 0
	self.angularAcceleration = angularAcceleration
	self.maxAngularSpeed = maxAngularSpeed
	self.angularFriction = angularFriction
	self.poses = poses or 1
	self.maxHealth = maxHealth
	self.health = health or maxHealth
	
	self.bloodColour = {0.8, 0.1, 0.1}
end

function Actor:die(corpseType)
	if self.dead then return end
	self.dead = true
	self.world:removeEntity(self)
	self.world:addEntity(classes.Blood(self.world, self.position.x, self.position.y, self.bloodColour, 4 + love.math.random() * 2, 10 + love.math.random() * 5, 1 + love.math.random() * 2, 0.5 + love.math.random()))
	self.world:addEntity(classes.Corpse(self.world, self.position.x, self.position.y, self.apothem, corpseType, self.angle, self.velocity.x, self.velocity.y))
	if self.item then
		self.item:toGround()
	end
end

function Actor:getCorpseType(damage)
	return self.class.name .. "Corpse"
end

function Actor:takeDamage(damage)
	self.health = self.health - damage
	if self.health <= 0 then
		self:die(self:getCorpseType(damage))
	end
end

function Actor:update(dt)
	if self.dead then return end
	
	if #self.velocity > 0 then
		local newMagnitude = math.max(#self.velocity - self.friction * dt, 0)
		self.velocity = vec2.normalise(self.velocity) * newMagnitude
	end
	self.angularVelocity = math.sign(self.angularVelocity) * math.max(math.abs(self.angularVelocity) - self.angularFriction * dt, 0)
	
	if self == self.world.playerEntity then
		if self.world.keypressed[consts.commands.shoot] or self.world.mousepressed[consts.commands.shoot] then
			if self.item and self.item.onUse then
				self.item:onUse()
			end
		end
		if type(consts.commands.shoot) == "number" and love.mouse.isDown(consts.commands.shoot) or love.keyboard.isDown(consts.commands.shoot) then
			if self.item and self.item.onUseHeld then
				self.item:onUseHeld()
			end
		end
		local move = vec2()
		if love.keyboard.isDown(consts.commands.left) then
			move.x = move.x - 1
		end
		if love.keyboard.isDown(consts.commands.right) then
			move.x = move.x + 1
		end
		if love.keyboard.isDown(consts.commands.up) then
			move.y = move.y - 1
		end
		if love.keyboard.isDown(consts.commands.down) then
			move.y = move.y + 1
		end
		-- move = vec2.rotate(move, self.angle)
		self.velocity = self.velocity + (move * self.acceleration * dt)
		-- local angularMove = 0
		-- if love.keyboard.isDown(",") then
			-- angularMove = angularMove - 1
		-- end
		-- if love.keyboard.isDown(".") then
			-- angularMove = angularMove + 1
		-- end
		-- self.angularVelocity = self.angularVelocity + (angularMove * self.angularAcceleration * dt)
		self.angle = math.atan2(self.world.cursorY - love.graphics.getWidth() / 2, self.world.cursorX - love.graphics.getHeight() / 2)
	end
	if self.item then
		self.item:update(dt)
	end
	if #self.velocity > 0 then
		if #self.velocity > self.maxSpeed then
			self.velocity = vec2.normalise(self.velocity) * self.maxSpeed
		end
	end
	self.angularVelocity = math.sign(self.angularVelocity) * math.min(math.abs(self.angularVelocity), self.maxAngularSpeed)
	classes.Entity.update(self, dt)
	
	if #self.velocity == 0 then
		self.walkCyclePos = 0
	else
		self.walkCyclePos = (self.walkCyclePos + #self.velocity / self.maxSpeed * self.walkCycleSpeed * dt) % 1
	end
	self.poseNumber = 0
end

function Actor:getSpritesheetColumn() -- x
	return math.floor(self.walkCyclePos * self.walkCycleStages)
end

function Actor:getSpritesheetRow() -- y
	return self.poseNumber
end

function Actor:draw()
	if self.dead then return end
	local quad = quadreasonable.getQuad(self:getSpritesheetColumn(), self:getSpritesheetRow(), self.walkCycleStages, self.poses, self.spriteWidth, self.spriteHeight, consts.spritePadding)
	love.graphics.draw(assets.actors[self.class.name], quad, self.position.x, self.position.y, self.angle, 1, 1, self.spriteWidth / 2, self.spriteHeight / 2)
end

return Actor
