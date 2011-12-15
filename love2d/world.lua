require "oo"

class "World"
{
	objects = {};
}

function World:add(o)
	table.insert(self.objects, o)
end

function World:draw()
	for i,o in ipairs(self.objects) do
		o:draw()
	end
end

function World:update(dt)
	for i,o in ipairs(self.objects) do
		o:update(dt)
	end
end