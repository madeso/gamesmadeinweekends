width = 20
height = 20
items = 20
steps = 7

kSolutionTime = 0.05
--math.floor(width/2)

function playSound(s)
	love.audio.stop(s)
	love.audio.rewind(s)
	love.audio.play(s)
end

function sfx(path)
	return love.audio.newSource(path, "static")
end

function isfree(x,y)
	if playerx ==x and playery == y then
		return false
	end
	
	return mem[x][y] == false
end

function remember(sx,sy,dx,dy,nx,ny)
	local x,y = sx,sy
	local d = {}
	local p = {}
	repeat
		-- for map generation
		mem[x][y] = true
		
		-- for solution traversing
		p = {}
		p.x=x
		p.y=y
		table.insert(solution, p)
		
		x=x+dx
		y=y+dy
	until x==nx and y==ny
end

function fillworld()
	local x,y = playerx, playery
	local dx,dy = 0,0
	local dir = 1
	local range = 1
	local nx, ny
	
	local i = 1
	local done = false
	
	repeat
		range = math.random(steps)
		dir = math.random(4)
		dx,dy = 0,0
		if     dir == 1 then
			dx = 1
		elseif dir == 2 then
			dx = -1
		elseif dir == 3 then
			dy = 1
		elseif dir == 4 then
			dy = -1
		end
		
		nx,ny = x+dx*range, y+dy*range
		
		if nx <= 0 then nx = 1 end
		if ny <= 0 then ny=1 end
		if nx > width then nx = width end
		if ny > height then ny = height end
		
		if world[nx][ny] == 0 and isfree(nx,ny) then
			remember(x,y,dx,dy,nx,ny)
			x,y = nx,ny
			world[x][y] = 1
			
			i = i+1
			if i>items then
				done = true
			end
			print "placing point"
		else
			print "invalid suggestion, retrying"
		end
	until done
	
	-- for solution traversing
	p = {}
	p.x=x
	p.y=y
	table.insert(solution, p)
end

function genworld()
	world = {}
	mem = {}
	solution = {}
	
	playerx = math.random(width)
	playery = math.random(height)
	canplay = true
	
	solutionindex = 1
	solutiontimer = 0
	
	timer = 0
	dx = 0
	dy = 0
	
	for x=1,width do
		local temp = {}
		local t = {}
		for y=1,height do
			temp[y] = 0
			t[y] = false
		end
		world[x] = temp
		mem[x] = t
	end
	
	
	fillworld()
end

function playMusic(path)
	local m = love.audio.newSource(path, "stream")
	m:setLooping(true)
	m:play()
end

function love.load()
	showsolution = false
	math.randomseed( os.time() )
	love.graphics.setBackgroundColor( 100, 149, 237 )
	
	--up = love.graphics.newImage("up.png")
	--down = love.graphics.newImage("down.png")
	--left = love.graphics.newImage("left.png")
	--right = love.graphics.newImage("right.png")
	
	player = love.graphics.newImage("player.png")
	item = love.graphics.newImage("item.png")
	
	sDie = sfx("die.wav")
	sScore = sfx("score.wav")
	sStep = sfx("step.wav")
	
	playMusic("external.xm")
	
	-- to stop weird delay in rendering when first printing a text
	-- love.graphics.setFont( love.graphics.newFont() )
	
	genworld()
end

function transform(x,y)
	local startx = 20
	local starty = 20
	local step = 18
	
	return startx+step*x,starty+step*y
end

function line(a,b, x,y)
	a,b = transform(a,b)
	x,y = transform(x,y)
	love.graphics.line(a,b,x,y)
end

function love.draw()
	love.graphics.setColor(0,0,0)
	
	for x=1,width+1 do
		line(x,1,x,height+1)
	end
	for y=1,height+1 do
		line(1,y,width+1,y)
	end
	
	love.graphics.setColor(255,255,255)
	love.graphics.draw(player, transform(playerx, playery))
	
	love.graphics.setColor(255,255,255)
	for x=1,width do
		for y=1,height do
			if world[x][y] ~= 0 then
				love.graphics.draw(item, transform(x, y))
			end
		end
	end
	
	if showsolution then
		--local v = solution[solutionindex]
		for i,v in ipairs(solution) do
			if solutionindex == i then
				love.graphics.setColor(255,0,0, 255)
			else
				love.graphics.setColor(0,0,255, 50)
			end
			local a,b = transform(v.x,v.y)
			love.graphics.rectangle("fill", a, b, 16,16)
		end
	end
	
	love.graphics.setColor(255,255,255)
	if canplay == false then
		love.graphics.print("you died", 20, 10)
	end
	
	love.graphics.setColor(255,255,255, 255)
	-- comment this this introduce a delay/sleep in rendering
	love.graphics.print("game & idea by sirGustav, sound by sfxr, music by ", 0, love.graphics.getHeight() - 15)
end

function gameover()
	canplay = false
	playSound(sDie)
end

function score()
	playSound(sScore)
end

function step(x,y)
	playerx = playerx+x
	playery = playery+y
	
	if playerx <= 0 then
		gameover()
		return false
	end
	if playery <= 0 then
		gameover()
		return false
	end
	
	if playerx > width then
		gameover()
		return false
	end
	
	if playery > height then
		gameover()
		return false
	end
	
	if world[playerx][playery] ~=0 then
		world[playerx][playery] = 0
		score()
		return false
	end
	
	playSound(sStep)
	
	return true
end

function love.update(dt)
	if showsolution then
		solutiontimer = solutiontimer + dt
		if solutiontimer > kSolutionTime then
			solutiontimer = solutiontimer - kSolutionTime
			if solutionindex == #solution then
				solutionindex = 1
			else
				solutionindex = solutionindex +1
			end
		end
	end
	if canplay then
		if dx~=0 or dy~=0 then
			if timer <= 0 then
				if step(dx,dy) then
					timer = 0.1
				else
					dx = 0
					dy = 0
					timer = 0
				end
			else
				timer = timer - dt
			end
		end
	end
end

function onkey(down, key, unicode)
	if down==true and key==" " then
		genworld()
	end
	
	if canplay then
		if key =='s' then
			showsolution = down
			solutiontimer = -0.5
			solutionindex = 1
		end
		
		if dx~=0 or dy~=0 then
		else
			if down==true and key=="right" then
				dx,dy=1,0
			end
			
			if down==true and key=="left" then
				dx,dy=-1,0
			end
			
			if down==true and key=="up" then
				dx,dy=0,-1
			end
			
			if down==true and key=="down" then
				dx,dy=0,1
			end
		
		end
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