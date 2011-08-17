<?php
session_name("sora");
session_set_cookie_params(30*24*3600);
session_start();

include "../config.inc.php";
require "/usr/share/php/smarty3/Smarty.class.php";
/**
 * Smarty renderer with options set
 */
$SMARTY = new Smarty();
$SMARTY->setTemplateDir(dirname(__FILE__)."/templates");
$SMARTY->setCompileDir(dirname(__FILE__)."/smarty/templates_c");
$SMARTY->setCacheDir(dirname(__FILE__)."/smarty/cache");
$SMARTY->setConfigDir(dirname(__FILE__)."/smarty/configs");
$SMARTY->assign("static", "/static");
$SMARTY->assign("DB", $DB);

/**
 * Check the login status of current visitor
 * Also set $current_user and add the info
 * to $SMARTY
 * @return bool
 */
function is_logged_in(){
	global $DB, $current_user, $SMARTY;
	if(!array_key_exists("user", $_SESSION)) return false;
	$current_user = $DB->users->findOne(array("_id" => $_SESSION['user']));
	$SMARTY->assign("user", $current_user);
	return $current_user !== null;
}

/**
 * Check permission for current user
 * User levels:
 *   * 0: Reporter
 *   * 1: Publisher
 *   * 2: Root (allow all permissions)
 * @param string Permission name to check
 * @return bool
 */
function current_user_can($name){
	global $current_user;
	$permissions = array(
		"create stream" => 2,
		"delete stream" => 2,
		"post updates" => 0,
		"publish updates" => 1,
		"delete updates" => 1,
		"create user" => 2,
		"delete user" => 2,
	);
	if($current_user['role'] == 2){
		return true;
	}else{
		return $permissions[$name] <= $current_user['role'];
	}
}