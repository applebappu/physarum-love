bresenham = require "bresenham"

love.window.setTitle("Physarum Polycephalum")

math.randomseed(os.time() - (os.clock() * 1000))

font = love.graphics.newFont("courier.ttf", 20)
love.graphics.setFont(font)

physarum = {
	body_table = {},
	starting_position = {
		x = math.random(15, 20),
		y = math.random(15, 20)
	},
	energy = 18
}

food = {
	location_table = {},
	global_nutrition = 18
}

map = {
	map_table = {},
	board_size = {
		x = 50,
		y = 37
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
				
				local nutrition = food.global_nutrition
				if map.map_table[i][j] == "f" then
					food.location_table[i][j] = {"%", nutrition}
					map.map_table[i][j] = "."
				end
			end
		end
	end
}

directions = {
	{-1, -1}, {0, -1}, {1, -1},
	{-1, 0},  	   {1, 0},
	{-1, 1},  {0 , 1}, {1, 1}
}

global_timer = 0

InitMatrix = function(matrix)
	local m = matrix
	for i = 1, map.board_size.x do
		m[i] = {}
		for j = 1, map.board_size.y do
			m[i][j] = {}
		end
	end
end

ExpandPlasmodium = function()
	for i = 2, (map.board_size.x - 1) do
		for j = 2, (map.board_size.y - 1) do
			if physarum.body_table[i][j] == "p" then
				for n = 1, #directions do
					local target_x = directions[n][1]
					local target_y = directions[n][2]
					local a = i + target_x
					local b = j + target_y

					if map.map_table[a][b] == "." and physarum.energy > 0 and physarum.body_table[a][b] ~= "p" and physarum.body_table[a][b] ~= "~" then
						physarum.body_table[i][j] = "~"
						physarum.body_table[a][b] = "p"
						physarum.energy = physarum.energy - 1
					end
				end
				global_timer = 0
			end
		end
	end
end

ProcessNutrients = function()
	for i = 2, (map.board_size.x - 1) do
		for j = 2, (map.board_size.y - 1) do
			if food.location_table[i][j][1] == "%" and (physarum.body_table[i][j] == "p" or physarum.body_table[i][j] == "~") then
				physarum.energy = physarum.energy + 1
				food.location_table[i][j][2] = food.location_table[i][j][2] - 1
				global_timer = 0
			end
		end
	end
end

ConsolidatePlasmodium = function()
	-- go through the map, gathering the positions of where food overlaps with the physarum
	local food_network = {}
	local ideal_path_list = {}
	local ideal_path_entry = {}
	
	for i = 1, #food.location_table do
		for j = 1, #food.location_table[i] do
			if food.location_table[i][j][1] == "%" and (physarum.body_table[i][j] == "p" or physarum.body_table[i][j] == "~") then
				local entry = {
					x = i, 
					y = j
				}
				table.insert(food_network, entry)
			end
		end
	end

	-- go through the food_network finding paths between entries
	if #food_network % 2 == 0 then -- this will ultimately fail if the total number of food things is odd. but eh
		for i = 1, #food_network, 2 do
			local source = food_network[i]
			local destination = food_network[i + 1]

			direct_path = bresenham.line(source.x, source.y, destination.x, destination.y, "los")
			for m = 1, #direct_path do
				if direct_path[m + 1].map_tile == "#" then
					for n = 1, #directions do
						-- try directions until we get a clear tile,
						-- make that the new source, do another line
						-- store these tiles in ideal_path_entry
					end
				end
			end
		end
	end

	-- once we have a collection of ideal_path_entry items, find the path from each tile to the closest tile in the closest item and scrunch
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
			if food.location_table[i][j][1] == "%" then
				love.graphics.setColor(0,0,0)
				love.graphics.rectangle("fill",  i * map.tile_size,  j * map.tile_size, map.tile_size, map.tile_size)
				if physarum.body_table[i][j] == "p" or physarum.body_table[i][j] == "~" then
					love.graphics.setColor(255/255, 255/255, 0/255)
				else
					love.graphics.setColor(218/255,165/255,32/255)
				end
				love.graphics.print("%", i * map.tile_size, j * map.tile_size)
			elseif physarum.body_table[i][j] == "p" or physarum.body_table[i][j] == "~" then
				love.graphics.setColor(0,0,0)
				love.graphics.rectangle("fill",  i * map.tile_size,  j * map.tile_size, map.tile_size, map.tile_size)
				love.graphics.setColor(255/255, 255/255, 0/255)
				love.graphics.print(physarum.body_table[i][j], i * map.tile_size, j * map.tile_size)
			end
		end
	end
end

function love.update(dt)
	if global_timer >= 1 then
		ExpandPlasmodium()
		ProcessNutrients()
		--ConsolidatePlasmodium()
	end
	global_timer = global_timer + 1 * dt
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.quit()
	end
end
