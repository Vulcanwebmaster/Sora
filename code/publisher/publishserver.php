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
	$allowed = array("_id", "text", "time", "creator", "file", "published");
	$out = array();
	foreach($allowed as $allow){
		if(!isset($msg[$allow])) continue;
		$out[$allow] = $msg[$allow];
	}
	$out['_id'] = $out['_id']->{'$id'};
	if($msg['published']){
		$out2 = $out;
		$out2['creator'] = $DB->users->getDBRef($out['creator']);
		$out2['creator'] = $out2['creator']['name'];
			file_get_contents($config['viewerhost'].$streamID."?key=".rawurlencode($config['viewerkey'])."&type=message&data=".rawurlencode(json_encode($out2)));
	}
	$out['creator'] = $out['creator']['$id'];
	$out['time'] = date("j/n/y g:i:s A", $out['time']->sec);
	file_get_contents($config['publisherhost'].$streamID."?key=".rawurlencode($config['publisherkey'])."&type=message&data=".rawurlencode(json_encode($out)));
}

function handleRequest(){
	global $streamID, $stream, $DB, $current_user, $config;

	// Publish update
	if($_SERVER['REQUEST_METHOD'] == "POST" && $_POST['type'] == "update" && current_user_can("post message")){
		$allowedKinds = array("message");
		$published = false;
		$publisher = null;
		// Auto publish
		if(array_key_exists("autopublish", $stream['config']) && $stream['config']['autopublish']){
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
			"published" => $published,
			"publisher" => $publisher,
			"text" => $_POST['text']
		);
		if(trim($_POST['text']) == "" && !is_uploaded_file($_FILES['pic']['tmp_name'])){
			return array("error" => "Enter message or image");
		}
		if(is_uploaded_file($_FILES['pic']['tmp_name'])){
			// Get the file extension
			preg_match('~\.([a-zA-Z0-9]+)$~', $_FILES['pic']['name'], $extension);
			$fn = uniqid().$extension[0];
			// Then move it to the upload path
			// TODO: Make this more scalable, such as support for S3
			move_uploaded_file($_FILES['pic']['tmp_name'], $config['uploadpath'].$fn);
			$saveData['file'] = $fn;
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
		// Toggle publish status
		if($_GET['act'] == "publish" && current_user_can("publish message")){
			$message['published'] = !$message['published'];
			if($message['published']){
				$message['publisher'] = $DB->users->createDBRef($current_user);
			}
			$DB->messages->save($message);
			pushEvent($message);
			if(!$message['published']){
				$msg = array("delete" => $id);
				file_get_contents($config['viewerhost'].$streamID."?key=".rawurlencode($config['viewerkey'])."&type=message&data=".rawurlencode(json_encode($msg)));
			}
			return $message;
		// Delete message
		}else if($_GET['act'] == "delete" && current_user_can("delete message")){
			$msg = array("delete" => $id);
			if($message['published']){
				file_get_contents($config['viewerhost'].$streamID."?key=".rawurlencode($config['viewerkey'])."&type=message&data=".rawurlencode(json_encode($msg)));
			}
			file_get_contents($config['publisherhost'].$streamID."?key=".rawurlencode($config['publisherkey'])."&type=message&data=".rawurlencode(json_encode($msg)));
			if(isset($message['file'])){
				unlink($config['uploadpath'].$message['file']);
			}
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