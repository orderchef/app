var mongoose = require('mongoose')
	, models = require('../models')
	, spawn = require('child_process').spawn

exports.router = function (socket) {
	socket.on('register', function(data) {
		console.log(models.printers);
		
		console.log("Registering a printer @"+data.ip + " called "+data.name);
		
		var printer = {
			socket: socket,
			name: data.name,
			ip: data.ip,
			prices: data.prices,
			category: data.category
		}
		
		var found = false;
		for (var i = 0; i < models.printers.length; i++) {
			if (models.printers[i].name == printer.name) {
				models.printers[i] = printer;
				found = true;
				break;
			}
		}
		
		if (!found) {
			models.printers.push(printer)
		}
	})
}