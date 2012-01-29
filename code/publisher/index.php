<?php
include "lib.inc.php";
if(!is_logged_in()){
	header("Location: login.php");
	die();
}

// add new stream
if(array_key_exists("title", $_POST) && trim($_POST['title']) != ""){
	$stream = array(
		"config" => array(),
		"created" => new MongoDate(),
		"live" => null,
		"name" => $_POST['title'],
		"creator" => $DB->users->createDBRef($current_user),
	);
	$DB->streams->insert($stream);
	regenerate_html($stream);
}

$q = $DB->streams->find()->sort(array("created" => -1));

$SMARTY->assign("streams", $q);
$SMARTY->assign("can_create", current_user_can("create stream"));

$SMARTY->assign("can_action", current_user_can("delete stream"));
$SMARTY->assign("can_post", current_user_can("post message"));
$SMARTY->assign("can_publish", current_user_can("publish message"));
$SMARTY->assign("can_delete", current_user_can("delete message"));

$SMARTY->display("publisher.tpl");