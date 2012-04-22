require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require "player.lua"
require "debug.lua"

Spike = Class{inherits=Collidable, name="Spike", function(self, x,y)
	Collidable.construct(self, "ninja.png", x,y, 40,25,-10,36)
	self:setAnimation({1})
	self.velocity = 0
	self.gravity = 100
end}

function Spike:colon_with(other, world)
	if other:is_a(Player) then
		print("player")
	end
	return false
end

function Spike:colon_down()
	self.velocity = 0
	self:setPassive()
end

function Spike:update(dt)
	self:Collidable_update(dt)
	self.velocity = self.velocity + dt*self.gravity
	self:move( vector(0,self.velocity*dt) )
end