Class = require "hump.class"
Camera = require "hump.camera"
Vector = require 'hump.vector'
--require "console"

ATL_Loader = require("AdvTiledLoader.Loader")
HC = require 'hardon'

require 'debug'

-- this is called when two shapes collide
function on_collision(dt, sa, sb, mx, my)
	--print(string.format("Colliding. mtv = (%s - %s) (%s,%s)", tostring(sa.type), tostring(sb.type), mx, my))
	if sa.type then sa.type:_onCollision(sb.type, sa.type._world_ref, mx, my) end
	if sb.type then sb.type:_onCollision(sa.type, sb.type._world_ref, -mx, -my) end
end

-- this is called when two shapes stop colliding
function collision_stop(dt, shape_a, shape_b)
    --print("Stopped colliding")
end

World = Class{function(self, path, creators)
	if creators == nil then
		creators = {}
	end
	self.objects = {};
	self.map = ATL_Loader.load(path)
	self.map.drawObjects = false
	self.collider = HC(100, on_collision, collision_stop)
	self.debug_collisons = false
	
	local added = 0
	
	for tilename, tilelayer in pairs(self.map.tileLayers) do
		print("Working on ", tilename, self.map.height, self.map.width)
		for y=1,self.map.height do
			for x=1,self.map.width do
				local tilenumber = tilelayer.tileData[y][x]
				local tile = self.map.tiles[tilenumber]
				if tile and tile ~= 0 then 
					if tilenumber>0 then
						--print(x,y, tilenumber)
						local epsilon = 0.0
						local ctile = self.collider:addRectangle((x-1)* self.map.tileWidth, (y-1) * self.map.tileHeight, self.map.tileWidth-epsilon, self.map.tileHeight-epsilon)
						ctile.type = nil
						self.collider:addToGroup("tiles", ctile)
						self.collider:setPassive(ctile)
						added = added + 1
					end
				end
			end
		end
	end
	
	for layername, layer in pairs(self.map.objectLayers) do
		print("Working on objectlayer ", layername)
		for i,o in pairs(layer.objects) do
			print("Object: #", i, ", name: ", o.name, ", type: ", o.type, ", pos: ", o.x, o.y)
			c = creators[layername]
			if c ~= nil then
				col = c(o.x,o.y,o.properties)
				if col ~= nil then
					self:add(col)
				else
					print("Failed to create object")
				end
			else
				print("No matching creator for object")
			end
		end
	end
	
	print(added)
	
	self.camera = Camera(Vector(0,0))
end}

function World:add(o)
	o:enterWorld(self, self.collider)
	table.insert(self.objects, o)
	o._world_ref = self
end

function World:draw()
	love.graphics.setColor(255, 255, 255, 255)
	self.camera:attach()
	self.map:draw()
	for i,o in ipairs(self.objects) do
		o:draw(self)
	end
	self.camera:detach()
end

function World:getCamera()
	return self.camera
end

function World:update(dt)
	for i,o in ipairs(self.objects) do
		o:update(dt)
		o:_apply_hor(dt)
		
	end
	self.horizontal = true
	self.collider:update(dt)
	for i,o in ipairs(self.objects) do
		o:_apply_ver(dt)
	end
	self.horizontal = false
	self.collider:update(dt)
	
	for i,o in ipairs(self.objects) do
		o:post_update(dt)
	end
end

function World:onkey(down, key, unicode)
	for i,o in ipairs(self.objects) do
		o:onkey(down, key, unicode)
	end
end