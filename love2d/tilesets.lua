require "tileset"
Class = require 'hump.class'

Tilesets = Class{function(self)
	self.sets = {}
end}

function Tilesets:add(img, size)
	local set = Tileset(img, size)
	self.sets[img] = set
	return set
end

function Tilesets:get(img)
	local set = self.sets[img]
	if set == nil then
		return self:add(img, 32)
	else
		return set
	end
end

tilesets = Tilesets()