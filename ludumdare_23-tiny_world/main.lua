require "world"
require "player"
require "tilesets"
require "console"
require "spike"

function createSpike(x,y,p)
	return Spike(x,y)
end

function love.load()
	love.graphics.setBackgroundColor( 100, 149, 237 )
	tilesets:add("ninja.png", 32)
	world = World("level.tmx", {spikes=createSpike} )
	-- world:add(Box(100, 100, 50))
	world:add(Player(world:getCamera(), 400, 20))
	canplay = 3
	deltat = 1
	acu = 0
	STEP = 0.005
	world.debug_collisons=true
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