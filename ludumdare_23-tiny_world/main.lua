function playSound(s)
	love.audio.stop(s)
	love.audio.rewind(s)
	love.audio.play(s)
end

function sfx(path)
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

function createSpike(x,y,p)
	return Spike(x,y)
end

function createRat(x,y,p)
	return Rat(x,y)
end

function createStar(x,y,p)
	return Star(x,y)
end

function createPlayer(x,y,p,world)
	print("creating player")
	return Player(world:getCamera(), x, y)
end

function love.load()
	love.graphics.setBackgroundColor( 100, 149, 237 )
	tilesets:add("ninja.png", 64)
	world = World("level.tmx", {spikes=createSpike,rats=createRat,player=createPlayer,stars=createStar} )
	-- world:add(Box(100, 100, 50))
	--world:add()
	canplay = 3
	deltat = 1
	acu = 0
	STEP = 0.005
	--playMusic("bu-a-banana-and-simplices.it")
	--world.debug_collisons=true
end

function love.draw()
	world:draw()
	console:draw()
	fps = 1/deltat
	love.graphics.setColor(0,0,0, 255)
	love.graphics.print(string.format("%d", fps), 100, 10)
end

function love.update(dt)
	deltat=dt
	if canplay==0 then
		acu = acu + dt
		while acu > STEP do
			world:update(STEP)
			console:update(STEP)
			acu = acu - STEP
		end
	else
		print(dt)
		canplay = canplay - 1
		world:update(0)
	end
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("q")
	end
	
	if canplay==0 then
		world:onkey(true, key, unicode)
	end
end

function love.keyreleased(key)
	world:onkey(false, key, nil)
end

function love.mousepressed(x, y, button)
	world:onkey(true, "_"..button, nil)
end

function love.mousereleased(x, y, button)
	world:onkey(false, "_"..button, nil)
end