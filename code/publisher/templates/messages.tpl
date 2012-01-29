<div class="pane-in">{$messages|join:""}</div>
{if $can_action}
<div class="popup" id="streamconfig">
<strong>Configuration</strong>
<form action="publisher.php?stream={$stream._id}" method="POST" class="ajaxme">
	<input type="checkbox" id="autopublish" name="autopublish" {if $stream.config.autopublish|default:false}checked{/if}> <span>Automatically publish new items</span><br>
	<input type="hidden" name="type" value="config">
	<input type="submit" value="Save">
</form>
<strong>Metadata</strong>
<form action="publisher.php?stream={$stream._id}" method="POST" class="ajaxme thenrefresh">
	Title <input type="text" name="name" value="{$stream.name}"><br>
	<input type="hidden" name="type" value="metadata">
	<input type="submit" value="Save">
</form>
<form action="publisher.php?stream={$stream._id}" method="POST" class="ajaxme thenrefresh">
	<input type="hidden" name="type" value="metadata">
	<input type="hidden" name="delete" value="Delete">
	<input type="submit" value="Delete" onclick="return confirm('Delete stream?')">
</form>
<form action="publisher.php?stream={$stream._id}&amp;act=regenerate" method="GET" class="ajaxme">
	<input type="submit" value="Regenerate client page"> (<a href="{$static}viewer/{$stream._id}.html" target="_blank">Client page</a>)
</form>
</div>
{/if}
<div class="footer">
	{if $can_action}<div class="config">
		<button class="btn_config">Config</button>
	</div>{/if}
	{if $can_post}
	<form id="publishform" action="publishserver.php?stream={$stream._id}" enctype="multipart/form-data" method="post" class="ajaxme">
		{if $can_publish}<span id="publishcheck">
		<input type="checkbox" name="publish" id="publish">
		<label for="publish">Publish</label>
		</span>{/if}
		<input type="text" name="text" autofocus>
		<input type="file" name="pic">
		<input type="submit" value="Submit">
		<input type="hidden" name="type" value="update">
	</form>
	{/if}
</div>