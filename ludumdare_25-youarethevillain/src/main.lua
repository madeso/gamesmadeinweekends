WORLDSIZE = 300
PLAYERSIZE = 32
WORLDY = 150
WORLDYCHANGE = 250

require "tileset"
Camera = require "hump.camera"

citybg = {}
citynight = {}
citylines = {}
city = 1
worldrotation = 0

worldtime = 0

cam = Camera(0,0)

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
	cam:lookAt(0,-worldy)
	
	cam:attach()
	draw_world()
	cam:detach()
end

function draw_world()
	local nightval = math.max(0.4,1-worldtime)
	love.graphics.setColor(255*nightval,255*nightval,255*nightval)
	love.graphics.draw(citybg[city], 0, 0, worldrotation, 1,1, 512,512)
	love.graphics.setColor(255,255,255, 255 * math.min(1, 2*worldtime))
	love.graphics.draw(citynight[city], 0, 0, worldrotation, 1,1, 512,512)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(citylines[city], 0, 0, worldrotation, 1,1, 512,512)
	
	love.graphics.setColor(255,0,0)
    love.graphics.circle("line", 0, 0, WORLDSIZE)
	love.graphics.circle("line", 0, -WORLDSIZE-PLAYERSIZE, PLAYERSIZE)
	
	tiles:start()
	
	local object = {}
	object.image = 1
	object.dir = 6
	object.pos = worldrotation * 8
	object.drawnight = true
	
	draw_object(object, nightval)
	
	tiles:stop()
end

function draw_object(o, nightval)
	local dist = WORLDSIZE+PLAYERSIZE
	local x = dist * math.cos(o.pos)
	local y = dist * math.sin(o.pos)
	local ang = o.pos + 0.5 * math.pi
	if o.drawnight then
		tiles:draw(o.image,x,y,o.dir, 1, ang, 255, 255*nightval)
	else
		tiles:draw(o.image,x,y,o.dir, 1, ang)
	end
end

function love.update(dt)
	worldrotation = worldrotation + dt * 0.05 * math.pi
	worldtime = worldtime + dt * 0.1
	if worldtime > 1 then
		worldtime = 1
	end
	if worldrotation > 2*math.pi then
		worldrotation = worldrotation - 2*math.pi
	end
end