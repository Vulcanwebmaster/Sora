{extends "base.tpl"}
{block title}Publisher | Sora{/block}
{block head}
	<script src="{$server}socket.io/socket.io.js"></script>
	<script src="{$static}position.js"></script>
	<script src="{$static}mustache.js"></script>
	<style>
html,body{ width:100%;height:100%;margin:0;padding:0; }
body{
	font-family: Helvetica, verdana, sans-serif;
	background: #555;
}
header{
	width: 100%;
	background: #ddd;
	padding: 10px;
	font-size: 18pt;
	text-shadow: #ccc 0px 2px 1px;
	border-bottom: #aaa solid 1px;
	box-sizing: border-box;
}
header small{
	font-size: 10pt;
	vertical-align: middle;
}
.pane{
	width: 20%;
	background: #eee;
	border-right: #aaa solid 1px;
	height: 90%;
	box-sizing: border-box;
	position: relative;
	float: left;
}
.pane-in{
	height: 92%;
	overflow: auto;
}
.pane.fit{ width:80%; }
.pane ul{
	margin:0;
	list-style: none;
	padding:0;
}
.pane li{
	border-bottom: #ccc solid 1px;
}
.pane li a{
	display: block;
	padding: 10px;
	text-decoration:none;
	color: inherit;
}
.pane li a:hover, .pane li.selected a{
	background: #acf;
}
.pane .footer{
	position: absolute;
	bottom: 0px;
	background: #ddd;
	width: 100%;
	padding: 10px;
	box-sizing: border-box;
	border-top: #ccc solid 1px;
}
.message{
	margin: 10px;
	border: #333 solid 1px;
	padding: 5px;
	border-radius: 10px;
	background: #ddd;
}
.message img{
	max-width: 200px;
	max-height: 200px;
}
.msgright{
	float: right;
	font-size: 10pt;
	vertical-align: middle;
	color: #888;
}
.metadata{
	float: left;
}
.msgaction{
	float: left;
}
label{
	font-size: 10pt;
}
input[name=text]{
	width: 50%;
}
input[type=file]{
	width: 20%;
}
#publishcheck{
	margin-right: 10px;
	padding: 5px;
	border-radius: 5px;
}
.footer input[type=submit]{
	display: none;
}
.config{
	float: right;
}
.popup{
	padding: 10px;
	background: rgba(0,0,0,0.8);
	color: white;
	margin: 10px;
	-webkit-border-radius: 5px;
	z-index: 1000;
	display: none;
	width: 400px;
}
.popup a{
	color: white !important;
}
#streamlist .selected{ background: #ccc; }
@media all and (max-width: 900px) {
	.pane:not(:last-child){
		display: none;
	}
	.pane{
		width: 100% !important;
	}
}
	</style>
	<script>
var client, streamid;
var template;
io.transports = ["xhr-polling"];
$.get("templates/message.ms", function(d){
	template = d
});
function resize(){
	$(".pane").css("height", $(window).height()-$("header").outerHeight());
}
$(function(){
	$(window).resize(resize).resize();
	$("input[name=publish]").change(function(){
		if($(this).is(":checked")){
			$("#publishcheck").css("background", "#cfc");
		}else{
			$("#publishcheck").css("background", "transparent");
		}
	});
	$("#streamlist a").click(function(){
		if($(this).data("id") == streamid){
			return false;
		}
		$("#streamlist a.selected").removeClass("selected");
		$(this).addClass("selected")
		$(".pane.fit").remove();
		$("<div class='pane fit' />").appendTo("#container").load($(this).attr("href"));
		if(client){
			client.removeAllListeners();
		}
		streamid = $(this).data("id");
		client = io.connect("{$server}" + $(this).data("id"));
		client.on('message', function(e){
			if(e.delete){
				$("#container .pane.fit .pane-in .message[data-id="+e.delete+"]").remove();
			}else{
				e.static = "{$static}";
				e.can_action = !!{$can_action};
				e.can_post = !!{$can_post};
				e.can_publish = !!{$can_publish};
				e.can_delete = !!{$can_delete};
				var html = Mustache.to_html(template, e);
				console.log(e);
				if($("#container .pane.fit .pane-in .message[data-id="+e._id+"]").length > 0){
					$("#container .pane.fit .pane-in .message[data-id="+e._id+"]").replaceWith(html);
				}else{
					$(html).prependTo("#container .pane.fit .pane-in");
				}
			}
		})
		resize();
		return false;
	});
	$("#container").delegate(".btn_config", "click", function(){
		$("#streamconfig").fadeToggle(100).position({ "my": "right bottom", "at": "right top", "of": this, "offset": "-5 -5" });
	}).delegate(".ajaxme", "submit", function(e){
		var fdata = new FormData(this);
		var xhr = new XMLHttpRequest();
		xhr.open("POST", $(this).attr("action") || $(this).attr("href"));
		xhr.send(fdata);
		if($(this).hasClass("thenrefresh")){
			setTimeout(function(){ window.location.reload(); }, 250);
		}
		$("input[name=text]", this).val("");
		$("input[name=pic]", this).val("");
		e.preventDefault();
		$(".popup").fadeOut(100);
	}).delegate(".btn-del", "click", function(){
		var id = $(this).parents(".message").data("id");
		if(!confirm("Delete "+$(".messagebody", $(this).parents(".message")).text().replace(/{literal}[ \n\r\t]{2,}{/literal}/g, " ")+"?")){
			return;
		}
		$.get("publishserver.php", { "act": "delete", "id": id, "stream": streamid });
	}).delegate(".btn-pub", "click", function(){
		var id = $(this).parents(".message").data("id");
		$.get("publishserver.php", { "act": "publish", "stream": streamid, "id": id });
	});
	$(".btn_create").click(function(){
		$("#addstreampop").fadeToggle(100).position({ "my": "left bottom", "at": "left top", "of": this, "offset": "-5 -5" });
	});
})
	</script>
{/block}
{block body}
<header>
	Publisher <small>v0.1</small>
</header>
<div id="container">
<div class="pane">
	<ul id="streamlist">
		{foreach $streams as $stream}
		<li><a href="publisher.php?stream={$stream._id}" data-id="{$stream._id}">{$stream.name}</a></li>
		{/foreach}
	</ul>
	<div class="popup" id="addstreampop">
		<strong>Add new stream</strong>
		<form action="" method="post">
			<input type="text" name="title" id="title">
			<input type="submit">
		</form>
	</div>
	<div class="footer">
		{if $can_create}
		<button class="btn_create">+</button>
		{/if}
	</div>
</div>
</div>
{/block}