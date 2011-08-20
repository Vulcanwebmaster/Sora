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

function handleRequest(){
	global $streamID, $stream, $DB, $current_user;

	// Publish update
	if($_POST['type'] == "update" && current_user_can("post updates")){
		$allowedKinds = array("message");
		$kind = $_POST['kind'];
		// Is the kind supported?
		if(!in_array($kind, $allowedKinds)){
			return array("error" => "Invalid kind");
		}
		$published = false;
		// Auto publish
		if(in_array("autopublish", $stream['config']) && $stream['config']['autopublish']){
			$published = true;
		}
		// Or the user have rights to self-publish
		if(current_user_can("publish updates") && in_array("publish", $_POST) && $_POST['publish']){
			$published = true;
		}
		$saveData = array(
			"creator" => $DB->users->createDBRef($current_user),
			"time" => new MongoDate(),
			"stream" => $DB->streams->createDBRef($stream),
			"kind" => $kind,
			"published" => $published
		);
		// per-kind save data
		if($kind == "message"){
			if(trim($_POST['text']) == ""){
				return array("error" => "Enter message");
			}
			$saveData['text'] = $_POST['text'];
		}
		// Save it
		$DB->messages->insert($saveData);
		return $saveData;
	}else{
		return array(
			"error" => "No/invalid action or no permission"
		);
	}
}

print json_encode(handleRequest());