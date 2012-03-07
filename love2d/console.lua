require 'hump.class'

CEntry = Class{function(self, text)
	self.time = 10;
	self.total = 10;
	self.text = text
end}

function CEntry:update(dt)
	if self.time > 0 then
		self.time = self.time - dt
		return true
	else
		return false
	end
end

function CEntry:draw(i)
	love.graphics.setColor(255,255,255, 255 - (1-math.min(self.time,7)/7)*250)
	love.graphics.print(self.text, 10, 10+i* 15)
end

Console = Class{function(self)
	self.entries = {}
end}

function Console:print(t)
	table.insert(self.entries, 0, CEntry(t))
	
end

function Console:draw()
	for i,o in ipairs(self.entries) do
		o:draw(i)
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function Console:update(dt)
	for i=#self.entries,1,-1 do
		local o = self.entries[i]
		if o:update(dt)==false then
			table.remove(self.entries)
		end
	end
end

console = Console()