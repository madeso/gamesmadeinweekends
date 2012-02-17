-- for sleep
require "socket"

function sleep(sec)
    socket.select(nil, nil, sec)
end

width = 20
height = 20
items = 10
kSolutionTime = 0.05

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

luaprint = print
function print(...)
	luaprint(...)
	--sleep(0.2)
end

function remember(sx,sy,nx,ny)
	local x,y = sx,sy
	local d = {}
	local p = {}
	
	local dx,dy = 0,0
	
	if x > nx then
		dx = -1
	elseif x < nx then
		dx = 1
	end
	
	if y > ny then
		dy = -1
	elseif y < ny then
		dy = 1
	end
	
	
	--print(sx,sy,nx,ny,dx,dy)
	
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

function makepoint(x,y)
	local r = {}
	r.x = x
	r.y = y
	return r
end

function listValidPositions(sx,sy)
	local r = {}
	
	local x, y = 0,0
	
	for x=1,width do
		if x ~= sx then
			table.insert(r, makepoint(x,sy))
		end
	end
	
	for y=1,height do
		if y ~= sy then
			table.insert(r, makepoint(sx,y))
		end
	end
	
	return r
end

function fillworld()
	local x,y = playerx, playery
	local nx, ny
	
	local done = false
	
	local positions = {}
	local pos = {}
	local generate = true
	local randomindex = 0
	local i = 0
	
	repeat
		if generate then
			positions = listValidPositions(x,y)
			print("generated valid positions")
			generate = false
		end
		
		if #positions == 0 then
			print("no more valid positions, failing...")
			return false
		end
		
		
		randomindex = math.random(#positions)
		pos = positions[ randomindex ]
		nx,ny = pos.x, pos.y
		
		if world[nx][ny] == 0 and isfree(nx,ny) then
			remember(x,y,nx,ny)
			x,y = nx,ny
			world[x][y] = 1
			itemsleft = itemsleft + 1
			
			i = i+1
			if i>items then
				done = true
			end
			
			generate = true
			print "placing item"
		else
			print("invalid suggestion, retrying", #positions)
			table.remove(positions, randomindex)
		end
	until done
	
	-- for solution traversing
	p = {}
	p.x=x
	p.y=y
	table.insert(solution, p)
	
	print("filling world: done")
	return true
end

function dogenworld()
	print("initializing................................................")
	world = {}
	mem = {}
	solution = {}
	
	playerx = math.random(width)
	playery = math.random(height)
	canplay = true
	canplaytext = ""
	
	solutionindex = 1
	solutiontimer = 0
	
	itemsleft = 0
	
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
	
	
	return fillworld()
end

function genworld()
	local complete = false
	print("generating world........")
	repeat
		complete = dogenworld()
	until complete
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
		love.graphics.print(canplaytext, 20, 10)
	end
	
	love.graphics.setColor(255,255,255, 255)
	-- comment this this introduce a delay/sleep in rendering
	love.graphics.print("game & idea by sirGustav, sound by sfxr, music by ", 0, love.graphics.getHeight() - 15)
end

function gameover()
	canplay = false
	canplaytext = "Game over. Press space to restart."
	playSound(sDie)
end

function win()
	canplay = false
	canplaytext = "Level completed. Press space to restart"
	--playSound(sDie)
end

function score()
	playSound(sScore)
	itemsleft = itemsleft -1
	if itemsleft == 0 then
		win()
	end
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