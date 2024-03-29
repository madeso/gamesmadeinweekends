require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'

Player = Class{inherits=Collidable, function(self, camera, x,y)
	Collidable.construct(self, "ninja.png", x,y, 16,16)
	self.speed = 90
	self.velocity = 0
	self.downt = 0
	self.camera = camera
	--self.camera.zoom = 3
	
	self.anmove = self:addAnimation('move', {21,22,23,24,25,26}, 0.10)
	self.anidle = self:addAnimation('idle', {1})
end}

function Player:colon_down()
	self.downt = 0
	self.velocity = 0
end

function Player:colon_up()
	self.velocity = 0
end

function Player:update(dt)
	self:Collidable_update(dt)
	self.downt = self.downt + dt
	self.velocity = self.velocity + dt*4
	
	--self.camera:rotate(dt)
	local m = vector(0,0)
	local ism = false
	if love.keyboard.isDown("left") then
		m = m - vector(1,0)
		self:face_left()
		ism = true
	end
	if love.keyboard.isDown("right") then
		m = m + vector(1,0)
		self:face_right()
		ism = true
	end
	m = m + vector(0,self.velocity)
	self:move(m*self.speed*dt)
	
	if ism then
		self:changeAnimation(self.anmove)
	else
		self:changeAnimation(self.anidle)
	end
end

function Player:post_update(dt)
	self.camera.pos = self.pos
	--self.camera.pos = self.camera:mousepos() -- mouselook
end

function Player:onkey(down, key, unicode)
	if down and key == "x" then
		console:print("bang!")
	end
	if down and key == "up" then
		if self.downt < 0.1 then
			self.velocity = -2.5
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
		console:print("zing!")
		local loc = self.camera:worldCoords(love.mouse.getPosition())
		self.col:moveTo( loc.x, loc.y )
	end
end