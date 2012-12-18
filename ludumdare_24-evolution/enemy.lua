require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require "player"
require "debug"
require "text"
require "bomb"

Enemy = Class{inherits=Collidable, name="Enemy", function(self, x,y)
	Collidable.construct(self, x,y, 64,64,0,0)
	--self:setAnimation({26, 27, 28, 27}, 0.1)
	self:setAnimation({40 + math.random(5)},nil)
	--self:stopWorldCollision()
	self:setPassive()
	self.type = math.random(4)
	self.m = vector(0,0)
	self.uptimer = math.random()
	self.hasbomb = false
	if math.random() > 0.7 then
		self.hasbomb = true
	end
end}

function Enemy:colon_with(other, world)
	if other:is_a(Bullet) then
		self:kill()
		return false
	end
	if other:is_a(Player) then
		if other.dashtimer > 0 then
			self:kill()
		end
		return false
	else
		return false
	end
end

function Enemy:kill()
	if self.removeThis then
	else
		world:add(Img(self.pos.x + Diff(60), self.pos.y + Diff(60), 52, 0.40, 5))
		
		local ratpower = 0
		if theplayer.player == 1 then
			ratpower = (levelPower+1) *20
		end
		local extra = self.type*(100 + ratpower + levelEvolution*30) * gameWave
		
		world:add(Text(self.pos.x, self.pos.y, tostring(extra), 1, 15))
		self.removeThis = true
		playSound(sndScore)
		gameEvolution = gameEvolution + extra
		if self.hasbomb then
			world:add(Bomb(self.pos.x, self.pos.y))
		end
	end
end

function Enemy:update(dt)
	self:Collidable_update(dt)
	
	local up = false
	
	if self.type == 3 then
		self.uptimer = self.uptimer - dt
		if self.uptimer <= 0 then
			self.uptimer = 0.2 + 3*math.random()
			up = true
		end
	else
		up = true
	end
	
	if up and theplayer ~= nil then
		self.m = theplayer.pos - self.pos
		self.m = self.m:normalized()
	end
	
	if self.m.x > 0 then
		self:face_right()
	else
		self:face_left()
	end
	local speed = 50
	if self.type == 2 then
		speed = 100
	end
	if self.type == 3 then
		speed = 200
	end
	if self.type == 4 then
		speed = 250
	end
	
	if self.hasbomb then
		speed = speed * 0.75
	end
	
	self:move( self.m*speed*dt )
end

