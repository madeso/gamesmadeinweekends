WORLDSIZE = 300
PLAYERSIZE = 32
WORLDY = 150
WORLDYCHANGE = 250

require "tileset"

citybg = {}
citynight = {}
citylines = {}
city = 1
worldrotation = 0

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
	local worldy = WORLDY + WORLDYCHANGE * worldtime
	draw_sky(worldtime)
	
	local nightval = math.max(0.4,1-worldtime)
	
	love.graphics.setColor(255*nightval,255*nightval,255*nightval)
	love.graphics.draw(citybg[city], 400, 300+worldy, worldrotation, 1,1, 512,512)
	love.graphics.setColor(255,255,255, 255 * math.min(1, 2*worldtime))
	love.graphics.draw(citynight[city], 400, 300+worldy, worldrotation, 1,1, 512,512)
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(citylines[city], 400, 300+worldy, worldrotation, 1,1, 512,512)
	
	love.graphics.setColor(255,0,0)
    love.graphics.circle("line", 400, 300+worldy, WORLDSIZE)
	love.graphics.circle("line", 400, 300-WORLDSIZE-PLAYERSIZE+worldy, PLAYERSIZE)
	
	tiles:start()
	local image = 1
	local dir = 6
	local pos = worldrotation * 8
	local drawnight = true
	
	local dist = WORLDSIZE+PLAYERSIZE
	local x = dist * math.cos(pos)
	local y = dist * math.sin(pos)
	local ang = pos + 0.5 * math.pi
	if drawnight then
		tiles:draw(image,400+x,300+worldy+y,dir, 1, ang, 255, 255*nightval)
	else
		tiles:draw(image,400+x,300+worldy+y,dir, 1, ang)
	end
	tiles:stop()
end

function love.update(dt)
	worldrotation = worldrotation + dt * 0.05 * math.pi
	worldtime = worldtime + dt * 0.01
	if worldtime > 1 then
		worldtime = 1
	end
	if worldrotation > 2*math.pi then
		worldrotation = worldrotation - 2*math.pi
	end
end