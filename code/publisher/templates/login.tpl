{extends "base.tpl"}
{block "title"}Login | Sora{/block}
{block "head"}
<script src="{$static}/sha1.js"></script>
<script>
var challenge = "{$challenge}";
$(function(){
	$("form").submit(function(){
		var hash = hex_hmac_sha1(challenge, $("#password").val());
		$("#password").val(hash);
	})
})
</script>
{/block}
{block "body"}
<div id="login">
<h1>Login</h1>
<form action="login.php" method="POST">
	<table>
		<tr><th><label for="username">Username</label></th><td><input type="text" name="username" id="username"></td></tr>
		<tr><th><label for="password">Password</label></th><td><input type="password" name="password" id="password"></td></tr>
	</table>
	<noscript>Cannot login without JavaScript</noscript>
	<input type="submit" value="Login" />
</form>
</div>
{/block}