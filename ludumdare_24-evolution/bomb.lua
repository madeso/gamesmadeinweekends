require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require "player"
require "debug"

Bomb = Class{inherits=Object, name="Bomb", function(self, x,y)
	Object.construct(self, x,y, {46,47,48},0.1)
	self.time = 3	+ math.random() * 2
end}

function Bomb:update(dt)
	self:Object_update(dt)
	self.time = self.time - dt
	if self.time < 0 then
		bang(self.pos, 300)
		self.removeThis = true
		playSound(sndBang)
	end
end