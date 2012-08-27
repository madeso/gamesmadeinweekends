function playSound(s)
	love.audio.stop(s)
	love.audio.rewind(s)
	love.audio.play(s)
end

function sfx(path)
	print("loading ", sfx)
	return love.audio.newSource(path, "static")
end

function playMusic(path)
	local m = love.audio.newSource(path, "stream")
	m:setLooping(true)
	m:play()
end

sndScore = sfx("score.wav")
sndBang = sfx("bang.wav")

sndGui = sfx("gui.wav")
sndBad = sfx("notenough.wav")
sndUpgrade = sfx("upgrade.wav")
sndGameover = sfx("gameover.wav")
sndtogame = sfx("togame.wav")
sndjump = sfx("jump.wav")
sndhump = sfx("hump.wav")
sndlife = sfx("life.wav")
snddie = sfx("die.wav")
snddash = sfx("dash.wav")
sndhurt = sfx("hurt.wav")
snddlaser = sfx("laser.wav")
sndskunkcharge = sfx("skunkcharge.wav")
sndskunkexplosion = sfx("skunkexplosion.wav")

require "world"
require "player"
require "tilesets"
require "console"
require "creator"
require "enemy"
require "partner"

Gamestate = require "hump.gamestate"

sgame = Gamestate.new()
smenu = Gamestate.new()
sfail = Gamestate.new()
supgrade = Gamestate.new()

function bang(pos, r)
	world:add(Img(pos.x, pos.y, 53, 0.40, r/32))
	for shape in pairs(world.collider:shapesInRange(pos.x-r,pos.y-r, pos.x+r,pos.y+r)) do
		if shape.type then
			if shape.type:is_a(Enemy) then
				local rr = pos - shape.type.pos
				rr = rr:len2()
				if rr < r*r then
					shape.type:kill()
				end
			end
		end
	end
end

function newgame()
	gameGeneration = 0
	gameChildren = 2
	gameEvolution = 0
	
	print("setting player")
	levelJump = 0
	levelHealth = 0
	levelSpeed = 0
	levelAir = 0
	levelGround = 0
	levelAirJump = 0
	levelDashSpeed = 0
	levelDashTime = 0
	levelFertility = 0
	levelPower = 0
	levelEvolution = 0
end

function smenu:init()
	self.bg = love.graphics.newImage('start.png')
	self.index = 0
	self.dir = 6
end
function smenu:draw()
	love.graphics.setColor(255,255,255,255)
    love.graphics.draw(self.bg, 0, 0)
	
	local animal = "unknown"
	local desc = "???"
	local power = "???"
	local text = "please select animal to evolve"
	if self.index == 0 then
		animal = "CAT"
		desc = "The common household cat can be really dangerrrous"
		power = "The cat can cough up furrrballs on enemies"
	elseif self.index == 1 then
		animal = "LABRAT"
		desc = "Escaped from a lab, the labrat is a fierce being"
		power = "After being subjected to drugs and radiation the rat evolves faster than other animals"
	elseif self.index == 2 then
		animal = "SKUNK"
		desc = "Everyone knows that the skunk smells"
		power = "The skunk can charge and release smelly bombs"
	end
	
	local START = 770
	
	local center = love.graphics.getWidth()/2
	tilesets:get():draw(2 + 5*self.index, center-4, START, self.dir)
	
	love.graphics.setColor(0,0,0,255)
	love.graphics.print("", 0,0)
	love.graphics.print(text, center-love.graphics.getFont():getWidth(text)/2, START - 90, 0, 1,1)
	love.graphics.print(animal, center-love.graphics.getFont():getWidth(animal)/2, START + 40, 0, 1,1)
	love.graphics.print(desc,  center-love.graphics.getFont():getWidth(desc)/2, START + 60, 0, 1,1)
	love.graphics.print(power,center-love.graphics.getFont():getWidth(power)/2, START + 80, 0, 1,1)
	
	text = "[Z = jump | X + direction = dash | C = use ability | space = mate]"
	love.graphics.print(text, center-love.graphics.getFont():getWidth(text)/2, 980, 0, 1,1)
	
end
function smenu:enter()
	print("entered menu")
end
function smenu:keypressed(key)
    if key == "escape" then
		love.event.quit()
	elseif key == "return" or key == " " then
		newgame()
		gamePlayer = self.index
		loadWorld()
		playSound(sndUpgrade)
		Gamestate.switch(sgame)
	elseif key=="left" then
		self.index = self.index - 1
		self.dir = 4
		playSound(sndGui)
		if self.index < 0 then
			self.index = 2
		end
	elseif key=="right" then
		self.index = self.index + 1
		self.dir = 6
		playSound(sndGui)
		if self.index > 2 then
			self.index = 0
		end
	end
end

function sfail:init()
	self.bg = love.graphics.newImage('gameover.png')
end
function sfail:enter()
	print("entered fail")
	playSound(sndGameover)
end
function sfail:draw()
	love.graphics.setColor(255,255,255,255)
    love.graphics.draw(self.bg, 0, 0)
end
function sfail:keypressed(key)
	if key == "escape" then
		love.event.quit()
    else
		Gamestate.switch(smenu)
		playSound(sndtogame)
	end
end

function supgrade:init()
	self.bg = love.graphics.newImage('evolve.png')
	self.item = 11
end
function supgrade:enter()
	print("entered upgrade")
end

function calccost(level)
	return (level+1)*20000
end

function supgrade:drawItem(item, name, value, desc, maxlevel)
	maxlevel = maxlevel or 3
	local y = 500 + 20*item
	local co = 120
	
	local c = calccost(value)
	local afford = false
	if c >= gameEvolution then
		afford = true
	end
	
	if self.item == item then
		love.graphics.print("->", 500, y)
		co = 0
		
		local r = 0
		local g = 0
		if value >= maxlevel then
			r = 120
			g = 120
		elseif afford then
			g = 255
			r = 0
		else
			g = 0
			r = 255
		end
		local epy = 460
		love.graphics.setColor(120, 120, 120, 255)
		love.graphics.print("Evolution points:", 600, epy)
		love.graphics.setColor(0, g, r, 255)
		love.graphics.print(string.format("%d", gameEvolution), 900, epy)
		
		love.graphics.setColor(120, 120, 120, 255)
		love.graphics.print(desc,  600, 730)
	end
	
	love.graphics.setColor(co, co, co, 255)
	
	if value >= maxlevel then
		c = "MAXED OUT"
	else
		c = string.format("%d", c)
	end
	love.graphics.print(name, 600, y)
	
	for i=1, maxlevel do
		local img = "X"
		if i > value then
			img = "-"
		end
		love.graphics.print(img, 700 + i*10, y)
	end
	
	love.graphics.print(c, 900, y)
end

function supgrade:draw()
	love.graphics.setColor(255,255,255,255)
    love.graphics.draw(self.bg, 0, 0)
	love.graphics.setColor(0,0,0,255)
	
	love.graphics.print("Please select what to evolve:", 550, 400)
	
	self:drawItem(0, "Jump strength", levelJump, "Dictactes how high you can jump")
	self:drawItem(1, "Health", levelHealth, "This is how sturdy you are", 10)
	self:drawItem(2, "Speed", levelSpeed, "How fast you can run")
	self:drawItem(3, "Air control", levelAir, "How much control you have in air")
	self:drawItem(4, "Ground control", levelGround, "How good your footgrip is")
	self:drawItem(5, "Air jump", levelAirJump, "How many extra jumps you can acchieve in mid-air")
	self:drawItem(6, "Dash speed", levelDashSpeed, "How fast you can dash")
	self:drawItem(7, "Dash time", levelDashTime, "How long your dash lasts")
	self:drawItem(8, "Fertility", levelFertility, "How fast you mate")
	self:drawItem(9, "Ability", levelPower, "How good your natural ability is")
	self:drawItem(10, "Adaptability", levelEvolution, "How good you are to evolve")
	
	local c = 120
	local y = 500 + 20*14
	if self.item == 11 then
		c = 0
		love.graphics.print("->", 500, y)
		
		local epy = 460
		love.graphics.setColor(120, 120, 120, 255)
		love.graphics.print("Evolution points:", 600, epy)
		love.graphics.print(string.format("%d", gameEvolution), 900, epy)
	end
	love.graphics.setColor(c, c, c, 255)
	love.graphics.print("Continue!", 600, y)
end

function nextLevel(level, maxlevel)
	maxlevel = maxlevel or 3
	if level >= maxlevel then
		playSound(sndBad)
		return level
	else
		local cost = calccost(level)
		if gameEvolution >= cost then
			gameEvolution = gameEvolution - cost
			playSound(sndUpgrade)
			return level + 1
		else
			playSound(sndBad)
			return level
		end
	end
end

function upgrade(item)
	if item == 0 then
		levelJump = nextLevel(levelJump)
	elseif item == 1 then
		levelHealth = nextLevel(levelHealth, 10)
	elseif item == 2 then
		levelSpeed = nextLevel(levelSpeed)
	elseif item == 3 then
		levelAir = nextLevel(levelAir)
	elseif item == 4 then
		levelGround = nextLevel(levelGround)
	elseif item == 5 then
		levelAirJump = nextLevel(levelAirJump)
	elseif item == 6 then
		levelDashSpeed = nextLevel(levelDashSpeed)
	elseif item == 7 then
		levelDashTime = nextLevel(levelDashTime)
	elseif item == 8 then
		levelFertility = nextLevel(levelFertility)
	elseif item == 9 then
		levelPower = nextLevel(levelPower)
	elseif item == 10 then
		levelEvolution = nextLevel(levelEvolution)
	end
end
function supgrade:keypressed(key)
	if key == "escape" then
		--love.event.quit()
		Gamestate.switch(sgame)
		playSound(sndUpgrade)
    elseif key == " " or key == "return" then
		if self.item == 11 then
			Gamestate.switch(sgame)
			playSound(sndUpgrade)
		else
			upgrade(self.item)
		end
	elseif key == "up" then
		self.item = self.item - 1
		playSound(sndGui)
		if self.item < 0 then
			self.item = 11
		end
	elseif key == "down" then
		self.item = self.item + 1
		playSound(sndGui)
		if self.item > 11 then
			self.item = 0
		end
	end
end

function createCreator(x,y,p)
	return Creator(x,y)
end

function createPlayer(x,y,p,world)
	print("creating player")
	theplayer = Player(world:getCamera(), x, y)
	return theplayer
end

function createPartner(x,y,p,world)
	if math.random() > 0.7 then
		return Partner(x,y)
	end
end

function loadWorld(file)
	local thefile = file or "level.tmx"
	print("loading.. ", thefile)
	world = World(thefile, creators)
	gameWave = 0
end

function love.load()
	theplayer = nil
	gamePlayer = 0
	love.graphics.setBackgroundColor( 252, 252, 248 )
	tilesets:set("ninja.png", 64)
	creators = {creators=createCreator,player=createPlayer,partners=createPartner}
	newgame()
	loadWorld()
	-- world:add(Box(100, 100, 50))
	--world:add()
	canplay = 3
	deltat = 1
	acu = 0
	STEP = 0.005
	playMusic("bu-monument-of-the-breeds.it")
	world.debug_collisons=true
	Gamestate.registerEvents()
    Gamestate.switch(smenu)
end

DIFF = 13

function sgame:draw()
	world:draw()
	console:draw()
	fps = 1/deltat
	love.graphics.setColor(0,0,0, 255)
	love.graphics.print(string.format("Generation: %d", gameGeneration+1), 100, DIFF * 1)
	love.graphics.print(string.format("Children: %d", gameChildren), 100, DIFF * 2)
	love.graphics.print(string.format("Evolution: %d", gameEvolution), 100, DIFF * 3)
	love.graphics.print(string.format("Enemies left: %d", gameEnemies or 0), 100, DIFF * 4)
	love.graphics.print(string.format("Hitpoints: %d", theplayer.health), 100, DIFF * 5)
	love.graphics.print(string.format("Wave: %d", gameWave), 100, DIFF * 6)
end

function spawnOnCreator(c)
	if math.random() < 0.2 * gameWave then
		world:add(Enemy(c.pos.x,c.pos.y))
	end
end

function countEnemy(c)
	gameEnemies = gameEnemies + 1
end

function sgame:update(dt)
	deltat=dt
	if canplay==0 then
		acu = acu + dt
		while acu > STEP do
			world:update(STEP)
			console:update(STEP)
			acu = acu - STEP
			
			gameEnemies = 0
			world:forEach(Enemy, countEnemy)
			
			if gameEnemies == 0 then
				gameWave = gameWave + 1
				world:add(Text(theplayer.pos.x, theplayer.pos.y, "Wave " .. gameWave, 3, 20))
				world:forEach(Creator, spawnOnCreator)
				if theplayer.health < 3 then
					theplayer.health = theplayer.health + 1
				end
			end
			
			if theplayer.dead == true then
				if gameChildren > 0 then
					gameChildren = gameChildren - 1
					gameGeneration = gameGeneration + 1
					Gamestate.switch(supgrade)
				else
					newgame()
					Gamestate.switch(sfail)
				end
				loadWorld()
			end
		end
	else
		print(dt)
		canplay = canplay - 1
		world:update(0)
	end
end

function sgame:keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	end
	
	if canplay==0 then
		world:onkey(true, key, unicode)
	end
end

function sgame:keyreleased(key)
	world:onkey(false, key, nil)
end

function sgame:mousepressed(x, y, button)
	world:onkey(true, "_"..button, nil)
end

function sgame:mousereleased(x, y, button)
	world:onkey(false, "_"..button, nil)
end