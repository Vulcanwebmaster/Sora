<?php
session_name("sora");
session_set_cookie_params(30*3600);
session_start();

include "../config.inc.php";
require "/usr/share/php/smarty3/Smarty.class.php";
$SMARTY = new Smarty();
$SMARTY->setTemplateDir(dirname(__FILE__)."/templates");
$SMARTY->setCompileDir(dirname(__FILE__)."/smarty/templates_c");
$SMARTY->setCacheDir(dirname(__FILE__)."/smarty/cache");
$SMARTY->setConfigDir(dirname(__FILE__)."/smarty/configs");
$SMARTY->assign("static", "/static");

function is_logged_in(){
	return false;
}