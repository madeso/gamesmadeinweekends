require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'
require 'bullet'
require 'img'

AIRJUMPLIM = 300
AIRJUMPSPEED = 700

Player = Class{inherits=Collidable, function(self, camera, x,y)
	Collidable.construct(self, x,y, 28,64, -14, -2)
	self.speed = 230 + levelSpeed * 50
	self.gravity = 1500
	self.jumpspeed = 800 + levelJump * 100
	self.velocity = 0
	self.downt = 100
	self.camera = camera
	self.hormo = 0
	self.airfriction = 1 + levelAir
	self.groundfriction = 8 + levelGround
	self.BUMP = 1
	self.dead = false
	self.totalairjumps = levelAirJump
	self.airjumpsleft = 0
	self.candash = false
	self.dashtimer = -1
	self.dashtotal = 0.8 + levelDashTime * 0.5
	self.dashspeed = 800 + levelDashSpeed * 200
	self.killpower = -0.01
	self.humptimer = -0.01
	self.health = 3 + levelHealth
	self.spt = -0.1
	
	self.lastsafe = vector(x,y)
	
	self.player = gamePlayer
	local b = self.player * 5
	
	self.anmove = self:addAnimation('move', {b+3,b+4}, 0.15)
	self.anidle = self:addAnimation('idle', {b+2})
	self.anjump = self:addAnimation('jump', {b+3})
	self.anfall = self:addAnimation('fall', {b+4})
	
	self.sndjump = sndjump
	self.sndhump = sndhump
	self.sndlife = sndlife
	self.snddie = snddie
	self.snddash = snddash
	self.sndhurt = sndhurt
	self.snddlaser = snddlaser
	self.sndskunkcharge = sndskunkcharge
	self.sndskunkexplosion = sndskunkexplosion
end}

function Player:colon_down(world)
	self.downt = 0
	self.velocity = 0
end

function Player:colon_up()
	self.velocity = 0
end

function Player:colon_with(other, world)
	if other:is_a(Enemy) then
		if self.dashtimer > 0 then
			self.candash = true
		else
			if self:isFlickering() then
			else
				self:flicker()
				self.candash = true
				playSound(self.sndhurt)
				self.health = self.health - 1
				if self.health <= 0 then
					playSound(self.snddie)
					self.dead = true
				end
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
	
	local onground = false
	local ism = false
	
	if self.killpower > 0 then
		self.killpower = self.killpower - dt
	end
	
	if self.humptimer > 0 then
		self.humptimer = self.humptimer - dt
	end
	
	if self.dashtimer > 0 then
		self.dashtimer = self.dashtimer - dt
		self:move(self.dash * self.dashspeed *dt)
		
		SPT = 0.1
		
		self.spt = self.spt + dt
		if self.spt > SPT then
			self.spt = self.spt - SPT
			--world:add(Img(self.pos.x, self.pos.y, 53 + math.random(5), 1.0, 3))
		end
		
	else
		self.downt = self.downt + dt
		self.velocity = self.velocity + dt*self.gravity
		
		-- mindfuck
		--self.camera.zoom = 1.5 - math.abs(self.velocity) / (self.jumpspeed * 3)
		
		--self.camera:rotate(dt)
		local m = -self.hormo
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
		
		if self.downt < 0.1 then
			onground = true
		end
		
		local friction = self.airfriction
		if onground then
			friction = self.groundfriction
			self.airjumpsleft = self.totalairjumps
			self.lastsafe = self:getPosition()
			self.candash = true
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
	end
	
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
	self.camera.pos.x = self.pos.x
	self.camera.pos.y = math.min(1026-(1024/2)+64*2, self.pos.y)
	
	if self.pos.y > 1180 then
		self.dead = true
		playSound(self.snddie)
	end
end

function Diff(d)
	return d - math.random() * d*2
end

function Player:onkey(down, key, unicode)
	if self.dashtimer > 0 then
		-- nothing
		if down==false and key == "x" then
			self.dashtimer = -1
		end
	else
		if down and key == "z" then
			if self.downt < 0.1 then
				self.velocity = -self.jumpspeed
				playSound(self.sndjump)
			else
				if self.airjumpsleft>0 and self.velocity < AIRJUMPLIM and self.velocity > -AIRJUMPLIM then
					self.velocity = -AIRJUMPSPEED
					playSound(self.sndjump)
					self.airjumpsleft = self.airjumpsleft - 1
				end
			end
		end
		
		if down and key == "x" then
			local dx = 0
			local dy = 0
			if love.keyboard.isDown("right") then
				dx = dx + 1
			end
			if love.keyboard.isDown("left") then
				dx = dx - 1
			end
			if love.keyboard.isDown("up") then
				dy = dy - 1
			end
			if love.keyboard.isDown("down") then
				dy = dy + 1
			end
			
			self.dash = vector(dx,dy)
			if self.dash:len2() > 0.1 then
				if self.candash then
					self.dash:normalize_inplace()
					self.dashtimer = self.dashtotal
					self.candash = false
					self.velocity = 0
					playSound(self.snddash)
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
		
		if down and key == " " then
			local r = 15
			for shape in pairs(world.collider:shapesInRange(self.pos.x-r,self.pos.y-r, self.pos.x+r,self.pos.y+r)) do
				if shape.type and shape.type:is_a(Partner) then
					
					for i=0, 3 do
						world:add(Img(shape.type.pos.x + Diff(60), shape.type.pos.y + Diff(60), 51, 0.3, 6))
					end
					
					self.humptimer = self.humptimer + 1 + levelFertility
					playSound(self.sndhump)
					
					if self.humptimer > 10 then
						playSound(self.sndlife)
						self.humptimer = -0.01
						shape.type.removeThis = true
						gameChildren = gameChildren + 1
					end
				end
			end
		end
		
		if self.player == 2 then
			if down and key == "c" then
				playSound(self.sndskunkcharge)
				self.killpower = self.killpower - 1
				if self.velocity < AIRJUMPLIM and self.velocity > -AIRJUMPLIM then
					self.velocity = -AIRJUMPLIM/2
				end
				if self.killpower <= 0 then
					self.killpower = 30
					playSound(self.sndskunkexplosion)
					bang(self.pos, 300 + levelPower * 100)
				end
			end
		end
		
		if self.player == 0 then
			if down and key == "c" then
				--self.col:moveTo( self.lastsafe.x, self.lastsafe.y )
				local dir = self._Object_dir
				if love.keyboard.isDown("up") then
					dir = 8
				elseif love.keyboard.isDown("down") then
					dir = 2
				end
				local bullet = Bullet(self.pos.x, self.pos.y, dir, 400 + levelPower * 200)
				self._world_ref:add( bullet )
				playSound(self.snddlaser)
			end
		end
	end
end