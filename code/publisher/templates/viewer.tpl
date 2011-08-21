<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>{$stream.name}</title>
	<script src="{$static}/jquery-1.6.2.min.js"></script>
	<script src="{$server}socket.io/socket.io.js"></script>
	<script>
var stream = {
	"id": "{$stream._id}",
	"server": "{$server}"
};
{literal}
var renderedEventsId = [];
var ioStream = io.connect(stream.server+stream.id);
function renderEvent(d){
	if(renderedEventsId.indexOf(d['_id']) != -1) return;
	renderedEventsId.push(d['_id']);
	tmpl = $("#tmpl_message").html();
	tmpl = $(tmpl);
	$(".message-in", tmpl).html(d['text']);
	$(".metadata", tmpl).text(new Date((d['time']['sec']*1000)+Math.floor(d['time']['usec']/1000)).toLocaleTimeString() + " by "+d['creator']);
	tmpl.prependTo("#messagelist");
}
function updateStream(){
	$.getJSON("/getstream.php", {"stream": stream.id}, function(d){
		$.each(d, function(k,v){renderEvent(v);});
	});
}
ioStream.on("message", function(d){
	renderEvent(d);
});
$(function(){
	updateStream();
});
{/literal}
	</script>
</head>
<body>
<div id="messagelist"></div>
<div style="display: none;">
	<div id="tmpl_message">
		<div class="message">
			<div class="message-in"></div>
			<div class="metadata"></div>
		</div>
	</div>
</div>
</body>
</html>