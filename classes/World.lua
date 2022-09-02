local consts = require("consts")
local assets = require("assets")

local classes = require("classes")
local class = require("lib.middleclass")

local json = require("lib.json")
local list = require("lib.list")
local bump = require("lib.bump")
local vec2 = require("lib.vec2")

local World = class("World")

function World:initialize(levelPath)
	self.entities = list()
	self.bumpWorld = bump.newWorld()
	-- self.cameraEntity, self.playerEntity = nil, nil
	local levelData = json.decode(love.filesystem.read("assets/levels/" .. levelPath .. "/levelData.json"))
	
	self.environmentBlocks = {} -- level geometry
	for i, v in ipairs(levelData.environmentBlocks) do
		self.environmentBlocks[i] = {isBlock = true, x = v[1], y = v[2], w = v[3], h = v[4]}
		self.bumpWorld:add(self.environmentBlocks[i], unpack(v))
	end
	
	self.megatextures = {} -- level graphics
	self.megatextureOffsetX, self.megatextureOffsetY = levelData.megatextureOffsetX, levelData.megatextureOffsetY
	self.numMegatexturesHorizontal, self.numMegatexturesVertical = levelData.numMegatexturesHorizontal, levelData.numMegatexturesVertical
	for x = 0, self.numMegatexturesHorizontal - 1 do
		local megatexturesX = {}
		self.megatextures[x] = megatexturesX
		for y = 0, self.numMegatexturesVertical - 1 do
			local megatexturesXY = {}
			megatexturesX[y] = megatexturesXY
			local path = "assets/levels/" .. levelPath .. "/megatextures/" .. x .. "," .. y .. "bg.png"
			if love.filesystem.getInfo(path) then
				megatexturesXY.background = love.graphics.newImage(path)
			end
			local path = "assets/levels/" .. levelPath .. "/megatextures/" .. x .. "," .. y .. "fg.png"
			if love.filesystem.getInfo(path) then
				megatexturesXY.foreground = love.graphics.newImage(path)
			end
			megatexturesXY.drawX = self.megatextureOffsetX + x * consts.megatextureSize
			megatexturesXY.drawY = self.megatextureOffsetY + y * consts.megatextureSize
		end
	end
	
	local player = classes.Player(self, levelData.startPosX, levelData.startPosY, levelData.startAngle or 0)
	self:addEntity(player)
	self:setPlayer(player)
	self:setCamera(player)
	
	for _=1, 100 do
		self:addEntity(classes.Player(self, love.math.random() * 2048, love.math.random() * 2048, love.math.random() * math.tau))
	end
	
	self.mousepressed = {}
	self.mousereleased = {}
	self.keypressed = {}
	self.keyreleased = {}
	self.entitiesToRemove = {}
	
	self.canvas = love.graphics.newCanvas(consts.gameWidth, consts.gameHeight)
	
	self.paused = false
end

function World:update(dt)
	if self.paused then return end
	
	for _,entity in ipairs(self.entitiesToRemove) do
		-- doing it here (after draw) allows fast projectiles that hit walls to look right
		self.entities:remove(entity)
		self.bumpWorld:remove(entity)
	end
	self.entitiesToRemove = {}
	
	for entity in self.entities:elements() do
		entity:update(dt)
	end
	self.mousepressed = {}
	self.mousereleased = {}
	self.keypressed = {}
	self.keyreleased = {}
end

function World:draw()
	if not self.cameraEntity then return end
	love.graphics.setCanvas({self.canvas, stencil = true})
	love.graphics.clear()
	love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
	-- love.graphics.rotate(-self.cameraEntity.angle)
	love.graphics.translate(-self.cameraEntity.position.x, -self.cameraEntity.position.y)
	
	local x = self.cameraEntity.position.x - self.megatextureOffsetX
	local y = self.cameraEntity.position.y - self.megatextureOffsetY
	local x = math.floor(x / consts.megatextureSize)
	local y = math.floor(y / consts.megatextureSize)
	local function try(x, y)
		if self.megatextures[x] then
			if self.megatextures[x][y] then
				return self.megatextures[x][y]
			end
		end
	end
	local megatextureSetsToDraw = {try(x-1, y-1), try(x-1, y), try(x-1, y+1), try(x, y-1), try(x, y), try(x, y+1), try(x+1, y-1), try(x+1, y), try(x+1, y+1)} -- doing pairs so nils don't matter
	
	for _, v in pairs(megatextureSetsToDraw) do
		if v.background then love.graphics.draw(v.background, v.drawX, v.drawY) end
	end
	local layers = {{}, {}, {}, {}}
	for entity in self.entities:elements() do
		if entity.isDecal then
			layers[1][#layers[1]+1] = entity
		elseif entity.isCorpse then
			layers[2][#layers[2]+1] = entity
		elseif entity.isItem then
			layers[3][#layers[3]+1] = entity
		else
			layers[4][#layers[4]+1] = entity
		end
	end
	love.graphics.stencil(function()
		for _,block in ipairs(self.environmentBlocks) do
			love.graphics.rectangle("fill", block.x, block.y, block.w, block.h)
		end
	end)
	love.graphics.setStencilTest("notequal", 1)
	for _,entity in ipairs(layers[1]) do
		entity:draw()
	end
	love.graphics.setStencilTest()
	for i=2,#layers do for _,entity in ipairs(layers[i]) do entity:draw() end end
	
	for _, v in pairs(megatextureSetsToDraw) do
		if v.foreground then love.graphics.draw(v.background, v.drawX, v.drawY) end
	end
	
	love.graphics.origin()
	love.graphics.draw(assets.ui.aimer, self.cursorX - assets.ui.aimer:getWidth() / 2, self.cursorY - assets.ui.aimer:getHeight() / 2)
	love.graphics.setCanvas()
	love.graphics.draw(self.canvas)
end

function World:addEntity(entity)
	assert(not self.entities:has(entity))
	self.entities:add(entity)
	self.bumpWorld:add(entity, entity:toTopLeftXYAndWH())
end

function World:removeEntity(entity)
	assert(self.entities:has(entity))
	self.entitiesToRemove[#self.entitiesToRemove + 1] = entity
end

function World:setCamera(entity)
	assert(self.entities:has(entity))
	self.cameraEntity = entity
end

function World:setPlayer(entity)
	assert(self.entities:has(entity))
	self.playerEntity = entity
end

return World
