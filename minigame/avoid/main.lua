Coll = 10
R = Coll*4
Speed = 150
Influence = 3
TotalTime = 0.3
Life = 1.0
ChargeSpeed = 0.3
ExplostionIncrease = 350
BangLifeReduction = 0.7
ScoreAffect = 100
ScoreSpeed = Speed*3
ChargeModifer = 1.7
CreationModifier = 1.4
ExplosionNum = 25

function add(x,y)
	local item = {}
	item.x = x
	item.y = y
	item.dead = false
	item.xx,item.xy = 0,0
	table.insert(items, item)
end

function adds(x,y)
	local item = {}
	item.x = x
	item.y = y
	item.dead = false
	table.insert(score, item)
end

function exp(x,y, life)
	local item = {}
	item.x = x
	item.y = y
	item.life = life
	item.maxlife = life
	item.size = 0
	table.insert(bangs, item)
	playSound(explosion)
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
	score = {}
	points = 0
	charge = 0
	down = false
	mx, my = love.mouse.getPosition()
end

function love.load()
	created = sfx('created.wav')
	die = sfx('die.wav')
	restart = sfx('restart.wav')
	explosion = sfx('explosion.wav')
	point = sfx('point.wav')
	
	love.graphics.setBackgroundColor( 100, 149, 237 )
	w,h = love.graphics.getWidth(), love.graphics.getHeight()
	
	newgame()
end

function love.draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(points,10,10)
	
	if down then
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.circle("line", mx, my, charge*ExplostionIncrease, ExplosionNum)
	end
	
	love.graphics.setColor(0, 0, 255, 70)
	for i,item in ipairs(score) do
		local cx,cy = item.x, item.y
		love.graphics.circle("line", cx, cy, Coll)
	end
	
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
		--love.graphics.line(item.x,item.y, item.x+item.xx, item.y+item.xy)
	end
	
	for i,item in ipairs(bangs) do
		if item.life > 0 then
			love.graphics.setColor(0, 255, 0, 255*item.life/item.maxlife)
			love.graphics.circle("line", item.x, item.y, item.size, ExplosionNum)
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
	for i,item in ipairs(list) do
		if func(item) then
			table.insert(toremove, i)
		end
	end
	local i = 0
	while #toremove ~= 0 do
		i = table.remove(toremove)
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

function is_item_dead(aa)
	return aa.dead
end

function love.update(dt)
	if killedby == 0 then
		if down then
			if charge < Life then
				charge = charge + ChargeSpeed * dt
			else
				charge = Life
			end
		end
		
		timer = timer + dt * (1+charge*CreationModifier)
		if timer > TotalTime then
			timer = timer - TotalTime
			playSound(created)
			add(randomPosition())
		end
		
		mx, my = love.mouse.getPosition()
		local dx,dy = 0,0
		local xx,xy = 0,0
		local l = 0
		local lspe = 0
		
		for bi,bang in ipairs(bangs) do
			for i,item in ipairs(items) do
				if iswithin(bang.x,bang.y, bang.size, item.x,item.y)<1 then
					item.dead = true
					item.bang = bang.maxlife
				end
			end
			
			
			if bang.life > 0 then
				bang.life = bang.life - dt
				bang.size = bang.size + dt * ExplostionIncrease
			end
		end
		
		for i, item in ipairs(items) do
			if item.dead then
				exp(item.x, item.y, item.bang * BangLifeReduction)
				adds(item.x, item.y)
			end
		end
		
		remove_if(bangs, is_bang_dead)
		remove_if(items, is_item_dead)
		
		for i,item in ipairs(items) do
			dx,dy = mx-item.x, my-item.y
			xx,xy = avoidance(i, item.x, item.y, Influence)
			dx,dy=dx+xx,dy+xy
			item.xx,item.xy = xx,xy
			l = math.sqrt(dx*dx+dy*dy)
			lspe = Speed * (charge*ChargeModifer+1)
			dx,dy = lspe*dt*dx/l, lspe*dt*dy/l
			item.x,item.y = item.x+dx, item.y+dy
			
			if iswithin(item.x,item.y,Coll,mx,my)<1 then
				killedby = i
				playSound(die)
			end
		end
		
		for i,item in ipairs(score) do
			dx,dy = mx-item.x, my-item.y
			l = math.sqrt(dx*dx+dy*dy)
			lspe = math.max(0, 1-iswithin(item.x,item.y, ScoreAffect, mx,my))
			dx,dy = lspe*ScoreSpeed*dt*dx/l, lspe*ScoreSpeed*dt*dy/l
			item.x,item.y = item.x+dx, item.y+dy
			
			if iswithin(item.x,item.y,Coll,mx,my)<1 then
				item.dead = true
				playSound(point)
				points = points + 1
			end
		end
		
		remove_if(score, is_item_dead)
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
	if killedby == 0 then
		if button=="l" then
			down = true
			charge = 0
		end
	end
end

function love.mousereleased(x, y, button)
	if killedby == 0 then
		if button=="l" then
			down = false
			exp(x,y, charge)
			charge = 0
		end
	end
end