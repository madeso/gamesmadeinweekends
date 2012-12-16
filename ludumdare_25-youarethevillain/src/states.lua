SGame = SetupGamestates(Gamestate.new())

function SGame:draw()
	draw_everything()
end
function SGame:onkey(key, code, down)
	game_onkey(key, code, down)
end
function SGame:update(dt)
	game_update(dt)
end
function SGame:enter()
end
