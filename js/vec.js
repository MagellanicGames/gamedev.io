function vec(xpos,ypos,zpos){
	this.x = xpos;
	this.y = ypos;
	this.z = zpos;
}

function vecAdd(v1,v2){
	return new vec(v1.x + v2.x,v1.y + v2.y,v1.z + v2.z);
}