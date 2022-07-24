MapHST = class(Module)

function MapHST:Name()
	return "MapHST"
end

function MapHST:internalName()
	return "maphst"
end

local pathGraphs = {}

local mCeil = math.ceil

function MapHST:Init()
	self:EchoDebug('MapHST START')
	self.DebugEnabled = true
	if self.map_loaded then
		return
	end
	self:basicMapInfo()
	self:createGrid()
	self.METALS = map:GetMetalSpots()
	self.GEOS = map:GetGeoSpots()
	self.METALS = self:SimplifyMetalSpots(self.gridSize * 2)-- is a random choice, can be 1 or 9999999999
	self.allSpots = self.ai.tool:tableConcat({self.METALS,self.GEOS})
	self.hotSpots = {}
	self:hotSpotter(self.METALS,self.GEOS)
	self.waterMetals = {}
	self.groundMetals = {}
	self.networks = {} --hold data in a "specific network" area(about GAS (area,mex,geos,trampling)
	self.layers = {} --hold the "global layer" data about a GAS (area,mex,geos,trampling)
	self.startLocations = {}
	self.ai.armyhst.UWMetalSpotCheckUnitType = self.game:GetTypeByName(self.ai.armyhst.UWMetalSpotCheckUnit)
	self:gridAnalisy()
	self:metalScan()
	self:geoScan()
	self:LayerScan()
	self:spotToCellMoveTest()
	self:DrawDebug()
	self.map_loaded = true
	self:EchoDebug('MapHST STOP')
end

function MapHST:basicMapInfo()--capture and set foundamental map info
	self.mapSize = map:MapDimensions()
	self.elmoMapSizeX = self.mapSize.x * 8
	self.elmoMapSizeZ = self.mapSize.z * 8
	self:EchoDebug(self.ai.tool:gcd(self.elmoMapSizeX,self.elmoMapSizeZ))
	self.elmoArea = self.elmoMapSizeX * self.elmoMapSizeZ
	self.gridSize = 256 --math.max( math.floor(math.max(MapHST.mapSize.x * 8, MapHST.mapSize.z * 8) / 128),32)-- don't make grids smaller than 32
	self.gridSizeHalf = self.gridSize / 2
	self.gridSideX = self.elmoMapSizeX / self.gridSize
	self.gridSideZ = self.elmoMapSizeZ / self.gridSize
	self.gridArea = self.gridSideX * self.gridSideZ
	self:EchoDebug("grid size: " .. self.gridSize ..'cell count', self.gridArea,self.gridSideX,self.gridSideZ)
end


function MapHST:createGrid()
	self.GRID = {}
	for X = 1, self.gridSideX do
		if not self.GRID[X] then
			self.GRID[X] = {}
		end
		for Z = 1, self.gridSideZ do
			self.GRID[X][Z] = self:NewCell(X,Z)
		end
	end
end

function MapHST:isInMap(pos)
	if (pos.x <= 0) or (pos.x > self.elmoMapSizeX) or (pos.z <= 0) or (pos.z > self.elmoMapSizeZ) then
		self:EchoDebug("bad position: " .. pos.x .. ", " .. pos.z)
		return nil
	else
		return pos
	end
end

function MapHST:PosToGrid(pos)
	local X = math.ceil(pos.x / self.gridSize)
	local Z = math.ceil(pos.z / self.gridSize)
	if not self.GRID[Z] or not self.GRID[X][Z] then
		self:Warn( X,Z,'is out of GRID')
	end
	return X, Z
end

function MapHST:GridToPos(X,Z)
	local pos = {}
	pos.x = X * self.gridSize - self.gridSizeHalf
	pos.z = Z * self.gridSize - self.gridSizeHalf
	pos.y  = Spring.GetGroundHeight(pos.x,pos.z)
	if not self:isInMap(pos) then
		self:Warn(pos.x,pos.z,'is not in map')
		return
	end
	return pos
end

function MapHST:NewCell(gx, gz)
	local x = (gx * self.gridSize) - self.gridSizeHalf
	local z = (gz * self.gridSize) - self.gridSizeHalf
	local cellPos = {}
	cellPos.x, cellPos.z = x, z
	cellPos.y = Spring.GetGroundHeight(x, z)
	self:isInMap(cellPos)--move here ,is in map!!
	local cell = {}
	cell.POS = cellPos --the cell position
	cell.X = gx --the cell coordinate X on the grid
	cell.Z = gz --the cell coordinate Z on the grid
	cell.moveLayers = self:moveLayerTest(cellPos) --hold the  layers and networks in this cell
	cell.metalSpots = {} --hold the metalSpots of this cell
	cell.geoSpots = {} --hold the geoSpots of this cell
	cell.allSpots = {} --hold all the interesting spots
	cell.trampled = 0 --how many times it is trampled by non-flying units
	return cell
end

function MapHST:areaCells(X,Z,R,grid) -- return alist of cells in range R from a cell
	if not X or not Z then
		self:Warn('no grid XZ for areacells')
	end
	local AC = {}
	R = R or 0
	myself = myself or false
	for x = X - R , X + R,1  do
		for z = Z - R , Z + R,1 do
			if grid[x] and grid[x][z] then
				table.insert(AC, grid[x][z])
			end
		end
	end
	return AC
end

function MapHST:GetCell(X,Z,grid) --accept 1one position({t.x,t.y,t.z}) OR 2two XZ grid coordinate; return a CEll if exist
	if type(X) == 'table' and X.x and X.z then
		grid = Z
		X,Z = self:PosToGrid(X)
	end
	if not grid[X] then
		return
	end
	if not grid[X][Z] then
		--dbgwarn
		return
	end
	return grid[X][Z]
end

function MapHST:getCellsFields(position,fields,range,grid) --return the required list of values of a cell/cells
	if not fields or not position or type(fields) ~= 'table' then
		self:Warn('incomplete or incorrect params for get cells params',fields,position, range)
		return
	end
	range = range or 0
	local X, Z = self:PosToGrid(position)
	local cells = self:areaCells(X,Z,range,grid)
	local value = 0 --VALUE is a total count of all request fields
	local subValues = {} --subValues is the sum of this fields of each asked cell
	for i, f in pairs(fields) do
		subValues[f] = 0
	end
	for index , cell in pairs(cells) do
		for i, field in pairs(fields) do
			value = value + cell[field]
			subValues[field] = subValues[field] + cell[field]
		end
	end
	return value , subValues , cells
end

function MapHST:moveLayerTest(pos)--check where units can stay or not
	local layers = {}
	layers.air = 1
	for layer,unitName in pairs(self.ai.armyhst.mobUnitExampleName) do
		if Spring.TestMoveOrder(self.ai.armyhst.unitTable[unitName].defId, pos.x, pos.y, pos.z,nil,nil,nil,true,false,true) then
			layers[layer] = 0
		else
			layers[layer] = false
		end
	end
	return layers
end

function MapHST:gridAnalisy()--do the first analisy of the grid
	local net = {}
	for X,Zetas in pairs(self.GRID) do
		for Z, CELL in pairs(Zetas) do
			for layer,anteNetwork in pairs(CELL.moveLayers) do--(self.ai.armyhst.mobUnitExampleName) do
				if anteNetwork == 0 then
				--if CELL.moveLayers[layer] and CELL.moveLayers[layer] == 0  then
					if not net[layer] then
						net[layer] = 0
						self.networks[layer] = {}
					end
					net[layer] = net[layer] + 1
					self.networks[layer][net[layer]] = {}
					self.networks[layer][net[layer]].area = 0
					self.networks[layer][net[layer]].metals = {}
					self.networks[layer][net[layer]].geos = {}
					self.networks[layer][net[layer]].allSpots = {}
					self:TopologyFooded(X,Z,layer,net)
				end
			end
		end
	end
	self.networks.air = {}
	self.networks.air[1] = {
		area = self.gridArea,
		metals = {},
		geos = {},
		allSpots = {}
		}

end

function MapHST:LayerScan() --a most approfondite analisy of the layers
	for layer,net in pairs(self.networks) do
		local main = {}
		main[layer] = {}
		main[layer].area = 0
		main[layer].metals = 0
		main[layer].geos = 0
		main[layer].allSpots = 0
		main[layer].ratioArea = 0
		main[layer].ratioMetals = 0
		main[layer].ratioGeos = 0
		for index,network in pairs(net) do
			network.allSpots = self.ai.tool:tableConcat({network.metals,network.geos})
			network.ratioArea = network.area / self.gridArea
			if #network.allSpots == 0 or #self.allSpots == 0 then
				network.ratioSpots = 0
			else
				network.ratioSpots = #network.allSpots / #self.allSpots
			end

			if #network.metals == 0 or #self.METALS == 0 then
				network.ratioMetals = 0
			else
				network.ratioMetals = #network.metals / #self.METALS
			end

			if #network.geos == 0 or #self.GEOS == 0 then
				network.ratioGeos = 0
			else
				network.ratioGeos = #network.geos / #self.GEOS
			end
			self:EchoDebug(layer,'Network :',index,network.area,#network.metals,#network.geos,network.ratioArea,network.ratioMetals,network.ratioGeos)
			main[layer].area 		= main[layer].area + network.area
			main[layer].metals 		= main[layer].metals + #network.metals
			main[layer].geos 		= main[layer].geos + #network.geos
			main[layer].allSpots 	= main[layer].allSpots + #network.metals + #network.geos
		end
		main[layer].ratioArea 	= main[layer].area / self.gridArea
		if main[layer].metals == 0 or #self.METALS == 0 then
			main[layer].ratioMetals = 0
		else
			main[layer].ratioMetals = main[layer].metals / #self.METALS
		end
		if main[layer].geos == 0 or #self.GEOS == 0 then
			main[layer].ratioGeos 	=  0
		else
			main[layer].ratioGeos 	= main[layer].geos / #self.GEOS
		end
		self.layers[layer] = main[layer]

	self:EchoDebug('layers',layer,main[layer].area,main[layer].metals,main[layer].geos,main[layer].ratioArea,main[layer].ratioMetals,main[layer].ratioGeos)
	end
end

function MapHST:TopologyFooded(x, z, layer,net)--rolling on the cell to extrapolate where unit can go
	if x > self.gridSideX or x < 1 or z > self.gridSideZ or z < 1 then
		return
	end
	if self.GRID[x][z].moveLayers[layer] == 0   then
		self.GRID[x][z].moveLayers[layer] = net[layer]
		self.networks[layer][net[layer]].area = self.networks[layer][net[layer]].area + 1
		for X = -1, 1,1 do
			for Z = -1,1,1 do
				if x ~= x + X or z ~= z + Z then
					self:TopologyFooded(x+X,z+Z,layer,net)
				end
			end
		end
	end
end

function MapHST:hotSpotter()
	local spots = {}
	local mirrorspots = {}
	local limit = (self.map:MapDimensions())
	local limit = limit.x/2  + limit.z/2
	for i,v in pairs(self.METALS) do
		table.insert(spots,v)
	end
	for i,v in pairs(self.GEOS) do
		table.insert(spots,v)
	end
	self:EchoDebug('limit',tostring(limit))
	for index1,pos1 in pairs(spots) do
		if spots[index1]  then
			mirrorspots[index1] = {}
			table.insert(mirrorspots[index1],pos1)
			spots[index1] = false
			for index2,pos2 in pairs(spots) do
				if spots[index2] and pos1 ~= pos2 then
					local dist = self.ai.tool:distance(pos1,pos2)
					if dist < limit  and ((pos1.y > 0 and pos2.y > 0) or (pos1.y < 0 and pos2.y < 0)) then
						table.insert(mirrorspots[index1],pos2)
						spots[index2] = false
					end
				end
			end
		end
	end
	for i,v in pairs(mirrorspots) do
		local items = 0
		local x = 0
		local z = 0
		local y = 0
		for ii,vv in pairs(v) do
			items = items+1
			x = x + vv.x
			z = z + vv.z
		end
		x = x / items
		z = z / items
		y = Spring.GetGroundHeight(x,z)
		table.insert(self.hotSpots,{x=x,y=y,z=z,weight = items})
		--Spring.MarkerAddPoint(x,y,z,'hot ' ..items	)
	end
end

function MapHST:SimplifyMetalSpots(number) --reduce the number of metal spots for speed metal maps
	if #self.METALS <= 1024 then-- metal map is too complex, simplify it
		return self.METALS
	end
	local spots = {}
	local spotsCount = 0
	for x = 0, self.elmoMapSizeX - number, number do
		for z = 0, self.elmoMapSizeX - number, number do
			for i,spot in pairs (self.METALS) do
				if spot.x > x and spot.x < x + number and spot.z > z and spot.z < z + number then
					spotsCount = spotsCount + 1
					spots[spotsCount] = spot
					table.remove(self.METALS, i)
					break
				end
			end
		end
	end
	return spots
end

function MapHST:metalScan()--insert GEOS in to the correct CELL and layer's network
	for i, spot in pairs(self.METALS) do
		local CELL = self:GetCell(spot,self.GRID)
		table.insert(CELL.metalSpots,spot)
		for layer,nets in pairs(self.networks) do
			if nets then
				for index,network in pairs(nets) do
	-- 				if network  then
						table.insert(network.metals,spot)
	-- 				end
				end
			end
		end
		if map:CanBuildHere(self.ai.armyhst.UWMetalSpotCheckUnitType, spot) then
			table.insert(self.waterMetals, spot)
		else
			table.insert(self.groundMetals, spot)
		end
	end
end

function MapHST:geoScan()--insert GEOS in to the correct CELL and layer's network
	for i, spot in pairs(self.GEOS) do
		local CELL = self:GetCell(spot,self.GRID)
		table.insert(CELL.geoSpots,spot)
		for layer,nets in pairs(self.networks) do
			if nets then
				for index,network in pairs(nets) do

						table.insert(network.geos,spot)

				end
			end
		end
	end
end

function MapHST:MergePositions(posTable, cutoff, includeNonMerged)
	local list = {} -- make copy to prevent clearing table
	for k, v in pairs(posTable) do table.insert(list, v) end
	self:EchoDebug('#list&cutof',#list .. " " .. cutoff)
	local merged = {}
	while #list > 0 do
		local lp = table.remove(list)
		local pos1 = api.Position()
		pos1.x, pos1.y, pos1.z = lp.x, lp.y, lp.z
		local merge = nil
		for i = #list, 1, -1 do
			local pos2 = list[i]
			local dist = self.ai.tool:Distance(pos1, pos2)
			if dist < cutoff then
				self:EchoDebug("merging " .. pos1.x .. "," .. pos1.z .. " with " .. pos2.x .. "," .. pos2.z .. " -- " .. dist .. " away")
				merge = self.ai.tool:MiddleOfTwo(pos1, pos2)
				pos1 = merge
				table.remove(list, i)
			end
		end
		if merge ~= nil then
			table.insert(merged, merge)
		elseif includeNonMerged then
			table.insert(merged, pos1)
		end
	end
	self:EchoDebug('#merged',#merged)
	return merged
end

function MapHST:spotToCellMoveTest()--check how many time a unit(i chose commander) walk on a CELL, the analisy is from cell to cell foreach cell, CAUTION is heavy computable
	self:EchoDebug('self.spotPathMobRank START')
	local counter = 0
	local utable = self.ai.armyhst.unitTable
	local className = UnitDefNames['corcom'].moveDef.name
	local classID = UnitDefNames['armcom'].id
	local layer = 'amp'
	local doing = {}
	self.ttt={trampled = 0}
	--for index , spotPos in pairs(spot) do
	for X1,Zetas1 in pairs(self.GRID) do
		for Z1 in pairs(Zetas1) do
			self.GRID[X1][Z1].trampled = 1
			--[[for X2,Zetas2 in pairs(self.GRID) do
				for Z2 in pairs(Zetas2) do
					local POS1 = self:GridToPos(X1,Z1)
					local POS2 = self:GridToPos(X2,Z2)
					if X1 ~= X2 or  Z1 ~= Z2 then
						if self.GRID[X1][Z1].moveLayers[layer] == self.GRID[X2][Z2].moveLayers[layer] then
-- 							self:EchoDebug('')
						else
							if Spring.TestMoveOrder(classID,POS1.x,POS1.y,POS1.z) and Spring.TestMoveOrder(classID,POS2.x,POS2.y,POS2.z)then
								if doing[X1..';'..Z1] == X2..';'..Z2  or doing[X2..';'..Z2] == X1..';'..Z1 then
									---
								else
									local dist  = self.ai.tool:distance(POS1,POS2)
									local metapath = Spring.RequestPath(className, POS1.x,POS1.y,POS1.z,POS2.x,POS2.y,POS2.z)
									if metapath then
										local waypoints, pathStartIdx = metapath:GetPathWayPoints()
										if  waypoints and  #waypoints  > 1 then
											local waypointsNumber = #waypoints
											local last = waypoints[#waypoints]
											doing[X2..';'..Z2] = X1..';'..Z1
											doing[X1..';'..Z1] = X2..';'..Z2
											local distance_to_goal = self.ai.tool:DistanceXZ(POS2.x, POS2.z, last[1], last[3])
											if distance_to_goal > self.gridSizeHalf then
												print('WARNING THIS PATH IS INCOMPLETE',POS1.x, POS1.z, last[1], last[3],className,POS2.x,POS2.z,distance_to_goal)
											else
												counter = counter + 1
												map:DrawLine(POS1, POS2, {0,1,1,1}, nil, false, 8 )
												local first = table.remove(waypoints)
												first = {x = first[1],y = first[2],z = first[3]}
												for i,v in pairs(waypoints) do
													local wpos = table.remove(waypoints)
													wpos = {x = wpos[1],y = wpos[2],z = wpos[3]}
													local firstX,firstZ = self:PosToGrid(first)
													local wposX,wposZ = self:PosToGrid(wpos)
													if firstX ~= wposX or firstZ ~= wposZ then
														self.GRID[firstX][firstZ].trampled = self.GRID[firstX][firstZ].trampled +1
														if self.GRID[firstX][firstZ].trampled > self.ttt.trampled then
															self.ttt = self.GRID[firstX][firstZ]
														end
														first = wpos
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end]]
		end
	end
	self:EchoDebug(counter,'path evalutated:', 'most trampled',self.ttt.X,self.ttt.Z,self.ttt.trampled)
end

function MapHST:SetStartLocation()-- find start locations (loading them into air's list for later localization)
	if self.startLocations["air"] == nil then
		self.startLocations["air"] = {}
	end
	self.startLocations["air"][1] = self:GuessStartLocations(self.METALS)
	if self.startLocations["air"][1] ~= nil then
		-- localize start locations into mobility networks
		for i, start in pairs(self.startLocations["air"][1]) do
			self:EchoDebug("start location guessed at: " .. start.x .. ", " .. start.z)
			for layer, net in pairs(self.networks) do
				if layer ~= "air" then -- air list is already filled
					for index, network in pairs(layer) do
						if self.startLocations[layer] == nil then self.startLocations[layer] = {} end
						if self.startLocations[layer][index] == nil then self.startLocations[layer][index] = {} end
						table.insert(self.startLocations[layer][index], start)
					end
				end
			end
		end
	end
end

function MapHST:GuessStartLocations(spots)
	if spots == nil then return end
	if #spots == 0 then
		self:EchoDebug("spot table for start location guessing is empty")
		return
	end
	-- find links
	local spotsCopy = {}
	for i, v in pairs(spots) do table.insert(spotsCopy, v) end
	local minDist = 1000
	local links = {}
	local from = table.remove(spotsCopy)
	while #spotsCopy > 0 do
		local closest = nil
		for i, to in pairs(spotsCopy) do
			local dist = self.ai.tool:Distance(from, to)
			if dist < minDist then
				minDist = dist
				closest = i
			end
			local middle = self.ai.tool:MiddleOfTwo(from, to)
			table.insert(links, {dist = dist, middle = middle})
		end
		if closest ~= nil then
			from = table.remove(spotsCopy, closest)
		else
			from = table.remove(spotsCopy)
		end
	end
	-- look for matches
	local matches = {}
	local tolerance = minDist * 0.5
	local cutoff = minDist + tolerance
	self:EchoDebug("tolerance: " .. tolerance .. "  cutoff: " .. cutoff)
	for i, l in pairs(links) do
		if l.dist < cutoff then
			self:EchoDebug("metal spot link at " .. math.ceil(l.middle.x) .. "," .. math.ceil(l.middle.z) .. " within cutoff with self.ai.tool:distance of " .. math.ceil(l.dist))
			table.insert(matches, l.middle)
		end
	end
	if #matches == 0 then return end
	-- merge matches close to each other
	local merged = self:MergePositions(matches, cutoff, false)
	if #merged < 2 then
		self:EchoDebug("not enough merged, using all matches")
		return matches
	else
		self:EchoDebug("using merged links")
		return merged
	end
end

function MapHST:ClosestFreeMex(unittype, builder, position)--get the closest free metal spot for the request unittype
	position = position or builder:GetPosition()
	local layer, net = self:MobilityOfUnit(builder)
	local builderName = builder:Name()
	local builderPos = builder:GetPosition()
	local uname = unittype:Name()
	local spotPosition = nil
	local spotDistance = math.huge
	for index, spot in pairs(self.networks[layer][net].metals) do
		if self:UnitCanGoHere(builder, spot) then
			if not self.ai.buildsitehst:PlansOverlap(spot, uname) then
				if self.ai.targethst:IsSafeCell(spot, builder) then
					if map:CanBuildHere(unittype, spot) then
						local CELL = self:GetCell(spot,self.ai.targethst.ENEMIES)
						if not CELL or CELL.enemy == 0 then
							local distance = self.ai.tool:distance(position,spot)
-- 							if distance < 300 then
-- 								return spot
-- 							else
							if distance < spotDistance then
								spotPosition = spot
								spotDistance = distance
							end
-- 							end
						end
					end
				end
			end
		end
	end
	return spotPosition
end

function MapHST:ClosestFreeGeo(unittype, builder, position)--get the closest free geo spot for the request unittype
	self:EchoDebug("closestfreegeo for " .. unittype:Name() .. " by " .. builder:Name())
	if not position then position = builder:GetPosition() end
	local layer, net = self:MobilityOfUnit(builder)
	local bname = builder:Name()
	local uname = unittype:Name()
	local bestDistance, bestPos
	for i,p in pairs(self.networks[layer][net].geos) do----(self.GEOS) do
		-- dont use this spot if we're already building there
		if not self.ai.buildsitehst:PlansOverlap(p, uname) and self:UnitCanGoHere(builder, p) and self.map:CanBuildHere(unittype, p) and self.ai.targethst:IsSafeCell(p, builder) then
			local dist = self.ai.tool:Distance(position, p)
			if not bestDistance or dist < bestDistance then
				bestDistance = dist
				bestPos = p
			end
		end
	end
	return bestPos
end

function MapHST:MobilityNetworkHere(mtype, position)
	if not mtype or not position then return nil end
	return self:GetCell(position,self.GRID).moveLayers[mtype]
end

function MapHST:MobilityOfUnit(unit)
	local position = unit:GetPosition()
	local name = unit:Name()
	local mtype = self.ai.armyhst.unitTable[name].mtype
	return mtype, self:MobilityNetworkHere(mtype, position)
end

function MapHST:UnitCanGoHere(unit, position)
	if not unit  or not position then return false end
	local mtype, unet = self:MobilityOfUnit(unit)
	if mtype == 'air' then return true end
	-- check if it's even a valid move order theorically already tested Spring.TestMoveOrder so do not need another
	local pnet = self:MobilityNetworkHere(mtype, position)
	if unet == pnet then
		return true
	end
end

function MapHST:UnitCanGetToUnit(unit1, unit2)
	local position = unit2:GetPosition()
	return self:UnitCanGoHere(unit1, position)
end

function MapHST:MobilitynetworkSizeHere(layer, position)
	if layer == "air" then return self.gridArea end
	local network = self:GetCell(position,self.GRID).moveLayers[layer]
	if layer then
		return self.networks[layer][network].size
	end
end

function MapHST:AccessibleMetalSpotsHere(mtype, position)
-- 	if layer == "air" then return self.METALS end
	local network = self:MobilityNetworkHere(mtype, position)
	if network then
		return self.networks[mtype][network].metals or {}
	end
	return {}

end

function MapHST:AccessibleGeoSpotsHere(mtype, position)
-- 	if layer == "air" then return self.GEOS end
	local network = self:MobilityNetworkHere(mtype, position)
	if network then
		return self.networks[mtype][network].geos or {}
	end
	return {}
end

function MapHST:AccessibleSpotsHere(mtype, position)
	local network = self:MobilityNetworkHere(mtype, position)
	print (mtype,network)
	if network then
		return self.networks[mtype][network].allSpots or {}
	end
	return {}
end

function MapHST:IsUnderWater(position)
	return position.y < 0
-- 	return Spring.GetGroundHeight(position.x, position.z) < 0
end

function MapHST:DrawDebug()
	local ch = 1
	for i=0,9 do
		self.map:EraseAll(i)
	end
	if not self.ai.drawDebug then
		return
	end
	local colours={
		{1,0,0,1},--'red'
		{0,1,0,1},--'green'
		{0,0,1,1},--'blue'
		{0,1,1,1},
		{1,1,0,1},
		{1,1,1,1},
		{0,0,0,1},
		}
	for i,p in pairs (self.hotSpots) do
		map:DrawPoint(p, green, i,  ch)
	end
	for i,p in pairs (self.METALS) do
		map:DrawPoint(p, white, i,  ch)
	end
	for i,p in pairs (self.GEOS) do
		map:DrawPoint(p, white, i,  ch)
	end
	for X,Zetas in pairs(self.GRID) do
		for Z, CELL in pairs(Zetas) do
			if CELL.trampled > self.ttt.trampled / 2 then
				map:DrawPoint(CELL.POS, {1,1,1,1}, CELL.trampled, 9)
			end
			local pos1, pos2 = {},{}
			pos1.x, pos1.z = CELL.POS.x - self.gridSizeHalf, CELL.POS.z - self.gridSizeHalf
			pos2.x, pos2.z = CELL.POS.x + self.gridSizeHalf, CELL.POS.z + self.gridSizeHalf
			pos1.y=0
			pos2.y=0
			map:DrawRectangle(pos1,pos2, white, nil, false, ch)
			ch = 0
			for layer,unitName in pairs(CELL.moveLayers) do
				ch = ch+1
				if CELL.moveLayers[layer] then
					map:DrawRectangle(pos1,pos2, colours[ch],CELL.moveLayers[layer], true, ch)
				end
			end
		end
	end

end

function MapHST:GetPathGraph(mtype, targetNodeSize)
	targetNodeSize = targetNodeSize or 256
	local cellsPerNodeSide = mCeil(targetNodeSize / self.gridSize)
	if pathGraphs[mtype] then
		if pathGraphs[mtype][cellsPerNodeSide] then
			return pathGraphs[mtype][cellsPerNodeSide]
		end
	end
	local nodeSize = cellsPerNodeSide * self.gridSize
	local nodeSizeHalf = nodeSize / 2
	local graph = {}
	local id = 1
	local myTopology = self.networks[mtype][network]
	for cx = 1, self.gridSideX, cellsPerNodeSide do
		local x = ((cx * self.gridSize) - self.gridSizeHalf) + nodeSizeHalf
		for cz = 1, self.gridSideZ, cellsPerNodeSide do
			local cellsComplete = true
			local goodCells = {}
			local goodCellsCount = 0
			for ccx = cx, cx+cellsPerNodeSide-1 do
				for ccz = cz, cz+cellsPerNodeSide-1 do
					if myTopology[ccx] and myTopology[ccx][ccz] then
						goodCellsCount = goodCellsCount + 1
						goodCells[goodCellsCount] = {ccx, ccz}
					else
						cellsComplete = false
					end
				end
			end
			if goodCellsCount > 0 then
				local z = ((cz * self.gridSize) - self.gridSizeHalf) + nodeSizeHalf
				local position = api.Position()
				position.x = x
				position.z = z
				position.y = 0
				if not cellsComplete then
					local bestDist, bestX, bestZ
					for i = 1, goodCellsCount do
						local good = goodCells[i]
						local gx = (good[1] * self.gridSize) - self.gridSizeHalf
						local gz = (good[2] * self.gridSize) - self.gridSizeHalf
						local dx = x - gx
						local dz = z - gz
						local dist = dx*dx + dz*dz
						if not bestDist or dist < bestDist then
							bestDist = dist
							bestX = gx
							bestZ = gz
						end
					end
					position.x = bestX
					position.z = bestZ
				end
				position.y = Spring.GetGroundHeight(x, z)
				local nodeX = mCeil(cx / cellsPerNodeSide)
				local nodeY = mCeil(cz / cellsPerNodeSide)
				local node = { x = nodeX, y = nodeY, id = id, position = position }
				-- self.map:DrawPoint(position, {1,1,1,1}, mtype .. " " .. nodeX .. ", " .. nodeY, 8)
				graph[id] = node
				id = id + 1
			end
		end
	end
	local aGraph = GraphAStar()
	aGraph:Init(graph)
	aGraph:SetOctoGridSize(1)
	aGraph:SetPositionUnitsPerNodeUnits(nodeSize)
	pathGraphs[mtype] = pathGraphs[mtype] or {}
	pathGraphs[mtype][cellsPerNodeSide] = aGraph
	return aGraph
end
