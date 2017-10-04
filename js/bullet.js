function Bullet(pos, dir) {
	this.pos = pos;
	this.speed = 20;
	this.dir = dir;
	this.dmg = currentBulletDmg;
	this.destroy = false;
}

Bullet.prototype.draw = function(){
	this.pos.x += this.dir.x * this.speed;
	this.pos.y += this.dir.y * this.speed;
	ctx.beginPath();
			ctx.rect(this.pos.x,this.pos.y,bulletSize.x,bulletSize.y);			
			ctx.fillStyle = "#0095DD";
			ctx.fill();
			ctx.lineWidth = "1";
			ctx.strokeStyle = "black";			
			ctx.stroke();
	ctx.closePath();	
}

function cleanUpBullets(){
	for(i = 0; i < bulletsArray.length;i++){
		if(bulletsArray[i] == null){
			continue;
		}
		if(bulletsArray[i].pos.x > canvas.width || bulletsArray[i].y > canvas.height
			|| bulletsArray[i].pos.x < 0 || bulletsArray[i].y < 0 || bulletsArray[i].destroy == true){			
				bulletsArray[i] = null;
				bulletSlotsAvailable ++;
		}		
	}		
}

function createNewBullet(pos, dir){
	vecNormalise(dir);
	if(bulletSlotsAvailable > 0 && bulletSlotsAvailable < 11){
		bulletsArray.push(new Bullet(pos, dir));
		bulletSlotsAvailable --;
	}
}