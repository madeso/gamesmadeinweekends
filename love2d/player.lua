require "collidable"
Class = require 'hump.class'
vector = require "hump.vector"
require "tilesets"
require "console"
require 'iolib'

function print_r (t, name, indent)
  local tableList = {}
  function table_r (t, name, indent, full)
    local serial=string.len(full) == 0 and name
        or type(name)~="number" and '["'..tostring(name)..'"]' or '['..name..']'
    io.write(indent,serial,' = ') 
    if type(t) == "table" then
      if tableList[t] ~= nil then io.write('{}; -- ',tableList[t],' (self reference)\n')
      else
        tableList[t]=full..serial
        if next(t) then -- Table not empty
          io.write('{\n')
          for key,value in pairs(t) do table_r(value,key,indent..'\t',full..serial) end 
          io.write(indent,'};\n')
        else io.write('{};\n') end
      end
    else io.write(type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"'
                  or tostring(t),';\n') end
  end
  table_r(t,name or '__unnamed__',indent or '','')
end

Player = Class{inherits=Collidable, function(self, camera, x,y)
	Collidable.construct(self, "ninja.png", x,y, 16,16)
	self.speed = 90
	self.velocity = vector(0,0)
	self.camera = camera
	--self.camera.zoom = 3
	
	self.anmove = self:addAnimation('move', {21,22,23,24,25,26}, 0.10)
	self.anidle = self:addAnimation('idle', {1})
end}


function Player:update(dt)
	self:Collidable_update(dt)
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
	if love.keyboard.isDown("up") then
		m = m - vector(0,1)
	end
	if love.keyboard.isDown("down") then
		m = m + vector(0,1)
	end
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