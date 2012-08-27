require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require "debug"

Img = Class{inherits=Object, name="Img", function(self, x,y, img, life, scale)
	Object.construct(self, x,y, {img}, nil)
	self.life = life or 1
	self.totallife = life or 1
	self.scale = scale or 10
end}

function Img:update(dt)
	self:Object_update(dt)
	
	local a = self.life / self.totallife
	local s = self.scale*(1-a)
	self:setScale(s)
	self:setAlpha(a*255)
	
	self.life = self.life - dt
	if self.life < 0 then
		self.removeThis = true
	end
end