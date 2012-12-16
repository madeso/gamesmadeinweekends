SGame = SetupGamestates(Gamestate.new())
SFadeInToWorld = SetupGamestates(Gamestate.new())
SEnterTitle = SetupGamestates(Gamestate.new())
SPressStart = SetupGamestates(Gamestate.new())
SMeny = SetupGamestates(Gamestate.new())

function basic_scroll(dt)
	player:move(0.01*dt)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
				Gamestate.switch(SGame)
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
	draw_everything(self.worldtime, true, true, true)
end
function SGame:onkey(key, code, down)
	game_onkey(key, down)
end
function SGame:update(dt)
	self.worldtime = self.worldtime + dt * 0.01
	if self.worldtime > 1 then
		self.worldtime = 1
	end
	
	game_update(dt)
end
function SGame:enter()
	self.worldtime = 0
end

--------------------------------------------------------------------------------
