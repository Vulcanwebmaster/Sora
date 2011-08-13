<?php
include "lib.inc.php";
if(!is_logged_in()){
	header("Location: login.php");
	die();
}