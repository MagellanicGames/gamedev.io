-- title:  Zombies
-- author: Magellanic
-- desc:   Kill the zombies
-- script: lua

sound={
	shot=0,
	hit=1,
	playerHit=2,
	misFire=3,
	reload=4,
	healthUp=5
}

colours={
	red=6,
	white=15,
	yellow=14,
	blue=13,
	green=11
}

area={
	x=0,y=0,
	w=240,h=128,
	waves={},
	numWaves=5,
	currentWave=1,	
	clear=false
}


areaInTiles={w=30,h=16}

sprites={bullet=65}

upSpr=17
rightSpr=18
downSpr=19
leftSpr=20

FRAMETIME=0.5

buttons={
	up=0,
	down=1,
	left=2,
	right=3,
	reload=4,
	shoot=5
}

directions={
	up={x=0,y=-1,degrees=0,sprIndex=0}, --sprIndex refers to a frame if it has multple orientations
	upRight={x=0.707106769,y=-0.707106769,degrees=45,sprIndex=1}, --ie first sprite plus this index will give correct orientation
	right={x=0.707106769,y=0,degrees=90,sprIndex=2},
	downRight={x=0.707106769,y=0.707106769,degrees=90+45,sprIndex=3},
	down={x=0,y=1,degrees=180,sprIndex=4},
	downLeft={x=-0.707106769,y=0.707106769,degrees=180+45,sprIndex=5},
	left={x=-1,y=0,degrees=180+90,sprIndex=6},
	upLeft={x=-0.707106769,y=-0.707106769,degrees=360-45,sprIndex=7}
}

bullets={}
entities={}
floatingText={}
particles={}

Waves={}
Utils= {}

spawnPoints={}
spawnPoints[1]={x=-8,y=-8}
spawnPoints[2]={x=area.w*0.5,y=-8}
spawnPoints[3]={x=area.w+8,y=-8} --top
spawnPoints[4]={x=-8,y=area.h*0.5}
spawnPoints[5]={x=area.w+8,y=area.h*0.5} --middle
spawnPoints[6]={x=-8,y=area.h+8}
spawnPoints[7]={x=area.w*0.5,y=area.h+8}
spawnPoints[8]={x=area.w+8,y=area.h+8}--bottom

--------------------------------------------------------------------------------------------
theTime=time()
lastTime=theTime
deltaTime=0

Utils.keepTime = function()
	lastTime=theTime
	theTime=time()
	deltaTime=(theTime-lastTime)/1000
end

-----------------------------------------------------------------------------------
player={
	x=area.w*0.5,y=area.h*0.5,
	w=4,h=4,
	direction=directions.up,
	speed=1,
	sprite=upSpr,
	health=100,
	score=0,
	shotTimer=0,
	reloadTime=0.5,
	shootSpeed=0.5,
	critChance=25
}

inventory={
	ammo=50,
	clipSize=4,
	clip=4
}

player.shoot=function()

	if btn(buttons.shoot)and player.shotTimer<0 and inventory.clip>0 then --shoot if have bullets in clip
		sfx(sound.shot,3*12+6,25)
		player.shotTimer=player.shootSpeed
		inventory.clip=inventory.clip-1
		table.insert(bullets,createBullet(player.x,player.y))
	end

	if btn(buttons.shoot) and inventory.clip<1 and player.shotTimer<0 then --shoot but no bullets in clip
	 sfx(sound.misFire,4*12+6,10)
	 player.shotTimer=player.shootSpeed * 0.5
	 table.insert(floatingText,createFloatingText(player.x,player.y,"Reload!!",colours.blue))
	end

	player.shotTimer=player.shotTimer-deltaTime	--decrement timer for being able to shoot

end

player.reload=function()
	if btn(buttons.reload) and inventory.ammo>0 and inventory.clip < inventory.clipSize then
		local numBulletsNeeded=inventory.clipSize-inventory.clip
		if inventory.ammo-numBulletsNeeded>-1 then 
			inventory.ammo=inventory.ammo-numBulletsNeeded
			inventory.clip=inventory.clip+numBulletsNeeded
			player.shotTimer=player.reloadTime
			sfx(sound.reload,4*12+6,20)
		else
			if inventory.ammo>0 and inventory.ammo<numBulletsNeeded then 
				inventory.clip=inventory.ammo
				inventory.ammo=0
			end  		
		end
	end
end

player.move=function()
	if btn(buttons.up) and not btn(buttons.down) and not btn(buttons.left) and not btn(buttons.right) then--up
	
		player.direction=directions.up
		player.sprite=upSpr
	end
	if not btn(buttons.up) and btn(buttons.down) and not btn(buttons.left) and not btn(buttons.right) then--down
	
		player.direction=directions.down
		player.sprite=downSpr
	end
	if not btn(buttons.up) and not btn(buttons.down) and btn(buttons.left) and not btn(buttons.right)then--left
	
		player.direction=directions.left
		player.sprite=leftSpr
	end
	if not btn(buttons.up) and not btn(buttons.down) and not btn(buttons.left) and btn(buttons.right)then--right
	 
		player.direction=directions.right
		player.sprite=rightSpr
	end
	
	if btn(buttons.up) and btn(buttons.right) and not btn(buttons.down) and not btn(buttons.left) then--upright
	 	player.direction=directions.upRight
		player.sprite=upSpr
	end
	if btn(buttons.down) and btn(buttons.right) and not btn(buttons.left) and not btn(buttons.up)then--downRight
	player.direction=directions.downRight
		player.sprite=downSpr
	end
	if btn(buttons.down) and btn(buttons.left) and not btn(buttons.right) and not btn(buttons.up)then--downLeft
	player.direction=directions.downLeft
		player.sprite=leftSpr
	end
	if btn(buttons.up) and btn(buttons.left) and not btn(buttons.right) and not btn(buttons.down)then--upLeft
	 	player.direction=directions.upLeft
		player.sprite=leftSpr
	end

	if btn(buttons.up) or btn(buttons.down) or btn(buttons.left) or btn(buttons.right) then 
	
		player.x = player.x + (player.direction.x * player.speed)
		player.y = player.y + (player.direction.y * player.speed)
	end	

	changeArea()
end

player.draw=function()
	spr(player.sprite,player.x,player.y,0)
	drawHealthBar(player,false)
end
----------------------------------------------------------------------------------------
Waves.createWave=function(minMobs,maxMobs)--add to list of waves for an area
	local w={}
	w.numMobs=math.random(minMobs,maxMobs)
	w.complete=false
	return w
end

Waves.generateWaves=function(area)	--creates desired number of waves for an area
	for i=1,area.numWaves do
		table.insert(area.waves,Waves.createWave(2,5))
	end
end

Waves.generateMobs=function(wave) --creates mobs based on wave data created in functions above
	local spawnPoint=math.random(1,8)--there are 8 spawn points		
	table.insert(entities,createZ(spawnPoints[spawnPoint].x,spawnPoints[spawnPoint].y,true))
	wave.numMobs=wave.numMobs-1
end

-----------------------------------------------------------------------------------------

function createZ(x,y,aggroed)
	local z={}
	z.x=x
	z.y=y
	z.rot=0 --rotation per tic80 api
	z.speed=0.25
	z.w=4 --width
	z.h=4 --height
	z.area={x=0,y=0} --area that entity resides in
	z.sprite=33 --index of the first animation frame
	z.sprIndex=0 --current frame of animation
	z.aniTimer=0 --timer for animations
	z.health=100
	z.attackTimer=0 --timer for attacks
	z.attackTime=0.5 --reset value for attack timer
	z.attackDmg=8 
	z.hasAggro=aggroed
	z.aggroDist=32 --distance player has to be before chasing/aggro
	z.scoreValue=25
	return z
end

function createBullet(x,y)
	local b={}
	b.x=x
	b.y=y
	b.direction=player.direction
	b.speed=8
	b.destroy=false
	b.area={x=area.x,y=area.y}
	b.dmg=25
	b.isCrit=false
	if math.random(0,100)<player.critChance then
	 b.dmg=b.dmg+b.dmg
	 b.isCrit=true
	end
	b.firstSpr=49
	return b
end

function createFloatingText(x,y,val,colour)
	local text={}
	text.x=x
	text.y=y
	text.val=val
	text.lifeTime=1
	text.speed=10
	text.colour=colour
	return text
end

function generateParticleHit(entity,bullet,colour)
	local numParticles=math.random(10,20)
	local i=1
	while i<=numParticles do
		local particle={}
		particle.x=entity.x
		particle.y=entity.y	
		particle.angle=bullet.direction.degrees + (math.random(45,90)-45)
		particle.direction={x=0,y=0}
		particle.direction.x=math.cos(math.deg(particle.angle))
		particle.direction.y=math.sin(math.deg(particle.angle))
		particle.speed = math.random(1,2)
		particle.lifetime=math.random(1,3) / 10
		particle.colour=colour--6=red
		table.insert(particles, particle)
	i=i+1
	end
end
--------------------------------------------------------------------------------------------
function withinSameArea(entity1,entity2)
	if withinarea(entity1) and withinarea(entity2) then return true
	else
	  return false
	end
end

function withinBounds(entity,x,y)
	if x>entity.x-entity.w and x<entity.x+entity.w and y>entity.y-entity.h and y<entity.y+entity.h then
		return true
	else
	   return false
	 end 
end


function withinarea(entity)
	if entity.area.x ~= area.x or entity.area.y ~= area.y then return false
	else
	  return true
	end
end
---------------------------------------------------------------------------------------

function changeArea()

	if player.x>area.w then --move to next area to the right
		if area.clear then
	 		player.x=0
	 		area.x=area.x+1
	 	else
	 	  player.x=area.w
	 	end
	end
	if player.x<0 then --move to next area to the left
	 if area.x>0 and area.clear then
	 	player.x=area.w
	 	area.x=area.x-1
	 else
	   player.x=0
	 end
	end

	if player.y>area.h then--area to the bottom
	 if area.clear then 
	 	player.y=0
	 	area.y=area.y+1
	 else
	   player.y=area.h
	 end
	end 

	if player.y<0 then --area to the top
		if area.y>0 and area.clear then
	 		player.y=area.h
	 		area.y=area.y-1
	 	else
	 	  player.y=0
	 	end
	end 
end

-------------------------------------
function aggroEntity(entity)
	if entity.hasAggro==false then
		table.insert(floatingText,Utils.createFloatingText(entity.x + entity.w,entity.y+8,"!",colours.red))	
	end
	entity.hasAggro=true
end

function aggroed(entity)

	if player.x>entity.x - entity.aggroDist and player.x< entity.x + entity.aggroDist and 
		player.y>entity.y - entity.aggroDist and player.y<entity.y + entity.aggroDist then	
		return true
	else		
		return false
	end
end

-------------------------------------------------------------------------------------------------

function drawEntity(entity)
	if withinarea(entity) == false then return end
	spr(entity.sprite+entity.sprIndex,entity.x,entity.y,0,1,0,entity.rot)
	drawHealthBar(entity,true)
end

function drawHealthBar(entity,above)
	local barWidth=(entity.w * 3)
	local barMissing=((100-entity.health) / 100) * barWidth
	local sx=entity.x - entity.w
	local y
	if above then y=entity.y-entity.h else y=entity.y+entity.h * 2 end
	local ex=sx + barWidth - barMissing
	local colour=11

	if entity.health<=50 then colour=9 end
	if entity.health<=25 then colour=6 end 

	line(sx,y,ex,y,colour)	
end

function drawParticles()
	local i=1
	while i<=#particles do	
		local p=particles[i]
		if p.lifetime>0 then
			p.x=p.x + (p.direction.x*p.speed)
			p.y=p.y + (p.direction.y*p.speed)
			p.lifetime=p.lifetime-deltaTime
			line(p.x,p.y,p.x,p.y,p.colour)
			i=i+1
		else
	  		table.remove(particles,i)
		end
	end	
end

-----------------------------------------------
function updateFloatingText()
	if #floatingText<1 then return end
	local i=1
	while i<= #floatingText do
		if floatingText[i].lifeTime>0 then 
			floatingText[i].lifeTime=floatingText[i].lifeTime-deltaTime --countdown life time
			floatingText[i].y=floatingText[i].y-(floatingText[i].speed*deltaTime)--move text
			print(floatingText[i].val,floatingText[i].x,floatingText[i].y,floatingText[i].colour,true,1)--print text
			i=i+1
		else
		  table.remove(floatingText,i)
		end
	end
end

function updateBullets()

	local i=1
	while i <=#bullets do

			if bullets[i].x < 0 or bullets[i].x>area.w or bullets[i].y<0 or bullets[i].y>area.h or bullets[i].destroy then --out of bounds, destroy
				table.remove(bullets,i)
			else
			bullets[i].x=bullets[i].x + (bullets[i].direction.x * bullets[i].speed) --update
			bullets[i].y=bullets[i].y + (bullets[i].direction.y * bullets[i].speed)
			spr(bullets[i].firstSpr+bullets[i].direction.sprIndex,bullets[i].x,bullets[i].y,0,1,0,0,1,1)
			i=i+1	
			end			
	end
	
end

function animateEntity(entity)
entity.aniTimer=entity.aniTimer+deltaTime
	
	if entity.aniTimer > FRAMETIME then	
		if entity.sprIndex==3 then
		 entity.sprIndex=0
		else
			entity.sprIndex=entity.sprIndex+1
		end
		entity.aniTimer=0
	end
end

function updateZ(entity)	
	
	if withinarea(entity) == false then return end --don't update unless entity is in same area as player

	local i=1 ------------------------------------------------------------check if hit by a bullet
	while i <=#bullets do
		if withinBounds(entity,bullets[i].x,bullets[i].y) and withinSameArea(entity,bullets[i]) then
		 entity.health=entity.health-bullets[i].dmg
		 local textColour=colours.white
		 if bullets[i].isCrit then 
		 	textColour=colours.yellow
		 	table.insert(floatingText,createFloatingText(entity.x-12,entity.y+8,"CRITICAL!",textColour))
		 end
		 bullets[i].destroy=true
		 aggroEntity(entity)
		 generateParticleHit(entity,bullets[i],colours.red)
		 table.insert(floatingText,createFloatingText(entity.x,entity.y,bullets[i].dmg,textColour))
		 sfx(sound.hit,2*12+3,5,1) 
		end
		i=i+1
	end

	if aggroed(entity)==true then aggroEntity(entity) end

	if entity.hasAggro==false then return end --exit early if not aggroed

	if entity.x<player.x then ----------------------------move towards player
	 entity.x=entity.x+entity.speed
	end
	if entity.x>player.x then
	 entity.x=entity.x-entity.speed
	end
	if entity.y<player.y then
	 entity.y=entity.y+entity.speed
	end
	if entity.y>player.y then
	 entity.y=entity.y-entity.speed
 	end

 	if math.abs(entity.x-player.x) > math.abs(entity.y-player.y) then --change rotation depending on pos compared to player
		if entity.x > player.x then entity.rot=3
		else entity.rot=1 end
	else
		if entity.y>player.y then entity.rot=0
		else entity.rot=2 end
	end

	if entity.attackTimer>0 then entity.attackTimer=entity.attackTimer-deltaTime end --decrement attack timer

	if withinBounds(entity,player.x,player.y) then ---------------------if within range, attack player
		if entity.attackTimer<=0 then 
			player.health=player.health-entity.attackDmg
			entity.attackTimer=entity.attackTime
			sfx(sound.playerHit,2*12+3,5,2) 		
			table.insert(floatingText,createFloatingText(player.x-4,player.y,"-"..entity.attackDmg,colours.red))
		end
	end
end
-------------------------------------------------

flashTimer=0.5
function drawHUD()
	print("Health: "..player.health,0,area.h,colours.red)
	print("Score: " ..player.score)
	print("Waves: "..area.numWaves,64,2)
	print("Ammo: "..inventory.ammo,area.w - 64,0,colours.blue)
	local i=1
	while i<=inventory.clip do
		spr(sprites.bullet,(area.w/2) +(8*i),-1,0)
		i=i+1
	end
	print("Kill the zombies",84,130)

	flashTimer=flashTimer-deltaTime

	if flashTimer<-0.5 then flashTimer=0.5 end
	if area.clear==false then
		if flashTimer>0 then print("!!Danger!!",area.w-50,130,colours.red) end 
	else
	 	print("Safe =D",area.w-50,130,colours.green)
	end

	--print("Time: ".. time()/1000)
end
--------------------------------------

spawnTimer=2

Waves.generateWaves(area)
Waves.generateMobs(area.waves[area.currentWave])

function gameState()
	
	spawnTimer=spawnTimer-deltaTime

	if spawnTimer<0 and area.waves[area.currentWave].numMobs>0 then --does the current wave still have mobs?
		Waves.generateMobs(area.waves[area.currentWave]) --create mob
		spawnTimer=math.random(2,4) --countdown to next mob spawn
	end
	if spawnTimer<0 and area.waves[area.currentWave].numMobs<1 and #entities<1 then	--is the current wave finished?   		
	   	if area.currentWave<#area.waves then --are there still waves left?
	   		area.currentWave=area.currentWave+1 --move to next wave
	   		area.numWaves=area.numWaves-1 --decrement the number of waves in the area
	   	else
	   		area.numWaves=area.numWaves-1 --decrement to zero
	   		area.clear=true --no waves left, area is clear
	   	end		
	end

	Utils.keepTime()
	player.move()
	player.shoot()
	player.reload()	

	cls(0)
 	map(areaInTiles.w*area.x,areaInTiles.h*area.y,30,16)
	player.draw()

	local i=1
	while i<=#entities do
		updateZ(entities[i])
		animateEntity(entities[i])
		drawEntity(entities[i])
		if entities[i].health<=0 then --if removed then don't need to increment index
			player.score=player.score+entities[i].scoreValue
		 table.remove(entities,i) 
		else
		  i=i+1
		end		
	end

	updateBullets()
	updateFloatingText()

	drawParticles()
	drawHUD()	
end


titleXpos=(area.w/2)-print("Zombie Apocalyp-tic-80",area.w/2,area.h/2,colours.green)/2
titleYpos=area.h/2
startGame=false
startTimer=1
startTextColor=colours.green

function startScreenState()
	Utils.keepTime()
	cls(0)
	print("Zombie Apocalyp-tic-80",titleXpos,titleYpos,startTextColor)
	print("Press A (Z key) to start!",titleXpos-4,titleYpos+32,colours.blue)
	print("\'A\' to reload, \'B\' to shoot,  Arrows to move.",0,titleYpos+64)

	if btn(buttons.reload) and startGame==false then
	 startGame=true
	 startTextColor=colours.red
	 sfx(sound.healthUp,4*12+3,20,2)
	end

	if startGame then 
		startTimer=startTimer-deltaTime	 
	end
	if startTimer<0 then currentState.run=gameState end
end

currentState={run=startScreenState}



function TIC()		
	currentState.run()	
end
