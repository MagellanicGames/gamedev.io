-- title:  Zombies
-- author: Magellanic
-- desc:   Kill the zombies
-- script: lua

upSpr=17
rightSpr=18
downSpr=19
leftSpr=20

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

zombie={
	x=84,y=100,
	rot=0,
	speed=0.5,
	w=4,h=4
}

function zombie.withinBounds(self,x,y)
	if x>self.x-self.w and x<self.x+self.w and y>self.y-self.h and y<self.y+self.h then
		return true
	else
	   return false
	 end 
end

shotTimer=1

function createBullet(x,y)
	local b={}
	b.x=x
	b.y=y
	b.direction=player.direction
	b.speed=4
	b.destroy=false
	return b
end

function shoot()

	if btn(5)and shotTimer>1 then
		sfx(0,3*12+6,30)
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

	if player.x>area.w then player.x=0 end
	if player.x<0 then player.x=area.w end
	if player.y>area.h then player.y=0 end
	if player.y<0 then player.y=area.h end
end


z=33
zIndex=0

theTime=time()
lastTime=theTime
deltaTime=0

aniTimer=0
------------------------------
function keepTime()
	lastTime=theTime
	theTime=time()
	deltaTime=(theTime-lastTime)/1000
end
-------------------------------
function chasePlayer()	
	
	if zombie.x<player.x then
	 zombie.x=zombie.x+zombie.speed
	end
	if zombie.x>player.x then
	 zombie.x=zombie.x-zombie.speed
	end
	if zombie.y<player.y then
	 zombie.y=zombie.y+zombie.speed
	end
	if zombie.y>player.y then
	 zombie.y=zombie.y-zombie.speed
 end
	
	if math.abs(zombie.x-player.x) > math.abs(zombie.y-player.y) then
		if zombie.x > player.x then zombie.rot=3
		else zombie.rot=1 end
	else
		if zombie.y>player.y then zombie.rot=0
		else zombie.rot=2 end
	end

	local i=1
	while i <=#bullets do
		if zombie.withinBounds(zombie,bullets[i].x,bullets[i].y) then bullets[i].destroy=true end
		i=i+1
	end
end
-------------------------------------
function animateZombie()
aniTimer=aniTimer+deltaTime
	
	if aniTimer > 0.5 then	
		if zIndex==3 then
		 zIndex=0
		else
			zIndex=zIndex+1
		end
		aniTimer=0
	end
end
------------------------------------
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
	print("Kill the zombies",84,130)
	print("Time: ".. time()/1000)
end
--------------------------------------
function TIC()

	keepTime()
	move()
	shoot()
	chasePlayer()
	animateZombie()



	shotTimer=shotTimer+deltaTime	
	cls(0)
 	map(0,0,30,16)
	spr(player.sprite,player.x,player.y,0)
	spr(z+zIndex,zombie.x,zombie.y,0,1,0,zombie.rot)

	updateBullets()

	drawHUD()	
end
