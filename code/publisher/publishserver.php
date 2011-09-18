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

function pushEvent($msg){
	global $DB, $config, $streamID;
	$allowed = array("_id", "kind", "text", "time", "creator");
	$out = array();
	foreach($allowed as $allow){
		$out[$allow] = $msg[$allow];
	}
	$out['creator'] = $DB->users->getDBRef($out['creator']);
	$out['creator'] = $out['creator']['name'];
	$out['_id'] = $out['_id']->{'$id'};
	if($msg['published']){
		file_get_contents($config['viewerhost'].$streamID."?key=".rawurlencode($config['viewerkey'])."&type=message&data=".rawurlencode(json_encode($out)));
	}
	
	file_get_contents($config['publisherhost'].$streamID."?key=".rawurlencode($config['publisherkey'])."&type=message&data=".rawurlencode(json_encode($msg)));
}

function handleRequest(){
	global $streamID, $stream, $DB, $current_user;

	// Publish update
	if($_SERVER['REQUEST_METHOD'] == "POST" && $_POST['type'] == "update" && current_user_can("post message")){
		$allowedKinds = array("message");
		$kind = $_POST['kind'];
		// Is the kind supported?
		if(!in_array($kind, $allowedKinds)){
			return array("error" => "Invalid kind");
		}
		$published = false;
		$publisher = null;
		// Auto publish
		if(array_key_exists("auto publish", $stream['config']) && $stream['config']['autopublish']){
			$published = true;
			$publisher = $DB->users->createDBRef($current_user);
		}
		// Or the user have rights to self-publish
		if(current_user_can("publish message") && array_key_exists("publish", $_POST) && $_POST['publish']){
			$published = true;
			$publisher = $DB->users->createDBRef($current_user);
		}
		$saveData = array(
			"creator" => $DB->users->createDBRef($current_user),
			"time" => new MongoDate(),
			"stream" => $DB->streams->createDBRef($stream),
			"kind" => $kind,
			"published" => $published,
			"publisher" => $publisher,
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
		pushEvent($saveData);
		return $saveData;
	}else if(array_key_exists("act", $_GET)){
		$id = $_GET['id'];
		$message = $DB->messages->findOne(array("_id" => new MongoID($id)));
		if(!$message){
			return array("error" => "Invalid message ID.");
		}
		if($_GET['act'] == "publish" && current_user_can("publish message")){
			$message['published'] = !$message['published'];
			if($message['published']){
				$message['publisher'] = $DB->users->createDBRef($current_user);
			}
			$DB->messages->save($message);
			pushEvent($message);
			return $message;
		}else if($_GET['act'] == "delete" && current_user_can("delete message")){
			$DB->messages->remove(array("_id" => new MongoID($id)), array("justOne" => true));
			return true;
		}else{
			return array(
				"error" => "No/invalid action or no permission"
			);
		}
	}else{
		return array(
			"error" => "No/invalid action or no permission"
		);
	}
}

print json_encode(handleRequest());