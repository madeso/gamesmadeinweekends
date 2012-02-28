require "oo"
require "tileset"

class "Tilesets"
{
	sets = {};
}

function Tilesets:add(img, size)
	local set = Tileset:new(img, size)
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

tilesets = Tilesets:new()