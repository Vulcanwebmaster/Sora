{extends "base.tpl"}
{block body}
Logged in as {$user._id}
<h1>List of streams</h1>
{foreach $streams as $stream}
<div class="stream">
	<h2><a href="publisher.php?stream={$stream._id}">{$stream.name}</a></h2>
	Publish date {if $stream.live}{$stream.live->sec|date_format}{else}not set{/if} | Created {$stream.created->sec|date_format:"%D %T"} by {$stream.creator['$id']}
</div>
{/foreach}
{if $page > 1}
<a href="?page={$page-1}">Prev page</a>
{/if}
Page {$page} | {$streamcount} items
{if $nextpage}
<a href="?page={$page+1}">Next page</a>
{/if}

{if $can_create}
<form action="" method="POST">
<h1>Create new stream</h1>
<label for="title">Title:</label><input type="text" name="title" id="title">
<input type="submit" value="Create">
</form>
{/if}
{/block}