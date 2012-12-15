WORLDSIZE = 300
PLAYERSIZE = 32
WORLDY = 150
WORLDYCHANGE = 250

TWOPI = 2*math.pi

require "tileset"
Camera = require "hump.camera"

citybg = {}
citynight = {}
citylines = {}
city = 1

worldtime = 0

sky = {}

function love.load()
	tiles = Tileset("gfx/tiles.png", 64)
	
	for i=1, 1 do
		table.insert( citybg, love.graphics.newImage("gfx/city" .. i ..  ".png") )
		table.insert( citynight, love.graphics.newImage("gfx/city" .. i ..  "-night.png") )
		table.insert( citylines, love.graphics.newImage("gfx/city" .. i ..  "-lines.png") )
	end
	
	sky.blue = love.graphics.newImage("gfx/sky-blue.png")
	sky.darkness = love.graphics.newImage("gfx/sky-darkness.png")
	sky.front = love.graphics.newImage("gfx/sky-front.png")
	sky.parallax1 = love.graphics.newImage("gfx/sky-parallax1.png")
	sky.parallax2 = love.graphics.newImage("gfx/sky-parallax2.png")
	sky.parallax3 = love.graphics.newImage("gfx/sky-parallax3.png")
	sky.signal = love.graphics.newImage("gfx/sky-signal.png")
	
	newgame()
end

function newgame()
	player = Object()
	player.image = 2
	player.animation = {2,4,1,3}
	player.animationspeed = 0.25
	objects = {}
	table.insert(objects, Object())
end

function draw_sky(x)
	local ix = 1-(x*1.75)
	love.graphics.setColor(255,255,255, 255)
	if x < 0.5 then
		love.graphics.draw(sky.blue, 0, 0)
		love.graphics.setColor(255,255,255, 2*x*255)
		love.graphics.draw(sky.darkness, 0, 0)
		love.graphics.setColor(255,255,255, 255)
	else
		love.graphics.draw(sky.darkness, 0, 0)
	end
	love.graphics.draw(sky.parallax3, 0, 30*ix)
	love.graphics.draw(sky.parallax2, 0, 20*ix)
	if x > 0.5 then
		love.graphics.setColor(255,255,255, 2*(x-0.5)*255)
		love.graphics.draw(sky.signal, 0, 0)
		love.graphics.setColor(255,255,255, 255)
	end
	love.graphics.draw(sky.parallax1, 0, 10*ix)
	love.graphics.draw(sky.front, 0, 0)
end

function love.draw()
	draw_sky(worldtime)
	
	local worldy = WORLDY + WORLDYCHANGE * worldtime
	local cam = Camera(0,-worldy, 1, 0)
	
	cam:attach()
	draw_world()
	cam:detach()
end

function draw_world()
	local worldrotation = player.pos
	local nightval = math.max(0.4,1-worldtime)
	love.graphics.setColor(255*nightval,255*nightval,255*nightval)
	love.graphics.draw(citybg[city], 0, 0, worldrotation, 1,1, 512,512)
	love.graphics.setColor(255,255,255, 255 * math.min(1, 2*worldtime))
	love.graphics.draw(citynight[city], 0, 0, worldrotation, 1,1, 512,512)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(citylines[city], 0, 0, worldrotation, 1,1, 512,512)
	
	tiles:start()
	
	for i,o in pairs(objects) do
		draw_object(o, nightval, worldrotation)
	end
	
	draw_object(player, nightval, worldrotation)
	
	tiles:stop()
end

function Object()
	local self = {}
	self.image = 1
	self.dir = 6
	self.pos = 0
	self.drawnight = true
	self.dead = false
	
	self.animation = {1,3}
	self.animationspeed = 1
	self.animationtimer = 0
	self.animationindex = 1
	
	self.life = 3
	
	function self:update(dt)
		if self.life < 0 then
			self.dead = true
		else
			self.life = self.life - dt
		end
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer > self.animationspeed then
			self.animationtimer = self.animationtimer - self.animationspeed
			self.animationindex = self.animationindex + 1
			if self.animationindex > #self.animation then
				self.animationindex = 1
			end
			self.image = self.animation[self.animationindex]
		end
	end
	
	function self:move(d)
		self.pos = self.pos - d * math.pi
		
		if self.pos > TWOPI then
			self.pos = self.pos - TWOPI
		end
		if self.pos < 0 then
			self.pos = self.pos + TWOPI
		end
	end
	
	return self
end

function draw_object(o, nightval, worldrotation)
	local dist = WORLDSIZE+PLAYERSIZE
	local pos = -o.pos + worldrotation - 0.5*math.pi
	local x = dist * math.cos(pos)
	local y = dist * math.sin(pos)
	local ang = pos + 0.5 * math.pi
	if o.drawnight then
		tiles:draw(o.image,x,y,o.dir, 1, ang, 255, 255*nightval)
	else
		tiles:draw(o.image,x,y,o.dir, 1, ang)
	end
end

function love.update(dt)
	local move = 0
	if leftkey then
		move = -1
		player.dir = 4
	elseif rightkey then
		move = 1
		player.dir = 6
	end
	
	for i,o in pairs(objects) do
		o:update(dt)
	end
	remove_if(objects, object_is_dead)
	player:update(dt)
	
	player:move(move*dt*0.05)
	worldtime = worldtime + dt * 0.1
	if worldtime > 1 then
		worldtime = 1
	end
end

function object_is_dead(obj)
	return obj.dead
end

function love.keypressed(key, unicode)
	onkey(key, true)
end

function love.keyreleased(key)
	onkey(key, false)
end

leftkey = false
rightkey = false

function onkey(key, down)
	if key == "left" then
		leftkey = down
	end
	
	if key == "right" then
		rightkey = down
	end
end

function remove_if(list, func)
        local toremove = {}
        for i,item in ipairs(list) do
                if func(item) then
                        table.insert(toremove, i)
                end
        end
        local i = 0
        while #toremove ~= 0 do
                i = table.remove(toremove)
                table.remove(list,i)
        end
end