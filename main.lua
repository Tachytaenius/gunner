require("monkeypatch")
local bump = require("lib.bump")
local class = require("lib.middleclass")
local classes = require("classes")
local list = require("lib.list")
local vec2 = require("lib.vec2")
local consts = require("consts")

local world

function love.load(arg)
	love.graphics.setLineStyle("rough")
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	love.mouse.setGrabbed(true)
	
	world = classes.World("testworld")
end

local cursorX, cursorY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2

function love.update(dt)
	love.mouse.setVisible(not love.mouse.isGrabbed())
	if love.mouse.isGrabbed() then
		cursorX, cursorY = love.mouse.getPosition()
	end
	world.cursorX, world.cursorY = cursorX, cursorY
	world:update(dt)
end

function love.draw()
	world:draw()
end

local pauseHeld

function love.keypressed(key)
	if key == consts.commands.pause then
		if not world.paused then
			world.paused = true
			pauseHeld = true
		end
	else
		world.keypressed[key] = true
	end
end

function love.keyreleased(key)
	if key == consts.commands.pause then
		if pauseHeld then
			pauseHeld = false
		else
			if world.paused then
				world.paused = false
			end
		end
	elseif key == consts.commands.toggleMouseGrab then
		love.mouse.setGrabbed(not love.mouse.isGrabbed())
	else
		world.keyreleased[key] = true
	end
end

function love.mousepressed(x, y, button)
	if not love.mouse.isGrabbed() then
		love.mouse.setGrabbed(true)
		return
	end
	world.mousepressed[button] = true
end

function love.mousereleased(x, y, button)
	world.mousereleased[button] = true
end
