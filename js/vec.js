function vec(xpos,ypos,zpos){
	this.x = xpos;
	this.y = ypos;
	this.z = zpos;
}

function vecAdd(v1,v2){
	return new vec(v1.x + v2.x,v1.y + v2.y,v1.z + v2.z);
}

function vecSub(v1,v2){
	return new vec(v1.x - v2.x,v1.y - v2.y,v1.z - v2.z);
}

function vecLength(vector){
	return Math.sqrt((vector.x * vector.x) + (vector.y * vector.y));
}

function vecNormalise(vector){
	var length = vecLength(vector);
	vector.x = vector.x / length;
	vector.y = vector.y / length;
}