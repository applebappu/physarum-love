--[[
	PHYSARUM POLYCEPHALUM

	Physarum owns.  This is a simulation of their behavior, modeled on a grid.

	It's a pathfinding experiment, but also physarum polycephalum is just
	really cool and I like them a lot.

	- Jo

	Physarum life cycle (arbitrarily starting with mature plasmodium):
	1. mature plasmodium. expands, looks for nutrients, does cool stuff
	1a. if the habitat is too dry, becomes a sclerotia (waits for moisture)
	2. under stress, sporangia formation begins
	3. young sporangium
	4. the mature sporangium releases spores (at which point, the physarum is considered haploid)
	5. when the spore lands and germinates, it releases cells
	5a. if cell hits nutrients, it becomes ameoboid initially (then flagellates)
	5b. if not, it grows flagella and looks for nutrients initially (then ameoba....ates?)
	6. when 2 flagellated cells find each other, they fuse cytoplasma and fertilize each other
	7. fused fertilized cells are a zygote (and the physarum becomes diploid again)
	8. the zygote feeds and develops into a young plasmodium
	9. young plasmodium becomes mature plasmodium with time/nutrients

	In terms of simplified simulation:
	1. the plasmodium, goes around until it runs out of food
	2. the spores, move randomly for a while then burst, spawning entities
	3. the moving entities, which make new plasmodium when they meet if they have enough energy
]]

love.window.setTitle("Physarum Polycephalum")

math.randomseed(os.time() - (os.clock() * 1000))

font = love.graphics.newFont("courier.ttf", 20)
love.graphics.setFont(font)

physarum = {
	body_table = {},
	starting_position = {
		x = math.random(10,20),
		y = math.random(10,20)
	},
	energy = 10
}

food = {
	location_table = {},
	nutrition = 5
}

map = {
	map_table = {},
	board_size = {
		x = 38,
		y = 28
	},
	tiles = {"#","#",".",".",".",".",".","f","#","#"},
	tile_size = 20,

	RandomMap = function()
		local noise_map = {}
		
		for i = 1, map.board_size.x do
			noise_map[i] = {}
			for j = 1, map.board_size.y do
				noise_map[i][j] = math.floor(10 * ( love.math.noise( i + math.random(1, 9), j + math.random(1, 9) ) ) ) + 1
				map.map_table[i][j] = map.tiles[noise_map[i][j]]

				if i == 1 or j == 1 or i == map.board_size.x or j == map.board_size.y then
					map.map_table[i][j] = "#"
				end

				if map.map_table[i][j] == "f" then
					food.location_table[i][j] = "%"
					map.map_table[i][j] = "."
				end
			end
		end
	end
}

InitMatrix = function(matrix)
	local m = matrix
	for i = 1, map.board_size.x do
		m[i] = {}
		for j = 1, map.board_size.y do
			m[i][j] = {}
		end
	end
end

SpreadPlasmodium = function()
	for i = 1, map.board_size.x do
		for j = 1, map.board_size.y do
			if physarum.body_table[i][j] == "p" then
				if map.map_table[i - 1][j - 1] ~= "#" and physarum.energy >= 1 then
					physarum.body_table[i - 1][j - 1] = "p"
					physarum.energy = physarum.energy - 1
				end
			end
		end
	end
end

-- MAIN CODE --
InitMatrix(physarum.body_table)
InitMatrix(food.location_table)
InitMatrix(map.map_table)

map.RandomMap()

physarum.body_table[physarum.starting_position.x][physarum.starting_position.y] = "p"
map.map_table[physarum.starting_position.x][physarum.starting_position.y] = "."

function love.draw()
	for i = 1, map.board_size.x do
		for j = 1, map.board_size.y do
			love.graphics.setColor(255,255,255)
			love.graphics.print(map.map_table[i][j], i * map.tile_size, j * map.tile_size)
			if food.location_table[i][j] == "%" then
				love.graphics.setColor(0,0,0)
				love.graphics.rectangle("fill",  i * map.tile_size,  j * map.tile_size, map.tile_size, map.tile_size)
				love.graphics.setColor(218/255,165/255,32/255)
				love.graphics.print("%", i * map.tile_size, j * map.tile_size)
			elseif physarum.body_table[i][j] == "p" then
				love.graphics.setColor(0,0,0)
				love.graphics.rectangle("fill",  i * map.tile_size,  j * map.tile_size, map.tile_size, map.tile_size)
				love.graphics.setColor(255/255, 255/255, 0/255)
				love.graphics.print(physarum.body_table[i][j], i * map.tile_size, j * map.tile_size)
			end
		end
	end
end

function love.update(dt)

end

function love.keyreleased(key)
	if key == "escape" then
		love.event.quit()
	end
end
