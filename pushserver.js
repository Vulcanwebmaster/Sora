// config this
var sharedSecret = "soraserver";

var express = require('express');
var app = express.createServer();
var io = require('socket.io').listen(app);

app.get('/:stream', function(req, res){
	res.contentType("text/plain");
	stream = req.param("stream");
	pass = req.param("key");
	type = req.param("type");
	if(pass != sharedSecret){
		res.send(403);
		return;
	}
	data = req.param("data");
	out = io.of('/'+stream).emit(type, JSON.parse(data));
	res.send("ok");
});
app.listen(parseInt(process.argv[2]) || 4000);