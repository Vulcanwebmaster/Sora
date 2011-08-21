<div class="alert-message block-message {if $message.published}published{else}notpublish{/if}">
	<p>{$message.text|escape}</p>
	{call messageaction message=$message}
	<div class="twipsy below"> 
		<div class="twipsy-arrow"></div> 
		<div class="twipsy-inner">by <em>{$message.creator['$id']}</em> on {$message.time->sec|date_format:"%T"}</div> 
	</div> 
	<div class="clearfix"></div>
</div>