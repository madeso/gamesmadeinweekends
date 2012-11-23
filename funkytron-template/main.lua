function Img(src)
	local image = love.graphics.newImage(src)
	image:setFilter('nearest','nearest')
	return image
end

game = {}
require "game"

main = {}
main.bg = love.graphics.newImage("bg.jpg")
main.overlay = love.graphics.newImage("funkytron_overlay.png")
main.paused = false
main.ingame = false
main.index = 0
main.timer = 0
main.colorindex = 0
main.colors = { {255,255,255}, {0,0,255}, {0,255,0}, {255,0,0} }

modes = love.graphics.getModes()
table.sort(modes, function(a, b) return a.width*a.height < b.width*b.height end)

font = love.graphics.newFont("nintendo_nes_font.ttf", 20)
font = love.graphics.newImageFont("font.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"")
love.graphics.setFont(font)

function getmode(i)
	local index = i % (#modes +1)
	if index == 0 then
		return nil
	else
		return modes[index]
	end
end

function love.draw()
	local w, h = love.graphics.getWidth(),love.graphics.getHeight()
	local cx,cy = w/2, h/2
	local ix,iy = main.overlay:getWidth()/2,main.overlay:getHeight()/2
	local dx,dy = cx-ix,cy-iy
	love.graphics.draw(main.bg, 0, 0, 0, w/main.bg:getWidth(),h/main.bg:getHeight())
	love.graphics.push()
	love.graphics.translate(dx+32, dy+32)
	love.graphics.scale(2,2)
	
	if main.ingame == false then
		for drawi=0,5 do
			local grabi = main.index + drawi - 2
			local mode = getmode(grabi)
			local text = ""
			if mode == nil then
				text = "Windowed"
			else
				text = mode.width .. "x" .. mode.height
			end
			
			if grabi == main.index then
				love.graphics.setColor(main.colors[main.colorindex])
			else
				love.graphics.setColor(255,255,255)
			end
			
			love.graphics.print(text, 35, 20+drawi*22)
		end
	else
		game.draw()
	end
	love.graphics.pop()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(main.overlay, dx, dy)
end

function keytransform(key)
	if key == "up" then
		return "u"
	end
	
	if key == "left" then
		return "l"
	end
	
	if key == "right" then
		return "r"
	end
	
	if key == "down" then
		return "d"
	end
	
	if key == " " then
		return "select"
	end
	
	if key == "return" then
		return "start"
	end
	
	if key == "lshift" then
		return "a"
	end
	if key == "rshift" then
		return "a"
	end
	
	if key == "lctrl" then
		return "b"
	end
	if key == "rctrl" then
		return "b"
	end
	
	return nil
end

function love.keypressed(key, unicode)
	if main.ingame == false then
	else
		local tk = keytransform(key)
		if tk ~= nil then
			game.onkey(tk, true)
		end
	end
end

function love.keyreleased(key, unicode)
	if main.ingame == false then
		if key == "up" then
			main.index = main.index - 1
		elseif key == "down" then
			main.index = main.index + 1
		elseif keytransform(key) ~= nil then
			local mode = getmode(main.index)
			if mode == nil then
			else
				-- todo: set to true
				love.graphics.setMode( mode.width, mode.height, false)
			end
			main.ingame = true
		end
	else
		local tk = keytransform(key)
		if tk ~= nil then
			game.onkey(tk, false)
		end
	end
end

function love.focus(f)
	main.gameIsPaused = not f
end

function love.update(dt)
	if main.gameIsPaused then return end

	if main.ingame == false then
		main.timer = main.timer + dt
		if main.timer > 0.05 then
			main.timer = 0
			main.colorindex = (main.colorindex % #main.colors)+1
		end
	else
		game.update(dt)
	end
end