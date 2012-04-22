require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'

Player = Class{inherits=Collidable, function(self, camera, x,y)
	Collidable.construct(self, "ninja.png", x,y, 28,64, -14, -2)
	self.speed = 230
	self.gravity = 900
	self.jumpspeed = 343
	self.velocity = 0
	self.downt = 0
	self.camera = camera
	self.hormo = 0
	self.airfriction = 1
	self.groundfriction = 8
	self.BUMP = 1
	self.star = nil
	
	self.lastsafex = x
	self.lastsafey = y
	
	self.anmove = self:addAnimation('move', {3,2,4,2}, 0.15)
	self.anidle = self:addAnimation('idle', {2})
	self.anjump = self:addAnimation('jump', {3})
	self.anfall = self:addAnimation('fall', {4})
	
	self.sndjump = sfx("jump.wav")
	self.sndsuperjump = sfx("superjump.wav")
	self.sndpush = sfx("push.wav")
	self.snddie = sfx("die.wav")
	self.sndstar = sfx("star.wav")
end}

function Player:colon_down(world)
	self.downt = 0
	self.velocity = 0
end

function Player:colon_up()
	self.velocity = 0
end

function Player:colon_with(other, world)
	if other:is_a(Star) then
		if other.selected then
		else
			self.lastsafex = self.pos.x
			self.lastsafey = self.pos.y
			if self.star ~= nil then
				self.star:deselect()
			end
			self.star = other
			self.star:select()
			playSound(self.sndstar)
		end
	end
	if other:is_a(Spike) then
		self.col:moveTo( self.lastsafex, self.lastsafey )
		playSound(self.snddie)
		self.hormo = 0
		self.velocity = 0
	end
	if other:is_a(Rat) then
		if self.velocity > 0 then
			self.velocity = -self.jumpspeed*2
			playSound(self.sndsuperjump)
		else
			if other.pos.x > self.pos.x then
				self.hormo = -self.BUMP
				playSound(self.sndpush)
			else
				self.hormo = self.BUMP
				playSound(self.sndpush)
			end
		end
	end
	return false
end

function Player:draw(world)
	self:Collidable_draw(world)
end

function Player:test(world)
	local x,y = self.pos.x, self.pos.y
	if world:isFree(x-15,y+35)==false and world:isFree(x+47,y+35)==false then
		--print("ok")
		return true
	else
		--print("not ok")
		return false
	end
end

function Player:update(dt)
	self:Collidable_update(dt)
	self.downt = self.downt + dt
	self.velocity = self.velocity + dt*self.gravity
	
	-- mindfuck
	--self.camera.zoom = 1.5 - math.abs(self.velocity) / (self.jumpspeed * 3)
	
	--self.camera:rotate(dt)
	local m = -self.hormo
	local ism = false
	if love.keyboard.isDown("left") and love.keyboard.isDown("right") then
	else	
		if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
			m = -1
			self:face_left()
			ism = true
		end
		if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
			m = 1
			self:face_right()
			ism = true
		end
	end
	
	local onground = false
	if self.downt < 0.1 then
		onground = true
	end
	
	local friction = self.airfriction
	if onground then
		friction = self.groundfriction
	end
	
	self.hormo = self.hormo + m * dt * friction
	if self.hormo > 1 then
		self.hormo = 1
	end
	if self.hormo < -1 then
		self.hormo = -1
	end
	
	local moves = vector(self.hormo,0) * self.speed + vector(0,self.velocity)
	self:move(moves*dt)
	
	if onground then
		if ism then
			self:changeAnimation(self.anmove)
		else
			self:changeAnimation(self.anidle)
		end
	else
		if self.velocity > 0 then
			self:changeAnimation(self.anfall)
		else
			self:changeAnimation(self.anjump)
		end
	end
end

function Player:post_update(dt)
	self.camera.pos = self.pos
	--self.camera.pos = self.camera:mousepos() -- mouselook
end

function Player:onkey(down, key, unicode)
	if down then
		if key == "up" or key == "x" or key=="w" or key==" " then
			if self.downt < 0.1 then
				self.velocity = -self.jumpspeed
				playSound(self.sndjump)
			end
		end
	end
	if down and key == "s" then
		local file = {}
		file.pos = {}
		file.pos.x = self.pos.x
		file.pos.y = self.pos.y
		iolib.save(file, 'save')
		console:print("saved to: " .. love.filesystem.getSaveDirectory())
	end
	if down and key=="l" then
		local save, ok = iolib.load('save')
		if ok then
			self.col:moveTo(save.pos.x, save.pos.y)
		end
	end
	if down and key == "_l" then
		local loc = self.camera:worldCoords(love.mouse.getPosition())
		self.col:moveTo( loc.x, loc.y )
	end
end