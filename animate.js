var blinkOn = 1;
var firstRun = 1;
var element = document.getElementById("blink");

var intervalTime = 400;
var arrayPos = 0;

var title = ["W",":","\\","M","a","g","e","l","l","a","n","i","c"," ","G","a","m","e","s"];

var titleString = "";
var blinkString = " ";

function blink(){
	if(blinkOn == 1)
	{
		blinkString = " ";
		blinkOn = 0;
	}
	else
	{
		blinkString = "_";
		blinkOn = 1;
	}
}

function animateBlink(){
	blink();
	element.innerHTML = "W:\\Magellanic Games" + blinkString;
}

function animation(){	

	if(firstRun == 1)
	{
		titleString = titleString + title[arrayPos] ;
		element.innerHTML = titleString + blinkString;
		arrayPos ++;
		if(arrayPos == title.length - 1){
			firstRun = 0;					
		}
		blink();
	}
	else
	{
		animateBlink();
	}
	
}

setInterval(animation,intervalTime);