<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6/jquery.min.js"></script>
<script type="text/javascript">
$j = jQuery.noConflict();

$j(document).ready(function() {
	// Changes the color of the header button based on what page is currently presented
	$j(".header-button").click(function() {
		$j(".header-button").removeClass().addClass("header-button");
		$j(this).addClass("active");
	});	
		
});


</script>
