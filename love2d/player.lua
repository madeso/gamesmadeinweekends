require "oo"
require "object"
vector = require "hump/vector"
require "tilesets"


class "Player" {}

function Player:__init(x,y)
	self.super = Object:new("ninja.png", x,y)
end

function Player:draw()
	self.super:draw()
end

function Player:update(dt)
	self.super.pos = self.super.pos + vector(30,30)*dt
end