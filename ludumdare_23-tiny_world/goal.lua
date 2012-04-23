require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require "player.lua"
require "debug.lua"

Goal = Class{inherits=Collidable, name="Goal", function(self, x,y,nxt)
	Collidable.construct(self, "ninja.png", x,y, 40,25,-10,36)
	self:setAnimation({25})
	self.next = nxt or "done"
end}

function Goal:colon_with(other, world)
	return false
end

function Goal:update(dt)
	self:Collidable_update(dt)
	self:setPassive()
end