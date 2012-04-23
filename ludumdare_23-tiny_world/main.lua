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

require "world"
require "player"
require "tilesets"
require "console"
require "spike"
require "rat"
require "star"
require "goal"
Gamestate = require "hump.gamestate"

sgame = Gamestate.new()
smenu = Gamestate.new()
sdone = Gamestate.new()

function smenu:init()
	self.bg = love.graphics.newImage('start.png')
end
function smenu:draw()
	love.graphics.setColor(255,255,255,255)
    love.graphics.draw(self.bg, 0, 0)
end
function smenu:enter()
	print("entered menu")
	loadWorld()
end
function smenu:keyreleased(key)
    if key == ' ' then
		Gamestate.switch(sgame)
	end
end

function sdone:init()
	self.bg = love.graphics.newImage('done.png')
end
function sdone:enter()
	print("entered done")
end
function sdone:draw()
	love.graphics.setColor(255,255,255,255)
    love.graphics.draw(self.bg, 0, 0)
end
function sdone:keyreleased(key)
    if key == ' ' then
		Gamestate.switch(smenu)
	end
end

function createSpike(x,y,p)
	return Spike(x,y)
end

function createRat(x,y,p)
	return Rat(x,y)
end

function createStar(x,y,p)
	return Star(x,y)
end

function createGoal(x,y,p)
	return Goal(x,y)
end

function createPlayer(x,y,p,world)
	print("creating player")
	return Player(world:getCamera(), x, y)
end

function loadWorld(file)
	local thefile = file or "level.tmx"
	print("loading.. ", thefile)
	world = World(thefile, creators)
end

function love.load()
	love.graphics.setBackgroundColor( 100, 149, 237 )
	tilesets:add("ninja.png", 64)
	creators = {spikes=createSpike,rats=createRat,player=createPlayer,stars=createStar,goal=createGoal}
	loadWorld()
	-- world:add(Box(100, 100, 50))
	--world:add()
	canplay = 3
	deltat = 1
	acu = 0
	STEP = 0.005
	playMusic("bu-a-banana-and-simplices.it")
	--world.debug_collisons=true
	Gamestate.registerEvents()
    Gamestate.switch(smenu)
end

function sgame:draw()
	world:draw()
	console:draw()
	fps = 1/deltat
	love.graphics.setColor(0,0,0, 255)
	love.graphics.print(string.format("%d", fps), 100, 10)
end

function sgame:update(dt)
	deltat=dt
	if canplay==0 then
		acu = acu + dt
		while acu > STEP do
			world:update(STEP)
			console:update(STEP)
			acu = acu - STEP
			
			if world.data.goal ~= nil then
				if world.data.goal == "done" then
					Gamestate.switch(sdone)
				else
					loadWorld(world.data.goal)
				end
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
		love.event.push("q")
	end
	
	if canplay==0 then
		world:onkey(true, key, unicode)
	end
end

function sgame:keyreleased(key)
	if key == "p" then
		loadWorld()
	end
	world:onkey(false, key, nil)
end

function sgame:mousepressed(x, y, button)
	world:onkey(true, "_"..button, nil)
end

function sgame:mousereleased(x, y, button)
	world:onkey(false, "_"..button, nil)
end