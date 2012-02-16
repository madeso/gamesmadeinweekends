function love.load()
	printif = false
	time = 0
	
	love.graphics.setBackgroundColor( 100, 149, 237 )
end

function love.draw()
	w,h = love.graphics.getWidth(), love.graphics.getHeight()
	
	x = (math.sin(time)*0.5+0.5) * w
	y = (math.cos(time)*0.5+0.5) * h
	
	love.graphics.line(0,y,w,y)
	love.graphics.line(x,0,x,h)
	
	if printit then
		love.graphics.print("delay!", 20, 10)
	end
end

function love.update(dt)
	time = time + dt
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("q")
	end
	if key == " " then
		printit = true
	end
end