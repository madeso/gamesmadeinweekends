maxitemtime = 1.5
speed = 0.25
reactiontime = 0.2
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

function randomPosition()
	return math.random()
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
	
	for i=1,4 do
		add(randomPosition())
	end
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
		if item.passed then
			love.graphics.setColor(255, 0, 0, 255)
		else
			love.graphics.setColor(255, 255, 255, 255)
		end
		love.graphics.circle("line", cx, cy, reaction*drawsize)
		love.graphics.setColor(255, 255, 255, 255)
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
			if item.passed then
				item.position = randomPosition()
				item.passed = false
				playSound(miss)
			else
				playSound(passed)
				item.passed = true
				item.time = 0
			end
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
				item.position = randomPosition()
				item.passed = false
			end
		end
		
		if col then
			playSound(hit)
		else
			playSound(miss)
		end
	end
end