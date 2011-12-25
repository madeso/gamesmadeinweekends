require "oo"
require "camera"
--require "console"

ATL_Loader = require("AdvTiledLoader.Loader")
HC = require 'hardon'

class "World"
{
	objects = {};
}

-- this is called when two shapes collide
function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
    print(string.format("Colliding. mtv = (%s,%s)", mtv_x, mtv_y))
end

-- this is called when two shapes stop colliding
function collision_stop(dt, shape_a, shape_b)
    print("Stopped colliding")
end

function World:__init(path)
	self.map = ATL_Loader.load(path)
	self.collider = HC(100, on_collision, collision_stop)
	
	for tilename, tilelayer in pairs(self.map.tileLayers) do
		print("Working on ", tilename, self.map.height, self.map.width)
		for y=1,self.map.height do
			for x=1,self.map.width do
				local tilenumber = tilelayer.tileData[y][x]
				local tile = self.map.tiles[tilenumber]
				if tile and tile ~= 0 then 
					if tilenumber>0 then
						--print(x,y, tilenumber)
						local epsilon = 0.001
						self.collider:addRectangle(x* self.map.tileWidth, y * self.map.tileHeight, self.map.tileWidth-epsilon, self.map.tileHeight-epsilon)
					end
				end
			end
		end
	end
	
	self.camera = Camera:new(0,0)
end

function World:add(o)
	table.insert(self.objects, o)
end

function World:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.push()
	love.graphics.scale(self.camera.zoom)
	love.graphics.translate(self.camera.x, self.camera.y)
	
	self.map:draw()
	for i,o in ipairs(self.objects) do
		o:draw()
	end
	
	love.graphics.pop()
end

function World:getCamera()
	return self.camera
end

function World:update(dt)
	for i,o in ipairs(self.objects) do
		o:update(dt)
	end
	self.collider:update(dt)
end

function World:onkey(down, key, unicode)
	for i,o in ipairs(self.objects) do
		o:onkey(down, key, unicode)
	end
end