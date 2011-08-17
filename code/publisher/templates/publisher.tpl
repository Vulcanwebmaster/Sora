{extends "base.tpl"}
{block "title"}{$stream.name} | Sora{/block}
{block "body"}
<h1>{$stream.name}</h1>
<div id="messages" class="box">
	List of messages
</div>
<div id="postform" class="box">
	Post message
</div>
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
			<input type="submit" name="delete" value="Delete" onclick="return confirm('Delete?')">
		</form>
	</fieldset>
</div>
{/if}
{/block}