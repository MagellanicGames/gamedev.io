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
	healthUp=5,
	menu=6
}

colours={
	red=6,
	orange=9,
	white=15,
	yellow=14,
	blue=13,
	green=11,
	pink=12
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
	shoot=5,
	menu=6,
	special=7
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

weapons={

	pistol={
	reloadTime=0.5,
	shootSpeed=0.5,
	critChance=15,
	clipSize=4,
	dmg=15,
	comboDmg=20,
	bleedDmg=5
}
	
}

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
	weapon=weapons.pistol,
	combo=0,
	maxCombo=0,
	experience=0,
	experienceReq=100,
	totalExperience=0,
	level=1,
	talentPoints=0
}

inventory={
	ammo=50,	
	clip=4
}

expBar={
	x=205,y=133,
	width=1,
	totalWidth=32,
	expInPercent=0
}

abilities={
	shred=false,
	stun=false,
	headShot=false
}

player.experienceGain=function(amount)
	player.experience=player.experience+amount
	player.totalExperience=player.totalExperience+amount
	table.insert(floatingText,createFloatingText(player.x,player.y,amount.." exp",colours.orange))
	if player.experience>=player.experienceReq then --level up
		player.level=player.level+1
		local expOver=player.experience-player.experienceReq--work out if exp is over required amount
		if expOver>0 then player.experience=expOver else player.experience=0 end --set exp to excess or zero
		player.experienceReq=player.experienceReq+(player.experienceReq*0.5)
		player.talentPoints=player.talentPoints+1
		if player.maxCombo<3 then player.maxCombo=player.maxCombo+1 end
		table.insert(floatingText,createFloatingText(player.x,player.y+8,"LEVEL UP!",colours.pink))
	end
	local percentage=(player.experience/player.experienceReq)
	expBar.expInPercent=math.floor(percentage*100)
	expBar.width=expBar.totalWidth*percentage
end

player.shoot=function()

	if btn(buttons.shoot)and player.shotTimer<0 and inventory.clip>0 then --shoot if have bullets in clip
		sfx(sound.shot,3*12+6,25)
		player.shotTimer=player.weapon.shootSpeed
		inventory.clip=inventory.clip-1
		table.insert(bullets,createBullet(player.x,player.y))
	end

	if btn(buttons.shoot) and inventory.clip<1 and player.shotTimer<0 then --shoot but no bullets in clip
	 sfx(sound.misFire,4*12+6,10)
	 player.shotTimer=player.weapon.shootSpeed * 0.5
	 table.insert(floatingText,createFloatingText(player.x,player.y,"Reload!!",colours.blue))
	end

	if btn(buttons.special) and player.combo>0 and player.shotTimer<0 then --shoot combo ability
		sfx(sound.shot,3*12+6,25)
		player.shotTimer=player.weapon.shootSpeed*3
		local bullet =createComboBlastBullet(player.x,player.y)
		if player.combo==1 and abilities.shred then 
			bullet.shred=true 
		end
		if player.combo==2 and abilities.stun then
			bullet.stun=true
			bullet.dmg=player.weapon.dmg
		end
		--3 just damages
		table.insert(bullets,bullet)
		player.combo=0 --must be set after else will calculate 0 dmg
	end

	player.shotTimer=player.shotTimer-deltaTime	--decrement timer for being able to shoot

end

player.reload=function()
	if btn(buttons.reload) and player.shotTimer<0 and inventory.ammo>0 and inventory.clip < player.weapon.clipSize then
		local numBulletsNeeded=player.weapon.clipSize-inventory.clip
		if inventory.ammo-numBulletsNeeded>-1 then 
			inventory.ammo=inventory.ammo-numBulletsNeeded
			inventory.clip=inventory.clip+numBulletsNeeded
			player.shotTimer=player.weapon.reloadTime
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
	z.totalHealth=100
	z.attackTimer=0 --timer for attacks
	z.attackTime=0.5 --reset value for attack timer
	z.attackDmg=8 
	z.hasAggro=aggroed
	z.aggroDist=32 --distance player has to be before chasing/aggro
	z.scoreValue=25
	z.expValue=10
	z.bleeding=false
	z.stunned=false
	z.stunTimer=0
	return z
end

function createBullet(x,y)
	local b={}
	b.x=x
	b.y=y
	b.direction=player.direction
	b.speed=6
	b.destroy=false
	b.area={x=area.x,y=area.y}
	b.dmg=player.weapon.dmg
	b.isCrit=false
	if math.random(0,100)<player.weapon.critChance then
	 b.dmg=b.dmg+b.dmg
	 b.isCrit=true
	end
	b.isCombo=false
	b.firstSpr=49
	return b
end

function createComboBlastBullet(x,y)
	local b={}
	b.x=x
	b.y=y
	b.direction=player.direction
	b.speed=6
	b.destroy=false
	b.area={x=area.x,y=area.y}
	b.dmg=player.weapon.comboDmg*(player.combo)
	b.isCrit=false
	b.shred=false
	b.stun=false
	b.isCombo=true	
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
				if not bullets[i].destroy then player.combo=0 end --player missed so remove combo points
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

bleedingTimer=1
function updateZ(entity)	
	
	if withinarea(entity) == false then return end --don't update unless entity is in same area as player

	local i=1 ------------------------------------------------------------check if hit by a bullet
	while i <=#bullets do
		local bullet=bullets[i]
		if withinBounds(entity,bullet.x,bullet.y) and withinSameArea(entity,bullet) then
		 entity.health=entity.health-bullet.dmg		
		 if player.combo<player.maxCombo and bullet.isCombo==false then		  
		  player.combo=player.combo+1 
		 end
		 local textColour=colours.white
		 if bullet.isCrit then 
		 	textColour=colours.yellow
		 	table.insert(floatingText,createFloatingText(entity.x-12,entity.y+8,"CRITICAL!",textColour))
		 end

		if bullet.shred == true then 
			entity.bleeding=true 
			table.insert(floatingText,createFloatingText(entity.x+12,entity.y+8,"Bleeding",colours.red))
		end

		if bullet.stun ==true then
		 entity.stun=true
		 entity.stunTimer=3
		 table.insert(floatingText,createFloatingText(entity.x+12,entity.y+8,"Stunned",colours.blue))
		end

		bullet.destroy=true
		aggroEntity(entity)
		generateParticleHit(entity,bullet,colours.red)
		table.insert(floatingText,createFloatingText(entity.x,entity.y,bullet.dmg,textColour))
		sfx(sound.hit,2*12+3,5,1) 
		end
		i=i+1
	end

	bleedingTimer=bleedingTimer-deltaTime
	if entity.bleeding==true and bleedingTimer<0 then
		local dmg=entity.totalHealth*0.05
		entity.health=entity.health-dmg
		table.insert(floatingText,createFloatingText(entity.x+12,entity.y+8,"-"..dmg,colours.red))
		bleedingTimer=1
	end

	if aggroed(entity)==true then aggroEntity(entity) end

	if entity.hasAggro==false then return end --exit early if not aggroed

	if entity.stun and entity.stunTimer>0 then entity.stunTimer=entity.stunTimer-deltaTime
	else entity.stun = false
	end
		
	if entity.stun == false then

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
			player.combo=0
			entity.attackTimer=entity.attackTime
			sfx(sound.playerHit,2*12+3,5,2) 		
			table.insert(floatingText,createFloatingText(player.x-4,player.y,"-"..entity.attackDmg,colours.red))
		end
	end
end
-------------------------------------------------

flashTimer=0.5
function drawHUD()
	
	print("Score: " ..player.score,0,0)
	print("Waves: "..area.numWaves,64,2)
	print("Ammo: "..inventory.ammo,area.w - 64,0,colours.blue)
	local i=1
	while i<=inventory.clip do
		spr(sprites.bullet,0 +(8*i),area.h,0)
		i=i+1
	end

	local comboPos={x=50,y=area.h+1}

	print("Combo "..player.combo,comboPos.x,comboPos.y,colours.green)

	print("Exp: %"..expBar.expInPercent,expBar.x-44,130)  
	
	line(expBar.x,expBar.y,expBar.x+expBar.width,expBar.y,colours.orange)
	flashTimer=flashTimer-deltaTime

	if flashTimer<-0.5 then flashTimer=0.5 end
	if area.clear==false then
		if flashTimer>0 then print("!!Danger!!",114,2,colours.red) end 
	else
	 	print("Safe =D",114,2,colours.green)
	end

	if player.talentPoints>0 and flashTimer>0 then print("\'A\' to Level up!",player.x - 20,player.y+8,colours.pink) end
	--print("Time: ".. time()/1000)
end
--------------------------------------

spawnTimer=2

Waves.generateWaves(area)
Waves.generateMobs(area.waves[area.currentWave])
menuPressed=false
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
		local entity=entities[i]
		updateZ(entity)
		animateEntity(entity)
		drawEntity(entity)
		if entity.health<=0 then --if removed then don't need to increment index
			player.experienceGain(entity.expValue)
			player.score=player.score+entity.scoreValue
			table.remove(entities,i) 
		else
		  i=i+1
		end		
	end

	updateBullets()
	updateFloatingText()

	drawParticles()
	drawHUD()
	
	if btn(buttons.menu) and menuPressed==false then menuPressed=true end
	if btn(buttons.menu)==false and menuPressed==true then
		menuPressed=false
		if player.talentPoints>0 then currentState.run=levelUpState else currentState.run=inGameMenuState end		
	end
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
	print("Press \'Z\' key to start!",titleXpos-4,titleYpos+32,colours.blue)
	print("\'Z\' to reload, \'X\' to shoot,  Arrows to move.",0,titleYpos+56)
	print("\'A\' to open menu, \'S\' for combo ability",0,titleYpos+64)

	if btn(buttons.reload) and startGame==false then
	 startGame=true
	 startTextColor=colours.red
	 sfx(sound.healthUp,4*12+3,20,2)
	end

	if startGame then 
		startTimer=startTimer-deltaTime	 
	end
	if startTimer<0 then currentState.run=introductionScreenState end
end


introTimer=3
introYpos=24
textSpacing=8
function introductionScreenState()
	cls(0)
	print("Kill the zombies, when clear move to",16,introYpos)
	print("the next area.",16,introYpos+(textSpacing*1))
	print("Find supplies to keep yourself alive",16,introYpos+(textSpacing*3))
	print("and get out of the city.",16,introYpos+(textSpacing*4))

	if introTimer<0 then print("Press \'z\' to continue.",16,introYpos+(textSpacing*6),colours.yellow) end

	introTimer=introTimer-deltaTime
	if introTimer<0 and btn(buttons.reload) then
	 acceptSound()
	 currentState.run=gameState
	end
end


menuOptions = {}
menuOptions[1]="Help"
menuOptions[2]="Level Up"
menuOptions[3]="Inventory"
optionSelected=1
zPressed=false
xPressed=false
upPressed=false
downPressed=false
menuPos={x=(area.w*0.5)-24,y=(area.h*0.5)-16}
instructionsOffset={x=-90,y=81}

function inGameMenuState()
	cls(0)--draw
	print("Menu",menuPos.x,menuPos.y,colours.green)

	for i=1,3 do
		local colour=colours.white
		if i==optionSelected then colour=colours.yellow end
		print(menuOptions[i],menuPos.x,menuPos.y + (8*i),colour)
	end
	print("\'x\' - accept \'z\' - back",menuPos.x +instructionsOffset.x,menuPos.y+instructionsOffset.y,colours.yellow)
	---------------------------------------------------------------------------------input
	if btn(buttons.up)==true and upPressed==false then upPressed=true end
	if btn(buttons.up)==false and upPressed==true then
		upPressed=false
		if optionSelected == 1 then optionSelected=3 
		else
		  optionSelected=optionSelected-1
		end
		menuSound()
	end

	if btn(buttons.down)==true and downPressed==false then downPressed=true end
	if btn(buttons.down)==false and downPressed==true then
		downPressed=false
		if optionSelected == 3 then optionSelected=1 
		else
		  optionSelected=optionSelected+1
		end
		menuSound()
	end

	if btn(buttons.shoot)==true and xPressed==false then xPressed=true end
	if btn(buttons.shoot)==false and xPressed==true then
		xPressed=false

		if optionSelected==1 then trace("TODO") end --help
		if optionSelected==2 then currentState.run=levelUpState end --level up
		if optionSelected==3 then end --inventory
		acceptSound()
	end

	if btn(buttons.reload)==true and zPressed==false then zPressed=true end
	if btn(buttons.reload)==false and zPressed==true then
		zPressed=false
		acceptSound()
		currentState.run=gameState
	end

end

talents={}
talents[1]={name="Razor Bullets. Req. lvl2",info="Added damage over time. Cost: 1 combo"}
talents[2]={name="Stun. Req. lvl3",info="Stun target for 3 secs. Cost: 2 combo"}
talents[3]={name="Head Shot. Req. lvl4",info="Shot that does 3x weapon dmg. Cost: 3 combo"}

learned={}
learned[1]=false
learned[2]=false
learned[3]=false

talentSelected=1
function levelUpState()
	cls(0)
	print("Talents",menuPos.x,8,colours.green)
	print("Points - Avl: "..player.talentPoints.." Used: "..player.level-1,0,0)
	print("\'x\' - accept \'z\' - back",menuPos.x +instructionsOffset.x,menuPos.y+instructionsOffset.y,colours.yellow)

	local yOffset=17
	local nameY=5
	for i=1,#talents do
		local colour={}
		if learned[i]==true then colour=colours.green else colour=colours.red end 

		print(talents[i].name,0,nameY+(yOffset*i),colour)
		print(talents[i].info,0,12+(yOffset*i),colours.yellow)
	end

	spr(81,128,(yOffset*talentSelected) + 4,0)

	if btn(buttons.shoot)==true and xPressed==false then xPressed=true end
	if btn(buttons.shoot)==false and xPressed==true then
		xPressed=false
		if player.level==2 and talentSelected==1 then 
			player.talentPoints=0
			abilities.shred=true
			learned[1]=true
		end
		if player.level==3 and talentSelected==2 then 
			player.talentPoints=0
			abilities.stun=true
			learned[2]=true
		end
		if player.level==4 and talentSelected==3 then 
			player.talentPoints=0
			abilities.headShot=true
			learned[3]=true
		end
		acceptSound()
	end

	if btn(buttons.reload)==true and zPressed==false then zPressed=true end
	if btn(buttons.reload)==false and zPressed==true then
		zPressed=false
		acceptSound()
		currentState.run=inGameMenuState
	end

	if btn(buttons.up)==true and upPressed==false then upPressed=true end
	if btn(buttons.up)==false and upPressed==true then
		upPressed=false
		if talentSelected == 1 then talentSelected=3 
		else
		  talentSelected=talentSelected-1
		end
		menuSound()
	end

	if btn(buttons.down)==true and downPressed==false then downPressed=true end
	if btn(buttons.down)==false and downPressed==true then
		downPressed=false
		if talentSelected == 3 then talentSelected=1 
		else
		  talentSelected=talentSelected+1
		end
		menuSound()
	end
end

currentState={run=startScreenState}

function TIC()		
	currentState.run()	
end

function menuSound()
	sfx(sound.menu,6*12+3,5,1) 
end

function acceptSound()
	sfx(sound.menu,4*12+3,5,1)
end