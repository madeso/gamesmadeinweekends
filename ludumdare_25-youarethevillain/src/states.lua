SGame = SetupGamestates(Gamestate.new())
SFadeInToWorld = SetupGamestates(Gamestate.new())
SEnterTitle = SetupGamestates(Gamestate.new())

function basic_scroll(dt)
	player:move(0.01*dt)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function SEnterTitle:draw()
	draw_everything(0, false, false, false)
	draw_title(self.timer)
end

function SEnterTitle:update(dt)
	self.timer = self.timer + dt*1
	if self.timer > 1 then
		Gamestate.switch(SGame)
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
	game_onkey(key, code, down)
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
