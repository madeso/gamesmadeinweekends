vector = require "hump.vector"
Class = require 'hump.class'
require "tilesets"

Object = Class{function(self, img, x,y,index)
	self.pos = vector(x,y)
	self.img = tilesets:get(img)
	if index ~= nil then
		self.index = index
	else
		self.index = 1
	end
end}

function Object:draw()
	self.img:draw(self.index, self.pos:unpack())
	--love.graphics.draw(self.img, self.pos:unpack())
end

function Object:update(dt)
end

function Object:onkey(down, key, unicode)
end

function Object:enterWorld(word, c)
end