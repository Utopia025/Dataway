$(document).ready(function() {
	// Changes the color of the header button based on what page is currently presented
	$(".header-button").click(function() {
		$(".header-button").removeClass().addClass("header-button");
		$(this).addClass("active");
	});	
		
});


