require "tileset"
Class = require 'hump.class'

Tilesets = Class{name="Tilesets", function(self)
end}

function Tilesets:set(img, size)
	self.set = Tileset(img, size)
	return set
end

function Tilesets:get()
	assert(self.set)
	return self.set
end

tilesets = Tilesets()