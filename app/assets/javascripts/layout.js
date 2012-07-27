<script type="text/javascript" src="jquery.js">
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
</script>
