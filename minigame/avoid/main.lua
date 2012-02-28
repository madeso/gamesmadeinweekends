Coll = 10
R = Coll*4
Speed = 200
Influence = 3
TotalTime = 0.3
Life = 1
ExplostionIncrease = 150

function add(x,y)
	item = {}
	item.x = x
	item.y = y
	item.xx,item.xy = 0,0
	table.insert(items, item)
end

function exp(x,y, life)
	item = {}
	item.x = x
	item.y = y
	item.life = life
	item.size = 0
	table.insert(bangs, item)
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
	local side = math.random(1,4)
	if side == 1 then
		return 0,math.random()*h
	elseif side == 2 then
		return w,math.random()*h
	elseif side==3 then
		return math.random()*w,0
	else
		return math.random()*w,h
	end
end

function newgame()
	items = {}
	bangs = {}
	timer = -0.5
	killedby = 0
end

function love.load()
	created = sfx('created.wav')
	die = sfx('die.wav')
	restart = sfx('restart.wav')
	
	love.graphics.setBackgroundColor( 100, 149, 237 )
	w,h = love.graphics.getWidth(), love.graphics.getHeight()
	
	newgame()
end

function love.draw()
	love.graphics.print(#items,10,10)
	love.graphics.setColor(255, 255, 255, 255)
	for i,item in ipairs(items) do
		local cx,cy = item.x, item.y
		if i==killedby then
			love.graphics.setColor(255, 0, 0, 255)
			love.graphics.circle("fill", cx, cy, Coll)
			love.graphics.setColor(255, 255, 255, 255)
		else
			love.graphics.circle("line", cx, cy, Coll)
		end
		--love.graphics.circle("line", cx, cy, R)
		love.graphics.line(item.x,item.y, item.x+item.xx, item.y+item.xy)
	end
	
	for i,item in ipairs(bangs) do
		if item.life > 0 then
			love.graphics.circle("line", item.x, item.y, item.size)
		end
	end
end

function avoid(cx,cy, x,y)
	return cx-x,cy-y
end
function lengths(x,y)
	return x*x+y*y
end

function iswithin(cx,cy, r, x, y)
	local d = lengths(avoid(cx,cy,x,y))
	return math.sqrt(d)/r
end

function avoidance(noti,ix,iy, inf)
	local x,y = 0,0
	local sl = 0
	local xx,yy = 0,0
	for i,item in ipairs(items) do
		if i ~= noti then
			sl = iswithin(ix,iy, R, item.x, item.y)
			if sl <= 1 then
				sl = 1-sl
				xx,yy = avoid(ix,iy, item.x, item.y)
				x,y = x+xx*sl,y+yy*sl
			end
		end
	end
	return x*inf,y*inf
end

function remove_if(list, func)
	local toremove = {}
	for i,item in ipairs(bangs) do
		if func(item) then
			table.insert(toremove, i)
		end
	end
	for i=#toremove,1 do
		table.remove(list,i)
	end
end

function is_bang_dead(bang)
	if bang.life <= 0 then
		return true
	else
		return false
	end
end

function love.update(dt)
	if killedby == 0 then
		timer = timer + dt
		if timer > TotalTime then
			timer = timer - TotalTime
			playSound(created)
			add(randomPosition())
		end
		
		local mx, my = love.mouse.getPosition()
		local dx,dy = 0,0
		local xx,xy = 0,0
		local l = 0
		for i,item in ipairs(items) do
			dx,dy = mx-item.x, my-item.y
			xx,xy = avoidance(i, item.x, item.y, Influence)
			dx,dy=dx+xx,dy+xy
			item.xx,item.xy = xx,xy
			l = math.sqrt(dx*dx+dy*dy)
			dx,dy = Speed*dt*dx/l, Speed*dt*dy/l
			item.x,item.y = item.x+dx, item.y+dy
			
			if iswithin(item.x,item.y,Coll,mx,my)<1 then
				killedby = i
				playSound(die)
			end
		end
		
		for i,item in ipairs(bangs) do
			if item.life > 0 then
				item.life = item.life - dt
				item.size = item.size + dt * ExplostionIncrease
			end
		end
		
		remove_if(bangs, is_bang_dead)
	end
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("q")
	end
	if key == " " then
		playSound(restart)
		newgame()
	end
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	if button=="l" then
		exp(x,y, Life)
	end
end