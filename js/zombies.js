var canvas = document.getElementById("myCanvas");
var ctx = canvas.getContext("2d");
var the_score = 0;
var currentBulletDmg = 2;
var zombieSpawnTimer = 3000;

var drawTimer = setInterval(drawGame,10);
var zombieTimer = setInterval(createNewZombie,zombieSpawnTimer);

var keyboard = {
	up:38,left:37,right:39,down:40
};


var bulletsArray = [];
var bulletSlotsAvailable = 10;
var bulletSize = new vec(canvas.width * 0.005,canvas.width * 0.005,0);

var zombieArray = [];
var zombieSlotsAvailable = 25;
var shotSound = new Sound("Sounds/shot.ogg");


var canvasCenter = new vec(canvas.width / 2, canvas.height /2, 0);

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


function mousePos(event) {
    mouseClickPos.x = event.offsetX;
    mouseClickPos.y = event.offsetY; 
    createNewBullet(new vec(player.pos.x,player.pos.y,0),vecSub(mouseClickPos,player.pos));   
    shotSound.play();
}


function drawGame(){	
	ctx.clearRect(0,0,canvas.width, canvas.height);

	if(playerMoveDirection.up == true){ //controls called from controls.js
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
	document.getElementById("health").innerHTML = 'Health:';
	document.getElementById("ammo").innerHTML = 'Ammo:';
	border.draw();
	player.draw();

	for(i = 0; i < zombieArray.length; i++){
		if(zombieArray[i] != null){
			zombieArray[i].draw();
		}		
	}
	for(i = 0; i < bulletsArray.length;i++){
		if(bulletsArray[i] != null){
			bulletsArray[i].draw();
		}
		
	}

	cleanUpBullets(); //bullets.js
	cleanUpZombies();//enemies.js
	 //console.log("slots free: " + bulletSlotsAvailable);
}

function drawStartMenu(){
	ctx.clearRect(0,0,canvas.width, canvas.height);
	ctx.beginPath();
			ctx.rect(player.pos.x,player.pos.y,player.size.x,player.size.y);
			ctx.lineWidth = 4;
			ctx.strokeStyle = "#f4a742";
			ctx.stroke();
		ctx.closePath();
}