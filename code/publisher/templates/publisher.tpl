{extends "base.tpl"}
{block "title"}{$stream.name} | Sora{/block}
{block "head"}
<script src="{$server}socket.io/socket.io.js"></script>
<script>
var ioStream = io.connect("{$server}{$stream._id}")
ioStream.on("message", function(d){
	var e = $("#tmpl_"+d.kind).html();
	$.each(d, function(k,v){
		if(k == "time") v = new Date(v['sec']).toLocaleTimeString();
		else if(k == "creator") v = v['$id'];
		e = e.replace(new RegExp("%"+k+"%", "g"), v);
	});
	if(d['published']){
		publishState = "Unpublish <small>(was published by "+d.publisher['$id']+")</small>";
	}else{
		publishState = "Publish";
	}
	e = e.replace(/%msgaction%/d, '<div style="float: right;"><a href="publishserver.php?act=publish&stream={$stream._id}&id='+d['_id']['$id']+'" class="btn publishToggle">'+publishState+'</a> <a href="publishserver.php?act=delete&stream={$stream._id}&id='+d['_id']['$id']+'" onclick="return confirm(\'Delete this message?\');" class="btn">Delete</a></div>');
	e = $(e);
	if(d['published']){
		e.addClass("published");
	}else{
		e.addClass("notpublish");
	}
	e.data("data", d).addClass("message-"+d['_id']['$id']);
	oldmsg = $("#messages .message-"+d['_id']['$id']);
	if(oldmsg.length > 0){
		// replace it...
		oldmsg.replaceWith(e);
	}else{
		afterHere = null;
		$("#messages .message").each(function(){
			if($(this).data("data").time.sec > d.time.sec){
				afterHere = this;
			}else{
				return false;
			}
		})
		if(afterHere){
			e.insertAfter(afterHere);
		}else{
			e.prependTo("#messages");
		}
	}
	// crop
	$("#messages .message:gt(100)").remove()
});
</script>
{/block}
{block "body"}
{function messageaction}
{if $message}
<div style="float: right;"><a href="publishserver.php?act=publish&stream={$stream._id}&id={$message._id}" class="btn">{if $message.published}Unpublish <small>(was published by {$message.publisher['$id']})</small>{else}Publish{/if}</a> <a href="publishserver.php?act=delete&stream={$stream._id}&id={$message._id}" onclick="return confirm('Delete this message?');" class="btn">Delete</a></div>
{else}
%msgaction%
{/if}
{/function}
{include "head.tpl"}
<div class="container" style="margin-top: 60px;">
<div class="page-header">
	<h1>{$stream.name} <small><a href="../static/viewer/{$stream._id}.html" target="_blank">View client</a></small></h1>
</div>
<div class="row">
	<div id="messages" class="span11 column">
		{foreach $messages as $message}
		{include file="stream.`$message.kind`.tpl" message=$message}
		{/foreach}
		<div class="pagination"> 
			<ul> 
				<li class="prev {if $page == 1}disabled{/if}"><a href="{if $page == 1}#{else}?page={$page-1}{/if}">&larr; Previous</a></li>
				<li class="active"><a href="#">{$page}</a></li> 
				<li class="next {if !$nextpage}disabled{/if}"><a href="{if !$nextpage}#{else}?page={$page+1}{/if}">Next &rarr;</a></li> 
			</ul> 
		</div>
	</div>
	{if $can_action}
	<div id="action" class="span5 column">
		<form action="" method="POST" class="form-stacked">
			<fieldset id="config">
				<legend for="config">Configuration</legend>
				<div class="clearfix">
					<ul class="inputs-list">
						<li>
							<label for="autopublish">
								<input type="checkbox" id="autopublish" name="autopublish" {if $stream.config.autopublish|default:false}checked{/if}>
								<span>Automatically publish new items</span>
							</label>
					</ul>
				</div>
				<input type="hidden" name="type" value="config">
				<input type="submit" value="Save" class="btn primary">
				<a href="publisher.php?stream={$stream._id}&act=regenerate" class="btn">Regenerate client page</a>
			</fieldset>
		</form>
		<form action="" method="POST" class="form-stacked">
			<fieldset id="metadata">
				<legend for="metadata">Metadata</legend>
					<div class="clearfix">
						<label for="">Title</label>
						<div class="input"><input type="text" name="name" value="{$stream.name}"></div>
					</div>
					<div class="clearfix">
						<label for="">Live date/time</label>
						<div class="input"><input type="text" name="live" value="{$stream.live}"></div>
					</div>
					<input type="hidden" name="type" value="metadata">
					<input type="submit" value="Save" class="btn primary">
					<input type="submit" name="delete" value="Delete" onclick="return confirm('Delete stream?')" class="btn">
				</form>
			</fieldset>
		</form>
	</div>
	{/if}
	{if $can_post}
	<div id="postform" class="span11 column">
		<form action="publishserver.php?stream={$stream._id}" method="post" class="form-stacked">
			<fieldset>
				<legend>Add message</legend>
				<div class="clearfix">
					<label for="kind box">Kind:</label> 
					<div class="input"><select name="kind" id="kindbox">
						<option value="message">Text</option>
					</select></div>
				</div>
				<div class="clearfix">
					<div class="input">
						<div class="input-prepend">
							<span class="add-on {if $stream.config.autopublish|default:false}active{/if}">
								{if $stream.config.autopublish|default:false or $can_publish}
								<label for="publish" style="display:inline;">Publish</label>
								<input type="checkbox" id="publish" name="publish"{if $stream.config.autopublish|default:false} checked{/if}>
								{/if}
							</span>
							<input class="xlarge" type="text" name="text">
						</div>
					</div>
				</div>
				<div class="actions">
					<input type="submit" value="Add" class="btn primary">
				</div>
				<input type="hidden" name="type" value="update">
			</fieldset>
		</form>
	</div>
	{/if}
</div>
<div style="display: none;">
	<div id="tmpl_message">
		{include file="stream.message.tpl" message=null}
	</div>
</div>
</div>
</div>
{/block}
