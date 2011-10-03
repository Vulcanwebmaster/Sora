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
	"server": "{$server}",
	"static": "{$static}/images/",
};
{literal}
var ioStream = io.connect(stream.server+stream.id);
function renderEvent(d){
	if(d['delete']){
		$("#messagelist .message-"+d['delete']).remove();
	}else{
		tmpl = $("#tmpl_message").html();
		tmpl = $(tmpl);
		tmpl.data("data", d).addClass("message-"+d['_id']);
		if(d['text']){
			$(".message-in", tmpl).html(d['text']);
		}
		if(d['file']){
			$(".message-in", tmpl).prepend("<div><img src='"+stream['static']+d['file']+"'></div>");
		}
		$(".metadata", tmpl).text(new Date((d['time']['sec']*1000)+Math.floor(d['time']['usec']/1000)).toLocaleTimeString() + " by "+d['creator']);
		// find target position
		oldmsg = $("#messagelist .message-"+d['_id']);
		if(oldmsg.length > 0){
			// replace it...
			oldmsg.replaceWith(tmpl);
		}else{
			afterHere = null;
			$("#messagelist .message").each(function(){
				if($(this).data("data").time.sec > d.time.sec){
					afterHere = this;
				}else{
					return false;
				}
			})
			if(afterHere){
				tmpl.insertAfter(afterHere);
			}else{
				tmpl.prependTo("#messagelist");
			}
		}
		// crop
		$("#messagelist .message:gt(100)").remove()
	}
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