vector = require "hump.vector"
Class = require 'hump.class'
require "tilesets"

Object = Class{function(self, img, x,y,indices, timer)
	self.pos = vector(x,y)
	self.img = tilesets:get(img)
	self._Object_dir = 6
	self:setAnimation(indices, timer)
end}

function Object:Object_draw(world)
	self.img:draw(self._Object_indices[self._Object_index], self.pos.x, self.pos.y, self._Object_dir)
	--love.graphics.draw(self.img, self.pos:unpack())
end

function Object:draw(world)
	self:Object_draw(world)
end

function Object:setAnimation(indices, timer)
	self._Object_animationtimer = 0
	
	if indices  ~= nil then
		self._Object_indices = indices
	else
		self._Object_indices = {1}
	end
	
	self._Object_index = 1
	if timer  ~= nil then
		self._Object_timer = timer
	else
		self._Object_timer = -1
	end
end

function Object:face_right()
	self._Object_dir = 6;
end

function Object:face_left()
	self._Object_dir = 4;
end

function Object:Object_update(dt)
	self._Object_animationtimer = self._Object_animationtimer + dt
	if self._Object_timer > 0 then
		while self._Object_animationtimer > self._Object_timer do
			self._Object_animationtimer = self._Object_animationtimer - self._Object_timer
			self._Object_index = self._Object_index + 1
			self._Object_index = (self._Object_index % #self._Object_indices)+1
		end
	end
end

function Object:update(dt)
	self:Object_update(dt)
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