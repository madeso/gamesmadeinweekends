require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require "player"
require "debug"

Partner = Class{inherits=Collidable, name="Partner", function(self, x,y)
	Collidable.construct(self, x,y, 28,64, -14, -2)
	local player = math.random(0,2)
	local b = player * 5
	self:setAnimation({b+3,b+4}, 0.1)
	self.velocity = 0
	self.gravity = 100
	self.dir = math.random(2)-1
	self.speed = 50
end}

function Partner:colon_with(other, world)
	return false
end

function Partner:colon_down()
	self.velocity = 0
end

function Partner:colon_left()
	self.dir = 1
end

function Partner:colon_right()
	self.dir = 0
end

function Partner:update(dt)
	self:Collidable_update(dt)
	self.velocity = self.velocity + dt*self.gravity
	local m = 0
	if self.dir == 1 then
		m = 1
		self:face_right()
	else
		m = -1
		self:face_left()
	end
	self:move( vector(m*self.speed*dt,self.velocity*dt) )
end

