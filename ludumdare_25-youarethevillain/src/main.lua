WORLDSIZE = 300
PLAYERSIZE = 32
WORLDY = 150
WORLDYCHANGE = 250
PUNCHRANGE = 0.15
CHARGETIME = 0.05

TWOPI = 2*math.pi

KEYLEFT = "left"
KEYRIGHT = "right"
KEYPUNCH = " "
KEYBLOCK = "down"

--KEYLEFT = "joy1-An1"
--KEYRIGHT = "joy1-Ap1"
--KEYPUNCH = "joy1-3"
--KEYBLOCK = "joy1-2"

require "tileset"
Camera = require "hump.camera"
Gamestate = require "hump.gamestate"

function SetupGamestates(gs)
	function gs:keypressed(key, unicode)
		self:onkey(key, unicode, true)
	end
	
	function gs:keyreleased(key)
		self:onkey(key, nil, false)
	end
	
	function gs:joystickpressed( joystick, button )
		self:onkey("joy"..tostring(joystick).."-"..tostring(button), true)
	end

	function gs:joystickreleased( joystick, button )
		self:onkey("joy"..tostring(joystick).."-"..tostring(button), false)
	end
	
	return gs
end

require "states"

citybg = {}
citynight = {}
citylines = {}
city = 1

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
	
	gametitle = love.graphics.newImage("gfx/title.png")
	
	Gamestate.registerEvents()
	--Gamestate.switch(SFadeInToWorld)
	Gamestate.switch(SGame)
	newgame()
end

function newgame()
	punch = 0
	blocking = false
	civcount = 0
	player = Player()
	objects = {}
	newobjects = {}
	global_worldtime = 0
	
	spawn_civ()
	
	--todo remove
	table.insert(objects, Hero_Dog())
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

MENYWIDTH = 200
MENYX = 300
MENYY = 400
MENYHEIGHT = 25

function draw_meny(total)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', MENYX, MENYY, MENYWIDTH,MENYHEIGHT*total)
end

function meny_isaction(key)
	return key == " " or key == "return"
end

function meny_changeindex(key, index, total)
	local r = index
	
	if key == "up" then
		r = r - 1
	end
	
	if key == "down" then
		r = r + 1
	end
	
	if r >= total then
		r = r - total
	end
	
	if r < 0 then
		r = r + total
	end
	
	return r
end

function draw_meny_item(index, selected, text)
	if index == selected then
		love.graphics.setColor(255, 0, 0, 255)
		love.graphics.rectangle('fill', MENYX, MENYY+MENYHEIGHT*index, MENYWIDTH,MENYHEIGHT)
	end
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(text, MENYX, MENYY+MENYHEIGHT*index, 0, 2)
end

function draw_screen()
	love.graphics.rectangle('fill', 0, 0, 800,600)
end

function draw_title(y)
	--love.graphics.print("TITLE", 20, 100*y)
	love.graphics.draw(gametitle, 0, -150*(1-y))
end

function draw_everything(worldtime, drawobjects, drawplayer, drawhud)
	draw_sky(worldtime)
	
	local worldy = WORLDY + WORLDYCHANGE * worldtime
	local cam = Camera(0,-worldy, 1, 0)
	
	cam:attach()
	draw_world(worldtime, drawobjects, drawplayer)
	cam:detach()
	
	if drawhud then
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("health: " .. tostring(player.health), 0,0)
	end
end

function draw_world(worldtime, drawobjects, drawplayer)
	local worldrotation = player.pos
	local nightval = math.max(0.4,1-worldtime)
	love.graphics.setColor(255*nightval,255*nightval,255*nightval)
	love.graphics.draw(citybg[city], 0, 0, worldrotation, 1,1, 512,512)
	love.graphics.setColor(255,255,255, 255 * math.min(1, 2*worldtime))
	love.graphics.draw(citynight[city], 0, 0, worldrotation, 1,1, 512,512)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(citylines[city], 0, 0, worldrotation, 1,1, 512,512)
	
	tiles:start()
	
	if drawobjects then
		for i,o in pairs(objects) do
			draw_object(o, nightval, worldrotation)
		end
	end
	
	if drawplayer then
		draw_object(player, nightval, worldrotation)
	end
	
	tiles:stop()
end

function Object()
	local self = {}
	self.image = 1
	self.dir = 6
	self.pos = 0
	self.rot = 0
	self.y = 0
	self.alpha = 255
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
		tiles:draw(o.image,x,y,o.dir, 1, ang, o.alpha, 255*nightval)
	else
		tiles:draw(o.image,x,y,o.dir, 1, ang)
	end
end

punchtimer = 0

function game_update(dt)
	local move = 0
	local moving = false
	local isblocking = false
	
	if player.hurt > 0 then
		player.hurt = player.hurt - dt
		player:setanimation("hurt", 1, {10})
	else
		if leftkey then
			move = -1
			player.dir = 4
			moving = true
		elseif rightkey then
			move = 1
			player.dir = 6
			moving = true
		end
		
		if not moving and player.charging then
			player.charging = false
		end
		
		if punchtimer <= 0 and blocking then
			punch = 0
			move = 0
			moving = false
			isblocking = true
		end
		player.isblocking = isblocking
		
		if punch > 0 then
			if player.moving>0.05 and punchtimer <= 0 then
				-- charge!
				player.charging = true
			else
				punchtimer = 0.2
				player:move(move*0.002)
				player.moving = 0
			end
		end
		
		if player.charging then
			player.chargetimer = player.chargetimer + dt
			while player.chargetimer > CHARGETIME do
				player.chargetimer = player.chargetimer - CHARGETIME
				player_punch()
			end
		else
			player.chargetimer = 0
		end
		
		local walking = false
		
		if player.charging then
			player:move(move*dt*0.2)
			player:setanimation("charge", 0.12, {12, 13})
		else
			if isblocking then
				player:setanimation("blocking", 1, {9})
			else
				if punchtimer > 0 then
					punchtimer = punchtimer - dt
					player:setanimation("punching", 0.10, {6, 7, 6, 8})
				else
					if moving then
						player:setanimation("walk", 0.15, {2, 3, 4, 5})
						player:move(move*dt*0.05)
						walking = true
					else
						player:setanimation("idle", 1, {1})
					end
				end
			end
		end
		
		if walking then
			player.moving = player.moving + dt
		else
			if player.moving > 0 then
				player.moving = player.moving - dt
			end
		end
	end
	
	if player.kickback > 0 then
		player:move(player.kickbackdir * player.kickback * 0.8 * dt)
		player.kickback = player.kickback - dt
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
	
	punch = 0
	
	spawn_civ()
end

function spawn_civ()
	while civcount < 20 do
		table.insert(objects, Civilian())
	end
end

function object_is_dead(obj)
	return obj.dead
end

leftkey = false
rightkey = false

function game_onkey(key, down)
	--print(down, key)
	
	if key == "escape" and down then
		--love.event.quit()
		Gamestate.switch(SIngame)
	end
	
	if key == KEYLEFT then
		leftkey = down
	end
	
	if key == KEYRIGHT then
		rightkey = down
	end
	
	if key == KEYPUNCH and down then
		punch = punch + 1
		player_punch()
	end
	
	if key == KEYBLOCK then
		blocking = down
	end
end

function player_punch()
	on_close(player.pos, PUNCHRANGE, on_player_punched, player)
end

function on_player_punched(obj, dir, pl)
	if obj.class == "civ" and dir == pl.dir then
		obj:onhurt(player)
	elseif obj.class == "hero" and dir == pl.dir then
		obj:onhurt(player)
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
	player.moving = 0
	player.health = 3
	player.isblocking = false
	player.charging = false
	player.chargetimer = 0
	player.kickback = 0
	player.kickbackdir = 1
	player.hurt = 0
	
	function player:onhurt(other)
		local power = 1
		local dmg = 1
		if self.charging then
			power = power * 2
			dmg = 2
		end
		if self.isblocking then
			power = power * 0.25
			dmg = 0
		end
		if dmg > 0 then
			self.hurt = 0.25
			self.health = self.health - dmg
			if self.health <= 0 then
				Gamestate.switch(SMoveDeadPlayer)
			end
		end
		self.kickback = 0.3 * power
		self.charging = false
		
		if onleftside(self.pos, other.pos) then
			self.kickbackdir = -1
		else
			self.kickbackdir = -1
		end
	end
	
	return player
end

function Civilian()
	local civ = Object()
	civ.class = "civ"
	civ.baseimage = 20
	civ.obj_update = civ.update
	civ.hurt = 0
	civ.health = 5
	civcount = civcount + 1
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
		self.health = self.health -1
		
		if self.health <= 0 then
			self.dead = true
			table.insert(newobjects, Bodypart(self.baseimage, true, self.pos, self.dir))
			table.insert(newobjects, Bodypart(self.baseimage, false, self.pos, self.dir))
			civcount = civcount - 1
		else
			self.hurt = 0.1
		end
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
	
	civ:update(0)
	return civ
end

function Hero_Dog()
	local dog = Object()
	dog.class = "hero"
	dog.baseimage = 40
	dog.obj_update = dog.update
	dog.timer = 1
	dog.health = 15
	dog.state = 1
	dog.punchtimer = 0
	dog.pos = math.random() * 2 * math.pi
	--dog.pos = math.pi * 0.25
	
	function dog:onhurt(other)
		if self.state == 6 then
			if other ~= nil then
				other:onhurt(self)
			end
		else
			if self.state ~= 3 and self.state ~= 7 and self.state ~= 1 then
				self.health = self.health -1
				if self.health <= 0 then
					-- dead
					self.timer = 4
					self.state = 7
				else
					-- hurt
					self.timer = 0.5
					self.state = 3
				end
			end
		end
	end
	
	function dog:update(dt)
		if self.timer > 0 then
			self.timer = self.timer - dt
		end
		
		if self.state == 1 then
			-- spawning
			self.alpha = 255 * (1-self.timer)
			if self.timer <= 0 then
				self.alpha = 255
				self.state = 2
			end
			self:setanimation("spawning", 1, {1})
		elseif self.state == 2 then
			-- walking
			if distance(self.pos, player.pos) < 0.045 * math.pi then
				self:setPunchBlockorLaugh()
			end
			
			self:setanimation("walk", 0.25, {2, 3, 4, 3})
			local mdir = 1
			self.dir = 6
			if onleftside(self.pos, player.pos) then
				mdir = -1
				self.dir = 4
			end
			self:move(mdir * 0.05 * dt)
		elseif self.state == 3 then
			-- hurt
			self:setanimation("hurt", 1, {9})
			if self.timer < 0 then
				self:setPunchOrBlock()
			end
		elseif self.state == 4 then
			-- laughing
			self:setanimation("laughing", 1, {8})
			if self.timer <= 0 then
				self.state = 2
			end
		elseif self.state == 5 then
			-- punching
			DOGPUNCHSPEED = 0.10
			self:setanimation("punching", DOGPUNCHSPEED, {6,7})
			self.punchtimer = self.punchtimer - dt
			if self.punchtimer <= 0 then
				self.punchtimer = self.punchtimer + DOGPUNCHSPEED
				on_close(self.pos, PUNCHRANGE, on_dog_punched, self)
			end
			if self.timer <= 0 then
				self.state = 2
				self.punchtimer = 0
			end
			
			local mdir = 1
			if self.dir==4 then
				mdir = -1
			end
			self:move(mdir * 0.02 * dt)
		elseif self.state == 6 then
			-- blocking
			self:setanimation("block", 1, {5})
			if self.timer <= 0 then
				self.state = 2
			end
		elseif self.state == 7 then
			-- die
			self.alpha = 255 * self.timer/4
			self:setanimation("cry", 0.5, {10,11})
			if self.timer <= 0 then
				self.dead = true
			end
		else
			-- unknown
			self.state = 1
		end
		
		self:obj_update(dt)
	end
	function dog:setPunchOrBlock()
		if math.random() > 0.5 then
			-- punching
			self.timer = 1+math.random()
			self.state = 5
		else
			-- blocking
			self.timer = 2+math.random()
			self.state = 6
		end
	end
	function dog:setPunchBlockorLaugh()
		local r = math.random()
		if r < 0.40 then
			-- punch
			self.timer = 1+math.random()
			self.state = 5
		elseif r < 0.80 then
			-- block
			self.timer = 1+math.random()
			self.state = 6
		else
			-- laugh
			self.timer = 1+2*math.random()
			self.state = 4
		end
	end
	
	dog:update(0)
	return dog
end

function on_dog_punched(obj, dir, dog)
	if obj.class == "player" and dog.dir == dir then
		obj:onhurt(obj)
	end
end

function onleftside(a,b)
	local _, right = getdirectiondata(a,b)
	return right == false
end

function distance(a,b)
	local dist, _ = getdirectiondata(a,b)
	return dist
end

function PhysObj(dx,dy, grav, rinc)
	local p = Object()
	p.obj_update = p.update
	p.dx = dx
	p.dy = dy
	p.boxy = 0
	p.grav = grav
	p.rinc = rinc
	p.life = -1
	function p:update(dt)
		if self.life > 0 then
			self.life = self.life - dt
			if self.life < 1 then
				self.alpha = 255 * self.life
			end
			if self.life <= 0 then
				self.dead = true
			end
		end
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
	b.life = 8
	
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

function on_close(pos, range, func, data)
	for i,o in pairs(objects) do
		_on_close(o, pos, range, func, data)
	end
	_on_close(player, pos, range, func, data)
end

function _on_close(obj, pos, range, func, data)
	local isclose = false
	local dir = false
	
	if math.abs(obj.pos-pos) < range then
		isclose = true
		dir = obj.pos < pos
	end
	
	if math.abs(obj.pos+(2*math.pi)-pos) < range then
		isclose = true
		dir = obj.pos+(2*math.pi) < pos
	end
	if math.abs(obj.pos-(2*math.pi)-pos) < range then
		isclose = true
		dir = obj.pos-(2*math.pi) < pos
	end
	
	if isclose then
		if dir then
			dir = 6
		else
			dir = 4
		end
		func(obj, dir, data)
	end
end

function getdirectiondata(b,a)
	local right =  a < b
	local range = math.abs(a-b)
	
	local temp = math.abs(a+(2*math.pi)-b)
	if temp < range then
		right = a+(2*math.pi) < b
		range = temp
	end
	
	temp = math.abs(a-(2*math.pi)-b)
	if temp < range then
		right = a-(2*math.pi) < b
		range = temp
	end
	
	return range, right
end

-- todo: incorperate into states
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
