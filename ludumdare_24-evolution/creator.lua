require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require "player"
require "debug"

Creator = Class{inherits=Object, name="Creator", function(self, x,y)
	Object.construct(self, x,y, {30},nil)
end}

function Creator:draw()
	--return false
end

function Creator:update(dt)
	self:Object_update(dt)
end