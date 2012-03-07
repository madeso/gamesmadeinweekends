require "object"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"

Player = Class{inherits=Object, function(self, camera, x,y)
	Object.construct(self, "ninja.png", x,y)
	self.speed = 90
	self.velocity = vector(0,0)
	self.camera = camera
end}

function Player:enterWorld(world, c)
	self.col = c:addRectangle(self.pos.x,self.pos.y,16,16)
	self.col.type = self
end

function Player:draw()
	self:Object_draw()
	self.col:draw("fill")
	local mx, my = self.camera:getWorldFromView(love.mouse.getPosition())
	--love.graphics.line(self.pos.x, self.pos.y, mx, my)
end

function Player:onCollision(other, mx, my)
	if other == nil then
		print("adjusting", mx, my)
		self.col:move(mx, 0)
		self.col:move(0, my)
	end
end

function Player:update(dt)
	self.pos.x, self.pos.y = self.col:center()
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
	--self.pos = self.pos + 
	self.col:move(m*self.speed*dt)
	self.camera:target(self.pos:unpack())
end

function Player:onkey(down, key, unicode)
	if down and key == "x" then
		console:print("bang!")
	end
	if down and key == "_l" then
		console:print("zing!")
		self.col:moveTo( self.camera:getWorldFromView(love.mouse.getPosition()) )
	end
end