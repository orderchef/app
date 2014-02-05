var io = require('socket.io').listen(parseInt(process.env.PORT) || 8000);
var mongoose = require('mongoose')
	, models = require('./models')
	, spawn = require('child_process').spawn
	, routes = require('./routes')
	, bugsnag = require('bugsnag')

bugsnag.register('c987848f96714ef34560d05ef7e53b5d');

mongoose.connect("mongodb://127.0.0.1/iorder", {
	auto_reconnect: true,
	native_parser: true,
	server: {
		auto_reconnect: true
	}
})

io.sockets.on('connection', function(socket) {
	console.log("A Socket connected..");
	
	routes.router(socket);
})
io.set('log level', 1);