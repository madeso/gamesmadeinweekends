SGame = SetupGamestates(Gamestate.new())
SFadeInToWorld = SetupGamestates(Gamestate.new())
SEnterTitle = SetupGamestates(Gamestate.new())
SPressStart = SetupGamestates(Gamestate.new())
SMeny = SetupGamestates(Gamestate.new())
SMenyToBlack = SetupGamestates(Gamestate.new())
SFadeIntoGame = SetupGamestates(Gamestate.new())
SIngame = SetupGamestates(Gamestate.new())
SMoveDeadPlayer = SetupGamestates(Gamestate.new())
SDeadMeny = SetupGamestates(Gamestate.new())

function basic_scroll(dt)
	player:move(0.01*dt)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function SDeadMeny:draw()
	draw_gameover(1)
	
	draw_meny(2)
	draw_meny_item(0, self.index, "New Game")
	draw_meny_item(1, self.index, "Quit to meny")
end

function SDeadMeny:update(dt)
end
function SDeadMeny:enter()
	self.index = 0
end
function SDeadMeny:onkey(key, code, down)
	if down then
		if meny_isaction(key) then
			if self.index == 0 then
				-- todo better state
				Gamestate.switch(SFadeIntoGame)
			elseif self.index == 1 then
				-- todo better state
				Gamestate.switch(SMeny)
			end
		else
			self.index = meny_changeindex(key, self.index, 2)
		end
	end
end

--------------------------------------------------------------------------------

function draw_gameover(timer)
	draw_everything(global_worldtime, true, false, true)
	
	love.graphics.setColor(0,0,0,255*timer)
	draw_screen()
	
	love.graphics.setColor(255,255,255,255)
	
	local dist = WORLDSIZE+PLAYERSIZE
	local pos = -math.pi * 0.5
	local x = dist * math.cos(pos)
	local y = dist * math.sin(pos)
	
	local worldy = WORLDY + WORLDYCHANGE * global_worldtime
	local cam = Camera(0,-worldy, 1, 0)
	cam:attach()
	tiles:start()
	tiles:draw(11,x - timer * 150,y, player.dir, 1, 0)
	tiles:stop()
	cam:detach()
end

function SMoveDeadPlayer:draw()
	draw_gameover(self.timer)
end

function SMoveDeadPlayer:update(dt)
	self.timer = self.timer + dt
	if self.timer > 1 then
		Gamestate.switch(SDeadMeny)
	end
end
function SMoveDeadPlayer:enter()
	self.timer = 0
end
function SMoveDeadPlayer:onkey(key, code, down)
end

--------------------------------------------------------------------------------

function SIngame:draw()
	draw_everything(global_worldtime, true, true, true)
	love.graphics.setColor(0,0,0,100)
	draw_screen()
	love.graphics.setColor(255,255,255,255)
	
	draw_meny(2)
	draw_meny_item(0, self.index, "Continue")
	draw_meny_item(1, self.index, "Abort")
end

function SIngame:update(dt)
end
function SIngame:enter()
	self.index = 0
end
function SIngame:onkey(key, code, down)
	if down then
		if meny_isaction(key) then
			if self.index == 0 then
				Gamestate.switch(SGame)
			elseif self.index == 1 then
				-- todo correct state
				Gamestate.switch(SMeny)
			end
		else
			self.index = meny_changeindex(key, self.index, 2)
		end
	end
end

--------------------------------------------------------------------------------

function SFadeIntoGame:draw()
	draw_everything(0, true, true, true)
	
	love.graphics.setColor(0,0,0,255*(1-self.timer))
	draw_screen()
end

function SFadeIntoGame:update(dt)
	--basic_scroll(dt)
	self.timer = self.timer + dt*1
	if self.timer > 1 then
		Gamestate.switch(SGame)
	end
end
function SFadeIntoGame:enter()
	self.timer = 0
	newgame()
end
function SFadeIntoGame:onkey(key, code, down)
end

--------------------------------------------------------------------------------

function SMenyToBlack:draw()
	draw_everything(0, false, false, false)
	draw_title(1)
	
	-- direct copy from meny
	draw_meny(2)
	draw_meny_item(0, 0, "New Game")
	draw_meny_item(1, 0, "Quit")
	
	love.graphics.setColor(0,0,0,255*self.timer)
	draw_screen()
end

function SMenyToBlack:update(dt)
	basic_scroll(dt)
	self.timer = self.timer + dt*1
	if self.timer > 1 then
		Gamestate.switch(SFadeIntoGame)
	end
end
function SMenyToBlack:enter()
	self.timer = 0
end
function SMenyToBlack:onkey(key, code, down)
end

--------------------------------------------------------------------------------

function SMeny:draw()
	draw_everything(0, false, false, false)
	draw_title(1)
	
	draw_meny(2)
	draw_meny_item(0, self.index, "New Game")
	draw_meny_item(1, self.index, "Quit")
end

function SMeny:update(dt)
	basic_scroll(dt)
end
function SMeny:enter()
	self.index = 0
	print("entered meny")
end
function SMeny:onkey(key, code, down)
	print(key, down)
	if down then
		if meny_isaction(key) then
			if self.index == 0 then
				Gamestate.switch(SMenyToBlack)
			elseif self.index == 1 then
				love.event.quit()
			end
		else
			self.index = meny_changeindex(key, self.index, 2)
		end
	end
end

--------------------------------------------------------------------------------

function SPressStart:draw()
	draw_everything(0, false, false, false)
	draw_title(1)
	
	love.graphics.setColor(255, 255, 255, 255)
	if self.timer < 0.5 then
		love.graphics.print("PRESS ANY KEY", 300, 550, 0, 2)
	end
end

function SPressStart:update(dt)
	self.timer = self.timer + dt*1
	if self.timer > 1 then
		self.timer = self.timer - 1
	end
	basic_scroll(dt)
end
function SPressStart:enter()
	self.timer = 0
end
function SPressStart:onkey()
	Gamestate.switch(SMeny)
end

--------------------------------------------------------------------------------

function SEnterTitle:draw()
	draw_everything(0, false, false, false)
	draw_title(self.timer)
end

function SEnterTitle:update(dt)
	self.timer = self.timer + dt*1
	if self.timer > 1 then
		Gamestate.switch(SPressStart)
	end
	basic_scroll(dt)
end
function SEnterTitle:enter()
	self.timer = 0
end
function SEnterTitle:onkey()
end

--------------------------------------------------------------------------------

function SFadeInToWorld:draw()
	draw_everything(0, false, false, false)
	love.graphics.setColor(0,0,0,255*(1-self.timer))
	draw_screen()
end

function SFadeInToWorld:update(dt)
	self.timer = self.timer + dt*1
	if self.timer > 1 then
		Gamestate.switch(SEnterTitle)
	end
	basic_scroll(dt)
end
function SFadeInToWorld:enter()
	self.timer = 0
end
function SFadeInToWorld:onkey()
end

--------------------------------------------------------------------------------

function SGame:draw()
	draw_everything(global_worldtime, true, true, true)
end
function SGame:onkey(key, code, down)
	game_onkey(key, down)
end
function SGame:update(dt)
	global_worldtime = global_worldtime + dt * 0.01
	if global_worldtime > 1 then
		global_worldtime = 1
	end
	
	game_update(dt)
end
function SGame:enter()
end

--------------------------------------------------------------------------------
