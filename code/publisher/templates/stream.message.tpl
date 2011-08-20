<div class="message {if $message.published}published{else}notpublish{/if}">
	<blockquote>{$message.text|escape}</blockquote>
	by {$message.creator['$id']} on {$message.time->sec|date_format:"%T"} {call messageaction message=$message}
</div>