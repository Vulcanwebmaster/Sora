<?php
chdir("publisher");
include "lib.inc.php";
header("Content-Type: text/javascript");

$messages = $DB->messages->find(array('stream.$id' => new MongoId($_GET['stream']), 'published' => true), array("_id", "kind", "text", "time", "creator"));
$messages->sort(array("time" => -1));
$messages->limit(100);

$out = array();
foreach($messages as $v){
	$v['_id'] = $v['_id']->{'$id'};
	$v['creator'] = $DB->users->getDBRef($v['creator']);
	$v['creator'] = $v['creator']['name'];
	$out[] = $v;
}
print json_encode(array_reverse($out));