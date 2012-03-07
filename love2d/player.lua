require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"

Player = Class{inherits=Collidable, function(self, camera, x,y)
	Collidable.construct(self, "ninja.png", x,y, 16,16)
	self.speed = 90
	self.velocity = vector(0,0)
	self.camera = camera
end}


function Player:update(dt)
	self:Collidable_update(dt)
	local m = vector(0,0)
	if love.keyboard.isDown("left") then
		m = m - vector(1,0)
	end
	if love.keyboard.isDown("right") then
		m = m + vector(1,0)
	end
	if love.keyboard.isDown("up") then
		m = m - vector(0,1)
	end
	if love.keyboard.isDown("down") then
		m = m + vector(0,1)
	end
	self:move(m*self.speed*dt)
end

function Player:post_update(dt)
	self.camera.pos = self.pos
end

function Player:onkey(down, key, unicode)
	if down and key == "x" then
		console:print("bang!")
	end
	if down and key == "_l" then
		console:print("zing!")
		local loc = self.camera:worldCoords(love.mouse.getPosition())
		self.col:moveTo( loc.x, loc.y )
	end
end