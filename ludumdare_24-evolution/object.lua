vector = require "hump.vector"
Class = require 'hump.class'
require "tilesets"

FLICKERINTERVAL = 0.05

Object = Class{name="Object", function(self, x,y,indices, timer)
	self.pos = vector(x,y)
	self.img = tilesets:get()
	self._Object_dir = 6
	self.hotspot = vector(self.img.size/2, self.img.size/2)
	self:setAnimation(indices, timer)
	self._Object_animationname = ''
	self._Object_animations = {}
	self._Object_animationtimer = 0
	self._Object_flickertimer = -0.1
	self._Object_flickering = -0.1
	self._Object_scale = 1
	self._Object_alpha = 255
end}

function Object:setScale(s)
	self._Object_scale = s
end

function Object:setAlpha(a)
	self._Object_alpha = a
end

function Object:isFlickering()
	if self._Object_flickertimer > 0 then
		return true
	else
		return false
	end
end

function Object:flicker(t)
	self._Object_flickertimer = t or 1
	self._Object_flickering = FLICKERINTERVAL * 2
end

function Object:Object_draw(world)
	if self._Object_flickertimer < 0 or self._Object_flickering < FLICKERINTERVAL then
		local s = self.img.size
		self.img:draw(self._Object_indices[self._Object_index], self.pos.x+s-self.hotspot.x*self._Object_scale, self.pos.y+s-self.hotspot.y*self._Object_scale, self._Object_dir, self._Object_scale, 0, self._Object_alpha)
	end
end

function Object:draw(world)
	self:Object_draw(world)
end

function Object:addAnimation(name, indices, timer)
	local an = {indices=indices, timer=timer}
	self._Object_animations[name] = an
	return name
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

function Object:changeAnimation(name)
	if self._Object_animationname ~= name then
		local an = self._Object_animations[name]
		assert(an, name .. ' not found')
		self:setAnimation(an.indices, an.timer)
		self._Object_animationname = name
	end
end

function Object:face_right()
	self._Object_dir = 6;
end

function Object:face_left()
	self._Object_dir = 4;
end

function Object:Object_update(dt)
	if self._Object_flickertimer > 0 then
		self._Object_flickertimer = self._Object_flickertimer - dt
	end
	if self._Object_flickering > 0 then
		self._Object_flickering = self._Object_flickering - dt
		if self._Object_flickering <= 0 and self._Object_flickertimer > 0 then
			self._Object_flickering = FLICKERINTERVAL * 2
		end
	end
	self._Object_animationtimer = self._Object_animationtimer + dt
	if self._Object_timer > 0 then
		while self._Object_animationtimer > self._Object_timer do
			self._Object_animationtimer = self._Object_animationtimer - self._Object_timer
			--self._Object_index = self._Object_index + 1
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