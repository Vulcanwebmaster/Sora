<?php
include "lib.inc.php";
if(!is_logged_in()){
	header("Location: login.php");
	die();
}

$streamID = $_GET['stream'];
$stream = $DB->streams->findOne(array("_id" => new MongoID($streamID)));
if(!$stream){
	header("Location: .");
	die();
}

if(array_key_exists("type", $_POST) && current_user_can("delete stream")){
	$type = $_POST['type'];
	if($type == "config"){
		$configTypes = array(
			"autopublish" => "bool"
		);
	}else if($type == "metadata"){
		if(array_key_exists("delete", $_POST) && $_POST['delete']){
			$DB->streams->remove($stream, array("justOne"));
			header("Location: .");
			die();
		}else{
			$stream['name'] = $_POST['name'];
			if(trim($_POST['live']) != "")
				$stream['live'] = new MongoDate((int)$_POST['live']);
			else
				$stream['live'] = null;
			$DB->streams->save($stream);
		}
	}else{
		die("Invalid save type!");
	}
}

$streamRef = $DB->streams->createDBRef($stream);
$messages = $DB->messages->find(array("stream" => $stream));

$SMARTY->assign("stream", $stream);
$SMARTY->assign("messages", $messages);
$SMARTY->assign("can_action", current_user_can("delete stream"));

$SMARTY->display("publisher.tpl");