vector = require "hump.vector"
Class = require 'hump.class'
require "tilesets"

Object = Class{function(self, img, x,y,index)
	self.pos = vector(x,y)
	self.img = tilesets:get(img)
	self._Object_dir = 6
	if index ~= nil then
		self.index = index
	else
		self.index = 1
	end
end}

function Object:Object_draw(world)
	self.img:draw(self.index, self.pos.x, self.pos.y, self._Object_dir)
	--love.graphics.draw(self.img, self.pos:unpack())
end

function Object:draw(world)
	self:Object_draw(world)
end

function Object:face_right()
	self._Object_dir = 6;
end

function Object:face_left()
	self._Object_dir = 4;
end

function Object:update(dt)
end

function Object:onkey(down, key, unicode)
end

function Object:enterWorld(word, c)
end

function Object:post_update(dt)
end

function Object:_apply_hor()
end

function Object:_apply_ver()
end