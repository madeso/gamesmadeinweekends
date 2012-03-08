require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"

Box = Class{inherits=Collidable, function(self, x,y, speed)
	Collidable.construct(self, "ninja.png", x,y, 16,16)
	self.speed = speed
	self:setAnimation({70})
end}

function Box:update(dt)
	self:Collidable_update(dt)
	self:move(vector(0,1)*self.speed*dt)
end

function Box:colon_with(other, world)
	return true
end