require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require "player"
require "debug"

Text = Class{inherits=Object, name="Text", function(self, x,y, text, life, scale)
	Object.construct(self, x,y, {30},nil)
	self.text = text
	self.life = life or 1
	self.totallife = life or 1
	self.hwidth = love.graphics.getFont():getWidth(text) / 2
	self.hheight = love.graphics.getFont():getHeight() / 2
	self.scale = scale or 10
end}

function Text:draw(world)
	local a = self.life / self.totallife
	local s = self.scale*(1-a)
	love.graphics.setColor(0,0,0, a*255)
	love.graphics.print(self.text, self.pos.x-self.hwidth*s, self.pos.y-self.hheight*s, 0, s, s)
	love.graphics.setColor(255,255,255,255)
	--love.graphics.printf( text, x, y, limit, align )
end

function Text:update(dt)
	self:Object_update(dt)
	self.life = self.life - dt
	if self.life < 0 then
		self.removeThis = true
	end
end