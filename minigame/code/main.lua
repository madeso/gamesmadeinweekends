width = 10
height = 10
local kBoxSize = 32
local kForce = 7
local kMin = 5
local kMaxValue = 10

function playSound(s)
	love.audio.stop(s)
	love.audio.rewind(s)
	love.audio.play(s)
end

function sfx(path)
	return love.audio.newSource(path, "static")
end

function makepoint(x,y)
	local r = {}
	r.x = x
	r.y = y
	return r
end

function newworld()
	world = {}
	local row = {}
	for y=1,height do
		row = {}
		for x=1,width do
			table.insert(row, math.random(kMaxValue) )
		end
		table.insert(world, row)
	end
end


function love.load()
	math.randomseed( os.time() )
	love.graphics.setBackgroundColor( 100, 149, 237 )
	
	lastx,lasty = love.mouse.getPosition()
	dir = true
	
	newworld()
end

function transform(a,b)
	local h,w = love.graphics.getHeight(), love.graphics.getWidth()
	
	local startx = w/2.0 - (kBoxSize*width)/2.0
	local starty = h/2.0 - (kBoxSize*height)/2.0
	
	return startx+kBoxSize*(a-1),starty+kBoxSize*(b-1)
end

function itransform(x,y)
	local h,w = love.graphics.getHeight(), love.graphics.getWidth()
	local startx = w/2.0 - (kBoxSize*width)/2.0
	local starty = h/2.0 - (kBoxSize*height)/2.0
	
	return math.floor((x-startx)/kBoxSize)+1,math.floor((y-starty)/kBoxSize)+1
end



function highlight(x,y)
	local a,b = transform(x,y)
	love.graphics.rectangle("fill", a,b, kBoxSize, kBoxSize)
end

function line(a,b, x,y)
	a,b = transform(a,b)
	x,y = transform(x,y)
	love.graphics.line(a,b,x,y)
end

function alter(x,y,dir)
	if dir then
		return x-kBoxSize*0.5,y
	else
		return x,y-kBoxSize*0.5
	end
end

function dxdy(dir, x,y, one)
	if dir then
		return x+one,y
	else
		return x,y+one
	end
end

function isvalid(x,y)
	if x >= 1 and y >= 1 and x <= width and y <= height then
		return true
	else
		return false
	end
end

function love.draw()
	love.graphics.setColor(0,0,0)
	
	for x=1,width+1 do
		line(x,1,x,height+1)
	end
	for y=1,height+1 do
		line(1,y,width+1,y)
	end
	
	--local x,y = transform(1,1)
	local mx, my = love.mouse.getPosition()
	local dx,dy = mx-lastx, my-lasty
	lastx,lasty = mx,my
	--love.graphics.line(x,y,mx,my)
	
	love.graphics.setColor(255,255,255, 100)
	local x,y = itransform(alter(mx, my, dir))
	local cx,cy = dxdy(dir, x, y, 1)
	local doit = false
	
	if isvalid(x,y) and isvalid(cx,cy) then
		doit = true
	end
	if doit == false then
		cx,cy = dxdy(dir, x, y, -1)
		if isvalid(x,y) and isvalid(cx,cy) then
			doit = true
		end
	end
	if doit then
		highlight(x,y)
		highlight(cx,cy)
	end
	
	love.graphics.setColor(0,0,0, 255)
	local px,py = 0,0
	for ay=1,height do
		for ax=1,width do
			px,py = transform(ax,ay)
			love.graphics.print(world[ay][ax], px+kBoxSize/2,py+kBoxSize/2)
		end
	end
	
	love.graphics.setColor(255,255,255, 255)
	love.graphics.print(x .. ", " .. y, 0, love.graphics.getHeight() - 15)
end

function love.update(dt)
end

function onkey(down, key, unicode)
	if key=='_r' and down then
		dir = not dir
	end
end

-- basic functions:

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("q")
	end
	onkey(true, key, unicode)
end

function love.keyreleased(key)
	onkey(false, key, nil)
end

function love.mousepressed(x, y, button)
	onkey(true, "_"..button, nil)
end

function love.mousereleased(x, y, button)
	onkey(false, "_"..button, nil)
end