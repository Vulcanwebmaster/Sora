<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>{block "title"}Sora{/block}</title>
	<script src="{$static}/jquery-1.6.2.min.js"></script>
	<link rel="stylesheet" href="{$static}/bootstrap-1.0.0.min.css">
	<script>
$(function(){
	$('.add-on :checkbox').click(function() {
	    if ($(this).attr('checked')) {
	      $(this).parents('.add-on').addClass('active');
	    } else {
	      $(this).parents('.add-on').removeClass('active');
	    }
	  });
});
	</script>
	{block head}{/block}
</head>
<body>
{block "body"}{/block}
</body>
</html>