var canvas = document.getElementById("myCanvas");
var ctx = canvas.getContext("2d");
var the_score = 0;

var keyboard = {
	up:38,left:37,right:39,down:40
};

function Bullet(dir) {
	this.pos = new vec(player.pos.x,player.pos.y,0);
	this.speed = 5;
	this.dir = dir;
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

var bulletsArray = [];
var bulletSlotsAvailable = 10;

var mouseClickPos = new vec(0,0,0);

var canvasCenter = new vec(canvas.width / 2, canvas.height /2, 0);

var bulletSize = new vec(canvas.width * 0.01,canvas.width * 0.01,0);

var border = {
	color:"black",
	width:"4",
	draw:function(){
		ctx.beginPath();
			ctx.rect(0,0,canvas.width,canvas.height);
			ctx.lineWidth = border.width;
			ctx.strokeStyle = border.color;
			ctx.stroke();
		ctx.closePath();
	}
};

var player = {
	color:"blue",
	size:new vec(canvas.width * 0.05,canvas.height * 0.05,0),
	pos:new vec(canvasCenter.x,canvasCenter.y,0),

	draw:function(){
		ctx.beginPath();
			ctx.rect(player.pos.x,player.pos.y,player.size.x,player.size.y);
			ctx.lineWidth = 4;
			ctx.strokeStyle = player.color;
			ctx.stroke();
		ctx.closePath();
	}
};

var playerMoveDirection = {
	up:false,down:false,left:false,right:false
};



$(document).keypress(function(e){	
		if(e.keyCode == keyboard.down){
			playerMoveDirection.down = true;
		}
		if(e.keyCode == keyboard.left ){
			playerMoveDirection.left = true;
		}
		if(e.keyCode == keyboard.right){
			playerMoveDirection.right = true;
		}

		if(e.keyCode == keyboard.up){
			playerMoveDirection.up = true;
		}
	});

$(document).keyup(function(e){
		if(e.keyCode == keyboard.down){
			playerMoveDirection.down = false;
		}
		if(e.keyCode == keyboard.left ){
			playerMoveDirection.left = false;
		}
		if(e.keyCode == keyboard.right){
			playerMoveDirection.right = false;
		}

		if(e.keyCode == keyboard.up){
			playerMoveDirection.up = false;
		}
});

function cleanUpBullets(){
	for(i = 0; i < bulletsArray.length;i++){
		if(bulletsArray[i] == null){
			continue;
		}
		if(bulletsArray[i].pos.x > canvas.width || bulletsArray[i].y > canvas.height
			|| bulletsArray[i].pos.x < 0 || bulletsArray[i].y < 0){			
				bulletsArray[i] = null;
				bulletSlotsAvailable ++;
		}		
	}
		
}

function createNewBullet(dir){
	vecNormalise(dir);
	if(bulletSlotsAvailable > 0 && bulletSlotsAvailable < 11){
		bulletsArray.push(new Bullet(dir));
		bulletSlotsAvailable --;
	}
	
}

function mousePos(event) {
    mouseClickPos.x = event.offsetX;
    mouseClickPos.y = event.offsetY; 
    createNewBullet(vecSub(mouseClickPos,player.pos));   
}

function draw(){	
	ctx.clearRect(0,0,canvas.width, canvas.height);

	if(playerMoveDirection.up == true){
		player.pos.y -= 1;
	}
	if(playerMoveDirection.down == true){
		player.pos.y += 1;
	}
	if(playerMoveDirection.left == true){
		player.pos.x -= 1;
	}
	if(playerMoveDirection.right == true){
		player.pos.x += 1;
	}
	document.getElementById("score").innerHTML = 'Score:' + the_score;
	border.draw();
	player.draw();
	for(i = 0; i < bulletsArray.length;i++){
		if(bulletsArray[i] != null){
			bulletsArray[i].draw();
		}
		
	}
	cleanUpBullets();
	 //console.log("slots free: " + bulletSlotsAvailable);
}

setInterval(draw,10);