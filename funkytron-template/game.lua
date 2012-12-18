local tween = require 'tween'

function game.draw()
	love.graphics.setColor(color)
	love.graphics.rectangle('fill', 0, 0, 256, 224 )
	love.graphics.setColor(flash)
	love.graphics.rectangle('fill', 0, 0, 256, 224 )
	love.graphics.setColor(255,255,255,255)
end

TIMER = 0.5
TWEEN = 'outInCirc'

timer = TIMER
color = {0,0,0}
flash = {255,255,255,0}

function game.update(dt)
	tween.update(dt)
	
	timer = timer + dt
	if timer > TIMER then
		timer = 0
		tween(TIMER, color, {math.random(0,255),math.random(0,255),math.random(0,255)}, TWEEN)
		-- red = math.random(0,255)
		-- green = math.random(0,255)
		-- blue = math.random(0,255)
	end
end

function game.onkey(key, down)
	if down==false then return end
	flash = {255,255,255,255}
	tween(0.5, flash, {255,255,255,0}, 'inOutCubic')
end