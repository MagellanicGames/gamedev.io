-- title:  Zombies
-- author: Magellanic
-- desc:   Kill the zombies
-- script: lua

Utils= {}

particles={}

sprites={
	bullet=65
}

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

upSpr=17
rightSpr=18
downSpr=19
leftSpr=20

FRAMETIME=0.5

currentArea={
	x=0,y=0
}

currentAreaClear=false

areaInTiles={w=30,h=16}

buttons={
	up=0,
	down=1,
	left=2,
	right=3
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

player={
	x=96,y=24,
	w=4,h=4,
	direction=directions.up,
	speed=1,
	sprite=upSpr,
	health=100,
	score=0,
	shotTimer=0,
	reloadTime=2
}

player.inventory={
	ammo=40,
	clipSize=4,
	clip=4
}

area={w=240,h=128}
--display is 240x136

Utils.createFloatingText = function(x,y,val,colour)
	local text={}
	text.x=x
	text.y=y
	text.val=val
	text.lifeTime=1
	text.speed=10
	text.colour=colour
	return text
end

function createZ(x,y)
	local z={}
	z.x=x
	z.y=y
	z.rot=0 --rotation per tic80 api
	z.speed=0.5
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
	z.hasAggro=false
	z.aggroDist=32 --distance player has to be before chasing/aggro
	z.scoreValue=25
	return z
end

function withinSameArea(entity1,entity2)
	if withinCurrentArea(entity1) and withinCurrentArea(entity2) then return true
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

function createBullet(x,y)
	local b={}
	b.x=x
	b.y=y
	b.direction=player.direction
	b.speed=4
	b.destroy=false
	b.area={x=currentArea.x,y=currentArea.y}
	b.dmg=25
	b.firstSpr=49
	return b
end

player.shoot=function()

	if btn(5)and player.shotTimer<0 and player.inventory.clip>0 then
		sfx(sound.shot,3*12+6,25)
		player.shotTimer=1
		player.inventory.clip=player.inventory.clip-1
		table.insert(bullets,createBullet(player.x,player.y))
	end

	if btn(5) and player.inventory.clip<1 and player.shotTimer<0 then
	 sfx(sound.misFire,4*12+6,10)
	 player.shotTimer=1
	 table.insert(floatingText,Utils.createFloatingText(player.x,player.y,"Reload!!",colours.blue))
	end

end

player.reload=function()
	if btn(4) and player.inventory.ammo>0 and player.inventory.clip < player.inventory.clipSize then
		local numBulletsNeeded=player.inventory.clipSize-player.inventory.clip
		if player.inventory.ammo-numBulletsNeeded>-1 then 
			player.inventory.ammo=player.inventory.ammo-numBulletsNeeded
			player.inventory.clip=player.inventory.clip+numBulletsNeeded
			player.shotTimer=player.reloadTime
			sfx(sound.reload,4*12+6,20)
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

function changeArea()

	if player.x>area.w then --move to next area to the right
		if currentAreaClear then
	 		player.x=0
	 		currentArea.x=currentArea.x+1
	 	else
	 	  player.x=area.w
	 	end
	end
	if player.x<0 then --move to next area to the left
	 if currentArea.x>0 and currentAreaClear then
	 	player.x=area.w
	 	currentArea.x=currentArea.x-1
	 else
	   player.x=0
	 end
	end

	if player.y>area.h then--area to the bottom
	 player.y=0
	 currentArea.y=currentArea.y+1
	end 
	if player.y<0 then --area to the top
		if currentArea.y>0 and currentAreaClear then
	 		player.y=area.h
	 		currentArea.y=currentArea.y-1
	 	else
	 	  player.y=0
	 	end
	end 
end


theTime=time()
lastTime=theTime
deltaTime=0

------------------------------
Utils.keepTime = function()
	lastTime=theTime
	theTime=time()
	deltaTime=(theTime-lastTime)/1000
end
-------------------------------------------------
Utils.generateParticleHit=function(entity,bullet,colour)
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
-------------------------------
function withinCurrentArea(entity)
	if entity.area.x ~= currentArea.x or entity.area.y ~= currentArea.y then return false
	else
	  return true
	end
end
-------------------------------------
function aggroed(entity)

	if player.x>entity.x - entity.aggroDist and player.x< entity.x + entity.aggroDist and 
		player.y>entity.y - entity.aggroDist and player.y<entity.y + entity.aggroDist then		
		return true
	else		
		return false
	end
end
--------------------------------
function chasePlayer(entity)	
	
	if withinCurrentArea(entity) == false then return end --don't update unless entity is in same area as player

	local i=1 ------------------------------------------------------------check if hit by a bullet
	while i <=#bullets do
		if withinBounds(entity,bullets[i].x,bullets[i].y) and withinSameArea(entity,bullets[i]) then
		 entity.health=entity.health-bullets[i].dmg
		 bullets[i].destroy=true		
		 entity.hasAggro=true
		 Utils.generateParticleHit(entity,bullets[i],colours.red)
		 table.insert(floatingText,Utils.createFloatingText(entity.x,entity.y,bullets[i].dmg,15))
		 sfx(sound.hit,2*12+3,5,1) 
		end
		i=i+1
	end

	if aggroed(entity)==true then entity.hasAggro=true end

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
			table.insert(floatingText,Utils.createFloatingText(player.x-4,player.y,"-"..entity.attackDmg,colours.red))
		end
	end
end
-------------------------------------------------
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
-----------------------------------------------
function drawEntity(entity)
	if withinCurrentArea(entity) == false then return end
	spr(entity.sprite+entity.sprIndex,entity.x,entity.y,0,1,0,entity.rot)
	Utils.drawHealthBar(entity,true)
end
------------------------------------
Utils.drawHealthBar=function(entity,above)
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
-------------------------------------------------
Utils.drawParticles=function()
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
-------------------------------------------------
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
------------------------------------
flashTimer=0.5
function drawHUD()
	print("Health: "..player.health,0,area.h,colours.red)
	print("Score: " ..player.score)
	print("Ammo: "..player.inventory.ammo,area.w - 64,0,colours.blue)
	local i=1
	while i<=player.inventory.clip do
		spr(sprites.bullet,(area.w/2) +(8*i),-1,0)
		i=i+1
	end
	print("Kill the zombies",84,130)

	flashTimer=flashTimer-deltaTime

	if flashTimer<-0.5 then flashTimer=0.5 end
	if #entities>0 then
		if flashTimer>0 then print("!!Danger!!",area.w-50,130,colours.red) end 
	else
	 	print("Safe =D",area.w-50,130,colours.green)
	end

	--print("Time: ".. time()/1000)
end
--------------------------------------

table.insert(entities,createZ(84,100))
table.insert(entities,createZ(150,80))
table.insert(entities,createZ(10,20))
table.insert(entities,createZ(212,100))
function TIC()

	if #entities==0 then currentAreaClear=true end

	Utils.keepTime()
	player.move()
	player.shoot()
	player.reload()

	player.shotTimer=player.shotTimer-deltaTime	
	cls(0)
 	map(areaInTiles.w*currentArea.x,areaInTiles.h*currentArea.y,30,16)
	spr(player.sprite,player.x,player.y,0)
	Utils.drawHealthBar(player,false)
	local i=1
	while i<=#entities do
		chasePlayer(entities[i])
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

	Utils.drawParticles()
	drawHUD()	
end
