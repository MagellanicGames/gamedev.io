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

		if(e.keyCode == 32){
			console.log("space pressed");
		}
});

var mouseClickPos = new vec(0,0,0);