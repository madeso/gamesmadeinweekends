require "oo"
require "object"
vector = require "hump/vector"
require "tilesets"


class "Player"
{
	speed = 30
}

function Player:__init(x,y)
	self.super = Object:new("ninja.png", x,y)
	self.velocity = vector(0,0)
end

function Player:draw()
	self.super:draw()
end

function Player:update(dt)
	local m = vector(0,0)
	if love.keyboard.isDown("left") then
		m = m - vector(1,0)
	end
	if love.keyboard.isDown("right") then
		m = m + vector(1,0)
	end
	if love.keyboard.isDown("up") then
		m = m - vector(0,1)
	end
	if love.keyboard.isDown("down") then
		m = m + vector(0,1)
	end
	self.super.pos = self.super.pos + m*self.speed*dt
end