require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require "debug"

Bullet = Class{inherits=Collidable, name="Bullet", function(self, x,y, adir,speed)
	Collidable.construct(self, x,y, 50,45,-6,24)
	self:setAnimation({49 + math.random(0,1)}, 0.1)
	self.dir = adir
	self.speed = speed
end}

function Bullet:colon_with(other, world)
	if other:is_a(Enemy) then
		self.removeThis = true
	end
	return false
end

function Bullet:colon_down()
	self.removeThis = true
end

function Bullet:colon_left()
	self.removeThis = true
end

function Bullet:colon_right()
	self.removeThis = true
end

function Bullet:colon_up()
	self.removeThis = true
end

function Bullet:update(dt)
	self:Collidable_update(dt)
	
	if self.pos.x > theplayer.pos.x+800 or self.pos.x<theplayer.pos.x-800 or self.pos.y > theplayer.pos.y+800 or self.pos.y < theplayer.pos.y-800 then
		self.removeThis = true
		print("removed item")
	end
	
	local m = 0
	local dy = 0
	if self.dir == 8 then
		dy = -1
	elseif self.dir == 2 then
		dy = 1
	elseif self.dir == 6 then
		m = 1
		self:face_right()
	else
		m = -1
		self:face_left()
	end
	self:move( vector(m*self.speed*dt,dy*self.speed*dt) )
end

