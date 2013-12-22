var io = require('socket.io').listen(8080);
var mongoose = require('mongoose')
	, models = require('./models')
	, spawn = require('child_process').spawn
	, routes = require('./routes')

mongoose.connect("mongodb://127.0.0.1/iorder", {
	auto_reconnect: true,
	native_parser: true
})

io.sockets.on('connection', function(socket) {
	console.log("Socket connected..");
	
	routes.router(socket);
})
io.set('log level', 1);