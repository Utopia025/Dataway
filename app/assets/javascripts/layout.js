





// Changes the color of the header button based on what page is currently presented
function buttonColorChange(self)
{
	document.getElementByTagName("header-button").className = "header-button";
	document.getElementById(self).className += " active";
}




