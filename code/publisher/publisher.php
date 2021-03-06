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
		foreach($configTypes as $k=>$type){
			@$v = $_POST[$k];
			if($type == "bool"){
				$v = (bool) $v;
			}else if($type == "int"){
				$v = (int) $v;
			}else if($type == "float"){
				$v = (float) $v;
			}
			$stream['config'][$k] = $v;
		}
		$DB->streams->save($stream);
	}else if($type == "metadata"){
		if(array_key_exists("delete", $_POST) && $_POST['delete']){
			$DB->streams->remove($stream, array("justOne"));
			header("Location: .");
			die();
		}else{
			$stream['name'] = $_POST['name'];
			$DB->streams->save($stream);
		}
	}else{
		die("Invalid save type!");
	}
	regenerate_html($stream);
}
if(array_key_exists("act", $_GET) && $_GET['act'] == "regenerate"){
	regenerate_html($stream);
}

$messages = $DB->messages->find(array('stream.$id' => $stream['_id']));
$messages->sort(array("time" => -1));
@$page = (int) $_GET['page'];
if(!$page){
	$page = 1;
}
$per_page = 100;
$messages->skip(($page-1)*$per_page);
$messages->limit($per_page);
$messages = iterator_to_array($messages, false);

require_once "mustache.php";
$m = new Mustache;
foreach($messages as $k=>$message){
	$message['creator'] = $message['creator']['$id'];
	$message['time'] = date("j/n/y g:i:s A", $message['time']->sec);
	$message = array_merge($message, array(
		"static" => $config['staticurl'],
		"can_action" => current_user_can("delete stream"),
		"can_post" => current_user_can("post message"),
		"can_publish" => current_user_can("publish message"),
		"can_delete" => current_user_can("delete message"),
	));
	$messages[$k] = $m->render(file_get_contents("templates/message.ms"), $message);
}

$totalMessages = $DB->messages->count(array('stream.$id' => $stream['_id']));
$hasNext = false;
if($page+1 < ceil($totalMessages / $per_page)){
	$hasNext = true;
}

$SMARTY->assign("stream", $stream);
$SMARTY->assign("messages", $messages);
$SMARTY->assign("total_message", $totalMessages);
$SMARTY->assign("page", $page);
$SMARTY->assign("nextpage", $hasNext);
$SMARTY->assign("can_action", current_user_can("delete stream"));
$SMARTY->assign("can_post", current_user_can("post message"));
$SMARTY->assign("can_publish", current_user_can("publish message"));
$SMARTY->assign("can_delete", current_user_can("delete message"));

$SMARTY->display("messages.tpl");