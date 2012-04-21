require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require "player.lua"
require "debug.lua"

Star = Class{inherits=Collidable, name="Star", function(self, x,y)
	Collidable.construct(self, "ninja.png", x,y, 16,16)
	self:setAnimation({18})
end}

function Star:colon_with(other, world)
	if other:is_a(Player) then
		print("player")
	end
	return true
end