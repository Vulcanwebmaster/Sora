{extends "base.tpl"}
{block "title"}Login | Sora{/block}
{block "head"}
<script src="{$static}/sha1.js"></script>
<script>
var challenge = "{$challenge}";
$(function(){
	$("form").submit(function(){
		var hash = hex_hmac_sha1(challenge, hex_sha1($("#password").val()));
		$("#password").val(hash);
	})
})
</script>
{/block}
{block "body"}
<form action="login.php" method="POST">
<div id="login" class="modal">
	<div class="modal-header">
		<h3>Login</h3>
	</div>
	<div class="modal-body"> 
		{if isset($error)}
		<div class="alert-message error">{$error}</div>
		{/if}
		<div class="clearfix">
			<label for="username">Username</label>
			<div class="input"><input type="text" name="username" id="username"></div>
		</div>
		<div class="clearfix">
			<label for="password">Password</label>
			<div class="input"><input type="password" name="password" id="password"></div>
		</div>
		<noscript>
			<div class="alert-message error"> 
				<p>Cannot login without JavaScript</p> 
			</div> 
		</noscript>
	</div>
	<div class="modal-footer"> 
		<input type="submit" value="Login" class="btn primary" />
	</div>
</div>
</form>
{/block}