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
	
	socket.on('get.printers', function(data, cb) {
		console.log("Sending back printers..");
		
		var ps = [];
		for (var i = 0; i < models.printers.length; i++) {
			ps.push({
				name: models.printers[i].name,
				ip: models.printers[i].ip,
				prices: models.printers[i].prices,
				category: models.printers[i].category
			});
		}
		
		cb(ps);
	})
	
	socket.on('print', function(data) {
		console.log("Printing some data..");
		
		var receiptPrinterOnly = data.receiptPrinter;
		for (var i = 0; i < models.printers.length; i++) {
			if (models.printers[i].printsBill == receiptPrinterOnly) {
				console.log("Printing to", models.printers[i].name);
				console.log(data.data+"\n")
				models.printers[i].socket.emit('print_data', {
					data: data.data
				})
			}
		}
	})
}