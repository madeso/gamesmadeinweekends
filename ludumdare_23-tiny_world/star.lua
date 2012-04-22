require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require "player.lua"
require "debug.lua"

Star = Class{inherits=Collidable, name="Star", function(self, x,y)
	Collidable.construct(self, "ninja.png", x,y, 40,25,-10,36)
	self:deselect()
end}

function Star:colon_with(other, world)
	return false
end

function Star:select()
	self.selected = true
	self:setAnimation({30})
end

function Star:deselect()
	self.selected = false
	self:setAnimation({29})
end

function Star:colon_down()
	self.velocity = 0
end

function Star:update(dt)
	self:Collidable_update(dt)
	self:setPassive()
end