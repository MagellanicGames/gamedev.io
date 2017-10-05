function Zombie(position){
	this.pos = position;
	this.size = new vec(canvas.width * 0.05,canvas.height * 0.05,0);
	this.speed = 1.5;
	this.dir = new vec(0,1,0);
	this.dead = false;
	this.health = 10
}

Zombie.prototype.draw = function(){
	this.dir = vecSub(player.pos,this.pos);
	vecNormalise(this.dir);
	this.pos.x += this.dir.x * this.speed;
	this.pos.y += this.dir.y * this.speed;
	ctx.beginPath();
			ctx.rect(this.pos.x,this.pos.y,this.size.x,this.size.y);			
			ctx.fillStyle = "#0095DD";
			ctx.fill();
			ctx.lineWidth = "1";
			ctx.strokeStyle = "black";			
			ctx.stroke();
	ctx.closePath();

	for(i = 0; i < bulletsArray.length; i++){
		var b = bulletsArray[i];
		if(b != null){
			if(this.withinBounds(b.pos)){
				this.health -= b.dmg;
				b.destroy = true;
			}
		}
	}
	if(this.health < 0){
		this.dead = true;
	}
}

Zombie.prototype.withinBounds = function(point){
	if(point.x > this.pos.x && point.x < this.pos.x + this.size.x &&
		point.y > this.pos.y && point.y < this.pos.y + this.size.y){
		return true;
	}
	else{
		return false;
	}
}

function cleanUpZombies(){
	for(i = 0; i < zombieArray.length; i++){

		if(zombieArray[i] == null){
			continue;
		}
		if(zombieArray[i].dead == true){
			zombieArray[i] = null;
			zombieSlotsAvailable ++;	
			console.log("Zombie cleaned up.");
		}
	}
}

function createNewZombie(){
	zombieSpawnTimer = (Math.Random * 10000) + 2000;
	if(zombieSlotsAvailable > 0 && zombieSlotsAvailable < 26){
		zombieArray.push(new Zombie(generateRandomSpawn()));
		zombieSlotsAvailable --;
		
	}
}


function randomNumber(min,max){
	return Math.random() * (max - min) + min;
}

function generateRandomSpawn(){
	var x = randomNumber(0,1024);
	var chance = randomNumber(0,100);
	var y = 0;
	if(chance < 50){
		y = randomNumber(-300,0);
	}
	else if( chance > 50){
		y = randomNumber(768,1068);
	}	
	return new vec(x,y,0);
}