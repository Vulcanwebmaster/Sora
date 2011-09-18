<div class="message message-{$message['_id']} alert-message block-message {if $message and $message.published}published{else if $message}notpublish{/if}" data-data='{htmlentities(json_encode($message))}'>
	<p>{$message.text|default:"%text%"}</p>
	{call messageaction message=$message}
	<div class="twipsy below"> 
		<div class="twipsy-arrow"></div> 
		<div class="twipsy-inner">by <em>{$message.creator['$id']|default:"%creator%"}</em> on {$message.time->sec|date_format:"%T"|default:"%time%"}</div> 
	</div> 
	<div class="clearfix"></div>
</div>