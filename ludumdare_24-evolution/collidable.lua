require "object"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"

Collidable = Class{name="Collidable", inherits=Object, function(self, x,y,width,height,xadjust,yadjust)
	Object.construct(self, x,y)
	self._width,self._height = width,height
	self._xadjust = xadjust or 0
	self._yadjust = yadjust or self._xadjust
	self._isActive = true
	self._collideWithWorld = true
	print("adjusting: ", self._xadjust, self._yadjust)
end}

function Collidable:enterWorld(world, c)
	self.col = c:addRectangle(self.pos.x,self.pos.y,self._width,self._height)
	self.col.type = self
	self.hardon = c
	if self._isActive ~= true then
		self.hardon:setPassive(self.col)
	end
end

function Collidable:leaveWorld()
	if self.hardon ~= nil then
		self.hardon:remove(self.col)
		self.hardon = nil
		self.col = nil
	end
end

function Collidable:Collidable_draw(world)
	if world.debug_collisons then
		self.col:draw("fill")
	end
	self:Object_draw()
end

function Collidable:draw(world)
	self:Collidable_draw(world)
end

function Collidable:stopWorldCollision()
	self._collideWithWorld = false
end

function iszero(x)
	return math.abs(x) < 0.001
end

function Collidable:_onCollision(other, world, mx, my)
	if other == nil then
		if self._collideWithWorld then
			self.col:move(0, my)
			self.col:move(mx, 0)
			
			if world.horizontal then
				if iszero(mx) then
				else
					if mx > 0 then
						self:colon_left(world)
					else
						self:colon_right(world)
					end
				end
			else
				if iszero(my) then
				else
					if my > 0 then
						self:colon_up(world)
					else
						self:colon_down(world)
					end
				end
			end
		end
	else
		if self:colon_with(other, world, mx, my) then
			self.col:move(0, my)
			self.col:move(mx, 0)
		end
	end
end

function Collidable:colon_with(other, world)
	return true
end

function Collidable:colon_left()
end

function Collidable:setPassive()
	if self.hardon then
		self.hardon:setPassive(self.col)
	end
	self._isActive = false
end

function Collidable:colon_right()
end

function Collidable:colon_down()
end

function Collidable:colon_up()
end

function Collidable:move(xy)
	self._move_x = xy.x
	self._move_y = xy.y
end

function Collidable:_apply_hor()
	self.col:move(vector(self._move_x, 0))
	self._move_x = 0
end

function Collidable:_apply_ver()
	self.col:move(vector(0, self._move_y))
	self._move_y = 0
end

function Collidable:Collidable_update(dt)
	self:Object_update(dt)
	local x,y = self.col:center()
	self._move_x, self._move_y = 0
	self.pos.x, self.pos.y = x-self._width/2+self._xadjust,y-self._height/2-self._yadjust
end

function Collidable:getPosition()
	local x,y = self.col:center()
	return vector(x,y)
end

function Collidable:update(dt)
	self:Collidable_update(dt)
end

function Collidable:post_update(dt)
end

function Collidable:onkey(down, key, unicode)
end