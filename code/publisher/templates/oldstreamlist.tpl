{extends "base.tpl"}
{block body}
{include "head.tpl"}
<div class="container" style="margin-top: 60px;">
	<div class="page-header">
		<h1>Stream list</h1>
	</div>
	<table class="common-table zebra-striped">
		<thead>
			<tr><th>Name</th><th>Publish date</th><th>Created</th><th>Creator</th></tr>
		</thead>
		<tbody>
			{foreach $streams as $stream}
			<tr>
				<td><a href="publisher.php?stream={$stream._id}">{$stream.name}</a></td>
				<td>{if $stream.live}{$stream.live->sec|date_format}{else}not set{/if}</td>
				<td>{$stream.created->sec|date_format:"%D %T"}</td>
				<td>{$stream.creator['$id']}</td>
			</tr>
			{/foreach}
		</tbody>
	</table>
	<div class="pagination"> 
		<ul> 
			<li class="prev {if $page == 1}disabled{/if}"><a href="{if $page == 1}#{else}?page={$page-1}{/if}">&larr; Previous</a></li>
			<li class="active"><a href="#">{$page}</a></li> 
			<li class="next {if !$nextpage}disabled{/if}"><a href="{if !$nextpage}#{else}?page={$page+1}{/if}">Next &rarr;</a></li> 
		</ul> 
	</div>
	
	{if $can_create}
	<form action="" method="POST" class="form-stacked">
		<fieldset>
			<legend>Create new stream</legend>
			<div class="clearfix">
				<label for="title">Title:</label>
				<div class="input"><input type="text" name="title" id="title"></div>
			</div>
			<div class="actions">
				<input type="submit" value="Create" class="btn primary">
			</div>
		</fieldset>
	</form>
	{/if}
</div>
{/block}
