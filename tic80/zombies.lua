-- title:  Zombies
-- author: Magellanic
-- desc:   Kill the zombies
-- script: lua

sound={
	shot=0,
	hit=1,
	playerHit=2
}

upSpr=17
rightSpr=18
downSpr=19
leftSpr=20

FRAMETIME=0.5

shotTimer=1

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
	up={x=0,y=-1},
	upRight={x=0.707106769,y=-0.707106769},
	right={x=0.707106769,y=0},
	downRight={x=0.707106769,y=0.707106769},
	down={x=0,y=1},
	downLeft={x=-0.707106769,y=0.707106769},
	left={x=-1,y=0},
	upLeft={x=-0.707106769,y=-0.707106769}
}

bullets={}
entities={}
floatingText={}

player={
	x=96,y=24,
	direction=directions.up,
	speed=1,
	sprite=upSpr,
	health=100,
	score=0
	}

area={w=240,h=128}
--display is 240x136

function createFloatingText(x,y,val)
	local text={}
	text.x=x
	text.y=y
	text.val=val
	text.lifeTime=1
	text.speed=10
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
	return b
end

function shoot()

	if btn(5)and shotTimer>1 then
		sfx(sound.shot,3*12+6,25)
		shotTimer=0
		table.insert(bullets,createBullet(player.x,player.y))
	end
end

function move()
	if btn(0) and not btn(1) and not btn(2) and not btn(3) then--up
	
		player.direction=directions.up
		player.sprite=upSpr
	end
	if btn(1) and not btn(0) and not btn(2) and not btn(3)then--down
	
		player.direction=directions.down
		player.sprite=downSpr
	end
	if btn(2) and not btn(1) and not btn(0) and not btn(3)then--left
	
		player.direction=directions.left
		player.sprite=leftSpr
	end
	if btn(3) and not btn(1) and not btn(2) and not btn(0)then--right
	 
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
function keepTime()
	lastTime=theTime
	theTime=time()
	deltaTime=(theTime-lastTime)/1000
end
-----------------------------------------------
function updateFloatingText()
	if #floatingText<1 then return end
	local i=1
	while i<= #floatingText do
		if floatingText[i].lifeTime>0 then 
			floatingText[i].lifeTime=floatingText[i].lifeTime-deltaTime --countdown life time
			floatingText[i].y=floatingText[i].y-(floatingText[i].speed*deltaTime)--move text
			print(floatingText[i].val,floatingText[i].x,floatingText[i].y,15,true,1)--print text
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
		 table.insert(floatingText,createFloatingText(entity.x,entity.y,bullets[i].dmg))
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
end
------------------------------------
function drawHealthBar(entity)

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
			spr(49,bullets[i].x,bullets[i].y,0)
			i=i+1	
			end			
	end
	
end
------------------------------------
function drawHUD()
	print("Health: "..player.health,0,area.h)
	print("Score: " ..player.score)
	print("Kill the zombies",84,130)
	--print("Time: ".. time()/1000)
end
--------------------------------------

table.insert(entities,createZ(84,100))
table.insert(entities,createZ(150,80))
table.insert(entities,createZ(10,20))
table.insert(entities,createZ(212,100))
function TIC()

	if #entities==0 then currentAreaClear=true end

	keepTime()
	move()
	shoot()

	shotTimer=shotTimer+deltaTime	
	cls(0)
 	map(areaInTiles.w*currentArea.x,areaInTiles.h*currentArea.y,30,16)
	spr(player.sprite,player.x,player.y,0)

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
	drawHUD()	
end
