maxitemtime = 1.5
speed = 0.25
reactiontime = 0.1
totalreaction = speed*reactiontime
reaction = totalreaction/2

function add(at)
	item = {}
	item.position = at
	item.time = -1
	item.passed = false
	table.insert(items, item)
end

function playSound(s)
	love.audio.stop(s)
	love.audio.rewind(s)
	love.audio.play(s)
end

function sfx(path)
	return love.audio.newSource(path, "static")
end

function love.load()
	printif = false
	round = 0
	
	hit = sfx('hit.wav')
	miss = sfx('miss.wav')
	passed = sfx('passed.wav')
	
	love.graphics.setBackgroundColor( 100, 149, 237 )
	w,h = love.graphics.getWidth(), love.graphics.getHeight()
	
	spacing = 20
	drawsize = math.min(w,h)-(spacing*2)
	
	items = {}
	add(0.5)
	add(0.2)
	add(0.9)
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
	
	for i,item in ipairs(items) do
		cx,cy = getxy(item.position)
		love.graphics.circle("line", cx, cy, 5)
		if item.time >= 0 then
			love.graphics.setColor(255, 255, 255, 255-255*item.time/maxitemtime)
			love.graphics.circle("line", cx, cy, item.time*100, 20)
			love.graphics.setColor(255, 255, 255, 255)
		end
	end
end

function love.update(dt)
	local lastround = round
	round = round + dt*0.25
	
	for i,item in ipairs(items) do	
		if item.position > lastround and round > item.position then
			-- passed
			playSound(passed)
			item.time = 0
		end
		
		if item.time >= 0 then
			item.time = item.time + dt
			if item.time > maxitemtime then
				item.time = -1
			end
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
		local col = false
		for i,item in ipairs(items) do
			if round > item.position-reaction and round < item.position+reaction then
				col = true
			end
		end
		
		if col then
			playSound(hit)
		else
			playSound(miss)
		end
	end
end