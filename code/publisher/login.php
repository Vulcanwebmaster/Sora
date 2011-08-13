<?php
include "lib.inc.php";

function check_login(){
	global $SMARTY, $DB;
	// 0: Check for no challenge.
	// Or else this would be vulnerable to replay attack
	if(!array_key_exists("challenge", $_SESSION) || $_SESSION['challenge'] == ""){
		// security warning!
		$SMARTY->assign("error", "Challenge could not be verified");
		return false;
	}
	// 1: Get the user from database
	$user = $DB->users->findOne(array("_id" => $_POST['username']));
	if($user === null){
		$SMARTY->assign("error", "Wrong username/password combination.");
		return false;
	}
	// 2: HMAC
	$correct = hash_hmac("sha1", $user['password'], $_SESSION['challenge']);
	if($correct == $_POST['password']){
		// set login
		$_SESSION['user'] = $user['_id'];
		return true;
	}else{
		$SMARTY->assign("error", "Wrong username/password combination.");
		return false;
	}
}

if(array_key_exists("username", $_POST)){
	check_login();
}

if(is_logged_in()){
	header("Location: .");
	die();
}

$_SESSION['challenge'] = uniqid("", true);
$SMARTY->assign("challenge", $_SESSION['challenge']);
$SMARTY->display("login.tpl");