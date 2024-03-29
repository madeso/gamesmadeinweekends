require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require "player"
require "debug"

Rat = Class{inherits=Collidable, name="Rat", function(self, x,y)
	Collidable.construct(self, "ninja.png", x,y, 50,45,-6,24)
	self:setAnimation({26, 27, 28, 27}, 0.1)
	self.velocity = 0
	self.gravity = 100
	self.dir = 1
	self.speed = 100
end}

function Rat:colon_with(other, world)
	if other:is_a(Player) then
		return true
	else
		return false
	end
end

function Rat:colon_down()
	self.velocity = 0
end

function Rat:colon_left()
	self.dir = 1
end

function Rat:colon_right()
	self.dir = 0
end

function Rat:update(dt)
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

