Class = require "hump.class"
require "camera"
--require "console"

ATL_Loader = require("AdvTiledLoader.Loader")
HC = require 'hardon'

-- this is called when two shapes collide
function on_collision(dt, sa, sb, mx, my)
	--print(string.format("Colliding. mtv = (%s - %s) (%s,%s)", tostring(sa.type), tostring(sb.type), mx, my))
	if sa.type then sa.type:onCollision(sb.type, mx, my) end
	if sb.type then sb.type:onCollision(sa.type, mx, my) end
end

-- this is called when two shapes stop colliding
function collision_stop(dt, shape_a, shape_b)
    --print("Stopped colliding")
end

World = Class{function(self, path)
	self.objects = {};
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
						local ctile = self.collider:addRectangle((x-1)* self.map.tileWidth, (y-1) * self.map.tileHeight, self.map.tileWidth-epsilon, self.map.tileHeight-epsilon)
						ctile.type = nil
						self.collider:addToGroup("tiles", ctile)
						self.collider:setPassive(ctile)
					end
				end
			end
		end
	end
	
	self.camera = Camera:new(0,0)
end}

function World:add(o)
	o:enterWorld(self, self.collider)
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