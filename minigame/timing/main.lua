maxitemtime = 1.5
speed = 0.25
reactiontime = 0.1
totalreaction = speed*reactiontime
reaction = totalreaction/2

function love.load()
	printif = false
	round = 0
	
	love.graphics.setBackgroundColor( 100, 149, 237 )
	w,h = love.graphics.getWidth(), love.graphics.getHeight()
	
	spacing = 20
	drawsize = math.min(w,h)-(spacing*2)
	
	item = {}
	item.position = 0.5
	item.time = -1
end

function getposition(x,y)
	return (w-drawsize)/2 + x*drawsize, (h-drawsize)/2 + y*drawsize
end

function getxy(a)
	local p = a * math.pi*2
	return getposition(math.cos(p)*-0.5+0.5, math.sin(p)*-0.5+0.5)
end

function love.draw()
	x,y = getxy(round)
	
	cx,cy = getposition(0.5, 0.5)
	love.graphics.circle("line", cx, cy, drawsize/2, 40)
	love.graphics.line(0,y,w,y)
	love.graphics.line(x,0,x,h)
	
	cx,cy = getxy(item.position)
	love.graphics.circle("line", cx, cy, 5)
	if item.time >= 0 then
		love.graphics.setColor(255, 255, 255, 255-255*item.time/maxitemtime)
		love.graphics.circle("line", cx, cy, item.time*100, 20)
		love.graphics.setColor(255, 255, 255, 255)
	end
	
	if printit then
		love.graphics.print("delay! " .. tostring(round), 20, 10)
	end
end

function love.update(dt)
	local lastround = round
	round = round + dt*0.25
	
	if item.position > lastround and round > item.position then
		-- passed
		item.time = 0
	end
	
	if item.time >= 0 then
		item.time = item.time + dt
		if item.time > maxitemtime then
			item.time = -1
		end
	end
	
	if round > 1 then
		round = round -1
		printit = false
	end
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("q")
	end
	if key == " " then
		if round > item.position-reaction and round < item.position+reaction then
			printit = true
		end
	end
end