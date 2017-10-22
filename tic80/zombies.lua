-- title:  Zombies
-- author: Magellanic
-- desc:   Kill the zombies
-- script: lua

function createArea(x,y,numWaves)
	local a={}
	local pos={}
	pos.x=x
	pos.y=y
	a.pos=pos
	a.w=240
	a.h=128
	a.waves={}
	a.numWaves=numWaves
	a.currentWave=1	
	a.clear=false
	a.doodads={}
	return a
end

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

areas={}

area=createArea(0,0,1)
areas[area.pos]=area

itemId={
	health=0,
	ammo=1,
	dmgUp=2,
	critUp=3
}

areaInTiles={w=30,h=16}

sprites={
	bullet=65,
	healthPack=97,
	ammo=98,
	dmgUp=99,
	critUp=100
}

stats={
	enemiesKilledTotal=0,
	enemiesKilledThisLevel=0,
	successfulShots=0,
	missedShots=0,
	hitsTaken=0,
	expEarntThisLevel=0,
	mostDmg=0,
	
}

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
	special=7,
	changeAbility=8
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
itemDrops={}
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
	
}

weapons[1]=
{
	name="Rusty Pistol",
	reloadTime=0.5,
	shootSpeed=0.45,
	critChance=20,
	clipSize=4,
	startingAmmo=45,
	dmg=15,
	comboDmg=20,
	bleedDmg=0.33,
	ability="Shred",
	soundEffect=sound.shot,
	soundEffectPitch=3*12+6,
	menuSprite=256
}

weapons[2]=
{
	name="Stunning Shotgun",
	reloadTime=1.5,
	shootSpeed=0.5,
	critChance=10,
	clipSize=5,
	startingAmmo=35,--35
	dmg=5,
	comboDmg=10,
	bleedDmg=5,
	ability="Stun",
	soundEffect=sound.shot,
	soundEffectPitch=3*12+6,
	menuSprite=258
}

weapons[3]=
{
	name="Dead Future",
	reloadTime=0.75,
	shootSpeed=0.30,
	critChance=35,
	clipSize=10,
	startingAmmo=150,
	dmg=5,
	comboDmg=20,
	bleedDmg=5,
	ability="Exploder",
	soundEffect=sound.shot,
	soundEffectPitch=3*12+6,
	menuSprite=260
}

--weapons[3]=
--{
--	name="Between the Rifles",
--	reloadTime=1,
--	shootSpeed=1.5,
--	critChance=25,
--	clipSize=4,
--	startingAmmo=45,
--	dmg=30,
--	comboDmg=20,
--	bleedDmg=5,
--	ability="Rapidshot",
--	soundEffect=sound.shot,
--	soundEffectPitch=3*12+6,
--	menuSprite=262
--}



meleeWeapon=
{
	name="Spud Gun",
	reloadTime=0.75,
	shootSpeed=0.7,
	critChance=15,
	clipSize=4,
	startingAmmo=0,
	dmg=8,
	comboDmg=20,
	bleedDmg=5,
	ability="",
	soundEffect=sound.shot,
	soundEffectPitch=3*12+6
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

function createPlayer()

	local p={}
	p.x=area.w*0.5
	p.y=area.h*0.5
	p.w=4
	p.h=4
	p.direction=directions.up
	p.speed=1
	p.sprite=upSpr
	p.health=100
	p.maxHealth=100
	p.score=0
	p.shotTimer=0
	p.weapon={}
	p.storeWeapon={}
	p.meleeWeapon=meleeWeapon
	p.combo=0
	p.maxCombo=1
	p.experience=0
	p.experienceReq=60
	p.totalExperience=0
	p.level=1
	p.talentPoints=0
	p.talentPointsUsed=0
	p.maxAbility=0
	p.bleeding=false
	p.bleedingTimeLeft=0
	p.dead=false
	return p
end

player=createPlayer()

talents={
}

function createTalents()
talents[1]={
	name="Not Quite a Zombie",
	numPoints=0,
	maxPoints=5,
	levelRequirement=2,
	description="For each point gain 3% health regen but lose",
	description1="10% total health. Health packs aren't as effective."
}

talents[2]={
	name="Bullet Rations",
	numPoints=0,
	maxPoints=3,
	levelRequirement=2,
	description="Crits refund 1 ammo per ",
	description1="point but you lose 5% crit dmg per point."
}

talents[3]={
	name="Athlete",
	numPoints=0,
	maxPoints=5,
	levelRequirement=3,
	description="Each point grants 10% movement ",
	description1="speed but if hit you bleed."
}

talents[4]={
name="Seasoned",
	numPoints=0,
	maxPoints=5,
	levelRequirement=3,
	description="Increase max. combo points",
	description1="per point."
}
end




inventory={
	ammo=35,	
	clip=4
}

expBar={
	x=205,y=133,
	width=1,
	totalWidth=32,
	expInPercent=0
}

function playerExperienceGain(amount)
	stats.expEarntThisLevel=stats.expEarntThisLevel+amount
	player.experience=player.experience+amount
	player.totalExperience=player.totalExperience+amount
	table.insert(floatingText,createFloatingText(player.x,player.y,amount.." exp",colours.orange))
	if player.experience>=player.experienceReq then --level up
		player.level=player.level+1
		local expOver=player.experience-player.experienceReq--work out if exp is over required amount
		if expOver>0 then player.experience=expOver else player.experience=0 end --set exp to excess or zero
		player.experienceReq=player.experienceReq+(player.experienceReq*0.5)
		player.talentPoints=player.talentPoints+1				
		local lvlText=createFloatingText(player.x,player.y+8,"LEVEL UP!",colours.pink)
		lvlText.lifeTime=3
		table.insert(floatingText,lvlText)
	end
	local percentage=(player.experience/player.experienceReq)
	expBar.expInPercent=math.floor(percentage*100)
	expBar.width=expBar.totalWidth*percentage
end

changeBtnPressed=false
function playerShoot()
	
	if isInterval then return end
	if btn(buttons.shoot) and btn(buttons.reload)==false and player.shotTimer<0 and inventory.clip>0 then --shoot if have bullets in clip
		sfx(player.weapon.soundEffect,3*12+6,25)
		player.shotTimer=player.weapon.shootSpeed
		inventory.clip=inventory.clip-1

		if player.weapon.name=="Stunning Shotgun" then
			shotgunShot(player.x,player.y)
		else
			local b=createBullet(player.x,player.y)
			if player.weapon.name=="Spud Gun" then 
				b.firstSpr=57 
				b.isSpudGunShot=true
			end
		  	table.insert(bullets,b)
		end
		
	end

	if btn(buttons.shoot) and btn(buttons.reload)==false and inventory.clip<1 and player.shotTimer<0 then --shoot but no bullets in clip
		if player.weapon.name ~= "Spud Gun" then 
	 		sfx(sound.misFire,4*12+6,10)
	 		player.shotTimer=player.weapon.shootSpeed * 0.5
	 		table.insert(floatingText,createFloatingText(player.x,player.y,"Reload!!",colours.blue))
		else
			inventory.clip=player.weapon.clipSize
		end
	end


	if btn(buttons.special) and player.combo>0 and player.shotTimer<0 then --shoot combo ability
		local bullet =createComboBlastBullet(player.x,player.y)
		if player.weapon.ability=="Shred" and player.combo>=1 then 
			sfx(player.weapon.soundEffect,player.weapon.soundEffectPitch,25)
			player.shotTimer=player.weapon.shootSpeed
			bullet.shred=true 
			bullet.dmg=player.weapon.dmg*0.15
			table.insert(bullets,bullet)
			player.combo=player.combo-1 --must be set after else will change damage
		end
		if player.weapon.ability=="Stun" and player.combo>=1 then
			sfx(player.weapon.soundEffect,player.weapon.soundEffectPitch,25)
			player.shotTimer=player.weapon.shootSpeed
			bullet.stun=true
			bullet.dmg=player.weapon.dmg*3
			table.insert(bullets,bullet)
			player.combo=player.combo-1
		end
		if player.weapon.ability=="Exploder" and player.combo>=1 then			
			sfx(player.weapon.soundEffect,player.weapon.soundEffectPitch,25)
			player.shotTimer=player.weapon.shootSpeed
			bullet.exploder=true
			table.insert(bullets,bullet)
			player.combo=player.combo-1
		end		

		if player.weapon.abliliy=="Rapidshot" and player.combo>=3 and abilities.headShot then
			sfx(player.weapon.soundEffect,player.weapon.soundEffectPitch,25)
			player.shotTimer=player.weapon.shootSpeed
			table.insert(bullets,bullet)
			player.combo=player.combo-3
		end	


	end
	
	player.shotTimer=player.shotTimer-deltaTime	--decrement timer for being able to shoot

end

function playerReload()
	if btn(buttons.reload) and btn(buttons.shoot)==false and player.shotTimer<0 and inventory.ammo>0 and inventory.clip < player.weapon.clipSize then
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

function playerMove()
	if btn(buttons.up) and not btn(buttons.down) and not btn(buttons.left) and not btn(buttons.right) then--up
		player.dirIndex=1
		player.direction=directions.up
		player.sprite=upSpr
	end
	if not btn(buttons.up) and btn(buttons.down) and not btn(buttons.left) and not btn(buttons.right) then--down
		player.dirIndex=5
		player.direction=directions.down
		player.sprite=downSpr
	end
	if not btn(buttons.up) and not btn(buttons.down) and btn(buttons.left) and not btn(buttons.right)then--left
		player.dirIndex=3
		player.direction=directions.left
		player.sprite=leftSpr
	end
	if not btn(buttons.up) and not btn(buttons.down) and not btn(buttons.left) and btn(buttons.right)then--right
	 	player.dirIndex=7
		player.direction=directions.right
		player.sprite=rightSpr
	end
	
	if btn(buttons.up) and btn(buttons.right) and not btn(buttons.down) and not btn(buttons.left) then--upright
		player.dirIndex=2
	 	player.direction=directions.upRight
		player.sprite=upSpr
	end
	if btn(buttons.down) and btn(buttons.right) and not btn(buttons.left) and not btn(buttons.up)then--downRight
	player.dirIndex=4
	player.direction=directions.downRight
		player.sprite=downSpr
	end
	if btn(buttons.down) and btn(buttons.left) and not btn(buttons.right) and not btn(buttons.up)then--downLeft
	player.dirIndex=6
	player.direction=directions.downLeft
		player.sprite=leftSpr
	end
	if btn(buttons.up) and btn(buttons.left) and not btn(buttons.right) and not btn(buttons.down)then--upLeft
	player.dirIndex=8
	 	player.direction=directions.upLeft
		player.sprite=leftSpr
	end

	if btn(buttons.up) or btn(buttons.down) or btn(buttons.left) or btn(buttons.right) then 
	
		player.x = player.x + (player.direction.x * player.speed)
		player.y = player.y + (player.direction.y * player.speed)
	end	

	changeArea()
	if player.health<=0 then player.dead=true end
	if player.dead==true then currentState.run=endGameState end
end


playerBleedTick=0
function playerBleed()

	if player.bleedingTimeLeft>0 then player.bleedingTimeLeft=player.bleedingTimeLeft-deltaTime
	else
	  player.bleeding=false
	end
	playerBleedTick=playerBleedTick-deltaTime
	if playerBleedTick<=0 then
		playerBleedTick=1
		local bleedAmount=player.maxHealth*0.02
		table.insert(floatingText,createFloatingText(player.x,player.y,"-"..bleedAmount,colours.red))
		player.health=player.health-bleedAmount		
	end
end
function playerDraw()
	spr(player.sprite,player.x,player.y,0)
	playerRegen()
	drawHealthBar(player,false)
	if player.bleeding==true then playerBleed() end
	if inventory.ammo<1 and inventory.clip<1 and player.combo<1 and player.weapon.name ~= "Spud Gun" then 
		table.insert(floatingText,createFloatingText(player.x,player.y,"Spud Gun Equipped",colours.white))
		player.storeWeapon=player.weapon
		player.weapon=player.meleeWeapon
		player.combo=0
	end

	if player.weapon.name=="Spud Gun" and inventory.ammo>0 then
		inventory.clip=0
		table.insert(floatingText,createFloatingText(player.x,player.y,"Gun Equipped",colours.white))
		player.weapon=player.storeWeapon
		player.storeWeapon={}
	end
end

regenTimer=0
function playerRegen()
	if regenTimer>0 then regenTimer=regenTimer-deltaTime end
	if talents[1].numPoints>0 and player.health<player.maxHealth and regenTimer<=0 then
		local regenAmount=player.maxHealth*((3*talents[1].numPoints)/100)
		regenAmount=math.ceil(regenAmount)
		player.health=player.health+regenAmount
		if player.health>player.maxHealth then player.health = player.maxHealth end
		regenTimer=3
		table.insert(floatingText,createFloatingText(player.x,player.y,"+"..regenAmount,colours.green))
	end
end
----------------------------------------------------------------------------------------
Waves.createWave=function(minMobs,maxMobs)--add to list of waves for an area
	local w={}
	w.numMobs=math.random(minMobs,maxMobs)
	w.numMobs=w.numMobs+level
	w.complete=false
	return w
end

Waves.generateWaves=function(area)	--creates desired number of waves for an area
	if level==10 then area.numWaves=1 end
	for i=1,area.numWaves do
		if level<5 then
			local min=math.random(1,2)
			local max=math.random(4,6)
			table.insert(area.waves,Waves.createWave(min,max))
		else
			local min=math.random(1,3)
			local max=math.random(4,7)
			table.insert(area.waves,Waves.createWave(min,max))
		end
	end
end

bossSpawned=false
Waves.generateMobs=function(wave) --creates mobs based on wave data created in functions above
	if level==10 then --boss wave
		local spawnPoint={}
		spawnPoint=math.random(1,8)
		if bossSpawned==false then
			table.insert(entities,createBossZ(spawnPoints[spawnPoint].x,spawnPoints[spawnPoint].y))
			bossSpawned=true
		else
		  	table.insert(entities,createZ(spawnPoints[spawnPoint].x,spawnPoints[spawnPoint].y,true))
		end

	else
		local generateMini=5
		if math.random(1,100)<generateMini then
			local spawnPoint={}

			for i=2,6 do
				spawnPoint=math.random(1,8)
				table.insert(entities,createMiniZ(spawnPoints[spawnPoint].x,spawnPoints[spawnPoint].y,true))
				wave.numMobs=wave.numMobs-1
			end--end for spawn loop
		else
	  		local spawnPoint=math.random(1,8)--there are 8 spawn points		
			table.insert(entities,createZ(spawnPoints[spawnPoint].x,spawnPoints[spawnPoint].y,true))
			wave.numMobs=wave.numMobs-1
		end--end mini if
	end --bosswave if
	
	
end

-----------------------------------------------------------------------------------------

function createZ(x,y,aggroed)
	local z={}
	z.x=x
	z.y=y
	z.rot=0 --rotation per tic80 api
	z.speed=math.random(30,60) / 100	
	z.w=4 --width
	z.h=4 --height
	z.area={x=area.pos.x,y=area.pos.y} --area that entity resides in
	z.sprite=33 --index of the first animation frame
	z.sprIndex=0 --current frame of animation
	z.aniTimer=0 --timer for animations
	local healthMultiplier=2
	
	z.health=40+(healthMultiplier*level)
	z.maxHealth=40+(healthMultiplier*level)
	z.attackTimer=0 --timer for attacks
	z.attackTime=1 --reset value for attack timer
	z.attackDmg=20 
	z.hasAggro=aggroed
	z.aggroDist=32 --distance player has to be before chasing/aggro
	z.scoreValue=25
	z.expValue=10+(10*level)
	z.bleeding=false
	z.bleedingStacks=0
	z.stunned=false
	z.stunTimer=0
	z.isMini=false
	z.isBossZ=false
	z.exploderDebuff=false
	return z
end

function createMiniZ(x,y,aggroed)
	local z=createZ(x,y,aggroed)
	z.health=30+(level*2)
	z.maxHealth=30+(level*2)
	z.expValue=2+(level*2)
	z.isMini=true	
	return z
end

function createBossZ(x,y)
	local z=createZ(x,y,true)
	z.health=z.health*60
	z.maxHealth=z.health
	z.expValue=z.expValue*60
	z.isBossZ=true
	z.w=z.w*3
	z.h=z.w*3
	z.speed=0.2
	z.expValue=z.expValue*60+inventory.ammo
	return z

end

function createBullet(x,y)
	local b={}
	b.x=x
	b.y=y
	b.direction=player.direction
	b.speed=6
	b.destroy=false
	b.lifetime=nil
	b.area={x=area.pos.x,y=area.pos.y}
	b.dmg=player.weapon.dmg
	b.isCrit=false
	if math.random(0,100)<player.weapon.critChance then
	 b.dmg=b.dmg+b.dmg
	 b.isCrit=true
	end
	b.isCombo=false
	b.firstSpr=49
	b.timeAlive=0
	b.isShotgunShot=false
	b.isSpudGunShot=false
	return b
end

function shotgunShot(x,y)
	local center=createBullet(x,y)
	local left=createBullet(x+2,y+2)
	local right=createBullet(x-2,y-2)
	left.isCombo=true --stops application of multiple combo points
	right.isCombo=true
	center.isShotgunShot=true
	left.isShotgunShot=true
	right.isShotgunShot=true

	table.insert(bullets,left)
	table.insert(bullets,center)
	table.insert(bullets,right)
end

function createComboBlastBullet(x,y)
	local b={}
	b.x=x
	b.y=y
	b.direction=player.direction
	b.speed=6
	b.destroy=false
	b.area={x=area.pos.x,y=area.pos.y}
	b.dmg=player.weapon.comboDmg*(player.combo)
	b.isCrit=false
	b.shred=false
	b.stun=false
	b.exploder=false
	b.stunTime=1*(player.combo)
	b.isCombo=true	
	b.firstSpr=49
	b.timeAlive=0
	b.isShotgunShot=false
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

function createItem(x,y)
	local itemToDrop=math.random(1,100)
	local item={}
	item.w=8
	item.h=8
	item.x=x
	item.y=y

	if itemToDrop>45 and itemToDrop<=60 then
	 item.id=itemId.ammo
	 item.sprite=sprites.ammo
	
	elseif itemToDrop>65 and itemToDrop<=70 then
	 item.id=itemId.health 
	 item.sprite=sprites.healthPack
	
	elseif itemToDrop>75 and itemToDrop<=80 then
	 item.id=itemId.dmgUp
	 item.sprite=sprites.dmgUp
	
	elseif itemToDrop>80 and itemToDrop<=85 then
	 item.id=itemId.critUp
	 item.sprite=sprites.critUp
	else
		item=nil
	end
	
	return item
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
	if entity.area.x ~= area.pos.x or entity.area.y ~= area.pos.y then return false
	else
	  return true
	end
end

function pickupItem(item)
	
	if item.id == itemId.health then 
		local missingHealth=player.maxHealth-player.health
		if missingHealth>0 then
			if player.health+15 < player.maxHealth then
				player.health=player.health+15
			else
				player.health=player.maxHealth
			end			
		end
		table.insert(floatingText,createFloatingText(item.x,item.y,"+".. 15,colours.green))
		healthUpSound()
	elseif item.id == itemId.ammo then
		local pickupAmount=math.random(1,math.ceil(player.weapon.clipSize*0.75))
		pickupAmount=math.ceil(pickupAmount)
		inventory.ammo=inventory.ammo+pickupAmount
		table.insert(floatingText,createFloatingText(item.x,item.y,"+".. pickupAmount .." ammo",colours.yellow))
		sfx(sound.reload,5*12+6,20)
	elseif item.id == itemId.dmgUp then
		local pickupAmount=player.weapon.dmg*0.05
		player.weapon.dmg=player.weapon.dmg+pickupAmount
		player.meleeWeapon.dmg=player.meleeWeapon.dmg+pickupAmount
		table.insert(floatingText,createFloatingText(item.x,item.y,"+".. 5 .."% dmg",colours.blue))
		acceptSound()
	elseif item.id==itemId.critUp then
		player.weapon.critChance=player.weapon.critChance+1
		player.meleeWeapon.critChance=player.meleeWeapon.critChance+1
		table.insert(floatingText,createFloatingText(item.x,item.y,"+" .. 1 .. "% crit",colours.blue)) 
		acceptSound()
	end

end
---------------------------------------------------------------------------------------

function changeArea()
	if player.x>area.w then player.x=area.w	end
	if player.x<0 then player.x=0 end
	if player.y>area.h then player.y=area.h end 
	if player.y<0 then player.y=0 end 
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
	if entity.isBossZ==false then
		spr(entity.sprite+entity.sprIndex,entity.x,entity.y,0,1,0,entity.rot)
	else
	  	spr(entity.sprite+entity.sprIndex,entity.x,entity.y,0,3,0,entity.rot)
	end
	drawHealthBar(entity,true)
end

function drawHealthBar(entity,above)
	local barWidth=(entity.w * 3) --total width
	local barMissing=((entity.maxHealth-entity.health) / entity.maxHealth) * barWidth 
	local sx=entity.x - entity.w
	local y
	if above then y=entity.y-entity.h else y=entity.y+entity.h * 2 end
	local ex=sx + barWidth - barMissing
	local colour=11

	if entity.health<=50 then colour=9 end
	if entity.health<=25 then colour=6 end 

	line(sx,y,sx+barWidth,y,colours.white)
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
		local bullet=bullets[i]		
		if bullet.x < 0 or bullet.x>area.w or bullet.y<0 or bullet.y>area.h or bullet.destroy then --out of bounds, destroy
			
			if not bullet.destroy and player.weapon.name ~= "Dead Future" then --player missed so remove combo points
				player.combo=0
				stats.missedShots=stats.missedShots+1
			end 

			if player.weapon.name=="Dead Future" then
				if bullet.isCombo == false and bullet.destroy ==false  then
					player.combo=0
					stats.missedShots=stats.missedShots+1
				end
			end
			
			table.remove(bullets,i)				
		else
			bullet.timeAlive=bullet.timeAlive+deltaTime
			bullet.x=bullet.x + (bullet.direction.x * bullet.speed) --update
			bullet.y=bullet.y + (bullet.direction.y * bullet.speed)
			if bullet.isSpudGunShot then
				spr(bullet.firstSpr,bullet.x,bullet.y,0,1,0,0,1,1)
			else
			  spr(bullet.firstSpr+bullet.direction.sprIndex,bullet.x,bullet.y,0,1,0,0,1,1)
			end
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
			stats.successfulShots=stats.successfulShots+1
		 if player.combo<player.maxCombo and bullet.isCombo==false and player.weapon.name ~="Spud Gun" then		  
		  player.combo=player.combo+1 
		 end

		 if entity.stun==true and bullet.isCrit==false then
		 	bullet.isCrit=true
		 	bullet.dmg=bullet.dmg*2
		 end
		 if bullet.dmg>stats.mostDmg then stats.mostDmg=bullet.dmg end

		 local textColour=colours.white
		 if bullet.isCrit then 
		 	textColour=colours.yellow
		 	table.insert(floatingText,createFloatingText(entity.x-12,entity.y+8,"CRITICAL!",textColour))

		 	if talents[2].numPoints>0 and bullet.isCombo== false then --talent ability bullet rations
		 		inventory.ammo=inventory.ammo+(talents[2].numPoints)
		 		local percent=(talents[2].numPoints/10)*0.5
		 		bullet.dmg=bullet.dmg-(bullet.dmg*percent)
		 	end
		 end

		 if bullet.isShotgunShot then --shots up close do more dmg
			if bullet.timeAlive<=0.1 then
				local extradmg=bullet.dmg*0.5
				bullet.dmg=bullet.dmg+extradmg				
			 end
		 end

		entity.health=entity.health-bullet.dmg	

		if bullet.shred == true then 
			entity.bleeding=true 
			entity.bleedingStacks=entity.bleedingStacks+1
			table.insert(floatingText,createFloatingText(entity.x+12,entity.y+8,"Bleeding",colours.red))
		end

		if bullet.stun ==true then
		 entity.stun=true
		 entity.stunTimer=bullet.stunTime
		 table.insert(floatingText,createFloatingText(entity.x+12,entity.y+8,"Stunned",colours.blue))
		end

		if bullet.exploder ==true then
			entity.exploderDebuff=true
			table.insert(floatingText,createFloatingText(entity.x+12,entity.y+8,"Explosive",colours.blue))
		end

		bullet.destroy=true
		aggroEntity(entity)
		generateParticleHit(entity,bullet,colours.red)
		table.insert(floatingText,createFloatingText(entity.x+math.random(2,4),entity.y+math.random(2,4),math.floor(bullet.dmg),textColour))
		sfx(sound.hit,2*12+3,5,1) 
		end
		i=i+1
	end

	bleedingTimer=bleedingTimer-deltaTime
	if entity.bleeding==true and bleedingTimer<0 then
		local dmg=(player.weapon.dmg*player.weapon.bleedDmg)*entity.bleedingStacks
		entity.health=entity.health-dmg
		table.insert(floatingText,createFloatingText(entity.x+12,entity.y+8,"-"..math.floor(dmg),colours.red))
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

	if entity.isBossZ then
		if entity.health<entity.maxHealth*0.5 then entity.speed=0.5 end
	end

	if entity.attackTimer>0 then entity.attackTimer=entity.attackTimer-deltaTime end --decrement attack timer

	if withinBounds(entity,player.x,player.y) then ---------------------if within range, attack player
		if entity.attackTimer<=0 then 
			stats.hitsTaken=stats.hitsTaken+1
			local h=player.health-entity.attackDmg
			if h<1 then 
				player.health=-1
			else
			  player.health=player.health-entity.attackDmg
			end
			if talents[3].numPoints>0 then  --athlete talentp
				player.bleeding=true
				player.bleedingTimeLeft=3*talents[3].numPoints
			end
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
	local comboPos={x=50,y=area.h+1}
	print("Score: " ..player.score,0,0)
	print("Waves: "..area.numWaves,64,2)
	print("Ammo: "..inventory.ammo,area.w - 64,0,colours.blue)

	local i=1
	while i<=inventory.clip do
		spr(sprites.bullet,0 +(8*i),area.h,0)
		i=i+1
	end

	

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

createTalents()
increaseDifficulty=true
level=1
bossDead=false
numberOfWaves=1
area=createArea(0,0,numberOfWaves)
spawnTimer=2
Waves.generateWaves(area)
Waves.generateMobs(area.waves[area.currentWave])
menuPressed=false
intervalTimer=0
isInterval=false
function gameState()
	
	spawnTimer=spawnTimer-deltaTime

	if area.clear==false and isInterval==false then 
		if spawnTimer<0 and area.waves[area.currentWave].numMobs>0 then --does the current wave still have mobs?
			Waves.generateMobs(area.waves[area.currentWave]) --create mob
			if level ~=10 then
				if level>5 then 
					spawnTimer=math.random(1,2)
				else
					spawnTimer=math.random(1,3) --countdown to next mob spawn
				end
			else
				if bossDead then currentState.run=endGameState end
			  	spawnTimer=math.random(3,4)
			end
		end
		if spawnTimer<0 and area.waves[area.currentWave].numMobs<1 and #entities<1 and area.numWaves>0 then	--is the current wave finished?   	
			area.currentWave=area.currentWave+1
			area.numWaves=area.numWaves-1
			if area.numWaves<1 then 
				area.clear=true 
				if level==10 then 
					currentState.run=endGameState
				end
				intervalTimer=15
				isInterval=true
			end
		end
	end

	

	Utils.keepTime()
	playerMove()
	playerShoot()
	playerReload()	

	cls(0)
 	map(areaInTiles.w*area.pos.x,areaInTiles.h*area.pos.y,30,16)
 
	playerDraw()

	local i=1
	while i<=#entities do
		local entity=entities[i]
		updateZ(entity)
		animateEntity(entity)
		drawEntity(entity)
		if entity.health<=0 then --if removed then don't need to increment index
			playerExperienceGain(entity.expValue)
			player.score=player.score+entity.scoreValue

			if entity.isMini==false then 
				local item={}
				item = createItem(entity.x,entity.y)
				if item ~= nil then table.insert(itemDrops,item) end
			else
			  local chance=15
			  if math.random(1,100)<chance then 
				table.insert(itemDrops,createItem(entity.x,entity.y))
			  end
			end
			if entity.isBossZ then
				bossDead=true
			end

			if entity.exploderDebuff==true then
				local tmp = {}

				for i=1,8 do
					tmp[i]=createBullet(entity.x,entity.y)
					tmp[i].dmg=player.weapon.dmg*3
					tmp[i].exploder=true
					tmp[i].isCombo=true
				end

				tmp[1].direction=directions.up
				tmp[2].direction=directions.upRight
				tmp[3].direction=directions.right
				tmp[4].direction=directions.downRight
				tmp[5].direction=directions.down
				tmp[6].direction=directions.downLeft
				tmp[7].direction=directions.left
				tmp[8].direction=directions.upLeft

				for i=1,8 do
					table.insert(bullets,tmp[i])
				end			
			end

			table.remove(entities,i) 
			stats.enemiesKilledTotal=stats.enemiesKilledTotal+1
			stats.enemiesKilledThisLevel=stats.enemiesKilledThisLevel+1
		else
		  i=i+1
		end		
	end

	i=1
	while i<=#itemDrops do
		local item=itemDrops[i]
		spr(item.sprite,item.x,item.y,0,1,0)
		if withinBounds(item,player.x,player.y) then
			pickupItem(item)
			table.remove(itemDrops,i)
		else
			i=i+1
		end
	end

	updateBullets()
	updateFloatingText()

	drawParticles()
	drawHUD()

	if isInterval==true then
		intervalTimer=intervalTimer-deltaTime
		print("Interval",(area.w*0.5)-16,area.h+2,colours.yellow)
		statsScreen()
		if intervalTimer<0 then 
			area.clear=false
			isInterval=false
			numberOfWaves=numberOfWaves+1
			level=level+1 
			stats.enemiesKilledThisLevel=0
			stats.expEarntThisLevel=0
			stats.successfulShots=0
			area=createArea(0,0,numberOfWaves)			
			Waves.generateWaves(area)
			for i=1,#itemDrops do
				itemDrops[i]=nil
			end
		end
	end
	
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
	print("Press \'X\' key to start!",titleXpos-4,titleYpos+32,colours.blue)
	print("\'Z\' to reload, \'X\' to shoot,  Arrows to move.",0,titleYpos+56)
	print("\'A\' to open menu, \'S\' for combo ability",0,titleYpos+64)

	if btn(buttons.shoot) and startGame==false then
	 startGame=true
	 startTextColor=colours.red
	 healthUpSound()
	end

	if startGame then 
		startTimer=startTimer-deltaTime	 
	end
	if startTimer<0 then
	 startTimer=1
	 currentState.run=weaponSelectState
	end
end


introTimer=3
introYpos=24
textSpacing=8
zPressed=false
xPressed=false
upPressed=false
downPressed=false
function introductionScreenState()
	cls(0)
	print("Survive as long as you can.",16,introYpos)
	print("Pickup supplies to keep yourself alive.",16,introYpos+(textSpacing*1))
	print("Killing zombies will allow you to unlock ",16,introYpos+(textSpacing*2))
	print("many new ablities.",16,introYpos+(textSpacing*3))
	
	if introTimer<0 then print("Press \'x\' to continue.",16,introYpos+(textSpacing*6),colours.yellow) end

	introTimer=introTimer-deltaTime
	if btn(buttons.shoot) and xPressed==false then xPressed=true end
	if btn(buttons.shoot)==false and xPressed==true then
		xPressed=false
		if introTimer<0 then
			introTimer=3
 			acceptSound()
 			player.x=area.w*0.5
 			player.y=area.h*0.5
	 		currentState.run=gameState
		end	
	end
end


menuOptions = {}
menuOptions[1]="Help"
menuOptions[2]="Level Up"
menuOptions[3]="Inventory"
optionSelected=1
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

titlePos={x=menuPos.x,y=8}
gunNamePos={x=titlePos.x-32,y=titlePos.y+16}
gunInfoPos={x=gunNamePos.x+72,y=gunNamePos.y+16}
weaponIndex=1
rightPressed=false
leftPressed=false
xPressed=false

function weaponSelectState()
	cls(0)
	local numWeapons=#weapons
	print("Weapon Select",menuPos.x,8,colours.green)
	print(weapons[weaponIndex].name,gunNamePos.x,gunNamePos.y,colours.white)
	print("Damage: "..weapons[weaponIndex].dmg,gunInfoPos.x,gunInfoPos.y,colours.red)
	print("Reload: "..weapons[weaponIndex].reloadTime,gunInfoPos.x,gunInfoPos.y+8,colours.yellow)
	print("FireRate: "..weapons[weaponIndex].shootSpeed,gunInfoPos.x,gunInfoPos.y+16,colours.yellow)
	print("Crit: "..weapons[weaponIndex].critChance .. "%",gunInfoPos.x,gunInfoPos.y+24,colours.green)
	print("Clip Size: "..weapons[weaponIndex].clipSize,gunInfoPos.x,gunInfoPos.y+32,colours.white)
	print("Ability: "..weapons[weaponIndex].ability,gunInfoPos.x,gunInfoPos.y+40,colours.blue)

	spr(weapons[weaponIndex].menuSprite,64,gunInfoPos.y,0,2,0,0,2,2)
	spr(264,0,gunInfoPos.y+16,0,2,1,0)
	spr(264,area.w-16,gunInfoPos.y+16,0,2,0,0)
	if btn(buttons.left)==true and leftPressed==false then leftPressed=true end
	if btn(buttons.left)==false and leftPressed==true then
		leftPressed=false
		if weaponIndex>1 then weaponIndex=weaponIndex-1 else
		  weaponIndex=numWeapons
		end
		menuSound()
	end

	if btn(buttons.right)==true and rightPressed==false then rightPressed=true end
	if btn(buttons.right)==false and rightPressed==true then
		rightPressed=false
		if weaponIndex<numWeapons then weaponIndex=weaponIndex+1 else
		  weaponIndex=1
		end		
		menuSound()
	end

	if btn(buttons.shoot)==true and xPressed==false then xPressed=true end
	if btn(buttons.shoot)==false and xPressed==true then
		xPressed=false
		player.weapon=weapons[weaponIndex]
		inventory.ammo=player.weapon.startingAmmo
		inventory.clip=player.weapon.clipSize
		weaponIndex=1
		currentState.run=introductionScreenState
		acceptSound()
	end

	print("\'x\' - accept",menuPos.x +instructionsOffset.x,menuPos.y+instructionsOffset.y,colours.yellow)

end

talentIndex=1
talentNamePos={x=titlePos.x-32,y=titlePos.y+16}
function levelUpState()
	cls(0)
	print("Talents",titlePos.x,titlePos.y,colours.green)
	print("Points - Avl: "..player.talentPoints.." Used: "..player.talentPointsUsed.." Current Level: "..player.level,0,0)
	print("\'x\' - accept \'z\' - back",menuPos.x +instructionsOffset.x,menuPos.y+instructionsOffset.y,colours.yellow)

	spr(264,0,gunInfoPos.y+16,0,2,1,0)
	spr(264,area.w-16,gunInfoPos.y+16,0,2,0,0)
	local numTalents=#talents
	
	print("Name: ".. talents[talentIndex].name,talentNamePos.x,talentNamePos.y,colours.yellow)
	print("Level Req. "..talents[talentIndex].levelRequirement,talentNamePos.x,talentNamePos.y+8,colours.red)
	print("Current Level "..talents[talentIndex].numPoints .."/"..talents[talentIndex].maxPoints,talentNamePos.x,talentNamePos.y+16,colours.white)
	print("Info:",talentNamePos.x-40,talentNamePos.y+50,colours.white)
	print(talents[talentIndex].description,talentNamePos.x-64,talentNamePos.y+58,colours.white)
	print(talents[talentIndex].description1,talentNamePos.x-64,talentNamePos.y+66,colours.white)

	if btn(buttons.left)==true and leftPressed==false then leftPressed=true end
	if btn(buttons.left)==false and leftPressed==true then
		leftPressed=false
		if talentIndex==1 then talentIndex=#talents else
		  talentIndex=talentIndex-1
		end
		menuSound()
	end

	if btn(buttons.right)==true and rightPressed==false then rightPressed=true end
	if btn(buttons.right)==false and rightPressed==true then
		rightPressed=false
		if talentIndex==#talents then
			talentIndex=1
		else		  
		  talentIndex=talentIndex+1
		end
		menuSound()
	end

	if btn(buttons.shoot)==true and xPressed==false then xPressed=true end
	if btn(buttons.shoot)==false and xPressed==true then
		xPressed=false
		local talent=talents[talentIndex]
		if player.level>=talent.levelRequirement then --if meets level requirement
			if player.talentPoints>0 and talent.numPoints<talent.maxPoints then --if player has a point and its not maxed on level
				talent.numPoints=talent.numPoints+1
				player.talentPoints=player.talentPoints-1
				player.talentPointsUsed=player.talentPointsUsed+1

				if talentIndex==1 then notAzombieTalent() end
				if talentIndex==3 then athleteTalent() end
				if talentIndex==4 then player.maxCombo=player.maxCombo+1 end --seasoned talent
				acceptSound()
			end	
		end
	end

	if btn(buttons.reload)==true and zPressed==false then zPressed=true end
	if btn(buttons.reload)==false and zPressed==true then
		zPressed=false
		currentState.run=inGameMenuState
		menuSound()
	end


	print("\'x\' - accept",menuPos.x +instructionsOffset.x,menuPos.y+instructionsOffset.y,colours.yellow)
end

function statsScreen()
	local panelPos={x=40,y=32}
	rect(panelPos.x,panelPos.y,160,80,colours.blue)
	print("Stats for level "..level,panelPos.x+16,panelPos.y+4,colours.white)
	print("Enemies Killed: "..stats.enemiesKilledThisLevel,panelPos.x+2,panelPos.y+12,colours.yellow)
	print("Successful Shots: "..stats.successfulShots,panelPos.x+2,panelPos.y+20,colours.yellow)
	print("Missed Shots: "..stats.missedShots,panelPos.x+2,panelPos.y+28,colours.yellow)
	print("Hits Taken: "..stats.hitsTaken,panelPos.x+2,panelPos.y+36,colours.yellow)
	print("Experience Gained: "..stats.expEarntThisLevel,panelPos.x+2,panelPos.y+44,colours.yellow)
end

restartTimer=5
function endGameState()
	cls(0)
	if player.dead==true then
		print("You Died!...but here's how you did: ",(area.w*0.5)-96,0,colours.red)
	else
		print("You beat the game and this is how well you did: ",(area.w*0.5)-96,0,colours.green)
	end
	
	local panelPos={x=40,y=32}
	rect(panelPos.x,panelPos.y,160,80,colours.blue)
	print("You reached level "..level,panelPos.x+16,panelPos.y+4,colours.white)
	print("Enemies Killed: "..stats.enemiesKilledThisLevel,panelPos.x+2,panelPos.y+12,colours.yellow)
	print("Successful Shots: "..stats.successfulShots,panelPos.x+2,panelPos.y+20,colours.yellow)
	print("Missed Shots: "..stats.missedShots,panelPos.x+2,panelPos.y+28,colours.yellow)
	print("Hits Taken: "..stats.hitsTaken,panelPos.x+2,panelPos.y+36,colours.yellow)
	print("Experience Gained: "..player.totalExperience,panelPos.x+2,panelPos.y+44,colours.yellow)
	print("Highest dmg shot: "..math.floor(stats.mostDmg),panelPos.x+2,panelPos.y+52,colours.yellow)

	restartTimer=restartTimer-deltaTime

	if restartTimer<0 then
		print("Press \'x\' to restart.",0,area.h,colours.white)
	end

	if btn(buttons.shoot) and xPressed== false then xPressed= true end
	if btn(buttons.shoot)==false and xPressed==true then 
		xPressed=false
		if restartTimer<0 then 
			reset()
			currentState.run=startScreenState
		end
	end

end


function notAzombieTalent()
	player.maxHealth=player.maxHealth-((player.maxHealth*0.1))
	player.maxHealth=math.ceil(player.maxHealth)
	if player.health>player.maxHealth then player.health=player.maxHealth end
end

function athleteTalent()
	player.speed=player.speed+(player.speed*0.1)
end

currentState={run=startScreenState}

function TIC()		
	currentState.run()	
end

function reset()

	bullets={}
	entities={}
	itemDrops={}
	floatingText={}
	particles={}
	restartTimer=3
	weaponIndex=1
	player=createPlayer()
	inventory.ammo=50	
	inventory.clip=4
 	introTimer=3
 	startTimer=1
 	startGame=false
 	--gameState variables
 	level=1
	numberOfWaves=1
	area=createArea(0,0,numberOfWaves)
	spawnTimer=2
	Waves.generateWaves(area)
	Waves.generateMobs(area.waves[area.currentWave])
	menuPressed=false
	intervalTimer=0
	isInterval=false

	
	stats.enemiesKilledTotal=0
	stats.enemiesKilledThisLevel=0
	stats.successfulShots=0
	stats.missedShots=0
	stats.hitsTaken=0
	stats.expEarntThisLevel=0
	stats.mostDmg=0
	createTalents()

end

function menuSound()
	sfx(sound.menu,6*12+3,5,1) 
end

function acceptSound()
	sfx(sound.menu,4*12+3,5,1)
end

function healthUpSound()
	sfx(sound.healthUp,4*12+3,20,2)
end