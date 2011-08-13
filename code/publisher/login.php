<?php
include "lib.inc.php";

if(in_array("username", $_POST)){
	
}

if(is_logged_in()){
	header("Location: .");
	die();
}

$_SESSION['challenge'] = uniqid("", true);
$SMARTY->assign("challenge", $_SESSION['challenge']);
$SMARTY->display("login.tpl");