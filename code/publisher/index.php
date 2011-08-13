<?php
include "lib.inc.php";
if(!is_logged_in()){
	header("Location: login.php");
	die();
}

// add new stream
if(array_key_exists("title", $_POST) && trim($_POST['title']) != ""){
	$DB->streams->insert(array(
		"config" => array(),
		"created" => new MongoDate(),
		"live" => null,
		"name" => $_POST['title'],
		"creator" => $DB->users->createDBRef($current_user),
	));
}

$per_page = 20;
if(array_key_exists("page", $_GET))
	$curPage = ((int) $_GET['page'])-1;
else
	$curPage = 0;

$q = $DB->streams->find()->sort(array("created" => -1));
$q->skip($curPage * $per_page);
$q->limit($per_page);

$SMARTY->assign("streams", $q);
$SMARTY->assign("page", $curPage+1);
$cnt = $DB->streams->count();
$SMARTY->assign("streamcount", $cnt);
// has next page?
$hasNext = false;
if($curPage+1 < ceil($cnt / $per_page)){
	$hasNext = true;
}
$SMARTY->assign("nextpage", $hasNext);
$SMARTY->assign("can_create", current_user_can("create stream"));

$SMARTY->display("streamlist.tpl");