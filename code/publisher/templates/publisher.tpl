{extends "base.tpl"}
{block "title"}{$stream.name} | Sora{/block}
{block "body"}
{function messageaction}
<a href="publishserver.php?act=publish&stream={$stream._id}&id={$message._id}">{if $message.published}Unpublish <small>(was published by {$message.publisher['$id']})</small>{else}Publish{/if}</a> | <a href="publishserver.php?act=delete&stream={$stream._id}&id={$message._id}" onclick="return confirm('Delete this message?');">Delete</a>
{/function}
<h1>{$stream.name}</h1>
<div id="messages" class="box">
{foreach $messages as $message}
{include file="stream.`$message.kind`.tpl" message=$message}
{/foreach}
{if $page > 1}
<a href="?page={$page-1}">Prev page</a>
{/if}
Page {$page} | {$total_message} items
{if $nextpage}
<a href="?page={$page+1}">Next page</a>
{/if}
</div>
{if $can_post}
<div id="postform" class="box">
	<form action="publishserver.php?stream={$stream._id}" method="post">
		<strong>Kind:</strong> <select name="kind">
			<option value="message">Text</option>
		</select><br />
		<input type="text" name="text"><br />
		{if $stream.config.autopublish|default:false or $can_publish}
		<input type="checkbox" name="publish"{if $stream.config.autopublish|default:false} checked{/if}> Publish<br/>
		{/if}
		<input type="submit" value="Add">
		<input type="hidden" name="type" value="update">
	</form>
</div>
{/if}
{if $can_action}
<div id="action" class="box">
	<h2>Stream</h2>
	<fieldset id="config">
		<legend for="config">Configuration</legend>
		<form action="" method="POST">
			<ul>
				<li><input type="checkbox" name="autopublish" {if $stream.config.autopublish|default:false}checked{/if}> Auto publish new items</li>
			</ul>
			<input type="hidden" name="type" value="config">
			<input type="submit" value="Save">
		</form>
	</fieldset>
	<fieldset id="metadata">
		<legend for="metadata">Metadata</legend>
		<form action="" method="POST">
			<ul>
				<li><strong>Title:</strong> <input type="text" name="name" value="{$stream.name}"></li>
				<li><strong>Live date/time:</strong> <input type="text" name="live" value="{$stream.live}"></li>
			</ul>
			<input type="hidden" name="type" value="metadata">
			<input type="submit" value="Save">
			<input type="submit" name="delete" value="Delete" onclick="return confirm('Delete stream?')">
		</form>
	</fieldset>
</div>
{/if}
{/block}