<?php
/**
 * Config these
 */
$config = array(
	"host" => "mongodb://sora:sora@localhost:27017",
);
/**
 * Don't touch these
 */
$MONGO = new Mongo($config['host']."/sora");
$DB = $MONGO->sora;