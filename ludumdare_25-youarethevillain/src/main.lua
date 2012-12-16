WORLDSIZE = 300
PLAYERSIZE = 32
WORLDY = 150
WORLDYCHANGE = 250
PUNCHRANGE = 0.15

TWOPI = 2*math.pi

KEYLEFT = "left"
KEYRIGHT = "right"
KEYPUNCH = " "

KEYLEFT = "joy1-An1"
KEYRIGHT = "joy1-Ap1"
KEYPUNCH = "joy1-3"

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
	punch = 0
	player = Player()
	objects = {}
	newobjects = {}
	table.insert(objects, Civilian())
	table.insert(objects, Civilian())
	table.insert(objects, Civilian())
	table.insert(objects, Civilian())
	local c = Civilian()
	c.pos = 0
	table.insert(objects, c)
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
	self.rot = 0
	self.y = 0
	self.drawnight = true
	self.dead = false
	self.baseimage = 0
	
	self.animation = {1}
	self.animationspeed = 1
	self.animationtimer = 0
	self.animationindex = 1
	self.animationname = ""
	
	function self:setanimation(name, timer, anim)
		if name ~= self.animationname then
			self.animationspeed = timer
			self.animation = anim
			self.image = self.baseimage + anim[1]
			self.animationindex = 1
			self.animationtimer = 0
			self.animationname = name
		end
	end
	
	function self:update(dt)
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer > self.animationspeed then
			self.animationtimer = self.animationtimer - self.animationspeed
			self.animationindex = self.animationindex + 1
			if self.animationindex > #self.animation then
				self.animationindex = 1
			end
			self.image = self.baseimage + self.animation[self.animationindex]
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
	local dist = WORLDSIZE+PLAYERSIZE+o.y
	local pos = -o.pos + worldrotation - 0.5*math.pi
	local x = dist * math.cos(pos)
	local y = dist * math.sin(pos)
	local ang = pos + 0.5 * math.pi + o.rot
	if o.drawnight then
		tiles:draw(o.image,x,y,o.dir, 1, ang, 255, 255*nightval)
	else
		tiles:draw(o.image,x,y,o.dir, 1, ang)
	end
end

punchtimer = 0

function love.update(dt)
	sendjoykeys()
	local move = 0
	local moving = false
	if leftkey then
		move = -1
		player.dir = 4
		moving = true
	elseif rightkey then
		move = 1
		player.dir = 6
		moving = true
	end
	
	if punch > 0 then
		punchtimer = 0.2
		player:move(move*0.002)
	end
	
	if punchtimer > 0 then
		punchtimer = punchtimer - dt
		player:setanimation("punching", 0.10, {6, 7, 6, 8})
	else
		if moving then
			player:setanimation("walk", 0.15, {2, 3, 4, 5})
			player:move(move*dt*0.05)
		else
			player:setanimation("idle", 1, {1})
		end
	end
	
	for i,o in pairs(objects) do
		o:update(dt)
	end
	remove_if(objects, object_is_dead)
	player:update(dt)
	for i,o in pairs(newobjects) do
		table.insert(objects, o)
	end
	newobjects = {}
	
	worldtime = worldtime + dt * 0.01
	if worldtime > 1 then
		worldtime = 1
	end
	
	punch = 0
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
	print(down, key)
	
	if key == "escape" and down then
		love.event.quit()
	end
	
	if key == KEYLEFT then
		leftkey = down
	end
	
	if key == KEYRIGHT then
		rightkey = down
	end
	
	if key == KEYPUNCH and down then
		punch = punch + 1
		on_close(player.pos, PUNCHRANGE, on_player_punched)
	end
end

function on_player_punched(obj, dir)
	if obj.class == "civ" and dir == player.dir then
		obj:onhurt()
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

function Player()
	local player = Object()
	player.class = "player"
	player.image = 1
	player.animation = {1, 2}
	player.animationspeed = 0.8
	return player
end

function Civilian()
	local civ = Object()
	civ.class = "civ"
	civ.baseimage = 20
	civ.obj_update = civ.update
	civ.hurt = 0
	civ.pos = math.random() * 2 * math.pi
	local dir = math.random() > 0.5
	if dir then
		civ.dir = 6
		civ.mdir = 1
	else
		civ.dir = 4
		civ.mdir = -1
	end
	
	function civ:onhurt()
		self.hurt = 0.1
		
		table.insert(newobjects, Bodypart(self.baseimage, true, self.pos, self.dir))
		table.insert(newobjects, Bodypart(self.baseimage, false, self.pos, self.dir))
	end
	
	function civ:update(dt)
		if self.hurt > 0 then
			self.hurt = self.hurt - dt
			self:setanimation("hurt", 1, {math.random(3,5)})
		else
			self:setanimation("walk", 0.5, {1, 2})
		end
		self:move(self.mdir * 0.01 * dt)
		self:obj_update(dt)
	end
	return civ
end

function PhysObj(dx,dy, grav, rinc)
	local p = Object()
	p.obj_update = p.update
	p.dx = dx
	p.dy = dy
	p.boxy = 0
	p.grav = grav
	p.rinc = rinc
	function p:update(dt)
		self:move(self.dx * dt)
		self.y = self.y + self.dy * dt
		self.dy = self.dy - self.grav * dt
		self.rot = self.rot + self.rinc * dt
		if self.y+self.boxy < 0 then
			self.dy = -self.dy * 0.7
			self.dx = self.dx * 0.7
		end
		self:obj_update(dt)
	end
	return p
end

function randomsign()
	if math.random() < 0.5 then
		return 1
	else
		return -1
	end
end

function Bodypart(bi, head, pos, dir)
	local b = PhysObj(0.05*math.random()*randomsign(),40 * math.random(), 20, 0)
	b.class = "bpart"
	b.pos = pos
	b.dir = dir
	b.baseimage = bi
	b.usespeed = true
	
	if head then
		b:setanimation("idle", 1, {math.random(6,7)})
		b.boxy = 20
	else
		b:setanimation("idle", 1, {math.random(8,9)})
		b.boxy = 0
		b.dy = b.dy * 2
	end
	
	return b
end

function on_close(pos, range, func)
	for i,o in pairs(objects) do
		_on_close(o, pos, range, func)
	end
	_on_close(player, pos, range, func)
end

function _on_close(obj, pos, range, func)
	local isclose = false
	local dir = false
	
	if math.abs(obj.pos-pos) < range then
		isclose = true
		dir = obj.pos < pos
	end
	
	if math.abs(obj.pos+(2*math.pi)-pos) < range then
		isclose = true
	end
	if math.abs(obj.pos-(2*math.pi)-pos) < range then
		isclose = true
	end
	
	if isclose then
		if dir then
			dir = 6
		else
			dir = 4
		end
		func(obj, dir)
	end
end

function love.joystickpressed( joystick, button )
	onkey("joy"..tostring(joystick).."-"..tostring(button), true)
end

function love.joystickreleased( joystick, button )
	onkey("joy"..tostring(joystick).."-"..tostring(button), false)
end

function sendjoykeys()
	local joysticks = love.joystick.getNumJoysticks()
	
	if js == nil then
		js = {}
		for joystick=1, joysticks do
			local data = {}
			data.axes = love.joystick.getNumAxes(joystick)
			data.axesl = {}
			data.axesr = {}
			for axis=1, data.axes do
				data.axesl[axis] = false
				data.axesr[axis] = false
			end
			js[joystick] = data
		end
	end
	
	for joystick=1, joysticks do
		local data = js[joystick]
		for axis=1, data.axes do
			local direction = love.joystick.getAxis(joystick, axis)
			local left = false
			local right = false
			if direction > 0.5 then
				right = true
			end
			if direction < -0.5 then
				left = true
			end
			if data.axesl[axis] ~= left then
				data.axesl[axis] = left
				onkey("joy"..tostring(joystick).."-An"..tostring(axis), left)
			end
			if data.axesr[axis] ~= right then
				data.axesr[axis] = right
				onkey("joy"..tostring(joystick).."-Ap"..tostring(axis), right)
			end
		end
	end
end