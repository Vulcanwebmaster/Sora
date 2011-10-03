<?php
$config = array(
	// MongoDB Host
	// Format: mongodb://user:pass@hostname:port
	"host" => "mongodb://sora:sora@localhost:27017",
	// pushserver.js server for publisher backend
	// MUST include tailing slash
	"publisherhost" => "http://localhost:4000/",
	// MUST be accessible outside of your firewall
	"publisherurl" => "http://sora.whs.in.th:4000/",
	"publisherkey" => "soraserver",
	// pushserver.js server for viewer
	// MUST include tailing slash
	"viewerhost" => "http://localhost:4500/",
	// MUST be accessible outside of your firewall
	"viewerurl" => "http://sora.whs.in.th:4500/",
	"viewerkey" => "soraserver",
	// Full path to the static/images folder WITH trailing slash
	"uploadpath" => "/var/www/static/images/",
	"viewerpath" => "/var/www/static/viewer/",
	// /viewer/ /images/ are appended to the staticurl.
	"staticurl" => "http://sora.whs.in.th/static/",
);
