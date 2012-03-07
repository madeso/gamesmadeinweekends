require "object"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"

Collidable = Class{inherits=Object, function(self, texture, x,y,width,height)
	Object.construct(self, texture, x,y)
	self._width,self._height = width,height
end}

function Collidable:enterWorld(world, c)
	self.col = c:addRectangle(self.pos.x,self.pos.y,self._width,self._height)
	self.col.type = self
end

function Collidable:Collidable_draw(world)
	self:Object_draw()
	if world.debug_collisons then
		self.col:draw("fill")
	end
end

function Collidable:draw(world)
	self:Collidable_draw(world)
end

function Collidable:onCollision(other, mx, my)
	if other == nil then
		self.col:move(0, my)
		self.col:move(mx, 0)
	end
end

function Collidable:move(xy)
	self._move_x = xy.x
	self._move_y = xy.y
end

function Collidable:_apply_hor()
	self.col:move(vector(self._move_x, 0))
end

function Collidable:_apply_ver()
	self.col:move(vector(0, self._move_y))
end

function Collidable:Collidable_update(dt)
	local x,y = self.col:center()
	self.pos.x, self.pos.y = x-self._width/2,y-self._height/2
end

function Collidable:update(dt)
	self:Collidable_update()
end

function Collidable:post_update(dt)
end

function Collidable:onkey(down, key, unicode)
end